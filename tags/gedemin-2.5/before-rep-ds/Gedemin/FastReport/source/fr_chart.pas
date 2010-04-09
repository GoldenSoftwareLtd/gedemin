
{******************************************}
{                                          }
{             FastReport v2.53             }
{           Chart Add-In Object            }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_Chart;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  FR_Class, FR_Ctrls, ExtCtrls, TeeProcs, TeEngine, Chart, Series, StdCtrls, 
  ComCtrls, Menus;

type
  TChartOptions = packed record
    ChartType: Byte;
    Dim3D, IsSingle, ShowLegend, ShowAxis, ShowMarks, Colored: Boolean;
    MarksStyle: Byte;
    Top10Num: Integer;
    Reserved: Array[0..35] of Byte;
  end;

  TfrChartObject = class(TComponent)  // fake component
  end;

  TfrChartView = class(TfrView)
  private
    FChart: TChart;
    FPicture: TMetafile;
    CurStr: Integer;
    LastLegend: String;
    function ShowChart: Boolean;
    procedure ChartEditor(Sender: TObject);
  public
    ChartOptions: TChartOptions;
    LegendObj, ValueObj, Top10Label: String;
    constructor Create; override;
    destructor Destroy; override;
    procedure Draw(Canvas: TCanvas); override;
    procedure StreamOut(Stream: TStream); override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure DefinePopupMenu(Popup: TPopupMenu); override;
    procedure DefineProperties; override;
    procedure OnHook(View: TfrView); override;
    procedure ShowEditor; override;
    procedure AssignChart(AChart: TCustomChart);
    property Chart: TChart read FChart;
  end;

  TfrChartForm = class(TForm)
    Image1: TImage;
    Page1: TPageControl;
    Tab1: TTabSheet;
    GroupBox1: TGroupBox;
    SB1: TfrSpeedButton;
    SB2: TfrSpeedButton;
    SB3: TfrSpeedButton;
    SB4: TfrSpeedButton;
    SB5: TfrSpeedButton;
    SB6: TfrSpeedButton;
    Tab2: TTabSheet;
    Button1: TButton;
    Button2: TButton;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    E1: TEdit;
    Label2: TLabel;
    E2: TEdit;
    GroupBox3: TGroupBox;
    CB1: TCheckBox;
    CB2: TCheckBox;
    CB3: TCheckBox;
    CB4: TCheckBox;
    CB6: TCheckBox;
    CB5: TCheckBox;
    Tab3: TTabSheet;
    GroupBox4: TGroupBox;
    RB1: TRadioButton;
    RB2: TRadioButton;
    RB3: TRadioButton;
    RB4: TRadioButton;
    RB5: TRadioButton;
    GroupBox5: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    E3: TEdit;
    E4: TEdit;
    Label5: TLabel;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
  end;


implementation

uses FR_Intrp, FR_Pars, FR_Utils, FR_Const;

{$R *.DFM}

type
  THackView = class(TfrView)
  end;

  TSeriesClass = class of TChartSeries;

var
  frChartForm: TfrChartForm;

const
  ChartTypes: Array[0..5] of TSeriesClass =
    (TLineSeries, TAreaSeries, TPointSeries,
     TBarSeries, THorizBarSeries, TPieSeries);

function ExtractFieldName(const Fields: string; var Pos: Integer): string;
var
  i: Integer;
begin
  i := Pos;
  while (i <= Length(Fields)) and (Fields[i] <> ';') do Inc(i);
  Result := Copy(Fields, Pos, i - Pos);
  if (i <= Length(Fields)) and (Fields[i] = ';') then Inc(i);
  Pos := i;
end;


constructor TfrChartView.Create;
begin
  inherited Create;
  FChart := TChart.Create(frChartForm);
  with FChart do
  begin
    Parent := frChartForm;
    Visible := False;
    BevelInner := bvNone;
    BevelOuter := bvNone;
  end;
  with ChartOptions do
  begin
    Dim3D := True;
    IsSingle := True;
    ShowLegend := True;
    ShowMarks := True;
    Colored := True;
  end;
  FPicture := TMetafile.Create;
  BaseName := 'Chart';
  Flags := Flags or flWantHook;
