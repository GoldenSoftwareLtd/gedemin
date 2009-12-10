unit rp_Report;

interface

uses
  Classes, rp_BaseReport_unit, IBDatabase;

type
  TgsReport = class(TComponent)
  private
    FReportList: TStrings;
    FCurrentReport: TCustomReport;

    FTransaction: TIBTransaction;
    FDatabase: TIBDatabase;

    procedure SetDatabase(const AnDatabase: TIBDatabase);
    function GetDatabase: TIBDatabase;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function Add: Boolean;
    function Edit(const AnReportKey: Integer): Boolean;
    function Delete(const AnReportKey: Integer): Boolean;

    procedure Execute;

    property CurrentReport: TCustomReport read FCurrentReport;
  published
    property Database: TIBDatabase read GetDatabase write SetDatabase;
  end;

procedure Register;

implementation

uses
  rp_dlgEditReport_unit, rp_vwReport_unit;

constructor TgsReport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FReportList := TStringList.Create;
  FCurrentReport := TCustomReport.Create;
  FTransaction := TIBTransaction.Create(nil);
  FDatabase := nil;
end;

destructor TgsReport.Destroy;
begin
  FReportList.Free;
  FCurrentReport.Free;
  FTransaction.Free;
  FDatabase := nil;

  inherited Destroy;
end;

procedure TgsReport.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if (Operation = opRemove) and (AComponent = FDatabase) then
    FDatabase := nil;
end;

procedure TgsReport.SetDatabase(const AnDatabase: TIBDatabase);
begin
  if FDatabase <> AnDatabase then
  begin
    if FDatabase <> nil then
      FDatabase.RemoveFreeNotification(Self);
    FDatabase := AnDatabase;
    FTransaction.DefaultDatabase := FDatabase;
    if FDatabase <> nil then
      FDatabase.FreeNotification(Self);
  end;
end;

function TgsReport.GetDatabase: TIBDatabase;
begin
  Result := FDatabase;
end;

function TgsReport.Add: Boolean;
begin
  with TdlgEditReport.Create(Self) do
  try
    FDatabase := Self.Database;
    FTransaction := Self.FTransaction;
    Result := AddReport;
  finally
    Free;
  end;
end;

function TgsReport.Edit(const AnReportKey: Integer): Boolean;
begin
  with TdlgEditReport.Create(Self) do
  try
    FDatabase := Self.Database;
    FTransaction := Self.FTransaction;
    Result := EditReport(AnReportKey);
  finally
    Free;
  end;
end;

function TgsReport.Delete(const AnReportKey: Integer): Boolean;
begin
  with TdlgEditReport.Create(Self) do
  try
    FDatabase := Self.Database;
    FTransaction := Self.FTransaction;
    Result := DeleteReport(AnReportKey);
  finally
    Free;
  end;
end;

procedure TgsReport.Execute;
begin
  with TvwReport.Create(Self) do
  try
    FDatabase := Self.Database;
    FTransaction := Self.FTransaction;
    ViewReport;
  finally
    Free;
  end;
end;

procedure Register;
begin
  RegisterComponents('gsNew', [TgsReport]);
end;

end.
