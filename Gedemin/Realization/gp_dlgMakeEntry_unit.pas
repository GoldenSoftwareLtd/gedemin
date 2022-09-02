// ShlTanya, 11.03.2019

unit gp_dlgMakeEntry_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, xDateEdits, gsTransaction, IBDatabase, dmDatabase_unit,
  Db, IBCustomDataSet, at_sql_setup, ExtCtrls, ComCtrls, IBSQL;

type
  TdlgMakeEntry = class(TForm)
    Label1: TLabel;
    xdeDateBegin: TxDateEdit;
    xdeDateEnd: TxDateEdit;
    Label2: TLabel;
    cbUseOnlyNew: TCheckBox;
    bOk: TButton;
    bCancel: TButton;
    gsTransaction: TgsTransaction;
    IBTransaction: TIBTransaction;
    ibdsRealPos: TIBDataSet;
    dsRealPos: TDataSource;
    atSQLSetup: TatSQLSetup;
    rgTransaction: TRadioGroup;
    ibdsDocReal: TIBDataSet;
    dsDocReal: TDataSource;
    ProgressBar: TProgressBar;
    Label3: TLabel;
    ibsqlRecordCount: TIBSQL;
    cbCheckTransaction: TCheckBox;
    procedure bOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FDocumentTypeKey: TID;
    procedure SetDocumentTypeKey(const Value: TID);
    { Private declarations }
  public
    { Public declarations }
    property DocumentTypeKey: TID read FDocumentTypeKey write SetDocumentTypeKey; 
  end;

var
  dlgMakeEntry: TdlgMakeEntry;

implementation

{$R *.DFM}

uses
  xAppReg;


procedure TdlgMakeEntry.bOkClick(Sender: TObject);
var
  i: Integer;
begin
  if not IBTransaction.InTransaction then
    IBTransaction.StartTransaction;

  try
    if cbUseOnlyNew.Checked then
    begin
      ibdsRealPos.SelectSQL.Text :=
        ibdsRealPos.SelectSQL.Text + ' AND docp.trtypekey IS NULL';
    end;

    ibdsDocReal.Prepare;
    ibdsDocReal.ParamByName('DateBegin').AsDateTime := xdeDateBegin.Date;
    SetTID(ibdsDocReal.ParamByName('DT'), DocumentTypeKey);
    ibdsDocReal.ParamByName('DateEnd').AsDateTime := xdeDateEnd.Date;

    ibsqlRecordCount.Prepare;
    ibsqlRecordCount.ParamByName('DateBegin').AsDateTime := xdeDateBegin.Date;
    ibsqlRecordCount.ParamByName('DateEnd').AsDateTime := xdeDateEnd.Date;

    if (rgTransaction.ItemIndex = 0) and cbUseOnlyNew.Checked then
      ibdsDocReal.SelectSQL.Text := ibdsDocReal.SelectSQL.Text + ' AND doc.trtypekey IS NULL';

    ibdsDocReal.Open;

    for i:= 0 to ibdsDocReal.FieldCount - 1 do
      ibdsDocReal.Fields[i].Required := False;

    if (rgTransaction.ItemIndex > 0) then
    begin
      ibdsRealPos.Open;
      for i:= 0 to ibdsRealPos.FieldCount - 1 do
        ibdsRealPos.Fields[i].Required := False;
    end;


    gsTransaction.AddConditionDataSet([ibdsDocReal]);
    if (rgTransaction.ItemIndex > 0) then
      gsTransaction.AddConditionDataSet([ibdsRealPos]);

    if rgTransaction.ItemIndex > 0 then
    begin
      gsTransaction.SetStartTransactionInfo(False);

      ibsqlRecordCount.ExecQuery;

      ProgressBar.Max := ibsqlRecordCount.Fields[0].AsInteger;
      ProgressBar.Min := 0;
      ProgressBar.Position := 0;

      while not ibdsDocReal.EOF do
      begin
        gsTransaction.CreateTransactionOnDataSet(
          GetTID(ibdsDocReal.FieldByName('currkey')),
          ibdsDocReal.FieldByName('documentdate').AsDateTime,
          nil, nil, cbCheckTransaction.Checked);
        ibdsDocReal.Next;
        ProgressBar.Position := ProgressBar.Position + 1;
        Application.ProcessMessages;
      end;

      ibdsRealPos.Close;
    end;

    if (rgTransaction.ItemIndex = 0) or (rgTransaction.ItemIndex = 2) then
    begin
      gsTransaction.DocumentOnly := True;
      gsTransaction.DataSource := dsDocReal;
      gsTransaction.SetStartTransactionInfo(False);
      gsTransaction.CreateTransactionOnDataSet(GetTID(ibdsDocReal.FieldByName('currkey')),
        ibdsDocReal.FieldByName('documentdate').AsDateTime,
        nil, nil, cbCheckTransaction.Checked);
      gsTransaction.DocumentOnly := False;
    end;

    ibdsDocReal.Close;

    if IBTransaction.InTransaction then
      IBTransaction.Commit;

    if MessageBox(HANDLE, 'Формирование проводок завершено успешно. Выйти из режима ?',
      'Внимание', mb_YesNo or mb_IconQuestion) = idYes
    then
      ModalResult := mrOk;

  except
    if IBTransaction.InTransaction then
      IBTransaction.RollBack;
  end;

end;

procedure TdlgMakeEntry.SetDocumentTypeKey(const Value: TID);
begin
  FDocumentTypeKey := Value;
  gsTransaction.DocumentType := FDocumentTypeKey;
end;

procedure TdlgMakeEntry.FormCreate(Sender: TObject);
begin
  xdeDateBegin.Date :=  AppRegistry.ReadDate('Entry_Date', 'DateBegin', Date);
  xdeDateEnd.Date := AppRegistry.ReadDate('Entry_Date', 'DateEnd', Date);
end;

procedure TdlgMakeEntry.FormDestroy(Sender: TObject);
begin
  AppRegistry.WriteDate('Entry_Date', 'DateBegin', xdeDateBegin.Date);
  AppRegistry.WriteDate('Entry_Date', 'DateEnd', xdeDateEnd.Date);
end;

end.



