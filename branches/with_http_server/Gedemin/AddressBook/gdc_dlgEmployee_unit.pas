
unit gdc_dlgEmployee_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgContact_unit, IBDatabase, Menus, Db, ActnList, at_Container,
  DBCtrls, xDateEdits, StdCtrls, gsIBLookupComboBox, Mask, ComCtrls,
  ExtCtrls, gdcBase;

type
  Tgdc_dlgEmployee = class(Tgdc_dlgContact)
    procedure gsIBlcWCompanyKeyChange(Sender: TObject);
    procedure gsibluFolderCreateNewObject(Sender: TObject;
      ANewObject: TgdcBase);
    procedure gsibluFolderAfterCreateDialog(Sender: TObject;
      ANewObject: TgdcBase);
    procedure actMakeEmployeeExecute(Sender: TObject);

  public
    procedure SyncField(Field: TField; SyncList: TList); override;
    function CallSyncField(const Field: TField; const SyncList: TList): Boolean; override;

    function TestCorrect: Boolean; override;

    procedure SetupDialog; override;
    procedure SetupRecord; override;
  end;

var
  gdc_dlgEmployee: Tgdc_dlgEmployee;

implementation
{$R *.DFM}

uses
  IBSQL,
  gd_ClassList,
  gdcBaseInterface,
  gdcContacts,
  Gedemin_TLB,
  gd_security, Storages
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{ Tgdc_dlgEmployee }

procedure Tgdc_dlgEmployee.SetupRecord;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}

  q: TIBSQL;
  P: Integer;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGEMPLOYEE', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGEMPLOYEE', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGEMPLOYEE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGEMPLOYEE',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGEMPLOYEE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if not gdcObject.FieldByName('parent').IsNull then
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcBaseManager.ReadTransaction;
      q.SQL.Text := 'SELECT id, parent, lb, rb, contacttype FROM gd_contact WHERE id = :ID';
      q.ParamByName('id').AsInteger := gdcObject.FieldByName('parent').AsInteger;
      q.ExecQuery;
      while
        (not q.EOF)
        and (q.FieldByName('contacttype').AsInteger = 4)
        and (not q.FieldByName('parent').IsNull) do
      begin
        P := q.FieldByName('parent').AsInteger;
        q.Close;
        q.ParamByName('id').AsInteger := P;
        q.ExecQuery;
      end;

      if not q.EOF then
      begin
        if q.FieldByName('contacttype').AsInteger <> 4 then
          gsIBlcWCompanyKey.CurrentKeyInt := q.FieldByName('id').AsInteger
        else
          gsibluFolder.Condition := Format('contacttype=4 AND lb > (SELECT c1.lb FROM gd_contact c1 WHERE c1.id = %d) AND rb <= (SELECT c2.rb FROM gd_contact c2 WHERE c2.id = %d)',
            [q.FieldByName('id').Asinteger, q.FieldByName('id').AsInteger]);
      end else
      begin
        gsibluFolder.Condition := 'contacttype=4';
      end;

      // нужно для перечитывания из базы данных после смены
      // кондишена
      gsibluFolder.CurrentKey := gsibluFolder.CurrentKey;
    finally
      q.Free;
    end;
  end;

  gsIBlcWCompanyKey.ReadOnly := not gdcObject.FieldByName('wcompanykey').IsNull;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGEMPLOYEE', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGEMPLOYEE', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgEmployee.gsIBlcWCompanyKeyChange(Sender: TObject);
begin
  if gsIBlcWCompanyKey.CurrentKey > '' then
  begin
    gsibluFolder.Condition := Format('contacttype=4 AND lb > (SELECT c1.lb FROM gd_contact c1 WHERE c1.id=%d) AND rb <= (SELECT c2.rb FROM gd_contact c2 WHERE c2.id=%d)',
      [gsIBlcWCompanyKey.CurrentKeyInt, gsIBlcWCompanyKey.CurrentKeyInt]);

    // у другой компании такого подразделения не будет
    // надо перечитать
    gsibluFolder.CurrentKey := gsibluFolder.CurrentKey;
  end;
end;

procedure Tgdc_dlgEmployee.gsibluFolderCreateNewObject(Sender: TObject;
  ANewObject: TgdcBase);
begin
  if ANewObject.Transaction <> gdcObject.Transaction then
  begin
    ANewObject.Cancel;
    ANewObject.Close;
    ANewObject.ReadTransaction := gdcObject.Transaction;
    ANewObject.Transaction := gdcObject.Transaction;
    ANewObject.Open;
    ANewObject.Insert;
  end;

  if gsibluFolder.CurrentKey > '' then
    ANewObject.FieldByName('parent').AsInteger := gsibluFolder.CurrentKeyInt
  else if gsIBlcWCompanyKey.CurrentKey > '' then
    ANewObject.FieldByName('parent').AsInteger := gsIBlcWCompanyKey.CurrentKeyInt;
end;

procedure Tgdc_dlgEmployee.gsibluFolderAfterCreateDialog(Sender: TObject;
  ANewObject: TgdcBase);
begin
  gsIBlcWCompanyKeyChange(nil);
end;

procedure Tgdc_dlgEmployee.actMakeEmployeeExecute(Sender: TObject);
var
  ID: Integer;
  q: TIBSQL;
  DidActivate: Boolean;
