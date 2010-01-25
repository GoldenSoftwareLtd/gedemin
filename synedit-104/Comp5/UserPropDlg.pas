
unit UserPropDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, StdCtrls, Mask, DBCtrls, DBTables, mmLabel, mBitButton, xLabel,
  UserInGroupsDlg, UserLogin, gsMultilingualSupport;

type
  TUserPropDialog = class(TForm)
    tblUser: TTable;
    DBEdit1: TDBEdit;
    dsUser: TDataSource;
    DBEdit2: TDBEdit;
    DBEdit3: TDBEdit;
    DBEdit4: TDBEdit;
    DBEdit5: TDBEdit;
    mBitButton1: TmBitButton;
    mBitButton2: TmBitButton;
    xLabel1: TxLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    DBCheckBox1: TDBCheckBox;
    DBCheckBox2: TDBCheckBox;
    DBCheckBox3: TDBCheckBox;
    DBCheckBox4: TDBCheckBox;
    DBEdit6: TDBEdit;
    Label3: TLabel;
    mBitButton3: TmBitButton;
    DBCheckBox5: TDBCheckBox;
    Label7: TLabel;
    DBText1: TDBText;
    gsMultilingualSupport: TgsMultilingualSupport;
    procedure FormCreate(Sender: TObject);
    procedure mBitButton1Click(Sender: TObject);
    procedure mBitButton2Click(Sender: TObject);
    procedure mBitButton3Click(Sender: TObject);

  private
    FUserKey: Integer;
    FNestedTransaction: Boolean;

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
  FNestedTransaction := Database.InTransaction;
end;

procedure TUserPropDialog.FormCreate(Sender: TObject);
begin
  if not FNestedTransaction then
    Database.StartTransaction;
  tblUser.Open;
  if FUserKey = -1 then
  begin
    tblUser.Append;
    mBitButton3.Enabled := False;
  end else begin
    Assert(tblUser.FindKey([FUserKey]));
    tblUser.Edit;
  end;
end;

procedure TUserPropDialog.mBitButton1Click(Sender: TObject);
begin
  if tblUser.State in [dsEdit, dsInsert] then
    tblUser.Post;
  if not FNestedTransaction then
    Database.Commit;
  ModalResult := mrOk;
end;

procedure TUserPropDialog.mBitButton2Click(Sender: TObject);
begin
  if tblUser.State in [dsEdit, dsInsert] then
    tblUser.Cancel;
  if not FNestedTransaction then
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

