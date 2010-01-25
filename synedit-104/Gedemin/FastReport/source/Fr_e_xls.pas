{******************************************************************}
{                                                                  }
{     FR_E_XLS: Export filter FR2.4 into Excel (xls format)        }
{                                                                  }
{     Copyright (c) 2001 Dmitry Kirkinsky                          }
{                                                                  }
{******************************************************************}
//    bugfixed by Konstantin Beliaev (konstb@newmail.ru)
//
// have fixed:
//  - check if cell already used
//  - horizontal alignment in the cell
//  - vertical alignment in the cell (works from 2.47)
//  - text rotation in cell
//  - завершение Excel - процесс зависал в пам€ти,
//    если экспортировалось более одного документа
//  - позиционирование €чеек по вертикали, если отчет выгружаетс€
//    на один лист
//  - форматирование колонок, если отчет выгружаетс€ на один лист
//  - вычисление ширины колонок (у Excel нелинейный масштаб 8-0)
//  - позиционирование картинок на листе
//  - добавил проверку на максимальную ширину/высоту €чеек
//    и пустой текстовый блок
// not done yet:
//  - not supported: shape, line, chart, checkbox,
//    reachtext, roundrect, barcode, ...
//  - очень медленна€ скорость, через OLE вр€д ли удастс€
//    разогнать, надо переходить на пр€мое сохранение в файл
//    или формирование образа документа в Clipboard
//    »з подход€щих компонентов: Flexcel и vtkExport
//    (поддерживают BIFF8)
// unable to fix:
//  - Excel does not support overlapping text regions
{******************************************************************}

unit FR_E_XLS;

