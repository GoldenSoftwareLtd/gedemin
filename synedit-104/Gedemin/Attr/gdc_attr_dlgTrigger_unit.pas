unit gdc_attr_dlgTrigger_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgGMetaData_unit, Menus, Db, ActnList, StdCtrls, DBCtrls, Mask,
  SynEditHighlighter, SynHighlighterSQL, SynEdit, SynMemo, ExtCtrls,
  IBDatabase, gdc_dlgG_unit;

type
  Tgdc_dlgTrigger = class(Tgdc_dlgGMetadata)
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

  private
    function GetItemIndex(const TypeTrigger :Integer): Integer;
    function GetTypeByIndex(const Index : Integer): Integer;

  protected
    procedure BeforePost; override;

  public
    procedure SetupRecord; override;
    function TestCorrect: Boolean; override;
  end;

var
  gdc_dlgTrigger: Tgdc_dlgTrigger;

implementation
uses
  ibsql, at_classes, gd_ClassList, dmDatabase_unit;

{$R *.DFM}

{ Tgdc_dlgTrigger }

procedure Tgdc_dlgTrigger.BeforePost;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
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
      UserPrefix + gdcObject.FieldByName('triggername').AsString;

  if Trim(gdcObject.FieldByName('rdb$trigger_source').AsString) <> Trim(smTriggerBody.Lines.Text) then
    gdcObject.FieldByName('rdb$trigger_source').AsString := smTriggerBody.Lines.Text;
    
  if gdcObject.FieldByName('rdb$trigger_type').AsInteger <> GetTypeByIndex(cmbType.ItemIndex) then
    gdcObject.FieldByName('rdb$trigger_type').AsInteger := GetTypeByIndex(cmbType.ItemIndex);

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
  cmbType.ItemIndex := GetItemIndex(gdcObject.FieldByName('rdb$trigger_type').AsInteger - 1);
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

  Result := False;
  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := IBTransaction;
    IBTransaction.Active := True;

    if gdcObject.FieldByName('trigger_inactive').AsInteger > 0 then
      activetext := 'INACTIVE'
    else
      activetext := 'ACTIVE';

    ibsql.ParamCheck := False;
    if not gdcObject.CachedUpdates then
    begin
      if gdcObject.State = dsInsert then
        ibsql.SQL.Text := Format('CREATE TRIGGER %s FOR %s %s POSITION %s  %s ',
          [gdcObject.FieldByName('triggername').AsString, gdcObject.FieldByName('relationname').AsString,
           cmbType.Text, gdcObject.FieldByName('rdb$trigger_sequence').AsString,
           gdcObject.FieldByName('rdb$trigger_source').AsString])
      else
        ibsql.SQL.Text := Format('ALTER TRIGGER %s %s %s POSITION %s  %s ',
          [gdcObject.FieldByName('triggername').AsString, activetext,
           cmbType.Text, gdcObject.FieldByName('rdb$trigger_sequence').AsString,
           gdcObject.FieldByName('rdb$trigger_source').AsString]);

      try
        ibsql.Prepare;
        Result := True;
      except
        on E: Exception do
          raise Exception.Create(Format('При сохранении триггера возникла следующая ошибка'#13#10 +
            ' %s', [E.Message]));
      end;
    end
    else begin
      ibsql.SQL.Text := 'SELECT * FROM rdb$triggers WHERE rdb$trigger_name = ''' +
        AnsiUpperCase(gdcObject.FieldByName('triggername').AsString) + ''' ';
      ibsql.ExecQuery;
      if ibsql.EOF then
      begin
        ibsql.Close;
        ibsql.SQL.Text := Format('CREATE TRIGGER %s FOR %s %s POSITION %s  %s ',
          [gdcObject.FieldByName('triggername').AsString, gdcObject.FieldByName('relationname').AsString,
           cmbType.Text, gdcObject.FieldByName('rdb$trigger_sequence').AsString,
           gdcObject.FieldByName('rdb$trigger_source').AsString]);
      end else
      begin
        ibsql.Close;
        ibsql.SQL.Text := Format('ALTER TRIGGER %s %s %s POSITION %s  %s ',
            [gdcObject.FieldByName('triggername').AsString, activetext,
             cmbType.Text, gdcObject.FieldByName('rdb$trigger_sequence').AsString,
             gdcObject.FieldByName('rdb$trigger_source').AsString]);
      end;

      try
        ibsql.Prepare;
        Result := True;
      except
        on E: Exception do
        begin
          raise Exception.Create(Format('При сохранении триггера возникла следующая ошибка'#13#10 +
            ' %s', [E.Message]));
        end;
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

function Tgdc_dlgTrigger.GetItemIndex(const TypeTrigger: Integer): Integer;
begin
  case TypeTrigger of
    0..5: Result := TypeTrigger;
    16: Result := 6;
    17: Result := 7;
    24: Result := 8;
    25: Result := 9;
    26: Result := 10;
    27: Result := 11;
    113: Result := 12;
    114: Result := 13;
  else
    Result := TypeTrigger;
  end;
end;

function Tgdc_dlgTrigger.GetTypeByIndex(const Index: Integer): Integer;
begin
  case Index of
    0..5: Result := Index + 1;
    6: Result := 17;
    7: Result := 18;
    8: Result := 25;
    9: Result := 26;
    10: Result := 27;
    11: Result := 28;
    12: Result := 113;
    13: Result := 114;
  else
    Result := Index + 1;
  end;
end;

procedure Tgdc_dlgTrigger.cmbTypeChange(Sender: TObject);
var
  RelPrefix, RelName: String;
  UnderLinePos: Integer;
begin
  inherited;

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
    RelPrefix := UserPrefix;
    RelName := AnsiUpperCase(gdcObject.FieldByName('relationname').AsString);
  end;
  RelName := Trim(RelName);

  case cmbType.ItemIndex of
    0: gdcObject.FieldByName('triggername').AsString := RelPrefix + 'BI'
      + '_' + RelName;
    1: gdcObject.FieldByName('triggername').AsString := RelPrefix + 'AI'
      + '_' + RelName;
    2: gdcObject.FieldByName('triggername').AsString := RelPrefix + 'BU'
      + '_' + RelName;
    3: gdcObject.FieldByName('triggername').AsString := RelPrefix + 'AU'
      + '_' + RelName;
    4: gdcObject.FieldByName('triggername').AsString := RelPrefix + 'BD'
      + '_' + RelName;
    5: gdcObject.FieldByName('triggername').AsString := RelPrefix + 'AD'
      + '_' + RelName;
    6: gdcObject.FieldByName('triggername').AsString := RelPrefix + 'BIU'
      + '_' + RelName;
    7: gdcObject.FieldByName('triggername').AsString := RelPrefix + 'AIU'
      + '_' + RelName;
    8: gdcObject.FieldByName('triggername').AsString := RelPrefix + 'BID'
      + '_' + RelName;
    9: gdcObject.FieldByName('triggername').AsString := RelPrefix + 'AID'
      + '_' + RelName;
    10: gdcObject.FieldByName('triggername').AsString := RelPrefix + 'BUD'
      + '_' + RelName;
    11: gdcObject.FieldByName('triggername').AsString := RelPrefix + 'AUD'
      + '_' + RelName;
    12: gdcObject.FieldByName('triggername').AsString := RelPrefix + 'BIUD'
      + '_' + RelName;
    13: gdcObject.FieldByName('triggername').AsString := RelPrefix + 'AIUD'
      + '_' + RelName;
  end
end;

initialization
  RegisterFrmClass(Tgdc_dlgTrigger);

finalization
  UnRegisterFrmClass(Tgdc_dlgTrigger);

end.
