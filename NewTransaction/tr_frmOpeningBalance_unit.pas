unit tr_frmOpeningBalance_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_frmG_unit, ComCtrls, Grids, DBGrids, gsDBGrid, gsIBGrid, ExtCtrls,
  gsDBTreeView, ActnList,  ToolWin, StdCtrls, IBSQL, Db,
  IBCustomDataSet, IBDatabase, Contnrs, at_sql_setup, gsIBLargeTreeView,
  ImgList, Menus,  flt_sqlFilter, gsReportManager;

const
  ENTRY_RELATION_NAME = 'GD_ENTRYS';
  
type
  TAnalyticSource = class;
  TAccountData = class;

  Ttr_frmOpeningBalance = class(Tgd_frmG)
    pnlTree: TPanel;
    pnlTotal: TPanel;
    pnlEntries: TPanel;
    Splitter1: TSplitter;
    ibgrdEntries: TgsIBGrid;
    Splitter2: TSplitter;
    lvAnalytics: TListView;
    ibtrOpeningBalance: TIBTransaction;
    ibdsAccounts: TIBDataSet;
    dsAccounts: TDataSource;
    ibsqlEntryAnalitics: TIBSQL;
    ibdsRemains: TIBDataSet;
    dsRemains: TDataSource;
    atSQLSetup1: TatSQLSetup;
    tvAccounts: TgsIBLargeTreeView;
    Label1: TLabel;
    Label2: TLabel;
    Bevel1: TBevel;
    lblDebet: TLabel;
    lblCredit: TLabel;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ilRemains: TImageList;
    actComputeAll: TAction;
    actComputeCurrent: TAction;
    ibsqlAccounts: TIBSQL;
    ibsqlCurrentCard: TIBSQL;
    gsqfOpenBalance: TgsQueryFilter;
    pFilter: TPopupMenu;
    gsReportManager1: TgsReportManager;

    procedure tvAccountsChange(Sender: TObject; Node: TTreeNode);

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure ibdsRemainsAfterScroll(DataSet: TDataSet);

    procedure actNewExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);

    procedure lblDebetClick(Sender: TObject);

    procedure actComputeAllExecute(Sender: TObject);

  private

    function GetAnalytic(AnIndex: Integer): TAnalyticSource;
    function GetAnalyticCount: Integer;
    function GetAnalyticName(AName: String): TAnalyticSource;
    function GetAccountByID(AnID: Integer): TAccountData;

  private
    FAnalytics: TObjectList;
    FAttrList: TStringList;
    FAccounts: TObjectList;

    FTopBranchID: Integer;
    FLB: Integer;
    FRB: Integer;

    procedure ComputeAccount(AnAccount: TAccountData);

    property AnalyticCount: Integer read GetAnalyticCount;
    property Analytic[AnIndex: Integer]: TAnalyticSource read GetAnalytic;
    property AnalyticName[AName: String]: TAnalyticSource read GetAnalyticName;

    property AccountByID[AnID: Integer]: TAccountData read GetAccountByID;

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;

  end;

  TAnalyticSource = class
  private
    FSQL: TIBSQL;
    FFieldName: String;
    FOwner: Ttr_frmOpeningBalance;

    function GetValue(Key: String): String;
    procedure SetFieldName(const Value: String);

  protected
    procedure PrepareSQL;

  public
    constructor Create(AnOwner: Ttr_frmOpeningBalance);
    destructor Destroy; override;

    property FieldName: String read FFieldName write SetFieldName;
    property Value[Key: String]: String read GetValue;

  end;

  TAccountData = class
  private
    FAccountKey: Integer;

    FDebet: Currency;
    FCredit: Currency;

    FComputed: Boolean;

    FOwner: Ttr_frmOpeningBalance;

  protected
  public
    constructor Create(AnOwner: Ttr_frmOpeningBalance);
    destructor Destroy; override;

    property AccountKey: Integer read FAccountKey;
    property Debet: Currency read FDebet;
    property Credit: Currency read FCredit;

    property Computed: Boolean read FComputed;

  end;

  Etr_frmOpeningBalanceError = class(Exception);

var
  tr_frmOpeningBalance: Ttr_frmOpeningBalance;

