
{

  1. Имя хранилища -- это имя его корневой папки.
  2. Сначала создается хранилище; соответственно присваивается некоторое
     имя корневой папке -- GLOBAL, USER, COMPANY.
  3. Сразу после создания хранилища, корневая папка имеет атрибут Changed=False
     и ID = -1.
  4. При загрузке хранилища из базы, имя и ID корневой папки считываются
     из таблицы. После загрузки устанавливается Changed=False.
  5. Перед записью в БД генерируется и присваивается имя корневой папки в
     соответствии с типом хранилища.
}


unit gdcStorage;

{ DONE 5 -oandreik -cStorage : При удалении пользователя, компании, десктопа, удалять хранилище }
{ DONE 5 -oandreik -cStorage : Assert на IBLogin, а используем gdcBasemanager }
{ DONE 5 -oandreik -cStorage : повторный импорт данных. распознавать ситуацию и предотвращать }
{ DONE 5 -oandreik -cStorage : Конфликт транзакций. Сделать обработку при сохранении и удалении эл хран }
{ DONE 5 -oandreik -cStorage : В форме просмотра запрещать вложенные уровни }
{ DONE 5 -oandreik -cStorage : убрать из TdlgToSetting.Setup код, который работает с хран по старому}
{ DONE 5 -oandreik -cStorage : массив InSett сейчас заполняется неправильно}
{ DONE 5 -oandreik -cStorage : BLOBs like QUADs! }
{ DONE 5 -oandreik -cStorage : Редактироваие через БО наименование корневого элемента }
{ DONE 5 -oandreik -cStorage : Определиться с максимальной длиной имени и контролировать ее при создании элемента }
{ DONE 5 -oandreik -cStorage : CheckTheSameStatement для загрузки веток хранилища через настройку }
{ DONE 5 -oandreik -cStorage : БЛОБы и загрузка из потока }
{ DONE 5 -oandreik -cStorage : Проверку на имя элемента при загрузке из БД можно не делать }

{ TODO 5 -oandreik -cStorage : Обработка удаленных элементов }
{ TODO 5 -oandreik -cStorage : Зачем в gdcStreamSaver выставлялся флаг IsModified хранилища? }
{ TODO 5 -oandreik -cStorage : А как быть с хранилищем раб стола? }
{ TODO 5 -oandreik -cStorage : Оптимизация доступа к полям TIBSQL через индексы, а не по имени }
{ TODO 5 -oandreik -cStorage : Может присвоение ИД внутрь объекта внести? property ID read only? }
{ TODO 5 -oandreik -cStorage : Смена имени или парента у блоба }
{ TODO 5 -oandreik -cStorage : Обращение к STorage для каждого элемента }
{ TODO 5 -oandreik -cStorage : Редактироваие DFM форм }
{ TODO 5 -oandreik -cStorage : Редактироваие DFM форм, если при распознавании потока получается ошибка }
{ TODO 5 -oandreik -cStorage : Работа с хранилищем раб стола }
{ TODO 5 -oandreik -cStorage : При конвертации БД сразу конвертировать все настройки с хранилищами }
{ TODO 5 -oandreik -cStorage : Надо ли наименования корневых папок хранилища брать из базы? }
{ TODO 5 -oandreik -cStorage : Стоит ли в базе запретить изменение наименования корневой папки? }
{ TODO 5 -oandreik -cStorage : Когда происходит считывание хранилища администратора? }
{ TODO 5 -oandreik -cStorage : Как вместе с настройками передаются хранилища пользователя? }
{ TODO 5 -oandreik -cStorage : Проверку делать через триггер, а не через уникальный индекс }
{ TODO 5 -oandreik -cStorage : TwrpGsStorageFolder.DropFolder переименовать }
{ TODO 5 -oandreik -cStorage : TwrpGsStorageFolder.LoadFromDatabase перенести на уровень TgsIBStorage }
{ TODO 5 -oandreik -cStorage : Надо ли конвертировать хранилище раб стола? }
{ TODO 5 -oandreik -cStorage : UpdateName для раб стола не должен обращаться к БД }
{ TODO 5 -oandreik -cStorage : Changed после создания объекта и после загрузки из потока.
  Не забыть: десктоп, конвертацию, корневую папку   }
{ TODO 5 -oandreik -cStorage : procedure TgdcUser.CopySettingsByUser(U: Integer; ibtr: TIBTransaction); }
{ TODO 5 -oandreik -cStorage : в тестирование добавить сохранение на диск и считывание с диска }
{ TODO 5 -oandreik -cStorage : копирование и распространение настроек в форме проверить }
{ TODO 5 -oandreik -cStorage : копирование настроек при создании нового пользователя проверить }
{ TODO 5 -oandreik -cStorage : Мы вылавливаем из текста исключения подстроку вида '. ID=', надеясь что там она есть }
{ TODO 5 -oandreik -cStorage : В оболочках предусмотреть ObjectKey или вернуться к XXXKey? }

