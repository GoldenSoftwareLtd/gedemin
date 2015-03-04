unit rpl_ManagerRegisterDB_unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ActnList, StdCtrls, XPEdit, XPComboBox, ExtCtrls, ComCtrls,
  CheckTreeView, XPTreeView, XPButton, rpl_dmImages_unit, TB2Dock,
  TB2Toolbar, TB2Item, rpl_DBRegistrar_unit;

type
  TfrmManagerRegisterDB = class(TForm)
    Panel1: TPanel;
    XPButton1: TXPButton;
    XPButton2: TXPButton;
    XPButton3: TXPButton;
    Bevel1: TBevel;
    ActionList: TActionList;
    actOk: TAction;
    actCancel: TAction;
    actHelp: TAction;
    actTestConnect: TAction;
    actOpenDBFile: TAction;
    TBDock1: TTBDock;
    Bevel2: TBevel;
    tvDB: TXPTreeView;
    Splitter1: TSplitter;
    Panel2: TPanel;
    Bevel3: TBevel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    Label28: TLabel;
    Label9: TLabel;
    Label7: TLabel;
    cbServerName: TXPComboBox;
    cbProtocol: TXPComboBox;
    cePath: TXPEdit;
    XPButton4: TXPButton;
    eDBDescription: TXPEdit;
    eUser: TXPEdit;
    ePassword: TXPEdit;
    cbCharSet: TXPComboBox;
    eRole: TXPEdit;
    mAddiditionParam: TXPMemo;
    TBToolbar1: TTBToolbar;
    actRegisterDB: TAction;
    actCopyInfo: TAction;
    actUnregisterDB: TAction;
    TBItem1: TTBItem;
    TBItem2: TTBItem;
    TBItem3: TTBItem;
    OpenDialog: TOpenDialog;
    actSave: TAction;
    TBSeparatorItem1: TTBSeparatorItem;
    TBItem4: TTBItem;
    Button5: TXPButton;
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tvDBChange(Sender: TObject; Node: TTreeNode);
    procedure cbServerNameDropDown(Sender: TObject);
    procedure actUnregisterDBUpdate(Sender: TObject);
    procedure actCopyInfoUpdate(Sender: TObject);
    procedure actUnregisterDBExecute(Sender: TObject);
    procedure tvDBChanging(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean);
    procedure tvDBEdited(Sender: TObject; Node: TTreeNode; var S: String);
    procedure actRegisterDBExecute(Sender: TObject);
    procedure actOpenDBFileExecute(Sender: TObject);
    procedure actSaveUpdate(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure actCopyInfoExecute(Sender: TObject);
    procedure actTestConnectExecute(Sender: TObject);
  private
    FDBRegistrar: TDBRegistrar;
    FModified: Boolean;
    FAlias: string;
    FCreateNew: Boolean;

    procedure OnDBregistrarLoad(Sender: TObject);
    procedure SaveDbRegistrar;
    function CheckRegisterInfo: boolean;
  public
  end;

var
  frmManagerRegisterDB: TfrmManagerRegisterDB;

resourcestring
  MSG_DBAliasAlreadyRegistred =
    'Подключение с таким наименованием уже зарегестрировано.'#13#10 +
    'Задайте новое имя подключению.';

implementation

uses Math, main_frmIBReplicator_unit, rpl_ResourceString_unit;

{$R *.dfm}

procedure TfrmManagerRegisterDB.actOkExecute(Sender: TObject);
begin
  actSave.Execute;
  ModalResult := mrOk;
end;

procedure TfrmManagerRegisterDB.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmManagerRegisterDB.FormCreate(Sender: TObject);
var
  S: TStrings;
  I: Integer;
begin
  FDBRegistrar := TDBRegistrar.Create;
  S := TStringList.Create;
  try
    S.Assign(FDBRegistrar.DBAliasList);
    for I := 0 to S.Count - 1 do
    begin
      tvDB.Items.AddChild(nil, S[I]);
    end;
  finally
    S.Free;
  end;
  FDBRegistrar.OnLoad := OnDBregistrarLoad;
  tvDB.Selected:= tvDB.Items.GetFirstNode;
end;

procedure TfrmManagerRegisterDB.FormDestroy(Sender: TObject);
begin
  FDBRegistrar.Free;
end;

procedure TfrmManagerRegisterDB.tvDBChange(Sender: TObject;
  Node: TTreeNode);
begin
  FModified := False;
  FAlias := '';

  if (Node <> nil) and not FCreateNew then
  begin
    FDBRegistrar.Alias := Node.Text;
    FAlias := Node.Text;
  end;
end;

procedure TfrmManagerRegisterDB.OnDBregistrarLoad(Sender: TObject);
begin
  with FDBRegistrar do
  begin
    cbServerName.Text := ServerName;
    cbProtocol.ItemIndex := cbProtocol.Items.IndexOf(Protocol);
    cePath.Text := FileName;
    eDBDescription.Text := Description;
    eUser.Text := User;
    ePassword.Text := Password;
    eRole.Text := Role;
    cbCharSet.ItemIndex := cbCharSet.Items.IndexOf(CharSet);
    mAddiditionParam.Lines.Text := Additional;
  end;
end;

procedure TfrmManagerRegisterDB.cbServerNameDropDown(Sender: TObject);
begin
  TCustomComboBox(Sender).Items.Assign(FDBRegistrar.ServerList);
end;

procedure TfrmManagerRegisterDB.actUnregisterDBUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := tvDB.Selected <> nil;
end;

procedure TfrmManagerRegisterDB.actCopyInfoUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := tvDB.Selected <> nil;
end;

procedure TfrmManagerRegisterDB.actUnregisterDBExecute(Sender: TObject);
begin
  try
    FDBRegistrar.Alias := tvDB.Selected.Text;
  except
  end;  
  FDBRegistrar.Delete;
  tvDB.Selected.Delete;
end;

procedure TfrmManagerRegisterDB.SaveDbRegistrar;
begin
  with FDBRegistrar do
  begin
    DBAlias := eDBDescription.Text; 
    ServerName := cbServerName.Text;
    Protocol := cbProtocol.Text;
    FileName := cePath.Text;
    try
      if eDBDescription.Text = '' then
        eDBDescription.Text := FDBRegistrar.DataBaseName;
    except
    end;
    Description := eDBDescription.Text;
    User := eUser.Text;
    Password := ePassword.Text;
    Role := eRole.Text;
    CharSet := cbCharSet.Text;
    Additional := mAddiditionParam.Lines.Text;
  end;
end;

procedure TfrmManagerRegisterDB.tvDBChanging(Sender: TObject;
  Node: TTreeNode; var AllowChange: Boolean);
var
  I: Integer;
  S: string;
  R: TDBRegistrar;
begin
  if tvDB.Selected <> nil then
  begin
    AllowChange := CheckRegisterInfo;
    if AllowChange then
    begin
      for I := 0 to tvDb.Items.Count - 1 do
      begin
        if eDBDescription.Text = '' then
          eDBDescription.Text := cePath.Text;
        S := eDBDescription.Text;

        if (tvDB.Items[I].Text = S) and (tvDB.Selected <> tvDB.Items[I]) then
        begin
          AllowChange := False;
          ShowMessage(MSG_DBAliasAlreadyRegistred);
          Exit;
        end;
      end;
    end;

    if AllowChange then
    begin
      R := TDBRegistrar.Create;
      try
        R.Alias := FAlias;
        R.Delete;
        FDBRegistrar.SaveToRegister;
        tvDB.Selected.Text := FDBRegistrar.Description;
      finally
        R.Free;
      end;
    end;
  end;  
end;

function TfrmManagerRegisterDB.CheckRegisterInfo: boolean;
begin
  Result := True;
  SaveDbRegistrar;
  if not FDBRegistrar.CheckRegisterInfo then
  begin
    ShowMessage(FDBRegistrar.CheckRegisterInfoErrorMessage);
    Result := False;
  end;
end;

procedure TfrmManagerRegisterDB.tvDBEdited(Sender: TObject;
  Node: TTreeNode; var S: String);
begin
  eDBDescription.Text := S;
end;

procedure TfrmManagerRegisterDB.actRegisterDBExecute(Sender: TObject);
begin
  FCreateNew := True;
  try
    tvDb.Selected := tvDb.Items.AddChild(nil, 'Новое подключение');
    cbServerName.Text := '';
    cbProtocol.ItemIndex := -1;
    cePath.Text := '';
    eDBDescription.Text := '';
    eUser.Text := '';
    ePassword.Text := '';
    eRole.Text := '';
    cbCharSet.ItemIndex := -1;
    mAddiditionParam.Lines.Text:= 'NO_GARBAGE_COLLECT';
  finally
    FCreateNew := False;
  end;
end;

procedure TfrmManagerRegisterDB.actOpenDBFileExecute(Sender: TObject);
begin
  if OpenDialog.Execute then
  begin
    cePath.Text := OpenDialog.FileName;
  end;
end;

procedure TfrmManagerRegisterDB.actSaveUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := tvDB.Selected <> nil;
  Panel2.Enabled := tvDB.Selected <> nil;
end;

procedure TfrmManagerRegisterDB.actSaveExecute(Sender: TObject);
var
  R: TDBRegistrar;
begin
  if CheckRegisterInfo then
  begin
    R := TDBRegistrar.Create;
    try
      R.Alias := FAlias;
      R.Delete;
      FDBRegistrar.SaveToRegister;
      FAlias := FDBRegistrar.Alias;
      tvDB.Selected.Text := FAlias;
    finally
      R.Free;
    end;
  end;
end;

procedure TfrmManagerRegisterDB.actCopyInfoExecute(Sender: TObject);
begin
  FCreateNew := True;
  try
    tvDb.Selected := tvDb.Items.AddChild(nil, eDBDescription.Text + ' Copy');
    eDBDescription.Text := tvDb.Selected.Text;
  finally
    FCreateNew := False;
  end;
end;

procedure TfrmManagerRegisterDB.actTestConnectExecute(Sender: TObject);
begin
  if mainIBReplicator.TestConnect(cbServerName.Text, cbProtocol.Text, cePath.Text, eUser.Text,
      ePassword.Text, cbCharSet.Text, eRole.Text, mAddiditionParam.Lines.Text) then
    Application.MessageBox(PChar(DataBaseTestConnectSucces),
      PChar(ConnectionTest), MB_OK + MB_APPLMODAL + MB_ICONASTERISK);
end;

end.
