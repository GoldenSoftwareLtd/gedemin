
{******************************************}
{                                          }
{             FastReport v2.4              }
{              Cross object                }
{                                          }
{ Copyright (c) 1998-2000 by Tzyganenko A. }
{                                          }
{******************************************}

unit FR_Cross;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Menus, FR_Class, FR_Cross1, FR_DSet, ExtCtrls
{$IFDEF Delphi6}
, Variants
{$ENDIF};


type
  TfrCrossObject = class(TComponent)  // fake component
  end;

  TfrCrossView = class(TfrView)
  private
    FCross: TfrCross;
    FColumnWidths: Variant;
    FColumnHeights: Variant;
    FFlag: Boolean;
    FSkip: Boolean;
    FRowDS: TfrUserDataset;
    FColumnDS: TfrUserDataset;
    FRepeatCaptions: Boolean;
    FShowHeader: Boolean;
    FInternalFrame: Boolean;
    FSavedOnBeginDoc: TBeginDocEvent;
    FSavedOnBeforePrint: TEnterRectEvent;
    FSavedOnPrintColumn: TPrintColumnEvent;
    FSavedOnEndDoc: TEndDocEvent;
    FReport: TfrReport;
    procedure CreateObjects;
    procedure CalcWidths;
    procedure MakeBands;
    procedure ReportPrintColumn(ColNo: Integer; var Width: Integer);
    procedure ReportBeforePrint(Memo: TStringList; View: TfrView);
    procedure ReportEndDoc;
    procedure ReportBeginDoc;
    procedure P1Click(Sender: TObject);
    procedure P2Click(Sender: TObject);
  protected
    procedure SetPropValue(Index: String; Value: Variant); override;
    function GetPropValue(Index: String): Variant; override;
  public
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


implementation

{$R *.DFM}

uses FR_Const, FR_DBRel, FR_Utils;

type
  TDrawPanel = class(TPanel)
  private
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

var
  frCrossForm: TfrCrossForm;
  frCrossList: TfrCrossList;


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
  frCrossList.Add(Self);
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
  frCrossList.Delete(Self);
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
    Result.dy := 18;
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

  OneObject('ColumnHeaderMemo', 'Header');

  v := OneObject('ColumnTotalMemo', 'Total');
  v.FillColor := $F5F5F5;

  v := OneObject('GrandColumnTotalMemo', 'Grand total');
  v.FillColor := clSilver;

  OneObject('RowHeaderMemo', 'Header');

  v := OneObject('CellMemo', 'Cell');
  v.Alignment := frtaRight;
  v.Font.Style := [];

  v := OneObject('RowTotalMemo', 'Total');
  v.FillColor := $F5F5F5;

  v := OneObject('GrandRowTotalMemo', 'Grand total');
  v.FillColor := clSilver;
end;

procedure TfrCrossView.DefineProperties;
begin
  inherited DefineProperties;
  AddProperty('InternalFrame', [frdtBoolean], nil);
  AddProperty('RepeatCaptions', [frdtBoolean], nil);
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
end;

procedure TfrCrossView.SaveToStream(Stream: TStream);
begin
  inherited SaveToStream(Stream);
  frWriteBoolean(Stream, FInternalFrame);
  frWriteBoolean(Stream, FRepeatCaptions);
  frWriteBoolean(Stream, FShowHeader);
end;

procedure TfrCrossView.DefinePopupMenu(Popup: TPopupMenu);
var
  m: TMenuItem;
begin
  m := TMenuItem.Create(Popup);
  m.Caption := 'Repeat captions';//LoadStr(SRepeatHeader);
  m.OnClick := P1Click;
  m.Checked := FRepeatCaptions;
  Popup.Items.Add(m);

  m := TMenuItem.Create(Popup);
  m.Caption := 'Internal frame';//LoadStr(SRepeatHeader);
  m.OnClick := P2Click;
  m.Checked := FInternalFrame;
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
  i, w, maxw, h, maxh: Integer;
  v: TfrView;
  b: TBitmap;
  m: TStringList;
