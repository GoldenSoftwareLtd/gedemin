unit gdcDelphiObject;

interface

uses
  gdcBase, gdcTree, DB, Classes, gdcBaseInterface, IBDatabase;

type
  TObjectType = (otObject, otClass);

  TgdcDelphiObject = class(TgdcLBRBTree)
  private
    FObjectType: TObjectType;

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

    class function NeedModifyFromStream(const SubType: String): Boolean; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    function CheckTheSameStatement: String; override;

    class function AddObject(AComponent: TComponent;
      ATransaction: TIBTransaction = nil): Integer;

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

class function TgdcDelphiObject.AddObject(AComponent: TComponent;
  ATransaction: TIBTransaction = nil): Integer;
var
  Branch: Integer;

  function Insert(const AParent: Variant; AName: string): Integer;
  var
    q: TIBSQL;
    Tr: TIBTransaction;
    CreateTransaction: Boolean;
  begin
    Assert(gdcBaseManager <> nil);

    q := TIBSQL.Create(nil);
    try
      CreateTransaction := ATransaction = nil;

      if CreateTransaction then
        Tr := TIBTransaction.Create(nil)
      else
        Tr := ATransaction;

      try
        if CreateTransaction then
        begin
          Tr.DefaultDatabase := gdcBaseManager.Database;
          Tr.StartTransaction;
        end;

        Result := gdcBaseManager.GetNextID;

        q.Transaction := Tr;

        q.SQL.Text := 'INSERT INTO evt_object(id, objectname, parent, achag, afull, aview)' +
          ' VALUES (:id, :objectname, :parent, :achag, :afull, :aview)';
        q.ParamByName('id').AsInteger := Result;
        q.ParamByName('objectname').AsString := AName;
        q.ParamByName('parent').AsVariant := AParent;
        q.ParamByName('AChag').AsInteger := -1;
        q.ParamByName('AFull').AsInteger := -1;
        q.ParamByName('AView').AsInteger := -1;
        q.ExecQuery;
        
        if CreateTransaction then
          Tr.Commit;
      finally
        if CreateTransaction then
          Tr.Free;
      end;
    finally
      q.Free;
    end;
  end;

  function IterateOwner(C: TComponent; var ABranch: Integer): Integer;
  var
    q: TIBSQL;
    Parent: Variant;
    ObjectName: String;
    Tr: TIBTransaction;
  begin
    Assert(C <> nil);
    Assert(gdcBaseManager <> nil);

    if (C.Owner <> nil) and (C.Owner <> Application) and (not (C is TCustomForm))then
      Parent := IterateOwner(C.Owner, ABranch)
    else
      Parent := Null;

    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcBaseManager.ReadTransaction;
      if C is TCreateableForm then
      begin
        ObjectName := TCreateableForm(C).InitialName;
        q.SQL.Text :=
          'SELECT * FROM evt_object WHERE UPPER(objectname) = :objectname ' +
          '  AND parent IS NULL';
        q.Params[0].AsString := AnsiUpperCase(ObjectName);
        q.ExecQuery;
        if q.Eof then
        begin
          q.Close;
          q.SQL.Text := 'SELECT * FROM evt_object WHERE UPPER(objectname) = :objectname';
          q.Params[0].AsString := AnsiUpperCase(ObjectName);
          q.ExecQuery;
        end;
      end
      else
      begin
        q.SQL.Text := 'SELECT * FROM evt_object WHERE UPPER(objectname) = :objectname';
        ObjectName := TComponent(C).Name;
        q.Params[0].AsString := AnsiUpperCase(ObjectName);
        q.ExecQuery;
      end;

      if q.Eof then
      begin
        Result := Insert(Parent, ObjectName);
        ABranch := Result;
      end
      else
      begin
        Result := q.FieldByName('id').AsInteger;

        if (C is TCreateableForm) and (not q.FieldByName(fnParent).IsNull) then
        begin
          //Для формы парент должен быть нул. Если это не так то
          //исправляем и выдаем предупреждение
          Tr := TIBTransaction.Create(nil);
          try
            Tr.DefaultDatabase := gdcBaseManager.Database;

            Tr.StartTransaction;
            q.Transaction := Tr;
            q.Close;
            q.SQL.Text := 'UPDATE evt_object SET parent = null WHERE id = :id';
            q.Params[0].AsInteger := Result;
            q.ExecQuery;
            MessageBox(0,
              'Обнаружена внутренняя ошибка в данных.'#13#10 +
              'Для её исправления необходимо перезагрузить Гедымин.',
              'Ошибка',
              MB_OK or MB_ICONERROR or MB_TASKMODAL);
            Tr.Commit;
          finally
            Tr.Free;
          end;
        end;
      end;

    finally
      q.Free;
    end;
  end;

begin
  Result := 0;

  if AComponent = Application then
  begin
    Result := OBJ_APPLICATION;
    Exit;
  end;

  if (AComponent <> nil) and (AComponent.Name <> '') then
  begin
    Branch := 0;
    Result := IterateOwner(AComponent, Branch);

    if (Branch > 0) and (EventControl <> nil) then
      EventControl.LoadBranch(Branch);
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

class function TgdcDelphiObject.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmDelphiObject';
end;

initialization
  RegisterGDCClass(TgdcDelphiObject);

finalization
  UnregisterGdcClass(TgdcDelphiObject);
end.
