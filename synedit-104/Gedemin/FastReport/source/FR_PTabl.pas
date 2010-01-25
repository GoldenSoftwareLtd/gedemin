
{******************************************}
{                                          }
{               FastReport v2.5            }
{            Print table component         }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}
{ 2002/04/28 Marco Menardi TfrPrintGrid    }
{  for IBO, TfrPrintGrid FitWidth and      }
{  AutoWidth, removed use of DB.PAS for    }
{  IBO compilation                         }
{******************************************}


unit FR_PTabl;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
   Printers, FR_DSet, FR_DBSet
{$IFDEF IBO}
, IB_Components
, IB_Grid
, IB_Parse
{$ELSE}
, DB
, DBGrids
{$ENDIF}
, FR_Class, FR_View;

type
  TfrShrinkOption = (frsoProportional, frsoShrinkOnly);
  TfrShrinkOptions = set of TfrShrinkOption;
  TfrAggregateType = (frAggNone, frAggSum, frAggAvg, frAggCount, frAggMin, frAggMax);

  TfrField = record
{$IFDEF IBO}
    Field: TIB_Column;
{$ELSE}
    Field: TField;
{$ENDIF}
    Value: Double;
    AggregateType: TfrAggregateType;
  end;

  TfrPrintColumnEvent = procedure(ColumnNo: Integer; var Width: Integer) of object;

  TfrDataSection = (frOther, frHeader, frData, frFooter, frTitle, frSummary, frPageHeader, frPageFooter);

