// ShlTanya, 31.01.2019

unit at_AddToSetting;

interface

uses
  DBGrids, gdcBase;

procedure AddToSetting(FromStorage: Boolean; ABranchName, AValueName: String;
  AgdcObject: TgdcBase; BL: TBookmarkList);

implementation

uses
  Windows, Forms, Controls, Classes, SysUtils, DB, IBDatabase, IBSQL,
  gdcBaseInterface, at_dlgToSetting_unit, at_dlgToNamespace_unit, gdcNamespace,
  gdcNamespaceController;

procedure AddToSetting(FromStorage: Boolean; ABranchName, AValueName: String;
  AgdcObject: TgdcBase; BL: TBookmarkList);
var
  OldCursor: TCursor;
  FgdcNamespaceController: TgdcNamespaceController;
  R: Boolean;
  S: String;
begin
  Assert(gdcBaseManager <> nil);
  Assert(gdcBaseManager.Database <> nil);
  Assert(AgdcObject <> nil);
  Assert(AgdcObject.RecordCount > 0);

  if (GetAsyncKeyState(VK_SHIFT) shr 1) = 0 then
  begin
    FgdcNamespaceController := TgdcNamespaceController.Create;
    try
      OldCursor := Screen.Cursor;
      try
        Screen.Cursor := crHourGlass;
        R := FgdcNamespaceController.Setup(AgdcObject, BL);
      finally
        Screen.Cursor := OldCursor;
      end;

      if R then
      begin
        with TdlgToNamespace.Create(nil) do
        try
          SetupController(FgdcNamespaceController);
          if ShowModal = mrOk then
            FgdcNamespaceController.Include;
        finally
          Free;
        end;
      end else
      begin
        if FgdcNamespaceController.MultipleNS then
        begin
          if FgdcNamespaceController.MultipleObjects > 1 then
            S := '������� ������ � ��: '
          else
            S := '������ ������ � ��: ';

          S := S + #13#10 + StringReplace(FgdcNamespaceController.PrevNSName, ', ', #13#10, [rfReplaceAll]);

          MessageBox(0,
            PChar(S + #13#10#13#10 +
            '�������� ��������� �� ���, ����� ������ ������ ������ � ���� �� ���.'),
            '��������',
            MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
        end
        else if FgdcNamespaceController.InconsistentParams then
        begin
          MessageBox(0,
            '��������� �������� ����������, ��� ��� ��������� ���������'#13#10 +
            '�������� ����������� ��� ��� ����������� ������ ��������.',
            '��������',
            MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
        end;
      end;
    finally
      FgdcNamespaceController.Free;
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
