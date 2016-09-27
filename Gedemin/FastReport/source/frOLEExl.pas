{******************************************}
{                                          }
{             FastReport v2.55             }
{         Excel OLE export filter          }
{          Copyright(c) 1998-2005          }
{          by Alexander Fediachov,         }
{                                          }
{******************************************}

unit frOLEExl;

interface

{$I fr.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, extctrls, Clipbrd, Printers, ComObj, FR_Class, frIEMatrix, frProgr
{$IFDEF Delphi6}
, Variants
{$ENDIF},
  FR_Progr, FR_Ctrls;


type
  TfrOLEExcelSet = class(TForm)
    OK: TButton;
    Cancel: TButton;
    Panel1: TPanel;
    GroupCellProp: TGroupBox;
    CB_Pictures: TCheckBox;
    GroupPageRange: TGroupBox;
    Pages: TLabel;
    Descr: TLabel;
    E_Range: TEdit;
    CB_OpenExcel: TCheckBox;
    procedure FormCreate(Sender: TObject);
  private
    procedure Localize;
  end;

  TFrExcel = class;

  TfrOLEExcelExport = class(TfrExportFilter)
  private
    FCurrentPage: integer;
    frExportSet: TfrOLEExcelSet;
    pgList: TStringList;
    FExcel: TfrExcel;
    FExportPictures: Boolean;
    FExportStyles: Boolean;
    FFirstPage: Boolean;
    FMatrix: TfrIEMatrix;
    FMergeCells: Boolean;
    FOpenExcelAfterExport: Boolean;
    FPageBottom: Extended;
    FPageLeft: Extended;
    FPageRight: Extended;
    FPageTop: Extended;
    FPageOrientation: TPrinterOrientation;
    FProgress: TfrProgress;
    FShowProgress: Boolean;
    FWysiwyg: Boolean;
    FAsText: Boolean;
    FBackground: Boolean;
    FpageBreaks: Boolean;

    expMerged, expWrapWords, expFillColor, expBorders, expAlign,
      expPageBreaks, expFontName, expFontSize, expFontStyle,
      expFontColor, expPictures, expOpenAfter, expHQ: boolean;
    expTopMargin, expLeftMargin: Double;

    procedure ExportPage_Fast;
    function CleanReturns(Str: String): String;
    procedure AfterExport(const FileName: string);
    function FrameTypesToByte(Value: Integer): Byte;
    function GetNewIndex(Strings: TStrings; ObjValue: Integer): Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ShowModal: Word; override;
    procedure OnBeginDoc; override;
    procedure OnEndPage; override;
    procedure OnBeginPage; override;
    procedure OnData(x, y: Integer; View: TfrView); override;
  published
    property HighQuality : Boolean read expHQ write expHQ default True;
    property CellsAlign : Boolean read expAlign write expAlign default True;
    property CellsBorders : Boolean read expBorders write expBorders default True;
    property CellsFillColor : Boolean read expFillColor write expFillColor default True;
    property CellsFontColor : Boolean read expFontColor write expFontColor default True;
    property CellsFontName : Boolean read expFontName write expFontName default True;
    property CellsFontSize : Boolean read expFontSize write expFontSize default True;
    property CellsFontStyle : Boolean read expFontStyle write expFontStyle default True;
    property CellsMerged : Boolean read expMerged write expMerged default True;
    property CellsWrapWords : Boolean read expWrapWords write expWrapWords default True;
    property ExportPictures : Boolean read expPictures write expPictures default True;
    property LeftMargin : Double read expLeftMargin write expLeftMargin;
    property OpenExcelAfterExport : Boolean read expOpenAfter write expOpenAfter default False;
    property PageBreaks : Boolean read expPageBreaks write expPageBreaks default True;
    property TopMargin : Double read expTopMargin write expTopMargin;
    property Wysiwyg: Boolean read FWysiwyg write FWysiwyg default True;
    property AsText: Boolean read FAsText write FAsText;
  end;