{$IFDEF IBO}
  TfrPrintDataEvent = procedure(Field: TIB_Column; Memo: TStringList; View: TfrView; Section: TfrDataSection) of object;
{$ELSE}
  TfrPrintDataEvent = procedure(Field: TField; Memo: TStringList; View: TfrView; Section: TfrDataSection) of object;
{$ENDIF}

  TfrPrintOption = (frpoHeader, frpoHeaderOnEveryPage, frpoFooter);
  TfrPrintOptions = set of TfrPrintOption;

  TfrFrameLine = (frLeft, frTop, frRight, frBottom);
  TfrFrameLines = set of TfrFrameLine;

  TfrAutoOrientation = class(TPersistent)
  private
    FEnabled: boolean;
    FResizePercent: integer;
    procedure SetResizePercent(const Value: integer);
  public
    constructor Create; virtual;
    procedure Assign(Source: TPersistent); override;
  published
    property Enabled: boolean read FEnabled write FEnabled;
    property ResizePercent: integer read FResizePercent write SetResizePercent;
  end;

  TfrWidthsArray = Array[0..255] of Word;
  TfrCustomWidthsEvent = procedure(var Widths: TfrWidthsArray; DataColumns, PageActiveWidth: integer) of object;

  TfrPrintRowEvent = procedure(var IsPrint :Boolean) of object; // Add Stalker

  TfrFitWidth = class(TPersistent)
  private
    FShrinkOptions: TfrShrinkOptions;
    FApplyBeforeOnCustomize: boolean;
    FEnabled: Boolean;
    FResizePercent: integer;
    FFields: string;
    procedure SetApplyBeforeOnCustomize(const Value: boolean);
    procedure SetEnabled(const Value: Boolean);
    procedure SetFields(const Value: string);
    procedure SetResizePercent(const Value: integer);
  public
    constructor Create; virtual;
    procedure Assign(Source: TPersistent); override;
  published
    property Enabled: Boolean read FEnabled write SetEnabled;
    property Fields: string read FFields write SetFields;
    property ShrinkOptions: TfrShrinkOptions read FShrinkOptions write FShrinkOptions;

    property ResizePercent: integer read FResizePercent write SetResizePercent;
    property ApplyBeforeOnCustomize: boolean read FApplyBeforeOnCustomize write SetApplyBeforeOnCustomize;
  end;

  TfrPageMargins = class(TPersistent)
  private
    FLeft: Integer;
    FTop: Integer;
    FRight: Integer;
    FBottom: Integer;
  public
    constructor Create; virtual;
    procedure Assign(Source: TPersistent); override;
  published
    property Left: Integer read FLeft write FLeft;
    property Top: Integer read FTop write FTop;
    property Right: Integer read FRight write FRight;
    property Bottom: Integer read FBottom write FBottom;
  end;

  TfrSectionParams = class(TPersistent)
  private
    FFont: TFont;
    FColor: TColor;
    FFrame: TfrFrameLines;
    FFrameWidth: Integer;
    procedure SetFont(Value: TFont);
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function GetFrameTyp: Integer;
  published
    property Font: TFont read FFont write SetFont;
    property Color: TColor read FColor write FColor;
    property Frame: TfrFrameLines read FFrame write FFrame;
    property FrameWidth: Integer read FFrameWidth write FFrameWidth;
  end;

  TfrAdvSectionParams = class(TfrSectionParams)
  private
    FAlign: TAlignment;
    FText: String;
  public
    constructor Create; override;
    procedure Assign(Source: TPersistent); override;
    function GetAlign: Integer;
  published
    property Align: TAlignment read FAlign write FAlign default taCenter;
    property Text: String read FText write FText;
  end;

  TfrCustomPrintDataSet = class(TComponent)
  private
    FAutoWidth: Boolean;
    FHasAggregates: Boolean;
    FOnFirst, FOnNext, FOnPrior: TNotifyEvent;
    FOnCheckEOF: TCheckEOFEvent;
    FWidths: TfrWidthsArray;
    FCustomizeWidths: TfrCustomWidthsEvent;
    FpgSize: Integer;
    FpgWidth: Integer;
    FpgHeight: Integer;
    FPageMargins: TfrPageMargins;
    FOrientation: TPrinterOrientation;
    FTitle, FPageHeader, FPageFooter, FSummary: TfrAdvSectionParams;
    FHeader, FBody: TfrSectionParams;
    FWidth: Integer;
    FReport: TfrReport;
    FPreview: TfrPreview;
    FReportDataSet: TfrDBDataSet;
    FColumnDataSet: TfrUserDataSet;
    FOnPrintColumn: TfrPrintColumnEvent;
    FOnPrintData: TfrPrintDataEvent;
    FOnBeginDoc: TBeginDocEvent;
    FOnEndDoc: TEndDocEvent;
    FOnBeginPage: TBeginPageEvent;
    FOnEndPage: TEndPageEvent;
    FFooter: TfrSectionParams;
    FPrintOptions: TfrPrintOptions;
    FOnPrintRow  :TfrPrintRowEvent;        // Add Stalker
    FFitWidth: TfrFitWidth;
    FAutoOrientation: TfrAutoOrientation;
    FReportBefore: TfrReport;
    FReportAfter: TfrReport;
    FDoublePass : Boolean;
    FPreviewButtons : TfrPreviewButtons;
    procedure OnEnterRect(Memo: TStringList; View: TfrView); virtual;
    procedure OnPrintColumn_(ColNo: Integer; var Width: Integer); virtual;
    procedure OnUserFunction(const Name: String; p1, p2,  p3: Variant; var Val: Variant); virtual;
    function GetFieldCount: Integer; virtual;
    function RealColumnIndex(Index: Integer): Integer;
    procedure SetPageMargins(Value: TfrPageMargins);
    procedure SetTitle(Value: TfrAdvSectionParams);
    procedure SetPageHeader(Value: TfrAdvSectionParams);
    procedure SetPageFooter(Value: TfrAdvSectionParams);
    procedure SetHeader(Value: TfrSectionParams);
    procedure SetBody(Value: TfrSectionParams);
    procedure SetFooter(const Value: TfrSectionParams);
    function GetColWidths(Index: Integer): word;
    procedure SetColWidths(Index: Integer; const Value: word);
    function GetColCount: integer;
    procedure SetSummary(const Value: TfrAdvSectionParams);
    procedure SetAggFields(const Value: TStringList);
  protected
    { Protected declarations }
  {$IFDEF IBO}
    FDataSet: TIB_Dataset;
  {$ELSE}
    FDataSet: TDataset;
  {$ENDIF}
    FVisibleFields: array[0..255] of TfrField;
    FAggFields: TStringList;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CreateDS; virtual;
    property AutoWidth: Boolean read FAutoWidth write FAutoWidth default True;

    function ColumnIndexByName(AField: string): integer;
{$IFDEF IBO}
    function FieldByColumIndex(AIndex: integer): TIB_Column;
{$ELSE}
    function FieldByColumIndex(AIndex: integer): TField;
{$ENDIF}
    function TextWidthInSection(AText: string; ADataSection: TfrDataSection): integer;
    function TextHeightInSection(AText: string; ADataSection: TfrDataSection): integer;
    function TextExtentInSection(AText: string; ADataSection: TfrDataSection): TSize;
    function TryToFitWidth(var Widths: TfrWidthsArray; DataColumns, ADesiredWidth, AThresold: integer; AFields: string; AOptions: TfrShrinkOptions): boolean;
    function SuggestedOrientation: TPrinterOrientation;

    property ColWidths[Index: Integer]: word read GetColWidths write SetColWidths;
    property ColCount: integer read GetColCount;

    procedure BuildReport;
    procedure ShowReport;

    property FitWidth: TfrFitWidth read FFitWidth write FFitWidth;
    property PageSize: Integer read FpgSize write FpgSize;
    property PageWidth: Integer read FpgWidth write FpgWidth;
    property PageHeight: Integer read FpgHeight write FpgHeight;
    property PageMargins: TfrPageMargins read FPageMargins write SetPageMargins;
    property Orientation: TPrinterOrientation read FOrientation write FOrientation default poPortrait;
    property Title: TfrAdvSectionParams read FTitle write SetTitle;
    property PageHeader: TfrAdvSectionParams read FPageHeader write SetPageHeader;
    property PageFooter: TfrAdvSectionParams read FPageFooter write SetPageFooter;
    property Header: TfrSectionParams read FHeader write SetHeader;
    property Footer: TfrSectionParams read FFooter write SetFooter;
    property Summary: TfrAdvSectionParams read FSummary write SetSummary;
    property Body: TfrSectionParams read FBody write SetBody;
    property Preview: TfrPreview read FPreview write FPreview;
    property Report: TfrReport read FReport;
    property AggregateFields: TStringList read FAggFields write SetAggFields;
    property OnPrintColumn: TfrPrintColumnEvent read FOnPrintColumn write FOnPrintColumn;
    property OnPrintData: TfrPrintDataEvent read FOnPrintData write FOnPrintData;
    property PrintOptions: TfrPrintOptions read FPrintOptions write FPrintOptions;
    property OnCustomizeWidths: TfrCustomWidthsEvent read FCustomizeWidths write FCustomizeWidths;
    // Add Stalker
    property OnPrintRow: TfrPrintRowEvent read FOnPrintRow write FOnPrintRow;
    //
    property OnBeginDoc: TBeginDocEvent read FOnBeginDoc write FOnBeginDoc;
    property OnEndDoc: TEndDocEvent read FOnEndDoc write FOnEndDoc;
    property OnBeginPage: TBeginPageEvent read FOnBeginPage write FOnBeginPage;
    property OnEndPage: TEndPageEvent read FOnEndPage write FOnEndPage;
    property OnFirst: TNotifyEvent read FOnFirst write FOnFirst;
    property OnNext: TNotifyEvent read FOnNext write FOnNext;
    property OnPrior: TNotifyEvent read FOnPrior write FOnPrior;
    property OnCheckEOF: TCheckEOFEvent read FOnCheckEOF write FOnCheckEOF;
    property AutoOrientation: TfrAutoOrientation read FAutoOrientation write FAutoOrientation;
    property ReportBefore: TfrReport read FReportBefore write FReportBefore;
    property ReportAfter: TfrReport read FReportAfter write FReportAfter;
    property DoublePassReport: Boolean read FDoublePass write FDoublePass;
    property PreviewButtons: TfrPreviewButtons read FPreviewButtons write FPreviewButtons;
  end;

  TfrPrintTable = class(TfrCustomPrintDataSet)
  private
    procedure OnEnterRect(Memo: TStringList; View: TfrView); override;
    procedure OnPrintColumn_(ColNo: Integer; var Width: Integer); override;
  protected
    { Protected declarations }
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure CreateDS; override;
  published
  {$IFDEF IBO}
    property DataSet: TIB_DataSet read FDataSet write FDataSet;
  {$ELSE}
    property DataSet: TDataSet read FDataSet write FDataSet;
  {$ENDIF}
    property AutoWidth;
    property FitWidth;
    property PageSize;
    property PageWidth;
    property PageHeight;
    property PageMargins;
    property Orientation;
    property Title;
    property PageHeader;
    property PageFooter;
    property Header;
    property Footer;
    property Summary;
    property Body;
    property PrintOptions;
    property AggregateFields;
    property AutoOrientation;
    property ReportBefore;
    property ReportAfter;
    property OnPrintColumn;
    property OnPrintData;
    property OnCustomizeWidths;
    property OnPrintRow;        // Add Stalker
    property OnBeginDoc;
    property OnEndDoc;
    property OnBeginPage;
    property OnEndPage;
    property OnFirst;
    property OnNext;
    property OnPrior;
    property OnCheckEOF;
    property DoublePassReport;
    property PreviewButtons;
  end;

  TfrPrintGrid = class(TfrCustomPrintDataSet)
  private
{$IFDEF IBO}
    FDBGrid: TIB_Grid;
{$ELSE}
    FDBGrid: TDBGrid;
{$ENDIF}
    function RealGridIndex(Index: Integer): Integer;
    procedure OnEnterRect(Memo: TStringList; View: TfrView); override;
    procedure OnPrintColumn_(ColNo: Integer; var Width: Integer); override;
    function GetFieldCount: Integer; override;
  protected
    { Protected declarations }
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    procedure CreateDS; override;
  published
{$IFDEF IBO}
    property DBGrid: TIB_Grid read FDBGrid write FDBGrid;
{$ELSE}
    property DBGrid: TDBGrid read FDBGrid write FDBGrid;
{$ENDIF}
    property AutoWidth;
    property FitWidth;
    property PageSize;
    property PageWidth;
    property PageHeight;
    property PageMargins;
    property Orientation;
    property Title;
    property PageHeader;
    property PageFooter;
    property Header;
    property Body;
    property OnPrintColumn;
    property OnPrintRow;        // Add Stalker
 end;


implementation

{$IFDEF Delphi2}
uses DBTables;
{$ENDIF}


{ TfrSectionParams }

constructor TfrSectionParams.Create;
begin
  inherited Create;
  FFont := TFont.Create;
  FFont.Name := 'Arial';
{$IFNDEF Delphi2}
  FFont.Charset := frCharset;
{$ENDIF}
  FFont.Size := 10;
  FColor := clWhite;
  FFrame := [frLeft, frTop, frRight, frBottom];
  FFrameWidth := 1;
end;

