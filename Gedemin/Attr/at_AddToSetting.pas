
unit at_AddToSetting;

interface

uses
  DBGrids, gdcBase;

procedure AddToSetting(FromStorage: Boolean; ABranchName, AValueName: String;
  AgdcObject: TgdcBase; BL: TBookmarkList);

implementation

uses
  Windows, IBDatabase, IBSQL, gdcBaseInterface, at_dlgToSetting_unit,
  at_dlgToNamespace_unit, gdcNamespace;

procedure AddToSetting(FromStorage: Boolean; ABranchName, AValueName: String;
  AgdcObject: TgdcBase; BL: TBookmarkList);
begin
  Assert(gdcBaseManager <> nil);
  Assert(gdcBaseManager.Database <> nil);
  Assert(AgdcObject <> nil);
  Assert(AgdcObject.RecordCount > 0);

  if MessageBox(0,
    'Добавить в настройку? (Нет -- добавление в пространство имен)',
    'Внимание',
    MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES then
  begin
    with TdlgToSetting.Create(nil) do
    try
      Setup(FromStorage, ABranchName, AValueName, AgdcObject, BL);
      ShowModal;
    finally
      Free;
    end;
  end else
  begin
    with TdlgToNamespace.Create(nil) do
    try
      SetupParams(AgdcObject, BL);
      ShowModal;
    finally
      Free;
    end;
  end;
end;

end.
