// ShlTanya, 20.02.2019

unit syn_ManagerInterface_body_unit;

interface

uses
  syn_ManagerInterface_unit, Classes, SynEditHighlighter, SysUtils, Graphics,
  SynEdit, SynEditKeyCmds;

const
  SM_SYNC_COUNT = 3;
  SM_SYNC_COUNT1 = 4;
  SM_SYNC_PATH  = 'Options\SynOptions\';

type
  TSynManager = class(TComponent, ISynManager)
  private
    FVBSHighLighter, FJSHighLighter, FSQLHighLighter: TSynCustomHighLighter;
    FFont: TFont;
    FDefault, FClassic, FNewClassic, FVisualStudio: TSynEditKeyStrokes;
    FKeyStrokesIndex: Integer;

    function Get_Component: TObject;
    procedure GetHighlighterOptions(const AnHighLighter: TSynCustomHighLighter);
    function GetHighlighterFont: TFont;
    procedure SaveToStream(const AnStream: TStream);
    procedure LoadFromStream(const AnStream: TStream);
    function ExecuteDialog: Boolean;
    procedure GetSynEditOptions(const ASynEdit: TSynEdit);
    procedure ResetProperty;
    function GetKeyStroke: TSynEditKeyStrokes;
  protected
    procedure SaveCustomToStream(const AnSynHighLighter: TSynCustomHighLighter;
     const AnStream: TStream);
    procedure LoadCustomFromStream(const AnSynHighLighter: TSynCustomHighLighter;
     const AnStream: TStream);
    procedure SaveFontToStream(AnFont: TFont; const AnStream: TStream);
    procedure LoadFontFromStream(AnFont: TFont; const AnStream: TStream);
    function GetKeyStrokes(Index: Integer): TSynEditKeyStrokes;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TWriterCracker = class(TWriter);
  TReaderCracker = class(TReader);
  TPersistentCracker = class(TPersistent);

procedure Register;

implementation

uses
  SynHighlighterVBScript, SynHighlighterJScript, SynHighlighterSQL,
  syn_dlgOptionsManager_unit, Windows, TypInfo, Storages;

{ TSynManager }

constructor TSynManager.Create(AnOwner: TComponent);
begin
  Assert(SynManager = nil);

  inherited Create(AnOwner);

  FVBSHighLighter := TSynVBScriptSyn.Create(nil);
  FVBSHighLighter.CommentAttribute.Foreground := clRed;
  FVBSHighLighter.StringAttribute.Foreground := clBlue;
  FJSHighLighter := TSynJScriptSyn.Create(nil);
  //Настройка SQL редактора по-умолчанию
  FSQLHighLighter := TSynSQLSyn.Create(nil);
  (FSQLHighLighter as TSynSQLSyn).SQLDialect := sqlInterbase6;
  (FSQLHighLighter as TSynSQLSyn).SymbolAttri.Foreground := clNone;
  (FSQLHighLighter as TSynSQLSyn).SymbolAttri.Background := clNone;
  (FSQLHighLighter as TSynSQLSyn).NumberAttri.Style := [];
  (FSQLHighLighter as TSynSQLSyn).IdentifierAttri.Style := [];
  (FSQLHighLighter as TSynSQLSyn).KeyAttri.Style := [fsBold];
  (FSQLHighLighter as TSynSQLSyn).TableNameAttri.Foreground := clGreen;
  (FSQLHighLighter as TSynSQLSyn).TableNameAttri.Style := [fsUnderline];

  FFont := TFont.Create;
  FFont.Size := 10;
  FFont.Charset := RUSSIAN_CHARSET;
  FFont.Name := 'Courier New';

  FDefault:= TSynEditKeyStrokes.Create(nil);
  ResetDefaultDefaults(FDefault);
  FClassic:= TSynEditKeyStrokes.Create(nil);
  ResetClassicDefaults(FClassic);
  FNewClassic:= TSynEditKeyStrokes.Create(nil);
  FNewClassic.ResetDefaults;
  FVisualStudio:= TSynEditKeyStrokes.Create(nil);
  FVisualStudio.ResetDefaults;
  ResetProperty;

  SynManager := Self;
end;

destructor TSynManager.Destroy;
begin
  FreeAndNil(FVBSHighLighter);
  FreeAndNil(FJSHighLighter);
  FreeAndNil(FSQLHighLighter);
  FreeAndNil(FFont);

  FDefault.Free;
  FClassic.Free;
  FNewClassic.Free;
  FVisualStudio.Free;
//  FreeAndNil(FSynEdit);

  if Assigned(SynManager) and (SynManager.Get_Component = Self) then
    SynManager := nil;

  inherited Destroy;
end;

