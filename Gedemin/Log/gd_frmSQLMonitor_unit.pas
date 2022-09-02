// ShlTanya, 24.02.2019

unit gd_frmSQLMonitor_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_createable_form, gdSQLMonitor, StdCtrls, SynEditHighlighter,
  SynHighlighterSQL, SynEdit, ExtCtrls, syn_ManagerInterface_body_unit,
  ActnList, ComCtrls, IBDatabase;

type
  Tgd_frmSQLMonitor = class(TCreateableForm)
    Panel1: TPanel;
    btnUpdate: TButton;
    SynSQLSyn: TSynSQLSyn;
    btnClear: TButton;
    btnFlush: TButton;
    gbTraceFlags: TGroupBox;
    chbxTracePrepare: TCheckBox;
    chbxTraceExecute: TCheckBox;
    chbxTraceFetch: TCheckBox;
    chbxTraceError: TCheckBox;
    chbxTraceStatement: TCheckBox;
    chbxTraceConnect: TCheckBox;
    chbxTraceTransact: TCheckBox;
    chbxTraceBlob: TCheckBox;
    chbxTraceService: TCheckBox;
    chbxTraceMisc: TCheckBox;
    ActionList: TActionList;
    actUpdate: TAction;
    Label1: TLabel;
    lblSize: TLabel;
    actClear: TAction;
    actFlush: TAction;
    actClose: TAction;
    btnClose: TButton;
    chbxSQLMonitor: TCheckBox;
    btnForm: TButton;
    actForm: TAction;
    pc: TPageControl;
    tsSQLMonitor: TTabSheet;
    tsTransactions: TTabSheet;
    SynEdit: TSynEdit;
    lvTransactions: TListView;
    pnlTransaction: TPanel;
    btnRefreshTransactions: TButton;
    actRefreshTransactions: TAction;
    actStart: TAction;
    btnStart: TButton;
    actCommit: TAction;
    actRollback: TAction;
    btnCommit: TButton;
    btnRollback: TButton;
    chbxOnlyActive: TCheckBox;
    tsDatasets: TTabSheet;
    Panel2: TPanel;
    btnRefreshDatasets: TButton;
    chbxOnlyActiveDataSet: TCheckBox;
    lvDataSets: TListView;
    actRefreshDatasets: TAction;
    procedure FormCreate(Sender: TObject);
    procedure actUpdateExecute(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
    procedure actFlushExecute(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure chbxTracePrepareClick(Sender: TObject);
    procedure chbxSQLMonitorClick(Sender: TObject);
    procedure actFormExecute(Sender: TObject);
    procedure actFormUpdate(Sender: TObject);
    procedure actFlushUpdate(Sender: TObject);
    procedure actRefreshTransactionsExecute(Sender: TObject);
    procedure actRefreshTransactionsUpdate(Sender: TObject);
    procedure pcChange(Sender: TObject);
    procedure actStartUpdate(Sender: TObject);
    procedure actStartExecute(Sender: TObject);
    procedure actCommitUpdate(Sender: TObject);
    procedure actCommitExecute(Sender: TObject);
    procedure actRollbackExecute(Sender: TObject);
    procedure chbxOnlyActiveClick(Sender: TObject);
    procedure actRefreshDatasetsUpdate(Sender: TObject);
    procedure actRefreshDatasetsExecute(Sender: TObject);
    procedure chbxOnlyActiveDataSetClick(Sender: TObject);

  private
    function CheckTransaction(Tr: Pointer): TIBTransaction;
    procedure Warning;  
  end;

var
  gd_frmSQLMonitor: Tgd_frmSQLMonitor;

implementation

{$R *.DFM}

uses
  IB, IBSQLMonitor, IBCustomDataSet, gd_security, syn_ManagerInterface_unit, Storages,
  gdcSQLStatement;

procedure Tgd_frmSQLMonitor.FormCreate(Sender: TObject);
var
  T: TTraceFlag;
  I: Integer;
begin
  if Assigned(GlobalStorage) then
  begin
    chbxSQLMonitor.Checked := GlobalStorage.ReadBoolean('Options', 'MSQL', False, False);
    IBLogin.Database.TraceFlags := IntegerToTraceFlags(GlobalStorage.ReadInteger('Options', 'MSQLF', 0, False));
  end;

  if SQLMonitor = nil then
  begin
    SQLMonitor := TgdSQLMonitor.Create(nil);
  end;

  for T := tfQPrepare to tfMisc do
  begin
    for I := 0 to ComponentCount - 1 do
    begin
      if (Pos('chbxTrace', Components[I].Name) = 1)
        and (Components[I].Tag = Integer(T)) then
      begin
        (Components[I] as TCheckBox).Checked := T in IBLogin.Database.TraceFlags;
      end;
    end;
  end;

  ShowSpeedButton := True;
  //SynManager.GetSynEditOptions(SynEdit);
  SynManager.GetHighlighterOptions(SynSQLSyn);

  actUpdate.Execute;
end;

procedure Tgd_frmSQLMonitor.actUpdateExecute(Sender: TObject);
begin
  SQLMonitor.Unload(SynEdit.Lines);
  lblSize.Caption := IntToStr(SQLMonitor.GetSize div 1024);
  actRefreshTransactions.Execute;
  actRefreshDataSets.Execute;
end;

procedure Tgd_frmSQLMonitor.actClearExecute(Sender: TObject);
begin
  SQLMonitor.Clear;
  actUpdate.Execute;
end;

procedure Tgd_frmSQLMonitor.actFlushExecute(Sender: TObject);
begin
  SQLMonitor.Flush;
  actUpdate.Execute;
end;

procedure Tgd_frmSQLMonitor.actCloseExecute(Sender: TObject);
begin
  Close;
end;

procedure Tgd_frmSQLMonitor.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure Tgd_frmSQLMonitor.chbxTracePrepareClick(Sender: TObject);
var
  T: TTraceFlag;
begin
  T := TTraceFlag((Sender as TCheckBox).Tag);
  if (Sender as TCheckBox).Checked then
    IBLogin.Database.TraceFlags := IBLogin.Database.TraceFlags + [T]
  else
    IBLogin.Database.TraceFlags := IBLogin.Database.TraceFlags - [T];

  if Assigned(GlobalStorage) then
  begin
    GlobalStorage.WriteInteger('Options', 'MSQLF', TraceFlagsToInteger(IBLogin.Database.TraceFlags));
  end;
end;

procedure Tgd_frmSQLMonitor.chbxSQLMonitorClick(Sender: TObject);
begin
  if Assigned(GlobalStorage) then
  begin
    if chbxSQLMonitor.Checked then
      GlobalStorage.WriteBoolean('Options', 'MSQL', True)
    else
      GlobalStorage.DeleteValue('Options', 'MSQL', False);
  end;
end;


procedure Tgd_frmSQLMonitor.actFormExecute(Sender: TObject);
begin
  TgdcSQLStatement.CreateViewForm(Application).Show;
end;

procedure Tgd_frmSQLMonitor.actFormUpdate(Sender: TObject);
begin
  actForm.Enabled := Assigned(IBLogin) and IBLogin.LoggedIn;
end;

procedure Tgd_frmSQLMonitor.actFlushUpdate(Sender: TObject);
begin
  actFlush.Enabled := Assigned(IBLogin) and IBLogin.LoggedIn;
end;

procedure Tgd_frmSQLMonitor.actRefreshTransactionsExecute(Sender: TObject);
var
  I, K: Integer;
  LI: TListItem;
  Tr: TIBTransaction;
  S: Pointer;
begin
  if lvTransactions.Selected = nil then
    S := nil
  else
    S := lvTransactions.Selected.Data;

  K := 0;
  lvTransactions.Items.Clear;
  for I := 0 to IBLogin.Database.TransactionCount - 1 do
  begin
    if IBLogin.Database.Transactions[I] <> nil then
    begin
      Tr := IBLogin.Database.Transactions[I];

      if chbxOnlyActive.Checked and (not Tr.InTransaction) then
        continue;

      LI := lvTransactions.Items.Add;
      LI.Data := IBLogin.Database.Transactions[I];
      Inc(K);
      LI.Caption := IntToStr(K);
      if Tr.Name > '' then
        LI.SubItems.Add(IBLogin.Database.Transactions[I].Name)
      else
        LI.SubItems.Add('<no name>');
      if Tr.Owner = nil then
        LI.SubItems.Add('<no owner>')
      else begin
        if Tr.Owner.Name > '' then
          LI.SubItems.Add(Tr.Owner.Name)
        else
          LI.SubItems.Add('<no name>');
      end;
      if IBLogin.Database.Transactions[I].InTransaction then
        LI.SubItems.Add('Yes')
      else
        LI.SubItems.Add('No');
      LI.SubItems.Add(StringReplace(IBLogin.Database.Transactions[I].Params.Text,
        #13#10, ' ', [rfReplaceAll]));
    end;
  end;

  for I := 0 to lvTransactions.Items.Count - 1 do
  begin
    if lvTransactions.Items[I].Data = S then
    begin
      lvTransactions.Selected := lvTransactions.Items[I];
      break;
    end;
  end;
end;

procedure Tgd_frmSQLMonitor.actRefreshTransactionsUpdate(Sender: TObject);
begin
  actRefreshTransactions.Enabled := (IBLogin <> nil)
    and IBLogin.LoggedIn;
end;

procedure Tgd_frmSQLMonitor.pcChange(Sender: TObject);
begin
  if pc.ActivePage = tsTransactions then
  begin
    actRefreshTransactions.Execute;
  end;
  if pc.ActivePage = tsDataSets then
  begin
    actRefreshDataSets.Execute;
  end;
end;

procedure Tgd_frmSQLMonitor.actStartUpdate(Sender: TObject);
begin
  actStart.Enabled := (lvTransactions.Selected <> nil)
    and (CheckTransaction(lvTransactions.Selected.Data) <> nil)
    and (not CheckTransaction(lvTransactions.Selected.Data).InTransaction);
end;

function Tgd_frmSQLMonitor.CheckTransaction(Tr: Pointer): TIBTransaction;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to IBLogin.Database.TransactionCount - 1 do
  begin
    if Tr = IBLogin.Database.Transactions[I] then
    begin
      Result := TIBTransaction(Tr);
      exit;
    end;
  end;
end;

procedure Tgd_frmSQLMonitor.actStartExecute(Sender: TObject);
begin
  Warning;
  CheckTransaction(lvTransactions.Selected.Data).StartTransaction;
  actRefreshTransactions.Execute;
end;

procedure Tgd_frmSQLMonitor.actCommitUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (lvTransactions.Selected <> nil)
    and (CheckTransaction(lvTransactions.Selected.Data) <> nil)
    and CheckTransaction(lvTransactions.Selected.Data).InTransaction;
end;

procedure Tgd_frmSQLMonitor.actCommitExecute(Sender: TObject);
begin
  Warning;
  CheckTransaction(lvTransactions.Selected.Data).Commit;
  actRefreshTransactions.Execute;
end;

procedure Tgd_frmSQLMonitor.actRollbackExecute(Sender: TObject);
begin
  Warning;
  CheckTransaction(lvTransactions.Selected.Data).Rollback;
  actRefreshTransactions.Execute;
end;

procedure Tgd_frmSQLMonitor.chbxOnlyActiveClick(Sender: TObject);
begin
  actRefreshTransactions.Execute;
end;

procedure Tgd_frmSQLMonitor.Warning;
begin
  MessageBox(Handle,
    '¬ыполнение данной операции способно привести к нестабильной работе системы!',
    '¬нимание',
    MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
end;

procedure Tgd_frmSQLMonitor.actRefreshDatasetsUpdate(Sender: TObject);
begin
  actRefreshDataSets.Enabled := (IBLogin <> nil)
    and IBLogin.LoggedIn;
end;

procedure Tgd_frmSQLMonitor.actRefreshDatasetsExecute(Sender: TObject);
var
  I, K: Integer;
  LI: TListItem;
  DS: TIBCustomDataset;
  S: Pointer;
begin
  if lvDataSets.Selected = nil then
    S := nil
  else
    S := lvDataSets.Selected.Data;

  K := 0;
  DS := nil;
  lvDataSets.Items.Clear;
  for I := 0 to IBLogin.Database.SQLObjectCount - 1 do
  begin
    if (IBLogin.Database.SQLObjects[I] <> nil)
      and (IBLogin.Database.SQLObjects[I].Owner is TIBCustomDataSet) then
    begin
      if DS = IBLogin.Database.SQLObjects[I].Owner then
        continue;

      DS := TIBCustomDataSet(IBLogin.Database.SQLObjects[I].Owner);

      if chbxOnlyActiveDataSet.Checked and (not DS.Active) then
        continue;

      LI := lvDataSets.Items.Add;
      LI.Data := IBLogin.Database.SQLObjects[I].Owner;
      Inc(K);
      LI.Caption := IntToStr(K);
      if DS.Name > '' then
        LI.SubItems.Add(DS.Name)
      else
        LI.SubItems.Add('<no name>');
      if DS.Owner = nil then
        LI.SubItems.Add('<no owner>')
      else begin
        if DS.Owner.Name > '' then
          LI.SubItems.Add(DS.Owner.Name)
        else
          LI.SubItems.Add('<no name>');
      end;
      if DS.Active then
        LI.SubItems.Add('Yes')
      else
        LI.SubItems.Add('No');
      LI.SubItems.Add(FormatFloat('#,##0', DS.CacheSize));  
      LI.SubItems.Add(FormatFloat('#,##0', DS.RecordCount));  
      LI.SubItems.Add(FormatFloat('#,##0', DS.FieldCount));
    end;
  end;

  for I := 0 to lvDatasets.Items.Count - 1 do
  begin
    if lvDataSets.Items[I].Data = S then
    begin
      lvDataSets.Selected := lvDataSets.Items[I];
      break;
    end;
  end;
end;

procedure Tgd_frmSQLMonitor.chbxOnlyActiveDataSetClick(Sender: TObject);
begin
  actRefreshDatasets.Execute;
end;

end.
