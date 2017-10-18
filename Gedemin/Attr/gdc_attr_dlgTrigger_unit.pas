
unit gdc_attr_dlgTrigger_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgGMetaData_unit, Menus, Db, ActnList, StdCtrls, DBCtrls, Mask,
  SynEditHighlighter, SynHighlighterSQL, SynEdit, SynMemo, ExtCtrls,
  IBDatabase, gdc_dlgG_unit;

type
  Tgdc_dlgTrigger = class(Tgdc_dlgGMetaData)
    pnHead: TPanel;
    pnText: TPanel;
    smTriggerBody: TSynMemo;
    SynSQLSyn: TSynSQLSyn;
    dbeName: TDBEdit;
    cmbType: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    dbcActive: TDBCheckBox;
    Label3: TLabel;
    dbePos: TDBEdit;
    IBTransaction: TIBTransaction;
    procedure cmbTypeChange(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
    procedure smTriggerBodySpecialLineColors(Sender: TObject;
      Line: Integer; var Special: Boolean; var FG, BG: TColor);
    procedure smTriggerBodyChange(Sender: TObject);

  protected
    procedure BeforePost; override;
    procedure InvalidateForm; override;

  public
    constructor Create(AnOwner: TComponent); override;

    procedure SetupRecord; override;
    function TestCorrect: Boolean; override;
  end;

var
  gdc_dlgTrigger: Tgdc_dlgTrigger;

implementation

uses
  ibsql, at_classes, gd_ClassList, dmDatabase_unit, gdcMetaData,
  gdcTriggerHelper, gd_directories_const, gdcBaseInterface;

{$R *.DFM}

{ Tgdc_dlgTrigger }

procedure Tgdc_dlgTrigger.BeforePost;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  T: Integer;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGTRIGGER', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGTRIGGER', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGTRIGGER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGTRIGGER',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGTRIGGER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  //  Если триггер не имеет префикса триггера-атрибута,
  //  добавляем указанный префикс;

  if (gdcObject.State = dsInsert) and
    (AnsiPos(UserPrefix, AnsiUpperCase(gdcObject.FieldByName('triggername').AsString)) <> 1)
  then
    gdcObject.FieldByName('triggername').AsString :=
      System.Copy(UserPrefix + gdcObject.FieldByName('triggername').AsString, 1, cstMetaDataNameLength);

  if Trim(gdcObject.FieldByName('rdb$trigger_source').AsString) <> Trim(smTriggerBody.Lines.Text) then
    gdcObject.FieldByName('rdb$trigger_source').AsString := smTriggerBody.Lines.Text;

  T := gdcTriggerHelper.GetTypeID(cmbType.Text);
  if gdcObject.FieldByName('rdb$trigger_type').AsInteger <> T then
    gdcObject.FieldByName('rdb$trigger_type').AsInteger := T;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGTRIGGER', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGTRIGGER', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgTrigger.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGTRIGGER', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGTRIGGER', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGTRIGGER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGTRIGGER',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGTRIGGER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  smTriggerBody.Lines.Text := gdcObject.FieldByName('rdb$trigger_source').AsString;
  (gdcObject as TgdcBaseTrigger).EnumTriggerTypes(cmbType.Items);
  if gdcObject.FieldByName('rdb$trigger_type').AsInteger = 0 then
    cmbType.ItemIndex := -1
  else
    cmbType.ItemIndex := cmbType.Items.IndexOf(
      gdcTriggerHelper.GetTypeName(gdcObject.FieldByName('rdb$trigger_type').AsInteger));

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGTRIGGER', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGTRIGGER', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

function Tgdc_dlgTrigger.TestCorrect: Boolean;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  ibsql: TIBSQL;
  activetext: String;
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_DLGTRIGGER', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGTRIGGER', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGTRIGGER') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGTRIGGER',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGTRIGGER' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  Assert(not IBTransaction.Active);
  ClearError;

  Result := False;
  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := IBTransaction;
    IBTransaction.StartTransaction;

    if gdcObject.FieldByName('trigger_inactive').AsInteger <> 0 then
      activetext := 'INACTIVE'
    else
      activetext := 'ACTIVE';

    ibsql.ParamCheck := False;

    if gdcObject is TgdcTrigger then
      ibsql.SQL.Text := Format('CREATE OR ALTER TRIGGER %s FOR %s %s POSITION %s  %s ',
        [gdcObject.FieldByName('triggername').AsString, gdcObject.FieldByName('relationname').AsString,
         cmbType.Text, gdcObject.FieldByName('rdb$trigger_sequence').AsString,
         gdcObject.FieldByName('rdb$trigger_source').AsString])
    else
      ibsql.SQL.Text := Format('CREATE OR ALTER TRIGGER %s %s %s ',
        [gdcObject.FieldByName('triggername').AsString, cmbType.Text,
         gdcObject.FieldByName('rdb$trigger_source').AsString]);
    try
      ibsql.Prepare;
      Result := True;
    except
      on E: Exception do
      begin
        ExtractErrorLine(E.Message);
        raise Exception.Create(Format('При сохранении триггера возникла следующая ошибка'#13#10 +
          ' %s', [E.Message]));
      end;
    end;
  finally
    ibsql.Free;
    //На данном этапе мы ничего не меняем: транзакция необходима только для проверки
    //правильности написания триггера. Поэтому, если она не была открыта, мы ее открываем,
    // а по завершении проверки делаем откат
    if IBTransaction.InTransaction then
      IBTransaction.Rollback;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGTRIGGER', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGTRIGGER', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgTrigger.cmbTypeChange(Sender: TObject);
begin
  inherited;

  if gdcObject is TgdcTrigger then
  begin
    gdcObject.FieldByName('triggername').AsString := gdcBaseManager.AdjustMetaName(
      GetObjectNameByRelName(gdcObject.FieldByName('relationname').AsString,
        '_' + GetTypeAcronym(gdcTriggerHelper.GetTypeID(cmbType.Text)) + '_'));
  end;
end;

constructor Tgdc_dlgTrigger.Create(AnOwner: TComponent);
begin
  inherited;
  FEnterAsTab := 2; // отключим EnterAsTab
end;

procedure Tgdc_dlgTrigger.actOkUpdate(Sender: TObject);
begin
  if (cmbType.Text = '') or (dbePos.Text = '') then
    actOk.Enabled := False
  else
    inherited;

  btnOK.Default := not smTriggerBody.Focused;
end;

procedure Tgdc_dlgTrigger.smTriggerBodySpecialLineColors(Sender: TObject;
  Line: Integer; var Special: Boolean; var FG, BG: TColor);
begin
  if Line = FErrorLine then
  begin
    Special := True;
    BG := clRed;
    FG := clWhite;
  end;
end;

procedure Tgdc_dlgTrigger.InvalidateForm;
begin
  smTriggerBody.Invalidate;
end;

procedure Tgdc_dlgTrigger.smTriggerBodyChange(Sender: TObject);
begin 
  ClearError;
end;

initialization
  RegisterFrmClass(Tgdc_dlgTrigger);

finalization
  UnRegisterFrmClass(Tgdc_dlgTrigger);
end.