destructor TfrSectionParams.Destroy;
begin
  FFont.Free;
  inherited Destroy;
end;

procedure TfrSectionParams.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
  FFont.Assign(TfrSectionParams(Source).Font);
  FColor := TfrSectionParams(Source).Color;
  FFrame := TfrSectionParams(Source).Frame;
end;

procedure TfrSectionParams.SetFont(Value: TFont);
begin
  FFont.Assign(Value);
end;

function TfrSectionParams.GetFrameTyp: Integer;
begin
  Result := 0;
  if frLeft in FFrame then
    Result := frftLeft;
  if frRight in FFrame then
    Result := Result + frftRight;
  if frTop in FFrame then
    Result := Result + frftTop;
  if frBottom in FFrame then
    Result := Result + frftBottom;
end;


{ TfrAdvSectionParams }

constructor TfrAdvSectionParams.Create;
begin
  inherited Create;
  FAlign := taCenter;
  FFrame := [];
end;

procedure TfrAdvSectionParams.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
  FAlign := TfrAdvSectionParams(Source).Align;
  FText := TfrAdvSectionParams(Source).Text;
end;

function TfrAdvSectionParams.GetAlign: Integer;
begin
  Result := 0;
  if FAlign = taLeftJustify then
    Result := frtaLeft
  else if FAlign = taRightJustify then
    Result := frtaRight
  else if FAlign = taCenter then
    Result := frtaCenter
end;

{ TfrFitWidth }

procedure TfrFitWidth.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
  FEnabled := TfrFitWidth(Source).Enabled;
  FFields := TfrFitWidth(Source).Fields;
  FShrinkOptions := TfrFitWidth(Source).ShrinkOptions;
  FResizePercent := TfrFitWidth(Source).ResizePercent;
  FApplyBeforeOnCustomize := TfrFitWidth(Source).ApplyBeforeOnCustomize;
end;

constructor TfrFitWidth.Create;
begin
  FEnabled:=False;
  FFields:='';
  FShrinkOptions:=[frsoProportional, frsoShrinkOnly];
  FResizePercent:=30;
  FApplyBeforeOnCustomize:=False;
end;

procedure TfrFitWidth.SetApplyBeforeOnCustomize(const Value: boolean);
begin
  FApplyBeforeOnCustomize := Value;
end;

procedure TfrFitWidth.SetEnabled(const Value: Boolean);
begin
  FEnabled := Value;
end;

procedure TfrFitWidth.SetFields(const Value: string);
begin
  FFields := Value;
end;

procedure TfrFitWidth.SetResizePercent(const Value: integer);
begin
  if (Value<1) or (Value>100) then
    ShowMessage('The percent must be between 1 and 100')
  else
    FResizePercent := Value;
end;

{ TfrPageMargins }

constructor TfrPageMargins.Create;
begin
  inherited Create;
  FLeft   := 0;
  FTop    := 0;
  FRight  := 0;
  FBottom := 0;
end;

procedure TfrPageMargins.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
  FLeft   := TfrPageMargins(Source).Left;
  FTop    := TfrPageMargins(Source).Top;
  FRight  := TfrPageMargins(Source).Right;
  FBottom := TfrPageMargins(Source).Bottom;
end;


{ TfrCustomPrintDataSet }

constructor TfrCustomPrintDataSet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPageMargins := TfrPageMargins.Create;
  FpgSize := 9;
  FDoublePass := false;
  FTitle := TfrAdvSectionParams.Create;
  FTitle.Font.Style := [fsBold];
  FTitle.Font.Size := 12;

  FPageHeader := TfrAdvSectionParams.Create;

  FPageFooter := TfrAdvSectionParams.Create;

  FSummary := TfrAdvSectionParams.Create;
  FSummary.Font.Style := [fsItalic];
  FSummary.Font.Size := 12;

  FHeader := TfrSectionParams.Create;
  FHeader.Font.Style := [fsBold];
  FHeader.Font.Color := clWhite;
  FHeader.Color := clNavy;

  FFooter := TfrSectionParams.Create;
  FFooter.Font.Style := [fsItalic];
  FFooter.Color := clSilver;


  FBody := TfrSectionParams.Create;
  FReport := TfrReport.Create(Self);

  FPreviewButtons := [pbZoom, pbSave, pbPrint, pbFind, pbHelp, pbExit, pbPageSetup];
  FReport.PreviewButtons := FPreviewButtons;

  FReportDataSet := TfrDBDataSet.Create(Self);
  FReportDataSet.Name := 'frGridDBDataSet1';

  FColumnDataSet := TfrUserDataSet.Create(Self);
  FColumnDataSet.Name := 'frGridUserDataSet1';
  FColumnDataSet.RangeEnd := reCount;

  FPrintOptions:=[frpoHeader, frpoHeaderOnEveryPage];

  FAutoWidth := True;
  FFitWidth := TfrFitWidth.Create;
  FAutoOrientation := TfrAutoOrientation.Create;

  FAggFields := TStringList.Create;
end;

destructor TfrCustomPrintDataSet.Destroy;
begin
  FAutoOrientation.Free;
  FFitWidth.Free;
  FReportDataSet.Free;
  FColumnDataSet.Free;
  FReport.Free;
  FTitle.Free;
  FPageHeader.Free;
  FPageFooter.Free;
  FSummary.Free;
  FHeader.Free;
  FFooter.Free;
  FBody.Free;
  FPageMargins.Free;
  FAggFields.Free;
  inherited Destroy;
end;

procedure TfrCustomPrintDataSet.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FPreview) then
    FPreview := nil;
  if (Operation = opRemove) and (AComponent = FReportBefore) then
    FReportBefore := nil;
  if (Operation = opRemove) and (AComponent = FReportAfter) then
    FReportAfter := nil;
end;

function TfrCustomPrintDataSet.RealColumnIndex(Index: Integer): Integer;
var
  Y, I: Integer;
begin
  Result := 0;
  Y := -1;
  for I := 0 to FDataSet.FieldCount - 1 do
    if FDataSet.Fields[I].Visible then
    begin
      Inc(Y);
      if Y = Index then
      begin
        Result := I;
        break;
      end;
    end;
end;

procedure TfrCustomPrintDataSet.SetPageMargins(Value: TfrPageMargins);
begin
  FPageMargins.Assign(Value);
end;

procedure TfrCustomPrintDataSet.SetTitle(Value: TfrAdvSectionParams);
begin
  FTitle.Assign(Value);
end;

procedure TfrCustomPrintDataSet.SetPageHeader(Value: TfrAdvSectionParams);
begin
  FPageHeader.Assign(Value);
end;

procedure TfrCustomPrintDataSet.SetPageFooter(Value: TfrAdvSectionParams);
begin
  FPageFooter.Assign(Value);
end;

procedure TfrCustomPrintDataSet.SetHeader(Value: TfrSectionParams);
begin
  FHeader.Assign(Value);
end;

procedure TfrCustomPrintDataSet.SetBody(Value: TfrSectionParams);
begin
  FBody.Assign(Value);
end;

procedure TfrCustomPrintDataSet.CreateDS;
begin
end;

function TfrCustomPrintDataSet.GetFieldCount: Integer;
var
  i: Integer;
  b: Boolean;
begin
  Result := FDataSet.FieldCount;
  b := True;
  for i := 0 to FDataSet.FieldCount - 1 do
    if (FDataSet.Fields[i] <> nil) and FDataSet.Fields[i].Visible then
    begin
      if b then
      begin
        b := False;
        Result := 0;
      end;
      Inc(Result);
    end;