function TSynManager.ExecuteDialog: Boolean;
var
  MS: TMemoryStream;
begin
  with TdlgOptionsManager.Create(nil) do
  try
    SynJScriptSyn1.Assign(FJSHighLighter);
    SynVBScriptSyn1.Assign(FVBSHighLighter);
    SynSQLSyn1.Assign(FSQLHighLighter);
    seTestScript.Font.Assign(FFont);

    if FDefault.Count > 0 then
      Default.KeyStrokes.Assign(FDefault);
    if FClassic.Count > 0 then
      Classic.KeyStrokes.Assign(FClassic);
    KeyStrokesIndex := FKeyStrokesIndex;
    with SynEditProperty do
    begin
      cbAutoIndentMode.Checked := AutoIndentMode;
      cbInsertMode.Checked := InsertMode;
      cbSmartTab.Checked := SmartTab;
      cbTabToSpaces.Checked := TabToSpaces;
      cbGroupUndo.Checked := GroupUndo;
      cbCursorBeyondEOF.Checked := CursorBeyondEOF;
      cbUndoAfterSave.Checked := UndoAfterSave;
      cbKeepTrailingBlanks.Checked := KeepTrailingBlanks;
      cbFindTextAtCursor.Checked := FindTextAtCursor;
      cbUseSyntaxHighLight.Checked := UseSyntaxHilight;
      cbVisibleRightMargine.Checked := VisibleRightMargine;
      cbVisibleGutter.Checked := VisibleGutter;
      cbRightMargin.Text := IntToStr(RightMargin);
      cbGutterWidth.Text := IntToStr(GutterWidth);
      cbUndoLimit.Text := IntToStr(UndoLimit);
      cbTabStops.Text := IntToStr(TabWidth);
    end;
    Result := Execute;
    if Result then
    begin
      FJSHighLighter.Assign(SynJScriptSyn1);
      FVBSHighLighter.Assign(SynVBScriptSyn1);
      FSQLHighLighter.Assign(SynSQLSyn1);
      FFont.Assign(seTestScript.Font);

      FDefault.Assign(Default.KeyStrokes);
      FClassic.Assign(Classic.KeyStrokes);
//      FNewClassic.Assign(NewClassic.KeyStrokes);
//      FVisualStudio.Assign(VisualStudio.KeyStrokes);
      FKeyStrokesIndex := KeyStrokesIndex;

      with SynEditProperty do
      begin
        AutoIndentMode := cbAutoIndentMode.Checked;
        InsertMode := cbInsertMode.Checked;
        SmartTab := cbSmartTab.Checked;
        TabToSpaces := cbTabToSpaces.Checked;
        GroupUndo := cbGroupUndo.Checked;
        CursorBeyondEOF := cbCursorBeyondEOF.Checked;
        UndoAfterSave := cbUndoAfterSave.Checked;
        KeepTrailingBlanks := cbKeepTrailingBlanks.Checked;
        FindTextAtCursor := cbFindTextAtCursor.Checked;
        UseSyntaxHilight := cbUseSyntaxHighLight.Checked;
        VisibleRightMargine := cbVisibleRightMargine.Checked;
        VisibleGutter := cbVisibleGutter.Checked;
        RightMargin := StrToInt(cbRightMargin.Text);
        GutterWidth := StrToInt(cbGutterWidth.Text);
        UndoLimit := StrToInt(cbUndoLimit.Text);
        TabWidth := StrToInt(cbTabStops.Text);
      end;

      if Assigned(UserStorage) and Assigned(SynManager) then
      begin
        MS := TMemoryStream.Create;
        try
          SynManager.SaveToStream(MS);
          MS.Position := 0;
          UserStorage.WriteStream(SM_SYNC_PATH, 'DATA', MS);
        finally
          MS.Free;
        end;
      end;
    end;
  finally
    Free;
  end;
end;

function TSynManager.GetHighlighterFont: TFont;
begin
  Result := FFont;
end;

procedure TSynManager.GetHighlighterOptions(const AnHighLighter: TSynCustomHighLighter);
begin
  if AnHighLighter is TSynVBScriptSyn then
    AnHighLighter.Assign(FVBSHighLighter)
  else
    if AnHighLighter is TSynJScriptSyn then
      AnHighLighter.Assign(FJSHighLighter)
    else
      if AnHighLighter is TSynSQLSyn then
        AnHighLighter.Assign(FSQLHighLighter)
      else
        raise Exception.Create('Not supported');
  if Assigned(AnHighLighter) then
    AnHighLighter.Enabled := SynEditProperty.UseSyntaxHilight;
end;

function TSynManager.GetKeyStroke: TSynEditKeyStrokes;
begin
  Result := GetKeyStrokes(FKeyStrokesIndex);
