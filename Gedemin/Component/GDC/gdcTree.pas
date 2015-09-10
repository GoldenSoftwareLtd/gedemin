
unit gdcTree;

interface

uses
  Classes,    Controls,         DB,           IB,       IBHeader,
  IBDatabase, IBCustomDataSet,  IBSQL,        SysUtils, DBGrids,
  Forms,      gdcBaseInterface, gd_createable_form,
  menus,      at_sql_setup,     gd_ClassList, gdcBase,  gd_KeyAssoc,
  Contnrs;

type
  TgdcTree = class;
  CgdcTree = class of TgdcTree;

  TgdcTreeInsertMode = (timTheSameLevel, timChildren);

  // при добавлении новой записи поле Родитель инициализируется
  // значением родителя текущей записи. т.е. добавление происходит
  // на том же уровне, что и текущая запись
  // если надо добавить запись-потомок для текущей записи, то
  // необходимо воспользоваться методами InsertChildren,
  // CreateChildrenDialog
  TgdcTree = class(TgdcBase)
  private
    FForceChildren: Boolean;
    FCurrentParent: Integer;
    FParent: TID;

    procedure _InitChild(AnObj: TgdcBase);

  protected
    procedure SetParent(const Value: TID); virtual;
    function GetParent: TID; virtual;

    procedure DoBeforeInsert; override;
    procedure DoBeforePost; override;
    procedure DoAfterPost; override;
    procedure _DoOnNewRecord; override;

    function GetFromClause(const ARefresh: Boolean = False): String; override;
    procedure GetWhereClauseConditions(S: TStrings); override;

    //
    function GetTreeInsertMode: TgdcTreeInsertMode; virtual;

    //
    function AcceptClipboard(CD: PgdcClipboardData): Boolean; override;

  public
    constructor Create(AnOwner: TComponent); override;

    procedure Assign(Source: TPersistent); override;

    procedure InsertChildren;

    function CreateChildrenDialog: Boolean; overload;
    function CreateChildrenDialog(C: CgdcBase): Boolean; overload;
    function CreateChildrenDialog(C: TgdcFullClass): Boolean; overload; 

    // функция создает и возвращает объект, на который ссылается
    // поле пэрэнт, т.е. родительский объект
    function GetParentObject: TgdcTree;

    procedure Post; override;

    // указывается список полей. для всех записей
    // которые являются детьми по отношению к текущей записи
    // и для всех их детей и т.д. значения указанных полей
    // устанавливаются как у родительской записи.
    // поля разделяются точкой с запятой.
    procedure Propagate(const AFields: String; const AnOnlyFirstLevel: Boolean = False);

    procedure GetProperties(ASL: TStrings); override;

    //
    function GetPath(const AnIncludeSelf: Boolean = True): String; virtual;

    //
    class function GetParentField(const ASubType: TgdcSubType): String; virtual;

    //
    class function GetSubSetList: String; override;

    //
    class function IsAbstractClass: Boolean; override;

    //
    class function GetTableInfos(const ASubType: String): TgdcTableInfos; override;

    // данные могут быть организованы в дерево двумя способами
    // первый, когда дерево хранится в одной таблице, а листья в
    // другой. Пример: msg_box -- msg_message
    // второй, когда дерево и листья хранятся в одной таблице
    // Пример: gd_contact
    // Данный метод дает нам ответ, содержит таблица листья
    // или нет.
    class function HasLeafs: Boolean; virtual;

    property Parent: TID read GetParent write SetParent;
  end;

  TgdcLBRBTree = class(TgdcTree)
  private
    function GetLB: Integer;
    function GetRB: Integer;
    procedure SetLB(const Value: Integer);
    procedure SetRB(const Value: Integer);
    
  protected
    procedure _DoOnNewRecord; override;
    procedure CreateFields; override;
    function GetNotCopyField: String; override;

    function GetFromClause(const ARefresh: Boolean = False): String; override;
    procedure GetWhereClauseConditions(S: TStrings); override;

    procedure DoBeforePost; override;

  public
    procedure GetProperties(ASL: TStrings); override;
    
    //
    class function GetSubSetList: String; override;

    //
    class function GetTableInfos(const ASubType: String): TgdcTableInfos; override;

    //
    class function IsAbstractClass: Boolean; override;

    property LB: Integer read GetLB write SetLB;
    property RB: Integer read GetRB write SetRB;
  end;

