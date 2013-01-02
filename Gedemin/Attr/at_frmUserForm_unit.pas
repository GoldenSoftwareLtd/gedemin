//

{ generic form }

unit at_frmUserForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_createable_form, ComCtrls,  dmImages_unit, ActnList,
  ToolWin, ExtCtrls, StdCtrls, Menus, Db, dmDatabase_unit,
  IBDatabase, DBGrids,
  IBCustomDataSet, gdcConst, TB2Item, TB2Dock, TB2Toolbar, gd_MacrosMenu,
  Grids, gsDBGrid, gsIBGrid, DBClient, gdc_createable_form, gdcBase;

const
  scNew         = 'Ins';
  scEdit        = 'Ctrl+Enter';
  scDelete      = 'Ctrl+Del';

type
  Tat_frmUserForm = class(TCreateableForm)
    sbMain: TStatusBar;
    alMain: TActionList;
    actNew: TAction;
    actEdit: TAction;
    actDelete: TAction;
    actHlp: TAction;
    pmMain: TPopupMenu;
    dsMain: TDataSource;
    nNew_OLD: TMenuItem;
    nEdit_OLD: TMenuItem;
    nDel_OLD: TMenuItem;
    TBDockTop: TTBDock;
    TBDockLeft: TTBDock;
    TBDockRight: TTBDock;
    TBDockBottom: TTBDock;
    tbMainToolbar: TTBToolbar;
    tbiNew: TTBItem;
    tbiEdit: TTBItem;
    tbiDelete: TTBItem;
    tbiHelp: TTBItem;
    pnlWorkArea: TPanel;
    pnlMain: TPanel;
    tbMainMenu: TTBToolbar;
    tbsiMainMenuHelp: TTBSubmenuItem;
    tbiMainMenuHelp: TTBItem;
    actSaveToFile: TAction;
    actLoadFromFile: TAction;
    tbiLoadFromFile: TTBItem;
    tbiSaveToFile: TTBItem;
    tbsiMainMenuObject: TTBSubmenuItem;
    tbi_mm_New: TTBItem;
    tbi_mm_Edit: TTBItem;
    tbi_mm_Delete: TTBItem;
    tbi_mm_Load: TTBItem;
    tbi_mm_Save: TTBItem;
    actDeleteChoose: TAction;
    spChoose: TSplitter;
    pnChoose: TPanel;
    pnButtonChoose: TPanel;
    btnCancelChoose: TButton;
    btnOkChoose: TButton;
    tbChooseMain: TTBToolbar;
    ibgrChoose: TgsDBGrid;
    dsChoose: TDataSource;
    btnDelSelect: TButton;
    actMainToSetting: TAction;
    sprSetting: TMenuItem;
    miMainToSetting: TMenuItem;
    ibgrMain: TgsDBGrid;
    tbiMainSep1: TTBSeparatorItem;
    cldsMain: TClientDataSet;
    cldsChoose: TClientDataSet;
    cldsMainFormName: TStringField;
    cldsChooseFormName: TStringField;
    miMainSep2: TMenuItem;
    miLoadForms: TMenuItem;
    actLoadForms: TAction;
    actSelectAll: TAction;
    actUnSelectAll: TAction;
    tbiUnSelectAll: TTBItem;
    tbiSelectAll: TTBItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure actNewExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actDeleteUpdate(Sender: TObject);
    procedure actLoadFormsExecute(Sender: TObject);
    procedure actLoadFromFileExecute(Sender: TObject);
    procedure actSaveToFileExecute(Sender: TObject);
    procedure actSaveToFileUpdate(Sender: TObject);
    procedure actSelectAllExecute(Sender: TObject);
    procedure actSelectAllUpdate(Sender: TObject);
    procedure actUnSelectAllExecute(Sender: TObject);
    procedure actUnSelectAllUpdate(Sender: TObject);
    procedure actDeleteChooseExecute(Sender: TObject);
    procedure actDeleteChooseUpdate(Sender: TObject);
    procedure actMainToSettingExecute(Sender: TObject);
    procedure actMainToSettingUpdate(Sender: TObject);
    procedure ibgrMainClickCheck(Sender: TObject; CheckID: String;
      var Checked: Boolean);

  private
    FNewForm: TgdcCreateableForm;
    FgdcClass: TgdcBase;
    ChooseList: TStringList;

    procedure LoadForms;
    procedure EditForm;

    //Добавляет в selectedid объекта для выбранных записей
    procedure AddToChooseObject(FormName: String);
    //Удаляет из selectedid объекта для выбранных записей
    procedure DeleteFromChooseObject(FormName: String);

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure SaveSettings; override;
    procedure LoadSettings; override;

  end;

var
  at_frmUserForm: Tat_frmUserForm;

implementation

