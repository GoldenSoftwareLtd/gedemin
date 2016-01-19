
{++

  Copyright (c) 2001 - 2016 by Golden Software of Belarus, Ltd

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
    Label7: TLabel;
    dbedRelationFieldName: TDBEdit;
    dbedRelationFieldLName: TDBEdit;
    dbedRelationFieldShortLName: TDBEdit;
    dbedRelationFieldDescription: TDBMemo;
    tsVisualSettings: TTabSheet;
    Label8: TLabel;
    Label14: TLabel;
    lblFormat: TLabel;
    dbrgAligment: TDBRadioGroup;
    dbedColWidth: TDBEdit;
    dbcbVisible: TDBCheckBox;
    dbedFormat: TDBEdit;
    dbcbReadOnly: TDBCheckBox;
    tsObjects: TTabSheet;
    Label2: TLabel;
    actAddObject: TAction;
    btnAddObjects: TButton;
    Bevel1: TBevel;
    actDelObject: TAction;
    btnDelObject: TButton;
    actSelectBC: TAction;
    actDelBC: TAction;
    pnlBC: TPanel;
    lblBusinessClass: TLabel;
    Label9: TLabel;
    dbedBusinessClass: TDBEdit;
    dbedSubType: TDBEdit;
    btnSelectBC: TButton;
    btnDelBC: TButton;
    lbClasses: TListBox;
    Label10: TLabel;
    pnlType: TPanel;
    pcType: TPageControl;
    tsType: TTabSheet;
    lblDefaultValue: TLabel;
    lblRuleDelete: TLabel;
    Label6: TLabel;
    dbcbNotNull: TDBCheckBox;
    luFieldType: TgsIBLookupComboBox;
    edDefaultValue: TDBMemo;
    cmbRuleDelete: TComboBox;
    tsCalculated: TTabSheet;
    lComputed: TLabel;
    dbmComputed: TDBMemo;

    procedure luFieldTypeChange(Sender: TObject);
    procedure dbmComputedChange(Sender: TObject);
    procedure dbedRelationFieldNameEnter(Sender: TObject);
    procedure dbedRelationFieldNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dbedRelationFieldNameKeyPress(Sender: TObject;
      var Key: Char);
    procedure pcRelationFieldChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actDelBCExecute(Sender: TObject);
    procedure actDelBCUpdate(Sender: TObject);
    procedure actSelectBCExecute(Sender: TObject);
    procedure actSelectBCUpdate(Sender: TObject);
    procedure actDelObjectUpdate(Sender: TObject);
    procedure actDelObjectExecute(Sender: TObject);
    procedure actAddObjectExecute(Sender: TObject);

  private
    IsNeedDefault: Boolean;

  protected
    procedure BeforePost; override;

  public
    procedure SetupRecord; override;
    function TestCorrect: Boolean; override;
  end;

  Egdc_dlgRelationField = class(Exception);

var
  gdc_dlgRelationField: Tgdc_dlgRelationField;

implementation

{$R *.DFM}

uses
  gdcMetaData, IBSQL, at_classes, gdcBase, gdcBaseInterface, gd_resourcestring,
  jclStrings, at_sql_tools, gd_dlgClassList_unit;

const
  cst_Restrict   = 'RESTRICT';
  cst_Cascade    = 'CASCADE';
  cst_SetNull    = 'SET NULL';
  cst_SetDefault = 'SET DEFAULT';

{ Tgdc_dlgRelationField }

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
    if (pcType.ActivePage = tsCalculated) and (Trim(dbmComputed.Text) = '') then
    begin
      pcRelationField.ActivePage := tsCommon;
      dbmComputed.SetFocus;
      MessageBox(Handle,
        'Укажите выражение для вычисляемого поля.',
        'Внимание',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
      Result := False;
    end;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGRELATIONFIELD', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGRELATIONFIELD', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgRelationField.luFieldTypeChange(Sender: TObject);
var
  Field: TgdcField;
begin
  if gdcObject.State = dsInsert then
  begin
    if luFieldType.CurrentKeyInt > -1 then
    begin
      Field := TgdcField.Create(nil);
      try
        Field.SubSet := 'ByID';
        Field.ID := luFieldType.CurrentKeyInt;
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

        if (not Field.FieldByName('reftable').IsNull) or
          (not Field.FieldByName('reflistfield').IsNull)  then
        begin
          pnlBC.Visible := True;
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
          pnlBC.Visible := False;
          lblRuleDelete.Visible := False;
          cmbRuleDelete.Visible := False;
        end;

        if (Trim(Field.FieldByName('fieldname').AsString) <> Trim(Field.FieldByName('lname').AsString)) then
        begin
          if ((gdcObject.FieldByName('fieldname').AsString = gdcObject.FieldByName('lname').AsString)
            or gdcObject.FieldByName('lname').IsNull)
          then
            gdcObject.FieldByName('lname').AsString := Field.FieldByName('lname').AsString;

          if ((gdcObject.FieldByName('fieldname').AsString = gdcObject.FieldByName('lshortname').AsString)
            or gdcObject.FieldByName('lshortname').IsNull)
          then
            gdcObject.FieldByName('lshortname').AsString :=
              Copy(Field.FieldByName('lname').AsString, 1, gdcObject.FieldByName('lshortname').Size);
        end;

        gdcObject.FieldByName('gdclassname').AsString :=
          Field.FieldByName('gdclassname').AsString;

        gdcObject.FieldByName('gdsubtype').AsString :=
          Field.FieldByName('gdsubtype').AsString;
      finally
        Field.Free;
      end;
    end else
    begin
      pnlBC.Visible := False;
      lblRuleDelete.Visible := False;
      cmbRuleDelete.Visible := False;
    end;
  end;
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

  if (gdcObject.State = dsInsert) and cmbRuleDelete.Visible then
    gdcObject.FieldByName('deleterule').asString := cmbRuleDelete.Text;

  if lbClasses.Items.Count > 0 then
    gdcObject.FieldByName('objects').AsString := lbClasses.Items.CommaText
  else
    gdcObject.FieldByName('objects').Clear;

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

  if gdcObject.State in dsEditModes then
  begin
    if gdcObject.FieldByName('sourcenullflag').AsInteger > 0 then
      gdcObject.FieldByName('nullflag').AsInteger :=
        gdcObject.FieldByName('sourcenullflag').AsInteger;
    if gdcObject.FieldByName('colwidth').IsNull then
      gdcObject.FieldByName('colwidth').AsInteger := 8;
    if gdcObject.FieldByName('visible').IsNull then
      gdcObject.FieldByName('visible').AsInteger := 0;
  end;

  if gdcObject.State = dsEdit then
  begin
    dbedRelationFieldName.ReadOnly := True;
    dbedRelationFieldName.Color := clBtnFace;
    luFieldType.ReadOnly := True;
    dbcbNotNull.Enabled := False;
    edDefaultValue.Enabled := False;
    lblDefaultValue.Enabled := False;

    if gdcObject.FieldByName('computed_value').IsNull then
    begin
      tsType.Visible := True;
      tsType.TabVisible := True;
      tsCalculated.TabVisible := False;
      tsCalculated.Visible := False;
      pcType.ActivePage := tsType;
    end else
    begin
      tsType.Visible := False;
      tsType.TabVisible := False;
      tsCalculated.TabVisible := True;
      tsCalculated.Visible := True;
      pcType.ActivePage := tsCalculated;
    end;

    Field := TgdcField.CreateSubType(nil, '', 'ByID');
    try
      if gdcObject.Transaction.InTransaction then
      begin
        Field.ReadTransaction := gdcObject.Transaction;
      end;
      Field.Transaction := gdcObject.Transaction;
      Field.ID := gdcObject.FieldByName('fieldsourcekey').AsInteger;
      Field.Open;
      if not Field.EOF then
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
  end else
  begin
    luFieldType.Enabled := True;
    //cbCalculated.Enabled := True;
    dbcbNotNull.Enabled := True;
  end;

  (gdcObject as TgdcRelationField).ChangeComputed := False;

  lbClasses.Items.CommaText := gdcObject.FieldByName('objects').AsString;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGRELATIONFIELD', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGRELATIONFIELD', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
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
  if pcrelationField.ActivePage = tsVisualSettings then
  begin
    if luFieldType.CurrentKey > '' then
    begin
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
  end;
end;

procedure Tgdc_dlgRelationField.FormCreate(Sender: TObject);
begin
  inherited;

  pcRelationField.ActivePage := tsCommon;
end;

procedure Tgdc_dlgRelationField.actDelBCExecute(Sender: TObject);
begin
  gdcObject.FieldbyName('gdclassname').Clear;
  gdcObject.FieldbyName('gdsubtype').Clear;
end;

procedure Tgdc_dlgRelationField.actDelBCUpdate(Sender: TObject);
begin
  actDelBC.Enabled := (gdcObject <> nil)
    and (gdcObject.State in [dsEdit, dsInsert])
    and (
      (gdcObject.FieldbyName('gdclassname').AsString > '')
      or
      (gdcObject.FieldbyName('gdsubtype').AsString > '')
    );
end;

procedure Tgdc_dlgRelationField.actSelectBCExecute(Sender: TObject);
var
  FC: TgdcFullClassName;
begin
  with Tgd_dlgClassList.Create(Self) do
  try
    if SelectModal('', FC) then
    begin
      gdcObject.FieldByName('gdclassname').AsString := FC.gdClassName;
      gdcObject.FieldByName('gdsubtype').AsString := FC.SubType;
    end;
  finally
    Free;
  end;
end;

procedure Tgdc_dlgRelationField.actSelectBCUpdate(Sender: TObject);
begin
  actSelectBC.Enabled := (gdcObject <> nil) and (gdcObject.State in [dsEdit, dsInsert]);
end;

procedure Tgdc_dlgRelationField.actDelObjectUpdate(Sender: TObject);
begin
  actDelObject.Enabled := lbClasses.ItemIndex > -1;
end;

procedure Tgdc_dlgRelationField.actDelObjectExecute(Sender: TObject);
begin
  lbClasses.Items.Delete(lbClasses.ItemIndex);
end;

procedure Tgdc_dlgRelationField.actAddObjectExecute(Sender: TObject);
var
  FC: TgdcFullClassName;
  S: String;
begin
  with Tgd_dlgClassList.Create(Self) do
  try
    if SelectModal('', FC) then
    begin
      if FC.SubType > '' then
        S := FC.gdClassName + '(' + FC.SubType + ')'
      else
        S := FC.gdClassName;

      if lbClasses.Items.IndexOf(S) = -1 then
        lbClasses.Items.Add(S);
    end;
  finally
    Free;
  end;
end;

initialization
  RegisterFrmClass(Tgdc_dlgRelationField);

finalization
  UnRegisterFrmClass(Tgdc_dlgRelationField);
end.
