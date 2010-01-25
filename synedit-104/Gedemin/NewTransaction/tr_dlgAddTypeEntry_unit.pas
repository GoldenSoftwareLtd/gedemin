unit tr_dlgAddTypeEntry_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, DBCtrls, gsIBLookupComboBox, IBDatabase, Db,
  IBCustomDataSet, Grids, DBGrids, gsDBGrid, gsIBGrid, gsIBCtrlGrid,
  dmDatabase_unit, at_Controls, at_sql_setup, ActnList, 
  gd_security;

type
  TdlgAddTypeEntry = class(TForm)
    gsibgrEntry: TgsIBCtrlGrid;
    ibdsEntry: TIBDataSet;
    IBTransaction: TIBTransaction;
    dsEntry: TDataSource;
    ScrollBox1: TScrollBox;
    Label1: TLabel;
    atSQLSetup: TatSQLSetup;
    atEditor: TatEditor;
    bOk: TButton;
    bNext: TButton;
    bVariable: TButton;
    gsiblcAccount: TgsIBLookupComboBox;
    ActionList1: TActionList;
    actOk: TAction;
    actCancel: TAction;
    actVariable: TAction;
    dbcbAccountType: TDBComboBox;
    bCancel: TButton;
    actNext: TAction;
    bRelation: TButton;
    actAnalyzeRelation: TAction;
    procedure FormCreate(Sender: TObject);
    procedure ibdsEntryAfterInsert(DataSet: TDataSet);
    procedure ibdsEntryBeforePost(DataSet: TDataSet);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actVariableExecute(Sender: TObject);
    procedure actVariableUpdate(Sender: TObject);
    procedure ibdsEntryBeforeInsert(DataSet: TDataSet);
    procedure actNextExecute(Sender: TObject);
    procedure actAnalyzeRelationExecute(Sender: TObject);
    procedure gsibgrEntrySetCtrl(Sender: TObject; Ctrl: TWinControl;
      Column: TColumn; var Show: Boolean);
    procedure gsiblcAccountExit(Sender: TObject);
    procedure dbcbAccountTypeExit(Sender: TObject);
  private
    FEntryKey: Integer;
    FTrTypeKey: Integer;
    { DONE 1 -oденис -cнедочет : Где префикс F }
    FInTransaction: Boolean;

    function Save: Boolean;
    function Check: Boolean;
    procedure DoAccountChange(Sender: TField);
    function GetVariable: String;
    procedure AccountTypeGetText(Sender: TField; var Text: String; DisplayText: Boolean);
    procedure AccountTypeSetText(Sender: TField; const Text: String);
  public
    { Public declarations }
    procedure SetupDialog(const aEntryKey, aTrTypeKey: Integer);
    property EntryKey: Integer read FEntryKey;
  end;

var
  dlgAddTypeEntry: TdlgAddTypeEntry;

implementation

{$R *.DFM}

uses
  tr_dlgChooseEntryVar_unit, tr_dlgSetRelAnalyzeAndDocField_unit, Storages;

procedure TdlgAddTypeEntry.FormCreate(Sender: TObject);
var
  OldOnExit: TNotifyEvent;
  OldOnKeyDown: TKeyEvent;
begin
  OldOnExit := gsiblcAccount.OnExit;
  OldOnKeyDown := gsiblcAccount.OnKeyDown;
  gsibgrEntry.AddControl('ALIAS', gsiblcAccount, OldOnExit,
    OldOnKeyDown);
  gsiblcAccount.OnExit := OldOnExit;
  gsiblcAccount.OnKeyDown := OldOnKeyDown;

  OldOnExit := dbcbAccountType.OnExit;
  OldOnKeyDown := dbcbAccountType.OnKeyDown;
  gsibgrEntry.AddControl('AccountType', dbcbAccountType, OldOnExit,
    OldOnKeyDown);
  dbcbAccountType.OnExit := OldOnExit;
  dbcbAccountType.OnKeyDown := OldOnKeyDown;
  FInTransaction := False;

  UserStorage.LoadComponent(gsibgrEntry, gsibgrEntry.LoadFromStream);

  gsiblcAccount.Condition :=
    Format(
    'GRADE >= 2 ' +
    'AND ' +
    'LB >= (SELECT LB FROM gd_cardaccount c1 JOIN gd_cardcompany cc ' +
    '         ON c1.ID = cc.cardaccountkey AND cc.activecard = 1 AND cc.ourcompanykey = %0:d) ' +
    'AND ' +
    'RB <= (SELECT RB FROM gd_cardaccount c1 JOIN gd_cardcompany cc ' +
    '         ON c1.ID = cc.cardaccountkey AND cc.activecard = 1 AND cc.ourcompanykey = %0:d) ',
    [IBLogin.CompanyKey]);