var
  UpdateChildren_Global: Boolean;
  UpdateChildren_UseMask: Boolean;
  UpdateChildren_AFull_And: Integer;
  UpdateChildren_AFull_Or: Integer;
  UpdateChildren_AChag_And: Integer;
  UpdateChildren_AChag_Or: Integer;
  UpdateChildren_AView_And: Integer;
  UpdateChildren_AView_Or: Integer;

implementation

uses
  Windows,    IBTable, DBClient,        gd_security,
  at_classes, IBQuery, dmDatabase_unit, gd_common_functions;

{ TgdcTree }

procedure TgdcTree.Assign(Source: TPersistent);
begin
  inherited;
  Parent := (Source as TgdcTree).Parent;
end;

constructor TgdcTree.Create(AnOwner: TComponent);
begin
  inherited;
  FForceChildren := False;
  FParent := -1;
end;

procedure TgdcTree.DoBeforeInsert;
{var
  Ref: TgdcTree;}
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCTREE', 'DOBEFOREINSERT', KEYDOBEFOREINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCTREE', KEYDOBEFOREINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCTREE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCTREE',
  {M}          'DOBEFOREINSERT', KEYDOBEFOREINSERT, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCTREE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited DoBeforeInsert;

  { TODO : этот код надо проверить, что если мастер датасет пуст? или добавляется первая запись? }
  if GetTreeInsertMode = timTheSameLevel then
  begin
    if ((Parent = -1) or (RecordCount = 0)) and Active and (FgdcDataLink.DataSet is TgdcTree) then
      FCurrentParent := (FgdcDataLink.DataSet as TgdcBase).ID
    else if RecordCount > 0 then
      FCurrentParent := Parent
    else
      FCurrentParent := -1;
  end else
    FCurrentParent := ID;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCTREE', 'DOBEFOREINSERT', KEYDOBEFOREINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCTREE', 'DOBEFOREINSERT', KEYDOBEFOREINSERT);
  {M}  end;
  {END MACRO}
end;

function TgdcTree.GetParent: TID;
begin
  if Active and (not FieldByName(GetParentField(SubType)).IsNull) then
    Result := FieldByName(GetParentField(SubType)).AsInteger
  else
    Result := FParent;
end;

function TgdcTree.GetParentObject: TgdcTree;
begin
  if FieldByName(GetParentField(SubType)).IsNull then
    Result := nil
  else
  begin
    Result := CgdcTree(Self.ClassType).CreateWithID(Owner,
      Database, Transaction, Parent, SubType);
    Result.Open;
    if Result.EOF then
      raise EgdcException.CreateObj('Invalid parent reference', Self);
  end;
end;

procedure TgdcTree._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCTREE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCTREE', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCTREE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCTREE',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCTREE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if FCurrentParent > 0 then
    FieldByName(GetParentField(SubType)).AsInteger := FCurrentParent;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCTREE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCTREE', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

procedure TgdcTree.SetParent(const Value: TID);
var
  WasActive: Boolean;
begin
  Assert(Value >= -1, 'Invalid parent id');
  if State in dsEditModes then
  begin
    if Value = -1 then
      FieldByName(GetParentField(SubType)).Clear
    else
      FieldByName(GetParentField(SubType)).AsInteger := Value
  end else if HasSubSet('ByParent') then
  begin
    WasActive := Active;
    Close;
    ParamByName(GetParentField(SubType)).AsInteger := Value;
    Active := WasActive;
  end;
  FParent := Value;
end;

