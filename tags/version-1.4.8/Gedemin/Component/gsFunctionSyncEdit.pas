unit gsFunctionSyncEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  SynEdit, SynDBEdit, contnrs, VBParser, gdcFunction, db, SynEditKeyCmds,
  SynEditTypes, SynEditTextBuffer, prp_MessageConst;


type
  //lsEditable - строка видима и редактируема
  //lsReadOnly - сторка видима но нередактируема
  //lsShowOnly - строка видима.
  TgsLineState = (lsNone, lsEditable, lsReadOnly, lsShowOnly);
 // TgsLineStates = set of TgsLineState;

  TOnPaintGutter = procedure (AClip: TRect; FirstLine, LastLine: Integer) of object;
  TOnBeforePaint = procedure (Sender: TObject) of object;

type
  TgsFunctionSynEdit = class(TCustomDBSynEdit)
  private
    { Private declarations }
    FgdcFunction: TgdcFunction;
    FParser: TCustomParser;
    FDataSource: TDataSource;
    FUseParser: Boolean;
    FShowOnlyColor: Tcolor;
    FOnPaintGutter: TOnPaintGutter;
    FOnBeforePaint: TOnBeforePaint;
    procedure SetgdcFunction(const Value: TgdcFunction);
    procedure SetParser(const Value: TCustomParser);
    procedure SetUseParser(const Value: Boolean);
    procedure SetShowOnlyColor(const Value: Tcolor);
    procedure SetOnPaintGutter(const Value: TOnPaintGutter);
    procedure SetOnBeforePaint(const Value: TOnBeforePaint);
  protected
    FFirstLoad: Boolean;
    { Protected declarations }
    procedure UpdateData(Sender: TObject); override;
    procedure DoLinesInserted(FirstLine, Count: integer); override;
    procedure SetCaretXY(Value: TPoint); override;
    procedure SetCaretXYEx(CallEnsureCursorPos: Boolean; Value: TPoint); override;
    function GetReadOnly: boolean; overload; override;
    function GetReadOnly(Line: Integer): Boolean; reintroduce; overload;// override;
    procedure SetReadOnly(Value: boolean); override;

    function DoOnSpecialLineColors(Line: integer;
      var Foreground, Background: TColor): boolean; override;
    procedure PaintGutter(AClip: TRect; FirstLine, LastLine: integer); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // Если Flag = True, делает строку N только для чтения
    procedure LineShowOnly(const N: Integer;
      const Flag: Boolean);
    procedure UpdateRecord; override;
    procedure LoadMemo; override;
    procedure CodeComplite;
    procedure CodeCompliteEx(AUseParser: Boolean);
    procedure ExecuteCommand(Command: TSynEditorCommand; AChar: char;
      Data: pointer); override;
    procedure SaveToFile(FileName: string);
    procedure SaveMarksToStream(Stream: TStream);
    procedure LoadMarksFromStream(Stream: TStream);
    procedure SaveCaretXYToStream(Stream: TStream);
    procedure LoadCaretXYFromStream(Stream: TStream);
    procedure SaveStateToStream(Stream: TStream);
    procedure LoadStateFromStream(Stream: TStream);
    procedure Paint; override;
  published
    { Published declarations }
    property gdcFunction: TgdcFunction read FgdcFunction write SetgdcFunction;
    property Parser: TCustomParser read FParser write SetParser;
    property OnPaintGutter: TOnPaintGutter read FOnPaintGutter write SetOnPaintGutter;
    property OnBeforePaint: TOnBeforePaint read FOnBeforePaint write SetOnBeforePaint;
    property OnLoadData;
    // inherited properties
    property Align;
{$IFDEF SYN_COMPILER_4_UP}
    property Anchors;
    property Constraints;
{$ENDIF}
    property Color;
    {$IFNDEF SYN_KYLIX}
    property Ctl3D;
    {$ENDIF}
    property Enabled;
    property Font;
    property Height;
    property Name;
    property ParentColor;
    {$IFNDEF SYN_KYLIX}
    property ParentCtl3D;
    {$ENDIF}
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Tag;
    property Visible;
    property Width;
    // inherited events
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
{$IFDEF SYN_COMPILER_4_UP}
    {$IFNDEF SYN_KYLIX}
    property OnEndDock;
    {$ENDIF}
{$ENDIF}
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
{$IFDEF SYN_COMPILER_4_UP}
    {$IFNDEF SYN_KYLIX}
    property OnStartDock;
    {$ENDIF}
{$ENDIF}
    property OnStartDrag;
    // TCustomSynEdit properties
    property BookMarkOptions;
    property BorderStyle;
    property ExtraLineSpacing;
    property Gutter;
    property HideSelection;
    property Highlighter;
    property InsertCaret;
    property InsertMode;
    property Keystrokes;
    property MaxLeftChar;
    property MaxUndo;
    property Options;
    property OverwriteCaret;
    property ReadOnly;
    property RightEdge;
    property RightEdgeColor;
    property ScrollBars;
    property SelectedColor;
    property SelectionMode;
    property TabWidth;
    property WantTabs;
    // TCustomSynEdit events
    property OnChange;
    property OnCommandProcessed;
    property OnDropFiles;
    property OnGutterClick;
    property OnPaint;
    property OnPlaceBookmark;
    property OnProcessCommand;
    property OnProcessUserCommand;
    property OnReplaceText;
    property OnSpecialLineColors;
    property OnStatusChange;
    property OnPaintTransient;

    property UseParser: Boolean read FUseParser write SetUseParser;
    property ShowOnlyColor: TColor read FShowOnlyColor write SetShowOnlyColor;
  end;

