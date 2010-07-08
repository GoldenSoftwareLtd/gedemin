{�������� ����� �������� �� ���������� � �������� ������ ����������,
� �������� ������� �� ���������� � �������� ����� ������}
unit mdf_ChangeFilterReportName;

interface
uses
  sysutils, IBDatabase, gdModify;
  procedure ChangeFilterReportName(IBDB: TIBDatabase; Log: TModifyLog);

implementation
uses
  IBSQL;

procedure ChangeFilterReportName(IBDB: TIBDatabase; Log: TModifyLog);
var
  FIBTransaction: TIBTransaction;
  ibsql, ibsqlUpdate: TIBSQL;
  DBID: Integer;
begin
  ibsql := TIBSQL.Create(nil);
  ibsqlUpdate := TIBSQL.Create(nil);
  FIBTransaction := TIBTransaction.Create(nil);
  try
    FIBTransaction.DefaultDatabase := IBDB;
    ibsql.Transaction := FIBTransaction;
    ibsqlUpdate.Transaction := FIBTransaction;
    try
      if FIBTransaction.InTransaction then
        FIBTransaction.Rollback;
      FIBTransaction.StartTransaction;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT GEN_ID(gd_g_dbid, 0) FROM rdb$database';
      ibsql.ExecQuery;
      DBID := ibsql.Fields[0].AsInteger;

      //���������, ���� �� ��� ���������� ������ �� ��������
      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$indices WHERE rdb$index_name = ''FLT_X_SAVEDFILTER_NAMECKEY''';
      ibsql.ExecQuery;
      if ibsql.RecordCount > 0 then
      begin
        ibsql.Close;
        Log('FLT_SAVEDFILTER: �������� ����������� ������� flt_x_savedfilter_nameckey');
        ibsql.SQL.Text := 'DROP INDEX flt_x_savedfilter_nameckey';
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      {�������� ������������ � �������� ���������� ����� ��������}
      ibsqlUpdate.Close;
      ibsqlUpdate.SQL.Text := 'UPDATE flt_savedfilter SET name = :name WHERE id = :id';

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT f.* ' +
        ' FROM flt_savedfilter f ' +
        ' WHERE ' +
        ' EXISTS( ' +
        '  SELECT name, componentkey, userkey, COUNT(id) ' +
        '  FROM flt_savedfilter ' +
        '  WHERE name = f.name AND componentkey = f.componentkey AND userkey = f.userkey '  +
        '  GROUP BY name, componentkey, userkey ' +
        '  HAVING COUNT(id) > 1)';
      ibsql.ExecQuery;
      if not ibsql.EOF then
        Log('FLT_SAVEDFILTER: ��������� ���� �������� �� ���������� � �������� ������ ����������');
      while not ibsql.EOF do
      begin
        ibsqlUpdate.Close;
        //��� ����� ���� �� ������ 60, 20 �������� ������� ��� ����
        ibsqlUpdate.ParamByName('name').AsString := Copy(ibsql.FieldByName('name').AsString, 1, 40) +
          ibsql.FieldByName('id').AsString + '_' + IntToStr(DBID);
        ibsqlUpdate.ParamByName('id').AsString := ibsql.FieldByName('id').AsString;
        ibsqlUpdate.ExecQuery;
        ibsql.Next;
      end;
      FIBTransaction.Commit;
      FIBTransaction.StartTransaction;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$exceptions WHERE rdb$exception_name = ''FLT_E_INVALIDFILTERNAME''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        Log('FLT_SAVEDFILTER: �������� ���������� FLT_E_INVALIDFILTERNAME');
        ibsql.ParamCheck := False;
        ibsql.SQL.Text := 'CREATE EXCEPTION FLT_E_INVALIDFILTERNAME ' +
          '''You made an attempt to save filter with duplicate name.''';
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$triggers WHERE rdb$trigger_name = ''FLT_BI_SAVEDFILTER1''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        Log('FLT_SAVEDFILTER: �������� �������� FLT_BI_SAVEDFILTER1');
        ibsql.ParamCheck := False;
        ibsql.SQL.Text := 'CREATE TRIGGER flt_bi_savedfilter1 FOR flt_savedfilter '#13#10 +
          ' BEFORE INSERT POSITION 1 '#13#10 +
          ' AS '#13#10 +
          ' BEGIN '#13#10 +
          '   IF (EXISTS '#13#10 +
          '        (SELECT * '#13#10 +
          '         FROM flt_savedfilter '#13#10 +
          '         WHERE name = NEW.name AND componentkey = NEW.componentkey '#13#10 +
          '         AND (userkey = NEW.userkey OR userkey IS NULL AND NEW.userkey IS NULL)) '#13#10 +
          '       ) '#13#10 +
          '   THEN '#13#10 +
          '     EXCEPTION flt_e_invalidfiltername; '#13#10 +
          ' END ';

        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$triggers WHERE rdb$trigger_name = ''FLT_BU_SAVEDFILTER1''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        Log('FLT_SAVEDFILTER: �������� �������� FLT_BU_SAVEDFILTER1');
        ibsql.ParamCheck := False;
        ibsql.SQL.Text := 'CREATE TRIGGER flt_bu_savedfilter1 FOR flt_savedfilter '#13#10 +
          ' BEFORE UPDATE POSITION 1 '#13#10 +
          ' AS '#13#10+
          ' BEGIN '#13#10 +
          '   IF (EXISTS '#13#10 +
          '        (SELECT * '#13#10 +
          '         FROM flt_savedfilter '#13#10 +
          '         WHERE name = NEW.name AND componentkey = NEW.componentkey '#13#10 +
          '         AND (userkey = NEW.userkey OR userkey IS NULL AND NEW.userkey IS NULL) AND id <> NEW.id) '#13#10 +
          '       ) '#13#10 +
          '   THEN '#13#10 +
          '     EXCEPTION flt_e_invalidfiltername; '#13#10+
          ' END ';

        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;


      //���������, ���� �� ��� ���������� ������ �� �������
      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$indices WHERE rdb$index_name = ''RP_X_REPORTLIST_NAMERPGROUP''';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        {�������� ������������ � �������� ������ �������� �������}
        ibsqlUpdate.Close;
        ibsqlUpdate.SQL.Text := 'UPDATE rp_reportlist SET name = :name WHERE id = :id';

        ibsql.Close;
        ibsql.SQL.Text := 'SELECT r.* ' +
          ' FROM rp_reportlist r ' +
          ' WHERE ' +
          ' EXISTS( ' +
          '  SELECT name, reportgroupkey ' +
          '  FROM rp_reportlist ' +
          '  WHERE name = r.name AND reportgroupkey = r.reportgroupkey '  +
          '  GROUP BY name, reportgroupkey ' +
          '  HAVING COUNT(id) > 1)';
        ibsql.ExecQuery;
        if not ibsql.EOF then
          Log('RP_REPORTLIST: ��������� �������� ������� �� ���������� � �������� ����� ������');
        while not ibsql.EOF do
        begin
          ibsqlUpdate.Close;
          //��� ����� ���� �� ������ 60, 20 �������� ������� ��� ����
          ibsqlUpdate.ParamByName('name').AsString := Copy(ibsql.FieldByName('name').AsString, 1, 40) +
            ibsql.FieldByName('id').AsString + '_' + IntToStr(DBID);
          ibsqlUpdate.ParamByName('id').AsString := ibsql.FieldByName('id').AsString;
          ibsqlUpdate.ExecQuery;
          ibsql.Next;
        end;
        FIBTransaction.Commit;
        FIBTransaction.DefaultDataBase.Connected := False;
        FIBTransaction.DefaultDataBase.Connected := True;
        FIBTransaction.StartTransaction;

        ibsql.Close;
        Log('RP_REPORTLIST: �������� ����������� ������� �� ���� name, reportgroupkey');
        ibsql.SQL.Text := 'CREATE UNIQUE INDEX rp_x_reportlist_namerpgroup ON rp_reportlist(name, reportgroupkey)';
        ibsql.ExecQuery;
        FIBTransaction.Commit;
        FIBTransaction.StartTransaction;
      end;

      if FIBTransaction.InTransaction then
        FIBTransaction.Commit;
    except
      on E: Exception do
      begin
        if FIBTransaction.InTransaction then
          FIBTransaction.Rollback;
        Log('������: ' + E.Message);
      end;
    end;
  finally
    ibsql.Free;
    ibsqlUpdate.Free;
    FIBTransaction.Free;
  end;
end;

end.
