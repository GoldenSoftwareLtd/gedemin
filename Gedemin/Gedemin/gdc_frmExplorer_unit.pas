
{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    gdc_frmExplorer_unit.pas

  Abstract

    Part of a business class. Explorer.

  Author

    Michael Shoihet

  Revisions history

    Initial  13-12-2001  Michael  Initial version.

--}


unit gdc_frmExplorer_unit;
                        
interface

uses
  Windows,          Messages,            SysUtils,        Classes,
  Graphics,         Controls,            Forms,           Dialogs,
  gdc_frmG_unit,    ComCtrls,            gsDBTreeView,    Db,
  Menus,            ActnList,            ToolWin,         ExtCtrls,
  TB2Item,          TB2Dock,             TB2Toolbar,      gdcExplorer,
  gd_security,      IBCustomDataSet,     gdcBase,         gdcTree,
  StdCtrls,         gd_MacrosMenu,       Grids,           DBGrids,
  gsDBGrid,         gsIBGrid, ImgList, gsIBLookupComboBox;

type
  Tgdc_frmExplorer = class(Tgdc_frmG)
    actShow: TAction;
    N1: TMenuItem;
    N2: TMenuItem;
    gdcExplorer: TgdcExplorer;
    actCreateNewObject: TAction;
    nactCreateNewObject1: TMenuItem;
    tbiCreateObjExp: TTBItem;
    tbiOpenExp: TTBItem;
    Panel1: TPanel;
    dbtvExplorer: TgsDBTreeView;
    spl: TSplitter;
    actShowRecent: TAction;
    TBItem1: TTBItem;
    pmLB: TPopupMenu;
    N3: TMenuItem;
    N4: TMenuItem;
    pnlTop: TPanel;
    lb: TListBox;
    pcSecurity: TPageControl;
    tsGroup: TTabSheet;
    tsUser: TTabSheet;
    actSecurity: TAction;
    TBItem2: TTBItem;
    il: TImageList;
    iblkupGroup: TgsIBLookupComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Panel2: TPanel;
    Label3: TLabel;
    rbVY: TRadioButton;
    rbVN: TRadioButton;
    Panel3: TPanel;
    Label4: TLabel;
    rbCY: TRadioButton;
    rbCN: TRadioButton;
    Panel4: TPanel;
    Label5: TLabel;
    rbFY: TRadioButton;
    rbFN: TRadioButton;
    Button1: TButton;
    actSetAccess: TAction;
    chbxUpdateChildren: TCheckBox;
    iblkupUser: TgsIBLookupComboBox;
    Label6: TLabel;
    lblGroups: TLabel;
    tsHelp: TTabSheet;
    ListBox1: TListBox;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    tsCommand: TTabSheet;
    Panel5: TPanel;
    Panel6: TPanel;
    mRights: TMemo;
    lblClass: TLabel;
    btnDistrChild: TButton;
    btnDistrAll: TButton;
    actDistrChild: TAction;
    actDistrAll: TAction;
    Label14: TLabel;
    procedure actShowExecute(Sender: TObject);
    procedure actPropertiesUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure dbtvExplorerDblClick(Sender: TObject);
    procedure actCreateNewObjectUpdate(Sender: TObject);
    procedure actCreateNewObjectExecute(Sender: TObject);
    procedure actShowUpdate(Sender: TObject);
    procedure dbtvExplorerAdvancedCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage;
      var PaintImages, DefaultDraw: Boolean);
    procedure dbtvExplorerPostProcess(Sender: TObject);
    procedure actDeleteUpdate(Sender: TObject);
    procedure actNewUpdate(Sender: TObject);
    procedure actEditUpdate(Sender: TObject);
    procedure actSaveToFileUpdate(Sender: TObject);
    procedure lbClick(Sender: TObject);
    procedure lbDblClick(Sender: TObject);
    procedure actShowRecentUpdate(Sender: TObject);
    procedure actShowRecentExecute(Sender: TObject);
    procedure dbtvExplorerClick(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure dbtvExplorerFilterRecord(DataSet: TDataSet;
      var Accept: Boolean);
    procedure FormShow(Sender: TObject);
    procedure dbtvExplorerExpanded(Sender: TObject; Node: TTreeNode);
    procedure actSecurityUpdate(Sender: TObject);
    procedure actSecurityExecute(Sender: TObject);
    procedure iblkupGroupChange(Sender: TObject);
    procedure FormCanResize(Sender: TObject; var NewWidth,
      NewHeight: Integer; var Resize: Boolean);
    procedure rbVNClick(Sender: TObject);
    procedure rbCNClick(Sender: TObject);
    procedure rbFYClick(Sender: TObject);
    procedure rbCYClick(Sender: TObject);
    procedure actSetAccessUpdate(Sender: TObject);
    procedure actSetAccessExecute(Sender: TObject);
    procedure iblkupUserChange(Sender: TObject);
    procedure pcSecurityChange(Sender: TObject);
    procedure ListBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure dsMainDataChange(Sender: TObject; Field: TField);
    procedure actDistrChildUpdate(Sender: TObject);
    procedure actDistrChildExecute(Sender: TObject);
    procedure actDistrAllUpdate(Sender: TObject);
    procedure actDistrAllExecute(Sender: TObject);

  private
    FUserMask: Integer;
    FOldWidth: Integer;

    procedure UpdateInfo;

  protected
    procedure Loaded; override;

    procedure WMSysCommand(var Message: TMessage);
      message WM_SYSCOMMAND;

  public
    destructor Destroy; override;

    class function CreateAndAssign(AnOwner: TComponent): TForm; override;

    procedure LoadSettings; override;
    procedure SaveSettings; override;
  end;

var
  gdc_frmExplorer: Tgdc_frmExplorer;

implementation

{$R *.DFM}

uses
  Storages, gd_ClassList, gdcBaseInterface, gd_directories_const,
  gd_createable_form, dmImages_unit, jclStrings, gsResizerInterface,
  gdcUser
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{ Tgdc_frmExplorer }

class function Tgdc_frmExplorer.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmExplorer) then
    gdc_frmExplorer := Tgdc_frmExplorer.Create(AnOwner);
  Result := gdc_frmExplorer;