function TgdcTree.CreateChildrenDialog: Boolean;
begin
  Result := CreateChildrenDialog(MakeFullClass(CgdcBase(Self.ClassType), Self.SubType));
end;

function TgdcTree.CreateChildrenDialog(C: CgdcBase): Boolean;
begin
  Result := CreateChildrenDialog(MakeFullClass(C, ''));
end;

function TgdcTree.CreateChildrenDialog(C: TgdcFullClass): Boolean;
begin
  FForceChildren := True;
  try
    Result := CreateDialog(C, _InitChild);
  finally
    FForceChildren := False;
  end;
end;

procedure TgdcTree.InsertChildren;
begin
  FForceChildren := True;
  try
    Insert;
  finally
    FForceChildren := False;
  end;
end;

procedure TgdcTree.Propagate(const AFields: String; const AnOnlyFirstLevel: Boolean = False);
var
  L: TList;
  A: Variant;
  I: Integer;
  q: TIBSQL;
  S: String;
  Obj: TgdcTree;
  DidActivate: Boolean;
begin
  L := TList.Create;
  try
    GetFieldList(L, AFields);
    if L.Count = 0 then exit;
    A := VarArrayCreate([0, L.Count - 1], varVariant);
    for I := 0 to L.Count - 1 do
      if TField(L[I]) is TBlobField then
        raise EgdcException.CreateObj('BLOBs are not supported', Self)
      else if AnsiCompareText(TField(L[I]).FieldName, GetKeyField(SubType)) = 0 then
        raise EgdcException.CreateObj('key field specified', Self)
      else
        A[I] := TField(L[I]).AsVariant;
    S := 'UPDATE ' + GetListTable(SubType) + ' SET ';
    for I := 0 to L.Count - 1 do
      S := S + TField(L[I]).FieldName + '=:' + TField(L[I]).FieldName + ',';
    SetLength(S, Length(S) - 1);
    S := S + ' WHERE ' + GetParentField(SubType)  + '=:' + GetKeyField(SubType);
    DidActivate := False;
    q := TIBSQL.Create(nil);
    try
      q.Database := Database;
      q.Transaction := Transaction;
      DidActivate := ActivateTransaction;
      q.SQL.Text := S;
      q.Prepare;
      for I := 0 to L.Count - 1 do
        q.ParamByName(TField(L[I]).FieldName).AsVariant := A[I];
      q.ExecQuery;
    finally
      q.Free;

      if DidActivate then
        Transaction.Commit;
    end;
    if not AnOnlyFirstLevel then
    begin
      Obj := TgdcTree(Self.ClassType).CreateWithParams(Self.Owner,
        Database, Transaction, SubType);
      try
        Obj.SubSet := 'ByParent';
        Obj.ParamByName(GetParentField(SubType)).AsInteger := Self.ID;
        Obj.Open;
        while not Obj.EOF do
        begin
          Obj.Propagate(AFields);
          Obj.Next;
        end;
      finally
        Obj.Free;
      end;
    end;
  finally
    L.Free;
  end;
end;

class function TgdcTree.GetParentField(const ASubType: TgdcSubType): String;
begin
  Result := 'parent';
end;

class function TgdcTree.GetSubSetList: String;
begin
  Result := inherited GetSubSetList +
    'ByParent;TopLevel;ByRootID;ByRootIDInc;'
end;

class function TgdcTree.GetTableInfos(
  const ASubType: String): TgdcTableInfos;
var
  R: TatRelation;
begin
  Result := inherited GetTableInfos(ASubType);
  R := atDatabase.Relations.ByRelationName(GetListTable(ASubType));
  if (R <> nil) and (R.RelationFields <> nil) then
    if R.RelationFields.ByFieldName(Self.GetParentField(ASubType)) <> nil then
      Include(Result, tiParent);
end;

procedure TgdcTree.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('ByParent') then
  { TODO -oJulia : Пока не поддерживается нормальная обработка
  query в котором несколько одноименных  параметров, и при этом
  хотя бы один из них сравнивается с константой. При присвоении
  параметра как строки возникает ошибка. }
