
unit UserAddUser;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, StdCtrls, Mask, DBCtrls, DBTables, mmLabel, mBitButton, xLabel,
  UserInGroupsDlg, UserLogin;

type
  TUserPropDialog = class(TForm)
    mBitButton1: TmBitButton;
    mBitButton2: TmBitButton;
    xLabel1: TxLabel;
    procedure FormCreate(Sender: TObject);
    procedure mBitButton1Click(Sender: TObject);
    procedure mBitButton2Click(Sender: TObject);
    procedure mBitButton3Click(Sender: TObject);

  private
    FUserKey: Integer;

  public
    constructor Create(AnOwner: TComponent; const AUserKey: Integer); reintroduce;
  end;

var
  UserPropDialog: TUserPropDialog;

implementation

{$R *.DFM}

uses
  Ternaries;

constructor TUserPropDialog.Create(AnOwner: TComponent;
  const AUserKey: Integer);
begin
  inherited Create(AnOwner);
  FUserKey := AUserKey;
end;

procedure TUserPropDialog.FormCreate(Sender: TObject);
begin
  if not Database.InTransaction then
    Database.StartTransaction;
  tblUser.Open;
  if FUserKey = -1 then
  begin
    tblUser.Append;
  end else begin
    Assert(tblUser.FindKey([FUserKey]));
    tblUser.Edit;
  end;
end;

procedure TUserPropDialog.mBitButton1Click(Sender: TObject);
begin
  if tblUser.State in [dsEdit, dsInsert] then
    tblUser.Post;
  if Database.InTransaction then
    Database.Commit;
  ModalResult := mrOk;
end;

procedure TUserPropDialog.mBitButton2Click(Sender: TObject);
begin
  if tblUser.State in [dsEdit, dsInsert] then
    tblUser.Cancel;
  if Database.InTransaction then
    Database.Rollback;
  ModalResult := mrCancel;
end;

procedure TUserPropDialog.mBitButton3Click(Sender: TObject);
begin
  with TUserInGroupsDialog.Create(Self, FUserKey) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

end.

