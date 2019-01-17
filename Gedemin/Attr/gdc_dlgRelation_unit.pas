
{++

  Copyright (c) 2001-2018 by Golden Software of Belarus, Ltd

  Module

    gdc_dlgRelation_unit.pas

  Abstract

    Dialog window to edit relation.

  Author

    Denis Romanovski,
    Julia Teryokhina

  Revisions history

    1.0    06.12.2001    dennis    Initial version.
    2.0    23.01.2002    michael   ѕеределки, добавление триггеров.
    3.0    17.05.2002    Julia     ƒобавление индексов, изменение триггеров
    4.0    03.10.2007    Alexander ƒобавление чеков

--}

unit gdc_dlgRelation_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgGMetaData_unit, Db, ActnList, StdCtrls, IBCustomDataSet, gdcBase,
  gdcMetaData, TB2Item, TB2Dock, TB2Toolbar, Grids, DBGrids, gsDBGrid,
  gsIBGrid, DBCtrls, Mask, ExtCtrls, ComCtrls, Contnrs,
  IBDatabase, SynEdit, SynMemo, SynEditHighlighter, SynHighlighterSQL,
  Menus, gdcBaseInterface, gsIBLookupComboBox, gdc_dlgG_unit, SynDBEdit {, at_sql_metadata};

