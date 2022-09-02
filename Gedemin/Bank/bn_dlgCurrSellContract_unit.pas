// ShlTanya, 30.01.2019

unit bn_dlgCurrSellContract_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, Mask, DBCtrls, IBSQL,
  gsIBLookupComboBox, Db, xDateEdits, ComCtrls, ExtCtrls, at_Container,
  gdc_dlgG_unit, Menus;

type
  Tgd_dlgCurrSellContract = class(Tgdc_dlgG)
    Panel1: TPanel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Label1: TLabel;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    iblcCurr: TgsIBLookupComboBox;
    dbedAmount: TDBEdit;
    dbedMinRate: TDBEdit;
    ddbedDocumentDate: TxDateDBEdit;
    Label5: TLabel;
    iblcBankAccountKey: TgsIBLookupComboBox;
    Label6: TLabel;
    iblcBankKey: TgsIBLookupComboBox;
    Label7: TLabel;
    iblcOwnAccountKey: TgsIBLookupComboBox;
    atContainer1: TatContainer;
    Label8: TLabel;
    dbedNumber: TDBEdit;
    procedure FormCreate(Sender: TObject);
    procedure iblcBankKeyChange(Sender: TObject);

  public
  end;

var
  gd_dlgCurrSellContract: Tgd_dlgCurrSellContract;

implementation

{$R *.DFM}

uses
  gd_security, gdcBase, gd_ClassList, gdcBaseInterface;

{ Tgd_dlgCurrSellContract }

procedure Tgd_dlgCurrSellContract.FormCreate(Sender: TObject);
begin
  inherited;
  iblcBankAccountKey.Condition := 'COMPANYKEY = ' + TID2S(IBLogin.CompanyKey);
end;

procedure Tgd_dlgCurrSellContract.iblcBankKeyChange(Sender: TObject);
begin
  if iblcBankKey.CurrentKey > '' then
    iblcBankAccountKey.Condition := 'companykey = ' + iblcBankKey.CurrentKey
  else
    iblcBankAccountKey.Condition := '';
end;

initialization
  RegisterFrmClass(Tgd_dlgCurrSellContract);

finalization
  UnRegisterFrmClass(Tgd_dlgCurrSellContract);

end.