begin
  FFlag := True;
  FColumnWidths := VarArrayCreate([0, FCross.Columns.Count + 10], varInteger);
  FColumnHeights := VarArrayCreate([0, FCross.TopLeftSize.cy], varInteger);
  v := FReport.FindObject('CrossMemo' + Name);
  m := TStringList.Create;
  b := TBitmap.Create;
  THackMemoView(v).Canvas := b.Canvas;

  FColumnDS.First;
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

    FColumnWidths[FColumnDS.RecNo] := maxw;
    FColumnDS.Next;
  end;
  FColumnWidths[FCross.Columns.Count] := 0;

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
      FColumnHeights[i] := maxh else
      FColumnHeights[i] := v.dy;
    FRowDS.Next;
  end;

  THackMemoView(v).DrawMode := drAll;
  m.Free;
  b.Free;
  FFlag := False;
end;

procedure TfrCrossView.MakeBands;
var
  i, d: Integer;
  ch1, ch2, cd1, cd2: TfrBandView;
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
  ch1.SetBounds(0, 400, 0, 18);
  if FRepeatCaptions then
    ch1.Prop['RepeatHeader'] := True;
  p.Objects.Add(ch1);

  cd1 := TfrBandView.Create; // master data
  cd1.BandType := btMasterData;
  cd1.Name := 'CrossData1' + Name;
  cd1.SetBounds(0, 500, 0, 18);
  cd1.DataSet := 'RowDS' + Name;
  cd1.Prop['Stretched'] := True;
  p.Objects.Add(cd1);

  ch2 := TfrBandView.Create; // cross header
  ch2.BandType := btCrossHeader;
  ch2.Name := 'CrossHeader2' + Name;
  ch2.SetBounds(p.LeftMargin, 0, 60, 18);
  if FRepeatCaptions then
    ch2.Prop['RepeatHeader'] := True;
  p.Objects.Add(ch2);

  cd2 := TfrBandView.Create; // cross data
  cd2.BandType := btCrossData;
  cd2.Name := 'CrossData2' + Name;
  cd2.DataSet := 'CrossHeader1' + Name + '=ColumnDS' + Name + ';CrossData1' + Name + '=ColumnDS' + Name + ';';
  cd2.SetBounds(500, 0, 60, 18);
  p.Objects.Add(cd2);

  v := TfrMemoView.Create;
  v.Name := 'CrossMemo' + Name;
  v.SetBounds(cd2.x, cd1.y, cd2.dx, cd1.dy);
  p.Objects.Add(v);

  CalcWidths;

  ch2.dx := 0;
  d := ch2.x;
  for i := 0 to FCross.TopLeftSize.cx - 1 do
  begin
    v := TfrMemoView.Create;
    v.SetBounds(d, cd1.y, FColumnWidths[i], cd1.dy);
    v.Name := 'CrossMemo' + IntToStr(i) + Name;
    p.Objects.Add(v);
    ch2.dx := ch2.dx + FColumnWidths[i];
    d := d + FColumnWidths[i];
  end;

  ch1.dy := 0;
  d := ch1.y;
  for i := 0 to FCross.TopLeftSize.cy - 1 do
  begin
    v := TfrMemoView.Create;
    v.SetBounds(cd2.x, d, cd2.dx, FColumnHeights[i]);
    v.Name := 'CrossMemo_' + IntToStr(i) + Name;
    p.Objects.Add(v);
    ch1.dy := ch1.dy + FColumnHeights[i];
    d := d + FColumnHeights[i];
  end;
end;

procedure TfrCrossView.ReportPrintColumn(ColNo: Integer; var Width: Integer);
var
  i: Integer;
begin
  if not FSkip and (Pos(Name, CurView.Name) <> 0) then
  begin
    Width := FColumnWidths[ColNo - 1 + FCross.TopLeftSize.cx];
    FReport.FindObject('CrossMemo' + Name).dx := Width;
    for i := 0 to FCross.TopLeftSize.cy - 1 do
      FReport.FindObject('CrossMemo_' + IntToStr(i) + Name).dx := Width;
  end;
  if Assigned(FSavedOnPrintColumn) then
    FSavedOnPrintColumn(ColNo, Width);
end;