end;

procedure Tgdc_frmExplorer.actShowExecute(Sender: TObject);
begin
  if not gdcObject.CanView then
  begin
    MessageBox(Handle,
      'У Вас нет прав для выполнения данной команды.',
      'Отказано в доступе',
      MB_OK or MB_ICONHAND or MB_TASKMODAL);
    exit;
  end;

  (gdcObject as TgdcExplorer).ShowProgram(GetAsyncKeyState(VK_CONTROL) shr 1 > 0);

  if gdcObject.FieldByName('classname').AsString = '' then
  begin
    if dbtvExplorer.Selected <> nil then
    begin
      if dbtvExplorer.Selected.Expanded then
        dbtvExplorer.Selected.Collapse(False)
      else
        dbtvExplorer.Selected.Expand(False);
    end;
  end;

  if lb.Items.IndexOf(gdcObject.ObjectName) = -1 then
  begin
    Randomize;
    if lb.Items.Count >= 20 then
      lb.Items.Delete(Random(20));
    lb.Items.AddObject(gdcObject.ObjectName, Pointer(gdcObject.ID));
  end;
end;

procedure Tgdc_frmExplorer.actPropertiesUpdate(Sender: TObject);
begin
  actProperties.Enabled := dbtvExplorer.Selected <> nil;
end;