type
  Tgdc_dlgRelation = class(Tgdc_dlgGMetaData)
    pcRelation: TPageControl;
    tsCommon: TTabSheet;
    lblTableName: TLabel;
    lblLName: TLabel;
    lblLShortName: TLabel;
    lblDescription: TLabel;
    dbedRelationName: TDBEdit;
    dbedLRelationName: TDBEdit;
    dbeShortRelationName: TDBEdit;
    dbeRelationDescription: TDBMemo;
    tsFields: TTabSheet;
    ibgrTableField: TgsIBGrid;
    actNewField: TAction;
    actEditField: TAction;
    actDeleteField: TAction;
    dsTableField: TDataSource;
    tsTriggers: TTabSheet;
    actNewTrigger: TAction;
    actEditTrigger: TAction;
    actDeleteTrigger: TAction;
    SynSQLSyn: TSynSQLSyn;
    gdcIndex: TgdcIndex;
    dsIndex: TDataSource;
    ibgrIndex: TgsIBGrid;
    tsIndices: TTabSheet;
    actNewIndex: TAction;
    actEditIndex: TAction;
    actDeleteIndex: TAction;
    gdcTrigger: TgdcTrigger;
    ibcmbReference: TgsIBLookupComboBox;
    lblReference: TLabel;
    IBTransaction: TIBTransaction;
    lblBranch: TLabel;
    iblcExplorerBranch: TgsIBLookupComboBox;
    actSetShortCat: TAction;
    Label3: TLabel;
    Label4: TLabel;
    dbeExtendedFields: TDBEdit;
    dbeListField: TDBEdit;
    Label5: TLabel;
    Label6: TLabel;
    lClass: TEdit;
    lSubType: TEdit;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    splTrigger: TSplitter;
    tsConstraints: TTabSheet;
    ibgrCheckConstraint: TgsIBGrid;
    dsCheckConstraint: TDataSource;
    gdcCheckConstraint: TgdcCheckConstraint;
    actNewCheck: TAction;
    actEditCheck: TAction;
    actDeleteCheck: TAction;
    tsScript: TTabSheet;
    smScriptText: TSynMemo;
    TBDock1: TTBDock;
    tbFields: TTBToolbar;
    TBItem3: TTBItem;
    TBItem2: TTBItem;
    TBItem1: TTBItem;
    TBDock3: TTBDock;
    tbIndices: TTBToolbar;
    tbiNewIndices: TTBItem;
    tbiEditIndices: TTBItem;
    tbiDeleteIndices: TTBItem;
    TBDock4: TTBDock;
    tbChecks: TTBToolbar;
    TBItem7: TTBItem;
    TBItem8: TTBItem;
    TBItem9: TTBItem;
    dsTrigger: TDataSource;
    ibgrTrigger: TgsIBGrid;
    TBDock2: TTBDock;
    tbTriggers: TTBToolbar;
    TBItem4: TTBItem;
    TBItem5: TTBItem;
    TBItem6: TTBItem;
    dbseTriggerBody: TDBSynEdit;
    actAddFieldToSetting: TAction;
    TBItem10: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    actAddTriggerToSetting: TAction;
    TBItem11: TTBItem;
    TBSeparatorItem2: TTBSeparatorItem;
    actAddIndexToSetting: TAction;
    TBItem12: TTBItem;
    TBSeparatorItem3: TTBSeparatorItem;
    actAddConstraintToSetting: TAction;
    TBItem13: TTBItem;
    TBSeparatorItem4: TTBSeparatorItem;
    Panel6: TPanel;
    lblTriggerType: TLabel;
    dbseConstraint: TDBSynEdit;
    Panel7: TPanel;
    Panel8: TPanel;
    lblWarn: TLabel;
    Label1: TLabel;
    dbedSemCategory: TDBEdit;

    procedure actNewFieldExecute(Sender: TObject);
    procedure actNewFieldUpdate(Sender: TObject);

    procedure actEditFieldExecute(Sender: TObject);
    procedure actEditFieldUpdate(Sender: TObject);

    procedure actDeleteFieldExecute(Sender: TObject);
    procedure actDeleteFieldUpdate(Sender: TObject);

    procedure actNewTriggerExecute(Sender: TObject);
    procedure actNewTriggerUpdate(Sender: TObject);

    procedure actEditTriggerExecute(Sender: TObject);
    procedure actEditTriggerUpdate(Sender: TObject);

    procedure actDeleteTriggerExecute(Sender: TObject);
    procedure actDeleteTriggerUpdate(Sender: TObject);

    procedure actNewIndexExecute(Sender: TObject);
    procedure actNewIndexUpdate(Sender: TObject);

    procedure actEditIndexExecute(Sender: TObject);
    procedure actEditIndexUpdate(Sender: TObject);

    procedure actDeleteIndexExecute(Sender: TObject);
    procedure actDeleteIndexUpdate(Sender: TObject);

    procedure actNewCheckExecute(Sender: TObject);
    procedure actNewCheckUpdate(Sender: TObject);

    procedure actEditCheckExecute(Sender: TObject);
    procedure actEditCheckUpdate(Sender: TObject);

    procedure actDeleteCheckExecute(Sender: TObject);
    procedure actDeleteCheckUpdate(Sender: TObject);

    procedure dbedRelationNameEnter(Sender: TObject);
    procedure dbedRelationNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dbedRelationNameKeyPress(Sender: TObject; var Key: Char);
    procedure pcRelationChange(Sender: TObject);
    procedure actAddFieldToSettingUpdate(Sender: TObject);
    procedure actAddFieldToSettingExecute(Sender: TObject);
    procedure actAddTriggerToSettingUpdate(Sender: TObject);
    procedure actAddTriggerToSettingExecute(Sender: TObject);
    procedure actAddIndexToSettingUpdate(Sender: TObject);
    procedure actAddIndexToSettingExecute(Sender: TObject);
    procedure actAddConstraintToSettingUpdate(Sender: TObject);
    procedure actAddConstraintToSettingExecute(Sender: TObject);
    procedure dsTriggerDataChange(Sender: TObject; Field: TField);

  private
    procedure PrepareDatasetFields(ibgr: TgsIBGrid; const AVisibleFieldName: String);

  protected
    gdcTableField: TgdcRelationField;

    procedure BeforePost; override;

  public
    procedure SetupRecord; override;
    function TestCorrect: Boolean; override;
  end;

  Egdc_dlgRelation = class(Exception);

var
  gdc_dlgRelation: Tgdc_dlgRelation;

implementation

uses
  IBSQL, at_Classes, at_AddToSetting, gdcTriggerHelper,
  at_sql_metadata, Storages, gd_ClassList, gdcExplorer, dbConsts,
  gdcAttrUserDefined, IBExtract, jclStrings, gd_dlgClassList_unit
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$R *.DFM}

procedure Tgdc_dlgRelation.actNewFieldExecute(Sender: TObject);
begin
  gdcTableField.CreateDialog;
end;

procedure Tgdc_dlgRelation.actNewFieldUpdate(Sender: TObject);
begin
  actNewField.Enabled := (pcRelation.ActivePage = tsFields)
    and gdcTableField.CanCreate;
end;

