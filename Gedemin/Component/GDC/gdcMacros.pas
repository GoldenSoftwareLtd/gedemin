unit gdcMacros;

interface

uses
  gdcBase, DB, gdcDelphiObject, Classes, gdcTree, gdcBaseInterface, gd_KeyAssoc;

type
  TgdcMacrosGroup = class(TgdcLBRBTree)
  protected
    // проверяет существование в базе макроса с таким именем
    // возвращает Истину, если есть и Ложь в противном
    // случае
    function CheckMacrosGroup(const Name: String): Boolean;
    // Формирование запроса
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    function GetOrderClause: String; override;

    procedure GetWhereClauseConditions(S: TStrings); override;

    function AcceptClipboard(CD: PgdcClipboardData): Boolean; override;

  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;

    function CheckTheSameStatement: String; override;
    procedure _SaveToStream(Stream: TStream; ObjectSet: TgdcObjectSet;
      PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
      WithDetailList: TgdKeyArray;
      const SaveDetailObjects: Boolean = True); override;

    class function NeedModifyFromStream(const SubType: String): Boolean; override;
  end;

type
  TgdcMacros = class(TgdcBase)
  private
    FLastInsertID: Integer;
    FOnlyDisplaying: Boolean;
    procedure SetOnlyDisplaying(const Value: Boolean);
  protected
    // Заполнение полей при добавлении новой записи
    procedure _DoOnNewRecord; override;

    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    procedure GetWhereClauseConditions(S: TStrings); override;
    function GetOrderClause: String; override;
    procedure CustomDelete(Buff: Pointer); override;
    procedure DoBeforePost; override;

  public
    constructor Create(AnOwner: TComponent); override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;

    function CheckTheSameStatement: String; override;

    // проверяет существование в базе макрос с таким именем
    // возвращает Истину, если есть и Ложь в противном
    // случае
    function  CheckMacros(const AName: String; MacrosGroupId: Integer): Boolean;
    // Возвращает униканое имя в базе.
    //
    function GetUniqueName(PrefName, Name: string; MacrosGroupId: Integer): string;

    property LastInsertID: Integer read FLastInsertID;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    class function NeedModifyFromStream(const SubType: String): Boolean; override;

    property OnlyDisplaying: Boolean read FOnlyDisplaying write SetOnlyDisplaying default False ;
  end;

const
  ssMacrosGroup = 'ByMacrosGroup';

procedure Register;

implementation

uses
  gd_ClassList, IBSQL, gd_SetDatabase, Sysutils, gdcConstants,
  gdcFunction, IBCustomDataSet, gdc_attr_frmMacros_unit, gd_directories_const;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcMacrosGroup]);
  RegisterComponents('gdc', [TgdcMacros]);
end;

{ TgdcMacrosGroup }

function TgdcMacrosGroup.AcceptClipboard(CD: PgdcClipboardData): Boolean;
var
  LocId: Integer;
  IsGlobal: Boolean;
  gdcFunction: TgdcFunction;
