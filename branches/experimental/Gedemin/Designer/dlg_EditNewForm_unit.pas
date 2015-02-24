unit dlg_EditNewForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, ExtCtrls, gd_createable_form, gdc_Createable_Form,
  gdcBase, Menus, gd_security;

type
  Tdlg_EditNewForm = class(TCreateableForm, IConnectChangeNotify)
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    alEditForm: TActionList;
    actNewForm: TAction;
    actEditForm: TAction;
    actDeleteForm: TAction;
    actExit: TAction;
    PopupMenu1: TPopupMenu;
    actFormAsDFM: TAction;
    N1: TMenuItem;
    N2: TMenuItem;
    actRefresh: TAction;
    pnlList: TPanel;
    lbForms: TListBox;
    Button5: TButton;
    Button6: TButton;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    actHelp: TAction;
    Button7: TButton;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    procedure actExitExecute(Sender: TObject);
    procedure actEditFormUpdate(Sender: TObject);
    procedure actDeleteFormExecute(Sender: TObject);
    procedure actNewFormExecute(Sender: TObject);
    procedure actEditFormExecute(Sender: TObject);
    procedure actFormAsDFMExecute(Sender: TObject);
    procedure actNewFormUpdate(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actRefreshUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);

  private
    FgdcClass: TgdcBase;

    procedure LoadForms;

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    procedure DoAfterSuccessfullConnection;
    procedure DoBeforeDisconnect;
    procedure DoAfterConnectionLost;

  public
    constructor Create(AnOwner: TComponent); override;
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;

    procedure Prepare;
  end;


var
  dlg_EditNewForm: Tdlg_EditNewForm;

implementation

{$R *.DFM}

uses
  Storages, gd_directories_const, gsStorage, dlg_NewForm_Wzrd_unit,
  gsResizerInterface, dlgEditDfm_unit;

var
  FNewForm: TgdcCreateableForm;

procedure Tdlg_EditNewForm.LoadForms;
var
  F: TgsStorageFolder;
  I: Integer;
begin
  if not Assigned(GlobalStorage) then
    Exit;
  lbForms.Items.Clear;
  F := GlobalStorage.OpenFolder(st_ds_NewFormPath);
  try
    if Assigned(F) then
      for I := 0 to F.FoldersCount - 1 do
        lbForms.Items.Add(F.Folders[I].Name);
  finally
    GlobalStorage.CloseFolder(F);
  end;
end;

procedure Tdlg_EditNewForm.actExitExecute(Sender: TObject);
begin
  Close;
end;

procedure Tdlg_EditNewForm.actEditFormUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled :=
    (lbForms.ItemIndex >= 0)
    and (FNewForm = nil)
    and Assigned(IBLogin)
    and IBLogin.LoggedIn;

  lbForms.Visible := FNewForm = nil;
end;

procedure Tdlg_EditNewForm.actDeleteFormExecute(Sender: TObject);
var
  F: TgsStorageFolder;
