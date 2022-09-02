// ShlTanya, 30.01.2019

unit bn_dlgCurrBuyContract_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, Mask, DBCtrls, IBSQL,
  gsIBLookupComboBox, Db, xDateEdits, ComCtrls, ExtCtrls, at_Container,
  gdc_dlgG_unit, Menus;

type
  Tgd_dlgCurrBuyContract = class(Tgdc_dlgG)
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
    dbedAmountCurr: TDBEdit;
    dbedMaxRate: TDBEdit;
    ddbedDocumentDate: TxDateDBEdit;
    Label5: TLabel;
    iblcAccountKey: TgsIBLookupComboBox;
    Label6: TLabel;
    atContainer1: TatContainer;
    Label8: TLabel;
    dbedAmountNCU: TDBEdit;
    Label7: TLabel;
    iblcCorrCompKey: TgsIBLookupComboBox;
    Label9: TLabel;
    dbmDestination: TDBMemo;
    Label10: TLabel;
    dbedPercent: TDBEdit;
    Label11: TLabel;
    dbedNumber: TDBEdit;
    lbBank: TLabel;
    procedure iblcAccountKeyChange(Sender: TObject);

  public
  end;

var
  gd_dlgCurrBuyContract: Tgd_dlgCurrBuyContract;

implementation

{$R *.DFM}

uses
  gd_Security, gdcBase, gd_ClassList;

{ Tgd_dlgCurrBuyContract }

procedure Tgd_dlgCurrBuyContract.iblcAccountKeyChange(Sender: TObject);
var
  ibsql: TIBSQL;
begin
  if iblcAccountKey.CurrentKey > '' then
  begin
    ibsql := TIBSQL.Create(nil);
    try
      ibsql.Transaction := gdcObject.Transaction;
      ibsql.SQL.Text := 'SELECT b.name FROM gd_companyaccount c, gd_contact b WHERE c.id = ' +
        iblcAccountKey.CurrentKey + ' and c.bankkey = b.id ';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 1 then
        lbBank.Caption := ibsql.FieldByName('name').AsString
      else
        lbBank.Caption := '';
      ibsql.Close;
    finally
      ibsql.Free;
    end;
  end;
end;

initialization
  RegisterFrmClass(Tgd_dlgCurrBuyContract);

finalization
  UnRegisterFrmClass(Tgd_dlgCurrBuyContract);

end.
