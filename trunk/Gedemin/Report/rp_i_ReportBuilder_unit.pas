unit rp_i_ReportBuilder_unit;

interface

uses
  Windows, ActiveX, Classes, Graphics, OleServer, OleCtrls, StdVCL,
  rp_BaseReport_unit, Forms,
  {$IFDEF GEDEMIN}
  gd_createable_form,
  {$ENDIF}
  SysUtils;

type
  TReportEvent = procedure(const AnVarArray: Variant;
   const AnEventFunction: TrpCustomFunction; var AnResult: Boolean) of object;

type
  TExportType = (etNone, etWord, etExcel, etPdf);

type

// *********************************************************************//
// Interface: IgsReportBuilder
// Flags:     (0)
// GUID:      {B5CC4034-1ED7-11D5-AECE-006052067F0D}
// *********************************************************************//
  IgsReportBuilder = interface(IUnknown)
    ['{B5CC4034-1ED7-11D5-AECE-006052067F0D}']
    procedure BuildReport;
    procedure PrintReport;
    procedure ExportReport(const AnExportType: TExportType; const AnFileName: String);
    function IsProcessed: Boolean;
    procedure Set_ReportResult(const AnReportResult: TReportResult);
    function Get_ReportResult: TReportResult;
    procedure Set_ReportTemplate(const AnReportTemplate: TReportTemplate);
    function Get_ReportTemplate: TReportTemplate;
    procedure Set_Params(const AnParams: Variant);
    function Get_Params: Variant;
    procedure Set_BuildDate(const AnValue: TDateTime);
    function Get_Preview: Boolean;
    procedure Set_Preview(const AnValue: Boolean);
    function Get_ReportEvent: TReportEvent;
    procedure Set_ReportEvent(Value: TReportEvent);
    function Get_EventFunction: TrpCustomFunction;
    procedure Set_EventFunction(Value: TrpCustomFunction);
    function Get_Caption: String;
    procedure Set_Caption(Value: String);
    function Get_PrinterName: String;
    procedure Set_PrinterName(Value: String);
    function Get_ShowProgress: Boolean;
    procedure Set_ShowProgress(Value: Boolean);
    function Get_FileName: String;
    procedure Set_FileName(Value: String);
    function Get_ExportType: TExportType;
    procedure Set_ExportType(Value: TExportType);

    property ReportResult: TReportResult read Get_ReportResult write Set_ReportResult;
    property ReportTemplate: TReportTemplate read Get_ReportTemplate write Set_ReportTemplate;
    property Params: Variant read Get_Params write Set_Params;
    property BuildDate: TDateTime write Set_BuildDate;
    property Preview: Boolean read Get_Preview write Set_Preview;
    property OnReportEvent: TReportEvent read Get_ReportEvent write Set_ReportEvent;
    property EventFunction: TrpCustomFunction read Get_EventFunction write Set_EventFunction;
    property Caption: String read Get_Caption write Set_Caption;
    property PrinterName: String read Get_PrinterName write Set_PrinterName;
    property ShowProgress: Boolean read Get_ShowProgress write Set_ShowProgress;
    property FileName: String read Get_FileName write Set_FileName;
    property ExportType: TExportType read Get_ExportType write Set_ExportType;
  end;

  TCustomReportBuilder = class(TInterfacedObject, IgsReportBuilder)
  private
    FOldClose: TCloseEvent;
    FOldDestroy: TNotifyEvent;
    FPreview: Boolean;
    FCaption: String;
    FPrinterName: String;
    FShowProgress: Boolean;
    FFileName: String;
    FExportType: TExportType;

    procedure DoClose(Sender: TObject; var Action: TCloseAction);
    procedure DoDestroy(Sender: TObject);
  protected
    FPreviewForm: TForm;
    FReportEvent: TReportEvent;
    FEventFunction: TrpCustomFunction;

    procedure FreeOldForm;
    procedure CreatePreviewForm; virtual;
    procedure AddParam(const AnName: String; const AnValue: Variant); virtual; abstract;

    procedure BuildReport; virtual;
    procedure PrintReport; virtual; abstract;
    procedure ExportReport(const AnExportType: TExportType; const AnFileName: String); virtual;
    function IsProcessed: Boolean; virtual;
    procedure Set_ReportResult(const AnReportResult: TReportResult);  virtual; abstract;
    function Get_ReportResult: TReportResult;  virtual; abstract;
    procedure Set_ReportTemplate(const AnReportTemplate: TReportTemplate);  virtual; abstract;
    function Get_ReportTemplate: TReportTemplate;  virtual; abstract;
    procedure Set_Params(const AnParams: Variant); virtual;
    function Get_Params: Variant; virtual;
    procedure Set_BuildDate(const AnValue: TDateTime);
    function Get_Preview: Boolean;
    procedure Set_Preview(const AnValue: Boolean);
    function Get_ReportEvent: TReportEvent;
    procedure Set_ReportEvent(Value: TReportEvent);
    function Get_EventFunction: TrpCustomFunction;
    procedure Set_EventFunction(Value: TrpCustomFunction);
    function Get_Caption: String;
    procedure Set_Caption(Value: String);
    function Get_PrinterName: String;
    procedure Set_PrinterName(Value: String);
    function Get_ShowProgress: Boolean;
    procedure Set_ShowProgress(Value: Boolean);
    function Get_FileName: String;
    procedure Set_FileName(Value: String);
    function Get_ExportType: TExportType;
    procedure Set_ExportType(Value: TExportType);
  public
    constructor Create;
    destructor Destroy; override;

    property ReportResult: TReportResult read Get_ReportResult write Set_ReportResult;
    property ReportTemplate: TReportTemplate read Get_ReportTemplate write Set_ReportTemplate;
    property Params: Variant read Get_Params write Set_Params;
    property BuildDate: TDateTime write Set_BuildDate;
    property Preview: Boolean read Get_Preview write Set_Preview;
    property EventFunction: TrpCustomFunction read Get_EventFunction write Set_EventFunction;
    property PrinterName: string read Get_PrinterName write Set_PrinterName;
    property ShowProgress: Boolean read Get_ShowProgress write Set_ShowProgress;
    property FileName: String read Get_FileName write Set_FileName;
    property ExportType: TExportType read Get_ExportType write Set_ExportType;
  end;