end;

procedure TfrCustomPrintDataSet.BuildReport;
var
  v: TfrView;
  b: TfrBandView;
  Page: TfrPage;
  LeftMargin: Integer;
begin
  CreateDS;

  if FDataSet = nil then Exit;

  FReport.OnBeforePrint := OnEnterRect;
  FReport.OnPrintColumn := OnPrintColumn_;
  FReport.Preview := FPreview;
  FReport.OnUserFunction := OnUserFunction;
  FReport.OnBeginDoc := FOnBeginDoc;
  FReport.OnEndDoc := FOnEndDoc;
  FReport.OnBeginPage := FOnBeginPage;
  FReport.OnEndPage := FOnEndPage;

  FReportDataSet.DataSet := FDataSet;
  FColumnDataSet.RangeEndCount := GetFieldCount;

  FReportDataSet.OnCheckEOF:=FOnCheckEOF;
  FReportDataSet.OnFirst:=FOnFirst;
  FReportDataSet.OnNext:=FOnNext;
  FReportDataSet.OnPrior:=FOnPrior;

  FReport.Clear;
  FReport.Pages.Add;
  Page := FReport.Pages[0];
  with Page do
  begin
    pgMargins.Left   := Round(FPageMargins.Left   * 18 / 5);
    pgMargins.Top    := Round(FPageMargins.Top    * 18 / 5);
    pgMargins.Right  := Round(FPageMargins.Right  * 18 / 5);
    pgMargins.Bottom := Round(FPageMargins.Bottom * 18 / 5);
    ChangePaper(FpgSize, FpgWidth * 10, FpgHeight * 10, -1, FOrientation);
  end;

  LeftMargin := Page.PrnInfo.Ofx;
  if Page.pgMargins.Left <> 0 then
    LeftMargin := Page.pgMargins.Left;

  with FFitWidth do
    if Enabled and ApplyBeforeOnCustomize then
      TryToFitWidth(FWidths, FColumnDataSet.RangeEndCount, Page.RightMargin-Page.LeftMargin,
        Trunc((Page.RightMargin-Page.LeftMargin)/(ResizePercent / 100)), Fields, ShrinkOptions);

  if Assigned(FCustomizeWidths) then FCustomizeWidths(FWidths, FColumnDataSet.RangeEndCount, Page.RightMargin-Page.LeftMargin);

  with FFitWidth do
    if Enabled and not ApplyBeforeOnCustomize then
      TryToFitWidth(FWidths, FColumnDataSet.RangeEndCount, Page.RightMargin-Page.LeftMargin,
        Trunc((Page.RightMargin-Page.LeftMargin)/(ResizePercent / 100)), Fields, ShrinkOptions);

// Title
  if FTitle.Text <> '' then
  begin
    b := TfrBandView(frCreateObject(gtBand, ''));
    b.SetBounds(0, 20, 1000, 30);
    b.Flags := b.Flags or flStretched;
    b.BandType := btReportTitle;
    Page.Objects.Add(b);
    v := frCreateObject(gtMemo, '');
    v.SetBounds(0, 20, 1000, 20);

  b.Script.Clear;                           // Add Stalker
  b.Script.Add('begin');                    // Add Stalker
  b.Script.Add(' Visible := IsPrint()');    // Add Stalker
  b.Script.Add('end');                      // Add Stalker

    v.BandAlign := baWidth;
    TfrMemoView(v).Alignment:= FTitle.GetAlign + frtaMiddle;
    TfrMemoView(v).Font := FTitle.Font;
    v.FrameTyp := FTitle.GetFrameTyp;
    v.FrameWidth := FTitle.FrameWidth;
    v.FillColor := FTitle.Color;
    v.Memo.Add(FTitle.Text);
    Page.Objects.Add(v);
  end;

// Summary
  if FSummary.Text <> '' then
  begin
    b := TfrBandView(frCreateObject(gtBand, ''));
    b.SetBounds(0, 320, 1000, 30);
    b.Flags := b.Flags or flStretched;
    b.BandType := btReportSummary;
    Page.Objects.Add(b);
    v := frCreateObject(gtMemo, '');
    v.SetBounds(0, 320, 1000, 20);
    v.BandAlign := baWidth;
    TfrMemoView(v).Alignment:= FSummary.GetAlign + frtaMiddle;
    TfrMemoView(v).Font := FSummary.Font;
    v.FrameTyp := FSummary.GetFrameTyp;
    v.FrameWidth := FSummary.FrameWidth;
    v.FillColor := FSummary.Color;
    v.Memo.Add(FSummary.Text);
    Page.Objects.Add(v);
  end;

// Header
  if frpoHeader in FPrintOptions then
  begin
    b := TfrBandView(frCreateObject(gtBand, ''));
    b.BandType := btMasterHeader;
    b.SetBounds(0, 0, 1000, 30);
    b.Flags := b.Flags or flStretched;
    if frpoHeaderOnEveryPage in FPrintOptions then
      b.Flags := b.Flags or flBandRepeatHeader;
    Page.Objects.Add(b);

    v := frCreateObject(gtMemo, '');
    v.SetBounds(LeftMargin, 0, 20, 30);
    TfrMemoView(v).Alignment := frtaCenter + frtaMiddle;
    TfrMemoView(v).Font := FHeader.Font;
    v.FillColor := FHeader.Color;
    v.FrameTyp := FHeader.GetFrameTyp;
    v.FrameWidth := FHeader.FrameWidth;
    v.Flags := v.Flags or flWordWrap or flStretched;
    v.Memo.Add('[Header]');
    Page.Objects.Add(v);
  end;

// Body
  b := TfrBandView(frCreateObject(gtBand, ''));
  b.BandType := btMasterData;
  b.Dataset := FReportDataSet.Name;
  b.SetBounds(0, 130, 1000, 18);
  b.Flags := b.Flags or flStretched;
  Page.Objects.Add(b);

  b := TfrBandView(frCreateObject(gtBand, ''));
  b.BandType := btCrossData;
  b.Dataset := FColumnDataSet.Name;
  b.SetBounds(LeftMargin, 0, 20, 1000);
  Page.Objects.Add(b);

  v := frCreateObject(gtMemo, '');
  v.SetBounds(LeftMargin, 130, 20, 18);
  TfrMemoView(v).Font := FBody.Font;
  v.FillColor := FBody.Color;
  v.FrameTyp := FBody.GetFrameTyp;
  v.FrameWidth := FBody.FrameWidth;
  TfrMemoView(v).GapX := 3;
  v.Flags := v.Flags or flWordWrap or flStretched;
  v.Memo.Add('[Cell]');
  Page.Objects.Add(v);


// Footer
  if frpoFooter in FPrintOptions then
  begin
    b:=TfrBandView(frCreateObject(gtBand, ''));
    b.BandType := btMasterFooter;
    b.SetBounds(0, 160, 1000, 30);
    Page.Objects.Add(b);

    v := frCreateObject(gtMemo, '');
    v.SetBounds(LeftMargin, 160, 20, 30);
    TfrMemoView(v).Alignment := frtaCenter + frtaMiddle;
    TfrMemoView(v).Font := FFooter.Font;
    v.FillColor := FFooter.Color;
    v.FrameTyp := FFooter.GetFrameTyp;
    v.FrameWidth := FFooter.FrameWidth;
    v.Flags := v.Flags or flWordWrap or flStretched;
    v.Memo.Add('[Footer]');
    Page.Objects.Add(v);
  end;

