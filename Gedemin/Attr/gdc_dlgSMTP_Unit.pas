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
    dbePassw: TDBEdit;
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
    Button1: TButton;
    actCheckConnect: TAction;
    procedure actCheckConnectExecute(Sender: TObject);

  protected
    procedure SetupDialog; override;
    procedure SetupRecord; override;
  end;

var
  gdc_dlgSMTP: Tgdc_dlgSMTP;

implementation

uses
  gd_classList, gd_common_functions, IdSMTP, IdSSLOpenSSL;

{$R *.DFM}

procedure Tgdc_dlgSMTP.SetupDialog;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGSMTP', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGSMTP', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGSMTP') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGSMTP',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGSMTP' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  dbePassw.MaxLength := dbePassw.MaxLength div 2;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGSMTP', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGSMTP', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgSMTP.SetupRecord;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  PassHex, S: String;
  Len: Integer;
  I, P: Integer;
  B: Byte;
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

  PassHex := gdcObject.FieldByName('PASSW').AsString;
  Len := Length(PassHex) div 2;
  SetLength(S, Len);
  I := 1; P := 1;
  while P <= Len do
  begin
    try
      S[P] := HexToAnsiChar(PassHex, I);
      B := Byte(S[P]);
      B := B xor (1 shl 4);
      S[P] := Chr(B);
    except
      S := '';
      break;
    end;
    Inc(I, 2);
    Inc(P);
  end;

  gdcObject.FieldByName('PASSW').AsString := S;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGSMTP', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGSMTP', 'SETUPRECORD', KEYSETUPRECORD);
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
    IdSMTP.Password := dbePassw.Text;

    if dbcbIPSec.Text > '' then
    begin
      IdSSLIOHandlerSocket := TIdSSLIOHandlerSocket.Create(IdSMTP);
      if dbcbIPSec.Text = 'SSLV2' then
        IdSSLIOHandlerSocket.SSLOptions.Method := sslvSSLv2
      else if dbcbIPSec.Text = 'SSLV23' then
        IdSSLIOHandlerSocket.SSLOptions.Method := sslvSSLv23
      else if dbcbIPSec.Text = 'SSLV3' then
        IdSSLIOHandlerSocket.SSLOptions.Method := sslvSSLv3
      else if dbcbIPSec.Text = 'TLSV1' then
        IdSSLIOHandlerSocket.SSLOptions.Method := sslvTLSv1;

      IdSMTP.IOHandler := IdSSLIOHandlerSocket;
    end;

    IdSMTP.Connect(StrToInt(dbeTimeout.Text));

    if IdSMTP.Connected then
    begin
      if IdSMTP.Authenticate  then
      begin
        MessageBox(Handle, '���������� �����������', '���� ����������',
          MB_OK + MB_ICONINFORMATION);
      end;
    end;
  finally
    if IdSMTP.Connected then
      IdSMTP.Disconnect;
    IdSMTP.Free;
  end;
end;

initialization
  RegisterFrmClass(Tgdc_dlgSMTP, '�������� ����');

finalization
  UnRegisterFrmClass(Tgdc_dlgSMTP);

end.