//    S.Add(Format('((%0:s.%1:s=:%2:s) OR ((%0:s.%1:s IS NULL) AND (-1=:%2:s))) ',
//      [GetListTableAlias, GetParentField(SubType), GetParentField(SubType)]));
    S.Add(Format('(%0:s.%1:s=:%2:s)',
      [GetListTableAlias, GetParentField(SubType), GetParentField(SubType)]));
  if HasSubSet('TopLevel') then
    S.Add(Format('(%s.%s IS NULL)',
      [GetListTableAlias, GetParentField(SubType)]));
end;

function TgdcTree.GetTreeInsertMode: TgdcTreeInsertMode;
begin
  if FForceChildren then
    Result := timChildren
  else
    Result := timTheSameLevel;
end;

class function TgdcTree.HasLeafs: Boolean;
begin
  Result := False;
end;

class function TgdcTree.IsAbstractClass: Boolean;
begin
  Result := Self.ClassNameIs('TgdcTree');
end;

function TgdcTree.AcceptClipboard(CD: PgdcClipboardData): Boolean;
var
  I, J: Integer;
  O: TgdcTree;
  C: TgdcFullClass;
  CurrID: TID;
  CurrBm: String;
  F: TField;
//  q: TIBSQL;
begin
  Assert(Assigned(CD));

  Result := False;

  if CD.Obj = Self then
  begin
    CurrID := ID;
    CurrBm := Bookmark;

    for I := 0 to CD.ObjectCount - 1 do
    begin
      if not Locate(GetKeyField(SubType), CD.ObjectArr[I].ID, []) then
        continue;

      if CD.Cut then
      begin
        if CurrID <> FieldByName(GetKeyField(SubType)).AsInteger then
        begin
          Edit;
          FieldByName(GetParentField(SubType)).AsInteger := CurrID;
          try
            Post;
          except
            Cancel;
            raise;
          end;
        end;
      end else
        Copy(GetParentField(SubType) + ';' + GetListField(SubType),
          VarArrayOf([CurrID, CD.ObjectArr[I].ObjectName + ' (Копия)']),
          False, True, True);

      // пасля змену пэрэнта, альбо ўстаўцы копіі запісу
      // LB, RB могуць змяніцца
      { TODO : 
проку тут не слишком много так как
ЛБ РБ может поменяться у всех записей }
{      if Self is TgdcLBRBTree then
      begin
        q := TIBSQL.Create(nil);
        try
          if Transaction.InTransaction then
            q.Transaction := Transaction
          else
            q.Transaction := ReadTransaction;
          q.SQL.Text := Format('SELECT lb, rb FROM %s WHERE id=%d',
            [GetListTable(SubType), CurrID]);
          q.ExecQuery;
          SetValueForBookmark(CurrBm, 'LB', q.Fields[0].AsInteger);
          SetValueForBookmark(CurrBm, 'RB', q.Fields[1].AsInteger);
        finally
          q.Free;
        end;
      end;}

      Result := True;
    end;
  end else
  begin
    C.gdClass := nil;
    C.SubType := '';
    O := nil;
    try
      for I := 0 to CD.ObjectCount - 1 do
      begin
        if (C.gdClass = nil)
          or (C.gdClass.ClassName <> CD.ObjectArr[I].ClassName)
          or (C.SubType <> CD.ObjectArr[I].SubType) then
        begin
          C.gdClass := CgdcBase(GetClass(CD.ObjectArr[I].ClassName));
          C.SubType := CD.ObjectArr[I].SubType;
        end;

        if (C.gdClass <> nil)
          and ((C.gdClass.InheritsFrom(Self.ClassType) and (C.SubType = Self.SubType))
            or (C.gdClass.GetListTable(C.SubType) = Self.GetListTable(SubType))) then
        begin
          if (O = nil) or (O.ClassType <> C.gdClass) or (O.SubType <> C.SubType) then
          begin
            O.Free;
            O := TgdcTree(C.gdClass.CreateWithParams(nil,
              Self.Database,
              Self.Transaction,
              CD.ObjectArr[I].SubType,
              'ByID',
              CD.ObjectArr[I].ID));
          end else
          begin
            O.Close;
            O.ParamByName('ID').AsInteger := CD.ObjectArr[I].ID;
          end;

          CopyEventHandlers(O, Self);
          try
            O.Open;

            if not O.IsEmpty then
            begin
              if CD.Cut then
              begin
                if O.ID <> Self.ID then
                begin
                  O.Edit;
                  try
                    O.FieldByName(O.GetParentField(O.SubType)).Assign(
                      Self.FieldByName(Self.GetKeyField(Self.SubType)));
                    O.Post;
                  except
                    O.Cancel;
                    raise;
                  end;
                end;
              end else
                O.Copy(O.GetParentField(O.SubType) + ';' + O.GetListField(O.SubType),
                  VarArrayOf([Self.ID, CD.ObjectArr[I].ObjectName + ' (Копия)']));
              Result := True;

              if Result and Active and O.Active
                and (O.InheritsFrom(Self.ClassType) and (O.SubType = Self.SubType)) then
              begin
                FDataTransfer := True;
                ResetEventHandlers(Self);
                try
                  Append;
                  for J := 0 to FieldCount - 1 do
                  begin
                    F := O.FindField(Fields[J].FieldName);
                    if Assigned(F) then
                      Fields[J].Assign(F);
                  end;
                  Post;
                finally
                  FDataTransfer := False;
                end;
              end;
            end;
          finally
            CopyEventHandlers(Self, O);
          end;
        end;
      end;
    finally
      O.Free;
    end;
  end;
