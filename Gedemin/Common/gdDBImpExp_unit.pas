// ShlTanya, 24.02.2019

unit gdDBImpExp_unit;

interface

uses
  Classes, gdcBaseInterface, IBDatabase, IBSQL, DBClient, ContNrs, gd_KeyAssoc;

const
  cMaxFields = 256;

type
  TgdDBImpExp = class;

  TgdDBImpExpTable = class(TObject)
  private
    FTableName: String;
    FgdDBImpExp: TgdDBImpExp;
    q: TIBSQL;
    CDS: TClientDataSet;
    MapArray: array[0..cMaxFields - 1] of Integer;
    RefArray: array[0..cMaxFields - 1] of TgdDBImpExpTable;
    FRecurrIndex: Integer;
    One2OneList: TObjectList;
    FSetTable: Boolean;

  public
    constructor Create(const AgdDBImpExp: TgdDBImpExp; const ATableName: String);
    destructor Destroy; override;

    procedure SaveRecord(const AnID: TID);
    procedure SaveToStream(S: TStream);

    property TableName: String read FTableName;
  end;

  TgdDBImpExp = class(TObject)
  private
    FTables: TObjectList;
    FJournal: TObjectList;
    qRUID, qRUIDInsert: TIBSQL;
    FIDS: TgdKeyStringAssoc;

  public
    constructor Create;
    destructor Destroy; override;

    procedure SaveRecord(const AnID: TID; const ATableName: String);
    function CheckFieldName(const AFieldName: String): Boolean;
    function GetTable(const ATableName: String): TgdDBImpExpTable;
    procedure LogRecord(const ATable: TgdDBImpExpTable);
    procedure SaveToStream(S: TStream);
    function GetRUID(const AnID: TID): String;

    property IDS: TgdKeyStringAssoc read FIDS;
  end;

implementation

uses
  DB, SysUtils, IBHeader, at_classes, gd_security, gd_directories_const;

{ TgdDBImpExp }

function TgdDBImpExp.CheckFieldName(const AFieldName: String): Boolean;
begin
  Result := (AFieldName <> 'AFULL')
    and (AFieldName <> 'ACHAG')
    and (AFieldName <> 'AVIEW');
end;

constructor TgdDBImpExp.Create;
begin
  FTables := TObjectList.Create(True);
  FJournal := TObjectList.Create(False);
  FIDS := TgdKeyStringAssoc.Create;
end;

destructor TgdDBImpExp.Destroy;
begin
  FTables.Free;
  FJournal.Free;
  qRUID.Free;
  if qRUIDInsert <> nil then
  begin
    if qRUIDInsert.Transaction.InTransaction then
      qRUIDInsert.Transaction.Commit;
    qRUIDInsert.Free;
  end;
  FIDS.Free;
  inherited;
end;

function TgdDBImpExp.GetRUID(const AnID: TID): String;
begin
  if qRUID = nil then
  begin
    qRUID := TIBSQL.Create(nil);
    qRUID.Transaction := gdcBaseManager.ReadTransaction;
    qRUID.SQL.Text := 'SELECT * FROM gd_ruid WHERE id = :ID';
    qRUID.Prepare;
  end;

  SetTID(qRUID.ParamByName('ID'), AnID);
  qRUID.ExecQuery;
  try
    if qRUID.EOF then
    begin
      if qRUIDInsert = nil then
      begin
        qRUIDInsert := TIBSQL.Create(nil);
        qRUIDInsert.Transaction := TIBTransaction.Create(qRUIDInsert);
        qRUIDInsert.Transaction.DefaultDatabase := gdcBaseManager.Database;
        qRUIDInsert.Transaction.StartTransaction;
        qRUIDInsert.SQL.Text :=
          'INSERT INTO gd_ruid (id, xid, dbid, modified, editorkey) VALUES (:id, :xid, :dbid, :mod, :ek) ';
      end;
      SetTID(qRUIDInsert.ParamByName('id'), AnID);
      SetTID(qRUIDInsert.ParamByName('xid'), AnID);
      if AnID < cstUserIDStart then
        qRUIDInsert.ParamByName('dbid').AsInteger := cstEtalonDBID
      else
        qRUIDInsert.ParamByName('dbid').AsInteger := IBLogin.DBID;
      qRUIDInsert.ParamByName('mod').AsDateTime := Now;
      SetTID(qRUIDInsert.ParamByName('ek'), IBLogin.ContactKey);
      Result := qRUIDInsert.ParamByName('XID').AsString + '_' + qRUIDInsert.ParamByName('DBID').AsString;
      qRUIDInsert.ExecQuery;
      { TODO : надо обрабатывать ситуацию, когда такой РУИД уже есть в базе. }
    end else
    begin
      Result := qRUID.FieldByName('XID').AsString + '_' + qRUID.FieldByName('DBID').AsString
    end;
  finally
    qRUID.Close;
  end;
end;

