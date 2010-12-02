//

unit gdc_frmMDVTree_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDH_unit, IBDatabase, Db, gsReportManager, flt_sqlFilter, Menus,
  ActnList,  ComCtrls, ToolWin, ExtCtrls, Grids, DBGrids, gsDBGrid,
  gsIBGrid, gsDBTreeView, gdc_frmMDV_unit, gdcBase, IBCustomDataSet,
  gdcConst, ImgList, TB2Item, TB2Dock, TB2Toolbar, StdCtrls, gd_MacrosMenu;
             
type
  Tgdc_frmMDVTree = class(Tgdc_frmMDV)
    tvGroup: TgsDBTreeView;
    ibgrDetail: TgsIBGrid;
    actShowSubGroups: TAction;
    tbi_mm_ShowSubGroups: TTBItem;
    tbi_mm_sep5: TTBSeparatorItem;
    actAllowDragnDrop: TAction;
    tbi_mm_AllowDragnDrop: TTBItem;
    procedure ibgrDetailMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ibgrDetailDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ibgrDetailStartDrag(Sender: TObject;
      var DragObject: TDragObject);
    procedure tvGroupDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure tvGroupEnter(Sender: TObject);
    procedure ibgrDetailEnter(Sender: TObject);
    procedure ibgrDetailDblClick(Sender: TObject);
    procedure actDetailNewExecute(Sender: TObject);
    procedure ibgrDetailKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tvGroupDblClick(Sender: TObject);
    procedure actDetailFindExecute(Sender: TObject);
    procedure actShowSubGroupsExecute(Sender: TObject);
    procedure actShowSubGroupsUpdate(Sender: TObject);
    procedure ibgrDetailClickCheck(Sender: TObject; CheckID: String;
      var Checked: Boolean);
    procedure tvGroupClickCheck(Sender: TObject; CheckID: Integer;
      var Checked: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure tvGroupStartDrag(Sender: TObject;
      var DragObject: TDragObject);
    procedure tvGroupDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ibgrDetailDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure actDetailEditExecute(Sender: TObject);
    procedure actDetailDuplicateExecute(Sender: TObject);
    procedure actDetailSaveToFileExecute(Sender: TObject);
    procedure actCopySettingsFromUserExecute(Sender: TObject);
    procedure actSearchDetailExecute(Sender: TObject);
    procedure actSearchMainExecute(Sender: TObject);
    procedure actDetailReductionExecute(Sender: TObject);
    procedure actDetailEditInGridUpdate(Sender: TObject);
    procedure actDetailEditInGridExecute(Sender: TObject);

    procedure SwitchSubGroups(const F: Boolean);
    function SubGroupsChecked: Boolean;
    procedure SetDragnDropState(const F: Boolean); 
    function DragnDropAllowed: Boolean;
    procedure actEditExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actAllowDragnDropExecute(Sender: TObject);
    procedure tvGroupClickedCheck(Sender: TObject; CheckID: String;
      Checked: Boolean);

  protected
    ByLBRBSubSetName, ByParentSubSetName, ByLBRBContrSubSetName: String;
    ByLBRBDetailField, ByLBRBMasterField: String;
    ByParentDetailField, ByParentMasterField: String;

    procedure DeleteChoose(AnID: Integer); override;
//    function OnInvoker(const Name: WideString; AnParams: OleVariant): OleVariant; override;

  public
    constructor Create(AnOwner: TComponent); override;
    constructor CreateUser(AnOwner: TComponent; const AFormName: String; const ASubType: String = ''; const AForEdit: Boolean = False); override;

    function GetDetailBookmarkList: TBookmarkList; override;
    function Get_SelectedKey: OleVariant; override; safecall;

    procedure LoadSettings; override;
    procedure LoadSettingsAfterCreate; override;
    procedure SaveSettings; override;

    procedure SetChoose(AnObject: TgdcBase); override;
  end;

var
  gdc_frmMDVTree: Tgdc_frmMDVTree;

implementation

{$R *.DFM}

uses
  gdcTree, gd_security, dmDataBase_unit, gsStorage_CompPath,
  Storages,  gd_ClassList, gdcBaseInterface, Contnrs, prp_methods
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  , gdc_frmStreamSaver;

function Tgdc_frmMDVTree.Get_SelectedKey: OleVariant;
var
  MasterA: Variant;
  I, K, Count: Integer;
begin
  Count := 0;
  for I := 0 to tvGroup.Items.Count - 1 do
    if tvGroup.Items[I].StateIndex = 1 then
      Inc(Count);
  if Count > 0 then
  begin
    MasterA := VarArrayCreate([0, Count - 1], varVariant);

    K := 0;
    for I := 0 to tvGroup.Items.Count - 1 do
    begin
      if tvGroup.Items[I].StateIndex = 1 then
      begin
        MasterA[K] := Integer(tvGroup.Items[I].Data);
        Inc(K);
      end;
    end;  
  end else
    MasterA := VarArrayOf([]);

{  if not (gdcDetailObject.Active and (gdcDetailObject.RecordCount > 0)) then
    DetailA := VarArrayOf([])
  else
    if ibgrDetail.SelectedRows.Count = 0 then
    begin
      DetailA := VarArrayCreate([0, 0], varVariant);
      DetailA[0] := gdcDetailObject.ID;
    end
    else
    begin
      DetailA := VarArrayCreate([0, ibgrDetail.SelectedRows.Count - 1], varVariant);

      for I := 0 to ibgrDetail.SelectedRows.Count - 1 do
      begin
        DetailA[I] := gdcDetailObject.GetIDForBookmark(ibgrDetail.SelectedRows.Items[I]);
      end;
    end;}

  Result := VarArrayOf([MasterA,
    CreateSelectedArr(gdcDetailObject, ibgrDetail.SelectedRows)]);
end;

function Tgdc_frmMDVTree.GetDetailBookmarkList: TBookmarkList;
var
  I: Integer;
begin
  Result := ibgrDetail.SelectedRows;
  if (ibgrDetail.DataSource <> nil)
    and (ibgrDetail.DataSource.DataSet = gdcDetailObject) then
  begin
    if (Result.Count = 1) and (gdcDetailObject.Bookmark <> Result[0]) then
    begin
      Result.Clear;
      Result.CurrentRowSelected := True;
    end
    else if Result.Count > 1 then
    begin
      for I := 0 to Result.Count - 1 do
      begin
        if gdcDetailObject.Bookmark = Result[I] then
        begin
          exit;
        end;
      end;
      Result.CurrentRowSelected := True;
    end;
  end;
end;

procedure Tgdc_frmMDVTree.LoadSettings;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  MS: TMemoryStream;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMMDVTREE', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMMDVTREE', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMMDVTREE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMMDVTREE',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMMDVTREE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if UserStorage <> nil then
  begin
    LoadGrid(ibgrDetail);

    MS := TMemoryStream.Create;
    try
      if UserStorage.ReadStream(BuildComponentPath(tvGroup), 'TVState', MS) then
        tvGroup.LoadFromStream(MS);
    finally
      MS.Free;
    end;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMMDVTREE', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMMDVTREE', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmMDVTree.SaveSettings;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  MS: TMemoryStream;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMMDVTREE', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMMDVTREE', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMMDVTREE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMMDVTREE',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMMDVTREE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if UserStorage <> nil then
  begin
    UserStorage.WriteBoolean(BuildComponentPath(Self), 'ShSG', SubGroupsChecked);
    UserStorage.WriteBoolean(BuildComponentPath(Self), 'AllowDD', DragnDropAllowed);

    SaveGrid(ibgrDetail);

    if FInChoose and ibgrChoose.SettingsModified then
      UserStorage.SaveComponent(ibgrChoose, ibgrChoose.SaveToStream);

    if not FInChoose then
    begin
      MS := TMemoryStream.Create;
      try
        tvGroup.TVState.Checked.Clear;
        tvGroup.SaveToStream(MS);
        UserStorage.WriteStream(BuildComponentPath(tvGroup), 'TVState', MS);
      finally
        MS.Free;
      end;
    end;
  end;

  inherited;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMMDVTREE', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMMDVTREE', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmMDVTree.ibgrDetailMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
{const
  PrevX: Integer = 0;
  PrevY: Integer = 0;
  InDragWait: Boolean = False;}
begin
{ TODO : плохо прописывать высоту заголовка грида непосредственной константой }
                                        
  if (ssLeft in Shift) and (Y > 20) and DragnDropAllowed then
  begin
    ibgrDetail.BeginDrag(False, 10);
  end;
  
{  if (ssLeft in Shift) then
  begin
    if Y > 20 then
    begin
      if InDragWait and (Abs(X - PrevX) > 1) and (Abs(Y - PrevY) > 1) then
      begin
        InDragWait := False;
        ibgrDetail.BeginDrag(False);
      end else
      begin
        InDragWait := True;
        PrevX := X;
        PrevY := Y;
      end;
    end else
      InDragWait := False;
  end else
    InDragWait := False;}
end;


procedure Tgdc_frmMDVTree.ibgrDetailDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  GdcDragOver(gdcDetailObject, Sender, Source, X, Y, State, Accept);
end;

procedure Tgdc_frmMDVTree.ibgrDetailStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
  if CanStartDrag(gdcDetailObject) then
  begin
    DragObject := TgdcDragObject.Create;
    TgdcDragObject(DragObject).SourceControl := ibgrDetail;
    gdcDetailObject.CopyToClipboard(GetDetailBookmarkList, cCut);
  end;
end;

procedure Tgdc_frmMDVTree.tvGroupDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  GdcDragOver(gdcObject, Sender, Source, X, Y, State, Accept);
end;

procedure Tgdc_frmMDVTree.tvGroupEnter(Sender: TObject);
begin
  inherited;
  SetShortCut(True);
end;

procedure Tgdc_frmMDVTree.ibgrDetailEnter(Sender: TObject);
begin
  inherited;
  SetShortCut(False);
end;

procedure Tgdc_frmMDVTree.ibgrDetailDblClick(Sender: TObject);
const
  Counter: Integer = 0;
begin
  if (ibgrDetail.GridCoordFromMouse.X >= 0) and
     (ibgrDetail.GridCoordFromMouse.Y >= 0) and
     Assigned(gdcDetailObject) then
  begin
    if not actDetailEditInGrid.Checked then
    begin
      if gdcDetailObject.IsEmpty then
        actDetailNew.Execute
      else
        actDetailEdit.Execute;
    end else
    begin
      Inc(Counter);
      if Counter > 2 then
      begin
        MessageBox(Handle,
          PChar('¬ насто€щий момент режим "–едактирование в таблице" включен.'#13#10 +
          'ƒл€ того, чтобы по двойному щелчку мыши открывалось диалоговое окно '#13#10 +
          'изменени€ записи, необходимо выключить этот режим.'#13#10 +
          'Ќажмите соответствующую кнопку на панели инструментов.'),
          '¬нимание',
          MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
      end;
    end;
  end;
end;

procedure Tgdc_frmMDVTree.actDetailNewExecute(Sender: TObject);
var
  OldID: Integer;
begin
  if not gdcDetailObject.IsEmpty then
    OldID := gdcDetailObject.ID
  else
    OldID := -1;

  gdcDetailObject.CreateDescendant;

  if OldID <> gdcDetailObject.ID then
  begin
    if ibgrDetail.SelectedRows.Count > 0 then
      ibgrDetail.SelectedRows.Clear;
  end;
end;

procedure Tgdc_frmMDVTree.ibgrDetailKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_RETURN)
    and (Shift = [])
    and Assigned(gdcDetailObject)
    and (gdcDetailObject.State = dsBrowse)
    and (not ibgrDetail.EditorMode)
    and (ibgrDetail.ReadOnly or (not (dgEditing in ibgrDetail.Options))) then
  begin
    if gdcDetailObject.IsEmpty then
      actDetailNew.Execute
    else
      actDetailEdit.Execute;
  end;
end;

procedure Tgdc_frmMDVTree.tvGroupDblClick(Sender: TObject);
begin
  if Assigned(tvGroup.Selected) then
  begin
    if PtInRect(tvGroup.Selected.DisplayRect(True),
      tvGroup.ScreenToClient(Mouse.CursorPos)) then
    begin
      actEdit.Execute;
    end;
  end;
end;

procedure Tgdc_frmMDVTree.actDetailFindExecute(Sender: TObject);
begin
  SetLocalizeListName(ibgrDetail);
  inherited;
end;

procedure Tgdc_frmMDVTree.actShowSubGroupsExecute(Sender: TObject);
begin
  SwitchSubGroups(not SubGroupsChecked);
end;

procedure Tgdc_frmMDVTree.actShowSubGroupsUpdate(Sender: TObject);
begin
  actShowSubGroups.Enabled := (gdcObject <> nil)
    and (gdcObject.State = dsBrowse)
    and (gdcObject is TgdcLBRBTree)
    and (gdcDetailObject <> nil)
    and (gdcDetailObject.CheckSubSet(ByLBRBSubSetName))
    and (gdcDetailObject.CheckSubSet(ByParentSubSetName))
    and (not gdcDetailObject.HasSubSet('All'));
  actShowSubGroups.Checked := SubGroupsChecked;
end;

constructor Tgdc_frmMDVTree.Create(AnOwner: TComponent);
begin
  inherited;
  if GlobalStorage.ReadBoolean('Options', 'ByLBRB', False, False) then
  begin
    ByLBRBSubSetName := 'ByLBRB';
    ByLBRBContrSubSetName := 'ByRootID';
    ByLBRBMasterField := 'LB;RB';
    ByLBRBDetailField := 'LB;RB';
  end else
  begin
    ByLBRBSubSetName := 'ByRootID';
    ByLBRBContrSubSetName := 'ByLBRB';
    ByLBRBMasterField := 'ID';
    ByLBRBDetailField := 'RootID';
  end;
  ByParentSubSetName := 'ByParent';
  ByParentMasterField := 'ID';
  ByParentDetailField := 'PARENT';
                         
//  AllowDragnDrop := True;
end;

procedure Tgdc_frmMDVTree.LoadSettingsAfterCreate;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMMDVTREE', 'LOADSETTINGSAFTERCREATE', KEYLOADSETTINGSAFTERCREATE)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMMDVTREE', KEYLOADSETTINGSAFTERCREATE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGSAFTERCREATE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMMDVTREE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMMDVTREE',
  {M}          'LOADSETTINGSAFTERCREATE', KEYLOADSETTINGSAFTERCREATE, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMMDVTREE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if UserStorage <> nil then
  begin                                                                       
    SwitchSubGroups(UserStorage.ReadBoolean(BuildComponentPath(Self), 'ShSG', True));    
    SetDragnDropState(UserStorage.ReadBoolean(BuildComponentPath(Self), 'AllowDD', True));
  end;                        

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMMDVTREE', 'LOADSETTINGSAFTERCREATE', KEYLOADSETTINGSAFTERCREATE)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMMDVTREE', 'LOADSETTINGSAFTERCREATE', KEYLOADSETTINGSAFTERCREATE);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmMDVTree.ibgrDetailClickCheck(Sender: TObject;
  CheckID: String; var Checked: Boolean);
