unit FR_E_CSV_RS;

interface

{$I FR.inc}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Forms, StdCtrls, ComCtrls,
  FR_Class, Controls, OleCtnrs, ExtCtrls, Spin,
{$IFDEF Delphi2}
  Ole2{, Spin};
{$ELSE}
  ActiveX;
{$ENDIF}

type
  TfrCSV_rsExport = class(TfrExportFilter)
  protected
    Strings: TStringList;
  private
    TempStream  : TStream;
    DataList    : TList;
    NewPage     : Boolean;
//!!!
    FFrom: Integer; //С какой страницы
    FTo: Integer; //По какую станицу
    FRangePages: Boolean; //использовать ли диапозон страниц
    FCurrentPage: Integer; //номер текущей страницы
//!!!
    function NeedExport: Boolean;

    function GetRich(i: Integer):String;

    procedure OnEndPage1;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function ShowModal: Word; override;

    procedure OnBeginDoc; override;
    procedure OnEndDoc; override;

    procedure OnBeginPage; override;
    procedure OnEndPage; override;

    procedure OnText(DrawRect: TRect; X, Y: Integer; const Text: String;
      FrameTyp: Integer; View: TfrView); override;
    procedure OnData(x, y: Integer; View: TfrView); override;
  end;

  TfrCSV_rsExportForm = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    GroupBox1: TPanel;
    rgPages: TGroupBox;
    lblFrom: TLabel;
    lblTo: TLabel;
    rbtnAllPages: TRadioButton;
    rbtnRangePages: TRadioButton;
    edFrom: TSpinEdit;
    edTo: TSpinEdit;
    procedure FormCreate(Sender: TObject);
    procedure rbtnRangePagesClick(Sender: TObject);
    procedure rbtnAllPagesClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


implementation

uses  FR_Const, FR_Utils, FR_ChBox, FR_Rich, FR_OLE, FR_Shape;

{$R *.DFM}

const TwipsPPix     = 15.4; //26.46875
      TwipsPPixCell = 15.4; //15.4
      TwipsCellSpacing = 48; //96

function CorrectTextForcsv(const AText: String): String;
const
   IncorrectSymbol: array[1..1] of Char =
   ('"');
var
  I: Integer;

begin
  Result := AText;
  for I := 1 to Length(IncorrectSymbol) do
    Result := StringReplace(Result, IncorrectSymbol[I], '"' + IncorrectSymbol[I], [rfReplaceAll]);
  if AnsiPos(';', Result) > 0 then
    Result := '"' + Result + '"';
  Result := Result + ';';
end;

constructor TfrCSV_rsExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  frRegisterExportFilter(Self, 'CSV(разделители - запятые) (*.csv)', '*.csv');
  ShowDialog   := True;
  Strings := TStringList.Create;
end;

destructor TfrCSV_rsExport.Destroy;
begin
  frUnRegisterExportFilter(Self);
  Strings.Free;
  inherited Destroy;
end;

function TfrCSV_rsExport.ShowModal: Word;
begin
  if not ShowDialog then
    Result := mrOk
  else with TfrCSV_rsExportForm.Create(nil) do begin
    Result := ShowModal;
    FFrom := edFrom.Value;
    FTo := edTo.Value;
    FRangePages := rbtnRangePages.Checked;
    Free;
  end;
end;

procedure TfrCSV_rsExport.OnBeginDoc;
begin
  FCurrentPage := 0;
  DataList := TList.Create;
  TempStream := TMemoryStream.Create;
end;

procedure TfrCSV_rsExport.OnEndDoc;
begin
  Stream.CopyFrom(TempStream, 0);
  TempStream.Free;
  DataList.Free;
end;


procedure TfrCSV_rsExport.OnBeginPage;
var i: Integer;
begin
  Inc(FCurrentPage);
  ClearLines;
  for i := 0 to 200 do Lines.Add(nil);
end;

procedure TfrCSV_rsExport.OnEndPage;
begin
  if NeedExport then
   OnEndPage1;
   
end;

procedure TfrCSV_rsExport.OnEndPage1;
var
  i, n     : Integer;
  p        : PfrTextRec;
  s, sObj  : String;

begin
  n := Lines.Count - 1;
  while n >= 0 do begin if Lines[n] <> nil then break; Dec(n); end;

  for i := 0 to n do begin
    p:= PfrTextRec(Lines[i]);
    s := '';
    while p <> nil do begin
      sObj:=copy(p^.Text,1,9);
      if sObj='##frImg##' then begin
      end else if sObj='##frRich#' then begin
        s := s + CorrectTextForcsv(GetRich(StrToInt(Copy(p^.Text,10,Length(p^.Text)-9))))
      end else if sObj='##frOLE##' then begin
      end else if sObj='##frLine#' then begin
      end else if sObj='##frShap#' then begin
      end else if sObj='##frMImg#' then begin
      end else begin
        s := s + CorrectTextForcsv(p^.Text);
      end;
      p := p^.Next;
    end;
    if s > '' then
    begin
      s := s + #13#10;
      TempStream.Write(s[1], Length(s));
    end;
  end;
  NewPage := True;
  DataList.Clear;
end;


{---------------------------------------------------------------------}

var
  LastView : string;

procedure TfrCSV_rsExport.OnText(DrawRect: TRect; X, Y: Integer;
  const Text: String; FrameTyp: Integer; View: TfrView);