function TgdDBImpExp.GetTable(const ATableName: String): TgdDBImpExpTable;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to FTables.Count - 1 do
  begin
    if AnsiCompareText((FTables[I] as TgdDBImpExpTable).TableName, ATableName) = 0 then
    begin
      Result := FTables[I] as TgdDBImpExpTable;
      break;
    end;
  end;

  if Result = nil then
  begin
    Result := TgdDBImpExpTable.Create(Self, ATableName);
    FTables.Add(Result);
  end;
end;

procedure TgdDBImpExp.LogRecord(const ATable: TgdDBImpExpTable);
begin
  FJournal.Add(ATable);
end;

procedure TgdDBImpExp.SaveRecord(const AnID: TID;
  const ATableName: String);
begin
  GetTable(ATableName).SaveRecord(AnID);
end;

procedure TgdDBImpExp.SaveToStream(S: TStream);
var
  I, J: Integer;
  A: array of SmallInt;
begin
  FIDS.SaveToStream(S);

  SetLength(A, FJournal.Count);

  for I := 0 to FJournal.Count - 1 do
  begin
    for J := 0 to FTables.Count - 1 do
    begin
      if FJournal[I] = FTables[J] then
      begin
        A[I] := J;
        break;
      end;
    end;
  end;

  I := FJournal.Count;
  S.WriteBuffer(I, SizeOf(I));
  S.WriteBuffer(A[0], I * SizeOf(SmallInt));

  I := FTables.Count;
  S.WriteBuffer(I, SizeOf(I));
  for I := 0 to FTables.Count - 1 do
  begin
    (FTables[I] as TgdDBImpExpTable).SaveToStream(S);
  end;
end;

{ TgdDBImpExpTable }

constructor TgdDBImpExpTable.Create(const AgdDBImpExp: TgdDBImpExp; const ATableName: String);
begin
  FTableName := ATableName;
  FgdDBImpExp := AgdDBImpExp;
end;

destructor TgdDBImpExpTable.Destroy;
begin
  q.Free;
  CDS.Free;
  One2OneList.Free;
  inherited;
end;

procedure TgdDBImpExpTable.SaveRecord(const AnID: TID);
var
  I, J: Integer;
  FieldAliasName, RelationName, FieldName: String;
  FieldSize: Integer;
  FieldType: TFieldType;
  InternalCalcField: Boolean;
  F: TField;
  RF: TatRelationField;
  R: TatRelation;
  RefID: array[0..cMaxFields - 1] of Integer;
  OL: TObjectList;
  qTemp: TIBSQL;
