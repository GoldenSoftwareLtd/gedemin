// ShlTanya, 10.02.2019

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
    // ��������� ������������� � ���� ������� � ����� ������
    // ���������� ������, ���� ���� � ���� � ���������
    // ������
    function CheckName(const AUserName: String): Boolean;
    // ���������� ����� ��� ���������� ����� ������
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
      ATransaction: TIBTransaction = nil): TID;

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
  ATransaction: TIBTransaction = nil): TID;
var
  Branch: TID;

  function _Insert(const AParent: TID; const AName: String): TID;
  var
    q: TIBSQL;
    Tr: TIBTransaction;
  begin
    Assert(gdcBaseManager <> nil);

    q := TIBSQL.Create(nil);
    try
      if ATransaction = nil then
      begin
        Tr := TIBTransaction.Create(nil);
        Tr.DefaultDatabase := gdcBaseManager.Database;
        Tr.StartTransaction;
      end else
        Tr := ATransaction;

      try
        Result := gdcBaseManager.GetNextID;

        q.Transaction := Tr;
        q.SQL.Text := 'INSERT INTO evt_object(id, objectname, parent, achag, afull, aview)' +
          ' VALUES (:id, :objectname, :parent, -1, -1, -1)';
        SetTID(q.ParamByName('id'), Result);
        q.ParamByName('objectname').AsString := AName;
        if AParent > 0 then
          SetTID(q.ParamByName('parent'), AParent)
        else
          q.ParamByName('parent').Clear;
        q.ExecQuery;
        
        if ATransaction = nil then
          Tr.Commit;
      finally
        if ATransaction = nil then
          Tr.Free;
      end;
    finally
      q.Free;
    end;
  end;

  function IterateOwner(C: TComponent; var ABranch: TID): TID;
  var
    q: TIBSQL;
    Parent: TID;
    ObjectName: String;
    Tr: TIBTransaction;
  begin
    Assert(C <> nil);
    Assert(gdcBaseManager <> nil);

    if (C.Owner <> nil) and (C.Owner <> Application) and (not (C is TCustomForm)) then
      Parent := IterateOwner(C.Owner, ABranch)
    else
      Parent := -1;

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
        Result := _Insert(Parent, ObjectName);
        ABranch := Result;
      end else
      begin
        Result := GetTID(q.FieldByName('id'));

        if (C is TCreateableForm) and (not q.FieldByName(fnParent).IsNull) then
        begin
          //��� ����� ������ ������ ���� ���. ���� ��� �� ��� ��
          //���������� � ������ ��������������
          Tr := TIBTransaction.Create(nil);
          try
            Tr.DefaultDatabase := gdcBaseManager.Database;

            Tr.StartTransaction;
            q.Close;
            q.Transaction := Tr;
            q.SQL.Text := 'UPDATE evt_object SET parent = null WHERE id = :id';
            SetTID(q.Params[0], Result);
            q.ExecQuery;
            MessageBox(0,
              '���������� ���������� ������ � ������.'#13#10 +
              '��� � ����������� ���������� ������������� �������.',
              '������',
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
  if AComponent = Application then
  begin
    Result := OBJ_APPLICATION;
    exit;
  end;

  if (AComponent <> nil) and (AComponent.Name <> '') then
  begin
    Branch := 0;
    Result := IterateOwner(AComponent, Branch);

    if (Branch > 0) and (EventControl <> nil) then
      EventControl.LoadBranch(Branch);
  end else
    Result := 0;
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
  SetTID(FieldByName('parentindex'), 0);
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
  ParentIndex: TID;
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
  {M}                raise Exception.Create('��� ������ ''' + 'CHECKTHESAMESTATEMENT' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
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
      ParentIndex := GetTID(FieldByName('parent'));

    Result := Format('SELECT o.id FROM evt_object o ' +
      ' WHERE ' +
      ' (UPPER(o.objectname) = UPPER(''%s''))  AND ' +
      ' (UPPER(o.classname) = UPPER(''%s'')) AND ' +
      ' (o.parentindex = %d) AND ' +
      ' (UPPER(o.subtype) = UPPER(''%s''))',
      [StringReplace(FieldByName('objectname').AsString, '''', '''''', [rfReplaceAll]),
       FieldByName('classname').AsString,
       TID264(ParentIndex),
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
