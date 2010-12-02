
unit gdcReplication;

interface

uses
  Classes, IBCustomDataSet, gdcBase, Forms, gd_createable_form, Controls, DB,
  gdcBaseInterface, IBDataBase;

type
  TrplPrepareStep = (psBackup);

  TgdcRplDatabase = class(TgdcBase)
  protected
    function CheckTheSameStatement: String; override;
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

function TgdcRplDatabase.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCRPLDATABASE', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCRPLDATABASE', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCRPLDATABASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCRPLDATABASE',
  {M}          'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'CHECKTHESAMESTATEMENT' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCRPLDATABASE' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  //Стандартные записи ищем по идентификатору
  if FieldByName(GetKeyField(SubType)).AsInteger < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    Result := inherited CheckTheSameStatement;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCRPLDATABASE', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCRPLDATABASE', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
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
