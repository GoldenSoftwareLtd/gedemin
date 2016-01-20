unit gdc_dlgHGR_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, Db, ActnList, StdCtrls,Mask, xDateEdits, DBCtrls, ExtCtrls, Grids, DBGrids,
  gsDBGrid, gsIBGrid, gsIBCtrlGrid, gdcBase, ComCtrls, ToolWin, gdcBaseInterface,
  dmDatabase_unit, FrmPlSvr, TB2Item, TB2Dock, TB2Toolbar, gdc_dlgTR_unit,
  IBDatabase, Menus;

type
  Tgdc_dlgHGR = class(Tgdc_dlgTR)
    dsDetail: TDataSource;
    actDetailNew: TAction;
    actDetailEdit: TAction;
    actDetailDelete: TAction;
    actDetailDuplicate: TAction;
    actDetailPrint: TAction;
    actDetailCut: TAction;
    actDetailCopy: TAction;
    actDetailPaste: TAction;
    actDetailMacro: TAction;
    pnlMain: TPanel;
    pnlDetail: TPanel;
    ibgrDetail: TgsIBGrid;
    tbdTop: TTBDock;
    tbDetail: TTBToolbar;
    tbNew: TTBItem;
    tbEdit: TTBItem;
    tbDelete: TTBItem;
    tbDuplicate: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    tbCopy: TTBItem;
    tbCut: TTBItem;
    tbPaste: TTBItem;
    TBSeparatorItem2: TTBSeparatorItem;
    tbMacro: TTBItem;
    tbdLeft: TTBDock;
    tbdRight: TTBDock;
    tbdBottom: TTBDock;
    pnlMaster: TPanel;
    splMain: TSplitter;
    tbiDetailProperties: TTBItem;
    actDetailProp: TAction;

    procedure actDetailNewExecute(Sender: TObject);
    procedure actDetailNewUpdate(Sender: TObject);

    procedure actDetailEditExecute(Sender: TObject);
    procedure actDetailEditUpdate(Sender: TObject);

    procedure actDetailDeleteExecute(Sender: TObject);
    procedure actDetailDeleteUpdate(Sender: TObject);

    procedure actDetailDuplicateExecute(Sender: TObject);
    procedure actDetailDuplicateUpdate(Sender: TObject);

    procedure actDetailCutExecute(Sender: TObject);
    procedure actDetailCutUpdate(Sender: TObject);

    procedure actDetailCopyExecute(Sender: TObject);
    procedure actDetailCopyUpdate(Sender: TObject);

    procedure actDetailPasteExecute(Sender: TObject);
    procedure actDetailPasteUpdate(Sender: TObject);
    procedure ibgrDetailEnter(Sender: TObject);
    procedure ibgrDetailExit(Sender: TObject);
    procedure actDetailPropUpdate(Sender: TObject);
    procedure actDetailPropExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);

  private
    FControlsDisabled: Boolean;

    procedure SetgdcDetailObject(const Value: TgdcBase);

  protected
    FgdcDetailObject: TgdcBase;

    procedure SetupGrid;

  public
    function GetDetailBookmarkList: TBookmarkList; virtual;

    procedure LoadSettings; override;
    procedure SaveSettings; override;

    property gdcDetailObject: TgdcBase read FgdcDetailObject write SetgdcDetailObject;

    function Get_SelectedKey: OleVariant; override; safecall;

  end;

var
  gdc_dlgHGR: Tgdc_dlgHGR;

implementation

uses
  dmImages_unit, Storages,  gd_ClassList, gsStorage_CompPath, at_classes, at_sql_setup;

{$R *.DFM}

procedure Tgdc_dlgHGR.actDetailEditExecute(Sender: TObject);
begin
  FgdcDetailObject.EditMultiple(GetDetailBookmarkList);
end;

procedure Tgdc_dlgHGR.actDetailNewExecute(Sender: TObject);
begin
  FgdcDetailObject.CreateDialog;
end;

procedure Tgdc_dlgHGR.actDetailNewUpdate(Sender: TObject);
begin
  actDetailNew.Enabled := (FgdcDetailObject <> nil)
    and (FgdcDetailObject.CanCreate)
    and (not RecordLocked);
end;

