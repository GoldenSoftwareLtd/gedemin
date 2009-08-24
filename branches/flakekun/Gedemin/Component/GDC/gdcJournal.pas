
unit gdcJournal;

interface

uses
  Forms, Classes, DB, gdcBase, gdcBaseInterface, gd_createable_form,
  IBDatabase;

type
  TgdcJournal = class(TgdcBase)
  protected
    function GetSelectClause: String; override;
    function GetOrderClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    procedure GetWhereClauseConditions(S: TStrings); override;

    function CreateDialogForm: TCreateableForm; override;

  public
    procedure CreateTriggers;
    procedure DropTriggers;

    class procedure AddEvent(const AData: String;
      const ASource: String = '';
      const AnObjectID: Integer = -1;
      const ATransaction: TIBTransaction = nil;
      const AForce: Boolean = False);

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;
  end;

procedure Register;

implementation

uses
  Windows, Controls, IBSQL, SysUtils, gd_directories_const, gdc_frmJournal_unit,
  gd_ClassList, ComObj, gdcMetaData, gd_KeyAssoc, gd_security, Storages
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcJournal]);
end;

{ TgdcJournal }

function TgdcJournal.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCJOURNAL', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCJOURNAL', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCJOURNAL') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCJOURNAL',
  {M}          'CREATEDIALOGFORM', KEYCREATEDIALOGFORM, Params, LResult) then
  {M}          begin
  {M}            Result := nil;
  {M}            if VarType(LResult) <> varDispatch then
  {M}              raise Exception.Create('Скрипт-функция: ' + Self.ClassName +
  {M}                TgdcBase(Self).SubType + 'CREATEDIALOGFORM' + #13#10 + 'Для метода ''' +
  {M}                'CREATEDIALOGFORM' + ' ''' + 'класса ' + Self.ClassName +
  {M}                TgdcBase(Self).SubType + #10#13 + 'Из макроса возвращен не объект.')
  {M}            else
  {M}              if IDispatch(LResult) = nil then
  {M}                raise Exception.Create('Скрипт-функция: ' + Self.ClassName +
  {M}                  TgdcBase(Self).SubType + 'CREATEDIALOGFORM' + #13#10 + 'Для метода ''' +
  {M}                  'CREATEDIALOGFORM' + ' ''' + 'класса ' + Self.ClassName +
  {M}                  TgdcBase(Self).SubType + #10#13 + 'Из макроса возвращен пустой (null) объект.');
  {M}            Result := GetInterfaceToObject(LResult) as TCreateableForm;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCJOURNAL' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := nil;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCJOURNAL', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCJOURNAL', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

function TgdcJournal.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCJOURNAL', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCJOURNAL', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCJOURNAL') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCJOURNAL',
  {M}          'GETFROMCLAUSE', KEYGETFROMCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETFROMCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCJOURNAL' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    'FROM gd_journal z LEFT JOIN gd_contact u ON u.id=z.contactkey ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCJOURNAL', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCJOURNAL', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcJournal.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'id';
end;

class function TgdcJournal.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'GD_JOURNAL';
end;

function TgdcJournal.GetOrderClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETORDERCLAUSE('TGDCJOURNAL', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCJOURNAL', KEYGETORDERCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETORDERCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCJOURNAL') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCJOURNAL',
  {M}          'GETORDERCLAUSE', KEYGETORDERCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETORDERCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCJOURNAL' then
  {M}        begin
  {M}          Result := Inherited GetOrderClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if sView in BaseState then
    Result := ' '
  else
    Result := 'ORDER BY z.operationdate DESC ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCJOURNAL', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCJOURNAL', 'GETORDERCLAUSE', KEYGETORDERCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcJournal.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCJOURNAL', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCJOURNAL', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCJOURNAL') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCJOURNAL',
  {M}          'GETSELECTCLAUSE', KEYGETSELECTCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETSELECTCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCJOURNAL' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    'SELECT ' +
    '  z.id,' +
    '  z.contactkey,' +
    '  z.operationdate,' +
    '  z.source,' +
    '  z.objectid,' +
    '  z.data,' +
    '  u.name' +
    ' ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCJOURNAL', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCJOURNAL', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcJournal.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmJournal';
end;

procedure TgdcJournal.CreateTriggers;

  function GetUniqName(const Prefix: String): String;
  begin
    Result := System.Copy(Prefix + StringReplace(
      StringReplace(
        StringReplace(CreateClassID, '{', '', [rfReplaceAll]), '}', '', [rfReplaceAll]),
        '-', '', [rfReplaceAll]), 1, 31);
  end;

const
  cInsertTrigger =
    'CREATE TRIGGER %s FOR %s' +
    '  AFTER INSERT ' +
    '  POSITION 29861 ' +
    'AS ' +
    'BEGIN' +
    '  INSERT INTO gd_journal (source, data, objectid) ' +
    '    VALUES (''%s'', ''Добавлена запись.'', NEW.id); ' +
    'END' +
    '';

  cInsertTrigger2 =
    'CREATE TRIGGER %s FOR %s' +
    '  AFTER INSERT ' +
    '  POSITION 29861 ' +
    'AS ' +
    'BEGIN' +
    '  INSERT INTO gd_journal (source, data) ' +
    '    VALUES (''%s'', ''Добавлена запись.''); ' +
    'END' +
    '';

  cUpdateTrigger =
    'CREATE TRIGGER %s FOR %s'#13#10 +
    '  AFTER UPDATE '#13#10 +
    '  POSITION 29861 '#13#10 +
    'AS '#13#10 +
    '  DECLARE VARIABLE S VARCHAR(32000); '#13#10 +
    'BEGIN'#13#10 +
    '  '#13#10 +
    '  S = ''''; '#13#10 +
    '  '#13#10 +
    '  %s'#13#10 +
    '  IF (S > '''') THEN '#13#10 +
    '    INSERT INTO gd_journal (source, data, objectid) '#13#10 +
    '      VALUES (''%s'', ''Изменена запись.'' || :S, NEW.id); '#13#10 +
    '  '#13#10 +
    '  WHEN ANY DO '#13#10 +
    '    S = ''''; '#13#10 +
    'END'#13#10 +
    '';

  cUpdateTrigger2 =
    'CREATE TRIGGER %s FOR %s'#13#10 +
    '  AFTER UPDATE '#13#10 +
    '  POSITION 29861 '#13#10 +
    'AS '#13#10 +
    '  DECLARE VARIABLE S VARCHAR(32000); '#13#10 +
    'BEGIN'#13#10 +
    '  '#13#10 +
    '  S = ''''; '#13#10 +
    '  '#13#10 +
    '  %s'#13#10 +
    '  IF (S > '''') THEN '#13#10 +
    '    INSERT INTO gd_journal (source, data) '#13#10 +
    '      VALUES (''%s'', ''Изменена запись.'' || :S); '#13#10 +
    '  '#13#10 +
    '  WHEN ANY DO '#13#10 +
    '    S = ''''; '#13#10 +
    'END'#13#10 +
    '';

  cDeleteTrigger =
    'CREATE TRIGGER %s FOR %s' +
    '  AFTER DELETE ' +
    '  POSITION 29861 ' +
    'AS ' +
    'BEGIN' +
    '  INSERT INTO gd_journal (source, data, objectid) ' +
    '    VALUES (''%s'', ''Удалена запись.'', OLD.id); ' +
    'END' +
    '';

  cDeleteTrigger2 =
    'CREATE TRIGGER %s FOR %s' +
    '  AFTER DELETE ' +
    '  POSITION 29861 ' +
    'AS ' +
    'BEGIN' +
    '  INSERT INTO gd_journal (source, data) ' +
    '    VALUES (''%s'', ''Удалена запись.''); ' +
    'END' +
    '';

  cCompare =
    'IF ((NEW.%0:s <> OLD.%0:s) OR (NEW.%0:s IS NULL AND (NOT OLD.%0:s IS NULL)) OR (NOT NEW.%0:s IS NULL AND OLD.%0:s IS NULL)) THEN '#13#10 +
    'BEGIN '#13#10 +
    '  IF (NEW.%0:s IS NULL) THEN '#13#10 +
    '    S = :S || ''%1:s'' || CAST(OLD.%0:s AS VARCHAR(32000)) || '' -> NULL ''; '#13#10 +
    '  ELSE IF (OLD.%0:s IS NULL) THEN'#13#10 +
    '    S = :S || ''%1:s'' || '' NULL -> '' || CAST(NEW.%0:s AS VARCHAR(32000)); '#13#10 +
    '  ELSE '#13#10 +
    '    S = :S || ''%1:s'' || CAST(OLD.%0:s AS VARCHAR(32000)) || '' -> '' || CAST(NEW.%0:s AS VARCHAR(32000)); '#13#10 +
    ' ' +
    'END '#13#10 +
    ' '#13#10 +
    ' ';
var
  qTables, qTrigger, qFields, qHasID, qTestTable: TIBSQL;
  Tr: TIBTransaction;
  OldCursor: TCursor;
  S, S2: String;
  KA: TgdKeyArray;
  V: OleVariant;
begin
  if MessageBox(ParentHandle,
    'Перед созданием триггеров будет выполнен поиск и удаление '#13#10 +
    'существующих триггеров, регистрирующих изменение данных.',
    'Внимание',
    MB_ICONEXCLAMATION or MB_OKCANCEL) = IDCANCEL then
  begin
    exit;
  end;

  DropTriggers;

  KA := nil;
  try
    if MessageBox(ParentHandle,
      'Создавать триггеры для всех таблиц?',
      'Внимание',
      MB_ICONQUESTION or MB_YESNO) = IDNO then
    begin
      KA := TgdKeyArray.Create;
      if not ChooseItems(TgdcTable, KA, V, '', 'All') then
        exit;
    end;

    if MessageBox(ParentHandle,
      'Создание триггеров может занять несколько минут.',
      'Внимание',
      MB_ICONEXCLAMATION or MB_OKCANCEL) = IDCANCEL then
    begin
      exit;
    end;

    OldCursor := Screen.Cursor;
    try
      Screen.Cursor := crHourGlass;

      qTables := TIBSQL.Create(nil);
      qTrigger := TIBSQL.Create(nil);
      qFields := TIBSQL.Create(nil);
      qHasID := TIBSQL.Create(nil);
      qTestTable := TIBSQL.Create(nil);
      Tr := TIBTransaction.Create(nil);
      try
        Tr.DefaultDatabase := Database;

        qTrigger.ParamCheck := False;
        qTrigger.Transaction := Tr;

        qFields.Transaction := ReadTransaction;
        qFields.SQL.Text := 'SELECT r.rdb$field_name FROM rdb$relation_fields r ' +
          'JOIN rdb$fields f ON f.rdb$field_name = r.rdb$field_source ' +
          'WHERE f.rdb$segment_length IS NULL AND r.rdb$relation_name = :RN ' +
          'AND f.rdb$computed_blr IS NULL ';
        qFields.Prepare;

        qHasID.Transaction := ReadTransaction;
        qHasID.SQL.Text := 'SELECT rdb$field_name FROM rdb$relation_fields ' +
          ' WHERE rdb$relation_name = :RN AND rdb$field_name = ''ID'' ';
        qHasID.Prepare;

        qTestTable.Transaction := ReadTransaction;
        qTestTable.SQL.Text := 'SELECT id FROM at_relations WHERE relationname=:RN ';
        qTestTable.Prepare;

        qTables.Transaction := ReadTransaction;
        qTables.SQL.Text := 'SELECT DISTINCT r.rdb$relation_name FROM rdb$relation_fields r WHERE ' +
          ' r.rdb$relation_name <> ''GD_JOURNAL'' AND NOT r.rdb$relation_name STARTING WITH ''RDB$'' ' +
          ' AND NOT r.rdb$relation_name STARTING WITH ''RPL'' ';

        if not qTables.Transaction.Active then
          qTables.Transaction.StartTransaction;

        qTables.ExecQuery;

        while not qTables.EOF do
        begin
          if KA <> nil then
          begin
            qTestTable.Close;
            qTestTable.ParamByName('RN').AsString := qTables.Fields[0].AsTrimString;
            qTestTable.ExecQuery;

            if KA.IndexOf(qTestTable.Fields[0].AsInteger) = -1 then
            begin
              qTables.Next;
              continue;
            end;
          end;

          qHasID.Close;
          qHasID.ParamByName('RN').AsString := qTables.Fields[0].AsTrimString;
          qHasID.ExecQuery;

          if qHasID.RecordCount > 0 then
            S2 := cInsertTrigger
          else
            S2 := cInsertTrigger2;

          qTrigger.SQL.Text := Format(S2,
            [GetUniqName('ai'), qTables.Fields[0].AsTrimString, qTables.Fields[0].AsTrimString]);

          try
            qTrigger.Transaction.StartTransaction;
            qTrigger.ExecQuery;
            qTrigger.Close;
            qTrigger.Transaction.Commit;
          except
            qTrigger.Transaction.Rollback;
          end;

          qFields.Close;
          qFields.ParamByName('RN').AsString := qTables.Fields[0].AsTrimString;
          qFields.ExecQuery;
          S := '';
          while not qFields.EOF do
          begin
            // LB, RB могут массово меняться при расширении ветки
            // дерева. Не будем в этом случае ничего заносить в лог
            if (qFields.Fields[0].AsTrimString <> 'LB') and (qFields.Fields[0].AsTrimString <> 'RB') then
              S := S +
                Format(cCompare, [qFields.Fields[0].AsTrimString, #13#10 + qFields.Fields[0].AsTrimString + ': ']);
            qFields.Next;
          end;

          if qHasID.RecordCount > 0 then
            S2 := cUpdateTrigger
          else
            S2 := cUpdateTrigger2;

          qTrigger.SQL.Text := Format(S2,
            [GetUniqName('au'), qTables.Fields[0].AsTrimString,
              S,
              qTables.Fields[0].AsTrimString]);

          try
            qTrigger.Transaction.StartTransaction;
            qTrigger.ExecQuery;
            qTrigger.Close;
            qTrigger.Transaction.Commit;
          except
            qTrigger.Transaction.Rollback;
          end;

          if qHasID.RecordCount > 0 then
            S2 := cDeleteTrigger
          else
            S2 := cDeleteTrigger2;

          qTrigger.SQL.Text := Format(S2,
            [GetUniqName('ad'), qTables.Fields[0].AsTrimString, qTables.Fields[0].AsTrimString]);

          try
            qTrigger.Transaction.StartTransaction;
            qTrigger.ExecQuery;
            qTrigger.Close;
            qTrigger.Transaction.Commit;
          except
            qTrigger.Transaction.Rollback;
          end;

          qTables.Next;
        end;

        qTables.Close;
      finally
        qHasID.Free;
        qTables.Free;
        qTrigger.Free;
        qTestTable.Free;
        Tr.Free;
      end;

      MessageBox(ParentHandle,
        'Создание триггеров успешно завершено.',
        'Журнал',
        MB_OK or MB_ICONINFORMATION);
    finally
      Screen.Cursor := OldCursor;
    end;
  finally
    KA.Free;
  end;
end;

procedure TgdcJournal.DropTriggers;
const
  cDropTrigger = 'DROP TRIGGER %s ';
var
  qTriggers, qTrigger: TIBSQL;
  Tr: TIBTransaction;
  OldCursor: TCursor;
begin
  OldCursor := Screen.Cursor;
  try
    qTriggers := TIBSQL.Create(nil);
    qTrigger := TIBSQL.Create(nil);
    Tr := TIBTransaction.Create(nil);
    try
      Tr.DefaultDatabase := Database;

      qTrigger.ParamCheck := False;
      qTrigger.Transaction := Tr;

      qTriggers.Transaction := ReadTransaction;
      qTriggers.SQL.Text := 'SELECT rdb$trigger_name FROM rdb$triggers WHERE rdb$trigger_sequence = 29861 ' +
        'AND rdb$trigger_name STARTING WITH ''A'' ';

      if not qTriggers.Transaction.Active then
        qTriggers.Transaction.StartTransaction;

      qTriggers.ExecQuery;

      if qTriggers.EOF or
        (MessageBox(ParentHandle,
        'Удаление триггеров может занять несколько минут.',
        'Внимание',
        MB_ICONEXCLAMATION or MB_OKCANCEL) = IDCANCEL) then
      begin
        exit;
      end;

      Screen.Cursor := crHourGlass;

      while not qTriggers.EOF do
      begin
        qTrigger.SQL.Text := Format(cDropTrigger,
          [qTriggers.Fields[0].AsTrimString]);

        try
          qTrigger.Transaction.StartTransaction;
          qTrigger.ExecQuery;
          qTrigger.Close;
          qTrigger.Transaction.Commit;
        except
          qTrigger.Transaction.Rollback;
        end;

        qTriggers.Next;
      end;

      qTriggers.Close;
    finally
      qTriggers.Free;
      qTrigger.Free;
      Tr.Free;
    end;

    MessageBox(ParentHandle,
      'Удаление триггеров успешно завершено.',
      'Журнал',
      MB_OK or MB_ICONINFORMATION);
  finally
    Screen.Cursor := OldCursor;
  end;
end;

class procedure TgdcJournal.AddEvent(const AData, ASource: String;
  const AnObjectID: Integer; const ATransaction: TIBTransaction;
  const AForce: Boolean);
begin
  if Assigned(IBLogin) and Assigned(GlobalStorage)
    and (IBLogin.Database <> nil) and IBLogin.Database.Connected then
  begin
    if AForce or (IBLogin.AllowUserAudit
      and GlobalStorage.ReadBoolean('Options', 'AllowAudit', False, False)) then
    begin
      gdcBaseManager.ExecSingleQuery(
        'INSERT INTO gd_journal (source, objectid, data, contactkey) ' +
          ' VALUES (:S, :OID, :D, :CK) ',
        VarArrayOf([System.Copy(ASource, 1, 40), AnObjectID, AData, IBLogin.ContactKey]),
        ATransaction);
    end;
  end;
end;

class function TgdcJournal.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByObjectID;'
end;

procedure TgdcJournal.GetWhereClauseConditions(S: TStrings);
begin
  inherited;

  if HasSubSet('ByObjectID') then
    S.Add('z.objectid = :ObjectID');
end;

initialization
  RegisterGDCClass(TgdcJournal);

finalization
  UnRegisterGDCClass(TgdcJournal);
end.