implementation

{ TRTFReportInterface }

// Method must be override, where calling CustomExecuteReport.
procedure TCustomReportBuilder.BuildReport;
begin
  FreeOldForm;

  // Call abstarct method.
  CreatePreviewForm;

  FOldClose := FPreviewForm.OnClose;
  FOldDestroy := FPreviewForm.OnDestroy;

  FPreviewForm.OnClose := DoClose;
  FPreviewForm.OnDestroy := DoDestroy;
end;

constructor TCustomReportBuilder.Create;
begin
  inherited Create;

  FOldClose := nil;
  FOldDestroy := nil;
  FPreviewForm := nil;
  FPreview := True;
  FReportEvent := nil;
  FIsExport := False;
  FFileName := '';
  FExportType := etNone;
  FEventFunction := TrpCustomFunction.Create;
  InterlockedIncrement(FRefCount);
end;

procedure TCustomReportBuilder.CreatePreviewForm;
begin
  if Assigned(FPreviewForm) then
  begin
    {$IFDEF GEDEMIN}
    if FPreviewForm is TCreateableForm then
      TCreateableForm(FPreviewForm).Caption := FCaption
    else
      FPreviewForm.Caption := FCaption;
    {$ELSE}
    FPreviewForm.Caption := FCaption;
    {$ENDIF}
    //дл€ того чтобы вызывалс€ OnDestroy из деструктора
    FPreviewForm.OldCreateOrder := True;
  end;
end;

destructor TCustomReportBuilder.Destroy;
begin
  FreeOldForm;
  FreeAndNil(FEventFunction);

  inherited Destroy;
end;

procedure TCustomReportBuilder.DoClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if Assigned(FOldClose) then
    FOldClose(Sender, Action);
//!!! JKL проверь этот код. ≈сли Action присвоить caFree то окно просмотра
//результатов отчета высвобождаетс€ даже если пользователь просто свернул окно

// ѕри минимизации окна OnClose вызыватьс€ не должно, и оно не вызывалось некоторое врем€
// насколько € помню (после наследовани€ от createableform).
// ј если этот код закомментировать, освобождатьс€ окно не будет.
// ¬ любом случае вызов OnClose при minimize - это ошибка. JKL