procedure Tgdc_dlgHGR.actDetailEditUpdate(Sender: TObject);
begin
  actDetailEdit.Enabled := (FgdcDetailObject <> nil)
    and (FgdcDetailObject.RecordCount > 0)
    and (FgdcDetailObject.State = dsBrowse)
    and (FgdcDetailObject.CanEdit);

end;

procedure Tgdc_dlgHGR.actDetailDeleteExecute(Sender: TObject);
begin
  FgdcDetailObject.DeleteMultiple(GetDetailBookmarkList);
end;

procedure Tgdc_dlgHGR.actDetailDeleteUpdate(Sender: TObject);
begin
  actDetailDelete.Enabled := (FgdcDetailObject <> nil)
    and (FgdcDetailObject.RecordCount > 0)
    and (FgdcDetailObject.CanDelete)
    and (not RecordLocked);
end;

procedure Tgdc_dlgHGR.actDetailDuplicateExecute(Sender: TObject);
begin
  FgdcDetailObject.CopyDialog;
end;

procedure Tgdc_dlgHGR.actDetailDuplicateUpdate(Sender: TObject);
begin
  actDetailDuplicate.Enabled := (FgdcDetailObject <> nil)
    and (FgdcDetailObject.RecordCount > 0)
    and (FgdcDetailObject.CanEdit)
    and (not RecordLocked);
end;


procedure Tgdc_dlgHGR.actDetailCutUpdate(Sender: TObject);
begin
  actDetailCut.Enabled := (FgdcDetailObject <> nil)
    and (FgdcDetailObject.CanDelete)
    and (not RecordLocked);
end;

procedure Tgdc_dlgHGR.actDetailCopyUpdate(Sender: TObject);
begin
  actDetailCopy.Enabled := (FgdcDetailObject <> nil) and
    (FgdcDetailObject.CanEdit);
end;

procedure Tgdc_dlgHGR.actDetailPasteUpdate(Sender: TObject);
begin
  actDetailPaste.Enabled := (FgdcDetailObject <> nil)
    and (FgdcDetailObject.CanPasteFromClipboard)
    and (not RecordLocked);
end;

procedure Tgdc_dlgHGR.actDetailCopyExecute(Sender: TObject);
begin
  inherited;
  FgdcDetailObject.CopyToClipboard(GetDetailBookmarkList, cCopy);
end;

procedure Tgdc_dlgHGR.actDetailPasteExecute(Sender: TObject);
begin
  inherited;
  FgdcDetailObject.PasteFromClipboard;
end;

procedure Tgdc_dlgHGR.actDetailCutExecute(Sender: TObject);
begin
  inherited;
  FgdcDetailObject.CopyToClipboard(GetDetailBookmarkList, cCut);
end;

function Tgdc_dlgHGR.GetDetailBookmarkList: TBookmarkList;
begin
  Result := nil;
end;

procedure Tgdc_dlgHGR.LoadSettings;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  H: Integer;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGHGR', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGHGR', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGHGR') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGHGR',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGHGR' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if Assigned(UserStorage) then
  begin
    H := UserStorage.ReadInteger(BuildComponentPath(pnlMaster),
      'Height', pnlMaster.Height);

    if pnlMaster.Height > pnlMain.Height then
      H := pnlMain.Height - 10;

    pnlMaster.Height := H;

    UserStorage.LoadComponent(ibgrDetail, ibgrDetail.LoadFromStream);
  end;  

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGHGR', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGHGR', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgHGR.SaveSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGHGR', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGHGR', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGHGR') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGHGR',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGHGR' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if Assigned(UserStorage) then
  begin
    SaveGrid(ibgrDetail);

    UserStorage.WriteInteger(BuildComponentPath(pnlMaster),
      'Height', pnlMaster.Height);
  end;    

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGHGR', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGHGR', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

function Tgdc_dlgHGR.Get_SelectedKey: OleVariant;
begin
  Result := VarArrayOf([VarArrayOf([gdcObject.ID]),
    CreateSelectedArr(gdcDetailObject, ibgrDetail.SelectedRows)]);
end;

procedure Tgdc_dlgHGR.ibgrDetailEnter(Sender: TObject);
begin
  inherited;
  btnOk.Default := False;
  btnCancel.Cancel := False;
end;