// Page header
  if FPageHeader.Text <> '' then
  begin
    b := TfrBandView(frCreateObject(gtBand, ''));
    b.BandType := btPageHeader;
    b.SetBounds(0, 200, 1000, 30);
    Page.Objects.Add(b);

    v := frCreateObject(gtMemo, '');
    v.SetBounds(0, 200, 20, 20);
    v.BandAlign := baWidth;
    TfrMemoView(v).Alignment := FPageHeader.GetAlign;
    TfrMemoView(v).Font := FPageHeader.Font;
    v.FillColor := FPageHeader.Color;
    v.FrameTyp := FPageHeader.GetFrameTyp;
    v.FrameWidth := FPageHeader.FrameWidth;
    v.Memo.Add(FPageHeader.Text);
    Page.Objects.Add(v);
  end;

// Page footer
  if FPageFooter.Text <> '' then
  begin
    b := TfrBandView(frCreateObject(gtBand, ''));
    b.BandType := btPageFooter;
    b.SetBounds(0, 240, 1000, 30);
    Page.Objects.Add(b);

    v := frCreateObject(gtMemo, '');
    v.SetBounds(0, 240, 20, 20);
    v.BandAlign := baWidth;
    TfrMemoView(v).Alignment := FPageFooter.GetAlign;
    TfrMemoView(v).Font := FPageFooter.Font;
    v.FillColor := FPageFooter.Color;
    v.FrameTyp := FPageFooter.GetFrameTyp;
    v.FrameWidth := FPageFooter.FrameWidth;
    v.Memo.Add(FPageFooter.Text);
    Page.Objects.Add(v);
  end;
end;

procedure TfrCustomPrintDataSet.ShowReport;
var
  r: TfrCompositeReport;
begin
  r:=TfrCompositeReport.Create(nil);
  r.PreviewButtons := FPreviewButtons;
  r.DoublePass := FDoublePass;
  try
    BuildReport;
    FDataSet.DisableControls;
    FReport.Pages[0].PrintToPrevPage:=True;
    if Assigned(FReportBefore) and (FReportBefore.Pages.Count>0) then
      r.Reports.Add(FReportBefore);
    r.Reports.Add(FReport);
    if Assigned(FReportAfter) and (FReportAfter.Pages.Count>0) then
      r.Reports.Add(FReportAfter);
    r.ShowReport;
  finally
    r.Free;
    FDataSet.EnableControls;
  end;
end;

procedure TfrCustomPrintDataSet.OnEnterRect(Memo: TStringList; View: TfrView);
begin
// empty method
end;

procedure TfrCustomPrintDataSet.OnPrintColumn_(ColNo: Integer; var Width: Integer);
begin
//--  Width := FWidths[ColNo]; - do not set here. It will be set in descendants
  if Assigned(FOnPrintColumn) then
    FOnPrintColumn(ColNo, Width);
  FWidth := Width;
end;


procedure TfrCustomPrintDataSet.SetFooter(const Value: TfrSectionParams);
begin
  FFooter := Value;
end;

// Add Stalker
procedure TfrCustomPrintDataSet.OnUserFunction(const Name: String; p1, p2,  p3: Variant; var Val: Variant);
var
  lResult :Boolean;

begin

 if Name = 'ISPRINT' then begin
   if Assigned(FOnPrintRow) then begin
     FOnPrintRow(lResult);
     Val := lResult;
   end else
     Val := True;   
 end; { if }
        
end;

function TfrCustomPrintDataSet.GetColWidths(Index: Integer): word;
begin
  if (Index>=0) and (Index<=High(FWidths)) then
    Result:=FWidths[Index]
  else
    Result:=0;
end;

procedure TfrCustomPrintDataSet.SetColWidths(Index: Integer;
  const Value: word);
begin
  if (Index>=0) and (Index<=High(FWidths)) then
    FWidths[Index]:=Value;
end;

function TfrCustomPrintDataSet.GetColCount: integer;
begin
  Result:=FColumnDataSet.RangeEndCount;
end;

procedure TfrCustomPrintDataSet.SetSummary(
  const Value: TfrAdvSectionParams);
begin
  FSummary := Value;
end;

function TfrCustomPrintDataSet.ColumnIndexByName(AField: string): integer;
var
  i: integer;
  Y: integer;

begin
  Result:=-1;
  Y:=0;

  for i:=0 to FDataSet.FieldCount-1 do
    if FDataSet.Fields[i].Visible then
    begin
{$IFDEF IBO}  // marco menardi patch 06 april 2002
      if AField=FDataSet.Fields[i].FieldName then
{$ELSE}

{$IFDEF Delphi4}
      if AField=FDataSet.Fields[i].FullName then
{$ELSE}
      if AField=FDataSet.Fields[i].{Full}Name then
{$ENDIF}

{$ENDIF}
      begin
        Result := Y;
        Break;
      end;
      inc(Y);
    end;
end;

{$IFDEF IBO}
function TfrCustomPrintDataSet.FieldByColumIndex(AIndex: integer): TIB_Column;
{$ELSE}
function TfrCustomPrintDataSet.FieldByColumIndex(AIndex: integer): TField;
{$ENDIF}
begin
  Result:=FDataSet.Fields[RealColumnIndex(AIndex)];
end;

function TfrCustomPrintDataSet.TextExtentInSection(AText: string;
  ADataSection: TfrDataSection): TSize;
var
  c: TCanvas;
  b: TBitmap;
begin
  b := TBitmap.Create;
  b.Width:=16; b.Height:=16;

  c:=b.Canvas;

  case ADataSection of
    frHeader: c.Font:=FHeader.Font;
    frData: c.Font:=FBody.Font;
    frFooter: c.Font:=FFooter.Font;
    frTitle: c.Font:=FTitle.Font;
    frSummary: c.Font:=FSummary.Font;
    frPageHeader: c.Font:=FPageHeader.Font;
    frPageFooter: c.Font:=FPageFooter.Font;
  else
    c.Font:=FBody.Font; //--- default
  end;
  c.Font.Height := -Round(c.Font.Size * 96 / 72); //--- go to FR coords

  Result.cx:=c.TextWidth(AText);
  Result.cy:=c.TextHeight(AText);

  b.Free;
end;

function TfrCustomPrintDataSet.TryToFitWidth(var Widths: TfrWidthsArray; DataColumns, ADesiredWidth, AThresold: integer; AFields: string; AOptions: TfrShrinkOptions): boolean;
var
  mCols: TfrWidthsArray;
  mColsLen: integer;
  w: integer;
  nDiff: integer;
  i: integer;
  nPos: integer;
  nRep: double;
  nCol: integer;

begin
  Result:=False;
  w:=0;
  for i:=0 to DataColumns-1 do
    w:=w+Widths[i];

  nDiff:=ADesiredWidth - w;

  if (Abs(nDiff) > AThresold) or (nDiff=0) then Exit;

  if (frsoShrinkOnly in AOptions) and (nDiff>0) then Exit;

  //----->>> make the elastic columns
  if AFields='' then //--- we'll put all columns
  begin
    mColsLen:=DataColumns;
    nRep:=ADesiredWidth / w;
    for i:=0 to DataColumns-1 do
      mCols[i]:=i;
  end
  else
  begin
    mColsLen:=0;
    nPos := 1;
    nRep:=0;
    while nPos <= Length(AFields) do
    begin
      nCol:=ColumnIndexByName(ExtractFieldName(AFields, nPos));
      if nCol<>-1 then
      begin
        mCols[mColsLen]:=nCol;
        nRep:=nRep+Widths[mCols[mColsLen]];
        inc(mColsLen);
      end;
    end;

    if (nRep = 0) or (w - ADesiredWidth > nRep) then
    begin
      Result:=False;
      Exit;
    end;

    nRep:=1 + (ADesiredWidth - w)/nRep;
  end;

  if frsoProportional in AOptions then
  begin
    for i:=0 to mColsLen-1 do
      Widths[mCols[i]]:=Trunc(nRep * Widths[mCols[i]])-1;
  end
  else
  begin
    nDiff := nDiff div mColsLen;
    for i:=0 to mColsLen-1 do
      Widths[mCols[i]]:=Widths[mCols[i]] + nDiff - 1;
  end;

  Result:=True;
