{******************************************}
{                                          }
{             FastReport v2.53             }
{         HTML table export filter         }
{        Copyright(c) 1998-2004 by         }
{             FastReports Inc.             }
{                                          }
{******************************************}

unit frHTMExp;

interface

{$I Fr.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, extctrls, Clipbrd, Printers, ComObj, FR_Class, JPEG, ShellAPI
{$IFDEF Delphi6}, Variants {$ENDIF}, FR_Progr, FR_Ctrls, ComCtrls, frProgr, frIEMatrix;

type
  TfrHTMLExprSet = class(TForm)
    OK: TButton;
    Cancel: TButton;
    Panel1: TPanel;
    CB_OpenAfter: TCheckBox;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
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
    GroupPageRange: TGroupBox;
    Pages: TLabel;
    Descr: TLabel;
    E_Range: TEdit;
    GroupCellProp: TGroupBox;
    CB_Borders: TCheckBox;
    CB_HQ: TCheckBox;
    CB_PageBreaks: TCheckBox;
    CB_Pictures: TCheckBox;
    CB_PicsSame: TCheckBox;
    CB_FixWidth: TCheckBox;
    CB_Navigator: TCheckBox;
    CB_Multipage: TCheckBox;
    CB_Mozilla: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure CB_PageBreaksClick(Sender: TObject);
  private
    procedure Localize;
  end;

