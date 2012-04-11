//

unit gdc_frmMDHGR_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDH_unit, ExtCtrls, IBDatabase, Db, flt_sqlFilter,
  Menus, ActnList,  ComCtrls, ToolWin, Grids, DBGrids, gsDBGrid, gsIBGrid,
  FrmPlSvr, IBCustomDataSet, gdcBase, gdcConst, TB2Item, TB2Dock,
  TB2Toolbar, StdCtrls, gd_MacrosMenu;

type
  Tgdc_frmMDHGR = class(Tgdc_frmMDH)
    ibgrMain: TgsIBGrid;
    ibgrDetail: TgsIBGrid;
    procedure ibgrMainAggregateChanged(Sender: TObject);
    procedure sbMainClick(Sender: TObject);
    procedure ibgrMainEnter(Sender: TObject);
    procedure ibgrDetailEnter(Sender: TObject);
    procedure ibgrDetailDblClick(Sender: TObject);
    procedure ibgrMainDblClick(Sender: TObject);
    procedure ibgrMainKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ibgrDetailKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure actFindExecute(Sender: TObject);
    procedure actDetailFindExecute(Sender: TObject);
    procedure actAddToSelectedExecute(Sender: TObject);
    procedure actRemoveFromSelectedExecute(Sender: TObject);
    procedure ibgrMainClickCheck(Sender: TObject; CheckID: String;
      var Checked: Boolean);
    procedure ibgrDetailClickCheck(Sender: TObject; CheckID: String;
      var Checked: Boolean);
    procedure actDetailEditExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actDuplicateExecute(Sender: TObject);
    procedure actDetailDuplicateExecute(Sender: TObject);
    procedure actSaveToFileExecute(Sender: TObject);
    procedure actDetailSaveToFileExecute(Sender: TObject);
    procedure actCopySettingsFromUserExecute(Sender: TObject);
    procedure actSearchMainExecute(Sender: TObject);
    procedure actSearchDetailExecute(Sender: TObject);
    procedure actMainReductionExecute(Sender: TObject);
    procedure actDetailReductionExecute(Sender: TObject);
    procedure actEditInGridUpdate(Sender: TObject);
    procedure actEditInGridExecute(Sender: TObject);
    procedure actDetailEditInGridUpdate(Sender: TObject);
    procedure actDetailEditInGridExecute(Sender: TObject);
    procedure actNewExecute(Sender: TObject);
    procedure actDetailNewExecute(Sender: TObject);

  protected
    procedure DeleteChoose(AnID: Integer); override;

  public
    function GetMainBookmarkList: TBookmarkList; override;
    function GetDetailBookmarkList: TBookmarkList; override;

    procedure LoadSettings; override;
    procedure SaveSettings; override;

    function Get_SelectedKey: OleVariant; override;
  end;

var
  gdc_frmMDHGR: Tgdc_frmMDHGR;

implementation

{$R *.DFM}

{ Tgdc_frmMDHGR }

uses
  Storages, gdcClasses,  gd_ClassList
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  , gdc_frmStreamSaver;

procedure Tgdc_frmMDHGR.LoadSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMMDHGR', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMMDHGR', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMMDHGR') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMMDHGR',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMMDHGR' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if Assigned(UserStorage) then
  begin
    UserStorage.LoadComponent(ibgrMain, ibgrMain.LoadFromStream);
    UserStorage.LoadComponent(ibgrDetail, ibgrDetail.LoadFromStream);
  end;  

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMMDHGR', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMMDHGR', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmMDHGR.SaveSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMMDHGR', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMMDHGR', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMMDHGR') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMMDHGR',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMMDHGR' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if Assigned(UserStorage) then
  begin
    SaveGrid(ibgrMain);
    SaveGrid(ibgrDetail);
  end;    

  inherited;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMMDHGR', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMMDHGR', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

function Tgdc_frmMDHGR.Get_SelectedKey: OleVariant;
{var
  I: Integer;
  MasterA, DetailA: Variant;}
