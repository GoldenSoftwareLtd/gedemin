unit ibr_ReplicationServer_unit;

interface
uses ibr_BaseTypes_unit, Classes, ibr_ResourceString_unit, SysUtils, IBSQL, DB,
  ibr_const, Contnrs, ibr_GlobalVars_unit, IBStoredProc, Controls, Dialogs;

type
  TrpForeignKeys = class;

  //Список отключаемых внешних ссылок
  TrpForeignKey = class
  private
    FDropped: Boolean;
    FConstraintName: string;
    FTableName: string;
    FDeleteRule: string;
    FOnFieldName: string;
    FFieldName: string;
    FOnTableName: string;
    FUpdateRule: string;
    procedure SetConstraintName(const Value: string);
    procedure SetDeleteRule(const Value: string);
    procedure SetDropped(const Value: Boolean);
    procedure SetFieldName(const Value: string);
    procedure SetOnFieldName(const Value: string);
    procedure SetOnTableName(const Value: string);
    procedure SetTableName(const Value: string);
    procedure SetUpdateRule(const Value: string);
  public
    //Функции возвращают слк для добавления и удаления внешнего ключа
    function AddDLL: string;
    function DropDLL: string;
    //Чтение из переданного ИБСКЛ
    procedure Read(SQL: TIBSQL);
    //Функции чтения и записи в поток
    procedure SaveToStream(Stream: TStream);
    procedure ReadFromStream(Stream: TStream);

    property TableName: string read FTableName write SetTableName;
    property ConstraintName: string read FConstraintName write SetConstraintName;
    property FieldName: string read FFieldName write SetFieldName;
    property OnTableName: string read FOnTableName write SetOnTableName;
    property OnFieldName: string read FOnFieldName write SetOnFieldName;
    property DeleteRule: string read FDeleteRule write SetDeleteRule;
    property UpdateRule: string read FUpdateRule write SetUpdateRule;
    property Dropped: Boolean read FDropped write SetDropped;
  end;

  TrpForeignKeys = class(TObjectList)
  private
    function GetForeignKeys(Index: Integer): TrpForeignKey;
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    procedure SaveToStream(Stream: TStream);
    procedure SaveDroppedToStream(Stream: TStream);
    procedure ReadFromStream(Stream: TStream);
    function  LoadFromTextFile(AFileName: string): boolean;
    procedure ReadKeys;
    procedure DropKeys;
    procedure AddKeys;
    procedure RestoreKeys;

    property ForeignKeys[Index: Integer]: TrpForeignKey read GetForeignKeys;
  end;

implementation

uses  IB, IBErrorCodes, Forms, IBDatabase;

{ TrpForeignKey }

function TrpForeignKey.AddDLL: string;
var
  lOnUpDate, lOnDelete: string;
begin
  if FUpDateRule <> 'RESTRICT' then
    lOnUpDate := ' ON UPDATE ' + FUpdateRule
  else
    lOnUpDate := '';

  if FDeleteRule <> 'RESTRICT' then
    lOnDelete := ' ON DELETE ' + FDeleteRule
  else
    lOnDelete := '';

  Result := 'ALTER TABLE ' + FTableName + ' ADD CONSTRAINT ' +
    FConstraintName + ' FOREIGN KEY (' + FFieldName + ' )' +
    'REFERENCES ' + FOnTableName + '(' + FOnFieldName + ')' +
    lOnUpDate + lOnDelete;
end;

function TrpForeignKey.DropDLL: string;
begin
  Result := 'ALTER TABLE ' + FTableName + ' DROP CONSTRAINT ' +
    FConstraintName;
end;

procedure TrpForeignKey.Read(SQL: TIBSQL);
begin
  FTableName := UpperCase(Trim(SQL.FieldByName(fnTableName).AsString));
  FFieldName := UpperCase(Trim(SQL.FieldByName(fnFieldName).AsString));
  FConstraintName := UpperCase(Trim(SQL.FieldByName(fnConstraintName).AsString));
  FOnTableName := UpperCase(Trim(SQL.FieldByName(fnOnTableName).AsString));
  FOnFieldName := UpperCase(Trim(SQL.FieldByName(fnOnFieldName).AsString));
  FDeleteRule := Trim(SQL.FieldByName(fnOnDelete).AsString);
  FUpdateRule := Trim(SQL.FieldByName(fnOnUpdate).AsString);
  FDropped := False;