procedure Tgdc_dlgRelation.actEditFieldExecute(Sender: TObject);
begin
  gdcTableField.EditDialog;
end;

procedure Tgdc_dlgRelation.actEditFieldUpdate(Sender: TObject);
begin
  actEditField.Enabled := (pcRelation.ActivePage = tsFields)
    and (not gdcTableField.IsEmpty)
    and gdcTableField.CanEdit;
end;

procedure Tgdc_dlgRelation.actDeleteFieldExecute(Sender: TObject);
begin
  gdcTableField.DeleteMultiple(nil);
end;

procedure Tgdc_dlgRelation.actDeleteFieldUpdate(Sender: TObject);
begin
  actDeleteField.Enabled := (pcRelation.ActivePage = tsFields)
    and (not gdcTableField.IsEmpty)
    and gdcTableField.CanDelete;
end;

procedure Tgdc_dlgRelation.actNewTriggerExecute(Sender: TObject);
begin
  gdcTrigger.CreateDialog;
end;

procedure Tgdc_dlgRelation.actNewTriggerUpdate(Sender: TObject);
begin
  actNewTrigger.Enabled := (pcRelation.ActivePage = tsTriggers)
    and gdcTrigger.CanCreate;
end;


procedure Tgdc_dlgRelation.actEditTriggerExecute(Sender: TObject);
begin
  gdcTrigger.EditDialog;
end;

procedure Tgdc_dlgRelation.actDeleteTriggerExecute(Sender: TObject);
begin
  gdcTrigger.DeleteMultiple(ibgrTrigger.SelectedRows);
end;

procedure Tgdc_dlgRelation.actNewIndexExecute(Sender: TObject);
begin
  gdcIndex.CreateDialog;
end;

procedure Tgdc_dlgRelation.actEditIndexExecute(Sender: TObject);
begin
  gdcIndex.EditDialog;
end;

procedure Tgdc_dlgRelation.actDeleteIndexExecute(Sender: TObject);
begin
  gdcIndex.DeleteMultiple(ibgrIndex.SelectedRows);
end;

procedure Tgdc_dlgRelation.actDeleteIndexUpdate(Sender: TObject);
begin
  actDeleteIndex.Enabled := (pcRelation.ActivePage = tsIndices)
    and (not gdcIndex.IsEmpty)
    and gdcIndex.CanDelete;
end;

procedure Tgdc_dlgRelation.actNewIndexUpdate(Sender: TObject);
begin
  actNewIndex.Enabled := (pcRelation.ActivePage = tsIndices)
    and gdcIndex.CanCreate;
end;

procedure Tgdc_dlgRelation.actEditIndexUpdate(Sender: TObject);
begin
  actEditIndex.Enabled := (pcRelation.ActivePage = tsIndices)
    and (not gdcIndex.IsEmpty)
    and gdcIndex.CanEdit;
end;

procedure Tgdc_dlgRelation.actEditTriggerUpdate(Sender: TObject);
begin
  actEditTrigger.Enabled := (pcRelation.ActivePage = tsTriggers)
    and (not gdcTrigger.IsEmpty)
    and gdcTrigger.CanEdit;
end;

procedure Tgdc_dlgRelation.actDeleteTriggerUpdate(Sender: TObject);
begin
  actDeleteTrigger.Enabled := (pcRelation.ActivePage = tsTriggers)
    and (not gdcTrigger.IsEmpty)
    and gdcTrigger.CanDelete;
end;

