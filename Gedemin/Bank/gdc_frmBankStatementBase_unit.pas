// ShlTanya, 30.01.2019

unit gdc_frmBankStatementBase_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDHGRAccount_unit, Db, flt_sqlFilter, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, ComCtrls, ToolWin, ExtCtrls, gdcClasses,
  IBCustomDataSet, gdcBase, IBDatabase, IBQuery, StdCtrls, IBSQL,
  gd_security, gd_Security_body, gsIBLookupComboBox, gd_security_OperationConst,
  gdcBaseInterface, gdcContacts, gdcStatement, TB2Item,
  TB2Dock, TB2Toolbar, gdcBaseBank, gdcTree, Buttons, gd_MacrosMenu, Mask,
  xDateEdits;

type
  Tgdc_frmBankStatementBase = class(Tgdc_frmMDHGRAccount)
    gdcBankStatement: TgdcBankStatement;
    Panel1: TPanel;
    lblCurrency: TLabel;
    Label2: TLabel;
    dsCatalogue: TDataSource;
    actSearchClient: TAction;
    N11: TMenuItem;
    sbtnSaldo: TSpeedButton;
    actSaldo: TAction;
    actCreateEntry: TAction;
    actGotoEntry: TAction;
    TBItem1: TTBItem;
    TBItem2: TTBItem;
    lblShowSaldo: TLabel;
    xdeForDate: TxDateEdit;
    procedure FormCreate(Sender: TObject);
    procedure actSaldoExecute(Sender: TObject);
    procedure ibcmbAccountChange(Sender: TObject);
    procedure gdcBankStatementAfterScroll(DataSet: TDataSet);
    procedure gdcBankStatementAfterOpen(DataSet: TDataSet);
    procedure actCreateEntryExecute(Sender: TObject);
    procedure actGotoEntryExecute(Sender: TObject);
    procedure actCreateEntryUpdate(Sender: TObject);
  end;

var
  gdc_frmBankStatementBase: Tgdc_frmBankStatementBase;

implementation

uses
  dmDataBase_unit,  gd_ClassList,
  gdc_frmTransaction_unit, gdcAcctEntryRegister,
  gd_resourcestring;

{$R *.DFM}

procedure Tgdc_frmBankStatementBase.FormCreate(Sender: TObject);
begin
  gdcObject := gdcBankStatement;
  if Assigned(dsDetail.DataSet) then
    gdcDetailObject := dsDetail.DataSet as TgdcBase;

  inherited;
end;

procedure Tgdc_frmBankStatementBase.actSaldoExecute(Sender: TObject);
var
  S, SC: String;
  ibsqlSaldo: TIBSQL;
begin
  if ibcmbAccount.CurrentKeyInt >= 0 then
  begin
    ibsqlSaldo := TIBSQL.Create(nil);
    try
      ibsqlSaldo.Transaction := gdcBaseManager.ReadTransaction;
      ibsqlSaldo.SQL.Text :=
        'SELECT SUM(l.csumncu) as Credit, SUM(l.dsumncu) as Debet, ' +
        '  SUM(l.csumcurr) as CCredit, SUM(l.dsumcurr) as CDebet ' +
        'FROM bn_bankstatementline l ' +
        '  JOIN bn_bankstatement s ' +
        '  ON l.bankstatementkey = s.documentkey ' +
        '  JOIN gd_document doc ' +
        '  ON doc.id = s.documentkey ' +
        'WHERE s.accountkey = :accountkey ' +
        '  AND doc.documentdate <= :ForDate ';
      SetTID(ibsqlSaldo.ParamByName('accountkey'), ibcmbAccount.CurrentKeyInt);
      ibsqlSaldo.ParamByName('fordate').AsDate := xdeForDate.Date;
      ibsqlSaldo.ExecQuery;
      if ibsqlSaldo.FieldByName('Credit').AsCurrency = ibsqlSaldo.FieldByName('Debet').AsCurrency then
        S := '0'
      else
        S := FormatCurr('#,##0.##', ibsqlSaldo.FieldByName('Credit').AsCurrency -
          ibsqlSaldo.FieldByName('Debet').AsCurrency);
      if ibsqlSaldo.FieldByName('CCredit').AsCurrency = ibsqlSaldo.FieldByName('CDebet').AsCurrency then
        SC := '0'
      else
        SC := FormatCurr('#,##0.##', ibsqlSaldo.FieldByName('CCredit').AsCurrency -
          ibsqlSaldo.FieldByName('CDebet').AsCurrency);

      MessageBox(0,
        PChar('В рублях: ' + S + #13#10 + 'В валюте: ' + SC),
        'Текущее сальдо по счету',
        MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
    finally
      ibsqlSaldo.Free;
    end;
  end else
  begin
    MessageBox(Handle,
      'Выберите расчетный счет из выпадающего списка!',
      'Внимание',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
  end;
end;

procedure Tgdc_frmBankStatementBase.ibcmbAccountChange(Sender: TObject);
begin
  inherited;
//  actSaldoExecute(Sender);
end;

procedure Tgdc_frmBankStatementBase.gdcBankStatementAfterScroll(
  DataSet: TDataSet);
begin
  inherited;
  lblCurrency.Caption := gdcBankStatement.FieldByName('currname').AsString;
end;

procedure Tgdc_frmBankStatementBase.gdcBankStatementAfterOpen(
  DataSet: TDataSet);
begin
  inherited;
  lblCurrency.Caption := gdcBankStatement.FieldByName('currname').AsString;
end;

procedure Tgdc_frmBankStatementBase.actCreateEntryExecute(Sender: TObject);
var
  DidActivate: Boolean;
begin
  if MessageBox(HANDLE, 'Провести проводки по списку документов?', 'Внимание',
       mb_YesNo or mb_IconQuestion or mb_TaskModal) = idNo then
    exit;
    
  DidActivate := not gdcObject.Transaction.InTransaction;
  if DidActivate then
    gdcObject.Transaction.StartTransaction;
  try
    try
      if gdcObject.EOF then
        gdcObject.Prior;
      while not gdcObject.EOF do
      begin
        (gdcObject as TgdcDocument).CreateEntry;
        gdcObject.Next;
      end;
    except
      if DidActivate and gdcObject.Transaction.InTransaction then
        gdcObject.Transaction.Rollback;
      raise;
    end;
  finally
    if DidActivate and gdcObject.Transaction.InTransaction then
      gdcObject.Transaction.Commit;
  end;

end;

procedure Tgdc_frmBankStatementBase.actGotoEntryExecute(Sender: TObject);
begin
  Tgdc_frmTransaction.GoToEntries(Self, gdcDetailObject);
end;

procedure Tgdc_frmBankStatementBase.actCreateEntryUpdate(Sender: TObject);
begin
  actCreateEntry.Enabled := (gdcObject <> nil) and gdcObject.CanEdit;
end;

initialization
  RegisterFrmClass(Tgdc_frmBankStatementBase);

finalization
  UnRegisterFrmClass(Tgdc_frmBankStatementBase);
end.