procedure Tgdc_frmExplorer.LoadSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  SL: TStringList;
  I: Integer;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMEXPLORER', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMEXPLORER', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMEXPLORER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMEXPLORER',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMEXPLORER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if Assigned(UserStorage) then
  begin
    UserStorage.LoadComponent(dbtvExplorer, dbtvExplorer.LoadFromStream);
    pnlTop.Height := UserStorage.ReadInteger('Options', 'RecentHeight', 163);
    SL := TStringList.Create;
    try
      lb.Items.BeginUpdate;
      try
        lb.Items.Clear;
        SL.CommaText := UserStorage.ReadString('Options', 'Recent', '');
        for I := 0 to SL.Count - 1 do
        begin
          if (SL.Names[I] > '') and (lb.Items.IndexOf(SL.Names[I]) = -1)
            and (StrToIntDef(SL.Values[SL.Names[I]], 0) > 0) then
          begin
            lb.Items.Objects[lb.Items.Add(SL.Names[I])] :=
              Pointer(StrToIntDef(SL.Values[SL.Names[I]], 0));
          end;
        end;
      finally
        lb.Items.EndUpdate;
      end;  
    finally
      SL.Free;
    end;
  end;

  pnlTop.Enabled := pnlTop.Height > 1;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMEXPLORER', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMEXPLORER', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmExplorer.SaveSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  S: String;
  I: Integer;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMEXPLORER', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMEXPLORER', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMEXPLORER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMEXPLORER',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMEXPLORER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if Assigned(UserStorage) then
  begin
    UserStorage.SaveComponent(dbtvExplorer, dbtvExplorer.SaveToStream);
    UserStorage.WriteInteger('Options', 'RecentHeight', pnlTop.Height);
    S := '';
    for I := 0 to lb.Items.Count - 1 do
    begin
      if I >= 20 then
        break;
      if Pos('=', lb.Items[I]) = 0 then
        S := S + '"' + lb.Items[I] + '=' + IntToStr(Integer(lb.Items.Objects[I])) + '",';
    end;
    if S > '' then
      SetLength(S, Length(S) - 1);
    UserStorage.WriteString('Options', 'Recent', S);
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMEXPLORER', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMEXPLORER', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmExplorer.FormCreate(Sender: TObject);
begin
  gdcObject := gdcExplorer;

  inherited;

  if Assigned(gdcBaseManager) then
    gdcBaseManager.Explorer := gdcExplorer;

  iblkupGroup.Transaction := gdcBaseManager.ReadTransaction;
  iblkupUser.Transaction := gdcBaseManager.ReadTransaction;
end;

procedure Tgdc_frmExplorer.dbtvExplorerDblClick(Sender: TObject);
var
  R: TRect;
begin
  if Assigned(dbtvExplorer.Selected) then
  begin
    R := dbtvExplorer.Selected.DisplayRect(True);
    R.Left := R.Left - dbtvExplorer.Indent;
    if PtInRect(R, dbtvExplorer.ScreenToClient(Mouse.CursorPos)) then
    begin
      actShow.Execute;
    end;
  end;
end;

procedure Tgdc_frmExplorer.Loaded;
var
  RDesk: TRect;
  T: Integer;
begin
  inherited;
  if Assigned(Application.MainForm) and (Position = poDesigned) then
  begin
    SystemParametersInfo(SPI_GETWORKAREA, 0, @RDesk, 0);
    T := Application.MainForm.Top + Application.MainForm.Height;
    SetBounds(Application.MainForm.Left, T, 200,
      RDesk.Bottom - RDesk.Top + 1 - T);
  end;
end;

procedure Tgdc_frmExplorer.actCreateNewObjectUpdate(Sender: TObject);
begin
  actCreateNewObject.Enabled := gdcExplorer.gdcClass <> nil;
end;

procedure Tgdc_frmExplorer.actCreateNewObjectExecute(Sender: TObject);
var
  Obj: TgdcBase;
begin
  Obj := gdcExplorer.CreateGdcInstance;
  try
    Obj.CreateDescendant;
  finally
    Obj.Free;
  end;
end;

procedure Tgdc_frmExplorer.actShowUpdate(Sender: TObject);
begin
  actShow.Enabled := Assigned(gdcObject)
    and (not gdcObject.IsEmpty);
end;

procedure Tgdc_frmExplorer.dbtvExplorerAdvancedCustomDrawItem(
  Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
  Stage: TCustomDrawStage; var PaintImages, DefaultDraw: Boolean);
var
  V: Variant;
  C: TClass;
  B: TBitmap;
  R: TRect;
  LFullClass: TgdcFullClassName;
  F: Boolean;
  M: Integer;
