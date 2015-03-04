unit FR_E_RTF_RS;

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
  TfrRTF_rsExport = class(TfrExportFilter)
  protected
    FScaleX, FScaleY: Double;
    Strings: TStringList;
  private
    FExpGraphics : boolean;
    FExpOLEAsBmp : boolean;
    FExpFileType : integer;
    TempStream  : TStream;
    FontTable, ColorTable: TStringList;
    DataList    : TList;
    NewPage     : Boolean;
//!!!
    Margins     : TRect;
    LastSL : Integer;
    PardFlag : Boolean;
    PageLeft: Integer;

    FFrom: Integer; //С какой страницы
    FTo: Integer; //По какую станицу
    FRangePages: Boolean; //использовать ли диапозон страниц
    FCurrentPage: Integer; //номер текущей страницы
//!!!
    function GetOLE      ( i : Integer):String;
    function GetImage    ( i : Integer):String;
    function GetMetaImage( i : Integer):String;
    function GetRich     ( i : Integer):String;
    function GetLine     ( i : Integer):String;
    function GetShape    ( i : Integer):String;
    function GetCellBorderStyle( f : Integer):String;
    function GetParBorderStyle ( f : Integer):String;
    function GetAlignmentStyle ( f : Integer):String;
    function GetFontStyle( f : Integer):String;
    function GetColor    ( f : String ):String;
    function GetFontName ( f : String ):String;
    function NeedExport: Boolean;

    procedure OnEndPage1;
    procedure OnEndPage2;
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
  published
    property ExportGraphics: boolean read FExpGraphics write FExpGraphics;
    property ExportOLEAsBmp: boolean read FExpOLEAsBmp write FExpOLEAsBmp;
    property ExportFileType: integer read FExpFileType write FExpFileType;
    property ScaleX: Double read FScaleX write FScaleX;
    property ScaleY: Double read FScaleY write FScaleY;
  end;

  TfrRTF_rsExportForm = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    E1: TEdit;
    Button1: TButton;
    Button2: TButton;
    Label2: TLabel;
    Label3: TLabel;
    E2: TEdit;
    CB1: TCheckBox;
    CB2: TCheckBox;
    RG1: TRadioGroup;
    rgPages: TGroupBox;
    rbtnAllPages: TRadioButton;
    rbtnRangePages: TRadioButton;
    lblFrom: TLabel;
    edFrom: TSpinEdit;
    lblTo: TLabel;
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

