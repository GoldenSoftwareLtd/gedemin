
 {++
   Project ADDRESSBOOK
   Copyright © 2000- by Golden Software

   Модуль

     gdc_dlgCompany_unit

   Описание

     Окно для работы с компанией

   Автор

    Anton

   История

     ver    date    who    what
     1.00 - 25.06.2001 - anton - Первая версия

 --}


unit gdc_dlgBank_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgCustomCompany_unit, Db, IBCustomDataSet, gdcBase, gdcContacts,
  ActnList, at_Container, ComCtrls, ToolWin, ExtCtrls, gsDBGrid,
  gsDBTreeView, DBCtrls, gsIBLookupComboBox, StdCtrls, Grids, DBGrids,
  Mask, Buttons, gsIBGrid, Menus, IBDatabase, gdcTree,
  TB2Item, TB2Dock, TB2Toolbar;

type
  Tgdc_dlgBank = class(Tgdc_dlgCustomCompany)
    LabelCode: TLabel;
    dbeBankCode: TDBEdit;
    LabelMFO: TLabel;
    dbeBankMFO: TDBEdit;
    lblSWIFT: TLabel;
    dbeSWIFT: TDBEdit;
    lblBankBranch: TLabel;
    dbedBankBranch: TDBEdit;
    procedure FormCreate(Sender: TObject);
  private
  public

  end;

var
  gdc_dlgBank: Tgdc_dlgBank;

implementation

{$R *.DFM}

uses
  gd_ClassList, at_Classes;

procedure Tgdc_dlgBank.FormCreate(Sender: TObject);
var
  F: TatRelationField;
begin
  inherited;
  F := atDatabase.FindRelationField('GD_BANK', 'BANKBRANCH');
  if Assigned(F) then
  begin
    dbedBankBranch.DataField := 'BANKBRANCH';
    dbedBankBranch.Visible := True;
    lblBankBranch.Visible := True;
  end
  else
  begin
    dbedBankBranch.Visible := False;
    lblBankBranch.Visible := False;
  end;  
end;

initialization
  RegisterFrmClass(Tgdc_dlgBank);

finalization
  UnRegisterFrmClass(Tgdc_dlgBank);

end.