end;

procedure TgdcTree.DoAfterPost;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  S: String;
  qs, qu: TIBSQL;
  DidActivate: Boolean;

  procedure DoRecurs(const I: Integer);
  var
    L: TList;
    J: Integer;
  begin
    L := TList.Create;
    try
      qs.ParamByName('P').AsInteger := I;
      qs.ExecQuery;
      while not qs.EOF do
      begin
        L.Add(Pointer(qs.Fields[0].AsInteger));
        qs.Next;
      end;
      qs.Close;

      if L.Count > 0 then
      begin
        qu.ParamByName('P').AsInteger := I;
        qu.ExecQuery;
        qu.Close;
      end;

      for J := 0 to L.Count - 1 do
      begin
        DoRecurs(Integer(L[J]));
      end;
    finally
      L.Free;
    end;
  end;

begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCTREE', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCTREE', KEYDOAFTERPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCTREE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCTREE',
  {M}          'DOAFTERPOST', KEYDOAFTERPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCTREE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if FDataTransfer then
    exit;

  inherited;

  if UpdateChildren_Global then
  begin
    S := '';
    if (FindField('afull') <> nil) {and FieldChanged('afull')} then
    begin
      if UpdateChildren_AFull_And <> 0 then
        S := 'afull = BIN_AND(afull, ' + IntToStr(UpdateChildren_AFull_And) + ')'
      else if UpdateChildren_AFull_Or <> 0 then
        S := 'afull = BIN_OR(afull, ' + IntToStr(UpdateChildren_AFull_Or) + ')'
      else
        S := 'afull = ' + FieldByName('afull').AsString;
    end;
    if (FindField('achag') <> nil) {and FieldChanged('achag')} then
    begin
      if S > '' then
        S := S + ', ';
      if UpdateChildren_AChag_And <> 0 then
        S := S + 'achag = BIN_AND(achag, ' + IntToStr(UpdateChildren_AChag_And) + ')'
      else if UpdateChildren_AChag_Or <> 0 then
        S := S + 'achag = BIN_OR(achag, ' + IntToStr(UpdateChildren_AChag_Or) + ')'
      else
        S := S + 'achag = ' + FieldByName('achag').AsString;
    end;
    if (FindField('aview') <> nil) {and FieldChanged('aview')} then
    begin
      if S > '' then
        S := S + ', ';
      if UpdateChildren_AView_And <> 0 then
        S := S + 'aview = BIN_AND(aview, ' + IntToStr(UpdateChildren_AView_And) + ')'
      else if UpdateChildren_AView_Or <> 0 then
        S := S + 'aview = BIN_OR(aview, ' + IntToStr(UpdateChildren_AView_Or) + ')'
      else
        S := S + 'aview = ' + FieldByName('aview').AsString;
    end;

    if S > '' then
    begin
      qs := TIBSQL.Create(nil);
      qu := TIBSQL.Create(nil);
      try
        qs.Transaction := Transaction;
        qu.Transaction := Transaction;
        DidActivate := not Transaction.InTransaction;
        try
          if DidActivate then
            Transaction.StartTransaction;
          qu.SQL.Text := Format('UPDATE %s SET %s WHERE %s = :P',
            [GetListTable(SubType), S, GetParentField(SubType)]);
          qs.SQL.Text := Format('SELECT %s FROM %s WHERE %s = :P',
            [GetKeyField(SubType), GetListTable(SubType), GetParentField(SubType)]);
          DoRecurs(ID);
          { TODO :
тут возможен один тонкий момент. если после поста курсор переместится
на другую запись }
        finally
          if DidActivate and Transaction.InTransaction then
            Transaction.Commit;
        end;
      finally
        qs.Free;
        qu.Free;
      end;
    end;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCTREE', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCTREE', 'DOAFTERPOST', KEYDOAFTERPOST);
  {M}  end;
  {END MACRO}