end;

destructor TfrChartView.Destroy;
begin
  if frChartForm <> nil then FChart.Free;
  FPicture.Free;
  inherited Destroy;
end;

procedure TfrChartView.DefineProperties;
begin
  inherited DefineProperties;
  AddProperty('Chart', [frdtHasEditor, frdtOneObject], ChartEditor);
end;

procedure TfrChartView.AssignChart(AChart: TCustomChart);
var
  tmpSeries: TChartSeries;
  tmpS: TChartSeriesClass;
  i: Integer;
begin
  FChart.RemoveAllSeries;
  FChart.Assign(AChart);
  for i := 0 to AChart.SeriesCount - 1 do
  begin
    tmpS := TChartSeriesClass(AChart.Series[i].ClassType);
    tmpSeries := tmpS.Create(FChart);
    tmpSeries.Assign(AChart.Series[i]); 
    tmpSeries.AssignValues(AChart.Series[i]);
    tmpSeries.Marks.Assign(AChart.Series[i].Marks);
{    tmpSeries.Marks.Visible := AChart.Series[i].Marks.Visible;
    tmpSeries.Marks.Style := AChart.Series[i].Marks.Style; }
    tmpSeries.SeriesColor := AChart.Series[i].SeriesColor;
    FChart.AddSeries(tmpSeries);
  end;
  Memo.Clear;
  ValueObj := ''; LegendObj := '';
  FPicture.Clear;
end;

function TfrChartView.ShowChart: Boolean;
var
  i, j, c1, c2: Integer;
  LegS, ValS, s: String;
  Ser: TChartSeries;
  EMF: TMetafile;

  procedure PaintChart;
  var
    c: TColor;
  begin
    with Canvas do
    begin
      c := FillColor;
      if c = clNone then
        c := clWhite;
      Chart.Color := c;
      EMF := Chart.TeeCreateMetafile(False, Rect(0, 0, Round(SaveDX), Round(SaveDY)));
      StretchDraw(DRect, EMF);
      EMF.Free;
    end;
  end;

  function Str2Float(s: String): Double;
  begin
    s := Trim(s);
    while (Length(s) > 0) and not (s[1] in ['-', '0'..'9']) do
      s := Copy(s, 2, 255);           // trim all non-digit chars at the begin
    while (Length(s) > 0) and not (s[Length(s)] in ['0'..'9']) do
      s := Copy(s, 1, Length(s) - 1); // trim all non-digit chars at the end
    while Pos(ThousandSeparator, s) <> 0 do
      Delete(s, Pos(ThousandSeparator, s), 1);
    Result := 0;
    try
      Result := StrToFloat(s);
    except;
    end;
  end;

  procedure SortValues(var LegS, ValS: String);
  var
    i, j: Integer;
    sl: TStringList;
    s: String;
    d: Double;
  begin
    sl := TStringList.Create;
    sl.Sorted := True;

    i := 1; j := 1;
    while i <= Length(LegS) do
      sl.Add(SysUtils.Format('%12.3f', [Str2Float(ExtractFieldName(ValS, j))]) + '=' +
             ExtractFieldName(LegS, i));

    LegS := ''; ValS := '';
    for i := 1 to ChartOptions.Top10Num do
    begin
      s := sl[sl.Count - i];
      ValS := ValS + Copy(s, 1, Pos('=', s) - 1) + ';';
      LegS := LegS + Copy(s, Pos('=', s) + 1, 255) + ';';
    end;

    i := sl.Count - ChartOptions.Top10Num - 1; d := 0;
    while i >= 0 do
    begin
      s := sl[i];
      d := d + Str2Float(Copy(s, 1, Pos('=', s) - 1));
      Dec(i);
    end;

    if Top10Label <> '' then
    begin
      LegS := LegS + Top10Label + ';';
      ValS := ValS + FloatToStr(d) + ';';
    end;
    sl.Free;
  end;