procedure Tgdc_dlgHGR.ibgrDetailExit(Sender: TObject);
begin
  inherited;
  btnOk.Default := True;
  btnCancel.Cancel := True;
end;

procedure Tgdc_dlgHGR.SetupGrid;
var
  I, K: Integer;
  R: TatRelation;
  F: TatRelationField;
  C: TgsIBColumnEditor;
  AlreadyExists: Boolean;
  FList: TStrings;
  DFN: String;
begin
  Assert(Assigned(gdcDetailObject));

  FList := TStringList.Create;
  try
    GetTableAlias(gdcDetailObject.SelectSQL.Text, FList);
    {}
    for I := 0 to gdcDetailObject.FieldCount - 1 do
    begin
      if gdcDetailObject.Fields[I].Calculated then
        Continue;

      R := atDatabase.Relations.ByRelationName(
        gdcDetailObject.RelationByAliasName(gdcDetailObject.Fields[I].FieldName));

      if not Assigned(R) then
        Continue;

      F := R.RelationFields.ByFieldName(gdcDetailObject.FieldNameByAliasName(
        gdcDetailObject.Fields[I].FieldName));

      if not F.IsUserDefined then
        Continue;

      if F.References <> nil then
      begin
        DFN := gdcBaseManager.AdjustMetaName(
          FList.Values[F.FieldName] +
          '_' +
          F.FieldName +
          '_' +
          F.ReferenceListField.FieldName);

        AlreadyExists := False;
        for K := 0 to ibgrDetail.ColumnEditors.Count - 1 do
        begin
          if AnsiCompareText(ibgrDetail.ColumnEditors[K].DisplayField, DFN) = 0 then
          begin
            AlreadyExists := True;
            break;
          end;
        end;

        if not AlreadyExists then
        begin
          C := ibgrDetail.ColumnEditors.Add;
          try
            C.EditorStyle := cesLookup;
            C.FieldName := gdcDetailObject.Fields[I].FieldName;
            C.DisplayField := DFN;

            if F.gdClassName > '' then
            begin
              C.Lookup.SubType := F.gdSubType;
              C.Lookup.gdClassName := F.gdClassName;
              if Assigned(F.Field.RefListField) then
                C.Lookup.LookupListField := F.Field.RefListField.FieldName;

            end else
              begin
                if Assigned(F.Field.RefListField) then
                  C.Lookup.LookupListField := F.Field.RefListField.FieldName
                else
                  C.Lookup.LookupListField := F.References.ListField.FieldName;

                C.Lookup.LookupKeyField := F.References.PrimaryKey.
                  ConstraintFields[0].FieldName;
                C.Lookup.LookupTable := F.References.RelationName;
              end;

            if Assigned(F.Field) and (F.Field.RefCondition > '') then
              C.Lookup.Condition := F.Field.RefCondition;

            C.Lookup.Transaction := ibtrCommon;
          except
            ibgrDetail.ColumnEditors.Delete(C.Index);
          end;
        end;
      end
    end;
  finally
    FList.Free;
  end;
end;

procedure Tgdc_dlgHGR.actDetailPropUpdate(Sender: TObject);
begin
  actDetailProp.Enabled := Assigned(gdcDetailObject)
    and (gdcDetailObject.State = dsBrowse)
    and (not gdcDetailObject.IsEmpty);
end;

procedure Tgdc_dlgHGR.actDetailPropExecute(Sender: TObject);
begin
  gdcDetailObject.EditDialog('Tgdc_dlgObjectProperties');
end;

procedure Tgdc_dlgHGR.SetgdcDetailObject(const Value: TgdcBase);
begin
  FgdcDetailObject := Value;
  if FgdcDetailObject <> nil then
    FControlsDisabled := FgdcDetailObject.ControlsDisabled; 
end;

procedure Tgdc_dlgHGR.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  inherited;

  if CanClose and (gdcDetailObject <> nil) and (gdcDetailObject.Owner <> Self)
    and (not FControlsDisabled) then
  begin
    while gdcDetailObject.ControlsDisabled do
      gdcDetailObject.EnableControls;
  end;
end;

initialization
  RegisterFrmClass(Tgdc_dlgHGR, 'Диалоговое окно с таблицей').FormEditForm := True;

finalization
  UnRegisterFrmClass(Tgdc_dlgHGR);

end.

