program RmSvrMng;

uses
  Forms,
  rp_dlgViewReportServer_unit in 'rp_dlgViewReportServer_unit.pas' {dlgViewReportServer},
  rp_SvrMngTemplate_unit in 'rp_SvrMngTemplate_unit.pas' {SvrMngTemplate};

{$R *.RES}

(*

� ��������������, ������ ��� ����� ������ ������
������������� ������.

{$R Gedemin.TLB}

*)

begin
  Application.Initialize;
  Application.Title := '��������� ������';
  Application.CreateForm(TdlgViewReportServer, dlgViewReportServer);
  Application.Run;
end.