begin
  if (Memo.Count = 0) and (LegendObj = '') and (ValueObj = '') then
    if (FPicture.Width = 0) then
    begin
      PaintChart;
      Result := True;
      Exit;
    end
    else
    begin
      Canvas.StretchDraw(DRect, FPicture);
      Result := True;
      Exit;
    end;

  Result := False;
  Chart.RemoveAllSeries;
  with ChartOptions do
  begin
    Chart.Frame.Visible := False;
    Chart.LeftWall.Brush.Style := bsClear;
    Chart.BottomWall.Brush.Style := bsClear;

    Chart.View3D := Dim3D;
    Chart.Legend.Visible := ShowLegend;
{$IFNDEF Delphi2}
    Chart.Title.Font.Charset := frCharset;
    Chart.Legend.Font.Charset := frCharset;
    Chart.RightAxis.LabelsFont.Charset := frCharset;
    Chart.LeftAxis.LabelsFont.Charset := frCharset;
    Chart.TopAxis.LabelsFont.Charset := frCharset;
    Chart.BottomAxis.LabelsFont.Charset := frCharset;
{$ENDIF}
    Chart.AxisVisible := ShowAxis;
    Chart.View3DWalls := ChartType <> 5;
{$IFDEF Delphi4}
    Chart.BackWall.Brush.Style := bsClear;
    Chart.View3DOptions.Elevation := 315;
    Chart.View3DOptions.Rotation := 360;
    Chart.View3DOptions.Orthogonal := ChartType <> 5;
{$ENDIF}
  end;

  if Memo.Count > 0 then
    LegS := Memo[0] else
    LegS := '';
  if Memo.Count > 1 then
    ValS := Memo[1] else
    ValS := '';

  if (LegS = '') or (ValS = '') then Exit;
  if LegS[Length(LegS)] <> ';' then
    LegS := LegS + ';';
  if ValS[Length(ValS)] <> ';' then
    ValS := ValS + ';';

  if ChartOptions.IsSingle then
  begin
    Ser := ChartTypes[ChartOptions.ChartType].Create(Chart);
    Chart.AddSeries(Ser);
    if ChartOptions.Colored then
      Ser.ColorEachPoint := True;
    Ser.Marks.Visible := ChartOptions.ShowMarks;
    Ser.Marks.Style := TSeriesMarksStyle(ChartOptions.MarksStyle);
{$IFNDEF Delphi2}
    Ser.Marks.Font.Charset := frCharset;
{$ENDIF}

    c1 := 0;
    for i := 1 to Length(LegS) do
      if LegS[i] = ';' then Inc(c1);
    c2 := 0;
    for i := 1 to Length(ValS) do
      if ValS[i] = ';' then Inc(c2);
    if c1 <> c2 then Exit;

    if (ChartOptions.Top10Num > 0) and (c1 > ChartOptions.Top10Num) then
      SortValues(LegS, ValS);
    i := 1; j := 1;
    while i <= Length(LegS) do
    begin
      s := ExtractFieldName(ValS, j);
      Ser.Add(Str2Float(s), ExtractFieldName(LegS, i), clTeeColor);
    end;
  end
  else
  begin
    c1 := 0;
    for i := 1 to Length(LegS) do
      if LegS[i] = ';' then Inc(c1);
    if c1 <> Memo.Count - 1 then Exit;

    i := 1;
    c1 := 1;
    while i <= Length(LegS) do
    begin
      Ser := ChartTypes[ChartOptions.ChartType].Create(Chart);
      Chart.AddSeries(Ser);
      Ser.Title := ExtractFieldName(LegS, i);
      Ser.Marks.Visible := ChartOptions.ShowMarks;
      Ser.Marks.Style := TSeriesMarksStyle(ChartOptions.MarksStyle);
{$IFNDEF Delphi2}
      Ser.Marks.Font.Charset := frCharset;
{$ENDIF}
      ValS := Memo[c1];
      if ValS[Length(ValS)] <> ';' then
        ValS := ValS + ';';
      j := 1;
      while j <= Length(ValS) do
      begin
        s := ExtractFieldName(ValS, j);
        Ser.Add(Str2Float(s), '', clTeeColor);
      end;
      Inc(c1);
    end;
  end;

  PaintChart;
  Result := True;