function CorrectTextForRTF(const AText: String): String;
//Символ '\' должен стоять первым!!!!
const
   IncorrectSymbol: array[1..3] of Char =
   ('\', '{', '}');
var
  I: Integer;

begin
  Result := AText;
  for I := 1 to Length(IncorrectSymbol) do
    Result := StringReplace(Result, IncorrectSymbol[I], '\' + IncorrectSymbol[I], [rfReplaceAll]);
end;

constructor TfrRTF_rsExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  frRegisterExportFilter(Self, 'Reach Text Format RTF (*.rtf)', '*.rtf');
  ShowDialog   := True;
  FExpGraphics := True;
  FExpOLEAsBmp := False;
  FExpFileType := 0;
  ScaleX  := 1;
  ScaleY  := 1;
  Strings := TStringList.Create;
end;

destructor TfrRTF_rsExport.Destroy;
begin
  frUnRegisterExportFilter(Self);
  Strings.Free;
  inherited Destroy;
end;

function TfrRTF_rsExport.ShowModal: Word;
begin
  if not ShowDialog then
    Result := mrOk
  else with TfrRTF_rsExportForm.Create(nil) do begin
    Result := ShowModal;
    try
      FScaleX := frStrToFloat(E1.Text);
    except
      FScaleX := 1;
    end;
    try
      FScaleY := frStrToFloat(E2.Text);
    except
      FScaleY := 1;
    end;
    FExpGraphics := CB1.Checked;
    FExpOleAsBmp := CB2.Checked;
    FExpFileType := RG1.ItemIndex;
    FFrom := edFrom.Value;
    FTo := edTo.Value;
    FRangePages := rbtnRangePages.Checked;
    Free;
  end;
end;

procedure TfrRTF_rsExport.OnBeginDoc;
const TemplateStr = '{\rtf1\ansi' + #13#10 + '\paperw%d\paperh%d\margl%d\margr%d\margt%d\margb%d' + #13#10;
var
  s: String;
  FirstPage : TfrPage;
  PageIndex : Integer;
begin
  FCurrentPage := 0;
  FontTable := TStringList.Create;
  ColorTable := TStringList.Create;
  DataList := TList.Create;
  TempStream := TMemoryStream.Create;
  PageLeft := 0;
  If CurReport.Pages.Count > 0 then
  begin
    FirstPage := CurReport.Pages.Pages[0];
    PageIndex := 1;
    while (FirstPage.PageType <> ptReport) and (PageIndex < CurReport.Pages.Count) do
    begin
      FirstPage := CurReport.Pages.Pages[PageIndex];
      inc(PageIndex);
    end;
    Margins := Rect(567, 567, 567, 567);
    If FirstPage.PageType = ptReport then
    begin
      If FirstPage.UseMargins then
      begin
        Margins := FirstPage.pgMargins;
        With Margins, FirstPage.PrnInfo do
        begin
          If Left   = 0 then Left   := Round(Ofx * 15.75) else Left   := Round(Left   * 15.75);
          If Right  = 0 then Right  := Round((Pgw-Pw-Ofx) * 15.75) else Right  := Round(Right  * 15.75);
          If Top    = 0 then Top    := Round(Ofy * 15.75) else Top    := Round(Top    * 15.75);
          If Bottom = 0 then Bottom := Round((Pgh-Ph-Ofy) * 15.75) else Bottom := Round(Bottom * 15.75);
        end;
      end else Margins := Rect(0, 0, 0, 0);
      s := Format(TemplateStr, [Round(FirstPage.pgWidth * 5.67),
                                Round(FirstPage.pgHeight * 5.67),
                                Margins.Left,
                                Margins.Right,
                                Margins.Top,
                                Margins.Bottom])
    end else s := Format(TemplateStr, [11907, 16840, Margins.Left, Margins.Right, Margins.Top, Margins.Bottom]);
    PageLeft := Margins.Left;
  end else s := Format(TemplateStr, [11907, 16840, Margins.Left, Margins.Right, Margins.Top, Margins.Bottom]);
  Stream.Write(s[1], Length(s));
  NewPage  := False;
  LastSL   := -1;
  PardFlag := True;
 //  s := '{\rtf1\ansi' + #13#10 + '\margl0\margr0\margt600\margb600' + #13#10;
//  Stream.Write(s[1], Length(s));
end;

procedure TfrRTF_rsExport.OnEndDoc;
var
  i, c: Integer;
  s, s1: String;
begin
  s := '\par}';
  TempStream.Write(s[1], Length(s));
  s := '{\fonttbl';
  for i := 0 to FontTable.Count - 1 do begin
    s1 := '{\f' + IntToStr(i) + ' ' + FontTable[i] + '}';
    if Length(s + s1) < 255 then
      s := s + s1
    else begin
      s := s + #13#10;
      Stream.Write(s[1], Length(s));
      s := s1;
    end;
  end;
  s := s + '}' + #13#10;
  Stream.Write(s[1], Length(s));

  s := '{\colortbl;';
  for i := 0 to ColorTable.Count - 1 do begin
    c := StrToInt(ColorTable[i]);
    s1 := '\red' + IntToStr(GetRValue(c)) +
          '\green' + IntToStr(GetGValue(c)) +
          '\blue' + IntToStr(GetBValue(c)) + ';';
    if Length(s + s1) < 255 then
      s := s + s1
    else begin
      s := s + #13#10;
      Stream.Write(s[1], Length(s));
      s := s1;
    end;
  end;
  s := s + '}' + #13#10;
  Stream.Write(s[1], Length(s));

  Stream.CopyFrom(TempStream, 0);
  TempStream.Free;
  FontTable.Free;
  ColorTable.Free;
  DataList.Free;
end;


procedure TfrRTF_rsExport.OnBeginPage;
var i: Integer;
begin
  Inc(FCurrentPage);
  ClearLines;
  for i := 0 to 200 do Lines.Add(nil);
end;

{--------------------------------------------------------------------}

function TfrRTF_rsExport.GetOLE(i : Integer):String;
var r, oleclass, s0,s1  : String;
    x,y,dx,dy, k,n,n1,j : Integer;
    Str                 : TStream;
    bArr                : Array[0..1023] of Byte;
begin
  if FExpOleAsBmp then begin
    str:=TStream(DataList[i]);
    Str.Position:=0;
    Str.Read(x, 4);
    Str.Read(y, 4);
    Str.Read(dx, 4);
    Str.Read(dy, 4);
    r := r  +
         '{\pict\picscalex100\picscaley100\piccropl0\piccropr0\piccropt0\piccropb0'+
         '\picw' + IntToStr(Round(dx * TwipsPPix)) +
         '\pich' + IntToStr(Round(dy * TwipsPPix)) +
         '\wmetafile8' + #13#10;
    n1:=0;
    n:=Str.Read(bArr[0], 22);
    repeat
      n:=Str.Read(bArr[0], 1024);
      for j := 0 to n - 1 do begin
        r := r + IntToHex(bArr[j], 2); Inc(n1);
        if n1>63 then begin n1:=0; r:=r+#13#10; end;
      end;
    until n<1024;
    Str.Free;
    r:=r+'}';
    Result:=r;
  end else begin
    str:=TStream(DataList[i-1]);
    Str.Position:=0;
    Str.Read(x, 4);
    Str.Read(y, 4);
    Str.Read(dx,4);
    Str.Read(dy,4);
    Str.Read(n, 4);
    oleclass:='';
    for j:=1 to n do begin Str.Read(bArr,1); oleclass:=oleclass+char(bArr[0]); end;
    s0:= IntToHex(n+1,8);
    s1:= Copy(s0,7,2)+Copy(s0,5,2)+Copy(s0,3,2)+Copy(s0,1,2);
    s0:='';
    for j:=1 to n do s0:=s0+IntToHex(byte(oleclass[j]),2);
    r:='{\object\objemb'+
       '\objw'+IntToStr(Round(dx * TwipsPPix))+
       '\objh'+IntToStr(Round(dy * TwipsPPix))+
       '\objscalex100\objscaley100'+
       '{\*\objclass' + oleclass + '}' +
       '{\*\objdata' + #13#10 +
       '01050000' + #13#10 + '02000000' + #13#10 +
        s1 + #13#10 + s0 + '00' +
       '00000000' + #13#10 + '00000000' + #13#10;
    k:=0;
    n1:=0;
    s1:='';
    repeat
      n:=Str.Read(bArr[0], 1024);
      for j := 0 to n - 1 do begin
        s1 := s1 + IntToHex(bArr[j], 2); Inc(n1); Inc(k);
        if n1>63 then begin n1:=0; s1:=s1+#13#10; end;
      end;
    until n<1024;
    Str.Free;
    s0:= IntToHex(k ,8);
    r:=r + Copy(s0,7,2)+Copy(s0,5,2)+Copy(s0,3,2)+Copy(s0,1,2)
         + #13#10
         + s1 + #13#10
         + '01050000' +#13#10+ '00000000' +#13#10+ '}' +#13#10;

    str:=TStream(DataList[i]);
    Str.Position:=0;
    Str.Read(x, 4);
    Str.Read(y, 4);
    Str.Read(dx, 4);
    Str.Read(dy, 4);
    r := r  +
         '{\result{'+
         '{\pict\picscalex100\picscaley100\piccropl0\piccropr0\piccropt0\piccropb0'+
         '\picw' + IntToStr(Round(dx * TwipsPPix)) +
         '\pich' + IntToStr(Round(dy * TwipsPPix)) +
         '\wmetafile8' + #13#10;
    n1:=0;
    n:=Str.Read(bArr[0], 22);
    repeat
      n:=Str.Read(bArr[0], 1024);
      for j := 0 to n - 1 do begin
        r := r + IntToHex(bArr[j], 2); Inc(n1);
        if n1>63 then begin n1:=0; r:=r+#13#10; end;
      end;
    until n<1024;
    Str.Free;
    r:=r+'} }}}';
    Result:=r;
  end;
end;

function TfrRTF_rsExport.GetImage(i : Integer):String;
var j,n1,n, x,y,dx,dy: Integer;
    r, s0,s1  : String;
    bArr      : Array[0..1023] of Byte;
    str       : TStream;
begin
  str:=TStream(DataList[i]);
  Str.Position := 0;
  Str.Read(x, 4);
  Str.Read(y, 4);
  Str.Read(dx, 4);
  Str.Read(dy, 4);
  r := '{\pict\picscalex100\picscaley100\piccropl0\piccropr0\piccropt0\piccropb0'+
       '\picw' + IntToStr(Round(dx * TwipsPPix)) +
       '\pich' + IntToStr(Round(dy * TwipsPPix)) +
       '\wmetafile8' + #13#10;
  Str.Read(dx, 4);
  Str.Read(dy, 4);
  Str.Read(n, 2);
  Str.Read(n, 4);
  n := n div 2 + 7;
  s0:= IntToHex(n + $24, 8);
  r := r +
       '0100'+ //Тип метафайла =1
       '0900'+ //Размер заголовка в словах = 9
       '0003'+ //Номер версии = 0300 для Win3
       Copy(s0,7,2)+ Copy(s0,5,2)+Copy(s0,3,2)+ Copy(s0,1,2)+ //Размер файла в словах
       '0000'; //Число используемых объектов
  s0:= IntToHex(n,8);
  s1:= Copy(s0,7,2)+Copy(s0,5,2)+Copy(s0,3,2)+Copy(s0,1,2);
  r := r + s1 + //Размер самой большой записи в словах
       '0000'+ // НЕ используется
                   //---------Заголовок кончился пошли записи
       '05000000'+ // первая - 5 слов
       '0b02'+     // операция SetWindowOrg - начало окна в логич. единицах
       '00000000'+ // параметры X , Y
       '05000000'+ // длинна второй 5 слов
       '0c02';     // операция SetWindowExt - уст. непрерывную часть окна
  s0:= IntToHex(dy, 4);                  //  \
  r := r + Copy(s0,3,2)+Copy(s0,1,2);    //  ! Параметры
  s0:= IntToHex(dx, 4);                  //  !
  r := r + Copy(s0,3,2)+Copy(s0,1,2) +   //  /
       '05000000'+ // длинна третьей 5 слов
       '0902'+     // операция SetTextColor
       '00000000'+ // параметр - цвет - черный цвет
       '05000000'+ // длинна четвертой 5 слов
       '0102'+     // операция SetBkColor
       'ffffff00'+ // параметр - цвет - белый
       '04000000'+ // длинна пятой - 4 слова
       '0701'+     // SetStretchBltMode - метод сжатия bitmap изображений
       '0300'+     // просто отбрасывать удаленные строки
       s1 +        // Длинаа шестой записи - данные !!!!!!!!
       '430f'+     // операция StretchDIBits - перенос данных
       '2000cc00'+ // Параметры: операция
       '0000';     //            Использование палитры  - 0 - RGB цвет
  s0:= IntToHex(dy, 4);
  r := r + Copy(s0,3,2)+Copy(s0,1,2); // Высота источника
  s0:= IntToHex(dx, 4);
  r := r + Copy(s0,3,2)+Copy(s0,1,2)+ // Ширина источника
       '00000000';                    // Y, X начала источника
  s0:= IntToHex(dy, 4);
  r := r + Copy(s0,3,2)+Copy(s0,1,2); // Высота приемника
  s0:= IntToHex(dx, 4);
  r := r + Copy(s0,3,2)+Copy(s0,1,2)+ // Ширина приемника
       '00000000'+#13#10;             // Y, X начала приемника
  Str.Read(bArr[0], 8);
  n1:=0;
  repeat
    n:=Str.Read(bArr[0], 1024);
    for j := 0 to n - 1 do begin
      r := r + IntToHex(bArr[j], 2); Inc(n1);
      if n1>63 then begin n1:=0; r:=r+#13#10; end;
    end;
  until n<1024;
  r:=r+ '03000000'+ // Пустая операция
        '0000'+
        '}\par' + #13#10;
  TStream(DataList[i]).Free;
  Result:=r;
end;

function TfrRTF_rsExport.GetMetaImage(i : Integer):String;
var j,n1,n, x,y,dx,dy: Integer;
    r         : String;
    bArr      : Array[0..1023] of Byte;
    str       : TStream;
begin
  str:=TStream(DataList[i]);
  Str.Position := 0;
  Str.Read(x, 4);
  Str.Read(y, 4);
  Str.Read(dx, 4);
  Str.Read(dy, 4);
  r := '{\pict\picscalex100\picscaley100\piccropl0\piccropr0\piccropt0\piccropb0'+
       '\picw' + IntToStr(Round(dx * TwipsPPix)) +
       '\pich' + IntToStr(Round(dy * TwipsPPix)) +
       '\wmetafile8' + #13#10;
  Str.Read(bArr[0], 22);
  n1:=0;
  repeat
    n:=Str.Read(bArr[0], 1024);
    for j := 0 to n - 1 do begin
      r := r + IntToHex(bArr[j], 2); Inc(n1);
      if n1>63 then begin n1:=0; r:=r+#13#10; end;
    end;
  until n<1024;
  r:=r+ '}\par' + #13#10;
  TStream(DataList[i]).Free;
  Result:=r;
end;

function TfrRTF_rsExport.GetRich(i : Integer):String;
var j,n:Integer; Str:TStream; bArr:Array[0..1023] of Char; s:string;
begin
  Str := TStream(DataList[i]);  Str.Position := 0;  s:='';
  repeat n:=Str.Read(bArr[0],1024); for j:=0 to n-1 do s:=s+bArr[j];
  until n<1024;
  Str.Free;
  Result:=s;
end;

function TfrRTF_rsExport.GetLine( i : Integer):String;
var s:string;  Stm : TStream; x,y : Integer; View : TfrView;
begin
  {$WARNINGS OFF}
  View:=TfrView.Create;
  {$WARNINGS ON}
  Stm := TStream(DataList[i]);  Stm.Position := 0;
  Stm.Read(x, 4);
  Stm.Read(y, 4);
  Stm.Read(View.dx, 4);
  Stm.Read(View.dy, 4);
  Stm.Read(View.FrameStyle,sizeof(View.FrameStyle));
  Stm.Read(View.FrameWidth,sizeof(View.FrameWidth));
  Stm.Read(View.FrameColor,sizeof(View.FrameColor));
  Stm.Free;
  s := s + '{\*\do \dobxpage\dobypage'+#13+#10;
  s:=s + '\dpline '
       + '\dpptx' + IntToStr(Round(x * TwipsPPix))
       + '\dppty' + IntToStr(Round(y * TwipsPPix))
       + '\dpptx' + IntToStr(Round((x+View.dx) * TwipsPPix))
       + '\dpptx' + IntToStr(Round(y * TwipsPPix))
       + '\dpx' + IntToStr(Round(x * TwipsPPix))
       + '\dpy' + IntToStr(Round(y * TwipsPPix))
       + '\dpxsize' + IntToStr(Round(View.dx * TwipsPPix))
       + '\dpysize' + IntToStr(Round(View.dy * TwipsPPix))
       + '\dplinecob' + IntToStr( (View.FrameColor and $00ff0000) shr 16 )
       + '\dplinecog' + IntToStr( (View.FrameColor and $0000ff00) shr 8)
       + '\dplinecor' + IntToStr( (View.FrameColor and $000000ff));
  case TPenStyle(View.FrameStyle) of
    psSolid      :  s:=s + '\dplinesolid';
    psDash       :  s:=s + '\dplinedash';
    psDot        :  s:=s + '\dplinedot';
    psDashDot    :  s:=s + '\dplinedado';
    psDashDotDot :  s:=s + '\dplinedadodo';
  else              s:=s + '\dplinesolid';
  end;
  s:=s + '\dplinew'+IntToStr(Round( View.FrameWidth * TwipsPPix))
       + '\dpfillbgcb' + IntToStr( (View.FillColor and $00ff0000) shr 16 )
       + '\dpfillbgcg' + IntToStr( (View.FillColor and $0000ff00) shr 8 )
       + '\dpfillbgcr' + IntToStr( (View.FillColor and $000000ff))
       + '\dpfillpat1'
       + '}' + #13#10;

  View.Free;
  Result:=s;
end;

function TfrRTF_rsExport.GetShape( i : Integer):String;
var s:string;  Stm : TStream; x,y : Integer; View : TfrView; ShapeType:byte;
begin
  {$WARNINGS OFF}
  View:=TfrView.Create;
  {$WARNINGS ON}
  Stm := TStream(DataList[i]);  Stm.Position := 0;
  Stm.Read(x, 4);
  Stm.Read(y, 4);
  Stm.Read(View.dx, 4);
  Stm.Read(View.dy, 4);
  stm.Read(ShapeType, 1);
  Stm.Read(View.FrameStyle,sizeof(View.FrameStyle));
  Stm.Read(View.FrameWidth,sizeof(View.FrameWidth));
  Stm.Read(View.FrameColor,sizeof(View.FrameColor));
  Stm.Read(View.FillColor,sizeof(View.FillColor));
  Stm.Free;
  s := s + '{\*\do \dobxpage\dobypage'+#13+#10;
  case ShapeType of
    skRectangle: s:=s+'\dprect'+#13+#10;
    skRoundRectangle:s:=s+'\dprect\dproundr'+#13+#10;
    skEllipse:   s:=s+'\dpellipse';
    skTriangle:  s:=s+'\dppolyline \dppolycount4 '
                     +'\dpptx'+ IntToStr(Round(View.dx * TwipsPPix))
                     +'\dppty'+ IntToStr(Round(View.dy * TwipsPPix))
                     +'\dpptx0'
                     +'\dppty'+ IntToStr(Round(View.dy * TwipsPPix))
                     +'\dpptx'+ IntToStr(Round(View.dx/2 * TwipsPPix))
                     +'\dppty0'
                     +'\dpptx'+ IntToStr(Round(View.dx * TwipsPPix))
                     +'\dppty'+ IntToStr(Round(View.dy * TwipsPPix));
    skDiagonal1: s:=s+'\dpline '
                     +'\dpptx' + IntToStr(Round(x * TwipsPPix))
                     +'\dppty' + IntToStr(Round((y+View.dy) * TwipsPPix))
                     +'\dpptx' + IntToStr(Round((x+View.dx) * TwipsPPix))
                     +'\dppty' + IntToStr(Round(y * TwipsPPix));
    skDiagonal2: s:=s+'\dpline '
                     +'\dpptx' + IntToStr(Round(x * TwipsPPix))
                     +'\dppty' + IntToStr(Round(y * TwipsPPix))
                     +'\dpptx' + IntToStr(Round((x+View.dx) * TwipsPPix))
                     +'\dppty' + IntToStr(Round((y+View.dy) * TwipsPPix));
  end;
  s:=s + '\dpx' + IntToStr(Round(x * TwipsPPix))
       + '\dpy' + IntToStr(Round(y * TwipsPPix))
       + '\dpxsize' + IntToStr(Round(View.dx * TwipsPPix))
       + '\dpysize' + IntToStr(Round(View.dy * TwipsPPix));

  s:=s + '\dplinecob' + IntToStr( (View.FrameColor and $00ff0000) shr 16 )
       + '\dplinecog' + IntToStr( (View.FrameColor and $0000ff00) shr 8)
       + '\dplinecor' + IntToStr( (View.FrameColor and $000000ff));

  case TPenStyle(View.FrameStyle) of
    psSolid      :  s:=s + '\dplinesolid';
    psDash       :  s:=s + '\dplinedash';
    psDot        :  s:=s + '\dplinedot';
    psDashDot    :  s:=s + '\dplinedado';
    psDashDotDot :  s:=s + '\dplinedadodo';
  else              s:=s + '\dplinesolid';
  end;

  s:=s + '\dplinew'+IntToStr(Round( View.FrameWidth * TwipsPPix))
       + '\dpfillbgcb' + IntToStr( (View.FillColor and $00ff0000) shr 16 )
       + '\dpfillbgcg' + IntToStr( (View.FillColor and $0000ff00) shr 8 )
       + '\dpfillbgcr' + IntToStr( (View.FillColor and $000000ff))
       + '\dpfillpat1'
       + '}' + #13#10;

  View.Free;
  Result:=s;
end;



function TfrRTF_rsExport.GetCellBorderStyle(f: Integer): String;
begin
  Result := '\clvertalt';
  if (f and frftTop   )<>0 then Result:=Result+'\clbrdrt\brdrs\brdrw20';
  if (f and frftLeft  )<>0 then Result:=Result+'\clbrdrl\brdrs\brdrw20';
  if (f and frftBottom)<>0 then Result:=Result+'\clbrdrb\brdrs\brdrw20';
  if (f and frftRight )<>0 then Result:=Result+'\clbrdrr\brdrs\brdrw20';
end;

function TfrRTF_rsExport.GetParBorderStyle(f: Integer): String;
begin
  Result := '';
  if (f and frftTop   )<>0 then Result:=Result+'\brdrt\brdrw20 ';
  if (f and frftLeft  )<>0 then Result:=Result+'\brdrl\brdrw20 ';
  if (f and frftBottom)<>0 then Result:=Result+'\brdrb\brdrw20 ';
  if (f and frftRight )<>0 then Result:=Result+'\brdrr\brdrw20 ';
end;

function TfrRTF_rsExport.GetAlignmentStyle(f : Integer):String;
begin
  Result:='\ql';
  if (f and frtaRight   )<>0 then Result:='\qr';
  if (f and frtaCenter  )<>0 then Result:='\qc';
//  if (f and frtaVertical)<>0 then Result:='\ql';
//  if (f and frtaMiddle  )<>0 then Result:='\ql';
//  if (f and frtaDown    )<>0 then Result:='\ql';
end;

function TfrRTF_rsExport.GetFontStyle(f: Integer): String;
begin
  Result := '';
  if (f and $1) <> 0 then Result := '\i';
  if (f and $2) <> 0 then Result := Result + '\b';
  if (f and $4) <> 0 then Result := Result + '\u';
end;

function TfrRTF_rsExport.GetColor(f: String): String;
var i: Integer;
begin
  i := ColorTable.IndexOf(f);
  if i <> -1 then Result := IntToStr(i + 1)
  else begin ColorTable.Add(f); Result:=IntToStr(ColorTable.Count); end;
end;

function TfrRTF_rsExport.GetFontName(f: String): String;
var i: Integer;
begin
  i := FontTable.IndexOf(f);
  if i <> -1 then Result := IntToStr(i)
  else begin FontTable.Add(f); Result := IntToStr(FontTable.Count - 1); end;
end;


{----------------------------------------------------------------------}

procedure TfrRTF_rsExport.OnEndPage;
begin
  if NeedExport then
    case FExpFileType of
     0: OnEndPage1;
     1: OnEndPage2;
    end;
end;

procedure TfrRTF_rsExport.OnEndPage1;
var
  i, n, prevx, dy  : Integer;
  p                : PfrTextRec;
  sd, s0, s, sObj  : String;
  IsEmpty          : Boolean;

  procedure DefOneMoreCell;
  begin
    if (p^.x-prevx)>5 then begin
      s0:=s0+'\clvertalt\cltxlrtb\cellx'+IntToStr(Round(p^.X*ScaleX*TwipsPPixCell - PageLeft));
      s :=s +'\intbl \cell \pard';
    end;
    prevX:=p^.DrawRect.Right;
    s0:=s0
      + GetCellBorderStyle(p^.FrameTyp)
      + '\clcbpat'+GetColor(IntToStr(p^.FillColor))
      + '\cltxlrtb'
      + '\cellx'+IntToStr(Round(p^.DrawRect.Right*ScaleX*TwipsPPixCell - PageLeft));
    s:=s
      + ' \li20\ri20'
      + GetAlignmentStyle(p^.Alignment)+'\intbl'
      + '{{';
    if dy<(p^.DrawRect.Bottom-p^.DrawRect.Top) then
      dy:=p^.DrawRect.Bottom-p^.DrawRect.Top;
  end;
begin
(*  if NewPage then begin
    s := '{\page \par }' + #13#10;
    TempStream.Write(s[1], Length(s));
  end;                                *)

  n := Lines.Count - 1;
  while n >= 0 do begin if Lines[n] <> nil then break; Dec(n); end;

  sd:='';
  for i := 0 to n do begin
    p:= PfrTextRec(Lines[i]);
    s:='';  s0:='';  IsEmpty:=True; dy:=10;
    if p<>nil then prevx:=p^.x;
    while p <> nil do begin
      IsEmpty := False;
      sObj:=copy(p^.Text,1,9);
      if sObj='##frImg##' then begin
        DefOneMoreCell;
        s:=s+GetImage(StrToInt(Copy(p^.Text,10,Length(p^.Text)-9)))+'}\cell}\pard';
      end else if sObj='##frRich#' then begin
        DefOneMoreCell;
        s:=s+GetRich(StrToInt(Copy(p^.Text,10,Length(p^.Text)-9)))+'}\cell}\pard';
      end else if sObj='##frOLE##' then begin
        DefOneMoreCell;
        s:=s+GetOLE(StrToInt(Copy(p^.Text,10,Length(p^.Text)-9)))+'}\cell}\pard';
      end else if sObj='##frLine#' then begin
        sd:=sd+' {'+GetLine(StrToInt(Copy(p^.Text,10,Length(p^.Text)-9)))+'}'+#13#10;
      end else if sObj='##frShap#' then begin
        sd:=sd+' {'+GetShape(StrToInt(Copy(p^.Text,10,Length(p^.Text)-9)))+'}'+#13#10;
      end else if sObj='##frMImg#' then begin
        DefOneMoreCell;
        s:=s+GetMetaImage(StrToInt(Copy(p^.Text,10,Length(p^.Text)-9)))+'}\cell}\pard';
      end else begin
        DefOneMoreCell;
        if p^.FontColor = clWhite then p^.FontColor := clBlack;
        s := s
             +'\f' + GetFontName(p^.FontName)
             +'\fs' + IntToStr(p^.FontSize * 2)
             +GetFontStyle(p^.FontStyle)
             +'\cf' + GetColor(IntToStr(p^.FontColor))
             +' ' + CorrectTextForRTF(p^.Text)
             +'}\cell }\pard';
      end;
      p := p^.Next;
    end;

    if (not IsEmpty)and(s<>'')and(s0<>'') then begin
      p := PfrTextRec(Lines[i]);
      if p <> nil then
        s0:=s0+' \trleft' + IntToStr(Round(p^.X * ScaleX * TwipsPPixCell - PageLeft));
      s := '\trowd \trgaph0' +
           '\trrh'+IntToStr(Round(dy * ScaleY * 15))+
//!!! Не знаю че это такое, но только обрамляло оно хреново, без него лучше
      //     ' \trbrdrt\brdrs\brdrw10 \trbrdrl\brdrs\brdrw10 \trbrdrb\brdrs\brdrw10 \trbrdrr\brdrs\brdrw10 \trbrdrh\brdrs\brdrw10 \trbrdrv\brdrs\brdrw10 '+
           s0 + ' \pard \intbl ' + s + '\pard \intbl \row' + #13#10;
      TempStream.Write(s[1], Length(s));
    end;
  end;

  s := sd + #13#10 + '\pard ' + #13#10;
  TempStream.Write(s[1], Length(s));
  NewPage := True;
  DataList.Clear;
end;


procedure TfrRTF_rsExport.OnEndPage2;
var
  i, n      : Integer;
  p         : PfrTextRec;
  s,sd,sObj : String;

  procedure DefOneMoreCell;
  begin
    s := s
      +'\par\pard\pvpg\phpg'
      +'\posx'+IntToStr(Round(p^.DrawRect.Left*ScaleX*TwipsPPixCell)-(TwipsCellSpacing div 2))
      +'\posy'+IntToStr(Round(p^.DrawRect.Top*ScaleY*TwipsPPixCell))
      +'\absw'+IntToStr(Round((p^.DrawRect.Right-p^.DrawRect.Left)*ScaleX*TwipsPPixCell)-TwipsCellSpacing)
      +'\absh-'+IntToStr(Round((p^.DrawRect.Bottom-p^.DrawRect.Top)*ScaleY*TwipsPPixCell))
//      +#13#10
      +GetParBorderStyle(p^.FrameTyp)
      +GetAlignmentStyle(p^.Alignment);
  end;
begin
  (*if NewPage then begin
    s := '{\page \par }' + #13#10;
    TempStream.Write(s[1], Length(s));
  end;*)

  s := '\fs1' + #13#10;
  TempStream.Write(s[1], Length(s));

  sd:='';

  n := Lines.Count - 1;
  while n >= 0 do begin if Lines[n] <> nil then break; Dec(n); end;

  for i := 0 to n do begin
    p:= PfrTextRec(Lines[i]);
    s:='';
    while p <> nil do begin
      sObj:=copy(p^.Text,1,9);
      if sObj='##frImg##' then begin
        DefOneMoreCell;
        s := s + ' {'+GetImage(StrToInt(Copy(p^.Text,10,Length(p^.Text)-9)))
               + '}' + '\par\pard'+ #13#10;
      end else if sObj='##frRich#' then begin
        DefOneMoreCell;
        s := s + ' {'+GetRich(StrToInt(Copy(p^.Text,10,Length(p^.Text)-9)))
               + '}' + '\par\pard'+ #13#10;
      end else if sObj='##frOLE##' then begin
        DefOneMoreCell;
        s := s + ' {'+GetOLE(StrToInt(Copy(p^.Text,10,Length(p^.Text)-9)))
               + '}' + '\par\pard'+ #13#10;
      end else if sObj='##frLine#' then begin
        sd:=sd+'{'+GetLine(StrToInt(Copy(p^.Text,10,Length(p^.Text)-9)))+'}';
      end else if sObj='##frShap#' then begin
        sd:=sd+'{'+GetShape(StrToInt(Copy(p^.Text,10,Length(p^.Text)-9)))+'}';
      end else begin
        DefOneMoreCell;
        if p^.FontColor = clWhite then p^.FontColor := clBlack;
        s := s
               + '{\f' + GetFontName(p^.FontName)
               + '\fs' + IntToStr(p^.FontSize * 2) + GetFontStyle(p^.FontStyle)
               + '\cf' + GetColor(IntToStr(p^.FontColor))
               + '{' + CorrectTextForRTF(p^.Text) + '}}' + '\par\pard'+ #13#10;
      end;
      p := p^.Next;
    end;
    if s<>'' then
      TempStream.Write(s[1], Length(s));
  end;

  TempStream.Write(sd[1], Length(sd));
  NewPage := True;
  DataList.Clear;
end;



{---------------------------------------------------------------------}

var
  LastView : string;

procedure TfrRTF_rsExport.OnText(DrawRect: TRect; X, Y: Integer;
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
  Y := Round(Y / (14 / ScaleY));
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


procedure TfrRTF_rsExport.OnData(x, y: Integer; View: TfrView);
  procedure SaveOleToFile( filename : string);
  var
    PStorage : IPersistStorage;
    FStorage : IStorage;
  begin
    TfrOLEView(View).OleContainer.CopyOnSave:=True;
    TfrOLEView(View).OleContainer.OleObjectInterface.QueryInterface(IPersistStorage, PStorage);
    if PStorage <> nil then begin
      StgCreateDocFile(PWideChar(WideString(filename)),
        STGM_READWRITE or STGM_SHARE_EXCLUSIVE or STGM_CREATE,
        0, FStorage);
      OleSave(PStorage,FStorage,False);
      PStorage.SaveCompleted(nil);
    end;
  end;

var
  Str,fStm : TStream;
  n,sx,sy  : Integer;
  MetaFile : TMetaFile;
  Canvas   : TCanvas;
  Graphic  : TGraphic;
  Rect     : TRect;
  S        : String;
  szFN,szTP: PChar;
  bFN, bTP : array [0..8196] of char;
  SL       : TStringList;
begin
  if not NeedExport then Exit;
  LastView := '';

  if View.dx < 0 then
    View.dx := 0;

  if View.dy < 0 then
    View.dy := 0;

//Пока у нас нет человеческой обработки колонтитулов, будем их пропускать
 if not (View.ParentType in [btPageFooter, btPageHeader]) then
  if not FExpGraphics then begin
    OnText(Rect, X,Y, '', View.FrameTyp, View);
  end else if View is TfrPictureView then begin
    Graphic := TfrPictureView(View).Picture.Graphic;
    if not ((Graphic = nil) or Graphic.Empty) then begin
      Str := TMemoryStream.Create;
      Str.Write(x, 4);
      Str.Write(y, 4);
      Str.Write(View.dx, 4);
      Str.Write(View.dy, 4);
      n := Graphic.Width;
      Str.Write(n, 4);
      n := Graphic.Height;
      Str.Write(n, 4);
      Graphic.SaveToStream(Str);
      DataList.Add(Str);
      Rect.Left:=View.X; Rect.Right :=View.X+View.dx;
      Rect.Top :=View.Y; Rect.Bottom:=View.Y+View.dy;
      OnText(Rect, X, Y, '##frImg##'+IntToStr(DataList.Count-1),
             View.FrameTyp, View);
    end;
  end else if View is TfrRichView then begin
    Rect.Left:=View.X; Rect.Right :=View.X+View.dx;
    Rect.Top :=View.Y; Rect.Bottom:=View.Y+View.dy;
    if TfrRichView(View).RichEdit.Lines.Text<>'' then begin
    { TODO : Пока переносится текст без rtf-форматирования }
      Str := TMemoryStream.Create;
      SL := TStringList.Create;
      try
        SL.Assign(TfrRichView(View).RichEdit.Lines);
        SL.SaveToStream(Str);
        DataList.Add(Str);
        OnText(Rect,X,Y, '##frRich#'+IntToStr(DataList.Count-1), View.FrameTyp, View);
      finally
        SL.Free;
      end;
    end else
      OnText(Rect, X,Y, '', View.FrameTyp, View);
  end else if View is TfrOLEView then begin
    Str := TMemoryStream.Create;
    Str.Write(x, 4);
    Str.Write(y, 4);
    Str.Write(View.dx, 4);
    Str.Write(View.dy, 4);
    n:=length(TfrOLEView(View).OleContainer.OleClassName);
    Str.Write(n,4);
    Str.Write(TfrOLEView(View).OleContainer.OleClassName[1],n);

    szTP:=@bTP; GetTempPath(8196,szTP);
    szFN:=@bFN; GetTempFileName(szTP,'rsE',0,szFN);
    s:=szFN;
    SaveOLEToFile(s);
    fStm:=TFileStream.Create(s,fmOpenRead);
    Str.CopyFrom(fStm,0);
    fStm.Free;
    DeleteFile(szFN);

    DataList.Add(Str);

    Rect.Left:=0; Rect.Right :=View.dx;
    Rect.Top :=0; Rect.Bottom:=View.dy;
    TfrOLEView(View).OleContainer.Width  := View.dx;
    TfrOLEView(View).OleContainer.Height := View.dy;
    MetaFile:=TMetaFile.Create;
    Metafile.Width  := View.dx;
    Metafile.Height := View.dy;
    MetaFile.Enhanced:=False;
    Canvas:=TMetafileCanvas.Create(Metafile, 0);
    if TfrOLEView(View).OleContainer.OleObjectInterface <> nil then
      OleDraw(TfrOLEView(View).OleContainer.OleObjectInterface,
              DVASPECT_CONTENT, Canvas.Handle , Rect);
    Canvas.Free;
    Str := TMemoryStream.Create;
    Str.Write(x, 4);
    Str.Write(y, 4);
    Str.Write(View.dx, 4);
    Str.Write(View.dy, 4);
    Metafile.SaveToStream(Str);
    MetaFile.Free;

    DataList.Add(Str);

    Rect.Left:=View.X; Rect.Right :=View.X+View.dx;
    Rect.Top :=View.Y; Rect.Bottom:=View.Y+View.dy;
    OnText(Rect,X,Y, '##frOLE##'+IntToStr(DataList.Count-1), View.FrameTyp, View);
  end else if View is TfrShapeView then begin
    Rect.Left:=View.X; Rect.Right :=View.X+View.dx;
    Rect.Top :=View.Y; Rect.Bottom:=View.Y+View.dy;
    Str := TMemoryStream.Create;
    Str.Write(x, 4);
    Str.Write(y, 4);
    Str.Write(View.dx, 4);
    Str.Write(View.dy, 4);
    str.Write(TfrShapeView(View).ShapeType, 1);
    Str.Write(View.FrameStyle,sizeof(View.FrameStyle));
    Str.Write(View.FrameWidth,sizeof(View.FrameWidth));
    Str.Write(View.FrameColor,sizeof(View.FrameColor));
    Str.Write(View.FillColor,sizeof(View.FillColor));
    DataList.Add(Str);
    OnText(Rect,X,Y, '##frShap#'+IntToStr(DataList.Count-1), View.FrameTyp, View);
  end else if View is TfrLineView then begin
    Rect.Left:=View.X; Rect.Right :=View.X+View.dx;
    Rect.Top :=View.Y; Rect.Bottom:=View.Y+View.dy;
    Str := TMemoryStream.Create;
    Str.Write(x, 4);
    Str.Write(y, 4);
    Str.Write(View.dx, 4);
    Str.Write(View.dy, 4);
    Str.Write(View.FrameStyle,sizeof(View.FrameStyle));
    Str.Write(View.FrameWidth,sizeof(View.FrameWidth));
    Str.Write(View.FrameColor,sizeof(View.FrameColor));
    DataList.Add(Str);
    OnText(Rect,X,Y, '##frLine#'+IntToStr(DataList.Count-1), View.FrameTyp, View);
  end else begin
    MetaFile:=TMetaFile.Create;
    Metafile.Width  := View.dx;
    Metafile.Height := View.dy;
    MetaFile.Enhanced:=False;
    Canvas:=TMetafileCanvas.Create(Metafile, 0);
    sx:=View.x; sy:=View.y;
    View.x:=0;  View.y:=0;
    View.Draw(Canvas);
    View.x:=sx; View.y:=sy;
    Canvas.Free;
    Str := TMemoryStream.Create;
    Str.Write(x, 4);
    Str.Write(y, 4);
    Str.Write(View.dx, 4);
    Str.Write(View.dy, 4);
    Metafile.SaveToStream(Str);
    MetaFile.Free;

    DataList.Add(Str);

    Rect.Left:=View.X; Rect.Right :=View.X + View.dx;
    Rect.Top :=View.Y; Rect.Bottom:=View.Y + View.dy;
    OnText(Rect,X,Y, '##frMImg#'+IntToStr(DataList.Count-1), View.FrameTyp, View);
    Str.Free;
  end;
end;


procedure TfrRTF_rsExportForm.FormCreate(Sender: TObject);
begin
  Button1.Caption := LoadStr(SOk);
  Button2.Caption := LoadStr(SCancel);
end;

procedure TfrRTF_rsExportForm.rbtnRangePagesClick(Sender: TObject);
begin
  lblTo.Enabled := True;
  lblFrom.Enabled := True;
  edTo.Enabled := True;
  edFrom.Enabled := True;
end;

procedure TfrRTF_rsExportForm.rbtnAllPagesClick(Sender: TObject);
begin
  lblTo.Enabled := False;
  lblFrom.Enabled := False;
  edTo.Enabled := False;
  edFrom.Enabled := False;
end;

function TfrRTF_rsExport.NeedExport: Boolean;
begin
  Result := (not FRangePages) or
    (FCurrentPage >= FFrom) and (FCurrentPage <= FTo);
end;

end.