procedure Register;

implementation
uses rp_BaseReport_unit, prp_PropertySettings;

procedure Register;
begin
  RegisterComponents('SynEdit', [TgsFunctionSynEdit]);
end;

{ TgsSynEdit }

procedure TgsFunctionSynEdit.CodeComplite;
begin
  CodeCompliteEx(FUseParser);
end;

procedure TgsFunctionSynEdit.CodeCompliteEx(AUseParser: Boolean);
var
  Script: TStrings;
  I: Integer;
  M: Boolean;
begin
  M := False;
  Script := TStringList.Create;
  try
    if Assigned(FgdcFunction) and FgdcFunction.Active then
    begin
      Script.Assign(Lines);
      for I := 0 to Script.Count - 1 do
        Script.Objects[I] := Pointer(-1);

      if Assigned(Parser) and AUseParser then
      begin
        //Обрабатываем скрипт парсером  в случае если
        //установлен язык VBScipt
        Parser.PrepareScript(FgdcFunction.FieldbyName('name').AsString,
          Script);
        for I := 0 to Script.Count - 1 do
        begin
          if Integer(Script.Objects[I]) = 0 then
          begin
            Lines.Insert(I, Script[I]);
            DoLinesInserted(I + 1, 1);
            M := True;
          end;
        end;
      end;
    end;
    if M then
    begin
      Modified := M;
      if Assigned(OnChange) then
        OnChange(Self);
    end;
  finally
    Script.Free;
  end;
end;

constructor TgsFunctionSynEdit.Create(AOwner: TComponent);
begin
  inherited;

  FDataSource := TDataSource.Create(nil);
  DataSource := FDataSource;
  FFirstLoad := True;
end;

destructor TgsFunctionSynEdit.Destroy;
begin
  inherited;
  FDataSource.Free;
end;

procedure TgsFunctionSynEdit.DoLinesInserted(FirstLine, Count: integer);
var
  I: Integer;
begin
  inherited;

  for I := FirstLine - 1 to FirstLine + Count - 2 do
    Lines.Objects[I] := Pointer(lsEditable);
end;

function TgsFunctionSynEdit.DoOnSpecialLineColors(Line: integer;
  var Foreground, Background: TColor): boolean;
begin
  Result := inherited DoOnSpecialLineColors(Line, Foreground, Background);
  if not Result and GetReadOnly(Line) then
  begin
    Foreground := FShowOnlyColor;
    Result := True;
  end
end;

procedure TgsFunctionSynEdit.ExecuteCommand(Command: TSynEditorCommand;
  AChar: char; Data: pointer);
var
  Flag: Boolean;
begin
  IncPaintLock;
  try
    case Command of
      ecCodeComplite: CodeComplite;
      {ecDeleteLastChar,} ecDeleteChar:
      begin
        Flag := ReadOnly;
        if not Flag then
          Flag := not SelAvail and (TgsLineState(Lines.Objects[CaretY]) in
            [lsReadOnly, lsShowOnly]) and (CaretX > Length(Lines[CaretY - 1]));
        if not Flag then
          inherited;
      end;
    else
      inherited
    end;
  finally
    DecPaintLock;
  end;