end;

procedure TdlgAddTypeEntry.SetupDialog(const aEntryKey,
  aTrTypeKey: Integer);
var
  i: Integer;  
begin

  if not ibdsEntry.Transaction.InTransaction then
    ibdsEntry.Transaction.StartTransaction
  else
    FInTransaction := True;  
    
  FEntryKey := aEntryKey;
  FTrTypeKey := aTrTypeKey;

  if aEntryKey = -1 then
    FEntryKey := GenUniqueID
  else
    actNext.Enabled := False;  

  ibdsEntry.ParamByName('ek').AsInteger := FEntryKey;
  ibdsEntry.Open;

  for i:= 0 to ibdsEntry.FieldCount - 1 do
    ibdsEntry.Fields[i].Required := False;

  ibdsEntry.FieldByName('accountkey').OnChange := DoAccountChange;
  ibdsEntry.FieldByName('accounttype').OnGetText := AccountTypeGetText;
  ibdsEntry.FieldByName('accounttype').OnSetText := AccountTypeSetText;  
end;

procedure TdlgAddTypeEntry.ibdsEntryAfterInsert(DataSet: TDataSet);
begin
  ibdsEntry.FieldByName('EntryKey').AsInteger := FEntryKey;
  ibdsEntry.FieldByName('TrTypeKey').AsInteger := FTrTypeKey;
  ibdsEntry.FieldByName('id').AsInteger := GenUniqueID;
end;

procedure TdlgAddTypeEntry.ibdsEntryBeforePost(DataSet: TDataSet);
begin
  if ibdsEntry.FieldByName('AccountKey').IsNull and
     ibdsEntry.FieldByName('ExpressionNCU').IsNull and
     ibdsEntry.FieldByName('ExpressionCurr').IsNull and
     ibdsEntry.FieldByName('ExpressionEq').IsNull
  then
  begin
    ibdsEntry.Cancel;
    abort;
  end;
end;

function TdlgAddTypeEntry.Save: Boolean;
begin
  Result := Check;
  if Result then
  begin
    try
      if ibdsEntry.State in [dsEdit, dsInsert] then
        ibdsEntry.Post;
      ibdsEntry.ApplyUpdates;
      if ibdsEntry.Transaction.InTransaction and not FInTransaction then
        ibdsEntry.Transaction.Commit;
    except
      on E: Exception do
      begin
        MessageBox(HANDLE, PChar(Format('При сохранении возникла ошибка %s.', [E.Message])),
          'Внимание', mb_Ok or mb_IconInformation);
        Result := False;
      end;  
    end;
  end;
end;

function TdlgAddTypeEntry.Check: Boolean;
var
  CountDebit, CountCredit, CountDebitNCU, CountCreditNCU: Integer;
  Bookmark: TBookmark;
begin
  Result := False;

  CountDebit := 0;
  CountCredit := 0;
  CountDebitNCU := 0;
  CountCreditNCU := 0;
  
  Bookmark := ibdsEntry.GetBookmark;
  ibdsEntry.DisableControls;
  try

    ibdsEntry.First;
    while not ibdsEntry.EOF do
    begin
      if ibdsEntry.FieldByName('AccountType').AsString = 'D' then
      begin
        Inc(CountDebit);
        if ibdsEntry.FieldByName('expressionncu').AsString > '' then
          Inc(CountDebitNCU);
      end
      else
      begin
        Inc(CountCredit);
        if ibdsEntry.FieldByName('expressionncu').AsString > '' then
          Inc(CountCreditNCU);
      end;
      ibdsEntry.Next;
    end;

  finally
    ibdsEntry.GotoBookmark(Bookmark);
    ibdsEntry.FreeBookmark(Bookmark);
    ibdsEntry.EnableControls;
  end;

  if (CountDebit > 1) and (CountCredit > 1) then
  begin
    MessageBox(HANDLE,
      'В проводке не может быть одновременно несколько счетов по дебету и по кредиту!',
      'Внимание', mb_Ok or mb_IconInformation);
    exit;
  end;

  if (CountDebit = 0) or (CountCredit = 0) then
  begin
    MessageBox(HANDLE,
      'Проводка должна содержать счета по дебету и по кредиту!',
      'Внимание', mb_Ok or mb_IconInformation);
    exit;
  end;

  if (CountDebitNCU > 0) and (CountCreditNCU > 0) then
  begin
    MessageBox(HANDLE,
      'Формулы должны быть введены или по дебету или по кредиту!',
      'Внимание', mb_OK or mb_IconInformation);
    exit;   
  end;

  Result := True;

