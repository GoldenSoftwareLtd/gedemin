
unit LoginPropDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, StdCtrls, Mask, DBCtrls, DBTables, mmLabel, mBitButton, xLabel,
  UserInGroupsDlg, UserLogin, gsMultilingualSupport;

type
  TLoginPropDialog = class(TForm)
    mBitButton1: TmBitButton;
    xLabel1: TxLabel;
    lSubSystem: TLabel;
    lUser: TLabel;
    lUserRights: TLabel;
    lSession: TLabel;
    lStartWork: TLabel;
    lDBVersion: TLabel;
    memoDatabaseParams: TMemo;
    Label1: TLabel;
    gsMultilingualSupport: TgsMultilingualSupport;
    procedure mBitButton1Click(Sender: TObject);

  end;

var
  LoginPropDialog: TLoginPropDialog;

implementation

{$R *.DFM}

uses
  Ternaries;

procedure TLoginPropDialog.mBitButton1Click(Sender: TObject);
begin
  ModalResult := mrOk;
end;

end.