begin
  if not (MessageDlg('Вы хотите удалить форму?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
    Exit;

  if not Assigned(GlobalStorage) then
    Exit;
  F := GlobalStorage.OpenFolder(st_ds_NewFormPath);
  try
    F.DeleteFolder(lbForms.Items[lbForms.ItemIndex]);
    lbForms.Items.Delete(lbForms.ItemIndex);
  finally
    GlobalStorage.CloseFolder(F);
  end;
end;

procedure Tdlg_EditNewForm.actNewFormExecute(Sender: TObject);
var
  I: Integer;
begin
  with Tdlg_NewForm_Wzrd.Create(Self) do
  try
    ShowModal;
  finally
    Free;
  end;
  I := lbForms.ItemIndex;
  LoadForms;
  if (I >= 0) and (I < lbForms.Items.Count) then
    lbForms.ItemIndex := I;
end;

procedure Tdlg_EditNewForm.actEditFormExecute(Sender: TObject);
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

  F := GlobalStorage.OpenFolder(st_ds_NewFormPath + '\' + lbForms.Items[lbForms.ItemIndex]);
  try
    if F <> nil then
    begin
      IntType := F.ReadInteger(st_ds_InternalType);
      FormClass := F.ReadString(st_ds_FormClass);
      FNewForm := nil;
      for I := 0 to Screen.FormCount - 1 do
      begin
        if SameText(Screen.Forms[I].Name, lbForms.Items[lbForms.ItemIndex]) then
        begin
          FNewForm := TgdcCreateableForm(Screen.Forms[I]);
          Break;
        end;
      end;
      if Assigned(FNewForm) then
      begin
        if MessageDlg('Данная форма сейчас открыта. ' + #10#13 +
           'Если вы хотите закрыть ее и перейти в режим редактирования' + #10#13 +
           'нажмите - да иначе нажмите - нет.', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
          FreeAndNil(FNewForm)
        else
        begin
          FNewForm := nil;
          Exit;
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
                FNewForm := CgdcCreateableForm(P).CreateUser(Application, lbForms.Items[lbForms.ItemIndex], '', True);

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
                FNewForm := CgdcCreateableForm(P).CreateUser(Application, lbForms.Items[lbForms.ItemIndex], GDCSubtype, True);
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
        ShowMessage('Неизвестный тип формы. Обратитесь к разработчикам.');
    end;
  finally
    GlobalStorage.CloseFolder(F);
  end;
end;

procedure Tdlg_EditNewForm.Notification(AComponent: TComponent;
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

procedure Tdlg_EditNewForm.actFormAsDFMExecute(Sender: TObject);
var
  F: TMemoryStream;
  F1: TStringStream;
  S: String;
begin
  if Assigned(GlobalStorage) then
  begin
    F := TMemoryStream.Create;
    try
      GlobalStorage.ReadStream(st_ds_NewFormPath + '\' + lbForms.Items[lbForms.ItemIndex], st_ds_UserFormDFM, F);
      F.Seek(0, soFromBeginning);
      F1 := TStringStream.Create('');
      try
        SetLength(S, 3);
        F.Read(S[1], 3);
        if S = 'TPF' then
        begin
          F.Position := 0;
          ObjectBinaryToText(F, F1);
        end else
        begin
          F1.CopyFrom(F, 0);
        end;
        S := F1.DataString;
      finally
        F1.Free;
      end;
      if EditDfm(lbForms.Items[lbForms.ItemIndex], S) then
      begin
        F.Clear;
        F1 := TStringStream.Create(S);
        try
          F1.Seek(0, soFromBeginning);
          ObjectTextToBinary(F1, F);
          GlobalStorage.WriteStream(st_ds_NewFormPath + '\' + lbForms.Items[lbForms.ItemIndex], st_ds_UserFormDFM, F);
        finally
          F1.Free;
        end
      end;

    finally
      F.Free;
    end
  end;
end;

procedure Tdlg_EditNewForm.actNewFormUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (FNewForm = nil)
    and Assigned(IBLogin)
    and IBLogin.LoggedIn;
end;

procedure Tdlg_EditNewForm.Prepare;
begin
  LoadForms;
end;

procedure Tdlg_EditNewForm.actRefreshExecute(Sender: TObject);
begin
  LoadForms;
end;

procedure Tdlg_EditNewForm.FormDestroy(Sender: TObject);
begin
  if Assigned(FNewForm) then
    FNewForm.Release;

  if Assigned(IBLogin) then
    IBLogin.RemoveConnectNotify(Self);
end;

constructor Tdlg_EditNewForm.Create(AnOwner: TComponent);
begin
  inherited;
  ShowSpeedButton := True;
  UseDesigner := False;
end;

procedure Tdlg_EditNewForm.actRefreshUpdate(Sender: TObject);
begin
  actRefresh.Enabled := (FNewForm = nil)
    and Assigned(IBLogin)
    and IBLogin.LoggedIn;
end;

procedure Tdlg_EditNewForm.FormCreate(Sender: TObject);
begin
  if Assigned(IBLogin) then
    IBLogin.AddConnectNotify(Self);
end;

procedure Tdlg_EditNewForm.DoAfterConnectionLost;
begin
  Release;
end;

procedure Tdlg_EditNewForm.DoBeforeDisconnect;
begin
  Release;
end;

procedure Tdlg_EditNewForm.DoAfterSuccessfullConnection;
begin
  //
end;

class function Tdlg_EditNewForm.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(dlg_EditNewForm) then
    dlg_EditNewForm := Tdlg_EditNewForm.Create(AnOwner);
  Result := dlg_EditNewForm;
end;

procedure Tdlg_EditNewForm.actHelpExecute(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

end.
