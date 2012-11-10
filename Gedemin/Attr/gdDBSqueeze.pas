
unit gdDBSqueeze;

interface

uses
  Classes, IBDatabase, IBSQL;

type
  TgdDBSqueeze = class(TObject)
  private
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;
    FQ: TIBSQL;

    FTriggers, FFK: TStringList;

    procedure DisableTriggers;
    procedure EnableTriggers;

    procedure DropForeignKeys;
    procedure CreateForeignKeys;

    procedure DropPrimaryKeys;
    procedure CreatePrimaryKeys;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Squeeze;
  end;

implementation

uses
  SysUtils, at_frmSQLProcess;

{ TgdDBSqueeze }

constructor TgdDBSqueeze.Create;
begin
  FDatabase := TIBDatabase.Create(nil);
  FTransaction := TIBTransaction.Create(nil);
  FQ := TIBSQL.Create(nil);
  FTriggers := TStringList.Create;
  FFK := TStringList.Create;
end;

procedure TgdDBSqueeze.CreateForeignKeys;
var
  I: Integer;
begin
  if FTransaction.InTransaction then
    FQ.Close
  else
    FTransaction.StartTransaction;

  for I := 0 to FFK.Count - 1 do
  begin
    FQ.SQL.Text := FFK[I];
    try
      FQ.ExecQuery;
    except
      on E: Exception do
      begin
        AddMistake(E.Message);
        raise;
      end;
    end;
  end;

  try
    FQ.Close;
    FTransaction.Commit;
  except
    on E: Exception do
    begin
      AddMistake(E.Message);
      raise;
    end;
  end;

  AddText('Создано внешних ключей: ' + IntToStr(FFK.Count));
end;

procedure TgdDBSqueeze.Squeeze;
begin
  FDatabase.DatabaseName := '...';
  FDatabase.Params.Text := 'user_name=SYSDBA'#13#10'password=masterkey'#13#10'lc_ctype=win1251';
  FDatabase.LoginPrompt := False;
  FDatabase.Connected := True;

  FTransaction.DefaultDatabase := FDatabase;
  FQ.Transaction := FTransaction;

  AddText('Начато сжатие базы ' + FDatabase.DatabaseName);

  try
    DisableTriggers;
    DropForeignKeys;
    DropPrimaryKeys;

    {if FTransaction.InTransaction then
      FTransaction.Commit;

    FDatabase.Connected := False;
    FDatabase.Connected := True;}

    CreatePrimaryKeys;
    CreateForeignKeys;
    EnableTriggers;

    if FTransaction.InTransaction then
      FTransaction.Commit;

    AddText('Окончено сжатие базы ' + FDatabase.DatabaseName);
  except
    on E: Exception do
    begin
      AddMistake('Ошибка в процессе сжатия базы данных: ' + E.Message);

      if FTransaction.InTransaction then
        FTransaction.Rollback;
    end;
  end;
end;

destructor TgdDBSqueeze.Destroy;
begin
  FFK.Free;
  FTriggers.Free;
  FQ.Free;
  FTransaction.Free;
  FDatabase.Free;
  inherited;
end;

procedure TgdDBSqueeze.DisableTriggers;
var
  I: Integer;
begin
  FTriggers.Clear;

  if FTransaction.InTransaction then
    FQ.Close
  else
    FTransaction.StartTransaction;

  FQ.SQL.Text := 'SELECT rdb$trigger_name FROM rdb$triggers ' +
    'WHERE COALESCE(rdb$system_flag, 0) = 0 AND rdb$trigger_inactive = 0 ';
  FQ.ExecQuery;
  while not FQ.EOF do
  begin
    FTriggers.Add(FQ.Fields[0].AsTrimString);
    FQ.Next;
  end;

  FQ.Close;
  for I := 0 to FTriggers.Count - 1 do
  begin
    FQ.SQL.Text := 'ALTER TRIGGER ' + FTriggers[I] + ' INACTIVE';
    try
      FQ.ExecQuery;
    except
      on E: Exception do
      begin
        AddMistake(E.Message);
        raise;
      end;
    end;
  end;

  try
    FQ.Close;
    FTransaction.Commit;
  except
    on E: Exception do
    begin
      AddMistake(E.Message);
      raise;
    end;
  end;

  AddText('Отключено триггеров: ' + IntToStr(FTriggers.Count));
end;

procedure TgdDBSqueeze.DropForeignKeys;
var
  DropList: TStringList;
  S: String;
  I: Integer;
