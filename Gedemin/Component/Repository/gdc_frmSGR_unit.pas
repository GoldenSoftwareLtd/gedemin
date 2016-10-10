//

unit gdc_frmSGR_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmG_unit, Grids, DBGrids, gsDBGrid, gsIBGrid, IBDatabase, Db,
  gsReportManager, flt_sqlFilter, Menus, ActnList,
  ComCtrls, ToolWin, ExtCtrls, FrmPlSvr, IBCustomDataSet, gdcBase, gdcConst,
  TB2Item, TB2Dock, TB2Toolbar, StdCtrls, gd_MacrosMenu;

type
  Tgdc_frmSGR = class(Tgdc_frmG)
    ibgrMain: TgsIBGrid;
    procedure ibgrMainDblClick(Sender: TObject);
    procedure ibgrMainMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ibgrMainStartDrag(Sender: TObject;
      var DragObject: TDragObject);
    procedure ibgrMainDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ibgrMainDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ibgrMainKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure actFindExecute(Sender: TObject);
    procedure actAddToSelectedExecute(Sender: TObject);
    procedure actRemoveFromSelectedExecute(Sender: TObject);
    procedure ibgrMainClickCheck(Sender: TObject; CheckID: String;
      var Checked: Boolean);
    procedure actEditExecute(Sender: TObject);
    procedure actDuplicateExecute(Sender: TObject);
    procedure actSaveToFileExecute(Sender: TObject);
    procedure actCopySettingsFromUserExecute(Sender: TObject);
    procedure actSearchMainExecute(Sender: TObject);
    procedure actMainReductionExecute(Sender: TObject);
    procedure actEditInGridUpdate(Sender: TObject);
    procedure actEditInGridExecute(Sender: TObject);
    procedure actNewExecute(Sender: TObject);

  protected
    procedure DeleteChoose(AnID: Integer); override;    

  public
    function GetMainBookmarkList: TBookmarkList; override;

    function Get_SelectedKey: OleVariant; override;
    procedure LoadSettings; override;
    procedure SaveSettings; override;
  end;

var
  gdc_frmSGR: Tgdc_frmSGR;

implementation

{$R *.DFM}

uses
  Storages, gdcClasses, gd_ClassList, gdcBaseInterface
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  , gdc_frmStreamSaver;

function Tgdc_frmSGR.Get_SelectedKey: OleVariant;
begin
  Result := CreateSelectedArr(gdcObject, ibgrMain.SelectedRows);
end;

procedure Tgdc_frmSGR.LoadSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMSGR', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMSGR', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMSGR') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMSGR',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMSGR' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if Assigned(UserStorage) then
    UserStorage.LoadComponent(ibgrMain, ibgrMain.LoadFromStream);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMSGR', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMSGR', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmSGR.SaveSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMSGR', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMSGR', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMSGR') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMSGR',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMSGR' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  SaveGrid(ibgrMain);
  inherited;
  
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMSGR', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMSGR', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

function Tgdc_frmSGR.GetMainBookmarkList: TBookmarkList;
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

procedure Tgdc_frmSGR.ibgrMainDblClick(Sender: TObject);
const
  Counter: Integer = 0;
begin
  if Assigned(gdcObject) then
  begin
    if (ibgrMain.GridCoordFromMouse.X >= 0) and
       (ibgrMain.GridCoordFromMouse.Y >= 0) then
    begin
      if ((actEditInGrid <> nil) and
        not actEditInGrid.Checked) then
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
end;

procedure Tgdc_frmSGR.ibgrMainMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
const
  PrevX: Integer = 0;
  PrevY: Integer = 0;
  InDragWait: Boolean = False;
begin
{ TODO : плохо прописывать высоту заголовка грида непосредственной константой }
  if (ssLeft in Shift) then
  begin
    if Y > 20 then
    begin
      if InDragWait and (Abs(X - PrevX) > 0) and (Abs(Y - PrevY) > 0) then
      begin
        InDragWait := False;
        ibgrMain.BeginDrag(False);
      end else
      begin
        InDragWait := True;
        PrevX := X;
        PrevY := Y;
      end;
    end else
      InDragWait := False;
  end else
    InDragWait := False;
end;

procedure Tgdc_frmSGR.ibgrMainStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
  if CanStartDrag(gdcObject) then
  begin
    DragObject := TgdcDragObject.Create;
    TgdcDragObject(DragObject).SourceControl := ibgrMain;
    gdcObject.CopyToClipboard(ibgrMain.SelectedRows, cCut);
  end;