var p, p1, p2: PfrTextRec; i: integer;

  function TrimText( str : String): String;
  begin
    str:=TrimRight(str);
    i:=pos(#$D#$A,str);
    while i<>0 do begin Delete(str,i,2);Insert(' ',str,i);i:=pos(#$D#$A,str);end;
    i:=pos(#1,str);
    while i<>0 do begin Delete(str,i,1);i:=pos(#1,str);end;
    Result := str;
  end;

begin
//Пока у нас нет человеческой обработки колонтитулов, будем их пропускать
  if (View = nil) or (not NeedExport) or (View.dx <= 0) or (View.dy <= 0) then Exit;
  if (View.ParentType in [btPageFooter, btPageHeader]) then Exit;
  if View.Name=LastView then Exit;
  LastView:=View.Name;
  Y := Round(Y / 14);
  New(p);
  p^.X := View.X;                 p^.Y := View.Y;
  p^.DrawRect.Left:=View.X;       p^.DrawRect.Right :=View.X+View.DX;
  p^.DrawRect.Top :=View.Y;       p^.DrawRect.Bottom:=View.Y+View.DY;
  p^.FrameTyp  := View.FrameTyp;
  p^.FrameWidth:= Round(View.FrameWidth);
  p^.FrameColor:= View.FrameColor;
  p^.FillColor := View.FillColor;
  if View is TfrMemoView then with View as TfrMemoView do begin
    p^.Text:=TrimText(View.Memo.Text);
    p^.Alignment := Alignment;
    p^.FontName  := Font.Name;      p^.FontSize   := Font.Size;
    p^.FontColor := Font.Color;     p^.FontCharset:= Font.Charset;
    p^.FontStyle := frGetFontStyle(Font.Style);
  end else if View is TfrCheckBoxView then with View as TfrCheckBoxView do begin
    p^.Alignment := 0;
    p^.FontName  := 'Wingdings';    p^.FontSize   := dy;
    p^.FontColor := CheckColor;     p^.FontCharset:= DEFAULT_CHARSET;
    p^.FontStyle := frGetFontStyle([]);
//    Text:='';
//    if (Memo.Count>0)and(Memo[0]<>'') then if Memo[0][1]<>'0' then Text:='X';
    if Text='X'
      then if CheckStyle=0 then p^.Text:=#251 else p^.Text:=#252
      else p^.Text:='';
  end else begin
    p^.Text := Text;
    p^.Alignment:=0; p^.FontName:=''; p^.FontSize:=10;
    p^.FontStyle:=0; p^.FontColor:=0; p^.FontCharset:=0;
  end;

  p1 := PfrTextRec(Lines[Y]);
  p^.Next := nil;
  if p1 = nil then
    Lines[Y] := p{TObject(p)}
  else begin
    p2:=p1; while (p1<>nil)and(p1^.X<p^.X) do begin p2:=p1; p1:=p1^.Next; end;
    if p2<>p1
      then begin p2^.Next:=p; p^.Next:=p1; end
      else begin Lines[Y]:={TObject(p)}p; p^.Next:=p1; end;
  end;
end;


procedure TfrCSV_rsExport.OnData(x, y: Integer; View: TfrView);
var
  Rect: TRect;
  SL: TStringList;
  Str: TMemoryStream;
begin
  if not NeedExport then Exit;
  LastView := '';
//Пока у нас нет человеческой обработки колонтитулов, будем их пропускать
  if not (View.ParentType in [btPageFooter, btPageHeader]) then
  if View is TfrRichView then
  begin
    Rect.Left:=View.X; Rect.Right :=View.X+View.dx;
    Rect.Top :=View.Y; Rect.Bottom:=View.Y+View.dy;
    if TfrRichView(View).RichEdit.Lines.Text<>'' then
    begin
    { TODO : Пока переносится текст без rtf-форматирования }
      SL := TStringList.Create;
      Str := TMemoryStream.Create;
      try
        SL.Assign(TfrRichView(View).RichEdit.Lines);
        SL.SaveToStream(Str);
        DataList.Add(Str);
        OnText(Rect,X,Y, '##frRich#'+ IntToStr(DataList.Count-1), View.FrameTyp, View);
      finally
        SL.Free;
      end;
    end else
      OnText(Rect, X,Y, '', View.FrameTyp, View);
  end else
    OnText(Rect, X,Y, '', View.FrameTyp, View);
end;

procedure TfrCSV_rsExportForm.FormCreate(Sender: TObject);
begin
  btnOk.Caption := LoadStr(SOk);
  btnCancel.Caption := LoadStr(SCancel);
end;

procedure TfrCSV_rsExportForm.rbtnRangePagesClick(Sender: TObject);
begin
  lblTo.Enabled := True;
  lblFrom.Enabled := True;
  edTo.Enabled := True;
  edFrom.Enabled := True;
end;

procedure TfrCSV_rsExportForm.rbtnAllPagesClick(Sender: TObject);
begin
  lblTo.Enabled := False;
  lblFrom.Enabled := False;
  edTo.Enabled := False;
  edFrom.Enabled := False;
end;

function TfrCSV_rsExport.NeedExport: Boolean;
begin
  Result := (not FRangePages) or
    (FCurrentPage >= FFrom) and (FCurrentPage <= FTo);
end;

function TfrCSV_rsExport.GetRich(i: Integer): String;
var
  j,n: Integer;
  Str: TStream;
  bArr: Array[0..1023] of Char;
  s: String;
begin
  Str := TStream(DataList[i]);
  Str.Position := 0;
  s := '';
  repeat
    n := Str.Read(bArr[0],1024);
    for j := 0 to n - 1 do
      s := s + bArr[j];
  until n < 1024;
  Str.Free;
  Result := s;
end;

end.
