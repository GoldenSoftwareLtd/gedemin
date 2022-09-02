// ShlTanya, 09.03.2019, #4135

unit gdv_dlgAccounts_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  TB2Dock, TB2Toolbar, ComCtrls, gsDBTreeView, Db, IBCustomDataSet,
  gdcBase, gdcTree, gdcAcctAccount, StdCtrls, ExtCtrls, ActnList, TB2Item,
  IBSQL, gdcBaseInterface, gd_security, contnrs, at_classes;

type
  Tgdv_dlgAccounts = class(TForm)
    Panel1: TPanel;
    DataSource1: TDataSource;
    gdcAcctAccountChart: TgdcAcctBase;
    gsDBTreeView: TgsDBTreeView;
    tbdMain: TTBDock;
    tbtMain: TTBToolbar;
    ActionList1: TActionList;
    actOk: TAction;
    actCancel: TAction;
    actSelectAll: TAction;
    actDeselectAll: TAction;
    TBItem1: TTBItem;
    TBItem2: TTBItem;
    Button3: TButton;
    actHelp: TAction;
    pnlBottomRight: TPanel;
    Button1: TButton;
    Button2: TButton;
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actSelectAllExecute(Sender: TObject);
    procedure actDeselectAllExecute(Sender: TObject);
  private
    FActiveAccountKey: TID;
    procedure SetAccounts(const Value: string);
    procedure DeselectAll;
    procedure SelectAll;
    procedure Collapse;
    procedure Expand(Node: TTreeNode);
    function GetAccounts: string;
    procedure SetActiveAccountKey(const Value: TID);
    { Private declarations }
  public
    { Public declarations }
    property Accounts: string read GetAccounts write SetAccounts;
    property ActiveAccountKey: TID read FActiveAccountKey write SetActiveAccountKey;
  end;

var
  gdv_dlgAccounts: Tgdv_dlgAccounts;

implementation
uses AcctUtils;
{$R *.DFM}

procedure Tgdv_dlgAccounts.actOkExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure Tgdv_dlgAccounts.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure Tgdv_dlgAccounts.FormCreate(Sender: TObject);
begin
  gdcAcctAccountChart.ExtraConditions.Add('EXISTS (SELECT id FROM ac_account a WHERE '+
    ' a.lb >= z.lb AND a.rb <= z.rb AND a.accounttype IN (''A'', ''S''))');
  gdcAcctAccountChart.Open;
end;

procedure Tgdv_dlgAccounts.SetAccounts(const Value: string);
var
  S: TStrings;
  Str: string;
  I: Integer;
  ID: TID;
  N: TTreeNode;

  function GetAccountKeyByAlias(Alias: string): TID;
  var
    SQl: TIBSQL;
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcBaseManager.ReadTransaction;
      SQL.SQL.Text := 'SELECT a1.id FROM ac_companyaccount ca JOIN ac_account a ' +
        'ON a.id = ca.accountkey LEFT JOIN ac_account a1 ON a1.lb >= a.lb AND ' +
        'a1.rb <= a.rb AND a1.alias = :alias WHERE ca.companykey = :companykey';
      SQL.ParamByName('alias').AsString := Alias;
      SetTID(SQL.ParamByName('companykey'), IBLogin.CompanyKey);
      SQl.ExecQuery;
      Result := GetTID(SQl.FieldByName('id'));
    finally
      SQL.Free;
    end;
  end;
begin
  Str := Value;
  Str := StringReplace(Str, ',', #13#10, [rfReplaceAll]);
  gsDBTreeView.Items.BeginUpdate;
  try
    DeselectAll;
    Collapse;
    S := TStringList.Create;
    try
      S.Text := Str;
      for I := 0 to S.Count - 1 do
      begin
        Id := GetAccountKeyByAlias(Trim(S[I]));
        N := gsDBTreeView.Find(Id);
        if N <> nil then
        begin
          gsDBTreeView.AddCheck(ID);
          Expand(N);
        end;
      end;
    finally
      S.Free;
    end;
  finally
    gsDBTreeView.Items.EndUpdate;
  end;
end;

procedure Tgdv_dlgAccounts.DeselectAll;
var
  I: Integer;
begin
  gsDBTreeView.Items.BeginUpdate;
  try
    for I := 0 to gsDBTreeView.Items.Count - 1 do
    begin
      gsDBTreeView.DeleteCheck(GetTID(gsDBTreeView.Items[i].Data, Name));
    end;
  finally
    gsDBTreeView.Items.EndUpdate;
  end;
end;

function Tgdv_dlgAccounts.GetAccounts: string;
var
  I: Integer;
  Index: Integer;
  function CheckAccountId(Id: TID): Boolean;
  var
    SQl: TIBSQl;
  begin
    SQl := TIBSQL.Create(nil);
    try
      SQl.Transaction := gdcBaseManager.ReadTransaction;
      SQl.Sql.Add('SELECT * FROM ac_account WHERE id = :id AND accounttype IN (''A'', ''S'')');
      SetTID(SQl.ParamByName('id'), Id);
      SQl.ExecQuery;

      Result := SQl.recordCount > 0;
    finally
      SQL.Free;
    end;
  end;

begin
  Result := '';
  for I := 0 to gsDBTreeView.Items.Count - 1 do
  begin
    if CheckAccountId(GetTID(gsDBTreeView.Items[I].Data, Name)) then
    begin
      Index := gsDBTreeView.TVState.Checked.IndexOf(GetTID(gsDBTreeView.Items[I].Data, Name));
      if Index > - 1 then
      begin
        if Result > '' then
          Result := Result + ', ';

        Result := Result + gsDBTreeView.Items[I].Text;
      end;
    end;  
  end;
end;

procedure Tgdv_dlgAccounts.SelectAll;
var
  I: Integer;
begin
  gsDBTreeView.Items.BeginUpdate;
  try
    for I := 0 to gsDBTreeView.Items.Count - 1 do
    begin
      gsDBTreeView.AddCheck(GetTID(gsDBTreeView.Items[i].Data, Name));
    end;
  finally
    gsDBTreeView.Items.EndUpdate;
  end;
end;

procedure Tgdv_dlgAccounts.Collapse;
var
  I: Integer;
begin
  gsDBTreeView.Items.BeginUpdate;
  try
    for I := 0 to gsDBTreeView.Items.Count - 1 do
    begin
      gsDBTreeView.Items[I].Collapse(False);
    end;
  finally
    gsDBTreeView.Items.EndUpdate;
  end;
end;

procedure Tgdv_dlgAccounts.Expand(Node: TTreeNode);
var
  N: TTreeNode;
begin
  N := Node;
  while N <> nil do
  begin
    N.Expand(False);
    N := N.Parent;
  end;
end;

procedure Tgdv_dlgAccounts.actSelectAllExecute(Sender: TObject);
begin
  SelectAll;
end;

procedure Tgdv_dlgAccounts.actDeselectAllExecute(Sender: TObject);
begin
  DeselectAll;
end;

procedure Tgdv_dlgAccounts.SetActiveAccountKey(const Value: TID);
begin
  FActiveAccountKey := Value;
  if gdcAcctAccountChart.Active then
    gdcAcctAccountChart.Close;

  gdcAcctAccountChart.ExtraConditions.Add(
    Format(' exists (SELECT lb FROM ac_account c1 ' +
    'WHERE z.LB >= c1.lb AND z.rb <= c1.rb AND c1.id = %d ) ', [TID264(FActiveAccountKey)]));
  gdcAcctAccountChart.Open;
end;

end.
