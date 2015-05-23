
unit at_AddToSetting;

interface

uses
  DBGrids, gdcBase;

procedure AddToSetting(FromStorage: Boolean; ABranchName, AValueName: String;
  AgdcObject: TgdcBase; BL: TBookmarkList);

implementation

uses
  Windows, DB, IBDatabase, IBSQL, gdcBaseInterface, at_dlgToSetting_unit,
  at_dlgToNamespace_unit, gdcNamespace;

procedure AddToSetting(FromStorage: Boolean; ABranchName, AValueName: String;
  AgdcObject: TgdcBase; BL: TBookmarkList);
begin
  Assert(gdcBaseManager <> nil);
  Assert(gdcBaseManager.Database <> nil);
  Assert(AgdcObject <> nil);
  Assert(AgdcObject.RecordCount > 0);

  if (GetAsyncKeyState(VK_SHIFT) shr 1) = 0 then
  begin
    with TdlgToNamespace.Create(nil) do
    try
      SetupObject(AgdcObject, BL);
      ShowModal;
    finally
      Free;
    end;
  end else
  begin
    with TdlgToSetting.Create(nil) do
    try
      Setup(FromStorage, ABranchName, AValueName, AgdcObject, BL);
      ShowModal;
    finally
      Free;
    end;
  end;
end;

end.
