unit rp_ReportMainForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  rp_ReportClient, gd_createable_form, IBSQL;

type
  TReportMainForm = class(TCreateableForm)
    procedure FormDestroy(Sender: TObject);
  protected
    procedure VisibleChanging; override;
  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  ReportMainForm: TReportMainForm;

implementation

{$R *.DFM}

class function TReportMainForm.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(ReportMainForm) then
    ReportMainForm := TReportMainForm.Create(AnOwner);
  Result := ReportMainForm;
end;

procedure TReportMainForm.VisibleChanging;
begin
  // ����� � ������ ����� �������� .Show, �� �������������� ���� �������.
  // ������� ��� ��������.
  if ReportMainForm <> nil then
  begin
    if ClientReport <> nil then
      ClientReport.Execute;
    Abort;
  end;
end;

procedure TReportMainForm.FormDestroy(Sender: TObject);
begin
  ReportMainForm := nil;
end;

// ���������������� ��������� ������� �� ���������� ������
initialization
  RegisterClass(TReportMainForm);

finalization
  UnRegisterClass(TReportMainForm);
end.