{$R *.DFM}

uses
  at_AddToSetting, gd_ClassList, gsStorage, Storages,
  gd_directories_const, dlg_NewForm_Wzrd_unit,
  gsResizerInterface, dlgEditDfm_unit
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

procedure Tat_frmUserForm.FormCreate(Sender: TObject);
begin
  cldsMain.CreateDataSet;
  cldsChoose.CreateDataSet;
  LoadForms;
end;

procedure Tat_frmUserForm.LoadForms;
var
  F: TgsStorageFolder;
  I: Integer;

begin
  if not Assigned(GlobalStorage) then
    Exit;

  cldsChoose.Open;
  cldsChoose.EmptyDataSet;
  cldsMain.Open;
  cldsMain.EmptyDataSet;
  F := GlobalStorage.OpenFolder(st_ds_NewFormPath, True);
  try
    for I := 0 to F.FoldersCount - 1 do
    begin
      cldsMain.Insert;
      try
        cldsMain.FieldByName('formname').AsString := F.Folders[I].Name;
        cldsMain.Post;
      except
        cldsMain.Cancel;
        raise;
      end;
    end;
  finally
    GlobalStorage.CloseFolder(F);
  end;
end;

procedure Tat_frmUserForm.actNewExecute(Sender: TObject);
begin
  with Tdlg_NewForm_Wzrd.Create(Self) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure Tat_frmUserForm.actEditExecute(Sender: TObject);
begin
  if cldsMain.RecordCount > 0 then
    EditForm
  else
    actNew.Execute;
end;

procedure Tat_frmUserForm.EditForm;
var
  P: TPersistentClass;
  IntType, I: Integer;
  FormClass, GDCClass, GDCSubtype: String;
  F: TgsStorageFolder;
  OldEvent: TOnResiserActivate;
  FCS: TCreateableFormStates;
