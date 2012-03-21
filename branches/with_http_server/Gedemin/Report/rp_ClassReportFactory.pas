unit rp_ClassReportFactory;

interface

uses
  Classes, SysUtils, rp_BaseReport_unit, rp_i_ReportBuilder_unit,
  Windows, Forms, {RTF deleted} {rp_StreamRTF, }rp_StreamNone, rp_StreamFR,
  rp_StreamXFR, rp_StreamGRD, rp_report_const {$IFDEF FR4}, rp_StreamFR4{$ENDIF};

type
  TReportFactory = class(TComponent)
  private
    FOnReportEvent: TReportEvent;
    FPrinterName: String;
    FShowProgress: Boolean;
    FFileName: String;
    FExportType: TExportType;

    function GetReportInterface(const AnTemplateStructure: TTemplateStructure;
     AnReportResult: TReportResult; const AnParams: Variant;
     const AnBuildDate: TDateTime; const AnPreview: Boolean;
     const AnEventFunction: TrpCustomFunction; const AnReportName: String; const AnBaseQueryList: Variant; const AnModalPreview: Boolean): IgsReportBuilder;
    function GetReportEvent: TReportEvent;
    procedure SetReportEvent(Value: TReportEvent);
    procedure ShowForm(const FReportInterface: IgsReportBuilder);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure CreateReport(const AnTemplateStructure: TTemplateStructure;
     AnReportResult: TReportResult; const AnParams: Variant;
     const AnBuildDate: TDateTime; const AnPreview: Boolean;
     const AnEventFunction: TrpCustomFunction; const AnReportName: String;
     const AnPrinterName: String; const AnShowProgress: Boolean; const AnBaseQueryList: Variant;
     const AnFileName: String; const AnExportType: TExportType; const AnModalPreview: Boolean);
  published
    property OnReportEvent: TReportEvent read GetReportEvent write SetReportEvent;
  end;

procedure Register;

var
  ReportIsBuilding: Boolean;

implementation

uses
  FR_Prntr,
  Storages,
  gd_security
  {$IFDEF GEDEMIN_LOCK}
    ,gd_registration
  {$ENDIF}
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
   ;

// TReportFactory

constructor TReportFactory.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FOnReportEvent := nil;
  FFileName := '';
  FExportType := etNone;
end;

destructor TReportFactory.Destroy;
begin
  inherited Destroy;
end;

function TReportFactory.GetReportInterface(const AnTemplateStructure: TTemplateStructure;
 AnReportResult: TReportResult; const AnParams: Variant; const AnBuildDate: TDateTime;
 const AnPreview: Boolean; const AnEventFunction: TrpCustomFunction;
 const AnReportName: String; const AnBaseQueryList: Variant; const AnModalPreview: Boolean): IgsReportBuilder;
begin
  Result := nil;

  case AnTemplateStructure.RealTemplateType of
    ttNone:
      Result := TNoneReportInterface.Create;
    ttFR:
      Result := TFRReportInterface.Create;
    ttXFR:
      Result := TXFRReportInterface.Create;
    ttGRD:
      Result := TGRDReportInterface.Create;
    {$IFDEF FR4}
    ttFR4:
      Result := TFR4ReportInterface.Create;
    {$ENDIF}
  end;

  Result.PrinterName := FPrinterName;
  Result.ShowProgress := FShowProgress; 
  Result.ModalPreview := AnModalPreview;
  Result.FileName := FFileName;
  Result.ExportType := FExportType;

  if Result = nil then
    MessageBox(0, PChar(Format('Тип шаблона %s отчета не поддерживается.',
     [AnTemplateStructure.TemplateType])), 'Внимание', MB_OK or MB_ICONWARNING or MB_TASKMODAL)
  else
  begin
    if AnReportResult.IsStreamData then
      Result.ReportResult.AddDataSetList(AnBaseQueryList)
    else
      Result.ReportResult := AnReportResult;
    Result.ReportTemplate := AnTemplateStructure.ReportTemplate;
    Result.Params := AnParams;
    Result.BuildDate := AnBuildDate;
    Result.Preview := AnPreview;
    Result.OnReportEvent := FOnReportEvent;
    Result.EventFunction := AnEventFunction;
    Result.Caption := AnReportName;
  end;
end;

procedure TReportFactory.CreateReport(const AnTemplateStructure: TTemplateStructure;
 AnReportResult: TReportResult; const AnParams: Variant; const AnBuildDate: TDateTime;
 const AnPreview: Boolean; const AnEventFunction: TrpCustomFunction; const AnReportName: String;
 const AnPrinterName: String; const AnShowProgress: Boolean; const AnBaseQueryList: Variant;
 const AnFileName: String; const AnExportType: TExportType; const AnModalPreview: Boolean);
begin
  if Assigned(Prn) then
  begin
    if (Prn.Devmode = 0) then
    begin
      Prn.PaperSize := -1;
    end;
  end;

  FPrinterName := AnPrinterName;
  FShowProgress := AnShowProgress;
  FFileName := AnFileName;
  FExportType := AnExportType;

  ShowForm(GetReportInterface(AnTemplateStructure,
    AnReportResult, AnParams, AnBuildDate, AnPreview, AnEventFunction, AnReportName, AnBaseQueryList, AnModalPreview));
end;

function TReportFactory.GetReportEvent: TReportEvent;
begin
  Result := FOnReportEvent;
end;

procedure TReportFactory.SetReportEvent(Value: TReportEvent);
begin
  FOnReportEvent := Value;
end;

procedure Register;
begin
  RegisterComponents('gsReport', [TReportFactory]);
end;

procedure TReportFactory.ShowForm(
  const FReportInterface: IgsReportBuilder);
begin
  if FReportInterface.ExportType <> etNone then
    FReportInterface.ExportReport(FReportInterface.ExportType, FReportInterface.FileName)
  else if FReportInterface.Preview then
    FReportInterface.BuildReport
  else begin

  {$IFDEF GEDEMIN_LOCK}
    if not IsRegisteredCopy then
    begin
      MessageBox(0,
        'Вы используете незарегистрированную копию программы. Печать невозможна.'#13#10 +
        'Вы можете выполнить регистрацию вызвав команду Регистрация'#13#10 +
        'из пункта меню Справка главного окна программы.',
        'Внимание',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
      Exit;
    end;
  {$ENDIF}

    if Assigned(GlobalStorage) and Assigned(IBLogin)
      and ((GlobalStorage.ReadInteger('Options\Policy',
        GD_POL_PRINT_ID, GD_POL_PRINT_MASK, False) and IBLogin.InGroup) = 0) then
    begin
      MessageBox(0,
        'Печать документов запрещена текущими настройками политики безопасности.',
        'Отказано в доступе',
        MB_OK or MB_ICONHAND or MB_TASKMODAL);
      Exit;
    end;

    FReportInterface.PrintReport;
  end;

end;

end.
