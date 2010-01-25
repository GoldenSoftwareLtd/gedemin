
{

  TgdcBaseBank            - ������� ����� ��� ���������� � ��������� ������
  TgdcCompanyAccountType  - ��� ���������� �����

  Revisions history

    1.00    29.10.00    sai        Initial version.
}

unit gdcBaseBank;

interface

uses
  Classes, IBCustomDataSet, gdcBase, Forms, gd_createable_form,
  IBSQL, gsTransaction, contnrs, tr_Type_unit, DBGrids, gdcClasses, gdcBaseInterface;

type
  TgdcBaseBank = class(TgdcDocument)
  private
    FgsTransaction: TgsTransaction;

    function GetgsTransaction: TgsTransaction;
    procedure SetgsTransaction(const Value: TgsTransaction);

  protected
    procedure _DoOnNewRecord; override;
    procedure DoBeforePost; override;

    function GetNotCopyField: String; override;

  public
    procedure Assign(Source: TPersistent); override;
    function GetBankInfo(AccountKey: String): String;

    class function GetSubSetList: String; override;

    property gsTransaction: TgsTransaction read GetgsTransaction write SetgsTransaction;
  end;

  TgdcCompanyAccountType = class(TgdcBase)
  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
  end;

procedure Register;

implementation

uses
  DB, SysUtils, Dialogs, Controls, Windows,
  gdc_dlgCompanyAccountType_unit, gd_ClassList, gdc_frmAccountType_unit;


procedure Register;
begin
  RegisterComponents('gsNew', [TgdcCompanyAccountType]);
end;

{ TgdcBaseBank }

procedure TgdcBaseBank.Assign(Source: TPersistent);
begin
  inherited;
  FgsTransaction := (Source as TgdcBaseBank).gsTransaction;
end;

procedure TgdcBaseBank._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASEBANK', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASEBANK', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASEBANK') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASEBANK',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASEBANK' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if HasSubSet('ByAccount') then
    FieldByName('AccountKey').AsInteger := ParamByName('AccountKey').AsInteger;
  FieldByName('documentkey').AsInteger := FieldByName('ID').AsInteger;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASEBANK', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASEBANK', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

function TgdcBaseBank.GetBankInfo(AccountKey: String): String;
var
  q: TIBSQL;
  DidActivate: Boolean;
begin
  if (AccountKey = '') then
  begin
    Result := '';
    exit;
  end;

  DidActivate := False;
  q := TIBSQL.Create(nil);
  try
    q.Database := Database;
    q.Transaction := ReadTransaction;
    DidActivate := ActivateReadTransaction;

    q.Close;
    q.SQL.Text :=
      ' SELECT COMP.FULLNAME, C.CITY, BANK.BANKCODE, BANK.BANKKEY ' +
      ' FROM GD_COMPANYACCOUNT A, GD_COMPANY COMP ' +
      '  JOIN GD_CONTACT C ON COMP.CONTACTKEY = C.ID ' +
      '  JOIN GD_BANK BANK ON COMP.CONTACTKEY = BANK.BANKKEY ' +
      ' WHERE A.ID = :Id  AND COMP.CONTACTKEY = A.BANKKEY';
    q.Prepare;

    q.ParamByName('Id').AsString := AccountKey;
    q.ExecQuery;
    Result := q.FieldByName('FULLNAME').AsString + ', ��� ' +
      q.FieldByName('BANKCODE').AsString;
  finally
    q.Free;

    if DidActivate then
      DeactivateReadTransaction;
  end;
end;

function TgdcBaseBank.GetgsTransaction: TgsTransaction;
begin
  Result := FgsTransaction;
end;

class function TgdcBaseBank.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByAccount;'; 
end;

procedure TgdcBaseBank.SetgsTransaction(const Value: TgsTransaction);
begin
  FgsTransaction := Value;
end;

procedure TgdcBaseBank.DoBeforePost;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  ibsql: TIBSQL;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASEBANK', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASEBANK', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASEBANK') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASEBANK',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASEBANK' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := ReadTransaction;
    ibsql.SQL.Text := 'SELECT companykey FROM gd_companyaccount WHERE id = :id';
    ibsql.ParamByName('id').AsInteger := FieldByName('accountkey').AsInteger;
    ibsql.ExecQuery;
    if ibsql.RecordCount > 0 then
    begin
      if FieldByName('companykey').AsInteger <> ibsql.FieldByName('companykey').AsInteger then
        FieldByName('companykey').AsInteger := ibsql.FieldByName('companykey').AsInteger;
    end;
    ibsql.Close;
  finally
    ibsql.Free;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASEBANK', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASEBANK', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}

end;

function TgdcBaseBank.GetNotCopyField: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETNOTCOPYFIELD('TGDCBASEBANK', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASEBANK', KEYGETNOTCOPYFIELD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETNOTCOPYFIELD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASEBANK') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASEBANK',
  {M}          'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'GETNOTCOPYFIELD' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASEBANK' then
  {M}        begin
  {M}          Result := Inherited GetNotCopyField;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := inherited GetNotCopyField + ',DOCUMENTKEY';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASEBANK', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASEBANK', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD);
  {M}  end;
  {END MACRO}
end;

{ TgdcCompanyAccountType }

class function TgdcCompanyAccountType.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgCompanyAccountType';
end;

class function TgdcCompanyAccountType.GetKeyField(const ASubType: TgdcSubType): String;
begin
  Result := 'id';
end;

class function TgdcCompanyAccountType.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'name';
end;

class function TgdcCompanyAccountType.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'GD_COMPACCTYPE';
end;

class function TgdcCompanyAccountType.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmAccountType';
end;

initialization
  RegisterGdcClass(TgdcBaseBank);
  RegisterGdcClass(TgdcCompanyAccountType);

finalization
  UnRegisterGdcClass(TgdcBaseBank);
  UnRegisterGdcClass(TgdcCompanyAccountType);
end.
