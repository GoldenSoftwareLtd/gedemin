unit msf_CorrectBadInvCard;

interface

uses
  sysutils, IBDatabase, gdModify;

  procedure CorrectBadInvCard(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, Dialogs, Controls, Windows;

procedure CorrectBadInvCard(IBDB: TIBDatabase; Log: TModifyLog);
var
  ibsql, ibsqlUpdateParent, ibsqlUpdateField, ibsqlInvCard, ibsqlFeatures, ibsqlFirstDocKey: TIBSQL;
  ibsqlTrigger: TIBSQL;
  ibtr: TIBTransaction;
  i: Integer;
  S: String;
begin

  if MessageBox(0,
    'Проверить корректность складских карточек?',
    'Внимание',
    MB_YESNO or MB_ICONEXCLAMATION or MB_TASKMODAL or MB_TOPMOST) = IDYES then
  begin
    ibtr := TIBTransaction.Create(nil);
    try
      ibtr.DefaultDatabase := IBDB;

      ibsql := TIBSQL.Create(nil);
      ibsqlUpdateParent := TIBSQL.Create(nil);
      ibsqlUpdateField := TIBSQL.Create(nil);
      ibsqlInvCard := TIBSQL.Create(nil);
      ibsqlFeatures := TIBSQL.Create(nil);
      ibsqlFirstDocKey := TIBSQL.Create(nil);
      ibsqlTrigger := TIBSQL.Create(nil);

      try
        ibsql.Transaction := ibtr;

        ibtr.StartTransaction;

        Log('Корректировка триггера INV_CARD');
        ibsqlTrigger.Transaction := ibtr;
        ibsqlTrigger.SQL.Text :=
        'ALTER TRIGGER INV_BU_CARD ' + #13#10 +
        'ACTIVE BEFORE UPDATE POSITION 0 ' + #13#10 +
        'AS ' + #13#10 +
        '  DECLARE VARIABLE firstdocumentkey INTEGER; ' + #13#10 +
        '  DECLARE VARIABLE firstdate DATE; ' + #13#10 +
        'BEGIN ' + #13#10 +
        ' ' + #13#10 +
        '  IF ((OLD.parent <> NEW.parent) OR (OLD.parent IS null and NEW.parent IS NOT NULL)) THEN ' + #13#10 +
        '  BEGIN ' + #13#10 +
        '    SELECT firstdocumentkey, firstdate FROM inv_card ' + #13#10 +
        '    WHERE id = NEW.parent ' + #13#10 +
        '    INTO :firstdocumentkey, :firstdate; ' + #13#10 +
        ' ' + #13#10 +
        '    NEW.firstdocumentkey = :firstdocumentkey; ' + #13#10 +
        '    NEW.firstdate = :firstdate; ' + #13#10 +
        '  END ' + #13#10 +
        ' ' + #13#10 +
        '  IF ((OLD.firstdocumentkey <> NEW.firstdocumentkey) OR ' + #13#10 +
        '       (OLD.firstdate <> NEW.firstdate)) THEN ' + #13#10 +
        '    UPDATE inv_card SET ' + #13#10 +
        '      firstdocumentkey = NEW.firstdocumentkey, ' + #13#10 +
        '      firstdate = NEW.firstdate ' + #13#10 +
        '    WHERE ' + #13#10 +
        '      parent = NEW.id; ' + #13#10 +
        ' ' + #13#10 +
        'END ';
        ibsqlTrigger.ParamCheck := False;
        ibsqlTrigger.ExecQuery;
        Log('Триггер успешно исправлен INV_CARD');

        ibtr.Commit;
        ibtr.StartTransaction;

        Log('Исправление INV_CARD');

        ibsql.SQL.Text :=
        ' select c.id as FromID, c1.id as ToId, m.movementdate, m.movementkey from inv_movement m ' +
        ' join inv_card c ON m.cardkey = c.id and m.credit > 0 ' +
        ' left join inv_movement m1 ON m.movementkey = m1.movementkey and m1.debit > 0 ' +
        ' left join inv_card c1 ON m1.cardkey = c1.id ' +
        ' where c1.id <> c.id AND c1.parent IS NULL ' +
        ' order by m.movementdate, m.movementkey ' ;

        ibsqlFirstDocKey.Transaction := ibtr;
        ibsqlFirstDocKey.SQL.Text := 'SELECT firstdocumentkey FROM inv_card WHERE id = :id';

        ibsqlFeatures.Transaction := ibtr;
        ibsqlFeatures.SQL.Text := 'SELECT * FROM inv_card WHERE firstdocumentkey = :dockey AND ' +
          ' firstdocumentkey = documentkey AND parent IS NULL AND id < :id ';

        ibsqlUpdateParent.Transaction := ibtr;
        ibsqlUpdateParent.SQL.Text := 'update inv_card set parent = :parent WHERE id = :id';

        ibsqlUpdateField.Transaction := ibtr;

        ibsqlInvCard.Transaction := ibtr;
        ibsqlInvCard.SQL.Text := 'SELECT * FROM inv_card WHERE id = :id';

  //      ibtr.StartTransaction;

        ibsql.ExecQuery;
        while not ibsql.EOF do
        begin
          ibsqlUpdateParent.Close;
          ibsqlUpdateParent.ParamByName('parent').AsInteger := ibsql.FieldByName('FromID').AsInteger;
          ibsqlUpdateParent.ParamByName('id').AsInteger := ibsql.FieldByName('ToID').AsInteger;
          ibsqlUpdateParent.ExecQuery;

          ibsqlFirstDocKey.Close;
          ibsqlFirstDocKey.ParamByName('id').AsInteger := ibsql.FieldByName('FromID').AsInteger;
          ibsqlFirstDocKey.ExecQuery;

          ibsqlFeatures.Close;
          ibsqlFeatures.ParamByName('dockey').AsInteger := ibsqlFirstDocKey.FieldByName('firstdocumentkey').AsInteger;
          ibsqlFeatures.ParamByName('id').AsInteger := ibsql.FieldByName('ToID').AsInteger;
          ibsqlFeatures.ExecQuery;

          if ibsqlFeatures.RecordCount > 0 then
          begin

            ibsqlInvCard.Close;
            ibsqlInvCard.ParamByName('id').AsInteger := ibsql.FieldByName('ToID').AsInteger;
            ibsqlInvCard.ExecQuery;


            S := '';

            for i:= 0 to ibsqlInvCard.Current.Count - 1 do
            begin
              if (Pos('USR$', ibsqlInvCard.Fields[i].Name) = 1) and ibsqlInvCard.Fields[i].IsNull and
                  (not ibsqlFeatures.FieldByName(ibsqlInvCard.Fields[i].Name).IsNull and (ibsqlFeatures.FieldByName(ibsqlInvCard.Fields[i].Name).AsString <> ''))
              then
              begin
                if S <> '' then S := S + ', ';
                S := S + ibsqlInvCard.Fields[i].Name + ' = :' + ibsqlInvCard.Fields[i].Name;
              end;
            end;

            if S <> '' then
            begin
              ibsqlUpdateField.Close;
              ibsqlUpdateField.SQL.Text := 'UPDATE inv_card SET ' + S + ' WHERE id = :id';

              for i:= 0 to ibsqlInvCard.Current.Count - 1 do
              begin
                if (Pos('USR$', ibsqlInvCard.Fields[i].Name) = 1) and ibsqlInvCard.Fields[i].IsNull and
                    (not ibsqlFeatures.FieldByName(ibsqlInvCard.Fields[i].Name).IsNull and (ibsqlFeatures.FieldByName(ibsqlInvCard.Fields[i].Name).AsString <> ''))
                then
                begin
                  ibsqlUpdateField.ParamByName(ibsqlInvCard.Fields[i].Name).AsVariant :=
                    ibsqlFeatures.FieldByName(ibsqlInvCard.Fields[i].Name).AsVariant;
                end;
              end;
              ibsqlUpdateField.ParamByName('ID').AsInteger := ibsql.FieldByName('ToID').AsInteger;
              ibsqlUpdateField.ExecQuery;
            end;
          end;

          ibsql.Next;
        end;
        ibtr.Commit;

        Log('Исправление INV_CARD завершено');


      finally
        ibsql.Free;
        ibsqlUpdateParent.Free;
        ibsqlUpdateField.Free;
        ibsqlInvCard.Free;
        ibsqlFeatures.Free;
        ibsqlFirstDocKey.Free;
      end;

    finally
      ibtr.Free;
    end;
  end;
end;

end.
