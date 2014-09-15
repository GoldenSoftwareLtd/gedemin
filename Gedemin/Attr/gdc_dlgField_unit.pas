
{++


  Copyright (c) 2000-2012 by Golden Software of Belarus

  Module

    gdc_dlgField_unit.pas

  Abstract

    Dialog window to enter new field types (interbase domains).

  Author

    Anton Smirnov (25.12.2000)

  Revisions history

    1.0    15.11.2001    sai      Initial.
    2.0    05.12.2001    dennis   field creation and editing works correctly.

--}


unit gdc_dlgField_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBCustomDataSet, IBDatabase, ActnList, IBSQL, ComCtrls, gdcBase,
  StdCtrls, ExtCtrls, DBCtrls, gsIBLookupComboBox, Mask, Grids, DBGrids,
  gsDBGrid, gsIBGrid, gd_security, Contnrs, gdc_dlgG_unit, gdc_dlgTRMetaData_unit,
  Menus, gdc_dlgTR_unit, gdcBaseInterface, gd_ClassList;

type
  Tgdc_dlgField = class(Tgdc_dlgTRMetaData)
    pnlMain: TPanel;
    pcFieldType: TPageControl;
    tsMain: TTabSheet;
    tsType: TTabSheet;
    tsVisualSettings: TTabSheet;
    lblIBType: TLabel;
    lblName: TLabel;
    dbedName: TDBEdit;
    Label2: TLabel;
    dbedTypeName: TDBEdit;
    pcDataType: TPageControl;
    tsString: TTabSheet;
    tsNumeric: TTabSheet;
    tsTime: TTabSheet;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    cbAlwaysNotNull: TCheckBox;
    cbDefaultValue: TCheckBox;
    edDefaultValue: TEdit;
    cbConstraints: TCheckBox;
    edConstraints: TEdit;
    Label13: TLabel;
    dbrgAligment: TDBRadioGroup;
    Label14: TLabel;
    dbedColWidth: TDBEdit;
    dbcbVisible: TDBCheckBox;
    lblFormat: TLabel;
    dbedFormat: TDBEdit;
    tsReference: TTabSheet;
    tsSet: TTabSheet;
    cbOtherLanguage: TCheckBox;
    lblCharacterSet: TLabel;
    cbCharacterSet: TComboBox;
    cbCollation: TComboBox;
    lblCollation: TLabel;
    pnlString: TPanel;
    rgString: TRadioGroup;
    Label1: TLabel;
    edStringLength: TEdit;
    pnlNumeric: TPanel;
    rgNumeric: TRadioGroup;
    gbPrecision: TGroupBox;
    lblPrecision: TLabel;
    lblScale: TLabel;
    edPrecision: TEdit;
    edScale: TEdit;
    pnlTime: TPanel;
    rgData: TRadioGroup;
    pnlReference: TPanel;
    luRefRelation: TgsIBLookupComboBox;
    Label3: TLabel;
    lblRefListField: TLabel;
    luRefListField: TgsIBLookupComboBox;
    pnlSet: TPanel;
    Label16: TLabel;
    Label17: TLabel;
    Label19: TLabel;
    luSetRelation: TgsIBLookupComboBox;
    luSetListField: TgsIBLookupComboBox;
    cbCreateTextField: TCheckBox;
    edSetFieldLength: TEdit;
    lblOtherLanguage: TLabel;
    tsBlob: TTabSheet;
    pnlBlob: TPanel;
    rgBlobType: TRadioGroup;
    lblSubType: TLabel;
    edSubType: TEdit;
    lblSegmentSize: TLabel;
    edSegmentSize: TEdit;
    memoBlobInfo: TMemo;
    Label4: TLabel;
    Label5: TLabel;
    dbedDecription: TDBMemo;
    rgAutoUpdate: TRadioGroup;
    dbcbReadOnly: TDBCheckBox;
    lblBusinessClass: TLabel;
    lblClassSubType: TLabel;
    comboBusinessClass: TComboBox;
    comboClassSubType: TComboBox;
    memRefCondition: TDBMemo;
    memSetCondition: TDBMemo;
    tsEnumeration: TTabSheet;
    Panel1: TPanel;
    Label6: TLabel;
    lvNumeration: TListView;
    lValNum: TLabel;
    edValueNumeration: TEdit;
    Label11: TLabel;
    edNameNumeration: TEdit;
    bAddNumeration: TButton;
    bDelNumeration: TButton;
    acAddNumeration: TAction;
    acDeleteNumeration: TAction;
    Button1: TButton;
    actReplaceNum: TAction;
    Label7: TLabel;
    Label12: TLabel;

    procedure pcDataTypeChange(Sender: TObject);
    procedure pcDataTypeChanging(Sender: TObject;
      var AllowChange: Boolean);

    procedure rgNumericClick(Sender: TObject);
    procedure rgBlobTypeClick(Sender: TObject);
    procedure luRefRelationChange(Sender: TObject);
    procedure luSetRelationChange(Sender: TObject);
    procedure cbCreateTextFieldClick(Sender: TObject);
    procedure cbOtherLanguageClick(Sender: TObject);
    procedure cbDefaultValueClick(Sender: TObject);
    procedure cbConstraintsClick(Sender: TObject);
    procedure acAddNumerationExecute(Sender: TObject);
    procedure acAddNumerationUpdate(Sender: TObject);
    procedure acDeleteNumerationExecute(Sender: TObject);
    procedure acDeleteNumerationUpdate(Sender: TObject);
    procedure actReplaceNumExecute(Sender: TObject);
    procedure actReplaceNumUpdate(Sender: TObject);
    procedure lvNumerationSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure luSetListFieldCreateNewObject(Sender: TObject;
      ANewObject: TgdcBase);
    procedure luRefListFieldCreateNewObject(Sender: TObject;
      ANewObject: TgdcBase);
    procedure comboBusinessClassChange(Sender: TObject);
    procedure comboBusinessClassClick(Sender: TObject);
    procedure dbedTypeNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dbedTypeNameKeyPress(Sender: TObject; var Key: Char);
    procedure dbedTypeNameEnter(Sender: TObject);
    procedure pcFieldTypeChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    FClasses: TObjectList;
    FCurrentSubTypes: TStringList;

    FOldColWidth, FOldVisible, FOldFormat,
    FOldAlignment, FOldReadOnly: String;
    FOldgdClassName, FOldgdSubType: String;

    function SearchValueInNumeration(const Value: String): Boolean;

    procedure UpdateCharsetCollation;
    procedure UpdateOnlyEnglish;

    procedure UpdateDefaultValue;
    procedure UpdateConstraints;

    procedure UpdateNumeric;
    procedure UpdateBlobSubType;

    procedure UpdateRefRelation;
    procedure UpdateSetRelation;
    procedure UpdateSetTextField;

    procedure UpdateEditState;

    procedure TestName;
    procedure TestType;
    procedure TestVisualSettings;

    function BuildClassTree(ACE: TgdClassEntry; AData: Pointer): Boolean;

  protected
    procedure UpdateDomainInfo;

    procedure UpdateSubTypes;

    function MakeDomainInfo: Boolean;

    procedure ProceedAutomatedUpdate;

    procedure BeforePost; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetupRecord; override;
    procedure SetupDialog; override;
    function TestCorrect: Boolean; override;

  end;

  Egdc_dlgFieldError = class(Exception);