end;

procedure TgdcTree.DoBeforePost;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCTREE', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCTREE', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCTREE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCTREE',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCTREE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if FDataTransfer then
    exit;

  inherited DoBeforePost;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCTREE', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCTREE', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

procedure TgdcTree.Post;
begin
  if UpdateChildren_Global then
  begin
    SetModified(True);
  end;

  inherited;
end;

function TgdcTree.GetFromClause(const ARefresh: Boolean): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Sgn: String;
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCTREE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCTREE', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCTREE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCTREE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCTREE' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited GetFromClause(ARefresh);

  if (not (Self is TgdcLBRBTree)) and (not ARefresh) then
  begin
    if HasSubSet('ByRootID') or HasSubSet('ByRootIDInc') then
    begin
      if HasSubSet('ByRootIDInc') then
        Sgn := '%0:s = :RootID'
      else
        Sgn := '%2:s = :RootID';

      Result := Result +
        Format(
          'JOIN ( ' +
          '  WITH RECURSIVE internal_tree AS ( ' +
          '    SELECT %0:s FROM %1:s WHERE ' + Sgn +
          '    UNION ALL ' +
          '    SELECT z7.%0:s FROM %1:s z7 JOIN internal_tree it7 ON it7.%0:s = z7.%2:s ' +
          '  ) ' +
          '  SELECT %0:s FROM internal_tree ' +
          ') z8 ON %3:s.%0:s = z8.%0:s ',
          [GetKeyField(SubType), GetListTable(SubType), GetParentField(SubType), GetListTableAlias]);
      FSQLSetup.Ignores.AddAliasName('z8');
    end;
  end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCTREE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCTREE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcTree.GetPath(const AnIncludeSelf: Boolean): String;
var
  q: TIBSQL;
