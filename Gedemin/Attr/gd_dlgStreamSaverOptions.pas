unit gd_dlgStreamSaverOptions;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, ActnList, gd_createable_form, gd_ClassList,
  at_frmIncrDatabaseList;

type
  TdlgStreamSaverOptions = class(TCreateableForm)
    pcMain: TPageControl;
    pnlBottom: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    tbsMain: TTabSheet;
    tbsIncrement: TTabSheet;
    gbUseNewStream: TGroupBox;
    chbxUseNewStream: TCheckBox;
    chbxUseNewStreamForSetting: TCheckBox;
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
    rgStreamType: TRadioGroup;
    rgSettingStreamType: TRadioGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actClearRPLRecordsExecute(Sender: TObject);
    procedure actOKExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure chbxUseIncrementSavingClick(Sender: TObject);
    procedure actOKUpdate(Sender: TObject);
  private
    frameDatabases: TfrmIncrDatabaseList;
  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  dlgStreamSaverOptions: TdlgStreamSaverOptions;

implementation

uses
  Storages, gd_security, at_classes, gdcBaseInterface, IBDatabase, IBSQL;

{$R *.DFM}

class function TdlgStreamSaverOptions.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(dlgStreamSaverOptions) then
    dlgStreamSaverOptions := TdlgStreamSaverOptions.Create(AnOwner);
  Result := dlgStreamSaverOptions;
end;

procedure TdlgStreamSaverOptions.FormCreate(Sender: TObject);
begin
  if Assigned(GlobalStorage) then
    with GlobalStorage do
    begin
      chbxUseNewStream.Checked := ReadBoolean('Options', 'UseNewStream', False);
      chbxUseNewStreamForSetting.Checked := ReadBoolean('Options', 'UseNewStreamForSetting', False);
      rgStreamType.ItemIndex := ReadInteger('Options', 'StreamType', 0);
      rgSettingStreamType.ItemIndex := ReadInteger('Options', 'StreamSettingType', 0);
      rgReplaceRecordBehaviuor.ItemIndex := ReadInteger('Options', 'StreamReplaceRecordBehaviuor', 0);
      rgLogType.ItemIndex := ReadInteger('Options', 'StreamLogType', 2);
      chbxUseIncrementSaving.Checked := ReadBoolean('Options', 'UseIncrementSaving', False);
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
      WriteBoolean('Options', 'UseNewStream', chbxUseNewStream.Checked);
      WriteBoolean('Options', 'UseNewStreamForSetting', chbxUseNewStreamForSetting.Checked);
      WriteInteger('Options', 'StreamType', rgStreamType.ItemIndex);
      WriteInteger('Options', 'StreamSettingType', rgSettingStreamType.ItemIndex);
      WriteInteger('Options', 'StreamReplaceRecordBehaviuor', rgReplaceRecordBehaviuor.ItemIndex);
      WriteInteger('Options', 'StreamLogType', rgLogType.ItemIndex);
      WriteBoolean('Options', 'UseIncrementSaving', chbxUseIncrementSaving.Checked);
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

procedure TdlgStreamSaverOptions.actOKUpdate(Sender: TObject);
begin
  rgStreamType.Enabled := chbxUseNewStream.Checked;
  rgSettingStreamType.Enabled := chbxUseNewStreamForSetting.Checked;
end;

initialization
  RegisterClass(TdlgStreamSaverOptions);
finalization
  UnRegisterClass(TdlgStreamSaverOptions);

end.
