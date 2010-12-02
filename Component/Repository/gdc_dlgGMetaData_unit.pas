unit gdc_dlgGMetaData_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, Menus, Db, ActnList, StdCtrls;

type
  Tgdc_dlgGMetaData = class(Tgdc_dlgG)
    procedure actNewExecute(Sender: TObject);
  end;

var
  gdc_dlgGMetaData: Tgdc_dlgGMetaData;

implementation
uses
  gd_ClassList, at_frmSQLProcess;

{$R *.DFM}

procedure Tgdc_dlgGMetaData.actNewExecute(Sender: TObject);
begin
  inherited;

  if Assigned(frmSQLProcess) and frmSQLProcess.Visible then
  begin
    frmSQLProcess.Hide;
    frmSQLProcess.ShowModal;
  end;
end;

initialization
  RegisterFrmClass(Tgdc_dlgGMetaData);

finalization
  UnRegisterFrmClass(Tgdc_dlgGMetaData);

end.