begin
  inherited;
  if FInChoose and (FgdcLinkChoose = gdcDetailObject) then
    try
      if Checked then
        AddToChooseObject(StrToInt(CheckID))
      else
        DeleteFromChooseObject(StrToInt(CheckID));
    except
      raise Exception.Create('ќшибка при выборе записи. Ќеверный id: '+ CheckID);
    end;
end;

procedure Tgdc_frmMDVTree.DeleteChoose(AnID: Integer);
begin
  if FgdcLinkChoose = gdcObject then
  begin
    tvGroup.DeleteCheck(AnID);
    gdcObject.RemoveFromSelectedID(AnID);
  end else
  begin
    ibgrDetail.CheckBox.DeleteCheck(AnID);
    gdcDetailObject.RemoveFromSelectedID(AnID);
  end;
end;

procedure Tgdc_frmMDVTree.tvGroupClickCheck(Sender: TObject;
  CheckID: Integer; var Checked: Boolean);
begin
  inherited;
  if FInChoose and (FgdcLinkChoose = gdcObject) then
    try
      if Checked then
        AddToChooseObject(CheckID)
      else
        DeleteFromChooseObject(CheckID);
    except
      raise Exception.Create('ќшибка при выборе записи. Ќеверный id: '+ IntToStr(CheckID));
    end;