begin
  if (Stage = cdPostPaint) and (Node <> nil) and (Integer(Node.Data) > 0) then
  begin
    F := False;
    B := TBitmap.Create;
    try
      V := gdcExplorer.GetFieldValueForID(Integer(Node.Data), 'imgindex');
      if (VarType(V) = varInteger) and (V > 0) then
      begin
        dmImages.il16x16.GetBitmap(V, B);
      end else
      begin
        V := gdcExplorer.GetFieldValueForID(Integer(Node.Data), 'classname');
        if VarType(V) = varString then
        begin
          LFullClass.gdClassName := V;
          LFullClass.SubType := '';
          C := gdClassList.GetGdcClass(LFullClass);

          if (C <> nil) and C.InheritsFrom(TgdcBase) then
          begin
            CgdcBase(C).GetClassImage(16, 16, B);
          end else
            F := True;
        end else
          F := True;
      end;

      if F then
      begin
        V := gdcExplorer.GetFieldValueForID(Integer(Node.Data), 'parent');
        if (VarType(V) = varInteger) and (V > 0) then
        begin
          V := gdcExplorer.GetFieldValueForID(V, 'imgindex');
          if (VarType(V) = varInteger) and (V > 0) then
          begin
            dmImages.il16x16.GetBitmap(V, B);
          end else
            dmImages.il16x16.GetBitmap(0, B);
        end else
          dmImages.il16x16.GetBitmap(0, B);
      end;

      V := gdcExplorer.GetFieldValueForId(Integer(Node.Data), 'cmdtype');
      if (VarType(V) = varInteger) and (V > 0) then
      begin
        dmImages.il16x16.DrawOverlay(B.Canvas, 0, 0,  iiRunning, oiRunning);
      end else
      begin
        V := gdcExplorer.GetFieldValueForId(Integer(Node.Data), 'classname');
        if (not VarIsNull(V)) and (Trim(V) > '') then
          dmImages.il16x16.DrawOverlay(B.Canvas, 0, 0,  iiRunning, oiRunning);
      end;

      R := Node.DisplayRect(True);
      dbtvExplorer.Canvas.Draw(R.Left - 20, R.Top, B);

      if pcSecurity.Visible then
      begin
        M := 0;

        if (pcSecurity.ActivePage = tsGroup) and (iblkupGroup.CurrentKeyInt > 0) then
        begin
          M := 1 shl (iblkupGroup.CurrentKeyInt - 1);
        end
        else if (pcSecurity.ActivePage = tsUser) and (iblkupUser.CurrentKeyInt > 0) then
        begin
          M := FUserMask;
        end;

        if M <> 0 then
        begin
          if (gdcExplorer.GetFieldValueForId(Integer(Node.Data), 'aview') and M) <> 0 then
            il.Draw(dbtvExplorer.Canvas, R.Right + 2, R.Top + 4, 1)
          else
            il.Draw(dbtvExplorer.Canvas, R.Right + 2, R.Top + 4, 0);
          if (gdcExplorer.GetFieldValueForId(Integer(Node.Data), 'achag') and M) <> 0 then
            il.Draw(dbtvExplorer.Canvas, R.Right + 2 + 9, R.Top + 4, 1)
          else
            il.Draw(dbtvExplorer.Canvas, R.Right + 2 + 9, R.Top + 4, 0);
          if (gdcExplorer.GetFieldValueForId(Integer(Node.Data), 'afull') and M) <> 0 then
            il.Draw(dbtvExplorer.Canvas, R.Right + 2 + 18, R.Top + 4, 1)
          else
            il.Draw(dbtvExplorer.Canvas, R.Right + 2 + 18, R.Top + 4, 0);
        end;
      end;

      PaintImages := False;
      DefaultDraw := True;
    finally
      B.Free;
    end;
  end;
end;

procedure Tgdc_frmExplorer.dbtvExplorerPostProcess(Sender: TObject);
var
  I: Integer;
  S, S2: Variant;
  LFullClass: TgdcFullClassName;
  DataID: Integer;
