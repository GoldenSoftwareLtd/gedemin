// ShlTanya, 30.01.2019

unit bn_dlgCurrCommissSell_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, Mask, DBCtrls,
  gsIBLookupComboBox, Db, xDateEdits, ComCtrls, ExtCtrls, at_Container,
  gdc_dlgG_unit, Menus;

type
  Tgd_dlgCurrCommissSell = class(Tgdc_dlgG)
    Panel1: TPanel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Label1: TLabel;
    dbedNumber: TDBEdit;
    Label2: TLabel;
    ddbedDocumentDate: TxDateDBEdit;
    Label3: TLabel;
    iblcBank: TgsIBLookupComboBox;
    Label4: TLabel;
    dbedPercent: TDBEdit;
    Label5: TLabel;
    iblcAccountKey: TgsIBLookupComboBox;
    Label6: TLabel;
    dbedTimeInt: TDBEdit;
    Label7: TLabel;
    dbedComPercent: TDBEdit;
    Label8: TLabel;
    iblcToAccountKey: TgsIBLookupComboBox;
    Label9: TLabel;
    iblcToCurrAccountKey: TgsIBLookupComboBox;
    Label10: TLabel;
    ddbedDateValid: TxDateDBEdit;
    atContainer1: TatContainer;
    procedure iblcBankChange(Sender: TObject);

  public
  end;

var
  gd_dlgCurrCommissSell: Tgd_dlgCurrCommissSell;

implementation

{$R *.DFM}

uses
  gd_Security, gdcBase, gd_ClassList, gdcBaseInterface;

{ Tgd_dlgCurrCommissSell }

procedure Tgd_dlgCurrCommissSell.iblcBankChange(Sender: TObject);
begin
  if iblcBank.CurrentKey > '' then
    iblcAccountKey.Condition := 'companykey = ' + TID2S(IBLogin.CompanyKey) +
      ' AND bankkey = ' + iblcBank.CurrentKey
  else
    iblcAccountKey.Condition := 'companykey = ' + TID2S(IBLogin.CompanyKey);
end;

initialization
  RegisterFrmClass(Tgd_dlgCurrCommissSell);

finalization
  UnRegisterFrmClass(Tgd_dlgCurrCommissSell);

end.