end;

procedure Tgdc_frmMDVTree.FormCreate(Sender: TObject);
var
  L: TObjectList;
  I: Integer;
begin
  // смысл этого отсоединени€ датасета
  // если мастер -- дерево, то оно построитс€ после открыти€ датасета
  // если к нему подключен детальный датасет, то он откроетс€ дважды
  // первый раз когда откроетс€ датасет дерева, второй, когда
  // дерево построетс€ и в нем курсор примет запомненное положение
  // отосоедин€€ датасет мы избегаем первого открыти€
  // детального датасета
  L := TObjectList.Create(False);
  try
    for I := 0 to ComponentCount - 1 do
    begin
      if Components[I] is TgdcBase then
      begin
        if TgdcBase(Components[I]).MasterSource = dsMain then
        begin
          L.Add(Components[I]);
          TgdcBase(Components[I]).MasterSource := nil;
        end;
      end;
    end;

    inherited;

    for I := 0 to L.Count - 1 do
    begin
      TgdcBase(L[I]).MasterSource := dsMain;
    end;
  finally
    L.Free;
  end;

  FgdcLinkChoose := gdcDetailObject;
end;

procedure Tgdc_frmMDVTree.tvGroupStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin                                                
  if DragnDropAllowed and CanStartDrag(gdcObject) then
  begin
    DragObject := TgdcDragObject.Create;
    TgdcDragObject(DragObject).SourceControl := tvGroup;
    gdcObject.CopyToClipboard(nil, cCut);
  end;
