unit gdc_dlgFKManager_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTRPC_unit, IBDatabase, Menus, Db, ActnList, at_Container, DBCtrls,
  StdCtrls, ComCtrls, Mask;

type
  Tgdc_dlgFKManager = class(Tgdc_dlgTRPC)
    Label1: TLabel;
    dbedConstraintName: TDBEdit;
    Label2: TLabel;
    dbedConstraintRel: TDBEdit;
    Label3: TLabel;
    dbedConstraintField: TDBEdit;
    Label4: TLabel;
    dbedRefRel: TDBEdit;
    Label5: TLabel;
    dbedRefField: TDBEdit;
    Label6: TLabel;
    dbedUpdateRule: TDBEdit;
    Label7: TLabel;
    dbedDeleteRule: TDBEdit;
    Label8: TLabel;
    dbedRefState: TDBEdit;
    Label9: TLabel;
    dbcbRefNextState: TDBComboBox;
    Button1: TButton;
    actShowValues: TAction;
    Label10: TLabel;
    DBText1: TDBText;
    Label11: TLabel;
    DBText2: TDBText;
    Label12: TLabel;
    DBText3: TDBText;
    procedure actShowValuesExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_dlgFKManager: Tgdc_dlgFKManager;

implementation

{$R *.DFM}

uses
  gd_ClassList, flt_frmSQLEditorSyn_unit;

procedure Tgdc_dlgFKManager.actShowValuesExecute(Sender: TObject);
begin
  with TfrmSQLEditorSyn.Create(nil) do
  try
    ShowSQL(
      'SELECT ' + Trim(gdcObject.FieldByName('constraint_field').AsString) + ', COUNT(*)' +
      ' FROM ' + Trim(gdcObject.FieldByName('constraint_rel').AsString) +
      ' GROUP BY 1 ORDER BY 2 DESC');
  finally
    Free;
  end;
end;

initialization
  RegisterFrmClass(Tgdc_dlgFKManager);

finalization
  UnRegisterFrmClass(Tgdc_dlgFKManager);

end.
