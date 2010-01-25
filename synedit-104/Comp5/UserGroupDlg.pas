
unit UserGroupDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, StdCtrls, Mask, DBCtrls, DBTables, mmLabel, mBitButton, xLabel,
  UserInGroupsDlg, UserLogin, gsMultilingualSupport;

type
  TUserGroupDialog = class(TForm)
    tblUserGroup: TTable;
    DBEdit1: TDBEdit;
    dsUserGroup: TDataSource;
    DBEdit3: TDBEdit;
    mBitButton1: TmBitButton;
    mBitButton2: TmBitButton;
    xLabel: TxLabel;
    Label1: TLabel;
    Label4: TLabel;
    DBCheckBox1: TDBCheckBox;
    gsMultilingualSupport: TgsMultilingualSupport;
    procedure FormCreate(Sender: TObject);
    procedure mBitButton1Click(Sender: TObject);
    procedure mBitButton2Click(Sender: TObject);

  private
    FUserGroupKey: Integer;
    FNestedTransaction: Boolean;

  public
    constructor Create(AnOwner: TComponent; const AUserGroupKey: Integer); reintroduce;
  end;

var
  UserGroupDialog: TUserGroupDialog;

implementation

{$R *.DFM}

uses
  Ternaries;

constructor TUserGroupDialog.Create(AnOwner: TComponent;
  const AUserGroupKey: Integer);
begin
  inherited Create(AnOwner);
  FUserGroupKey := AUserGroupKey;
  FNestedTransaction := Database.InTransaction;
end;

procedure TUserGroupDialog.FormCreate(Sender: TObject);
begin
  if not FNestedTransaction then
    Database.StartTransaction;
  tblUserGroup.Open;
  if FUserGroupKey = -1 then
  begin
    tblUserGroup.Append;
    tblUserGroup.FieldByName('disabled').AsInteger := 0;
    xLabel.Caption := TranslateText(' ¬вод новой группы');
  end else begin
    Assert(tblUserGroup.FindKey([FUserGroupKey]));
    tblUserGroup.Edit;
    xLabel.Caption := TranslateText(' –едактирование группы');
  end;
end;

procedure TUserGroupDialog.mBitButton1Click(Sender: TObject);
begin
  if tblUserGroup.State in [dsEdit, dsInsert] then
    tblUserGroup.Post;
  if not FNestedTransaction then
    Database.Commit;
  ModalResult := mrOk;
end;

procedure TUserGroupDialog.mBitButton2Click(Sender: TObject);
begin
  if tblUserGroup.State in [dsEdit, dsInsert] then
    tblUserGroup.Cancel;
  if not FNestedTransaction then
    Database.Rollback;
  ModalResult := mrCancel;
end;

end.