end;

function TSynManager.GetKeyStrokes(Index: Integer): TSynEditKeyStrokes;
begin
  Result := nil;
  if (Index > - 1) and (Index < 4) then
  begin
    case Index of
      0: Result := FDefault;
      1: Result := FClassic;
      2: Result := FNewClassic;
      3: Result := FVisualStudio;
    end;
  end;
end;

procedure TSynManager.GetSynEditOptions(const ASynEdit: TSynEdit);
begin
  if Assigned(ASynEdit) then
  begin
    ASynEdit.Keystrokes.Assign(GetKeyStrokes(FKeyStrokesIndex));
    with SynEditProperty do
    begin
      if AutoIndentMode then
        ASynEdit.Options :=  ASynEdit.Options + [eoAutoIndent]
      else
        ASynEdit.Options :=  ASynEdit.Options - [eoAutoIndent];

      ASynEdit.InsertMode := InsertMode;

      if SmartTab then
        ASynEdit.Options :=  ASynEdit.Options + [eoSmartTabs]
      else
        ASynEdit.Options :=  ASynEdit.Options - [eoSmartTabs];

      if TabToSpaces then
        ASynEdit.Options :=  ASynEdit.Options + [eoTabsToSpaces]
      else
        ASynEdit.Options :=  ASynEdit.Options - [eoTabsToSpaces];

      if GroupUndo then
        ASynEdit.Options := ASynEdit.Options + [eoGroupUndo]
      else
        ASynEdit.Options := ASynEdit.Options - [eoGroupUndo];

      if CursorBeyondEOF then
        ASynEdit.Options :=  ASynEdit.Options + [eoScrollPastEof]
      else
        ASynEdit.Options :=  ASynEdit.Options - [eoScrollPastEof];

      if KeepTrailingBlanks then
        ASynEdit.Options := ASynEdit.Options + [eoScrollPastEol]
      else
        ASynEdit.Options := ASynEdit.Options - [eoScrollPastEol];

      if VisibleRightMargine then
        ASynEdit.RightEdge := RightMargin
      else
        ASynEdit.RightEdge := -1;

      ASynEdit.Gutter.Visible := VisibleGutter;
      ASynEdit.Gutter.Width := GutterWidth;
      ASynEdit.MaxUndo := UndoLimit;
      ASynEdit.TabWidth := TabWidth;
    end;
  end;
end;

function TSynManager.Get_Component: TObject;
begin
  Result := Self;
end;

procedure TSynManager.LoadCustomFromStream(
  const AnSynHighLighter: TSynCustomHighLighter; const AnStream: TStream);
var
  I, TempInt: Integer;
  TempColor: TColor;
  Count: Integer;
  Eqv: Boolean;
begin
  Assert(SizeOf(AnSynHighLighter.Attribute[I].IntegerStyle) = SizeOf(TempInt));
  AnStream.ReadBuffer(TempInt, SizeOf(AnSynHighLighter.AttrCount));

  //Для поддержки баз со старым экзешником
  Eqv := True;
  if AnSynHighLighter.AttrCount <> TempInt then
  begin
    Count := TempInt - 1;
    Eqv := False;
  end else
    Count := AnSynHighLighter.AttrCount - 1;

  for I := 0 to Count do
  begin //Проверка нужна, что бы загрузить правильно базу со старым SynEdit
    if Eqv or not ((AnSynHighLighter.Attribute[I].Name = 'Conditional Comment') or
      (AnSynHighLighter.Attribute[I].Name = 'Delimited Identifier') or
      (AnSynHighLighter.Attribute[I].Name = 'Table Name')) then
    begin
      AnStream.ReadBuffer(TempColor, SizeOf(AnSynHighLighter.Attribute[I].Background));
      AnSynHighLighter.Attribute[I].Background := TempColor;
      AnStream.ReadBuffer(TempColor, SizeOf(AnSynHighLighter.Attribute[I].Foreground));
      AnSynHighLighter.Attribute[I].Foreground := TempColor;
      AnStream.ReadBuffer(TempInt, SizeOf(AnSynHighLighter.Attribute[I].IntegerStyle));
      AnSynHighLighter.Attribute[I].IntegerStyle := TempInt;
    end;
  end;
end;

procedure TSynManager.LoadFontFromStream(AnFont: TFont; const AnStream: TStream);
var
  Reader: TReaderCracker;
begin
  Reader := TReaderCracker.Create(AnStream, AnStream.Size - AnStream.Position);
  try
    Reader.ReadListBegin;
    while not Reader.EndOfList do
      Reader.ReadProperty(FFont);
    Reader.ReadListEnd;
  finally
    Reader.Free;
  end;
