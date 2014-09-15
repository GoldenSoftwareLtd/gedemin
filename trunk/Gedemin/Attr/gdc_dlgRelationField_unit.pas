
{++


  Copyright (c) 2001 - 2013 by Golden Software of Belarus

  Module

    gdc_dlgRelationField_unit.pas

  Abstract

    Dialog Window to edit relation fields.

  Author

    Denis Romanovski

  Revisions history

    1.0    05.12.2001    dennis   Rewritten.
    2.0    24.06.2002    Julia    Added rule for delete, recreated many functions

--}

unit gdc_dlgRelationField_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, Db, ActnList, StdCtrls, DBCtrls, ExtCtrls,
  gsIBLookupComboBox, at_sql_metadata, Mask, ComCtrls, Contnrs,
  gdc_dlgTRMetaData_unit, IBDatabase, gsTreeView, Menus, gdc_dlgTR_unit, IBHeader, gd_ClassList;

type
  Tgdc_dlgRelationField = class(Tgdc_dlgTRMetaData)
    pcRelationField: TPageControl;
    tsCommon: TTabSheet;
    Label1: TLabel;
    lblTableName: TLabel;
    dbtRelationName: TDBText;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    lblDefaultValue: TLabel;
    dbedRelationFieldName: TDBEdit;
    dbedRelationFieldLName: TDBEdit;
    dbedRelationFieldShortLName: TDBEdit;
    luFieldType: TgsIBLookupComboBox;
    edDefaultValue: TDBMemo;
    dbedRelationFieldDescription: TDBMemo;
    tsVisualSettings: TTabSheet;
    Label8: TLabel;
    Label14: TLabel;
    lblFormat: TLabel;
    lblBusinessClass: TLabel;
    lblClassSubType: TLabel;
    dbrgAligment: TDBRadioGroup;
    dbedColWidth: TDBEdit;
    dbcbVisible: TDBCheckBox;
    dbedFormat: TDBEdit;
    dbcbReadOnly: TDBCheckBox;
    comboBusinessClass: TComboBox;
    comboClassSubType: TComboBox;
    lComputed: TLabel;
    dbmComputed: TDBMemo;
    cbCalculated: TCheckBox;
    tsObjects: TTabSheet;
    tvObjects: TgsTreeView;
    lblRuleDelete: TLabel;
    cmbRuleDelete: TComboBox;
    dbcbNotNull: TDBCheckBox;
    Label2: TLabel;

    procedure luFieldTypeChange(Sender: TObject);
    procedure cbCalculatedClick(Sender: TObject);
    procedure comboBusinessClassChange(Sender: TObject);
    procedure comboBusinessClassClick(Sender: TObject);
    procedure dbmComputedChange(Sender: TObject);
    procedure dbedRelationFieldNameEnter(Sender: TObject);
    procedure dbedRelationFieldNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dbedRelationFieldNameKeyPress(Sender: TObject;
      var Key: Char);
    procedure pcRelationFieldChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    FClasses: TObjectList;
    FCurrentSubTypes: TStringList;
    IsNeedDefault: Boolean;

    procedure WriteObjectState;

    procedure SetGDClass;

    function BuildClassTree(ACE: TgdClassEntry; AData: Pointer): Boolean;
  protected
    procedure LoadClasses;
    procedure UpdateSubTypes;

    function DlgModified: Boolean; override;

    procedure BeforePost; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetupDialog; override;
    procedure SetupRecord; override;
    function TestCorrect: Boolean; override;

  end;

  Egdc_dlgRelationField = class(Exception);

var
  gdc_dlgRelationField: Tgdc_dlgRelationField;

implementation

{$R *.DFM}

uses
  gdcMetaData, IBSQL, at_classes, gdcBase,
  gd_resourcestring, jclStrings, at_sql_tools;

const
  cst_Restrict   = 'RESTRICT';
  cst_Cascade    = 'CASCADE';
  cst_SetNull    = 'SET NULL';
  cst_SetDefault = 'SET DEFAULT';

  //Длина краткого имени поля
  LShortNameLong = 20;

{ Tgdc_dlgRelationField }

constructor Tgdc_dlgRelationField.Create(AnOwner: TComponent);
begin
  inherited;

  FClasses := TObjectList.Create;
  FCurrentSubTypes := TStringList.Create;
  FCurrentSubTypes.Sorted := True;

end;

destructor Tgdc_dlgRelationField.Destroy;
begin
  FClasses.Free;
  FCurrentSubTypes.Free;

  inherited;
