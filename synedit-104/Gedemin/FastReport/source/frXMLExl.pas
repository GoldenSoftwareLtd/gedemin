{******************************************}
{                                          }
{             FastReport v2.53             }
{         Excel XML export filter          }
{        Copyright(c) 1998-2004 by         }
{             FastReports Inc.             }
{                                          }
{******************************************}

unit frXMLExl;

interface

{$I Fr.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, extctrls, Clipbrd, Printers, ComObj, FR_Class, frIEMatrix, frProgr
{$IFDEF Delphi6}, Variants {$ENDIF}, FR_Progr, FR_Ctrls;

type
  TfrXMLExcelSet = class(TForm)
    OK: TButton;
    Cancel: TButton;
    Panel1: TPanel;
    GroupCellProp: TGroupBox;
    CB_Borders: TCheckBox;
    CB_WrapWords: TCheckBox;
    CB_HQ: TCheckBox;
    CB_PageBreaks: TCheckBox;
    GroupPageRange: TGroupBox;
    Pages: TLabel;
    Descr: TLabel;
    E_Range: TEdit;
    GroupPageSettings: TGroupBox;
    LeftM: TLabel;
    TopM: TLabel;
    ScX: TLabel;
    Label2: TLabel;
    ScY: TLabel;
    Label9: TLabel;
    E_LMargin: TEdit;
    E_TMargin: TEdit;
    E_ScaleX: TEdit;
    E_ScaleY: TEdit;
    CB_OpenExcel: TCheckBox;
    CB_Numbers: TCheckBox;
    procedure FormCreate(Sender: TObject);
  private
    procedure Localize;
  end;

