
{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    gdc_dlgRelation_unit.pas

  Abstract

    Dialog window to edit relation.

  Author

    Denis Romanovski,
    Julia Teryokhina

  Revisions history

    1.0    06.12.2001    dennis    Initial version.
    2.0    23.01.2002    michael   Переделки, добавление триггеров.
    3.0    17.05.2002    Julia     Добавление индексов, изменение триггеров
    4.0    03.10.2007    Alexander Добавление чеков
--}

unit gdc_dlgRelation_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgGMetaData_unit, Db, ActnList, StdCtrls, IBCustomDataSet, gdcBase,
  gdcMetaData, TB2Item, TB2Dock, TB2Toolbar, Grids, DBGrids, gsDBGrid,
  gsIBGrid, DBCtrls, Mask, ExtCtrls, ComCtrls, Contnrs,
  IBDatabase, SynEdit, SynMemo, SynEditHighlighter, SynHighlighterSQL,
  Menus, gdcBaseInterface, gsIBLookupComboBox, gdc_dlgG_unit {, at_sql_metadata};

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
    ibgrRelationFields: TgsIBGrid;
    actNewField: TAction;
    actEditField: TAction;
    actDeleteField: TAction;
    dsRelationFields: TDataSource;
    tsTrigger: TTabSheet;
    actNewTrigger: TAction;
    actEditTrigger: TAction;
    actDeleteTrigger: TAction;
    SynSQLSyn: TSynSQLSyn;
    gdcIndex: TgdcIndex;
    dsIndices: TDataSource;
    ibgrIndices: TgsIBGrid;
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
    tvTriggers: TTreeView;
    Panel3: TPanel;
    smTriggerBody: TSynMemo;
    Splitter1: TSplitter;
    tsConstraints: TTabSheet;
    ibgrConstraints: TgsIBGrid;
    dsConstraints: TDataSource;
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
    TBDock2: TTBDock;
    tbTriggers: TTBToolbar;
    TBItem4: TTBItem;
    TBItem5: TTBItem;
    TBItem6: TTBItem;
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

    procedure actNewFieldExecute(Sender: TObject);
    procedure actNewFieldUpdate(Sender: TObject);

    procedure actEditFieldExecute(Sender: TObject);
    procedure actEditFieldUpdate(Sender: TObject);

    procedure actDeleteFieldExecute(Sender: TObject);
    procedure actDeleteFieldUpdate(Sender: TObject);
    procedure pcRelationChanging(Sender: TObject;
      var AllowChange: Boolean);
    procedure tvTriggersChange(Sender: TObject; Node: TTreeNode);

    procedure actNewTriggerExecute(Sender: TObject);
    procedure actEditTriggerExecute(Sender: TObject);
    procedure actDeleteTriggerExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actNewIndexExecute(Sender: TObject);
    procedure actEditIndexExecute(Sender: TObject);
    procedure actDeleteIndexExecute(Sender: TObject);
    procedure actDeleteIndexUpdate(Sender: TObject);
    procedure actNewIndexUpdate(Sender: TObject);
    procedure actEditIndexUpdate(Sender: TObject);
    procedure actEditTriggerUpdate(Sender: TObject);
    procedure actDeleteTriggerUpdate(Sender: TObject);
    procedure gdcTriggerAfterInsert(DataSet: TDataSet);
    procedure actNewTriggerUpdate(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
    procedure actSetShortCatExecute(Sender: TObject);
    procedure tvTriggersDblClick(Sender: TObject);
    procedure tvTriggersCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure dbedRelationNameEnter(Sender: TObject);
    procedure dbedRelationNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dbedRelationNameKeyPress(Sender: TObject; var Key: Char);
    procedure iblcExplorerBranchChange(Sender: TObject);
    procedure ibgrRelationFieldsDblClick(Sender: TObject);
    procedure actNewCheckExecute(Sender: TObject);
    procedure actEditCheckExecute(Sender: TObject);
    procedure actDeleteCheckExecute(Sender: TObject);
    procedure actDeleteCheckUpdate(Sender: TObject);

  private
    TriggerList: TObjectList;
    isModify: Boolean;

    function GetTypeTriggerToString(const TypeTrigger: Integer;
       const IsShort: Boolean = False): String;

    function GetTypeTriggerFromTree(TreeNode: TTreeNode): Integer;

    procedure AddTriggerName(const AnID: Integer; const TriggerName, TriggerBody: String; const TriggerType: Integer;
      const TriggerInactive: Integer);

  protected
    gdcTableField: TgdcRelationField;
    //Указывает, был ли объект для работы с полями передан сверху или создан на форме
    TableFieldWasCreate: Boolean;

    function DlgModified: Boolean; override;

    procedure SyncTriggers;
    procedure BeforePost; override;
    procedure SetShortCat(AnObject: TgdcBase);

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetupDialog; override;
    procedure SetupRecord; override;
    procedure Post; override;
    procedure SyncControls; override;
    function TestCorrect: Boolean; override;

    procedure SaveSettings; override;
    procedure LoadSettings; override;
  end;

  Egdc_dlgRelation = class(Exception);

var
  gdc_dlgRelation: Tgdc_dlgRelation;

implementation

uses
  dmImages_unit,

  IBSQL, at_Classes,

  at_sql_metadata, Storages, gd_ClassList, gdcExplorer, dbConsts,
  gdcAttrUserDefined, IBExtract, jclStrings
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

const
  scNew         = 'Ins';
  scEdit        = 'Ctrl+Enter';
  scDelete      = 'Ctrl+Del';

{$R *.DFM}

{ TTriggerBody }

type
  TTriggerInfo = class
  private
    FTriggerName: String;
    FTriggerBody: String;
    FTriggerType: Integer;
    FID: Integer;

  public
    constructor Create(const anID: Integer; const aTriggerName, aTriggerBody: String;
      const aTriggerType: Integer);

    property ID: Integer read FID;
    property TriggerName: String read FTriggerName write FTriggerName;
    property TriggerType: Integer read FTriggerType write FTriggerType;

    property TriggerBody: String read FTriggerBody write FTriggerBody;

  end;

constructor TTriggerInfo.Create(const anID: Integer; const aTriggerName, aTriggerBody: String;
        const aTriggerType: Integer);
begin
  FID := anID;
  FTriggerName := aTriggerName;
  FTriggerBody := aTriggerBody;
  FTriggerType := aTriggerType;
end;

{ Tgdc_dlgRelation }

constructor Tgdc_dlgRelation.Create(AnOwner: TComponent);
begin
  inherited;
  TriggerList := TObjectList.Create;
  isModify := False;
  TableFieldWasCreate := False;
end;

destructor Tgdc_dlgRelation.Destroy;
begin
  if Assigned(TriggerList) then
    FreeAndNil(TriggerList);
  if TableFieldWasCreate then
    gdcTableField.Free;
  inherited;
end;

procedure Tgdc_dlgRelation.actNewFieldExecute(Sender: TObject);
begin
  gdcTableField.CreateDialog;
  isModify := True;
end;

procedure Tgdc_dlgRelation.actNewFieldUpdate(Sender: TObject);
begin
  actNewField.Enabled := True;
end;

procedure Tgdc_dlgRelation.actEditFieldExecute(Sender: TObject);
begin
  if gdcTableField.RecNo > -1 then begin
    gdcTableField.EditDialog;
    isModify := True;
  end;
end;

procedure Tgdc_dlgRelation.actEditFieldUpdate(Sender: TObject);
begin
  actEditField.Enabled :=
    gdcTableField.RecordCount > 0;
end;

procedure Tgdc_dlgRelation.actDeleteFieldExecute(Sender: TObject);
begin
  gdcTableField.DeleteMultiple(nil);
  isModify := True;
end;

procedure Tgdc_dlgRelation.actDeleteFieldUpdate(Sender: TObject);
begin
  actDeleteField.Enabled :=
    (gdcTableField.RecordCount > 0) and
    (AnsiPos(
      UserPrefix,
      AnsiUpperCase(gdcTableField.FieldByName('fieldname').AsString)) = 1);
end;

procedure Tgdc_dlgRelation.pcRelationChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  AllowChange := False;
  try
    if dbedRelationName.Focused then
      tsCommon.SetFocus;

    if (gdcObject.State = dsInsert) and
      (gdcObject.FieldByName('relationname').AsString <> '') then
    begin
      if (pcRelation.ActivePage = tsCommon) then
      begin
        (gdcObject as TgdcRelation).TestRelationName;

        dbedRelationName.Enabled := False;
      end;
    end;

    if (gdcObject is TgdcBaseTable)
      and (gdcObject.State = dsInsert)
      and (gdcTableField.RecordCount = 0) then
    begin
      (gdcObject as TgdcBaseTable).MakePredefinedRelationFields;
    end;

    AllowChange := True;
  except
    on E: Exception do
      MessageBox(Self.Handle, PChar(E.Message), 'Ошибка!', MB_OK or MB_ICONERROR or MB_TASKMODAL);
  end;
end;

procedure Tgdc_dlgRelation.tvTriggersChange(Sender: TObject;
  Node: TTreeNode);
begin
  if (Node.Parent <> nil) then
    smTriggerBody.Text := TTriggerInfo(Node.Data).TriggerBody
  else
    smTriggerBody.Lines.Clear;
end;

function Tgdc_dlgRelation.GetTypeTriggerToString(
  const TypeTrigger: Integer; const IsShort: Boolean = False): String;
begin
  if not isShort then
  begin
    case TypeTrigger of
    1: Result := 'BEFORE INSERT';
    2: Result := 'AFTER INSERT';
    3: Result := 'BEFORE UPDATE';
    4: Result := 'AFTER UPDATE';
    5: Result := 'BEFORE DELETE';
    6: Result := 'AFTER DELETE';
    else
      Result := '';
    end;
  end
  else
    case TypeTrigger of
    1: Result := 'BI';
    2: Result := 'AI';
    3: Result := 'BU';
    4: Result := 'AU';
    5: Result := 'BD';
    6: Result := 'AD';
    else
      Result := '';
    end;
end;

procedure Tgdc_dlgRelation.actNewTriggerExecute(Sender: TObject);
begin
  if gdcTrigger.CreateDialog then
    AddTriggerName(gdcTrigger.FieldByName('id').AsInteger,
      gdcTrigger.FieldByName('triggername').AsString,
      gdcTrigger.FieldByName('rdb$trigger_source').AsString,
      gdcTrigger.FieldByName('rdb$trigger_type').AsInteger,
      gdcTrigger.FieldByName('trigger_inactive').AsInteger);
end;

function Tgdc_dlgRelation.GetTypeTriggerFromTree(
  TreeNode: TTreeNode): Integer;
var
  NodeText: String;
begin
  Result := -1;

  if TreeNode = nil then
    Exit;

  if TreeNode.Parent <> nil then
    NodeText := AnsiUpperCase(Trim(TreeNode.Parent.Text))
  else
    NodeText := AnsiUpperCase(Trim(TreeNode.Text));

  if NodeText = 'BEFORE INSERT' then
    Result := 1
  else if NodeText = 'AFTER INSERT' then
    Result := 2
  else if NodeText = 'BEFORE UPDATE' then
    Result := 3
  else if NodeText = 'AFTER UPDATE' then
    Result := 4
  else if NodeText = 'BEFORE DELETE' then
    Result := 5
  else if NodeText = 'AFTER DELETE' then
    Result := 6;
end;

procedure Tgdc_dlgRelation.actEditTriggerExecute(Sender: TObject);
begin
  if gdcTrigger.Locate('id', TTriggerInfo(tvTriggers.Selected.Data).ID, [])
    and gdcTrigger.EditDialog then
  begin
    TTriggerInfo(TriggerList.Items[TriggerList.IndexOf(tvTriggers.Selected.Data)]).TriggerName :=
      gdcTrigger.FieldByName('triggername').AsString;
    TTriggerInfo(TriggerList.Items[TriggerList.IndexOf(tvTriggers.Selected.Data)]).TriggerBody :=
      gdcTrigger.FieldByName('rdb$trigger_source').AsString;
    TTriggerInfo(TriggerList.Items[TriggerList.IndexOf(tvTriggers.Selected.Data)]).TriggerType :=
      gdcTrigger.FieldByName('rdb$trigger_type').AsInteger;
    tvTriggers.Selected.Text := gdcTrigger.FieldByName('triggername').AsString;
    tvTriggers.Selected.StateIndex := gdcTrigger.FieldByName('trigger_inactive').AsInteger;
    smTriggerBody.Text := gdcTrigger.FieldByName('rdb$trigger_source').AsString;
  end;
end;

procedure Tgdc_dlgRelation.actDeleteTriggerExecute(Sender: TObject);
var
  i : integer;
begin
  if gdcTrigger.Locate('id', TTriggerInfo(tvTriggers.Selected.Data).ID, [])
    and gdcTrigger.DeleteMultiple(nil) then
  begin
    i := 0;
    while i < tvTriggers.Items.Count do
    begin
      if tvTriggers.Items[i].Parent <> nil then
        tvTriggers.Items.Delete(tvTriggers.Items[i])
      else
        Inc(i);
    end;
    TriggerList.Clear;

    gdcTrigger.First;
    while not gdcTrigger.EOF do
    begin
      if Trim(gdcTrigger.FieldByName('rdb$trigger_source').AsString) > '' then
        AddTriggerName(gdcTrigger.FieldByName('id').AsInteger,
          gdcTrigger.FieldByName('triggername').AsString,
          gdcTrigger.FieldByName('rdb$trigger_source').AsString,
          gdcTrigger.FieldByName('rdb$trigger_type').AsInteger,
          gdcTrigger.FieldByName('trigger_inactive').AsInteger);
      gdcTrigger.Next;
    end;
  end;
end;

procedure Tgdc_dlgRelation.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  if gdcTableField.CachedUpdates then
    gdcTableField.CachedUpdates := False;

  if gdcObject.Transaction.InTransaction then
    gdcObject.Transaction.Rollback;
end;

procedure Tgdc_dlgRelation.LoadSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGRELATION', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGRELATION', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGRELATION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGRELATION',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGRELATION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if Assigned(UserStorage) then
  begin
    UserStorage.LoadComponent(ibgrRelationFields, ibgrRelationFields.LoadFromStream);
    UserStorage.LoadComponent(ibgrIndices, ibgrIndices.LoadFromStream);    
    UserStorage.LoadComponent(ibgrConstraints , ibgrConstraints.LoadFromStream);
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGRELATION', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGRELATION', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgRelation.SaveSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGRELATION', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGRELATION', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGRELATION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGRELATION',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGRELATION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if Assigned(UserStorage) then
  begin
    if ibgrRelationFields.SettingsModified then
      UserStorage.SaveComponent(ibgrRelationFields, ibgrRelationFields.SaveToStream);
    if ibgrIndices.SettingsModified then
      UserStorage.SaveComponent(ibgrIndices, ibgrIndices.SaveToStream);
    if ibgrConstraints.SettingsModified then
      UserStorage.SaveComponent(ibgrConstraints, ibgrConstraints.SaveToStream);
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGRELATION', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGRELATION', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

function Tgdc_dlgRelation.DlgModified: Boolean;
begin
  Result := inherited DlgModified or (TriggerList.Count > 0) or isModify;
end;

procedure Tgdc_dlgRelation.actNewIndexExecute(Sender: TObject);
begin
  gdcIndex.CreateDialog;
  isModify := True;
end;

procedure Tgdc_dlgRelation.actEditIndexExecute(Sender: TObject);
begin
  if gdcIndex.RecordCount > 0 then
    gdcIndex.EditDialog
  else
    gdcIndex.CreateDialog;
end;

procedure Tgdc_dlgRelation.actDeleteIndexExecute(Sender: TObject);
begin
  gdcIndex.DeleteMultiple(ibgrIndices.SelectedRows);
end;

procedure Tgdc_dlgRelation.actDeleteIndexUpdate(Sender: TObject);
begin
  actDeleteIndex.Enabled := Assigned(gdcIndex) and
    (gdcIndex.RecordCount > 0)  and
    (gdcIndex.CanDelete) and
    (ANSIPos(UserPrefix, AnsiUpperCase(gdcIndex.FieldByName('indexname').AsString)) = 1);
end;

procedure Tgdc_dlgRelation.actNewIndexUpdate(Sender: TObject);
begin
//  actNewIndex.Enabled := gdcObject.State = dsEdit;
end;

procedure Tgdc_dlgRelation.actEditIndexUpdate(Sender: TObject);
begin
//  actEditIndex.Enabled := gdcObject.State = dsEdit;
end;

procedure Tgdc_dlgRelation.SyncTriggers;

  procedure DeleteOldTriggers;
  var
    i: Integer;
  begin
    i := 0;
    while i < tvTriggers.Items.Count do
    begin
      if tvTriggers.Items[i].Parent <> nil then
        tvTriggers.Items.Delete(tvTriggers.Items[i])
      else
        Inc(i);
    end;
    TriggerList.Clear;
  end;

begin
  gdcTrigger.SyncTriggers(gdcObject.FieldByName('relationname').AsString);
  DeleteOldTriggers;
  gdcTrigger.First;
  while not gdcTrigger.EOF do
  begin
    if Trim(gdcTrigger.FieldByName('rdb$trigger_source').AsString) > '' then
      AddTriggerName(gdcTrigger.FieldByName('id').AsInteger,
        gdcTrigger.FieldByName('triggername').AsString,
        gdcTrigger.FieldByName('rdb$trigger_source').AsString,
        gdcTrigger.FieldByName('rdb$trigger_type').AsInteger,
        gdcTrigger.FieldByName('trigger_inactive').AsInteger);
    gdcTrigger.Next;
  end;
end;

procedure Tgdc_dlgRelation.actEditTriggerUpdate(Sender: TObject);
begin
  actEditTrigger.Enabled := (tvTriggers.Selected <> nil) and (tvTriggers.Selected.Parent <> nil) and
    (AnsiPos(UserPrefix, tvTriggers.Selected.Text) = 1);

end;

procedure Tgdc_dlgRelation.actDeleteTriggerUpdate(Sender: TObject);
begin
  actDeleteTrigger.Enabled := (tvTriggers.Selected <> nil) and (tvTriggers.Selected.Parent <> nil) and
    (AnsiPos(UserPrefix, tvTriggers.Selected.Text) = 1);
end;

procedure Tgdc_dlgRelation.AddTriggerName(const AnID: Integer;
  const TriggerName, TriggerBody: String; const TriggerType: Integer;
  const TriggerInactive: Integer);
var
  i, Num, F, S: Integer;
  tNode, tNodeSecond, tNodeThird: TTreeNode;

  procedure FillNode(var Node: TTreeNode; Num: Integer);
    var i: Integer;
  begin
    for i:= 0 to tvTriggers.Items.Count - 1 do
      if (tvTriggers.Items[i].Parent = nil) and (GetTypeTriggerFromTree(tvTriggers.Items[i]) = Num) then
      begin
        Node := tvTriggers.Items.AddChild(tvTriggers.Items[i], TriggerName);
        Node.StateIndex := TriggerInactive;
        Break;
      end;
  end;

begin
  F := 0;
  S := 0;
  Num := 1;
  tNode := nil;
  tNodeSecond := nil;
  tNodeThird := nil;
  if not (TriggerType > 6) then
  begin
    for i:= 0 to tvTriggers.Items.Count - 1 do
      if (tvTriggers.Items[i].Parent = nil) then
      begin
        if Num = TriggerType then
        begin
          tNode := tvTriggers.Items.AddChild(tvTriggers.Items[i], TriggerName);
          tNode.StateIndex := TriggerInactive;
          Break;
        end;
        Inc(Num);
      end;
  end
  else if not (TriggerType > 112) then
  begin
    case TriggerType of
    17:
      begin
        F := 1;
        S := 3;
      end;
    18:
      begin
        F := 2;
        S := 4;
      end;
    25:
      begin
        F := 1;
        S := 5;
      end;
    26:
      begin
        F := 2;
        S := 6;
      end;
    27:
      begin
        F := 3;
        S := 5;
      end;
    28:
      begin
        F := 4;
        S := 6;
      end;
    end;

    if (F <> 0) and (S <> 0) then
    begin
      FillNode(tNode, F);
      FillNode(TNodeSecond, S);
    end;
  end
  else
    begin
      case TriggerType of
      113:
        begin
          FillNode(tNode, 1);
          FillNode(tNodeSecond, 3);
          FillNode(tNodeThird, 5);
        end;
      114:
        begin
          FillNode(tNode, 2);
          FillNode(tNodeSecond, 4);
          FillNode(tNodeThird, 6);
        end;
      end;
    end;

  if tNode <> nil then
  begin
    TriggerList.Add(TTriggerInfo.Create(AnID, TriggerName, TriggerBody, TriggerType));
    tNode.Data := TriggerList.Items[TriggerList.Count - 1];
    if tNodeSecond <> nil then
    begin
      tNodeSecond.Data := tNode.Data;
      if tNodeThird <> nil then
        tNodeThird.Data := tNode.Data;
    end;
  end;
end;

procedure Tgdc_dlgRelation.gdcTriggerAfterInsert(DataSet: TDataSet);
var
  RelPrefix, RelName: String;
  UnderLinePos: Integer;
begin
  inherited;
  gdcTrigger.FieldByName('rdb$trigger_type').AsInteger :=
    GetTypeTriggerFromTree(tvTriggers.Selected);
  if gdcTrigger.FieldByName('rdb$trigger_type').AsInteger = -1 then
    gdcTrigger.FieldByName('rdb$trigger_type').AsInteger := 1;

  UnderLinePos := AnsiPos('_', gdcObject.FieldByName('relationname').AsString);
  if UnderLinePos > 0 then
  begin
    RelPrefix := AnsiUpperCase(Copy(gdcObject.FieldByName('relationname').AsString, 1,
      UnderLinePos));
    RelName := AnsiUpperCase(Copy(gdcObject.FieldByName('relationname').AsString,
      UnderLinePos + 1,
      Length(gdcObject.FieldByName('relationname').AsString) - UnderLinePos));
  end else
  begin
    RelPrefix := '';
    RelName := AnsiUpperCase(gdcObject.FieldByName('relationname').AsString);
  end;
  RelName := Trim(RelName);

  gdcTrigger.FieldByName('rdb$trigger_sequence').AsInteger :=
    gdcTrigger.CalcPosition(gdcObject.FieldByName('relationname').AsString,
      gdcTrigger.FieldByName('rdb$trigger_type').AsInteger);

  if RelPrefix <> '' then
    gdcTrigger.FieldByName('triggername').AsString :=
      RelPrefix +
      GetTypeTriggerToString(gdcTrigger.FieldByName('rdb$trigger_type').AsInteger, True)
      + '_' + RelName
  else
    gdcTrigger.FieldByName('triggername').AsString :=
      UserPrefix + GetTypeTriggerToString(gdcTrigger.FieldByName('rdb$trigger_type').AsInteger, True)
      + '_' + RelName;


  if gdcTrigger.FieldByName('rdb$trigger_sequence').AsInteger > 0 then
    gdcTrigger.FieldByName('triggername').AsString := gdcTrigger.FieldByName('triggername').AsString +
      gdcTrigger.FieldByName('rdb$trigger_sequence').AsString;
end;

procedure Tgdc_dlgRelation.BeforePost;

  function GetTableTypeName: String;
  begin
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
var
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

  inherited;

  if (gdcObject is TgdcBaseTable)
    and (gdcObject.State = dsInsert)
    and (gdcTableField.RecordCount = 0) then
  begin
    (gdcObject as TgdcBaseTable).MakePredefinedRelationFields;
  end;

  if lblBranch.Visible and iblcExplorerBranch.Enabled then
  begin
    if gdcObject.FieldByName('relationname').IsNull then
    begin
      gdcObject.FieldByName('relationname').FocusControl;
      DatabaseErrorFmt(SFieldRequired, [gdcObject.FieldByName('relationname').DisplayName]);
    end;

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
        if gdcExplorer.RecordCount > 0 then
        begin
          gdcExplorer.Delete;
        end;
        gdcObject.FieldByName('branchkey').Clear;
      end
      else if (gdcObject.FieldByName('branchkey').AsInteger > 0) and
        (iblcExplorerBranch.CurrentKeyInt > 0)
      then
      begin
        {если у нас была ветка в исследователе, подредактируем ее и заменим наименование, родителя}
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
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGRELATION', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGRELATION', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgRelation.actNewTriggerUpdate(Sender: TObject);
begin
  actNewTrigger.Enabled := gdcObject.State = dsEdit;
end;

procedure Tgdc_dlgRelation.Post;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  WasError: Boolean;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGRELATION', 'POST', KEYPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGRELATION', KEYPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGRELATION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGRELATION',
  {M}          'POST', KEYPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGRELATION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
//Перекрыт, потому как важен порядок сохранения дитейл-объектов
  WasError := False;
  try
    try
      if Assigned(gdcObject) and (not (sSubDialog in gdcObject.BaseState)) then
      begin
        if gdcObject.State in dsEditModes then
          gdcObject.Post;

         if gdcTableField.CachedUpdates then
           gdcTableField.ApplyUpdates;
         gdcIndex.ApplyUpdates;
         gdcTrigger.ApplyUpdates;
         gdcCheckConstraint.ApplyUpdates;
      end;
    except
      WasError := True;
      raise;
    end;
  finally
    if (not WasError) and Assigned(FSharedTransaction) and FSharedTransaction.InTransaction and not FIsTransaction then
      FSharedTransaction.Commit;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGRELATION', 'POST', KEYPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGRELATION', 'POST', KEYPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgRelation.SetupDialog;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  i: Integer;
  IBExtract: TIBExtract;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGRELATION', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGRELATION', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGRELATION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGRELATION',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGRELATION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  tvTriggers.HandleNeeded;
  inherited;


  //При сохранении триггера используется проверка
  //Если таблица еще не существует, триггер не создастся
  if gdcObject.State = dsInsert then
    tsTrigger.TabVisible := False;

  Assert(atDatabase <> nil);
  //
  //  Настройка первой страницы

  gdcTableField := nil;
  for i:= 0 to gdcObject.DetailLinksCount - 1 do
    if (gdcObject.DetailLinks[i] is TgdcRelationField) then
    begin
      gdcTableField := gdcObject.DetailLinks[i] as TgdcRelationField;
      Break;
    end;

  if not Assigned(gdcTableField) then
  begin
    gdcTableField := TgdcTableField.Create(Self);
    gdcTableField.CachedUpdates := True;
    gdcTableField.Database := gdcObject.Database;
    gdcTableField.ReadTransaction := gdcObject.Transaction;
    gdcTableField.Transaction := gdcObject.Transaction;
    gdcTableField.MasterField := 'ID';
    gdcTableField.DetailField := 'RELATIONKEY';
    gdcTableField.MasterSource := dsgdcBase;
    gdcTableField.SubSet := 'ByRelation';
    gdcTableField.ParamByName('relationkey').AsInteger := gdcObject.FieldByName('id').AsInteger;
    TableFieldWasCreate := True;
  end;

  if not gdcTableField.CachedUpdates then
  begin
    gdcTableField.Close;
    gdcTableField.CachedUpdates := True;
  end;

  dsRelationFields.DataSet := gdcTableField;

  pcRelation.ActivePage := tsCommon;

  if not gdcTableField.Active then
    gdcTableField.Open;


  gdcIndex.Close;
  gdcIndex.ReadTransaction := gdcObject.Transaction;
  gdcIndex.Transaction := gdcObject.Transaction;

  gdcTrigger.Close;
  gdcTrigger.ReadTransaction := gdcObject.Transaction;
  gdcTrigger.Transaction := gdcObject.Transaction;

  gdcCheckConstraint.Close;
  gdcCheckConstraint.ReadTransaction := gdcObject.Transaction;
  gdcCheckConstraint.Transaction := gdcObject.Transaction;
  gdcCheckConstraint.Open;

  IBExtract := TIBExtract.Create(Self);
  try
    IBExtract.Database := gdcObject.Transaction.DefaultDatabase;
    IBExtract.Transaction := gdcObject.Transaction;
    IBExtract.ExtractObject(eoTable, gdcObject.FieldByName('relationname').AsString,
      [etDomain, etTable, etTrigger, etForeign, etIndex, etGrant, etCheck]);
    smScriptText.Text := IBExtract.Items.Text;
  finally
    IBExtract.Free;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGRELATION', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGRELATION', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgRelation.actOkUpdate(Sender: TObject);
begin
  {actOk.Enabled := Assigned(gdcTableField) and (gdcTableField.RecordCount > 0);
  if actOk.Enabled then}
    inherited;
end;

procedure Tgdc_dlgRelation.SetShortCat(AnObject: TgdcBase);
begin
  if AnObject is TgdcTableField then
  begin
    actNewField.ShortCut := TextToShortCut(scNew);
    actEditField.ShortCut := TextToShortCut(scEdit);
    actDeleteField.ShortCut := TextToShortCut(scDelete);

    actNewIndex.ShortCut := 0;
    actEditIndex.ShortCut := 0;
    actDeleteIndex.ShortCut := 0;

    actNewTrigger.ShortCut := 0;
    actEditTrigger.ShortCut := 0;
    actDeleteTrigger.ShortCut := 0;

    actNewCheck.ShortCut := 0;
    actEditCheck.ShortCut := 0;
    actDeleteCheck.ShortCut := 0;
  end
  else if AnObject is TgdcIndex then
  begin
    actNewField.ShortCut := 0;
    actEditField.ShortCut := 0;
    actDeleteField.ShortCut := 0;

    actNewIndex.ShortCut := TextToShortCut(scNew);
    actEditIndex.ShortCut := TextToShortCut(scEdit);
    actDeleteIndex.ShortCut := TextToShortCut(scDelete);

    actNewTrigger.ShortCut := 0;
    actEditTrigger.ShortCut := 0;
    actDeleteTrigger.ShortCut := 0;

    actNewCheck.ShortCut := 0;
    actEditCheck.ShortCut := 0;
    actDeleteCheck.ShortCut := 0;
  end
  else if AnObject is TgdcTrigger then
  begin
    actNewField.ShortCut := 0;
    actEditField.ShortCut := 0;
    actDeleteField.ShortCut := 0;

    actNewIndex.ShortCut := 0;
    actEditIndex.ShortCut := 0;
    actDeleteIndex.ShortCut := 0;

    actNewTrigger.ShortCut := TextToShortCut(scNew);
    actEditTrigger.ShortCut := TextToShortCut(scEdit);
    actDeleteTrigger.ShortCut := TextToShortCut(scDelete);

    actNewCheck.ShortCut := 0;
    actEditCheck.ShortCut := 0;
    actDeleteCheck.ShortCut := 0;
  end
  else if AnObject is TgdcCheckConstraint then
  begin
    actNewField.ShortCut := 0;
    actEditField.ShortCut := 0;
    actDeleteField.ShortCut := 0;

    actNewIndex.ShortCut := 0;
    actEditIndex.ShortCut := 0;
    actDeleteIndex.ShortCut := 0;

    actNewTrigger.ShortCut := 0;
    actEditTrigger.ShortCut := 0;
    actDeleteTrigger.ShortCut := 0;

    actNewCheck.ShortCut := TextToShortCut(scNew);
    actEditCheck.ShortCut := TextToShortCut(scEdit);
    actDeleteCheck.ShortCut := TextToShortCut(scDelete);
  end;
end;

procedure Tgdc_dlgRelation.actSetShortCatExecute(Sender: TObject);
begin
  inherited;
  if (Sender is TgsIBGrid) and ((Sender as TgsIBGrid).DataSource.DataSet is TgdcBase) then
    SetShortCat((Sender as TgsIBGrid).DataSource.DataSet as TgdcBase);
end;

procedure Tgdc_dlgRelation.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
var
  R: TatRelation;
  ibsql: TIBSQL;
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
  inherited;
  ActivateTransaction(gdcObject.Transaction);

  gdcIndex.Close;
  gdcIndex.CachedUpdates := False;
  gdcIndex.Open;
  gdcIndex.SyncIndices(gdcObject.FieldByName('relationname').AsString);
  gdcIndex.Close;
  gdcIndex.CachedUpdates := True;
  gdcIndex.Open;

  gdcTrigger.Close;
  gdcTrigger.CachedUpdates := False;
  gdcTrigger.Open;
  SyncTriggers;
  gdcTrigger.Close;
  gdcTrigger.CachedUpdates := True;
  gdcTrigger.Open;

  gdcCheckConstraint.Close;
  gdcCheckConstraint.CachedUpdates := True;
  gdcCheckConstraint.Open;
  // Изначально указываем, что создается
  // простая таблица с идентификатором

  if gdcObject.State = dsInsert then
  begin
    // Если создается новая таблица,
    // позволяем выбрать тип таблицы

  end else begin
    // Если таблица редактируется,
    // запрещаем изменять ее тип


    dbedRelationName.ReadOnly := True;
    dbedRelationName.Color := clBtnFace;
  end;

  // Если добавление таблицы - разрешаем добавление в проводник
  if gdcObject.State = dsInsert then
    iblcExplorerBranch.Visible :=       (
       (gdcObject is TgdcView) or
       (gdcObject is TgdcPrimeTable) or
       (gdcObject is TgdcSimpleTable) or
       (gdcObject is TgdcTreeTable) or
       (gdcObject is TgdcLBRBTreeTable) or
       (gdcObject is TgdcTableToTable)
      )

  else
  begin
   // Если редактирование таблицы пользователя и есть поле - идентификатор -
    // разрешаем добавление в проводник
    R := atDatabase.Relations.ByRelationName(
      gdcObject.FieldByName('relationname').AsString);

    if not Assigned(R) then
      if (StrIPos('RDB$', gdcObject.FieldByName('relationname').AsString) > 0) or
        (StrIPos('MON$', gdcObject.FieldByName('relationname').AsString) > 0)
      then
        raise Exception.Create('Нельзя редактировать системную таблицу.')
      else
        raise Exception.Create('Таблица не может быть открыта на редактирование.');


    if Assigned(R) then
      with R do
      begin
        iblcExplorerBranch.Visible :=
          (gdcObject.State = dsEdit) and
          IsUserDefined and
          (
           (gdcObject is TgdcView) or
           (gdcObject is TgdcPrimeTable) or
           (gdcObject is TgdcSimpleTable) or
           (gdcObject is TgdcTreeTable) or
           (gdcObject is TgdcLBRBTreeTable) or
           (gdcObject is TgdcTableToTable)
          );
      end;
  end;

  lblBranch.Visible := iblcExplorerBranch.Visible;

//Выведем родителя нашей ветки в исследователе
  if lblBranch.Visible and (gdcObject.FieldByName('branchkey').AsInteger > 0) then
  begin
    ibsql := TIBSQL.Create(Self);
    try
      ibsql.Transaction := gdcBaseManager.ReadTRansaction;
      ibsql.SQL.Text := 'SELECT parent FROM gd_command WHERE id = :id';
      ibsql.ParamByName('id').AsInteger := gdcObject.FieldByName('branchkey').AsInteger;
      ibsql.ExecQuery;

      if (ibsql.RecordCount > 0) and (ibsql.FieldByName('parent').AsInteger > 0) then
        iblcExplorerBranch.CurrentKeyInt := ibsql.FieldByName('parent').AsInteger;
    finally
      ibsql.Free;
    end;
  end;

  //Для редактирования нескольких веток запрещаем изменении ветки исследователя
  iblcExplorerBranch.Enabled := not (sMultiple in gdcObject.BaseState);

  if (gdcObject.ClassType = TgdcTableToTable) then
  begin
    lblReference.Visible := True;
    ibcmbReference.Visible := True;
    ibcmbReference.DataSource := dsgdcBase;
    ibcmbReference.DataField := 'referencekey';
    if (gdcObject.State = dsEdit) then
    begin
      ibcmbReference.CurrentKeyInt := atDatabase.Relations.ByRelationName(
      atDatabase.Relations.ByRelationName(gdcObject.FieldByName('relationname').AsString).RelationFields.ByFieldName('id').Field.RefTableName).ID;
      ibcmbReference.Enabled := False;
    end;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGRELATION', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGRELATION', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;


procedure Tgdc_dlgRelation.tvTriggersDblClick(Sender: TObject);
begin
  actEditTrigger.Execute;
end;

procedure Tgdc_dlgRelation.SyncControls;
var
  FC: TgdcFullClass;
begin
  inherited;

  lClass.Text := '';
  lSubType.Text := '';

  if Assigned(gdcObject) and (not gdcObject.IsEmpty)
    and (gdcObject.FieldByName('RELATIONNAME').AsString > '') then
  begin
    FC := GetBaseClassForRelation(gdcObject.FieldByName('RELATIONNAME').AsString);
    if FC.gdClass <> nil then
    begin
      lClass.Text := FC.gdClass.ClassName;
      lSubType.Text := FC.SubType;
    end;
  end;
end;

procedure Tgdc_dlgRelation.tvTriggersCustomDrawItem(
  Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  inherited;
  if Node.StateIndex > 0 then
  begin
    if Sender.Selected = Node then
      Sender.Canvas.Font.Style := [fsBold]
    else
      Sender.Canvas.Font.Color := clGray
  end;
end;

procedure Tgdc_dlgRelation.dbedRelationNameEnter(Sender: TObject);
var
  S: string;
begin
  S:= '00000409';
  LoadKeyboardLayout(@S[1], KLF_ACTIVATE);
end;

procedure Tgdc_dlgRelation.dbedRelationNameKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if ((Shift = [ssShift]) and (Key = VK_INSERT)) or ((Shift = [ssCtrl]) and (Chr(Key) in ['V', 'v'])) then begin
    CheckClipboardForName;
  end;
end;

procedure Tgdc_dlgRelation.dbedRelationNameKeyPress(Sender: TObject;
  var Key: Char);
begin
  Key:= CheckNameChar(Key);
end;

procedure Tgdc_dlgRelation.iblcExplorerBranchChange(Sender: TObject);
begin
  isModify:= True;
end;

procedure Tgdc_dlgRelation.ibgrRelationFieldsDblClick(Sender: TObject);
begin
  if actEditField.Enabled and
    (ibgrRelationFields.GridCoordFromMouse.X >= 0) and
    (ibgrRelationFields.GridCoordFromMouse.Y >= 0) then
  begin
    gdcTableField.EditDialog;
    isModify := True;
  end;
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
  gdcCheckConstraint.DeleteMultiple(ibgrConstraints.SelectedRows);
end;

procedure Tgdc_dlgRelation.actDeleteCheckUpdate(Sender: TObject);
begin
  actDeleteCheck.Enabled := Assigned(gdcCheckConstraint) and
    (gdcCheckConstraint.RecordCount > 0)  and
    (gdcCheckConstraint.CanDelete) and
    (ANSIPos(UserPrefix, AnsiUpperCase(gdcCheckConstraint.FieldByName('checkname').AsString)) = 1);
end;

function Tgdc_dlgRelation.TestCorrect: Boolean;
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

  // Проверка на дублирование локализованного наименования таблицы
  if Result and (not (sMultiple in gdcObject.BaseState))  then
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcBaseManager.ReadTransaction;
      q.SQL.Text :=
        'SELECT r.relationname FROM at_relations r WHERE r.lname = :lname';
      q.ParamByName('lname').AsString := gdcObject.FieldByName('lname').AsString;
      q.ExecQuery;

      if not q.EOF then
      begin
        MessageBox(Handle,
          PChar(
          'Таблица с таким локализованным названием уже существует в базе данных:'#13#10#13#10 +
          '  Наименование: ' + q.FieldByName('relationname').AsString + #13#10#13#10 +
          'Ввод дублирующихся записей запрещен.'), 'Внимание', MB_OK or MB_ICONEXCLAMATION);
        Result := False;
      end;
    finally
      FreeAndNil(q);
    end;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGRELATION', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGRELATION', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_dlgRelation);

finalization
  UnRegisterFrmClass(Tgdc_dlgRelation);
end.

