{******************************************}
{                                          }
{             FastReport v2.53             }
{        Text advanced  export filter      }
{          Copyright(c) 1998-2004          }
{            by FastReports Inc.           }
{                                          }
{******************************************}

unit frTXTExp;

interface

{$I Fr.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, extctrls, FR_Class, ComCtrls, ToolWin, ImgList, Mask, Buttons
{$IFDEF Delphi6}, Variants {$ENDIF}, FR_Progr, FR_Ctrls, Registry;

type
  TfrTextAdvExport = class;

  TfrTEXTExprSet = class(TForm)
    OK: TButton;
    Cancel: TButton;
    Panel1: TPanel;
    GroupCellProp: TGroupBox;
    GroupPageRange: TGroupBox;
    Pages: TLabel;
    Descr: TLabel;
    E_Range: TEdit;
    GroupScaleSettings: TGroupBox;
    ScX: TLabel;
    Label2: TLabel;
    ScY: TLabel;
    Label9: TLabel;
    E_ScaleX: TEdit;
    E_ScaleY: TEdit;
    CB_PageBreaks: TCheckBox;
    GroupFramesSettings: TGroupBox;
    RB_NoneFrames: TRadioButton;
    RB_Simple: TRadioButton;
    RB_Graph: TRadioButton;
    CB_OEM: TCheckBox;
    CB_EmptyLines: TCheckBox;
    CB_LeadSpaces: TCheckBox;
    CB_PrintAfter: TCheckBox;
    CB_Save: TCheckBox;
    UpDown1: TUpDown;
    UpDown2: TUpDown;
    Panel2: TPanel;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label3: TLabel;
    PgHeight: TLabel;
    PgWidth: TLabel;
    Preview: TMemo;
    EPage: TMaskEdit;
    PageUpDown: TUpDown;
    LBPage: TLabel;
    ImageList1: TImageList;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    BtnPreview: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure CB_OEMClick(Sender: TObject);
    procedure RefreshClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure E_ScaleXChange(Sender: TObject);
    procedure BtnPreviewClick(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
  private
    TxtExp: TfrTextAdvExport;
    Flag, created, MakeInit : boolean;
    printer: integer;
    procedure Localize;
  public
    PreviewActive: boolean;
  end;

  PfrTXTStyle = ^TfrTXTStyle;
  TfrTXTStyle = record
    Font : TFont;
    Alignment : integer;
    FrameTyp: Word;
    FrameWidth: Single;
    FrameColor: TColor;
    FrameStyle: Word;
    FillColor: TColor;
    IsText : boolean;
  end;

  TfrTXTPrinterCommand = record
     Name: String;
     SwitchOn: String;
     SwitchOff: String;
     Trigger: boolean;
  end;

  TfrTXTPrinterType = record
    name : string;
    CommCount: integer;
    Commands: array [0..31] of TfrTXTPrinterCommand;
  end;

  TfrTextAdvExport = class(TfrExportFilter)
  private
    CurrentPage: integer;
    FirstPage: boolean;
    CurY: integer;
    RX: TList; // TObjCell
    RY: TList; // TObjCell
    ObjectPos: TList; // TObjPos
    PageObj: TList; // TfrView
    StyleList: TList;
    CY, LastY: integer;
    frExportSet: TfrTEXTExprSet;
    pgList: TStringList;
    pgBreakList: TStringList;
    expBorders, expBordersGraph, expPrintAfter, expUseSavedProps,
      expPrinterDialog, expPageBreaks, expOEM, expEmptyLines,
      expLeadSpaces: boolean;
    expCustomFrameSet: string;
    expScaleX, expScaleY: Double;
    MaxWidth : integer;
    Scr: array of char;
    ScrWidth : integer;
    ScrHeight: integer;
    PrinterInitString: string;
    Registered: boolean;
    procedure WriteExpLn(str: string);
    procedure WriteExp(str: string);
    procedure ObjCellAdd(Vector: TList; Value: integer);
    procedure ObjPosAdd(Vector: TList; x, y, dx, dy, obj: integer);
    function CompareStyles(Style1, Style2: PfrTXTStyle):boolean;
    function FindStyle(Style: PfrTXTStyle):integer;
    procedure MakeStyleList;
    procedure ClearLastPage;
    procedure OrderObjectByCells;
    procedure ExportPage;
    function ChangeReturns(Str: string): string;
    function TruncReturns(Str: string): string;
    procedure AfterExport(const FileName: string);
    procedure PrepareExportPage;
    procedure DrawMemo(x, y: integer; dx, dy: integer; text: string; st: integer);
    procedure FlushScr;
    procedure CreateScr(dx, dy: integer);
    procedure FreeScr;
    procedure ScrType(x, y: integer; c: char);
    function ScrGet(x, y: integer): char;
    procedure ScrString(x, y: integer; s: string);
    procedure ParsePageNumbers;
    procedure FormFeed;
    function MakeInitString: string;
  public
    PrintersCount: integer;
    PrinterTypes: array [0..15] of TfrTXTPrinterType;
    SelectedPrinterType: integer;
    PageNumbers: string;
    PageWidth, PageHeight : integer;
    IsPreview: boolean;
    Copys: integer;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ShowModal: Word; override;
    procedure OnBeginDoc; override;
    procedure OnEndDoc; override;
    procedure OnEndPage; override;
    procedure OnBeginPage; override;
    procedure OnData(x, y: Integer; View: TfrView); override;
    function RegisterPrinterType(Name: string):integer;
    procedure RegisterPrinterCommand(PrinterIndex: integer; Name, switch_on, switch_off: string);
    procedure LoadPrinterInit(FName: string);
    procedure SavePrinterInit(FName: string);
  published
    property ScaleWidth : double read expScaleX  write expScaleX;
    property ScaleHeight : double read expScaleY  write expScaleY;
    property Borders : Boolean read expBorders write expBorders;
    property Pseudogrpahic : Boolean read expBordersGraph write expBordersGraph;
    property PageBreaks : Boolean read expPageBreaks write expPageBreaks;
    property OEMCodepage : Boolean read expOEM write expOEM;
    property EmptyLines : Boolean read expEmptyLines write expEmptyLines;
    property LeadSpaces : Boolean read expLeadSpaces write expLeadSpaces;
    property PrintAfter : Boolean read expPrintAfter write expPrintAfter;
    property PrinterDialog : Boolean read expPrinterDialog write expPrinterDialog;
    property UseSavedProps : Boolean read expUseSavedProps write expUseSavedProps;
    property InitString : String read PrinterInitString write PrinterInitString;
// frameset: vertical, horizontal, up-left corner, up-right corner
//           down-left corner, down-right corner, down tap, left tap,
//           up tap, right tap,  cross
    property CustomFrameSet : String read expCustomFrameSet write expCustomFrameSet;
  end;

implementation

uses FR_Const, FR_Utils, FR_prntr, Printers, Winspool, frTxtExpPrn;

{$R *.dfm}

type
  PObjCell = ^TObjCell;
  TObjCell = record
    Value: integer;
    Count: integer;
  end;

  PObjPos = ^TObjPos;
  TObjPos = record
    obj: integer;
    x,y: integer;
    dx, dy: integer;
    style: integer;
  end;

const
  Xdivider = 7;
  Ydivider = 10;
  FrameSet: array [1..2] of string = (
  '|-+++++++++',
  #179#196#218#191#192#217#193#195#194#180#197 );
  EpsonCommCnt = 12;
  Epson: array [0..EpsonCommCnt - 1, 0..2] of string = (
   ('Reset', #27#64, ''),
   ('Normal', #27#120#00, ''),
   ('Pica', #27#120#01#27#107#00, ''),
   ('Elite', #27#120#01#27#107#01, ''),
   ('Condensed', #15, #18),
   ('Bold', #27#71, #27#72),
   ('Italic', #27#52, #27#53),
   ('Wide', #27#87#01, #27#87#00),
   ('12cpi', #27#77, #27#80),
   ('Linefeed 1/8"', #27#48, ''),
   ('Linefeed 7/72"', #27#49, ''),
   ('Linefeed 1/6"', #27#50, ''));
  HPCommCnt = 6;
  HPComm: array [0..HPCommCnt - 1, 0..2] of string = (
   ('Reset', #27#69, ''),
   ('Landscape orientation', #27#38#108#49#79, #27#38#108#48#79),
   ('Italic', #27#40#115#49#83, #27#40#115#48#83),
   ('Bold', #27#40#115#51#66, #27#40#115#48#66),
   ('Draft EconoMode', #27#40#115#49#81, #27#40#115#50#81),
   ('Condenced', #27#40#115#49#50#72#27#38#108#56#68, #27#40#115#49#48#72));
  IBMCommCnt = 8;
  IBMComm: array [0..IBMCommCnt - 1, 0..2] of string = (
   ('Reset', #27#64, ''),
   ('Normal', #27#120#00, ''),
   ('Pica', #27#48#73, ''),
   ('Elite', #27#56#73, ''),
   ('Condensed', #15, #18),
   ('Bold', #27#71, #27#72),
   ('Italic', #27#52, #27#53),
   ('12cpi', #27#77, #27#80));

function ComparePoints(Item1, Item2: Pointer): Integer;
begin
  Result := PObjCell(Item1).Value - PObjCell(Item2).Value;
end;

function CompareObjects(Item1, Item2: Pointer): Integer;
var
  m1, m2:  TfrView;
begin
  m1 := TfrView(Item1);
  m2 := TfrView(Item2);
  Result := m1.y - m2.y;
  if Result = 0 then
    Result := m1.x - m2.x;
  if Result = 0 then
    Result := Length(m2.Memo.Text) - Length(m1.Memo.Text);
end;

constructor TfrTextAdvExport.Create(AOwner: TComponent);
var
  i: integer;
begin
  inherited Create(AOwner);
  Registered := frRegisterExportFilter(Self, frLoadStr(frRes + 2740), '*.prn'); /// LOCALIZE!!!
  RX := TList.Create;
  RY := TList.Create;
  PageObj := TList.Create;
  ObjectPos := TList.Create;
  StyleList := TList.Create;
  pgList := TStringList.Create;
  pgBreakList := TStringList.Create;
  ShowDialog := True;
  expBorders := True;
  expPageBreaks := True;
  expScaleX := 1.0;
  expScaleY := 1.0;
  expBordersGraph := False;
  expOEM := False;
  expEmptyLines := True;
  expLeadSpaces := True;
  PrinterInitString := '';
  PageWidth := 0;
  PageHeight := 0;
  IsPreview := false;
  expPrintAfter := false;
  expUseSavedProps := True;
  expPrinterDialog := True;
  PrintersCount := 0;
  SelectedPrinterType := 0;
  expCustomFrameSet := '';
  Copys := 1;
  /// printer registration
  RegisterPrinterType('NONE');
  RegisterPrinterType('EPSON ESC/P2 Matrix/Stylus)');
  for i := 0 to EpsonCommCnt - 1 do
    RegisterPrinterCommand(1, Epson[i, 0], Epson[i, 1], Epson[i, 2]);
  RegisterPrinterType('HP PCL (LaserJet/DeskJet)');
  for i := 0 to HPCommCnt - 1 do
    RegisterPrinterCommand(2, HPComm[i, 0], HPComm[i, 1], HPComm[i, 2]);
  RegisterPrinterType('CANON/IBM (Matrix)');
  for i := 0 to IBMCommCnt - 1 do
    RegisterPrinterCommand(3, IBMComm[i, 0], IBMComm[i, 1], IBMComm[i, 2]);
end;

destructor TfrTextAdvExport.Destroy;
begin
  ClearLastPage;
  if Registered then
    frUnRegisterExportFilter(Self);
  RX.Free;
  RY.Free;
  PageObj.Free;
  ObjectPos.Free;
  StyleList.Free;
  pgList.Free;
  pgBreakList.Free;
  inherited;
end;

function TfrTextAdvExport.TruncReturns(Str: string): string;
begin
  Str := StringReplace(Str, #1, '', [rfReplaceAll]);
  if Copy(Str, Length(Str) - 1, 2) = #13#10 then
    Delete(Str, Length(Str) - 1, 2);
  Result := Str;
end;

function TfrTextAdvExport.ChangeReturns(Str: string): string;
begin
   Result := StringReplace(Str, #1, '', [rfReplaceAll]);
end;

procedure TfrTextAdvExport.ClearLastPage;
var
  i: integer;
begin
  PageObj.Clear;
  for i := 0 to StyleList.Count - 1 do
  begin
    PfrTXTStyle(StyleList[i]).Font.Free;
    FreeMemory(PfrTXTStyle(StyleList[i]));
  end;
  StyleList.Clear;
  for i := 0 to RX.Count - 1 do FreeMem(PObjCell(RX[i]));
  RX.Clear;
  for i := 0 to RY.Count - 1 do FreeMem(PObjCell(RY[i]));
  RY.Clear;
  for i := 0 to ObjectPos.Count - 1 do FreeMem(PObjPos(ObjectPos[i]));
  ObjectPos.Clear;
end;

procedure TfrTextAdvExport.ObjCellAdd(Vector: TList; Value: integer);
var
   ObjCell: PObjCell;
   i, cnt: integer;
   exist: boolean;
begin
   exist := false;
   if Vector.Count > 0 then
   begin
     if Vector.Count > 100 then
        cnt := Vector.Count - 100
     else
        cnt := 0;
     for i := Vector.Count - 1 downto cnt do
       if PObjCell(Vector[i]).Value = Value then
       begin
         exist := true;
         break;
       end;
   end;
   if not exist then
   begin
     GetMem(ObjCell, SizeOf(TObjCell));
     ObjCell.Value := Value;
     ObjCell.Count := 0;
     Vector.Add(ObjCell);
   end;
end;

procedure TfrTextAdvExport.ObjPosAdd(Vector: TList; x, y, dx, dy, obj: integer);
var
   ObjPos: PObjPos;
begin
   GetMem(ObjPos, SizeOf(TObjPos));
   ObjPos.x := x;
   ObjPos.y := y;
   ObjPos.dx := dx;
   ObjPos.dy := dy;
   ObjPos.obj := Obj;
   Vector.Add(ObjPos);
end;

procedure TfrTextAdvExport.OrderObjectByCells;
var
   obj, c, fx, fy, dx, dy, m, mi, curx, cury, lastx, lasty: integer;
   View : TfrView;
begin
   lastx := 0;
   lasty := 0;
   for obj := 0 to PageObj.Count - 1 do
   begin
     View := TfrView(PageObj[obj]);
     m := (RX.Count - 1) div 2;
     c := m;
     while PObjCell(RX[c]).Value <> View.x do
     begin
       if m > 1 then
         m := m div 2;
       if PObjCell(RX[c]).Value < View.x then
         c := c + m
       else
         c := c - m;
     end;
     fx := c;
     m := View.x;
     mi := c + 1;
     curx := m + View.dx;
     while (m < curx) and (RX.Count > 1) do
     begin
       m := m + PObjCell(RX[mi]).Value - PObjCell(RX[mi - 1]).Value;
       inc(mi);
     end;
     dx := mi - c - 1;
     m := (RY.Count - 1) div 2;
     c := m;
     while PObjCell(RY[c]).Value <> View.y do
     begin
       if m > 1 then
         m := m div 2;
       if PObjCell(RY[c]).Value < View.y then
         c := c + m
       else
         c := c - m;
     end;
     fy := c;
     m := View.y;
     mi := c + 1;
     cury := m + View.dy;
     while (m < cury) and (RY.Count > 1) do
     begin
       m := m + PObjCell(RY[mi]).Value - PObjCell(RY[mi - 1]).Value;
       inc(mi);
     end;
     dy := mi - c - 1;
     if (not ((lastx = fx) and (lasty = fy))) or (obj = 0) then
       ObjPosAdd(ObjectPos, fx, fy, dx, dy, obj);
     lastx := fx;
     lasty := fy;
   end;
end;

function TfrTextAdvExport.CompareStyles(Style1, Style2: PfrTXTStyle): boolean;
begin
  if Style1.IsText and Style2.IsText then
  begin
   if (Style1.Font.Color = Style2.Font.Color) and
      (Style1.Font.Name = Style2.Font.Name) and
      (Style1.Font.Size = Style2.Font.Size) and
      (Style1.Font.Style = Style2.Font.Style) and
      (Style1.Font.Charset = Style2.Font.Charset) and
      (Style1.Alignment = Style2.Alignment) and
      (Style1.FrameTyp = Style2.FrameTyp) and
      (Style1.FrameWidth = Style2.FrameWidth) and
      (Style1.FrameColor = Style2.FrameColor) and
      (Style1.FrameStyle = Style2.FrameStyle) and
      (Style1.FillColor = Style2.FillColor) then
      Result := true
   else
      Result := false;
  end
  else
  if (not Style1.IsText) and (not Style2.IsText) then
  begin
   if (Style1.Alignment = Style2.Alignment) and
      (Style1.FrameTyp = Style2.FrameTyp) and
      (Style1.FrameWidth = Style2.FrameWidth) and
      (Style1.FrameColor = Style2.FrameColor) and
      (Style1.FrameStyle = Style2.FrameStyle) and
      (Style1.FillColor = Style2.FillColor) then
      Result := true
   else
      Result := false;
  end
  else
    Result := false;
end;

function TfrTextAdvExport.FindStyle(Style: PfrTXTStyle): integer;
var
  i: integer;
begin
  Result := -1;
  for i := 0 to StyleList.Count - 1 do
    if CompareStyles(Style, PfrTXTStyle(StyleList[i])) then
      Result := i;
end;

procedure TfrTextAdvExport.MakeStyleList;
var
  i, j, k : integer;
  obj : TfrView;
  style : PfrTXTStyle;
begin
  j := 0;
  for i := 0 to ObjectPos.Count - 1 do
  begin
     obj := PageObj[PObjPos(ObjectPos[i]).obj];
     style := AllocMem(SizeOf(TfrTXTStyle));
     if obj is TfrMemoView then
     begin
       style.Font := TFont.Create;
       style.Font.Assign(TfrMemoView(obj).Font);
       style.Alignment := TfrMemoView(obj).Alignment;
       style.IsText := true;
     end
     else
     begin
       style.Font := nil;
       style.Alignment := 0;
       style.IsText := false;
     end;
     style.FrameTyp := obj.FrameTyp;
     style.FrameWidth := obj.FrameWidth;
     style.FrameColor := obj.FrameColor;
     style.FrameStyle := obj.FrameStyle;
     style.FillColor := obj.FillColor;
     k := FindStyle(Style);
     if k = -1 then
     begin
       StyleList.Add(style);
       PObjPos(ObjectPos[i]).style := j;
       j := j + 1;
     end
     else
     begin
       PObjPos(ObjectPos[i]).style := k;
       Style.Font.Free;
       FreeMemory(Style);
     end;
  end;
end;

function StrToOem(const AnsiStr: string): string;
begin
  SetLength(Result, Length(AnsiStr));
  if Length(Result) > 0 then
    CharToOemBuff(PChar(AnsiStr), PChar(Result), Length(Result));
end;

function MakeStr(C: Char; N: Integer): string;
begin
  if N < 1 then Result := ''
  else begin
    SetLength(Result, N);
    FillChar(Result[1], Length(Result), C);
  end;
end;

function AddChar(C: Char; const S: string; N: Integer): string;
begin
  if Length(S) < N then
    Result := MakeStr(C, N - Length(S)) + S
  else Result := S;
end;

function AddCharR(C: Char; const S: string; N: Integer): string;
begin
  if Length(S) < N then
    Result := S + MakeStr(C, N - Length(S))
  else
    Result := S;
end;

function LeftStr(const S: string; N: Integer): string;
begin
  Result := AddCharR(' ', S, N);
end;

function RightStr(const S: string; N: Integer): string;
begin
  Result := AddChar(' ', S, N);
end;

function CenterStr(const S: string; Len: Integer): string;
begin
  if Length(S) < Len then begin
    Result := MakeStr(' ', (Len div 2) - (Length(S) div 2)) + S;
    Result := Result + MakeStr(' ', Len - Length(Result));
  end
  else
    Result := S;
end;

const
  Delims = [' ', #9, '-'];

function WrapTxt(s: string; dx, dy: integer): string;
var
  i, j, k : integer;
  buf1, buf2 : string;
begin
  i := 0;
  buf2 := s;
  Result := '';
  while (i < dy) and (Length(Buf2) > 0) do
  begin
    if Length(buf2) > dx then
      if buf2[dx + 1] = #10 then
        buf1 := copy(buf2, 1, dx + 1)
      else
      if buf2[dx + 1] = #13 then
        buf1 := copy(buf2, 1, dx + 2)
      else
        buf1 := copy(buf2, 1, dx)
    else
    begin
      Result := Result + buf2;
      break;
    end;
    k := Pos(#13#10, buf1);
    if k > 0 then
      j := k + 1
    else
      if Length(Buf1) < dx  then
      begin
        j := Length(Buf1);
        k := 1;
      end
      else
        j := dx;
    if (not (buf2[dx + 1] in Delims)) or (k > 0) then
    begin
      if k = 0 then
        while (j > 0) and (not (buf1[j] in Delims)) do
          Dec(j);
      if j > 0 then
      begin
        buf1 := copy(buf1, 1, j);
        buf2 := copy(buf2, j + 1, Length(buf2) - j)
      end
      else
        buf2 := copy(buf2, dx + 1, Length(buf2) - dx);
    end
    else
      buf2 := copy(buf2, dx + 2, Length(buf2) - dx - 1);
    i := i + 1;
    Result := Result + buf1;
    if k = 0 then
      Result := Result + #13#10;
  end;
end;

procedure TfrTextAdvExport.WriteExpLn(str: string);
var
  ln : string;
begin
  if Length(str) > 0 then
  begin
    if Length(str) > PageWidth then
      PageWidth := Length(str);
    Inc(PageHeight);
    Stream.Write(str[1], Length(str));
    ln := #13#10;
    Stream.Write(ln[1], Length(ln));
  end
  else
  if expEmptyLines then
  begin
    ln := #13#10;
    Inc(PageHeight);
    Stream.Write(ln[1], Length(ln));
  end;
end;

procedure TfrTextAdvExport.WriteExp(str: string);
begin
  if Length(str) > 0 then
    Stream.Write(str[1], Length(str))
end;

procedure TfrTextAdvExport.CreateScr(dx, dy: integer);
var
  i, j: integer;
begin
  ScrWidth := dx;
  ScrHeight := dy;
  Initialize(Scr);
  SetLength(Scr, ScrWidth * ScrHeight);
  for i := 0 to ScrHeight - 1 do
   for j := 0 to ScrWidth - 1 do
     Scr[i * ScrWidth + j] := ' ';
end;

procedure TfrTextAdvExport.ScrString(x, y: integer; s: string);
var
  i : integer;
begin
  for i := 0 to Length(s) - 1 do
    ScrType(x + i, y, s[i + 1]);
end;

function TfrTextAdvExport.ScrGet(x, y: integer): char;
begin
 if (x < ScrWidth) and (y < ScrHeight) and
    (x >= 0) and (y >= 0) then
    Result := Scr[ScrWidth * y + x]
 else
    Result := ' ';
end;

procedure TfrTextAdvExport.DrawMemo(x, y, dx, dy: integer; text: string;
  st: integer);
var
  i, sx, sy, lines : integer;
  buf: string;
  style : PfrTXTStyle;
  f : string;

  function AlignBuf: string;
  begin
    if ((style.Alignment and frtaRight) <> 0) and ((style.Alignment and frtaCenter) <> 0) then
      buf := LeftStr(buf, dx - 1)
    else
    if (style.Alignment and frtaRight) <> 0 then
      buf := RightStr(buf, dx - 1)
    else
    if (style.Alignment and frtaCenter) <> 0 then
      buf := CenterStr(buf, dx - 1)
    else
      buf := LeftStr(buf, dx - 1);
    if expOEM then
      buf := StrToOem(buf);
    Result := buf;
  end;

begin
  style := PfrTXTStyle(StyleList[st]);
  if (Style.FrameTyp > 0) and expBorders then
  begin
    if Length(expCustomFrameSet) > 0 then
      f := CustomFrameSet
    else
    if expBordersGraph then
      f := FrameSet[2]
    else
      f := FrameSet[1];
    if (ScrGet(x + 1, y) in [f[1], f[3], f[4]]) then
    begin
      Inc(x);
      Dec(dx);
    end
    else
    if (ScrGet(x - 1, y) in [f[1], f[3], f[4]]) then
    begin
      Dec(x);
      Inc(dx);
    end;
    if (Style.FrameTyp and frftLeft) <> 0 then
      for i := 0 to dy do
       if i = 0 then
         ScrType(x, y + i, f[3])
       else
       if i = dy then
         ScrType(x, y + i, f[5])
       else
         ScrType(x, y + i, f[1]);
    if (Style.FrameTyp and frftRight) <> 0 then
      for i := 0 to dy do
        if i = 0 then
          ScrType(x + dx, y + i, f[4])
        else
        if i = dy then
          ScrType(x + dx, y + i, f[6])
        else
          ScrType(x + dx, y + i, f[1]);
    if (Style.FrameTyp and frftTop) <> 0 then
      for i := 0 to dx do
        if i = 0 then
          ScrType(x + i, y, f[3])
        else
        if i = dx then
          ScrType(x + i, y, f[4])
        else
          ScrType(x + i, y, f[2]);
    if (Style.FrameTyp and frftBottom) <> 0 then
      for i := 0 to dx do
        if i = 0 then
          ScrType(x + i, y + dy, f[5])
        else
        if i = dx then
          ScrType(x + i, y + dy, f[6])
        else
          ScrType(x + i, y + dy, f[2]);
  end;
  text := WrapTxt(text, dx - 1, dy - 1);
  text := StringReplace(text, #13#10, #13, [rfReplaceAll]);
  lines := 1;
  for i := 0 to Length(text) - 1 do
    if text[i + 1] = #13 then
      Inc(lines);
  sx := x;
  if (style.Alignment and frtaDown) <> 0 then
    sy := y + dy - lines - 1
  else
  if (style.Alignment and frtaMiddle) <> 0 then
    sy := y + (dy - lines - 1) div 2
  else
    sy := y;
  buf := '';
  for i := 0 to Length(text) - 1 do
    if text[i + 1] = #13 then
    begin
      Inc(sy);
      if sy > (y + dy) then
        break;
      ScrString(sx + 1, sy, AlignBuf);
      buf := '';
    end
    else
    begin
      buf := buf + text[i + 1];
    end;
  if buf <> '' then
    ScrString(sx + 1, sy + 1, AlignBuf);
end;

procedure TfrTextAdvExport.FlushScr;
var
  i, j, cnt, maxcnt : integer;
  buf : string;
  f: string;
  c : char;

  function IsLine(c: char): boolean;
  begin
   Result := (c in [f[1], f[2]]);
  end;

  function IsConner(c: char): boolean;
  begin
   Result := (c in [f[3], f[4], f[5], f[6], f[7], f[8], f[9], f[10], f[11]]);
  end;

  function IsFrame(c: char): boolean;
  begin
   Result := IsLine(c) or IsConner(c);
  end;

  function FrameOpt(c: char; x, y: integer; f: string): char;
  begin
    if (not IsLine(ScrGet(x - 1, y))) and
       (not IsLine(ScrGet(x + 1, y))) and
       (not IsLine(ScrGet(x, y - 1))) and
       (IsLine(ScrGet(x, y + 1))) then
         Result := f[1]
    else
    if (not IsLine(ScrGet(x - 1, y))) and
       (not IsLine(ScrGet(x + 1, y))) and
       (IsLine(ScrGet(x, y - 1))) and
       (not IsLine(ScrGet(x, y + 1))) then
         Result := f[1]
    else
    if (not IsLine(ScrGet(x - 1, y))) and
       (IsLine(ScrGet(x + 1, y))) and
       (not IsLine(ScrGet(x, y - 1))) and
       (not IsLine(ScrGet(x, y + 1))) then
         Result := f[2]
    else
    if (not IsLine(ScrGet(x + 1, y))) and
       (IsLine(ScrGet(x - 1, y))) and
       (not IsLine(ScrGet(x, y - 1))) and
       (not IsLine(ScrGet(x, y + 1))) then
         Result := f[2]
    else
    if (not IsFrame(ScrGet(x + 1, y))) and
       (not IsFrame(ScrGet(x - 1, y))) and
       (ScrGet(x, y + 1) = f[1]) and
       (ScrGet(x, y - 1) = f[1]) then
         Result := f[1]
    else
    if (ScrGet(x + 1, y) = f[2]) and
       (ScrGet(x - 1, y) = f[2]) and
       (not IsFrame(ScrGet(x, y + 1))) and
       (not IsFrame(ScrGet(x, y - 1))) then
         Result := f[2]
    else
    if (ScrGet(x + 1, y) = f[2]) and
       (ScrGet(x - 1, y) = f[2]) and
       (ScrGet(x, y + 1) = f[1]) and
       (ScrGet(x, y - 1) = f[1]) then
         Result := f[11]
    else
    if (ScrGet(x + 1, y) = f[2]) and
       (ScrGet(x - 1, y) = f[2]) and
       (ScrGet(x, y + 1) = f[1]) and
       (ScrGet(x, y - 1) <> f[1]) then
         Result := f[9]
    else
    if (ScrGet(x + 1, y) = f[2]) and
       (ScrGet(x - 1, y) = f[2]) and
       (ScrGet(x, y - 1) = f[1]) and
       (ScrGet(x, y + 1) <> f[1]) then
         Result := f[7]
    else
    if (ScrGet(x, y - 1) = f[1]) and
       (ScrGet(x, y + 1) = f[1]) and
       (ScrGet(x + 1, y) = f[2]) and
       (ScrGet(x - 1, y) <> f[2])then
         Result := f[8]
    else
    if (ScrGet(x, y - 1) = f[1]) and
       (ScrGet(x, y + 1) = f[1]) and
       (ScrGet(x - 1, y) = f[2]) and
       (ScrGet(x + 1, y) <> f[2])then
         Result := f[10]
    else
    if (ScrGet(x + 1, y) = f[2]) and
       (ScrGet(x - 1, y) <> f[2]) and
       (ScrGet(x, y + 1) = f[1]) and
       (ScrGet(x, y - 1) <> f[1]) then
         Result := f[3]
    else
    if (ScrGet(x + 1, y) = f[2]) and
       (ScrGet(x - 1, y) <> f[2]) and
       (ScrGet(x, y + 1) <> f[1]) and
       (ScrGet(x, y - 1) = f[1]) then
         Result := f[5]
    else
    if (ScrGet(x + 1, y) <> f[2]) and
       (ScrGet(x - 1, y) = f[2]) and
       (ScrGet(x, y + 1) <> f[1]) and
       (ScrGet(x, y - 1) = f[1]) then
         Result := f[6]
    else
    if (ScrGet(x + 1, y) <> f[2]) and
       (ScrGet(x - 1, y) = f[2]) and
       (ScrGet(x, y + 1) = f[1]) and
       (ScrGet(x, y - 1) <> f[1]) then
         Result := f[4]
    else
      Result := c;
  end;

begin
  if expBorders then
  begin
    if Length(expCustomFrameSet) > 0 then
      f := CustomFrameSet
    else
    if expBordersGraph then
      f := FrameSet[2]
    else
      f := FrameSet[1];
    for i := 0 to ScrHeight - 1 do
      for j := 0 to ScrWidth - 1 do
      begin
        c := Scr[i * ScrWidth + j];
        if IsConner(c) then
          Scr[i * ScrWidth + j] := FrameOpt(c, j, i, f);
      end;
  end;
  if not expLeadSpaces then
  begin
    maxcnt := 99999;
    for i := 0 to ScrHeight - 1 do
    begin
      cnt := 0;
      for j := 0 to ScrWidth - 1 do
        if (Scr[i * ScrWidth + j] = ' ') then
          Inc(cnt)
        else
          break;
      if cnt < maxcnt then
        maxcnt := cnt;
    end;
  end
  else
    maxcnt := 0;
  for i := 0 to ScrHeight - 1 do
  begin
    buf := '';
    for j := 0 to ScrWidth - 1 do
      buf := buf + Scr[i * ScrWidth + j];
    buf := TrimRight(buf);
    if (maxcnt > 0) then
      buf := Copy(buf, maxcnt + 1, Length(buf) - maxcnt);
    WriteExpLn(buf);
  end;
end;

procedure TfrTextAdvExport.FreeScr;
begin
  Finalize(Scr);
  ScrHeight := 0;
  ScrWidth := 0;
end;

procedure TfrTextAdvExport.ScrType(x,y: integer; c: char);
var
  i : integer;
begin
  i := ScrWidth * y + x;
  if (not expOEM) and (c = #160) then
    c := ' ';
  Scr[i] := c;
end;

procedure TfrTextAdvExport.ExportPage;
var
  i, x, y: integer;
  s : string;
  obj: TfrView;
begin
  if CurReport.Terminated then
    exit;
  i := 0;
  CreateScr(Round(expScaleX * MaxWidth / Xdivider) + 10, Round(expScaleY * LastY / Ydivider) + 2);
  for y := 1 to RY.Count - 1 do
  begin
    for x := 1 to RX.Count - 1 do
      if i < ObjectPos.Count then
       if  ((PObjPos(ObjectPos[i]).y + CurY + 1) = y) and
           ((PObjPos(ObjectPos[i]).x + 1) = x) then
       begin
         Obj := TfrView(PageObj[PObjPos(ObjectPos[i]).obj]);
         s := ChangeReturns(TruncReturns(Obj.Memo.Text));
         DrawMemo(Round(expScaleX * obj.x / Xdivider),
                  Round(expScaleY * obj.y / Ydivider),
                  Round(expScaleX * obj.dx / Xdivider),
                  Round(expScaleY * obj.dy / Ydivider),
                  s, PObjPos(ObjectPos[i]).style);
         Obj.Free;
         Inc(i);
       end;
  end;
  FlushScr;
  FreeScr;
end;

procedure TfrTextAdvExport.ParsePageNumbers;
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

const
  REGISTRY_KEY = '\Software\FastReports\TxtAdvExport\1000';

function TfrTextAdvExport.ShowModal: Word;
var
  Reg : TRegistry;
  preview : boolean;
begin
  if ShowDialog then
  begin
    preview := false;
    frExportSet := TfrTEXTExprSet.Create(Self);
    if expUseSavedProps then
    begin
      Reg := TRegistry.Create;
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey(REGISTRY_KEY, true) then
      begin
        if Reg.ValueExists('Borders') then
        begin
          expBorders := Reg.ReadBool('Borders');
          expBordersGraph := Reg.ReadBool('BordersGraph');
          expPageBreaks := Reg.ReadBool('PageBreaks');
          expOEM := Reg.ReadBool('OEM');
          expEmptyLines := Reg.ReadBool('EmptyLines');
          expLeadSpaces := Reg.ReadBool('LeadSpaces');
          expScaleX := Reg.ReadFloat('ScaleX');
          expScaleY := Reg.ReadFloat('ScaleY');
          preview := Reg.ReadBool('Preview');
          frExportSet.Preview.Font.Size := Reg.ReadInteger('FontSize');
          expPrintAfter := Reg.ReadBool('PrintAfter');
        end;
        Reg.CloseKey;
      end;
      Reg.Free;
    end;
    frExportSet.RB_Graph.Checked := expBordersGraph;
    frExportSet.RB_NoneFrames.Checked := not expBorders;
    frExportSet.RB_Simple.Checked := expBorders and (not expBordersGraph);
    frExportSet.CB_PageBreaks.Checked := expPageBreaks;
    frExportSet.CB_OEM.Checked := expOEM;
    frExportSet.CB_EmptyLines.Checked := expEmptyLines;
    frExportSet.CB_LeadSpaces.Checked := expLeadSpaces;
    frExportSet.UpDown1.Position := StrToInt(IntToStr(Round(expScaleX * 100)));
    frExportSet.UpDown2.Position := StrToInt(IntToStr(Round(expScaleY * 100)));
    frExportSet.CB_PrintAfter.Checked := expPrintAfter;
    frExportSet.PreviewActive := preview;
    Result := frExportSet.ShowModal;
    if Result = mrOk then
    begin
      PageNumbers := frExportSet.E_Range.Text;
      expBorders := not frExportSet.RB_NoneFrames.Checked;
      expBordersGraph := frExportSet.RB_Graph.Checked;
      expPageBreaks := frExportSet.CB_PageBreaks.Checked;
      expOEM := frExportSet.CB_OEM.Checked;
      expEmptyLines := frExportSet.CB_EmptyLines.Checked;
      expLeadSpaces := frExportSet.CB_LeadSpaces.Checked;
      expScaleX := StrToInt(frExportSet.E_ScaleX.Text) / 100;
      expScaleY := StrToInt(frExportSet.E_ScaleY.Text) / 100;
      expPrintAfter := frExportSet.CB_PrintAfter.Checked;
      if frExportSet.MakeInit then
      begin
        SelectedPrinterType := frExportSet.printer;
        MakeInitString;
      end;
      if frExportSet.CB_Save.Checked then
      begin
        Reg := TRegistry.Create;
        Reg.RootKey := HKEY_CURRENT_USER;
        if Reg.OpenKey(REGISTRY_KEY, true) then
        begin
          Reg.WriteBool('Borders', expBorders);
          Reg.WriteBool('BordersGraph', expBordersGraph);
          Reg.WriteBool('PageBreaks', expPageBreaks);
          Reg.WriteBool('OEM', expOEM);
          Reg.WriteBool('EmptyLines', expEmptyLines);
          Reg.WriteBool('LeadSpaces', expLeadSpaces);
          Reg.WriteFloat('ScaleX', expScaleX);
          Reg.WriteFloat('ScaleY', expScaleY);
          Reg.WriteBool('Preview', frExportSet.PreviewActive);
          Reg.WriteInteger('FontSize', frExportSet.Preview.Font.Size);
          Reg.WriteBool('PrintAfter', expPrintAfter);
          Reg.CloseKey;
        end;
        Reg.Free;
      end;
    end;
    frExportSet.Free;
  end
  else
    Result := mrOk;
end;

procedure TfrTextAdvExport.OnBeginDoc;
begin
  CurReport.Terminated := false;
  OnAfterExport := AfterExport;
  CurrentPage := 0;
  FirstPage := true;
  ClearLastPage;
  if not IsPreview then
    WriteExp(PrinterInitString);
  pgList.Clear;
  pgBreakList.Clear;
  ParsePageNumbers;
end;

procedure TfrTextAdvExport.OnBeginPage;
begin
  Inc(CurrentPage);
  MaxWidth := 0;
  LastY := 0;
  CY := 0;
  CurY := 0;
  PageWidth := 0;
  PageHeight := 0;
end;

procedure TfrTextAdvExport.OnData(x, y: Integer; View: TfrView);
var
  MemoView : TfrMemoView;
  ind, maxy, dx, dy : integer;
begin
  if not CurReport.Terminated then
  begin
    ind := 0;
    dx := 0;
    dy := 0;
    if (pgList.Find(IntToStr(CurrentPage),ind)) or (pgList.Count = 0) then
    begin
      if View is TfrMemoView then
      begin
        if ((TfrMemoView(View).Memo.Count > 0) or (TfrMemoView(View).FrameTyp > 0)) then
        begin
          MemoView := TfrMemoView.Create;
          MemoView.Assign(View);
          MemoView.y := MemoView.y + CY;
          dx := View.dx;
          dy := View.dy;
          if dx = 0 then
            dx := 1;
          if dy = 0 then
            dy := 1;
          MemoView.dx := dx;
          MemoView.dy := dy;
          PageObj.Add(MemoView);
          ObjCellAdd(RX, View.x);
          ObjCellAdd(RX, View.x + dx);
          ObjCellAdd(RY, View.y + CY);
          ObjCellAdd(RY, View.y + dy + CY);
        end;
      end;
      if View.x + dx > MaxWidth then
        MaxWidth := View.x + dx;
      maxy := View.y + dy + CY;
      if maxy > LastY then
        LastY := maxy;
    end;
  end;
end;

procedure TfrTextAdvExport.OnEndPage;
var
  ind: integer;
begin
  if CurReport.Terminated then
    exit;
  ind := 0;
  if (pgList.Find(IntToStr(CurrentPage),ind)) or (pgList.Count = 0) then
  begin
    PrepareExportPage;
    ExportPage;
    if expPageBreaks then
      FormFeed;
    ClearLastPage;
    if IsPreview then
       CurReport.Terminated := true;
  end;
  if (pgList.Find(IntToStr(CurrentPage),ind)) or (pgList.Count = 0) then
    pgBreakList.Add(IntToStr(LastY));
end;

procedure TfrTextAdvExport.OnEndDoc;
begin
  if (not expPageBreaks) and (not IsPreview) then
    FormFeed;
end;


procedure SpoolFile(const FileName: String);
const
  BUF_SIZE = 1024;
var
  N: DWORD;
  f: TFileStream;
  buf: String;
  l: longint;
  DocInfo1: TDocInfo1;
  FDevice: PChar;
  FDriver: PChar;
  FPort: PChar;
  FDeviceMode: THandle;
  FHandle: THandle;
begin
  GetMem(FDevice, 128);
  GetMem(FDriver, 128);
  GetMem(FPort, 128);
  FillChar(FDevice^, 128, 0);
  FillChar(FDriver^, 128, 0);
  FillChar(FPort^, 128, 0);
  Printer.GetPrinter(FDevice, FDriver, FPort, FDeviceMode);
  if OpenPrinter(FDevice, FHandle, nil) then
  begin
    DocInfo1.pDocName := PChar(FileName);
    DocInfo1.pOutputFile := nil;
    DocInfo1.pDataType := 'RAW';
    StartDocPrinter(FHandle, 1, @DocInfo1);
    StartPagePrinter(FHandle);
    f := TFileStream.Create(FileName, fmOpenRead);
    SetLength(buf, BUF_SIZE);
    l := BUF_SIZE;
    while l = BUF_SIZE do
    begin
      l := f.Read(buf[1], BUF_SIZE);
      SetLength(buf, l);
      WritePrinter(FHandle, PChar(buf), Length(buf), N);
    end;
    f.Free;
    EndPagePrinter(FHandle);
    EndDocPrinter(FHandle);
  end;
  FreeMem(FDevice, 128);
  FreeMem(FDriver, 128);
  FreeMem(FPort, 128);
end;

function GetTempFName: string;
var
  tpath : string;
  Buffer: array[0..1023] of Char;
begin
  SetString(tpath, Buffer, GetTempPath(SizeOf(Buffer), Buffer));
  GetTempFileName(PChar(tpath), '', 0, buffer);
  SetString(Result, buffer, StrLen(Buffer));
end;

procedure TfrTextAdvExport.AfterExport(const FileName: string);
var
  i : integer;
  fname: string;
  f, ffrom: TFileStream;
begin
  if expPrintAfter then
  begin
    if Printer.Printers.Count = 0 then Exit;
    if expPrinterDialog  then
      with TfrPrnInit.Create(Self) do
      begin
        i := ShowModal;
        if i = mrOk then
          Copys := UpDown1.Position;
        Free;
      end
    else
      i := mrOk;
    if i = mrOk then
    begin
      MakeInitString;
      fname := GetTempFName;
      f := TFileStream.Create(fname, fmCreate);
      ffrom := TFileStream.Create(FileName, fmOpenRead);
      f.Write(PrinterInitString[1], Length(PrinterInitString));
      f.CopyFrom(ffrom, 0);
      f.Free;
      ffrom.Free;
      f := TFileStream.Create(FileName, fmCreate);
      ffrom := TFileStream.Create(fname, fmOpenRead);
      f.CopyFrom(ffrom, 0);
      f.Free;
      ffrom.Free;
      DeleteFile(fname);
      for i := 1 to Copys do
        SpoolFile(FileName);
    end;
  end;
end;

procedure TfrTextAdvExport.PrepareExportPage;
begin
  RX.Sort(@ComparePoints);
  RY.Sort(@ComparePoints);
  PageObj.Sort(@CompareObjects);
  OrderObjectByCells;
  MakeStyleList;
end;

function TfrTextAdvExport.MakeInitString: string;
var
  i: integer;
begin
  if PrintersCount > 0 then
  begin
    PrinterInitString := '';
    for i := 0 to PrinterTypes[SelectedPrinterType].CommCount - 1 do
      if PrinterTypes[SelectedPrinterType].Commands[i].Trigger then
        PrinterInitString := PrinterInitString +
            PrinterTypes[SelectedPrinterType].Commands[i].SwitchOn
      else
        PrinterInitString := PrinterInitString +
            PrinterTypes[SelectedPrinterType].Commands[i].SwitchOff;
  end;
end;

procedure TfrTextAdvExport.RegisterPrinterCommand(PrinterIndex: integer;
  Name, switch_on, switch_off: string);
var
  i : integer;
begin
  i := PrinterTypes[PrinterIndex].CommCount;
  PrinterTypes[PrinterIndex].Commands[i].Name := Name;
  PrinterTypes[PrinterIndex].Commands[i].SwitchOn := Switch_On;
  PrinterTypes[PrinterIndex].Commands[i].SwitchOff := Switch_Off;
  PrinterTypes[PrinterIndex].Commands[i].Trigger := false;
  Inc(PrinterTypes[PrinterIndex].CommCount);
end;

function TfrTextAdvExport.RegisterPrinterType(Name: string): integer;
begin
  PrinterTypes[PrintersCount].Name := Name;
  PrinterTypes[PrintersCount].CommCount := 0;
  Inc(PrintersCount);
  Result := PrintersCount - 1;
end;

procedure TfrTextAdvExport.LoadPrinterInit(FName: string);
var
  f: TextFile;
  i: integer;
  buf: string;
  b: boolean;
begin
{$I-}
  AssignFile(f, FName);
  Reset(f);
  ReadLn(f, buf);
  SelectedPrinterType := StrToInt(buf);
  i := 0;
  while (not eof(f)) and (i < PrinterTypes[SelectedPrinterType].CommCount) do
  begin
    ReadLn(f, buf);
      if Pos('True', buf) > 0 then
        b := true
      else
        b := false;
      PrinterTypes[SelectedPrinterType].Commands[i].Trigger := b;
    Inc(i);
  end;
  MakeInitString;
{$I+}
end;

procedure TfrTextAdvExport.SavePrinterInit(FName: string);
var
  f: TextFile;
  i: integer;
  s: string;
begin
{$I-}
  AssignFile(f, FName);
  Rewrite(f);
  WriteLn(f, IntToStr(SelectedPrinterType));
  for i := 0 to PrinterTypes[SelectedPrinterType].CommCount - 1 do
  begin
    if PrinterTypes[SelectedPrinterType].Commands[i].Trigger then
      s := 'True'
    else
      s := 'False';
    WriteLn(f, s);
  end;
  CloseFile(f);
{$I+}
end;

procedure TfrTextAdvExport.FormFeed;
begin
  WriteExp(#12);
end;

//////////////////////////////////////////////

procedure TfrTEXTExprSet.Localize;
begin
  Ok.Caption := frLoadStr(SOk);
  Cancel.Caption := frLoadStr(SCancel);
  Caption := frLoadStr(frRes + 2741);
  BtnPreview.Hint := frLoadStr(frRes + 2742);
  GroupCellProp.Caption := frLoadStr(frRes + 2744);
  CB_PageBreaks.Caption := frLoadStr(frRes + 2745);
  CB_OEM.Caption := frLoadStr(frRes + 2746);
  CB_EmptyLines.Caption := frLoadStr(frRes + 2747);
  CB_LeadSpaces.Caption := frLoadStr(frRes + 2748);
  GroupPageRange.Caption := frLoadStr(frRes + 44);
  Pages.Caption := frLoadStr(frRes + 47);
  Descr.Caption := frLoadStr(frRes + 48);
  GroupScaleSettings.Caption := frLoadStr(frRes + 2749);
  ScX.Caption := frLoadStr(frRes + 2750);
  ScY.Caption := frLoadStr(frRes + 2751);
  GroupFramesSettings.Caption := frLoadStr(frRes + 2752);
  RB_NoneFrames.Caption := frLoadStr(frRes + 2753);
  RB_Simple.Caption := frLoadStr(frRes + 2754);
  RB_Graph.Hint := frLoadStr(frRes + 2755);
  RB_Graph.Caption := frLoadStr(frRes + 2756);
  CB_PrintAfter.Caption := frLoadStr(frRes + 2757);
  CB_Save.Caption := frLoadStr(frRes + 2758);
  GroupBox1.Caption := frLoadStr(frRes + 2759);
  Label1.Caption := frLoadStr(frRes + 2760);
  Label3.Caption := frLoadStr(frRes + 2761);
  LBPage.Caption := frLoadStr(frRes + 2762);
  ToolButton1.Hint := frLoadStr(frRes + 2763);
  ToolButton2.Hint := frLoadStr(frRes + 2764);
end;

procedure TfrTEXTExprSet.FormCreate(Sender: TObject);
begin
  Localize;
  created := false;
  TxtExp := TfrTextAdvExport.Create(nil);
  PageUpDown.Max := CurReport.EMFPages.Count;
  BtnPreviewClick(Sender);
  Created := true;
  MakeInit := false;
  printer := 0;
end;

procedure TfrTEXTExprSet.CB_OEMClick(Sender: TObject);
begin
   RB_Graph.Enabled := CB_OEM.Checked;
   if not RB_Simple.Checked then
     RB_Simple.Checked := RB_Graph.Checked;
   E_ScaleXChange(Sender);
end;

procedure TfrTEXTExprSet.RefreshClick(Sender: TObject);
var
  fname: string;
  Progr: boolean;
begin
 if Flag then
 begin
  fname := GetTempFName;
  TxtExp.PageNumbers := EPage.Text;
  TxtExp.IsPreview := true;
  TxtExp.ShowDialog := false;
  TxtExp.Borders := not RB_NoneFrames.Checked;
  TxtExp.Pseudogrpahic := RB_Graph.Checked;
  TxtExp.PageBreaks := CB_PageBreaks.Checked;
  TxtExp.OEMCodepage := CB_OEM.Checked;
  TxtExp.EmptyLines := CB_EmptyLines.Checked;
  TxtExp.LeadSpaces := CB_LeadSpaces.Checked;
  TxtExp.ScaleWidth := StrToInt(E_ScaleX.Text) / 100;
  TxtExp.ScaleHeight := StrToInt(E_ScaleY.Text) / 100;
  progr := CurReport.ShowProgress;
  CurReport.ShowProgress := false;
  CurReport.ExportTo(TxtExp, fname);
  CurReport.ShowProgress := progr;
  if CB_OEM.Checked then
    Preview.Font.Name := 'Terminal'
  else
    Preview.Font.Name := 'Courier New';
  Preview.Lines.LoadFromFile(fname);
  DeleteFile(fname);
  PgWidth.Caption := IntToStr(TxtExp.PageWidth);
  PgHeight.Caption := IntToStr(TxtExp.PageHeight);
 end;
end;

procedure TfrTEXTExprSet.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  TxtExp.Free;
end;

procedure TfrTEXTExprSet.FormActivate(Sender: TObject);
begin
  CB_OEMClick(Sender);
  if PreviewActive then
  begin
    BtnPreview.Down := true;
  end;
  BtnPreviewClick(Sender);
end;

procedure TfrTEXTExprSet.E_ScaleXChange(Sender: TObject);
begin
 if PreviewActive then
   RefreshClick(Sender);
end;

procedure TfrTEXTExprSet.BtnPreviewClick(Sender: TObject);
begin
  if BtnPreview.Down then
  begin
    PreviewActive := true;
    Left := Left - 177;
    Width := 631;
    Panel2.Visible := true;
    Flag := true;
    E_ScaleXChange(Sender);
  end
  else
  begin
    if created and PreviewActive then
      Left := Left + 177;
    Flag := false;
    PreviewActive := false;
    Width := 277;
    Panel2.Visible := false;
  end;
end;

procedure TfrTEXTExprSet.ToolButton1Click(Sender: TObject);
begin
 if Preview.Font.Size < 30 then
  Preview.Font.Size := Preview.Font.Size + 1;
end;

procedure TfrTEXTExprSet.ToolButton2Click(Sender: TObject);
begin
 if Preview.Font.Size > 2 then
  Preview.Font.Size := Preview.Font.Size - 1;
end;

end.
