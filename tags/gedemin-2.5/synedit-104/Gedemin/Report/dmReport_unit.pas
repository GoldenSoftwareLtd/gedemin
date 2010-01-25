unit dmReport_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  rp_ReportServer, rp_ReportScriptControl, IBDatabase, ActiveX, rp_BaseReport_unit,
  rp_ReportClient;

type
  TdmReport = class(TDataModule)
    ClientReport1: TClientReport;
    IBTransaction1: TIBTransaction;
    ServerReport1: TServerReport;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure ClientReport1InputParams(
      const ExecuteFunction: TrpCustomFunction; out ParamResult: Variant;
      out ExecuteResult: Boolean);
    procedure ServerReport1ExecuteFunction(
      const ExecuteFunction: TrpCustomFunction;
      const ReportResult: TReportResult; var ParamAndResult: Variant;
      out ExecuteResult: Boolean);
    procedure ClientReport1ClientQuery(const ReportData: TCustomReport;
      const ReportResult: TReportResult; var ParamAndResult: Variant;
      out ExecuteResult: Boolean);
  private
    FReportScript: TReportScript;
  public
    procedure SetDatabase(const AnDatabase: TIBDatabase);
  end;

var
  dmReport: TdmReport;

implementation

{$R *.DFM}

procedure TdmReport.DataModuleCreate(Sender: TObject);
begin
  OleInitialize(nil);
  FReportScript := TReportScript.Create(Self);
  FReportScript.Transaction := IBTransaction1;
end;

procedure TdmReport.DataModuleDestroy(Sender: TObject);
begin
  FReportScript.Free;
  OleUninitialize;
end;

procedure TdmReport.ServerReport1ExecuteFunction(
  const ExecuteFunction: TrpCustomFunction;
  const ReportResult: TReportResult; var ParamAndResult: Variant;
  out ExecuteResult: Boolean);
begin
  ExecuteResult := FReportScript.ExecuteFunction(ExecuteFunction, ReportResult, ParamAndResult);
end;

procedure TdmReport.ClientReport1InputParams(
  const ExecuteFunction: TrpCustomFunction; out ParamResult: Variant;
  out ExecuteResult: Boolean);
begin
  ExecuteResult := FReportScript.InputParams(ExecuteFunction, ParamResult);
end;

procedure TdmReport.SetDatabase(const AnDatabase: TIBDatabase);
begin
  FReportScript.Database := AnDatabase;
  ClientReport1.Database := AnDatabase;
  ServerReport1.Database := AnDatabase;
  IBTransaction1.DefaultDatabase := AnDatabase;
  ClientReport1.Refresh;
  ServerReport1.Load;
end;

procedure TdmReport.ClientReport1ClientQuery(
  const ReportData: TCustomReport; const ReportResult: TReportResult;
  var ParamAndResult: Variant; out ExecuteResult: Boolean);
begin
  ExecuteResult := ServerReport1.GetReportResult(ReportData.ReportKey, ParamAndResult, ReportResult);
end;

end.