end;

procedure TrpForeignKey.ReadFromStream(Stream: TStream);
begin
  if not Assigned(Stream) then
    raise Exception.Create(MSG_STREAM_DO_NOT_INIT);

  FConstraintName := ReadStringFromStream(Stream);
  FTableName := ReadStringFromStream(Stream);
  FFieldName := ReadStringFromStream(Stream);
  FOnTableName := ReadStringFromStream(Stream);
  FOnFieldName := ReadStringFromStream(Stream);
  FDeleteRule := ReadStringFromStream(Stream);
  FUpdateRule := ReadStringFromStream(Stream);
  Stream.ReadBuffer(FDropped, SizeOf(FDropped));
end;

procedure TrpForeignKey.SaveToStream(Stream: TStream);
begin
  if not Assigned(Stream) then
    raise Exception.Create(MSG_STREAM_DO_NOT_INIT);

  SaveStringToStream(FConstraintName, Stream);
  SaveStringToStream(FTableName, Stream);
  SaveStringToStream(FFieldName, Stream);
  SaveStringToStream(FOnTableName, Stream);
  SaveStringToStream(FOnFieldName, Stream);
  SaveStringToStream(FDeleteRule, Stream);
  SaveStringToStream(FUpdateRule, Stream);
  Stream.WriteBuffer(FDropped, SizeOf(FDropped));
end;

procedure TrpForeignKey.SetConstraintName(const Value: string);
begin
  FConstraintName := Value;
end;

procedure TrpForeignKey.SetDeleteRule(const Value: string);
begin
  FDeleteRule := Value;
end;

procedure TrpForeignKey.SetDropped(const Value: Boolean);
begin
  FDropped := Value;
end;

procedure TrpForeignKey.SetFieldName(const Value: string);
begin
  FFieldName := Value;
end;

procedure TrpForeignKey.SetOnFieldName(const Value: string);
begin
  FOnFieldName := Value;
end;

procedure TrpForeignKey.SetOnTableName(const Value: string);
begin
  FOnTableName := Value;
end;

procedure TrpForeignKey.SetTableName(const Value: string);
begin
  FTableName := Value;
end;

procedure TrpForeignKey.SetUpdateRule(const Value: string);
begin
  FUpdateRule := Value;
end;

{ TrpForeignKeys }

procedure TrpForeignKeys.AddKeys;
var
  I: Integer;
  SQL, FKSQL: TIBSQL;
  Str: TMemoryStream;
begin
  ProgressState.Log(MSG_RESTORE_FKs);
  ProgressState.MaxMinor := Count;
  Str := TMemoryStream.Create;
  try
    FKSQL := TIBSQL.Create(nil);
    try
      FKSQL.Transaction := ReplDataBase.Transaction;
      FKSQL.SQL.Text := 'UPDATE rpl$dbstate SET fk = :fk';
      SQL := TIBSQL.Create(nil);
      try
        SQL.Transaction := ReplDataBase.Transaction;
        for I:= 0 to Count - 1 do
        begin
          if TrpForeignKey(Items[I]).Dropped then
          begin
            ReplDataBase.Connected := True;
            ReplDataBase.Transaction.StartTransaction;

            SQL.SQL.Text := TrpForeignKey(Items[I]).AddDLL;
            try
              SQL.ExecQuery;
              SQL.Close;
              TrpForeignKey(Items[I]).Dropped := False;
              Str.Clear;
              SaveDroppedToStream(Str);
              Str.Position := 0;
              if Str.Size > 0 then
                FKSQL.ParamByName(fnFk).LoadFromStream(Str)
              else
                FKSQL.ParamByName(fnFk).Clear;
              FKSQL.ExecQuery;

              ReplDataBase.Transaction.Commit;
              ReplDataBase.Connected := False;

              ProgressState.Log(Format(MSG_RESTORE_FK, [TrpForeignKey(Items[I]).FieldName,
                TrpForeignKey(Items[I]).TableName]));
            except
              on E: Exception do
              begin
                ReplDataBase.Transaction.Rollback;
                ReplDataBase.Connected := False;
                ProgressState.Log(Format(ERR_RESTORE_FK, [TrpForeignKey(Items[I]).FieldName,
                  TrpForeignKey(Items[I]).TableName, E.Message]));
              end;
            end;
          end;
          ProgressState.MinorProgress(Self);
        end;
      finally
        SQL.Free;
      end;
    finally
      FKSQL.Free;
    end;
  finally
    Str.Free;
  end;
