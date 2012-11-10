
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
    procedure actLoginUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbUserChange(Sender: TObject);

  private
    KL: Integer;

    procedure SyncControls;

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
  if gd_DatabasesList.ShowViewForm then
    SyncControls;
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
var
  DI: Tgd_DatabaseItem;
begin
  if chbxWithoutConnection.Checked then
    ModalResult := mrOk
  else begin
    ModalResult := mrCancel;
    if gd_DatabasesList <> nil then
    begin
      DI := gd_DatabasesList.FindSelected;
      if DI <> nil then
      begin
        DI.EnteredLogin := cbUser.Text;

        if edPassword.Text = '<<saved_password>>' then
          DI.EnteredPassword := DI.GetPassword(cbUser.Text)
        else
          DI.EnteredPassword := edPassword.Text;

        DI.AddUser(DI.EnteredLogin, DI.EnteredPassword);
        DI.RememberPassword := chbxRememberPassword.Checked;
        ModalResult := mrOk;
      end;
    end;
  end;
end;

procedure TdlgSecLogIn2.actLoginUpdate(Sender: TObject);
begin
  actLogin.Enabled := chbxWithoutConnection.Checked
    or ((cbUser.Text > '') and (gd_DatabasesList.FindSelected <> nil));
end;

procedure TdlgSecLogIn2.SyncControls;
var
  DI: Tgd_DatabaseItem;
begin
  chbxWithoutConnection.Checked := False;

  if gd_DatabasesList <> nil then
    DI := gd_DatabasesList.FindSelected
  else
    DI := nil;

  if DI <> nil then
  begin
    edDBName.Text := DI.Name;
    DI.GetUsers(cbUser.Items);
    if cbUser.Items.Count > 0 then
      cbUser.Text := cbUser.Items[0]
    else
      cbUser.Text := '';
    if DI.GetPassword(cbUser.Text) > '' then
      edPassword.Text := '<<saved_password>>'
    else
      edPassword.Text := '';
    chbxRememberPassword.Checked := DI.RememberPassword;
  end else
  begin
    edDBName.Text := '';
    cbUser.Items.Clear;
    cbUser.Text := '';
    edPassword.Text := '';
    chbxRememberPassword.Checked := False;
  end;

  if cbUser.Items.IndexOf('Administrator') = -1 then
    cbUser.Items.Add('Administrator');

  if edDBName.Text = '' then
    ActiveControl := btnSelectDB
  else if cbUser.Text= '' then
    ActiveControl := cbUser
  else
    ActiveControl := edPassword;
end;

procedure TdlgSecLogIn2.FormCreate(Sender: TObject);
begin
  SyncControls;
end;

procedure TdlgSecLogIn2.cbUserChange(Sender: TObject);
var
  DI: Tgd_DatabaseItem;
begin
  if gd_DatabasesList <> nil then
  begin
    DI := gd_DatabasesList.FindSelected;
    if DI <> nil then
    begin
      if DI.GetPassword(cbUser.Text) > '' then
        edPassword.Text := '<<saved_password>>'
      else
        edPassword.Text := '';
    end;
  end;
end;

end.

