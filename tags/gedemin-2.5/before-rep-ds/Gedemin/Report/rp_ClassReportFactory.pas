unit rp_ClassReportFactory;

interface

uses
  Classes, SysUtils, rp_BaseReport_unit, rp_i_ReportBuilder_unit,
  Windows, Forms, {RTF deleted} {rp_StreamRTF, }rp_StreamNone, rp_StreamFR,
  rp_StreamXFR, rp_StreamGRD, rp_report_const, JclDebug{$IFDEF FR4}, rp_StreamFR4{$ENDIF};

type
  TrpBuildReportThread = class(TJclDebugThread)
  private
    FReportInterface: IgsReportBuilder;
    FFormShowing: Boolean;

    procedure ShowForm;
    procedure FreeInterface;
    procedure DoClearTerminate;
  protected
    procedure Execute; override;
    procedure Proceed;
  public
    constructor Create(AnReportInterface: IgsReportBuilder);
    destructor Destroy; override;

    procedure ClearTerminate;
  end;

type
  TReportFactory = class(TComponent)
  private
    FThreadList: TList;
    FOnReportEvent: TReportEvent;
    FPrinterName: string;
    FShowProgress: boolean;

    procedure DoTerminate(Sender: TObject);
    function GetReportInterface(const AnTemplateStructure: TTemplateStructure;
     AnReportResult: TReportResult; const AnParams: Variant;
     const AnBuildDate: TDateTime; const AnPreview: Boolean;
     const AnEventFunction: TrpCustomFunction; const AnReportName: String; const AnBaseQueryList: Variant): IgsReportBuilder;
    procedure TerminateChildThreads;
    function GetReportEvent: TReportEvent;
    procedure SetReportEvent(Value: TReportEvent);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure CreateReport(const AnTemplateStructure: TTemplateStructure;
     AnReportResult: TReportResult; const AnParams: Variant;
     const AnBuildDate: TDateTime; const AnPreview: Boolean;
     const AnEventFunction: TrpCustomFunction; const AnReportName: String;
     const AnPrinterName: String; const AnShowProgress: boolean; const AnBaseQueryList: Variant);
    procedure Clear;
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

constructor TrpBuildReportThread.Create(AnReportInterface: IgsReportBuilder);
begin
  inherited Create(True);

  FreeOnTerminate := True;
  FFormShowing := False;

  if AnReportInterface <> nil then
    FReportInterface := AnReportInterface
  else
    Terminate;
  ReportIsBuilding := True;
  Resume;
end;

destructor TrpBuildReportThread.Destroy;
begin
  ReportIsBuilding := False;
  inherited Destroy;
end;

procedure TrpBuildReportThread.Proceed;
begin
  FFormShowing := FReportInterface.IsProcessed;
end;

procedure TrpBuildReportThread.FreeInterface;
begin
  FReportInterface := nil;
end;

procedure TrpBuildReportThread.DoClearTerminate;
begin
  OnTerminate := nil;
  Terminate;
end;

procedure TrpBuildReportThread.ClearTerminate;
begin
  Synchronize(DoClearTerminate);
end;

procedure TrpBuildReportThread.ShowForm;
begin
  if FReportInterface.Preview then
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

procedure TrpBuildReportThread.Execute;
begin
  if Terminated then
    Exit;

  FFormShowing := True;

  Synchronize(ShowForm);
  Synchronize(FreeInterface);
end;

// TReportFactory

constructor TReportFactory.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FThreadList := nil;
  FOnReportEvent := nil;

  if not (csDesigning in ComponentState) then
  begin
    FThreadList := TList.Create;
  end;
end;

destructor TReportFactory.Destroy;
begin
  if Assigned(FThreadList) then
  begin
    TerminateChildThreads;
    FreeAndNil(FThreadList);
  end;

  inherited Destroy;
end;

procedure TReportFactory.TerminateChildThreads;
var
  I: Integer;
begin
  for I := FThreadList.Count - 1 downto 0 do
  begin
    TrpBuildReportThread(FThreadList.Items[I]).FreeOnTerminate := False;
    TrpBuildReportThread(FThreadList.Items[I]).ClearTerminate;
    TrpBuildReportThread(FThreadList.Items[I]).WaitFor;
    TrpBuildReportThread(FThreadList.Items[I]).Free;
  end;
  FThreadList.Clear;
end;

function TReportFactory.GetReportInterface(const AnTemplateStructure: TTemplateStructure;
 AnReportResult: TReportResult; const AnParams: Variant; const AnBuildDate: TDateTime;
 const AnPreview: Boolean; const AnEventFunction: TrpCustomFunction;
 const AnReportName: String; const AnBaseQueryList: Variant): IgsReportBuilder;
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

  Result.PrinterName:= FPrinterName;
  Result.ShowProgress:= FShowProgress;

  if Result = nil then
    MessageBox(0, PChar(Format('Тип шаблона %s отчета не поддерживается.',
     [AnTemplateStructure.TemplateType])), 'Внимание', MB_OK or MB_ICONWARNING or MB_TASKMODAL)
  else
  begin
    if AnReportResult.IsStreamData then
      Result.ReportResult.LoadFromStream(AnReportResult.TempStream)
  //    Result.ReportResult.AddDataSetList(AnBaseQueryList)
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
 const AnPrinterName: String; const AnShowProgress: boolean; const AnBaseQueryList: Variant);
var
  I: Integer;
begin
  while FThreadList.Count > 0 do
  begin
    if Application.Terminated then
      exit;
    Application.ProcessMessages;
  end;

  if Assigned(Prn) then
  begin
    if (Prn.Devmode = 0) then
    begin
      Prn.PaperSize := -1;
    end;
  end;

  FPrinterName:= AnPrinterName;
  FShowProgress:= AnShowProgress;
  I := FThreadList.Add(TrpBuildReportThread.Create(GetReportInterface(AnTemplateStructure,
   AnReportResult, AnParams, AnBuildDate, AnPreview, AnEventFunction, AnReportName, AnBaseQueryList)));
  TThread(FThreadList.Items[I]).OnTerminate := DoTerminate;
end;

procedure TReportFactory.Clear;
begin
  TerminateChildThreads;
end;

procedure TReportFactory.DoTerminate(Sender: TObject);
var
  I: Integer;
begin
  if Assigned(FThreadList) then
  begin
    I := FThreadList.IndexOf(Sender);
    if I > -1 then
      FThreadList.Delete(I);
  end;
end;

procedure Register;
begin
  RegisterComponents('gsReport', [TReportFactory]);
end;

function TReportFactory.GetReportEvent: TReportEvent;
begin
  Result := FOnReportEvent;
end;

procedure TReportFactory.SetReportEvent(Value: TReportEvent);
begin
  FOnReportEvent := Value;
end;

end.