begin
{  if not (gdcObject.Active and (gdcObject.RecordCount > 0)) then
    MasterA := VarArrayOf([])
  else
    if ibgrMain.SelectedRows.Count = 0 then
      MasterA := VarArrayOf([gdcObject.ID])
    else
    begin
      MasterA := VarArrayCreate([0, ibgrMain.SelectedRows.Count - 1], varVariant);
        for I := 0 to ibgrMain.SelectedRows.Count - 1 do
        begin
          MasterA[I] := gdcObject.GetIDForBookmark(ibgrMain.SelectedRows.Items[I]);
        end;
    end;

  if not (gdcDetailObject.Active and (gdcDetailObject.RecordCount > 0)) then
    DetailA := VarArrayOf([])
  else
    if ibgrDetail.SelectedRows.Count = 0 then
      DetailA := VarArrayOf([gdcDetailObject.ID])
    else
    begin
      DetailA := VarArrayCreate([0, ibgrDetail.SelectedRows.Count - 1], varVariant);
      for I := 0 to ibgrDetail.SelectedRows.Count - 1 do
      begin
        DetailA[I] := gdcDetailObject.GetIDForBookmark(ibgrDetail.SelectedRows.Items[I]);
      end;
    end;}
    
  Result := VarArrayOf([CreateSelectedArr(gdcObject, ibgrMain.SelectedRows),
    CreateSelectedArr(gdcDetailObject, ibgrDetail.SelectedRows)])
end;

procedure Tgdc_frmMDHGR.ibgrMainAggregateChanged(Sender: TObject);
begin
  //sbMain.Panels[1].Text := (Sender as TgsIBGrid).Aggregate.AggregateText;
end;

function Tgdc_frmMDHGR.GetMainBookmarkList: TBookmarkList;
var
  I: Integer;
begin
  Result := ibgrMain.SelectedRows;
  if (ibgrMain.DataSource <> nil)
    and (ibgrMain.DataSource.DataSet = gdcObject) then
  begin
    if (Result.Count = 1) and (gdcObject.Bookmark <> Result[0]) then
    begin
      Result.Clear;
      Result.CurrentRowSelected := True;
    end
    else if Result.Count > 1 then
    begin
      for I := 0 to Result.Count - 1 do
      begin
        if gdcObject.Bookmark = Result[I] then
        begin
          exit;
        end;
      end;
      Result.CurrentRowSelected := True;
    end;
  end;
end;

function Tgdc_frmMDHGR.GetDetailBookmarkList: TBookmarkList;
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

procedure Tgdc_frmMDHGR.sbMainClick(Sender: TObject);
begin
  {if ibgrDetail.Focused then
    ibgrDetail.Aggregate.PopupMenu(-1, -1)
  else
    ibgrMain.Aggregate.PopupMenu(-1, -1);}
end;

procedure Tgdc_frmMDHGR.ibgrMainEnter(Sender: TObject);
begin
  inherited;
  SetShortCut(True);
end;

procedure Tgdc_frmMDHGR.ibgrDetailEnter(Sender: TObject);
begin
  inherited;
  SetShortCut(False);
end;

procedure Tgdc_frmMDHGR.ibgrDetailDblClick(Sender: TObject);
const
  Counter: Integer = 0;
begin
  if (ibgrDetail.GridCoordFromMouse.X >= 0) and
     (ibgrDetail.GridCoordFromMouse.Y >= 0) and
     Assigned(gdcDetailObject) then
  begin
    if (not actDetailEditInGrid.Checked) then
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
          PChar('В настоящий момент режим "Редактирование в таблице" включен.'#13#10 +
          'Для того, чтобы по двойному щелчку мыши открывалось диалоговое окно '#13#10 +
          'изменения записи, необходимо выключить этот режим.'#13#10 +
          'Нажмите соответствующую кнопку на панели инструментов.'),
          'Внимание',
          MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
      end;
    end;
  end;
end;

procedure Tgdc_frmMDHGR.ibgrMainDblClick(Sender: TObject);
const
  Counter: Integer = 0;
begin
  if (ibgrMain.GridCoordFromMouse.X >= 0) and
     (ibgrMain.GridCoordFromMouse.Y >= 0)
     and Assigned(gdcObject) then
  begin
    if (not actEditInGrid.Checked) then
    begin
      if gdcObject.IsEmpty then
        actNew.Execute
      else
        actEdit.Execute;
    end else
    begin
      Inc(Counter);
      if Counter > 2 then
      begin
        MessageBox(Handle,
          PChar('В настоящий момент режим "Редактирование в таблице" включен.'#13#10 +
          'Для того, чтобы по двойному щелчку мыши открывалось диалоговое окно '#13#10 +
          'изменения записи, необходимо выключить этот режим.'#13#10 +
          'Нажмите соответствующую кнопку на панели инструментов.'),
          'Внимание',
          MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
      end;
    end;
  end;
end;

procedure Tgdc_frmMDHGR.ibgrMainKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_RETURN)
    and (Shift = [])
    and Assigned(gdcObject)
    and (gdcObject.State = dsBrowse)
    and (not ibgrMain.EditorMode)
    and (ibgrMain.ReadOnly or (not (dgEditing in ibgrMain.Options))) then
  begin
    if gdcObject.IsEmpty then
      actNew.Execute
    else
      actEdit.Execute;
  end;