begin
  Result := True;

  if gdcObjectList.IndexOf(CD^.Obj) = -1 then
  begin
    Result := False;
    exit;
  end;

  if (CD^.ClassName = 'TgdcMacros') then
  begin
    CD^.Obj.Close;
    CD^.Obj.SubSet := ssById;
    CD^.Obj.ID := CD^.ObjectArr[0].ID;
    CD^.Obj.Open;
    LocId := FieldByName(fnId).AsInteger;
    IsGlobal := Boolean(FieldByName(fnIsGlobal).AsInteger);
    Close;
    ID := CD^.Obj.FieldByName(fnMacrosGroupKey).AsInteger;
    Open;
    if IsGlobal = Boolean(FieldByName(fnIsGlobal).AsInteger) then
    begin
      gdcFunction :=TgdcFunction.Create(nil);
      try
        if not CD^.Cut then
        begin
          gdcFunction.Transaction := Transaction;
          gdcFunction.DataBase := DataBase;
          gdcFunction.SubSet := ssById;
          gdcFunction.ParamByName(fnId).AsInteger :=
            TgdcMacros(CD^.Obj).FieldByName(fnFunctionKey).AsInteger;
          gdcFunction.Open;
          gdcFunction.Copy('id;name', VarArrayOf([GetUniqueKey(DataBase, Transaction),
            gdcFunction.GetUniqueName('copy', gdcFunction.FieldByName(fnName).AsString,
              gdcFunction.FieldByName('modulecode').AsInteger)]));

          CD^.Obj.Edit;

          CD^.Obj.Copy('id;name;functionkey', VarArrayOf([GetUniqueKey(Database, Transaction),
            TgdcMacros(CD^.Obj).GetUniqueName('копия', CD^.Obj.FieldByName(fnName).AsString,
              FieldByName(fnId).AsInteger), gdcFunction.FieldByName(fnId).AsInteger]));
          TgdcMacros(CD^.Obj).FLastInsertID := TgdcMacros(CD^.Obj).FieldByName(fnId).AsInteger;
        end;
        CD^.Obj.Edit;
        try
          CD^.Obj.FieldByName(fnMacrosGroupKey).AsInteger := LocId;

          CD^.Obj.Post;
        except
          CD^.Obj.Cancel;
          raise;
        end;
      finally
        gdcFunction.Free;
      end;
    end;
  end else if CD^.ClassName = 'TgdcMacrosGroup' then
  begin
    try
      IsGlobal := Boolean(FieldByName(fnIsGlobal).AsInteger);
      LocId := FieldByName(fnId).AsInteger;
      Close;
      SubSet := ssById;
      Id := CD^.ObjectArr[0].ID;
      Open;
      if IsGlobal = Boolean(FieldByName(fnIsGlobal).AsInteger) then
      begin
        Edit;
        FieldByName(fnParent).AsInteger := LocId;
        Post;
      end;
    except
      Result := False; //Для исключения возможности зацикливания ветвей дерева
    end;
  end else
    Result := False;
end;

function TgdcMacrosGroup.CheckMacrosGroup(const Name: String): Boolean;
var
  Flg: Boolean;
begin
  Result := False;
  Flg := not Transaction.InTransaction;
  try
    if Flg then
      Transaction.StartTransaction;
    Close;
    SubSet := ssAll;
    Open;
    Result := Locate(fnName, Name, [loCaseInsensitive]);
    if Flg then
      Transaction.Commit;
  except
  if Flg then
    Transaction.Rollback;
  end;
end;