  TfrXMLExcelExport = class(TfrExportFilter)
  private
    CurrentPage: integer;
    FirstPage: boolean;
    frExportSet: TfrXMLExcelSet;
    pgList: TStringList;
    expWrapWords, expBorders, expNumbers,
      expPageBreaks, expOpenAfter, expHQ: boolean;
    expScaleX, expScaleY, expTopMargin, expLeftMargin: Double;
    Exp: TStream; // Exporting stream
    Excel: Variant;
    IsXML: boolean;
    Matrix: TfrIEMatrix;
    Progress: TfrProgress;
    procedure WriteExpLn(const str: string);
    procedure ExportPage;
    function ChangeReturns(Str: string): string;
    function TruncReturns(Str: string): string;
    procedure AfterExport(const FileName: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ShowModal: Word; override;
    procedure OnBeginDoc; override;
    procedure OnEndPage; override;
    procedure OnBeginPage; override;
    procedure OnData(x, y: Integer; View: TfrView); override;
  published
    property Numbers : Boolean read expNumbers write expNumbers default True;
    property Styles : Boolean read expHQ write expHQ default True;
    property Borders : Boolean read expBorders write expBorders default True;
    property WrapWords : Boolean read expWrapWords write expWrapWords default True;
    property LeftMargin : Double read expLeftMargin write expLeftMargin;
    property OpenExcelAfterExport : Boolean read expOpenAfter write expOpenAfter default False;
    property PageBreaks : Boolean read expPageBreaks write expPageBreaks default True;
    property TopMargin : Double read expTopMargin write expTopMargin;
  end;

implementation

uses FR_Const, FR_Utils;

{$R *.dfm}

const
  Xdivider = 1.36;
  Ydivider = 1.25;
  MargDiv = 96;
  XLMaxHeight = 409;

constructor TfrXMLExcelExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  frRegisterExportFilter(Self, frLoadStr(frRes + 2710), '*.xls');
  frRegisterExportFilter(Self, frLoadStr(frRes + 2711), '*.xml');
  pgList := TStringList.Create;
  ShowDialog := True;
  expWrapWords := True;
  expBorders := True;
  expPageBreaks := True;
  expScaleX := 1.0;
  expScaleY := 1.0;
  expHQ := True;
  expNumbers := True;
  IsXML := false;
end;

destructor TfrXMLExcelExport.Destroy;
begin
  frUnRegisterExportFilter(Self);
  frUnRegisterExportFilter(Self);
  pgList.Free;
  inherited;
end;

function TfrXMLExcelExport.TruncReturns(Str: string): string;
begin
  Str := StringReplace(Str, #1, '', [rfReplaceAll]);
  if Copy(Str, Length(Str) - 1, 2) = #13#10 then
    Delete(Str, Length(Str) - 1, 2);
  Result := Str;
end;

function TfrXMLExcelExport.ChangeReturns(Str: string): string;
var
  i: integer;
  s : string;
begin
   if Pos(#13#10, Str) > 0 then
   begin
     i := 1;
     while i <= Length(str) do
       if Str[i] in ['0'..'9'] then
       begin
         s := '&#' + IntToStr(StrToInt(Str[i]) + 48);
         Delete(Str, i, 1);
         Insert(s, Str, i);
         Inc(i, 4);
       end
       else
         Inc(i);
       Str := StringReplace(Str, #13#10, '&#10', [rfReplaceAll]);
//       Str := StringReplace(Str, '&', '&amp;', [rfReplaceAll]);
       Str := StringReplace(Str, '"', '&quot;', [rfReplaceAll]);
       Str := StringReplace(Str, '<', '&lt;', [rfReplaceAll]);
       Str := StringReplace(Str, '>', '&gt;', [rfReplaceAll]);
   end;
   Result := Str;
end;

procedure TfrXMLExcelExport.WriteExpLn(const str: string);
begin
  if Length(str) > 0 then
    Exp.Write(str[1], Length(str));
end;

procedure TfrXMLExcelExport.ExportPage;
var
  i, x, y, dx, dy, fx, fy, Page: integer;
  dcol, drow: Extended;
  s, sb, si, su : string;
  Vert, Horiz: string;
  obj: TfrIEMObject;
  EStyle: TfrIEMStyle;
  St : string;
  OldSeparator: char;
  PageBreak: TStringList;
  S1 : String;

  procedure AlignFR2AlignExcel(Align: integer; var AlignH, AlignV: string);
  begin
    if (Align and frtaRight) <> 0 then
         if (Align and frtaCenter) <> 0 then AlignH := 'Justify'
         else AlignH := 'Right'
      else if (Align and frtaCenter) <> 0 then AlignH := 'Center'
      else AlignH := 'Left';
    if (Align and frtaMiddle) <> 0 then AlignV := 'Center'
      else if (Align and frtaDown) <> 0 then AlignV := 'Bottom'
      else AlignV := 'Top';
  end;

begin
  PageBreak := TStringList.Create;
  Progress := TfrProgress.Create(nil);
  Progress.Execute(Matrix.PagesCount, 'Exporting pages', true, true);
  WriteExpLn('<?xml version="1.0"?>');
  WriteExpLn('<?mso-application progid="Excel.Sheet"?>');
  WriteExpLn('<?fr-application created="FastReport"?>');
  WriteExpLn('<?fr-application homesite="http://www.fast-report.com"?>');
  WriteExpLn('<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"');
  WriteExpLn(' xmlns:o="urn:schemas-microsoft-com:office:office"');
  WriteExpLn(' xmlns:x="urn:schemas-microsoft-com:office:excel"');
  WriteExpLn(' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"');
  WriteExpLn(' xmlns:html="http://www.w3.org/TR/REC-html40">');
  WriteExpLn('<DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">');
  WriteExpLn('<Title>' + UTF8Encode(CurReport.ReportName) + '</Title>');
  WriteExpLn('<Author>' + UTF8Encode(CurReport.ReportAutor) + '</Author>');
  WriteExpLn('<Created>' + DateToStr(Date) + 'T' + TimeToStr(Time) + 'Z</Created>');
  WriteExpLn('<Version>' + UTF8Encode(CurReport.ReportVersionMajor) + '.' +
    UTF8Encode(CurReport.ReportVersionMinor) + '.' +
    UTF8Encode(CurReport.ReportVersionRelease) + '.' +
    UTF8Encode(CurReport.ReportVersionBuild) + '</Version>');
  WriteExpLn('</DocumentProperties>');
  WriteExpLn('<ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">');
  WriteExpLn('<ProtectStructure>False</ProtectStructure>');
  WriteExpLn('<ProtectWindows>False</ProtectWindows>');
  WriteExpLn('</ExcelWorkbook>');
  if expHQ then
  begin
    WriteExpLn('<Styles>');
    for x := 0 to Matrix.StylesCount - 1 do
    begin
      EStyle := Matrix.GetStyleById(x);
      s := 's'+IntToStr(x);
      WriteExpLn('<Style ss:ID="'+s+'">');
      if fsBold in EStyle.Font.Style then
         sb := ' ss:Bold="1"'
      else
         sb := '';
      if fsItalic in EStyle.Font.Style then
         si := ' ss:Italic="1"'
      else
         si := '';
      if fsUnderline in EStyle.Font.Style then
         su := ' ss:Underline="Single"'
      else
         su := '';
      WriteExpLn('<Font '+
        'ss:FontName="' + EStyle.Font.Name + '" '+
        'ss:Size="' + IntToStr(EStyle.Font.Size) + '" ' +
        'ss:Color="' + HTMLRGBColor(EStyle.Font.Color) + '"' + sb + si + su + '/>');
      WriteExpLn('<Interior ss:Color="' + HTMLRGBColor(EStyle.Color) +
        '" ss:Pattern="Solid"/>');
      AlignFR2AlignExcel(EStyle.Align, Horiz, Vert);
      if EStyle.Rotation > 0 then
        s := 'ss:Rotate="' + IntToStr(EStyle.Rotation) + '"'
      else
        s := '';
      if expWrapWords then
        si := '" ss:WrapText="1" '
      else
        si := '" ss:WrapText="0" ';
      WriteExpLn('<Alignment ss:Horizontal="' + Horiz + '" ss:Vertical="' + Vert + si + s +'/>');
      if expBorders then
      begin
        WriteExpLn('<Borders>');
        if EStyle.FrameWidth > 1 then
          i := 3  else  i := 1;
        s := 'ss:Weight="' + IntToStr(i) + '" ';
        si := 'ss:Color="' + HTMLRGBColor(EStyle.FrameColor) + '" ';
        if (frftLeft and EStyle.FrameTyp) <> 0 then
          WriteExpLn('<Border ss:Position="Left" ss:LineStyle="Continuous" ' + s + si + '/>');
        if (frftRight and EStyle.FrameTyp) <> 0 then
          WriteExpLn('<Border ss:Position="Right" ss:LineStyle="Continuous" ' + s + si + '/>');
        if (frftTop and EStyle.FrameTyp) <> 0 then
          WriteExpLn('<Border ss:Position="Top" ss:LineStyle="Continuous" ' + s + si + '/>');
        if (frftBottom and EStyle.FrameTyp) <> 0 then
          WriteExpLn('<Border ss:Position="Bottom" ss:LineStyle="Continuous" ' + s + si + '/>');
        WriteExpLn('</Borders>');
      end;
      WriteExpLn('</Style>');
    end;
    WriteExpLn('</Styles>');
  end;
  if Length(CurReport.ReportName) > 0 then
    s := CurReport.ReportName
  else
    s := 'Page1';
  WriteExpLn('<Worksheet ss:Name="' + UTF8Encode(s) + '">');
  WriteExpLn('<Table ss:ExpandedColumnCount="'+IntToStr(Matrix.Width)+'"' +
    ' ss:ExpandedRowCount="'+IntToStr(Matrix.Height)+'" x:FullColumns="1" x:FullRows="1">');
  OldSeparator := DecimalSeparator;
  DecimalSeparator := '.';
  for x := 1 to Matrix.Width - 1 do
  begin
     dcol := expScaleX * (Matrix.GetXPosById(x) - Matrix.GetXPosById(x - 1)) / Xdivider;
     WriteExpLn('<Column ss:AutoFitWidth="0" ss:Width="' +
        FloatToStr(dcol) + '"/>');
  end;
  st := '';
  Page := 0;
  for y := 0 to Matrix.Height - 2 do
  begin
    drow := expScaleY * (Matrix.GetYPosById(y + 1) - Matrix.GetYPosById(y)) / Ydivider;
    WriteExpLn('<Row ss:Height="' + FloatToStr(drow) + '">');
    if Matrix.PagesCount > Page then
      if Matrix.GetYPosById(y) >= Matrix.GetPageBreak(Page) then
      begin
        Inc(Page);
        PageBreak.Add(IntToStr(y + 1));
        Progress.Tick;
        if Progress.Terminated then
          break;
      end;
    for x := 0 to Matrix.Width - 1 do
    begin
      if Progress.Terminated then
         break;
      si := ' ss:Index="' + IntToStr(x + 1) + '" ';
      i := Matrix.GetCell(x, y);
      if (i <> -1) then
      begin
       Obj := Matrix.GetObjectById(i);
       if Obj.Counter = 0 then
       begin
         Matrix.GetObjectPos(i, fx, fy, dx, dy);
         Obj.Counter := 1;
         if Obj.IsText then
         begin
           if dx > 1 then
           begin
            s := 'ss:MergeAcross="' + IntToStr(dx - 1) + '" ';
            Inc(dx);
           end
           else
             s := '';
           if dy > 1 then
           begin
             sb := 'ss:MergeDown="' + IntToStr(dy - 1) + '" ';
           end
           else
             sb := '';
           if expHQ then
             st := 'ss:StyleID="' + 's' + IntToStr(Obj.StyleIndex) + '" '
           else
             st := '';
           WriteExpLn('<Cell' + si + s + sb + st + '>');
           s := TruncReturns(Obj.Memo.Text);
           s := ChangeReturns(s);
           //!!!b
           s := StringReplace(S, #$A0, '', [rfReplaceAll]);
           //!!!e
           try
             s1 := StringReplace(S, ',', DecimalSeparator, [rfReplaceAll]);
             s1 := StringReplace(S1, '.', DecimalSeparator, [rfReplaceAll]);
             {if }s1 := FloatToStr(StrToFloat(s1));{ = s then}
               s := s1;
               si := ' ss:Type="Number"';
             {else}
             //!!!b
               {si := ' ss:Type="Number"'}
             //!!!e
           except
             si := ' ss:Type="String"';
           end;
           WriteExpLn('<Data' + si + '>' + UTF8Encode(s) + '</Data>');
           WriteExpLn('</Cell>');
         end;
       end
      end else
        WriteExpLn('<Cell' + si + '/>');
    end;
    WriteExpLn('</Row>');
  end;
  WriteExpLn('</Table>');
  WriteExpLn('<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">');
  WriteExpLn('<PageSetup>');
  if CurReport.EMFPages[0].pgor = poLandscape then
    WriteExpLn('<Layout x:Orientation="Landscape"/>');

  WriteExpLn('<PageMargins x:Bottom="' + FloatToStr(CurReport.EMFPages[0].pgMargins.Bottom / MargDiv) +
          '" x:Left="' + FloatToStr(CurReport.EMFPages[0].pgMargins.Left / MargDiv) +
          '" x:Right="' + FloatToStr(CurReport.EMFPages[0].pgMargins.Right / MargDiv) +
          '" x:Top="' + FloatToStr(CurReport.EMFPages[0].pgMargins.Top / MargDiv) + '"/>');
  WriteExpLn('</PageSetup>');
  WriteExpLn('</WorksheetOptions>');
  DecimalSeparator := OldSeparator;
  if expPageBreaks then
  begin
    WriteExpLn('<PageBreaks xmlns="urn:schemas-microsoft-com:office:excel">');
    WriteExpLn('<RowBreaks>');
    for i := 0 to Matrix.PagesCount - 2 do
    begin
      WriteExpLn('<RowBreak>');
      WriteExpLn('<Row>' + PageBreak[i] + '</Row>');
      WriteExpLn('</RowBreak>');
    end;
    WriteExpLn('</RowBreaks>');
    WriteExpLn('</PageBreaks>');
  end;
  WriteExpLn('</Worksheet>');
  WriteExpLn('</Workbook>');
  PageBreak.Free;
  Progress.Free;
end;

function TfrXMLExcelExport.ShowModal: Word;
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
    if ExtractFileExt(FileName) = '.xml' then
      IsXML := true
    else
      IsXML := false;
    frExportSet := TfrXMLExcelSet.Create(nil);
    frExportSet.CB_WrapWords.Checked := expWrapWords;
    frExportSet.CB_Borders.Checked := expBorders;
    frExportSet.CB_PageBreaks.Checked := expPageBreaks;
    frExportSet.CB_OpenExcel.Checked := expOpenAfter;
    frExportSet.CB_HQ.Checked := expHQ;
    frExportSet.CB_Numbers.Checked := expNumbers;
    frExportSet.E_ScaleX.Text := FloatToStr(Int(expScaleX * 100));
    frExportSet.E_ScaleY.Text := FloatToStr(Int(expScaleY * 100));
    frExportSet.E_TMargin.Text := FloatToStr(expTopMargin);
    frExportSet.E_LMargin.Text := FloatToStr(expLeftMargin);
    if IsXML then
    begin
      frExportSet.Caption := frLoadStr(frRes + 2712);
      frExportSet.CB_OpenExcel.Visible := false;
    end
    else
    begin
      frExportSet.Caption := frLoadStr(frRes + 2713);
      frExportSet.CB_OpenExcel.Visible := true;
    end;
    Result := frExportSet.ShowModal;
    PageNumbers := frExportSet.E_Range.Text;
    expWrapWords := frExportSet.CB_WrapWords.Checked;
    expBorders := frExportSet.CB_Borders.Checked;
    expPageBreaks := frExportSet.CB_PageBreaks.Checked;
    expOpenAfter := frExportSet.CB_OpenExcel.Checked;
    expHQ := frExportSet.CB_HQ.Checked;
    expNumbers := frExportSet.CB_Numbers.Checked;
    expScaleX := StrToInt(frExportSet.E_ScaleX.Text) / 100;
    expScaleY := StrToInt(frExportSet.E_ScaleY.Text) / 100;
    expTopMargin := StrToFloat(frExportSet.E_TMargin.Text);
    expLeftMargin := StrToFloat(frExportSet.E_LMargin.Text);
    frExportSet.Destroy;
  end
  else
    Result := mrOk;
  pgList.Clear;
  ParsePageNumbers;
end;

procedure TfrXMLExcelExport.OnBeginDoc;
begin
  CurReport.Terminated := false;
  OnAfterExport := AfterExport;
  CurrentPage := 0;
  FirstPage := true;
  Matrix := TfrIEMatrix.Create;
  Matrix.ShowProgress := False;
  Matrix.MaxCellHeight := XLMaxHeight * Ydivider;
  Matrix.Inaccuracy := 0.5;
end;

procedure TfrXMLExcelExport.OnBeginPage;
begin
  Inc(CurrentPage);
end;

procedure TfrXMLExcelExport.OnData(x, y: Integer; View: TfrView);
var
  ind: integer;
begin
  ind := 0;
  if (pgList.Find(IntToStr(CurrentPage),ind)) or (pgList.Count = 0) then
    if View is TfrView then
      Matrix.AddObject(View);
end;

procedure TfrXMLExcelExport.OnEndPage;
var
  ind: integer;
begin
  ind := 0;
  if (pgList.Find(IntToStr(CurrentPage),ind)) or (pgList.Count = 0) then
    Matrix.AddPage(poLandscape, 0, 0, 0, 0, 0, 0);
end;

procedure TfrXMLExcelExport.AfterExport(const FileName: string);
begin
  if CurReport.Terminated then
    exit;
  DeleteFile(FileName);
  Exp := TFileStream.Create(FileName, fmCreate);
  Matrix.Prepare;
  ExportPage;
  Exp.Free;
  Matrix.Free;
  if CurReport.Terminated then
    exit;
  try
    if expOpenAfter then
    begin
      Excel := CreateOLEObject('Excel.Application');
      Excel.Visible := true;
      Excel.WorkBooks.Open(FileName);
      Excel := Unassigned;
    end;
  except
    Excel := Unassigned;
  end;
end;

//////////////////////////////////////////////

procedure TfrXMLExcelSet.Localize;
begin
  Ok.Caption := frLoadStr(SOk);
  Cancel.Caption := frLoadStr(SCancel);
  GroupPageRange.Caption := frLoadStr(frRes + 44);
  Pages.Caption := frLoadStr(frRes + 47);
  Descr.Caption := frLoadStr(frRes + 48);
  Caption := frLoadStr(frRes + 1844);
  GroupPageSettings.Caption := frLoadStr(frRes + 1845);
  Topm.Caption := frLoadStr(frRes + 1846);
  Leftm.Caption := frLoadStr(frRes + 1847);
  ScX.Caption := frLoadStr(frRes + 1848);
  ScY.Caption := frLoadStr(frRes + 1849);
  GroupCellProp.Caption := frLoadStr(frRes + 1850);
  CB_Borders.Caption := frLoadStr(frRes + 1854);
  CB_WrapWords.Caption := frLoadStr(frRes + 1855);
  CB_PageBreaks.Caption := frLoadStr(frRes + 1860);
  CB_HQ.Caption := frLoadStr(frRes + 2700);
  CB_Numbers.Caption := frLoadStr(frRes + 2714);
  CB_OpenExcel.Caption := frLoadStr(frRes + 1864);
end;

procedure TfrXMLExcelSet.FormCreate(Sender: TObject);
begin
   Localize;
end;

end.