end;

procedure Tgdc_frmMDVTree.tvGroupDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  OldSelected: TTreeNode;
begin
  if tvGroup.GetNodeAt(X, Y) <> nil then
  begin
    {gdcObject.DisableControls;
    try}
      OldSelected := tvGroup.Selected;
      tvGroup.Selected := tvGroup.GetNodeAt(X, Y);
      if gdcObject.PasteFromClipboard(True) then
      begin
        if OldSelected = nil then
        begin
          gdcDetailObject.Close;
          gdcDetailObject.Open;
        end;
      end;
      if OldSelected <> nil then
      begin
        try
          tvGroup.Selected := OldSelected;
        except
          gdcDetailObject.Close;
          gdcDetailObject.Open;
        end;
      end;
    {finally
      gdcObject.EnableControls;
    end;}
  end;
end;

procedure Tgdc_frmMDVTree.ibgrDetailDragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
  if Sender <> (Source as TgdcDragObject).SourceControl then
    gdcDetailObject.PasteFromClipboard;
end;

procedure Tgdc_frmMDVTree.actDetailEditExecute(Sender: TObject);
begin
  if (dgEditing in ibgrDetail.Options) and (gdcDetailObject.State = dsEdit) then
    gdcDetailObject.Post;

  inherited;
end;