procedure TfrCrossView.ReportBeforePrint(Memo: TStringList; View: TfrView);
var
  v: Variant;
  s, s1: String;
  i, row, col: Integer;
  b, hd: Boolean;
  al: Integer;
  v1: TfrMemoView;

  procedure Assign(m1, m2: TfrMemoView);
  begin
    m1.Flags := m2.Flags;
    m1.FrameWidth := m2.FrameWidth;
    m1.FrameColor := m2.FrameColor;
    m1.FrameStyle := m2.FrameStyle;
    m1.FillColor := m2.FillColor;
    m1.Format := m2.Format;
    m1.FormatStr := m2.FormatStr;
    m1.gapx := m2.gapx;
    m1.gapy := m2.gapy;
    m1.Alignment := m2.Alignment;
    m1.Highlight := m2.Highlight;
    if FCross.CellItemsCount = 1 then
      m1.HighlightStr := frParser.Str2OPZ(m2.HighlightStr) else
      m1.HighlightStr := '';
    m1.LineSpacing := m2.LineSpacing;
    m1.CharacterSpacing := m2.CharacterSpacing;
    m1.Font := m2.Font;
  end;

begin
  if not FSkip and
    (Pos('CrossMemo', View.Name) = 1) and (Pos(Name, View.Name) <> 0) then
  begin
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
      if View.Name <> 'CrossMemo' + Name then
      begin
        s := Copy(View.Name, 1, Pos(Name, View.Name) - 1);
        if s[10] = '_' then
        begin
          row := StrToInt(Copy(s, 11, 255));
          if not FShowHeader then
            Inc(row);
        end
        else
          col := StrToInt(Copy(s, 10, 255));
      end;
    end;
    if not FShowHeader and (row = 0) then
      Inc(row);

    Assign(TfrMemoView(View), TfrMemoView(FReport.FindObject('CellMemo' + Name)));
    al := TfrMemoView(View).Alignment;

    if FInternalFrame then
      View.FrameTyp := 15 else
      View.FrameTyp := frftLeft + frftRight;

    if (row = FCross.TopLeftSize.cy + 1) and (col >= FCross.TopLeftSize.cx) then
      if View.FrameTyp = frftLeft + frftRight then
         Inc(View.FrameTyp, frftTop);

    v := FCross.CellByIndex[row, col, -1];
    if v <> Null then
      View.FrameTyp := v;
    if row = FCross.Rows.Count - 2 then
      View.FrameTyp := View.FrameTyp or frftBottom;

    hd := False;
    if (row <= FCross.TopLeftSize.cy) and (col >= FCross.TopLeftSize.cx) then // column header
    begin
      Assign(TfrMemoView(View), TfrMemoView(FReport.FindObject('ColumnHeaderMemo' + Name)));
      hd := True;
    end
    else if (col < FCross.TopLeftSize.cx) and (row > FCross.TopLeftSize.cy) then // row header
    begin
      Assign(TfrMemoView(View), TfrMemoView(FReport.FindObject('RowHeaderMemo' + Name)));
      hd := True;
    end;

    if (col = FCross.Columns.Count - 1) and (row > 0) then // grand total column
      Assign(TfrMemoView(View), TfrMemoView(FReport.FindObject('GrandColumnTotalMemo' + Name)))
    else if row = FCross.Rows.Count - 1 then // grand total row
      Assign(TfrMemoView(View), TfrMemoView(FReport.FindObject('GrandRowTotalMemo' + Name)))
    else if FCross.IsTotalColumn[col] and (row > 0) then // "total" column
    begin
      if (View.FrameTyp and frftLeft) <> 0 then
        Assign(TfrMemoView(View), TfrMemoView(FReport.FindObject('ColumnTotalMemo' + Name)));
    end
    else if FCross.IsTotalRow[row] then // "total" row
    begin
      if (col >= FCross.TopLeftSize.cx) or ((View.FrameTyp and frftTop) <> 0) then
        Assign(TfrMemoView(View), TfrMemoView(FReport.FindObject('RowTotalMemo' + Name)));
    end;

    if not hd then
    begin
      TfrMemoView(View).Alignment := al;
      v1 := TfrMemoView(FReport.FindObject('CellMemo' + Name));
      TfrMemoView(View).Format := v1.Format;
      TfrMemoView(View).FormatStr := v1.FormatStr;
    end;

    if (row <= FCross.TopLeftSize.cy) and (col < FCross.TopLeftSize.cx) then
      View.FillColor := clNone;

    if (col >= FCross.TopLeftSize.cx) and (row > FCross.TopLeftSize.cy) then // cross body
    begin
      s := '';
      for i := 0 to FCross.CellItemsCount - 1 do
      begin
        v := FCross.CellByIndex[row, col, i];
        frVariables['CrossVariable'] := v;
        CurView := View;
        FReport.InternalOnGetValue('CrossVariable', s1);
        s := s + s1 + #13#10;
      end;
    end
    else
    begin
      v := FCross.CellByIndex[row, col, 0];
      if v = Null then
        s := ''
      else
      begin
        frVariables['CrossVariable'] := v;
        CurView := View;
        FReport.InternalOnGetValue('CrossVariable', s);
      end;
    end;

    b := (row = 0) and (col = FCross.TopLeftSize.cx);
    View.Prop['AutoWidth'] := b;
    View.Prop['WordWrap'] := not b;

    View.Memo.Text := s;
  end;
  if Assigned(FSavedOnBeforePrint) then
    FSavedOnBeforePrint(Memo, View);
