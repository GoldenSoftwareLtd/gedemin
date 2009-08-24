
{
  Адм. территориальная единица
}

unit gdc_dlgPlace_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, Mask, DBCtrls,
  gsIBLookupComboBox, Db, gdc_dlgTRPC_unit, Menus, gdc_dlgG_unit,
  IBDatabase, at_Container, ComCtrls;

type
  Tgdc_dlgPlace = class(Tgdc_dlgTRPC)
    cbMaster: TgsIBLookupComboBox;
    dbeTelPrefix: TDBEdit;
    dbedName: TDBEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label1: TLabel;
    DBComboBox1: TDBComboBox;
    Label4: TLabel;
    Label5: TLabel;
    dbeCode: TDBEdit;

  public

    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_dlgPlace: Tgdc_dlgPlace;

implementation
{$R *.DFM}

uses
  gdcBase, gd_ClassList;

{ Tgd_dlgPlace }

class function Tgdc_dlgPlace.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_dlgPlace) then
    gdc_dlgPlace := Tgdc_dlgPlace.Create(AnOwner);
  Result := gdc_dlgPlace;
end;

initialization
  RegisterFrmClass(Tgdc_dlgPlace);

finalization
  UnRegisterFrmClass(Tgdc_dlgPlace);
end.