interface

uses
  Classes, IBCustomDataSet, gdcBase, Forms, gd_createable_form, Controls, DB,
  gdcBaseInterface, IBDataBase, gdcTree, gsStorage;

type
  TgdcStorage = class(TgdcLBRBTree)
  protected
    procedure _DoOnNewRecord; override;
    procedure DoAfterDelete; override;
    procedure DoAfterPost; override;
    procedure DoBeforeEdit; override;

    function CheckTheSameStatement: String; override;
    function GetTreeInsertMode: TgdcTreeInsertMode; override;

  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    function GetCurrRecordClass: TgdcFullClass; override;

    function FindStorageItem(out SI: TgsStorageItem): Boolean; overload;
    function FindStorageItem(const AnID: Integer; out SI: TgsStorageItem): Boolean; overload;
    function GetPath: String;
  end;

  TgdcStorageFolder = class(TgdcStorage)
  protected
    procedure GetWhereClauseConditions(S: TStrings); override;

  public
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcStorageValue = class(TgdcStorage)
  protected
    procedure GetWhereClauseConditions(S: TStrings); override;
    function GetSelectClause: String; override;

  public
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;
  end;

  CgdcStorage = class of TgdcStorage;
  CgdcStorageFolder = class of TgdcStorageFolder;
  CgdcStorageValue = class of TgdcStorageValue;

procedure Register;
procedure ConvertStorageRecords(const ASettingKey: Integer; AnDatabase: TIBDatabase);

implementation

uses
  Windows,
  Graphics,
  SysUtils,
  IBSQL,
  at_frmSQLProcess,
  gd_directories_const,
  gdcStorage_Types,
  gdc_dlgStorageValue_unit,
  gdc_dlgStorageFolder_unit,
  gdc_frmStorage_unit,
  gd_ClassList,
  gd_security,
  Storages;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcStorage, TgdcStorageFolder, TgdcStorageValue]);
end;