procedure Tgdc_frmMDVTree.actDetailDuplicateExecute(Sender: TObject);
begin
  if (dgEditing in ibgrDetail.Options) and (gdcDetailObject.State = dsEdit) then
    gdcDetailObject.Post;

  inherited;
end;

procedure Tgdc_frmMDVTree.actDetailSaveToFileExecute(Sender: TObject);
var
  frmStreamSaver: TForm;
begin
  frmStreamSaver := Tgdc_frmStreamSaver.CreateAndAssign(Self);
  if ibgrDetail.SelectedRows.Count > 0 then
    (frmStreamSaver as Tgdc_frmStreamSaver).SetParams(gdcDetailObject, nil, ibgrDetail.SelectedRows, False)
  else
    (frmStreamSaver as Tgdc_frmStreamSaver).SetParams(gdcDetailObject);
  (frmStreamSaver as Tgdc_frmStreamSaver).ShowSaveForm;
end;

procedure Tgdc_frmMDVTree.actCopySettingsFromUserExecute(Sender: TObject);
begin
  inherited;
  ibgrDetail.SettingsModified := True;
end;

procedure Tgdc_frmMDVTree.actSearchDetailExecute(Sender: TObject);
begin
  inherited;

  if gdcDetailObject.RecordCount > 0 then
    FocusControl(ibgrDetail);
