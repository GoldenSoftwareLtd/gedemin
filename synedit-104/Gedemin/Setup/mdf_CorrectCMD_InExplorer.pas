unit mdf_CorrectCMD_InExplorer;

interface
uses
  sysutils, IBDatabase, gdModify;
  procedure CorrectCMD_InExplorer(IBDB: TIBDatabase; Log: TModifyLog);

implementation
uses
  IBSQL, IBCustomDataSet;

function GetRUIDForTable(rn: String; oldcmd: String; ibtr: TIBTransaction): String;
var
  ibsql: TIBSQL;
begin
  {Транзакция д.б. открыта}
  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := ibtr;
    ibsql.SQL.Text := 'SELECT r.xid, r.dbid FROM at_relations a ' +
      ' JOIN gd_ruid r ON r.id = a.id ' +
      ' WHERE a.relationname = :rn ';
    ibsql.ParamByName('rn').AsString := AnsiUpperCase(rn);
    ibsql.ExecQuery;
    if ibsql.RecordCount > 0 then
      Result := ibsql.FieldByName('xid').AsString + '_' + ibsql.FieldByName('dbid').AsString
    else
      Result := oldcmd;
  finally
    ibsql.Free;
  end;
end;

function CheckRuid(RUIDString: string): boolean;
const
  RuidSet = ['0'..'9', '_'];
  NumericSet = ['0'..'9'];
var
  I: Integer;
begin
  if (Length(RUIDString) = 0) or not(RUIDString[1] in NumericSet) then
  begin
    Result := False;
    Exit;
  end;

  for I := 2 to Length(RUIDString) do
  begin
    if not(RUIDString[I] in RuidSet) then
    begin
      Result := False;
      Exit;
    end;
  end;

  Result := AnsiPos('_', RuidString) > 0;
end;

var
  WasMessage: Boolean;

procedure MsgBeginUpdate(Log: TModifyLog);
begin
  if not WasMessage then
  begin
    Log('GD_COMMAND: Обновление поля cmd');
    WasMessage := True;
  end;
end;

procedure CorrectCMD_InExplorer(IBDB: TIBDatabase; Log: TModifyLog);
var
  ibtr: TIBTransaction;
  ibds: TIBDataSet;
  q, q2: TIBSQL;
  R: String;
begin
  WasMessage := False;
  ibtr := TIBTransaction.Create(nil);
  ibds := TIBDataSet.Create(nil);
  try
    ibtr.DefaultDatabase := IBDB;
    ibds.Transaction := ibtr;
    try
      if ibtr.InTransaction then
        ibtr.Rollback;
      ibtr.StartTransaction;

      ibds.SelectSQL.Text := ' SELECT * FROM gd_command ' +
        ' WHERE (cmdtype = 0) AND (subtype IS NOT NULL) ' +
        '    AND (( ' +
        '          (subtype <> cmd) ' +
        '      AND (UPPER(classname) <> ''TGDCATTRUSERDEFINED'') ' +
        '      AND (UPPER(classname) <> ''TGDCATTRUSERDEFINEDTREE'')  ' +
        '      AND (UPPER(classname) <> ''TGDCATTRUSERDEFINEDLBRBTREE'') ' +
        '         ) OR ' +
        '         ( ' +
        '         (subtype = cmd) AND ' +
        '         ((UPPER(classname) = ''TGDCATTRUSERDEFINED'') ' +
        '       OR (UPPER(classname) = ''TGDCATTRUSERDEFINEDTREE'') ' +
        '       OR (UPPER(classname) = ''TGDCATTRUSERDEFINEDLBRBTREE'')) ' +
        '         ) OR (cmd IS NULL) ' +
        '        ) ';
      ibds.ModifySQL.Text := 'UPDATE gd_command SET cmd = :cmd WHERE id = :old_id';
      ibds.Open;

      while not ibds.Eof do
      begin
        if CheckRUID(ibds.FieldByName('subtype').AsString) then
        begin
          MsgBeginUpdate(Log);
          ibds.Edit;
          ibds.FieldByName('cmd').AsString := Copy(ibds.FieldByName('subtype').AsString,
            1, ibds.FieldByName('cmd').Size);
          ibds.Post;
        end else
        begin
          R := GetRUIDForTable(ibds.FieldByName('subtype').AsString,
            ibds.FieldByName('cmd').AsString, ibtr);
          if R <> ibds.FieldByName('cmd').AsString then
          begin
            MsgBeginUpdate(Log);
            ibds.Edit;
            ibds.FieldByName('cmd').AsString := R;
            ibds.Post;
          end;
        end;

        ibds.Next;
      end;


      if ibtr.InTransaction then
        ibtr.Commit;
    except
      on E: Exception do
      begin
        if ibtr.InTransaction then
          ibtr.Rollback;
        Log(E.Message);
      end;
    end;

    ibtr.StartTransaction;
    try
      q := TIBSQL.Create(nil);
      q2 := TIBSQL.Create(nil);
      try
        q.Transaction := ibtr;
        q2.Transaction := ibtr;

        q.SQL.Text := 'select xid, dbid,count(xid) ' +
          'from gd_ruid ' +
          'group by xid, dbid ' +
          'having count(xid) > 1 ';
        q.ExecQuery;
        while not q.EOF do
        begin
          q2.Close;
          q2.SQL.Text := 'DELETE FROM gd_ruid WHERE xid=' + q.Fields[0].AsString +
            ' AND dbid = ' + q.Fields[1].AsString;
          q2.ExecQuery;
          q.Next;
        end;
        q.Close;
        q2.Close;

        ibtr.Commit;
        ibtr.StartTransaction;

        try
          q.SQL.Text := 'DROP INDEX gd_x_ruid_xid';
          q.ExecQuery;
          q.Close;

          ibtr.Commit;
        except
          if ibtr.InTransaction then
            ibtr.Rollback;
        end;

        if not ibtr.InTransaction then
          ibtr.StartTransaction;

        try
          q.Close;
          q.SQL.Text := 'CREATE UNIQUE INDEX gd_x_ruid_xid ON gd_ruid(xid, dbid)';
          q.ExecQuery;
          q.Close;

          if ibtr.InTransaction then
            ibtr.Commit;
        except
          if ibtr.InTransaction then
            ibtr.Rollback;
        end;

        if not ibtr.InTransaction then
          ibtr.StartTransaction;

        try
          q.Close;
          q.SQL.Text := 'ALTER TABLE gd_const ADD datatype CHAR(1)';
          q.ExecQuery;
          q.Close;

          if ibtr.InTransaction then
            ibtr.Commit;
        except
          if ibtr.InTransaction then
            ibtr.Rollback;
        end;
      finally
        q.Free;
        q2.Free;
      end;
    except
      on E: Exception do
      begin
        if ibtr.InTransaction then
          ibtr.Rollback;
        Log(E.Message);
      end;
    end;


  finally
    ibds.Free;
    ibtr.Free;
  end;
end;

end.