begin
  dbtvExplorer.Items.BeginUpdate;
  try
    I := 0;
    while I < dbtvExplorer.Items.Count do
    begin
      DataID := Integer(dbtvExplorer.Items[I].Data);
        if gdcExplorer.GetFieldValueForID(DataID,
        'cmdtype') = cst_expl_cmdtype_function
      then
        Inc(I)
      else
      begin
        S := gdcExplorer.GetFieldValueForID(DataID, 'classname');
        if VarIsNull(S) then S := '';
        S2 := gdcExplorer.GetFieldValueForID(DataID, 'cmd');
        if VarIsNull(S2) then S2 := '';
        LFullClass.gdClassName := S;
        LFullClass.SubType := '';
        if (S = '') or (S2 = '') or
          dbtvExplorer.Items[I].HasChildren or
          (gdClassList.FindClassByName(LFullClass)) or
          (GetClass(S) <> nil) or
          (StrIPos(USERFORM_PREFIX, S) = 1) then
        begin
          Inc(I);
        end else
        begin
          dbtvExplorer.TVState.Bookmarks.Remove(DataID);
          dbtvExplorer.Items[I].Delete;
        end;
      end;
    end;
  finally
    dbtvExplorer.Items.EndUpdate;
  end;
end;

procedure Tgdc_frmExplorer.actDeleteUpdate(Sender: TObject);
begin
  if IBlogin.IsIBUserAdmin then
  begin
    actDelete.Visible := True;
    (Sender as TAction).Enabled :=
      (gdcObject <> nil)
      and (gdcObject.RecordCount > 0)
      and (gdcObject.CanDelete)
      and (gdcObject.State = dsBrowse)
  end else
    actDelete.Visible := False;
end;

procedure Tgdc_frmExplorer.WMSysCommand(var Message: TMessage);
var
  RDesk, RMain: TRect;
begin
  case Message.WParam and $FFF0 of
    SC_MAXIMIZE:
      begin
        if (not (cfsDesigning in FCreateableFormState))
          and Assigned(Application.MainForm)
          and Assigned(UserStorage)
          and UserStorage.ReadBoolean('Options', 'Magic', True) then
        begin
          SystemParametersInfo(SPI_GETWORKAREA, 0, @RDesk, 0);
          GetWindowRect(Application.MainForm.Handle, RMain);
          SetBounds(RMain.Left, RMain.Bottom, 200,
            RDesk.Bottom - RMain.Bottom + 1);
          exit;
        end;
      end;
  end;

  inherited;
end;

procedure Tgdc_frmExplorer.actNewUpdate(Sender: TObject);
begin
  if IBLogin.IsIBUserAdmin then
  begin
    (Sender as TAction).Visible := True;
    inherited;
  end else
    (Sender as TAction).Visible := False;
end;

procedure Tgdc_frmExplorer.actEditUpdate(Sender: TObject);
begin
  if IBLogin.IsIBUserAdmin then
  begin
    actEdit.Visible := True;
    inherited;
  end else
    actEdit.Visible := False;
end;

procedure Tgdc_frmExplorer.actSaveToFileUpdate(Sender: TObject);
begin
  if IBLogin.IsIBUserAdmin then
  begin
    actSaveToFile.Visible := True;
    inherited;
  end else
    actSaveToFile.Visible := False;
end;

procedure Tgdc_frmExplorer.lbClick(Sender: TObject);
var
  I, K: Integer;
begin
  if gdcObject.Active then
  begin
    if (lb.Items.Count > 0) and (lb.ItemIndex > -1) then
    begin
      I := lb.ItemIndex;
      try
        K := Integer(lb.Items.Objects[I]);
        if not gdcObject.Locate(gdcObject.GetKeyField(gdcObject.SubType),
          K, []) then
        begin
          lb.Items.Delete(I);
        end;
      except
        lb.Items.Delete(I);
      end;
    end;
  end;  
end;

procedure Tgdc_frmExplorer.lbDblClick(Sender: TObject);
var
  I, K: Integer;
begin
  if gdcObject.Active then
  begin
    if (lb.Items.Count > 0) and (lb.ItemIndex > -1) then
    begin
      I := lb.ItemIndex;
      try
        K := Integer(lb.Items.Objects[I]);
        if not gdcObject.Locate(gdcObject.GetKeyField(gdcObject.SubType),
          K, []) then
        begin
          lb.Items.Delete(I);
        end else
        begin
          actShow.Execute;
        end;
      except
        lb.Items.Delete(I);
      end;
    end;
  end;  
end;

procedure Tgdc_frmExplorer.actShowRecentUpdate(Sender: TObject);
begin
  actShowRecent.Checked := pnlTop.Height > 1;