end;

procedure Tgdc_frmMDVTree.actSearchMainExecute(Sender: TObject);
begin
  inherited;

  if gdcObject.RecordCount > 0 then
    FocusControl(tvGroup);
end;

procedure Tgdc_frmMDVTree.actDetailReductionExecute(Sender: TObject);
begin
  gdcDetailObject.Reduction(ibgrDetail.SelectedRows);
end;

procedure Tgdc_frmMDVTree.actDetailEditInGridUpdate(Sender: TObject);
begin
  actDetailEditInGrid.Checked := Assigned(gdcDetailObject)
    and (gdcDetailObject.State = dsBrowse)
    and (not ibgrDetail.ReadOnly)
    and (dgEditing in ibgrDetail.Options);
  actDetailEditInGrid.Enabled := Assigned(gdcDetailObject)
    and gdcDetailObject.CanEdit;
end;

procedure Tgdc_frmMDVTree.actDetailEditInGridExecute(Sender: TObject);
begin
  if actDetailEditInGrid.Checked then
  begin
    if gdcDetailObject.State in dsEditModes then
      gdcDetailObject.Post;

    ibgrDetail.ReadOnly := True;
    ibgrDetail.Options := ibgrDetail.Options - [dgEditing, dgIndicator];
  end else
  begin
    ibgrDetail.ReadOnly := False;
    ibgrDetail.Options := ibgrDetail.Options + [dgEditing, dgIndicator];
  end;
  ibgrDetail.SettingsModified := True;
end;

procedure Tgdc_frmMDVTree.SwitchSubGroups(const F: Boolean);
begin
  if Assigned(gdcDetailObject)
    and gdcDetailObject.Active
    and gdcObject.Active
    and (gdcDetailObject.CheckSubSet(ByLBRBSubSetName))
    and (gdcDetailObject.CheckSubSet(ByParentSubSetName))
    and (not gdcDetailObject.HasSubSet('All')) then
  begin
    if F then
    begin
      if gdcDetailObject.HasSubSet(ByLBRBContrSubSetName) then
        gdcDetailObject.RemoveSubSet(ByLBRBContrSubSetName);
      if not gdcDetailObject.HasSubSet(ByLBRBSubSetName) then
      begin
        gdcDetailObject.Close;
        //gdcDetailObject.SubSet := ByLBRBSubSetName;
        gdcDetailObject.AddSubSet(ByLBRBSubSetName);
        gdcDetailObject.RemoveSubSet(ByParentSubSetName);
        gdcDetailObject.MasterField := ByLBRBMasterField;
        gdcDetailObject.DetailField := ByLBRBDetailField;
        gdcDetailObject.Open;
      end;
    end else
    begin
      if not gdcDetailObject.HasSubSet(ByParentSubSetName) then
      begin
        gdcDetailObject.Close;
        //gdcDetailObject.SubSet := ByParentSubSetName;
        gdcDetailObject.AddSubSet(ByParentSubSetName);
        gdcDetailObject.RemoveSubSet(ByLBRBSubSetName);
        gdcDetailObject.RemoveSubSet(ByLBRBContrSubSetName);
        gdcDetailObject.MasterField := ByParentMasterField;
        gdcDetailObject.DetailField := ByParentDetailField;
        gdcDetailObject.Open;
      end;
    end;
  end;
end;

function Tgdc_frmMDVTree.SubGroupsChecked: Boolean;
begin
  Result := Assigned(gdcDetailObject)
    and gdcDetailObject.Active
    and gdcObject.Active
    and gdcDetailObject.HasSubSet(ByLBRBSubSetName)
