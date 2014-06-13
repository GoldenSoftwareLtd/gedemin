
(*

  Для сохранения в хранилище настроек компонента мы используем путь, который
  строим из имен: компонента, его владельца, владельца владельца и т.д.

  В некоторых моментах при выходе из программы владельца уже может не быть.
  Тогда путь, вычисленный при сохранении будет не равен пути при считывании
  данных из хранилища.

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

function BuildComponentPath(C: TComponent; const Context: String = ''): String;

implementation

uses
  Forms, SysUtils, gdc_createable_form, jclStrings, gd_strings
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

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

begin
  try
    if not Assigned(C) then
      Result := Context
    else begin
      Result := _BuildComponentPath(C);

      if Context > '' then
        Result := Result + '\' + Context;
    end;
  except
    on E: Exception do
    begin
      MessageBox(0, PChar('Произошла ошибка при построении пути компоненты.' + E.Message),
       'Внимание', MB_OK or MB_ICONERROR or MB_TOPMOST or MB_TASKMODAL);
      Result := Context;
    end;
  end;
end;

end.
