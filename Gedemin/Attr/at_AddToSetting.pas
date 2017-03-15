
unit at_AddToSetting;

interface

uses
  DBGrids, gdcBase, ContNrs;

procedure AddToSetting(FromStorage: Boolean; ABranchName, AValueName: String;
  AgdcObject: TgdcBase; BL: TBookmarkList; AgdcObjectList: TObjectList = nil);

implementation

uses
  Windows, Forms, Controls, DB, IBDatabase, IBSQL, gdcBaseInterface, at_dlgToSetting_unit,
  at_dlgToNamespace_unit, gdcNamespace, gdcNamespaceController;

procedure AddToSetting(FromStorage: Boolean; ABranchName, AValueName: String;
  AgdcObject: TgdcBase; BL: TBookmarkList; AgdcObjectList: TObjectList = nil);
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
        R := FgdcNamespaceController.Setup(AgdcObject, BL, AgdcObjectList);
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
            S := 'Объекты входят в ПИ: '
          else
            S := 'Объект входит в ПИ: ';

          MessageBox(0,
            PChar(S + FgdcNamespaceController.PrevNSName + #13#10#13#10 +
            'Измените указанные ПИ так, чтобы объект входил только в одно из них.'),
            'Внимание',
            MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
        end
        else if FgdcNamespaceController.InconsistentParams then
        begin
          MessageBox(0,
            'Групповая операция невозможна, так как параметры выбранных'#13#10 +
            'объектов различаются или они подчиняются разным объектам.',
            'Внимание',
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