end;

procedure TfrCrossView.ReportBeginDoc;
var
  v: TfrView;
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

  {jkl}{!!!} // ѕришлось исправить т.к. самый простой способ
  FCross := TfrCross.Create(CurReport.Dictionary.gsGetDataSet(CurReport.Dictionary.RealDataSetName[Memo[0]]),
{  FCross := TfrCross.Create(TfrTDataSet(
    frFindComponent(FReport.Owner, FReport.Dictionary.RealDatasetName[Memo[0]])),}
    Memo[1], Memo[2], Memo[3]);

  v := FReport.FindObject('ColumnTotalMemo' + Name);
  if (v <> nil) and (v.Memo.Count > 0) then
    FCross.ColumnTotalString := v.Memo[0];

  v := FReport.FindObject('GrandColumnTotalMemo' + Name);
  if (v <> nil) and (v.Memo.Count > 0) then
    FCross.ColumnGrandTotalString := v.Memo[0];

  v := FReport.FindObject('RowTotalMemo' + Name);
  if (v <> nil) and (v.Memo.Count > 0) then
    FCross.RowTotalString := v.Memo[0];

  v := FReport.FindObject('GrandRowTotalMemo' + Name);
  if (v <> nil) and (v.Memo.Count > 0) then
    FCross.RowGrandTotalString := v.Memo[0];

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
    VarClear(FColumnWidths);
    VarClear(FColumnHeights);
  end;
  if Assigned(FSavedOnEndDoc) then
    FSavedOnEndDoc;
end;

//------------------------------------------------------------------------------

procedure TfrCrossForm.Localize;
begin
  GroupBox1.Caption := frLoadStr(frRes + 750);
  GroupBox2.Caption := frLoadStr(frRes + 751);
  CheckBox1.Caption := frLoadStr(frRes + 752);
  Label1.Caption := frLoadStr(frRes + 753);
  Caption := frLoadStr(frRes + 754);
  Button1.Caption := frLoadStr(SOK);
  Button2.Caption := frLoadStr(SCancel);
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
  if Integer(DatasetsLB.Items.Objects[DatasetsLB.ItemIndex]) = 1 then
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
        s := 'Total of ' + PureName1(FColumnFields[i])
      else
      begin
        Inc(CurY, DefDY);
        Dec(CurDY, DefDY);
        Canvas.Brush.Color := clSilver;
        s := 'Grand total';
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
      Draw(CurX, CurY, CurDX, DefDY, 'Total of ' + PureName1(FRowFields[i]));
      Inc(CurY, DefDY);
      Inc(CurDY, DefDY);
    end;

    Dec(CurX, DefDX);
    Inc(CurDX, DefDX);
    Dec(i);
  end;

// Grand total cell
  Canvas.Brush.Color := clSilver;
  LastY := CurY + DefDY;
  Draw(CurX + DefDX, CurY, CurDX - DefDX, DefDY, 'Grand total');
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


initialization
  frCrossForm := TfrCrossForm.Create(nil);
  frCrossList := TfrCrossList.Create;
  frRegisterObject(TfrCrossView, frCrossForm.Image1.Picture.Bitmap,
    frLoadStr(SInsertCrosstab));

finalization
  frCrossForm.Free;
  frCrossList.Free;
  frUnRegisterObject(TfrCrossView);

end.