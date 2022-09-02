// ShlTanya, 30.01.2019

unit bn_dlgCurrListAllocation_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, Mask, DBCtrls,
  gsIBLookupComboBox, Db, xDateEdits, ComCtrls, ExtCtrls, at_Container,
  gdc_dlgG_unit, Menus;

type
  Tgd_dlgCurrListAllocation = class(Tgdc_dlgG)
    Panel1: TPanel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Label1: TLabel;
    ddbedDocumentDate: TxDateDBEdit;
    atContainer1: TatContainer;
    Label2: TLabel;
    iblcCurrKey: TgsIBLookupComboBox;
    Label3: TLabel;
    dbedAmountCurr: TDBEdit;
    Label4: TLabel;
    iblcAccountKey: TgsIBLookupComboBox;
    Label5: TLabel;
    ddbedDateEnter: TxDateDBEdit;
    Label6: TLabel;
    dbedamountnotpay: TDBEdit;
    Label7: TLabel;
    dbedamountpay: TDBEdit;
    Label8: TLabel;
    dbedamountpayed: TDBEdit;
    Label9: TLabel;
    dbmBaseText: TDBMemo;
    Label10: TLabel;
    dbedNumber: TDBEdit;

  public
  end;

var
  gd_dlgCurrListAllocation: Tgd_dlgCurrListAllocation;

implementation

{$R *.DFM}

uses
  gd_Security, gdcBase, gd_ClassList;

initialization
  RegisterFrmClass(Tgd_dlgCurrListAllocation);

finalization
  UnRegisterFrmClass(Tgd_dlgCurrListAllocation);

end.
