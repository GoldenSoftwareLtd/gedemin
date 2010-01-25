
 {++
   Copyright © 2000- by Golden Software

   Модуль

     gdc_dlgCompanyAccount_unit

   Описание

     Диалог для ввода счетов предприятия

   Автор

     Anton

   История

     ver    date    who    what
     1.00 - 21.06.2000 - anton - Первая версия

 --}

unit gdc_dlgCompanyAccount_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Db, IBCustomDataSet, IBQuery, ActnList, IBSQL,
  gsIBLookupComboBox, Buttons, DBCtrls, Mask, IBDatabase, gd_resourcestring,
  gdcBase, gdcContacts, gdc_dlgTRPC_unit, Menus, gdc_dlgTR_unit,
  at_Container, ComCtrls;

type
  Tgdc_dlgCompanyAccount = class(Tgdc_dlgTRPC)
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label10: TLabel;
    Bevel1: TBevel;
    gsibluBank: TgsIBLookupComboBox;
    dbeAccount: TDBEdit;
    gsibluCurr: TgsIBLookupComboBox;
    gsibluBankCode: TgsIBLookupComboBox;
    gsibluMFO: TgsIBLookupComboBox;
    gsibluAccountType: TgsIBLookupComboBox;
    dbcbDisabled: TDBCheckBox;
    gsibluCompany: TgsIBLookupComboBox;
    lblCompany: TLabel;
  end;

var
  gdc_dlgCompanyAccount: Tgdc_dlgCompanyAccount;

implementation

{$R *.DFM}

uses
  dmDataBase_unit,
  gsDesktopManager, gd_ClassList;


initialization
  RegisterFrmClass(Tgdc_dlgCompanyAccount);

finalization
  UnRegisterFrmClass(Tgdc_dlgCompanyAccount);

end.