end;

procedure TSynManager.LoadFromStream(const AnStream: TStream);
var
  I: Integer;
begin
  if AnStream.Position >= AnStream.Size then
    Exit;
  I := 0;
  AnStream.ReadBuffer(I, SizeOf(SM_SYNC_COUNT));

  LoadCustomFromStream(FVBSHighLighter, AnStream);
  LoadCustomFromStream(FJSHighLighter, AnStream);
  LoadCustomFromStream(FSQLHighLighter, AnStream);
  if AnStream.Position < AnStream.Size then
    LoadFontFromStream(FFont, AnStream);

  if I >= SM_SYNC_COUNT1 then
  begin
    FDefault.LoadFromStream(AnStream);
    FClassic.LoadFromStream(AnStream);
    FNewClassic.LoadFromStream(AnStream);
    FVisualStudio.LoadFromStream(AnStream);
    AnStream.ReadBuffer(FKeyStrokesIndex, SizeOf(FKeyStrokesIndex));

    AnStream.ReadBuffer(SynEditProperty, SizeOf(SynEditProperty));
  end;
end;


procedure TSynManager.ResetProperty;
begin
  with SynEditProperty do
  begin
    AutoIndentMode := True;
    InsertMode := True;
    SmartTab := True;
    TabToSpaces := False;
    GroupUndo := True;
    CursorBeyondEOF := False;
    UndoAfterSave := False;
    KeepTrailingBlanks := True;
    FindTextAtCursor := True;
    UseSyntaxHilight := True;
    VisibleRightMargine := True;
    VisibleGutter := True;
    RightMargin := 80;
    GutterWidth := 30;
    UndoLimit := 1024;
    TabWidth := 8;
  end;
end;

procedure TSynManager.SaveCustomToStream(
  const AnSynHighLighter: TSynCustomHighLighter; const AnStream: TStream);
var
  I, TempInt: Integer;
begin
  TempInt := AnSynHighLighter.AttrCount;
  AnStream.Write(TempInt, SizeOf(AnSynHighLighter.AttrCount));
  for I := 0 to AnSynHighLighter.AttrCount - 1 do
  begin
    AnStream.Write(AnSynHighLighter.Attribute[I].Background,
     SizeOf(AnSynHighLighter.Attribute[I].Background));
    AnStream.Write(AnSynHighLighter.Attribute[I].Foreground,
     SizeOf(AnSynHighLighter.Attribute[I].Foreground));
    TempInt := AnSynHighLighter.Attribute[I].IntegerStyle;
    AnStream.Write(TempInt, SizeOf(AnSynHighLighter.Attribute[I].IntegerStyle));
  end;
end;

procedure TSynManager.SaveFontToStream(AnFont: TFont; const AnStream: TStream);
var
  I, Count: Integer;
  PropInfo: PPropInfo;
  PropList: PPropList;
  Writer: TWriterCracker;
begin
  Writer := TWriterCracker.Create(AnStream, 4096);
  try
    Writer.WriteListBegin;
    Count := GetTypeData(AnFont.ClassInfo)^.PropCount;
    if Count > 0 then
    begin
      GetMem(PropList, Count * SizeOf(Pointer));
      try
        GetPropInfos(AnFont.ClassInfo, PropList);
        for I := 0 to Count - 1 do
        begin
          PropInfo := PropList^[I];
          if PropInfo = nil then
            Break;
          Writer.WriteProperty(AnFont, PropInfo);
        end;
      finally
        FreeMem(PropList, Count * SizeOf(Pointer));
      end;
    end;
    TPersistentCracker(AnFont).DefineProperties(Writer);
    Writer.WriteListEnd;
  finally
    Writer.Free;
  end;
end;

procedure TSynManager.SaveToStream(const AnStream: TStream);
var
  I: Integer;
begin
  I := SM_SYNC_COUNT1;
  AnStream.Write(I, SizeOf(SM_SYNC_COUNT));
  SaveCustomToStream(FVBSHighLighter, AnStream);
  SaveCustomToStream(FJSHighLighter, AnStream);
  SaveCustomToStream(FSQLHighLighter, AnStream);
  SaveFontToStream(FFont, AnStream);

  FDefault.SaveToStream(AnStream);
  FClassic.SaveToStream(AnStream);
  FNewClassic.SaveToStream(AnStream);
  FVisualStudio.SaveToStream(AnStream);
  AnStream.WriteBuffer(FKeyStrokesIndex, SizeOf(FKeyStrokesIndex));

  AnStream.WriteBuffer(SynEditProperty, SizeOf(SynEditProperty));
end;

procedure Register;
begin
  RegisterComponents('gsNew', [TSynManager]);
end;

end.

