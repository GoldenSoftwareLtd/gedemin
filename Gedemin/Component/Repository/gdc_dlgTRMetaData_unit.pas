// ShlTanya, 21.02.2019

unit gdc_dlgTRMetaData_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTR_unit, IBDatabase, Menus, Db, ActnList, StdCtrls;

type
  Tgdc_dlgTRMetaData = class(Tgdc_dlgTR)
    procedure actNewExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_dlgTRMetaData: Tgdc_dlgTRMetaData;

implementation
uses
  gd_ClassList, at_frmSQLProcess;

{$R *.DFM}

procedure Tgdc_dlgTRMetaData.actNewExecute(Sender: TObject);
begin
  inherited;
  if Assigned(frmSQLProcess) and frmSQLProcess.Visible then
  begin
    frmSQLProcess.Hide;
    frmSQLProcess.ShowModal;
  end;
end;

initialization
  RegisterFrmClass(Tgdc_dlgTRMetaData);

finalization
  UnRegisterFrmClass(Tgdc_dlgTRMetaData);

end.