//!!!TipTop Action = caFree только если окно закрываетс€ с нажатым Shift-ом
//» если  закоментиировать то все работает правильно
//  Action := caFree;

end;

procedure TCustomReportBuilder.DoDestroy(Sender: TObject);
begin
  if Assigned(FOldDestroy) then
    FOldDestroy(Sender);
  FPreviewForm := nil;
  _Release;
end;

procedure TCustomReportBuilder.ExportReport(
  const AnExportType: TExportType; const AnFileName: String);
begin
  Beep;
end;

procedure TCustomReportBuilder.FreeOldForm;
begin
  if Assigned(FPreviewForm) then
  begin
    FPreviewForm.OnClose := FOldClose;
    FPreviewForm.OnDestroy := FOldDestroy;
    FreeAndNil(FPreviewForm);
  end;
end;

function TCustomReportBuilder.Get_Caption: String;
begin
  Result := FCaption;
end;

function TCustomReportBuilder.Get_EventFunction: TrpCustomFunction;
begin
  Result := FEventFunction;
end;

function TCustomReportBuilder.Get_ExportType: TExportType;
begin
  Result := FExportType;
end;

function TCustomReportBuilder.Get_FileName: String;
begin
  Result := FFileName;
end;

function TCustomReportBuilder.Get_IsExport: Boolean;
begin
  Result := FIsExport;
end;

function TCustomReportBuilder.Get_Params: Variant;
begin
  Result := Unassigned;
end;

function TCustomReportBuilder.Get_Preview: Boolean;
begin
  Result := FPreview;
end;

function TCustomReportBuilder.Get_PrinterName: String;
begin
  Result := FPrinterName;
end;

function TCustomReportBuilder.Get_ReportEvent: TReportEvent;
begin
  Result := FReportEvent;
end;

function TCustomReportBuilder.Get_ShowProgress: boolean;
begin
  Result := FShowProgress;
end;

function TCustomReportBuilder.IsProcessed: Boolean;
begin
  Result := FPreviewForm <> nil;
end;

procedure TCustomReportBuilder.Set_BuildDate(const AnValue: TDateTime);
const
  BuildDateName = 'BuildDate';
begin
  AddParam(BuildDateName, AnValue);
end;

procedure TCustomReportBuilder.Set_Caption(Value: String);
begin
  if Assigned(FPreviewForm) then
    FPreviewForm.Caption := Value;
  FCaption := Value;
end;

procedure TCustomReportBuilder.Set_EventFunction(Value: TrpCustomFunction);
begin
  FEventFunction.Assign(Value);
end;

procedure TCustomReportBuilder.Set_ExportType(Value: TExportType);
begin
  FExportType := Value;
end;

procedure TCustomReportBuilder.Set_FileName(Value: String);
begin
  FFileName := Value;
end;

procedure TCustomReportBuilder.Set_IsExport(Value: Boolean);
begin
  FIsExport := Value;
end;

procedure TCustomReportBuilder.Set_Params(const AnParams: Variant);
const
  cParamName = 'PARAM';
  cSeparator = 's';

  procedure SetParam(const AnParamName: String; const Param: Variant);
  var
    I: Integer;
    PP: OleVariant;
  begin
    if VarIsArray(Param) then
      for I := VarArrayLowBound(Param, 1) to VarArrayHighBound(Param, 1) do
      begin
        case VarType(Param[I]) of
          varDispatch:
            PP := 'Object';
          varEmpty:
            PP := ''
          else
          PP := Param[I];
        end;
        
        if Length(AnParamName) > Length(cParamName) then
          SetParam(AnParamName + cSeparator + IntToStr(I), PP)
        else
          // Call abstract method.
          SetParam(AnParamName + IntToStr(I), PP)
      end
    else
      AddParam(AnParamName, Param);
  end;
begin
  SetParam(cParamName, AnParams);
end;

procedure TCustomReportBuilder.Set_Preview(const AnValue: Boolean);
begin
  FPreview := AnValue;
end;

procedure TCustomReportBuilder.Set_PrinterName(Value: String);
begin
  FPrinterName := Value;
end;

procedure TCustomReportBuilder.Set_ReportEvent(Value: TReportEvent);
begin
  FReportEvent := Value;
end;

procedure TCustomReportBuilder.Set_ShowProgress(Value: boolean);
begin
  FShowProgress:= Value;
end;

end.