end;

function TgsFunctionSynEdit.GetReadOnly: boolean;
begin
  Result := (not SelAvail and (TgsLineState(Lines.Objects[CaretY - 1]) in
    [lsReadOnly, lsShowOnly])) or (SelAvail and ((TgsLineState(Lines.Objects[BlockBegin.Y - 1]) in
    [lsReadOnly, lsShowOnly]) or (TgsLineState(Lines.Objects[BlockEnd.Y - 1]) in
    [lsReadOnly, lsShowOnly])));
end;



function TgsFunctionSynEdit.GetReadOnly(Line: Integer): Boolean;
begin
  Result := TgsLineState(Lines.Objects[Line - 1]) in
    [lsReadOnly, lsShowOnly];
end;

procedure TgsFunctionSynEdit.LineShowOnly(const N: Integer;
  const Flag: Boolean);
begin
  if (N > -1) and (N < Lines.Count) then
    if Flag then
      Lines.Objects[N] := Pointer(lsShowOnly)
    else
      Lines.Objects[N] := Pointer(lsEditable);
end;

procedure TgsFunctionSynEdit.LoadCaretXYFromStream(Stream: TStream);
var
  C: TPoint;
begin
  if not Assigned(Stream) then
    raise Exception.Create(MSG_STREAM_DO_NOT_INIT);

  if Stream.Size = 0 then
    Exit;
  Stream.ReadBuffer(C, SizeOf(C));
  IncPaintLock;
  if FFirstLoad then C.X := 1;
  CaretXY := C;
  DecPaintLock;
end;

procedure TgsFunctionSynEdit.LoadMarksFromStream(Stream: TStream);
var
  I: Integer;
  Buf: Integer;
  BoolBuf: Boolean;
  lCount: Integer;
  M: TSynEditMark;
begin
  if not Assigned(Stream) then
    raise Exception.Create(MSG_STREAM_DO_NOT_INIT);

  for I := FMarkList.Count - 1 downto 0 do
    FMarkList.Delete(I);

  for I := 0 to 9 do
    fBookMarks[I] := nil;

  if Stream.Size = 0 then
    Exit;

  Stream.ReadBuffer(lCount, SizeOf(lCount));
  for I := 0 to lCount - 1 do
  begin
    M := TSynEditMark.Create(Self);
    with M do
    begin
      Stream.ReadBuffer(Buf, SizeOf(Buf));
      Line := Buf;
      Stream.ReadBuffer(Buf, SizeOf(Buf));
      Column := Buf;
      Stream.ReadBuffer(Buf, SizeOf(Buf));
      BookmarkNumber := Buf;
      Stream.ReadBuffer(Buf, SizeOf(Buf));
      ImageIndex := Buf;
      Stream.ReadBuffer(BoolBuf, SizeOf(BoolBuf));
      Visible := BoolBuf;
    end;
    fMarkList.Add(M);
    if M.BookmarkNumber in [0..9] then
      fBookMarks[M.BookmarkNumber] := M;
  end;
end;

procedure TgsFunctionSynEdit.LoadMemo;
var
//  CP: TPoint;
  Str: TStream;
begin
  Lines.BeginUpdate;
  try
//    CP := CaretXY;
    if Assigned(FgdcFunction) and FgdcFunction.Active then
      Lines.Text :=  gdcFunction.FieldByName('Script').AsString;


    Str := gdcFunction.CreateBlobStream(gdcFunction.FieldByName('editorstate'),
      DB.bmRead);
    try
      LoadStateFromStream(Str);
    finally
      Str.Free;
    end;
  finally
    Lines.EndUpdate;
    Modified := False;
    if FFirstLoad then FFirstLoad := False;
//    CaretXY := CP;
    ClearUndo;
  end;
end;

procedure TgsFunctionSynEdit.LoadStateFromStream(Stream: TStream);
begin
  if PropertySettings.GeneralSet.AutoSaveCaretPos then
  begin
    LoadMarksFromStream(Stream);
    LoadCaretXYFromStream(Stream);
  end;  
end;

procedure TgsFunctionSynEdit.Paint;
begin
  if Assigned(FOnBeforePaint) then
    FOnBeforePaint(Self);
    
  inherited;
end;

procedure TgsFunctionSynEdit.PaintGutter(AClip: TRect; FirstLine,
  LastLine: integer);
