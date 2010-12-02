
{******************************************}
{                                          }
{             FastReport v2.52             }
{              Cross object                }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}
{ Advanced Cross-tab object                }
{ Copyright(c) by Pavel Ishenin            }
{ <webpirat@mail.ru>                       }
{******************************************}


unit FR_Cross;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Menus, FR_Class, FR_Cross1, FR_DSet, ExtCtrls, Buttons, fr_crossd;

type
  TfrCrossObject = class(TComponent)  // fake component
  end;

  TfrCrossView = class(TfrView)
  private
    FCross: TfrCross;
    FColumnWidths: TQuickIntArray;
    FColumnHeights: TQuickIntArray;
    LastTotalCol: TQuickIntArray;
    FFlag: Boolean;
    FSkip: Boolean;
    FRowDS: TfrUserDataset;
    FColumnDS: TfrUserDataset;
    FRepeatCaptions: Boolean;
    FSavedOnBeginDoc: TBeginDocEvent;
    FSavedOnBeforePrint: TEnterRectEvent;
    FSavedOnPrintColumn: TPrintColumnEvent;
    FSavedOnEndDoc: TEndDocEvent;
    FReport: TfrReport;
    MaxGTHeight, MaxCellHeight: Integer; 
    LastX: Integer;                      
    DefDY : Integer;                     
    MaxString : String;                  
    LongNames : TStringList;             
    procedure CreateObjects;
    procedure CalcWidths;
    procedure MakeBands;
    procedure ReportPrintColumn(ColNo: Integer; var Width: Integer);
    procedure ReportBeforePrint(Memo: TStringList; View: TfrView);
    procedure ReportEndDoc;
    procedure ReportBeginDoc;
    procedure P1Click(Sender: TObject);
    procedure P2Click(Sender: TObject);
    procedure P3Click(Sender: TObject);
    function  GetDataCellText : String;  
    procedure DictionaryEditor(Sender : TObject);
    function  GetDictName(s : String) : String;  
    function  CheckLongName(s : String) : String;
    function  FormatedLongNames : String;        
  protected
    procedure SetPropValue(Index: String; Value: Variant); override;
    function  GetPropValue(Index: String): Variant; override;
  public
    FShowHeader: Boolean;
    FInternalFrame: Boolean;
    FShowGrandTotal: Boolean;
    FDataWidth  : Integer;    
    FHeaderWidth: Integer;    
    FDictionary: TStringList; 
    FMaxNameLen: Integer;     
    FDataCaption: String;     
    constructor Create; override;
    destructor Destroy; override;
    procedure Draw(Canvas: TCanvas); override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure DefinePopupMenu(Popup: TPopupMenu); override;
    procedure DefineProperties; override;
    procedure ShowEditor; override;
  end;

  TfrCrossForm = class(TForm)
    Image1: TImage;
    GroupBox1: TGroupBox;
    ListBox2: TListBox;
    ListBox3: TListBox;
    ListBox4: TListBox;
    Shape1: TShape;
    Shape2: TShape;
    GroupBox2: TGroupBox;
    DatasetsLB: TComboBox;
    FieldsLB: TListBox;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    ComboBox2: TComboBox;
    CheckBox1: TCheckBox;
    SpeedButton1: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure DatasetsLBClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure ListBox3Enter(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure ListBox3Click(Sender: TObject);
    procedure ListBox4Click(Sender: TObject);
    procedure ComboBox2Click(Sender: TObject);
    procedure ListBox4DrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure FieldsLBDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure FieldsLBDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ListBox3DblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
    FListBox: TListBox;
    FBusy: Boolean;
    DrawPanel: TPanel;
    procedure FillDatasetsLB;
    procedure Localize;
    procedure ClearSelection(Sender : TObject);
  public
    { Public declarations }
    Cross: TfrCrossView;
  end;

var 
  GrandTotalStr, TotalStr, TotalOfStr, CellStr, HeaderStr : String;

implementation

{$R *.DFM}

uses FR_Const, FR_DBRel, FR_Utils
{$IFDEF Delphi6}
, Variants
{$ENDIF}
;

type
  TDrawPanel = class(TPanel)
  private
    RowTotals : Integer;
    FColumnFields: TStrings;
    FRowFields: TStrings;
    FCellFields: TStrings;
    LastX, LastY, DefDx, DefDy : Integer;
    procedure Draw(x, y, dx ,dy: Integer; s: String);
    procedure DrawColumnCells;
    procedure DrawRowCells;
    procedure DrawCellField;
    procedure DrawBorderLines(pos : byte);
  public
    procedure Paint; override;
  end;

  TfrCrossList = class
  private
    FList: TList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(v: TfrCrossView);
    procedure Delete(v: TfrCrossView);
  end;

  TfrCrossLists = class
  private
    FList: TList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(v: TfrCrossView);
    procedure Delete(v: TfrCrossView);
  end;

  THackUserDataset = class(TfrUserDataset)
  end;

var
  frCrossForm: TfrCrossForm;
  frCrossLists: TfrCrossLists;

function PureName1(s: String): String;
begin
  if Pos('+', s) <> 0 then
    Result := Copy(s, 1, Pos('+', s) - 1) else
    Result := s;
end;


{ TfrCrossList }

constructor TfrCrossList.Create;
begin
  inherited Create;
  FList := TList.Create;
end;

destructor TfrCrossList.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

procedure TfrCrossList.Add(v: TfrCrossView);
begin
  FList.Add(v);
  v.FSavedOnBeginDoc := v.FReport.OnCrossBeginDoc;
  v.FReport.OnCrossBeginDoc := v.ReportBeginDoc;
  v.FSavedOnBeforePrint := v.FReport.OnBeforePrint;
  v.FReport.OnBeforePrint := v.ReportBeforePrint;
  v.FSavedOnPrintColumn := v.FReport.OnPrintColumn;
  v.FReport.OnPrintColumn := v.ReportPrintColumn;
  v.FSavedOnEndDoc := v.FReport.OnEndDoc;
  v.FReport.OnEndDoc := v.ReportEndDoc;
end;

procedure TfrCrossList.Delete(v: TfrCrossView);
var
  i: Integer;
  v1: TfrCrossView;
begin
  v.FReport.OnCrossBeginDoc := v.FSavedOnBeginDoc;
  v.FReport.OnBeforePrint := v.FSavedOnBeforePrint;
  v.FReport.OnPrintColumn := v.FSavedOnPrintColumn;
  v.FReport.OnEndDoc := v.FSavedOnEndDoc;

  i := FList.IndexOf(v);
  FList.Delete(i);

  if (i = 0) and (FList.Count > 0) then
  begin
    v := TfrCrossView(FList[0]);
    v.FSavedOnBeginDoc := v.FReport.OnCrossBeginDoc;
    v.FSavedOnEndDoc := v.FReport.OnEndDoc;
    v.FSavedOnBeforePrint := v.FReport.OnBeforePrint;
    v.FSavedOnPrintColumn := v.FReport.OnPrintColumn;
  end;

  for i := 1 to FList.Count - 1 do
  begin
    v := TfrCrossView(FList[i]);
    v1 := TfrCrossView(FList[i - 1]);
    v.FSavedOnBeginDoc := v1.ReportBeginDoc;
    v.FSavedOnEndDoc := v1.ReportEndDoc;
    v.FSavedOnBeforePrint := v1.ReportBeforePrint;
    v.FSavedOnPrintColumn := v1.ReportPrintColumn;
  end;

  if FList.Count > 0 then
  begin
    v := TfrCrossView(FList[FList.Count - 1]);
    v.FReport.OnCrossBeginDoc := v.ReportBeginDoc;
  end;
end;

{ TfrCrossLists }

constructor TfrCrossLists.Create;
begin
  inherited Create;
  FList := TList.Create;
end;

destructor TfrCrossLists.Destroy;
var
  cl: TfrCrossList;
begin
  while FList.Count > 0 do
  begin
    cl := FList[0];
    cl.Free;
    FList.Delete(0);
  end;
  FList.Free;
  inherited Destroy;
end;

procedure TfrCrossLists.Add(v: TfrCrossView);
var
  i, Index: Integer;
  cl: TfrCrossList;
begin
  Index := -1;
  for i := 0 to FList.Count - 1 do
  begin
    cl := FList[i];
    if (cl.FList.Count > 0) and (TfrCrossView(cl.FList[0]).FReport = v.FReport) then
    begin
      Index := i;
      break;
    end;
  end;
  if Index = -1 then
  begin
    cl := TfrCrossList.Create;
    FList.Add(cl);
    Index := FList.Count - 1;
  end;
  cl := FList[Index];
  cl.Add(v);
end;

procedure TfrCrossLists.Delete(v: TfrCrossView);
var
  i, Index: Integer;
  cl: TfrCrossList;
begin
  Index := -1;
  for i := 0 to FList.Count - 1 do
  begin
    cl := FList[i];
    if (cl.FList.Count > 0) and (TfrCrossView(cl.FList[0]).FReport = v.FReport) then
    begin
      Index := i;
      break;
    end;
  end;
  if Index <> -1 then
  begin
    cl := FList[Index];
    cl.Delete(v);
    if cl.FList.Count = 0 then
    begin
      cl.Free;
      FList.Delete(Index);
    end;
  end;
end;

{ TfrCrossView }

constructor TfrCrossView.Create;
begin
  inherited Create;
  FCross := nil;
  Typ := gtAddIn;
  BaseName := 'Cross';
  Flags := Flags + flDontUndo + flOnePerPage;
  FrameTyp := 15;
  Restrictions := frrfDontEditMemo + frrfDontSize;
  dx := 348;
  dy := 94;
  Visible := False;
  FReport := CurReport;
  frCrossLists.Add(Self);
  DefDY := 18;
  FDictionary := TStringList.Create;
  FShowHeader     := True;
  FInternalFrame  := False;
  FShowGrandTotal := True;
  FDataWidth      := -1;
  FHeaderWidth    := -1;
  FMaxNameLen     := 100;
  FDataCaption    := 'Data';

  GrandTotalStr := frLoadStr(frRes + 2600);
  TotalStr := frLoadStr(frRes + 2601); 
  TotalOfStr := frLoadStr(frRes + 2602); 
  CellStr := frLoadStr(frRes + 2603); 
  HeaderStr := frLoadStr(frRes + 2604); 

end;

destructor TfrCrossView.Destroy;
var
  i: Integer;
  p: TfrPage;

  procedure Del(s: String);
  var
    v: TfrView;
  begin
    if p <> nil then
    begin
      v := p.FindObject(s);
      if v <> nil then
        p.Delete(p.Objects.IndexOf(v));
    end;
  end;

begin
  p := nil;
  for i := 0 to FReport.Pages.Count - 1 do
    if FReport.Pages[i].FindObject(Self.Name) <> nil then
    begin
      p := FReport.Pages[i];
      break;
    end;

  Del('ColumnHeaderMemo' + Name);
  Del('ColumnTotalMemo' + Name);
  Del('GrandColumnTotalMemo' + Name);
  Del('RowHeaderMemo' + Name);
  Del('CellMemo' + Name);
  Del('RowTotalMemo' + Name);
  Del('GrandRowTotalMemo' + Name);
  frCrossLists.Delete(Self);
  FDictionary.Free;
  inherited Destroy;
end;

procedure TfrCrossView.CreateObjects;
var
  v: TfrMemoView;
  i: Integer;
  p: TfrPage;

  function OneObject(Name1, Name2: String): TfrMemoView;
  begin
    Result := TfrMemoView(frCreateObject(gtMemo, ''));
    Result.Name := Name1 + Name;
    Result.Memo.Add(Name2);
    Result.Font.Style := [fsBold];
    Result.dx := 80;
    Result.dy := DefDY;
    Result.Visible := False;
    Result.Alignment := frtaCenter + frtaMiddle;
    Result.FrameTyp := 15;
    Result.Restrictions := frrfDontSize + frrfDontMove + frrfDontDelete;
    p.Objects.Add(Result);
  end;

begin
  p := nil;
  for i := 0 to FReport.Pages.Count - 1 do
    if FReport.Pages[i].FindObject(Self.Name) <> nil then
    begin
      p := FReport.Pages[i];
      break;
    end;

  OneObject('ColumnHeaderMemo', HeaderStr);                

  v := OneObject('ColumnTotalMemo', TotalStr);             
  v.FillColor := $F5F5F5;

  v := OneObject('GrandColumnTotalMemo', GrandTotalStr);   
  v.FillColor := clSilver;

  OneObject('RowHeaderMemo', HeaderStr);                   

  v := OneObject('CellMemo', CellStr);                     
  v.Alignment := frtaRight;
  v.Font.Style := [];

  v := OneObject('RowTotalMemo', TotalStr);                
  v.FillColor := $F5F5F5;

  v := OneObject('GrandRowTotalMemo', GrandTotalStr);     
  v.FillColor := clSilver;
end;

procedure TfrCrossView.DefineProperties;
begin
  inherited DefineProperties;
  AddProperty('InternalFrame', [frdtBoolean], nil);
  AddProperty('RepeatCaptions', [frdtBoolean], nil);
  AddProperty('ShowHeader', [frdtBoolean], nil);        
  AddProperty('ShowGrandTotal', [frdtBoolean], nil);    
  AddProperty('DataWidth', [frdtInteger], nil);         
  AddProperty('HeaderWidth', [frdtInteger], nil);       
  AddProperty('Dictionary', [frdtOneObject, frdtHasEditor], DictionaryEditor);
  AddProperty('MaxNameLen', [frdtInteger], nil);
  AddProperty('DataCaption', [frdtString], nil);
  DelProperty('Name');
end;

procedure TfrCrossView.SetPropValue(Index: String; Value: Variant);
begin
  inherited SetPropValue(Index, Value);
  Index := AnsiUpperCase(Index);
  if Index = 'INTERNALFRAME' then
    FInternalFrame := Value
  else if Index = 'REPEATCAPTIONS' then
    FRepeatCaptions := Value
  else if Index = 'SHOWHEADER' then
    FShowHeader := Value
  else if Index = 'SHOWGRANDTOTAL' then
    FShowGrandTotal := Value
  else if Index = 'DATAWIDTH' then
    FDataWidth := Value
  else if Index = 'HEADERWIDTH' then
    FHeaderWidth := Value
  else if Index = 'MAXNAMELEN' then
    FMaxNameLen := Value
  else if Index = 'DATACAPTION' then
    FDataCaption := Value
end;

function TfrCrossView.GetPropValue(Index: String): Variant;
begin
  Index := AnsiUpperCase(Index);
  Result := inherited GetPropValue(Index);
  if Result <> Null then Exit;
  if Index = 'INTERNALFRAME' then
    Result := FInternalFrame
  else if Index = 'REPEATCAPTIONS' then
    Result := FRepeatCaptions
  else if Index = 'SHOWHEADER' then
    Result := FShowHeader
  else if Index = 'SHOWGRANDTOTAL' then
    Result := FShowGrandTotal
  else if Index = 'DATAWIDTH' then
    Result := FDataWidth
  else if Index = 'HEADERWIDTH' then
    Result := FHeaderWidth
  else if Index = 'MAXNAMELEN' then
    Result := FMaxNameLen
  else if Index = 'DATACAPTION' then
    Result := FDataCaption
end;

procedure TfrCrossView.ShowEditor;
begin
  frCrossForm.Cross := Self;
  frCrossForm.ShowModal;
end;

procedure TfrCrossView.Draw(Canvas: TCanvas);
var
  v: TfrView;
begin
  if FReport.FindObject('ColumnHeaderMemo' + Name) = nil then
    CreateObjects;
  BeginDraw(Canvas);
  CalcGaps;
  ShowBackground;
  ShowFrame;

  v := FReport.FindObject('ColumnHeaderMemo' + Name);
  v.SetBounds(x + 92, y + 8, v.dx, v.dy);
  v.Draw(Canvas);

  v := FReport.FindObject('ColumnTotalMemo' + Name);
  v.SetBounds(x + 176, y + 8, v.dx, v.dy);
  v.Draw(Canvas);

  v := FReport.FindObject('GrandColumnTotalMemo' + Name);
  v.SetBounds(x + 260, y + 8, v.dx, v.dy);
  v.Draw(Canvas);

  v := FReport.FindObject('RowHeaderMemo' + Name);
  v.SetBounds(x + 8, y + 28, v.dx, v.dy);
  v.Draw(Canvas);

  v := FReport.FindObject('CellMemo' + Name);
  v.SetBounds(x + 92, y + 28, v.dx, v.dy);
  v.Draw(Canvas);

  v := FReport.FindObject('RowTotalMemo' + Name);
  v.SetBounds(x + 8, y + 48, v.dx, v.dy);
  v.Draw(Canvas);

  v := FReport.FindObject('GrandRowTotalMemo' + Name);
  v.SetBounds(x + 8, y + 68, v.dx, v.dy);
  v.Draw(Canvas);

  Canvas.Draw(x + dx - 20, y + dy - 20, frCrossForm.Image1.Picture.Bitmap);
  RestoreCoord;
end;

procedure TfrCrossView.LoadFromStream(Stream: TStream);
begin
  inherited LoadFromStream(Stream);
  FInternalFrame := frReadBoolean(Stream);
  FRepeatCaptions := frReadBoolean(Stream);
  FShowHeader := frReadBoolean(Stream);
  if LVersion > 0 then 
  begin
    FShowGrandTotal := frReadBoolean(Stream);
    FDataWidth      := frReadInteger(Stream);
    FHeaderWidth    := frReadInteger(Stream);
  end else begin
    FShowGrandTotal := True;
    FDataWidth      := -1;
    FHeaderWidth    := -1;
  end;
  if LVersion > 1 then 
  begin
    FDictionary.Text := frReadString(Stream);
    FMaxNameLen  := frReadInteger(Stream);
  end else begin
    FDictionary.Text := '';
    FMaxNameLen  := 100;
  end;
  if LVersion > 2 then
  begin
    FDataCaption := frReadString(Stream);
  end else
  begin
    FDataCaption := 'Data';
  end;
end;

procedure TfrCrossView.SaveToStream(Stream: TStream);
begin
  LVersion := 3;
  inherited SaveToStream(Stream);
  frWriteBoolean(Stream, FInternalFrame);
  frWriteBoolean(Stream, FRepeatCaptions);
  frWriteBoolean(Stream, FShowHeader);
  frWriteBoolean(Stream, FShowGrandTotal);
  frWriteInteger(Stream, FDataWidth);
  frWriteInteger(Stream, FHeaderWidth);
  frWriteString (Stream, FDictionary.Text);
  frWriteInteger(Stream, FMaxNameLen);
  frWriteString(Stream, FDataCaption);
end;

procedure TfrCrossView.DefinePopupMenu(Popup: TPopupMenu);
var
  m: TMenuItem;
begin
  m := TMenuItem.Create(Popup);
  m.Caption := frLoadStr(frRes + 2605);
  m.OnClick := P1Click;
  m.Checked := FRepeatCaptions;
  Popup.Items.Add(m);

  m := TMenuItem.Create(Popup);
  m.Caption := frLoadStr(frRes + 2606);
  m.OnClick := P2Click;
  m.Checked := FInternalFrame;
  Popup.Items.Add(m);

  m := TMenuItem.Create(Popup); 
  m.Caption := frLoadStr(frRes + 2607);
  m.OnClick := P3Click;
  m.Checked := FShowHeader;
  Popup.Items.Add(m);
end;

procedure TfrCrossView.P1Click(Sender: TObject);
begin
  frDesigner.BeforeChange;
  with Sender as TMenuItem do
  begin
    Checked := not Checked;
    if (Restrictions and frrfDontModify) = 0 then
      FRepeatCaptions := Checked;
  end;
  frDesigner.AfterChange;
end;

procedure TfrCrossView.P2Click(Sender: TObject);
begin
  frDesigner.BeforeChange;
  with Sender as TMenuItem do
  begin
    Checked := not Checked;
    if (Restrictions and frrfDontModify) = 0 then
      FInternalFrame := Checked;
  end;
  frDesigner.AfterChange;
end;


//------------------------------------
type
  THackMemoView = class(TfrMemoView)
  end;

procedure TfrCrossView.CalcWidths;
var
  i, w, maxw, h, maxh, k: Integer;
  v: TfrView;
  b: TBitmap;
  m: TStringList;
begin
  FFlag := True;
  if FDataWidth = -1 then 
    FColumnWidths  := TQuickIntArray.Create(FCross.Columns.Count+1) else
  if FHeaderWidth = -1 then
    FColumnWidths  := TQuickIntArray.Create(FCross.TopLeftSize.cx+1);

  FColumnHeights := TQuickIntArray.Create(FCross.TopLeftSize.cy + 2);
  LastTotalCol   := TQuickIntArray.Create(FCross.TopLeftSize.cy + 1);

  MaxCellHeight := 0; MaxGTHeight := 0;

  If not FShowGrandTotal then 
  begin
    FRowDS.RangeEndCount    := FRowDS.RangeEndCount - 1;
    FColumnDS.RangeEndCount := FColumnDS.RangeEndCount - 1;
  end;

  for k := 0 to FCRoss.CellItemsCount - 1 do 
  begin
    v := FReport.FindObject('CrossMemo@'+ IntToStr(k) + Name);
    m := TStringList.Create;
    b := TBitmap.Create;
    THackMemoView(v).Canvas := b.Canvas;

    if FHeaderWidth = -1 then 
    begin
      FColumnDS.First;
      while FColumnDS.RecNo < FCross.TopLeftSize.cx do
      begin
        maxw := 0;

        FRowDS.First;
        FRowDS.Next;
        while not FRowDS.EOF do
        begin
          ReportBeforePrint(nil, v);
          m.Assign(v.Memo);
          if m.Count = 0 then
            m.Add(' ');
          w := THackMemoView(v).CalcWidth(m) + 5;
          if w > maxw then
            maxw := w;
          FRowDS.Next;
        end;
        If FColumnWidths.Cell[FColumnDS.RecNo] < maxw then FColumnWidths.Cell[FColumnDS.RecNo] := maxw;
        FColumnDS.Next;
      end;
    end;
    if FDataWidth = -1 then 
    begin
      THackUserDataset(FColumnDS).FRecNo := FCross.TopLeftSize.cx;
      while not FColumnDS.EOF do
      begin
        maxw := 0;

        FRowDS.First;
        FRowDS.Next;
        while not FRowDS.EOF do
        begin
          ReportBeforePrint(nil, v);
          m.Assign(v.Memo);
          if m.Count = 0 then
            m.Add(' ');
          w := THackMemoView(v).CalcWidth(m) + 5;
          if w > maxw then
            maxw := w;
          FRowDS.Next;
        end;
        If FColumnWidths.Cell[FColumnDS.RecNo] < maxw then FColumnWidths.Cell[FColumnDS.RecNo] := maxw;
        FColumnDS.Next;
      end;
      FColumnWidths.Cell[FCross.Columns.Count] := 0;
    end;
  
    FRowDS.First;
    for i := 0 to FCross.TopLeftSize.cy do
    begin
      maxh := 0;

      FColumnDS.First;
      while not FColumnDS.EOF do
      begin
        w := v.dx;
        v.dx := 1000;
        h := THackMemoView(v).CalcHeight;
        v.dx := w;
        if h > maxh then
          maxh := h;
        FColumnDS.Next;
      end;

      if maxh > v.dy then
        FColumnHeights.Cell[i] := maxh else
        FColumnHeights.Cell[i] := v.dy;
      FRowDS.Next;
    end;

    FColumnDS.First;  
    while not FColumnDS.EOF do
    begin
      w := v.dx;
      v.dx := 1000;
      h := THackMemoView(v).CalcHeight;
      v.dx := w;
      if h > MaxCellHeight then
        MaxCellHeight := h;
      FColumnDS.Next;
    end;

    If FShowGrandTotal then   
    begin
      THackUserDataset(FRowDS).FRecNo := FRowDS.RangeEndCount - 1;
      FColumnDS.First;
      while not FColumnDS.EOF do
      begin
        w := v.dx;
        v.dx := 1000;
        h := THackMemoView(v).CalcHeight;
        v.dx := w;
        if h > MaxGTHeight then
          MaxGTHeight := h;
        FColumnDS.Next;
      end;
    end;

    THackMemoView(v).DrawMode := drAll;
    m.Free;
    b.Free;
  end;

  if MaxCellHeight < DefDy then 
     MaxCellHeight := DefDY;
  if MaxGTHeight < DefDy then   
     MaxGTHeight := DefDY;
  FFlag  := False;
  LastX := 0;                  
end;

procedure TfrCrossView.MakeBands;
var
  i, j, d, d1, dx, dh: Integer;
  ch1, ch2, cd1, cd2, cf1: TfrBandView;
  v: TfrMemoView;
  p: TfrPage;
begin
  p := nil;
  for i := 0 to FReport.Pages.Count - 1 do
    if FReport.Pages[i].FindObject(Self.Name) <> nil then
    begin
      p := FReport.Pages[i];
      break;
    end;

  ch1 := TfrBandView.Create; // master header
  ch1.BandType := btMasterHeader;
  ch1.Name := 'CrossHeader1' + Name;
  ch1.SetBounds(0, 400, 0, DefDY);
  if FRepeatCaptions then
    ch1.Prop['RepeatHeader'] := True;
  p.Objects.Add(ch1);

  cd1 := TfrBandView.Create; // master data
  cd1.BandType := btMasterData;
  cd1.Name := 'CrossData1' + Name;
  cd1.SetBounds(0, 500, 0, DefDY);
  cd1.DataSet := 'RowDS' + Name;
  cd1.Prop['Stretched'] := True;
  p.Objects.Add(cd1);

  ch2 := TfrBandView.Create; // cross header
  ch2.BandType := btCrossHeader;
  ch2.Name := 'CrossHeader2' + Name;
  ch2.SetBounds(p.LeftMargin, 0, 60, DefDY);
  if FRepeatCaptions then
    ch2.Prop['RepeatHeader'] := True;
  p.Objects.Add(ch2);

  cd2 := TfrBandView.Create; // cross data
  cd2.BandType := btCrossData;
  cd2.Name := 'CrossData2' + Name;
  cd2.DataSet := 'CrossHeader1' + Name + '=ColumnDS' + Name + ';CrossData1' + Name + '=ColumnDS' + Name + ';';
  cd2.SetBounds(500, 0, 60, DefDY);
  p.Objects.Add(cd2);

  d  := cd1.y;   
  dh := cd1.dy;
  for i := 0 to FCross.CellItemsCount - 1 do
  begin
    v := TfrMemoView.Create;
    v.Name := 'CrossMemo@' + IntToStr(i) + Name;
    v.SetBounds(cd2.x, d, cd2.dx, dh);
    p.Objects.Add(v);
    inc(d, dh);
    inc(cd1.dy, dh);
  end;

  CalcWidths; 

  cd1.dy := MaxCellHeight*FCross.CellItemsCount; 
  dh := MaxCellHeight;
  d  := cd1.y;
  for i := 0 to FCross.CellItemsCount - 1 do
  begin
    v := FReport.FindObject('CrossMemo@'+ IntToStr(i) + Name) as TfrMemoView;
    v.y :=  d; 
    v.dy := dh;
    inc(d, dh);
  end;

  ch2.dx := 0;
  d := ch2.x;
  for i := 0 to FCross.TopLeftSize.cx - 1 do
  begin
    v := TfrMemoView.Create;
    if FHeaderWidth = -1 then
      dx := FColumnWidths.Cell[i] else
      dx := FHeaderWidth;
    v.SetBounds(d, cd1.y, dx, cd1.dy);
    v.Name := 'CrossMemo' + IntToStr(i) + Name;
    p.Objects.Add(v);
    inc(ch2.dx, dx);
    inc(d, dx);
  end;

  ch1.dy := 0;
  d := ch1.y;
  for i := 0 to FCross.TopLeftSize.cy - 1 + ord(FShowHeader) do //!! Не забываем про заголовок
  begin
    v := TfrMemoView.Create;
    dh := FColumnHeights.Cell[i];
    v.SetBounds(cd2.x, d, cd2.dx, dh);
    v.Name := 'CrossMemo_' + IntToStr(i) + Name;
    p.Objects.Add(v);
    inc(ch1.dy, dh);
    inc(d, dh);
  end;

  if FShowHeader then 
  begin
    d  := ch1.y;
    for i := 0 to FCross.TopLeftSize.cy do
    begin
      d1 := ch2.x;
      dh := FColumnHeights.Cell[i];
      for j := 0 to FCross.TopLeftSize.cx - 1 do
      begin
        v := TfrMemoView.Create;
        if FHeaderWidth = -1 then
           dx := FColumnWidths.Cell[j] else
           dx := FHeaderWidth;
        v.SetBounds(d1, d, dx, dh);
        v.Name := 'CrossMemo~' + IntToStr(i) +  '~' + IntToStr(j) + Name; //04.12.01  Их имя содержит 2 координаты
        p.Objects.Add(v);
        inc(d1, dx);
      end;
      inc(d, dh);
    end;

    if LongNames.Count > 0 then
    begin
      cf1 := TfrBandView.Create; // master footer
      cf1.BandType := btMasterFooter;
      cf1.Name := 'CrossFooter1' + Name;
      cf1.SetBounds(0, p.BottomMargin - (LongNames.Count+1) * DefDY, 0, (LongNames.Count+1) * DefDY);
      p.Objects.Add(cf1);

      v := TfrMemoView.Create;
      v.SetBounds(p.LeftMargin, cf1.y + DefDY, p.RightMargin - p.LeftMargin, LongNames.Count * DefDY);
      v.Name := 'CrossFooterMemo' + Name;
      v.FrameTyp := 15;
      v.Memo.Text := FormatedLongNames;
      v.Alignment := frtaMiddle;
      v.Prop['AutoWidth'] := True;
      p.Objects.Add(v);
    end;
  end;
end;

procedure TfrCrossView.ReportPrintColumn(ColNo: Integer; var Width: Integer);
var
  i: Integer;
begin
  if not FSkip and (Pos(Name, CurView.Name) <> 0) then
  begin
    if FDataWidth = -1 then
      Width := FColumnWidths.Cell[ColNo - 1 + FCross.TopLeftSize.cx] else
      Width := FDataWidth;

    for i := 0 to FCRoss.CellItemsCount - 1 do
      FReport.FindObject('CrossMemo@' + IntToStr(i) + Name).dx := Width;

    if FRowDS.RecNo < FCross.TopLeftSize.cy then
      for i := 0 to FCross.TopLeftSize.cy - 1 do
        FReport.FindObject('CrossMemo_' + IntToStr(i) + Name).dx := Width;
  end;
  if Assigned(FSavedOnPrintColumn) then
    FSavedOnPrintColumn(ColNo, Width);
end;

function GetString(S : String; N : Integer) : String; 
var i : Integer;
begin
  Result := '';
  for i := 1 to Length(S) do
  begin
    If S[i] = ';' then Dec(N) else
    If N = 1 then Result := Result + s[i] else
    If N = 0 then break;
  end;
end;
function GetPureString(S : String; N : Integer) : String; //!! Получает подстроку из строки Memo
var i : Integer;
begin
  Result := '';
  for i := 1 to Length(S) do
  begin
    If S[i] = ';' then Dec(N) else
    If N = 1 then Result := Result + s[i] else
    If N = 0 then break;
  end;
  Result := PureName1(Result);
end;

procedure TfrCrossView.ReportBeforePrint(Memo: TStringList; View: TfrView);
var
  v: Variant;
  s, s1: String;
  i, j, row, col: Integer;
  hd: Boolean;
  al: Integer;
//  v1: TfrMemoView;
  ft : Word;

  procedure Assign(m1, m2: TfrMemoView);
  begin
    m1.Flags        := m2.Flags;
    m1.FrameWidth   := m2.FrameWidth;
    m1.FrameColor   := m2.FrameColor;
    m1.FrameStyle   := m2.FrameStyle;
    m1.FillColor    := m2.FillColor;
    m1.Format       := m2.Format;
    m1.FormatStr    := m2.FormatStr;
    m1.gapx         := m2.gapx;
    m1.gapy         := m2.gapy;
    m1.Alignment    := m2.Alignment;
    m1.Highlight    := m2.Highlight;
    m1.HighlightStr := frParser.Str2OPZ(m2.HighlightStr);
    m1.LineSpacing  := m2.LineSpacing;
    m1.CharacterSpacing := m2.CharacterSpacing;
    m1.Font             := m2.Font;
  end;

begin
  if not FSkip and
    (Pos('CrossMemo', View.Name) = 1) and (Pos(Name, View.Name) <> 0) then
  begin
    i   := 0;
    row := FRowDS.RecNo;
    col := FColumnDS.RecNo;
    if not FFlag then
    begin
      while FRowDS.RecNo <= FCross.TopLeftSize.cy do
        FRowDS.Next;
      while FColumnDS.RecNo < FCross.TopLeftSize.cx do
        FColumnDS.Next;
      row := FRowDS.RecNo;
      col := FColumnDS.RecNo;
      if View.Name <> 'CrossMemo@0' + Name then
      begin
        s := Copy(View.Name, 1, Pos(Name, View.Name) - 1);
        if s[10] in ['_', '@', '~'] then 
        begin
          if s[10] = '@' then 
            i := StrToInt(Copy(s, 11, 255)) else 
          if s[10] = '~' then 
          begin
            Delete(s, 1, 10);
            row := StrToInt(Copy(s, 1, Pos('~', s) - 1));
            Delete(s, 1, Pos('~', s));
            col := StrToInt(s);
          end else
          begin
            row := StrToInt(Copy(s, 11, 255));
            if not FShowHeader then
              Inc(row);
          end
        end else col := StrToInt(Copy(s, 10, 255));
      end;
    end else if View.Name <> 'CrossMemo' + Name then
    begin
      s := Copy(View.Name, 1, Pos(Name, View.Name) - 1); 
      if s[10] = '@' then i := StrToInt(Copy(s, 11, 255));
    end;
    if not FShowHeader and (row = 0) then
      Inc(row);
    If not FFlag then
    begin
      If row <= FCross.TopLeftSize.cy then View.dy := FColumnHeights.Cell[Row];
      View.Visible := True;
      if (Col < FCross.TopLeftSize.cx) then
        if (FHeaderWidth = -1) then
           View.dx := FColumnWidths.Cell[Col] else
           View.dx := FHeaderWidth else
        if (FDataWidth = -1) then
          View.dx := FColumnWidths.Cell[Col] else
          View.dx := FDataWidth;
    end;

    Assign(TfrMemoView(View), TfrMemoView(FReport.FindObject('CellMemo' + Name)));
    al := TfrMemoView(View).Alignment;
    if FInternalFrame then
      View.FrameTyp := 15 else
      View.FrameTyp := frftLeft or frftRight;

    if (row = FCross.TopLeftSize.cy + 1) and (col >= FCross.TopLeftSize.cx) then
      if View.FrameTyp = frftLeft or frftRight then
         Inc(View.FrameTyp, frftTop);

    v := FCross.CellByIndex[row, col, -1];
    if v <> Null then
      View.FrameTyp := v;
    if row = FCross.Rows.Count - 2 then
      View.FrameTyp := View.FrameTyp or frftBottom;

    v := FCross.CellByIndex[row, col, 0];
    if v = Null then
      s := '' else
      s := v;

    hd := False;
    if (row <= FCross.TopLeftSize.cy) then // header
    begin
      Assign(TfrMemoView(View), TfrMemoView(FReport.FindObject('ColumnHeaderMemo' + Name)));
      hd := True;
      If not FFlag then
      begin
        If (col >= FCross.TopLeftSize.cx) then
          if (row > 0) then 
          begin
            View.Visible := (v <> Null) or (col - LastTotalCol.Cell[row-1] = 1);
            If (View.Visible and
               (col < FCross.Columns.Count - 1)) and
               (FCross.CellByIndex[row, col + 1, 0] = Null) then
            begin
              for i := Col + 1 to FCross.Columns.Count - 1 do
              begin
                ft := FCross.CellByIndex[row, i, -1];
                if FDataWidth = -1 then
                  j := View.dx + FColumnWidths.Cell[i] else
                  j := View.dx + FDataWidth;
                if not ((ft <> frftTop) and (ft and frftLeft <> 0))  then
                  If (View.x + j <= CurPage.RightMargin) then View.dx := j else
                  begin
                    if not FRepeatCaptions then View.FrameTyp := View.FrameTyp xor frftRight;
                    LastTotalCol.Cell[row-1] := i-1;
                    break;
                  end
                else break;
              end;
            end;
          end else
          begin
            View.Visible   := (v <> Null) or (col - LastX = 1);
            View.FrameTyp  := View.FrameTyp or frftTop or frftBottom or frftRight;
            TfrMemoView(View).Alignment := TfrMemoView(View).Alignment xor frtaCenter;

            If View.Visible and (col < FCross.Columns.Count - 1) then
            begin
              for i := Col + 1 to FCross.Columns.Count - 1 do
              begin
                if FDataWidth = -1 then
                  j := View.dx + FColumnWidths.Cell[i] else
                  j := View.dx + FDataWidth;
                if (View.x + j <= CurPage.RightMargin) then 
                View.dx := j else begin
                  if not FRepeatCaptions then View.FrameTyp := View.FrameTyp xor frftRight;
                  LastX := i-1;
                  break;
                end
              end;
            end;
          end
        else begin // Row Header
          If row = FCross.TopLeftSize.cy then
            View.FrameTyp := 15
          else begin
            v := '';
            if col = FCross.TopLeftSize.cx -1 then View.FrameTyp := frftRight else View.FrameTyp := 0;
            if Col = 0 then inc(View.FrameTyp, frftLeft); 
            if (row = 0) then
            begin
              inc(View.FrameTyp, frftTop); 
              if not FCross.DoDataCol then 
                inc(View.FrameTyp, frftBottom);
              if  (col = 0) then
              begin
                if (not FCross.DoDataCol) then
                  for j := 1 to FCross.CellItemsCount do
                    v := v + CheckLongName(GetDictName(GetString(Self.Memo.Strings[3], j)))+ '  ';
              end;
            end;
          end;
        end;
      end;
      If (col < FCross.TopLeftSize.cx) and (row = FCross.TopLeftSize.cy) then
      begin
        if (col = FCross.TopLeftSize.cx - 1) and (FCross.DoDataCol) then
          v := FDataCaption else
          v := GetDictName(GetPureString(Self.Memo.Strings[1], Col + 1));
      end;
    end
    else if (col < FCross.TopLeftSize.cx) and (row > FCross.TopLeftSize.cy) then // row header
    begin
      Assign(TfrMemoView(View), TfrMemoView(FReport.FindObject('RowHeaderMemo' + Name)));
      if FFlag and (col = FCross.TopLeftSize.cx - 1) and FCross.DoDataCol then
        v := MaxString;
      hd := True;
    end;

    if (col = FCross.Columns.Count - 1) and (row > 0) then // grand total column
    begin
      Assign(TfrMemoView(View), TfrMemoView(FReport.FindObject('GrandColumnTotalMemo' + Name)));
      If (not FFlag) and (row <= FCross.TopLeftSize.cy) then 
      begin
        If LastTotalCol.Cell[row-1] < col then 
        begin
          for j := row - 1 to FCross.TopLeftSize.cy do
            LastTotalCol.Cell[j] := Col; 
          View.dy := 0;
          for j := row to FCross.TopLeftSize.cy do 
            Inc(View.dy, FColumnHeights.Cell[j]);
        end else View.Visible := False;
      end;
    end
    else if row = FCross.Rows.Count - 1 then 
    begin
      Assign(TfrMemoView(View), TfrMemoView(FReport.FindObject('GrandRowTotalMemo' + Name)));
      if not FFlag then
      begin
        CurBand.dy := MaxGTHeight * FCross.CellItemsCount;
        if (Col = FCross.TopLeftSize.cx) and (View.dy = MaxCellHeight) then
        begin
          View.y  := View.y - i * (MaxCellHeight - MaxGTHeight);
          View.dy := MaxGTHeight;
        end else
        if Col < FCross.TopLeftSize.cx then
           View.dy := CurBand.dy else
           View.dy := MaxGTHeight;
      end;
    end
    else if FCross.IsTotalColumn[col] and (row > 0) then // "total" column
    begin
      if (View.FrameTyp and frftLeft) <> 0 then
      begin
        Assign(TfrMemoView(View), TfrMemoView(FReport.FindObject('ColumnTotalMemo' + Name)));
        If (not FFlag) and (row <= FCross.TopLeftSize.cy) then
        begin
          If LastTotalCol.Cell[row-1] < col then
          begin
            for j := row - 1 to FCross.TopLeftSize.cy do
              LastTotalCol.Cell[j] := Col;
            View.dy := 0;
            for j := row to FCross.TopLeftSize.cy do
              Inc(View.dy, FColumnHeights.Cell[j]);
          end else View.Visible := False;
        end;
      end;
    end
    else if FCross.IsTotalRow[row] then // "total" row
    begin
      if (col >= FCross.TopLeftSize.cx) or ((View.FrameTyp and frftTop) <> 0) then
      begin
        Assign(TfrMemoView(View), TfrMemoView(FReport.FindObject('RowTotalMemo' + Name)));
      end;
    end;

    if not hd then
    begin
      TfrMemoView(View).Alignment := al;
//      v1 := TfrMemoView(FReport.FindObject('CellMemo' + Name));
//      TfrMemoView(View).Format := v1.Format;
//      TfrMemoView(View).FormatStr := v1.FormatStr;
    end;

    if (col >= FCross.TopLeftSize.cx) and (row > FCross.TopLeftSize.cy) then // cross body
    begin
      s := '';
      v := FCross.CellByIndex[row, col, i];
      frVariables['CrossVariable'] := v;
      CurView := View;
      FReport.InternalOnGetValue('CrossVariable', s1);
      s := s1;
      If (i < FCross.CellItemsCount - 1) then View.FrameTyp := View.FrameTyp and (15 xor frftBottom);
      If (i > 0) then View.FrameTyp := View.FrameTyp and (15 xor frftTop);
    end else
    begin
      if v = Null then
        s := ''
      else
      begin
        frVariables['CrossVariable'] := v;
        CurView := View;
        FReport.InternalOnGetValue('CrossVariable', s);
      end;
    end;

    View.Prop['AutoWidth'] := False;
    View.Prop['WordWrap']  := True;

    View.Memo.Text := s;
  end;
  if Assigned(FSavedOnBeforePrint) then
    FSavedOnBeforePrint(Memo, View);
end;

procedure TfrCrossView.ReportBeginDoc;
var
  v: TfrView;
  i: Integer;
begin
  Visible := False;
  FSkip := False;
  if (Memo.Count < 4) or (Trim(Memo[0]) = '') or (Trim(Memo[1]) = '') or
     (Trim(Memo[2]) = '') or (Trim(Memo[3]) = '') then
  begin
    FSkip := True;
    if Assigned(FSavedOnBeginDoc) then
      FSavedOnBeginDoc;
    Exit;
  end;

  if FReport.FindObject('ColumnHeaderMemo' + Name) = nil then
    CreateObjects;

  {jkl}{!!!} // Пришлось исправить т.к. самый простой способ
  FCross := TfrCross.Create(CurReport.Dictionary.gsGetDataSet(CurReport.Dictionary.RealDataSetName[Memo[0]]),
{  FCross := TfrCross.Create(TfrTDataSet(
    frFindComponent(FReport.Owner, FReport.Dictionary.RealDatasetName[Memo[0]])),}
    Memo[1], Memo[2], Memo[3]);

  v := FReport.FindObject('ColumnTotalMemo' + Name);
  if (v <> nil) and (v.Memo.Count > 0) then
    FCross.ColumnTotalString := v.Memo[0];

  If FShowGrandTotal then 
  begin
    v := FReport.FindObject('GrandColumnTotalMemo' + Name);
    if (v <> nil) and (v.Memo.Count > 0) then
      FCross.ColumnGrandTotalString := v.Memo[0];
  end;

  v := FReport.FindObject('RowTotalMemo' + Name);
  if (v <> nil) and (v.Memo.Count > 0) then
    FCross.RowTotalString := v.Memo[0];

  If FShowGrandTotal then 
  begin
    v := FReport.FindObject('GrandRowTotalMemo' + Name);
    if (v <> nil) and (v.Memo.Count > 0) then
      FCross.RowGrandTotalString := v.Memo[0];
  end;

  FCross.HeaderString := ''; 
  for i := 1 to CharCount(';', Memo.Strings[2]) do
    FCross.HeaderString := FCross.HeaderString + '     ' + GetDictName(GetPureString(Memo.Strings[2], i));

  LongNames := TStringList.Create;
  FCross.DoDataCol := (CharCount(';', Memo[3]) > 1) and (FShowHeader);
  FCross.DataStr   := GetDataCellText; 

  FCross.Build;
  if FCross.Columns.Count = 0 then
  begin
    FCross.Free;
    FSkip := True;
    if Assigned(FSavedOnBeginDoc) then
      FSavedOnBeginDoc;
    Exit;
  end;

  FRowDS := TfrUserDataset.Create(FReport.Owner);
  FRowDS.Name := 'RowDS' + Name;
  FRowDS.RangeEnd := reCount;
  FRowDS.RangeEndCount := FCross.Rows.Count;

  FColumnDS := TfrUserDataset.Create(FReport.Owner);
  FColumnDS.Name := 'ColumnDS' + Name;
  FColumnDS.RangeEnd := reCount;
  FColumnDS.RangeEndCount := FCross.Columns.Count;

  MakeBands;
  if Assigned(FSavedOnBeginDoc) then
    FSavedOnBeginDoc;
end;

procedure TfrCrossView.ReportEndDoc;
begin
  if not FSkip then
  begin
    FCross.Free;
    FRowDS.Free;
    FColumnDS.Free;
    FColumnWidths.Free;
    FColumnHeights.Free;
    LastTotalCol.Free;
    LongNames.Free;
  end;
  if Assigned(FSavedOnEndDoc) then
    FSavedOnEndDoc;
end;
procedure TfrCrossView.P3Click(Sender: TObject);
begin
  frDesigner.BeforeChange;
  with Sender as TMenuItem do
  begin
    Checked := not Checked;
    if (Restrictions and frrfDontModify) = 0 then
      FShowHeader := Checked;
  end;
  frDesigner.AfterChange;
end;

function TfrCrossView.GetDataCellText: String;
function GoodString : String;
var List : TStringList;
    i : Integer;
    s, ss : String;
begin
  s := Memo[3];
  List := TStringList.Create;
  for i := 0 to CharCount(';', s) - 1 do
  begin
    ss := Copy(s, 1, Pos(';', s)-1);
    Delete(s, 1, Pos(';', s));
    List.Add(ss);
  end;
  Result := List.Text;
  List.Free;
end;
var List : TStringList;
    i : Integer;
    ss: String;
begin
  List := TStringList.Create;
  List.Text := GoodString;
  MaxString := '';
  for i := 0 to List.Count - 1 do
  begin
    ss := List[i];
    ss := CheckLongName(GetDictName(ss));
    if Length(ss) > Length(MaxString) then MaxString := ss;
    List[i] := ss;
  end;
  Result := List.Text;
  List.Free;
end;

procedure TfrCrossView.DictionaryEditor(Sender: TObject);
var i : Integer;
begin
  if FDictionary.Count = 0 then
  begin
    for i := 1 to CharCount(';', Memo[1]) do
      FDictionary.Add(GetPureString(Memo[1], i)+'=');
    for i := 1 to CharCount(';', Memo[2]) do
      FDictionary.Add(GetPureString(Memo[2], i)+'=');
    for i := 1 to CharCount(';', Memo[3]) do
      FDictionary.Add(GetString(Memo[3], i)+'=');
  end;
  DictionaryForm := TDictionaryForm.Create(Application);
  DictionaryForm.Memo1.Lines.Assign(FDictionary);
  DictionaryForm.ShowModal;
  if DictionaryForm.ModalResult = mrOk then
    FDictionary.Assign(DictionaryForm.Memo1.Lines);
  DictionaryForm.Free;
end;

function TfrCrossView.GetDictName(s: String): String;
begin
  Result := s;
  if FDictionary.Values[s] <> EmptyStr then Result := FDictionary.Values[s];
end;

function TfrCrossView.CheckLongName(s: String): String;
var p : PChar;
begin
  Result := s;
  if Length(s) > FMaxNameLen then
  begin
    if LongNames.Values[s] <> EmptyStr then Result := LongNames.Values[s] else
    begin
      GetMem(p, LongNames.Count + 2);
      FillChar(p^, LongNames.Count+1, '*');
      p[LongNames.Count+1] := #0;
      Result := StrPas(p);
      LongNames.Values[s] := Result;
      FreeMem(p, LongNames.Count + 1);
    end;
  end;
end;

function TfrCrossView.FormatedLongNames: String;
var i : Integer;
    s : String;
begin
  Result := '';
  for i := 0 to LongNames.Count -1 do
  begin
    s := LongNames.Strings[i];
    s := Copy(s, Pos('=', s) + 1, Length(s)) + ' - ' + Copy(s, 1, Pos('=', s)-1);
    Result := Result + s + #$D#$A;
  end;
  Delete(Result, Length(Result) - 1, 2);
end;

//------------------------------------------------------------------------------
{ TfrCrossForm }

procedure TfrCrossForm.Localize;
begin
  GroupBox1.Caption := frLoadStr(frRes + 750);
  GroupBox2.Caption := frLoadStr(frRes + 751);
  CheckBox1.Caption := frLoadStr(frRes + 752);
  Label1.Caption := frLoadStr(frRes + 753);
  Caption := frLoadStr(frRes + 754);
  Button1.Caption := frLoadStr(SOK);
  Button2.Caption := frLoadStr(SCancel);

  GrandTotalStr := frLoadStr(frRes + 2600);
  TotalStr := frLoadStr(frRes + 2601); 
  TotalOfStr := frLoadStr(frRes + 2602); 
  CellStr := frLoadStr(frRes + 2603); 
  HeaderStr := frLoadStr(frRes + 2604); 
end;

procedure TfrCrossForm.FillDatasetsLB;
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  DatasetsLB.Items.BeginUpdate;
  CurReport.Dictionary.GetDatasetList(DatasetsLB.Items);
  DatasetsLB.Items.EndUpdate;
  sl.Free;
end;

procedure TfrCrossForm.DatasetsLBClick(Sender: TObject);
var
  i: Integer;
  sl: TStringList;
begin
  if (DatasetsLB.ItemIndex >= 0) and (Integer(DatasetsLB.Items.Objects[DatasetsLB.ItemIndex]) = 1) then
  begin
    sl := TStringList.Create;
    CurReport.Dictionary.GetVariablesList(DatasetsLB.Items[DatasetsLB.ItemIndex], sl);
    FieldsLB.Items.Clear;
    for i := 0 to sl.Count - 1 do
      FieldsLB.Items.AddObject(sl[i], TObject(1));
    sl.Free;
  end
  else
    CurReport.Dictionary.GetFieldList(DatasetsLB.Items[DatasetsLB.ItemIndex],
      FieldsLB.Items)
end;

procedure TfrCrossForm.ListBox3Enter(Sender: TObject);
begin
  FListBox := TListBox(Sender);
end;

procedure TfrCrossForm.ClearSelection(Sender : TObject);
var
  i: Integer;
begin
  for i := 0 to GroupBox1.ControlCount - 1 do
    if (GroupBox1.Controls[i] <> Sender) and (GroupBox1.Controls[i] is TListBox) then
      (GroupBox1.Controls[i] as TListBox).ItemIndex := -1;
  CheckBox1.Enabled := Sender <> ListBox4;
  ComboBox2.Enabled := Sender = ListBox4;
end;

procedure TfrCrossForm.ListBox3Click(Sender: TObject);
var
  s : String;
begin
  if (FListBox <> nil) and (FListBox.ItemIndex <> -1) then
  begin
    s := FListBox.Items[FListBox.ItemIndex];
    FBusy := True;
    CheckBox1.Checked := Pos('+', s) <> 0;
    FBusy := False;
  end;
  ClearSelection(Sender);
end;

procedure TfrCrossForm.CheckBox1Click(Sender: TObject);
var
  i: Integer;
  s: String;
begin
  if FBusy then Exit;
  if (FListBox <> nil) and (FListBox.ItemIndex <> -1) then
  begin
    i := FListBox.ItemIndex;
    s := FListBox.Items[i];
    if Pos('+', s) <> 0 then
      s := Copy(s, 1, Length(s) - 1) else
      s := s + '+';
    FListBox.Items[i] := s;
    FListBox.ItemIndex := i;
  end;
  TDrawPanel(DrawPanel).Paint;
end;

procedure TfrCrossForm.ListBox4Click(Sender: TObject);
var
  s: String;
begin
  FBusy := True;
  if ListBox4.ItemIndex <> -1 then
  begin
    ComboBox2.Enabled := True;
    s := ListBox4.Items[ListBox4.ItemIndex];
    if Pos('+', s) = 0 then
      ComboBox2.ItemIndex := 0
    else
    begin
      s := AnsiLowerCase(Copy(s, Pos('+', s) + 1, 255));
      if (s = '') or (s = 'sum') then
        ComboBox2.ItemIndex := 1
      else if s = 'min' then
        ComboBox2.ItemIndex := 2
      else if s = 'max' then
        ComboBox2.ItemIndex := 3
      else if s = 'avg' then
        ComboBox2.ItemIndex := 4
      else if s = 'count' then
        ComboBox2.ItemIndex := 5
    end;
  end;
  FBusy := False;
  ClearSelection(Sender);
end;

procedure TfrCrossForm.ComboBox2Click(Sender: TObject);
var
  i: Integer;
  s: String;
begin
  if FBusy then Exit;
  if ListBox4.ItemIndex <> -1 then
  begin
    i := ListBox4.ItemIndex;
    s := PureName1(ListBox4.Items[i]);
    case ComboBox2.ItemIndex of
      0: ;
      1: s := s + '+';
      2: s := s + '+min';
      3: s := s + '+max';
      4: s := s + '+avg';
      5: s := s + '+count';
    end;
    ListBox4.Items[i] := s;
    ListBox4.ItemIndex := i;
  end;
end;

procedure TfrCrossForm.ListBox3DblClick(Sender: TObject);
begin
  CheckBox1.Checked := not CheckBox1.Checked;
end;

procedure TfrCrossForm.ListBox4DrawItem(Control: TWinControl;
  Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  s: String;
begin
  with TListBox(Control).Canvas do
  begin
    s := TListBox(Control).Items[Index];
    FillRect(ARect);
    if Pos('+', s) <> 0 then
    begin
      TextOut(ARect.Left + 1, ARect.Top, Copy(s, 1, Pos('+', s) - 1));
      s := Copy(s, Pos('+', s) + 1, 255);
      if s = '' then
        if Control = ListBox4 then
          s := 'sum' else
          s := 'total';
      TextOut(ARect.Right - TextWidth(s) - 2, ARect.Top, s);
    end
    else
      TextOut(ARect.Left + 1, ARect.Top, s);
  end;
end;

procedure TfrCrossForm.FieldsLBDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := TListBox(Source).Items.Count > 0;
end;

function GetLBIndex(LB : TListBox; s : String) : Integer;
var i : Integer;
begin
  Result := -1;
  for i := 0 to LB.Items.Count - 1 do
    If PureName1(Lb.Items[i]) = s then
    begin
      Result := i;
      Exit;
    end;
end;

procedure TfrCrossForm.FieldsLBDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  s: String;
  i: Integer;
  L4Exist: Boolean;
begin
  if (Source = Sender) and (Source <> FieldsLB) then
  begin
    i := TListBox(Source).ItemAtPos(Point(x, y), True);
    if i = -1 then
      i := TListBox(Source).Items.Count - 1;
    TListBox(Source).Items.Exchange(TListBox(Source).ItemIndex, i);
  end
  else if Source <> Sender then
  begin
    if TListBox(Source).ItemIndex = -1 then Exit;
    s := PureName1(TListBox(Source).Items[TListBox(Source).ItemIndex]);
    L4Exist := GetLBIndex(ListBox4, s) >= 0;
    if Source = FieldsLB then
      s := s + '+';
    if (not ((Source = ListBox4) and (Sender = FieldsLB))) and
       (not ((Source = FieldsLB) and (Sender <> ListBox4) and L4Exist)) then
         TListBox(Sender).Items.Add(s);
    i := GetLBIndex(FieldsLB, PureName1(s));
    if (Source = ListBox4) and (Sender <> FieldsLB) and (i <> -1) then
    begin
      FieldsLB.Items.Delete(i);
      repeat
        i := GetLBIndex(ListBox4, PureName1(s));
        if i <> -1 then ListBox4.Items.Delete(i);
      until i = -1;
    end;
    if (Source <> FieldsLB) and (Sender = ListBox4) then
      FieldsLB.Items.Add(s);
    if (not ((Source = FieldsLB) and (Sender = ListBox4))) and (not((Source = FieldsLB) and L4Exist)) then
    begin
      i := TListBox(Source).ItemIndex;
      if (i <> -1) and (Pos(PureName1(s), TListBox(Source).Items[i]) = 1) then
        TListBox(Source).Items.Delete(i);
    end;
  end;
  TDrawPanel(DrawPanel).Paint;
end;

procedure TfrCrossForm.FormShow(Sender: TObject);
var
  i: Integer;
  sl: TStringList;
  s: String;
begin
  sl := TStringList.Create;
  FillDatasetsLB;

  if Cross.Memo.Count >= 4 then
  begin
    i := DatasetsLB.Items.IndexOf(Cross.Memo[0]);
    if i <> -1 then
    begin
      DatasetsLB.ItemIndex := i;
      DatasetsLBClick(nil);

      frSetCommaText(Cross.Memo[1], sl);
      for i := 0 to sl.Count - 1 do
      begin
        s := PureName1(sl[i]);
        if FieldsLB.Items.IndexOf(s) <> -1 then
          FieldsLB.Items.Delete(FieldsLB.Items.IndexOf(s));
      end;
      ListBox2.Items.Assign(sl);

      frSetCommaText(Cross.Memo[2], sl);
      for i := 0 to sl.Count - 1 do
      begin
        s := PureName1(sl[i]);
        if FieldsLB.Items.IndexOf(s) <> -1 then
          FieldsLB.Items.Delete(FieldsLB.Items.IndexOf(s));
      end;
      ListBox3.Items.Assign(sl);

      frSetCommaText(Cross.Memo[3], sl);
      ListBox4.Items.Assign(sl);
    end;
  end
  else
  begin
    if DatasetsLB.Items.Count > 0 then
      DatasetsLB.ItemIndex := 0;
    DatasetsLBClick(nil);
    ListBox2.Clear;
    ListBox3.Clear;
    ListBox4.Clear;
  end;

  sl.Free;
end;

procedure TfrCrossForm.FormHide(Sender: TObject);
var
  i: Integer;
  s: String;
begin
  if ModalResult = mrOk then
  begin
    frDesigner.BeforeChange;
    Cross.Memo.Clear;
    Cross.Memo.Add(DatasetsLB.Items[DatasetsLB.ItemIndex]);

    s := '';
    for i := 0 to ListBox2.Items.Count - 1 do
      s := s + ListBox2.Items[i] + ';';
    Cross.Memo.Add(s);

    s := '';
    for i := 0 to ListBox3.Items.Count - 1 do
      s := s + ListBox3.Items[i] + ';';
    Cross.Memo.Add(s);

    s := '';
    for i := 0 to ListBox4.Items.Count - 1 do
      s := s + ListBox4.Items[i] + ';';
    Cross.Memo.Add(s);
  end;
end;

procedure TfrCrossForm.FormCreate(Sender: TObject);
begin
  Localize;
  DrawPanel := TDrawPanel.Create(Self);
  DrawPanel.Parent := Self;
  DrawPanel.Align := alBottom;
  DrawPanel.Height := ClientHeight - 244;
  DrawPanel.BevelOuter := bvNone;
  DrawPanel.BorderStyle := bsSingle;
end;

{ TDrawPanel }

procedure TDrawPanel.Draw(x, y, dx ,dy: Integer; s: String);
begin
  with Canvas do
  begin
    Pen.Color := clBlack;
    Rectangle(x, y, x + dx + 1, y + dy + 1);
    TextRect(Rect(x+1, y+1, x + dx-1, y + dy-1), x + 3, y + 3, s);
  end;
end;

procedure TDrawPanel.DrawColumnCells;
var
  i, StartX, CurX, CurY, CurDX, CurDY: Integer;
  s: String;
begin
  CurX := 10 + FRowFields.Count * DefDX;
  CurY := 10 + (FColumnFields.Count - 1) * DefDY;
  CurDX := DefDX; CurDY := DefDY;
  StartX := CurX;

  i := FColumnFields.Count - 1;

// create cell
  Canvas.Brush.Color := clWhite;
  Draw(CurX, CurY, CurDX, CurDY, PureName1(FColumnFields[i]));
  Dec(CurY, DefDY);
  Inc(CurDY, DefDY);
  Inc(CurX, DefDX);

  Dec(i);
  while i >= -1 do
  begin
// Header cell
    Canvas.Brush.Color := clWhite;
    if i <> -1 then
      Draw(StartX, CurY, CurDX, DefDY, PureName1(FColumnFields[i]));

// Total cell
    if (i = -1) or (Pos('+', FColumnFields[i]) <> 0) then
    begin
      Canvas.Brush.Color := $F5F5F5;
      if i <> -1 then
        s := TotalOfStr + PureName1(FColumnFields[i])
      else
      begin
        Inc(CurY, DefDY);
        Dec(CurDY, DefDY);
        Canvas.Brush.Color := clSilver;
        s := GrandTotalStr;
      end;
      LastX := CurX + DefDX;
      Draw(CurX, CurY, DefDX, CurDY, s);
      Inc(CurDX, DefDX);
      Inc(CurX, DefDX);
    end;
    Dec(CurY, DefDY);
    Inc(CurDY, DefDY);

    Dec(i);
  end;
end;

procedure TDrawPanel.DrawRowCells;
var
  i, StartY, CurX, CurY, CurDX, CurDY, DefDY: Integer;
begin
  RowTotals := 0;
  DefDY := Self.DefDY;
  CurX := 10 + (FRowFields.Count - 1) * DefDX;
  CurY := 10 + FColumnFields.Count * DefDY;
  StartY := CurY;
  DefDY := 18 * FCellFields.Count;
  CurDX := DefDX; CurDY := DefDY;

  i := FRowFields.Count - 1;

// create cell
  Canvas.Brush.Color := clWhite;
  Draw(CurX, CurY, CurDX, CurDY, PureName1(FRowFields[i]));
  Dec(CurX, DefDX);
  Inc(CurY, DefDY);
  Inc(CurDX, DefDX);

  Dec(i);
  while i >= 0 do
  begin
// Header cell
    Canvas.Brush.Color := clWhite;
    Draw(CurX, StartY, DefDX, CurDY, PureName1(FRowFields[i]));

// Total cell

    if Pos('+', FRowFields[i]) <> 0 then
    begin
      Canvas.Brush.Color := $F5F5F5;
      Draw(CurX, CurY, CurDX, DefDY, TotalOfStr + PureName1(FRowFields[i]));
      Inc(CurY, DefDY);
      Inc(CurDY, DefDY);
      Inc(RowTotals);
    end;

    Dec(CurX, DefDX);
    Inc(CurDX, DefDX);
    Dec(i);
  end;

// Grand total cell
  Canvas.Brush.Color := clSilver;
  LastY := CurY + DefDY;
  Draw(CurX + DefDX, CurY, CurDX - DefDX, DefDY, GrandTotalStr);
end;

procedure TDrawPanel.DrawCellField;
var
  i, CurX, CurY: Integer;
begin
  CurX := 10 + FRowFields.Count * DefDX;
  CurY := 10 + FColumnFields.Count * DefDY;
  Canvas.Brush.Color := clWhite;

  for i := 0 to FCellFields.Count - 1 do
  begin
    Draw(CurX, CurY, DefDX, DefDY, PureName1(FCellFields[i]));
    Inc(CurY, DefDY);
  end;
end;

procedure TDrawPanel.DrawBorderLines(pos : byte);
begin
  Canvas.Brush.Color := clWhite;
  Canvas.Pen.Style := psDashDot;
  if Pos = 0 then
    Draw(10, 10, FRowFields.Count * DefDX, FColumnFields.Count * DefDY, '') 
  else
  begin
    Canvas.MoveTo(10 + FRowFields.Count * DefDX, LastY);
    Canvas.LineTo(LastX, LastY);
    Canvas.MoveTo(LastX, 10 + FColumnFields.Count * DefDY);
    Canvas.LineTo(LastX, LastY);
  end;
  Canvas.Pen.Style := psSolid;
end;

procedure TDrawPanel.Paint;
begin
  Color := clWhite;
  inherited;
  FColumnFields := TfrCrossForm(Parent).ListBox3.Items;
  FRowFields := TfrCrossForm(Parent).ListBox2.Items;
  FCellFields := TfrCrossForm(Parent).ListBox4.Items;
  if (FColumnFields.Count < 1) or
     (FRowFields.Count < 1) or
     (FCellFields.Count < 1) then Exit;

  DefDx := 72; DefDy := 18;
  DrawBorderLines(0);
  DrawRowCells;
  DrawColumnCells;
  DrawCellField;
  DrawBorderLines(1);
end;


procedure TfrCrossForm.SpeedButton1Click(Sender: TObject);
var s : String;
begin
  s := ListBox2.Items.Text;
  ListBox2.Items.Text := ListBox3.Items.Text;
  ListBox3.Items.Text := s;
  DrawPanel.Invalidate;
end;

initialization
  frCrossForm := TfrCrossForm.Create(nil);
  frCrossLists := TfrCrossLists.Create;
  frRegisterObject(TfrCrossView, frCrossForm.Image1.Picture.Bitmap,
    frLoadStr(SInsertCrosstab));

finalization
  frCrossForm.Free;
  frCrossLists.Free;
  frUnRegisterObject(TfrCrossView);

end.

