
unit tr_frmEntrys_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, ComCtrls, ToolWin, gsDBTreeView, Grids, DBGrids, gsDBGrid,
  gsIBGrid, Db, IBCustomDataSet, gd_createable_form, IBDatabase, dmDatabase_unit, StdCtrls,
  ImgList, gsTransaction, gd_security_OperationConst, ActnList,
  at_sql_setup, IBSQL, Menus, flt_sqlFilter, 
  gsReportRegistry, dmImages_unit, IBQuery, IBStoredProc,
  gdEntryGrid, gd_security;

type
  TfrmEntrys = class(TCreateableForm)
    Panel1: TPanel;
    CoolBar1: TCoolBar;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    Panel2: TPanel;
    Splitter1: TSplitter;
    Panel3: TPanel;
    gsdbtvTransaction: TgsDBTreeView;
    ibdsTransaction: TIBDataSet;
    dsTransaction: TDataSource;
    IBTransaction: TIBTransaction;
    Timer: TTimer;
    ActionList1: TActionList;
    actNewOperation: TAction;
    actEditOperation: TAction;
    actDelOperation: TAction;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    atSQLSetup: TatSQLSetup;
    ToolButton4: TToolButton;
    pFilter: TPopupMenu;
    gsQueryFilter: TgsQueryFilter;
    Panel4: TPanel;
    cbViewSubLevel: TCheckBox;
    gsReportRegistry: TgsReportRegistry;
    pOperation: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    gsTransaction: TgsTransaction;
    dsAccountInfo: TDataSource;
    ibsqlAccountSaldo: TIBSQL;
    ibdsAccountInfo: TIBDataSet;
    egEntries: TgdEntryGrid;
    sbEntries: TStatusBar;
    ibdsEmpty: TIBDataSet;
    ToolButton6: TToolButton;
    actRemains: TAction;
    procedure gsdbtvTransactionGetImageIndex(Sender: TObject;
      Node: TTreeNode);
    procedure gsdbtvTransactionGetSelectedIndex(Sender: TObject;
      Node: TTreeNode);
    procedure FormCreate(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure gsdbtvTransactionChanging(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean);
    procedure actNewOperationExecute(Sender: TObject);
    procedure actEditOperationExecute(Sender: TObject);
    procedure actDelOperationExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cbViewSubLevelClick(Sender: TObject);
    procedure actEditOperationUpdate(Sender: TObject);
    procedure egEntriesTotalEvent(Sender: TObject; Debit, Credit: Double;
      SelCount: Integer);
    procedure egEntriesSQLEvent(Sender: TObject; var SQL: String);
    procedure gsQueryFilterFilterChanged(Sender: TObject;
      const AnCurrentFilter: Integer);
    procedure actRemainsExecute(Sender: TObject);
    procedure ToolButton4Click(Sender: TObject);
  private
    { Private declarations }
    procedure ShowEntries;
    procedure EditRemainder(const aID: Integer);
  public
    { Public declarations }
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  frmEntrys: TfrmEntrys;

implementation

{$R *.DFM}

uses tr_dlgAddSimpleDoc_unit, tr_dlgRemainder_unit, tr_type_unit,
     tr_dlgAccountInfo_unit, tr_frmOpeningBalance_unit, Storages;

class function TfrmEntrys.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(frmEntrys) then
    frmEntrys := TfrmEntrys.Create(AnOwner);

  Result := frmEntrys;
end;

procedure TfrmEntrys.gsdbtvTransactionGetImageIndex(Sender: TObject;
  Node: TTreeNode);
begin
  if Node.HasChildren then
  begin
    if Node.Expanded then
      Node.ImageIndex := 1
    else
      Node.ImageIndex := 0;
  end
  else
    Node.ImageIndex := 17;    
end;

procedure TfrmEntrys.gsdbtvTransactionGetSelectedIndex(Sender: TObject;
  Node: TTreeNode);
begin
  if Node.HasChildren then
  begin
    if Node.Expanded then
      Node.SelectedIndex := 1
    else
      Node.SelectedIndex := 0;
  end
  else
    Node.SelectedIndex := 17;    
end;

procedure TfrmEntrys.FormCreate(Sender: TObject);
begin
  if not IBTransaction.InTransaction then
    IBTransaction.StartTransaction;

  gsTransaction.SetStartTransactionInfo(False);  
  ibdsTransaction.Prepare;
  ibdsTransaction.ParamByName('ck').AsInteger := IBLogin.CompanyKey; 
  ibdsTransaction.Open;

  with UserStorage.OpenFolder('\tr_frmTransaction_unit', True) do
    cbViewSubLevel.Checked := ReadInteger('cbViewSubLevel', 0) = 1;

  //
  //  Создаем меню для фильтра проводок

  gsQueryFilter.CreatePopupMenu;
end;

procedure TfrmEntrys.ShowEntries;
begin
  with gsdbtvTransaction do
  begin
    egEntries.Active := False;
    if not Assigned(Selected) or not Assigned(Selected.Data) then Exit;

    if cbViewSubLevel.Checked then
    begin
      egEntries.Params := [pTrTypeLB, pTrTypeRB, pCompanyKey];
      egEntries.Param[pTrTypeLB] := ibdsTransaction.FieldByName('lb').AsString;
      egEntries.Param[pTrTypeRB] := ibdsTransaction.FieldByName('rb').AsString;
      egEntries.Param[pCompanyKey] := IntToStr(IBLogin.CompanyKey);
    end else
    begin
      egEntries.Params := [pTrTypeKey, pCompanyKey];
      egEntries.Param[pTrTypeKey] := IntToStr(ID);
      egEntries.Param[pCompanyKey] := IntToStr(IBLogin.CompanyKey);
    end;

    egEntries.Active := True;
  end;
end;

procedure TfrmEntrys.TimerTimer(Sender: TObject);
begin
  Timer.Enabled := False;
  ShowEntries;
end;

procedure TfrmEntrys.gsdbtvTransactionChanging(Sender: TObject;
  Node: TTreeNode; var AllowChange: Boolean);
begin
  Timer.Enabled := True;
end;

procedure TfrmEntrys.actNewOperationExecute(Sender: TObject);
begin
  with gsdbtvTransaction do
  begin
    if not Assigned(Selected) or not Assigned(Selected.Data) then Exit;

    if ID <> RemainderTransactionKey then
    begin
      with TdlgAddSimpleDoc.Create(Self) do
      try
        SetupDialog(-1, ID);
        if ShowModal = mrOK then ShowEntries;
      finally
        Free;
      end;
    end else
      EditRemainder(-1);
  end;
end;

procedure TfrmEntrys.actEditOperationExecute(Sender: TObject);
begin
  if egEntries.DocumentKey = -1 then Exit;

  if egEntries.TrTypeKey <> RemainderTransactionKey then
  begin
    with TdlgAddSimpleDoc.Create(Self) do
    try
      SetupDialog(egEntries.DocumentKey, egEntries.TrTypeKey);
      if ShowModal = mrOK then ShowEntries;
    finally
      Free;
    end;
  end else

  if egEntries.ID <> -1 then
    EditRemainder(egEntries.ID);
end;

procedure TfrmEntrys.actDelOperationExecute(Sender: TObject);
var
  ibsql: TIBSQL;
begin
  if egEntries.EntryKey = -1 then Exit;

  if egEntries.TrTypeKey <> RemainderTransactionKey then
  begin
    if MessageBox(Handle, {PChar(Format(}'Удалить проводку ?',{ [])),}
      'Внимание', mb_YesNo or mb_IconQuestion) =
       idYes
    then begin
      ibsql := TIBSQL.Create(Self);
      try
        ibsql.Transaction := IBTransaction;
        ibsql.SQL.Text := Format(
          'DELETE FROM gd_entrys WHERE ENTRYKEY = %d', [egEntries.EntryKey]);
        ibsql.ExecQuery;
        ibsql.Close;
        IBTransaction.CommitRetaining;
        egEntries.Active := False;
        egEntries.Active := True;
      finally
        ibsql.Free;
      end;
    end;
  end else

  if egEntries.ID <> -1 then
  begin
    if MessageBox(HANDLE, 'Удалить текущую строку?', 'Внимание',
      mb_YesNo or mb_IconQuestion) = idYes then
    begin
      ibsql := TIBSQL.Create(Self);
      try
        ibsql.Transaction := IBTransaction;
        ibsql.SQL.Text := Format(
          'DELETE FROM gd_entrys WHERE ID = %d', [egEntries.ID]);
        ibsql.ExecQuery;
        ibsql.Close;
        IBTransaction.CommitRetaining;
        egEntries.Active := False;
        egEntries.Active := True;
      finally
        ibsql.Free;
      end;
    end;
  end;
end;

procedure TfrmEntrys.FormDestroy(Sender: TObject);
begin
  with UserStorage.OpenFolder('\tr_frmTransaction_unit', True) do
    WriteInteger('cbViewSubLevel', Integer(cbViewSubLevel.Checked))
end;

procedure TfrmEntrys.cbViewSubLevelClick(Sender: TObject);
begin
  ShowEntries;
end;

procedure TfrmEntrys.EditRemainder(const aID: Integer);
begin
  with TdlgRemainder.Create(Self) do
    try
      SetupDialog(aID, egEntries.DocumentKey, egEntries.DocDate);
      if ShowModal = mrOk then ShowEntries;
    finally
      Free;
    end;
end;

procedure TfrmEntrys.actEditOperationUpdate(Sender: TObject);
begin
  actEditOperation.Enabled :=
    egEntries.Active and (egEntries.EntryKey > 0) and
    (gsTransaction.IsValidDocTransaction(egEntries.TrTypeKey) or
     (egEntries.TrTypeKey = RemainderTransactionKey));
end;

procedure TfrmEntrys.egEntriesTotalEvent(Sender: TObject; Debit,
  Credit: Double; SelCount: Integer);
begin
  sbEntries.Panels[0].Text := 'Дебет: ' + CurrToStr(Debit);
  sbEntries.Panels[1].Text := 'Кредит: ' + CurrToStr(Credit);
  sbEntries.Panels[2].Text := 'Кол-во: ' + IntToStr(SelCount);
end;

procedure TfrmEntrys.egEntriesSQLEvent(Sender: TObject; var SQL: String);
begin
  gsQueryFilter.SetQueryText(SQL);
  gsQueryFilter.CreateSQL;
  SQL := gsQueryFilter.FilteredSQL.Text;
end;

procedure TfrmEntrys.gsQueryFilterFilterChanged(Sender: TObject;
  const AnCurrentFilter: Integer);
begin
  egEntries.FreeSQLHandle;

  with gsdbtvTransaction do
  begin
    if not Assigned(Selected) or not Assigned(Selected.Data) then Exit;

    if cbViewSubLevel.Checked then
    begin
      egEntries.Params := [pTrTypeLB, pTrTypeRB, pCompanyKey];
      egEntries.Param[pTrTypeLB] := ibdsTransaction.FieldByName('lb').AsString;
      egEntries.Param[pTrTypeRB] := ibdsTransaction.FieldByName('rb').AsString;
      egEntries.Param[pCompanyKey] := IntToStr(IBLogin.CompanyKey);
    end else

    begin
      egEntries.Params := [pTrTypeKey, pCompanyKey];
      egEntries.Param[pTrTypeKey] := IntToStr(ID);
      egEntries.Param[pCompanyKey] := IntToStr(IBLogin.CompanyKey);
    end;
  end;

  egEntries.Open;
end;

procedure TfrmEntrys.actRemainsExecute(Sender: TObject);
begin
  Ttr_frmOpeningBalance.CreateAndAssign(Application).Show;
end;

procedure TfrmEntrys.ToolButton4Click(Sender: TObject);
var
  R: TRect;
begin
    R := ToolButton4.BoundsRect;
    R.TopLeft := ClientToScreen(R.TopLeft);
    R.BottomRight := ClientToScreen(R.BottomRight);


  gsQueryFilter.PopupMenu(R.Left, R.Bottom);
end;

initialization
  RegisterClass(TfrmEntrys);

end.
