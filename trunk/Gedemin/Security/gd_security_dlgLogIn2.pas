
{++

  Copyright (c) 2012 by Golden Software of Belarus

  Module

    gd_security_dlgLogIn2.pas

  Abstract

    Dialog window for loggin to database.

  Author

    Andrei Kireev 

  Revisions history

--}


unit gd_security_dlgLogIn2;

interface

uses
  Windows, Classes, ActnList, StdCtrls, Controls, ExtCtrls, Graphics, Forms,
  SysUtils, Messages;

type
  TdlgSecLogIn2 = class(TForm)
    imgSecurity: TImage;
    pnlLoginParams: TPanel;
    lblUser: TLabel;
    lblPassword: TLabel;
    edPassword: TEdit;
    ActionList: TActionList;
    actLogin: TAction;
    btnOk: TButton;
    btnCancel: TButton;
    actCancel: TAction;
    lblDBName: TLabel;
    bvl2: TBevel;
    lKL: TLabel;
    Timer: TTimer;
    cbUser: TComboBox;
    actHelp: TAction;
    chbxRememberPassword: TCheckBox;
    actVer: TAction;
    btnVer: TButton;
    edDBName: TEdit;
    btnSelectDB: TButton;
    actSelectDB: TAction;
    chbxWithoutConnection: TCheckBox;
    chbxSingleUser: TCheckBox;
    bvl1: TBevel;

    procedure actCancelExecute(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure actVerExecute(Sender: TObject);
    procedure actSelectDBExecute(Sender: TObject);
    procedure chbxWithoutConnectionClick(Sender: TObject);
    procedure actSelectDBUpdate(Sender: TObject);
    procedure actLoginExecute(Sender: TObject);

  private
    KL: Integer;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  dlgSecLogIn2: TdlgSecLogIn2;

implementation

{$R *.DFM}

uses
  gd_directories_const, gd_dlgAbout_unit, gd_DatabasesList_unit
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub, gd_localization
  {$ENDIF}
  ;

procedure TdlgSecLogIn2.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TdlgSecLogIn2.TimerTimer(Sender: TObject);
var
  Ch: array[0..KL_NAMELENGTH] of Char;
begin
  GetKeyboardLayoutName(Ch);
  if KL <> StrToInt('$' + StrPas(Ch)) then
  begin
    KL := StrToInt('$' + StrPas(Ch));
    case (KL and $3ff) of
      LANG_BELARUSIAN: lKL.Caption := '¡≈À';
      LANG_RUSSIAN: lKL.Caption := '–”—';
      LANG_ENGLISH: lKL.Caption := '¿Õ√';
      LANG_GERMAN: lKL.Caption := 'Õ≈Ã';
      LANG_UKRAINIAN: lKL.Caption := '” –';
    else
      lKL.Caption := '';
    end;
  end;
end;

constructor TdlgSecLogIn2.Create(AnOwner: TComponent);
begin
  inherited;
  KL := -1;
end;

destructor TdlgSecLogIn2.Destroy;
begin
  inherited;
end;

procedure TdlgSecLogIn2.actHelpExecute(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TdlgSecLogIn2.actVerExecute(Sender: TObject);
begin
  with Tgd_dlgAbout.Create(Self) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TdlgSecLogIn2.actSelectDBExecute(Sender: TObject);
begin
  gd_DatabasesList.ShowViewForm;
end;

procedure TdlgSecLogIn2.chbxWithoutConnectionClick(Sender: TObject);
begin
  bvl1.Enabled := not chbxWithoutConnection.Checked;
  bvl2.Enabled := not chbxWithoutConnection.Checked;
  lblDBName.Enabled := not chbxWithoutConnection.Checked;
  lblUser.Enabled := not chbxWithoutConnection.Checked;
  lblPassword.Enabled := not chbxWithoutConnection.Checked;
  edDBName.Enabled := not chbxWithoutConnection.Checked;
  cbUser.Enabled := not chbxWithoutConnection.Checked;
  edPassword.Enabled := not chbxWithoutConnection.Checked;
  chbxSingleUser.Enabled := not chbxWithoutConnection.Checked;
  chbxRememberPassword.Enabled := not chbxWithoutConnection.Checked;
  btnSelectDB.Enabled := not chbxWithoutConnection.Checked;
end;

procedure TdlgSecLogIn2.actSelectDBUpdate(Sender: TObject);
begin
  actSelectDB.Enabled := gd_DatabasesList <> nil;
end;

procedure TdlgSecLogIn2.actLoginExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

end.

