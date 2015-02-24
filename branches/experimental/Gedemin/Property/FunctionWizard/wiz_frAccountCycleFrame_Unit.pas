unit wiz_frAccountCycleFrame_Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  wiz_frEditFrame_unit, StdCtrls, ComCtrls, BtnEdit, Grids, DBGrids,
  gsDBGrid, gsIBGrid, Db, IBCustomDataSet, wiz_FunctionBlock_unit, Menus,
  gdcbaseInterface, dmImages_unit, TB2Item, ActnList, TB2Dock, TB2Toolbar,
  ExtCtrls;

type
  TfrAccountCycleFrame = class(TfrEditFrame)
    DataSource: TDataSource;
    IBDataSet: TIBDataSet;
    beAnal: TBtnEdit;
    beGroupBy: TBtnEdit;
    beFilter: TBtnEdit;
    tsAddiditional: TTabSheet;
    beBeginDate: TBtnEdit;
    Label10: TLabel;
    beEndDate: TBtnEdit;
    Label11: TLabel;
    gbSQL: TGroupBox;
    lSelect: TLabel;
    lFrom: TLabel;
    lWhere: TLabel;
    lOrder: TLabel;
    eSelect: TEdit;
    eFrom: TEdit;
    eWhere: TEdit;
    eOrder: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    Label5: TLabel;
    pmAdd: TPopupMenu;
    Panel1: TPanel;
    gsIBGrid: TgsIBGrid;
    TBDock1: TTBDock;
    TBToolbar1: TTBToolbar;
    ActionList1: TActionList;
    actOnlySelected: TAction;
    TBItem1: TTBItem;
    procedure beAnalBtnOnClick(Sender: TObject);
    procedure beFilterBtnOnClick(Sender: TObject);
    procedure beBeginDateBtnOnClick(Sender: TObject);
    procedure pmAddPopup(Sender: TObject);
    procedure IBDataSetFilterRecord(DataSet: TDataSet;
      var Accept: Boolean);
    procedure actOnlySelectedUpdate(Sender: TObject);
    procedure actOnlySelectedExecute(Sender: TObject);
  private
    { Private declarations }
    FCardOfAccountKey: Integer;
    FFiltered: Boolean;
  protected
    procedure SetBlock(const Value: TVisualBlock); override;
    function GetAccounts: string;
    procedure SetAccounts(A: string);
    procedure ClickAnal(Sender: TObject);
    procedure ClickAnalCycle(Sender: TObject);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SaveChanges; override;
    function CheckOk: Boolean; override;
  end;

var
  frAccountCycleFrame: TfrAccountCycleFrame;

implementation

{$R *.DFM}

uses
  tax_frmAnalytics_unit, wiz_dlgAliticSelect_unit, wiz_Utils_unit,
  wiz_ExpressionEditorForm_unit, Storages, gsStorage_CompPath;

{ TfrAccountCycleFrame }

constructor TfrAccountCycleFrame.Create(AOwner: TComponent);
begin
  inherited;
  if UserStorage <> nil then
  begin
    UserStorage.LoadComponent(gsIBGrid, gsIBGrid.LoadFromStream);
    FFiltered := UserStorage.ReadBoolean(BuildComponentPath(gsIBGrid),
      'OnlySelected', False);
  end;
end;

destructor TfrAccountCycleFrame.Destroy;
begin
  if UserStorage <> nil then
  begin
    UserStorage.SaveComponent(gsIBGrid, gsIBGrid.SaveToStream);
    UserStorage.WriteBoolean(BuildComponentPath(gsIBGrid), 'OnlySelected',
      IBDataSet.Filtered);
  end;

  inherited;
end;

procedure TfrAccountCycleFrame.beAnalBtnOnClick(Sender: TObject);
var
  F: TdlgAnaliticSelect;
begin
  F := TdlgAnaliticSelect.Create(nil);
  try
    F.Analitics := TEditSButton(Sender).Edit.Text;
    if F.ShowModal = mrOk then
      TEditSButton(Sender).Edit.Text := F.Analitics;
  finally
    F.Free;
  end;
end;

procedure TfrAccountCycleFrame.beFilterBtnOnClick(Sender: TObject);
begin
  beClick(Sender, pmAdd)
end;

procedure TfrAccountCycleFrame.beBeginDateBtnOnClick(Sender: TObject);
begin
  TEditSButton(Sender).Edit.Text := FBlock.EditExpression(TEditSButton(Sender).Edit.Text, FBlock)
end;

procedure TfrAccountCycleFrame.pmAddPopup(Sender: TObject);
begin
  pmAdd.Items.Clear;
  FillAnaliticMenuItem(pmAdd, pmAdd.Items, ClickAnal, nil, ClickAnalCycle, nil);