end;

function TfrCustomPrintDataSet.TextHeightInSection(AText: string;
  ADataSection: TfrDataSection): integer;
begin
  Result:=TextExtentInSection(AText, ADataSection).cY;
end;

function TfrCustomPrintDataSet.TextWidthInSection(AText: string;
  ADataSection: TfrDataSection): integer;
begin
  Result:=TextExtentInSection(AText, ADataSection).cX;
end;

procedure TfrCustomPrintDataSet.SetAggFields(const Value: TStringList);
begin
  FAggFields.Assign(Value);
end;

function TfrCustomPrintDataSet.SuggestedOrientation: TPrinterOrientation;
var
  i: Integer;
  w: Integer;
  Page: TfrPage;

begin
  Result:=Orientation;
  if FAutoOrientation.Enabled and (PageWidth=0) and (PageHeight=0) then
    begin
      FReport.Clear;
      FReport.Pages.Add;
      Page := FReport.Pages[0];

      w:=0;
      for I := 0 to FColumnDataSet.RangeEndCount-1 do
        w:=w+FWidths[i];

      if w<>0 then
      begin
        if (w > Page.RightMargin-Page.LeftMargin) and (Orientation=poPortrait) then
          if (Page.RightMargin-Page.LeftMargin)*100/w > (100 - FAutoOrientation.ResizePercent) then
            Result:=poLandscape;

        if (w < Page.BottomMargin-Page.TopMargin) and (Orientation=poLandscape) then
          if w*100/(Page.RightMargin-Page.LeftMargin) < (100 - FAutoOrientation.ResizePercent) then
            Result:=poPortrait;
      end;
      Freport.Clear;
    end;

end;

{ TfrPrintTable }

constructor TfrPrintTable.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

procedure TfrPrintTable.CreateDS;
var
  i, n: Integer;
  s: String;
  c: TCanvas;
  b: TBitmap;
  CHandle: HDC;
  TextSize: TSize;
  nVisCount: integer;
  nCount: integer;
  cAggType: string;
begin
  if FDataSet = nil then Exit;
  if FAutoWidth or (FAggFields.Count>0) then
  begin
    FDataSet.DisableControls;

    b := TBitmap.Create;
    b.Width:=16; b.Height:=16;

    c := b.Canvas;

    c.Font := FHeader.Font;
    c.Font.Height := -Round(FHeader.Font.Size * 96 / 72); //--- go to FR coords

    FDataSet.First;

    nVisCount:=0;
    for i := 0 to FDataSet.FieldCount - 1 do
    begin
      if FDataSet.Fields[i].Visible then
      begin
        FVisibleFields[nVisCount].Field:=FDataSet.Fields[i];
        FVisibleFields[nVisCount].Value:=0;
        FVisibleFields[nVisCount].AggregateType:=frAggNone;

        cAggType:=UpperCase(FAggFields.Values[FDataSet.Fields[i].FieldName]);
        if cAggType<>'' then
          FHasAggregates:=True;

        if cAggType='SUM' then
          FVisibleFields[nVisCount].AggregateType:=frAggSum
        else
          if cAggType='MIN' then
            FVisibleFields[nVisCount].AggregateType:=frAggMin
          else
            if cAggType='MAX' then
              FVisibleFields[nVisCount].AggregateType:=frAggMax
            else
              if cAggType='COUNT' then
                FVisibleFields[nVisCount].AggregateType:=frAggCount
              else
                if cAggType='AVG' then
                  FVisibleFields[nVisCount].AggregateType:=frAggAvg;

        if (FVisibleFields[nVisCount].AggregateType=frAggMax) or (FVisibleFields[nVisCount].AggregateType=frAggMin) then
          FVisibleFields[nVisCount].Value:=FVisibleFields[nVisCount].Field.AsFloat;
{$IFDEF IBO}    // marco menardi patch 27 april 2002
        FWidths[nVisCount] := Round(FVisibleFields[nVisCount].Field.DisplayWidth / 8 * c.TextWidth('0')) + 8;
{$ELSE}
        FWidths[nVisCount] := c.TextWidth(FVisibleFields[nVisCount].Field.DisplayLabel) + 8;
{$ENDIF}
        inc(nVisCount);
      end;
    end;

    c.Font := FBody.Font;
    c.Font.Height := -Round(FBody.Font.Size * 96 / 72); //--- go to FR coords

    CHandle:=c.Handle;

    nCount:=0;
    while not FDataSet.EOF do
    begin
      for i := 0 to nVisCount-1 do
      begin
        // marco menardi patch 27 april 2002
{$IFDEF IBO}
        if FVisibleFields[i].Field.InheritsFrom(TIB_ColumnBlob) then
{$ELSE}
        if FVisibleFields[i].Field.InheritsFrom(TBLOBField) then
{$ENDIF}
        begin
          s:=Trim(FVisibleFields[i].Field.AsString);
          Windows.GetTextExtentPoint32(CHandle, PChar(s), Length(s), TextSize);
          n:=TextSize.cx+8;
        end
        else
        begin
          s:=Trim(FVisibleFields[i].Field.DisplayText);
          n:=c.TextWidth(s)+8;
        end;
        if n > FWidths[i] then
          FWidths[i]:=n;

        if FHasAggregates then
          case FVisibleFields[i].AggregateType of
            frAggSum:
              FVisibleFields[i].Value:=FVisibleFields[i].Value+FVisibleFields[i].Field.AsFloat;
            frAggAvg:
              FVisibleFields[i].Value:=FVisibleFields[i].Value+FVisibleFields[i].Field.AsFloat;
            frAggMin:
              if FVisibleFields[i].Value<FVisibleFields[i].Field.AsFloat then
                FVisibleFields[i].Value:=FVisibleFields[i].Field.AsFloat;
            frAggMax:
              if FVisibleFields[i].Value>FVisibleFields[i].Field.AsFloat then
                FVisibleFields[i].Value:=FVisibleFields[i].Field.AsFloat;
          end;
      end;

      inc(nCount);
      FDataSet.Next;
    end;

    if FHasAggregates then
    begin
      for i := 0 to nVisCount-1 do
      begin
        case FVisibleFields[i].AggregateType of
          frAggAvg:
            FVisibleFields[i].Value:=FVisibleFields[i].Value / nCount;
          frAggCount:
            FVisibleFields[i].Value:=nCount;
        end;
        if FVisibleFields[i].AggregateType<>frAggNone then
        begin
{$IFDEF IBO}
          if FVisibleFields[i].Field.InheritsFrom(TIB_ColumnNumBase) then
            s:=FormatFloat(TIB_ColumnNumBase(FVisibleFields[i].Field).DisplayFormat, FVisibleFields[i].Value)
{$ELSE}
          if FVisibleFields[i].Field.InheritsFrom(TNumericField) then
            s:=FormatFloat(TNumericField(FVisibleFields[i].Field).DisplayFormat, FVisibleFields[i].Value)
{$ENDIF}
          else
            s:=FloatToStr(FVisibleFields[i].Value);
          // marco menardi patch 27 april 2002
          n:=c.TextWidth(s)+8;
          if n > FWidths[i] then
            FWidths[i]:=n;
        end;
      end;
    end;

    //--- AutoChange page orientation
    Orientation:=SuggestedOrientation;

    b.Free;

    FDataSet.EnableControls;
  end;