end;

procedure TrpForeignKeys.DropKeys;
var
  I, Key: Integer;
  SQL, FKSQL: TIBSQL;
  Str: TMemoryStream;
  R: TrpRelation;
begin
  ProgressState.Log(MSG_DROPING_FK);
  ReplDataBase.Connected := True;
  try
    ReadKeys;
    ProgressState.MaxMinor := Count;
    Str := TMemoryStream.Create;
    try
      FKSQL := TIBSQL.Create(nil);
      try
        FKSQL.Transaction := ReplDataBase.Transaction;
        FKSQL.SQL.Text := 'UPDATE rpl$dbstate SET fk = :fk';
        SQL := TIBSQL.Create(nil);
        try
          SQL.Transaction := ReplDataBase.Transaction;
          for I := 0 to Count - 1 do
          begin
            if not TrpForeignKey(Items[I]).Dropped then
            begin
              ReplDataBase.Connected := True;
              ReplDataBase.Transaction.StartTransaction;

              //Перед тем как удалить внешний ключ необходимо
              //занести инфомацию в список таблиц
              Key := ReplDataBase.Relations.KeyByName(TrpForeignKey(Items[I]).TableName);
              R := ReplDataBase.Relations.Relations[Key];
              R.Load;
              SQL.SQL.Text := TrpForeignKey(Items[I]).DropDLL;
              try
                SQL.ExecQuery;
                SQL.Close;
                TrpForeignKey(Items[I]).Dropped := True;
                Str.Clear;
                SaveDroppedToStream(Str);
                Str.Position := 0;
                if Str.Size > 0 then
                  FKSQL.ParamByName(fnFk).LoadFromStream(Str)
                else
                  FKSQL.ParamByName(fnFk).Clear;
                FKSQL.ExecQuery;

                ReplDataBase.Transaction.Commit;
                ReplDataBase.Connected := False;

                ProgressState.Log(Format(MSG_DROP_FK, [TrpForeignKey(Items[I]).FieldName,
                  TrpForeignKey(Items[I]).TableName]));
              except
                on E: Exception do
                begin
                  ReplDataBase.Transaction.Rollback;
                  ReplDataBase.Connected := False;
                  ProgressState.Log(Format(MSG_DROP_FK, [TrpForeignKey(Items[I]).FieldName,
                    TrpForeignKey(Items[I]).TableName, E.Message]));
                end;
              end;
            end;
            ProgressState.MinorProgress(Self);
          end;
        finally
          SQL.Free;
        end;
      finally
        FKSQL.Free;
      end;
    finally
      Str.Free;
    end;
  finally
    ReplDataBase.Connected := False;
  end;
end;

function TrpForeignKeys.GetForeignKeys(Index: Integer): TrpForeignKey;
begin
  Result := TrpForeignKey(Items[Index]);
end;

function TrpForeignKeys.LoadFromTextFile(AFileName: string): boolean;
var
  sl: TStringList;
  i: integer;
  FK: TrpForeignKey;
begin
  Result:= False;
  if SysUtils.FileExists(AFileName) then begin
    sl:= TStringList.Create;
    try
      Clear;
      sl.LoadFromFile(AFileName);
      while Trim(sl[sl.Count - 1]) = '' do
        sl.Delete(sl.Count - 1);
      i:= 0;
      while i < sl.Count - 1 do begin
        while Trim(sl[i]) = '' do
          sl.Delete(i);
        if i + 5 > sl.Count then Exit;
        FK:= TrpForeignKey.Create;
        FK.ConstraintName:= sl[i];
        FK.TableName:= sl[i + 1];
        FK.FieldName:= sl[i + 2];
        FK.OnTableName:= sl[i + 3];
        FK.OnFieldName:= sl[i + 4];
        Inc(i, 5);
        Add(FK);
      end;
      Result:= True;
    finally
      sl.Free;
    end;
  end;
end;

procedure TrpForeignKeys.Notify(Ptr: Pointer; Action: TListNotification);
begin
  inherited;
{  if Action = lnDeleted then
    TrpForeignKey(Ptr).Free;}
