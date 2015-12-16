var
  q: TIBSQL;
  US, OldUS: TgsUserStorage;
  OldCursor: TCursor;
  OldCFS: TCreateableFormStates;
begin
  Assert(Assigned(gdcBaseManager));
  Assert(Assigned(gdcBaseManager.ReadTransaction));
  Assert(gdcBaseManager.ReadTransaction.Active);

  if MessageBox(Handle,
    'Скопировать визуальные настройки текущей формы всем пользователям?',
    'Внимание',
    MB_YESNO or MB_ICONEXCLAMATION or MB_TASKMODAL) = IDNO then
  begin
    exit;
  end;

  OldCursor := Screen.Cursor;
  q := TIBSQL.Create(nil);
  try
    Screen.Cursor := crHourGlass;
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text := 'SELECT id FROM gd_user WHERE id <> ' +
      IntToStr(IBLogin.UserKey);
    q.ExecQuery;
    while not q.EOF do
    begin
      US := TgsUserStorage.Create;
      try
        US.ObjectKey := q.Fields[0].AsInteger;
        OldUS := UserStorage;
        OldCFS := CreateableFormState;
        Include(FCreateableFormState, cfsDistributeSettings);
        try
          UserStorage := US;
          SaveSettings;
          US.SaveToDatabase;
        finally
          FCreateableFormState := OldCFS;
          UserStorage := OldUS;
        end;
      finally
        US.Free;
      end;
      q.Next;
    end;
  finally
    q.Free;
    Screen.Cursor := OldCursor;
  end;

  if Assigned(IBLogin) then
  begin
    IBLogin.AddEvent('Распространены настройки формы',
      Self.ClassName + ' ' + Self.SubType,
      '',
      -1);
  end;
end;