begin
  if MessageBox(Handle,
    'Изменить тип данного объекта с Сотрудник на Физическое лицо?',
    'Внимание',
    MB_YESNO or MB_ICONQUESTION) = IDYES then
  begin
    BeforePost;
    if TestCorrect then
    begin
      ID := TgdcFolder.SelectObject('Укажите папку, где будет размещена запись:', 'Выбор папки');
      if ID <> -1 then
      begin
        gdcObject.FieldByName('parent').AsInteger := ID;

        DidActivate := False;
        q := TIBSQL.Create(nil);
        try
          q.Transaction := gdcObject.Transaction;
          DidActivate := not q.Transaction.InTransaction;
          if DidActivate then
            q.Transaction.StartTransaction;

          q.SQL.Text := 'UPDATE gd_company SET directorkey=NULL WHERE directorkey=' +
            IntToStr(gdcObject.ID);
          q.ExecQuery;

          q.SQL.Text := 'UPDATE gd_company SET chiefaccountantkey=NULL WHERE chiefaccountantkey=' +
            IntToStr(gdcObject.ID);
          q.ExecQuery;

          if DidActivate and q.Transaction.InTransaction then
            q.Transaction.Commit;
        finally
          if DidActivate and q.Transaction.InTransaction then
            q.Transaction.Rollback;
          q.Free;
        end;

        ModalResult := mrOk;
      end;
    end;
  end;
end;

procedure Tgdc_dlgEmployee.SyncField(Field: TField; SyncList: TList);
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_DLGG_SYNCFIELD('TGDC_DLGEMPLOYEE', 'SYNCFIELD', KEYSYNCFIELD)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGEMPLOYEE', KEYSYNCFIELD);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSYNCFIELD]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGEMPLOYEE') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf(
  {M}        [GetGdcInterface(Self), GetGdcInterface(Field) as IgsFieldComponent,
  {M}         GetGdcInterface(SyncList) as IgsList]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGEMPLOYEE',
  {M}        'SYNCFIELD', KEYSYNCFIELD, Params, LResult) then exit;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGEMPLOYEE' then
  {M}      begin
  {M}        Inherited;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  inherited;

  if Field.FieldName = 'PARENT' then
    (gdcObject as TgdcEmployee).SetWCompanyKeyByDepartment;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGEMPLOYEE', 'SYNCFIELD', KEYSYNCFIELD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGEMPLOYEE', 'SYNCFIELD', KEYSYNCFIELD);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgEmployee.SetupDialog;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGEMPLOYEE', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGEMPLOYEE', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGEMPLOYEE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGEMPLOYEE',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGEMPLOYEE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  gsIBlcWCompanyKey.Transaction := gdcObject.Transaction;
  gsibluFolder.Transaction := gdcObject.Transaction;
  ActivateTransaction(gdcObject.Transaction);
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGEMPLOYEE', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGEMPLOYEE', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

function Tgdc_dlgEmployee.CallSyncField(const Field: TField;
  const SyncList: TList): Boolean;
begin
  Result := inherited CallSyncField(Field, SyncList) or
    ((Field.DataSet = gdcObject) and
      (Field.FieldName = 'PARENT'));

end;

function Tgdc_dlgEmployee.TestCorrect: Boolean;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  q: TIBSQL;
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_DLGEMPLOYEE, 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGEMPLOYEE', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGEMPLOYEE') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGEMPLOYEE',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGEMPLOYEE' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  Result := inherited TestCorrect;

  if Result
    and (not (sMultiple in gdcObject.BaseState))
    and Assigned(GlobalStorage)
    and GlobalStorage.ReadBoolean('Options', 'Duplicates', True)
    and GlobalStorage.ReadBoolean('Options', 'CheckName', True) then
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcBaseManager.ReadTransaction;
      q.SQL.Text := ' SELECT p.firstname, p.surname, p.middlename FROM gd_people p ' +
        ' WHERE UPPER(p.firstname) = :fname ' +
        '   AND UPPER(p.surname) = :sname ' +
        '   AND UPPER(p.middlename) = :mname ' +
        '   AND wcompanykey = :companykey ' +
        '   AND p.contactkey <> :id';
      q.Params[0].AsString := AnsiUpperCase(Trim(gdcObject.FieldByName('firstname').AsString));
      q.Params[1].AsString := AnsiUpperCase(Trim(gdcObject.FieldByName('surname').AsString));
      q.Params[2].AsString := AnsiUpperCase(Trim(gdcObject.FieldByName('middlename').AsString));
      q.Params[3].AsInteger := IBLogin.CompanyKey;
      q.Params[4].AsInteger := gdcObject.ID;
      q.ExecQuery;
      if not q.EOF then
      begin
        if MessageBox(Handle,
          PChar(
          'Сотрудник с таким наименованием уже существует в базе данных!'#13#10#13#10 +
          gdcObject.FieldByName('name').AsString + #13#10 +
          'Ввод дублирующихся записей не рекомендован.'#13#10 +
          'Отключить данную проверку Вы можете в окне "Опции" пункта "Сервис" главного меню.'#13#10#13#10 +
          'Вернуться к редактированию сотрудника?'#13#10#13#10 +
          'Нажмите "Да" для того, чтобы вернуться в окно редактирования и ввести другое наименование.'#13#10 +
          'Нажмите "Нет" для того, чтобы сохранить запись с таким наименованием в базе данных.'),
          'Внимание',
          MB_YESNO or MB_ICONEXCLAMATION) = IDYES then
        begin
          Result := False;
          exit;
        end;
      end;
      q.Close;
    finally
      q.Free;
    end;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGCEMPLOYEE', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGEMPLOYEE', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_dlgEmployee);

finalization
  UnRegisterFrmClass(Tgdc_dlgEmployee);

end.
