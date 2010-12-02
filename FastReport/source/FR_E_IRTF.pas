
{******************************************}
{                                          }
{             FastReport v2.4              }
{       Improved RTF export filter         }
{                                          }
{     Original version by Tzyganenko A.    }
{     Improved version by Ishenin    P.    }
{                                          }
{******************************************}

{
  Очень много переделано.
  Все основные элементы остались старые, точнее в них были внесены изменения.
  Изменения :
  1. Добавлено указание полей и размера страницы.
  2. Добавлен вывод диаграмм как рисунков.
  3. Изменены коэффициенты пересчета положений объектов и их размера.
  4. Скорректированы положения объектов относительно полей.
  5. Скорректированы размер и положения рамок вокруг рисунков, так и размеры
     самих рисунков.
  6. При выводе в виде таблицы дополнительно указывается высота ячейки, что 
     приводит к точной передаче таблицы из FastReport'а в Word.
  7. При выводе в виде текста без таблиц указывается межстрочный интервал, что
     приводит к точной передаче положения строк текста из FastReport'а в Word.
  8. При появлении пустот в тексте они переносятся в Rtf в виде пустой
     рамки нужной высоты и нужного положения. Для вариации типа одна рамка на 
     всю пустоту или рамка до рисунка и рамка после рисунка помещен флажок на
     форму и добавлено свойство OneFrameToSpace.
  9. Обработка KillEmptyLines убрана, т.к. если не KillEmptyLines, то выводился
     мусор, а следовательно текст выглядел коряво в Word'е.
 10. Изменен формат вывода новой строки при отчете без таблиц, что приводит
     к уменьшению размера выдаваемого файла.
 11. Решена проблема с текстом, который не влезает в рамку(мемо). Теперь при
     экспорте с таблицами он находится на следующих строках ячеек (его не видно,
     но он есть как и в FastReport'е), а при экспорте без таблиц не влезший
     текст просто не выводится.
 12. Добавлено указания цвета заливки ячейки (если он не белый). Ранее заливка
     ячеек не влияла на содержимое RTF файла.
 13. Добавлено указание цвета рамки (если он не черный). Ранее при формировании
     RTF файла цвет рамки в расчет не брался.
 14. Для простоты использования (хотя может быть для кого-то и нет)
     инициализация экспорта осуществляется в момент инициализации модуля, так
     что для использования достаточно просто в модуле проекта добавить этот
     экспорт в раздел uses. 

Использовать в виде компоненты без переделки модуля не рекомендуется, т.к. 
в текущей реализации вместо одного экземпляра класса у вас создастся второй 
ненужный.

За вопросами и предложениями обращайтесь по e-mail : webpirat@mail.ru
                                            http   : free1c.narod.ru
Ишенин Павел
}

unit FR_E_IRTF; { Improved RTF export }

interface

{$I FR.inc}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Forms, StdCtrls, ComCtrls,
  FR_Class, Controls;

type
  PfrRtfRec = ^TfrRtfRec;
  TfrRtfRec = record
    Next: PfrRtfRec;
    X: Integer;
    Text: String;
    FontName: String[32];
    FontSize, FontStyle, FontColor, FontCharset, Space, FillColor: Integer;
    FrameColor : Integer;
    DrawRect: TRect;
    FrameTyp: Integer;
    Alignment:integer;
  end;
  PRect = ^TRect;

  TfrIRtfExport = class(TfrExportFilter)
  private
    FExportBitmaps, FConvertToTable: Boolean;
    TempStream: TStream;
    FontTable, ColorTable: TStringList;
    DataList: TList;
    NewPage: Boolean;
    Margins : TRect;
    Objs : TList; // Для сохранения координат объектов на странице
    LastSL : Integer;
    PardFlag : Boolean;
  protected
    FScaleX, FScaleY: Double;
    FOneFrame, FConvertToOEM, FExportFrames,
    FUsePseudographic, FPageBreaks: Boolean;
    Strings: TStringList;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ShowModal: Word; override;
    procedure OnEndPage; override;
    procedure OnBeginPage; override;
    procedure OnText(DrawRect: TRect; X, Y: Integer; const Text: String;
      FrameTyp: Integer; View: TfrView); override;
    procedure InsertTextRec(p: PfrRtfRec; LineIndex: Integer);
    procedure OnData(x, y: Integer; View: TfrView); override;
    procedure OnBeginDoc; override;
    procedure OnEndDoc; override;
  published
    property ExportBitmaps: Boolean read FExportBitmaps write FExportBitmaps default False;
    property ConvertToTable: Boolean read FConvertToTable write FConvertToTable default False;
    property ScaleX: Double read FScaleX write FScaleX;
    property ScaleY: Double read FScaleY write FScaleY;
    property OneFrameToSpace: Boolean read FOneFrame write FOneFrame default True;
    property ConvertToOEM: Boolean read FConvertToOEM write FConvertToOEM default False;
    property ExportFrames: Boolean read FExportFrames write FExportFrames default False;
    property UsePseudographic: Boolean read FUsePseudographic write FUsePseudographic default False;
    property PageBreaks: Boolean read FPageBreaks write FPageBreaks default True;
  end;

  TfrRTFExportFm = class(TForm)
    GroupBox1: TGroupBox;
    CB1: TCheckBox;
    Label1: TLabel;
    E1: TEdit;
    Button1: TButton;
    Button2: TButton;
    CB5: TCheckBox;
    Label2: TLabel;
    Label3: TLabel;
    E2: TEdit;
    CB2: TCheckBox;
    CB3: TCheckBox;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
  end;


implementation

uses FR_Const, FR_Utils, FR_Chart, Dialogs;

{$R *.DFM}


{ TfrRTFExport }

constructor TfrIRtfExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Strings := TStringList.Create;
  FOneFrame := True;
  ConvertToOEM := False;
  ExportFrames := False;
  UsePseudographic := False;
  PageBreaks := True;
  ShowDialog := True;
  ScaleX := 1;
  ScaleY := 1;
  ExportBitmaps := False;
  ConvertToTable := True;
  Objs := TList.Create;
end;
{
  Исправлено неверное значение полей и размера бумаги.
  Теперь значения полей и размера бумаги устанавливаются из значений первой
  печатной страницы текущего отчета.
  Ранее писалась строка
  s := '{\rtf1\ansi' + #13#10 + '\margl600\margr600\margt600\margb600' + #13#10; 
  Где цифры 600 - означали около 10 мм.
  Исправлено из расчета 567 - 10 мм. Значение 567 взято из rtf файлов,
  сохраняемых Word 97.
  Размер бумаги считается приблизительно правильно из-за округления значений.
  Тем не менее можно более точно указывать размер бумаги опираясь не на
  значения pgWidth и pgHeight страницы, а на значение pgSize и только если
  размер равен $100, то на ширину и высоту.
}
procedure TfrIRtfExport.OnBeginDoc;
const TemplateStr = '{\rtf1\ansi' + #13#10 + '\paperw%d\paperh%d\margl%d\margr%d\margt%d\margb%d' + #13#10;
var
  s: String;
  FirstPage : TfrPage;
  PageIndex : Integer;
begin
  FontTable := TStringList.Create;
  ColorTable := TStringList.Create;
  DataList := TList.Create;
  TempStream := TMemoryStream.Create;
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
  end else s := Format(TemplateStr, [11907, 16840, Margins.Left, Margins.Right, Margins.Top, Margins.Bottom]);
  Stream.Write(s[1], Length(s));
  NewPage  := False;
  LastSL   := -1;
  PardFlag := True;
end;

procedure TfrIRtfExport.OnEndDoc;
var
  i, c: Integer;
  s, s1: String;
begin
  s := '\par}';
  TempStream.Write(s[1], Length(s));
  s := '{\fonttbl';
  for i := 0 to FontTable.Count - 1 do
  begin
    s1 := '{\f' + IntToStr(i) + ' ' + FontTable[i] + '}';
    if Length(s + s1) < 255 then
      s := s + s1
    else
    begin
      s := s + #13#10;
      Stream.Write(s[1], Length(s));
      s := s1;
    end;
  end;
  s := s + '}' + #13#10;
  Stream.Write(s[1], Length(s));

  s := '{\colortbl;';
  for i := 0 to ColorTable.Count - 1 do
  begin
    c := StrToInt(ColorTable[i]);
    s1 := '\red' + IntToStr(GetRValue(c)) +
          '\green' + IntToStr(GetGValue(c)) +
          '\blue' + IntToStr(GetBValue(c)) + ';';
    if Length(s + s1) < 255 then
      s := s + s1
    else
    begin
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

function TfrIRtfExport.ShowModal: Word;
begin
  if not ShowDialog then
    Result := mrOk
  else with TfrRTFExportFm.Create(nil) do
  begin
    CB1.Checked := FOneFrame;
    CB2.Checked := ExportBitmaps;
    CB3.Checked := ConvertToTable;
    CB5.Checked := PageBreaks;
    E1.Text := FloatToStr(ScaleX);
    E2.Text := FloatToStr(ScaleY);

    Result := ShowModal;
    try
      ScaleX := frStrToFloat(E1.Text);
    except
      ScaleX := 1;
    end;
    try
      ScaleY := frStrToFloat(E2.Text);
    except
      ScaleY := 1;
    end;
    FOneFrame := CB1.Checked;
    ExportBitmaps := CB2.Checked;
    ConvertToTable := CB3.Checked;
    PageBreaks := CB5.Checked;
    Free;
  end;
end;

procedure TfrIRtfExport.OnEndPage;
var
  i, j, n, n1, x, x1, y, dx, dy, correction, the_left, lasty: Integer;
  p,pPrior: PfrRtfRec;
  s0, s, s1, txt, bordercolor: String;
  fSize, fStyle, fColor: Integer;
  fName: String;
  Str: TStream;
  bArr: Array[0..1023] of Byte;
  _Rect : TRect;

  function GetFontStyle(f: Integer): String;
  begin
    Result := '';
    if (f and $1) <> 0 then Result := '\i';
    if (f and $2) <> 0 then Result := Result + '\b';
    if (f and $4) <> 0 then Result := Result + '\u';
  end;

  function GetFontColor(f: String): String;
  var
    i: Integer;
  begin
    i := ColorTable.IndexOf(f);
    if i <> -1 then
      Result := IntToStr(i + 1)
    else
    begin
      ColorTable.Add(f);
      Result := IntToStr(ColorTable.Count);
    end;
  end;

  function GetFontName(f: String): String;
  var
    i: Integer;
  begin
    i := FontTable.IndexOf(f);
    if i <> -1 then
      Result := IntToStr(i)
    else
    begin
      FontTable.Add(f);
      Result := IntToStr(FontTable.Count - 1);
    end;
  end;

  // Возвращает через параметры область объекта, попадающего в заданные координаты
  // Передаем Rect и получаем Rect
  // Rect.Top, Rect.Left - координаты пред. текстового фрагмента
  // Rect.Bottom, Rect.Right - координаты текущего текстового фрагмента
  function GetObjectRect(var Rect : Trect) : Boolean;
  var i : Integer;
      ObjTop, ObjBottom : Integer;
  begin
    Result := False;
    If Objs.Count = 0 then Exit;
    for i := 0 to Objs.Count - 1 do
    begin
      ObjTop := PRect(Objs[i])^.Top;
      ObjBottom := PRect(Objs[i])^.Bottom;
      if (ObjTop >= Rect.Top) and (ObjBottom <= Rect.Bottom) then
      begin
        Result := True;
        Rect.Top := ObjTop;
        Rect.Bottom := ObjBottom;
      end;
    end;
  end;
  function GetRtfBorder(Rect : TRect) : String;
  begin
    Result := Format('\pard\phmrg\posx%d\posy%d\absh-%d\absw%d\par' + #$D#$A, 
                     [Round(Rect.Left / ScaleX * 15.75)-Margins.Left,
                      Round(Rect.Top * 15.75) - Margins.Top,
                      Round((Rect.Bottom - Rect.Top) * 15.75),
                      Round((Rect.Right - Rect.Left) * 15.75)
                     ]
                    );
    PardFlag := True;
  end;
begin
  if NewPage and PageBreaks then
  begin
    s := '\page ' + #13#10;
    TempStream.Write(s[1], Length(s));
  end;

  n := Lines.Count - 1;
  while n >= 0 do
  begin
    if Lines[n] <> nil then break;
    Dec(n);
  end;

  lasty := -1;
  for i := 0 to n do
  begin
    p := PfrRtfRec(Lines[i]);
    if p = nil then continue;
    s := '';
    fSize := -1; fStyle := -1; fColor := -1; fName := '';

    If (lasty <> -1) and ((p^.DrawRect.Top - lasty) > 2) then
    begin
      If not FOneFrame then
      begin
        _Rect.Top := lasty;
        _Rect.Bottom := p^.DrawRect.Top;
        If GetObjectRect(_Rect) then // Если между строками текта затесался объект, то
        begin                      // вставляем рамку одну перед объектом, одну после объекта
          If (_Rect.Top - lasty) > 2 then s0 := GetRtfBorder(Rect(p^.DrawRect.Left, lasty + 1, p^.DrawRect.Right, _Rect.Top-1)) else
            s0 := '';
          If (p^.DrawRect.Top - _Rect.Bottom) > 2 then s0 := s0 +
            GetRtfBorder(Rect(p^.DrawRect.Left, _Rect.Bottom+2, p^.DrawRect.Right, p^.DrawRect.Top-1));
        end else s0 := GetRtfBorder(Rect(p^.DrawRect.Left, lasty+2, p^.DrawRect.Right, p^.DrawRect.Top-1));
      end else
        s0 := GetRtfBorder(Rect(p^.DrawRect.Left, lasty+2, p^.DrawRect.Right, p^.DrawRect.Top-1));
    end else s0 := '';
    lasty := p^.DrawRect.Bottom;

    if ConvertToTable then
      // значение 30 определяет отступ текста внутри ячейки от границ
      s0 := s0 + '\trowd \trgaph30' else if PardFlag then
      begin
        s0 := s0 + '\pard \sl-' + IntToStr(p^.Space) + '\slmult0';
        LastSL := p^.Space;
        PardFlag := False;
      end;

    x1 := 0;

    the_left := Round(p^.DrawRect.Left/ ScaleX * 15.75 ) - (Margins.Left + 30);
    correction := Margins.Left + 30;

    pPrior:=nil; //  предыдущее значение
    while p <> nil do
    begin
      if ConvertToTable then
      begin
        // Если существует пропуск между ячейками, например при многоколоночном отчете
        if (pPrior<>nil)and(Abs(Round((p^.DrawRect.Left))-
          Round((pPrior^.DrawRect.Right)))>3) then
        begin
          s0 := s0 + '\cellx' + IntToStr(Round((pPrior^.DrawRect.Right-1) * 15.75 / ScaleX)-correction);
          // Обрамление
          if (p^.FrameTyp and frftLeft) <> 0 then
            s0:=s0+'\clbrdrr\brdrw15\brdrs';
          if (pPrior^.FrameTyp and frftRight) <> 0 then
            s0:=s0+'\clbrdrl\brdrw15\brdrs';
          s := s + '{' + ' ' + '}\cell ';
        end;
        if p <> PfrRtfRec(Lines[i]) then
        begin
          s0 := s0 + '\cellx' + IntToStr(Round(p^.DrawRect.Left*15.75 / ScaleX )-correction);
        end;
        If (p^.FillColor mod 16777216) <> clWhite then
          s0 := s0 + '\clcbpat' + GetFontColor(IntToStr(p^.FillColor));
        If (p^.FrameColor mod 16777216) <> clBlack then
          bordercolor := '\brdrcf' + GetFontColor(IntToStr(p^.FrameColor)) else
          bordercolor := '';
        if (p^.FrameTyp and frftLeft) <> 0 then
          s0:=s0+'\clbrdrl\brdrw15\brdrs'+bordercolor;
        if (p^.FrameTyp and frftTop) <> 0 then
          s0:=s0+'\clbrdrt\brdrw15\brdrs'+bordercolor;
        if (p^.FrameTyp and frftBottom) <> 0 then
          s0:=s0+'\clbrdrb\brdrw15\brdrs'+bordercolor;
        if (p^.FrameTyp and frftRight) <> 0 then
          s0:=s0+'\clbrdrr\brdrw15\brdrs'+bordercolor;
      end
      else
      begin
        dx := Round(p^.X / ScaleX * 15.75)-correction;
        if dx > 1 then
          s := s + '\tx' + IntToStr(dx) else dx := 0;
      end;  
      s1 := '';
      
      if (fName <> p^.FontName) or ConvertToTable then
        s1 := s1 + '\f' + GetFontName(p^.FontName);
      if (fSize <> p^.FontSize) or ConvertToTable then
        s1 := s1 + '\fs' + IntToStr(p^.FontSize * 2);

      If (not ConvertToTable) and (LastSL <> p^.Space) then
      begin
        s0 := s0 + '\sl-' + IntToStr(p^.Space);
        LastSL := p^.Space;
        PardFlag := True;
      end;

      if (fStyle <> p^.FontStyle) or ConvertToTable then
        s1 := s1 + GetFontStyle(p^.FontStyle);
      if (fColor <> p^.FontColor) or ConvertToTable then
        s1 := s1 + '\cf' + GetFontColor(IntToStr(p^.FontColor));

      if ConvertToTable then
      begin
        if p^.Alignment=0 then s:=s+'\ql'
        else if p^.Alignment=1 then s:=s+'\qr'
        else if p^.Alignment=2 then s:=s+'\qc'
        else if p^.Alignment=3 then s:=s+'\qj'
        else s:=s+'\ql';
        txt := p^.Text;
        while (p^.Next <> nil) and (p^.DrawRect.Left = p^.Next^.DrawRect.Left) and
                                   (p^.DrawRect.Top = p^.Next^.DrawRect.Top)   do
        begin // Решение проблемы с невлезшим текстом для таблиц
          p := p^.Next;
          txt := p^.Text + ' \par ' + txt;
        end;
        s := s + '{' + s1 + ' ' + txt + '}\cell ';
      end else
      begin // Решение проблемы с невлезшим текстом для экспорта без таблиц
        while (p^.Next <> nil) and (p^.DrawRect.Left = p^.Next^.DrawRect.Left) and
                                   (p^.DrawRect.Top = p^.Next^.DrawRect.Top)   do
          p := p^.Next;
        If dx = 0 then s := s + s1 + ' ' + p^.Text else
                       s := s + '\tab' + s1 + ' ' + p^.Text;
      end;  

      fSize := p^.FontSize; fStyle := p^.FontStyle;
      fColor := p^.FontColor; fName := p^.FontName;
      x1 := Round((p^.DrawRect.Right-1) / ScaleX * 15.75) - correction;
      pPrior:=p;
      p := p^.Next;
    end;

    p := PfrRtfRec(Lines[i]);
    if ConvertToTable then
    begin
      s0 := s0 + '\cellx' + IntToStr(x1) + ' \trleft' +
           IntToStr(the_left) + ' \trrh-'+IntToStr(Round((p^.DrawRect.Bottom - p^.DrawRect.Top-1) / ScaleY*15.75));
      s := s0 + ' \pard \intbl ' + s + '\pard \intbl \row' + #13#10;
    end else s := s0 + '{' + s + '\par}' + #13#10;
    if s = '' then 
    begin
      s := '{\pard \par}' + #13#10;
      PardFlag := True;
    end;
    TempStream.Write(s[1], Length(s));
  end;

  if ExportBitmaps then
    for i := 0 to DataList.Count - 1 do
    begin
      Str := TStream(DataList[i]);
      Str.Position := 0;
      Str.Read(x, 4);
      Str.Read(y, 4);
      Str.Read(dx, 4);
      Str.Read(dy, 4);
{
  Скорректирован размер рамки вокруг рисунка
  Положение рамки как и раньше из расчета 1 мм = 56,7. Из-за перевода точек в
  сантиметры умножаем на 5/18.
}
      PardFlag := True;      
      s := '\pard\phmrg\posx' + IntToStr(Round(x / ScaleX * 15.75)-Margins.Left) +
           '\posy' + IntToStr(Round(y * 15.75) - Margins.Top) +
           '\absh-' + IntToStr(Round(dy * 15.75)) +
           '\absw' + IntToStr(Round(dx * 15.75)) +
           '{\pict\wmetafile8\picw' + IntToStr(Round(dx * 500 / 18)) +
           '\pich' + IntToStr(Round(dy * 500 / 18)) + ' \picbmp\picbpp4' + #13#10;
      TempStream.Write(s[1], Length(s));
  // shit begins
      Str.Read(dx, 4);
      Str.Read(dy, 4);
      Str.Read(n, 2);
      Str.Read(n, 4);
      n := n div 2 + 7;
      s0 := IntToHex(n + $24, 8);
      s := '010009000003' + Copy(s0, 7, 2) + Copy(s0, 5, 2) +
           Copy(s0, 3, 2) + Copy(s0, 1, 2) + '0000';
      s0 := IntToHex(n, 8);
      s1 := Copy(s0, 7, 2) + Copy(s0, 5, 2) + Copy(s0, 3, 2) + Copy(s0, 1, 2);
      s := s + s1 + '0000050000000b0200000000050000000c02';
      s0 := IntToHex(dy, 4);
      s := s + Copy(s0, 3, 2) + Copy(s0, 1, 2);
      s0 := IntToHex(dx, 4);
      s := s + Copy(s0, 3, 2) + Copy(s0, 1, 2) +
           '05000000090200000000050000000102ffffff000400000007010300' + s1 +
           '430f2000cc000000';
      s0 := IntToHex(dy, 4);
      s := s + Copy(s0, 3, 2) + Copy(s0, 1, 2);
      s0 := IntToHex(dx, 4);
      s := s + Copy(s0, 3, 2) + Copy(s0, 1, 2) + '00000000';
      s0 := IntToHex(dy, 4);
      s := s + Copy(s0, 3, 2) + Copy(s0, 1, 2);
      s0 := IntToHex(dx, 4);
      s := s + Copy(s0, 3, 2) + Copy(s0, 1, 2) + '00000000' + #13#10;
      TempStream.Write(s[1], Length(s));
  // shit ends

      Str.Read(bArr[0], 8);
      n1 := 0; s := '';
      repeat
        n := Str.Read(bArr[0], 1024);
        for j := 0 to n - 1 do
        begin
          s := s + IntToHex(bArr[j], 2);
          Inc(n1);
          if n1 > 63 then
          begin
            n1 := 0;
            s := s + #13#10;
            TempStream.Write(s[1], Length(s));
            s := '';
          end;
        end;
      until n < 1024;
      Str.Free;
      if n1 <> 0 then
        TempStream.Write(s[1], Length(s));

      s := '030000000000}\par' + #13#10;
      TempStream.Write(s[1], Length(s));
    end;

  if ConvertToTable then
  begin
    s := '\pard' + #13#10;
    TempStream.Write(s[1], Length(s));
  end;
  NewPage := True;
  DataList.Clear;
  while Objs.Count > 0 do
  begin
    Dispose(PRect(Objs[0]));
    Objs.Delete(0);
  end;
end;

procedure TfrIRtfExport.OnData(x, y: Integer; View: TfrView);
var
  Str: TStream;
  n: Integer;
  Graphic: TGraphic;
  Bitmap : TBitmap;
  _Rect : PRect;
begin
  if View is TfrPictureView then
  begin
    Graphic := TfrPictureView(View).Picture.Graphic;
    if not ((Graphic = nil) or Graphic.Empty) then
    begin
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
      New(_Rect);
      _Rect^ := Rect(View.x, View.y, View.x + View.dx, View.y + View.dy);
      Objs.Add(_Rect);
    end;
  end
{$IFDEF TeeChart}
  else if View is TfrChartView then
  begin
    Bitmap := TBitmap.Create;
    Bitmap.Width  := View.x + View.dx + 1;
    Bitmap.Height := View.y + View.dy + 1;
    (View as TfrChartView).Draw(Bitmap.Canvas);
    Bitmap.Canvas.CopyRect(Rect(0, 0, View.dx + 1, View.dy + 1), Bitmap.Canvas,
               Rect(View.x, View.y, View.x + View.dx + 1, View.y + View.dy + 1));
    Bitmap.Width  := View.dx + 1;
    Bitmap.Height := View.dy + 1;
    If not Bitmap.Empty then
    begin
      Str := TMemoryStream.Create;
      Str.Write(x, 4);
      Str.Write(y, 4);
      Str.Write(View.dx, 4);
      Str.Write(View.dy, 4);
      n := Bitmap.Width;
      Str.Write(n, 4);
      n := Bitmap.Height;
      Str.Write(n, 4);
      Bitmap.SaveToStream(Str);
      DataList.Add(Str);
      New(_Rect);
      _Rect^ := Rect(View.x, View.y, View.x + View.dx, View.y + View.dy);
      Objs.Add(_Rect);
    end;
    Bitmap.Free;
  end{$ENDIF};
end;

procedure TfrRTFExportFm.Localize;
begin
  Caption := frLoadStr(frRes + 1820);
  CB1.Caption := frLoadStr(frRes + 1823);
  CB2.Caption := frLoadStr(frRes + 1821);
  CB3.Caption := frLoadStr(frRes + 1822);
  CB5.Caption := frLoadStr(frRes + 1805);
  Label1.Caption := frLoadStr(frRes + 1806);
  Button1.Caption := frLoadStr(SOk);
  Button2.Caption := frLoadStr(SCancel);
end;

procedure TfrRTFExportFm.FormCreate(Sender: TObject);
begin
  Localize;
end;


destructor TfrIRtfExport.Destroy;
begin
  Strings.Free;
  Objs.Free;
  inherited Destroy;
end;

procedure TfrIRtfExport.OnBeginPage;
var
  i: Integer;
begin
  ClearLines;
  for i := 0 to 200 do Lines.Add(nil);
end;

procedure TfrIRtfExport.OnText(DrawRect: TRect; X, Y: Integer;
  const Text: String; FrameTyp: Integer; View: TfrView);
var
  p: PfrRtfRec;
  Koef : Real;
begin
  if View = nil then Exit;
{
  То значение Y, что нам передается обычно равно DrawRect.Top + 1. Однако,
  когда текст не влазит в свою рамку (мемо), то значение DrawRect.Top  и Y разли
  чаются, на высоту абзаца, которая нам не нужна.
  Чтобы поствить абзац в тексте надо написать \par, и знание высоты не пригождается.
  ==> значение Y для нас бесполезно и даже вредно при невлезании текста в рамку.
}

  Y := Round({Y} (DrawRect.Top + 1) / (14 / ScaleY));
  New(p);
  p^.X := X;
  p^.Text := Text;
  if View is TfrMemoView then
    with View as TfrMemoView do
    begin
      p^.FontName := Font.Name;
      p^.FontSize := Font.Size;
      Koef := 96/72;
      p^.Space := Abs(Font.Size) * 20 + // Size of font + 
                  Round((DrawRect.Bottom - DrawRect.Top - Abs(Font.Height)) * Koef * 10);
      p^.FontStyle := frGetFontStyle(Font.Style);
      p^.FontColor := Font.Color;
      p^.Alignment:=Alignment;
{$IFNDEF Delphi2}
      p^.FontCharset := Font.Charset;
{$ENDIF}
    end;
  p^.DrawRect   := DrawRect;
  p^.FrameTyp   := FrameTyp;
  p^.FillColor  := View.FillColor;
  p^.FrameColor := View.FrameColor;
  InsertTextRec(p, Y);
end;

procedure TfrIRtfExport.InsertTextRec(p: PfrRtfRec; LineIndex: Integer);
var
  p1, p2: PfrRtfRec;
begin
  p1 := PfrRtfRec(Lines[LineIndex]);
  p^.Next := nil;
  if p1 = nil then
    Lines[LineIndex] := TObject(p)
  else
  begin
    p2 := p1;
    while (p1 <> nil) and (p1^.X < p^.X) do
    begin
      p2 := p1;
      p1 := p1^.Next;
    end;
    if p2 <> p1 then
    begin
      p2^.Next := p;
      p^.Next := p1;
    end
    else
    begin
      Lines[LineIndex] := TObject(p);
      p^.Next := p1;
    end;
  end;
end;

var RtfExportFilter : TfrIRtfExport;

initialization
  RtfExportFilter := TfrIRtfExport.Create(nil);
  frRegisterExportFilter(RtfExportFilter, frLoadStr(SRTFFile) + ' (*.rtf)', '*.rtf');
finalization
  frUnRegisterExportFilter(RtfExportFilter);
  RtfExportFilter.Free;
end.