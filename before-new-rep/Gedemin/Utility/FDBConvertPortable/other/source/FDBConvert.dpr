program FDBConvert;

uses
  Forms,
  SysUtils,
  gsFDBConvertFormView_unit in 'gsFDBConvertFormView_unit.pas' {gsFDBConvertFormView},
  gsFDBConvert_unit in 'gsFDBConvert_unit.pas',
  gsFDBConvertController_unit in 'gsFDBConvertController_unit.pas',
  gsFDBConvertConsoleView_unit in 'gsFDBConvertConsoleView_unit.pas',
  gs_frmFunctionEdit_unit in 'gs_frmFunctionEdit_unit.pas' {frmFunctionEdit},
  gsFDBConvertLocalization_unit in 'gsFDBConvertLocalization_unit.pas',
  dmImages_unit;

{$R *.RES}

var
  ConsoleController: TgsFDBConvertController;

begin
  // Если нам передали какой-нибудь параметр, значит работаем с консолью
  if ParamCount > 0 then
  begin
    AttachToConsole;
    try
      // выводим информацию о предстоящей конвертации
      // (Y/N) если ДА, то проверяем свободное место на диске
      //  при недостаче сообщаем пользователю
      ConsoleController := TgsFDBConvertController.Create(nil);
      try
        // Разбор строки параметров и запрос недостающих у пользователя
        ConsoleController.SetProcessParameters;
        // Вывод информации о предстоящем процессе
        ConsoleController.ViewPreProcessInformation;
        try
          // Проверить правильность введенных параметров
          ConsoleController.CheckProcessParams;
          // Провести конвертирование БД
          ConsoleController.DoConvertDatabase;
        except
          on E: Exception do
            ConsoleController.ViewInterruptedProcessInformation(E.Message);
        end;
      finally
        ConsoleController.Free;
      end;

      GetInputString(GetLocalizedString(lsPressAnyButton));
    finally
      ReleaseConsole;
    end;
  end
  else
  begin
    Application.Initialize;
    Application.Title := 'FDBConvert';
  Application.CreateForm(TgsFDBConvertFormView, gsFDBConvertFormView);
    Application.CreateForm(TdmImages, dmImages);
    Application.Run;
  end;
end.
