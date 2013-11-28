unit gdcDelphiObject;

interface

uses
  gdcBase, gdcTree, DB, Classes, gdcBaseInterface;

type
  TObjectType = (otObject, otClass);

  TgdcDelphiObject = class(TgdcLBRBTree)
  private
    FObjectType: TObjectType;
    //
    // только для объектов
    procedure InsertObject(var Id: Integer; const Parent: Variant;
      AName: string);
    procedure SetObjectType(const Value: TObjectType);

  protected
    // проверяет существование в базе макроса с таким именем
    // возвращает Истину, если есть и Ложь в противном
    // случае
    function CheckName(const AUserName: String): Boolean;
    // Заполнение полей при добавлении новой записи
    procedure _DoOnNewRecord; override;
    procedure GetWhereClauseConditions(S: TStrings); override;


  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;

    class function AddClass(const gdcClass: TgdcFullClassName): Integer;

    class function NeedModifyFromStream(const SubType: String): Boolean; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    function CheckTheSameStatement: String; override;
    function AddObject(AComponent: TComponent): Integer;

  published
    property ObjectType: TObjectType read FObjectType write SetObjectType;
  end;

procedure Register;

implementation

uses
  gd_ClassList, evt_Base, Contnrs, gd_SetDatabase, SysUtils, Windows, IBSQL,
  gdcConstants, Forms, gd_security_operationconst, evt_i_Base, gd_createable_form,
  gd_directories_const, gdc_createable_form
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcDelphiObject]);
end;

{ TgdcObject }

procedure TgdcDelphiObject.InsertObject(var Id: Integer; const Parent: Variant; AName: string);
begin
  Open;
  try
    Insert;
    FieldByName(fnObjectName).AsString := AName;
    FieldByName(fnParent).AsVariant := Parent;
    Post;
    Id := FieldByName(fnId).AsInteger;
  finally
    Close;
  end;
end;

function TgdcDelphiObject.AddObject(AComponent: TComponent): Integer;
var
  TmpCmp: TComponent;
  OL: TList;
  I: Integer;
  ObjectName: string;
  Added: Boolean;
  S: string;
  SQL: TIBSQL;
  A: Boolean;
  DidActivate, DidActivate2: Boolean;
begin
  Result := 0;
  Added := False;

  if AComponent = Application then
  begin
    Result := OBJ_APPLICATION;
    Exit;
  end;

  if (AComponent <> nil) and (AComponent.Name <> '') then
  try
    OL := TList.Create;
    try
      TmpCmp := AComponent;
      while (TmpCmp <> nil) and (TmpCmp <> Application) do
      begin
        OL.Add(TmpCmp);
        if (TmpCmp is TCustomForm) then
          Break;
        TmpCmp := TmpCmp.Owner;
      end;

      if OL.Count > 0 then
      begin
        DidActivate2 := False;
        SQL := TIBSQL.Create(nil);
        try
          SQL.Transaction := ReadTransaction;
          DidActivate2 := not ReadTransaction.InTransaction;
          if DidActivate2 then
            ReadTransaction.StartTransaction;
          A := Active;
          Close;
          try
            S := SubSet;
            SubSet := ssAll;
            if TComponent(OL[OL.Count - 1]) is TCreateableForm then
            begin
              ObjectName := TCreateableForm(OL[OL.Count - 1]).InitialName;
              SQL.SQL.Text :=
                'SELECT * FROM evt_object WHERE UPPER(objectname) = :objectname ' +
                '  AND parent IS NULL';
              SQL.Params[0].AsString := AnsiUpperCase(ObjectName);
              SQL.ExecQuery;
              if SQL.Eof then
              begin
                SQL.Close;
                SQL.SQL.Text := 'SELECT * FROM evt_object WHERE UPPER(objectname) = :objectname';
                SQL.Params[0].AsString := AnsiUpperCase(ObjectName);
                SQL.ExecQuery;
              end;
            end else
              begin
                SQL.SQL.Text := 'SELECT * FROM evt_object WHERE UPPER(objectname) = :objectname';
                ObjectName := TComponent(OL[OL.Count - 1]).Name;
                SQL.Params[0].AsString := AnsiUpperCase(ObjectName);
                SQL.ExecQuery;
              end;

            if SQL.Eof then
            begin
              InsertObject(Result, Null, ObjectName);
              Added := True;
            end else
            begin
              Result := SQL.FieldByName(fnId).AsInteger;
              if not SQL.FieldByName(fnParent).IsNull then
              begin
                //Для формы парент должен быть нул. Если это не так то
                //исправляем и выдаем предупреждение
                SQL.Close;
                SQL.Transaction := Transaction;
                try
                  DidActivate := not Transaction.InTransaction;
                  if DidActivate then
                    Transaction.StartTransaction;
                  try
                    SQL.SQL.Text := 'UPDATE evt_object SET parent = null WHERE id = :id';
                    SQL.Params[0].AsInteger := Result;
                    SQL.ExecQuery;
                    MessageBox(0,
                      'Обнаружена внутренняя ошибка в данных.'#13#10 +
                      'Для её исправления необходимо перезагрузить Гедымин.',
                      'Ошибка',
                      MB_OK or MB_ICONERROR or MB_TASKMODAL);
                    if DidActivate then
                      Transaction.Commit;
                  except
                    if Didactivate then
                      Transaction.RollBack;
                  end;
                finally
                  SQL.Transaction := ReadTransaction;
                end;
              end;
            end;

            SQL.Close;
            SQL.SQL.Text := 'SELECT * FROM evt_object WHERE parent = :parent ' +
              'and UPPER(objectname) = :objectname';
            for I := OL.Count - 2 downto 0 do
            begin
              SQL.Params[0].AsInteger := Result;
              SQL.Params[1].AsString := UpperCase(TComponent(OL[I]).Name);
              SQL.ExecQuery;
              if not SQL.Eof then
                Result := SQL.FieldByName(fnId).AsInteger
              else
              begin
                InsertObject(Result, Result, TComponent(OL[I]).Name);
                Added := True;
              end;
              SQL.Close;
            end;
          finally
            Close;
            if S <> SubSet then
              Subset := S;
            Active := A;
          end;
        finally
          SQL.Free;

          if DidActivate2 then
            ReadTransaction.Commit;
        end;
      end;
    finally
      OL.Free;
    end;

    if (Result <> 0) and Assigned(EventControl) and Added then
      EventControl.LoadBranch(Result);
  except
    on E: Exception do
    begin
      MessageBox(0,
        PChar('Ошибка создания обьекта ' + E.Message),
        'Ошибка',
        MB_OK or MB_ICONERROR or MB_TASKMODAL);
      Result := 0;
    end;
  end;