  TfrHTMLTableExport = class(TfrExportFilter)
  private
    CurrentPage: integer;
    FirstPage: boolean;
    frExportSet: TfrHTMLExprSet;
    pgList: TStringList;
    CntPics: integer;
    expPictures, expBorders, expPageBreaks,
      expHQ, expPicsSame, expMozilla,
      expOpenAfter, expFixWidth, expNavigator, expMultipage: boolean;
    expScaleX, expScaleY, expTopMargin, expLeftMargin: Double;
    Exp: TStream; // Exporting stream
    Progress: TfrProgress;
    Matrix: TfrIEMatrix;
    procedure WriteExpLn(const str: string);
    procedure ExportPage;
    function ChangeReturns(Str: string): string;
    function TruncReturns(Str: string): string;
    procedure AfterExport(const FileName: string);
    function GetPicsFolder: string;
    function GetPicsFolderRel: string;
    procedure PrepareExportPage;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ShowModal: Word; override;
    procedure OnBeginDoc; override;
    procedure OnEndPage; override;
    procedure OnBeginPage; override;
    procedure OnData(x, y: Integer; View: TfrView); override;
  published
    property OpenAfterExport : Boolean read expOpenAfter write expOpenAfter default False;
    property FixedWidth : Boolean read expFixWidth write expFixWidth default False;
    property Pictures : Boolean read expPictures write expPictures default True;
    property PicsInSameFolder : Boolean read expPicsSame write expPicsSame default False;
    property Styles : Boolean read expHQ write expHQ default True;
    property Borders : Boolean read expBorders write expBorders default True;
    property LeftMargin : Double read expLeftMargin write expLeftMargin;
    property PageBreaks : Boolean read expPageBreaks write expPageBreaks default True;
    property Navigator : Boolean read expNavigator write expNavigator default False;
    property Multipage : Boolean read expMultipage write expMultipage default False;
    property MozillaFrames : Boolean read expMozilla write expMozilla default false;
    property TopMargin : Double read expTopMargin write expTopMargin;
  end;

implementation

uses FR_Const, FR_Utils;

{$R *.dfm}

const
  Xdivider = 1;
  Ydivider = 1;

constructor TfrHTMLTableExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  frRegisterExportFilter(Self, frLoadStr(frRes + 2720), '*.html');
  pgList := TStringList.Create;
  ShowDialog := True;
  expBorders := True;
  expPageBreaks := True;
  expScaleX := 1.0;
  expScaleY := 1.0;
  expPictures := True;
  expPicsSame := False;
  expHQ := True;
  expOpenAfter := false;
  expFixWidth := False;
  expNavigator := False;
  expMultipage := False;
  expMozilla := False;
end;

destructor TfrHTMLTableExport.Destroy;
begin
  frUnRegisterExportFilter(Self);
  pgList.Free;
  inherited;
end;

function TfrHTMLTableExport.TruncReturns(Str: string): string;
begin
  Str := StringReplace(Str, #1, '', [rfReplaceAll]);
  if Copy(Str, Length(Str) - 1, 2) = #13#10 then
    Delete(Str, Length(Str) - 1, 2);
  Result := Str;
end;

function TfrHTMLTableExport.ChangeReturns(Str: string): string;
begin
   Str := StringReplace(Str, #13#10, '<br>', [rfReplaceAll]);
   Str := StringReplace(Str, '&', '&amp;', [rfReplaceAll]);
   Str := StringReplace(Str, '"', '&quot;', [rfReplaceAll]);
   Result := Str;
end;

procedure TfrHTMLTableExport.WriteExpLn(const str: string);
var
  ln : string;
begin
  if Length(str) > 0 then
  begin
    ln := #13#10;
    Exp.Write(str[1], Length(str));
    Exp.Write(ln[1], Length(ln));
  end;
end;

procedure TfrHTMLTableExport.ExportPage;
var
  i, x, y, dx, dy, fx, fy, pbk : integer;
  dcol, drow: integer;
  text, s, sb, si, su : string;
  Vert, Horiz: string;
  obj: TfrIEMObject;
  EStyle: TfrIEMStyle;
  St, buff : string;
  hlink, newpage : boolean;
  jpg : TJPEGImage;
  tableheader : string;

  procedure AlignFR2AlignExcel(Align: integer; var AlignH, AlignV: string);
  begin
    if (Align and frtaRight) <> 0 then
         if (Align and frtaCenter) <> 0 then AlignH := 'justify'
         else AlignH := 'right'
      else if (Align and frtaCenter) <> 0 then AlignH := 'center'
      else AlignH := 'left';
    if (Align and frtaMiddle) <> 0 then AlignV := 'middle'
      else if (Align and frtaDown) <> 0 then AlignV := 'bottom'
      else AlignV := 'top';
  end;

begin
  if CurReport.Terminated then
    exit;

  WriteExpLn('<html><head>');
  WriteExpLn('<meta http-equiv="Content-Type" content="text/html; charset=utf-8">');
  WriteExpLn('<meta name=Generator content="FastReport 3.0 http://www.fast-report.com">');
  if Length(CurReport.ReportName) > 0 then
    s := CurReport.ReportName
  else
    s := ChangeFileExt(ExtractFileName(CurReport.FileName), '');
  WriteExpLn('<title>' + UTF8Encode(s) + '</title>');
  if expHQ then
  begin
    WriteExpLn('<style type="text/css"><!-- ');
    WriteExpLn('.page_break {page-break-before: always;}');
    for x := 0 to Matrix.StylesCount - 1 do
    begin
      EStyle := Matrix.GetStyleById(x);
      s := 's'+IntToStr(x);
      WriteExpLn('.'+s+' {');
      if Assigned(EStyle.Font) then
      begin
        if fsBold in EStyle.Font.Style then
          sb := ' font-weight: bold;'
        else sb := '';
        if fsItalic in EStyle.Font.Style then
          si := ' font-style: italic;'
        else si := ' font-style: normal;';
        if fsUnderline in EStyle.Font.Style then
          su := ' text-decoration: underline;'
        else su := '';
        WriteExpLn(' font-family: ' + EStyle.Font.Name + ';' +
          ' font-size: ' + IntToStr(Round(EStyle.Font.Size * 96 / 72)) + 'px;' +
          ' color: ' + HTMLRGBColor(EStyle.Font.Color) + ';' + sb + si + su);
      end;
      WriteExpLn(' background-color: ' + HTMLRGBColor(EStyle.Color) + ';');
      AlignFR2AlignExcel(EStyle.Align, Horiz, Vert);
      if expBorders then
      begin
        if EStyle.FrameTyp <> 0 then
        begin
          su := IntToStr(Round(EStyle.FrameWidth));
          s := HTMLRGBColor(EStyle.FrameColor);
          si := ' border-color:' + s + ';';
          WriteExpLn(si + ' border-style: solid;');
          if (frftLeft and EStyle.FrameTyp) <> 0 then
            WriteExpLn(' border-left-width: ' + su + ';')
          else WriteExpLn(' border-left-width: 0px;');
          if (frftRight and EStyle.FrameTyp) <> 0 then
            WriteExpLn(' border-right-width: ' + su + ';')
          else WriteExpLn(' border-right-width: 0px;');
          if (frftTop and EStyle.FrameTyp) <> 0 then
            WriteExpLn(' border-top-width: ' + su + ';')
          else WriteExpLn(' border-top-width: 0px;');
          if (frftBottom and EStyle.FrameTyp) <> 0 then
            WriteExpLn(' border-bottom-width: ' + su + ';')
          else WriteExpLn(' border-bottom-width: 0px;');
        end;
      end;
      WriteExpLn(' text-align: ' + Horiz + '; vertical-align: ' + Vert +';');
      WriteExpLn('}');
    end;
    WriteExpLn('--></style>');
  end;
  WriteExpLn('</head>');
  WriteExpLn('<body  bgcolor="#FFFFFF" text="#000000">');
  WriteExpLn('<a name="1"></a>');
  if expFixWidth then
    st := ' width="' + IntToStr(Round(expScaleY * Matrix.MaxWidth / Ydivider)) + '"'
  else st := '';
  tableheader := '<table' + st +' border="0" cellspacing="0" cellpadding="0"';
  WriteExpLn(tableheader + '>');
  pbk := 0;
  st := '';
  newpage := false;
  for y := 0 to Matrix.Height - 2 do
  begin
    if not expMultipage then
      if Progress.Terminated then
        break;
    drow := Round(expScaleY * (Matrix.GetYPosById(y + 1) - Matrix.GetYPosById(y)) / Ydivider);
    s := '';
    if Matrix.PagesCount > pbk then
      if Round(Matrix.GetPageBreak(pbk)) <= Round(Matrix.GetYPosById(y + 1)) then
      begin
        Inc(pbk);
        if not expMultipage then
          Progress.Tick;
        newpage := true;
      end;
    WriteExpLn('<tr height="' + IntToStr(drow) + '"' + s + '>');
    buff := '';
    for x := 0 to Matrix.Width - 2 do
    begin
      if not expMultipage then
        if Progress.Terminated then
          break;
      i := Matrix.GetCell(x, y);
      if (i <> -1) then
      begin
       Obj := Matrix.GetObjectById(i);
       dcol := Round(expScaleX * (Obj.Width) / Xdivider);
       if Obj.Counter = 0 then
       begin
         Matrix.GetObjectPos(i, fx, fy, dx, dy);
         Obj.Counter := 1;
         if dx > 1 then
           s := ' colspan="' + IntToStr(dx) + '"'
         else s := '';
         if dy > 1 then
           sb := ' rowspan="' + IntToStr(dy) + '"'
         else
           sb := '';
         if expHQ then
           st := ' class="' + 's' + IntToStr(Obj.StyleIndex) + '"'
         else
           st := '';
         if Length(Trim(Obj.Memo.Text)) = 0 then
           st := st + ' style={font-size:0px}';
         buff := buff + '<td width="' + IntToStr(dcol) + '"' + s + sb + st + '>';
         if Length(Obj.URL) > 0 then
         begin
           if Obj.URL[1] = '@' then
             if  expMultipage then
             begin
               s := Obj.URL;
               s[1] := ' ';
               Obj.URL := s;
               if expMozilla then
                 Obj.URL := GetPicsFolderRel + Trim(Obj.URL) + '.html'
               else
                 Obj.URL := Trim(Obj.URL) + '.html';
             end else
             begin
               s := Obj.URL;
               s[1] := '#';
               Obj.URL := s;
             end;
           buff := buff + '<a href="' + Obj.URL + '">';
           hlink := true;
         end else
           hlink := false;
         if Obj.IsText then
         begin
           // text
           text := ChangeReturns(TruncReturns(Obj.Memo.Text));
           if Length(text) > 0 then
             buff := buff + UTF8Encode(text)
           else
             buff := buff + '&nbsp';
         end else
         begin
           // pic
           s :=  GetPicsFolder + 'img' + IntToStr(CntPics) + '.jpg';
           jpg := TJPEGImage.Create;
           jpg.Assign(Obj.Image);
           jpg.SaveToFile(s);
           jpg.Free;
           s := GetPicsFolderRel + 'img' + IntToStr(CntPics) + '.jpg';
           buff := buff + '<img src="' + s + '" alt=""/>';
           Inc(CntPics);
         end;
         if hlink then
           buff := buff + '</a>';
         buff := buff + '</td>';
       end;
      end else
      begin
        dcol := Round(expScaleX * (Matrix.GetXPosById(x + 1) - Matrix.GetXPosById(x)) / Xdivider);
        buff := buff + '<td style={font-size:0px} width="' + IntToStr(dcol) + '"/>';
      end
    end;
    WriteExpLn(buff);
    WriteExpLn('</tr>');
    if newpage then
    begin
      WriteExpLn('</table>');
      newpage := false;
      if y < Matrix.Height - 2 then
      begin
        WriteExpLn('<a name="' + IntToStr(pbk + 1) + '"></a>');
        WriteExpLn(tableheader + ' class="page_break">');
      end;
    end;
  end;
  WriteExpLn('</table></body></html>');
end;

function TfrHTMLTableExport.ShowModal: Word;
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
    frExportSet := TfrHTMLExprSet.Create(nil);
    frExportSet.CB_Borders.Checked := expBorders;
    frExportSet.CB_PageBreaks.Checked := expPageBreaks;
    frExportSet.CB_HQ.Checked := expHQ;
    frExportSet.CB_PicsSame.Checked := expPicsSame;
    frExportSet.CB_Pictures.Checked := expPictures;
    frExportSet.CB_OpenAfter.Checked := expOpenAfter;
    frExportSet.CB_FixWidth.Checked := expFixWidth;
    frExportSet.CB_Navigator.Checked := expNavigator;
    frExportSet.CB_Multipage.Checked := expMultipage;
    frExportSet.CB_Mozilla.Checked := expMozilla;
    frExportSet.E_ScaleX.Text := FloatToStr(Int(expScaleX * 100));
    frExportSet.E_ScaleY.Text := FloatToStr(Int(expScaleY * 100));
    frExportSet.E_TMargin.Text := FloatToStr(expTopMargin);
    frExportSet.E_LMargin.Text := FloatToStr(expLeftMargin);
    Result := frExportSet.ShowModal;
    PageNumbers := frExportSet.E_Range.Text;
    expMozilla := frExportSet.CB_Mozilla.Checked;
    expBorders := frExportSet.CB_Borders.Checked;
    expPageBreaks := frExportSet.CB_PageBreaks.Checked;
    expHQ := frExportSet.CB_HQ.Checked;
    expPicsSame := frExportSet.CB_PicsSame.Checked;
    expPictures := frExportSet.CB_Pictures.Checked;
    expScaleX := StrToInt(frExportSet.E_ScaleX.Text) / 100;
    expScaleY := StrToInt(frExportSet.E_ScaleY.Text) / 100;
    expTopMargin := StrToFloat(frExportSet.E_TMargin.Text);
    expLeftMargin := StrToFloat(frExportSet.E_LMargin.Text);
    expOpenAfter := frExportSet.CB_OpenAfter.Checked;
    expFixWidth := frExportSet.CB_FixWidth.Checked;
    expMultipage := frExportSet.CB_Multipage.Checked;
    expNavigator := frExportSet.CB_Navigator.Checked;
    frExportSet.Destroy;
  end
  else
    Result := mrOk;
  pgList.Clear;
  ParsePageNumbers;
end;

procedure TfrHTMLTableExport.OnBeginDoc;
begin
  CurReport.Terminated := false;
  OnAfterExport := AfterExport;
  CurrentPage := 0;
  FirstPage := true;
  CntPics := 0;
  Matrix := TfrIEMatrix.Create;
  if not expMultipage then
    Matrix.ShowProgress := true
  else
    Matrix.ShowProgress := false;
  Matrix.Inaccuracy := 1;
  Matrix.RotatedAsImage := True;
  Matrix.FramesOptimization := True;
end;

procedure TfrHTMLTableExport.OnBeginPage;
begin
  Inc(CurrentPage);
end;

procedure TfrHTMLTableExport.OnData(x, y: Integer; View: TfrView);
var
  ind: integer;
begin
  ind := 0;
  if (pgList.Find(IntToStr(CurrentPage),ind)) or (pgList.Count = 0) then
    if View is TfrView then
      Matrix.AddObject(View);
end;

procedure TfrHTMLTableExport.OnEndPage;
var
  ind: integer;
begin
  if CurReport.Terminated then
    exit;
  ind := 0;
  if (pgList.Find(IntToStr(CurrentPage),ind)) or (pgList.Count = 0) then
  if expMultipage then
  begin
    PrepareExportPage;
    Exp := TFileStream.Create(GetPicsFolder + IntToStr(CurrentPage) + '.html', fmCreate);
    ExportPage;
    Matrix.Clear;
    Exp.Free;
  end;
  if (pgList.Find(IntToStr(CurrentPage),ind)) or (pgList.Count = 0) then
	  Matrix.AddPage(poLandscape, 0, 0, 0, 0, 0, 0);
end;

procedure TfrHTMLTableExport.AfterExport(const FileName: string);
var
  s, st : string;
  i : integer;
begin
  if CurReport.Terminated then
    exit;
  if not expMultipage then
  begin
    Progress := TfrProgress.Create(self);
    Progress.Execute(Matrix.PagesCount - 1, 'Please wait', true, true);
    PrepareExportPage;
    DeleteFile(FileName);
    if expNavigator then
      Exp := TFileStream.Create(GetPicsFolder + 'main.html', fmCreate)
    else
      Exp := TFileStream.Create(FileName, fmCreate);
    ExportPage;
    Exp.Free;
    Progress.Free;
  end;
  if expNavigator then
  begin
    Exp := TFileStream.Create(GetPicsFolder + 'nav.html', fmCreate);
    WriteExpLn('<html><head>');
    WriteExpLn('<style type="text/css"><!--');
    WriteExpLn('.s { font-family: Arial; font-size: 14px; font-weight: bold; font-style: normal;');
    WriteExpLn('text-align: center; vertical-align: middle; }');
    WriteExpLn('--></style></head><body  bgcolor="#FFFFFF" text="#000000" leftmargin="0" topmargin="4">');
    WriteExpLn('<table border="0" cellspacing="0" cellpadding="0" align="center"><tr><td class="s">Pages: '); /// Localize!!!
    if expPageBreaks then
      for i := 0 to CurrentPage - 1 do
      begin
        if expMozilla then
          st := GetPicsFolder
        else
          st := '';
        if expPicsSame then
          st := ChangeFileExt(ExtractFileName(FileName), '.');
        if expMultipage then
          s := '<a href="' + st + IntToStr(i+1) + '.html" target="mainFrame">' + IntToStr(i+1) + '</a>'
        else
          s := '<a href="' + st + 'main.html#' + IntToStr(i+1) + '" target="mainFrame">' + IntToStr(i+1) + '</a>';
        WriteExpLn(s + '&nbsp');
      end;
    WriteExpLn('</td></tr></table></body></html>');
    Exp.Free;
    Exp := TFileStream.Create(FileName, fmCreate);
    WriteExpLn('<html><head>');
    if Length(CurReport.ReportName) > 0 then
      s := CurReport.ReportName
    else
      s := ChangeFileExt(ExtractFileName(CurReport.FileName), '');
    WriteExpLn('<title>' + UTF8Encode(s) + '</title>');
    WriteExpLn('<meta http-equiv="Content-Type" content="text/html; charset=utf-8"></head>');
    WriteExpLn('<frameset rows="*,26" frameborder="YES" border="1" framespacing="0" cols="*">');
    if expMultipage then
      WriteExpLn('<frame name="mainFrame" src="' + GetPicsFolder + '1.html">')
    else
      WriteExpLn('<frame name="mainFrame" src="' + GetPicsFolder + 'main.html">');
    WriteExpLn('<frame name="bottomFrame" src="' + GetPicsFolder + 'nav.html">');
    WriteExpLn('</frameset><noframes><body bgcolor="#FFFFFF" text="#000000"></body></noframes>');
    Exp.Free;
  end;
  frProgressForm.Close;
  if expOpenAfter then
    if expMultipage and (not expNavigator) then
      ShellExecute(GetDesktopWindow, 'open', PChar(GetPicsFolder + '1.html'), nil, nil, SW_SHOW)
    else
      ShellExecute(GetDesktopWindow, 'open', PChar(FileName), nil, nil, SW_SHOW);
  Matrix.Free;
end;

function TfrHTMLTableExport.GetPicsFolderRel: string;
begin
  if expPicsSame then
    result := ChangeFileExt(ExtractFileName(FileName), '.')
  else if expMultipage then
    result := ''
  else
    result := ChangeFileExt(ExtractFileName(FileName),'.files') + '\'
end;

function TfrHTMLTableExport.GetPicsFolder: string;
begin
  if expPicsSame then
    result := ChangeFileExt(ExtractFileName(FileName), '.')
  else
  begin
    result := ChangeFileExt(ExtractFileName(FileName), '.files');
    {$I-}
    MkDir(result);
    {$I+}
    result := result + '\';
  end;
end;

procedure TfrHTMLTableExport.PrepareExportPage;
begin
  Matrix.Prepare;
end;

//////////////////////////////////////////////

procedure TfrHTMLExprSet.Localize;
begin
  Ok.Caption := frLoadStr(SOk);
  Cancel.Caption := frLoadStr(SCancel);
  GroupPageRange.Caption := frLoadStr(frRes + 44);
  Pages.Caption := frLoadStr(frRes + 47);
  Descr.Caption := frLoadStr(frRes + 48);
  GroupPageSettings.Caption := frLoadStr(frRes + 1845);
  Topm.Caption := frLoadStr(frRes + 1846);
  Leftm.Caption := frLoadStr(frRes + 1847);
  ScX.Caption := frLoadStr(frRes + 1848);
  ScY.Caption := frLoadStr(frRes + 1849);
  GroupCellProp.Caption := frLoadStr(frRes + 1850);
  CB_Borders.Caption := frLoadStr(frRes + 1854);
  CB_PageBreaks.Caption := frLoadStr(frRes + 1860);
  Caption := frLoadStr(frRes + 2721);
  CB_HQ.Caption := frLoadStr(frRes + 2700);
  CB_Pictures.Caption := frLoadStr(frRes + 2722);
  CB_PicsSame.Caption := frLoadStr(frRes + 2723);
  CB_OpenAfter.Caption := frLoadStr(frRes + 2724);
  CB_FixWidth.Caption := frLoadStr(frRes + 2725);
  CB_Navigator.Caption := frLoadStr(frRes + 2726);
  CB_Multipage.Caption := frLoadStr(frRes + 2727);
  CB_Mozilla.Caption := frLoadStr(frRes + 2728);
  TabSheet1.Caption := frLoadStr(frRes + 2729);
  TabSheet2.Caption := frLoadStr(frRes + 2730);
end;

procedure TfrHTMLExprSet.FormCreate(Sender: TObject);
begin
   Localize;
   CB_PageBreaksClick(Sender);
end;

procedure TfrHTMLExprSet.CB_PageBreaksClick(Sender: TObject);
begin
   CB_Navigator.Enabled := CB_PageBreaks.Checked;
   CB_Multipage.Enabled := CB_PageBreaks.Checked;
end;

end.