procedure Tgdc_dlgRelation.BeforePost;

  function GetTableTypeName: String;
  var
    C: TgdcFullClass;
  begin
    if gdcObject is TgdcInheritedTable then
    begin
      C := GetBaseClassForRelation((gdcObject as TgdcInheritedTable).GetReferenceName);
      if C.gdClass = nil then
        raise Exception.Create('Unregistered relation.');
      Result := C.gdClass.ClassName;
    end
    else
      case (gdcObject as TgdcRelation).TableType of
        ttIntervalTree: Result := 'TgdcAttrUserDefinedLBRBTree';
        ttTree: Result := 'TgdcAttrUserDefinedTree';
        else Result := 'TgdcAttrUserDefined';
      end;
  end;

  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  gdcExplorer: TgdcExplorer;

  procedure _InsertExplorer;
  begin
    {если у нас не было ветки в исследователе и мы захотели ее создать}
    gdcExplorer.Open;
    gdcExplorer.Insert;
    gdcExplorer.FieldByName('parent').AsInteger := iblcExplorerBranch.CurrentKeyInt;
    if gdcObject.FieldByName('lname').AsString = '' then
      gdcExplorer.FieldByName('name').AsString := gdcObject.FieldByName('relationname').AsString
    else
      gdcExplorer.FieldByName('name').AsString := gdcObject.FieldByName('lname').AsString;
    gdcExplorer.FieldByName('classname').AsString := GetTableTypeName;
    gdcExplorer.FieldByName('subtype').AsString := gdcObject.FieldByName('relationname').AsString;
    gdcExplorer.FieldByName('cmd').AsString := GetRUIDForRelation(
      gdcObject.FieldByName('relationname').AsString);
    gdcExplorer.FieldByName('cmdtype').AsInteger := cst_expl_cmdtype_class;
    gdcExplorer.Post;
    gdcObject.FieldByName('branchkey').AsInteger := gdcExplorer.ID;
  end;

begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGRELATION', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGRELATION', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGRELATION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGRELATION',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGRELATION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  (gdcObject as TgdcRelation).CheckObjectName;

  inherited;

  gdcExplorer := TgdcExplorer.CreateSubType(nil, '', 'ByID');
  try
    gdcExplorer.Transaction := gdcObject.Transaction;
    gdcExplorer.ReadTransaction := gdcObject.ReadTransaction;
    if (gdcObject.FieldByName('branchkey').IsNull) and
      (iblcExplorerBranch.CurrentKeyInt > 0)
    then
    begin
      _InsertExplorer;
    end
    else if (gdcObject.FieldByName('branchkey').AsInteger > 0) and
      (iblcExplorerBranch.CurrentKeyInt = -1)
    then
    begin
      {если у нас была ветка в исследователе и мы захотели ее удалить}
      gdcExplorer.ID := gdcObject.FieldByName('branchkey').AsInteger;
      gdcExplorer.Open;
      if not gdcExplorer.EOF then
        gdcExplorer.Delete;
      gdcObject.FieldByName('branchkey').Clear;
    end
    else if (gdcObject.FieldByName('branchkey').AsInteger > 0) and
      (iblcExplorerBranch.CurrentKeyInt > 0)
    then
    begin
      {если у нас была ветка в исследователе, подредактируем ее и заменим наименование, родител€}
      gdcExplorer.ID := gdcObject.FieldByName('branchkey').AsInteger;
      gdcExplorer.Open;
      if (gdcExplorer.RecordCount = 0) or
        (gdcExplorer.FieldByName('subtype').AsString <> gdcObject.FieldByName('relationname').AsString) then
      begin
        _InsertExplorer;
      end else
      begin
        gdcExplorer.Edit;
        gdcExplorer.FieldByName('parent').AsInteger := iblcExplorerBranch.CurrentKeyInt;
        gdcExplorer.FieldByName('name').AsString := gdcObject.FieldByName('lname').AsString;
        gdcExplorer.Post;
      end;
    end;
  finally
    gdcExplorer.Free
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGRELATION', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGRELATION', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgRelation.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
var
  R: TatRelation;
  CF: TatRelationField;
  ibsql: TIBSQL;
  FC: TgdcFullClass;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGRELATION', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGRELATION', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGRELATION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGRELATION',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGRELATION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  gdcTableField.Free;

  if gdcObject is TgdcBaseTable then
    gdcTableField := TgdcTableField.Create(Self)
  else
    gdcTableField := TgdcViewField.Create(Self);

  gdcTableField.SubSet := 'ByRelation';
  gdcTableField.MasterSource := dsgdcBase;
  gdcTableField.MasterField := 'id';
  gdcTableField.DetailField := 'relationkey';
  dsTableField.DataSet := gdcTableField;
  gdcTableField.Open;

  inherited;

  pcRelation.ActivePage := tsCommon;

  PrepareDataSetFields(ibgrTableField, 'FIELDNAME;LNAME');
  PrepareDataSetFields(ibgrTrigger, 'TRIGGERNAME');
  PrepareDataSetFields(ibgrIndex, 'INDEXNAME');
  PrepareDataSetFields(ibgrCheckConstraint, 'CHECKNAME');

  if gdcObject.State = dsInsert then
  begin
    tsFields.TabVisible := False;
    tsTriggers.TabVisible := False;
    tsIndices.TabVisible := False;
    tsConstraints.TabVisible := False;
    tsScript.TabVisible := False;
    lblWarn.Caption :=
      'ƒл€ доступа к пол€м, триггерам, индексам и ограничени€м сохраните таблицу/представление и переподключитесь к базе данных. ' +
      'Ћог SQL команд можно просмотреть в окне ÷ентра ”правлени€ (GDCC)';
  end else
  begin
    tsFields.TabVisible := True;
    tsTriggers.TabVisible := True;
    tsIndices.TabVisible := gdcObject is TgdcBaseTable;
    tsConstraints.TabVisible := gdcObject is TgdcBaseTable;
    tsScript.TabVisible := True;
    lblWarn.Caption :=
      '¬се изменени€ полей, триггеров, индексов и ограничений будут сразу записаны в базу данных. ' +
      'Ћог SQL команд можно просмотреть в окне ÷ентра ”правлени€ (GDCC)';

    dbedRelationName.ReadOnly := True;
    dbedRelationName.Color := clBtnFace;
  end;

  if gdcObject.FieldByName('branchkey').AsInteger > 0 then
  begin
    ibsql := TIBSQL.Create(nil);
    try
      ibsql.Transaction := gdcBaseManager.ReadTRansaction;
      ibsql.SQL.Text := 'SELECT parent FROM gd_command WHERE id = :id';
      ibsql.ParamByName('id').AsInteger := gdcObject.FieldByName('branchkey').AsInteger;
      ibsql.ExecQuery;

      if (not ibsql.EOF) and (ibsql.FieldByName('parent').AsInteger > 0) then
        iblcExplorerBranch.CurrentKeyInt := ibsql.FieldByName('parent').AsInteger;
    finally
      ibsql.Free;
    end;
  end;

  iblcExplorerBranch.Enabled := not (sMultiple in gdcObject.BaseState);

  if gdcObject is TgdcTableToTable then
  begin
    lblReference.Visible := True;
    ibcmbReference.Visible := True;
    ibcmbReference.DataSource := dsgdcBase;
    ibcmbReference.DataField := 'referencekey';

    if (gdcObject.State = dsEdit) then
    begin
      R := atDatabase.Relations.ByRelationName(gdcObject.FieldByName('relationname').AsString);

      if (R <> nil) and (R.PrimaryKey <> nil) and (R.PrimaryKey.ConstraintFields.Count = 1) then
      begin
        CF := R.PrimaryKey.ConstraintFields[0];

        if CF.Field.RefTable <> nil then
          ibcmbReference.CurrentKeyInt := CF.Field.RefTable.ID;
      end;

      ibcmbReference.Enabled := False;
    end;
  end else
  begin
    lblReference.Visible := False;
    ibcmbReference.Visible := False;
  end;

  if gdcObject is TgdcBaseTable then
  begin
    FC := GetBaseClassForRelation(gdcObject.FieldByName('relationname').AsString);
    if FC.gdClass <> nil then
    begin
      lClass.Text := FC.gdClass.ClassName;
      lSubType.Text := FC.SubType;
    end else
    begin
      lClass.Text := '';
      lSubType.Text := '';
    end;
  end;  

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGRELATION', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGRELATION', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgRelation.dbedRelationNameEnter(Sender: TObject);
var
  S: String;
begin
  S := '00000409';
  LoadKeyboardLayout(@S[1], KLF_ACTIVATE);
end;

procedure Tgdc_dlgRelation.dbedRelationNameKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if ((Shift = [ssShift]) and (Key = VK_INSERT)) or ((Shift = [ssCtrl]) and (Chr(Key) in ['V', 'v'])) then
    CheckClipboardForName;
end;

procedure Tgdc_dlgRelation.dbedRelationNameKeyPress(Sender: TObject;
  var Key: Char);
begin
  Key := CheckNameChar(Key);
end;

procedure Tgdc_dlgRelation.actNewCheckExecute(Sender: TObject);
begin
  gdcCheckConstraint.CreateDialog;
end;