var
  gdc_dlgField: Tgdc_dlgField;

implementation

{$R *.DFM}

uses
  gdcMetaData, IBHeader, at_classes,

  at_sql_tools
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{ Tgdc_dlgField }

procedure Tgdc_dlgField.SetupRecord;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  I: Integer;
  clName, sbType: String;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGFIELD', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGFIELD', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGFIELD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGFIELD',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGFIELD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  ActivateTransaction(gdcObject.Transaction);

  //////////////////////////////////////////////////////////////////////////////
  //  Осуществляем первоначальную настройку диалогового окна

  pcFieldType.ActivePage := tsMain;

  //////////////////////////////////////////////////////////////////////////////
  // Вторая страница

  pcDataType.ActivePageIndex := 0;

  // Строковые данные
  rgString.ItemIndex := 1;
  edStringLength.Text := '';

  // Числовые данные
  rgNumeric.ItemIndex := 0;
  edPrecision.Text := '';
  edScale.Text := '';

  // Временные данные
  rgData.ItemIndex := 0;

  // Бинарный тип
  rgBlobType.ItemIndex := 0;
  edSubType.Text := '1';
  edSegmentSize.Text := '80';
  UpdateBlobSubType;

  // Данные тип - ссылка
  luRefRelation.ReadOnly := gdcObject.State <> dsInsert;

  // Данные тип - множество
  luSetRelation.ReadOnly := gdcObject.State <> dsInsert;

  cbCreateTextField.Checked := True;
  edSetFieldLength.Text := '';

  // Другие параметры
  cbAlwaysNotNull.Checked := False;
  cbDefaultValue.Checked := False;
  edDefaultValue.Text := '';
  cbConstraints.Checked := False;
  edConstraints.Text := '';

  luRefRelation.Transaction := gdcObject.Transaction;
  luRefListField.Transaction := gdcObject.Transaction;

  luSetRelation.Transaction := gdcObject.Transaction;
  luSetListField.Transaction := gdcObject.Transaction;

  //////////////////////////////////////////////////////////////////////////////
  //  Третья страница

  // Визуальные настройки
  dbrgAligment.ItemIndex := 0;

  rgAutoUpdate.Visible := gdcObject.State = dsEdit;


  comboBusinessClass.ItemIndex := -1;
  comboBusinessClass.Items.Clear;

  comboBusinessClass.Items.AddObject(' ', nil);
  comboBusinessClass.Sorted := False;
  comboClassSubType.Sorted := False;

  for I := 0 to FClasses.Count - 1 do
  with FClasses[I] as TgdcClassHandler, gdcObject do
  begin
    comboBusinessClass.Items.AddObject(
      gdcDisplayName + '[' + gdcClassName + ']',
      FClasses[I]
    );

    if
      (FieldByName('GDCLASSNAME').AsString <> '')
        and
      (AnsiCompareText(gdcClassName, FieldByName('GDCLASSNAME').AsString) = 0)
    then
      comboBusinessClass.ItemIndex := I + 1;
  end;

  UpdateSubTypes;
  comboClassSubType.ItemIndex := -1;

  if (gdcObject.FieldByName('GDSUBTYPE').AsString <> '') then
  begin
    for I := 0 to FCurrentSubTypes.Count - 1 do
      if AnsiCompareText(
        FCurrentSubTypes.Values[FCurrentSubTypes.Names[I]],
        gdcObject.FieldByName('GDSUBTYPE').AsString) = 0
      then begin
        comboClassSubType.ItemIndex := I;
        Break;
      end;
  end;
  if comboBusinessClass.ItemIndex > -1 then
    clName := comboBusinessClass.Items[comboBusinessClass.ItemIndex]
  else
    clName := '';

  if comboClassSubType.ItemIndex > -1 then
    sbType := comboClassSubType.Items[comboClassSubType.ItemIndex]
  else
    sbType := '';

  comboBusinessClass.Sorted := True;
  comboClassSubType.Sorted := True;

  if clName > '' then
    comboBusinessClass.ItemIndex := comboBusinessClass.Items.IndexOf(clName)
  else
    comboBusinessClass.ItemIndex := -1;

  if sbType > '' then
    comboClassSubType.ItemIndex := comboClassSubType.Items.IndexOf(sbType)
  else
    comboClassSubType.ItemIndex := -1;

  UpdateDomainInfo;

  if gdcObject.State = dsEdit then
    UpdateEditState;

  //
  //  Запоминаем старые значения
  //  определенных полей

  FOldColWidth := gdcObject.FieldByName('colwidth').AsString;
  FOldVisible := gdcObject.FieldByName('visible').AsString;
  FOldFormat := gdcObject.FieldByName('format').AsString;
  FOldAlignment := gdcObject.FieldByName('alignment').AsString;
  FOldReadOnly := gdcObject.FieldByName('readonly').AsString;
  FOldgdClassName := gdcObject.FieldByName('gdclassname').AsString;
  FOldgdSubType := gdcObject.FieldByName('gdsubtype').AsString;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGFIELD', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGFIELD', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

function Tgdc_dlgField.TestCorrect: Boolean;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
{  WasEditingState: Boolean;
  Stream: TStringStream;
  S: String;
  i: Integer;
  Relation: TatRelation;
  RelationField: TatRelationField;}
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_DLGFIELD', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGFIELD', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGFIELD') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGFIELD',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGFIELD' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  Result := True;

  //
  //  Осуществляем проверку
  //  показателей, необходимых
  //  для создания метаданных

  try
    TestName;
    TestType;
    TestVisualSettings;
  except
    ModalResult := mrNone;
    raise;
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGFIELD', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGFIELD', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgField.UpdateBlobSubType;
begin
  edSubType.Enabled := rgBlobType.ItemIndex > 0;
  if not edSubType.Enabled then
    edSubType.Text := '1'
  else if (edSubType.Text = '1') or (edSubType.Text = '') then
    edSubType.Text := '-1';
end;

procedure Tgdc_dlgField.UpdateCharsetCollation;
begin
  cbCharacterSet.Enabled := cbOtherLanguage.Checked and cbOtherLanguage.Enabled;
  lblCharacterSet.Enabled := cbOtherLanguage.Checked and cbOtherLanguage.Enabled;

  cbCollation.Enabled := cbOtherLanguage.Checked and cbOtherLanguage.Enabled;
  lblCollation.Enabled := cbOtherLanguage.Checked and cbOtherLanguage.Enabled;
end;

procedure Tgdc_dlgField.UpdateConstraints;
begin
  edConstraints.Enabled := cbConstraints.Checked;
end;

procedure Tgdc_dlgField.UpdateDefaultValue;
begin
  edDefaultValue.Enabled := cbDefaultValue.Checked;
end;

procedure Tgdc_dlgField.UpdateDomainInfo;
var
  Stream: TStringStream;
  S, ValueNum, NameNum: String;
  LI: TListItem;

