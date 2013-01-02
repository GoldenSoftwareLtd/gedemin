
unit at_AddToSetting;

interface

uses
  DBGrids, gdcBase;

procedure AddToSetting(FromStorage: Boolean; ABranchName, AValueName: String;
  AgdcObject: TgdcBase; BL: TBookmarkList);

implementation

uses
  at_dlgToSetting_unit;

procedure AddToSetting(FromStorage: Boolean; ABranchName, AValueName: String;
  AgdcObject: TgdcBase; BL: TBookmarkList);
begin
  with TdlgToSetting.Create(nil) do
  try
    Setup(FromStorage, ABranchName, AValueName, AgdcObject, BL);
    ShowModal;
  finally
    Free;
  end;
end;

end.