{$I FR.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, extctrls, Clipbrd, Printers, ComObj, activex, excel97, FR_Class
  {$IFDEF Delphi6}
, Variants
{$ENDIF};

type
  //Used interfaces
  IxlApplication = Excel97._Application;
  IxlWorkbook = Excel97._Workbook;
  IxlWorksheet = Excel97._Worksheet;
  IxlRange = variant;

  TfrExcel = class;

  TfrExcelWriteBuffer = class(TPersistent)
  private
    FBuff: OleVariant;               
    FFirstRow: Integer;              
    FLastRow: Integer;               
    FLeftColumn: Integer;
    FRightColumn: Integer;
    FCapacity: Integer;
    FOwner: TfrExcel;
    procedure SetCapacity(const Value: Integer);
    procedure SetLeftColumn(const Value: Integer);
    procedure SetRightColumn(const Value: Integer);
  public
    constructor Create(AOwner: TfrExcel);
    procedure Clear;                 
    procedure Write;                 
  published
    property Capacity: Integer read FCapacity write SetCapacity;
    property LeftColumn: Integer read FLeftColumn write SetLeftColumn;
    property RightColumn: Integer read FRightColumn write SetRightColumn;
  end;

  //Excel
  TfrExcel = class(TComponent)
  private
    FIXLSApp: IxlApplication;
    FLCID: LCID;
    FActivated: boolean;
    FIXLSBook: IxlWorkbook;
    FIXLSSheet: IxlWorksheet;
    FVisible: boolean;
    FWriteBuffer: TfrExcelWriteBuffer;
    procedure WriteRange(ARange: OleVariant; TopRow, LeftCol: Integer);
    procedure SetActivated(const Value: boolean);
    procedure SetCellValue(row, col: Integer; const Value: Variant);
    procedure SetVisible(const Value: boolean);
    function GetCellItem(row, col: OleVariant): IxlRange;
    function GetCellValue(row, col: Integer): Variant;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SaveBook(fname: string ='');
    property Activated: boolean read FActivated write SetActivated;
    property CellValue[row,col: Integer]: Variant read GetCellValue
                                                  write SetCellValue; default;
    property CellItem[row,col: OleVariant]: IxlRange read GetCellItem;
    property _LCID: LCID read FLCID;
    property IXLSApp:  IxlApplication read FIXLSApp; 
    property IXLSBook: IxlWorkbook read FIXLSBook;   
    property IXLSSheet: IxlWorksheet read FIXLSSheet write FIXLSSheet; 
    property Visible: boolean read FVisible write SetVisible;
    property WriteBuffer: TfrExcelWriteBuffer read FWriteBuffer
                                              write FWriteBuffer;
  end;

  TByteSet = set of byte;

  TfrExcelExport = class(TfrExportFilter)
  private
    eDoc : TfrExcel;
    Views: TList;
    RC: array ['x'..'y'] of TList;
                                          
    UsedCells: array [1..255] of TByteSet;
    PicCount: integer;
    PageNumber: integer;                  
    OldAfterExport: TAfterExportEvent;
    MaxY: integer; // instead of FirstRow - increment object's Y coordinate

    MaxRow: integer;                      
    FOpenAfterExport: boolean;
    FBreakOnSheets: boolean;

    function GetRC(xy: char; val: integer): integer;
    procedure AddRC(xy: char; val: integer);
    procedure SetCellsSize(xy: char);
    procedure ClearViews;

    procedure ExportMemo(v: TfrMemoView);
    procedure ExportPicture(v: TfrPictureView);
    procedure DoAfterExport(const FileName: string);
    procedure DoExport;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ShowModal: Word; override;
    procedure OnBeginDoc; override;
    procedure OnEndDoc; override;
    procedure OnEndPage; override;
    procedure OnBeginPage; override;
    procedure OnText(DrawRect: TRect; X, Y: Integer; const Text: String;
      FrameTyp: Integer; View: TfrView); override;
    procedure OnData(x, y: Integer; View: TfrView); override;
  published
    property OpenAfterExport: boolean read FOpenAfterExport
      write FOpenAfterExport default True;
    property BreakOnSheets: boolean read FBreakOnSheets
      write FBreakOnSheets default True;
  end;

  TfrXLSExportForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    cbOpen: TCheckBox;
    cbOnSheets: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  end;

procedure Register;

implementation

{$R *.DFM}

{.$define Tdebug}
{$ifdef Tdebug}
var Tsave:TDateTime; // for timing test
{$endif}

procedure Register;
begin
  RegisterComponents('FastReport', [TfrExcelExport]);
end;

{ TfrExcelExport }
{$D+}
procedure TfrExcelExport.AddRC(xy: char; val: integer);
var
  i: integer;
begin
  i:=0;
  while (i<RC[xy].Count) and (integer(RC[xy].Items[i])<val) do Inc(i);
  if i=RC[xy].Count then RC[xy].Add(pointer(val))
  else 
    if integer(RC[xy].Items[i])>val then RC[xy].Insert(i,pointer(val));
end;

function TfrExcelExport.GetRC(xy: char; val: integer): integer;
begin
  Result:=1;
  while (Result<=RC[xy].Count) and (integer(RC[xy].Items[Result-1])<val) do
    Inc(Result);
  if (Result>RC[xy].Count) or (integer(RC[xy].Items[Result-1])>val) then
    Result := 0;
end;

procedure TfrExcelExport.ClearViews;
var
  i: Integer;
begin
  for i:=0 to Views.Count-1 do TfrView(Views[i]).Free;
  Views.Clear;
  RC['x'].Clear;
  RC['y'].Clear;
end;

constructor TfrExcelExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Views := TList.Create;
  RC['x'] := TList.Create;
  RC['y'] := TList.Create;
  if ClassName = 'TfrExcelExport' then
    frRegisterExportFilter(Self, 'Excel file (*.xls)', '*.xls');
  ShowDialog := True;
  FOpenAfterExport := True;
  FBreakOnSheets := True;
end;

destructor TfrExcelExport.Destroy;
begin
  frUnRegisterExportFilter(Self);
  ClearViews;
  Views.Free;
  RC['x'].Free;
  RC['y'].Free;
  inherited;
end;

procedure TfrExcelExport.DoAfterExport(const FileName: string);
begin
  if Assigned(OldAfterExport) then OldAfterExport(FileName);
  OnAfterExport := OldAfterExport;
  try eDoc.SaveBook(FileName);
  except // if save error?
    OpenAfterExport:=true;
  end;
  if OpenAfterExport then eDoc.Visible := True;
  FreeAndNil(eDoc);
end;
//----------------------------------------
procedure TfrExcelExport.ExportMemo(v: TfrMemoView);
var
  row, col, row2, col2, i, j: byte;
  str: string;
  IR1, IR2: IxlRange;
  vFont: TFont;
  f: boolean;
begin
  col := GetRC('x',v.x);
  row := GetRC('y',v.y);
  col2 := GetRC('x',v.x+v.dx)-1;
  row2 := GetRC('y',v.y+v.dy)-1;
  f := True;
  while f and (row<=row2) do
  begin
    f := False;
    for i:=col to col2 do f:=f or (i in UsedCells[row]);
    if f then Inc(row);
  end;
  if not f then
  begin
    for i:=row to row2 do
      for j:=col to col2 do Include(UsedCells[i],j);
    str := StringReplace(v.Memo.Text,#1,'',[rfReplaceAll]);
    str := StringReplace(str,#$D,'',[rfReplaceAll]);
    if (str<>'') and (str[Length(str)]=#$A) then str := copy(str,1,Length(str)-1);

    if row2 > MaxRow then MaxRow := row2;
    eDoc[row,col] := str;
    IR1 := eDoc.CellItem[row,col];
    IR2 := eDoc.CellItem[row2,col2];
    with eDoc.IXLSSheet.Range[IR1,IR2] do
    begin
      if (row2>row) or (col2>col) then MergeCells := True;
      case (v.Alignment and $3) of
        frtaLeft  : HorizontalAlignment := LongInt(xlHAlignLeft);
        frtaRight : HorizontalAlignment := LongInt(xlHAlignRight);
        frtaCenter: HorizontalAlignment := LongInt(xlHAlignCenter);
        3 {Justify}: HorizontalAlignment := LongInt(xlHAlignJustify);
        end;
      if (v.Alignment and frtaVertical)<>0 then Orientation:=90;
      case (v.Alignment and $18) of
        0 {Top}      : VerticalAlignment := LongInt(xlVAlignTop);
        frtaMiddle   : VerticalAlignment := LongInt(xlVAlignCenter);
        frtaDown     : VerticalAlignment := LongInt(xlVAlignBottom);
        end;
      vFont := (v as TfrMemoView).Font;
      Font.Name := vFont.Name;
      Font.Size := vFont.Size;
      if (fsBold in vFont.Style) then Font.Bold:= True;
      if (fsItalic in vFont.Style) then Font.Italic:= True;
      if (fsUnderline in vFont.Style) then Font.Underline:= True;
      if (fsStrikeOut in vFont.Style) then Font.Strikethrough:= True;
      if v.FrameTyp>0 then
        if v.FrameTyp=15 then Borders.LineStyle := xlContinuous
        else begin
          if (v.FrameTyp and 1)>0 then
            Borders[xlEdgeRight].LineStyle := xlContinuous;
          if (v.FrameTyp and 2)>0 then
            Borders[xlEdgeBottom].LineStyle := xlContinuous;
          if (v.FrameTyp and 4)>0 then
            Borders[xlEdgeLeft].LineStyle := xlContinuous;
          if (v.FrameTyp and 8)>0 then
            Borders[xlEdgeTop].LineStyle := xlContinuous;
        end;
    end;
  end;
end;

procedure TfrExcelExport.ExportPicture(v: TfrPictureView);
var
  MyFormat : Word;
  AData: Cardinal;
  APalette : HPALETTE;
begin
  if pos(v.Tag,'H')=0 then
  begin
    v.Picture.SaveToClipboardFormat(MyFormat,AData,APalette);
    Clipboard.SetAsHandle(MyFormat,THandle(AData));
    Inc(PicCount);
    eDoc.IXLSSheet.Paste(EmptyParam,EmptyParam,eDoc._LCID);
    with Picture(eDoc.IXLSSheet.Pictures(PicCount,eDoc._LCID)) do
    begin
      Width := v.dx/1.4;
      Height := v.dy/1.4;
      Left := (v.x-integer(RC['x'].Items[0]))/1.4;
      Top  := (v.y-integer(RC['y'].Items[0]))/1.25;
    end;
  end;
end;

procedure TfrExcelExport.DoExport;
var
  i: integer;
  v: TfrView;
  Mar: TRect;
  //!!!b
  OldCursor: TCursor;
  //!!!e
begin
  //!!!b
  OldCursor := Screen.Cursor;
  try
    Screen.Cursor := crHourGlass;
  //!!!e
    if BreakOnSheets then
      with eDoc do
      begin
        if PageNumber>IXLSBook.Sheets.Count then
          IXLSBook.Sheets.Add(EmptyParam,IXLSSheet,1,EmptyParam,_LCID);
        IXLSSheet := IXLSBook.Worksheets.Item[PageNumber] as IxlWorksheet;
        IXLSSheet.Activate(_LCID);
      end;

    SetCellsSize('x');
    SetCellsSize('y');

    with eDoc.IXLSSheet.PageSetup do
    begin
      if CurReport.EMFPages[PageNumber-1].pgor = poLandscape then
        Orientation := xlLandscape;
      Mar := CurReport.EMFPages[PageNumber-1].pgMargins;
      LeftMargin := Mar.Left/3.6+integer(RC['x'].Items[0]);
      RightMargin := Mar.Right/3.6;
      TopMargin := Mar.Top/3.6+integer(RC['y'].Items[0]);
      BottomMargin := Mar.Bottom/3.6;
    end;

    with eDoc.WriteBuffer do
    begin
      RightColumn := RC['x'].Count;
      Capacity := RC['y'].Count;
    end;
    for i:=1 to 255 do UsedCells[i]:=[];

    for i:=0 to Views.Count-1 do
    begin
      v := TfrView(Views[i]);
      if v is TfrMemoView then ExportMemo(v as TfrMemoView) else
      if v is TfrPictureView then ExportPicture(v as TfrPictureView);
      //!!!b
      //Application.ProcessMessages;
      //!!!e
    end;
    eDoc.WriteBuffer.Write;
    eDoc.WriteBuffer.Clear;
    ClearViews;
  //!!!b
  finally
    Screen.Cursor := OldCursor; 
  end;
  //!!!e
end;
//------------------------
procedure TfrExcelExport.OnBeginDoc;
begin
  OldAfterExport := OnAfterExport;
  OnAfterExport := DoAfterExport;
  if eDoc<>nil then eDoc.Free;
  eDoc := TfrExcel.Create(self);
  eDoc.Activated := True;
  {
  with eDoc do
  begin
    RunNewInstance := True;
    ShowSplash := True;
    WriteBuffer.Active := True;
    Activated := True;
  end;}
  PageNumber:=0;
  MaxY:=0;
  PicCount:=0;
  MaxRow:=0;
  {$ifdef Tdebug}TSave:=Now;{$endif}
end;

procedure TfrExcelExport.OnBeginPage;
begin
  Inc(PageNumber);
end;

procedure TfrExcelExport.OnEndPage;
begin
  // if each page exported on its own sheet - then export
  // else - wait for end of document 
  if BreakOnSheets then DoExport
  else begin
    MaxY := integer(RC['y'].Items[RC['y'].Count-1])+1;
    with eDoc.IXLSSheet do HPageBreaks.Add(Cells.Item[RC['y'].Count,1]);
  end;
end;

procedure TfrExcelExport.OnEndDoc;
var
  i: integer;
begin
  if not BreakOnSheets then DoExport;
  with eDoc.IXLSBook do
  begin
    for i:=PageNumber+1 to Sheets.Count do
      (WorkSheets.Item[PageNumber+1] as IxlWorksheet).Delete(eDoc._LCID);
   (Worksheets.Item[1] as IxlWorksheet).Activate(eDoc._LCID);
  end;
  {$ifdef Tdebug}
  TSave:=Now-TSave;
  ShowMessage('Time to export: '+FormatDateTime('hh:nn:ss',TSave)+#13#10#13#10#13#10#13#10#13#10#13#10);
  {$endif}
end;
//------------------------------------
procedure TfrExcelExport.OnData(x, y: Integer; View: TfrView);
var
  v: TfrPictureView;
  m: TfrMemoView;
begin
  if (View is TfrPictureView) then
  begin
    v := TfrPictureView.Create;
    v.Assign(View);
    Views.Add(v);
  end;
  if (View is TfrMemoView) then
    if (Views.Count=0) or (TfrView(Views[Views.Count-1]).Name<>View.Name) then
    begin
      m := TfrMemoView.Create;
      m.Assign(View);
      m.y:=m.y+MaxY; // vertical increment if export on single sheet
      Views.Add(m);
      AddRC('x',m.x);
      AddRC('x',m.x+m.dx);
      AddRC('y',m.y);
      AddRC('y',m.y+m.dy);
    end;
end;

procedure TfrExcelExport.OnText(DrawRect: TRect; X, Y: Integer;
  const Text: String; FrameTyp: Integer; View: TfrView);
begin
// here text comes line by line,
// but we need the whole object => go to OnData
end;

procedure TfrExcelExport.SetCellsSize(xy: char);
var
  i : Integer;
  val: double;
begin
  for i:=1 to RC[xy].Count-1 do
  try
    val := integer(RC[xy].Items[i])-integer(RC[xy].Items[i-1]);
    if xy='x' then begin
     {Excel's
      X: (0..1)1=12 pixel, (>1)1=7 pixel
      Y: 0.75=1 pixel
      and don't ask me why...}
      if val<=12 then val:=val/12
                 else val:=1+(val-12)/7.5; // why not 7? who knows...
      if val>255 then val:=255; // Excel limits
      end
    else begin
      val:=val/1.25; // why not 0.75? see above...
      if val>409 then val:=409; end;
    if xy='x' then eDoc.CellItem[EmptyParam,i].ColumnWidth := val
              else eDoc.IXLSSheet.Rows.Item[i,EmptyParam].RowHeight := val;
  except end;
end;

function TfrExcelExport.ShowModal: Word;
begin
  if not ShowDialog then Result := mrOK
  else
    with TfrXLSExportForm.Create(self) do Result:=ShowModal;
end;

{ TfrXLSExportForm }

procedure TfrXLSExportForm.FormShow(Sender: TObject);
begin
  with Owner as TfrExcelExport do
  begin
    cbOpen.Checked := OpenAfterExport;
    cbOnSheets.Checked := BreakOnSheets;
  end;
end;

procedure TfrXLSExportForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  with Owner as TfrExcelExport do
  begin
    OpenAfterExport := cbOpen.Checked;
    BreakOnSheets := cbOnSheets.Checked;
  end;
  Action := caFree;
end;

{ TfrExcel }

constructor TfrExcel.Create(AOwner: TComponent);
begin
  inherited;
  Visible:=false;
  FActivated:=false;
  WriteBuffer := TfrExcelWriteBuffer.Create(self);
end;

destructor TfrExcel.Destroy;
begin
  Activated := False;
  WriteBuffer.Free;
  inherited;
end;

function TfrExcel.GetCellItem(row, col: OleVariant): IxlRange;
begin
  Result := IXLSSheet.Cells.Item[row,col]
end;

function TfrExcel.GetCellValue(row, col: Integer): Variant;
begin
  Result := IXLSSheet.Cells.Item[row,col].Value
end;

procedure TfrExcel.SaveBook(fname: string);
begin
  if Assigned(IXLSBook) then
    if fname='' then IXLSBook.Save(FLCID)
                else OleVariant(IXLSBook).SaveAs(FileName:=fname)
end;

procedure TfrExcel.SetActivated(const Value: boolean);
var IU : IUnknown;
    isCreate:boolean;
begin
  if FActivated<>Value then
  begin
    if Value then
    begin
      try
        FLCID := LOCALE_USER_DEFAULT;
        // look for existing process
        isCreate:=not SUCCEEDED(GetActiveObject(Excel97.CLASS_ExcelApplication, nil, IU));
        if isCreate then
          FIXLSApp := CreateComObject(Excel97.CLASS_ExcelApplication) as Excel97._Application
        else
          FIXLSApp := IU as Excel97._Application;
        IXLSApp.DisplayAlerts[FLCID] := False;
      except
        MessageDlg('Failed to run Excel',mtError,[mbOk],0);
        raise;
      end;
      WriteBuffer.Clear;
      FIXLSBook := IXLSApp.Workbooks.Add(EmptyParam,0);
      FIXLSSheet := IXLSBook.Worksheets.Item[1] as Excel97._Worksheet;
      if isCreate then SetVisible(Visible);
    end
    else begin
      WriteBuffer.Write;
      FIXLSSheet := nil;
      FIXLSBook := nil;
      if Assigned(IXLSApp) and (not IXLSApp.Visible[FLCID]) then begin
        while IXLSApp.Workbooks.Count>0 do
          with IXLSApp.ActiveWorkbook do Close(False,FullName[FLCID],False,FLCID);
        IXLSApp.Quit;
      end;
      FIXLSApp := nil;
    end;
    FActivated := Value;
  end;
end;

procedure TfrExcel.SetCellValue(row, col: Integer; const Value: Variant);
begin
  if Assigned(IXLSSheet) then
    with WriteBuffer do
    begin
      if (row<FFirstRow) or (row>FLastRow) then
      begin
        WriteRange(FBuff,FFirstRow-1,LeftColumn-1);
        FFirstRow := row;
        FLastRow := row+Capacity;
        FBuff := VarArrayCreate([1,FLastRow-FFirstRow+1,1,
          RightColumn-LeftColumn+1],varVariant);
      end;
      FBuff[row-FFirstRow+1,col-LeftColumn+1] := Value;
    end;
end;

procedure TfrExcel.SetVisible(const Value: boolean);
begin
  FVisible := Value;
  if Assigned(IXLSApp) then begin
    IXLSApp.Visible[FLCID] := Value;
    if Value then begin
      if IXLSApp.WindowState[FLCID] = TOLEEnum(Excel97.xlMinimized) then
        IXLSApp.WindowState[FLCID] := TOLEEnum(Excel97.xlNormal);
      IXLSApp.ScreenUpdating[FLCID] := true;
      IXLSApp.DisplayAlerts[FLCID] := true;
//      Application.BringToFront;
    end;
  end;
end;

procedure TfrExcel.WriteRange(ARange: OleVariant; TopRow,
  LeftCol: Integer);
var
  IR1, IR2: IxlRange;
begin
  if not VarIsEmpty(ARange) then
  begin
    IR1 :=
      IXLSSheet.Cells.Item[VarArrayLowBound(ARange,1)+TopRow,
                           VarArrayLowBound(ARange,2)+LeftCol];
    IR2 :=
      IXLSSheet.Cells.Item[VarArrayHighBound(ARange,1)+TopRow,
                           VarArrayHighBound(ARange,2)+LeftCol];

    IXLSSheet.Range[IR1,IR2].Value := ARange;
  end;
end;

{ TfrExcelWriteBuffer }

procedure TfrExcelWriteBuffer.Clear;
begin
  fBuff := Unassigned;
  FFirstRow := 0;
  FLastRow := 0;
end;

constructor TfrExcelWriteBuffer.Create(AOwner: TfrExcel);
begin
  inherited Create;
  FOwner := AOwner;
  FLeftColumn := 1;
  FRightColumn := 1;
  FCapacity := 100;
  Clear;
end;

procedure TfrExcelWriteBuffer.SetCapacity(const Value: Integer);
begin
  if FCapacity<>Value then
  begin
    FCapacity := Value;
    FLastRow := 0;
  end;
end;

procedure TfrExcelWriteBuffer.SetLeftColumn(const Value: Integer);
begin
  if FLeftColumn<>Value then
  begin
    FLeftColumn := Value;
    FLastRow := 0;
  end;
end;

procedure TfrExcelWriteBuffer.SetRightColumn(const Value: Integer);
begin
  if FRightColumn<>Value then
  begin
    FRightColumn := Value;
    FLastRow := 0;
  end;
end;

procedure TfrExcelWriteBuffer.Write;
begin
  if Assigned(FOwner.IXLSSheet) then
    FOwner.WriteRange(FBuff,FFirstRow-1,LeftColumn-1);
end;

end.