begin
  //
  // Если имеем дело с доменом-ссылкой на другую таблицу

    if not gdcObject.FieldByName('reftable').IsNull or
      not gdcObject.FieldByName('reflistfield').IsNull then
    begin
      pcDataType.ActivePage := tsReference;

      luRefRelation.CurrentKey := gdcObject.FieldByName('reftablekey').AsString;
      luRefListField.CurrentKey := gdcObject.FieldByName('reflistfieldkey').AsString;
    end else

    if not gdcObject.FieldByName('settable').IsNull or
      not gdcObject.FieldByName('setlistfield').IsNull then
    begin
      luSetRelation.CurrentKey := gdcObject.FieldByName('settablekey').AsString;
      luSetListField.CurrentKey := gdcObject.FieldByName('setlistfieldkey').AsString;

      edSetFieldLength.Text := gdcObject.FieldByName('fcharlength').AsString;
      cbCreateTextField.Checked := edSetFieldLength.Text <> '';

      pcDataType.ActivePage := tsSet;
    end else

    if not gdcObject.FieldByName('numeration').IsNull then
    begin
      Stream := TStringStream.Create(gdcObject.FieldByName('numeration').AsString);
      try
        S := Stream.ReadString(Stream.Size);
        while S <> '' do
        begin
          ValueNum := copy(S, 1, Pos(#13#10, S) - 1);
          NameNum := copy(ValueNum, 3, Length(ValueNum));
          ValueNum := copy(S, 1, 1);
                    
          LI := lvNumeration.Items.Add;
          LI.Caption := ValueNum;
          LI.SubItems.Add(NameNum);

          S := copy(S, Pos(#13#10, S) + 2, Length(S));
        end;

      finally
        Stream.Free;
      end;
      pcDataType.ActivePage := tsEnumeration;
      
    end else

    case gdcObject.FieldByName('ffieldtype').AsInteger of
      //
      //  Если BLOB-поле

      blr_blob:
      begin
        pcDataType.ActivePage := tsBlob;

        if gdcObject.FieldByName('fsubtype').AsInteger = 1 then
          rgBlobType.ItemIndex := 0
        else
          rgBlobType.ItemIndex := 1;

        edSubType.Text := gdcObject.FieldByName('fsubtype').AsString;
        edSegmentSize.Text := gdcObject.FieldByName('seglength').AsString;
      end;

      //
      //  Строковое поле с перменной или постоянной длиной

      blr_text, blr_varying:
      begin
        pcDataType.ActivePage := tsString;
        edStringLength.Text := gdcObject.FieldByName('fcharlength').AsString;

        if gdcObject.FieldByName('ffieldtype').AsInteger = blr_text then
          rgString.ItemIndex := 0
        else
          rgString.ItemIndex := 1;
      end;
      blr_cstring: // not supported
        raise Egdc_dlgFieldError.Create('Тип не поддерживается!');

      //
      //  Числовое поле с дробной частью

      blr_d_float, blr_double, blr_float:
      begin
        pcDataType.ActivePage := tsNumeric;
        rgNumeric.ItemIndex := 3;

{        edPrecision.Text := gdcObject.FieldByName('fprecision').AsString;
        edScale.Text := IntToStr(Abs(gdcObject.FieldByName('fscale').AsInteger));}
      end;

      //
      //  Целое числовое поле

      blr_long, blr_int64:
      begin
        pcDataType.ActivePage := tsNumeric;

        if (gdcObject.FieldByName('fprecision').AsInteger > 0) or
         (gdcObject.FieldByName('fscale').AsInteger < 0) then
        begin
          rgNumeric.ItemIndex := 2;
          edPrecision.Text := gdcObject.FieldByName('fprecision').AsString;
          edScale.Text := IntToStr(Abs(gdcObject.FieldByName('fscale').AsInteger));
        end else
          rgNumeric.ItemIndex := 0;
      end;

      //
      //  Целое чисовое поле с меньшими границами

      blr_short:
      begin
        pcDataType.ActivePage := tsNumeric;
        rgNumeric.ItemIndex := 1;
      end;

      blr_quad: // not supported
        raise Egdc_dlgFieldError.Create('Тип не поддерживается!');

      //
      //  Поле дата

      blr_sql_date:
      begin
        pcDataType.ActivePage := tsTime;
        rgData.ItemIndex := 1;
      end;

      //
      //  Поле время

      blr_sql_time:
      begin
        pcDataType.ActivePage := tsTime;
        rgData.ItemIndex := 0;
      end;

      //
      //  Дата и время

      blr_timestamp:
      begin
        pcDataType.ActivePage := tsTime;
        rgData.ItemIndex := 2;
      end;
    end;

    cbOtherLanguage.Checked := cbCreateTextField.Checked;

    if gdcObject.State = dsInsert then
    begin
      cbCharacterSet.ItemIndex := 0;
      cbCollation.ItemIndex := 0;
    end else
    begin
      cbCharacterSet.Text := Trim(gdcObject.FieldByName('CHARSET').AsString);
      cbCollation.Text := Trim(gdcObject.FieldByName('COLLATION').AsString);
    end;

    cbAlwaysNotNull.Checked := Boolean(gdcObject.FieldByName('flag').AsInteger);

    edDefaultValue.Text := gdcObject.FieldByName('DEFSOURCE').AsString;
    cbDefaultValue.Checked := edDefaultValue.Text <> '';

    edConstraints.Text := gdcObject.FieldByName('CHECKSOURCE').AsString;
    cbConstraints.Checked := edConstraints.Text <> '';
end;

procedure Tgdc_dlgField.UpdateEditState;
begin
  dbedTypeName.ReadOnly := True;
  dbedTypeName.Color := clBtnFace;

  pnlString.Enabled := False;
  pnlNumeric.Enabled := False;
  pnlTime.Enabled := False;
  pnlBlob.Enabled := False;

  pnlReference.Enabled := pcDataType.ActivePage = tsReference;
  pnlSet.Enabled := pcDataType.ActivePage = tsSet;

  cbCreateTextField.Enabled := False;
  edSetFieldLength.Enabled := False;

  cbOtherLanguage.Enabled := False;
  cbCharacterSet.Enabled := False;
  cbCollation.Enabled := False;
  cbAlwaysNotNull.Enabled := False;
  cbDefaultValue.Enabled := False;
  edDefaultValue.Enabled := False;
  cbConstraints.Enabled := False;
  edConstraints.Enabled := False;

  lValNum.Enabled := False;
  edValueNumeration.Enabled := False;
end;

procedure Tgdc_dlgField.UpdateNumeric;
begin
  edPrecision.Enabled := rgNumeric.ItemIndex = 2;
  lblPrecision.Enabled := rgNumeric.ItemIndex = 2;

  edScale.Enabled := rgNumeric.ItemIndex = 2;
  lblScale.Enabled := rgNumeric.ItemIndex = 2;
end;

procedure Tgdc_dlgField.UpdateOnlyEnglish;
begin
  cbOtherLanguage.Enabled :=
    (pcDataType.ActivePage = tsSet) or
    (pcDataType.ActivePage = tsString) or
    ((pcDataType.ActivePage = tsBlob) and (rgBlobType.ItemIndex = 0));
  UpdateCharsetCollation;
end;

procedure Tgdc_dlgField.UpdateRefRelation;
begin
  if luRefRelation.CurrentKey = '' then
    luRefListField.Condition := 'RELATIONKEY = -1'
  else
    luRefListField.Condition := 'RELATIONKEY = ' + luRefRelation.CurrentKey;

  luRefListField.CurrentKey := '';
end;

procedure Tgdc_dlgField.UpdateSetRelation;
begin
  if luSetRelation.CurrentKey = '' then
    luSetListField.Condition := 'RELATIONKEY = -1'
  else
    luSetListField.Condition := 'RELATIONKEY = ' + luSetRelation.CurrentKey;
    
  luSetListField.CurrentKey := '';
end;

procedure Tgdc_dlgField.UpdateSetTextField;
begin
  edSetFieldLength.Enabled := cbCreateTextField.Checked;
  cbOtherLanguage.Enabled := cbCreateTextField.Checked;
  cbOtherLanguage.Checked := cbCreateTextField.Checked;
end;

procedure Tgdc_dlgField.pcDataTypeChange(Sender: TObject);
begin
  UpdateOnlyEnglish;
end;

procedure Tgdc_dlgField.pcDataTypeChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  AllowChange := gdcObject.State <> dsEdit;
end;

procedure Tgdc_dlgField.rgNumericClick(Sender: TObject);
begin
  UpdateNumeric;
end;

procedure Tgdc_dlgField.rgBlobTypeClick(Sender: TObject);
begin
  UpdateBlobSubType;
  UpdateOnlyEnglish;
end;

procedure Tgdc_dlgField.luRefRelationChange(Sender: TObject);
begin
  UpdateRefRelation;
end;

procedure Tgdc_dlgField.luSetRelationChange(Sender: TObject);
begin
  UpdateSetRelation;
end;

procedure Tgdc_dlgField.cbCreateTextFieldClick(Sender: TObject);
begin
  UpdateSetTextField;
end;

procedure Tgdc_dlgField.cbOtherLanguageClick(Sender: TObject);
begin
  UpdateCharsetCollation;
end;

procedure Tgdc_dlgField.cbDefaultValueClick(Sender: TObject);
begin
  UpdateDefaultValue;
end;

procedure Tgdc_dlgField.cbConstraintsClick(Sender: TObject);
begin
  UpdateConstraints;
end;

procedure Tgdc_dlgField.TestName;
var
  ibsql: TIBSQL;
begin
  Assert(gdcBaseManager <> nil);
  Assert(atDataBase <> nil);

  if gdcObject.State = dsEdit then
    exit;

  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := gdcBaseManager.ReadTransaction;
    ibsql.SQL.Text := 'SELECT * FROM at_fields WHERE fieldname = ' + QuotedStr(dbedTypeName.Text);
    ibsql.ExecQuery;
    if not ibsql.Eof then
      raise Egdc_dlgFieldError.Create('Наименование типа поля дублируется с уже существующим!');
  finally
    ibsql.Free;
  end;
end;

procedure Tgdc_dlgField.TestType;
var
  I: Integer;
  ibsql: TIBSQL;
begin
  Assert(gdcBaseManager <> nil);
  Assert(atDataBase <> nil);

  // Осуществляем проверку только в случае
  // добавления новой записи
  if gdcObject.State = dsEdit then Exit;

  //
  // Строковый тип

  if pcDataType.ActivePage = tsString then
  begin
    if rgString.ItemIndex = -1 then
    begin
      pcFieldType.ActivePage := tsType;
      rgString.SetFocus;

      raise Egdc_dlgFieldError.Create('Выберите тип строкового поля!');
    end;

    I := StrToIntDef(edStringLength.Text, 0);
    if I = 0 then
    begin
      pcFieldType.ActivePage := tsType;
      edStringLength.SetFocus;
      raise Egdc_dlgFieldError.Create('Длина строки указана некорректно!');
    end;
  end else

  //
  // Числовой тип

  if pcDataType.ActivePage = tsNumeric then
  begin
    if rgNumeric.ItemIndex = -1 then
    begin
      pcFieldType.ActivePage := tsType;
      rgNumeric.SetFocus;
      raise Egdc_dlgFieldError.Create('Выберите тип числового поля!');
    end;

    //
    //  Дробное число

    if rgNumeric.ItemIndex = 2 then
    begin
      I := StrToIntDef(edPrecision.Text, 0);
      if I = 0 then
      begin
        pcFieldType.ActivePage := tsType;
        edPrecision.SetFocus;
        raise Egdc_dlgFieldError.Create('Некорректно указано количество цифр (Precision)!');
      end;

      I := StrToIntDef(edScale.Text, 0);
      if I < 0 then
      begin
        pcFieldType.ActivePage := tsType;
        edScale.SetFocus;
        raise Egdc_dlgFieldError.Create('Некорректно указано количество цифр (Precision)!');
      end;
    end;
  end else

  //
  // Временной тип

  if pcDataType.ActivePage = tsTime then
  begin
    if rgData.ItemIndex = -1 then
    begin
      pcFieldType.ActivePage := tsType;
      rgData.SetFocus;
      raise Egdc_dlgFieldError.Create('Выберите тип временного поля!');
    end;
  end else

  //
  // Бинарный тип

  if pcDataType.ActivePage = tsBlob then
  begin
    if rgBlobType.ItemIndex = -1 then
    begin
      pcFieldType.ActivePage := tsType;
      rgBlobType.SetFocus;
      raise Egdc_dlgFieldError.Create('Выберите тип бинарного поля!');
    end;

    I := StrToIntDef(edSubType.Text, 0);
    if I = 0 then
    begin
      pcFieldType.ActivePage := tsType;
      edSubType.SetFocus;
      raise Egdc_dlgFieldError.Create('Некорректно указан подтип поля!');
    end else begin
      if (rgBlobType.ItemIndex = 0) and (I <> 1) then
      begin
        pcFieldType.ActivePage := tsType;
        raise Egdc_dlgFieldError.Create('Подтип "1" только для строкового типа!');
      end;
    end;

    I := StrToIntDef(edSegmentSize.Text, 0);
    if I <= 0 then
    begin
      pcFieldType.ActivePage := tsType;
      edSegmentSize.SetFocus;
      raise Egdc_dlgFieldError.Create('Некорректно указан размер сегмента!');
    end;
  end else

  //
  //  Ссылка на другую таблицу

  if pcDataType.ActivePage = tsReference then
  begin
    if luRefRelation.CurrentKey = '' then
    begin
      pcFieldType.ActivePage := tsType;
      luRefRelation.SetFocus;
      raise Egdc_dlgFieldError.Create('Выберите ссылку на таблицу!');
    end;

    if luRefListField.CurrentKey = '' then
    begin
      pcFieldType.ActivePage := tsType;
      luRefListField.SetFocus;
      raise Egdc_dlgFieldError.Create('Выберите поле таблицы для отображения!');
    end;

    if Trim(memRefCondition.Text) > '' then
    begin
      ibsql := TIBSQL.Create(nil);
      try
        ibsql.Transaction := gdcBaseManager.ReadTransaction;
        ibsql.SQL.Text := 'SELECT ' +
          atDataBase.Relations.ByID(luRefRelation.CurrentKeyInt).RelationFields.ByID(luRefListField.CurrentKeyInt).FieldName +
          ' FROM ' + atDataBase.Relations.ByID(luRefRelation.CurrentKeyInt).RelationName +
          ' WHERE ' + Trim(memRefCondition.Text);
        try
          ibsql.Prepare;
        except
          on E: Exception do
          begin
            if atDataBase.InMultiConnection then
              MessageBox(Self.Handle, PChar('При сохранении условия возникла ошибка: ' +
                E.Message + ' Возможно, у вас еще не создались необходимые мета-данные. Попробуйте перезагрузиться.'),
                'Сохранение типа', MB_ICONEXCLAMATION or MB_OK)
            else
              raise Exception.Create('При сохранении условия возникла ошибка: ' +
                E.Message);
          end;
        end;
      finally
        ibsql.Free;
      end;
    end;
  end else

  //
  //  Множество

  if pcDataType.ActivePage = tsSet then
  begin
    if luSetRelation.CurrentKey = '' then
    begin
      pcFieldType.ActivePage := tsType;
      luSetRelation.SetFocus;
      raise Egdc_dlgFieldError.Create('Выберите ссылку на таблицу-источник множества!');
    end;

    if luSetListField.CurrentKey = '' then
    begin
      pcFieldType.ActivePage := tsType;
      luSetListField.SetFocus;
      raise Egdc_dlgFieldError.Create('Выберите поле таблицы для отображения!');
    end;

    if cbCreateTextField.Checked then
    begin
      I := StrToIntDef(edSetFieldLength.Text, 0);
      if I = 0 then
      begin
        pcFieldType.ActivePage := tsType;
        edSetFieldLength.SetFocus;
        raise Egdc_dlgFieldError.Create('Укажите корректный размер поля!');
      end;
    end;

    if Trim(memSetCondition.Text) > '' then
    begin
      ibsql := TIBSQL.Create(nil);
      try
        ibsql.Transaction := gdcBaseManager.ReadTransaction;
        ibsql.SQL.Text := 'SELECT ' +
          atDataBase.Relations.ByID(luSetRelation.CurrentKeyInt).RelationFields.ByID(luSetListField.CurrentKeyInt).FieldName +
          ' FROM ' + atDataBase.Relations.ByID(luSetRelation.CurrentKeyInt).RelationName +
          ' WHERE ' + Trim(memSetCondition.Text);
        try
          ibsql.Prepare;
        except
          on E: Exception do
          begin
            if atDataBase.InMultiConnection then
              MessageBox(Self.Handle, PChar('При сохранении условия возникла ошибка: ' +
                E.Message + ' Возможно, у вас еще не создались необходимые мета-данные. Попробуйте перезагрузиться.'),
                'Сохранение типа', MB_ICONEXCLAMATION or MB_OK)
            else
              raise Exception.Create('При сохранении условия возникла ошибка: ' +
                E.Message);
          end;
        end;
      finally
        ibsql.Free;
      end;
    end;
  end else

  if pcDataType.ActivePage = tsEnumeration then
  begin
    if lvNumeration.Items.Count = 0 then
    begin
      pcFieldType.ActivePage := tsType;
      edValueNumeration.SetFocus;
      raise Egdc_dlgFieldError.Create('Укажите значения для типа перечисление');
    end;
  end;

  //
  //  Проверка символьной кодировки

  if cbOtherLanguage.Enabled and cbOtherLanguage.Checked then
  begin
    if cbCharacterSet.Text = '' then
    begin
      pcFieldType.ActivePage := tsType;
      cbCharacterSet.SetFocus;
      raise Egdc_dlgFieldError.
        Create('Укажите кодировку (Character Set) текстового поля!');
    end;

    if cbCollation.Text = '' then
    begin
      pcFieldType.ActivePage := tsType;
      cbCollation.SetFocus;
      raise Egdc_dlgFieldError.
        Create('Укажите сличение (Collation) текстового поля!');
    end;
  end;

  if cbDefaultValue.Checked then
  begin
    if edDefaultValue.Text = '' then
    begin
      pcFieldType.ActivePage := tsType;
      edDefaultValue.SetFocus;
      raise Egdc_dlgFieldError.Create('Укажите значение по умолчанию!');
    end;
  end;

  if cbConstraints.Checked then
  begin
    if edConstraints.Text = '' then
    begin
      pcFieldType.ActivePage := tsType;
      edConstraints.SetFocus;
      raise Egdc_dlgFieldError.Create('Укажите список ограничений!');
    end;
  end;
end;

procedure Tgdc_dlgField.TestVisualSettings;
begin
  with gdcObject do
  begin
    if FieldByName('alignment').AsString = '' then
    begin
      pcFieldType.ActivePage := tsVisualSettings;
      dbrgAligment.SetFocus;
      raise Egdc_dlgFieldError.Create('Укажите вид выравнивания для типа поля!');
    end;

    if FieldByName('colwidth').AsString = '' then
    begin
      pcFieldType.ActivePage := tsVisualSettings;
      dbedColWidth.SetFocus;
      raise Egdc_dlgFieldError.Create('Укажите ширину поля!');
    end;

    if FieldByName('visible').AsString = '' then
    begin
      pcFieldType.ActivePage := tsVisualSettings;
      dbcbVisible.SetFocus;
      raise Egdc_dlgFieldError.Create('Укажите видимость поля при отображении!');
    end;


    {
      TODO 2 -oденис -cнедоработка : Необходимо прямо здесь осуществлять проверку
      формата отображения поля
    }
  end;
end;

function Tgdc_dlgField.MakeDomainInfo: Boolean;
var
  ibsql: TIBSQL;
  Relation: TatRelation;
begin
  //
  //  Если строка

  if pcDataType.ActivePage = tsString then
  begin
    case rgString.ItemIndex of
      0: gdcObject.FieldByName('ffieldtype').AsInteger := blr_text;
      1: gdcObject.FieldByName('ffieldtype').AsInteger := blr_varying;
      else
        gdcObject.FieldByName('ffieldtype').Clear;
    end;
    try
      gdcObject.FieldByName('fcharlength').AsString := edStringLength.Text;
    except
      raise Egdc_dlgFieldError.Create('Неправильно указана длина строки!');
    end;
  end else

  //
  //  Если число

  if pcDataType.ActivePage = tsNumeric then
  begin
    case rgNumeric.ItemIndex of
      0: gdcObject.FieldByName('ffieldtype').AsInteger := blr_long;
      1: gdcObject.FieldByName('ffieldtype').AsInteger := blr_short;
      2: gdcObject.FieldByName('ffieldtype').AsInteger := blr_int64;
      3: gdcObject.FieldByName('ffieldtype').AsInteger := blr_double;
      else
        gdcObject.FieldByName('ffieldtype').Clear;
    end;

    //
    //  Если дробное число

    if rgNumeric.ItemIndex = 2 then
    begin
      gdcObject.FieldByName('fprecision').AsString := edPrecision.Text;
      gdcObject.FieldByName('fscale').AsString := edScale.Text;
    end;
  end else

  //
  //  Если дата/время

  if pcDataType.ActivePage = tsTime then
  begin
    case rgData.ItemIndex of
      0: gdcObject.FieldByName('ffieldtype').AsInteger := blr_sql_time;
      1: gdcObject.FieldByName('ffieldtype').AsInteger := blr_sql_date;
      2: gdcObject.FieldByName('ffieldtype').AsInteger := blr_timestamp;
      else
        gdcObject.FieldByName('ffieldtype').Clear;
    end;
  end else

  //
  //  Если blob-поле

  if pcDataType.ActivePage = tsBlob then
  begin
    gdcObject.FieldByName('ffieldtype').AsInteger := blr_blob;
    if rgBlobType.ItemIndex = 0 then
      gdcObject.FieldByName('fsubtype').AsInteger := 1
    else
    begin
      gdcObject.FieldByName('fsubtype').AsString := edSubType.Text;
    end;
    gdcObject.FieldByName('seglength').AsString := edSegmentSize.Text;

  end else

  //
  //  Если ссылка

  if pcDataType.ActivePage = tsReference then
  begin
    ibsql := TIBSQL.Create(nil);
    try
      ibsql.Transaction := gdcObject.Transaction;
      ibsql.SQL.Text := 'SELECT r.relationname FROM at_relations r WHERE r.id = ' +
        luRefRelation.CurrentKey;
      ibsql.ExecQuery;
      if ibsql.RecordCount > 0 then
      begin
        Relation := atDatabase.Relations.ByRelationName(ibsql.FieldByName('relationname').AsString);
        if Assigned(Relation) and Assigned(Relation.PrimaryKey)
           and Assigned(Relation.PrimaryKey.ConstraintFields)
        then
        begin
          gdcObject.FieldByName('ffieldtype').AsInteger := Relation.PrimaryKey.ConstraintFields[0].SQLType;
          if (gdcObject.FieldByName('ffieldtype').AsInteger <> blr_long) and
             (gdcObject.FieldByName('ffieldtype').AsInteger <> blr_short)
          then
          begin
            gdcObject.FieldByName('fprecision').AsInteger := 18;
            gdcObject.FieldByName('fscale').AsInteger := 0;
          end;
        end;
      end
      else
        raise EgdcIBError.Create('Неверная структура атрибутов');
    finally
    end;
  end else

  //
  //  Если множество

  if pcDataType.ActivePage = tsSet then
  begin
    //
    //  Если необходимо создавать и строковое поле
    //  для отображения текста множества

    if cbCreateTextField.Checked then
    begin
      gdcObject.FieldByName('ffieldtype').AsInteger := blr_varying;
      gdcObject.FieldByName('fcharlength').AsString := edSetFieldLength.Text;
    end

    //
    //  Если же без строкового поля

    else
      gdcObject.FieldByName('ffieldtype').AsInteger := blr_short;
  end else

  if pcDataType.ActivePage = tsEnumeration then
  begin
    gdcObject.FieldByName('ffieldtype').AsInteger := blr_text;
    gdcObject.FieldByName('fcharlength').AsInteger := 1;
  end;

  // Устанавливаем значение по умолчанию
  gdcObject.FieldByName('defsource').AsString := edDefaultValue.Text;

  // Устанавливаем значение NOT NULL
  gdcObject.FieldByName('flag').AsInteger := Integer(cbAlwaysNotNull.Checked);

  // Если используются ограничения
  if cbConstraints.Checked then
    gdcObject.FieldByName('checksource').AsString := edConstraints.Text;

  // Устанавливаем COLLATION для строковых полей
  if cbOtherLanguage.Enabled and cbOtherLanguage.Checked
  then
  begin
    gdcObject.FieldByName('charset').AsString := cbCharacterSet.Text;
    if (pcDataType.ActivePage <> tsBlob) then
      gdcObject.FieldByName('collation').AsString := cbCollation.Text;
  end else
  begin
    gdcObject.FieldByName('charset').Clear;
    if (pcDataType.ActivePage <> tsBlob) then
      gdcObject.FieldByName('collation').Clear;
  end;

  Result := not gdcObject.FieldByName('ffieldtype').IsNull;
end;

constructor Tgdc_dlgField.Create(AnOwner: TComponent);
begin
  inherited;

  FClasses := TObjectList.Create;
  FCurrentSubTypes := TStringList.Create;
  FCurrentSubTypes.Sorted := True;
end;

destructor Tgdc_dlgField.Destroy;
begin
  FClasses.Free;
  FCurrentSubTypes.Free;

  inherited;
end;

procedure Tgdc_dlgField.UpdateSubTypes;
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
          comboClassSubType.Items.Add(FCurrentSubTypes.Names[I]
            + '[' + FCurrentSubTypes.Values[FCurrentSubTypes.Names[I]] + ']');
    end;
  end;
end;

procedure Tgdc_dlgField.ProceedAutomatedUpdate;
var
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(nil);

  try
    ibsql.Database := gdcObject.Database;
    ibsql.Transaction := gdcObject.Transaction;

    case rgAutoUpdate.ItemIndex of
      0: // обновляем все
      begin
        ibsql.SQL.Text :=
          'UPDATE at_relation_fields SET colwidth = :colwidth, visible = :visible, ' +
          'format = :format, alignment = :alignment, readonly = :readonly, ' +
          'gdclassname = :gdclassname, gdsubtype = :gdsubtype ' +
          ' WHERE fieldsourcekey = :fieldsourcekey';
        ibsql.ParamByName('fieldsourcekey').AsInteger := gdcObject.ID;

        ibsql.ParamByName('colwidth').AsString :=
          gdcObject.FieldByName('colwidth').AsString;
        ibsql.ParamByName('visible').AsString :=
          gdcObject.FieldByName('visible').AsString;
        ibsql.ParamByName('format').AsString :=
          gdcObject.FieldByName('format').AsString;
        ibsql.ParamByName('alignment').AsString :=
          gdcObject.FieldByName('alignment').AsString;
        ibsql.ParamByName('readonly').AsString :=
          gdcObject.FieldByName('readonly').AsString;
        ibsql.ParamByName('gdclassname').AsString :=
          gdcObject.FieldByName('gdclassname').AsString;
        ibsql.ParamByName('gdsubtype').AsString :=
          gdcObject.FieldByName('gdsubtype').AsString;

        ibsql.ExecQuery;
      end;
      1: // обновляем, где совпадают настройки полей
      begin
        //
        // Обновление ширины

        ibsql.SQL.Text :=
          'UPDATE at_relation_fields SET colwidth = :colwidth WHERE ' +
          'fieldsourcekey = :fieldsourcekey AND colwidth = :oldcolwidth';

        ibsql.ParamByName('fieldsourcekey').AsInteger := gdcObject.ID;
        ibsql.ParamByName('colwidth').AsString :=
          gdcObject.FieldByName('colwidth').AsString;
        ibsql.ParamByName('oldcolwidth').AsString :=
          FOldColWidth;

        ibsql.ExecQuery;

        //
        // Обновление видимости

        ibsql.SQL.Text :=
          'UPDATE at_relation_fields SET visible = :visible WHERE ' +
          'fieldsourcekey = :fieldsourcekey AND visible = :oldvisible';

        ibsql.ParamByName('fieldsourcekey').AsInteger := gdcObject.ID;
        ibsql.ParamByName('visible').AsString :=
          gdcObject.FieldByName('visible').AsString;
        ibsql.ParamByName('oldvisible').AsString :=
          FOldVisible;

        ibsql.ExecQuery;

        //
        // Обновление формата

        ibsql.SQL.Text :=
          'UPDATE at_relation_fields SET format = :format WHERE ' +
          'fieldsourcekey = :fieldsourcekey AND format = :oldformat';

        ibsql.ParamByName('fieldsourcekey').AsInteger := gdcObject.ID;
        ibsql.ParamByName('format').AsString :=
          gdcObject.FieldByName('format').AsString;
        ibsql.ParamByName('oldformat').AsString :=
          FOldFormat;

        ibsql.ExecQuery;

        //
        // Обновление выравнивания

        ibsql.SQL.Text :=
          'UPDATE at_relation_fields SET alignment = :alignment WHERE ' +
          'fieldsourcekey = :fieldsourcekey AND alignment = :oldalignment';

        ibsql.ParamByName('fieldsourcekey').AsInteger := gdcObject.ID;
        ibsql.ParamByName('alignment').AsString :=
          gdcObject.FieldByName('alignment').AsString;
        ibsql.ParamByName('oldalignment').AsString :=
          FOldAlignment;

        ibsql.ExecQuery;

        //
        // Обновление запрета редатикрования

        ibsql.SQL.Text :=
          'UPDATE at_relation_fields SET readonly = :readonly WHERE ' +
          'fieldsourcekey = :fieldsourcekey AND readonly = :oldreadonly';

        ibsql.ParamByName('fieldsourcekey').AsInteger := gdcObject.ID;
        ibsql.ParamByName('readonly').AsString :=
          gdcObject.FieldByName('readonly').AsString;
        ibsql.ParamByName('oldreadonly').AsString :=
          FOldReadOnly;

        ibsql.ExecQuery;

        //
        // Обновление класса и сабтайпа

        ibsql.SQL.Text :=
          ' UPDATE at_relation_fields ' +
          ' SET gdclassname = :gdclassname, gdsubtype = :gdsubtype ' +
          ' WHERE fieldsourcekey = :fieldsourcekey AND UPPER(gdclassname) = :oldgdclassname ' +
          ' AND UPPER(gdsubtype) = :oldgdsubtype ';

        ibsql.ParamByName('fieldsourcekey').AsInteger := gdcObject.ID;
        ibsql.ParamByName('gdclassname').AsString :=
          gdcObject.FieldByName('gdclassname').AsString;
        ibsql.ParamByName('gdsubtype').AsString :=
          gdcObject.FieldByName('gdsubtype').AsString;
        ibsql.ParamByName('oldgdclassname').AsString :=
          AnsiUpperCase(FOldgdclassname);
        ibsql.ParamByName('oldgdsubtype').AsString :=
          AnsiUpperCase(FOldgdsubtype);

        ibsql.ExecQuery;

      end;
      2: // не производим никаких действий
      begin
      end;
    end;

  finally
    ibsql.Free;
  end;
end;

procedure Tgdc_dlgField.acAddNumerationExecute(Sender: TObject);
var
  LI: TListItem;
begin
  if not SearchValueInNumeration(edValueNumeration.Text) then
  begin
    LI := lvNumeration.Items.Add;
    LI.Caption := edValueNumeration.Text;
    LI.SubItems.Add(edNameNumeration.Text);
  end
  else
    MessageBox(HANDLE, 'Дублируется значение!', 'Внимание', mb_OK or mb_IconInformation);
end;

procedure Tgdc_dlgField.acAddNumerationUpdate(Sender: TObject);
begin
  acAddNumeration.Enabled := (gdcObject.State = dsInsert) and
    (edValueNumeration.Text <> '') and
    (edNameNumeration.Text <> '');
end;

procedure Tgdc_dlgField.acDeleteNumerationExecute(Sender: TObject);
begin
  if lvNumeration.Selected <> nil then
    lvNumeration.Items.Delete(lvNumeration.Items.IndexOf(lvNumeration.Selected));
end;

procedure Tgdc_dlgField.acDeleteNumerationUpdate(Sender: TObject);
begin
  acDeleteNumeration.Enabled := (gdcObject.State = dsInsert) and (lvNumeration.Selected <> nil);
end;

procedure Tgdc_dlgField.actReplaceNumExecute(Sender: TObject);
begin
  if (lvNumeration.Selected <> nil) and (edValueNumeration.Text <> '') and
      (edNameNumeration.Text <> '')
  then
  begin
    if (edValueNumeration.Text = lvNumeration.Selected.Caption) or
        not SearchValueInNumeration(edValueNumeration.Text)
    then
    begin
      lvNumeration.Selected.Caption := edValueNumeration.Text;
      lvNumeration.Selected.SubItems.Delete(0);
      lvNumeration.Selected.SubItems.Add(edNameNumeration.Text);
    end
    else
      MessageBox(HANDLE, 'Дублируется значение!', 'Внимание', mb_OK or mb_IconInformation);
  end;
end;

procedure Tgdc_dlgField.actReplaceNumUpdate(Sender: TObject);
begin
  actReplaceNum.Enabled := (lvNumeration.Selected <> nil) and
    (edValueNumeration.Text <> '') and
    (edNameNumeration.Text <> '');

end;

procedure Tgdc_dlgField.lvNumerationSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  if Selected then
  begin
    edValueNumeration.Text := Item.Caption;
    edNameNumeration.Text := Item.SubItems[0];
  end;
end;

function Tgdc_dlgField.SearchValueInNumeration(
  const Value: String): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i:= 0 to lvNumeration.Items.Count - 1 do
    if lvNumeration.Items[i].Caption = Value then
    begin
      Result := True;
      Break;
    end;
end;

procedure Tgdc_dlgField.luSetListFieldCreateNewObject(Sender: TObject;
  ANewObject: TgdcBase);
begin
  inherited;
  if luSetRelation.CurrentKey <> '' then
    ANewObject.FieldByName('relationkey').AsString := luSetRelation.CurrentKey
  else
  begin
    MessageBox(HANDLE, 'Необходимо указать ссылку на таблицу перед добавлением поля',
      'Внимание', mb_OK or mb_IconInformation);
    abort;
  end;
end;

procedure Tgdc_dlgField.luRefListFieldCreateNewObject(Sender: TObject;
  ANewObject: TgdcBase);
begin
  inherited;
  if luRefRelation.CurrentKey <> '' then
    ANewObject.FieldByName('relationkey').AsString := luRefRelation.CurrentKey
  else
  begin
    MessageBox(HANDLE, 'Необходимо указать ссылку на таблицу перед добавлением поля',
      'Внимание', mb_OK or mb_IconInformation);
    abort;
  end;
end;

procedure Tgdc_dlgField.comboBusinessClassChange(Sender: TObject);
begin
  UpdateSubTypes;
end;

procedure Tgdc_dlgField.comboBusinessClassClick(Sender: TObject);
begin
  UpdateSubTypes;
end;


procedure Tgdc_dlgField.BeforePost;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Relation: TatRelation;
  RelationField: TatRelationField;
  Stream: TStringStream;
  I: Integer;
  S: String;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGFIELD', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGFIELD', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGFIELD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGFIELD',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGFIELD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  with gdcObject do
  begin
    //
    //  Если поле не имеет префикса поля-атрибута,
    //  добавляем указанный префикс;
    //  если не указано кратное наименование и(или)
    //  описание поля - копируем из локализированного наименования

    if (State = dsInsert) and
      (AnsiPos(UserPrefix, AnsiUpperCase(FieldByName('fieldname').AsString)) <> 1)
    then
      FieldByName('fieldname').AsString :=
        UserPrefix +
        FieldByName('fieldname').AsString;
  end;

    //
  //  Осуществляем проверку и создание
  //  метаданных

  if pcDataType.ActivePage = tsReference then
  begin
    gdcObject.FieldByName('reftablekey').AsString := luRefRelation.CurrentKey;
    gdcObject.FieldByName('reflistfieldkey').AsString := luRefListField.CurrentKey;
    Relation := atDatabase.Relations.ByID(
      gdcObject.FieldByName('reftablekey').AsInteger);
    if Assigned(Relation) then
    begin
      gdcObject.FieldByName('reftable').AsString := Relation.RelationName;
      RelationField :=
        Relation.RelationFields.ByID(
          gdcObject.FieldByName('reflistfieldkey').AsInteger);
      if Assigned(RelationField) then
        gdcObject.FieldByName('reflistfield').AsString := RelationField.FieldName;
    end;
  end else

  begin
    gdcObject.FieldByName('reftablekey').Clear;
    gdcObject.FieldByName('reflistfieldkey').Clear;
    gdcObject.FieldByName('reftable').Clear;
    gdcObject.FieldByName('reflistfield').Clear;
  end;

  if pcDataType.ActivePage = tsSet then
  begin
    gdcObject.FieldByName('settablekey').AsString := luSetRelation.CurrentKey;
    gdcObject.FieldByName('setlistfieldkey').AsString := luSetListField.CurrentKey;
    Relation :=
      atDatabase.Relations.ByID(
        gdcObject.FieldByName('settablekey').AsInteger);
    if Assigned(Relation) then
    begin
      gdcObject.FieldByName('settable').AsString := Relation.RelationName;
      RelationField :=
        Relation.RelationFields.ByID(gdcObject.FieldByName('setlistfieldkey').AsInteger);
      if Assigned(RelationField) then
        gdcObject.FieldByName('setlistfield').AsString := RelationField.FieldName;
    end;
  end else
  begin
    gdcObject.FieldByName('settablekey').Clear;
    gdcObject.FieldByName('setlistfieldkey').Clear;
    gdcObject.FieldByName('settable').Clear;
    gdcObject.FieldByName('setlistfield').Clear;
  end;

  if
    (comboBusinessClass.ItemIndex <> -1) and
    (comboBusinessClass.Items.Objects[comboBusinessClass.ItemIndex] <> nil)
  then
    gdcObject.FieldByName('GDCLASSNAME').AsString :=
      TgdcClassHandler(comboBusinessClass.Items.
        Objects[comboBusinessClass.ItemIndex]).gdcClassName
  else
    gdcObject.FieldByName('GDCLASSNAME').Clear;

  if comboClassSubType.ItemIndex <> -1 then
    gdcObject.FieldByName('GDSUBTYPE').AsString :=
      FCurrentSubTypes.Values[FCurrentSubTypes.Names[comboClassSubType.ItemIndex]]
  else
    gdcObject.FieldByName('GDSUBTYPE').Clear;

  if pcDataType.ActivePage = tsEnumeration then
  begin
    Stream := TStringStream.Create('');
    try
      S := '';
      for i:= 0 to lvNumeration.Items.Count - 1 do
        S := S + lvNumeration.Items[i].Caption + ';' + lvNumeration.Items[i].SubItems[0] + #13#10;
      Stream.WriteString(S);
      (gdcObject.FieldByName('numeration') as TBlobField).LoadFromStream(Stream);
    finally
      Stream.Free;
    end;
  end;

  if gdcObject.State = dsInsert then
    MakeDomainInfo

  else if gdcObject.State = dsEdit then
    ProceedAutomatedUpdate;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGFIELD', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGFIELD', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

function Tgdc_dlgField.BuildClassTree(ACE: TgdClassEntry; AData: Pointer): Boolean;
begin
  if ACE <> nil then
    if not (ACE.SubType > '') then
      FClasses.Add(TgdcClassHandler.Create(
        ACE.gdcClass, gdcObject.Transaction.DefaultDatabase,
        gdcObject.Transaction));
        
  Result := True;
end;

procedure Tgdc_dlgField.SetupDialog;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGFIELD', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGFIELD', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGFIELD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGFIELD',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGFIELD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FClasses.Clear;

  //  Подготовка базовых классов

  gdClassList.Traverse(TgdcBase, '', BuildClassTree, nil);

  luRefRelation.Condition :=
    '(SELECT COUNT(*) ' +
    'FROM rdb$relation_constraints rc ' + 
    '  JOIN rdb$index_segments iseg ON iseg.rdb$index_name = rc.rdb$index_name ' +
    '  JOIN rdb$relation_fields rf on rf.rdb$field_name = iseg.rdb$field_name AND rf.rdb$relation_name = rc.rdb$relation_name ' +
    '  JOIN rdb$fields f ON f.rdb$field_name = rf.rdb$field_source ' +
    'WHERE f.rdb$field_type = 8 AND rc.rdb$constraint_type = ''PRIMARY KEY'' AND rc.rdb$relation_name = relationname) = 1';

  luSetRelation.Condition := luRefRelation.Condition;  

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGFIELD', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGFIELD', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgField.dbedTypeNameEnter(Sender: TObject);
var
  S: String;
begin
  S:= '00000409';
  LoadKeyboardLayout(@S[1], KLF_ACTIVATE);
end;

procedure Tgdc_dlgField.dbedTypeNameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ((Shift = [ssShift]) and (Key = VK_INSERT)) or ((Shift = [ssCtrl]) and (Chr(Key) in ['V', 'v'])) then begin
    CheckClipboardForName;
  end;
end;

procedure Tgdc_dlgField.dbedTypeNameKeyPress(Sender: TObject;
  var Key: Char);
begin
  Key:= CheckNameChar(Key);
end;

procedure Tgdc_dlgField.pcFieldTypeChange(Sender: TObject);
begin
  if pcFieldType.ActivePage = tsVisualSettings then begin
    dbedFormat.Enabled:= gdcObject.FieldByName('ffieldtype').AsInteger in
        [blr_d_float, blr_double, blr_float,
         blr_long, blr_int64, blr_short,
         blr_sql_date, blr_sql_time, blr_timestamp];
    lblFormat.Enabled:= dbedFormat.Enabled;
    if not dbedFormat.Enabled then
      dbedFormat.Text:= '';
    comboBusinessClass.Enabled:= pcDataType.ActivePage = tsReference;
    comboClassSubType.Enabled:= comboBusinessClass.Enabled;
    lblBusinessClass.Enabled:= comboBusinessClass.Enabled;
    lblClassSubType.Enabled:= comboBusinessClass.Enabled;
  end;
end;

procedure Tgdc_dlgField.FormCreate(Sender: TObject);
begin
  inherited;
  UpdateOnlyEnglish;
end;

initialization
  RegisterFrmClass(Tgdc_dlgField);

finalization
  UnRegisterFrmClass(Tgdc_dlgField);

end.