procedure Tgdc_dlgRelation.actEditCheckExecute(Sender: TObject);
begin
  if gdcCheckConstraint.RecordCount > 0 then
    gdcCheckConstraint.EditDialog
  else
    gdcCheckConstraint.CreateDialog;
end;

procedure Tgdc_dlgRelation.actDeleteCheckExecute(Sender: TObject);
begin
  gdcCheckConstraint.DeleteMultiple(ibgrCheckConstraint.SelectedRows);
end;

procedure Tgdc_dlgRelation.actDeleteCheckUpdate(Sender: TObject);
begin
  actDeleteCheck.Enabled := (pcRelation.ActivePage = tsConstraints)
    and (not gdcCheckConstraint.IsEmpty)
    and (gdcCheckConstraint.CanDelete);
end;

function Tgdc_dlgRelation.TestCorrect: Boolean;

  procedure _Traverse(CE: TgdClassEntry; const ARN: String; var ACount: Integer);
  var
    I: Integer;
  begin
    if CE.Hidden then
      exit;

    if (CE as TgdBaseEntry).DistinctRelation = ARN then
      Inc(ACount);

    for I := 0 to CE.Count - 1 do
    begin
      if (not CE.Children[I].VirtualSubType) and (not (CE.Children[I] is TgdStorageEntry)) then
        _Traverse(CE.Children[I], ARN, ACount);
    end;
  end;

  function CanInherit(const RID: TID): Boolean;
  var
    Count: Integer;
    R: OleVariant;
  begin
    Count := 0;
    if gdcBaseManager.ExecSingleQueryResult('SELECT relationname FROM at_relations WHERE id = :id', RID, R) then
      _Traverse(gdClassList.Get(TgdBaseEntry, 'TgdcBase'), R[0, 0], Count);
    Result := Count <= 1;
  end;

var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  q: TIBSQL;
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_DLGRELATION', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGRELATION', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGRELATION') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGRELATION',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGRELATION' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  Result := inherited TestCorrect;

  //ѕроверка на возможность создани€ св€занной таблицы (наследование)
  if Result and (gdcObject is TgdcInheritedTable)
    and (ibcmbReference.CurrentKeyInt > -1)
    and (not CanInherit(ibcmbReference.CurrentKeyInt)) then
  begin
    MessageBox(Handle,
      PChar(
      'Ќельз€ наследовать класс от таблицы ' + ibcmbReference.Text + #13#10 +
      'так как в Ѕƒ присутствуют несколько классов дл€ которых данна€ таблица указана как DistinctRelation.'),
      '¬нимание', MB_OK or MB_ICONEXCLAMATION);
    Result := False;
  end;

  // ѕроверка на дублирование локализованного наименовани€ таблицы
  if Result and (not (sMultiple in gdcObject.BaseState))  then
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcObject.ReadTransaction;
      q.SQL.Text :=
        'SELECT r.relationname FROM at_relations r WHERE r.lname = :lname ' +
        '  AND r.id <> :ID ';
      q.ParamByName('id').AsInteger := gdcObject.ID;
      q.ParamByName('lname').AsString := gdcObject.FieldByName('lname').AsString;
      q.ExecQuery;

      if not q.EOF then
      begin
        MessageBox(Handle,
          PChar(
          '“аблица с таким локализованным названием уже существует в базе данных:'#13#10#13#10 +
          '  Ќаименование: ' + q.FieldByName('relationname').AsString + #13#10#13#10 +
          '¬вод дублирующихс€ записей запрещен.'), '¬нимание', MB_OK or MB_ICONEXCLAMATION);
        Result := False;
      end;
    finally
      q.Free;
    end;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGRELATION', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGRELATION', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgRelation.pcRelationChange(Sender: TObject);
var
  IBExtract: TIBExtract;
  ET: TExtractObjectTypes;
  Tr: TIBTransaction;
begin
  if pcRelation.ActivePage = tsScript then
  begin
    Tr := TIBTransaction.Create(nil);
    IBExtract := TIBExtract.Create(nil);
    try
      Tr.DefaultDatabase := gdcObject.Transaction.DefaultDatabase;
      Tr.StartTransaction;

      IBExtract.Database := Tr.DefaultDatabase;
      IBExtract.Transaction := Tr;
      if gdcObject is TgdcView then ET := eoView
        else ET := eoTable;
      IBExtract.ExtractObject(ET, gdcObject.FieldByName('relationname').AsString,
        [etDomain, etTable, etTrigger, etForeign, etIndex, etGrant, etCheck]);
      smScriptText.Text := IBExtract.Items.Text;
      
      Tr.Commit;
    finally
      IBExtract.Free;
      Tr.Free;
    end;
  end;
