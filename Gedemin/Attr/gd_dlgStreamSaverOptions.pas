unit gd_dlgStreamSaverOptions;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, ActnList, gd_createable_form, gd_ClassList,
  at_frmIncrDatabaseList, xCalculatorEdit;

type
  TdlgStreamSaverOptions = class(TCreateableForm)
    pcMain: TPageControl;
    pnlBottom: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    tbsMain: TTabSheet;
    tbsIncrement: TTabSheet;
    gbUseNewStream: TGroupBox;
    rgReplaceRecordBehaviuor: TRadioGroup;
    ActionList1: TActionList;
    actClearRPLRecords: TAction;
    actOK: TAction;
    actCancel: TAction;
    actCreateDatabaseFile: TAction;
    gbBaseList: TGroupBox;
    pnlSSDatabases: TPanel;
    chbxUseIncrementSaving: TCheckBox;
    lblUseIncrementSaving: TLabel;
    rgLogType: TRadioGroup;
    btnCreateDatabaseFile: TButton;
    btnClearRPLRecords: TButton;
    cbDefaultFormat: TComboBox;
    cbSettingFormat: TComboBox;
    lblDefaultFormat: TLabel;
    lblSettingFormat: TLabel;
    tbsWebServer: TTabSheet;
    lblWebServerPort: TLabel;
    btnTestWebServerPort: TButton;
    actTestWevServerPort: TAction;
    eWebServerPort: TxCalculatorEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actClearRPLRecordsExecute(Sender: TObject);
    procedure actOKExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure chbxUseIncrementSavingClick(Sender: TObject);
    procedure actTestWevServerPortExecute(Sender: TObject);
  private
    frameDatabases: TfrmIncrDatabaseList;
  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  dlgStreamSaverOptions: TdlgStreamSaverOptions;

implementation

uses
  Storages, gd_security, at_classes, gdcBaseInterface, IBDatabase, IBSQL,
  gsStreamHelper, IdHTTPServer, IdSocketHandle, gd_WebServerControl_unit;

{$R *.DFM}

class function TdlgStreamSaverOptions.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(dlgStreamSaverOptions) then
    dlgStreamSaverOptions := TdlgStreamSaverOptions.Create(AnOwner);
  Result := dlgStreamSaverOptions;
end;

procedure TdlgStreamSaverOptions.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  // Заполнение выпадающих списков
  for I := 0 to STREAM_FORMAT_COUNT - 1 do
  begin
    cbDefaultFormat.Items.Add(STREAM_FORMATS[I]);
    cbSettingFormat.Items.Add(STREAM_FORMATS[I]);
  end;

  if Assigned(GlobalStorage) then
    with GlobalStorage do
    begin
      cbDefaultFormat.ItemIndex := Integer(GetDefaultStreamFormat(False)) - 1;
      cbSettingFormat.ItemIndex := Integer(GetDefaultStreamFormat(True)) - 1;

      rgReplaceRecordBehaviuor.ItemIndex := ReadInteger('Options', 'StreamReplaceRecordBehaviuor', 0);
      rgLogType.ItemIndex := ReadInteger('Options', 'StreamLogType', 2);
      chbxUseIncrementSaving.Checked := ReadBoolean('Options', 'UseIncrementSaving', False);
      eWebServerPort.Value := ReadInteger('Options', gd_WebServerControl_unit.STORAGE_WEB_SERVER_PORT_VALUE_NAME, gd_WebServerControl_unit.DEFAULT_WEB_SERVER_PORT);
    end;
                                               
  if IBLogin.IsUserAdmin then
  begin
    if Assigned(atDatabase) and Assigned(atDatabase.Relations.ByRelationName('RPL_DATABASE')) then
    begin
      frameDatabases := TfrmIncrDatabaseList.Create(Self);
      frameDatabases.Parent := pnlSSDatabases;
      frameDatabases.Align := alClient;
      frameDatabases.gdcDatabases.Database := gdcBaseManager.Database;
      frameDatabases.gdcDatabases.ReadTransaction := gdcBaseManager.ReadTransaction;
      frameDatabases.gdcDatabases.Open;
      if Assigned(GlobalStorage) then
        GlobalStorage.LoadComponent(frameDatabases.ibgrDatabases, frameDatabases.ibgrDatabases.LoadFromStream);
    end
    else
    begin
      actCreateDatabaseFile.Enabled := False;
      actClearRPLRecords.Enabled := False;
    end;
  end;

  pnlSSDatabases.Enabled := chbxUseIncrementSaving.Checked;
  actClearRPLRecords.Enabled := chbxUseIncrementSaving.Checked;
  actCreateDatabaseFile.Enabled := chbxUseIncrementSaving.Checked;

  pcMain.ActivePage := tbsMain;
  actOK.Enabled := IBLogin.IsUserAdmin;
end;

procedure TdlgStreamSaverOptions.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
  if Assigned(frameDatabases) then
  begin
    frameDatabases.Free;
  end;
end;

procedure TdlgStreamSaverOptions.actClearRPLRecordsExecute(Sender: TObject);
var
  Tr: TIBTransaction;
  IBSQL: TIBSQL;