begin
  Assert(ReadTransaction <> nil);
  Assert(ReadTransaction.InTransaction);

  q := TIBSQL.Create(nil);
  try
    q.Transaction := ReadTransaction;
    q.SQL.Text :=
      'EXECUTE BLOCK (ID INTEGER = :ID)'#13#10 +
      '  RETURNS(Path VARCHAR(8192))'#13#10 +
      'AS'#13#10 +
      '  DECLARE VARIABLE NewID INTEGER = NULL;'#13#10 +
      'BEGIN'#13#10 +
      '  Path = '''';'#13#10 +
      '  WHILE (:ID IS DISTINCT FROM NULL) DO'#13#10 +
      '  BEGIN'#13#10 +
      '    SELECT REPLACE(' + GetListField(SubType) + ', ''\'', ''/'') || ''\'' || :Path, parent'#13#10 +
      '    FROM ' + GetListTable(SubType) + #13#10 +
      '    WHERE id = :ID'#13#10 +
      '    INTO :Path, :NewID;'#13#10 +
      '    ID = :NewID;'#13#10 +
      '  END'#13#10 +
      '  IF (:Path <> '''') THEN'#13#10 +
      '    Path = SUBSTRING(:Path FROM 1 FOR CHARACTER_LENGTH(:Path) - 1);'#13#10 +
      '  SUSPEND;'#13#10 +
      'END';
    if AnIncludeSelf then
      q.ParamByName('ID').AsInteger := ID
    else
      q.ParamByName('ID').AsInteger := Parent;
    q.ExecQuery;
    if q.EOF then
      Result := ''
    else
      Result := q.Fields[0].AsString;  
  finally
    q.Free;
  end;
end;

procedure TgdcTree._InitChild(AnObj: TgdcBase);
begin
  if AnObj is TgdcTree then
  begin
    if FForceChildren then
      (AnObj as TgdcTree).FCurrentParent := Self.ID
    else
      (AnObj as TgdcTree).FCurrentParent := Self.Parent;
  end;
end;

procedure TgdcTree.GetProperties(ASL: TStrings);
begin
  inherited;
  ASL.Add(AddSpaces('Путь') + GetPath);
  if Parent = -1 then
    ASL.Add(AddSpaces('Родитель') + 'NULL')
  else
    ASL.Add(AddSpaces('Родитель') + IntToStr(Parent));
end;

{ TgdcLBRBTree }

procedure TgdcLBRBTree.CreateFields;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCLBRBTREE', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCLBRBTREE', KEYCREATEFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCLBRBTREE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCLBRBTREE',
  {M}          'CREATEFIELDS', KEYCREATEFIELDS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCLBRBTREE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  FieldByName('lb').Required := False;
  FieldByName('rb').Required := False;
  FieldByName('lb').ReadOnly := True;
  FieldByName('rb').ReadOnly := True;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCLBRBTREE', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCLBRBTREE', 'CREATEFIELDS', KEYCREATEFIELDS);
  {M}  end;
  {END MACRO}
end;

procedure TgdcLBRBTree._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCLBRBTREE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCLBRBTREE', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCLBRBTREE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCLBRBTREE',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCLBRBTREE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

{  if Assigned(MasterSource)
    and (MasterSource.DataSet is TgdcTree)
    and (not MasterSource.DataSet.IsEmpty)
    and HasSubSet('ByLBRB') then
  begin
    FieldByName(GetParentField(SubType)).AsInteger :=
      (MasterSource.DataSet as TgdcBase).ID;
  end; }

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCLBRBTREE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCLBRBTREE', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

function TgdcLBRBTree.GetLB: Integer;
begin
  if FieldByName('lb').IsNull then
    Result := -1
  else
    Result := FieldByName('lb').AsInteger;
end;

function TgdcLBRBTree.GetNotCopyField: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETNOTCOPYFIELD('TGDCLBRBTREE', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCLBRBTREE', KEYGETNOTCOPYFIELD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETNOTCOPYFIELD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCLBRBTREE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCLBRBTREE',
  {M}          'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETNOTCOPYFIELD' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCLBRBTREE' then
  {M}        begin
  {M}          Result := Inherited GetNotCopyField;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := inherited GetNotCopyField + ',lb,rb';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCLBRBTREE', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCLBRBTREE', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD);
  {M}  end;
  {END MACRO}
end;