end;

function TgdcDelphiObject.CheckName(const AUserName: String): Boolean;
begin
  Result := False;
end;

procedure TgdcDelphiObject._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCDELPHIOBJECT', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCDELPHIOBJECT', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCDELPHIOBJECT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCDELPHIOBJECT',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCDELPHIOBJECT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FieldByName('parentindex').AsInteger := 0;
  FieldByName('AChag').AsInteger := -1;
  FieldByName('AFull').AsInteger := -1;
  FieldByName('AView').AsInteger := -1;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCDELPHIOBJECT', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCDELPHIOBJECT', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

class function TgdcDelphiObject.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := fnName;
end;

class function TgdcDelphiObject.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'EVT_OBJECT';
end;

procedure TgdcDelphiObject.GetWhereClauseConditions(S: TStrings);
begin
  if HasSubSet(ssByUpperName) then
    S.Add(
      '(UPPER(z.objectname) = UPPER(COALESCE(:objectname, ''''))) AND'#13#10 +
      '(UPPER(z.classname)  = UPPER(COALESCE(:classname, ''''))) AND'#13#10 +
      '(UPPER(z.subtype) = UPPER(COALESCE(:subtype, '''')))')
  else
    if HasSubSet('ByParent') then
      S.Add(' z.Parent = :Parent ')
    else
      inherited;
end;

class function TgdcDelphiObject.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + ssByUpperName + ';';
end;

function TgdcDelphiObject.CheckTheSameStatement: String;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  ParentIndex: Integer;
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCDELPHIOBJECT', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCDELPHIOBJECT', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCDELPHIOBJECT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCDELPHIOBJECT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCDELPHIOBJECT' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if State = dsInactive then
    Result :=
      'SELECT o.id FROM evt_object o ' +
      'WHERE ' +
      ' (UPPER(o.objectname) = UPPER(:objectname)) AND ' +
      ' (UPPER(o.classname) = UPPER(:classname)) AND ' +
      ' (o.parent IS NOT DISTINCT FROM :parent) AND ' +
      ' (UPPER(o.subtype) = UPPER(:subtype)) '
  else if ID < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
  begin
    if FieldByName('parent').IsNull then
      ParentIndex := 1
    else
      ParentIndex := FieldByName('parent').AsInteger;

    Result := Format('SELECT o.id FROM evt_object o ' +
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

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCDELPHIOBJECT', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCDELPHIOBJECT', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

class function TgdcDelphiObject.NeedModifyFromStream(
  const SubType: String): Boolean;
begin
  Result := True;
end;

procedure TgdcDelphiObject.SetObjectType(const Value: TObjectType);
begin
  FObjectType := Value;
end;

class function TgdcDelphiObject.AddClass(const gdcClass: TgdcFullClassName): Integer;
var
  I, K: Integer;
  ReadSQL: TIBSQL;
  TmpSubTypeList: TStrings;
  FClArray: array of TgdcFullClassName;
  TmpFullName: TgdcFullClassName;
  gdcDelphiObject: TgdcDelphiObject;

  function GetParentFullName(ChildFN: TgdcFullClassName): TgdcFullClassName;
  var
    GClass: TClass;
  begin
    Result.gdClassName := '';
    GClass := gdcClassList.GetGDCClass(ChildFN);
    if GClass = nil then
    begin
      GClass := frmClassList.GetFrmClass(ChildFN);
      if GClass = nil then
        raise Exception.Create('Передан некорректный класс.');
    end;

    GClass := GClass.ClassParent;
    if GClass.InheritsFrom(TgdcBase) then
    begin
      Result.gdClassName := CgdcBase(GClass).ClassName;
      CgdcBase(GClass).GetSubTypeList(TmpSubTypeList);
      if TmpSubTypeList.IndexOf(gdcClass.SubType) > -1 then
        Result.SubType := gdcClass.SubType
      else
        Result.SubType := '';
      Exit;
    end else
      if GClass.InheritsFrom(TgdcCreateableForm) then
      begin
        Result.gdClassName := CgdcCreateableForm(GClass).ClassName;
        CgdcCreateableForm(GClass).GetSubTypeList(TmpSubTypeList);
        if TmpSubTypeList.IndexOf(gdcClass.SubType) > -1 then
          Result.SubType := gdcClass.SubType
        else
          Result.SubType := '';
        Exit;
      end;
  end;

  function GetClassID(ClFullName: TgdcFullClassName): Integer;
  begin
    Result := -1;
    if ReadSQL.Open then
      ReadSQL.Close;
    ReadSQL.ParamByName('classname').AsString := ClFullName.gdClassName;
    ReadSQL.ParamByName('subtype').AsString := ClFullName.SubType;
    ReadSQL.ExecQuery;
    if not ReadSQL.Eof then
    begin
      Result := ReadSQL.FieldByName('id').AsInteger;
    end;
    ReadSQL.Close;
  end;

  function InsertClass(const Parent: Integer;
    InsFullName: TgdcFullClassName): Integer;
  begin
    if not gdcDelphiObject.Active then gdcDelphiObject.Open;
    gdcDelphiObject.Insert;
    try
      gdcDelphiObject.FieldByName(fnClassName).AsString := InsFullName.gdClassName;
      gdcDelphiObject.FieldByName(fnSubType).AsString := InsFullName.Subtype;
      if Parent = -1 then
        gdcDelphiObject.FieldByName(fnParent).Clear
      else
        gdcDelphiObject.FieldByName(fnParent).Value := Parent;
      gdcDelphiObject.Post;
    except
      gdcDelphiObject.Cancel;
      raise;
    end;
    Result := gdcDelphiObject.ID;
  end;

begin
  ReadSQL := TIBSQL.Create(nil);
  try
    ReadSQL.Transaction := gdcBaseManager.ReadTransaction;
    ReadSQL.SQL.Text :=
      'SELECT * FROM evt_object WHERE classname = :classname and subtype = :subtype';
    TmpSubTypeList := TStringList.Create;
    try
      Result := GetClassID(gdcClass);
      if Result > -1 then
        Exit;

      SetLength(FClArray, 1);
      FClArray[0] := gdcClass;
      I := -1;
      TmpFullName := GetParentFullName(gdcClass);
      while (I = -1) and (Length(Trim(TmpFullName.gdClassName)) > 0) do
      begin
        I := GetClassID(TmpFullName);
        if I = -1 then
        begin
          SetLength(FClArray, Length(FClArray) + 1);
          FClArray[Length(FClArray) - 1] := TmpFullName;
          TmpFullName := GetParentFullName(TmpFullName);
        end;
      end;

      gdcDelphiObject := TgdcDelphiObject.Create(nil);
      try
      for K := Length(FClArray) - 1 downto 0 do
        begin
          TmpFullName := FClArray[K];
          I := InsertClass(I, TmpFullName);
        end;
      finally
        gdcDelphiObject.Free;
      end;
      Result := GetClassID(gdcClass);

    finally
      TmpSubTypeList.Free;
    end;
  finally
    ReadSQL.Free;
  end;
end;

class function TgdcDelphiObject.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmDelphiObject'
end;

initialization
  RegisterGDCClass(TgdcDelphiObject);

finalization
  UnRegisterGDCClass(TgdcDelphiObject);
end.