implementation

uses
  Storages, tr_Type_unit, at_classes, tr_dlgRemainder_unit,
  gd_security, dmDataBase_unit;

{$R *.DFM}

{ TAnalyticSource }

constructor TAnalyticSource.Create(AnOwner: Ttr_frmOpeningBalance);
begin
  FOwner := AnOwner;
  FSQL := nil;
  FFieldName := '';
end;

destructor TAnalyticSource.Destroy;
begin
  if Assigned(FSQL) then FSQL.Free;
  
  inherited;
end;

function TAnalyticSource.GetValue(Key: String): String;
begin
  PrepareSQL;

  if FSQL.Prepared then
  begin
    FSQL.Params.ByName('ID').AsString := Key;
    FSQL.ExecQuery;
    Result := FSQL.Fields[0].AsString;
    FSQL.Close;
  end else
    Result := '';  
end;

procedure TAnalyticSource.PrepareSQL;
var
  EntryRelation: TatRelation;
  AnalytField: TatRelationField;

begin
  if not Assigned(FSQL) then
  begin
    FSQL := TIBSQL.Create(nil);
    FSQL.Database := dmDatabase.ibdbGAdmin;
    FSQL.Transaction := FOwner.ibtrOpeningBalance;
  end;

  if FSQL.Prepared then Exit;

  EntryRelation := atDatabase.Relations.ByRelationName(ENTRY_RELATION_NAME);
  if not Assigned(EntryRelation) then
    raise Etr_frmOpeningBalanceError.Create(
      '''GD_ENTRYS'' relation not found in attributes structure!');

  AnalytField := EntryRelation.RelationFields.ByFieldName(FFieldName);
  if not Assigned(AnalytField) then
    raise Etr_frmOpeningBalanceError.CreateFmt(
      '''%s'' field not found in attributes structure!',
      [FFieldName]);

  if not Assigned(AnalytField.References) then
    raise Etr_frmOpeningBalanceError.CreateFmt(
      'Field ''%s'' must have a reference!',
      [FFieldName]);

  FSQL.SQL.Text := Format(
    'SELECT %s FROM %s WHERE %s = :ID',
    [
      AnalytField.References.ListField.FieldName,
      AnalytField.References.RelationName,
      AnalytField.References.PrimaryKey.ConstraintFields[0].FieldName
    ]
  );
  FSQL.Prepare;
end;

procedure TAnalyticSource.SetFieldName(const Value: String);
begin
  if FFieldName <> Value then
  begin
    if Assigned(FSQL) and FSQL.Prepared then
      FSQL.FreeHandle;

    FFieldName := Value;
  end;
end;

{ TAccountData }

constructor TAccountData.Create(AnOwner: Ttr_frmOpeningBalance);
begin
  FAccountKey := -1;

  FDebet := 0;
  FCredit := 0;

  FOwner := AnOwner;
end;

destructor TAccountData.Destroy;
begin
  inherited;
end;

{ Ttr_frmOpeningBalance }

class function Ttr_frmOpeningBalance.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(tr_frmOpeningBalance) then
    tr_frmOpeningBalance := Ttr_frmOpeningBalance.Create(AnOwner);

  Result := tr_frmOpeningBalance;
end;

procedure Ttr_frmOpeningBalance.tvAccountsChange(Sender: TObject;
  Node: TTreeNode);
var
  Account: TAccountData;
begin
  if not Assigned(tvAccounts.Selected) then Exit;

  ibdsRemains.DisableControls;
  ibdsRemains.Close;

  ibdsRemains.ParamByName('ACCOUNTKEY').AsString :=
    (tvAccounts.Selected as TgsIBTreeNode).ID;

  ibdsRemains.ParamByName('ENTRYKEY').AsInteger :=
    RemainderEntryKey;

  ibdsRemains.Open;
  ibdsRemains.EnableControls;

  Account := AccountByID[StrToInt((tvAccounts.Selected as TgsIBTreeNode).ID)];

  if Account.Computed then
  begin
    lblDebet.Caption := CurrToStr(Account.Debet);
    lblCredit.Caption := CurrToStr(Account.Credit);
  end else
  begin
    lblDebet.Caption := '...';
    lblCredit.Caption := '...';
  end;
