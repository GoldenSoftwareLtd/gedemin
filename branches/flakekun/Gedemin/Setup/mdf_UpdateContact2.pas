
unit mdf_UpdateContact2;

interface

uses
  Classes, IBDatabase, gdModify;

procedure UpdateContact2(IBDB: TIBDatabase; Log: TModifyLog);


implementation

uses
  IBSQL, SysUtils, gd_KeyAssoc;

procedure UpdateContact2(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL, q, q2: TIBSQL;
  L, L2: TList;
  I: Integer;
begin
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      FIBSQL := TIBSQL.Create(nil);
      FIBSQL.ParamCheck := False;
      q := TIBSQL.Create(nil);
      q2 := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;
        q.Transaction := FTransaction;
        q2.Transaction := FTransaction;
        try
          FIBSQL.SQL.Text := 'UPDATE gd_contact SET parent=650001 WHERE parent IS NULL AND contacttype IN (3, 4) ';
          FIBSQL.ExecQuery;
          FTransaction.Commit;
          FTransaction.StartTransaction;

          FIBSQL.SQL.Text :=
            'alter table gd_contact drop constraint GD_CHK_CONTACT_PARENT ';
          FIBSQL.ExecQuery;
          FTransaction.Commit;
          FTransaction.StartTransaction;

          FIBSQL.SQL.Text :=
            'alter table gd_contact add constraint GD_CHK_CONTACT_PARENT CHECK ((contacttype IN (0, 1)) OR (NOT (parent IS NULL))) ';
          FIBSQL.ExecQuery;
          FTransaction.Commit;
          FTransaction.StartTransaction;

          FIBSQL.SQL.Text :=
            'DROP TRIGGER gd_bi_people ';
          try
            FIBSQL.ExecQuery;
            FTransaction.Commit;
          except
            if FTransaction.InTransaction then
              FTransaction.Rollback;
          end;
          if not FTransaction.InTransaction then
            FTransaction.StartTransaction;

          FIBSQL.SQL.Text :=
            'DROP TRIGGER gd_bu_people ';
          try
            FIBSQL.ExecQuery;
            FTransaction.Commit;
          except
            if FTransaction.InTransaction then
              FTransaction.Rollback;
          end;
          if not FTransaction.InTransaction then
            FTransaction.StartTransaction;

          FIBSQL.SQL.Text :=
            'alter table gd_people drop wtitle ';
          try
            FIBSQL.ExecQuery;
            FTransaction.Commit;
          except
            if FTransaction.InTransaction then
              FTransaction.Rollback;
          end;
          if not FTransaction.InTransaction then
            FTransaction.StartTransaction;

          FIBSQL.SQL.Text :=
            'alter table gd_people add wtitle dtext60 ';
          FIBSQL.ExecQuery;
          FTransaction.Commit;
          FTransaction.StartTransaction;

          FIBSQL.SQL.Text :=
            'alter table gd_people add wpositionkey dforeignkey ';
          try
            FIBSQL.ExecQuery;
            FTransaction.Commit;
          except
            if FTransaction.InTransaction then
              FTransaction.Rollback;
          end;
          if not FTransaction.InTransaction then
            FTransaction.StartTransaction;

          FIBSQL.SQL.Text :=
            'alter table gd_people add personalnumber dtext40 ';
          try
            FIBSQL.ExecQuery;
            FTransaction.Commit;
          except
            if FTransaction.InTransaction then
              FTransaction.Rollback;
          end;
          if not FTransaction.InTransaction then
            FTransaction.StartTransaction;

          FIBSQL.SQL.Text :=
            'alter table gd_people drop passportdate ';
          try
            FIBSQL.ExecQuery;
            FTransaction.Commit;
          except
            if FTransaction.InTransaction then
              FTransaction.Rollback;
          end;
          if not FTransaction.InTransaction then
            FTransaction.StartTransaction;

          FIBSQL.SQL.Text :=
            'alter table gd_people drop visitcard2 ';
          try
            FIBSQL.ExecQuery;
            FTransaction.Commit;
          except
            if FTransaction.InTransaction then
              FTransaction.Rollback;
          end;
          if not FTransaction.InTransaction then
            FTransaction.StartTransaction;

          FIBSQL.SQL.Text :=
            'alter table gd_people drop ipphone ';
          try
            FIBSQL.ExecQuery;
            FTransaction.Commit;
          except
            if FTransaction.InTransaction then
              FTransaction.Rollback;
          end;
          if not FTransaction.InTransaction then
            FTransaction.StartTransaction;

          FIBSQL.SQL.Text :=
            'alter table gd_people drop wpager ';
          try
            FIBSQL.ExecQuery;
            FTransaction.Commit;
          except
            if FTransaction.InTransaction then
              FTransaction.Rollback;
          end;
          if not FTransaction.InTransaction then
            FTransaction.StartTransaction;

          FIBSQL.SQL.Text :=
            'alter table gd_people drop whandy ';
          try
            FIBSQL.ExecQuery;
            FTransaction.Commit;
          except
            if FTransaction.InTransaction then
              FTransaction.Rollback;
          end;
          if not FTransaction.InTransaction then
            FTransaction.StartTransaction;

          FIBSQL.SQL.Text :=
            'alter table gd_people drop woffice ';
          try
            FIBSQL.ExecQuery;
            FTransaction.Commit;
          except
            if FTransaction.InTransaction then
              FTransaction.Rollback;
          end;
          if not FTransaction.InTransaction then
            FTransaction.StartTransaction;

          FIBSQL.SQL.Text :=
            'alter table gd_people drop hfax ';
          try
            FIBSQL.ExecQuery;
            FTransaction.Commit;
          except
            if FTransaction.InTransaction then
              FTransaction.Rollback;
          end;
          if not FTransaction.InTransaction then
            FTransaction.StartTransaction;

          FIBSQL.SQL.Text :=
            'alter table gd_people drop defaultphone ';
          try
            FIBSQL.ExecQuery;
            FTransaction.Commit;
          except
            if FTransaction.InTransaction then
              FTransaction.Rollback;
          end;
          if not FTransaction.InTransaction then
            FTransaction.StartTransaction;

          FIBSQL.SQL.Text :=
            'alter table gd_people drop hurl ';
          try
            FIBSQL.ExecQuery;
            FTransaction.Commit;
          except
            if FTransaction.InTransaction then
              FTransaction.Rollback;
          end;
          if not FTransaction.InTransaction then
            FTransaction.StartTransaction;

          FIBSQL.SQL.Text :=
            'CREATE TABLE wg_position '#13#10 +
            '( '#13#10 +
            '  id         dintkey, '#13#10 +
            '  /*alias      dalias,*/ '#13#10 +
            '  name       dname, '#13#10 +
            '  reserved   dreserved, '#13#10 +
            ' '#13#10 +
            '  CONSTRAINT wg_pk_position PRIMARY KEY (id) '#13#10 +
            ') ';
          try
            FIBSQL.ExecQuery;
            FTransaction.Commit;
          except
            if FTransaction.InTransaction then
              FTransaction.Rollback;
          end;
          if not FTransaction.InTransaction then
            FTransaction.StartTransaction;

          FIBSQL.SQL.Text :=
            'ALTER TABLE wg_position DROP alias '#13#10;
          try
            FIBSQL.ExecQuery;
            FTransaction.Commit;
          except
            if FTransaction.InTransaction then
              FTransaction.Rollback;
          end;
          if not FTransaction.InTransaction then
            FTransaction.StartTransaction;

          FIBSQL.SQL.Text :=
            'CREATE UNIQUE INDEX wg_x_position_name ON wg_position(name) ';
          try
            FIBSQL.ExecQuery;
            FTransaction.Commit;
          except
            if FTransaction.InTransaction then
              FTransaction.Rollback;
          end;
          if not FTransaction.InTransaction then
            FTransaction.StartTransaction;

          FIBSQL.SQL.Text :=
            'CREATE TRIGGER wg_bi_position FOR wg_position '#13#10 +
            '  BEFORE INSERT '#13#10 +
            '  POSITION 0 '#13#10 +
            'AS '#13#10 +
            'BEGIN '#13#10 +
            '  IF (NEW.id IS NULL) THEN '#13#10 +
            '    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0); '#13#10 +
            'END ';
          try
            FIBSQL.ExecQuery;
            FTransaction.Commit;
          except
            if FTransaction.InTransaction then
              FTransaction.Rollback;
          end;
          if not FTransaction.InTransaction then
            FTransaction.StartTransaction;


          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_people ADD CONSTRAINT gd_fk_people_positionkey '+
            '  FOREIGN KEY (wpositionkey) REFERENCES wg_position(id) ' +
            '  ON UPDATE CASCADE ' +
            '  ON DELETE SET NULL ';
          try
            FIBSQL.ExecQuery;
            FTransaction.Commit;
          except
            if FTransaction.InTransaction then
              FTransaction.Rollback;
          end;
          if not FTransaction.InTransaction then
            FTransaction.StartTransaction;

          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_people ADD hplacekey dforeignkey ';
          try
            FIBSQL.ExecQuery;
            FTransaction.Commit;
          except
            if FTransaction.InTransaction then
              FTransaction.Rollback;
          end;
          if not FTransaction.InTransaction then
            FTransaction.StartTransaction;


          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_bank ADD SWIFT dtext20 ';
          try
            FIBSQL.ExecQuery;
            FTransaction.Commit;
          except
            if FTransaction.InTransaction then
              FTransaction.Rollback;
          end;
          if not FTransaction.InTransaction then
            FTransaction.StartTransaction;


          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_people ADD CONSTRAINT gd_fk_people_hplacekey '#13#10 +
            '  FOREIGN KEY (hplacekey) REFERENCES gd_place(id) '#13#10 +
            '  ON UPDATE CASCADE '#13#10 +
            '  ON DELETE SET NULL; '#13#10;
          try
            FIBSQL.ExecQuery;
            FTransaction.Commit;
          except
            if FTransaction.InTransaction then
              FTransaction.Rollback;
          end;
          if not FTransaction.InTransaction then
            FTransaction.StartTransaction;

          FIBSQL.SQL.Text :=
            'CREATE TRIGGER gd_bi_people FOR gd_people '#13#10 +
            '  BEFORE INSERT '#13#10 +
            '  POSITION 0 '#13#10 +
            'AS '#13#10 +
            'BEGIN '#13#10 +
            '  NEW.rank = NULL; '#13#10 +
            '  SELECT g_s_copy(name, 1, 20) FROM wg_position WHERE id = NEW.wpositionkey '#13#10 +
            '    INTO NEW.rank; '#13#10 +
            ' '#13#10 +
            '  IF (NOT NEW.wcompanykey IS NULL) THEN '#13#10 +
            '  BEGIN '#13#10 +
            '    SELECT name FROM gd_contact WHERE id = NEW.wcompanykey '#13#10 +
            '      INTO NEW.wcompanyname; '#13#10 +
            '  END '#13#10 +
            'END';
          try
            FIBSQL.ExecQuery;
            FTransaction.Commit;
          except
            if FTransaction.InTransaction then
              FTransaction.Rollback;
          end;
          if not FTransaction.InTransaction then
            FTransaction.StartTransaction;

          FIBSQL.SQL.Text :=
            'CREATE TRIGGER gd_bu_people FOR gd_people '#13#10 +
            '  BEFORE UPDATE '#13#10 +
            '  POSITION 0 '#13#10 +
            'AS '#13#10 +
            'BEGIN '#13#10 +
            '  NEW.rank = NULL; '#13#10 +
            '  SELECT g_s_copy(name, 1, 20) FROM wg_position WHERE id = NEW.wpositionkey '#13#10 +
            '    INTO NEW.rank; '#13#10 +
            ' '#13#10 +
            '  IF (NOT NEW.wcompanykey IS NULL) THEN '#13#10 +
            '  BEGIN '#13#10 +
            '    SELECT name FROM gd_contact WHERE id = NEW.wcompanykey '#13#10 +
            '      INTO NEW.wcompanyname; '#13#10 +
            '  END '#13#10 +
            'END';
          try
            FIBSQL.ExecQuery;
            FTransaction.Commit;
          except
            if FTransaction.InTransaction then
              FTransaction.Rollback;
          end;
          if not FTransaction.InTransaction then
            FTransaction.StartTransaction;


          FIBSQL.SQL.Text :=
            'ALTER TRIGGER gd_bi_companyaccount  '#13#10 +
            '  BEFORE INSERT '#13#10 +
            '  POSITION 0 '#13#10 +
            'AS '#13#10 +
            'BEGIN  '#13#10 +
            '  IF (NEW.id IS NULL) THEN '#13#10 +
            '    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0); '#13#10 +
            'END';
          try
            FIBSQL.ExecQuery;
            FTransaction.Commit;
          except
            if FTransaction.InTransaction then
              FTransaction.Rollback;
          end;
          if not FTransaction.InTransaction then
            FTransaction.StartTransaction;


          FIBSQL.SQL.Text :=
            'DROP TRIGGER gd_ai_companyaccount ';
          try
            FIBSQL.ExecQuery;
            FTransaction.Commit;
          except
            if FTransaction.InTransaction then
              FTransaction.Rollback;
          end;
          if not FTransaction.InTransaction then
            FTransaction.StartTransaction;

          FIBSQL.SQL.Text :=
            'DROP TRIGGER gd_au_companyaccount ';
          try
            FIBSQL.ExecQuery;
            FTransaction.Commit;
          except
            if FTransaction.InTransaction then
              FTransaction.Rollback;
          end;
          if not FTransaction.InTransaction then
            FTransaction.StartTransaction;


          FIBSQL.SQL.Text :=
            'ALTER TRIGGER gd_bi_contact  '#13#10 +
            '  BEFORE INSERT '#13#10 +
            '  POSITION 0 '#13#10 +
            'AS '#13#10 +
            'BEGIN  '#13#10 +
            '  IF (NEW.id IS NULL) THEN '#13#10 +
            '    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0); '#13#10 +
            ' '#13#10 +
            '  IF (NEW.name IS NULL) THEN '#13#10 +
            '    NEW.name = ''''; '#13#10 +
            'END ';
          try
            FIBSQL.ExecQuery;
            FTransaction.Commit;
          except
            if FTransaction.InTransaction then
              FTransaction.Rollback;
          end;
          if not FTransaction.InTransaction then
            FTransaction.StartTransaction;


          {
          FIBSQL.SQL.Text :=
            'ALTER TABLE gd_companyaccount DROP ismainaccount ';
          try
            FIBSQL.ExecQuery;
            FTransaction.Commit;
          except
            if FTransaction.InTransaction then
              FTransaction.Rollback;
          end;
          if not FTransaction.InTransaction then
            FTransaction.StartTransaction;
          }

          Log('Начат перенос контактов в подразделения');

          L := TList.Create;
          L2 := TList.Create;

          q.SQL.Text := 'UPDATE gd_contact SET parent = :P WHERE id=:ID ';
          q2.SQL.Text := 'DELETE FROM gd_contactlist WHERE groupkey=:g AND contactkey=:c ';
          FIBSQL.SQL.Text :=
            'SELECT c.id, l.groupkey FROM gd_contactlist l JOIN gd_contact c ON c.id = l.contactkey ' +
            '  JOIN gd_contact g ON g.id = l.groupkey ' +
            '  WHERE c.contacttype = 2 AND c.parent <> l.groupkey AND g.contacttype IN (3, 4, 5) ';
          try
            FIBSQL.ExecQuery;
            while not FIBSQL.Eof do
            begin
              if L.IndexOf(Pointer(FIBSQL.FieldByName('id').AsInteger)) = -1 then
              begin
                L.Add(Pointer(FIBSQL.FieldByName('id').AsInteger));
                L2.Add(Pointer(FIBSQL.FieldByName('groupkey').AsInteger));
              end;

              FIBSQL.Next;
            end;
            FIBSQL.Close;

            for I := 0 to L.Count - 1 do
            begin
              q.ParamByName('p').AsInteger := Integer(L2[I]);
              q.ParamByName('id').AsInteger := Integer(L[I]);
              q.ExecQuery;

              q2.ParamByName('g').AsInteger := Integer(L2[I]);
              q2.ParamByName('c').AsInteger := Integer(L[I]);
              q2.ExecQuery;

              FTransaction.Commit;
              FTransaction.StartTransaction;
            end;
          except
          end;

          L.Free;
          L2.Free;

          try
            FTransaction.Commit;
            Log('Окончен перенос контактов');
          except
            if FTransaction.InTransaction then
              FTransaction.Rollback;
          end;
          if not FTransaction.InTransaction then
            FTransaction.StartTransaction;


          FIBSQL.SQL.Text :=
           'INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex) ' +
           ' VALUES ( ' +
           '   731200, ' +
           '   730000, ' +
           '   ''Должности'', ' +
           '   ''ref_position'', ' +
           '   ''TgdcWgPosition'', ' +
           '   NULL, ' +
           '   0 ' +
           ' ) ';
         try
            FIBSQL.ExecQuery;
            FTransaction.Commit;
          except
            if FTransaction.InTransaction then
              FTransaction.Rollback;
          end;


        except
        end;
      finally
        FIBSQL.Free;
        q.Free;
        q2.Free;
      end;
    except
      on E: Exception do
      begin
        if FTransaction.InTransaction then
          FTransaction.Rollback;
        Log(E.Message);
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;

end.
