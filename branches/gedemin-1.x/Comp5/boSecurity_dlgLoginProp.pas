
{++

  Copyright (c) 1998-2000 by Golden Software of Belarus

  Module

    boSecurity_dlgLoginProp.pas

  Abstract

    A Part of visual component for choosing user, user rights and pasword.
    Dialog window for loggin to database.

  Author

    Andrei Kireev (22-aug-99), Romanovski Denis (04.02.2000)

  Revisions history

--}


unit boSecurity_dlgLoginProp;

interface

uses
  Windows,          Messages,         SysUtils,         Classes,
  Graphics,         Controls,         Forms,            Dialogs,
  Db,               StdCtrls,         Mask,             DBCtrls,
  mmLabel,          mBitButton,       xLabel,           UserInGroupsDlg,
  UserLogin,        gsMultilingualSupport;

type
  TdlgLoginProp = class(TForm)
    btnOk: TmBitButton;
    lblInfo: TxLabel;
    lSubSystem: TLabel;
    lUser: TLabel;
    lUserRights: TLabel;
    lSession: TLabel;
    lStartWork: TLabel;
    lDBVersion: TLabel;
    memoDatabaseParams: TMemo;
    lParamsInfo: TLabel;
    gsMultilingualSupport: TgsMultilingualSupport;

    procedure btnOkClick(Sender: TObject);

  end;

var
  dlgLoginProp: TdlgLoginProp;

implementation

{$R *.DFM}

procedure TdlgLoginProp.btnOkClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

end.

