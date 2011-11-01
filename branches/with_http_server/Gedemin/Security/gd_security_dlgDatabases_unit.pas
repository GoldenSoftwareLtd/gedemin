
unit gd_security_dlgDatabases_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ActnList;

type
  Tgd_security_dlgDatabases = class(TForm)
    btnSelect: TButton;
    lv: TListView;
    btnCancel: TButton;
    btnAdd: TButton;
    btnDelete: TButton;
    ActionList: TActionList;
    actAdd: TAction;
    actEdit: TAction;
    actDelete: TAction;
    actCancel: TAction;
    actOk: TAction;
    btnRestore: TButton;
    actRestore: TAction;
    actSave: TAction;
    gbProps: TGroupBox;
    edAlias: TEdit;
    edDatabase: TEdit;
    btnEdit: TButton;
    btnSave: TButton;
    actHelp: TAction;
    btnHelp: TButton;
    btnBrowseDir: TButton;
    actBrowseDir: TAction;
    od: TOpenDialog;
    Label1: TLabel;
    edSearch: TEdit;
    btnSearch: TButton;
    actSearchNext: TAction;
    actFind: TAction;
    actSearch: TAction;
    procedure FormCreate(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure actAddExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure lvChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure actEditExecute(Sender: TObject);
    procedure actEditUpdate(Sender: TObject);
    procedure actDeleteUpdate(Sender: TObject);
    procedure actRestoreExecute(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure actSaveUpdate(Sender: TObject);
    procedure actAddUpdate(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
    procedure actRestoreUpdate(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure actBrowseDirExecute(Sender: TObject);
    procedure actSearchNextExecute(Sender: TObject);
    procedure actFindExecute(Sender: TObject);
    procedure actSearchExecute(Sender: TObject);
    procedure actSearchUpdate(Sender: TObject);
    procedure edSearchChange(Sender: TObject);
    procedure actBrowseDirUpdate(Sender: TObject);
  private
    FAddNew: Boolean;

    function DoSearch(const ANext: Boolean): Boolean;
    procedure SaveDatabasesListToRegistry;
    
  public
    { Public declarations }
  end;

var
  gd_security_dlgDatabases: Tgd_security_dlgDatabases;

implementation

{$R *.DFM}

uses
  Registry,
  gd_directories_const,
  gd_frmRestore_unit, jclStrings
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub, gd_localization
  {$ENDIF}
  ;

procedure Tgd_security_dlgDatabases.FormCreate(Sender: TObject);
var
  Reg: TRegistry;
  I: Integer;
  SL: TStringList;
  LI: TListItem;
  Path: String;
begin
  lv.Items.Clear;
  SL := TStringList.Create;
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := ClientRootRegistryKey;
    if Reg.OpenKey(ClientAccessRegistrySubKey, False) then
    begin
      Reg.GetKeyNames(SL);
      Path := Reg.CurrentPath;
      for I := 0 to SL.Count - 1 do
      begin
        if Reg.OpenKey(SL[I], False) then
        begin
          LI := lv.Items.Add;
          LI.Caption := SL[I];
          LI.SubItems.Text := Reg.ReadString('Database');
          Reg.CloseKey;
          Reg.OpenKey(Path, False);
        end;
      end;
    end;
  finally
    SL.Free;
    Reg.Free;
  end;

  if lv.Items.Count > 0 then
    lv.Items[0].Selected := True;

  {$IFDEF LOCALIZATION}
  LocalizeComponent(Self);
  {$ENDIF}
end;

procedure Tgd_security_dlgDatabases.actOkExecute(Sender: TObject);
begin
  SaveDatabasesListToRegistry;
  ModalResult := mrOk;
end;

procedure Tgd_security_dlgDatabases.actAddExecute(Sender: TObject);
begin
  with lv.Items.Add do
  begin
    Caption := '<Псевдоним>';
    SubItems.Text := '<Сервер>:<Путь к файлу базы данных>';

    Selected := True;
    FAddNew := True;
    // Деактивируем список баз и строку поиска
    lv.Enabled := False;
    edSearch.Enabled := False;

    actEdit.Execute;
  end;
end;

procedure Tgd_security_dlgDatabases.actDeleteExecute(Sender: TObject);
begin
  if Assigned(lv.Selected) then
  begin
    lv.Selected.Free;
    if lv.Items.Count > 0 then
      lv.Items[0].Selected := True;
  end;
end;

procedure Tgd_security_dlgDatabases.lvChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
begin
  if Change = ctState then
  begin
    if not edAlias.ReadOnly then
    begin
      actSave.Execute;
    end;

    edAlias.Text := Item.Caption;
    if Item.SubItems.Count > 0 then
      edDatabase.Text := Item.SubItems[0]
    else
      edDatabase.Text := '';  
  end;
end;

procedure Tgd_security_dlgDatabases.actEditExecute(Sender: TObject);
begin
  if Assigned(lv.Selected) then
  begin
    if edAlias.ReadOnly then
    begin
      // Деактивируем список баз и строку поиска
      lv.Enabled := False;
      edSearch.Enabled := False;
      with lv.Selected do
      begin
        edAlias.ReadOnly := False;
        edAlias.Color := clWindow;

        edDatabase.ReadOnly := False;
        edDatabase.Color := clWindow;

        edAlias.SetFocus;
      end;
    end
    else
    begin
      edAlias.Text := lv.Selected.Caption;
      if lv.Selected.SubItems.Count > 0 then
        edDatabase.Text := lv.Selected.SubItems[0]
      else
        edDatabase.Text := '';

      edAlias.ReadOnly := True;
      edAlias.Color := clBtnFace;

      edDatabase.ReadOnly := True;
      edDatabase.Color := clBtnFace;

      if FAddNew then
      begin
        lv.Selected.Free;
        if lv.Items.Count > 0 then
          lv.Items[0].Selected := True;
        FAddNew := False;
      end;
      // Активируем список баз и строку поиска
      lv.Enabled := True;
      edSearch.Enabled := True;
    end;
  end;
end;

procedure Tgd_security_dlgDatabases.actEditUpdate(Sender: TObject);
begin
  actEdit.Enabled := Assigned(lv.Selected);
  if edAlias.ReadOnly then
    actEdit.Caption := 'Изменить'
  else
    actEdit.Caption := 'Отменить';
end;

procedure Tgd_security_dlgDatabases.actDeleteUpdate(Sender: TObject);
begin
  actDelete.Enabled := Assigned(lv.Selected)
    and edAlias.ReadOnly
    and (lv.Items.Count > 1);
end;

procedure Tgd_security_dlgDatabases.actRestoreExecute(Sender: TObject);
var
  i: integer;
  sDB: string;
begin
  with Tgd_frmRestore.Create(Application) do
  try
    ShowModal;
    if Restored then
    begin
      sDB := edDatabase.Text;
      if edServer.Visible then
        sDB:= edServer.Text + ':' + sDB;
      for i := 0 to lv.Items.Count - 1 do
      begin
        if lv.Items[i].SubItems.Count > 0 then
        begin
          if AnsiUpperCase(lv.Items[i].SubItems[0]) = AnsiUpperCase(sDB) then
          begin
            lv.Selected:= lv.Items[i];
            Exit;
          end;
        end;
      end;
      self.actAdd.Execute;
      self.edAlias.Text:= edDatabase.Text;
      self.edDatabase.Text:= sDB;
      self.actSave.Execute;
    end;
  finally
    Free;
  end;
end;

procedure Tgd_security_dlgDatabases.actSaveExecute(Sender: TObject);
var
  I, J: Integer;
  S: String;
begin
  if Assigned(lv.Selected) then
  begin
    S := StringReplace(Trim(edAlias.Text), '\', '/', [rfReplaceAll]);

    for I := 0 to lv.Items.Count - 1 do
    begin
      if lv.Items[I] <> lv.Selected then
      begin
        if (AnsiCompareText(Trim(edDatabase.Text), Trim(lv.Items[I].SubItems.Text)) = 0)
          or (AnsiCompareText(S, Trim(lv.Items[I].Caption)) = 0) then
        begin
          MessageBox(Handle,
            'Такая база данных уже зарегистрирована в списке!',
            'Внимание',
            MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);

          edAlias.ReadOnly := True;
          edAlias.Color := clBtnFace;

          edDatabase.ReadOnly := True;
          edDatabase.Color := clBtnFace;

          lv.Selected.Free;
          if I >= lv.Items.Count then
            J := lv.Items.Count - 1
          else
            J := I;
          if J >= 0 then
            lv.Items[J].Selected := True;
          // Активируем список баз и строку поиска
          lv.Enabled := True;
          edSearch.Enabled := True;
          Exit;
        end;
      end;
    end;

    with lv.Selected do
    begin
      Caption := S;
      SubItems.Text := edDatabase.Text;

      edAlias.ReadOnly := True;
      edAlias.Color := clBtnFace;

      edDatabase.ReadOnly := True;
      edDatabase.Color := clBtnFace;
    end;
  end;
  // Активируем список баз и строку поиска
  lv.Enabled := True;
  edSearch.Enabled := True;
end;

procedure Tgd_security_dlgDatabases.actSaveUpdate(Sender: TObject);
begin
  actSave.Enabled := Assigned(lv.Selected)
    and (not edAlias.ReadOnly)
    and (AnsiCompareText(edAlias.Text, '<Зарегистрировать>') <> 0)
    and (Trim(edDatabase.Text) > '')
    and (Trim(edAlias.Text) > '');
end;

procedure Tgd_security_dlgDatabases.actAddUpdate(Sender: TObject);
begin
  actAdd.Enabled := edAlias.ReadOnly;
end;

procedure Tgd_security_dlgDatabases.actCancelExecute(Sender: TObject);
begin
  SaveDatabasesListToRegistry;
  ModalResult := mrCancel;
end;

procedure Tgd_security_dlgDatabases.actOkUpdate(Sender: TObject);
begin
  actOk.Enabled := edAlias.ReadOnly and (lv.Items.Count > 0);
end;

procedure Tgd_security_dlgDatabases.actRestoreUpdate(Sender: TObject);
begin
  actRestore.Enabled := edAlias.ReadOnly;
end;

procedure Tgd_security_dlgDatabases.actHelpExecute(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure Tgd_security_dlgDatabases.actBrowseDirExecute(Sender: TObject);
var
  S: String;
begin
  if od.Execute then
  begin
    if Pos('\\', od.FileName) > 0 then // \\server\folder\path...
    begin
      S := StringReplace(od.FileName, '\\', '', []);
      S := StringReplace(S, '\', ':', []);
      S := StringReplace(S, '\', ':\', []);
      if Pos(':\', S) - Pos(':', S) = 2 then
        edDatabase.Text := S
      else
        edDatabase.Text := '<Сервер>:<Путь на сервере>\' + ExtractFileName(od.FileName);
    end else
    begin
      if GetDriveType(PChar(ExtractFileDrive(od.FileName))) = DRIVE_REMOTE then
        edDatabase.Text := '<Сервер>:' + od.FileName
      else
        edDatabase.Text := od.FileName;
    end;

    if (Trim(edAlias.Text) = '') or (Copy(edAlias.Text, 1, 1) = '<') then
    begin
      edAlias.Text := ExtractFileName(od.FileName);
    end;
  end;
end;

procedure Tgd_security_dlgDatabases.actFindExecute(Sender: TObject);
begin
  if ActiveControl <> edSearch then
    ActiveControl := edSearch;
end;

procedure Tgd_security_dlgDatabases.actSearchNextExecute(Sender: TObject);
begin
  DoSearch(True);
end;

procedure Tgd_security_dlgDatabases.actSearchExecute(Sender: TObject);
begin
  DoSearch(False);
end;

procedure Tgd_security_dlgDatabases.actSearchUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (edSearch.Text > '') and (lv.Items.Count > 1);
end;

procedure Tgd_security_dlgDatabases.edSearchChange(Sender: TObject);
begin
  actSearch.Execute;
end;

function Tgd_security_dlgDatabases.DoSearch(const ANext: Boolean): Boolean;
var
  I, J: Integer;
begin
  Result := False;

  if lv.Selected <> nil then
  begin
    I := lv.Selected.Index;
    if ANext then Inc(I);
    if I >= lv.Items.Count then I := 0;
  end else
    I := 0;

  while True do
  begin
    for J := I to lv.Items.Count - 1 do
    begin
      if (StrIPos(edSearch.Text, lv.Items[J].Caption) <> 0) or
        ((lv.Items[J].SubItems.Count > 0) and (StrIPos(edSearch.Text, lv.Items[J].SubItems[0]) <> 0)) then
      begin
        lv.Items[J].Selected := True;
        lv.Items[J].MakeVisible(False);
        edSearch.Color := clWindow;
        Result := True;
        exit;
      end;
    end;

    if I = 0 then
      break
    else
      I := 0;
  end;

  edSearch.Color := $9090FF;
end;

procedure Tgd_security_dlgDatabases.SaveDatabasesListToRegistry;
var
  Reg: TRegistry;
  I: Integer;
  SL: TStringList;
  Path: String;
begin
  SL := TStringList.Create;
  Reg := TRegistry.Create(KEY_ALL_ACCESS);
  try
    Reg.RootKey := ClientRootRegistryKey;
    if Reg.OpenKey(ClientAccessRegistrySubKey, True) then
    begin
      Reg.GetKeyNames(SL);
      for I := 0 to SL.Count - 1 do
      begin
        Reg.DeleteKey(SL[I]);
      end;

      Path := Reg.CurrentPath;
      for I := 0 to lv.Items.Count - 1 do
      begin
        if Reg.OpenKey(lv.Items[I].Caption, True) then
        begin
          if lv.Items[I].SubItems.Count > 0 then
            Reg.WriteString('Database', lv.Items[I].SubItems[0]);
          Reg.CloseKey;
          Reg.OpenKey(Path, False);
        end;
      end;
    end;
  finally
    SL.Free;
    Reg.Free;
  end;
end;

procedure Tgd_security_dlgDatabases.actBrowseDirUpdate(Sender: TObject);
begin
  actBrowseDir.Enabled := not edDatabase.ReadOnly; 
end;

end.