end;

procedure TdlgAddTypeEntry.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if ModalResult <> mrOk then
  begin
    if MessageBox(HANDLE, 'Закрыть окно без сохранения изменений?', 'Внимание',
       mb_YesNo or mb_IconQuestion) = idYes
    then
    begin
      try
        if ibdsEntry.State in [dsEdit, dsInsert] then
          ibdsEntry.Cancel;
        ibdsEntry.CancelUpdates;

        if ibdsEntry.Transaction.InTransaction and not FInTransaction then
          ibdsEntry.Transaction.RollBack;
      except
        if ibdsEntry.Transaction.InTransaction and not FInTransaction then
          ibdsEntry.Transaction.RollBack;
      end;
    end
    else
    begin
      ModalResult := mrNone;
      abort;
    end;
  end;
end;

procedure TdlgAddTypeEntry.actOkExecute(Sender: TObject);
begin
  if Save then
    ModalResult := mrOk;
end;

procedure TdlgAddTypeEntry.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TdlgAddTypeEntry.FormDestroy(Sender: TObject);
begin
  UserStorage.SaveComponent(gsibgrEntry, gsibgrEntry.SaveToStream);
end;

procedure TdlgAddTypeEntry.DoAccountChange(Sender: TField);
begin
  if not Sender.IsNull then
    ibdsEntry.FieldByName('Alias').AsString := gsiblcAccount.Text
  else
    ibdsEntry.FieldByName('Alias').Clear;
end;

procedure TdlgAddTypeEntry.actVariableExecute(Sender: TObject);
begin
  if not (ibdsEntry.State in [dsEdit, dsInsert]) then
    ibdsEntry.Edit;

  gsibgrEntry.SelectedField.AsString := gsibgrEntry.SelectedField.AsString + GetVariable; 
end;

procedure TdlgAddTypeEntry.actVariableUpdate(Sender: TObject);
begin
  actVariable.Enabled := Pos('EXPRESSION', UpperCase(gsibgrEntry.SelectedField.FieldName)) > 0;
end;

function TdlgAddTypeEntry.GetVariable: String;
begin
  with TdlgChooseEntryVar.Create(Self) do
    try
      ibdsFields.Transaction := ibdsEntry.Transaction;
      if SetupDialog(FTrTypeKey) then
        Result := Variable;
    finally
      Free;
    end;
end;

procedure TdlgAddTypeEntry.AccountTypeGetText(Sender: TField;
  var Text: String; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    if Sender.AsString = 'D' then
      Text := 'Дебет'
    else
      Text := 'Кредит';
end;

procedure TdlgAddTypeEntry.AccountTypeSetText(Sender: TField;
  const Text: String);
begin
  if Text = 'Дебет' then
    Sender.AsString := 'D'
  else
    if Text = 'Кредит' then
      Sender.AsString := 'K'
    else
      Sender.Clear;    
end;

procedure TdlgAddTypeEntry.ibdsEntryBeforeInsert(DataSet: TDataSet);
begin
  gsibgrEntry.SelectedField := ibdsEntry.FieldByName('Alias');
end;

procedure TdlgAddTypeEntry.actNextExecute(Sender: TObject);
begin
  if Save then
  begin
    SetupDialog(-1, FTrTypeKey);
    gsibgrEntry.SetFocus;
  end;  
end;

procedure TdlgAddTypeEntry.actAnalyzeRelationExecute(Sender: TObject);
begin
  with TdlgSetRelAnalyzeAndDocField.Create(Self) do
    try
      SetupDialog(ibdsEntry.FieldByName('id').AsInteger,
        FTrTypeKey,
        ibdsEntry.FieldByName('accountkey').AsInteger, ibdsEntry.Transaction);
      ShowModal;
    finally
      Free;
    end;
end;

procedure TdlgAddTypeEntry.gsibgrEntrySetCtrl(Sender: TObject;
  Ctrl: TWinControl; Column: TColumn; var Show: Boolean);
begin
  if not (ibdsEntry.State in [dsEdit, dsInsert]) then
    ibdsEntry.Edit;
end;

procedure TdlgAddTypeEntry.gsiblcAccountExit(Sender: TObject);
begin
  if ibdsEntry.State in [dsEdit, dsInsert] then
    DoAccountChange(ibdsEntry.FieldByName('AccountKey'));
  SendMessage(gsibgrEntry.Handle, WM_KEYDOWN, VK_TAB, 0);
end;

procedure TdlgAddTypeEntry.dbcbAccountTypeExit(Sender: TObject);
begin
  SendMessage(gsibgrEntry.Handle, WM_KEYDOWN, VK_TAB, 0);
end;

end.
