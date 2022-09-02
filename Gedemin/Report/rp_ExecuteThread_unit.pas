// ShlTanya, 27.02.2019

unit rp_ExecuteThread_unit;

interface

uses
  Classes, rp_ReportServer, JclDebug;

type
  TReportResultThread = class(TJclDebugThread)
  private
    FServerReport: TServerReport;
    FSocketData: TrpSocketData;
    FSocketEvent: TrpSocketEvent;

    procedure GetReportResult;
    procedure SendData;
    procedure FreeData;
  protected
    procedure Execute; override;
  public
    constructor Create(AnServerReport: TServerReport; AnSocketData: TrpSocketData);
    destructor Destroy; override;

    property OnSendData: TrpSocketEvent read FSocketEvent write FSocketEvent;
  end;

implementation

uses
  SysUtils;

constructor TReportResultThread.Create(AnServerReport: TServerReport; AnSocketData: TrpSocketData);
begin
  Assert((AnServerReport <> nil) and (AnSocketData <> nil));
  FServerReport := AnServerReport;
  FSocketData := TrpSocketData.Create;
  FSocketData.Assign(AnSocketData);
  FSocketEvent := nil;
  FreeOnTerminate := True;

  inherited Create(False);
end;

destructor TReportResultThread.Destroy;
begin
  Synchronize(FreeData);

  inherited Destroy;
end;

procedure TReportResultThread.SendData;
begin
  if Assigned(FSocketEvent) then
    FSocketEvent(FSocketData);
  FSocketData.ReportResult.Clear;
end;

procedure TReportResultThread.GetReportResult;
var
  TempBuildDate: TDateTime;
begin
  if VarType(FSocketData.ExecuteResult) = varString then
  begin
    FServerReport.ThisFunc := FSocketData.ExecuteResult = FunctionIdentifier;
    // Ошибка при считывании данных
    if not FServerReport.ThisFunc then
      Exit;
  end else
    FServerReport.ThisFunc := False;
  FSocketData.ExecuteResult := FServerReport.GetReportResult(FSocketData.ReportKey, FSocketData.StaticParam,
    FSocketData.ReportResult, FSocketData.IsRebuild, TempBuildDate);
  FSocketData.BuildDate := TempBuildDate;
end;

procedure TReportResultThread.Execute;
begin
  Synchronize(GetReportResult);
  Synchronize(SendData);
end;

procedure TReportResultThread.FreeData;
begin
  if Assigned(FSocketData) then
    FreeAndNil(FSocketData);
  FServerReport := nil;
end;

end.