end;


procedure Tgdc_frmMDVTree.SetDragnDropState;
begin
  // надо сделать св-во дл€ дерева и обрабатывать начало перетаскивани€ в нем
  if Assigned(actAllowDragnDrop) then
    actAllowDragnDrop.Checked := F;
end;

function Tgdc_frmMDVTree.DragnDropAllowed: Boolean;
begin
  if Assigned(actAllowDragnDrop) then
    Result := actAllowDragnDrop.Checked
  else
    Result := True;  
end;

procedure Tgdc_frmMDVTree.SetChoose(AnObject: TgdcBase);
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_SETUP('TGDC_FRMMDVTREE', 'SETCHOOSE', KEYSETCHOOSE)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_FRMMDVTREE', KEYSETCHOOSE);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETCHOOSE]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMMDVTREE') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(AnObject)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMMDVTREE',
  {M}        'SETCHOOSE', KEYSETCHOOSE, Params, LResult) then exit;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMMDVTREE' then
  {M}      begin
  {M}        Inherited;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
   inherited;
   if FgdcLinkChoose = gdcObject then
   begin
     tvGroup.TVState.Checked.Assign(FgdcLinkChoose.SelectedID);
     { TODO -oёл€ : Ќадо каким-то образом перерисовывать дерево.
     CheckBox-ы перерисовываютс€ только после перестроени€ дерева. }
     tvGroup.TVState.InitTree;
   end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMMDVTREE', 'SETCHOOSE', KEYSETCHOOSE)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMMDVTREE', 'SETCHOOSE', KEYSETCHOOSE);
  {M}end;
  {END MACRO}
end;

{function Tgdc_frmMDVTree.OnInvoker(const Name: WideString;
  AnParams: OleVariant): OleVariant;
begin
  if  AnsiUpperCase(Name) = 'REMOVESUBSETLIST' then
  begin
    RemoveSubSetList(InterfaceToObject(AnParams[1]) as TStrings)
  end else
    inherited OnInvoker(Name, AnParams);

end;}

procedure Tgdc_frmMDVTree.actEditExecute(Sender: TObject);
begin
  //
  inherited;
end;

procedure Tgdc_frmMDVTree.actDeleteExecute(Sender: TObject);
begin
  //
  inherited;
end;

constructor Tgdc_frmMDVTree.CreateUser(AnOwner: TComponent;
  const AFormName, ASubType: String; const AForEdit: Boolean);
begin
  inherited;

  if GlobalStorage.ReadBoolean('Options', 'ByLBRB', False, False) then
  begin
    ByLBRBSubSetName := 'ByLBRB';
    ByLBRBContrSubSetName := 'ByRootID';
    ByLBRBMasterField := 'LB;RB';
    ByLBRBDetailField := 'LB;RB';
  end else
  begin
    ByLBRBSubSetName := 'ByRootID';
    ByLBRBContrSubSetName := 'ByLBRB';
    ByLBRBMasterField := 'ID';
    ByLBRBDetailField := 'RootID';
  end;

  ByParentSubSetName := 'ByParent';
  ByParentMasterField := 'ID';
  ByParentDetailField := 'PARENT';

end;

procedure Tgdc_frmMDVTree.actAllowDragnDropExecute(Sender: TObject);
begin
  if Assigned(actAllowDragnDrop) then
    SetDragnDropState(not actAllowDragnDrop.Checked);
end;                     

procedure Tgdc_frmMDVTree.tvGroupClickedCheck(Sender: TObject;
  CheckID: String; Checked: Boolean);
begin
  inherited;

  if FInChoose and (FgdcLinkChoose = gdcObject) then
  begin
    try
      if Checked then
        AddToChooseObject(StrToInt(CheckID))
      else
        DeleteFromChooseObject(StrToInt(CheckID));
    except
      raise Exception.Create('ќшибка при выборе записи. Ќеверный id: '+ CheckID);
    end;
  end;  
end;

initialization
  RegisterFrmClass(Tgdc_frmMDVTree);

finalization
  UnRegisterFrmClass(Tgdc_frmMDVTree);
end.