begin
  if not Assigned(GlobalStorage) then
    Exit;

  F := GlobalStorage.OpenFolder(st_ds_NewFormPath + '\' + cldsMain.FieldByName('formname').AsString);
  try
    if F <> nil then
    begin
      IntType := F.ReadInteger(st_ds_InternalType);
      FormClass := F.ReadString(st_ds_FormClass);
      FNewForm := nil;
      for I := 0 to Screen.FormCount - 1 do
      begin
        if SameText(Screen.Forms[I].Name, cldsMain.FieldByName('formname').AsString) then
        begin
          FNewForm := TgdcCreateableForm(Screen.Forms[I]);
          Break;
        end;
      end;

      if IntType in [st_ds_SimplyForm, st_ds_GDCForm] then
      begin
        P := GetClass(FormClass);
        if P<> nil then
        begin
          case IntType of
            st_ds_SimplyForm:// 1;
            begin

              if FNewForm = nil then
                FNewForm := CgdcCreateableForm(P).CreateUser(Application, cldsMain.FieldByName('formname').AsString);

              FNewForm.FreeNotification(Self);
              OldEvent := FNewForm.Resizer.OnActivate;
              FNewForm.Resizer.OnActivate := nil;
              FNewForm.Resizer.Enabled := True;

              FNewForm.Resizer.OnActivate := OldEvent;
              FCS := FNewForm.CreateableFormState;
              Include(FCS, cfsCloseAfterDesign);
              FNewForm.CreateableFormState := FCS;
              FNewForm.Show;
//              FNewForm.Resizer.ObjectInspectorForm.RefreshList;
//              FNewForm.Resizer.ObjectInspectorForm.RefreshProperties;
              FNewForm.BringToFront;
            end;
            st_ds_GDCForm: // 2;
            begin
              GDCClass := F.ReadString(st_ds_FormGdcObjectClass);
              GDCSubtype := F.ReadString(st_ds_FormGdcSubType);
              if FNewForm = nil then
                FNewForm := CgdcCreateableForm(P).CreateUser(Application, cldsMain.FieldByName('formname').AsString, GDCSubtype);
              FNewForm.FreeNotification(Self);

              if Pos('tgdc_dlg', FormClass) = 1 then
              begin
                P := GetClass(GDCClass);
                if Assigned(P) then
                begin
                  FgdcClass := CgdcBase(P).Create(FNewForm);
                  FgdcClass.FreeNotification(Self);
                  FgdcClass.SubType := GDCSubType;
                  FgdcClass.Open;
                  FNewForm.Setup(FgdcClass);
                end
                else
                begin
                  ShowMessage('GDC класс не определен')
                end;
              end;
              OldEvent := FNewForm.Resizer.OnActivate;
              FNewForm.Resizer.OnActivate := nil;
              FNewForm.Resizer.Enabled := True;
              FNewForm.Resizer.OnActivate := OldEvent;
              FCS := FNewForm.CreateableFormState;
              Include(FCS, cfsCloseAfterDesign);
              FNewForm.CreateableFormState := FCS;
              FNewForm.Show;
//              FNewForm.Resizer.ObjectInspectorForm.RefreshList;
//              FNewForm.Resizer.ObjectInspectorForm.RefreshProperties;
              FNewForm.BringToFront;
            end
          end;
        end
        else
          ShowMessage('Класс формы не определен');
      end
      else
        ShowMessage('Неизвестный тип формы');
    end;
  finally
    GlobalStorage.CloseFolder(F);
  end;

end;

procedure Tat_frmUserForm.actDeleteExecute(Sender: TObject);
var
  F: TgsStorageFolder;
begin
  if not Assigned(GlobalStorage) then
    Exit;
  F := GlobalStorage.OpenFolder(st_ds_NewFormPath);
  try
    F.DeleteFolder(cldsMain.FieldByName('formname').AsString);
    cldsMain.Delete;
  finally
    GlobalStorage.CloseFolder(F);
  end;

end;

procedure Tat_frmUserForm.actDeleteUpdate(Sender: TObject);
begin
  actDelete.Enabled := cldsMain.RecordCount > 0;
end;

procedure Tat_frmUserForm.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;

  if AComponent = FNewForm then
  begin
    FNewForm := nil;
  end
  else if AComponent = FgdcClass then
    FgdcClass := nil;
end;

procedure Tat_frmUserForm.actLoadFormsExecute(Sender: TObject);
begin
  LoadForms;
end;

procedure Tat_frmUserForm.actLoadFromFileExecute(Sender: TObject);
begin
  if not Assigned(GlobalStorage) then
    Exit;

  if OpenDialog.Execute then
  begin
    if AnsiCompareText(ExtractFileExt(OpenDialog.FileName), '.stt') = 0 then
      GlobalStorage.LoadFromFile(OpenDialog.FileName, sffText)
    else if AnsiCompareText(ExtractFileExt(OpenDialog.FileName), '.stb') = 0 then
      GlobalStorage.LoadFromFile(OpenDialog.FileName, sffBinary)
    else
      MessageBox(Handle,
        'Указано неверное расширение имени файла.'#13#10 +
        'Корректные значения:'#13#10 +
        '  .stt (загрузка формы в текстовом виде)' +
        '  .std (загрузка формы в двоичном виде)' +
        'Данные не были сохранены.',
        'Ошибка',
        MB_OK or MB_ICONEXCLAMATION);
    actLoadForms.Execute;
  end;
end;

procedure Tat_frmUserForm.actSaveToFileExecute(Sender: TObject);
var
  F: TgsStorageFolder;
begin
  if not Assigned(GlobalStorage) then
    Exit;

  F := GlobalStorage.OpenFolder(st_ds_NewFormPath + '\' +
    cldsMain.FieldByName('formname').AsString);

  if Assigned(F) and SaveDialog.Execute then
  begin
    if AnsiCompareText(ExtractFileExt(SaveDialog.FileName), '.stt') = 0 then
      F.SaveToFile(SaveDialog.FileName, sffText)
    else if AnsiCompareText(ExtractFileExt(SaveDialog.FileName), '.stb') = 0 then
      F.SaveToFile(SaveDialog.FileName, sffBinary)
    else
      MessageBox(Handle,
        'Указано неверное расширение имени файла.'#13#10 +
        'Корректные значения:'#13#10 +
        '  .stt (сохранение формы в текстовом виде)' +
        '  .std (сохранение формы в двоичном виде)' +
        'Данные не были сохранены.',
        'Ошибка',
        MB_OK or MB_ICONEXCLAMATION);
  end;
end;

procedure Tat_frmUserForm.actSaveToFileUpdate(Sender: TObject);
begin
  actSaveToFile.Enabled := cldsMain.RecordCount > 0;
end;

procedure Tat_frmUserForm.actUnSelectAllExecute(Sender: TObject);
begin
  while ibgrMain.CheckBox.CheckList.Count > 0 do
  begin
    ibgrMain.CheckBox.DeleteCheck(ibgrMain.CheckBox.CheckList[0]);
  end;
end;

procedure Tat_frmUserForm.actUnSelectAllUpdate(Sender: TObject);
begin
  actUnSelectAll.Enabled := ibgrMain.CheckBox.CheckCount > 0;
end;

procedure Tat_frmUserForm.actSelectAllExecute(Sender: TObject);
begin
  cldsMain.DisableControls;
  cldsMain.First;
  while not cldsMain.Eof do
  begin
    ibgrMain.CheckBox.AddCheck(cldsMain.FieldByName('formname').AsString);
    cldsMain.Next;
  end;
  cldsMain.First;
  cldsMain.EnableControls;
end;

procedure Tat_frmUserForm.actSelectAllUpdate(Sender: TObject);
begin
  actSelectAll.Enabled := (cldsMain.RecordCount > 0);
end;

constructor Tat_frmUserForm.Create(AnOwner: TComponent);
begin
  inherited;
  ChooseList := TStringList.Create;
  ChooseList.Sorted := True;
end;

destructor Tat_frmUserForm.Destroy;
begin
  ChooseList.Free;
  inherited;
end;

procedure Tat_frmUserForm.actDeleteChooseExecute(Sender: TObject);
var
  I: Integer;

begin
  if ibgrChoose.SelectedRows.Count > 1 then
    for I := 0 to ibgrChoose.SelectedRows.Count - 1 do
    begin
      cldsChoose.DisableControls;
      cldsChoose.Bookmark := ibgrChoose.SelectedRows[I];
      if ChooseList.IndexOf(AnsiUpperCase(cldsChoose.FieldByName('formname').AsString)) > -1 then
        ChooseList.Delete(ChooseList.IndexOf(AnsiUpperCase(cldsChoose.FieldByName('formname').AsString)));

      if ibgrMain.CheckBox.CheckList.IndexOf(cldsChoose.FieldByName('formname').AsString) > -1 then
        ibgrMain.CheckBox.CheckList.Delete(ibgrMain.CheckBox.CheckList.IndexOf(cldsChoose.FieldByName('formname').AsString));

      cldsChoose.Delete;
      cldsChoose.EnableControls;

    end
  else
  begin
    if ChooseList.IndexOf(AnsiUpperCase(cldsChoose.FieldByName('formname').AsString)) > -1 then
      ChooseList.Delete(ChooseList.IndexOf(AnsiUpperCase(cldsChoose.FieldByName('formname').AsString)));

    if ibgrMain.CheckBox.CheckList.IndexOf(cldsChoose.FieldByName('formname').AsString) > -1 then
      ibgrMain.CheckBox.CheckList.Delete(ibgrMain.CheckBox.CheckList.IndexOf(cldsChoose.FieldByName('formname').AsString));
    cldsChoose.Delete;
  end;

end;

procedure Tat_frmUserForm.actDeleteChooseUpdate(Sender: TObject);
begin
  actDeleteChoose.Enabled := (cldsChoose.RecordCount > 0);
end;

procedure Tat_frmUserForm.actMainToSettingExecute(Sender: TObject);
begin
  AddToSetting(True, st_root_Global +
    st_ds_NewFormPath + '\' +
    cldsMain.FieldByName('formname').AsString, '', nil, nil);
end;

procedure Tat_frmUserForm.actMainToSettingUpdate(Sender: TObject);
begin
  actDeleteChoose.Enabled := (cldsMain.RecordCount > 0);
end;

procedure Tat_frmUserForm.LoadSettings;
begin
  inherited;
  if Assigned(UserStorage) then
  begin
    UserStorage.LoadComponent(ibgrMain, ibgrMain.LoadFromStream);
    UserStorage.LoadComponent(ibgrChoose, ibgrChoose.LoadFromStream);
  end;  
end;

procedure Tat_frmUserForm.SaveSettings;
begin
  if Assigned(UserStorage) then
  begin
    if ibgrMain.SettingsModified then
      UserStorage.SaveComponent(ibgrMain, ibgrMain.SaveToStream);
    if ibgrChoose.SettingsModified then
      UserStorage.SaveComponent(ibgrChoose, ibgrChoose.SaveToStream);
  end;    
  inherited;
end;

procedure Tat_frmUserForm.AddToChooseObject(FormName: String);
var
  FN: String;
begin
  FN := AnsiUpperCase(FormName);
  if ChooseList.IndexOf(FN) = -1 then
  begin
    ChooseList.Add(FN);
    cldsChoose.Insert;
    try
      cldsChoose.FieldByName('formname').AsString := FormName;
      cldsChoose.Post;
    except
      cldsChoose.Cancel;
      raise;
    end;
  end;
end;

procedure Tat_frmUserForm.DeleteFromChooseObject(FormName: String);
var
  FN: String;
begin
  FN := AnsiUpperCase(FormName);
  if ChooseList.IndexOf(FN) > -1 then
  begin
    ChooseList.Delete(ChooseList.IndexOf(FN));
    if cldsChoose.Locate('formname', FormName, []) then
      cldsChoose.Delete;
  end;
end;

procedure Tat_frmUserForm.ibgrMainClickCheck(Sender: TObject;
  CheckID: String; var Checked: Boolean);
begin
  if Checked then
    AddToChooseObject(CheckID)
  else
    DeleteFromChooseObject(CheckID);
end;

initialization
  RegisterClass(Tat_frmUserForm);

finalization
  UnRegisterClass(Tat_frmUserForm);

end.