end;

procedure TfrChartView.Draw(Canvas: TCanvas);
begin
  BeginDraw(Canvas);
  Memo1.Assign(Memo);
  CalcGaps;
  if not ShowChart then
    ShowBackground;
  ShowFrame;
  RestoreCoord;
end;

procedure TfrChartView.StreamOut(Stream: TStream);
begin
  inherited StreamOut(Stream);
  Memo.Text := '';
end;

procedure TfrChartView.LoadFromStream(Stream: TStream);
var
  b: Byte;
  s: TStream;
begin
  inherited LoadFromStream(Stream);
  FPicture.Clear;
  Stream.Read(b, 1);
  if b = 1 then
  begin
    s := TMemoryStream.Create;
    s.CopyFrom(Stream, frReadInteger(Stream));
    s.Position := 0;
    FPicture.LoadFromStream(s);
    s.Free;
  end
  else with Stream do
  begin
    Read(ChartOptions, SizeOf(ChartOptions));
    LegendObj := frReadString(Stream);
    ValueObj := frReadString(Stream);
    Top10Label := frReadString(Stream);
  end;
end;

procedure TfrChartView.SaveToStream(Stream: TStream);
var
  b: Byte;
  s: TStream;
  EMF: TMetafile;
begin
  inherited SaveToStream(Stream);
  if (Memo.Count = 0) and (LegendObj = '') and (ValueObj = '') then
  begin
    b := 1;
    Stream.Write(b, 1);

    s := TMemoryStream.Create;
    EMF := FChart.TeeCreateMetafile(False, Rect(0, 0, DX, DY));
    EMF.SaveToStream(s);
    EMF.Free;

    s.Position := 0;
    frWriteInteger(Stream, s.Size);
    Stream.CopyFrom(s, 0);
    s.Free;
  end
  else with Stream do
  begin
    b := 0; // internal chart version
    Write(b, 1);
    Write(ChartOptions, SizeOf(ChartOptions));
    frWriteString(Stream, LegendObj);
    frWriteString(Stream, ValueObj);
    frWriteString(Stream, Top10Label);
  end;
end;

procedure TfrChartView.DefinePopupMenu(Popup: TPopupMenu);
begin
// no specific items in popup menu
end;

procedure TfrChartView.OnHook(View: TfrView);
var
  i: Integer;
  s: String;
begin
  if (ValueObj <> '') and (LegendObj <> '') and (Memo.Count < 2) then
  begin
    Memo.Clear;
    Memo.Add('');
    Memo.Add('');
  end;
  i := -1;
  if AnsiCompareText(View.Name, LegendObj) = 0 then
  begin
    i := 0;
    Inc(CurStr);
  end
  else if AnsiCompareText(View.Name, ValueObj) = 0 then
    i := CurStr;
  if ChartOptions.IsSingle then
    CurStr := 1;

  if i >= 0 then
  begin
    if Memo.Count <= i then
      while Memo.Count <= i do
        Memo.Add('');
    if THackView(View).Memo1.Count > 0 then
    begin
      s := THackView(View).Memo1[0];
//      if LastLegend <> s then
        Memo[i] := Memo[i] + s + ';';
      LastLegend := s;
    end;
  end;
end;

procedure TfrChartView.ShowEditor;

  procedure SetButton(b: Array of TfrSpeedButton; n: Integer);
  begin
    b[n].Down := True;
  end;

  function GetButton(b: Array of TfrSpeedButton): Integer;
  var
    i: Integer;
  begin
    Result := 0;
    for i := 0 to High(b) do
      if b[i].Down then
        Result := i;
  end;

  procedure SetRButton(b: Array of TRadioButton; n: Integer);
  begin
    b[n].Checked := True;
  end;

  function GetRButton(b: Array of TRadioButton): Integer;
  var
    i: Integer;
  begin
    Result := 0;
    for i := 0 to High(b) do
      if b[i].Checked then
        Result := i;
  end;