begin
  with FgdDBImpExp do
  begin
    if IDS.IndexOf(AnID) = -1 then
      IDS.ValuesByIndex[IDS.Add(AnID)] := GetRUID(AnID)
    else
      exit;
  end;

  if q = nil then
  begin
    R := atDatabase.Relations.ByRelationName(FTableName);

    if (R = nil) or (R.PrimaryKey = nil) then
      raise Exception.Create('Invalid table name specified');

    q := TIBSQL.Create(nil);
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text :=
      'SELECT * FROM ' + TableName +
      ' WHERE ' + R.PrimaryKey.ConstraintFields[0].FieldName + ' = :ID ';
    q.Prepare;

    FSetTable := R.PrimaryKey.ConstraintFields.Count = 1;
  end;

  if CDS = nil then
  begin
    J := 0;
    CDS := TClientDataSet.Create(nil);

    for I := 0 to q.Current.Count - 1 do
    begin
      if I = cMaxFields then
        break;

      MapArray[I] := -1;
      RefArray[I] := nil;
      with q.Current[I].Data^ do
      begin
        { Get the field name }
        SetString(FieldAliasName, aliasname, aliasname_length);
        SetString(RelationName, relname, relname_length);
        SetString(FieldName, sqlname, sqlname_length);
        FieldSize := 0;

        case sqltype and not 1 of
          { All VARCHAR's must be converted to strings before recording
           their values }
          SQL_VARYING, SQL_TEXT:
          begin
            FieldSize := sqllen;
            FieldType := ftString;
          end;
          { All Doubles/Floats should be cast to doubles }
          SQL_DOUBLE, SQL_FLOAT:
            FieldType := ftFloat;
          SQL_SHORT:
          begin
            if (sqlscale = 0) then
              FieldType := ftSmallInt
            else
            begin
              FieldType := ftBCD;
              FieldSize := -sqlscale;
            end;
          end;
          SQL_LONG:
          begin
            if (sqlscale = 0) then
              FieldType := ftInteger
            else
              if (sqlscale >= (-4)) then
              begin
                FieldType := ftBCD;
                FieldSize := -sqlscale;
              end
              else
                FieldType := ftFloat;
              end;
          SQL_INT64:
          begin
            if (sqlscale = 0) then
              FieldType := ftLargeInt
            else
              if (sqlscale >= (-4)) then
              begin
                FieldType := ftBCD;
                FieldSize := -sqlscale;
              end
              else
                FieldType := ftFloat;
              end;
          SQL_TIMESTAMP: FieldType := ftDateTime;
          SQL_TYPE_TIME: FieldType := ftTime;
          SQL_TYPE_DATE: FieldType := ftDate;
          SQL_BLOB:
          begin
            FieldSize := sizeof (TISC_QUAD);
            if (sqlsubtype = 1) then
              FieldType := ftmemo
            else
              FieldType := ftBlob;
          end;
          SQL_ARRAY:
          begin
            FieldSize := sizeof (TISC_QUAD);
            FieldType := ftUnknown;
          end;
          else
            FieldType := ftUnknown;
        end;

        if (FieldType <> ftUnknown) and (FieldAliasName <> 'IBX_INTERNAL_DBKEY')
          and FgdDBImpExp.CheckFieldName(FieldAliasName) then {do not localize}
        begin
          InternalCalcField := False;
          if (FieldName <> '') and (RelationName <> '') then
          begin
            if gdcBaseManager.Database.Has_COMPUTED_BLR(RelationName, FieldName) then
            begin
              InternalCalcField := True;
            end
          end;

          if not InternalCalcField then
          begin
            CDS.FieldDefs.Add(FieldAliasName, FieldType, FieldSize, False);
            MapArray[I] := J;

            if FieldType = ftInteger then
            begin
              RF := atDatabase.FindRelationField(RelationName, FieldName);
              if RF <> nil then
              begin
                R := RF.References;
                if R <> nil then
                begin
                  RefArray[I] := FgdDBImpExp.GetTable(R.RelationName);
                end;
              end;
            end;

            Inc(J);
          end;
        end;
      end;
    end;

    CDS.CreateDataSet;

    OL := TObjectList.Create(False);
    try
      atDatabase.ForeignKeys.ConstraintsByReferencedRelation(FTableName, OL);
      for I := 0 to OL.Count - 1 do
        with OL[I] as TatForeignKey do
      begin
        if IsSimpleKey
          and (Relation.PrimaryKey <> nil)
          //and (Relation.PrimaryKey.ConstraintFields.Count = 1)
          and (ConstraintField = Relation.PrimaryKey.ConstraintFields[0]) then
        begin
          if One2OneList = nil then
            One2OneList := TObjectList.Create(False);
          One2OneList.Add(FgdDBImpExp.GetTable(Relation.RelationName));
        end;
      end;
    finally
      OL.Free;
    end;
  end;

  if q.Open then
  begin
    qTemp := q;
    q := TIBSQL.Create(nil);
    q.Transaction := qTemp.Transaction;
    q.SQL.Assign(qTemp.SQL);
  end else
    qTemp := nil;

  SetTID(q.ParamByName('ID'), AnID);
  q.ExecQuery;
  try
    while not q.EOF do // несколько записей у нас будет только для элементов множества!
    begin
      if FRecurrIndex = 0 then
        CDS.Append
      else
        CDS.Insert;
      try
        J := q.Current.Count - 1;
        for I := 0 to J do
        begin
          if MapArray[I] <> -1 then
          begin
            F := CDS.Fields[MapArray[I]];
            if q.Fields[I].IsNull then
              F.Clear
            else begin
              case F.DataType of
                ftSmallInt, ftInteger: F.AsInteger := q.Fields[I].AsInteger;
                ftBCD, ftCurrency: F.AsCurrency := q.Fields[I].AsCurrency;
                ftDateTime, ftDate, ftTime: F.AsDateTime := q.Fields[I].AsDateTime;
                ftFloat: F.AsFloat := q.Fields[I].AsFloat;
              else
                F.AsString := q.Fields[I].AsString;
              end;
            end;
            if RefArray[I] <> nil then
            begin
             RefID[I] := GetTID(F);
            end;
          end;
        end;
        CDS.Post;
      except
        if CDS.State = dsInsert then
          CDS.Cancel;
        raise;
      end;

      if not FSetTable then
        q.Close;

      Inc(FRecurrIndex);
      try
        for I := 0 to J do    // может начинать с 1?
        begin
          if (RefArray[I] <> nil) and (RefID[I] > 0) then
          begin
            RefArray[I].SaveRecord(RefID[I]);
          end;
        end;
      finally
        Dec(FRecurrIndex);
      end;

      FgdDBImpExp.LogRecord(Self);

      if Assigned(One2OneList) then
      begin
        for I := 0 to One2OneList.Count - 1 do
        begin
          (One2OneList[I] as TgdDBImpExpTable).SaveRecord(AnID);
        end;
      end;

      if FSetTable then
        q.Next
      else
        break;
    end;
  finally
    if qTemp <> nil then
    begin
      q.Free;
      q := qTemp;
    end else
      q.Close;
  end;
end;

procedure TgdDBImpExpTable.SaveToStream(S: TStream);
begin
  if Assigned(CDS) then
  begin
    CDS.SaveToStream(S);
  end;
end;

end.