end;

procedure Tgdc_dlgRelationField.SetupDialog;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  I: Integer;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGRELATIONFIELD', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGRELATIONFIELD', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGRELATIONFIELD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGRELATIONFIELD',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGRELATIONFIELD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  //////////////////////////////////////////////////////////////////////////////
  //  Подготовка базовых классов

  gdClassList.Traverse(TgdcBase, '', BuildClassTree, nil);

  comboBusinessClass.ItemIndex := -1;
  comboBusinessClass.Items.Clear;

  comboBusinessClass.Items.AddObject(' ', nil);

  for I := 0 to FClasses.Count - 1 do
  with FClasses[I] as TgdcClassHandler, gdcObject do
  begin
{ TODO : абстрактные классы у нас не имеют имени }
    if gdcDisplayName = '' then
      continue;

    comboBusinessClass.Items.AddObject(
      gdcDisplayName + ' (' + gdcClassName + ')',
      FClasses[I]
    );
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGRELATIONFIELD', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGRELATIONFIELD', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

function Tgdc_dlgRelationField.TestCorrect: Boolean;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_DLGRELATIONFIELD', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGRELATIONFIELD', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGRELATIONFIELD') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGRELATIONFIELD',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGRELATIONFIELD' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  Result := inherited TestCorrect;

  if Result then
  begin
    if cbCalculated.Checked and (Trim(dbmComputed.Text) = '') then
    begin
      pcRelationField.ActivePage := tsCommon;
      dbmComputed.SetFocus;
      raise Egdc_dlgRelationField.Create('Укажите выражение для вычисляемого поля');
    end;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGRELATIONFIELD', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGRELATIONFIELD', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgRelationField.UpdateSubTypes;
var
  I: Integer;
begin
  if comboBusinessClass.ItemIndex = -1 then
    Exit else

  begin
    comboClassSubType.Items.Clear;

    if not Assigned(comboBusinessClass.Items.
      Objects[comboBusinessClass.ItemIndex])
    then
      Exit;

    with (comboBusinessClass.Items.Objects[comboBusinessClass.ItemIndex]
      as TgdcClassHandler) do
    begin
      if GetSubTypes(FCurrentSubTypes) then
        for I := 0 to FCurrentSubTypes.Count - 1 do
          comboClassSubType.Items.Add(FCurrentSubTypes.Names[I]);
    end;
  end;
end;

procedure Tgdc_dlgRelationField.luFieldTypeChange(Sender: TObject);
var
  Field: TgdcField;