begin
  if IBLogin.IsUserAdmin then
  begin
    if MessageBox(Self.Handle, 'Удалить записи о переданных данных?',
       'Внимание!', MB_YESNO or MB_ICONQUESTION or MB_TOPMOST or MB_TASKMODAL) = IDYES then
    begin
      Tr := TIBTransaction.Create(nil);
      try
        Tr.DefaultDatabase := gdcBaseManager.Database;
        Tr.StartTransaction;
        try
          IBSQL := TIBSQL.Create(nil);
          try
            IBSQL.Transaction := Tr;
            IBSQL.ParamCheck := False;
            IBSQL.SQL.Text := 'DELETE FROM RPL_RECORD';
            IBSQL.ExecQuery;
            Tr.Commit;
          finally
            IBSQL.Free;
          end;
          MessageBox(Self.Handle, 'Записи удалены.', 'Внимание!', MB_OK or MB_ICONASTERISK or MB_TOPMOST or MB_TASKMODAL);
        except
          on E: Exception do
          begin
            if Tr.InTransaction then
              Tr.Rollback;
          end;
        end;
      finally
        Tr.Free;
      end;
    end;
  end;
end;

procedure TdlgStreamSaverOptions.actOKExecute(Sender: TObject);
begin
  if Assigned(GlobalStorage) then
    with GlobalStorage do
    begin
      if cbDefaultFormat.ItemIndex > -1 then
        WriteInteger('Options', STORAGE_VALUE_STREAM_DEFAULT_FORMAT, cbDefaultFormat.ItemIndex + 1)
      else
        WriteInteger('Options', STORAGE_VALUE_STREAM_DEFAULT_FORMAT, Integer(sttBinaryOld));
      if cbSettingFormat.ItemIndex > -1 then
        WriteInteger('Options', STORAGE_VALUE_STREAM_SETTING_DEFAULT_FORMAT, cbSettingFormat.ItemIndex + 1)
      else
        WriteInteger('Options', STORAGE_VALUE_STREAM_SETTING_DEFAULT_FORMAT, Integer(sttBinaryOld));

      WriteInteger('Options', 'StreamReplaceRecordBehaviuor', rgReplaceRecordBehaviuor.ItemIndex);
      WriteInteger('Options', 'StreamLogType', rgLogType.ItemIndex);
      WriteBoolean('Options', 'UseIncrementSaving', chbxUseIncrementSaving.Checked);
      WriteInteger('Options', gd_WebServerControl_unit.STORAGE_WEB_SERVER_PORT_VALUE_NAME, Round(eWebServerPort.Value));
    end;

  if Assigned(frameDatabases) then
  begin
    if Assigned(GlobalStorage) and (frameDatabases.ibgrDatabases.SettingsModified) then
      GlobalStorage.SaveComponent(frameDatabases.ibgrDatabases, frameDatabases.ibgrDatabases.SaveToStream);
  end;

  Self.Close;
  ModalResult := mrOk;
end;

procedure TdlgStreamSaverOptions.actCancelExecute(Sender: TObject);
begin
  Self.Close;
  ModalResult := mrCancel;
end;

procedure TdlgStreamSaverOptions.chbxUseIncrementSavingClick(Sender: TObject);
begin
  pnlSSDatabases.Enabled := chbxUseIncrementSaving.Checked;
  actClearRPLRecords.Enabled := chbxUseIncrementSaving.Checked;
  actCreateDatabaseFile.Enabled := chbxUseIncrementSaving.Checked;
end;

procedure TdlgStreamSaverOptions.actTestWevServerPortExecute(
  Sender: TObject);
var
  PortNumber: Integer;
  HttpServer: TIdHTTPServer;
  Binding : TIdSocketHandle;
begin
  PortNumber := Round(eWebServerPort.Value);
  eWebServerPort.Value := PortNumber;

  if (PortNumber >= 1024) and (PortNumber <= 65535) then
  begin
    HttpServer := TIdHTTPServer.Create(nil);
    try
      HttpServer.ServerSoftware := 'GedeminHttpServer';
      // Привязка к порту
      HttpServer.Bindings.Clear;
      Binding := HttpServer.Bindings.Add;
      Binding.Port := PortNumber;
      Binding.IP := '127.0.0.1';
      try
        HttpServer.Active := True;
        // При успешном занятии порта, сообщим пользователю и выключим сервер
        Application.MessageBox(PChar('Порт ' + IntToStr(PortNumber) + ' свободен для работы веб-сервера.'), 'HTTP сервер', MB_OK + MB_APPLMODAL + MB_ICONINFORMATION);
        HttpServer.Active := False;
      except
        on E: Exception do
        begin
          eWebServerPort.Text := '';
          Application.MessageBox(PChar('При проверке порта возникла ошибка:'#13#10 + E.Message), 'Ошибка HTTP сервера', MB_OK + MB_APPLMODAL + MB_ICONEXCLAMATION);
        end;
      end;
    finally
      FreeAndNil(HttpServer);
    end;
  end
  else
  begin
    eWebServerPort.Text := '';
    Application.MessageBox(PChar('Можно указать только порт в границах 1024-65535.'), 'Ошибка HTTP сервера', MB_OK + MB_APPLMODAL + MB_ICONEXCLAMATION);
  end;
end;

initialization
  RegisterClass(TdlgStreamSaverOptions);
finalization
  UnRegisterClass(TdlgStreamSaverOptions);

end.