end;

procedure Tgdc_frmMDHGR.ibgrDetailKeyDown(Sender: TObject; var Key: Word;
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

procedure Tgdc_frmMDHGR.actFindExecute(Sender: TObject);
begin
  SetLocalizeListName(ibgrMain);
  inherited;
end;

procedure Tgdc_frmMDHGR.actDetailFindExecute(Sender: TObject);
begin
  SetLocalizeListName(ibgrDetail);
  inherited;
end;

procedure Tgdc_frmMDHGR.actAddToSelectedExecute(Sender: TObject);
begin
  gdcObject.AddToSelectedID(ibgrMain.SelectedRows);
end;

procedure Tgdc_frmMDHGR.actRemoveFromSelectedExecute(Sender: TObject);
begin
  gdcObject.RemoveFromSelectedID(ibgrMain.SelectedRows);
end;

procedure Tgdc_frmMDHGR.ibgrMainClickCheck(Sender: TObject;
  CheckID: String; var Checked: Boolean);
begin
  inherited;
  if FInChoose and (FgdcLinkChoose = gdcObject) then
    try
      if Checked then
        AddToChooseObject(StrToInt(CheckID))
      else
        DeleteFromChooseObject(StrToInt(CheckID));
    except
      raise Exception.Create('Ошибка при выборе записи. Неверный id: '+ CheckID);
    end;

end;

procedure Tgdc_frmMDHGR.ibgrDetailClickCheck(Sender: TObject;
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
      raise Exception.Create('Ошибка при выборе записи. Неверный id: '+ CheckID);
    end;

end;

procedure Tgdc_frmMDHGR.DeleteChoose(AnID: Integer);
begin
  if FgdcLinkChoose = gdcObject then
  begin
    ibgrMain.CheckBox.DeleteCheck(AnID);
    gdcObject.RemoveFromSelectedID(AnID);
  end else
  begin
    ibgrDetail.CheckBox.DeleteCheck(AnID);
    gdcDetailObject.RemoveFromSelectedID(AnID);
  end;
end;

procedure Tgdc_frmMDHGR.actDetailEditExecute(Sender: TObject);
begin
  if (dgEditing in ibgrDetail.Options) and (gdcDetailObject.State = dsEdit) then
    gdcDetailObject.Post;

  inherited;
end;

procedure Tgdc_frmMDHGR.actEditExecute(Sender: TObject);
begin
  if (dgEditing in ibgrMain.Options) and (gdcObject.State = dsEdit) then
    gdcObject.Post;

  inherited;
end;

procedure Tgdc_frmMDHGR.actDuplicateExecute(Sender: TObject);
begin
  if (dgEditing in ibgrMain.Options) and (gdcObject.State = dsEdit) then
    gdcObject.Post;

  inherited;
end;

procedure Tgdc_frmMDHGR.actDetailDuplicateExecute(Sender: TObject);
begin
  if (dgEditing in ibgrDetail.Options) and (gdcDetailObject.State = dsEdit) then
    gdcDetailObject.Post;

  inherited;
end;

procedure Tgdc_frmMDHGR.actSaveToFileExecute(Sender: TObject);
var
  frmStreamSaver: TForm;
begin
  frmStreamSaver := Tgdc_frmStreamSaver.CreateAndAssign(Self);
  if ibgrMain.SelectedRows.Count > 0 then
    //gdcObject.SaveToFile('', gdcDetailObject, ibgrMain.SelectedRows, False)
    (frmStreamSaver as Tgdc_frmStreamSaver).SetParams(gdcObject, gdcDetailObject, ibgrMain.SelectedRows, False)
  else
    //gdcObject.SaveToFile('', gdcDetailObject);
    (frmStreamSaver as Tgdc_frmStreamSaver).SetParams(gdcObject, gdcDetailObject);
  (frmStreamSaver as Tgdc_frmStreamSaver).ShowSaveForm;
end;

procedure Tgdc_frmMDHGR.actDetailSaveToFileExecute(Sender: TObject);
var
  frmStreamSaver: TForm;
begin
  frmStreamSaver := Tgdc_frmStreamSaver.CreateAndAssign(Self);
  if ibgrDetail.SelectedRows.Count > 0 then
    //gdcDetailObject.SaveToFile('', nil, ibgrDetail.SelectedRows, False)
    (frmStreamSaver as Tgdc_frmStreamSaver).SetParams(gdcDetailObject, nil, ibgrDetail.SelectedRows, False)
  else
    //gdcDetailObject.SaveToFile;
    (frmStreamSaver as Tgdc_frmStreamSaver).SetParams(gdcDetailObject);
  (frmStreamSaver as Tgdc_frmStreamSaver).ShowSaveForm;
end;

procedure Tgdc_frmMDHGR.actCopySettingsFromUserExecute(Sender: TObject);
begin
  inherited;

  ibgrMain.SettingsModified := True;
  ibgrDetail.SettingsModified := True;
end;

procedure Tgdc_frmMDHGR.actSearchMainExecute(Sender: TObject);
begin
  inherited;

  if gdcObject.RecordCount > 0 then
    FocusControl(ibgrMain);
end;

procedure Tgdc_frmMDHGR.actSearchDetailExecute(Sender: TObject);
begin
  inherited;

  if gdcDetailObject.RecordCount > 0 then
    FocusControl(ibgrDetail);
end;

procedure Tgdc_frmMDHGR.actMainReductionExecute(Sender: TObject);
begin
  gdcObject.Reduction(ibgrMain.SelectedRows);
end;

procedure Tgdc_frmMDHGR.actDetailReductionExecute(Sender: TObject);
begin
  gdcDetailObject.Reduction(ibgrDetail.SelectedRows);
end;

procedure Tgdc_frmMDHGR.actEditInGridUpdate(Sender: TObject);
begin
  actEditInGrid.Checked := Assigned(gdcObject)
    and (gdcObject.State = dsBrowse)
    and (not ibgrMain.ReadOnly)
    and (dgEditing in ibgrMain.Options);
  actEditInGrid.Enabled := Assigned(gdcObject)
    and gdcObject.CanEdit;
end;

procedure Tgdc_frmMDHGR.actEditInGridExecute(Sender: TObject);
begin
  if actEditInGrid.Checked then
  begin
    if gdcObject.State in dsEditModes then
      gdcObject.Post;

    ibgrMain.ReadOnly := True;
    ibgrMain.Options := ibgrMain.Options - [dgEditing, dgIndicator];
  end else
  begin
    ibgrMain.ReadOnly := False;
    ibgrMain.Options := ibgrMain.Options + [dgEditing, dgIndicator];
  end;
  ibgrMain.SettingsModified := True;
end;

procedure Tgdc_frmMDHGR.actDetailEditInGridUpdate(Sender: TObject);
begin
  actDetailEditInGrid.Checked := Assigned(gdcDetailObject)
    and ((gdcDetailObject.State = dsBrowse) or ibgrDetail.EditorMode)
    and (not ibgrDetail.ReadOnly)
    and (dgEditing in ibgrDetail.Options);
  actDetailEditInGrid.Enabled := Assigned(gdcDetailObject)
    and gdcDetailObject.CanEdit;
end;

procedure Tgdc_frmMDHGR.actDetailEditInGridExecute(Sender: TObject);
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

procedure Tgdc_frmMDHGR.actNewExecute(Sender: TObject);
var
  OldID: Integer;
begin
  if not gdcObject.IsEmpty then
    OldID := gdcObject.ID
  else
    OldID := -1;

  inherited;

  if OldID <> gdcObject.ID then
  begin
    if ibgrMain.SelectedRows.Count > 0 then
      ibgrMain.SelectedRows.Clear;
  end;
end;

procedure Tgdc_frmMDHGR.actDetailNewExecute(Sender: TObject);
var
  OldID: Integer;
begin
  if not gdcDetailObject.IsEmpty then
    OldID := gdcDetailObject.ID
  else
    OldID := -1;

  inherited;

  if OldID <> gdcDetailObject.ID then
  begin
    if ibgrDetail.SelectedRows.Count > 0 then
      ibgrDetail.SelectedRows.Clear;
  end;
end;

initialization
  RegisterFrmClass(Tgdc_frmMDHGR);

finalization
  UnRegisterFrmClass(Tgdc_frmMDHGR);

end.