end;

procedure TrpForeignKeys.ReadFromStream(Stream: TStream);
var
  I: Integer;
  lCount: Integer;
  FK: TrpForeignKey;
begin
  if not Assigned(Stream) then
    raise Exception.Create(MSG_STREAM_DO_NOT_INIT);

  Clear;
  Stream.ReadBuffer(lCount, SizeOf(lCount));
  for I := 0 to lCount - 1 do
  begin
    FK := TrpForeignKey.Create;
    FK.ReadFromStream(Stream);
    Add(Fk);
  end;
end;

procedure TrpForeignKeys.ReadKeys;
var
  SQL: TIBSQL;
  CSQL: TIBSQL;
  FK: TrpForeignKey;
begin
  Clear;

  CSQL := TIBSQL.Create(nil);
  try
    CSQL.Transaction := ReplDataBase.ReadTransaction;
    CSQL.SQL.Text := '/*Вытягивает циклические ссылки для таблиц учавствующих в репликации*/' +
      ' SELECT' +
      '  rc1.RDB$CONSTRAINT_NAME' +
      ' FROM' +
      '    RDB$RELATION_CONSTRAINTS rc1' +
      '    INNER JOIN RDB$REF_CONSTRAINTS refc1 ON (rc1.RDB$CONSTRAINT_NAME = refc1.RDB$CONSTRAINT_NAME)' +
      '    INNER JOIN RDB$RELATION_CONSTRAINTS rc2 ON (refc1.RDB$CONST_NAME_UQ = rc2.RDB$CONSTRAINT_NAME)' +
      '    INNER JOIN RDB$INDEX_SEGMENTS i_seg2 ON (rc2.RDB$INDEX_NAME = i_seg2.RDB$INDEX_NAME)' +
      '    INNER JOIN RDB$INDEX_SEGMENTS i_seg1 ON (rc1.RDB$INDEX_NAME = i_seg1.RDB$INDEX_NAME)' +
      ' WHERE' +
      '    rc1.RDB$CONSTRAINT_TYPE = ''FOREIGN KEY'' and' +
      '   rc1.RDB$RELATION_NAME <> rc2.RDB$RELATION_NAME and' +
      '   EXISTS (' +
      '     SELECT' +
      '       rpl_r.RELATION' +
      '     FROM' +
      '       RPL$RELATIONS rpl_r' +
      '     WHERE' +
      '       rpl_r.RELATION = rc1.RDB$RELATION_NAME' +
      '     ) AND' +
      '   EXISTS (' +
      '     SELECT' +
      '       rc11.RDB$RELATION_NAME' +
      '     FROM' +
      '       RDB$RELATION_CONSTRAINTS rc11' +
      '       INNER JOIN RDB$REF_CONSTRAINTS refc11 ON (rc11.RDB$CONSTRAINT_NAME = refc11.RDB$CONSTRAINT_NAME)' +
      '       INNER JOIN RDB$RELATION_CONSTRAINTS rc12 ON (refc11.RDB$CONST_NAME_UQ = rc12.RDB$CONSTRAINT_NAME)' +
      '       INNER JOIN RDB$INDEX_SEGMENTS i_seg12 ON (rc12.RDB$INDEX_NAME = i_seg12.RDB$INDEX_NAME)' +
      '       INNER JOIN RDB$INDEX_SEGMENTS i_seg11 ON (rc11.RDB$INDEX_NAME = i_seg11.RDB$INDEX_NAME)' +
      '    WHERE' +
      '      rc11.RDB$CONSTRAINT_TYPE = ''FOREIGN KEY'' and' +
      '      rc1.RDB$RELATION_NAME = rc12.RDB$RELATION_NAME and' +
      '      rc2.RDB$RELATION_NAME = rc11.RDB$RELATION_NAME' +
      '   )';
    CSQL.ExecQuery;
    if not CSQL.Eof then
    begin
      SQL := TIBSQL.Create(nil);
      try
        SQL.Transaction := ReplDataBase.ReadTransaction;
        SQL.SQL.Text := '/*Вытягивает для внешних полей всю информацию о них*/' +
          ' SELECT' +
          '  RC1.RDB$CONSTRAINT_NAME as ConstraintName,' +
          '  I_S1.RDB$FIELD_NAME as FieldName,' +
          '  RC2.RDB$RELATION_NAME as OnTableName,' +
          '  I_S2.RDB$FIELD_NAME as OnFieldName,' +
          '  RC1.RDB$RELATION_NAME as TableName,' +
          '  REFC.rdb$update_rule AS OnUpdate,' +
          '  REFC.rdb$delete_rule as OnDelete' +
          ' FROM' +
          '  RDB$RELATION_CONSTRAINTS RC1' +
          '  INNER JOIN RDB$INDEX_SEGMENTS I_S1 ON (RC1.RDB$INDEX_NAME = I_S1.RDB$INDEX_NAME)' +
          '  INNER JOIN RDB$REF_CONSTRAINTS REFC ON (RC1.RDB$CONSTRAINT_NAME = REFC.RDB$CONSTRAINT_NAME)' +
          '  INNER JOIN RDB$RELATION_CONSTRAINTS RC2 ON (REFC.RDB$CONST_NAME_UQ = RC2.RDB$CONSTRAINT_NAME)' +
          '  INNER JOIN RDB$INDEX_SEGMENTS I_S2 ON (RC2.RDB$INDEX_NAME = I_S2.RDB$INDEX_NAME)' +
          ' WHERE' +
          '  RC1.RDB$CONSTRAINT_NAME = :CONSTRAINT_NAME';
        SQL.Prepare;

        while not CSQL.Eof do
        begin
          SQL.ParamByName('CONSTRAINT_NAME').AsString := CSQL.Fields[0].AsString;
          SQL.ExecQuery;

          if not SQL.Eof then
          begin
            FK := TrpForeignKey.Create;
            FK.Read(SQL);
            Add(FK);
          end;

          SQL.Close;
          CSQL.Next;
        end;
      finally
        SQL.Free;
      end;
    end;
  finally
    CSQL.Free;
  end;
