unit gdcFunction;

interface

uses
  Classes, Db, gdcBase, gd_createable_form, gdcBaseInterface, gdcCustomFunction,
  IBDatabase, gd_KeyAssoc, mtd_i_Base, mtd_Base;

type
  TgdcFunction = class(TgdcCustomFunction)
  private
    // Используются для исключения циклических ссылок при записи в поток
    // Список ключе скриптов
    FScriptIDList: TgdKeyArray;
    // Количество вложений
    F_CallCount: Integer;

  protected
    procedure _DoOnNewRecord; override;
    procedure DoBeforePost; override;

    // Формирование запроса
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    function GetOrderClause:String; override;

    procedure GetWhereClauseConditions(S: TStrings); override;

    function CheckTheSameStatement: String; override;
    function CreateDialogForm: TCreateableForm; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor  Destroy; override;

    class function GetDisplayName(const ASubType: TgdcSubType): String; override;
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    function GetUniqueName(PrefName, Name: string; modulecode: integer): string;
    function CheckFunction(const Name: string; modulecode: integer): Boolean;

    // Список полей, которые не надо сохранять в поток.
    //  Наименования полей разделены запятой,
    //  пример: 'LB,RB,CREATORKEY,EDITORKEY'
    class function GetNotStreamSavedField(const IsReplicationMode: Boolean = False): String; override;

    //Проверяет наличие ссылок на данную запись
    function RecordUsed: Integer;

    procedure AddMethodFunction(const ClassID: Integer; const MethodName: String;
      const FullClassName: TgdcFullClassName);
    procedure _SaveToStream(Stream: TStream; ObjectSet: TgdcObjectSet;
      PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
      WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True); override;

    class function NeedModifyFromStream(const SubType: String): Boolean; override;
  end;

  procedure Register;

const
  cByModuleCode = 'ByModuleCode';
  cByModule = 'ByModule';
  cByLBRBModule = 'ByLBRBModule';
  cOnlyFunction = 'OnlyFunction';

implementation

uses
  SysUtils, IBSQL, IBCustomDataSet, gdcConstants, Windows,
  gd_security_operationconst, evt_i_Base, gd_ClassList,
  gdc_dlgFunction_unit, rp_report_const, forms, gd_directories_const,
  gdcEvent, gdcDelphiObject, ContNrs, at_classes;

const
  cByID = 'ByID';

procedure Register;
begin
  RegisterComponents('gdc', [TgdcFunction]);
end;

{ TgdcFunction }

procedure TgdcFunction._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCFUNCTION', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCFUNCTION', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCFUNCTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCFUNCTION',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCFUNCTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FieldByName('afull').AsInteger := -1;
  FieldByName('achag').AsInteger := -1;
  FieldByName('aview').AsInteger := -1;
  FieldByName('inheritedrule').AsInteger := 0;
  FieldByName('publicfunction').AsInteger := 1;
  FieldByName('modulecode').AsInteger := OBJ_APPLICATION;
  
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCFUNCTION', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCFUNCTION', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;            

procedure TgdcFunction.DoBeforePost;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  LocSQL: TIBSQL;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCFUNCTION', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCFUNCTION', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCFUNCTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCFUNCTION',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCFUNCTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if not (sMultiple in BaseState) then
  begin
    if State in [dsInsert] then
    begin
      LocSQL := TIBSQL.Create(nil);
      try
        LocSQL.Database := Database;
        LocSQL.Transaction := ReadTransaction;
        LocSQL.SQL.Text := 'SELECT name, modulecode FROM GD_FUNCTION WHERE Upper(name) = '
         + 'Upper(:name) AND modulecode = :modulecode';
        LocSQL.Params[0].AsString := FieldByName('name').AsString;
        LocSQL.Params[1].AsInteger := FieldByName('modulecode').AsInteger;
        LocSQL.ExecQuery;
        if LocSQL.RecordCount <> 0 then
          raise Exception.Create('Название скрипт-функции должно быть уникальным.');

        LocSQL.Close;
      finally
        LocSQL.Free;
      end;
    end;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCFUNCTION', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCFUNCTION', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

class function TgdcFunction.GetKeyField(const ASubType: TgdcSubType): String;
begin
  Result := 'ID';
end;

class function TgdcFunction.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'NAME'
end;

class function TgdcFunction.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'GD_FUNCTION'
end;

function TgdcFunction.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCFUNCTION', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCFUNCTION', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCFUNCTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCFUNCTION',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCFUNCTION' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := 'SELECT z.*, o.name as objectname ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCFUNCTION', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCFUNCTION', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcFunction.GetSubSetList: String;
begin
  Result := inherited GetSubSetList
    + cByModuleCode + ';'
    + cByModule + ';'
    + cByLBRBModule + ';'
    + cOnlyFunction + ';';
