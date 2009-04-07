
unit UserInGroupsDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBTables, ExtCtrls, mBitButton, Grids, DBGrids, StdCtrls, ActnList,
  xLabel, gsMultilingualSupport;

type
  TUserInGroupsDialog = class(TForm)
    Label2: TLabel;
    Label3: TLabel;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    mBitButton1: TmBitButton;
    mBitButton2: TmBitButton;
    mBitButton3: TmBitButton;
    qryInGroups: TQuery;
    qryGroups: TQuery;
    dsInGroups: TDataSource;
    dsGroups: TDataSource;
    ActionList: TActionList;
    actAdd: TAction;
    actRemove: TAction;
    qryInGroupsUSERGROUPKEY: TIntegerField;
    qryInGroupsNAME: TStringField;
    qryGroupsUSERGROUPKEY: TIntegerField;
    qryGroupsNAME: TStringField;
    qry: TQuery;
    xLabel: TxLabel;
    mBitButton4: TmBitButton;
    gsMultilingualSupport: TgsMultilingualSupport;
    procedure FormCreate(Sender: TObject);
    procedure actAddUpdate(Sender: TObject);
    procedure actRemoveUpdate(Sender: TObject);
    procedure actAddExecute(Sender: TObject);
    procedure actRemoveExecute(Sender: TObject);
    procedure mBitButton3Click(Sender: TObject);
    procedure mBitButton4Click(Sender: TObject);

  private
    FUserKey: Integer;
    FNestedTransaction: Boolean;

  public
    constructor Create(AnOwner: TComponent; const AUserKey: Integer);
      reintroduce;
  end;

var
  UserInGroupsDialog: TUserInGroupsDialog;

implementation

{$R *.DFM}

uses
  UserLogin;

{ TUserInGroupsDialog }

constructor TUserInGroupsDialog.Create(AnOwner: TComponent;
  const AUserKey: Integer);
begin
  inherited Create(AnOwner);
  FUserKey := AUserKey;
  FNestedTransaction := Database.InTransaction;
end;

procedure TUserInGroupsDialog.FormCreate(Sender: TObject);
begin
  if not FNestedTransaction then
    Database.StartTransaction;

  qry.SQL.Text := 'SELECT name FROM fin_user WHERE userkey = ' + IntToStr(FUserKey);
  qry.Open;
  xLabel.Caption := TranslateText(xLabel.Caption) + ' ' + qry.FieldByName('name').AsString;
  qry.Close;

  qryInGroups.ParamByName('UK').AsInteger := FUserKey;
  qryInGroups.Open;

  qryGroups.ParamByName('UK').AsInteger := FUserKey;
  qryGroups.Open;
end;

procedure TUserInGroupsDialog.actAddUpdate(Sender: TObject);
begin
  actAdd.Enabled := qryGroups.RecordCount > 0;
end;

procedure TUserInGroupsDialog.actRemoveUpdate(Sender: TObject);
begin
  actRemove.Enabled := qryInGroups.RecordCount > 0;
end;

procedure TUserInGroupsDialog.actAddExecute(Sender: TObject);
begin
  qry.SQL.Text := Format('INSERT INTO fin_userref VALUES (%d, %d)',
    [FUserKey, qryGroups.FieldByName('usergroupkey').AsInteger]);
  qry.ExecSQL;

  qryInGroups.Close;
  qryInGroups.Open;

  qryGroups.Close;
  qryGroups.Open;
end;

procedure TUserInGroupsDialog.actRemoveExecute(Sender: TObject);
begin
  qry.SQL.Text := Format('DELETE FROM fin_userref WHERE userkey = %d AND usergroupkey = %d',
    [FUserKey, qryInGroups.FieldByName('usergroupkey').AsInteger]);
  qry.ExecSQL;

  qryInGroups.Close;
  qryInGroups.Open;

  qryGroups.Close;
  qryGroups.Open;
end;

procedure TUserInGroupsDialog.mBitButton3Click(Sender: TObject);
begin
  if not FNestedTransaction then
    Database.Commit;
  ModalResult := mrOk;
end;

procedure TUserInGroupsDialog.mBitButton4Click(Sender: TObject);
begin
  if not FNestedTransaction then
    Database.Rollback;
  ModalResult := mrCancel;
end;

end.

