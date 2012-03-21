
unit st_frmMain_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_createable_form, TB2Item, StdCtrls, ExtCtrls, ComCtrls, TB2Dock,
  TB2Toolbar, dmImages_unit, ActnList, gsStorage, Menus, st_dlgFind_unit,
  gd_KeyAssoc;

type
  Tst_frmMain = class(TCreateableForm)
    sb: TStatusBar;
    TBDock1: TTBDock;
    TBToolbar1: TTBToolbar;
    TBItem1: TTBItem;
    cb: TComboBox;
    TBControlItem1: TTBControlItem;
    ActionList: TActionList;
    actSaveStorage: TAction;
    actNewFolder: TAction;
    pmMain: TPopupMenu;
    actNewFolder1: TMenuItem;
    actDeleteFolder: TAction;
    actDeleteFolder1: TMenuItem;
    pmDetail: TPopupMenu;
    actNewValue: TAction;
    actNewInteger1: TMenuItem;
    actDeleteValue: TAction;
    actDeleteValue1: TMenuItem;
    actSearch: TAction;
    actSearch1: TMenuItem;
    actEditValue: TAction;
    actEditValue1: TMenuItem;
    actSaveToFile: TAction;
    actLoadFromFile: TAction;
    SaveDialog: TSaveDialog;
    OpenDialog: TOpenDialog;
    actRefresh: TAction;
    actRefresh1: TMenuItem;
    N1: TMenuItem;
    actSaveToFile1: TMenuItem;
    actLoadFromFile1: TMenuItem;
    actShowFolderProp: TAction;
    actShowFolderProp1: TMenuItem;
    actAddFolderToSetting: TAction;
    N2: TMenuItem;
    N3: TMenuItem;
    actAddFolderToSetting1: TMenuItem;
    actEditFolder: TAction;
    actEditFolder1: TMenuItem;
    TBItem2: TTBItem;
    TBItem3: TTBItem;
    TBItem4: TTBItem;
    TBItem5: TTBItem;
    TBItem6: TTBItem;
    TBItem7: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    TBSeparatorItem2: TTBSeparatorItem;
    TBSeparatorItem3: TTBSeparatorItem;
    TBItem8: TTBItem;
    TBItem9: TTBItem;
    TBSeparatorItem4: TTBSeparatorItem;
    TBItem10: TTBItem;
    TBItem11: TTBItem;
    pnlWorkArea: TPanel;
    Panel1: TPanel;
    splVert: TSplitter;
    tv: TTreeView;
    Panel2: TPanel;
    lv: TListView;
    TBDock3: TTBDock;
    TBDock2: TTBDock;
    pnSearch: TPanel;
    lvSearch: TListView;
    splSearch: TSplitter;
    actAddValueToSetting: TAction;
    spValue1: TMenuItem;
    actAddValueToSetting1: TMenuItem;
    TBToolbar2: TTBToolbar;
    TBSubmenuItem1: TTBSubmenuItem;
    TBSubmenuItem2: TTBSubmenuItem;
    TBItem13: TTBItem;
    TBItem14: TTBItem;
    TBItem15: TTBItem;
    TBItem16: TTBItem;
    TBItem17: TTBItem;
    TBSeparatorItem5: TTBSeparatorItem;
    TBSeparatorItem6: TTBSeparatorItem;
    TBItem18: TTBItem;
    TBItem19: TTBItem;
    TBItem20: TTBItem;
    TBSeparatorItem7: TTBSeparatorItem;
    TBItem21: TTBItem;
    TBItem22: TTBItem;
    TBItem23: TTBItem;
    TBItem24: TTBItem;
    TBItem25: TTBItem;
    TBSeparatorItem9: TTBSeparatorItem;
    TBItem26: TTBItem;
    actRenameValue: TAction;
    N4: TMenuItem;
    TBItem12: TTBItem;
    actHelp: TAction;
    TBSubmenuItem3: TTBSubmenuItem;
    TBItem27: TTBItem;
    TBItem28: TTBItem;
    TBSeparatorItem8: TTBSeparatorItem;
    actShowInSett: TAction;
    procedure FormCreate(Sender: TObject);
    procedure tvChange(Sender: TObject; Node: TTreeNode);
    procedure cbChange(Sender: TObject);
    procedure actSaveStorageUpdate(Sender: TObject);
    procedure actSaveStorageExecute(Sender: TObject);
    procedure actNewFolderUpdate(Sender: TObject);
    procedure actNewFolderExecute(Sender: TObject);
    procedure tvEdited(Sender: TObject; Node: TTreeNode; var S: String);
    procedure actDeleteFolderUpdate(Sender: TObject);
    procedure actDeleteFolderExecute(Sender: TObject);
    procedure actNewValueExecute(Sender: TObject);
    procedure actNewValueUpdate(Sender: TObject);
    procedure actDeleteValueUpdate(Sender: TObject);
    procedure actDeleteValueExecute(Sender: TObject);
    procedure actSearchExecute(Sender: TObject);
    procedure lvSearchClick(Sender: TObject);
    procedure actEditValueUpdate(Sender: TObject);
    procedure actEditValueExecute(Sender: TObject);
    procedure actSaveToFileExecute(Sender: TObject);
    procedure actLoadFromFileExecute(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
    procedure actSaveToFileUpdate(Sender: TObject);
    procedure actShowFolderPropUpdate(Sender: TObject);
    procedure actShowFolderPropExecute(Sender: TObject);
    procedure actAddFolderToSettingExecute(Sender: TObject);
    procedure actAddFolderToSettingUpdate(Sender: TObject);
    procedure actEditFolderUpdate(Sender: TObject);
    procedure actEditFolderExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lvKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvDblClick(Sender: TObject);
    procedure actAddValueToSettingExecute(Sender: TObject);
    procedure actAddValueToSettingUpdate(Sender: TObject);
    procedure tvCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure FormActivate(Sender: TObject);
    procedure actRenameValueUpdate(Sender: TObject);
    procedure actRenameValueExecute(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure actShowInSettExecute(Sender: TObject);
    procedure actShowInSettUpdate(Sender: TObject);
    procedure lvCustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure lvCustomDrawSubItem(Sender: TCustomListView; Item: TListItem;
      SubItem: Integer; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure actLoadFromFileUpdate(Sender: TObject);
    procedure tvEditing(Sender: TObject; Node: TTreeNode;
      var AllowEdit: Boolean);

  private
    L: TList;
    CurrentStorage: TgsStorage;
    InSett: TgdKeyArray;
    dlgFind: Tst_dlgFind;

    procedure LoadTreeView(const ID: Integer);

  protected
    procedure DoCreate; override;
    procedure DoDestroy; override;
    procedure Activate; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure SaveSettings; override;
    procedure LoadSettings; override;
    procedure LoadSettingsAfterCreate; override;
  end;

var
  st_frmMain: Tst_frmMain;

implementation


{$R *.DFM}

uses
  Storages,               gdcUser,           gd_security,
  st_dlgEditValue_unit,   dlgEditDFM_unit,   gdcStorage,
  at_dlgToSetting_unit,   gsDesktopManager,  gd_directories_const,
  gsStorage_CompPath,     IBSQL,             gdcBaseInterface,
  gdcStorage_Types
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

constructor Tst_frmMain.Create(AnOwner: TComponent);
begin
  inherited;
  L := TList.Create;
end;

destructor Tst_frmMain.Destroy;
var
  I: Integer;
  S: PString;
begin
  for I := 0 to L.Count - 1 do
  begin
    S := L[I];
    Dispose(S);
  end;
  L.Free;

  if Assigned(CurrentStorage)
    and (CurrentStorage <> GlobalStorage)
    and (CurrentStorage <> UserStorage)
    and (CurrentStorage <> DesktopManager.Storage)
    and (CurrentStorage <> CompanyStorage) then
  begin
    CurrentStorage.Free;
  end;

  InSett.Free;

  inherited;
end;

procedure Tst_frmMain.FormCreate(Sender: TObject);
var
  U: TgdcUser;
begin
  actShowInSett.Execute;

  cb.Clear;
  U := TgdcUser.Create(Self);
  try
    U.SubSet := 'All';
    U.Open;
    while not U.EOF do
    begin
      cb.Items.AddObject(U.ObjectName, Pointer(U.ID));
      U.Next;
    end;
  finally
    U.Free;
  end;

  cb.Items.AddObject('<GLOBAL>', Pointer(-1000));
  cb.Items.AddObject('<COMPANY>', Pointer(-2000));
  cb.Items.AddObject('<DESKTOP>', Pointer(-3000));

  cb.ItemIndex := cb.Items.IndexOf('<GLOBAL>');
  LoadTreeView(-1000);
end;

procedure Tst_frmMain.LoadTreeView(const ID: Integer);
var
  N: TTreeNode;
  S: String;
  F: Boolean;
  I: Integer;
  RF: TgsStorageFolder;
begin
  if Assigned(CurrentStorage)
    and (CurrentStorage <> GlobalStorage)
    and (CurrentStorage <> UserStorage)
    and (CurrentStorage <> DesktopManager.Storage)
    and (CurrentStorage <> CompanyStorage) then
  begin
    CurrentStorage.Free;
  end;

  case ID of
    -1000: CurrentStorage := GlobalStorage;
    -2000: CurrentStorage := CompanyStorage;
    -3000: CurrentStorage := DesktopManager.Storage;
  else
    if ID = IBLogin.UserKey then
      CurrentStorage := UserStorage
    else begin
      CurrentStorage := TgsUserStorage.Create;
      TgsUserStorage(CurrentStorage).ObjectKey := ID;
    end;
  end;

  if (tv.Selected <> nil) and (tv.Selected.Data <> nil) then
    S := PString(tv.Selected.Data)^
  else
    S := '';

  tv.Items.BeginUpdate;
  try
    tv.Items.Clear;
    RF := CurrentStorage.OpenFolder('\', False, False);
    try
      N := tv.Items.Add(nil, RF.Name);
    finally
      CurrentStorage.CloseFolder(RF, False);
    end;
    CurrentStorage.BuildTreeView(N, L);
    if tv.Items.Count > 0 then
    begin
      F := False;
      if S > '' then
      begin
        for I := 0 to tv.Items.Count - 1 do
        begin
          if tv.Items[I].Data <> nil then
          begin
            if S = PString(tv.Items[I].Data)^ then
            begin
              tv.Items[I].Selected := True;
              F := True;
              break;
            end;
          end;
        end;
      end;
      if not F then
        tv.Items[0].Selected := True;
    end;
  finally
    tv.Items.EndUpdate;
  end;

  pnSearch.Visible := False;
  splSearch.Visible := False;
end;

procedure Tst_frmMain.tvChange(Sender: TObject; Node: TTreeNode);
var
  F: TgsStorageFolder;
  S: PString;
  I: Integer;
  L: TListItem;
  N: TTreeNode;
begin
  lv.Items.BeginUpdate;
  try
    lv.Items.Clear;

    S := Node.Data;
    F := CurrentStorage.OpenFolder(S^, False);
    if Assigned(F) then
      try
        for I := 0 to F.ValuesCount - 1 do
        begin
          L := lv.Items.Add;
          L.Caption := F.Values[I].Name;
          L.SubItems.Add(F.Values[I].GetTypeName);
          if not (F.Values[I] is TgsStreamValue) then
            L.SubItems.Add(F.Values[I].AsString)
          else
          begin
            if F.Values[I].DataSize > 0 then
              L.SubItems.Add(Format('%d (размер, байт)', [F.Values[I].DataSize]))
            else
              L.SubItems.Add('<размер не определен>');
          end;
          L.SubItems.Add(FormatDateTime('dd.mm.yy hh:nn:ss', F.Values[I].Modified));
        end;

        sb.SimpleText := S^;
      finally
        CurrentStorage.CloseFolder(F);
      end
    else begin
      N := Node.getNextSibling;
      if (N <> nil) and (N <> Node) then
        N.Selected := True;
      Node.Free;
      sb.SimpleText := '';
    end;

    if lv.Items.Count > 0 then
      lv.Items[0].Selected := True;
  finally
    lv.Items.EndUpdate;
  end;
end;

procedure Tst_frmMain.cbChange(Sender: TObject);
begin
  LoadTreeView(Integer(cb.Items.Objects[cb.ItemIndex]));
end;

procedure Tst_frmMain.actSaveStorageUpdate(Sender: TObject);
begin
  actSaveStorage.Enabled := (CurrentStorage is TgsIBStorage)
    and CurrentStorage.IsModified;
end;

procedure Tst_frmMain.actSaveStorageExecute(Sender: TObject);
begin
  (CurrentStorage as TgsIBStorage).SaveToDatabase;
  actRefresh.Execute;
end;

procedure Tst_frmMain.actNewFolderUpdate(Sender: TObject);
begin
  actNewFolder.Enabled := tv.Selected <> nil;
end;

procedure Tst_frmMain.actNewFolderExecute(Sender: TObject);
var
  S: PString;
  F: TgsStorageFolder;
  NewName: String;
  I: Integer;
begin
  S := tv.Selected.Data;
  NewName := IncludeTrailingBackslash(S^) + 'New folder';
  I := 0;
  while CurrentStorage.FolderExists(NewName) do
  begin
    Inc(I);
    NewName := IncludeTrailingBackslash(S^) + 'New folder ' + IntToStr(I);
  end;
  F := CurrentStorage.OpenFolder(NewName, True);
  try
    New(S);
    L.Add(S);
    S^ := F.Path;
    if I = 0 then
      tv.Items.AddChildObject(tv.Selected, 'New folder', S).Selected := True
    else
      tv.Items.AddChildObject(tv.Selected, 'New folder ' + IntToStr(I), S).Selected := True;
  finally
    CurrentStorage.CloseFolder(F);
  end;
end;

procedure Tst_frmMain.tvEdited(Sender: TObject; Node: TTreeNode;
  var S: String);

  procedure AdjustStr;
  var
    I, K: Integer;
  begin
    K := 0;
    for I := Length(S) downto 1 do
    begin
      if (S[I] = ']') or (S[I] = '[') then
        K := I;
    end;
    if K > 0 then
      S := Trim(Copy(S, 1, K - 1));
  end;

var
  F: TgsStorageFolder;
  P: PString;
begin
  AdjustStr;
  P := Node.Data;
  F := CurrentStorage.OpenFolder(P^, False);
  try
    if F <> nil then
    begin
      F.Name := S;
      P^ := F.Path;
    end;  
  finally
    CurrentStorage.CloseFolder(F);
  end;
end;

procedure Tst_frmMain.actDeleteFolderUpdate(Sender: TObject);
begin
  actDeleteFolder.Enabled := (tv.Selected <> nil) and (tv.Selected.Parent <> nil);
end;

procedure Tst_frmMain.actDeleteFolderExecute(Sender: TObject);
var
  S: PString;
  N: TTreeNode;
begin
  S := tv.Selected.Data;

  if MessageBox(Handle,
    PChar('Удалить папку "' + S^ + '"?'),
    'Внимание',
    MB_YESNO or MB_ICONEXCLAMATION) = IDNO then
  begin
    exit;
  end;

  CurrentStorage.DeleteFolder(S^);
  N := tv.Selected.GetPrevSibling;
  if (N <> nil) and (N <> tv.Selected) then
  begin
    tv.Selected.Free;
    N.Selected := True;
  end else
    tv.Selected.Free;
end;

procedure Tst_frmMain.actNewValueExecute(Sender: TObject);
var
  S: PString;
  I: TListItem;
  St: TStringStream;
begin
  S := tv.Selected.Data;
  with Tst_dlgEditValue.Create(Self) do
  try
    while ShowModal = mrOk do
    begin
      if CurrentStorage.ValueExists(S^, edName.Text) then
      begin
        MessageBox(Self.Handle,
          'Значение с таким именем уже существует.',
          'Внимание',
          MB_OK or MB_ICONHAND);
        continue;
      end;

      try
        case rg.ItemIndex of
          0: CurrentStorage.WriteInteger(S^, edName.Text, StrToInt(edValue.Text));
          1: CurrentStorage.WriteDateTime(S^, edName.Text, StrToDateTime(edValue.Text));
          3: CurrentStorage.WriteCurrency(S^, edName.Text, StrToCurr(edValue.Text));
          4: CurrentStorage.WriteBoolean(S^, edName.Text, Boolean(StrToInt(edValue.Text)));
        else
          if Length(edValue.Text) <= cStorageMaxStrLen then
            CurrentStorage.WriteString(S^, edName.Text, edValue.Text)
          else begin
            St := TStringStream.Create(edValue.Text);
            try
              CurrentStorage.WriteStream(S^, edName.Text, St);
            finally
              St.Free;
            end;
          end
        end;

        I := lv.Items.Add;
        I.Caption := edName.Text;
        I.SubItems.Add('');
        I.SubItems.Add(edValue.Text);
        I.SubItems.Add(FormatDateTime('dd.mm.yy hh:nn:ss', Now));
        I.Focused := True;
      except
        on E: Exception do
        begin
          Application.ShowException(E);
          continue;
        end;
      end;

      break;
    end;
  finally
    Free;
  end;
end;

procedure Tst_frmMain.actNewValueUpdate(Sender: TObject);
begin
  actNewValue.Enabled := tv.Selected <> nil;
end;

procedure Tst_frmMain.actDeleteValueUpdate(Sender: TObject);
begin
  actDeleteValue.Enabled := lv.Selected <> nil;
end;

procedure Tst_frmMain.actDeleteValueExecute(Sender: TObject);
var
  S: PString;
  F: TgsStorageFolder;
begin
  if MessageBox(Handle,
    'Удалить выбранный параметр?',
    'Внимание',
    MB_YESNO or MB_ICONQUESTION) = IDYES then
  begin
    S := tv.Selected.Data;
    F := CurrentStorage.OpenFolder(S^, False);
    try
      if F <> nil then
      begin
        F.DeleteValue(lv.Selected.Caption);
        lv.Selected.Free;
      end;  
    finally
      CurrentStorage.CloseFolder(F);
    end;
  end;
end;

procedure Tst_frmMain.actSearchExecute(Sender: TObject);
const
  SearchValue: String = '';
var
  gstSearchOptions: TgstSearchOptions;
  I, J: Integer;
  L: TListItem;
  FSearchList: TStringList;
begin
  FSearchList := TStringList.Create;
  try
    if dlgFind = nil then
      dlgFind := Tst_dlgFind.Create(Self);
    with dlgFind do
    begin
      ActiveControl := edFindText;
      edFindText.Text := SearchValue;

      if ShowModal = mrOk then
      begin
        SearchValue := edFindText.Text;

        lvSearch.Items.Clear;

        gstSearchOptions := [];
        if cbFolder.Checked then
          Include(gstSearchOptions, gstsoFolder);

        if cbValue.Checked then
          Include(gstSearchOptions, gstsoValue);

        if cbData.Checked then
          Include(gstSearchOptions, gstsoData);

        if cbDate.Checked then
          CurrentStorage.Find(FSearchList, edFindText.Text, gstSearchOptions, xdeFrom.Date, xdeTo.Date)
        else
          CurrentStorage.Find(FSearchList, edFindText.Text, gstSearchOptions);

        if Assigned(InSett) and (rgSetting.ItemIndex > 0) then
        begin
          for I := FSearchList.Count - 1 downto 0 do
          begin
            if FSearchList.Objects[I] is TgsStorageItem then
            begin
              J := InSett.IndexOf(TgsStorageItem(FSearchList.Objects[I]).ID);

              if ((rgSetting.ItemIndex = 1) and (J = -1))
                or ((rgSetting.ItemIndex = 2) and (J > -1)) then
              begin
                FSearchList.Delete(I);
              end;
            end;  
          end;
        end;

        if FSearchList.Count = 0 then
          MessageBox(Self.Handle, 'Не найдено ни одного значения', 'Внимание!',
            MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL)
        else
        begin
          pnSearch.Visible := True;
          splSearch.Visible := True;

          for I := 0 to FSearchList.Count - 1 do
          begin
            L := lvSearch.Items.Add;
            L.Caption := FSearchList[I];
          end;
        end;
      end;
    end;
  finally
    FSearchList.Free;
  end;
end;

procedure Tst_frmMain.lvSearchClick(Sender: TObject);
var
  I, J: Integer;
  FN, VN: String;
begin
  if lvSearch.Selected <> nil then
  begin
    FN := lvSearch.Selected.Caption;
    if CurrentStorage.FolderExists(FN) then
    begin
      VN := '';
    end else
    begin
      I := Length(FN);
      while (I > 0) and (FN[I] <> '\') do
        Dec(I);
      VN := Copy(FN, I + 1, 1024);
      SetLength(FN, I - 1);
    end;

    for I := 0 to tv.Items.Count - 1 do
      if FN = PString(tv.Items[I].Data)^ then
      begin
        tv.Items[I].Selected := True;

        if VN > '' then
          for J := 0 to lv.Items.Count - 1 do
            if VN = lv.Items[J].Caption then
            begin
              lv.Items[J].Selected := True;
              lv.Items[J].MakeVisible(False);
            end;

        break;
      end;
  end;
end;

procedure Tst_frmMain.actEditValueUpdate(Sender: TObject);
begin
  actEditValue.Enabled := (lv.Selected <> nil) and (tv.Selected <> nil);
end;

procedure Tst_frmMain.actEditValueExecute(Sender: TObject);
var
  S: String;
  F: TgsStorageFolder;
  V: TgsStorageValue;
  StIn, StOut: TStringStream;
  Sign: String;
begin
  F := CurrentStorage.OpenFolder(PString(tv.Selected.Data)^, False);

  if F <> nil then
  try
    V := F.ValueByName(lv.Selected.Caption);

    if V = nil then
      exit;

    if V is TgsStreamValue then
    begin
      { TODO : Плохо, что имена папок прописаны непосредственно в тексте программы, а не сделаны константами! }
      if Assigned(F.Parent) and ((F.Parent.Name = 'DFM') or (F.Parent.Name = 'NewForm')) then
      begin
        StIn := TStringStream.Create(V.AsString);
        StOut := TStringStream.Create('');
        try
          SetLength(Sign, 3);
          StIn.Read(Sign[1], 3);
          if Sign = 'TPF' then
          begin
            StIn.Position := 0;
            ObjectBinaryToText(StIn, StOut);
            S := StOut.DataString;
          end else
          begin
            S := StIn.DataString;
          end;

        finally
          StIn.Free;
          StOut.Free;
        end;

        if EditDFM(F.Name, S) then
        begin
          StIn := TStringStream.Create(S);
          StOut := TStringStream.Create('');
          try
            ObjectTextToBinary(StIn, StOut);
            V.AsString := StOut.DataString;
            lv.Selected.SubItems[2] := FormatDateTime('dd.mm.yy hh:nn:ss', V.Modified);
          finally
            StIn.Free;
            StOut.Free;
          end;
        end;
      end else
      begin
        S := V.AsString;
        if EditDFM(F.Name, S) then
        begin
          V.AsString := S;
          lv.Selected.SubItems[2] := FormatDateTime('dd.mm.yy hh:nn:ss', V.Modified);
        end;
      end;
    end else
      with Tst_dlgEditValue.Create(Self) do
      try
        edValue.Text := V.AsString;
        edID.Text := IntToStr(V.ID);
        edName.Text := V.Name;

        edName.Enabled := False;
        rg.Enabled := False;

        while ShowModal = mrOk do
        begin
          try
            V.AsString := edValue.Text;
            lv.Selected.SubItems[1] := edValue.Text;
            lv.Selected.SubItems[2] := FormatDateTime('dd.mm.yy hh:nn:ss', V.Modified);
          except
            on E: Exception do
            begin
              Application.ShowException(E);
              continue;
            end;
          end;

          break;
        end;
      finally
        Free;
      end;
  finally
    CurrentStorage.CloseFolder(F);
  end;
end;

procedure Tst_frmMain.actSaveToFileExecute(Sender: TObject);
var
  F: TgsStorageFolder;
  FF: TgsStorageFileFormat;
begin
  if SaveDialog.Execute then
  begin
    if AnsiCompareText(ExtractFileExt(SaveDialog.FileName), '.stt') = 0 then
      FF := sffText
    else if AnsiCompareText(ExtractFileExt(SaveDialog.FileName), '.stb') = 0 then
      FF := sffBinary
    else
    begin
      MessageBox(Handle,
        'Указано неверное расширение имени файла.'#13#10 +
        'Корректные значения:'#13#10 +
        '  .stt (сохранение данных хранилища в текстовом виде)' +
        '  .std (сохранение данных хранилища в двоичном виде)' +
        'Данные не были сохранены.',
        'Ошибка',
        MB_OK or MB_ICONEXCLAMATION);
      exit;
    end;

    if tv.Selected.Parent = nil then
    begin
      CurrentStorage.SaveToFile(SaveDialog.FileName, FF);
    end else
    begin
      F := CurrentStorage.OpenFolder(PString(tv.Selected.Data)^, False);
      try
        if F <> nil then
          F.SaveToFile(SaveDialog.FileName, FF);
      finally
        CurrentStorage.CloseFolder(F);
      end;
    end;
  end;
end;

procedure Tst_frmMain.actLoadFromFileExecute(Sender: TObject);
begin
  if OpenDialog.Execute then
  begin
    if AnsiCompareText(ExtractFileExt(OpenDialog.FileName), '.stt') = 0 then
      CurrentStorage.LoadFromFile(OpenDialog.FileName, sffText)
    else if AnsiCompareText(ExtractFileExt(OpenDialog.FileName), '.stb') = 0 then
      CurrentStorage.LoadFromFile(OpenDialog.FileName, sffBinary)
    else
      MessageBox(Handle,
        'Указано неверное расширение имени файла.'#13#10 +
        'Корректные значения:'#13#10 +
        '  .stt (загрузка данных хранилища в текстовом виде)' +
        '  .std (загрузка данных хранилища в двоичном виде)' +
        'Данные не были сохранены.',
        'Ошибка',
        MB_OK or MB_ICONEXCLAMATION);

    actRefresh.Execute;
  end;
end;

procedure Tst_frmMain.actRefreshExecute(Sender: TObject);
begin
  actShowInSett.Execute;
  LoadTreeView(Integer(cb.Items.Objects[cb.ItemIndex]));
end;

procedure Tst_frmMain.actSaveToFileUpdate(Sender: TObject);
begin
  actSaveToFile.Enabled := (tv.Selected <> nil)
    and Assigned(CurrentStorage);
end;

procedure Tst_frmMain.actShowFolderPropUpdate(Sender: TObject);
begin
  actShowFolderProp.Enabled := tv.Selected <> nil;
end;

procedure Tst_frmMain.actShowFolderPropExecute(Sender: TObject);
var
  F: TgsStorageFolder;
begin
  F := CurrentStorage.OpenFolder(PString(tv.Selected.Data)^);
  try
    if F <> nil then
      F.ShowPropDialog;
  finally
    CurrentStorage.CloseFolder(F);
  end;
end;

procedure Tst_frmMain.actAddFolderToSettingExecute(Sender: TObject);
var
  F: TgsStorageFolder;
  Obj: TgdcStorageFolder;
begin
  F := CurrentStorage.OpenFolder(PString(tv.Selected.Data)^);
  if F <> nil then
  try
    if F.ID = -1 then
      (F.Storage as TgsIBStorage).SaveToDatabase;

    Obj := TgdcStorageFolder.Create(nil);
    try
      Obj.SubSet := 'ByID';
      Obj.ID := F.ID;
      Obj.Open;

      AddToSetting(False, '', '', Obj, nil);
    finally
      Obj.Free;
    end;

    actShowInSett.Execute;
  finally
    CurrentStorage.CloseFolder(F);
  end;
end;

procedure Tst_frmMain.actAddFolderToSettingUpdate(Sender: TObject);
begin
  actAddFolderToSetting.Enabled := (tv.Selected <> nil)
    and Assigned(IBLogin)
    and ((CurrentStorage = GlobalStorage) or
      ((CurrentStorage = UserStorage) and (IBLogin.IsIBUserAdmin)));
end;

procedure Tst_frmMain.actEditFolderUpdate(Sender: TObject);
begin
  actEditFolder.Enabled := (tv.Selected <> nil) and (tv.Selected.Parent <> nil);
end;

procedure Tst_frmMain.actEditFolderExecute(Sender: TObject);
begin
  tv.Selected.EditText;
end;

procedure Tst_frmMain.Activate;
begin
  inherited;
  if Assigned(_OnActivateForm) then
    _OnActivateForm(Self);
end;

procedure Tst_frmMain.DoCreate;
begin
  inherited;
  if Assigned(_OnCreateForm) then
    _OnCreateForm(Self);
end;

procedure Tst_frmMain.DoDestroy;
begin
  if Assigned(_OnDestroyForm) then
    _OnDestroyForm(Self);
  inherited;
end;

procedure Tst_frmMain.LoadSettings;
begin
  inherited;
  //TBRegLoadPositions(Self, HKEY_CURRENT_USER, ClientRootRegistrySubKey + 'TB\' + Name);
end;

procedure Tst_frmMain.SaveSettings;
begin
  inherited;

  //TBRegSavePositions(Self, HKEY_CURRENT_USER, ClientRootRegistrySubKey + 'TB\' + Name);

  if Assigned(UserStorage) then
  begin
    UserStorage.WriteInteger(BuildComponentPath(tv), 'W', tv.Width);
    UserStorage.WriteInteger(BuildComponentPath(pnSearch), 'H', pnSearch.Height);
  end;
end;

procedure Tst_frmMain.LoadSettingsAfterCreate;
begin
  inherited;

  if Assigned(UserStorage) then
  begin
    tv.Width := UserStorage.ReadInteger(BuildComponentPath(tv), 'W', tv.Width);
    pnSearch.Height := UserStorage.ReadInteger(BuildComponentPath(pnSearch), 'H', pnSearch.Height);
  end;
end;

procedure Tst_frmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure Tst_frmMain.lvKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    actEditValue.Execute;
    Key := 0;
  end;
end;

procedure Tst_frmMain.lvDblClick(Sender: TObject);
begin
  actEditValue.Execute;
end;

procedure Tst_frmMain.actAddValueToSettingExecute(Sender: TObject);
var
  F: TgsStorageFolder;
  V: TgsStorageValue;
  Obj: TgdcStorageValue;
begin
  F := CurrentStorage.OpenFolder(PString(tv.Selected.Data)^);
  if F <> nil then
  try
    V := F.ValueByName(lv.Selected.Caption);

    if V = nil then
      exit;

    if V.ID = -1 then
      (V.Storage as TgsIBStorage).SaveToDatabase;

    Obj := TgdcStorageValue.Create(nil);
    try
      Obj.SubSet := 'ByID';
      Obj.ID := V.ID;
      Obj.Open;

      AddToSetting(False, '', '', Obj, nil);
    finally
      Obj.Free;
    end;

    actShowInSett.Execute;
  finally
    CurrentStorage.CloseFolder(F);
  end;
end;

procedure Tst_frmMain.actAddValueToSettingUpdate(Sender: TObject);
begin
  actAddValueToSetting.Enabled := (lv.Selected <> nil)
    and Assigned(IBLogin)
    and ((CurrentStorage = GlobalStorage) or
      ((CurrentStorage = UserStorage) and (IBLogin.IsIBUserAdmin)));
end;

procedure Tst_frmMain.tvCustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
var
  F: TgsStorageFolder;
begin
  if Assigned(CurrentStorage) then
  begin
    F := CurrentStorage.OpenFolder(PString(Node.Data)^);
    try
      if F <> nil then
      begin
        if (F.FoldersCount > 0) or (F.ValuesCount > 0) then
          Sender.Canvas.Font.Style := Sender.Canvas.Font.Style + [fsBold]
        else
          Sender.Canvas.Font.Style := Sender.Canvas.Font.Style - [fsBold];

        if Assigned(InSett) and (InSett.IndexOf(F.ID) <> -1) then
        begin
          if not (cdsSelected in State) then
            Sender.Canvas.Font.Color := clBlue
          else
            Sender.Canvas.Font.Color := $FFBBBB;
        end;

        if F.Changed then
          Sender.Canvas.Font.Style := [fsBold, fsUnderline]
        else
          Sender.Canvas.Font.Style := [fsBold];
      end;
    finally
      CurrentStorage.CloseFolder(F);
    end;
  end;
end;

procedure Tst_frmMain.FormActivate(Sender: TObject);
begin
  if Assigned(IBLogin) and (not IBLogin.IsUserAdmin) then
  begin
    MessageBox(0,
      'У вас нет прав на открытие данной формы.',
      'Внимание',
      MB_OK or MB_ICONHAND or MB_TASKMODAL);
    Close;
  end;
end;

procedure Tst_frmMain.actRenameValueUpdate(Sender: TObject);
begin
  actRenameValue.Enabled := lv.Selected <> nil;
end;

procedure Tst_frmMain.actRenameValueExecute(Sender: TObject);
var
  N: String;
  F: TgsStorageFolder;
  V: TgsStorageValue;
begin
  F := CurrentStorage.OpenFolder(PString(tv.Selected.Data)^);
  try
    if F <> nil then
    begin
      V := F.ValueByName(lv.Selected.Caption);
      if Assigned(V) then
      begin
        N := V.Name;
        if InputQuery('Параметр', 'Наименование:', N) then
        begin
          if V.Name <> N then
          begin
            V.Name := N;
            lv.Selected.Caption := N;
          end
        end;
      end;
    end;
  finally
    CurrentStorage.CloseFolder(F);
  end;
end;

procedure Tst_frmMain.actHelpExecute(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure Tst_frmMain.actShowInSettExecute(Sender: TObject);
var
  q: TIBSQL;
begin
  if InSett = nil then
    InSett := TgdKeyArray.Create
  else
    InSett.Clear;

  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text :=
      'SELECT r.id FROM gd_ruid r JOIN at_settingpos p ON ' +
      '  p.xid = r.id AND p.dbid = r.dbid ' +
      'WHERE p.category = ''GD_STORAGE_DATA'' ';
    q.ExecQuery;

    while not q.EOF do
    begin
      InSett.Add(q.Fields[0].AsInteger, True);
      q.Next;
    end;

    tv.Invalidate;
    lv.Invalidate;
  finally
    q.Free;
  end;
end;

procedure Tst_frmMain.actShowInSettUpdate(Sender: TObject);
begin
  actShowInSett.Enabled := Assigned(gdcBaseManager)
    and Assigned(gdcBaseManager.ReadTransaction);
end;

procedure Tst_frmMain.lvCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
var
  F: TgsStorageFolder;
  V: TgsStorageValue;
begin
  DefaultDraw := True;

  if InSett = nil then
    exit;

  if tv.Selected = nil then
    exit;

  F := CurrentStorage.OpenFolder(PString(tv.Selected.Data)^);
  if F <> nil then
  try
    V := F.ValueByName(Item.Caption);
    if V <> nil then
    begin
      if InSett.IndexOf(V.ID) <> -1 then
        Sender.Canvas.Font.Color := clBlue;

      if V.Changed then
        Sender.Canvas.Font.Style := [fsUnderline]
      else
        Sender.Canvas.Font.Style := [];
    end;
  finally
    CurrentStorage.CloseFolder(F);
  end;
end;

procedure Tst_frmMain.lvCustomDrawSubItem(Sender: TCustomListView;
  Item: TListItem; SubItem: Integer; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  DefaultDraw := True;
end;

procedure Tst_frmMain.actLoadFromFileUpdate(Sender: TObject);
begin
  actLoadFromFile.Enabled := Assigned(CurrentStorage);
end;

procedure Tst_frmMain.tvEditing(Sender: TObject; Node: TTreeNode;
  var AllowEdit: Boolean);
begin
  AllowEdit := (Node <> nil) and (Node.Parent <> nil);
end;

initialization
  RegisterClass(Tst_frmMain);

finalization
  UnRegisterClass(Tst_frmMain);
end.
