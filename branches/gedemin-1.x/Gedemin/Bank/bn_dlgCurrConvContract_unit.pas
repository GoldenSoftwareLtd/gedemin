
unit bn_dlgCurrConvContract_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, Mask, DBCtrls,
  gsIBLookupComboBox, Db, xDateEdits, ComCtrls, ExtCtrls, at_Container,
  gdc_dlgG_unit, Menus;

type
  Tgd_dlgCurrConvContract = class(Tgdc_dlgG)
    Panel1: TPanel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Label1: TLabel;
    ddbedDocumentDate: TxDateDBEdit;
    atContainer1: TatContainer;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    iblcFromCurrKey: TgsIBLookupComboBox;
    Label3: TLabel;
    dbedFromAmountCurr: TDBEdit;
    iblcFromAccountKey: TgsIBLookupComboBox;
    Label4: TLabel;
    Label5: TLabel;
    dbedNumber: TDBEdit;
    GroupBox2: TGroupBox;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    iblcToCurrKey: TgsIBLookupComboBox;
    dbedtoamountcurr: TDBEdit;
    iblctoaccountkey: TgsIBLookupComboBox;

  public
  end;

var
  gd_dlgCurrConvContract: Tgd_dlgCurrConvContract;

implementation

{$R *.DFM}

uses
  gd_Security, gdcBase, gd_ClassList;


initialization
  RegisterFrmClass(Tgd_dlgCurrConvContract);

finalization
  UnRegisterFrmClass(Tgd_dlgCurrConvContract);

end.
