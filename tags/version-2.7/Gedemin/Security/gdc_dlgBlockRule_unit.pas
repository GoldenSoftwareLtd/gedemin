unit gdc_dlgBlockRule_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_ClassList, gdc_dlgTRPC_unit, Db, IBCustomDataSet, gdcBase, gdcBlockRule,
  IBDatabase, Menus, ActnList, at_Container, DBCtrls, StdCtrls, ComCtrls;

type
  Tgdc_dlgBlockRule = class(Tgdc_dlgTRPC)
    gdcBlockRule: TgdcBlockRule;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_dlgBlockRule: Tgdc_dlgBlockRule;

implementation

{$R *.DFM}


procedure Tgdc_dlgBlockRule.FormCreate(Sender: TObject);
begin
  gdcObject := gdcBlockRule;
  inherited;
end;

initialization
  RegisterFrmClass(Tgdc_dlgBlockRule);

finalization
  UnRegisterFrmClass(Tgdc_dlgBlockRule);

end.
