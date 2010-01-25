unit gdc_attr_dlgStoredProc_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgGMetaData_unit, Db, ActnList, StdCtrls, ComCtrls, DBCtrls, Mask, ExtCtrls,
  SynEdit, SynMemo, SynEditHighlighter, SynHighlighterSQL, at_Classes, IBSQL,
  IBDatabase, Menus, gdc_dlgG_unit;

type
  Tgdc_attr_dlgStoredProc = class(Tgdc_dlgGMetaData)
    pcStoredProc: TPageControl;
    tsNameSP: TTabSheet;
    tsBodySP: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    dbedProcedureName: TDBEdit;
    dbmDescription: TDBMemo;
    pProcedureBody: TPanel;
    smProcedureBody: TSynMemo;
    SynSQLSyn: TSynSQLSyn;
    IBTransaction: TIBTransaction;
    procedure pcStoredProcChanging(Sender: TObject;
      var AllowChange: Boolean);
    procedure actOkUpdate(Sender: TObject);
    procedure dbedProcedureNameEnter(Sender: TObject);
    procedure dbedProcedureNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dbedProcedureNameKeyPress(Sender: TObject; var Key: Char);
    procedure pcStoredProcChange(Sender: TObject);

  protected
    procedure BeforePost; override;

  public
    function TestCorrect: Boolean; override;
    procedure SetupDialog; override;
    procedure SetupRecord; override;
  end;

var
  gdc_attr_dlgStoredProc: Tgdc_attr_dlgStoredProc;

implementation

{$R *.DFM}

uses
  gdcBase,
  gdcMetaData,
  gd_ClassList
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{ Tgdc_attr_dlgStoredProc }

procedure Tgdc_attr_dlgStoredProc.pcStoredProcChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  if pcStoredProc.ActivePage = tsNameSP then
  begin
    dbmDescription.SetFocus;
    AllowChange := Trim(gdcObject.FieldByName('procedurename').AsString) > '';

    if AllowChange then
    begin
      if (Pos(UserPrefix, gdcObject.FieldByName('procedurename').AsString) = 0)
        and (gdcObject.State = dsInsert) then
      begin
        gdcObject.FieldByName('procedurename').AsString := UserPrefix +
          gdcObject.FieldByName('procedurename').AsString;
      end;
    end else
    begin
      MessageBox(Handle,
        'Необходимо ввести наименование процедуры.',
        'Внимание',
        mb_Ok or mb_IconInformation or MB_TASKMODAL);
      dbedProcedureName.SetFocus;
    end;
  end;
end;

function Tgdc_attr_dlgStoredProc.TestCorrect: Boolean;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  ibsql: TIBSQL;
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_ATTR_DLGSTOREDPROC', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_ATTR_DLGSTOREDPROC', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_ATTR_DLGSTOREDPROC') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_ATTR_DLGSTOREDPROC',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_ATTR_DLGSTOREDPROC' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  if gdcObject.FieldByName('procedurename').AsString = '' then
    raise EgdcIBError.Create('Необходимо указать имя процедуры');

  if (smProcedureBody.Text > '') and
     (Pos(Trim(gdcObject.FieldByName('procedurename').AsString), smProcedureBody.Text) = 0) then
  begin
    raise EgdcIBError.Create('Неправильное имя функции');
  end;

  Result := False;

  if gdcObject.FieldByName('rdb$procedure_source').AsString > '' then
  begin
    ibsql := TIBSQL.Create(Self);
    IBTransaction.StartTransaction;
    try
      ibsql.Database := gdcObject.Database;
      ibsql.Transaction := IBTransaction;
      ibsql.SQL.Text := gdcObject.FieldByName('rdb$procedure_source').AsString;
      ibsql.ParamCheck := False;
      try
        ibsql.Prepare;
        ibsql.CheckValidStatement;
      except
        on E: Exception do
          raise EgdcIBError.Create(Format('При сохранении процедуры возникла следующая ошибка: %s',
            [E.Message]));
      end;
    finally
      ibsql.Free;
      IBTransaction.RollBack;
    end;
    Result := True;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_ATTR_DLGSTOREDPROC', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_ATTR_DLGSTOREDPROC', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_attr_dlgStoredProc.actOkUpdate(Sender: TObject);
begin
  if Trim(smProcedureBody.Text) > '' then
    inherited
  else
    actOk.Enabled := False;  
  btnOK.Default := not smProcedureBody.Focused;
end;

procedure Tgdc_attr_dlgStoredProc.BeforePost;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_ATTR_DLGSTOREDPROC', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_ATTR_DLGSTOREDPROC', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_ATTR_DLGSTOREDPROC') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_ATTR_DLGSTOREDPROC',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_ATTR_DLGSTOREDPROC' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  gdcObject.FieldByName('rdb$procedure_source').AsString := smProcedureBody.Text;

  if (Trim(dbmDescription.Lines.Text) = '') and (gdcObject.FieldByName('RDB$DESCRIPTION').AsString <> ' ') then
    gdcObject.FieldByName('RDB$DESCRIPTION').AsString:= ' ';

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_ATTR_DLGSTOREDPROC', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_ATTR_DLGSTOREDPROC', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_attr_dlgStoredProc.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_ATTR_DLGSTOREDPROC', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_ATTR_DLGSTOREDPROC', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_ATTR_DLGSTOREDPROC') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_ATTR_DLGSTOREDPROC',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_ATTR_DLGSTOREDPROC' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if gdcObject.State = dsEdit then
  begin
    dbedProcedureName.Enabled := False;
    smProcedureBody.Text := (gdcObject as TgdcStoredProc).GetAlterProcedureText
  end else
    smProcedureBody.Text := '';

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_ATTR_DLGSTOREDPROC', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_ATTR_DLGSTOREDPROC', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_attr_dlgStoredProc.SetupDialog;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_ATTR_DLGSTOREDPROC', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_ATTR_DLGSTOREDPROC', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_ATTR_DLGSTOREDPROC') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_ATTR_DLGSTOREDPROC',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_ATTR_DLGSTOREDPROC' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  pcStoredProc.ActivePage := tsNameSP;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_ATTR_DLGSTOREDPROC', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_ATTR_DLGSTOREDPROC', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_attr_dlgStoredProc.dbedProcedureNameEnter(Sender: TObject);
var
  S: string;
begin
  S:= '00000409';
  LoadKeyboardLayout(@S[1], KLF_ACTIVATE);
end;

procedure Tgdc_attr_dlgStoredProc.dbedProcedureNameKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if ((Shift = [ssShift]) and (Key = VK_INSERT)) or ((Shift = [ssCtrl]) and (Chr(Key) in ['V', 'v'])) then begin
    CheckClipboardForName;
  end;
end;

procedure Tgdc_attr_dlgStoredProc.dbedProcedureNameKeyPress(
  Sender: TObject; var Key: Char);
begin
  Key:= CheckNameChar(Key);
end;

procedure Tgdc_attr_dlgStoredProc.pcStoredProcChange(Sender: TObject);
begin
  if pcStoredProc.ActivePage = tsBodySP then
  begin
    if smProcedureBody.Text = '' then
      smProcedureBody.Text := (gdcObject as TgdcStoredProc).GetCreateProcedureText;
  end;
end;

initialization
  RegisterFrmClass(Tgdc_attr_dlgStoredProc);

finalization
  UnRegisterFrmClass(Tgdc_attr_dlgStoredProc);

end.
