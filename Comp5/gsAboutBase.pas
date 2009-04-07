unit gsAboutBase;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, xMsgBox, gsMultilingualSupport;

const
  ImageDef = 18555; { must be unique identifier }
  IconHelp = 18556; { must be unique identifier }

type
  THelpData = Record
    CompName: String;
    Info: String;
  end;

type
  TArHelpData = array of THelpData;

type
  THelpList = Record
    Count: Integer;
    Data: TArHelpData;
  end;

type
  TgsAbout = class(TImage)
  private
    { Private declarations }
    FListName: THelpList;
    FFileName: String;
    FActiveData: Boolean;
//    xMessageBox: TxMessageBox;
    BMPResurce: TBitmap;
    procedure WMDrop(var Message: TMessage);
      message WM_DROPFILES;
  protected
    { Protected declarations }
    procedure Loaded; override;
    procedure LoadData;
    procedure SortData;
    procedure PrepeareComp;
    procedure FindHelp(CompName: String);
    procedure SetFileName(const Value: String);
    //procedure OnEndDrag(Sender, Target: TObject; X, Y: Integer); override;
  public
    { Public declarations }
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
    procedure OnDO(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure OnED(Sender, Target: TObject; X, Y: Integer);
    property ActiveData: Boolean read FActiveData;
  published
    { Published declarations }
    property FileName: String read FFileName write SetFileName;
  end;

//procedure Register;

implementation

{$R About.res}

const
  STR_ARTICLE = '^A';

constructor TgsAbout.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FFileName := '';
  if xMessageBox = nil then
  begin
    xMessageBox := TxMessageBox.Create(Self.Parent);
    xMessageBox.Alignment := taLeftJustify;
    xMessageBox.Font.Charset := RUSSIAN_CHARSET;
    xMessageBox.SubtitleFont.Charset := RUSSIAN_CHARSET;
  end;
  if (csDesigning in ComponentState) and (Picture.Width = 0) and (Picture.Height = 0) then
  begin
    Self.DragCursor := crHelp;
    AutoSize := True;
    Picture.Bitmap.LoadFromResourceName(hInstance, 'ICONHELP');// LoadFromFile('d:\golden\comp5\Help.bmp');
  end;
  Hint := 'ѕеретащите вопрос на интересующий вас объект';
  ShowHint := True;
 { Self.Picture.Bitmap := TBitmap.Create;
  Self.Picture.Bitmap.LoadFromResourceName(hInstance, 'VOPROS');
  Self.AutoSize := True;}
end;

destructor TgsAbout.Destroy;
begin
  xMessageBox.Free;

  inherited Destroy;
end;

procedure TgsAbout.SetFileName(const Value: String);
begin
  if FFileName <> Value then
  begin
    FFileName := Value;

    //if not (csDesigning in ComponentState) {and (Pos('%d', FFileName) = 1)} then
     // FFileName := RealFileName(FFileName);
  end;
end;

procedure TgsAbout.Loaded;
begin
  inherited Loaded;

  DragMode := dmAutomatic;
  Transparent := True;
  OnEndDrag := Self.OnED;
  FActiveData := False;
  LoadData;
end;

procedure TgsAbout.LoadData;
var
  TheName: TextFile;
  S: String;
  I: Integer;
begin
  FListName.Count := 1000;
  SetLength(FListName.Data, 1000);
  if FileExists(ExtractFilePath(Application.ExeName) + FFileName) then
  begin
    AssignFile(TheName, ExtractFilePath(Application.ExeName) + FFileName);
    Reset(TheName);
    try
      I := 0;
      S := '';
      while not Eof(TheName) do
      begin
        while (S <> STR_ARTICLE) and (not Eof(TheName)) do
        begin
          Readln(TheName, S);
        end;
          Readln(TheName, FListName.Data[I].CompName);
          S := FListName.Data[I].CompName;
          FListName.Data[I].CompName := AnsiUpperCase(FListName.Data[I].CompName);
          FListName.Data[I].Info := '';
        while ((S <> STR_ARTICLE) and (S <> '')) and (not Eof(TheName)) do
        begin
          Readln(TheName, S);
          FListName.Data[I].Info := FListName.Data[I].Info + S + #10#13;
        end;
        FListName.Data[I].Info := Copy(FListName.Data[I].Info, 1,
         Length(FListName.Data[I].Info) - 4);
        Inc(I);
      end;
      FActiveData := True;
    finally
      CloseFile(TheName);
      if FActiveData then
      begin
        FListName.Count := I - 1;
        SetLength(FListName.Data, I - 1);
        SortData;
      end else begin
        FListName.Count := 0;
        SetLength(FListName.Data, 0);
      end;
    end;
  end;
end;

procedure TgsAbout.PrepeareComp;
var
  I: Integer;
begin
 { for I := 0 to Self.Parent.ComponentCount - 1 do
  begin
    if (Self.Parent.Components[I] is TWinControl) then
      (Self.Parent.Components[I] as Self.Parent.Components[I].ClassType).OnDragOver := nil;
     // (Self.Parent.Components[I] as TPanel).OnDragOver := nil;
  end; }
end;

procedure TgsAbout.SortData;
var
  I, J, Index: Integer;
  Temp: THelpData;
  S: String;
begin
  for I := 0 to FListName.Count - 1 do
  begin
    S := '€€€€€€';
    Index := -1;
    for J := I to FListName.Count - 1 do
    begin
      if S > FListName.Data[J].CompName then
      begin
        S := FListName.Data[J].CompName;
        Index := J;
      end;
    end;
    if Index > -1 then
    begin
      Temp.CompName := FListName.Data[Index].CompName;
      Temp.Info := FListName.Data[Index].Info;
      FListName.Data[Index].CompName := FListName.Data[I].CompName;
      FListName.Data[Index].Info := FListName.Data[I].Info;
      FListName.Data[I].CompName := Temp.CompName;
      FListName.Data[I].Info := Temp.Info;
    end;
  end;
end;

procedure TgsAbout.OnDO(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
//
end;

procedure TgsAbout.WMDrop(var Message: TMessage);
begin
 // inherited;

end;

procedure TgsAbout.OnED(Sender, Target: TObject; X, Y: Integer);
begin
  if Target <> nil then
  begin
    FindHelp((Target as TComponent).Name);
  end;
end;

procedure TgsAbout.FindHelp(CompName: String);
var
  I: Integer;
  Pnt: TPoint;
  StartPos, EndPos, CurPos, Flag: Integer;
  S: String;
begin
  GetCursorPos(Pnt);
  StartPos := 0;
  EndPos := FListName.Count - 1;
  CurPos := 0;
  Flag := 1;
  while (StartPos <= EndPos) do
  begin
    CurPos := (EndPos + StartPos) div 2;
    if AnsiUpperCase(FListName.Data[CurPos].CompName) <> AnsiUpperCase(CompName) then
    begin
      if AnsiUpperCase(FListName.Data[CurPos].CompName) < AnsiUpperCase(CompName) then
        Flag := 1
      else
        Flag := -1;
    end else begin
      S := TranslateText(FListName.Data[CurPos].Info);
      //if Length(FListName.Data[CurPos].Info) > 255 then
      //  FListName.Data[CurPos].Info := Copy(FListName.Data[CurPos].Info, 1, 255);
      if Length(S) > 255 then
        S := Copy(S, 1, 255);
      MessageBoxPos(Self.Parent.Handle, S, TranslateText('—правка'),
       MB_ICONINFORMATION, Pnt);
      Exit;
    end;
    if Flag = 1 then
      StartPos := CurPos + 1
    else
      EndPos := CurPos - 1;
  end;
(*  for I := 0 to FListName.Count - 1 do
  begin
    if FListName.Data[I].CompName = CompName then
    begin
      MessageBoxPos(Self.Parent.Handle, FListName.Data[I].Info, '—правка',
       MB_ICONINFORMATION, Pnt);
      Exit;
    end;
  end;  *)
  MessageBoxPos(Self.Parent.Handle, '—правка по данному объекту отсутствует', '—правка',
   MB_ICONEXCLAMATION, Pnt);
end;

end.