  TFrExcel = class(TObject)
  private
    FIsOpened: Boolean;
    FIsVisible: Boolean;
    Excel: Variant;
    WorkBook: Variant;
    WorkSheet: Variant;
    Range : Variant;
    function ByteToFrameTypes(Value: Byte): Integer;
  protected
    function IntToCoord(X, Y: Integer): string;
    function Pos2Str(Pos: Integer): String;
    procedure SetVisible(DoShow: Boolean);
    procedure ApplyStyles(aRanges:TStrings; Kind:byte;aProgress: TfrProgress);
    procedure ApplyFrame(const RangeCoord:string; aFrame:byte);
    procedure SetRowsSize(aRanges: TStrings; Sizes: array of Currency;MainSizeIndex:integer;RowsCount:integer;aProgress: TfrProgress);
    procedure ApplyStyle(const RangeCoord: string; aStyle: integer);
  public
    constructor Create;
    procedure MergeCells;
    procedure SetCellFrame(Frame: Integer);
    procedure SetRowSize(y: Integer; Size: Extended);
    procedure OpenExcel;
    procedure SetColSize(x: Integer; Size: Extended);
    procedure SetPageMargin(Left, Right, Top, Bottom: Extended;
      Orientation: TPrinterOrientation);
    procedure SetRange(x, y, dx, dy: Integer);
    property Visible: Boolean read FIsVisible write SetVisible;
  end;

implementation

uses FR_Const, FR_Utils;

{$R *.dfm}

const
  Xdivider = 8;
  Ydivider = 1.32;

  XLMaxHeight = 409;
  xlLeft = -4131;
  xlRight = -4152;
  xlTop = -4160;
  xlCenter = -4108 ;
  xlBottom = -4107;
  xlJustify = -4130 ;
  xlThin = 2;
  xlHairline = 1;
  xlNone = -4142;
  xlAutomatic = -4105;
  xlInsideHorizontal = 12 ;
  xlInsideVertical = 11 ;
  xlEdgeBottom = 9 ;
  xlEdgeLeft = 7 ;
  xlEdgeRight = 10 ;
  xlEdgeTop = 8 ;
  xlSolid = 1 ;
  xlLineStyleNone = -4142;
  xlTextWindows = 20 ;
  xlNormal = -4143 ;
  xlNoChange = 1 ;
  xlPageBreakManual = -4135 ;