begin
  with frChartForm do
  begin
    Page1.ActivePage := Tab1;
    with ChartOptions do
    begin
      SetButton([SB1, SB2, SB3, SB4, SB5, SB6], ChartType);
      SetRButton([RB1, RB2, RB3, RB4, RB5], MarksStyle);
      CB1.Checked := Dim3D;
      CB2.Checked := IsSingle;
      CB3.Checked := ShowLegend;
      CB4.Checked := ShowAxis;
      CB5.Checked := ShowMarks;
      CB6.Checked := Colored;
      E1.Text := LegendObj;
      E2.Text := ValueObj;
      E3.Text := IntToStr(Top10Num);
      E4.Text := Top10Label;
      if ShowModal = mrOk then
      begin
        frDesigner.BeforeChange;
        ChartType := GetButton([SB1, SB2, SB3, SB4, SB5, SB6]);
        MarksStyle := GetRButton([RB1, RB2, RB3, RB4, RB5]);
        Dim3D := CB1.Checked;
        IsSingle := CB2.Checked;
        ShowLegend := CB3.Checked;
        ShowAxis := CB4.Checked;
        ShowMarks := CB5.Checked;
        Colored := CB6.Checked;
        LegendObj := E1.Text;
        ValueObj := E2.Text;
        Top10Num := StrToInt(E3.Text);
        Top10Label := E4.Text;
      end;
    end;
  end;
end;

procedure TfrChartView.ChartEditor(Sender: TObject);
begin
  ShowEditor;
end;

{------------------------------------------------------------------------}
procedure TfrChartForm.Localize;
begin
  Caption := frLoadStr(frRes + 590);
  Tab1.Caption := frLoadStr(frRes + 591);
  Tab2.Caption := frLoadStr(frRes + 592);
  Tab3.Caption := frLoadStr(frRes + 604);
  GroupBox1.Caption := frLoadStr(frRes + 593);
  GroupBox2.Caption := frLoadStr(frRes + 594);
  GroupBox3.Caption := frLoadStr(frRes + 595);
  GroupBox4.Caption := frLoadStr(frRes + 605);
  GroupBox5.Caption := frLoadStr(frRes + 611);
  CB1.Caption := frLoadStr(frRes + 596);
  CB2.Caption := frLoadStr(frRes + 597);
  CB3.Caption := frLoadStr(frRes + 598);
  CB4.Caption := frLoadStr(frRes + 599);
  CB5.Caption := frLoadStr(frRes + 600);
  CB6.Caption := frLoadStr(frRes + 601);
  RB1.Caption := frLoadStr(frRes + 606);
  RB2.Caption := frLoadStr(frRes + 607);
  RB3.Caption := frLoadStr(frRes + 608);
  RB4.Caption := frLoadStr(frRes + 609);
  RB5.Caption := frLoadStr(frRes + 610);
  Label1.Caption := frLoadStr(frRes + 602);
  Label2.Caption := frLoadStr(frRes + 603);
  Label3.Caption := frLoadStr(frRes + 612);
  Label4.Caption := frLoadStr(frRes + 613);
  Label5.Caption := frLoadStr(frRes + 614);
  Button1.Caption := frLoadStr(SOk);
  Button2.Caption := frLoadStr(SCancel);
end;

procedure TfrChartForm.FormShow(Sender: TObject);
begin
  Localize;
end;

initialization
  frChartForm := TfrChartForm.Create(nil);
  frRegisterObject(TfrChartView, frChartForm.Image1.Picture.Bitmap,
    IntToStr(SInsChart));

finalization
  frChartForm.Free;
  frChartForm := nil;

end.