end;

procedure TrpForeignKeys.RestoreKeys;
var
  I, J: Integer;
  SQL: TIBSQL;
  Str: TMemoryStream;
begin
  Clear;
  SQL := TIBSQL.Create(nil);
  try
    SQL.SQL.Text := 'SELECT fk FROM rpl$dbstate';
    try
      ReplDataBase.Connected := True;
      SQL.Transaction := ReplDataBase.ReadTransaction;

      Str := TMemoryStream.Create;
      try
        SQL.ExecQuery;
        SQL.FieldByName(fnFk).SaveToStream(Str);
        Str.Position := 0;
        if Str.Size > 0 then
        begin
          ReadFromStream(Str);
        end;
      finally
        Str.Free;
      end;

      ReplDataBase.Connected := False;

      if Count > 0 then
      begin
        J := 0;
        for I := 0 to Count - 1 do
          if TrpForeignKey(Items[I]).Dropped then
            Inc(J);
        if J > 0 then
        begin
          ProgressState.Log(Format(MSG_FIND_NOT_RESTORE_FK, [J]));
          AddKeys;
        end;
      end;
    except
      on E: Exception do
      begin
        ReplDataBase.Connected := False;
      end;
    end;
  finally
    SQL.Free;
  end;
end;


procedure TrpForeignKeys.SaveDroppedToStream(Stream: TStream);
var
  I, iCount: Integer;
begin
  if not Assigned(Stream) then
    raise Exception.Create(MSG_STREAM_DO_NOT_INIT);

  iCount:= 0;
  for I := 0 to Count -1 do
    if TrpForeignKey(Items[I]).Dropped then
      Inc(iCount);

  if iCount = 0 then
    Stream.Size:= 0
  else begin
    Stream.WriteBuffer(iCount, SizeOf(iCount));
    for I := 0 to Count -1 do
      if TrpForeignKey(Items[I]).Dropped then
        TrpForeignKey(Items[I]).SaveToStream(Stream);
  end;
end;

procedure TrpForeignKeys.SaveToStream(Stream: TStream);
var
  I: Integer;
begin
  if not Assigned(Stream) then
    raise Exception.Create(MSG_STREAM_DO_NOT_INIT);

  Stream.WriteBuffer(Count, SizeOf(Count));
  for I := 0 to Count -1 do
    TrpForeignKey(Items[I]).SaveToStream(Stream);
end;

end.
