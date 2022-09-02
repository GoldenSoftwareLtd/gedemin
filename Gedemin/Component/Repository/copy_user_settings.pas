// ShlTanya, 21.02.2019
var
  U: TID;
  US, OldUS: TgsUserStorage;
begin
  U := TgdcUser.SelectObject(
    'Выберите пользователя, настройки которого будут скопированы:',
    'Выбор пользователя'
    );
  if (U <> -1) and (U <> IBLogin.UserKey) then
  begin
    US := TgsUserStorage.Create;
    try
      US.ObjectKey := U;
      OldUS := UserStorage;
      try
        UserStorage := US;
        LoadSettings;
        LoadSettingsAfterCreate;
      finally
        UserStorage := OldUS;
      end;
    finally
      US.Free;
    end;

    if Assigned(IBLogin) then
    begin
      IBLogin.AddEvent('Скопированы настройки пользователя',
        Self.ClassName + ' ' + Self.SubType,
        '',
        -1);
    end;

  end;
end;
