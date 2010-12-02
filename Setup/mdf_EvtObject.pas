unit mdf_EvtObject;

interface

uses
  sysutils, IBDatabase, classes, gdModify;

  procedure ClearEvtObject(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL;

procedure UpdateGDFunction(slON: TStringList; Tr: TIBTransaction);
var
  q1, q2: TIBSQL;
  s: string;
  sl, slIDs: TStringList;
  iNew, iOld: integer;
begin
  q1:= TIBSQL.Create(nil);
  q2:= TIBSQL.Create(nil);
  sl:= TStringList.Create;
  slIDs:= TStringList.Create;
  slIDs.Assign(slON);
  try
    q1.Transaction:= tr;
    q2.Transaction:= tr;
    q2.SQL.Text:=
      'SELECT id, editiondate FROM gd_function WHERE modulecode = :new AND name = :fname';

    while slIDs.Count > 0 do begin
      iOld:= StrToInt(slIDs.Names[0]);
      iNew:= StrToInt(slIDs.Values[slIDs.Names[0]]);
      q1.Close;
      q1.SQL.Text:=
        'SELECT id, editiondate, name FROM gd_function WHERE modulecode = :old';
      q1.ParamByName('old').AsInteger:= iOld;
      q1.ExecQuery;
      s:= '';
      while not q1.Eof do begin
        q2.Close;
        q2.ParamByName('new').AsInteger:= iNew;
        q2.ParamByName('fname').AsString:= q1.FieldByName('name').AsString;
        q2.ExecQuery;
        if not q2.Eof then begin
          if s <> '' then
            s:= s + ', ';
          if q2.FieldByName('editiondate').AsDateTime < q1.FieldByName('editiondate').AsDateTime then begin
            sl.Add(IntToStr(q2.FieldByName('id').AsInteger) + '=' + IntToStr(q1.FieldByName('id').AsInteger));
            s:= s + IntToStr(q2.FieldByName('id').AsInteger);
          end
          else begin
            sl.Add(IntToStr(q1.FieldByName('id').AsInteger) + '=' + IntToStr(q2.FieldByName('id').AsInteger));
            s:= s + IntToStr(q1.FieldByName('id').AsInteger)
          end;
        end;
        q1.Next;
      end;

      if s <> '' then begin
        while sl.COunt > 0 do begin
          q1.Close;
          q1.SQL.Text:=
            'UPDATE evt_objectevent SET functionkey = :new WHERE functionkey = :old';
          q1.ParamByName('new').AsInteger:= StrToInt(sl.Values[sl.Names[0]]);
          q1.ParamByName('old').AsInteger:= StrToInt(sl.Names[0]);
          try
            q1.ExecQuery;
          finally
            sl.Delete(0);
          end;
        end;
        q1.Close;
        q1.SQL.Text:=
          'DELETE FROM gd_function WHERE id IN (' + s + ')';
        q1.ExecQuery;
      end;

      q1.Close;
      q1.SQL.Text:=
        'UPDATE gd_function SET modulecode = :new WHERE modulecode = :old';
      q1.ParamByName('new').AsInteger:= iNew;
      q1.ParamByName('old').AsInteger:= iOld;
      q1.ExecQuery;

      slIDs.Delete(0);
    end;
  finally
    q1.Free;
    q2.Free;
    slIDs.Free;
    sl.Free;
  end;
end;

procedure UpdateEVTObjectEvent(slON: TStringList; Tr: TIBTransaction);
var
  q1, q2: TIBSQL;
  s: string;
  slIDs: TStringList;
  iNew, iOld: integer;
begin
  q1:= TIBSQL.Create(nil);
  q2:= TIBSQL.Create(nil);
  slIDs:= TStringList.Create;
  slIDs.Assign(slON);
  try
    q1.Transaction:= tr;
    q2.Transaction:= tr;
    q2.SQL.Text:=
      'SELECT id, editiondate FROM evt_objectevent WHERE objectkey = :new AND eventname = :ename';

    while slIDs.Count > 0 do begin
      iOld:= StrToInt(slIDs.Names[0]);
      iNew:= StrToInt(slIDs.Values[slIDs.Names[0]]);
      q1.Close;
      q1.SQL.Text:=
        'SELECT id, editiondate, eventname FROM evt_objectevent WHERE objectkey = :old';
      q1.ParamByName('old').AsInteger:= iOld;
      q1.ExecQuery;
      s:= '';
      while not q1.Eof do begin
        q2.Close;
        q2.ParamByName('new').AsInteger:= iNew;
        q2.ParamByName('ename').AsString:= q1.FieldByName('eventname').AsString;
        q2.ExecQuery;
        if not q2.Eof then begin
          if s <> '' then
            s:= s + ', ';
          if q2.FieldByName('editiondate').AsDateTime < q1.FieldByName('editiondate').AsDateTime then
            s:= s + IntToStr(q2.FieldByName('id').AsInteger)
          else
            s:= s + IntToStr(q1.FieldByName('id').AsInteger)
        end;
        q1.Next;
      end;

      if s <> '' then begin
        q1.Close;
        q1.SQL.Text:=
          'DELETE FROM evt_objectevent WHERE id IN (' + s + ')';
        q1.ExecQuery;
      end;

      q1.Close;
      q1.SQL.Text:=
        'UPDATE evt_objectevent SET objectkey = :new WHERE objectkey = :old';
      q1.ParamByName('new').AsInteger:= iNew;
      q1.ParamByName('old').AsInteger:= iOld;
      q1.ExecQuery;

      slIDs.Delete(0);
    end;
  finally
    q1.Free;
    q2.Free;
    slIDs.Free;
  end;
end;

procedure UpdateEVTObject(slON: TStringList; Tr: TIBTransaction);
var
  q: TIBSQL;
  slIDs: TStringList;
  iNew, iOld: integer;
  s: string;
begin
  q:= TIBSQL.Create(nil);
  slIDs:= TStringList.Create;
  slIDs.Assign(slON);
  try
    q.Transaction:= tr;
    while slIDs.Count > 0 do begin
      iOld:= StrToInt(slIDs.Names[0]);
      if s <> '' then
        s:= s + ', ';
      s:= s + IntToStr(iOld);

      slIDs.Delete(0);
    end;

    slIDs.Assign(slON);

    q.SQL.Text:=
      'UPDATE evt_object SET parent = :new WHERE parent = :old';
    if s <> '' then
      q.SQL.Text:= q.SQL.Text +
        ' AND id NOT IN (' + s + ')';

    while slIDs.Count > 0 do begin
      iOld:= StrToInt(slIDs.Names[0]);
      iNew:= StrToInt(slIDs.Values[slIDs.Names[0]]);
      q.Close;
      q.ParamByName('new').AsInteger:= iNew;
      q.ParamByName('old').AsInteger:= iOld;
      q.ExecQuery;

      slIDs.Delete(0);
    end;

    if s <> '' then begin
      q.Close;
      q.SQL.Text:=
        'DELETE FROM evt_object WHERE id IN (' + s + ')';
      q.ExecQuery;
    end;
  finally
    q.Free;
    slIDs.Free;
  end;
end;

procedure ClearEvtObject(IBDB: TIBDatabase; Log: TModifyLog);
var
  tr: TIBTransaction;
  q: TIBSQL;
  sl, slON: TStringList;
  iNew, iOld: integer;
begin
  Log('Очистка таблицы EVT_OBJECT');
  q:= TIBSQL.Create(nil);
  tr:= TIBTransaction.Create(nil);
  sl:= TStringList.Create;
  slON:= TStringList.Create;
  try
    tr.DefaultDatabase := IBDB;
    q.Transaction:= tr;

    tr.StartTransaction;

    q.SQL.Text:=
      'SELECT classname, objectname, subtype, parentindex, Count(*)         '#13#10 +
      'FROM evt_object                                                      '#13#10 +
      'GROUP BY classname, objectname, subtype, parentindex                 '#13#10 +
      'HAVING Count(*) > 1                                                  ';
    q.ExecQuery;
    while not q.Eof do begin
      sl.AddObject(q.Fields[1].AsString + '=' + q.Fields[2].AsString, pointer(q.Fields[3].AsInteger));
      q.Next;
    end;
    if sl.Count > 0 then begin
      q.Close;
      q.SQL.Text:=
        'SELECT id FROM evt_object WHERE objectname = :on AND subtype = :st AND parentindex = :pi';
      while sl.Count > 0 do begin
        q.Close;
        q.ParamByName('on').AsString:= sl.Names[0];
        q.ParamByName('st').AsString:= sl.Values[sl.Names[0]];
        q.ParamByName('pi').AsInteger:= integer(sl.Objects[0]);
        try
          q.ExecQuery;
          iNew:= q.Fields[0].AsInteger;
          q.Next;
          while not q.Eof do begin
            iOld:= q.Fields[0].AsInteger;
            slON.Add(IntToStr(iOld) + '=' + IntToStr(iNew));

            q.Next;
          end;
        except
          on E: Exception do begin
            Log('Ошибка: ' + E.Message);
            tr.RollBack;
            Break;
          end;
        end;
        sl.Delete(0);
      end;

      try
        UpdateGDFunction(slON, tr);
        UpdateEVTObjectEvent(slON, tr);
        UpdateEVTObject(slON, tr);
      except
        on E: Exception do begin
          Log('Ошибка: ' + E.Message);
          tr.RollBack;
        end;
      end;

      if tr.InTransaction then
        tr.Commit;
    end;

    if not tr.InTransaction then
      tr.StartTransaction;

    q.Close;
    q.SQL.Text:=
      'SELECT classname, subtype, Count(*)         '#13#10 +
      'FROM evt_object                             '#13#10 +
      'WHERE classname <> ''''                     '#13#10 +
      'GROUP BY classname, subtype                 '#13#10 +
      'HAVING Count(*) > 1                         ';
    q.ExecQuery;
    while not q.Eof do begin
      sl.Add(q.Fields[0].AsString + '=' + q.Fields[1].AsString);
      q.Next;
    end;
    if sl.Count > 0 then begin
      q.Close;
      q.SQL.Text:=
        'SELECT id FROM evt_object WHERE classname = :cn AND subtype = :st';
      while sl.Count > 0 do begin
        q.Close;
        q.ParamByName('cn').AsString:= sl.Names[0];
        q.ParamByName('st').AsString:= sl.Values[sl.Names[0]];
        try
          q.ExecQuery;
          iNew:= q.Fields[0].AsInteger;
          q.Next;
          while not q.Eof do begin
            iOld:= q.Fields[0].AsInteger;
            slON.Add(IntToStr(iOld) + '=' + IntToStr(iNew));

            q.Next;
          end;
        except
          on E: Exception do begin
            Log('Ошибка: ' + E.Message);
            tr.RollBack;
            Break;
          end;
        end;
        sl.Delete(0);
      end;

      try
        UpdateGDFunction(slON, tr);
        UpdateEVTObjectEvent(slON, tr);
        UpdateEVTObject(slON, tr);
      except
        on E: Exception do begin
          Log('Ошибка: ' + E.Message);
          tr.RollBack;
        end;
      end;

      if tr.InTransaction then
        tr.Commit;
    end;
  finally
    tr.Free;
    q.Free;
    sl.Free;
    slON.Free;
  end;
end;

end.
