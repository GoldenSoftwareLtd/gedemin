
unit gdcReplication;

interface

uses
  Classes, IBCustomDataSet, gdcBase, Forms, gd_createable_form, Controls, DB,
  gdcBaseInterface, IBDataBase;

type
  TrplPrepareStep = (psBackup);

  TgdcRplDatabase = class(TgdcBase)
  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    procedure PrepareRemoteDB(const ADBKey: Integer);
  end;

  TgdcRplDomain = class(TgdcBase)
  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcRplDomainClass = class(TgdcBase)
  protected
    procedure GetWhereClauseConditions(S: TStrings);override;

  public
    class function GetSubSetList: String; override;
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
  end;

procedure Register;

implementation

uses
  IBSQL,
  IBServices,
  dmDataBase_unit,
  Sysutils,
  gd_ClassList,
  gd_security,
  gd_directories_const,
  gdc_dlgRplDatabase_unit,
  gdc_frmRplDatabase_unit,
  gdc_dlgRplDomain_unit,
  gdc_frmRplDomain_unit,
  gdc_dlgRplDomainClass_unit;

const
  cst_ss_ByRplDomain = 'ByRplDomain';  

procedure Register;
begin
  RegisterComponents('gdc', [TgdcRplDatabase, TgdcRplDomain, TgdcRplDomainClass]);
end;

{ TgdcRplDatabase ------------------------------------------------}

class function TgdcRplDatabase.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'NAME';
end;

class function TgdcRplDatabase.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'RP2_BASE';
end;

class function TgdcRplDatabase.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmRplDatabase';
end;

class function TgdcRplDatabase.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgRplDatabase';
end;

{ TgdcRplDomain }

class function TgdcRplDomain.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgRplDomain';
end;

class function TgdcRplDomain.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'NAME';
end;

class function TgdcRplDomain.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'RP2_DOMAIN';
end;

class function TgdcRplDomain.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmRplDomain';
end;

{ TgdcRplDomainClass }

class function TgdcRplDomainClass.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgRplDomainClass';
end;

class function TgdcRplDomainClass.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'NAME';
end;

class function TgdcRplDomainClass.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'RP2_DOMAIN_CLASS';
end;

class function TgdcRplDomainClass.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + cst_ss_ByRplDomain + ';';
end;

class function TgdcRplDomainClass.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmRplDomain';
end;

procedure TgdcRplDomainClass.GetWhereClauseConditions(S: TStrings);
begin
  inherited;

  if HasSubSet(cst_ss_ByRplDomain) then
    S.Add(' z.domainkey = :domainkey ');
end;

(*

  1. Бэкап действующей базы.
  2. Разбэкап с новым именем.
  3. Установка ИД базы.
  4. Создание метаданных.

*)

procedure TgdcRplDatabase.PrepareRemoteDB(const ADBKey: Integer);
var
  CurrStep: TrplPrepareStep;
  IBBackup: TIBBackupService;
begin
  CurrStep := psBackup;

  GlobalStorage.SaveToDatabase;
  UserStorage.SaveToDatabase;
  CompanyStorage.SaveToDatabase;

  IBBackup := TIBBackupService.Create(nil);
  try
    IBBackup.ServerName := IBLogin.ServerName;

    if IBBackup.ServerName > '' then
      IBBackup.Protocol := TCP
    else
      IBBackup.Protocol := Local;

    IBBackup.LoginPrompt := False;
    IBBackup.Params.Clear;
    IBBackup.Params.Add('user_name=' + SysDBAUserName);
    IBBackup.Params.Add('password=' + 'masterkey');
    IBBackup.Verbose := False;
    IBBackup.Options := [NoGarbageCollection];
    IBBackup.DatabaseName := IBLogin.DatabaseName;
    IBBackup.BackupFile.Text := '';

    IBBackup.Active := True;
    IBBackup.ServiceStart;
    while (not IBBackup.Eof) and (IBBackup.IsServiceRunning) do
    begin
      IBBackup.GetNextLine;
    end;
  finally
    IBBackup.Free;
  end;
end;

initialization
  RegisterGdcClass(TgdcRplDatabase);
  RegisterGdcClass(TgdcRplDomain);
  RegisterGdcClass(TgdcRplDomainClass);

finalization
  UnRegisterGdcClass(TgdcRplDatabase);
  UnRegisterGdcClass(TgdcRplDomain);
  UnRegisterGdcClass(TgdcRplDomainClass);
end.
