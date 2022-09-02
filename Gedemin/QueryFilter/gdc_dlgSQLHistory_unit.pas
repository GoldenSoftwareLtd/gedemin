// ShlTanya, 10.03.2019

unit gdc_dlgSQLHistory_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTRPC_unit, IBDatabase, Menus, Db, ActnList, at_Container, DBCtrls,
  StdCtrls, ComCtrls, Mask;

type
  Tgdc_dlgSQLHistory = class(Tgdc_dlgTRPC)
    dbmSQL: TDBMemo;
    tsParams: TTabSheet;
    dbmParams: TDBMemo;
    Label1: TLabel;
    dbedBM: TDBEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_dlgSQLHistory: Tgdc_dlgSQLHistory;

implementation

{$R *.DFM}

uses
  gd_ClassList;

initialization
  RegisterFrmClass(Tgdc_dlgSQLHistory);

finalization
  UnRegisterFrmClass(Tgdc_dlgSQLHistory);

end.
