
(*

  Для сохранения в хранилище настроек компонента мы используем путь, который
  строим из имен: компонента, его владельца, владельца владельца и т.д.

  В некоторых моментах при выходе из программы владельца уже может не быть.
  Тогда путь, вычисленный при сохранении будет не равен пути при считывании
  данных из хранилища.

  Избежать этого мы планируем вычисляя путь только один раз и сохраняя
  его в списке. После этого если поступит обращение вычислить путь для
  данного компонента мы будем брать его из списка.

  Context:

  Иногда компонент один, но в зависимости от программного контекста он
  используется по разному. В этом случае это надо как-то различать
  при генерации пути. Мы используем строковый параметр Контекст.
  Значение пустая строка означает, что контекст не используется.

  Контекст используется в методах LoadComponent & SaveComponent in TgsStorage.

*)

unit gsStorage_CompPath;

interface

uses
  Classes, Windows;

{var
  MainForm: TComponent;}

function BuildComponentPath(C: TComponent; const Context: String = ''): String;
{procedure RemoveComponentFromList(C: TComponent);}

implementation

uses
  Forms, SysUtils, gdc_createable_form, jclStrings, gd_strings
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{var
  RegisteredCompPath: TStringList;

procedure RemoveComponentFromList(C: TComponent);
var
  I: Integer;
begin
  if Assigned(RegisteredCompPath) then
  begin
    I := RegisteredCompPath.IndexOfObject(C);
    if I <> -1 then
      RegisteredCompPath.Delete(I);
  end;
end;}

function BuildComponentPath(C: TComponent; const Context: String = ''): String;

  function RemoveLastNum(const Cmpnt: TComponent): String;
  var
    Tail: Integer;
    ST: String;
  begin
    Result := Cmpnt.Name;
    Tail := 0;

    // выкидываем из имени формы подтип
    if Cmpnt is TgdcCreateableForm then
    begin
      ST := RemoveProhibitedSymbols((Cmpnt as TgdcCreateableForm).SubType);

      if ST > '' then
      begin
        Tail := StrIPos(ST, Result) + Length(ST);
      end;
    end;

    if Tail = 0 then
    begin
      Tail := Length(Result);
      while (Tail > 0) and (Result[Tail] <> '_') do
        Dec(Tail);
    end;

    if Tail > 0 then
    begin
      if StrIsDigit(Copy(Result, Tail + 1, 255)) then
        Result := Copy(Result, 1, Tail - 1);
    end;
  end;

  function _BuildComponentPath(C: TComponent): String;
  begin
    // мы пазьбягаем Аплікэйшн, бо калі карыстацца функцыяй
    // з ОнДестрой і ОнКрыэйт форм вынікі будуць розныя
    // пры дэстроі Owner ўжо НІЛ, а не Аплікэйшн
    if (C.Owner = nil) or (C.Owner = Application) or (C is TCustomForm) then
      Result := Format('%s(%s)', [RemoveLastNum(C), C.ClassName])
    else
      Result := _BuildComponentPath(C.Owner) + '\' + Format('%s(%s)', [RemoveLastNum(C), C.ClassName]);
  end;

{var
  S: String;}

begin
  try
    if not Assigned(C) then
      Result := Context
    else begin
      Result := _BuildComponentPath(C);

      if Context > '' then
        Result := Result + '\' + Context;
    end;

    {if not Assigned(C) then
    begin
      Result := Context;
      exit;
    end;

    if Assigned(RegisteredCompPath) and (RegisteredCompPath.IndexOfObject(C) > -1) then
    begin
      Result := RegisteredCompPath[RegisteredCompPath.IndexOfObject(C)];

      // если компонент создан, для него сгенерирован путь, то он
      // заносится в наш список. позже компонент может быть удален
      // но в нашем списке он все равно останется. вынуждены сделать
      // дополнительную проверку и если выяснилось, что в списке
      // хранится путь и адрес удаленного компонента, который (адрес)
      // совпадает с переданным, то удаляем их из списка
      S := _BuildComponentPath(C);

      // пути могут отличаться левыми частями из-за owner-ов, которые
      // в отдельных ситуациях могут быть нулевыми
      if Pos(S, Result) = Length(Result) - Length(S) + 1 then
      begin

        if Context > '' then
          Result := Result + '\' + Context;

        exit;
      end else
        RegisteredCompPath.Delete(RegisteredCompPath.IndexOfObject(C));
    end;

    Result := _BuildComponentPath(C);

    RegisteredCompPath.AddObject(Result, C);

    if Assigned(MainForm) then
      C.FreeNotification(MainForm);

    if Context > '' then
      Result := Result + '\' + Context;}
  except
    on E: Exception do
    begin
      MessageBox(0, PChar('Произошла ошибка при построении пути компоненты.' + E.Message),
       'Внимание', MB_OK or MB_ICONERROR or MB_TOPMOST or MB_TASKMODAL);
      Result := Context;
    end;
  end;
end;

{initialization
  RegisteredCompPath := TStringList.Create;
  RegisteredCompPath.Sorted := True;
  RegisteredCompPath.Duplicates := dupIgnore;

finalization
  FreeAndNil(RegisteredCompPath);}
end.
