unit tr_dlgAddEntry_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Db, DBClient, Grids, DBGrids, gsDBGrid, DBCGrids, ActnList,
  Mask, DBCtrls, ComCtrls, Buttons, IBDatabase, IBCustomDataSet, dmDatabase_unit,
  Menus, contnrs, ToolWin, IBSQL, ExtCtrls;

type
  TdlgAddEntry = class(TForm)
    bOk: TButton;
    bNext: TButton;
    bCancel: TButton;
    ActionList1: TActionList;
    actOk: TAction;
    actNext: TAction;
    actCancel: TAction;
    tvAccount: TTreeView;
    ibdsEntry: TIBDataSet;
    IBTransaction: TIBTransaction;
    ibdsEntryLine: TIBDataSet;
    dsDebitEntry: TDataSource;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    actChooseAccount: TAction;
    actChooseAnalytical: TAction;
    actDel: TAction;
    nExpression: TNotebook;
    Label1: TLabel;
    dbedExpressionNCU: TDBEdit;
    dbedExpressionCURR: TDBEdit;
    Label2: TLabel;
    dbedExpressionEq: TDBEdit;
    Label3: TLabel;
    Panel1: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    procedure actChooseAccountExecute(Sender: TObject);
    procedure tvAccountChange(Sender: TObject; Node: TTreeNode);
    procedure actOkExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actNextExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actDelExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure ToolButton3Click(Sender: TObject);
  private
    { Private declarations }
    FEntryKey: Integer;
    FTransactionKey: Integer;
    DebitTreeNode: TTreeNode;
    CreditTreeNode: TTreeNode;

    procedure AddNewAccount(List: TList);
    procedure BeforeAction;
    procedure SetAccountTree;
    function Save: Boolean;
    procedure ShowLineInfo;
    function GetVariable: String;
    procedure PutVarToExpression(const FieldName: String);
  public
    { Public declarations }
    procedure SetupDialog(const aEntryKey, aTransactionKey: Integer);
  end;

var
  dlgAddEntry: TdlgAddEntry;

implementation

{$R *.DFM}

uses tr_dlgChooseAccount_unit, tr_dlgChooseEntryVar_unit;

type
  TAccountLine = class
    ID: Integer;
    AccountKey: Integer;
    Account: String;
    constructor Create(const aID, aAccountKey: Integer; const aAccount: String);
  end;

{ TAccountLine ----------------------------------------------------------------}

constructor TAccountLine.Create(const aID, aAccountKey: Integer; const aAccount: String);
begin
  ID := aID;
  AccountKey := aAccountKey;
  Account := aAccount;
end;

procedure TdlgAddEntry.AddNewAccount(List: TList);
var
  ParentNode: TTreeNode;
  i: Integer;
begin
  if List.Count = 0 then exit;

  if FEntryKey = -1 then
    FEntryKey := GenUniqueID;

  if tvAccount.Selected.Level = 0 then
    ParentNode := tvAccount.Selected
  else
    if tvAccount.Selected.Level = 1 then
      ParentNode := tvAccount.Selected.Parent
    else
      ParentNode := tvAccount.Selected.Parent.Parent;

  for i:= 0 to List.Count - 1 do
  begin
    if ((ParentNode = DebitTreeNode) and (DebitTreeNode.Count >= 1) and
       (CreditTreeNode.Count > 1)) or
       ((ParentNode = CreditTreeNode) and (DebitTreeNode.Count > 1) and
       (CreditTreeNode.Count >= 1))
    then
    begin
      MessageBox(HANDLE, 'Нельзя добавить несколько счетов и по дебету и по кредиту',
        'Внимание', mb_Ok or mb_IconExclamation);
      Break;
    end;

    ibdsEntryLine.Insert;
    ibdsEntryLine.FieldByName('ID').AsInteger := GenUniqueID;
    ibdsEntryLine.FieldByName('EntryKey').AsInteger := FEntryKey;
    ibdsEntryLine.FieldByName('TrTypeKey').AsInteger := FTransactionKey;
    ibdsEntryLine.FieldByName('AccountKey').AsInteger := TAccountLine(List[i]).AccountKey;
    if ParentNode = DebitTreeNode then
      ibdsEntryLine.FieldByName('accounttype').AsString := 'D'
    else
      ibdsEntryLine.FieldByName('accounttype').AsString := 'K';
    ibdsEntryLine.Post;

    TAccountLine(List[i]).ID := ibdsEntryLine.FieldByName('ID').AsInteger;
    tvAccount.Items.AddChildObject(ParentNode, TAccountLine(List[i]).Account,
      List[i]);
  end;