end;

procedure Tgdc_frmSGR.ibgrMainDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  GdcDragOver(gdcObject, Sender, Source, X, Y, State, Accept);
end;

procedure Tgdc_frmSGR.ibgrMainDragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
  if Sender <> (Source as TgdcDragObject).SourceControl then
    gdcObject.PasteFromClipboard;
end;

procedure Tgdc_frmSGR.ibgrMainKeyDown(Sender: TObject; var Key: Word;
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

procedure Tgdc_frmSGR.actFindExecute(Sender: TObject);
begin
  SetLocalizeListName(ibgrMain);
  inherited;
end;

procedure Tgdc_frmSGR.actAddToSelectedExecute(Sender: TObject);
begin
  gdcObject.AddToSelectedID(ibgrMain.SelectedRows);
end;

procedure Tgdc_frmSGR.actRemoveFromSelectedExecute(Sender: TObject);
begin
  gdcObject.RemoveFromSelectedID(ibgrMain.SelectedRows);
end;

procedure Tgdc_frmSGR.ibgrMainClickCheck(Sender: TObject; CheckID: String;
  var Checked: Boolean);
begin
  inherited;
  if FInChoose then
    try
      if Checked then
        AddToChooseObject(StrToInt(CheckID))
      else
        DeleteFromChooseObject(StrToInt(CheckID));
    except
      raise Exception.Create('Ошибка при выборе записи. Неверный id: '+ CheckID);
    end;
end;

procedure Tgdc_frmSGR.DeleteChoose(AnID: Integer);
begin
  ibgrMain.CheckBox.DeleteCheck(AnID);
  gdcObject.RemoveFromSelectedID(AnID);
end;

procedure Tgdc_frmSGR.actEditExecute(Sender: TObject);
begin
  if (dgEditing in ibgrMain.Options) and (gdcObject.State = dsEdit) then
    gdcObject.Post;

  inherited;
end;

procedure Tgdc_frmSGR.actDuplicateExecute(Sender: TObject);
begin
  if (dgEditing in ibgrMain.Options) and (gdcObject.State = dsEdit) then
    gdcObject.Post;

  inherited;
end;

procedure Tgdc_frmSGR.actSaveToFileExecute(Sender: TObject);
var
  frmStreamSaver: TForm;
begin
  frmStreamSaver := Tgdc_frmStreamSaver.CreateAndAssign(Self);
  if ibgrMain.SelectedRows.Count > 0 then
    //gdcObject.SaveToFile('', nil, ibgrMain.SelectedRows, False)
    (frmStreamSaver as Tgdc_frmStreamSaver).SetParams(gdcObject, nil, ibgrMain.SelectedRows, False)
  else
    //gdcObject.SaveToFile;
    (frmStreamSaver as Tgdc_frmStreamSaver).SetParams(gdcObject);
  (frmStreamSaver as Tgdc_frmStreamSaver).ShowSaveForm;
end;

procedure Tgdc_frmSGR.actCopySettingsFromUserExecute(Sender: TObject);
begin
  inherited;

  ibgrMain.SettingsModified := True;
end;

procedure Tgdc_frmSGR.actSearchMainExecute(Sender: TObject);
begin
  inherited;

  if gdcObject.RecordCount > 0 then
    FocusControl(ibgrMain);
end;

procedure Tgdc_frmSGR.actMainReductionExecute(Sender: TObject);
begin
  gdcObject.Reduction(ibgrMain.SelectedRows);
end;

procedure Tgdc_frmSGR.actEditInGridUpdate(Sender: TObject);
begin
  actEditInGrid.Checked := Assigned(gdcObject)
    and ((gdcObject.State = dsBrowse) or ibgrMain.EditorMode)
    and (not ibgrMain.ReadOnly)
    and (dgEditing in ibgrMain.Options);
  actEditInGrid.Enabled := Assigned(gdcObject)
    and gdcObject.Active
    and gdcObject.CanEdit;
end;

procedure Tgdc_frmSGR.actEditInGridExecute(Sender: TObject);
begin
  EditInGridHelper(gdcObject, ibgrMain, actEditInGrid);
end;

procedure Tgdc_frmSGR.actNewExecute(Sender: TObject);
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

initialization
  with RegisterFrmClass(Tgdc_frmSGR, 'Форма просмотра с таблицей') do
  begin
    AbstractBaseForm := True;
    ShowInFormEditor := True;
  end;

finalization
  UnRegisterFrmClass(Tgdc_frmSGR);
end.