end;

procedure TfrPrintTable.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = DataSet) then
    DataSet := nil;
end;

procedure TfrPrintTable.OnEnterRect(Memo: TStringList; View: TfrView);
var
{$IFDEF IBO}
  f: TIB_Column;
{$ELSE}
  f: TField;
{$ENDIF}
  s: TfrDataSection;

begin
  s:=frOther;

  if Memo[0] = '[Cell]' then
  begin
    f := FDataSet.Fields[RealColumnIndex(FColumnDataSet.RecNo)];

{$IFDEF IBO}
    if f.InheritsFrom(TIB_ColumnBlob) then
{$ELSE}
    if f.InheritsFrom(TBLOBField) then
{$ENDIF}
      Memo[0] := Trim(f.AsString)
    else
      Memo[0] := Trim(f.DisplayText);

    s:=frData;

    View.dx := FWidth;
    case f.Alignment of
      taLeftJustify : TfrMemoView(View).Alignment := frtaLeft;
      taRightJustify: TfrMemoView(View).Alignment := frtaRight;
      taCenter      : TfrMemoView(View).Alignment := frtaCenter;
    end;
  end;
  if Memo[0] = '[Header]' then
  begin
    f := FDataSet.Fields[RealColumnIndex(FColumnDataSet.RecNo)];
    Memo[0] := f.DisplayLabel;
    s:=frHeader;

    View.dx := FWidth;
  end;

  if Memo[0] = '[Footer]' then
  begin
    Memo[0] := '';
    if FVisibleFields[FColumnDataSet.RecNo].AggregateType<>frAggNone then
{$IFDEF IBO}
      Memo[0]:=FormatFloat(TIB_ColumnNumBase(FVisibleFields[FColumnDataSet.RecNo].Field).DisplayFormat, FVisibleFields[FColumnDataSet.RecNo].Value);
{$ELSE}
      Memo[0]:=FormatFloat(TNumericField(FVisibleFields[FColumnDataSet.RecNo].Field).DisplayFormat, FVisibleFields[FColumnDataSet.RecNo].Value);
{$ENDIF}
    s:=frFooter;
    View.dx := FWidth;
  end;
  if Assigned(FOnPrintData) then
    FOnPrintData(FDataSet.Fields[RealColumnIndex(FColumnDataSet.RecNo)], Memo, View, s);
end;

procedure TfrPrintTable.OnPrintColumn_(ColNo: Integer; var Width: Integer);
var
  c: TCanvas;
  n, n1: Integer;
begin
  if FAutoWidth then
//    Width := FWidths[RealColumnIndex(ColNo - 1)]
    Width :=FWidths[ColNo-1]
  else
  begin
    c := TCanvas.Create;
    c.Handle := GetDC(0);
    c.Font := FBody.Font;
    n := FDataSet.Fields[RealColumnIndex(ColNo - 1)].DisplayWidth;
    n1 := Length(FDataSet.Fields[RealColumnIndex(ColNo - 1)].DisplayLabel);
    if n1 > n then
      n := n1;
    Width := c.TextWidth('0') * n + 8;
    c.Free;
  end;
  FWidth := Width;
  inherited OnPrintColumn_(ColNo, Width);
end;


{ TfrPrintGrid }

{$IFDEF IBO}
type
  THackDBGrid = class(TIB_Grid)
  end;
{$ELSE}
type
  THackDBGrid = class(TDBGrid)
  end;
{$ENDIF}


procedure TfrPrintGrid.CreateDS;
var
  i, n: Integer;
  s: String;
  c: TCanvas;
  b: TBitmap;
  CHandle: HDC;
  TextSize: TSize;
  nVisCount: integer;
  nCount: integer;
  cAggType: string;
{$IFDEF IBO}
  f: TIB_Column;
{$ELSE}
  f: TField;
{$ENDIF}
begin
  if (FDBGrid = nil) or (DBGrid.DataSource = nil) or
     (DBGrid.DataSource.Dataset = nil) then Exit;
  FDataSet := DBGrid.DataSource.Dataset;

  if FDataSet = nil then Exit;
  if FAutoWidth or (FAggFields.Count>0) then
  begin
    FDataSet.DisableControls;

    b := TBitmap.Create;
    b.Width:=16; b.Height:=16;

    c := b.Canvas;

    c.Font := FHeader.Font;
    c.Font.Height := -Round(FHeader.Font.Size * 96 / 72); //--- go to FR coords

    FDataSet.First;

    nVisCount:=0;

