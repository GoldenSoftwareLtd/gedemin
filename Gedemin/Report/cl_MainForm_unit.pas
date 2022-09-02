// ShlTanya, 26.02.2019

unit cl_MainForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, rp_ReportMainForm_unit, ScktComp, OleCtrls, MSScriptControl_TLB;

type
  TMainReportClient = class(TForm)
    Execute: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ExecuteClick(Sender: TObject);
  private
    FReportMainForm: TReportMainForm;
  public
    { Public declarations }
  end;

var
  MainReportClient: TMainReportClient;

implementation

uses
  {$IFDEF GEDEMIN}
  dmDatabase_unit,
  {$ELSE}
  dmTestReport_unit,
  {$ENDIF}
  gd_security, gd_security_OperationConst, rp_ReportClient;

{$R *.DFM}

procedure TMainReportClient.FormCreate(Sender: TObject);
begin
  FReportMainForm := nil;
  {$IFDEF GEDEMIN}
  IBLogin.SubSystemKey := GD_SYS_GADMIN;
  if not IBLogin.Login then
  begin
    Application.ShowMainForm := False;
    Application.Terminate;
  end else
  {$ELSE}
  dmTestReport.IBDatabase1.Connected := True;
  {$ENDIF}
    FReportMainForm := TReportMainForm.Create(Self);
end;

procedure TMainReportClient.FormDestroy(Sender: TObject);
begin
  if Assigned(FReportMainForm) then
    FreeAndNil(FReportMainForm);
end;

procedure TMainReportClient.ExecuteClick(Sender: TObject);
begin
  ClientReport.Execute;
end;

end.