end;

procedure Tgdc_dlgRelation.actNewCheckUpdate(Sender: TObject);
begin
  actNewCheck.Enabled := (pcRelation.ActivePage = tsConstraints)
    and gdcCheckConstraint.CanCreate;
end;

procedure Tgdc_dlgRelation.actEditCheckUpdate(Sender: TObject);
begin
  actEditCheck.Enabled := (pcRelation.ActivePage = tsConstraints)
    and (not gdcCheckConstraint.IsEmpty)
    and gdcCheckConstraint.CanEdit;
end;

procedure Tgdc_dlgRelation.PrepareDatasetFields(ibgr: TgsIBGrid;
  const AVisibleFieldName: String);
var
  I: Integer;
begin
  for I := 0 to ibgr.Columns.Count - 1 do
    if ibgr.Columns[I].Field <> nil then
      ibgr.Columns[I].Visible := StrIPos(';' + ibgr.Columns[I].Field.FieldName + ';',
        ';' + AVisibleFieldName + ';') > 0;
end;

procedure Tgdc_dlgRelation.actAddFieldToSettingUpdate(Sender: TObject);
begin
  actAddFieldToSetting.Enabled := (pcRelation.ActivePage = tsFields)
    and (not gdcTableField.IsEmpty)
    and gdcTableField.CanAddToNS;
end;

procedure Tgdc_dlgRelation.actAddFieldToSettingExecute(Sender: TObject);
begin
  AddToSetting(False, '', '', gdcTableField, nil);
end;

procedure Tgdc_dlgRelation.actAddTriggerToSettingUpdate(Sender: TObject);
begin
  actAddTriggerToSetting.Enabled := (pcRelation.ActivePage = tsTriggers)
    and (not gdcTrigger.IsEmpty)
    and gdcTrigger.CanAddToNS;
end;

procedure Tgdc_dlgRelation.actAddTriggerToSettingExecute(Sender: TObject);
begin
  AddToSetting(False, '', '', gdcTrigger, nil);
end;

procedure Tgdc_dlgRelation.actAddIndexToSettingUpdate(Sender: TObject);
begin
  actAddIndexToSetting.Enabled := (pcRelation.ActivePage = tsIndices)
    and (not gdcIndex.IsEmpty)
    and gdcIndex.CanAddToNS;
end;

procedure Tgdc_dlgRelation.actAddIndexToSettingExecute(Sender: TObject);
begin
  AddToSetting(False, '', '', gdcIndex, nil);
end;

procedure Tgdc_dlgRelation.actAddConstraintToSettingUpdate(
  Sender: TObject);
begin
  actAddConstraintToSetting.Enabled := (pcRelation.ActivePage = tsConstraints)
    and (not gdcCheckConstraint.IsEmpty)
    and gdcCheckConstraint.CanAddToNS;
end;

procedure Tgdc_dlgRelation.actAddConstraintToSettingExecute(
  Sender: TObject);
begin
  AddToSetting(False, '', '', gdcCheckConstraint, nil);
end;

procedure Tgdc_dlgRelation.dsTriggerDataChange(Sender: TObject;
  Field: TField);
var
  SActive: String;
begin
  if gdcTrigger.IsEmpty or (gdcTrigger.State <> dsBrowse) then
    lblTriggerType.Caption := ''
  else begin
    if gdcTrigger.FieldByName('RDB$TRIGGER_INACTIVE').AsInteger <> 0 then
      SActive := 'INACTIVE'
    else
      SActive := 'ACTIVE';
    lblTriggerType.Caption := SActive + ', ' +
      GetTypeName(gdcTrigger.FieldByName('RDB$TRIGGER_TYPE').AsInteger) + ', ' +
      'POSITION ' + IntToStr(gdcTrigger.FieldByName('RDB$TRIGGER_SEQUENCE').AsInteger);
  end;
end;

initialization
  RegisterFrmClass(Tgdc_dlgRelation);

finalization
  UnRegisterFrmClass(Tgdc_dlgRelation);
end.

