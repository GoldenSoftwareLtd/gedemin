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
  // ���� ��� �������� �����-������ ��������, ������ �������� � ��������
  if ParamCount > 0 then
  begin
    AttachToConsole;
    try
      // ������� ���������� � ����������� �����������
      // (Y/N) ���� ��, �� ��������� ��������� ����� �� �����
      //  ��� ��������� �������� ������������
      ConsoleController := TgsFDBConvertController.Create(nil);
      try
        // ������ ������ ���������� � ������ ����������� � ������������
        ConsoleController.SetProcessParameters;
        // ����� ���������� � ����������� ��������
        ConsoleController.ViewPreProcessInformation;
        try
          // ��������� ������������ ��������� ����������
          ConsoleController.CheckProcessParams;
          // �������� ��������������� ��
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