end;

procedure Tgdc_frmExplorer.actShowRecentExecute(Sender: TObject);
begin
  if pnlTop.Height <= 1 then
    pnlTop.Height := 163
  else
    pnlTop.Height := 1;

  pnlTop.Enabled := pnlTop.Height > 1;
end;

procedure Tgdc_frmExplorer.dbtvExplorerClick(Sender: TObject);
begin
  lb.ItemIndex := -1;
end;

procedure Tgdc_frmExplorer.N3Click(Sender: TObject);
begin
  lb.Items.Clear;
end;

procedure Tgdc_frmExplorer.N4Click(Sender: TObject);
begin
  if (lb.Items.Count > 0) and (lb.ItemIndex > -1) then
  begin
    lb.Items.Delete(lb.ItemIndex);
  end;
end;

procedure Tgdc_frmExplorer.dbtvExplorerFilterRecord(DataSet: TDataSet;
  var Accept: Boolean);
begin
  Accept := (DataSet.FieldByName('id').AsInteger > 710000) and
    (((DataSet.FieldByName('aview').AsInteger or 1) and IBLogin.InGroup) <> 0) and
    (DataSet.FieldByName('disabled').AsInteger = 0);
end;

destructor Tgdc_frmExplorer.Destroy;
begin
  if gdc_frmExplorer = Self then
    gdc_frmExplorer := nil;
  inherited;
end;

procedure Tgdc_frmExplorer.FormShow(Sender: TObject);
begin
  if Assigned(gdcBaseManager) and
    (not gdcBaseManager.Class_TestUserRights(TgdcExplorer, '', 0)) then
  begin
    Release;
  end;
end;

procedure Tgdc_frmExplorer.dbtvExplorerExpanded(Sender: TObject;
  Node: TTreeNode);
begin
  inherited;
  //
end;

procedure Tgdc_frmExplorer.actSecurityUpdate(Sender: TObject);
begin
  actSecurity.Enabled := (IBLogin <> nil) and IBLogin.IsIBUserAdmin
    and actShowRecent.Checked;
  actSecurity.Checked := pcSecurity.Visible;
end;

procedure Tgdc_frmExplorer.actSecurityExecute(Sender: TObject);
begin
  pcSecurity.Visible := not pcSecurity.Visible;
  lb.Visible := not lb.Visible;

  if pcSecurity.Visible then
  begin
    UpdateInfo;

    if Width < 320 then
    begin
      FOldWidth := Width;
      Width := 320;
    end;
  end else
  begin
    if FOldWidth <> 0 then
    begin
      Width := FOldWidth;
      FOldWidth := 0;
    end;    
  end;
end;

procedure Tgdc_frmExplorer.iblkupGroupChange(Sender: TObject);
begin
  dbtvExplorer.Invalidate;
end;

procedure Tgdc_frmExplorer.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  inherited;

  //...
end;

procedure Tgdc_frmExplorer.rbVNClick(Sender: TObject);
begin
  rbCN.Checked := True;
  rbFN.Checked := True;
end;

procedure Tgdc_frmExplorer.rbCNClick(Sender: TObject);
begin
  rbFN.Checked := True;
end;

procedure Tgdc_frmExplorer.rbFYClick(Sender: TObject);
begin
  rbCY.Checked := True;
  rbVY.Checked := True;
end;

procedure Tgdc_frmExplorer.rbCYClick(Sender: TObject);
begin
  rbVY.Checked := True;
end;

procedure Tgdc_frmExplorer.actSetAccessUpdate(Sender: TObject);
begin
  actSetAccess.Enabled := (gdcObject <> nil)
    and gdcObject.Active
    and (not gdcObject.EOF)
    and (iblkupGroup.CurrentKeyInt > 0);
end;

procedure Tgdc_frmExplorer.actSetAccessExecute(Sender: TObject);
var
  OldUpdateChildren: Boolean;
  M: Integer;