begin
  FFK.Clear;

  if FTransaction.InTransaction then
    FQ.Close
  else
    FTransaction.StartTransaction;

  FQ.SQL.Text :=
    'EXECUTE BLOCK'#13#10 +
    '  RETURNS ('#13#10 +
    '    constraint_name   VARCHAR(31)  CHARACTER SET UNICODE_FSS,'#13#10 +
    '    const_name_uq     VARCHAR(31)  CHARACTER SET UNICODE_FSS,'#13#10 +
    '    update_rule       VARCHAR(10)  CHARACTER SET UNICODE_FSS,'#13#10 +
    '    delete_rule       VARCHAR(10)  CHARACTER SET UNICODE_FSS,'#13#10 +
    '    fk_relname        VARCHAR(31)  CHARACTER SET UNICODE_FSS,'#13#10 +
    '    fk_fields         VARCHAR(200) CHARACTER SET UNICODE_FSS,'#13#10 +
    '    pk_relname        VARCHAR(31)  CHARACTER SET UNICODE_FSS,'#13#10 +
    '    pk_fields         VARCHAR(200) CHARACTER SET UNICODE_FSS'#13#10 +
    '  )'#13#10 +
    'AS'#13#10 +
    '  DECLARE VARIABLE fld_name VARCHAR(31)  CHARACTER SET UNICODE_FSS;'#13#10 +
    '  DECLARE VARIABLE idx_name VARCHAR(31)  CHARACTER SET UNICODE_FSS;'#13#10 +
    'BEGIN'#13#10 +
    '  FOR SELECT'#13#10 +
    '    rf.rdb$constraint_name, rf.rdb$const_name_uq, rf.rdb$update_rule,'#13#10 +
    '    rf.rdb$delete_rule, fk.rdb$relation_name, fk.rdb$index_name'#13#10 +
    '  FROM'#13#10 +
    '    rdb$ref_constraints rf JOIN rdb$relation_constraints fk'#13#10 +
    '      ON fk.rdb$constraint_name = rf.rdb$constraint_name'#13#10 +
    '  INTO'#13#10 +
    '    :constraint_name, :const_name_uq, :update_rule, :delete_rule,'#13#10 +
    '    :fk_relname, :idx_name'#13#10 +
    '  DO BEGIN'#13#10 +
    '    fk_fields = NULL;'#13#10 +
    '    FOR SELECT rdb$field_name FROM rdb$index_segments'#13#10 +
    '      WHERE rdb$index_name = :idx_name INTO :fld_name'#13#10 +
    '    DO'#13#10 +
    '      fk_fields = COALESCE(:fk_fields || '','', '''') || TRIM(:fld_name);'#13#10 +
    ''#13#10 +
    '    SELECT rdb$relation_name, rdb$index_name FROM rdb$relation_constraints'#13#10 +
    '      WHERE rdb$constraint_name = :const_name_uq'#13#10 +
    '      INTO :pk_relname, :idx_name;'#13#10 +
    ''#13#10 +
    '    pk_fields = NULL;'#13#10 +
    '    FOR SELECT rdb$field_name FROM rdb$index_segments'#13#10 +
    '      WHERE rdb$index_name = :idx_name INTO :fld_name'#13#10 +
    '    DO'#13#10 +
    '      pk_fields = COALESCE(:pk_fields || '','', '''') || TRIM(:fld_name);'#13#10 +
    ''#13#10 +
    '    SUSPEND;'#13#10 +
    '  END'#13#10 +
    'END';

  DropList := TStringList.Create;
  try
    FQ.ExecQuery;
    while not FQ.EOF do
    begin
      DropList.Add('ALTER TABLE ' + FQ.FieldByName('fk_relname').AsTrimString +
        ' DROP CONSTRAINT ' + FQ.FieldByName('constraint_name').AsTrimString);
      S := 'ALTER TABLE ' + FQ.FieldByName('fk_relname').AsTrimString +
        ' ADD CONSTRAINT ' + FQ.FieldByName('constraint_name').AsTrimString +
        ' FOREIGN KEY (' + FQ.FieldByName('fk_fields').AsTrimString + ')' +
        ' REFERENCES ' + FQ.FieldByName('pk_relname').AsTrimString + ' (' +
        FQ.FieldByName('pk_fields').AsTrimString + ')';
      if FQ.FieldByName('update_rule').AsTrimString <> 'RESTRICT' then
        S := S + ' ON UPDATE ' + FQ.FieldByName('update_rule').AsTrimString;
      if FQ.FieldByName('delete_rule').AsTrimString <> 'RESTRICT' then
        S := S + ' ON DELETE ' + FQ.FieldByName('delete_rule').AsTrimString;
      FFK.Add(S);
      FQ.Next;
    end;

    for I := 0 to DropList.Count - 1 do
    begin
      FQ.Close;
      FQ.SQL.Text := DropList[I];
      try
        FQ.ExecQuery;
      except
        on E: Exception do
        begin
          AddMistake(E.Message);
          raise;
        end;
      end;
    end;
  finally
    DropList.Free;
  end;

  try
    FQ.Close;
    FTransaction.Commit;
  except
    on E: Exception do
    begin
      AddMistake(E.Message);
      raise;
    end;
  end;

  AddText('Удалено внешних ключей: ' + IntToStr(FFK.Count));
end;

procedure TgdDBSqueeze.EnableTriggers;
var
  I: Integer;
begin
  if FTransaction.InTransaction then
    FQ.Close
  else
    FTransaction.StartTransaction;

  for I := 0 to FTriggers.Count - 1 do
  begin
    FQ.SQL.Text := 'ALTER TRIGGER ' + FTriggers[I] + ' ACTIVE';
    try
      FQ.ExecQuery;
    except
      on E: Exception do
      begin
        AddMistake(E.Message);
        raise;
      end;
    end;
  end;

  try
    FQ.Close;
    FTransaction.Commit;
  except
    on E: Exception do
    begin
      AddMistake(E.Message);
      raise;
    end;
  end;

  AddText('Подключено триггеров: ' + IntToStr(FTriggers.Count));
end;

procedure TgdDBSqueeze.CreatePrimaryKeys;
begin

end;

procedure TgdDBSqueeze.DropPrimaryKeys;
begin

end;

end.