  xlSizeYRound = 0.25;
type
  TArrData = array [1..1] of variant;
  PArrData = ^TArrData;
  PFrameTypes = ^Integer;

constructor TfrOLEExcelExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  frRegisterExportFilter(Self, frLoadStr(frRes + 1840), '*.xls');
  pgList := TStringList.Create;
  ShowDialog := True;
  FMergeCells := True;
  FExportPictures := True;
  FExportStyles := True;
  FShowProgress := True;
  FWysiwyg := True;
  FAsText := False;
  FBackground := True;
  FPageBreaks := True;
end;

destructor TfrOLEExcelExport.Destroy;
begin
  frUnRegisterExportFilter(Self);
  pgList.Free;
  inherited;
end;

function TfrOLEExcelExport.FrameTypesToByte(Value: Integer): Byte;
begin
  Result := PByte(@Value)^
end;

function TfrOLEExcelExport.GetNewIndex(Strings: TStrings; ObjValue: Integer): Integer;
var
  L, H, I, C: Integer;
begin
  Result:=0;
  if Strings.Count > 0 then
  begin
    L := 0;
    H := Strings.Count - 1;
    while L <= H do
    begin
      I := (L + H) shr 1;
      C:= Integer(Strings.Objects[I]) - ObjValue;
      if C < 0 then
        L := I + 1
      else begin
        H := I - 1;
        if C = 0 then
        begin
          L := I;
          break;
        end;
      end;
    end;
    Result := L;
  end;
end;
function TfrOLEExcelExport.CleanReturns(Str: string): string;
var
  i: integer;
begin
   i := Pos(#13, Str);
   while i > 0 do
   begin
      if i > 0 then Delete(Str, i, 1);
      i := Pos(#13, Str);
   end;
   i := Pos(#1, Str);
   while i > 0 do
   begin
      if i > 0 then Delete(Str, i, 1);
      i := Pos(#1, Str);
   end;
   while Copy(Str, Length(str), 1) = #10 do
      Delete(Str, Length(Str), 1);
   Result := Str;
end;

procedure TfrOLEExcelExport.ExportPage_Fast;
var
  i, fx, fy, x, y, dx, dy: Integer;
  dcol, drow: Extended;
  s: OLEVariant;
  Vert, Horiz: Integer;
  ExlArray: Variant;

  obj: TfrIEMObject;
  EStyle: TfrIEMStyle;
  XStyle: Variant;
  Pic: TPicture;
  PicFormat: Word;
  PicData: Cardinal;
  PicPalette: HPALETTE;
  PicCount: Integer;
  PBreakCounter: Integer;
  RowSizes: array of Currency;
  RowSizesCount: array of Integer;
  imc: Integer;
  ArrData: PArrData;
  j: Integer;
  FixRow: String;
  CurRowSize: Integer;
  CurRangeCoord: String;
  vRowsToSizes: TStrings;
  vCellStyles: TStrings;
  vCellFrames: TStrings;
  vCellMerges: TStrings;
//  CurValIsFloat: Boolean;
//  conv : Extended;

  procedure AlignFR2AlignExcel(Align: integer; var AlignH, AlignV: integer);
  begin
    if (Align and frtaRight) <> 0 then
         if (Align and frtaCenter) <> 0 then AlignH := xlJustify
         else AlignH := xlRight
      else if (Align and frtaCenter) <> 0 then AlignH := xlCenter
      else AlignH := xlLeft;
    if (Align and frtaMiddle) <> 0 then AlignV := xlCenter
      else if (Align and frtaDown) <> 0 then AlignV := xlBottom
      else AlignV := xlTop;
  end;

  function RoundSizeY(const Value: Extended; xlSizeYRound: Currency): Currency;
  begin
    Result := Round(Value / xlSizeYRound) * xlSizeYRound
  end;

  function GetSizeIndex(const aSize: Currency): integer;
  var
    i: integer;
    c: integer;
  begin
    c := Length(RowSizes);
    for i := 0 to c - 1 do
    begin
      if RowSizes[i] = aSize then
      begin
        Result := i;
        RowSizesCount[i] := RowSizesCount[i] + 1;
        Exit
      end;
    end;
    SetLength(RowSizes, c + 1);
    SetLength(RowSizesCount,c + 1);
    RowSizes[c] := aSize;
    RowSizesCount[c] := 1;
    Result := c
  end;

begin
  PicCount := 0;
  FExcel.SetPageMargin(FPageLeft, FPageRight, FPageTop, FPageBottom, FPageOrientation);

  if FShowProgress then
  begin
    FProgress := TfrProgress.Create(self);
    FProgress.Execute(FMatrix.Height - 1, 'Process Rows', True, True);
  end
  else FProgress := nil;

  PBreakCounter := 0;

  FixRow := 'A1';
  CurRowSize := 0;
  vRowsToSizes := TStringList.Create;
  try
    vRowsToSizes.Capacity := FMatrix.Height;
    imc := 0;
    for y := 1 to FMatrix.Height - 1 do
    begin
      if FShowProgress then
      begin
       if FProgress.Terminated then
         break;
       FProgress.Tick;
      end;

      if (FMatrix.GetCellYPos(y) >= FMatrix.GetPageBreak(PBreakCounter)) and FpageBreaks then
      begin
        FExcel.WorkSheet.Rows[y + 2].PageBreak := xlPageBreakManual;
        Inc(PBreakCounter);
      end;

      drow := (FMatrix.GetYPosById(y) - FMatrix.GetYPosById(y - 1)) / Ydivider;
      j := GetSizeIndex(RoundSizeY(drow, xlSizeYRound));
      if RowSizesCount[j] > RowSizesCount[imc] then
        imc := j;
      if y > 1 then
      begin
        if j <> CurRowSize then
        begin
          if FixRow <> 'A' + IntToStr(y - 1) then
            CurRangeCoord := FixRow + ':A' + IntToStr(y - 1)
          else
            CurRangeCoord := FixRow;
          i := GetNewIndex(vRowsToSizes, CurRowSize);
          vRowsToSizes.InsertObject(i, CurRangeCoord, TObject(CurRowSize));
          FixRow := 'A' + IntToStr(y);
          CurRowSize := j;
        end;
      end;
      if y = FMatrix.Height - 1 then
      begin
        CurRangeCoord := FixRow + ':A' + IntToStr(y);
        i := GetNewIndex(vRowsToSizes, j);
        vRowsToSizes.InsertObject(i, CurRangeCoord, TObject(j));
      end;
    end;
    FExcel.SetRowsSize(vRowsToSizes, RowSizes, imc, FMatrix.Height, FProgress)
  finally
    vRowsToSizes.Free;
  end;

  if FShowProgress then
    if not FProgress.Terminated then
      FProgress.Execute(FMatrix.Width - 1, 'Process Columns', True, True);

  for x := 1 to FMatrix.Width - 1 do
  begin
    if FShowProgress then
    begin
      if FProgress.Terminated then
        break;
      FProgress.Tick;
    end;
    dcol := (FMatrix.GetXPosById(x) - FMatrix.GetXPosById(x - 1)) / Xdivider;
    FExcel.SetColSize(x, dcol);
  end;

  if FShowProgress then
    if not FProgress.Terminated then
      FProgress.Execute(FMatrix.StylesCount - 1, 'Process Styles', True, True);

  for x := 0 to FMatrix.StylesCount - 1 do
  begin
    if FShowProgress then
    begin
      if FProgress.Terminated then break;
      FProgress.Tick;
    end;
    EStyle := FMatrix.GetStyleById(x);
    s := 'S' + IntToStr(x);
    XStyle := FExcel.Excel.ActiveWorkbook.Styles.Add(s);
    XStyle.Font.Bold := fsBold in EStyle.Font.Style;
    XStyle.Font.Italic := fsItalic in EStyle.Font.Style;
    XStyle.Font.Underline := fsUnderline in EStyle.Font.Style;;
    XStyle.Font.Name := EStyle.Font.Name;
    XStyle.Font.Size := EStyle.Font.Size;
    XStyle.Font.Color:= EStyle.Font.Color;
    XStyle.Interior.Color := EStyle.Color;
    if (EStyle.Rotation > 0) and (EStyle.Rotation <= 90) then
      XStyle.Orientation := EStyle.Rotation
    else
      if (EStyle.Rotation < 360) and (EStyle.Rotation >= 270) then
        XStyle.Orientation := EStyle.Rotation - 360;

    AlignFR2AlignExcel(EStyle.Align, Horiz, Vert);
    XStyle.VerticalAlignment := Vert;
    XStyle.HorizontalAlignment := Horiz;
    Application.ProcessMessages;
  end;
  ExlArray := VarArrayCreate([1, FMatrix.Height , 1, FMatrix.Width ], varVariant);
  if FShowProgress then
    if not FProgress.Terminated then
      FProgress.Execute(FMatrix.Height, 'Process Objects', True, True);
  ArrData := VarArrayLock(ExlArray) ;
  vCellStyles := TStringList.Create;
  vCellFrames := TStringList.Create;
  vCellMerges := TStringList.Create;
  try
    for y := 1 to FMatrix.Height do
    begin
      if FShowProgress then
      begin
        if FProgress.Terminated then
          Break;
        FProgress.Tick;
      end;
      for x := 1 to FMatrix.Width do
      begin
        i := FMatrix.GetCell(x - 1, y - 1);
        if i <> -1 then
        begin
          Obj := FMatrix.GetObjectById(i);
          if Obj.Counter = 0 then
          begin
            Obj.Counter := 1;
            FMatrix.GetObjectPos(i, fx, fy, dx, dy);
            with FExcel do
            if  (dx>1) or (dy>1) then
              CurRangeCoord := IntToCoord(x, y)+ ':' +
                IntToCoord(x + dx - 1, y + dy - 1)
            else
              CurRangeCoord := IntToCoord(x, y);
            if FExportStyles then
            begin
              j := GetNewIndex(vCellStyles, Obj.StyleIndex);
              vCellStyles.InsertObject(j, CurRangeCoord, TObject(Obj.StyleIndex));
            end;

            if FMergeCells then
              if (dx > 1) or (dy > 1) then
                vCellMerges.Add(CurRangeCoord);
            if FExportStyles then
            begin
              i := FrameTypesToByte(obj.Style.FrameTyp);
              if i <> 0 then
              begin
                j := GetNewIndex(vCellFrames, i);
                vCellFrames.InsertObject(j, CurRangeCoord, TObject(i));
              end;
            end;

            s := CleanReturns(Obj.Memo.Text);

              ArrData^[y + FMatrix.Height * (x - 1)] := s;
            if not Obj.IsText then
            begin
              FExcel.SetRange(x, y, dx, dy);
              Inc(PicCount);
              Pic := TPicture.Create;
              Pic.Bitmap.Assign(Obj.Image);
              Pic.SaveToClipboardFormat(PicFormat, PicData, PicPalette);
              Clipboard.SetAsHandle(PicFormat,THandle(PicData));
              FExcel.Range.PasteSpecial(EmptyParam, EmptyParam, EmptyParam, EmptyParam);
              FExcel.WorkSheet.Pictures[PicCount].Left := FExcel.WorkSheet.Pictures[PicCount].Left + 1;
              FExcel.WorkSheet.Pictures[PicCount].Top := FExcel.WorkSheet.Pictures[PicCount].Top + 1;
              FExcel.WorkSheet.Pictures[PicCount].Width := Pic.Width / 1.38;
              FExcel.WorkSheet.Pictures[PicCount].Height := Pic.Height/ 1.38;
              Pic.Free;
            end;
          end;
        end;
      end;
    end;

    if FExportStyles then
    begin
      FExcel.ApplyStyles(vCellStyles, 0, FProgress);
      FExcel.ApplyStyles(vCellFrames, 1, FProgress);
    end;
    if FMergeCells then
      FExcel.ApplyStyles(vCellMerges, 2, FProgress);
  finally
    VarArrayUnlock(ExlArray);
    vCellStyles.Free;
    vCellFrames.Free;
    vCellMerges.Free;
  end;
  FExcel.SetRange(1, 1, FMatrix.Width , FMatrix.Height);
  FExcel.Range.Value := ExlArray;
  FExcel.WorkSheet.Cells.WrapText := True;
  if FShowProgress then
    FProgress.Free;
end;
function TfrOLEExcelExport.ShowModal: Word;
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
  frExportSet := TfrOLEExcelSet.Create(nil);
  frExportSet.CB_Pictures.Checked := FExportPictures;
  frExportSet.CB_OpenExcel.Checked := FOpenExcelAfterExport;
  Result := frExportSet.ShowModal;
  PageNumbers := frExportSet.E_Range.Text;
  FExportPictures := frExportSet.CB_Pictures.Checked;
  FOpenExcelAfterExport := frExportSet.CB_OpenExcel.Checked;
  frExportSet.Destroy;
 end
 else
   Result := mrOk;
 pgList.Clear;
 ParsePageNumbers;
end;

procedure TfrOLEExcelExport.OnBeginDoc;
begin
  FFirstPage := True;
  FMatrix := TfrIEMatrix.Create;
  FMatrix.ShowProgress := true;
  FMatrix.MaxCellHeight := XLMaxHeight * Ydivider;
  FMatrix.BackgroundImage := False;
  FMatrix.Background := FBackground;
  FMatrix.MaxCellHeight := 409 * Ydivider;
  if FWysiwyg then
    FMatrix.Inaccuracy := 0.5
  else
    FMatrix.Inaccuracy := 10;
  FMatrix.RotatedAsImage := False;
  FMatrix.DeleteHTMLTags := True;
  OnAfterExport := AfterExport;
  FMatrix.Printable := False;
  FExcel := TfrExcel.Create;
  FExcel.OpenExcel;
  FCurrentPage := 0;
end;

procedure TfrOLEExcelExport.OnBeginPage;
var
  m: TRect;
begin
  Inc(FCurrentPage);
  if FFirstPage then
  begin
    m := CurReport.EMFPages[FCurrentPage - 1].pgMargins;
    FFirstPage := False;
    FPageLeft := m.Left / Ydivider;
    FPageTop := m.Top / Ydivider;
    FPageBottom := m.Bottom / Ydivider;
    FPageRight := m.Right / Ydivider;
    FPageOrientation := CurReport.EMFPages[FCurrentPage - 1].pgOr;
  end;
end;

procedure TfrOLEExcelExport.OnData(x, y: Integer; View: TfrView);
var
  ind: integer;
begin
  ind := 0;
  if (pgList.Find(IntToStr(FCurrentPage),ind)) or (pgList.Count = 0) then
    if View is TfrView then
      FMatrix.AddObject(View);
end;

procedure TfrOLEExcelExport.OnEndPage;
var
  ind: integer;
begin
  ind := 0;
  if (pgList.Find(IntToStr(FCurrentPage),ind)) or (pgList.Count = 0) then
	  FMatrix.AddPage(poLandscape, 0, 0, 0, 0, 0, 0);
end;

procedure TfrOLEExcelExport.AfterExport(const FileName: string);
begin
  FMatrix.Prepare;
  ExportPage_Fast;
  FExcel.SetRange(1, 1, 1, 1);
  FExcel.Range.Select;
  if FOpenExcelAfterExport then
    FExcel.Visible := True;
  try
   DeleteFile(FileName);
{$IFDEF Delphi3}
   Excel.WorkBook.SaveAs(FileName,xlNormal);
{$ELSE}
    FExcel.WorkBook.SaveAs(FileName, xlNormal, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam, xlNoChange, EmptyParam, EmptyParam, EmptyParam);
{$ENDIF}
    FExcel.Excel.Application.DisplayAlerts := True;
    FExcel.Excel.Application.ScreenUpdating := True;
    if not FOpenExcelAfterExport then
    begin
      FExcel.Excel.Quit;
      FExcel.Excel := Null;
      FExcel.Excel := Unassigned;
    end;
  except
  end;
  FMatrix.Free;
  FExcel.Free;
end;

///////////////////////////////////////////////////////////

constructor TFrExcel.Create;
begin
  inherited Create;
  FIsOpened := False;
  FIsVisible := False;
end;

function TfrExcel.Pos2Str(Pos: Integer): String;
var
  i, j: Integer;
begin
  if Pos > 26 then
  begin
    i := Pos mod 26;
    j := Pos div 26;
    if i = 0 then
      Result := Chr(64 + j - 1)
    else
      Result := Chr(64 + j);
    if i = 0 then
      Result := Result + chr(90)
    else
      Result := Result + Chr(64 + i);
  end
  else
    Result := Chr(64 + Pos);
end;

procedure TFrExcel.SetVisible(DoShow: Boolean);
begin
  if not FIsOpened then Exit;
  if DoShow then
    Excel.Visible := True
  else
    Excel.Visible := False;
end;

function TFrExcel.IntToCoord(X, Y: Integer): string;
begin
  Result := Pos2Str(X) + IntToStr(Y);
end;

procedure TFrExcel.SetColSize(x: Integer; Size: Extended);
var
  r: variant;
begin
  if (Size > 0) and (Size < 256) and (x < 256) then
  begin
    try
      r := WorkSheet.Columns;
      r.Columns[x].ColumnWidth := Size;
    except
    end;
  end;
end;

procedure TFrExcel.SetRowSize(y: Integer; Size: Extended);
var
  r: variant;
begin
  if Size > 0 then
  begin
    r := WorkSheet.Rows;
    if size > 409 then
      size := 409;
    r.Rows[y].RowHeight := Size;
  end;
end;

procedure TFrExcel.MergeCells;
begin
  Range.MergeCells := true;
end;

procedure TFrExcel.OpenExcel;
begin
  try
    Excel := CreateOLEObject('Excel.Application');
    Excel.Application.ScreenUpdating := False;
    Excel.Application.DisplayAlerts := False;
    WorkBook := Excel.WorkBooks.Add;
    WorkSheet := WorkBook.WorkSheets[1];
    FIsOpened := True;
  except
    FIsOpened := False;
  end;
end;

procedure TFrExcel.SetPageMargin(Left, Right, Top, Bottom: Extended;
      Orientation: TPrinterOrientation);
var
  Orient: Integer;
begin
  if Orientation = poLandscape then
    Orient := 2
  else
    Orient := 1;
  try
    Excel.ActiveSheet.PageSetup.LeftMargin := Left;
    Excel.ActiveSheet.PageSetup.RightMargin := Right;
    Excel.ActiveSheet.PageSetup.TopMargin := Top;
    Excel.ActiveSheet.PageSetup.BottomMargin := Bottom;
    Worksheet.PageSetup.Orientation := Orient;
  except
  end;
end;


procedure TFrExcel.SetRange(x, y, dx, dy: Integer);
begin
  try
    if x > 255 then
      x := 255;
    if (x + dx) > 255 then
      dx := 255 - x;
    if (dx > 0) and (dy > 0) then
      Range := WorkSheet.Range[IntToCoord(x, y), IntToCoord(x + dx - 1, y + dy - 1)];
  except
  end;
end;

procedure TfrExcel.SetCellFrame(Frame: integer);
begin
  if (Frame and frftLeft) <> 0 then
     Range.Cells.Borders.Item[xlEdgeLeft].Linestyle := xlSolid;
  if (Frame and frftRight) <> 0 then
     Range.Cells.Borders.Item[xlEdgeRight].Linestyle := xlSolid;
  if (Frame and frftTop) <> 0 then
     Range.Borders.Item[xlEdgeTop].Linestyle := xlSolid;
  if (Frame and frftBottom) <> 0 then
     Range.Borders.Item[xlEdgeBottom].Linestyle := xlSolid;
end;

procedure TfrExcel.SetRowsSize(aRanges: TStrings;
  Sizes: array of Currency; MainSizeIndex: integer;
  RowsCount:integer; aProgress: TfrProgress);
var
  i: integer;
  s: string;
  curSizes: integer;
  v: Variant;
begin
  if aRanges.Count > 0 then
  begin
    if Assigned(aProgress) then
      if not aProgress.Terminated then
      begin
        s := 'Process Rows';
        aProgress.Execute(aRanges.Count, s, True, True);
        WorkSheet.Range['A1:A' + IntToStr(RowsCount)].RowHeight := Sizes[MainSizeIndex];
        s := aRanges[0];
        curSizes := Integer(aRanges.Objects[0]);
        for i := 1 to Pred(aRanges.Count) do
        begin
          if Assigned(aProgress) then
          begin
            if aProgress.Terminated then
              Break;
            aProgress.Tick;
          end;
          if Integer(aRanges.Objects[i]) = MainSizeIndex then
            Continue;
          if Integer(aRanges.Objects[i]) <> curSizes then
          begin
            if curSizes <> MainSizeIndex then
            begin
              try
                v := WorkSheet.Range[s];
                v.RowHeight := Sizes[curSizes];
              except
              end;
            end;
            curSizes := Integer(aRanges.Objects[i]);
            s := aRanges[i];
          end
          else if Length(s) + Length(aRanges[i]) + 1 > 255 then
          begin
            try
              v := WorkSheet.Range[s];
              v.RowHeight := Sizes[curSizes];
            except
            end;
            s := aRanges[i];
          end
          else s := s + ';' + aRanges[i]
        end;
        if Length(s) > 0 then
        begin
          try
            v := WorkSheet.Range[s].Rows;
            v.RowHeight := Sizes[curSizes];
          except
          end;
        end;
      end;
  end;
end;

//////////////////////////////////////////////

procedure TfrOLEExcelSet.Localize;
begin
  Ok.Caption := frLoadStr(SOk);
  Cancel.Caption := frLoadStr(SCancel);
  GroupPageRange.Caption := frLoadStr(frRes + 44);
  Pages.Caption := frLoadStr(frRes + 47);
  Descr.Caption := frLoadStr(frRes + 48);
  Caption := frLoadStr(frRes + 1844);
  GroupCellProp.Caption := frLoadStr(frRes + 1850);
  CB_Pictures.Caption := frLoadStr(frRes + 1863);
  CB_OpenExcel.Caption := frLoadStr(frRes + 1864);
end;

procedure TfrExcel.ApplyStyles(aRanges: TStrings; Kind: byte; aProgress: TfrProgress);
// Kind=0 - Styles
// Kind=1 - Frames
// Kind=2 - Merge
var
  i: integer;
  s: string;
  curStyle: integer;
begin
  if aRanges.Count > 0 then
  begin
    if Assigned(aProgress) then
      if not aProgress.Terminated then
      begin
        aProgress.Execute(aRanges.Count, 'Process Styles', True, True);
        s := aRanges[0];
        curStyle := Integer(aRanges.Objects[0]);
        for i := 1 to Pred(aRanges.Count) do
        begin
         if Assigned(aProgress) then
         begin
           if aProgress.Terminated then
             Break;
           aProgress.Tick;
         end;
         if Integer(aRanges.Objects[i]) <> CurStyle then
         begin
           case Kind of
             0: ApplyStyle(s, CurStyle);
             1: ApplyFrame(s, CurStyle);
          end;
          CurStyle := Integer(aRanges.Objects[i]);
          s := aRanges[i];
         end
         else if Length(s) + Length(aRanges[i]) + 1 > 255 then
         begin
           case Kind of
             0: ApplyStyle(s, CurStyle);
             1: ApplyFrame(s, CurStyle);
             2: try
                  WorkSheet.Range[s].MergeCells := True;
                except
                end;
          end;
          s := aRanges[i];
         end
         else s := s + ListSeparator + aRanges[i]
        end;
        case Kind of
          0: ApplyStyle(s, CurStyle);
          1: ApplyFrame(s, CurStyle);
          2: try
               WorkSheet.Range[s].MergeCells := True;
             except
             end;
        end;
      end
  end;
end;

procedure TfrExcel.ApplyStyle(const RangeCoord: String; aStyle: Integer);
begin
  try
    if Length(RangeCoord) > 0 then
      WorkSheet.Range[RangeCoord].Style := 'S' + IntToStr(aStyle)
  except
  end;
end;

function TfrExcel.ByteToFrameTypes(Value: Byte): Integer;
begin
  Result := PFrameTypes(@Value)^
end;


procedure TfrExcel.ApplyFrame(const RangeCoord: String; aFrame: Byte);
var
  vFrame: Integer;
  vBorders: Variant;
begin
  try
    if aFrame <> 0 then
      if Length(RangeCoord) > 0 then
      begin
        vFrame := ByteToFrameTypes(aFrame);
        vBorders := WorkSheet.Range[RangeCoord].Cells.Borders;
        if (frftLeft and vFrame) > 0 then
          vBorders.Item[xlEdgeLeft].Linestyle := xlSolid;
        if (frftRight and vFrame) > 0 then
          vBorders.Item[xlEdgeRight].Linestyle := xlSolid;
        if (frftTop and vFrame) > 0 then
          vBorders.Item[xlEdgeTop].Linestyle := xlSolid;
        if (frftBottom and vFrame) > 0 then
          vBorders.Item[xlEdgeBottom].Linestyle := xlSolid;
      end;
  except
  end;
end;

procedure TfrOLEExcelSet.FormCreate(Sender: TObject);
begin
   Localize;
end;

end.
