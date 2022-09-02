// ShlTanya, 27.02.2019, #4135

unit rp_dlgViewReportServer_unit;

interface
                                       
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, IBDatabase, Db, IBCustomDataSet, IBQuery, ActnList,
  {gd_createable_form, }Menus;

type
  TdlgViewReportServer = class(TForm)//class(TCreateableForm)
    lvReportServer: TListView;
    btnOK: TButton;
    btnCancel: TButton;
    ibtrServer: TIBTransaction;
    ActionList1: TActionList;
    actServerParam: TAction;
    PopupMenu1: TPopupMenu;
    actServerParam1: TMenuItem;
    N1: TMenuItem;
    ibdsServer: TIBDataSet;
    actDeleteServer: TAction;
    ibdbGAdmin: TIBDatabase;
    procedure actServerParamExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actDeleteServerExecute(Sender: TObject);
  private
    procedure ShowServer;
    procedure ServerOption(const AnServerName: String);
  public
    destructor Destroy; override;
//    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  dlgViewReportServer: TdlgViewReportServer;

implementation

uses rp_dlgReportOptions_unit, gd_SetDatabase, rp_RemoteManager_unit,
     gd_security_OperationConst, Registry, inst_const;

{$R *.DFM}

{class function TdlgViewReportServer.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(dlgViewReportServer) then
    dlgViewReportServer := TdlgViewReportServer.Create(AnOwner);
  Result := dlgViewReportServer;
end;}

procedure TdlgViewReportServer.ServerOption(const AnServerName: String);
var
  F: TRemoteManager;
begin
  F := TRemoteManager.Create(nil);
  try
    SetDatabase(F, ibtrServer.DefaultDatabase);
    F.ShowReportManager(AnServerName);
  finally
    F.Free;
  end;
end;

procedure TdlgViewReportServer.ShowServer;
var
  L: TListItem;
begin
  if not ibtrServer.InTransaction then
    ibtrServer.StartTransaction;
  try
    lvReportServer.Items.BeginUpdate;
    lvReportServer.Items.Clear;
    ibdsServer.Close;
    ibdsServer.Open;
    while not ibdsServer.Eof do
    begin
      L := lvReportServer.Items.Add;
      L.Caption := ibdsServer.FieldByName('computername').AsString;
      L.Data := TID2Pointer(GetTID(ibdsServer.FieldByName('id')), Name);

      ibdsServer.Next;
    end;
  finally
    lvReportServer.Items.EndUpdate;
    if ibtrServer.InTransaction then
      ibtrServer.Commit;
  end;
end;

procedure TdlgViewReportServer.actServerParamExecute(Sender: TObject);
begin
  if lvReportServer.Selected <> nil then
    ServerOption(lvReportServer.Selected.Caption);
end;

procedure TdlgViewReportServer.FormCreate(Sender: TObject);
var
  Reg: TRegistry;
begin
//  IBLogin.SubSystemKey := GD_SYS_GADMIN;
//  if IBLogin.Login then
  try
    Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_LOCAL_MACHINE;
      if Reg.OpenKeyReadOnly(cGedeminRoot) then
      begin
        if Reg.ValueExists(cGDDatabase) then
          ibdbGAdmin.DatabaseName := Reg.ReadString(cGDDatabase);
        Reg.CloseKey;
      end;
    finally
      Reg.Free;
    end;
    if ibdbGAdmin.DatabaseName = '' then
      raise Exception.Create('Не удалось обнаружить файл базы данных.');
    ibdbGAdmin.Params.Values['user_name'] := 'SYSDBA';
    ibdbGAdmin.Params.Values['lc_ctype'] := 'WIN1251';
    ibdbGAdmin.Connected := True;
    ShowServer;
  except
    on E: Exception do
    begin
      MessageBox(Handle, PChar(E.Message), 'Ошибка', MB_OK or MB_ICONERROR);
      Application.ShowMainForm := False;
      Application.Terminate;
    end;
  end;
end;

procedure TdlgViewReportServer.actDeleteServerExecute(Sender: TObject);
begin
  if lvReportServer.Selected <> nil then
  begin
    ibdsServer.Open;
    if ibdsServer.Locate('id', TID2V(GetTID(lvReportServer.Selected.Data, Name)), []) then
    begin
      ibdsServer.Delete;
      ShowServer;
    end;
    ibdsServer.Close;
  end;
end;

//initialization
//  RegisterClass(TdlgViewReportServer);
destructor TdlgViewReportServer.Destroy;
begin
  {$IFDEF ID64}
  FreeConvertContext(Name);
  {$ENDIF}
  inherited;
end;

end.
