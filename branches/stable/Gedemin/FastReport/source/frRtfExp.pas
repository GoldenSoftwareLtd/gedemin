{******************************************}
{                                          }
{             FastReport v2.55             }
{          Adv. RTF export filter          }
{          Copyright(c) 1998-2005          }
{           Alexander Fediachov            }
{                                          }
{******************************************}

unit frRtfExp;

interface

{$I Fr.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, extctrls, Clipbrd, Printers, FR_Class, frIEMatrix, frProgr, ShellAPI
{$IFDEF Delphi6}
, Variants
{$ENDIF},
  FR_Progr, FR_Ctrls;

type
  TfrRtfExpSet = class(TForm)
  OK: TButton;
  Cancel: TButton;
    GroupPageRange: TGroupBox;
    Pages: TLabel;
    E_Range: TEdit;
    Descr: TLabel;
    GroupCellProp: TGroupBox;
    CB_PageBreaks: TCheckBox;
    CB_Pictures: TCheckBox;
    procedure FormCreate(Sender: TObject);
 private
    procedure Localize;
end;

TfrRtfAdvExport = class(TfrExportFilter)
  private
    FColorTable: TStringList;
    FCurrentPage: Integer;
    FDataList: TList;
    FExportPageBreaks: Boolean;
    frExportSet: TfrRTFExpSet;
    FExportPictures: Boolean;
    FFirstPage: Boolean;
    FFontTable: TStringList;
    FMatrix: TfrIEMatrix;
    FOpenAfterExport: Boolean;
    FWysiwyg: Boolean;
	  FCreator: String;
    expLeftMargin: Extended;
    expTopmargin: Extended;
    pgList: TStringList;
    procedure AfterExport(const FileName: string);
    function ChangeReturns(Str: string): string;
    function TruncReturns(Str: string): string;
    function GetRTFBorders(Style: TfrIEMStyle): string;
    function GetRTFColor(c: Integer): string;
    function GetRTFFontStyle(f: TFontStyles): String;
    function GetRTFFontColor(f: String): String;
    function GetRTFFontName(f: String): String;
    function GetRTFHAlignment(HAlign: Integer) : String;
    function GetRTFVAlignment(VAlign: Integer) : String;
    procedure ExportPage(Stream: TStream);
    procedure PrepareExport;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ShowModal: Word; override;
    procedure OnBeginDoc; override;
    procedure OnEndPage; override;
    procedure OnBeginPage; override;
    procedure OnData(x, y: Integer; View: TfrView); override;
  published
    property ExportPageBreaks: Boolean read FExportPageBreaks write FExportPageBreaks default True;
    property ExportPictures : Boolean read FExportPictures write FExportPictures default True;
    property LeftMargin : Extended read expLeftMargin write expLeftMargin;
    property PageBreaks : Boolean read FExportPageBreaks write FExportPageBreaks default True;
    property OpenAfterExport: Boolean read FOpenAfterExport
      write FOpenAfterExport default False;
    property TopMargin : Extended read expTopMargin write expTopMargin;
    property Wysiwyg: Boolean read FWysiwyg write FWysiwyg;
    property Creator: String read FCreator write FCreator;
end;


implementation

uses FR_Const, FR_Utils
{$IFDEF Delphi6}
, StrUtils
{$ENDIF};

{$R *.dfm}

const
  Xdivider = 15.8;
  Ydivider = 14.2;
  PageDivider = 5.67;
  MargDivider = 15.8;
  FONT_DIVIDER = 16;
  IMAGE_DIVIDER = 25.3;

constructor TfrRtfAdvExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  frRegisterExportFilter(Self, frLoadStr(frRes + 1870), '*.rtf');
  ShowDialog := True;
  FExportPageBreaks := True;
  FExportPictures := True;
  FWysiwyg := True;
  FOpenAfterExport := True;
  FCreator := 'FastReport http://www.fast-report.com';
  pgList := TStringList.Create;
end;

destructor TfrRtfAdvExport.Destroy;
begin
  frUnRegisterExportFilter(Self);
  pgList.Free;
  inherited;
end;

function TfrRTFAdvExport.TruncReturns(Str: string): string;
begin
  Str := StringReplace(Str, #1, '', [rfReplaceAll]);
  if Copy(Str, Length(Str) - 1, 2) = #13#10 then
    Delete(Str, Length(Str) - 1, 2);
  Result := Str;
end;

function TfrRTFAdvExport.ChangeReturns(Str: string): string;
begin
  Str := StringReplace(Str, '\', '\\', [rfReplaceAll]);
  Str := StringReplace(Str, '{', '\{', [rfReplaceAll]);
  Str := StringReplace(Str, '}', '\}', [rfReplaceAll]);
  Str := StringReplace(Str, #13#10, '\line'#13#10, [rfReplaceAll]);
  Result := Str;
end;


function TfrRTFAdvExport.GetRTFBorders(Style: TfrIEMStyle): string;
var
  brdrw: String;
  brdrc: String;
begin
  Result := '';
  brdrw := '\brdrs\brdrw' + IntToStr(Round(Style.FrameWidth * 20)) + ' ';
  brdrc := '\brdrcf' + GetRTFFontColor(GetRTFColor(Style.FrameColor)) + ' ';
  if (frftTop and Style.FrameTyp) <> 0 then
    Result := Result + '\clbrdrt' + brdrw + brdrc;
  if (frftLeft and Style.FrameTyp) <> 0 then
    Result := Result + '\clbrdrl' + brdrw + brdrc;
  if (frftBottom and Style.FrameTyp) <> 0 then
    Result := Result + '\clbrdrb' + brdrw + brdrc;
  if (frftRight and Style.FrameTyp) <> 0 then
    Result := Result + '\clbrdrr' + brdrw + brdrc;
end;

function TfrRTFAdvExport.GetRTFColor(c: Integer): string;
begin
   Result := '\red' + IntToStr(GetRValue(c)) +
             '\green' + IntToStr(GetGValue(c)) +
             '\blue' + IntToStr(GetBValue(c)) + ';'
end;

function TfrRTFAdvExport.GetRTFFontStyle(f: TFontStyles): String;
begin
  Result := '';
  if f = [fsItalic] then Result := '\i';
  if f = [fsBold] then Result := Result + '\b';
  if f = [fsUnderline] then Result := Result + '\ul';
end;

function TfrRTFAdvExport.GetRTFFontColor(f: String): String;
var
  i: Integer;
begin
  i := FColorTable.IndexOf(f);
  if i <> -1 then
    Result := IntToStr(i + 1)
  else
  begin
    FColorTable.Add(f);
    Result := IntToStr(FColorTable.Count);
  end;
end;

function TfrRTFAdvExport.GetRTFFontName(f: String): String;
var
  i: Integer;
begin
  i := FFontTable.IndexOf(f);
  if i <> -1 then
    Result := IntToStr(i)
  else
  begin
    FFontTable.Add(f);
    Result := IntToStr(FFontTable.Count - 1);
  end;
end;

function TfrRTFAdvExport.GetRTFHAlignment(HAlign: Integer) : String;
begin
  Result:='';
  if (HAlign and frtaLeft) <> 0 then Result := Result + '\ql'
  else if ((HAlign and frtaRight) <> 0) and ((HAlign and frtaCenter) <> 0) then Result := Result + '\ql'
  else if (HAlign and frtaRight) <> 0 then Result := Result + '\qr'
  else if (HAlign and frtaCenter) <> 0 then Result := Result + '\qc'
  else Result := '\ql';
end;

function TfrRTFAdvExport.GetRTFVAlignment(VAlign: Integer) : String;
begin
  Result:='';
  if (VAlign and frtaVertical) <> 0 then Result := Result + '\clvertalt'
  else if (VAlign and frtaMiddle) <> 0 then Result := Result + '\clvertalc'
  else if (VAlign and frtaDown) <> 0 then Result := Result + '\clvertalb'
  else if Result = '' then Result := '\ql';
end;

procedure TfrRTFAdvExport.PrepareExport;
var
  i, j, x, y, n, n1, fx: Integer;
  s, s0, s1, s2: String;
  Obj: TfrIEMObject;
  RepPos: TStringList;
begin
  for y := 0 to FMatrix.Height - 1 do
    for x := 0 to FMatrix.Width - 1 do
    begin
      i := FMatrix.GetCell(x, y);
      if (i <> -1) then
      begin
        Obj := FMatrix.GetObjectById(i);
        if Obj.Counter <> -1 then
        begin
          Obj.Counter := -1;
          GetRTFFontColor(GetRTFColor(Obj.Style.Color));
          GetRTFFontColor(GetRTFColor(Obj.Style.FrameColor));
          if Obj.IsRichText then
          begin
            RepPos := TStringList.Create;
            s := Obj.Memo.Text;
            fx := Pos('{\fonttbl', s);
            Delete(s, 1, fx + 8);
            i := 1;
            RepPos.Clear;
            while (i < Length(s)) and (s[i] <> '}') do
            begin
              while (i < Length(s)) and (s[i] <> '{') do
                Inc(i);
              Inc(i);
              j := i;
              while (j < Length(s)) and (s[j] <> '}') do
                Inc(j);
              Inc(j);
              s1 := Copy(s, i , j - i - 2);
              i := j;
              j := Pos(' ', s1);
              s2 := Copy(s1, j + 1, Length(s1) - j + 1);
              s0 := '\f' + GetRTFFontName(s2);
              j := Pos('\f', s1);
              n := j + 1;
              while (n < Length(s1)) and (s1[n] <> '\') and (s1[n] <> ' ') do
                Inc(n);
              s2 := Copy(s1, j, n - j);
              j := Pos('}}', s);
              s1 := Copy(s, j + 2, Length(s) - j - 1);
              j := j + 2;
              n := 1;
              while n > 0 do
              begin
                n := Pos(s2, s1);
                if n > 0 then
                begin
                  if RepPos.IndexOf(IntToStr(n + j - 1)) = -1 then
                  begin
                    RepPos.Add(IntToStr(n + j - 1));
                    Delete(s, n + j - 1, Length(s2));
                    Insert(s0, s, n + j - 1);
                  end;
                  j := j + n + Length(s2) - 1;
                  s1 := Copy(s, j, Length(s) - j + 1);
                end;
              end;
            end;
            fx := Pos('}}', s);
            if fx > 0 then
              Delete(s, 1, fx + 1);
            fx := Pos('{\colortbl', s);
            if fx > 0 then
            begin
              Delete(s, 1, fx + 11);
              i := 1;
              n1 := 1;
              RepPos.Clear;
              while (i < Length(s)) and (s[i] <> '}') do
              begin
                while (i < Length(s)) and (s[i] <> '\') do
                  Inc(i);
                j := i;
                while (j < Length(s)) and (s[j] <> ';') do
                  Inc(j);
                Inc(j);
                s1 := Copy(s, i , j - i);
                i := j;
                s0 := '\cf' + GetRTFFontColor(s1);
                s2 := '\cf' + IntToStr(n1);
                j := Pos(';}', s);
                s1 := Copy(s, j + 2, Length(s) - j - 1);
                j := j + 2;
                n := 1;
                while n > 0 do
                begin
                  n := Pos(s2, s1);
                  if n > 0 then
                  begin
                    if RepPos.IndexOf(IntToStr(n + j - 1)) = -1 then
                    begin
                      RepPos.Add(IntToStr(n + j - 1));
                      Delete(s, n + j - 1, Length(s2));
                      Insert(s0, s, n + j - 1);
                    end;
                    j := j + n + Length(s2) - 1;
                    s1 := Copy(s, j, Length(s) - j + 1);
                  end;
                end;
                Inc(n1);
              end;
              fx := Pos(';}', s);
              if fx > 0 then
                Delete(s, 1, fx + 1);
            end;
            fx := Pos('{\stylesheet', s);
            if fx > 0 then
            begin
              Delete(s, 1, fx + 12);
              fx := Pos('}}', s);
              if fx > 0 then
                Delete(s, 1, fx + 1);
            end;
            s := StringReplace(s, '\pard', '', [rfReplaceAll]);
            Delete(s, Length(s) - 3, 3);
            Obj.Memo.Text := s;
            RepPos.Free;
          end else if Obj.IsText then
          begin
            GetRTFFontColor(GetRTFColor(Obj.Style.Font.Color));
            GetRTFFontName(Obj.Style.Font.Name);
          end;
        end;
      end;
    end;
end;

function TfrRtfAdvExport.ShowModal: Word;
var
  PageNumbers: string;

  procedure ParsePageNumbers;
  var
    i, j, n1, n2: Integer;
    s: String;
    IsRange: Boolean;
  begin
    s := PageNumbers;
    while Pos(' ', s) <> 0 do
      Delete(s, Pos(' ', s), 1);
    if s = '' then Exit;
    s := s + ',';
    i := 1; j := 1; n1 := 1;
    IsRange := False;
    while i <= Length(s) do
    begin
      if s[i] = ',' then
      begin
        n2 := StrToInt(Copy(s, j, i - j));
        j := i + 1;
        if IsRange then
          while n1 <= n2 do
          begin
            pgList.Add(IntToStr(n1));
            Inc(n1);
          end
        else
          pgList.Add(IntToStr(n2));
        IsRange := False;
      end
      else if s[i] = '-' then
      begin
        IsRange := True;
        n1 := StrToInt(Copy(s, j, i - j));
        j := i + 1;
      end;
      Inc(i);
    end;
    pgList.Sort;
  end;

begin
 if ShowDialog then
 begin
   frExportSet := TfrRtfExpSet.Create(nil);
   frExportSet.CB_Pictures.Checked := FExportPictures;
   Result := frExportSet.ShowModal;
   PageNumbers := frExportSet.E_Range.Text;
   FExportPictures := frExportSet.CB_Pictures.Checked;
   frExportSet.Destroy;
 end
 else
   Result := mrOk;
 pgList.Clear;
 ParsePageNumbers;
end;

procedure TfrRtfAdvExport.ExportPage(Stream: TStream);
var
  i, j, x, y, fx, fy, dx, dy, n, n1, pbk: Integer;
  dcol, drow, xoffs: Integer;
  buff, s, s0, s1, s2: String;
  CellsLine: String;
  Obj: TfrIEMObject;
  Graphic: TGraphic;
  Str, CellsStream: TMemoryStream;
  bArr: array[0..1023] of Byte;

  procedure WriteExpLn(const str: string);
  begin
    if Length(str) > 0 then
    begin
      Stream.Write(str[1], Length(str));
      Stream.Write(#13#10, 2);
    end;
  end;

  procedure SetPageProp(Page: Integer);
  begin
    WriteExpLn('\pgwsxn' + IntToStr(Round(FMatrix.GetPageWidth(Page) * PageDivider)) +
               '\pghsxn' + IntToStr(Round(FMatrix.GetPageHeight(Page) * PageDivider)) +
               '\marglsxn' + IntToStr(Round(FMatrix.GetPageLMargin(Page) * MargDivider)) +
               '\margrsxn' + IntToStr(Round(FMatrix.GetPageRMargin(Page) * MargDivider)) +
               '\margtsxn' + IntToStr(Round(FMatrix.GetPageTMargin(Page) * MargDivider)) +
               '\margbsxn' + IntToStr(Round(FMatrix.GetPageBMargin(Page) * MargDivider)));
    if FMatrix.GetPageOrientation(Page) = poLandscape then
      WriteExpLn('\lndscpsxn');
  end;
begin
  PrepareExport;
  WriteExpLn('{\rtf1\ansi');
  s := '{\fonttbl';
  for i := 0 to FFontTable.Count - 1 do
  begin
    s1 := '{\f' + IntToStr(i) + ' ' + FFontTable[i] + '}';
    if Length(s + s1) < 255 then
      s := s + s1
    else
    begin
      WriteExpLn(s);
      s := s1;
    end;
  end;
  s := s + '}';
  WriteExpLn(s);
  s := '{\colortbl;';
  for i := 0 to FColorTable.Count - 1 do
  begin
    s1 := FColorTable[i];
    if Length(s + s1) < 255 then
      s := s + s1
    else
    begin
      WriteExpLn(s);
      s := s1;
    end;
  end;
  s := s + '}';
  WriteExpLn(s);
  WriteExpLn('{\info{\title ' + CurReport.ReportName +
             '}{\author ' + FCreator +
             '}{\creatim\yr' + FormatDateTime('yyyy', Now) +
             '\mo' + FormatDateTime('mm', Now) + '\dy' + FormatDateTime('dd', Now) +
             '\hr' + FormatDateTime('hh', Now) + '\min' + FormatDateTime('nn', Now) + '}}');
  pbk := 0;
  SetPageProp(pbk);
  for y := 0 to FMatrix.Height - 2 do
  begin
    if FExportPageBreaks then
      if FMatrix.PagesCount > pbk then
        if FMatrix.GetPageBreak(pbk) <= FMatrix.GetYPosById(y) then
        begin
          WriteExpLn('\pard\sect');
          Inc(pbk);
          if pbk < FMatrix.PagesCount then
            SetPageProp(pbk);
          continue;
        end;
    drow := Round((FMatrix.GetYPosById(y + 1) - FMatrix.GetYPosById(y)) * Ydivider);
    buff := '\trrh' + IntToStr(drow)+ '\trgaph15';
    CellsStream := TMemoryStream.Create;
    xoffs := Round(FMatrix.GetXPosById(1));
    for x := 1 to FMatrix.Width - 2 do
    begin
      i := FMatrix.GetCell(x, y);
      if (i <> -1) then
      begin
        Obj := FMatrix.GetObjectById(i);
        FMatrix.GetObjectPos(i, fx, fy, dx, dy);
        if Obj.Counter = -1 then
        begin
          if dy > 1 then
            buff := buff + '\clvmgf';
          if (obj.Style.Color mod 16777216) <> clWhite then
            buff := buff + '\clcbpat' + GetRTFFontColor(GetRTFColor(Obj.Style.Color));
          buff := buff + GetRTFVAlignment(Obj.Style.Align) + GetRTFBorders(Obj.Style) + '\cltxlrtb';
          dcol := Round((Obj.Left + Obj.Width - xoffs) * Xdivider);
          buff := buff + '\cellx' + IntToStr(dcol);
          if Obj.IsText then
          begin
            s := '\f' + GetRTFFontName(Obj.Style.Font.Name);
            if Length(Obj.Memo.Text) > 0 then
              s := s + '\fs' + IntToStr(Obj.Style.Font.Size * 2)
            else
            begin
              j := drow div FONT_DIVIDER;
              if j > 20 then j := 20;
              s := s + '\fs' + IntToStr(j);
            end;
            s := s + GetRTFFontStyle(Obj.Style.Font.Style);
            s := s + '\cf' + GetRTFFontColor(GetRTFColor(Obj.Style.Font.Color));
            if (Obj.IsRichText) then
              s1 := Obj.Memo.Text
            else
              s1 := ChangeReturns(TruncReturns(Obj.Memo.Text));
            if Trim(s1) <> '' then
              s2 := '\sb' + IntToStr(Round(Obj.Style.GapY * Ydivider)) +
                  '\li' + IntToStr(Round((Obj.Style.GapX / 2) * Xdivider)) +
                  '\sl' + IntToStr(Round((Obj.Style.Font.Size + Obj.Style.LineSpacing) * Ydivider)) +
                  '\slmult0'
            else
              s2 := '';
            CellsLine := GetRTFHAlignment(Obj.Style.Align) +
              '{' + s + s2 + ' ' + s1 + '\cell}';
            CellsStream.Write(CellsLine[1], Length(CellsLine));
          end
          else if FExportPictures then
          begin
            Graphic := Obj.Image;
            if not ((Graphic = nil) or Graphic.Empty) then
            begin
              Str := TMemoryStream.Create;
              dx := Round(Obj.Width);
              dy := Round(Obj.Height);
              fx := Graphic.Width;
              fy := Graphic.Height;
              Graphic.SaveToStream(Str);
              Str.Position := 0;
              CellsLine := '{\sb0\li0\sl0\slmult0 {\pict\wmetafile8\picw' + FloatToStr(Round(dx * IMAGE_DIVIDER)) +
                   '\pich' + FloatToStr(Round(dy * IMAGE_DIVIDER)) + '\picbmp\picbpp4' + #13#10;
              CellsStream.Write(CellsLine[1], Length(CellsLine));
              Str.Read(n, 2);
              Str.Read(n, 4);
              n := n div 2 + 7;
              s0 := IntToHex(n + $24, 8);
              s := '010009000003' + Copy(s0, 7, 2) + Copy(s0, 5, 2) +
                   Copy(s0, 3, 2) + Copy(s0, 1, 2) + '0000';
              s0 := IntToHex(n, 8);
              s1 := Copy(s0, 7, 2) + Copy(s0, 5, 2) + Copy(s0, 3, 2) + Copy(s0, 1, 2);
              s := s + s1 + '0000050000000b0200000000050000000c02';
              s0 := IntToHex(fy, 4);
              s := s + Copy(s0, 3, 2) + Copy(s0, 1, 2);
              s0 := IntToHex(fx, 4);
              s := s + Copy(s0, 3, 2) + Copy(s0, 1, 2) +
                   '05000000090200000000050000000102ffffff000400000007010300' + s1 +
                   '430f2000cc000000';
              s0 := IntToHex(fy, 4);
              s := s + Copy(s0, 3, 2) + Copy(s0, 1, 2);
              s0 := IntToHex(fx, 4);
              s := s + Copy(s0, 3, 2) + Copy(s0, 1, 2) + '00000000';
              s0 := IntToHex(fy, 4);
              s := s + Copy(s0, 3, 2) + Copy(s0, 1, 2);
              s0 := IntToHex(fx, 4);
              s := s + Copy(s0, 3, 2) + Copy(s0, 1, 2) + '00000000';
              CellsLine := s + #13#10;
              CellsStream.Write(CellsLine[1], Length(CellsLine));
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
                    CellsLine := s + #13#10;
                    CellsStream.Write(CellsLine[1], Length(CellsLine));
                    s := '';
                  end;
                end;
              until n < 1024;
              Str.Free;
              if n1 <> 0 then
              begin
                CellsLine := s + #13#10;
                CellsStream.Write(CellsLine[1], Length(CellsLine));
              end;
              s := '030000000000}';
              CellsLine := s + '\cell}' + #13#10;
              CellsStream.Write(CellsLine[1], Length(CellsLine));
            end;
          end;
          Obj.Counter := y + 1;
        end
        else
        begin
          if (dy > 1) and (Obj.Counter <> (y + 1))then
          begin
            buff := buff + '\clvmrg';
            buff := buff + GetRTFBorders(Obj.Style) + '\cltxlrtb';
            dcol := Round((Obj.Left + Obj.Width - xoffs) * Xdivider);
            buff := buff + '\cellx' + IntToStr(dcol);
            j := drow div FONT_DIVIDER;
            if j > 20 then
              j := 20;
            CellsLine := '{\fs' + IntToStr(j) + ' \cell}';
            CellsStream.Write(CellsLine[1], Length(CellsLine));
            Obj.Counter := y + 1;
          end;
        end
      end
      end;
    if CellsStream.Size > 0 then
    begin
      s := '\trowd' + buff + '\pard\intbl';
      WriteExpLn(s);
      Stream.CopyFrom(CellsStream, 0);
      WriteExpLn('\pard\intbl{\trowd' + buff + '\row}');
    end;
    CellsStream.Free;
  end;
  WriteExpLn('}');
end;

procedure TfrRtfAdvExport.OnBeginDoc;
begin
    FFirstPage := True;
    FCurrentPage := 0;
    FMatrix := TfrIEMatrix.Create;
  FMatrix.ShowProgress := false;
	if FWysiwyg then
	  FMatrix.Inaccuracy := 0.5
	else
	  FMatrix.Inaccuracy := 10;
  FMatrix.RotatedAsImage := True;
  FMatrix.RichText := True;
  FMatrix.PlainRich := False;
  FMatrix.AreaFill := True;
  FMatrix.CropAreaFill := True;
  FMatrix.DeleteHTMLTags := True;
  FMatrix.BackgroundImage := False;
  FMatrix.Background := False;
  OnAfterExport := AfterExport;
  FFontTable := TStringList.Create;
  FColorTable := TStringList.Create;
  FDataList := TList.Create;
  FCurrentPage := 0;
end;

procedure TfrRtfAdvExport.OnBeginPage;
begin
  Inc(FCurrentPage);
  if FFirstPage then
    FFirstPage := False;
end;

procedure TfrRtfAdvExport.OnData(x, y: Integer; View: TfrView);
var
  ind : integer;

begin
  ind := 0;
  if (pgList.Find(IntToStr(FCurrentPage),ind)) or (pgList.Count = 0) then
    if View is TfrView then
      if (View is TfrMemoView) or
         (FExportPictures and (not (View is TfrMemoView))) then
        FMatrix.AddObject(TfrView(View));
end;

procedure TfrRtfAdvExport.OnEndPage;
var
  ind: integer;
  m: TRect;

begin
  ind := 0;
  m := CurReport.EMFPages[FCurrentPage - 1].pgMargins;
  if m.Left = 0 then m.Left := 18;
  if m.Top = 0  then m.Top := 18;
  if m.Bottom = 0 then m.Bottom := 18;
  if m.Right = 0 then m.Right := 18;
  if (pgList.Find(IntToStr(FCurrentPage),ind)) or (pgList.Count = 0) then
	  FMatrix.AddPage(CurReport.EMFPages[FCurrentPage - 1].pgOr,
      CurReport.EMFPages[FCurrentPage - 1].pgWidth,
      CurReport.EMFPages[FCurrentPage - 1].pgHeight,
      m.Left,	m.Top, m.Right, m.Bottom);
end;

procedure TfrRtfAdvExport.AfterExport(const FileName: string);
var
  Exp: TStream;
begin
  FMatrix.Prepare;
    Exp := TFileStream.Create(FileName, fmCreate);
    try
      ExportPage(Exp);
    finally
      Exp.Free;
    end;
    if FOpenAfterExport then
      ShellExecute(GetDesktopWindow, 'open', PChar(FileName), nil, nil, SW_SHOW);
  FMatrix.Clear;
  FMatrix.Free;
  FFontTable.Free;
  FColorTable.Free;
  FDataList.Free;
end;

procedure TfrRtfExpSet.Localize;
begin
  Ok.Caption := frLoadStr(SOk);
  Cancel.Caption := frLoadStr(SCancel);
  GroupPageRange.Caption := frLoadStr(frRes + 44);
  Pages.Caption := frLoadStr(frRes + 47);
  Descr.Caption := frLoadStr(frRes + 48);
  Caption := frLoadStr(frRes + 1871);
  GroupCellProp.Caption := frLoadStr(frRes + 1850);
  CB_PageBreaks.Caption := frLoadStr(frRes + 1860);
  CB_Pictures.Caption := frLoadStr(frRes + 1863);
end;

procedure TfrRtfExpSet.FormCreate(Sender: TObject);
begin
   Localize;
end;

end.
