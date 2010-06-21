unit mfd_UserGroupNameToRUID;

interface

uses
  IBDatabase, gdModify, jclStrings;

procedure UserGroupToRUID(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils;

procedure UserGroupToRUID(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  IBSQL1, sqlDObject, q: TIBSQL;
  FDBID: Integer;

  function GetDBId: Integer;
  var
    SQL: TIBSQL;
  begin
    if FDBID = 0 then
    begin
      SQL := TIBSQL.Create(nil);
      try
        SQL.Transaction := FTransaction;
        SQL.SQL.Text := 'SELECT gen_id(GD_G_DBID, 0) AS dbid ' +
          'FROM RDB$DATABASE';
        SQL.ExecQuery;
        FDBID := SQL.Fields[0].AsInteger;
      finally
        SQL.Free;
      end;
    end;
    Result := FDBID;
  end;

function StrConsistsofNumberChars(const S: string): Boolean;
var
  I: Integer;
begin
  Result := S <> '';
  for I := 1 to Length(S) do
  begin
    if S[I] IN ['0'..'9','+','-']  then
    begin
      Result := False;
      Exit;
    end;
 end;
end;
  

var
  WasModify: Boolean;

begin
  FDBID := 0;
  WasModify := False;
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      IBSQL1 := TIBSQL.Create(nil);
      try
        IBSQL1.Transaction := FTransaction;
        IBSQL1.SQL.Text := 'UPDATE rp_reportgroup SET usergroupname = :usergroupname WHERE id = :id';
        sqlDObject := TIBSQL.Create(nil);
        try
          sqlDObject.SQL.Text := 'SELECT usergroupname, id FROM ' +
            ' rp_reportgroup WHERE usergroupname not containing ''_'' AND id >= 147000000';
          sqlDObject.Transaction := FTransaction;
          sqlDObject.ExecQuery;

          while not sqlDObject.Eof do
          begin
            try
              //к руиду будем преобразовывать только usergroupname, хранящий идентификатор
              if StrConsistsOfNumberChars(sqlDObject.FieldByName('usergroupname').AsString) then
              begin
                IBSQL1.Close;
                IBSQL1.Params[0].AsString := sqlDObject.Fields[0].AsString +
                  '_' + IntToStr(GetDBID);
                IBSQL1.Params[1].AsInteger :=sqlDObject.Fields[1].AsInteger;
                IBSQL1.ExecQuery;
                WasModify := True;
              end;
            except
            end;
            sqlDObject.Next;
          end;
          FTransaction.Commit;
          if WasModify then
            Log('Поле usergroupname в таблице rp_reportgroup преобразовано к РУИДу');
        finally
          sqlDObject.Free;
        end;
      finally
        IBSQL1.Free;
      end;
    except
      Log('Ошибка преобразования поля usergroupname в таблице rp_reportgroup к РУИДу');
      FTransaction.Rollback;
    end;
  finally
    FTransaction.Free;
  end;

  //
  FTransaction := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    q.Transaction := FTransaction;

    FTransaction.StartTransaction;
    try
      q.SQL.Text := 'CREATE GENERATOR gd_g_block';
      q.ExecQuery;
      FTransaction.Commit;
    except
      if FTransaction.InTransaction then
        FTransaction.Rollback;
    end;

    FTransaction.StartTransaction;
    try
      q.SQL.Text := 'SET GENERATOR gd_g_block TO 0';
      q.ExecQuery;
      FTransaction.Commit;
    except
      if FTransaction.InTransaction then
        FTransaction.Rollback;
    end;

    FTransaction.StartTransaction;
    try
      q.SQL.Text := 'CREATE EXCEPTION gd_e_block ''Period zablokirovan!'' ';
      q.ExecQuery;
      FTransaction.Commit;
    except
      if FTransaction.InTransaction then
        FTransaction.Rollback;
    end;

    FTransaction.StartTransaction;
    try
      q.SQL.Text := 'CREATE TRIGGER inv_bi_movement_block FOR inv_movement ' +
'  ACTIVE ' +
'  BEFORE INSERT ' +
'  POSITION 28017 ' +
'AS ' +
'BEGIN ' +
'  IF (CAST(NEW.movementdate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN ' +
'  BEGIN ' +
'    EXCEPTION gd_e_block; ' +
'  END ' +
'END';
      q.ExecQuery;
      FTransaction.Commit;
    except
      if FTransaction.InTransaction then
        FTransaction.Rollback;
    end;

    FTransaction.StartTransaction;
    try
      q.SQL.Text := 'CREATE TRIGGER inv_bu_movement_block FOR inv_movement ' +
'  ACTIVE ' +
'  BEFORE UPDATE ' +
'  POSITION 28017 ' +
'AS ' +
'BEGIN ' +
'  IF (CAST(NEW.movementdate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN ' +
'  BEGIN ' +
'    EXCEPTION gd_e_block; ' +
'  END ' +
'END';
      q.ExecQuery;
      FTransaction.Commit;
    except
      if FTransaction.InTransaction then
        FTransaction.Rollback;
    end;

    FTransaction.StartTransaction;
    try
      q.SQL.Text := 'CREATE TRIGGER inv_bd_movement_block FOR inv_movement ' +
'  ACTIVE ' +
'  BEFORE DELETE ' +
'  POSITION 28017 ' +
'AS ' +
'BEGIN ' +
'  IF (CAST(OLD.movementdate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN ' +
'  BEGIN ' +
'    EXCEPTION gd_e_block; ' +
'  END ' +
'END';
      q.ExecQuery;
      FTransaction.Commit;
    except
      if FTransaction.InTransaction then
        FTransaction.Rollback;
    end;

    FTransaction.StartTransaction;
    try
      q.SQL.Text := 'CREATE TRIGGER ac_bi_entry_block FOR ac_entry ' +
'  ACTIVE ' +
'  BEFORE INSERT ' +
'  POSITION 28017 ' +
'AS ' +
'BEGIN ' +
'  IF (CAST(NEW.entrydate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN ' +
'  BEGIN ' +
'    EXCEPTION gd_e_block; ' +
'  END ' +
'END';
      q.ExecQuery;
      FTransaction.Commit;
    except
      if FTransaction.InTransaction then
        FTransaction.Rollback;
    end;

    FTransaction.StartTransaction;
    try
      q.SQL.Text := 'CREATE TRIGGER ac_bu_entry_block FOR ac_entry ' +
'  ACTIVE ' +
'  BEFORE UPDATE ' +
'  POSITION 28017 ' +
'AS ' +
'BEGIN ' +
'  IF (CAST(NEW.entrydate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN ' +
'  BEGIN ' +
'    EXCEPTION gd_e_block; ' +
'  END ' +
'END';
      q.ExecQuery;
      FTransaction.Commit;
    except
      if FTransaction.InTransaction then
        FTransaction.Rollback;
    end;

    FTransaction.StartTransaction;
    try
      q.SQL.Text := 'CREATE TRIGGER ac_bd_entry_block FOR ac_entry ' +
'  ACTIVE ' +
'  BEFORE DELETE ' +
'  POSITION 28017 ' +
'AS ' +
'BEGIN ' +
'  IF (CAST(OLD.entrydate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN ' +
'  BEGIN ' +
'    EXCEPTION gd_e_block; ' +
'  END ' +
'END';
      q.ExecQuery;
      FTransaction.Commit;
    except
      if FTransaction.InTransaction then
        FTransaction.Rollback;
    end;

    FTransaction.StartTransaction;
    try
      q.SQL.Text := 'CREATE TRIGGER gd_bi_document_block FOR gd_document ' +
'  ACTIVE ' +
'  BEFORE INSERT ' +
'  POSITION 28017 ' +
'AS ' +
'BEGIN ' +
'  IF (CAST(NEW.documentdate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN ' +
'  BEGIN ' +
'    EXCEPTION gd_e_block; ' +
'  END ' +
'END';
      q.ExecQuery;
      FTransaction.Commit;
    except
      if FTransaction.InTransaction then
        FTransaction.Rollback;
    end;

    FTransaction.StartTransaction;
    try
      q.SQL.Text := 'CREATE TRIGGER gd_bu_document_block FOR gd_document ' +
'  ACTIVE ' +
'  BEFORE UPDATE ' +
'  POSITION 28017 ' +
'AS ' +
'BEGIN ' +
'  IF (CAST(NEW.documentdate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN ' +
'  BEGIN ' +
'    EXCEPTION gd_e_block; ' +
'  END ' +
'END';
      q.ExecQuery;
      FTransaction.Commit;
    except
      if FTransaction.InTransaction then
        FTransaction.Rollback;
    end;

    FTransaction.StartTransaction;
    try
      q.SQL.Text := 'CREATE TRIGGER gd_bd_document_block FOR gd_document ' +
'  ACTIVE ' +
'  BEFORE DELETE ' +
'  POSITION 28017 ' +
'AS ' +
'BEGIN ' +
'  IF (CAST(OLD.documentdate AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN ' +
'  BEGIN ' +
'    EXCEPTION gd_e_block; ' +
'  END ' +
'END';
      q.ExecQuery;
      FTransaction.Commit;
    except
      if FTransaction.InTransaction then
        FTransaction.Rollback;
    end;

    FTransaction.StartTransaction;
    try
      q.SQL.Text := 'CREATE TRIGGER inv_bi_card_block FOR inv_card ' +
'  ACTIVE ' +
'  BEFORE INSERT ' +
'  POSITION 28017 ' +
'AS ' +
'  DECLARE VARIABLE D DATE; ' +
'BEGIN ' +
'  IF (GEN_ID(gd_g_block, 0) > 0) THEN ' +
'  BEGIN ' +
'    SELECT doc.documentdate ' +
'    FROM gd_document doc ' +
'    WHERE doc.id = NEW.documentkey ' +
'    INTO :D; ' +
' ' +
'    IF (CAST(D AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN ' +
'    BEGIN ' +
'      EXCEPTION gd_e_block; ' +
'    END ' +
'  END ' +
'END';
      q.ExecQuery;
      FTransaction.Commit;
    except
      if FTransaction.InTransaction then
        FTransaction.Rollback;
    end;

    FTransaction.StartTransaction;
    try
      q.SQL.Text := 'CREATE TRIGGER inv_bu_card_block FOR inv_card ' +
'  ACTIVE ' +
'  BEFORE UPDATE ' +
'  POSITION 28017 ' +
'AS ' +
'  DECLARE VARIABLE D DATE; ' +
'BEGIN ' +
'  IF (GEN_ID(gd_g_block, 0) > 0) THEN ' +
'  BEGIN ' +
'    SELECT doc.documentdate ' +
'    FROM gd_document doc ' +
'    WHERE doc.id = NEW.documentkey ' +
'    INTO :D; ' +
' ' +
'    IF (CAST(D AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN ' +
'    BEGIN ' +
'      EXCEPTION gd_e_block; ' +
'    END ' +
'  END ' +
'END';
      q.ExecQuery;
      FTransaction.Commit;
    except
      if FTransaction.InTransaction then
        FTransaction.Rollback;
    end;

    FTransaction.StartTransaction;
    try
      q.SQL.Text := 'CREATE TRIGGER inv_bd_card_block FOR inv_card ' +
'  ACTIVE ' +
'  BEFORE DELETE ' +
'  POSITION 28017 ' +
'AS ' +
'  DECLARE VARIABLE D DATE; ' +
'BEGIN ' +
'  IF (GEN_ID(gd_g_block, 0) > 0) THEN ' +
'  BEGIN ' +
'    SELECT doc.documentdate ' +
'    FROM gd_document doc ' +
'    WHERE doc.id = OLD.documentkey ' +
'    INTO :D; ' +
' ' +
'    IF (CAST(D AS INTEGER) < GEN_ID(gd_g_block, 0)) THEN ' +
'    BEGIN ' +
'      EXCEPTION gd_e_block; ' +
'    END ' +
'  END ' +
'END';
      q.ExecQuery;
      FTransaction.Commit;
    except
      if FTransaction.InTransaction then
        FTransaction.Rollback;
    end;

    {    FTransaction.StartTransaction;
    try
      q.SQL.Text := '';
      q.ExecQuery;
      FTransaction.Commit;
    except
      if FTransaction.InTransaction then
        FTransaction.Rollback;
    end; }

  finally
    q.Free;
    FTransaction.Free;
  end;
end;

end.