begin
  if gdcObject.State = dsInsert then
  begin
    if luFieldType.CurrentKey > '' then
      cbCalculated.Checked := False;
    cbCalculated.Enabled := not gdcObject.CachedUpdates and (luFieldType.CurrentKey = '');
    if luFieldType.CurrentKey > '' then
    begin
      Field := TgdcField.Create(nil);
      try
        Field.SubSet := 'ByID';
        Field.ID := StrToInt(luFieldType.CurrentKey);
        Field.Open;

        gdcObject.FieldByName('visible').AsString :=
          Field.FieldByName('visible').AsString;

        gdcObject.FieldByName('format').AsString :=
          Field.FieldByName('format').AsString;

        gdcObject.FieldByName('alignment').AsString :=
          Field.FieldByName('alignment').AsString;

        gdcObject.FieldByName('colwidth').AsString :=
          Field.FieldByName('colwidth').AsString;

        gdcObject.FieldByName('readonly').AsString :=
          Field.FieldByName('readonly').AsString;

        gdcObject.FieldByName('fieldsource').AsString :=
          Field.FieldByName('fieldname').AsString;

        if gdcObject.FieldByName('readonly').isNull then
          gdcObject.FieldByName('readonly').AsString := '0';

        gdcObject.FieldByName('nullflag').AsInteger :=
          Field.FieldByName('flag').AsInteger;

        if gdcObject.FieldByName('nullflag').AsInteger = 0 then
          dbcbNotNull.Enabled := True
        else
          dbcbNotNull.Enabled := False;

        if not Field.FieldByName('defsource').IsNull then
        begin
          edDefaultValue.Text := Trim(copy(Field.FieldByName('defsource').AsString, 9, 255));
          if edDefaultValue.Text[1] = '''' then
            edDefaultValue.Text := System.Copy(edDefaultValue.Text, 2,
              Length(edDefaultValue.Text) - 2);
        end
        else
          edDefaultValue.Text := '';

        if not Field.FieldByName('reftable').IsNull or
          not Field.FieldByName('reflistfield').IsNull  then
        begin
          comboBusinessClass.Enabled:= True;
          comboClassSubType.Enabled:= True;
          lblBusinessClass.Enabled:= True;
          lblClassSubType.Enabled:= True;
          lblRuleDelete.Visible := True;
          cmbRuleDelete.Visible := True;
          if gdcObject.State = dsInsert then
            cmbRuleDelete.ItemIndex := 0
          else
          begin
            cmbRuleDelete.ItemIndex := cmbRuleDelete.Items.IndexOf(
              UpperCase(Trim(gdcObject.FieldByName('deleterule').AsString)));
          end;
          lblRuleDelete.Enabled := gdcObject.State = dsInsert;
          cmbRuleDelete.Enabled := gdcObject.State = dsInsert;
        end else
        begin
          comboBusinessClass.Enabled:= False;
          comboClassSubType.Enabled:= False;
          lblBusinessClass.Enabled:= False;
          lblClassSubType.Enabled:= False;
          lblRuleDelete.Visible := False;
          cmbRuleDelete.Visible := False;
        end;

        if (Trim(Field.FieldByName('fieldname').AsString) <> Trim(Field.FieldByName('lname').AsString))
        then
        begin
          if ((gdcObject.FieldByName('fieldname').AsString = gdcObject.FieldByName('lname').AsString)
            or gdcObject.FieldByName('lname').IsNull)
          then
            gdcObject.FieldByName('lname').AsString := Field.FieldByName('lname').AsString;

          if ((gdcObject.FieldByName('fieldname').AsString = gdcObject.FieldByName('lshortname').AsString)
            or gdcObject.FieldByName('lshortname').IsNull)
          then
            gdcObject.FieldByName('lshortname').AsString :=
              Copy(Field.FieldByName('lname').AsString, 1, LShortNameLong);
        end;

        gdcObject.FieldByName('gdclassname').AsString :=
          Field.FieldByName('gdclassname').AsString;

        gdcObject.FieldByName('gdsubtype').AsString :=
          Field.FieldByName('gdsubtype').AsString;

        SetGDClass;
      finally
        Field.Free;
      end;
    end else
    begin
      comboBusinessClass.Enabled:= False;
      comboClassSubType.Enabled:= False;
      lblBusinessClass.Enabled:= False;
      lblClassSubType.Enabled:= False;
      lblRuleDelete.Visible := False;
      cmbRuleDelete.Visible := False;
    end;
  end;
end;

procedure Tgdc_dlgRelationField.cbCalculatedClick(Sender: TObject);
begin
  dbmComputed.Visible := cbCalculated.Checked;
  lComputed.Visible := dbmComputed.Visible;
  if cbCalculated.Checked then
    luFieldType.Text := '';
  luFieldType.Enabled := not cbCalculated.Checked;

  edDefaultValue.Visible := not cbCalculated.Checked;
  lblDefaultValue.Visible := not cbCalculated.Checked;

  lblRuleDelete.Visible := not cbCalculated.Checked;
  cmbRuleDelete.Visible := not cbCalculated.Checked;
end;

function Tgdc_dlgRelationField.BuildClassTree(ACE: TgdClassEntry; AData: Pointer): Boolean;
begin
  if ACE <> nil then
    if not (ACE.SubType > '') then
      FClasses.Add(TgdcClassHandler.Create(
        ACE.gdcClass, gdcObject.Transaction.DefaultDatabase,
        gdcObject.Transaction));

  Result := True;
end;

procedure Tgdc_dlgRelationField.LoadClasses;

  procedure TraverseClassList(ACE: TgdClassEntry; ATreeNode: TTreeNode; ARF: TatRelationField);
  var
    LTreeNode: TTreeNode;
    I: Integer;
  begin
    if ACE <> nil then
    begin
      if not (ACE.SubType > '') then
      begin
        ACE.gdcClass.RegisterClassHierarchy;

        LTreeNode := tvObjects.Items.AddChild(ATreeNode,
        ACE.gdcClass.GetDisplayName('') + ' [' + ACE.gdcClass.ClassName + ']');

        if gdcObject.State = dsInsert then
        begin
          if tvObjects.Items.Count = 1 then
            LTreeNode.StateIndex := 1
          else
            LTreeNode.StateIndex := 2;
        end
        else
        begin
          if ARF.InObject(ACE.gdcClass.ClassName) then
            LTreeNode.StateIndex := 1
          else
            LTreeNode.StateIndex := 2;

          if LTreeNode.StateIndex = 1 then
            while (LTreeNode.Parent <> nil) and (LTreeNode.Parent.StateIndex <> 1) do
            begin
              LTreeNode := LTreeNode.Parent;
              LTreeNode.StateIndex := 3;
            end;
        end;
      end
      else
      begin
        LTreeNode := tvObjects.Items.AddChild(ATreeNode, ACE.Comment +
         ' [' + ACE.gdcClass.ClassName + '(' + ACE.SubType + ')]');
        if dsgdcBase.DataSet.State = dsInsert then
          tvObjects.Items[tvObjects.Items.Count - 1].StateIndex := 2
        else
        begin
          if ARF.InObject(ACE.gdcClass.ClassName + '(' + ACE.SubType + ')') then
            tvObjects.Items[tvObjects.Items.Count - 1].StateIndex := 1
          else
            tvObjects.Items[tvObjects.Items.Count - 1].StateIndex := 2;

          LTreeNode := tvObjects.Items[tvObjects.Items.Count - 1];
            if LTreeNode.StateIndex = 1 then
              while (LTreeNode.Parent <> nil) and (LTreeNode.Parent.StateIndex <> 1) do
              begin
                LTreeNode := LTreeNode.Parent;
                LTreeNode.StateIndex := 3;
              end;
        end;
      end;

      if ACE.Count > 0 then
      begin
        for I := 0 to ACE.Count - 1 do
        begin
          if ACE.Siblings[I] <> nil then
          begin
            TraverseClassList(ACE.Siblings[I], LTreeNode, ARF);
          end;
        end;
      end;
    end;
  end;

var
  F: TatRelationField;
  CE: TgdClassEntry;
begin
  tvObjects.SortType := stNone;
  tvObjects.Items.Clear;

  if not Assigned(gdClassList) then
    Exit;

  Screen.Cursor:= crHourGlass;
  try
    tvObjects.Items.BeginUpdate;
    try
      F := atDatabase.FindRelationField(gdcObject.FieldByName('relationname').AsString,
        gdcObject.FieldByName('fieldname').AsString);

      if Assigned(F) then
      begin
        CE := gdClassList.Find(TgdcBase);
        if CE <> nil then
          TraverseClassList(CE, nil, F);
      end else
        Label2.Caption := 'Объекты будут доступны после создания поля.';

    finally
      tvObjects.Items.EndUpdate;
    end;

  finally
    Screen.Cursor:= crArrow;
  end;
  tvObjects.SortType := stText;
end;

procedure Tgdc_dlgRelationField.comboBusinessClassChange(Sender: TObject);
begin
  UpdateSubTypes;
end;

procedure Tgdc_dlgRelationField.comboBusinessClassClick(Sender: TObject);
begin
  UpdateSubTypes;
end;

procedure Tgdc_dlgRelationField.WriteObjectState;
var
  I: Integer;
  AnObjects: String;
begin
  AnObjects := '';
  for I := 0 to tvObjects.Items.Count - 1 do
    if tvObjects.Items[I].StateIndex = 1 then
    begin
      if AnObjects > '' then
        AnObjects := AnObjects + ',';
      AnObjects := AnObjects + Copy(tvObjects.Items[I].Text,
        AnsiPos('[', tvObjects.Items[I].Text) + 1,
        Length(tvObjects.Items[I].Text) - 1 - AnsiPos('[', tvObjects.Items[I].Text));
    end;
  if AnObjects > '' then
    gdcObject.FieldByName('objects').AsString := AnObjects
  else
    gdcObject.FieldByName('objects').Clear;
end;

function Tgdc_dlgRelationField.DlgModified: Boolean;
begin
  Result := True;
end;

procedure Tgdc_dlgRelationField.dbmComputedChange(Sender: TObject);
begin
  inherited;
  if gdcObject.State = dsEdit then
    (gdcObject as TgdcRelationField).ChangeComputed := True;
end;

procedure Tgdc_dlgRelationField.BeforePost;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGRELATIONFIELD', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGRELATIONFIELD', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGRELATIONFIELD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGRELATIONFIELD',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGRELATIONFIELD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  //
  //  Проверка наличия префикса поля пользователя
  if gdcObject.State = dsInsert then
  begin
    if Trim(dbedRelationFieldName.Text) <> dbedRelationFieldName.Text then
      dbedRelationFieldName.Text := Trim(dbedRelationFieldName.Text);

    if StrIPos(UserPrefix, dbedRelationFieldName.Text) <> 1 then
      dbedRelationFieldName.Text := UserPrefix + dbedRelationFieldName.Text;

    if Length(dbedRelationFieldName.Text) <= Length(UserPrefix) then
      raise Egdc_dlgRelationField.Create('Укажите название поля на английском языке!');
  end;

  if comboBusinessClass.ItemIndex >= 0 then
  begin
    if not (gdcObject.State in [dsEdit, dsInsert]) then
      gdcObject.Edit;
    if comboBusinessClass.Items.Objects[comboBusinessClass.ItemIndex] = nil then
      gdcObject.FieldByName('gdclassname').Clear
    else
      gdcObject.FieldByName('gdclassname').AsString :=
        TgdcClassHandler(comboBusinessClass.Items.
          Objects[comboBusinessClass.ItemIndex]).gdcClassName;
    if comboClassSubType.ItemIndex >= 0 then
      gdcObject.FieldByName('gdsubtype').AsString :=
        FCurrentSubTypes.Values[FCurrentSubTypes.Names[comboClassSubType.ItemIndex]]
    else
      gdcObject.FieldByName('gdsubtype').Clear;
  end
  else
    if not gdcObject.FieldByName('gdclassname').IsNull then
    begin
      if not (gdcObject.State in [dsEdit, dsInsert]) then
        gdcObject.Edit;
      gdcObject.FieldByName('gdclassname').Clear;
      gdcObject.FieldByName('gdsubtype').Clear;
    end;

  if (gdcObject.State = dsInsert) and cmbRuleDelete.Visible then
    gdcObject.FieldByName('deleterule').asString := cmbRuleDelete.Text;
    
  WriteObjectState;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGRELATIONFIELD', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGRELATIONFIELD', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgRelationField.SetupRecord;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Field: TgdcField;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGRELATIONFIELD', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGRELATIONFIELD', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGRELATIONFIELD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGRELATIONFIELD',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGRELATIONFIELD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  IsNeedDefault := False;

  if not Assigned(gdcObject) then
    Exit;

  if gdcObject.State in dsEditModes then
  begin
    if gdcObject.FieldByName('sourcenullflag').AsInteger > 0 then
      gdcObject.FieldByName('nullflag').AsInteger :=
        gdcObject.FieldByName('sourcenullflag').AsInteger;
  end;
  //////////////////////////////////////////////////////////////////////////////
  //  Общие настройки для ввода нового поля и редактирования

  //
  //  Если редактирование поля таблицы

  if gdcObject.State = dsEdit then
  begin
    // При редактировании запрещаем изменять
    // наименование поля
    dbedRelationFieldName.ReadOnly := True;
    dbedRelationFieldName.Color := clBtnFace;

    luFieldType.ReadOnly := True;
    // Нельзя менять тип поля при редактировании

    dbmComputed.Visible := not gdcObject.FieldByName('computed_value').IsNull;
    lComputed.Visible := dbmComputed.Visible;
    cbCalculated.Enabled := False;
    cbCalculated.Checked := not gdcObject.FieldByName('computed_value').IsNull;

    if gdcObject.FieldByName('colwidth').IsNull then
      gdcObject.FieldByName('colwidth').AsInteger := 8;
    if gdcObject.FieldByName('visible').IsNull then
      gdcObject.FieldByName('visible').AsInteger := 0;

    dbcbNotNull.Enabled := False;
  end else

  //
  //  Если создание нового поля таблицы

  begin
    luFieldType.Enabled := True;
    cbCalculated.Enabled := not gdcObject.CachedUpdates;
    dbcbNotNull.Enabled := True;
  end;

  SetGDClass;

  (gdcObject as TgdcRelationField).ChangeComputed := False;

  //установка правила удаления
  if gdcObject.State = dsEdit then
  begin
    edDefaultValue.Enabled := False;
    lblDefaultValue.Enabled := False;
    Field := TgdcField.CreateSubType(Self, '', 'ByID');
    try
      if gdcObject.Transaction.InTransaction then
      begin
        Field.ReadTransaction := gdcObject.Transaction;
      end;
      Field.Transaction := gdcObject.Transaction;
      Field.ID := gdcObject.FieldByName('fieldsourcekey').AsInteger;
      Field.Open;
      //если мы добавляли поля в CachedUpdates, то новые домены еще могли не попасть в базу
      if Field.RecordCount > 0 then
      begin
        if Field.FieldByName('flag').AsInteger = 1 then
          IsNeedDefault := True;

        if not Field.FieldByName('reftable').IsNull or
          not Field.FieldByName('reflistfield').IsNull  then
        begin
          lblRuleDelete.Visible := True;
          cmbRuleDelete.Visible := True;
          cmbRuleDelete.ItemIndex := cmbRuleDelete.Items.IndexOf(
            UpperCase(Trim(gdcObject.FieldByName('deleterule').AsString)));
          lblRuleDelete.Enabled := False;
          cmbRuleDelete.Enabled := False;
        end;
      end else
        cmbRuleDelete.Enabled := False;
    finally
      Field.Free;
    end;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGRELATIONFIELD', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGRELATIONFIELD', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgRelationField.SetGDClass;
var
  I: Integer;
  CurObject: TObject;
  sbType: String;
begin
  CurObject := nil;
  for I := 0 to FClasses.Count - 1 do
  with FClasses[I] as TgdcClassHandler, gdcObject do
  begin
{ TODO : абстрактные классы у нас не имеют имени }
    if gdcDisplayName = '' then
      continue;

    if (FieldByName('gdclassname').AsString > '')
        and
      (AnsiCompareText(gdcClassName, FieldByName('gdclassname').AsString) = 0)
    then
      CurObject := FClasses[i];
  end;

  comboBusinessClass.ItemIndex := comboBusinessClass.Items.IndexOfObject(CurObject);

  comboClassSubType.Sorted := False;
  UpdateSubTypes;
  comboClassSubType.ItemIndex := -1;

  if (gdcObject.FieldByName('gdsubtype').AsString > '') then
  begin
    for I := 0 to FCurrentSubTypes.Count - 1 do
      if AnsiCompareText(
        FCurrentSubTypes.Values[FCurrentSubTypes.Names[I]],
        gdcObject.FieldByName('gdsubtype').AsString) = 0
      then begin
        comboClassSubType.ItemIndex := I;
        Break;
      end;
  end;
  if comboClassSubType.ItemIndex > -1 then
    sbType := comboClassSubType.Items[comboClassSubType.ItemIndex]
  else
    sbType := '';
  comboClassSubType.Sorted := True;

  if sbType > '' then
    comboClassSubType.ItemIndex := comboClassSubType.Items.IndexOf(sbType);

end;

procedure Tgdc_dlgRelationField.dbedRelationFieldNameEnter(
  Sender: TObject);
var
  S: string;
begin
  S:= '00000409';
  LoadKeyboardLayout(@S[1], KLF_ACTIVATE);
end;

procedure Tgdc_dlgRelationField.dbedRelationFieldNameKeyDown(
  Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if ((Shift = [ssShift]) and (Key = VK_INSERT)) or ((Shift = [ssCtrl]) and (Chr(Key) in ['V', 'v'])) then begin
    CheckClipboardForName;
  end;
end;

procedure Tgdc_dlgRelationField.dbedRelationFieldNameKeyPress(
  Sender: TObject; var Key: Char);
begin
  Key:= CheckNameChar(Key);
end;

procedure Tgdc_dlgRelationField.pcRelationFieldChange(Sender: TObject);
var
  Field: TgdcField;
begin
  if pcrelationField.ActivePage = tsVisualSettings then begin
    if luFieldType.CurrentKey > '' then begin
      Field := TgdcField.Create(nil);
      try
        Field.SubSet := 'ByID';
        Field.ID := StrToInt(luFieldType.CurrentKey);
        Field.Open;

        dbedFormat.Enabled:= Field.FieldByName('ffieldtype').AsInteger in
            [blr_d_float, blr_double, blr_float,
             blr_long, blr_int64, blr_short,
             blr_sql_date, blr_sql_time, blr_timestamp];
        lblFormat.Enabled:= dbedFormat.Enabled;
        if not dbedFormat.Enabled then
          dbedFormat.Text:= '';
      finally
        Field.Free;
      end;
    end;
  end
  else if pcrelationField.ActivePage = tsObjects then begin
    if tvObjects.Items.Count = 0 then
      LoadClasses;
  end;
end;

procedure Tgdc_dlgRelationField.FormCreate(Sender: TObject);
begin
  inherited;

  pcRelationField.ActivePage := tsCommon;
end;

initialization
  RegisterFrmClass(Tgdc_dlgRelationField);

finalization
  UnRegisterFrmClass(Tgdc_dlgRelationField);
end.