{$IFDEF IBO}
    for i := 0 to DBGrid.GridFieldCount - 1 do
    begin
      f := DBGrid.GridFields[i];
{$ELSE}
    for i := 0 to DBGrid.Columns.Count - 1 do
    begin
      f := DBGrid.Fields[i];
{$ENDIF}
      if f.Visible then
      begin
        FVisibleFields[nVisCount].Field:=f;
        FVisibleFields[nVisCount].Value:=0;
        FVisibleFields[nVisCount].AggregateType:=frAggNone;

        cAggType:=UpperCase(FAggFields.Values[f.FieldName]);
        if cAggType<>'' then
          FHasAggregates:=True;

        if cAggType='SUM' then
          FVisibleFields[nVisCount].AggregateType:=frAggSum
        else
          if cAggType='MIN' then
            FVisibleFields[nVisCount].AggregateType:=frAggMin
          else
            if cAggType='MAX' then
              FVisibleFields[nVisCount].AggregateType:=frAggMax
            else
              if cAggType='COUNT' then
                FVisibleFields[nVisCount].AggregateType:=frAggCount
              else
                if cAggType='AVG' then
                  FVisibleFields[nVisCount].AggregateType:=frAggAvg;

        if (FVisibleFields[nVisCount].AggregateType=frAggMax) or (FVisibleFields[nVisCount].AggregateType=frAggMin) then
          FVisibleFields[nVisCount].Value:=FVisibleFields[nVisCount].Field.AsFloat;
{$IFDEF IBO}    // marco menardi patch 27 april 2002
        FWidths[nVisCount] := Round(FVisibleFields[nVisCount].Field.DisplayWidth / 8 * c.TextWidth('0')) + 8;
{$ELSE}
        FWidths[nVisCount] := c.TextWidth(FVisibleFields[nVisCount].Field.DisplayLabel) + 8;
{$ENDIF}
        inc(nVisCount);
      end;
    end;

    c.Font := FBody.Font;
    c.Font.Height := -Round(FBody.Font.Size * 96 / 72); //--- go to FR coords

    CHandle:=c.Handle;

    nCount:=0;
    while not FDataSet.EOF do
    begin
      for i := 0 to nVisCount-1 do
      begin
        // marco menardi patch 27 april 2002
{$IFDEF IBO}
        if FVisibleFields[i].Field.InheritsFrom(TIB_ColumnBlob) then
{$ELSE}
        if FVisibleFields[i].Field.InheritsFrom(TBLOBField) then
{$ENDIF}
        begin
          s:=Trim(FVisibleFields[i].Field.AsString);
          Windows.GetTextExtentPoint32(CHandle, PChar(s), Length(s), TextSize);
          n:=TextSize.cx+8;
        end
        else
        begin
          s:=Trim(FVisibleFields[i].Field.DisplayText);
          n:=c.TextWidth(s)+8;
        end;
        if n > FWidths[i] then
          FWidths[i]:=n;

        if FHasAggregates then
          case FVisibleFields[i].AggregateType of
            frAggSum:
              FVisibleFields[i].Value:=FVisibleFields[i].Value+FVisibleFields[i].Field.AsFloat;
            frAggAvg:
              FVisibleFields[i].Value:=FVisibleFields[i].Value+FVisibleFields[i].Field.AsFloat;
            frAggMin:
              if FVisibleFields[i].Value<FVisibleFields[i].Field.AsFloat then
                FVisibleFields[i].Value:=FVisibleFields[i].Field.AsFloat;
            frAggMax:
              if FVisibleFields[i].Value>FVisibleFields[i].Field.AsFloat then
                FVisibleFields[i].Value:=FVisibleFields[i].Field.AsFloat;
          end;
      end;

      inc(nCount);
      FDataSet.Next;
    end;

    if FHasAggregates then
    begin
      for i := 0 to nVisCount-1 do
      begin
        case FVisibleFields[i].AggregateType of
          frAggAvg:
            FVisibleFields[i].Value:=FVisibleFields[i].Value / nCount;
          frAggCount:
            FVisibleFields[i].Value:=nCount;
        end;
        if FVisibleFields[i].AggregateType<>frAggNone then
        begin
{$IFDEF IBO}
          if FVisibleFields[i].Field.InheritsFrom(TIB_ColumnNumBase) then
            s:=FormatFloat(TIB_ColumnNumBase(FVisibleFields[i].Field).DisplayFormat, FVisibleFields[i].Value)
{$ELSE}
          if FVisibleFields[i].Field.InheritsFrom(TNumericField) then
            s:=FormatFloat(TNumericField(FVisibleFields[i].Field).DisplayFormat, FVisibleFields[i].Value)
{$ENDIF}
          else
            s:=FloatToStr(FVisibleFields[i].Value);
          // marco menardi patch 27 april 2002
          n:=c.TextWidth(s)+8;
          if n > FWidths[i] then
            FWidths[i]:=n;
        end;
      end;
    end;

    //--- AutoChange page orientation
    Orientation:=SuggestedOrientation;

    b.Free;

    FDataSet.EnableControls;
  end;
end;

procedure TfrPrintGrid.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = DBGrid) then
    DBGrid := nil;
end;

function TfrPrintGrid.GetFieldCount: Integer;
var
  i: Integer;
begin
{$IFDEF IBO}
  if DBGrid.GridFieldCount = 0 then
    Result := inherited GetFieldCount
  else
  begin
    Result := 0; // marco menardi 28/04/02
    for i := 0 to DBGrid.GridFieldCount - 1 do
      if THackDBGrid(DBGrid).ColWidths[i] > 0 then
        Inc(Result);
  end;
{$ELSE}
  if DBGrid.Columns.Count = 0 then
    Result := inherited GetFieldCount
  else
  begin
    Result := 0;
    for i := 0 to DBGrid.Columns.Count - 1 do
      if DBGrid.Columns[i].Width > 0 then
        Inc(Result);
  end;
{$ENDIF}
end;

function TfrPrintGrid.RealGridIndex(Index: Integer): Integer;
var
  Y, I: Integer;
begin
  Result := 0;
  Y := -1;
{$IFDEF IBO}
  for I := 0 to DBGrid.GridFieldCount - 1 do
    if THackDBGrid(DBGrid).ColWidths[i] > 0 then
{$ELSE}
  for I := 0 to DBGrid.Columns.Count - 1 do
    if DBGrid.Columns[i].Width > 0 then
{$ENDIF}
    begin
      Inc(Y);
      if Y = Index then
      begin
        Result := I;
        break;
      end;
    end;
end;

procedure TfrPrintGrid.OnEnterRect(Memo: TStringList; View: TfrView);
var
{$IFDEF IBO}
  f: TIB_Column;
{$ELSE}
  f: TField;
{$ENDIF}
begin
  if Memo[0] = '[Cell]' then
  begin
{$IFDEF IBO}
    if DBGrid.GridFieldCount = 0 then
      f := FDataSet.Fields[RealColumnIndex(FColumnDataSet.RecNo)] else
      f := DBGrid.GridFields[RealGridIndex(FColumnDataSet.RecNo)];
{$ELSE}
    if DBGrid.Columns.Count = 0 then
      f := FDataSet.Fields[RealColumnIndex(FColumnDataSet.RecNo)] else
      f := DBGrid.Columns[RealGridIndex(FColumnDataSet.RecNo)].Field;
{$ENDIF}
//    if Assigned(f.OnGetText) then
      Memo[0] := f.DisplayText; 
//      else  Memo[0] := f.AsString;
    View.dx := FWidth;
    case f.Alignment of
      taLeftJustify : TfrMemoView(View).Alignment := frtaLeft;
      taRightJustify: TfrMemoView(View).Alignment := frtaRight;
      taCenter      : TfrMemoView(View).Alignment := frtaCenter;
    end;
  end;
  if Memo[0] = '[Header]' then
  begin
{$IFDEF IBO}
    if DBGrid.GridFieldCount = 0 then
{$ELSE}
    if DBGrid.Columns.Count = 0 then
{$ENDIF}
    begin
      f := FDataSet.Fields[RealColumnIndex(FColumnDataSet.RecNo)];
      Memo[0] := f.DisplayLabel;
    end
    else
{$IFDEF IBO}
      Memo[0] := DBGrid.GridFields[RealGridIndex(FColumnDataSet.RecNo)].GridDisplayLabel;
{$ELSE}
      Memo[0] := DBGrid.Columns[RealGridIndex(FColumnDataSet.RecNo)].Title.Caption;
{$ENDIF}
    View.dx := FWidth;
  end;
end;

procedure TfrPrintGrid.OnPrintColumn_(ColNo: Integer; var Width: Integer);
var
  d: Integer;
begin
  if FAutoWidth then
    Width :=FWidths[ColNo-1]
  else
  begin
{$IFDEF IBO}
    if DBGrid.IndicateRow then
{$ELSE}
    if dgIndicator in DBGrid.Options then
{$ENDIF}
      d := 1 else
      d := 0;
{$IFDEF IBO}
    Width := THackDBGrid(DBGrid).ColWidths[RealGridIndex(ColNo - 1) + d];
{$ELSE}
    Width := THackDBGrid(DBGrid).ColWidths[RealGridIndex(ColNo - 1) + d];
{$ENDIF}
  end;
  inherited OnPrintColumn_(ColNo, Width);
end;

{ TfrAutoOrientation }

procedure TfrAutoOrientation.Assign(Source: TPersistent);
begin
  inherited;
  ResizePercent:=TfrAutoOrientation(Source).ResizePercent;
  Enabled:=TfrAutoOrientation(Source).Enabled;
end;

constructor TfrAutoOrientation.Create;
begin
  FEnabled := True;
  ResizePercent := 20;
end;

procedure TfrAutoOrientation.SetResizePercent(const Value: integer);
begin
  if (Value<1) or (Value>100) then
    ShowMessage('The percent must be between 1 and 100')
  else
    FResizePercent := Value;
end;

end.
