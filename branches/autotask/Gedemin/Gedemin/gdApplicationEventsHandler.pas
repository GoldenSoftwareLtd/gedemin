
unit gdApplicationEventsHandler;

interface

uses
  sysutils, Messages, controls;

type
  TgdApplicationEventsHandler = class(TObject)
  public
    function ApplicationEventsHelp(Command: Word; Data: Integer;
      var CallHelp: Boolean): Boolean;
    procedure ApplicationEventsException(Sender: TObject; E: Exception);
    procedure ApplicationEventsShortCut(var Msg: TWMKey;
      var Handled: Boolean);
  end;

implementation

uses
  IB, contnrs, gd_resourcestring, gdHelp_Interface, Forms, Windows, gd_security,
  gd_directories_const, evt_i_base, mtd_i_base
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;


{ TgdApplicationEventsHandler }
function TgdApplicationEventsHandler.ApplicationEventsHelp(Command: Word;
  Data: Integer; var CallHelp: Boolean): Boolean;
begin
  Result := False;
  ShowHelp(Data);
  CallHelp := False;
end;

procedure TgdApplicationEventsHandler.ApplicationEventsShortCut(var Msg: TWMKey;
  var Handled: Boolean);
var
  I: Integer;
  F : TForm;
  ActiveForm: TWinControl;
  L: TObjectList;
begin
  if Msg.CharCode = VK_F6 then
  begin
    L := TObjectList.Create(False);
    try
      for I := 0 to Application.ComponentCount - 1 do
        if (Application.Components[I] is TForm) and
          (TForm(Application.Components[I]).HostDockSite = nil) and
          IsWindowEnabled(TForm(Application.Components[I]).Handle) and
          IsWindowVisible(TForm(Application.Components[I]).Handle) then
      begin
        L.Add(Application.Components[I]);
      end;
      F := nil;
      ActiveForm := Screen.ActiveForm;

      if ActiveForm.HostDockSite <> nil then
      begin
        while (ActiveForm <> nil) and (ActiveForm.Parent <> nil) do
        begin
          ActiveForm := ActiveForm.Parent
        end;
      end;

      if GetAsyncKeyState(VK_CONTROL) shr 1 > 0 then
      begin
        for I := L.Count - 1 downto 0 do
          if L[I] = ActiveForm then
          begin
            if I > 0 then F := L[I - 1] as TForm
              else F := L[L.Count - 1] as TForm;
          end
      end else
      begin
        for I := 0 to L.Count - 1 do
          if L[I] = ActiveForm then
          begin
            if I < L.Count - 1 then F := L[I + 1] as TForm
              else F := L[0] as TForm;
          end;
      end;
      if Assigned(F) then
      begin
        if F.WindowState = wsMinimized then
          ShowWindow(F.Handle, SW_RESTORE)
        else
          F.Show;
        Handled := True;
      end;
    finally
      L.Free;
    end;
  end;
end;

procedure TgdApplicationEventsHandler.ApplicationEventsException(
  Sender: TObject; E: Exception);
begin
  // Если не разрыв соединения с сервером, то выводим ошибку.
  if (E is EIBError)
    and IBLogin.Database.Connected
    and (not IBLogin.Database.TestConnected) then
  begin
    UnEventMacro := True;
    UnMethodMacro := True;

    MessageBox(Application.Handle,
      PChar(Format(
        'Потеряно соединение с базой данных: %s'#13#10#13#10 +
        'Ошибка: %s'#13#10#13#10 +
        'Код ошибки: %d.',
        [IBLogin.LoginParam[ServerNameValue], E.Message, (E as EIBError).IBErrorCode])
      ),
      PChar(sError),
      MB_OK or MB_ICONHAND or MB_TASKMODAL);

    ExitProcess(0);
  end else
    Application.ShowException(E);
end;

end.