end;

procedure TfrAccountCycleFrame.SetBlock(const Value: TVisualBlock);
begin
  inherited;
  with FBlock as TAccountCycleBlock do
  begin
    try
      FCardOfAccountKey := gdcBaseManager.GetIdByRuidString(MainFunction.CardOfAccountsRUID);
    except
      ShowMessage('Указан неверный план счетов');
      FCardOfAccountKey := -1;
    end;
    IBDataSet.ParamByName('accountkey').AsInteger := FCardOfAccountKey;
    IBDataSet.Open;
    SetAccounts(Account);
    beAnal.Text := Analise;
    beFilter.Text := Filter;
    beBeginDate.Text := BeginDate;
    beEnddate.Text := EndDate;
    beGroupBy.Text := GroupBy;

    eSelect.Text := Select;
    eFrom.Text := From;
    eWhere.Text := Where;
    eOrder.Text := Order;
    IBDataSet.First;
  end;

  if FFiltered and (gsIBGrid.CheckBox.CheckCount > 0)  then
  begin
    IBDataSet.Filtered := True;
    FFiltered := False;
  end;

end;

function TfrAccountCycleFrame.GetAccounts: string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to gsIBGrid.CheckBox.CheckCount - 1 do
  begin
    if Result > '' then Result := Result + '; ';
    Result := Result + gsIBGrid.CheckBox.CheckList[I];
  end;
end;

procedure TfrAccountCycleFrame.SetAccounts(A: string);
var
  S: TStrings;
  I: Integer;
begin
  gsIBGrid.CheckBox.CheckList.Clear;
  S := TStringList.Create;
  try
    ParseString(A, S);
    for I := 0 to S.Count - 1 do
    begin
      if IBDataSet.Locate('id', VarArrayOf([S[I]]), []) then
        gsIBGrid.CheckBox.CheckList.Add(S[I]);
    end;
  finally
    S.Free;
  end;
end;

procedure TfrAccountCycleFrame.ClickAnal(Sender: TObject);
var
  D: TfrmAnalytics;
begin
  D := TfrmAnalytics.Create(nil);
  try
    D.Block := Self.Block;
    if D.ShowModal = idOk then
    begin
      if FActiveEdit.Text > '' then
      begin
        if FActiveEdit.Text[Length(FActiveEdit.Text)] = ';' then
          FActiveEdit.Text := FActiveEdit.Text + D.Analytics
        else
          FActiveEdit.Text := FActiveEdit.Text + ';' + D.Analytics;
      end else
        FActiveEdit.Text := D.Analytics;
    end;
  finally
    D.Free
  end;
end;

procedure TfrAccountCycleFrame.ClickAnalCycle(Sender: TObject);
var
  S: string;
begin
  S := Format('%s.%s',
    [TVisualBlock(TMenuItem(Sender).Tag).BlockName,
    TMenuItem(Sender).Caption]);
  if FActiveEdit.Text > '' then
  begin
    if FActiveEdit.Text[Length(FActiveEdit.Text)] = ';' then
      FActiveEdit.Text := FActiveEdit.Text + S
    else
      FActiveEdit.Text := FActiveEdit.Text + ';' + S;
  end else
    FActiveEdit.Text := S;
end;

procedure TfrAccountCycleFrame.SaveChanges;
begin
  inherited;
  with FBlock as TAccountCycleBlock do
  begin
    Account := GetAccounts;
    Analise := beAnal.Text;
    Filter := beFilter.Text;
    BeginDate := beBeginDate.Text;
    EndDate := beEnddate.Text;
    GroupBy := beGroupBy.Text;

    Select := eSelect.Text;
    From := eFrom.Text;
    Where := eWhere.Text;
    Order := eOrder.Text;
  end;
end;

function TfrAccountCycleFrame.CheckOk: Boolean;
begin
  Result := inherited CheckOk;
  if Result then
  begin
    Result := gsIBGrid.CheckBox.CheckCount > 0;
    if not Result then
      ShowCheckOkMessage('Пожалуйста, выберите счет цикла')
  end;
end;

procedure TfrAccountCycleFrame.IBDataSetFilterRecord(DataSet: TDataSet;
  var Accept: Boolean);
begin
  Accept := gsIbGrid.CheckBox.CheckList.indexOf(DataSet.FieldByName('id').AsString) > - 1
end;

procedure TfrAccountCycleFrame.actOnlySelectedUpdate(Sender: TObject);
begin
  TAction(Sender).Checked := IBDataSet.Filtered;
end;

procedure TfrAccountCycleFrame.actOnlySelectedExecute(Sender: TObject);
begin
  IBDataSet.Filtered := not IBDataSet.Filtered
end;

end.