procedure ConvertStorageRecords(const ASettingKey: Integer; AnDatabase: TIBDatabase);
var
  q, qPos: TIBSQL;
  Tr: TIBTransaction;
  S: String;
  P: Integer;
  XID, DBID: TID;
  F: TgsStorageFolder;
  V: TgsStorageValue;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  qPos := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := AnDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q.SQL.Text :=
      'SELECT * FROM at_setting_storage WHERE settingkey = :settingkey AND (NOT branchname LIKE ''#%'')';
    q.ParamByName('settingkey').AsInteger := ASettingKey;
    q.ExecQuery;

    qPos.Transaction := Tr;
    qPos.SQL.Text := 'INSERT INTO at_settingpos (settingkey, objectclass, ' +
      'category, objectname, dbid, xid, withdetail, needmodify, autoadded) ' +
      'VALUES (:SK, :OC, :CAT, :ON, :DBID, :XID, :WD, :NM, :AA)';

    while not q.EOF do
    begin
      S := q.FieldByName('branchname').AsString;
      P := Pos('\', S);
      if P = 0 then
        continue;

      if Pos('GLOBAL', S) = 1 then
        F := GlobalStorage.OpenFolder(System.Copy(S, P + 1, 1024), False, False)
      else
        F := UserStorage.OpenFolder(System.Copy(S, P + 1, 1024), False, False);

      if F = nil then
      begin
        if MessageBox(0,
          PChar('Ветвь хранилища "' + S + '" отсутствует в базе данных.'#13#10#13#10 +
          'Удалить ее из настройки?'),
          'Внимание',
          MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = ID_NO then
        begin
          raise Exception.Create('Can not find storage folder "' + S + '"');
        end;
      end else
        try
          if q.FieldByName('valuename').IsNull then
          begin
            qPos.ParamByName('ON').AsString := F.Name;
            qPos.ParamByName('OC').AsString := CgdcStorageFolder.ClassName;
            gdcBaseManager.GetRUIDByID(F.ID, XID, DBID);
            AddText('Конвертация в БО ветви ' + S, clBlack);
          end else
          begin
            V := F.ValueByName(q.FieldByName('valuename').AsString);

            if V = nil then
            begin
              if MessageBox(0,
                PChar('Параметр хранилища "' + S + '\' + q.FieldByName('valuename').AsString +
                '" отсутствует в базе данных.'#13#10#13#10 +
                'Удалить его из настройки?'),
                'Внимание',
                MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = ID_NO then
              begin
                raise Exception.Create('Can not find storage value "' +
                  S + '\' + q.FieldByName('valuename').AsString + '"');
              end else
              begin
                q.Next;
                continue;
              end;
            end;

            qPos.ParamByName('ON').AsString := V.Name;
            qPos.ParamByName('OC').AsString := CgdcStorageValue.ClassName;
            gdcBaseManager.GetRUIDByID(V.ID, XID, DBID);
            AddText('Конвертация в БО значения ' + S + '\' + V.Name, clBlack);
          end;

          qPos.ParamByName('SK').AsInteger := ASettingKey;
          qPos.ParamByName('WD').AsInteger := 1;
          qPos.ParamByName('NM').AsInteger := 1;
          qPos.ParamByName('AA').AsInteger := 0;
          qPos.ParamByName('XID').AsInteger := XID;
          qPos.ParamByName('DBID').AsInteger := DBID;
          qPos.ParamByName('CAT').AsString := TgdcStorage.GetListTable('');

          qPos.ExecQuery;
        finally
          F.Storage.CloseFolder(F, False);
        end;

      q.Next;
    end;

    q.Close;
    q.SQL.Text :=
      'UPDATE at_setting_storage SET branchname = ''#'' || branchname ' +
      '  WHERE settingkey = :settingkey AND (NOT branchname LIKE ''#%'')';
    q.ParamByName('settingkey').AsInteger := ASettingKey;
    q.ExecQuery;

    Tr.Commit;
  finally
    qPos.Free;
    q.Free;
    Tr.Free;
  end;
end;

{ TgdcStorage ------------------------------------------------}

class function TgdcStorage.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'NAME';
end;

class function TgdcStorage.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'GD_STORAGE_DATA';
end;

class function TgdcStorage.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmStorage';
end;

function TgdcStorage.FindStorageItem(out SI: TgsStorageItem): Boolean;
begin
  Result := FindStorageItem(ID, SI);
end;

{ TgdcStorageValue }

class function TgdcStorageValue.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgStorageValue';
end;

function TgdcStorageValue.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCSTORAGEVALUE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCSTORAGEVALUE', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCSTORAGEVALUE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCSTORAGEVALUE',
  {M}          'GETSELECTCLAUSE', KEYGETSELECTCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETSELECTCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TGDCSTORAGEVALUE(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCSTORAGEVALUE' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := inherited GetSelectClause;

  {Result := Format('SELECT %s.*, ' +
    'CASE data_type ' +
    '  WHEN ''S'' THEN str_data ' +
    '  WHEN ''I'' THEN CAST(int_data AS VARCHAR(120)) ' +
    '  WHEN ''L'' THEN IIF(int_data = 0, ''False'', ''True'') ' +
    '  WHEN ''D'' THEN CAST(datetime_data AS VARCHAR(120)) ' +
    '  WHEN ''C'' THEN CAST(curr_data AS VARCHAR(120)) ' +
    '  WHEN ''B'' THEN ''Размер данных: '' || CAST(CHAR_LENGTH(blob_data) AS VARCHAR(120)) || '' байт'' ' +
    'ELSE ' +
    '  '''' ' +
    'END', [GetListTableAlias]);}

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCSTORAGEVALUE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCSTORAGEVALUE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcStorageValue.GetSubSetList: String;
begin
  Result := StringReplace(inherited GetSubSetList, ';ByLBRB;ByRootID;ByRootName;', ';', []);
end;

procedure TgdcStorageValue.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  S.Add(Format('%s.data_type IN (''S'', ''I'', ''C'', ''D'', ''L'', ''B'')', [GetListTableAlias]));
end;

{ TgdcStorageFolder }

class function TgdcStorageFolder.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgStorageFolder';
end;

procedure TgdcStorageFolder.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  S.Add(Format('%s.data_type IN (''F'', ''G'', ''U'', ''O'', ''T'')', [GetListTableAlias]));
end;

function TgdcStorage.GetCurrRecordClass: TgdcFullClass;
begin
  Result := inherited GetCurrRecordClass;

  if (not IsEmpty) and (Length(FieldByName('data_type').AsString) = 1) then
  begin
    case FieldByName('data_type').AsString[1] of
      cStorageGlobal, cStorageUser, cStorageCompany,
      cStorageDesktop, cStorageFolder:
        Result.gdClass := TgdcStorageFolder;

      cStorageInteger, cStorageString, cStorageBoolean,
      cStorageDateTime, cStorageCurrency, cStorageBLOB:
        Result.gdClass := TgdcStorageValue;
    end;
  end;
end;

procedure TgdcStorage._DoOnNewRecord;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCSTORAGE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCSTORAGE', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCSTORAGE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCSTORAGE',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCSTORAGE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if Self.InheritsFrom(TgdcStorageValue) then
    FieldByName('data_type').AsString := cStorageInteger
  else
    FieldByName('data_type').AsString := cStorageFolder;

  inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCSTORAGE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCSTORAGE', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

function TgdcStorage.GetPath: String;
var
  SI: TgsStorageItem;
  q: TIBSQL;
begin
  if FindStorageItem(SI) then
    Result := SI.Path
  else begin
    q := TIBSQL.Create(nil);
    try
      if ReadTransaction.InTransaction then
        q.Transaction := ReadTransaction
      else
        q.Transaction := gdcBaseManager.ReadTransaction;

      q.SQL.Text :=
        'WITH RECURSIVE ' +
        '  st AS ( ' +
        '    SELECT id, CAST('''' AS varchar(8192)) AS path ' +
        '      FROM gd_storage_data WHERE parent IS NULL ' +
        '    UNION ALL ' +
        '    SELECT s.id, h.path || ''\'' || s.name ' +
        '      FROM gd_storage_data s JOIN st h ON ' +
        '        s.parent = h.id ' +
        '  ) ' +
        'SELECT ' +
        '  s.id, iif(s.path = '''', ''\'', s.path) AS path ' +
        'FROM ' +
        '  st s ' +
        'WHERE s.id = :ID ';
      q.ParamByName('id').AsInteger := ID;
      q.ExecQuery;

      if q.EOF then
        Result := ''
      else
        Result := q.FieldByName('path').AsString;

    finally
      q.Free;
    end;
  end;
end;

procedure TgdcStorage.DoBeforeEdit;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  SI: TgsStorageItem;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCSTORAGE', 'DOBEFOREEDIT', KEYDOBEFOREEDIT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCSTORAGE', KEYDOBEFOREEDIT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREEDIT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCSTORAGE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCSTORAGE',
  {M}          'DOBEFOREEDIT', KEYDOBEFOREEDIT, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCSTORAGE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if FindStorageItem(SI) and SI.Changed and (SI.Storage is TgsIBStorage) then
  begin
    (SI.Storage as TgsIBStorage).SaveToDatabase;
    Refresh;
  end;

  inherited;

  if IsEmpty or (not FieldByName('parent').IsNull) or (FieldByName('name').AsString = '') then
    FieldByName('name').ReadOnly := False
  else
    FieldByName('name').ReadOnly := True;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCSTORAGE', 'DOBEFOREEDIT', KEYDOBEFOREEDIT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCSTORAGE', 'DOBEFOREEDIT', KEYDOBEFOREEDIT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcStorage.DoAfterPost;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  SI, SIParent: TgsStorageItem;
  S: TStream;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCSTORAGE', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCSTORAGE', KEYDOAFTERPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCSTORAGE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCSTORAGE',
  {M}          'DOAFTERPOST', KEYDOAFTERPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCSTORAGE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if FDataTransfer then
    exit;

  inherited;

  {
    Могло измениться: 1) значение; 2) наименование; 3) родитель.
  }

  Assert(Length(FieldByName('data_type').AsString) = 1);

  LockStorage(True);
  try
    if not FindStorageItem(FieldByName('parent').AsInteger, SIParent) then
      SIParent := nil;

    if FindStorageItem(SI) then
    begin
      if SI.Name <> FieldByName('name').AsString then
        SI.Name := FieldByName('name').AsString;

      if (SIParent <> nil) and (SIParent <> SI.Parent) then
      begin
        (SI.Parent as TgsStorageFolder).RemoveChildren(SI);
        (SIParent as TgsStorageFolder).AddChildren(SI);
      end;

      if SI.GetTypeName <> FieldByName('data_type').AsString then
      begin
        if not (FieldByName('parent').IsNull and (SI is TgsRootFolder)) then
          raise Exception.Create('Storage item data type mismatch');
      end;

      if SI is TgsStorageValue then
        case SI.GetTypeName of
          cStorageInteger:  TgsStorageValue(SI).AsInteger   := FieldByName('int_data').AsInteger;
          cStorageBoolean:  TgsStorageValue(SI).AsBoolean   := FieldByName('int_data').AsInteger <> 0;
          cStorageCurrency: TgsStorageValue(SI).AsCurrency  := FieldByName('curr_data').AsCurrency;
          cStorageDateTime: TgsStorageValue(SI).AsDateTime  := FieldByName('datetime_data').AsDateTime;
          cStorageString:   TgsStorageValue(SI).AsString    := FieldByName('str_data').AsString;
          cStorageBLOB:     TgsStorageValue(SI).AsString    := FieldByName('blob_data').AsString;
        end;
    end else
    begin
      if SIParent is TgsStorageFolder then
      begin
        case FieldByName('data_type').AsString[1] of
          cStorageFolder:
            TgsStorageFolder.Create(SIParent, FieldByName('name').AsString, ID);
          cStorageInteger:
            TgsIntegerValue.Create(SIParent, FieldByName('name').AsString, ID).AsInteger :=
              FieldByName('int_data').AsInteger;
          cStorageBoolean:
            TgsBooleanValue.Create(SIParent, FieldByName('name').AsString, ID).AsBoolean :=
              FieldByName('int_data').AsInteger <> 0;
          cStorageCurrency:
            TgsCurrencyValue.Create(SIParent, FieldByName('name').AsString, ID).AsCurrency :=
              FieldByName('curr_data').AsCurrency;
          cStorageDateTime:
            TgsDateTimeValue.Create(SIParent, FieldByName('name').AsString, ID).AsDateTime :=
              FieldByName('datettime_data').AsDateTime;
          cStorageString:
            TgsStringValue.Create(SIParent, FieldByName('name').AsString, ID).AsString :=
              FieldByName('str_data').AsString;
          cStorageBLOB:
          begin
            S := CreateBlobStream(FieldByName('blob_data'), DB.bmRead);
            try
              TgsStreamValue.Create(SIParent, FieldByName('name').AsString, ID).LoadDataFromStream(S);
            finally
              S.Free;
            end;
          end;
        end;
      end else
        raise Exception.Create('Invalid storage item parent');
    end;
  finally
    LockStorage(False);
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCSTORAGE', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCSTORAGE', 'DOAFTERPOST', KEYDOAFTERPOST);
  {M}  end;
  {END MACRO}
end;

function TgdcStorage.FindStorageItem(const AnID: Integer;
  out SI: TgsStorageItem): Boolean;
begin
  Result :=
    GlobalStorage.FindID(AnID, SI) or
    UserStorage.FindID(AnID, SI) or
    CompanyStorage.FindID(AnID, SI) or
    ((AdminStorage <> nil) and AdminStorage.FindID(AnID, SI));
end;

procedure TgdcStorage.DoAfterDelete;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  SI: TgsStorageItem;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCSTORAGE', 'DOAFTERDELETE', KEYDOAFTERDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCSTORAGE', KEYDOAFTERDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCSTORAGE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCSTORAGE',
  {M}          'DOAFTERDELETE', KEYDOAFTERDELETE, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCSTORAGE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if FDataTransfer then
    exit;

  inherited;

  if FindStorageItem(SI) then
    SI.Drop;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCSTORAGE', 'DOAFTERDELETE', KEYDOAFTERDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCSTORAGE', 'DOAFTERDELETE', KEYDOAFTERDELETE);
  {M}  end;
  {END MACRO}
end;

function TgdcStorage.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  S: String;
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCSTORAGE', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCSTORAGE', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCSTORAGE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCSTORAGE',
  {M}          'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'CHECKTHESAMESTATEMENT' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TGDCSTORAGE(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCSTORAGE' then
  {M}        begin
  {M}          Result := '';//Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  //Стандартные записи ищем по идентификатору
  if FieldByName(GetKeyField(SubType)).AsInteger < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else begin
    if not FieldByName('parent').IsNull then
      Result := Format('SELECT id FROM gd_storage_data WHERE UPPER(name)=''%0:s'' AND parent=%1:d',
        [AnsiUpperCase(FieldByName('name').AsString), FieldByName('parent').AsInteger])
    else begin
      if FieldByName('data_type').AsString = cStorageUser then
        S := 'AND int_data=' + IntToStr(IBLogin.UserKey)
      else if FieldByName('data_type').AsString = cStorageCompany then
        S := 'AND int_data=' + IntToStr(IBLogin.CompanyKey)
      else if FieldByName('data_type').AsString = cStorageDesktop then
        S := 'AND name=''' + FieldByName('name').AsString + ''''
      else if FieldByName('data_type').AsString = cStorageGlobal then
        S := ''
      else
        raise EgdcException.Create('Invalid storage data type');
      Result := Format('SELECT id FROM gd_storage_data WHERE parent IS NULL AND data_type=''%0:s'' %1:s',
        [FieldByName('data_type').AsString, S])
    end;
  end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCSTORAGE', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCSTORAGE', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

function TgdcStorage.GetTreeInsertMode: TgdcTreeInsertMode;
begin
  Result := timChildren;
end;

initialization
  RegisterGdcClasses([TgdcStorage, TgdcStorageFolder, TgdcStorageValue]);

finalization
  UnRegisterGdcClasses([TgdcStorage, TgdcStorageFolder, TgdcStorageValue]);
end.