begin
  if iblkupGroup.CurrentKeyInt = 1 then
  begin
    MessageBox(Handle,
      'Группа "Администраторы" всегда имеет полный доступ к объектам системы.',
      'Внимание',
      MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
  end else
  begin
    OldUpdateChildren := UpdateChildren_Global;
    if chbxUpdateChildren.Checked then
      gdcObject.DisableControls;
    try
      M := 1 shl (iblkupGroup.CurrentKeyInt - 1);

      UpdateChildren_Global := chbxUpdateChildren.Checked;
      UpdateChildren_UseMask := True;
      gdcObject.Edit;
      if rbVY.Checked then
      begin
        gdcObject.FieldByName('aview').AsInteger := gdcObject.FieldByName('aview').AsInteger or M;
        UpdateChildren_AView_And := 0;
        UpdateChildren_AView_Or := M;
      end else
      begin
        gdcObject.FieldByName('aview').AsInteger := gdcObject.FieldByName('aview').AsInteger and (not M);
        UpdateChildren_AView_And := not M;
        UpdateChildren_AView_Or := 0;
      end;
      if rbCY.Checked then
      begin
        gdcObject.FieldByName('achag').AsInteger := gdcObject.FieldByName('achag').AsInteger or M;
        UpdateChildren_AChag_And := 0;
        UpdateChildren_AChag_Or := M;
      end else
      begin
        gdcObject.FieldByName('achag').AsInteger := gdcObject.FieldByName('achag').AsInteger and (not M);
        UpdateChildren_AChag_And := not M;
        UpdateChildren_AChag_Or := 0;
      end;
      if rbFY.Checked then
      begin
        gdcObject.FieldByName('afull').AsInteger := gdcObject.FieldByName('afull').AsInteger or M;
        UpdateChildren_AFull_And := 0;
        UpdateChildren_AFull_Or := M;
      end else
      begin
        gdcObject.FieldByName('afull').AsInteger := gdcObject.FieldByName('afull').AsInteger and (not M);
        UpdateChildren_AFull_And := not M;
        UpdateChildren_AFull_Or := 0;
      end;
      gdcObject.Post;

      if chbxUpdateChildren.Checked and (dbtvExplorer.Selected <> nil)
        and dbtvExplorer.Selected.HasChildren then
      begin
        gdcObject.CloseOpen;
      end;
    finally
      UpdateChildren_Global := OldUpdateChildren;
      UpdateChildren_UseMask := False;
      UpdateChildren_AFull_And := 0;
      UpdateChildren_AFull_Or := 0;
      UpdateChildren_AChag_And := 0;
      UpdateChildren_AChag_Or := 0;
      UpdateChildren_AView_And := 0;
      UpdateChildren_AView_Or := 0;
      if chbxUpdateChildren.Checked then
        gdcObject.EnableControls;
    end;
  end;
end;

procedure Tgdc_frmExplorer.iblkupUserChange(Sender: TObject);
var
  V: OleVariant;
begin
  if iblkupUser.CurrentKeyInt > 0 then
  begin
    gdcBaseManager.ExecSingleQueryResult('SELECT ingroup FROM gd_user WHERE id=:ID',
      iblkupUser.CurrentKeyInt, V);
    FUserMask := V[0, 0];
    lblGroups.Caption := 'Пользователь входит в группы: ' +
      TgdcUserGroup.GetGroupList(FUserMask) + '.';
  end else
  begin
    FUserMask := 0;
    lblGroups.Caption := '';
  end;
  dbtvExplorer.Invalidate;
end;

procedure Tgdc_frmExplorer.pcSecurityChange(Sender: TObject);
begin
  dbtvExplorer.Invalidate;
end;

procedure Tgdc_frmExplorer.ListBox1DrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
const
  A: array[1..12] of Integer = (1, 1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0);
var
  I: Integer;
begin
  for I := 1 to 3 do
    il.Draw((Control as TListBox).Canvas, Rect.Right - 36 + I * 9, Rect.Top + 4,
      A[Index * 3 + I]);
end;

procedure Tgdc_frmExplorer.dsMainDataChange(Sender: TObject;
  Field: TField);
begin
  inherited;

  UpdateInfo;
end;

procedure Tgdc_frmExplorer.actDistrChildUpdate(Sender: TObject);
begin
  actDistrChild.Enabled := (dbtvExplorer.Selected <> nil) and
    dbtvExplorer.Selected.HasChildren
end;

procedure Tgdc_frmExplorer.UpdateInfo;
var
  F, K, J: Integer;
  S: String;
begin
  if pcSecurity.Visible and (not gdcObject.IsEmpty) then
  begin
    if gdcObject.FieldByName('classname').AsString > '' then
    begin
      lblClass.Caption := 'Класс: ' + gdcObject.FieldByName('classname').AsString;
      if gdcObject.FieldByName('subtype').AsString > '' then
        lblClass.Caption := lblClass.Caption + '(' + gdcObject.FieldByName('subtype').AsString + ')';
    end else
    if (gdcObject.FieldByName('cmd').AsString > '') and (gdcObject.FieldByName('cmdtype').AsInteger <> 0) then
      lblClass.Caption := 'Команда: ' + gdcObject.FieldByName('cmd').AsString
    else
      lblClass.Caption := 'Папка: ' + gdcObject.FieldByName('name').AsString;

    mRights.Lines.Clear;
    F := gdcObject.FieldByName('afull').AsInteger;
    K := gdcObject.FieldByName('achag').AsInteger and (not F);
    J := gdcObject.FieldByName('aview').AsInteger and (not (F or K));
    S := TgdcUserGroup.GetGroupList(not (F or K or J));
    if S > '' then
      mRights.Lines.Insert(0, 'НЕТ ДОСТУПА: ' + S + '.');
    if J <> 0 then
      mRights.Lines.Insert(0, 'ПРОСМОТР: ' + TgdcUserGroup.GetGroupList(J) + '.');
    if K <> 0 then
      mRights.Lines.Insert(0, 'ИЗМЕНЕНИЕ: ' + TgdcUserGroup.GetGroupList(K) + '.');
    if F <> 0 then
      mRights.Lines.Insert(0, 'ПОЛНЫЙ ДОСТУП: ' + TgdcUserGroup.GetGroupList(F) + '.');
    mRights.SelStart := 0;
  end;
end;

procedure Tgdc_frmExplorer.actDistrChildExecute(Sender: TObject);
var
  OldUpdateChildren: Boolean;
  OldCursor: TCursor;
begin
  OldUpdateChildren := UpdateChildren_Global;
  OldCursor := Screen.Cursor;
  gdcObject.DisableControls;
  try
    Screen.Cursor := crHourGlass;
    UpdateChildren_Global := True;
    gdcObject.Edit;
    gdcObject.Post;

    gdcObject.Close;
    gdcObject.Open;
  finally
    UpdateChildren_Global := OldUpdateChildren;
    Screen.Cursor := OldCursor;
    gdcObject.EnableControls;
  end;
end;

procedure Tgdc_frmExplorer.actDistrAllUpdate(Sender: TObject);
begin
  actDistrAll.Enabled := not gdcObject.IsEmpty;
end;

procedure Tgdc_frmExplorer.actDistrAllExecute(Sender: TObject);
var
  OldUpdateChildren: Boolean;
  OldCursor: TCursor;
  Bm: String;
  F, C, V: Integer;
begin
  OldUpdateChildren := UpdateChildren_Global;
  OldCursor := Screen.Cursor;
  gdcObject.DisableControls;
  try
    Screen.Cursor := crHourGlass;
    UpdateChildren_Global := True;

    F := gdcObject.FieldByName('afull').AsInteger;
    C := gdcObject.FieldByName('achag').AsInteger;
    V := gdcObject.FieldByName('aview').AsInteger;

    Bm := gdcObject.Bookmark;
    if gdcObject.Locate('id', 710000, []) then
    begin
      gdcObject.Edit;
      gdcObject.FieldByName('afull').AsInteger := F;
      gdcObject.FieldByName('achag').AsInteger := C;
      gdcObject.FieldByName('aview').AsInteger := V;
      gdcObject.Post;

      gdcObject.Close;
      gdcObject.Open;
    end;
  finally
    UpdateChildren_Global := OldUpdateChildren;
    Screen.Cursor := OldCursor;
    gdcObject.EnableControls;
  end;
end;

initialization
  RegisterFrmClass(Tgdc_frmExplorer);

finalization
  UnRegisterFrmClass(Tgdc_frmExplorer);
end.