begin
  inherited;

  if Assigned(FOnPaintGutter) then
    FOnPaintGutter(AClip, FirstLine, LastLine);
end;



procedure TgsFunctionSynEdit.SaveCaretXYToStream(Stream: TStream);
var
  C: TPoint;
begin
  if not Assigned(Stream) then
    raise Exception.Create(MSG_STREAM_DO_NOT_INIT);

  C := CaretXY;
  Stream.WriteBuffer(C, SizeOf(C));
end;

procedure TgsFunctionSynEdit.SaveMarksToStream(Stream: TStream);
var
  I: Integer;
  Buf: Integer;
  BoolBuf: Boolean;
begin
  if not Assigned(Stream) then
    raise Exception.Create(MSG_STREAM_DO_NOT_INIT);

  Buf := FMarkList.Count;
  Stream.WriteBuffer(Buf, SizeOf(Buf));
  for I := 0 to FMarkList.Count - 1 do
  begin
    with FMarkList[I] do
    begin
      Buf := Line;
      Stream.WriteBuffer(Buf, SizeOf(Buf));
      Buf := Column;
      Stream.WriteBuffer(Buf, SizeOf(Buf));
      Buf := BookmarkNumber;
      Stream.WriteBuffer(Buf, SizeOf(Buf));
      Buf := ImageIndex;
      Stream.WriteBuffer(Buf, SizeOf(Buf));
      BoolBuf := Visible;
      Stream.WriteBuffer(BoolBuf, SizeOf(BoolBuf));
    end;
  end;
end;

procedure TgsFunctionSynEdit.SaveStateToStream(Stream: TStream);
begin
  if PropertySettings.GeneralSet.AutoSaveCaretPos then
  begin
    SaveMarksToStream(Stream);
    SaveCaretXYToStream(Stream);
  end;  
end;

procedure TgsFunctionSynEdit.SaveToFile(FileName: string);
var
  BlobStream: TStream;
  lLines: TStrings;
begin
  lLines := TStringList.Create;
  try
    if FDataLink.Field.IsBlob then
    begin
      BlobStream := FDataLink.DataSet.CreateBlobStream(FDataLink.Field, bmRead);
      try
        lLines.LoadFromStream(BlobStream);
      finally
        BlobStream.Free;
      end;
    end else
      lLines.Text := FDataLink.Field.AsString;

    lLines.SaveToFile(FileName);
  finally
    lLines.Free;
  end;
end;

procedure TgsFunctionSynEdit.SetCaretXY(Value: TPoint);
begin
  inherited;
end;

procedure TgsFunctionSynEdit.SetCaretXYEx(CallEnsureCursorPos: Boolean;
  Value: TPoint);
begin
  inherited;
end;

procedure TgsFunctionSynEdit.SetgdcFunction(const Value: TgdcFunction);
begin
  FgdcFunction := Value;
  FDataSource.DataSet := Value;
  DataField := 'SCRIPT';
end;

procedure TgsFunctionSynEdit.SetOnBeforePaint(const Value: TOnBeforePaint);
begin
  FOnBeforePaint := Value;
end;

procedure TgsFunctionSynEdit.SetOnPaintGutter(const Value: TOnPaintGutter);
begin
  FOnPaintGutter := Value;
end;

procedure TgsFunctionSynEdit.SetParser(const Value: TCustomParser);
begin
  FParser := Value;
end;

procedure TgsFunctionSynEdit.SetReadOnly(Value: boolean);
begin
end;

procedure TgsFunctionSynEdit.SetShowOnlyColor(const Value: Tcolor);
begin
  FShowOnlyColor := Value;
end;

procedure TgsFunctionSynEdit.SetUseParser(const Value: Boolean);
begin
  FUseParser := Value;
end;

procedure TgsFunctionSynEdit.UpdateData(Sender: TObject);
begin
  if Assigned(FDataLink) and Assigned(FDataLink.Field) then
    FDataLink.Field.AsString := Lines.Text;
end;

procedure TgsFunctionSynEdit.UpdateRecord;
var
  Str: TStream;
begin
  Str := gdcFunction.CreateBlobStream(gdcFunction.FieldByName('editorstate'),
    DB.bmWrite);
  try
    Str.Size := 0;
    SaveStateToStream(Str);
  finally
    Str.Free;
  end;

  if Modified then
    UpdateData(Self)
  else
    FDataLink.UpdateRecord;
end;

end.