function TgdcMacrosGroup.CheckTheSameStatement: String;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  ParentIndex: Integer;
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCMACROSGROUP', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCMACROSGROUP', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCMACROSGROUP') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCMACROSGROUP',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCMACROSGROUP' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if State = dsInactive then
    Result :=
      'SELECT mg.id ' +
      'FROM evt_macrosgroup mg ' +
      '  LEFT JOIN evt_object o ON o.macrosgroupkey = mg.id ' +
      'WHERE ' +
      '  (UPPER(o.objectname) = UPPER(:objectname)) AND ' +
      '  (UPPER(o.classname) = UPPER(:classname)) AND ' +
      '  (o.parentindex = :parentindex) AND ' +
      '  (UPPER(o.subtype) = UPPER(:subtype)) '
  else if ID < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
  begin
    if FieldByName('parent').IsNull then
      ParentIndex := 1
    else
      ParentIndex := FieldByName('parent').AsInteger;

    Result := Format('SELECT mg.id FROM evt_macrosgroup mg ' +
      ' LEFT JOIN evt_object o ON o.macrosgroupkey = mg.id ' +
      ' WHERE ' +
      ' (UPPER(o.objectname) = UPPER(''%s''))  AND ' +
      ' (UPPER(o.classname) = UPPER(''%s'')) AND ' +
      ' (o.parentindex = %d) AND ' +
      ' (UPPER(o.subtype) = UPPER(''%s''))',
      [StringReplace(FieldByName('objectname').AsString, '''', '''''', [rfReplaceAll]),
       FieldByName('classname').AsString,
       ParentIndex,
       FieldByName('subtype').AsString]);
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCMACROSGROUP', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCMACROSGROUP', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

function TgdcMacrosGroup.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCMACROSGROUP', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCMACROSGROUP', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCMACROSGROUP') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCMACROSGROUP',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCMACROSGROUP' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := inherited GetFromClause(ARefresh);

  Result := Result +
    ' LEFT JOIN evt_object o ON o.macrosgroupkey = z.id ';

  if (not ARefresh) and HasSubSet(ssTree) then
    Result := Result +
      ' JOIN evt_macrosgroup t2 ON ' +
      ' (t2.lb <= z.lb) AND (t2.rb >= z.rb) ' +
      ' ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCMACROSGROUP', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCMACROSGROUP', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcMacrosGroup.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := fnName;
end;

class function TgdcMacrosGroup.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'EVT_MACROSGROUP';
end;

function TgdcMacrosGroup.GetOrderClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETORDERCLAUSE('TGDCMACROSGROUP', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCMACROSGROUP', KEYGETORDERCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETORDERCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCMACROSGROUP') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCMACROSGROUP',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCMACROSGROUP' then
  {M}        begin
  {M}          Result := Inherited GetOrderClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if HasSubSet(ssTree) then
    Result := ' ORDER BY z.lb, z.name'
  else
    Result := inherited GetOrderClause;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCMACROSGROUP', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCMACROSGROUP', 'GETORDERCLAUSE', KEYGETORDERCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcMacrosGroup.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCMACROSGROUP', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCMACROSGROUP', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCMACROSGROUP') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCMACROSGROUP',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCMACROSGROUP' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if HasSubSet(ssTree) then
    Result := 'SELECT z.*, 0 AS haschildren, o.objectname as objectname, o.parent as objectparent, o.classname, o.subtype '
  else
    Result := 'SELECT z.*, (SELECT 1 FROM rdb$database WHERE ' +
     'EXISTS (SELECT t3.id FROM evt_macrosgroup t3 WHERE t3.parent = z.id) ' +
     'OR EXISTS (SELECT t4.id FROM evt_macroslist t4 WHERE ' +
     't4.macrosgroupkey = z.id)) AS haschildren, ' +
     'o.objectname as objectname, o.parent as objectparent, o.classname, o.subtype ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCMACROSGROUP', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCMACROSGROUP', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcMacrosGroup.GetSubSetList: String;
begin
  Result := inherited GetSubSetList {+ ssMacrosGroup + ';' + ssNULLMacrosGroup + ';' }+
    ssTree + ';';
end;

procedure TgdcMacrosGroup.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet(ssTree) then
    S.Add(' (t2.id = :id) ');
end;

class function TgdcMacrosGroup.NeedModifyFromStream(
  const SubType: String): Boolean;
begin
  Result := True;
end;

procedure TgdcMacrosGroup._SaveToStream(Stream: TStream;
  ObjectSet: TgdcObjectSet; PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
  WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True);
var
  ibsql: TIBSQL;
  DelphiObject: TgdcDelphiObject;
begin
  if Assigned(ObjectSet) and (ObjectSet.Find(ID) > -1) then
    Exit;

  inherited;

  ibsql := CreateReadIBSQL;
  try
    ibsql.SQL.Text := 'SELECT * FROM evt_object WHERE macrosgroupkey = :mgk';
    ibsql.ParamByName('mgk').AsInteger := ID;
    ibsql.ExecQuery;
    if (ibsql.RecordCount > 0) and
      ((not Assigned(BindedList)) or (BindedList.Find(ibsql.FieldByName('id').AsInteger) = -1)) then
    begin
      DelphiObject := TgdcDelphiObject.CreateSingularByID(nil,
        ibsql.FieldByName('id').AsInteger, '') as TgdcDelphiObject;
      try
        DelphiObject.Open;
        DelphiObject._SaveToStream(Stream, ObjectSet, PropertyList, BindedList, WithDetailList, SaveDetailObjects);
      finally
        DelphiObject.Free;
      end;
    end;
  finally
    ibsql.Free;
  end;

end;

{ TgdcMacros }

function TgdcMacros.CheckMacros(const AName: String; MacrosGroupId: Integer): Boolean;
var
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
  {Какой урод написал так SQL? Вы передаете строковую константу через параметр
    Format-а и не учитываете что в наименовании могут быть ковычки.
    Передалено через парамерт. И все остальное по-хорошему нужно сделать через параметры ibsql}
    SQL.Transaction := gdcBaseManager.ReadTransaction;
    if Active then
      SQL.SQL.Text := Format('SELECT * FROM evt_macroslist WHERE UPPER(NAME) = :name ' +
        ' and macrosgroupkey = %d and id <> %d', [MacrosGroupId,
          FieldByName(fnId).AsInteger])
    else
      SQL.SQL.Text := Format('SELECT * FROM evt_macroslist WHERE UPPER(NAME) = :name ' +
        ' and macrosgroupkey = %d', [MacrosGroupId]);

    SQL.ParamByName('name').AsString := AnsiUpperCase(AName);    
    SQL.ExecQuery;
    Result := not SQl.Eof;
  finally
    SQL.Free;
  end;
end;

procedure TgdcMacros._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCMACROS', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCMACROS', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCMACROS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCMACROS',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCMACROS' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  FieldByName(fnIsLocalExecute).AsInteger := 0;
  FieldByName(fnIsRebuild).AsInteger := 0;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCMACROS', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCMACROS', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

function TgdcMacros.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCMACROS', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCMACROS', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCMACROS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCMACROS',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCMACROS' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if (not ARefresh) and HasSubSet(ssWithSubGroup) then
    Result :=
      ' FROM EVT_MACROSGROUP MG1 JOIN EVT_MACROSGROUP MG2 ON MG1.LB  <= MG2.LB ' +
      ' AND MG1.RB  >=  MG2.RB JOIN EVT_MACROSLIST Z ON z.macrosgroupkey = mg2.id ' +
      ' LEFT JOIN EVT_MACROSGROUP OMG1 ON ' +
      ' Z.MACROSGROUPKEY  =  OMG1.ID LEFT JOIN EVT_MACROSGROUP OMG2 ON OMG1.LB ' +
      ' >= OMG2.LB AND OMG1.RB  <=  OMG2.RB AND OMG2.PARENT IS NULL LEFT JOIN ' +
      ' EVT_OBJECT O ON O.MACROSGROUPKEY  =  OMG2.ID '
  else
    Result := inherited GetFromClause(ARefresh) +
      ' LEFT JOIN EVT_MACROSGROUP OMG1 ON Z.MACROSGROUPKEY  =  ' +
      ' OMG1.ID LEFT JOIN EVT_MACROSGROUP OMG2 ON OMG1.LB  >= OMG2.LB AND ' +
      ' OMG1.RB  <=  OMG2.RB AND OMG2.PARENT IS NULL LEFT JOIN EVT_OBJECT O ON' +
      ' O.MACROSGROUPKEY = OMG2.ID ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCMACROS', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCMACROS', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcMacros.GetKeyField(const ASubType: TgdcSubType): String;
begin
  Result := fnId;
end;

class function TgdcMacros.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := fnName;
end;

class function TgdcMacros.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'EVT_MACROSLIST';
end;

function TgdcMacros.GetOrderClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETORDERCLAUSE('TGDCMACROS', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCMACROS', KEYGETORDERCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETORDERCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCMACROS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCMACROS',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCMACROS' then
  {M}        begin
  {M}          Result := Inherited GetOrderClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if HasSubSet(ssWithSubGroup) then
    Result := ' ORDER BY mg2.lb, z.name '
  else
    Result := '';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCMACROS', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCMACROS', 'GETORDERCLAUSE', KEYGETORDERCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcMacros.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + ';' + ssWithSubGroup + ';' +
    ssMacrosGroup + ';';
end;

function TgdcMacros.GetUniqueName(PrefName, Name: string; MacrosGroupId: Integer): string;
var
  I: Integer;
  SQL: TIBSQL;
begin
  Result := Trim(PrefName + ' ' + Name);
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcBaseManager.ReadTransaction;
    if Active then
      SQL.SQL.Text := Format('SELECT * FROM evt_macroslist WHERE Upper(Name) = :name '+
        ' and macrosgroupkey = %d and id <> %d', [MacrosGroupId, FieldByName(fnId).AsInteger])
    else
      SQL.SQL.Text := Format('SELECT * FROM evt_macroslist WHERE Upper(Name) = :name '+
        ' and macrosgroupkey = %d', [MacrosGroupId]);

    SQL.Prepare;
    I := 1;
    SQL.Params[0].AsString := AnsiUpperCase(Result);
    SQL.ExecQuery;
    while not SQL.Eof do
    begin
      SQL.Close;
      Result := PrefName + ' (' + IntToStr(I) + ') ' + Name;
      SQL.Params[0].AsString := AnsiUpperCase(Result);
      SQL.ExecQuery;
      Inc(I);
    end;
  finally
    SQL.Free;
  end;
end;

procedure TgdcMacros.GetWhereClauseConditions(S: TStrings);
begin
  if HasSubSet(ssMacrosGroup) then
    S.Add('z.macrosgroupkey = :macrosgroupkey')
  else
  if HasSubSet(ssWithSubGroup) then
  begin
    S.Add('(mg1.id = :id)');
  end;

  if OnlyDisplaying then
    S.Add(' z.displayinmenu = 1 ');

  inherited GetWhereClauseConditions(S);
end;

class function TgdcMacros.GetViewFormClassName(const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmMacros';
end;

procedure TgdcMacros.CustomDelete(Buff: Pointer);
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  SQL: TIBSQL;
  ID: String;
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCMACROS', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCMACROS', KEYCUSTOMDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCMACROS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCMACROS',
  {M}          'CUSTOMDELETE', KEYCUSTOMDELETE, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCMACROS' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := Transaction;
    //Проверка вхождения функции макроса в другие функции о директиве #include
    SQL.SQL.Text := 'SELECT * FROM rp_additionalfunction WHERE addfunctionkey = ' +
      FieldByName(fnFunctionKey).AsString;
    SQL.ExecQuery;

    if not SQL.Eof then
      raise EgdcException.Create(Format('Невозможно удалить макрос %s т.к он используется другими функциями',[FieldByName(fnName).AsString]));

    SQL.Close;
    Id := FieldByName(fnFunctionKey).AsString;
    inherited CustomDelete(Buff);
    CustomExecQuery('DELETE FROM gd_function WHERE id = ' + Id, Buff);
  finally
    SQL.Free;
  end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCMACROS', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCMACROS', 'CUSTOMDELETE', KEYCUSTOMDELETE);
  {M}  end;
  {END MACRO}
end;

class function TgdcMacros.NeedModifyFromStream(
  const SubType: String): Boolean;
begin
  Result := True;
end;

function TgdcMacros.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCMACROS', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCMACROS', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCMACROS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCMACROS',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCMACROS' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if State = dsInactive then
    Result := 'SELECT m.id FROM evt_macroslist m WHERE m.functionkey = :functionkey'
  else if ID < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    Result := 'SELECT m.id FROM evt_macroslist m WHERE m.functionkey = ' + FieldByName('functionkey').AsString;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCMACROS', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCMACROS', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}

end;

function TgdcMacros.GetSelectClause: String;
 {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
 {M}VAR
 {M}  Params, LResult: Variant;
 {M}  tmpStrings: TStackStrings;
 {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCMACROS', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCMACROS', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCMACROS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCMACROS',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCMACROS' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

   Result := inherited GetSelectClause + ', o.name as objectname '; 
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCMACROS', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCMACROS', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcMacros.DoBeforePost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCMACROS', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCMACROS', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCMACROS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCMACROS',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCMACROS' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  if sLoadFromStream in BaseState then
  begin
    if CheckMacros(FieldByName(fnName).AsString,
      FieldByName(fnMacrosGroupKey).AsInteger) then
      FieldByName(fnName).AsString := GetUniqueName('renamed',
        FieldByName(fnName).AsString,
        FieldByName(fnMacrosGroupKey).AsInteger);
  end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCMACROS', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCMACROS', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

procedure TgdcMacros.SetOnlyDisplaying(const Value: Boolean);
begin
  FOnlyDisplaying := Value;
end;

constructor TgdcMacros.Create(AnOwner: TComponent);
begin
  inherited;
  CustomProcess := [cpDelete];
end;

initialization
  RegisterGDCClass(TgdcMacrosGroup, ctStorage, 'Папка макросов');
  RegisterGDCClass(TgdcMacros, ctStorage, 'Макрос');

finalization
  UnRegisterGDCClass(TgdcMacrosGroup);
  UnRegisterGDCClass(TgdcMacros);
end.