end;

procedure TdlgAddEntry.actChooseAccountExecute(Sender: TObject);
var
  List: TList;
  i: Integer;
begin
  List := TList.Create;
  try
    with TfrmChooseAccount.Create(Self) do
      try
        if ShowModal = mrOk then
        begin
          for i:= 0 to gsibgrAccount.CheckBox.CheckList.Count - 1 do
          begin
            ibdsAccount.Locate('ID', gsibgrAccount.CheckBox.IntCheck[i], []);
            List.Add(TAccountLine.Create(-1, gsibgrAccount.CheckBox.IntCheck[i],
              ibdsAccount.FieldByName('Alias').AsString));
          end;
        end;
      finally
        Free;
      end;
    AddNewAccount(List);
  finally
    List.Free;
  end;
end;

procedure TdlgAddEntry.SetupDialog(const aEntryKey,
  aTransactionKey: Integer);
begin
  FEntryKey := aEntryKey;
  FTransactionKey := aTransactionKey;

  BeforeAction;
  
  if FEntryKey <> -1 then
  begin
    actNext.Enabled := False;
    SetAccountTree;
  end;  

  ShowLineInfo;  
end;

procedure TdlgAddEntry.ShowLineInfo;
begin
  if ibdsEntryLine.State in [dsEdit, dsInsert] then
    ibdsEntryLine.Post;
  ibdsEntryLine.Close;
  if Assigned(tvAccount.Selected) and Assigned(tvAccount.Selected.Data) then
    ibdsEntryLine.Params.ByName('ID').AsInteger := TAccountLine(tvAccount.Selected.Data).ID;
  ibdsEntryLine.Open;
end;

procedure TdlgAddEntry.BeforeAction;
begin
  if not IBTransaction.InTransaction then
    IBTransaction.StartTransaction;
end;

procedure TdlgAddEntry.SetAccountTree;
var
  AccountLine: TAccountLine;
begin
  ibdsEntry.Params.ByName('EK').AsInteger := FEntryKey;
  ibdsEntry.Open;
  ibdsEntry.First;
  while not ibdsEntry.EOF do
  begin
    AccountLine := TAccountLine.Create(ibdsEntry.FieldByName('ID').AsInteger,
      ibdsEntry.FieldByName('AccountKey').AsInteger,
      ibdsEntry.FieldByName('Alias').AsString);

    if ibdsEntry.FieldByName('accounttype').AsString = 'D' then
      tvAccount.Items.AddChildObject(DebitTreeNode, ibdsEntry.FieldByName('Alias').AsString,
        AccountLine)
    else
      tvAccount.Items.AddChildObject(CreditTreeNode, ibdsEntry.FieldByName('Alias').AsString,
        AccountLine);
    ibdsEntry.Next;
  end;
  ibdsEntry.Close;
  DebitTreeNode.Expand(True);
  CreditTreeNode.Expand(True);
end;

procedure TdlgAddEntry.tvAccountChange(Sender: TObject; Node: TTreeNode);
var
  P: TTreeNode;
begin
  P := nil;
  if Assigned(Node.Parent) then
  begin
    P := Node.Parent;
    if Assigned(P.Parent) then
      P := P.Parent;
  end;
  
  if P = nil then
    nExpression.PageIndex := 0
  else
    nExpression.PageIndex := 1;
        
  ShowLineInfo;
end;

procedure TdlgAddEntry.actOkExecute(Sender: TObject);
begin
  if not Save then
  begin
    ModalResult := mrNone;
    abort;
  end;
end;

function TdlgAddEntry.Save: Boolean;
var
  ibsql: TIBSQL;
  CountDebit, CountCredit: Integer;