end;

procedure TgdcFunction.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet(cByModuleCode) then
    S.Add('z.modulecode = :objectkey');
  if HasSubSet(cByModule) then
    S.Add('UPPER(z.module) = :module');
  if HasSubSet(cByLBRBModule) then
    S.Add('o.lb >= :LB AND o.rb <= :RB ');
//исключаем все методы, макросы, события
  if HasSubSet(cOnlyFunction) then
    S.Add('((UPPER(z.module) = ''' + scrUnkonownModule + ''') OR ' +
     '(UPPER(z.module) = ''' + scrGlobalObject + ''') OR ' +
     '(UPPER(z.module) = ''' + scrVBClasses + ''') OR ' +
     '(UPPER(z.module) = ''' + MainModuleName + ''') OR ' +
     '(UPPER(z.module) = ''' + ParamModuleName + ''') OR ' +
     '(UPPER(z.module) = ''' + EventModuleName + ''') OR ' +
     '(UPPER(z.module) = ''' + scrEntryModuleName + ''') OR ' +
     '(UPPER(z.module) = ''' + scrConst + '''))');
end;

{procedure TgdcFunction.SetAddFunction;
var
  LocSQL: TIBSQL;
  SL: TStrings;
  I: Integer;
  DidActivate: Boolean;
begin
  SL := TStringList.Create;
  try
    SL.Add(AnsiUpperCase(FieldByName('name').AsString));
    ReadAddFunction(ID, SL, FieldByName('script').AsString,
      FieldByName('modulecode').AsInteger, ReadTransaction);

    DidActivate := False;
    LocSQL := TIBSQL.Create(nil);
    try
      LocSQL.Database := Database;
      LocSQL.Transaction := Transaction;
      DidActivate := ActivateTransaction;
      LocSQL.SQL.Text := 'DELETE FROM rp_additionalfunction WHERE mainfunctionkey = ' +
       FieldByName('id').AsString;
      LocSQL.ExecQuery;
      LocSQL.Close;
      LocSQL.SQL.Text := 'INSERT INTO rp_additionalfunction (mainfunctionkey, addfunctionkey) ' +
       'VALUES(' + FieldByName('id').AsString + ', :id)';
      LocSQL.Prepare;
      for I := 1 to SL.Count - 1 do
      begin
        LocSQL.Close;
        LocSQL.Params[0].AsInteger := Integer(SL.Objects[I]);
        LocSQL.ExecQuery;
      end;
    finally
      if DidActivate then
        Transaction.Commit;
      LocSQL.Free;
    end;
  finally
    SL.Free;
  end;
end;
}

function TgdcFunction.GetUniqueName(PrefName, Name: string; modulecode: integer): string;
var
  I: Integer;
  q: TIBSQL;
begin
  if Name > '' then
    Name := '_' + Name;
  Result := Trim(PrefName + Name);

  q := TIBSQL.Create(nil);
  try
    q.Transaction := ReadTransaction;
    q.SQL.Text := 'SELECT id FROM gd_function WHERE UPPER(name)=:N';
    if ModuleCode <> 0 then
      q.SQL.Add(' AND modulecode=:MC');
    I := 0;
    repeat
      if I > 0 then
        Result := PrefName + '_' + IntToStr(I) +  Name;
      q.Close;
      q.ParamByName('N').AsString := AnsiUpperCase(Result);
      if ModuleCode <> 0 then
        q.ParamByName('MC').AsInteger := ModuleCode;
      q.ExecQuery;
      Inc(I);
    until q.EOF;
  finally
    q.Free;
  end;
end;

function TgdcFunction.CheckFunction(const Name: string; modulecode: integer): Boolean;
var
  DataSet: TIBSQL;
begin
  DataSet := TIBSQL.Create(nil);
  try
    DataSet.Transaction := ReadTransaction;
    DataSet.SQl.Text := 'SELECT ' + fnName + ' FROM gd_function WHERE modulecode = :ModuleCode ' +
       ' AND UPPER(' + fnName + ') = :Name';
    DataSet.ParamByName('ModuleCode').AsInteger := ModuleCode;
    DataSet.ParamByName('Name').AsString := AnsiUpperCase(Name);
    DataSet.ExecQuery;
    Result := DataSet.EOF;
  finally
    DataSet.Free;
  end;
end;

function TgdcFunction.GetOrderClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETORDERCLAUSE('TGDCFUNCTION', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCFUNCTION', KEYGETORDERCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETORDERCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCFUNCTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCFUNCTION',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCFUNCTION' then
  {M}        begin
  {M}          Result := Inherited GetOrderClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if HasSubSet(cByModuleCode) then
    Result := ' ORDER BY z.MODULE, z.Name '
  else
    Result := inherited GetOrderClause;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCFUNCTION', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCFUNCTION', 'GETORDERCLAUSE', KEYGETORDERCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcFunction.RecordUsed: Integer;
var
  sql: TIBSQL;
  Lst: TObjectList;
  FK: TatForeignKey;
  I: Integer;
begin
  Result := 0;

  sql := TIBSQL.Create(nil);
  Lst := TObjectList.Create(False);
  try
    sql.Transaction := gdcBaseManager.ReadTransaction;

    atDatabase.ForeignKeys.ConstraintsByReferencedRelation(
      GetListTable(SubType), Lst);
    for I := 0 to Lst.Count - 1 do
    begin
      FK := Lst[I] as TatForeignKey;

      if FK.IsSimpleKey then
      begin
        sql.Close;
        sql.SQL.Text := 'SELECT * FROM ' + FK.Relation.RelationName +
          ' WHERE ' + FK.ConstraintFields[0].FieldName + '=' + IntToStr(Self.ID);
        sql.ExecQuery;
        if not sql.EOF then
        begin
          Result := 1;
          break;
        end;
      end;
    end;
  finally
    Lst.Free;
    sql.Free;
  end;
end;

function TgdcFunction.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCFUNCTION', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCFUNCTION', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCFUNCTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCFUNCTION',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCFUNCTION' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgdc_dlgFunction.CreateSubType(ParentForm, SubType);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCFUNCTION', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCFUNCTION', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

class function TgdcFunction.GetViewFormClassName(const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmFunction';
end;

procedure TgdcFunction._SaveToStream(Stream: TStream; ObjectSet: TgdcObjectSet;
  PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
  WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True);
var
  SQL: TIBSQL;
  LocID: Integer;
  LocSubSet: string;
begin
  // если объект с заданным ИД уже сохранен в потоке или уже есть в списке,
  // то выходим, ничего не делая
  if ((ObjectSet <> nil) and (ObjectSet.Find(ID) <> -1)) or
    (FScriptIDList.IndexOf(ID) > -1) then
    Exit;

  // если F_CallCount = 0 первое вхождение => очищает список
  if F_CallCount = 0 then
    FScriptIDList.Clear;

  // увеличиваем счетчик
  Inc(F_CallCount);
  try
    FScriptIDList.Add(ID);

    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcBaseManager.ReadTransaction;
      SQL.SQL.Text := 'SELECT * FROM rp_additionalfunction WHERE mainfunctionkey = ' +
         FieldByName('id').AsString;
      SQL.ExecQuery;
      LocID := FieldByName('Id').AsInteger;
      LocSubSet := SubSet;
      SubSet := ssByID;
      Open;
      while not SQL.Eof do
      begin
        ID := SQL.FieldByName('addfunctionkey').AsInteger;
        _SaveToStream(Stream, ObjectSet, PropertyList, BindedList, WithDetailList, SaveDetailObjects);
        SQL.Next;
      end;
      SubSet := LocSubSet;
      Open;
      ID := LocID;
      inherited;


    finally
      SQL.Free;
    end;
  finally
    // уменьшаем счетчик
    Dec(F_CallCount);
  end;
end;

function TgdcFunction.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCFUNCTION', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCFUNCTION', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCFUNCTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCFUNCTION',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCFUNCTION' then
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
    Result := Format('SELECT %s FROM %s WHERE UPPER(name)=''%s'' AND modulecode = %d',
      [GetKeyField(SubType), GetListTable(SubType), AnsiUpperCase(FieldByName('name').AsString),
       FieldByName('modulecode').AsInteger]);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCFUNCTION', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCFUNCTION', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

class function TgdcFunction.NeedModifyFromStream(
  const SubType: String): Boolean;
begin
  Result := True;
end;

class function TgdcFunction.GetDisplayName(const ASubType: TgdcSubType): String;
begin
  Result := 'Функция';
end;

function TgdcFunction.GetFromClause(const ARefresh: Boolean): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCFUNCTION', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCFUNCTION', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCFUNCTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCFUNCTION',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCFUNCTION' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=  ' FROM gd_function z ' +
    ' LEFT JOIN evt_object o ON o.id = z.modulecode ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCFUNCTION', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCFUNCTION', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

constructor TgdcFunction.Create(AnOwner: TComponent);
begin
  inherited;
  FScriptIDList := TgdKeyArray.Create;
  F_CallCount := 0;
end;

destructor TgdcFunction.Destroy;
begin
  FScriptIDList.Free;
  inherited;
end;

procedure TgdcFunction.AddMethodFunction(const ClassID: Integer;
  const MethodName: String; const FullClassName: TgdcFullClassName);
var
  MethodItem: TMethodItem;
  tmpObject: TObject;
  I: Integer;
  ClassMethods: TgdcClassMethods;
  gdcEvent: TgdcEvent;
  tmpClass: TClass;

const
  cCMErr = 'Для класса не найден объект описания методов класса.';

begin
  ClassMethods := nil;
  I := gdcClassList.IndexOfByName(FullClassName);
  if I > -1 then
  begin
    ClassMethods := gdcClassList.gdcItems[I];
  end else
    begin
      I := frmClassList.IndexOfByName(FullClassName);
      if I > -1 then
      begin
        ClassMethods := frmClassList.gdcItems[I];
      end;
    end;
  if ClassMethods = nil then
    raise Exception.Create(cCMErr);

//  ClassMethods.gdcMethods.MethodByName;
  tmpObject := MethodControl.FindMethodClass(FullClassName);
  if tmpObject = nil then
    with TgdcDelphiObject.Create(nil) do
    try
      I := AddClass(FullClassName);
      if I > -1 then
      begin
        tmpClass := gdcClassList.GetGDCClass(FullClassName);
        if tmpClass = nil then
          tmpClass := frmClassList.GetFrmClass(FullClassName);
        if tmpClass = nil then
          raise Exception.Create('Класс ' + FullClassName.gdClassName + ' не зарегистрирован в системе.');

        tmpObject := MethodControl.AddClass(I, FullClassName, tmpClass);
        if tmpObject = nil then
          raise Exception.Create('Не найден объект для класса ' + FullClassName.gdClassName +
            '.'#13#10 + 'Попытайтесь перекрыть метод в инспекторе скрипт-объектов.');
            end;
    finally
      Free;
    end;

  MethodItem :=  TCustomMethodClass(tmpObject).MethodList.Find(MethodName);
  if MethodItem = nil then
  begin
    I := TCustomMethodClass(tmpObject).MethodList.Add(MethodName, 0, False,
      TCustomMethodClass(tmpObject));
    MethodItem :=  TCustomMethodClass(tmpObject).MethodList.Items[I];
  end;
//    raise Exception.Create('Не найден объект описания метода.');

  while ClassMethods.gdcMethods.Count = 0 do
  begin
    ClassMethods := ClassMethods.GetGdcClassMethodsParent;
    if ClassMethods = nil then
      raise Exception.Create(cCMErr);
  end;

  MethodItem.MethodData :=  @ClassMethods.gdcMethods.MethodByName(MethodName).ParamsData;

  Insert;
  FieldByName(fnLanguage).AsString    := 'VBScript';
  FieldByName(fnModuleCode).AsInteger := ClassID;
  FieldByName(fnModule).AsString      := scrMethodModuleName;
  FieldByName(fnName).AsString        := MethodItem.AutoFunctionName;
  FieldByName(fnScript).AsString      := MethodItem.ComplexParams[fplVBScript];
  FieldByName(fnComment).AsString := 'Скрипт-метод';
  Post;

  gdcEvent := TgdcEvent.Create(nil);
  try
    gdcEvent.SubSet := cByObjectKey;
    gdcEvent.ParamByName('objectkey').AsInteger := ClassID;
    gdcEvent.Open;
    gdcEvent.Insert;
    try
      gdcEvent.ParamByName('objectkey').AsInteger := ClassID;
      gdcEvent.FieldByName('eventname').AsString  :=  AnsiUpperCase(MethodName);
      gdcEvent.FieldByName('functionkey').AsInteger  := ID;
      gdcEvent.Post;
    except
      gdcEvent.Cancel;
      raise;
    end;
    MethodItem.MethodId := gdcEvent.ID;
    MethodItem.FunctionKey := ID;
  finally
    gdcEvent.Free;
  end;

end;

class function TgdcFunction.GetNotStreamSavedField(const IsReplicationMode: Boolean = False): String;
begin
  Result := inherited GetNotStreamSavedField(IsReplicationMode);
  if Result <> '' then
    Result := Result + ',TESTRESULT,EDITORSTATE,BREAKPOINTS'
  else
    Result := 'TESTRESULT,EDITORSTATE,BREAKPOINTS';
end;

initialization
  RegisterGdcClass(TgdcFunction);

finalization
  UnRegisterGdcClass(TgdcFunction);

end.
