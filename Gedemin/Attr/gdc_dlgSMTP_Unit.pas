unit gdc_dlgSMTP_Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTR_unit, IBDatabase, Menus, Db, ActnList, StdCtrls, DBCtrls, Mask;

type
  Tgdc_dlgSMTP = class(Tgdc_dlgTR)
    dbeName: TDBEdit;
    dbmDescription: TDBMemo;
    dbeEMAIL: TDBEdit;
    dbeLogin: TDBEdit;
    dbcbIPSec: TDBComboBox;
    dbeTimeout: TDBEdit;
    dbeServer: TDBEdit;
    dbePort: TDBEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    dbcbDisabled: TDBCheckBox;
    btnTest: TButton;
    actCheckConnect: TAction;
    edPassw: TEdit;
    dbcbPrincipal: TDBCheckBox;
    procedure actCheckConnectExecute(Sender: TObject);

  protected
    procedure BeforePost; override;
    procedure SetupRecord; override;
  end;

var
  gdc_dlgSMTP: Tgdc_dlgSMTP;

implementation

uses
  gd_classList, gd_encryption, IdSMTP, IdSSLOpenSSL, gd_AutoTaskThread;

{$R *.DFM}

function GetIPSec(AnIPSec: String): TIdSSLVersion;
begin
  if AnIPSec = 'SSLV2' then
    Result := sslvSSLv2
  else if AnIPSec = 'SSLV23' then
    Result := sslvSSLv23
  else if AnIPSec = 'SSLV3' then
    Result := sslvSSLv3
  else if AnIPSec = 'TLSV1' then
    Result := sslvTLSv1
  else
    raise Exception.Create('Unknown ip security protocol.')
end;

procedure Tgdc_dlgSMTP.BeforePost;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TTGDC_DLGSMTP', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGSMTP', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGSMTP') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGSMTP',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGSMTP' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if edPassw.Text <> '<not changed>' then
    gdcObject.FieldByName('passw').AsString := EncryptString(edPassw.Text, 'PASSW');

  inherited;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGSMTP', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGSMTP', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgSMTP.actCheckConnectExecute(Sender: TObject);
var
  IdSMTP: TidSMTP;
  IdSSLIOHandlerSocket: TIdSSLIOHandlerSocket;
begin
  // https://www.google.com/settings/security/lesssecureapps

  IdSMTP := TidSMTP.Create(nil);
  try
    IdSMTP.Port := StrToInt(dbePort.Text);
    IdSMTP.Host := dbeServer.Text;
    IdSMTP.AuthenticationType := atLogin;
    IdSMTP.Username := dbeLogin.Text;
    if edPassw.Text <> '<not changed>' then
      IdSMTP.Password := edPassw.Text
    else if gdcObject.FieldByName('passw').AsString = '' then
      IdSMTP.Password := ''
    else
      IdSMTP.Password := DecryptString(gdcObject.FieldByName('passw').AsString, 'PASSW');

    if dbcbIPSec.Text > '' then
    begin
      IdSSLIOHandlerSocket := TIdSSLIOHandlerSocket.Create(IdSMTP);
      IdSSLIOHandlerSocket.SSLOptions.Method := GetIPSec(dbcbIPSec.Text);
      IdSMTP.IOHandler := IdSSLIOHandlerSocket;
    end;

    IdSMTP.Connect(StrToInt(dbeTimeout.Text));

    if IdSMTP.Connected then
    begin
      if IdSMTP.Authenticate then
      begin
        MessageBox(Handle, 'Соединение установлено.', 'Тест соединения',
          MB_OK + MB_ICONINFORMATION);
      end;
    end;
  finally
    if IdSMTP.Connected then
      IdSMTP.Disconnect;
    IdSMTP.Free;
  end;
end;

procedure Tgdc_dlgSMTP.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGSMTP', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGSMTP', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGSMTP') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGSMTP',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGSMTP' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  edPassw.Text := '<not changed>';

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGSMTP', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGSMTP', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_dlgSMTP, 'SMTP сервер');

finalization
  UnRegisterFrmClass(Tgdc_dlgSMTP);
end.