begin
  Result := False;

  if not DebitTreeNode.HasChildren then
  begin
    MessageBox(HANDLE, 'Необходимо указать счета по дебету', 'Внимание',
      mb_ok or mb_IconExclamation);
    exit;
  end;

  if not CreditTreeNode.HasChildren then
  begin
    MessageBox(HANDLE, 'Необходимо указать счета по кредиту', 'Внимание',
      mb_ok or mb_IconExclamation);
    exit;
  end;

  if ibdsEntryLine.State in [dsEdit, dsInsert] then
    ibdsEntryLine.Post;

  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := IBTransaction;
    ibsql.SQL.Text :=
      Format('SELECT * FROM gd_entry WHERE entrykey = %d and ((not expressionncu IS NULL) or ' +
      '(not expressioncurr IS NULL) or (not expressioneq IS NULL)) and (accounttype = ''D'')',
      [FEntryKey]);
    ibsql.ExecQuery;
    CountDebit := ibsql.RecordCount;
    ibsql.Close;
    ibsql.SQL.Text :=
      Format('SELECT * FROM gd_entry WHERE entrykey = %d and ((not expressionncu IS NULL) or ' +
      '(not expressioncurr IS NULL) or (not expressioneq IS NULL)) and (accounttype = ''K'')',
      [FEntryKey]);
    ibsql.ExecQuery;
    CountCredit := ibsql.RecordCount;
  finally
    ibsql.Free;
  end;

  if (CountDebit > 0) and (CountCredit > 0) then
  begin
    MessageBox(HANDLE, 'Формулы для сумм должны быть введены только или по дебету или по кредиту.',
      'Внимание', mb_Ok or mb_IconExclamation);
    exit;  
  end;

  if IBTransaction.InTransaction then
    IBTransaction.Commit;
    
  Result := True;  
end;

procedure TdlgAddEntry.FormCreate(Sender: TObject);
begin
  DebitTreeNode := tvAccount.Items[0];
  CreditTreeNode := tvAccount.Items[1];
end;

procedure TdlgAddEntry.actNextExecute(Sender: TObject);
begin
  if Save then
    SetupDialog(-1, FTransactionKey);
end;

procedure TdlgAddEntry.actCancelExecute(Sender: TObject);
begin
  Close;
end;

procedure TdlgAddEntry.actDelExecute(Sender: TObject);
begin
  if ibdsEntryLine.State in [dsEdit, dsInsert] then
    ibdsEntryLine.Post;

  if Assigned(tvAccount.Selected) and Assigned(tvAccount.Selected.Data) then
  begin
    if tvAccount.Selected.Level = 1 then
    begin
      if MessageBox(HANDLE, 'Удалить текущий счет', 'Внимание',
         mb_YesNo or mb_IconQuestion) = idYes
      then
      begin
        ibdsEntryLine.Delete;
        tvAccount.Selected.Delete;
      end;  
    end;
  end;
end;

procedure TdlgAddEntry.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if ModalResult <> mrOk then
  begin
    if ibdsEntryLine.State in [dsEdit, dsInsert] then
      ibdsEntryLine.Cancel;

    if IBTransaction.InTransaction then
      IBTransaction.Rollback;
  end;
end;

function TdlgAddEntry.GetVariable: String;
begin
  with TdlgChooseEntryVar.Create(Self) do
    try
      ibdsFields.Transaction := IBTransaction;
      if SetupDialog(FTransactionKey) then
        Result := Variable;
    finally
      Free;
    end;
end;

procedure TdlgAddEntry.PutVarToExpression(const FieldName: String);
begin
  if not (ibdsEntryLine.State in [dsEdit, dsInsert]) then
    ibdsEntryLine.Edit;
  ibdsEntryLine.FieldByName(FieldName).AsString :=
    ibdsEntryLine.FieldByName(FieldName).AsString + GetVariable;
end;

procedure TdlgAddEntry.SpeedButton1Click(Sender: TObject);
begin
  PutVarToExpression('expressionncu');
end;

procedure TdlgAddEntry.SpeedButton2Click(Sender: TObject);
begin
  PutVarToExpression('expressioncurr');
end;

procedure TdlgAddEntry.SpeedButton3Click(Sender: TObject);
begin
  PutVarToExpression('expressioneq');
end;

procedure TdlgAddEntry.ToolButton3Click(Sender: TObject);
begin
  {}
end;

end.