function TgdcLBRBTree.GetRB: Integer;
begin
  if FieldByName('rb').IsNull then
    Result := -1
  else
    Result := FieldByName('rb').AsInteger;
end;

class function TgdcLBRBTree.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByLBRB;ByRootName;ByRootNameInc;';
end;

class function TgdcLBRBTree.GetTableInfos(
  const ASubType: String): TgdcTableInfos;
var
  R: TatRelation;
begin
  Result := inherited GetTableInfos(ASubType);
  R := atDatabase.Relations.ByRelationName(GetListTable(ASubType));
  if (R <> nil) and (R.RelationFields <> nil) then
    if (R.RelationFields.ByFieldName('lb') <> nil) and
      (R.RelationFields.ByFieldName('rb') <> nil) then
       Include(Result, tiLBRB);
end;

procedure TgdcLBRBTree.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('ByLBRB') then
    S.Add(Format('%s.lb > :LB AND %s.rb <= :RB ',
      [GetListTableAlias, GetListTableAlias]))
end;

class function TgdcLBRBTree.IsAbstractClass: Boolean;
begin
  Result := Self.ClassNameIs('TgdcLBRBTree');
end;

procedure TgdcLBRBTree.SetLB(const Value: Integer);
begin
  if State in dsEditModes then
    FieldByName('lb').AsInteger := Value;
end;

procedure TgdcLBRBTree.SetRB(const Value: Integer);
begin
  if State in dsEditModes then
    FieldByName('rb').AsInteger := Value;
end;

procedure TgdcLBRBTree.DoBeforePost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCLBRBTREE', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCLBRBTREE', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCLBRBTREE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCLBRBTREE',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCLBRBTREE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCLBRBTREE', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCLBRBTREE', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

function TgdcLBRBTree.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Sgn: String;
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCLBRBTREE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCLBRBTREE', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCLBRBTREE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCLBRBTREE',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCLBRBTREE' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited GetFromClause(ARefresh);

  if not ARefresh then
  begin
    if HasSubSet('ByRootID') or HasSubSet('ByRootIDInc') then
    begin
      if HasSubSet('ByRootIDInc') then
        Sgn := '='
      else
        Sgn := '';

      Result := Result +
        Format(' JOIN %0:s root_item ON %1:s.lb >%2:s root_item.lb AND %1:s.rb <= root_item.rb AND root_item.id = :RootID ',
          [GetListTable(SubType), GetListTableAlias, Sgn]);
      FSQLSetup.Ignores.AddAliasName('root_item');
    end;

    if HasSubSet('ByRootName') or HasSubSet('ByRootNameInc') then
    begin
      if HasSubSet('ByRootNameInc') then
        Sgn := '='
      else
        Sgn := '';

      Result := Result +
        Format(' JOIN %0:s root_item_n ON %1:s.lb >%3:s root_item_n.lb AND %1:s.rb <= root_item_n.rb AND root_item_n.%2:s = :RootName ',
          [GetListTable(SubType), GetListTableAlias, GetListField(SubType), Sgn]);
      FSQLSetup.Ignores.AddAliasName('root_item');
    end;
  end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCLBRBTREE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCLBRBTREE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcLBRBTree.GetProperties(ASL: TStrings);
begin
  inherited;
  ASL.Add(AddSpaces('Левая граница') + IntToStr(LB));
  ASL.Add(AddSpaces('Правая граница') + IntToStr(RB));
end;

initialization
  UpdateChildren_Global := False;
  UpdateChildren_UseMask := False;
  UpdateChildren_AFull_And := 0;
  UpdateChildren_AFull_Or := 0;
  UpdateChildren_AChag_And := 0;
  UpdateChildren_AChag_Or := 0;
  UpdateChildren_AView_And := 0;
  UpdateChildren_AView_Or := 0;

  RegisterGDCClass(TgdcTree);
  RegisterGDCClass(TgdcLBRBTree);

finalization
  UnregisterGdcClass(TgdcTree);
  UnregisterGdcClass(TgdcLBRBTree);
end.