end;

procedure Ttr_frmOpeningBalance.FormCreate(Sender: TObject);
var
  I: Integer;
  EntryRelation: TatRelation;
begin
  inherited;

  FAnalytics := TObjectList.Create;
  FAttrList := TStringList.Create;
  FAccounts := TObjectList.Create;

  if not ibtrOpeningBalance.Active then
    ibtrOpeningBalance.StartTransaction;

  //
  //  Получаем общий список полей аналитики

  EntryRelation := atDatabase.Relations.ByRelationName(ENTRY_RELATION_NAME);
  if not Assigned(EntryRelation) then
    raise Etr_frmOpeningBalanceError.Create(
      '''GD_ENTRYS'' relation not found in attributes structure!');

  for I := 0 to EntryRelation.RelationFields.Count - 1 do
    if EntryRelation.RelationFields[I].IsUserDefined then
      FAttrList.Add(EntryRelation.RelationFields[I].FieldName);

  //
  //  Считываем список счетов

  ibsqlCurrentCard.Close;
  ibsqlCurrentCard.ParamByName('COMPANYKEY').AsInteger :=
    IBLogin.CompanyKey;
  ibsqlCurrentCard.ExecQuery;

  FTopBranchID := ibsqlCurrentCard.FieldByName('ID').AsInteger;
  FLB := ibsqlCurrentCard.FieldByName('LB').AsInteger;
  FRB := ibsqlCurrentCard.FieldByName('RB').AsInteger;

  tvAccounts.TopBranchID := IntToStr(FTopBranchID);
  tvAccounts.LoadFromDatabase;
  ibsqlCurrentCard.FreeHandle;

  if not Assigned(tvAccounts.Selected) and (tvAccounts.Items.Count > 0) then
    tvAccounts.Selected := tvAccounts.Items[0];

  UserStorage.LoadComponent(ibgrdEntries, ibgrdEntries.LoadFromStream);
end;

procedure Ttr_frmOpeningBalance.FormDestroy(Sender: TObject);
begin
  UserStorage.SaveComponent(ibgrdEntries, ibgrdEntries.SaveToStream);

  FreeAndNil(FAnalytics);
  FreeAndNil(FAttrList);
  FreeAndNil(FAccounts);

  inherited;
end;

procedure Ttr_frmOpeningBalance.ibdsRemainsAfterScroll(DataSet: TDataSet);
var
  F: TField;
  Source: TAnalyticSource;
  Item: TListItem;
  I: Integer;
begin
  inherited;

  lvAnalytics.Items.BeginUpdate;
  lvAnalytics.Items.Clear;

  try
    for I := 0 to FAttrList.Count - 1 do
    begin
      F := ibdsRemains.FindField(FAttrList[I]);

      if Assigned(F) and not F.IsNull then
      begin
        Source := AnalyticName[F.FieldName];
        Item := lvAnalytics.Items.Add;
        Item.Caption := Source.Value[F.AsString];
      end;
    end;
  finally
    lvAnalytics.Items.EndUpdate;
  end;
end;

function Ttr_frmOpeningBalance.GetAnalytic(
  AnIndex: Integer): TAnalyticSource;
begin
  Result := FAnalytics[AnIndex] as TAnalyticSource;
end;

function Ttr_frmOpeningBalance.GetAnalyticCount: Integer;
begin
  Result := FAnalytics.Count;
end;

function Ttr_frmOpeningBalance.GetAnalyticName(
  AName: String): TAnalyticSource;
var
  I: Integer;
begin
  for I := 0 to AnalyticCount - 1 do
    if AnsiCompareText(Analytic[I].FieldName, AName) = 0 then
    begin
      Result := Analytic[I];
      Exit;
    end;

  Result := TAnalyticSource.Create(Self);
  Result.FieldName := AName;
  FAnalytics.Add(Result);
end;

procedure Ttr_frmOpeningBalance.actNewExecute(Sender: TObject);
begin
  with TdlgRemainder.Create(Self) do
  try
    SetupDialog(-1,
      ibdsRemains.FieldByName('DOCUMENTKEY').AsInteger,
      ibdsRemains.FieldByName('ENTRYDATE').AsDateTime);

    if ShowModal = mrOK then
    begin
      ibdsRemains.DisableControls;

      ibdsRemains.Close;
      ibdsRemains.Open;
      
      ibdsRemains.EnableControls;
    end;
  finally
    Free;
  end;
end;

procedure Ttr_frmOpeningBalance.actEditExecute(Sender: TObject);
begin
  with TdlgRemainder.Create(Self) do
  try
    SetupDialog(ibdsRemains.FieldByName('ID').AsInteger,
      ibdsRemains.FieldByName('DOCUMENTKEY').AsInteger,
      ibdsRemains.FieldByName('ENTRYDATE').AsDateTime);

    if ShowModal = mrOK then
    begin
      ibdsRemains.Refresh;
      ibdsRemainsAfterScroll(ibdsRemains);
    end;
  finally
    Free;
  end;
end;

procedure Ttr_frmOpeningBalance.actDeleteExecute(Sender: TObject);
begin
  if ibdsRemains.IsEmpty then Exit;

  if MessageBox(Handle, 'Удалить запись по остаткам?', 'Внимание!',
    MB_YESNO or MB_ICONQUESTION) = ID_YES
  then begin
    ibdsRemains.Delete;
    ibtrOpeningBalance.CommitRetaining;
  end;
end;

function Ttr_frmOpeningBalance.GetAccountByID(AnID: Integer): TAccountData;
var
  I: Integer;
begin
  for I := 0 to FAccounts.Count - 1 do
    if (FAccounts[I] as TAccountData).FAccountKey = AnID then
    begin
      Result := FAccounts[I] as TAccountData;
      Exit;
    end;

  Result := TAccountData.Create(Self);
  Result.FAccountKey := AnID;
  FAccounts.Add(Result);
end;

procedure Ttr_frmOpeningBalance.lblDebetClick(Sender: TObject);
var
  Account: TAccountData;
begin
  if not Assigned(tvAccounts.Selected) then Exit;

  Account := AccountByID[StrToInt((tvAccounts.Selected as TgsIBTreeNode).ID)];

  if not Account.Computed then
  begin
    ComputeAccount(Account);
    lblDebet.Caption := CurrToStr(Account.Debet);
    lblCredit.Caption := CurrToStr(Account.Credit);
  end;
end;

procedure Ttr_frmOpeningBalance.ComputeAccount(AnAccount: TAccountData);
begin
  if not ibsqlEntryAnalitics.Prepared then
    ibsqlEntryAnalitics.Prepare;

  ibsqlEntryAnalitics.Close;
  
  ibsqlEntryAnalitics.ParamByName('ACCOUNTKEY').AsInteger :=
    AnAccount.AccountKey;
  ibsqlEntryAnalitics.ParamByName('ENTRYKEY').AsInteger :=
    RemainderEntryKey;

  ibsqlEntryAnalitics.ExecQuery;

  AnAccount.FDebet := ibsqlEntryAnalitics.Fields[0].AsFloat;
  AnAccount.FCredit := ibsqlEntryAnalitics.Fields[1].AsFloat;
  AnAccount.FComputed := True;
end;

procedure Ttr_frmOpeningBalance.actComputeAllExecute(Sender: TObject);
var
  Account: TAccountData;
begin
  ibsqlAccounts.Close;
  ibsqlAccounts.ParamByName('LB').AsInteger := FLB;
  ibsqlAccounts.ParamByName('RB').AsInteger := FRB;
  ibsqlAccounts.ExecQuery;

  while not ibsqlAccounts.EOF do
  begin
    Account := AccountByID[ibsqlAccounts.FieldByName('ID').AsInteger];
    ComputeAccount(Account);
    ibsqlAccounts.Next;
  end;

  if Assigned(tvAccounts.Selected) then
  begin
    Account := AccountByID[StrToInt((tvAccounts.Selected as TgsIBTreeNode).ID)];
    lblDebet.Caption := CurrToStr(Account.Debet);
    lblCredit.Caption := CurrToStr(Account.Credit);
  end;
  
  ibsqlAccounts.FreeHandle;
end;

end.
