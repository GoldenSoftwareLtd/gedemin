
unit gdc_dlgUser_unit;

interface

uses
  Windows, Classes, ActnList, Db, IBCustomDataSet, IBUpdateSQL, IBQuery,
  StdCtrls, DBCtrls, Controls, Mask, ExtCtrls, Forms, SysUtils, Dialogs,
  ComCtrls, gsIBLookupComboBox, gdc_dlgTRPC_unit, gdcBase, gdcUser, dmDatabase_unit,
  IBDatabase, gdc_dlgAddUserToGroup_unit, at_Container, Menus,
  gdc_dlgTR_unit, Spin, prp_PropertySettings, xDateEdits;

type
  Tgdc_dlgUser = class(Tgdc_dlgTRPC)
    btnGroup: TButton;
    actGroups: TAction;
    Button1: TButton;
    actCopySettings: TAction;
    lblInfo: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    lblExpDate: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    dbeName: TDBEdit;
    dbeFullName: TDBEdit;
    dbmDescription: TDBMemo;
    edPasswordConfirmation: TEdit;
    cbNeverExp: TDBCheckBox;
    cbCantChange: TDBCheckBox;
    cbMustChange: TDBCheckBox;
    cbDisabled: TDBCheckBox;
    gsiblcContact: TgsIBLookupComboBox;
    cbAllowAudit: TDBCheckBox;
    dbePassword: TDBEdit;
    dbePhone: TDBEdit;
    pgcErrors: TTabSheet;
    cbSaveErrorLog: TCheckBox;
    pnlErrLog: TPanel;
    Label5: TLabel;
    spErrorLines: TSpinEdit;
    cbLimitLines: TCheckBox;
    cbErrorLogFile: TComboBox;
    dbeStartWork: TxDateDBEdit;
    dbeEndWork: TxDateDBEdit;
    dbeExpDate: TxDateDBEdit;
    procedure mmcbNeverExpClick(Sender: TObject);
    procedure cbCantChangeClick(Sender: TObject);
    procedure actGroupsExecute(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
    procedure actCopySettingsUpdate(Sender: TObject);
    procedure actCopySettingsExecute(Sender: TObject);
    procedure cbSaveErrorLogClick(Sender: TObject);
    procedure cbLimitLinesClick(Sender: TObject);

  private
    FEnabledChildPnlErrLog: array of Boolean;
    FUserSettings: TSettings;

    procedure CheckLogFileName;
    procedure SetErrorsPage;
    procedure SaveErrorsPage;

  protected
    procedure Post; override;
    procedure DoDestroy; override;

  public
    function TestCorrect: Boolean; override;
    procedure SetupDialog; override;
    procedure SetupRecord; override;

    // в зависимости от состояния чек-бокса Пароль пользователя
    // никогда не устаревает будет включать или выключать контролы
    // для ввода даты истечения срока действия пароля
    procedure SyncControls; override;
  end;

var
  gdc_dlgUser: Tgdc_dlgUser;

implementation

{$R *.DFM}

uses
  gd_ClassList, gdcBaseInterface, IBSQL, Storages, gd_security,
  JclFileUtils, gd_i_ScriptFactory, Masks
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

procedure Tgdc_dlgUser.mmcbNeverExpClick(Sender: TObject);
begin
  SyncControls;
end;

// Установка групп в которые входит пользователь

procedure Tgdc_dlgUser.cbCantChangeClick(Sender: TObject);
begin
  SyncControls;
end;

procedure Tgdc_dlgUser.actGroupsExecute(Sender: TObject);
begin
  gdcObject.EditDialog('Tgdc_dlgAddUserToGroup');
end;

procedure Tgdc_dlgUser.actOkUpdate(Sender: TObject);
begin
  if (Trim(dbeName.Text) > '')
    and (edPasswordConfirmation.Text > '') then
  begin
    inherited;
  end else
    actOk.Enabled := False;
end;

function Tgdc_dlgUser.TestCorrect: Boolean;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  q: TIBSQL;
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_DLGUSER', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGUSER', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGUSER') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGUSER',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGUSER' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  Result := False;

  dbeName.Text := Trim(dbeName.Text);
  dbePassword.Text := Trim(dbePassword.Text);

  if dbePassword.Text <> edPasswordConfirmation.Text then
  begin
    MessageBox(Self.Handle, 'Неверно подтвержден пароль', 'Внимание', MB_OK or MB_ICONEXCLAMATION);
    dbePassword.SetFocus;
    exit;
  end;

  if gdcObject.FieldByName('ingroup').AsInteger = 0 then
  begin
    MessageBox(Self.Handle, 'Необходимо включить пользователя хотя бы в одну группу.', 'Внимание', MB_OK or MB_ICONEXCLAMATION);
    Result := gdcObject.EditDialog('Tgdc_dlgAddUserToGroup');
    exit;
  end;

  if gdcObject.FieldByName('contactkey').AsInteger > 0 then
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcBaseManager.ReadTransaction;
      q.SQL.Text :=
        'SELECT c.name as contactname, u.name as username ' +
        '  FROM gd_contact c JOIN gd_user u ' +
        '  ON u.contactkey = c.id WHERE u.id <> ' +
        gdcObject.FieldByName('id').AsString +
        ' AND u.contactkey = ' +
        gdcObject.FieldByName('contactkey').AsString;
      q.ExecQuery;
      if not q.EOF then
      begin
        if MessageBox(Handle,
          PChar('Контакт "' + q.Fields[0].AsString +
            '" уже выбран для учетной записи "' + q.Fields[1].AsString + '".'#13#10 +
            'Рекомендуется для каждой учетной записи использовать отдельную запись из таблицы контактов.'#13#10 +
            'Продолжить сохранение?'),
          'Внимание',
          MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDNO then
        begin
          exit;
        end;
      end;
    finally
      q.Free;
    end;
  end;

  Result := True;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGUSER', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGUSER', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgUser.SyncControls;
begin
  inherited;

  lblExpDate.Enabled := not cbNeverExp.Checked;
  dbeExpDate.Enabled := not cbNeverExp.Checked;

  if cbCantChange.Checked then
  begin
    cbMustChange.Checked := False;
    cbMustChange.Enabled := False;
  end else
  begin
    cbMustChange.Enabled := True;
  end;
end;

procedure Tgdc_dlgUser.actCopySettingsUpdate(Sender: TObject);
begin
  actCopySettings.Enabled := (gdcObject <> nil) and
    (gdcObject.State = dsEdit);
end;

procedure Tgdc_dlgUser.actCopySettingsExecute(Sender: TObject);
begin
  (gdcObject as TgdcUser).CopySettings(ibtrCommon);
end;

procedure Tgdc_dlgUser.SetErrorsPage;
const
  uDLFN = 'ErrScript.log';

begin
  if gdcObject.State <> dsInsert then
    UserStorage.ObjectKey := gdcObject.ID;

  if UserStorage.ObjectKey = IBLogin.UserKey then
  begin
    FUserSettings.Exceptions := PropertySettings.Exceptions;
  end else
    with FUserSettings.Exceptions do
    begin
      Stop :=
        UserStorage.ReadBoolean(sPropertyExceptionPath, cStop, False);
      StopOnInside :=
        UserStorage.ReadBoolean(sPropertyExceptionPath, cStopOnInside, False);
      SaveErrorLog :=
        UserStorage.ReadBoolean(sPropertyExceptionPath, cSaveErrorLog, True);
      FileName :=
        UserStorage.ReadString(sPropertyExceptionPath, cFileName, uDLFN);
      LimitLines :=
        UserStorage.ReadBoolean(sPropertyExceptionPath, cLimitLines, True);
      LinesCount :=
        UserStorage.ReadInteger(sPropertyExceptionPath, cLinesCount, 500);
    end;

  with FUserSettings.Exceptions do
  begin
    cbErrorLogFile.Text := FileName;
    cbLimitLines.Checked := LimitLines;
    spErrorLines.Value := LinesCount;
    cbSaveErrorLog.Checked := SaveErrorLog;
  end;

  spErrorLines.Enabled := cbLimitLines.Checked;
  BuildFileList(ExtractFileDir(Application.ExeName) + '\*.log',
    faAnyFile, cbErrorLogFile.Items);

  if UserStorage.ObjectKey <> IBLogin.UserKey then
    UserStorage.ObjectKey := IBLogin.UserKey;
end;

procedure Tgdc_dlgUser.SaveErrorsPage;

  function CheckChanges: Boolean;
  begin
    Result := False;
    with FUserSettings.Exceptions do
    begin
      if not Result then
        Result := SaveErrorLog <> cbSaveErrorLog.Checked;
      if not Result then
      begin
        Result := FileName <> cbErrorLogFile.Text;
        if Result then
          CheckLogFileName;
      end;
      if not Result then
        Result := LimitLines <> cbLimitLines.Checked;
      if not Result then
        Result := LinesCount <> spErrorLines.Value;
    end;
  end;
begin
  if CheckChanges then
  begin
    with FUserSettings.Exceptions do
    begin
      SaveErrorLog := cbSaveErrorLog.Checked;
      FileName := Trim(cbErrorLogFile.Text);
      if Copy(AnsiUpperCase(FileName), Length(FileName) - 4, 4) <> '.LOG' then
        FileName := FileName + '.log';
      LimitLines := cbLimitLines.Checked;
      LinesCount := spErrorLines.Value;
{      if Assigned(ScriptFactory) then
      begin
        ScriptFactory.ExceptionFlags := Exceptions;
      end;}

      UserStorage.ObjectKey := gdcObject.ID;
      UserStorage.WriteBoolean(sPropertyExceptionPath,
        cSaveErrorLog, SaveErrorLog);
      UserStorage.WriteString(sPropertyExceptionPath,
        cFileName, FileName);
      UserStorage.WriteBoolean(sPropertyExceptionPath,
        cLimitLines, LimitLines);
      UserStorage.WriteInteger(sPropertyExceptionPath,
        cLinesCount, LinesCount);
    end;
  end;
  if UserStorage.ObjectKey = IBLogin.UserKey then
  begin
    PropertySettings.Exceptions := FUserSettings.Exceptions;
    if Assigned(ScriptFactory) then
    begin
      ScriptFactory.ExceptionFlags := FUserSettings.Exceptions;
    end;
  end;
  UserStorage.ObjectKey := IBLogin.UserKey;
end;

procedure Tgdc_dlgUser.CheckLogFileName;
var
  LFileName: String;
  FullFileName: String;
begin
  LFileName := Trim(ExtractFileName(cbErrorLogFile.Text));
  if not MatchesMask(LFileName, '*.log') then
    LFileName := LFileName + '.log';
  FullFileName := ExtractFileDir(Application.ExeName) + '\' + LFileName;
  if FileExists(FullFileName) then
    cbErrorLogFile.Text := LFileName
  else
    begin
      if FileCreate(FullFileName) <> -1 then
      begin
        DeleteFile(FullFileName);
        cbErrorLogFile.Text := LFileName;
      end else
        begin
          MessageBox(0, PChar('Не возможно создать файл с именем ' +
            cbErrorLogFile.Text + #13#10 + 'Файлу дано стандартное имя ErrScript.log'),
            PChar('Ошибка сохранения свойств'), MB_OK or MB_ICONERROR or MB_TASKMODAL);
          cbErrorLogFile.Text := 'ErrScript.log';
        end;
    end;
end;

procedure Tgdc_dlgUser.cbSaveErrorLogClick(Sender: TObject);
  procedure ChangeEnabledChildPnlErrLog(const Enabled: Boolean);
  var
    i: Integer;
  begin
    pnlErrLog.Enabled := Enabled;
    for i := 0 to pnlErrLog.ControlCount - 1 do
    begin
      if Enabled then
        pnlErrLog.Controls[i].Enabled := FEnabledChildPnlErrLog[i]
      else
        begin
          FEnabledChildPnlErrLog[i] := pnlErrLog.Controls[i].Enabled;
          pnlErrLog.Controls[i].Enabled := Enabled;
        end;
    end;
  end;
begin
  inherited;
  ChangeEnabledChildPnlErrLog(cbSaveErrorLog.Checked);
end;

procedure Tgdc_dlgUser.cbLimitLinesClick(Sender: TObject);
begin
  inherited;
  spErrorLines.Enabled := cbLimitLines.Checked;
end;

procedure Tgdc_dlgUser.SetupDialog;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGUSER', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGUSER', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGUSER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGUSER',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGUSER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGUSER', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGUSER', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgUser.Post;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGUSER', 'POST', KEYPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGUSER', KEYPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGUSER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGUSER',
  {M}          'POST', KEYPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGUSER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  SaveErrorsPage;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGUSER', 'POST', KEYPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGUSER', 'POST', KEYPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgUser.SetupRecord;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGUSER', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGUSER', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGUSER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGUSER',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGUSER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  edPasswordConfirmation.Text := gdcObject.FieldByName('passw').AsString;
  dbeName.Enabled := gdcObject.State = dsInsert;

  SetLength(FEnabledChildPnlErrLog, pnlErrLog.ControlCount);
  SetErrorsPage;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGUSER', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGUSER', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgUser.DoDestroy;
begin
  FEnabledChildPnlErrLog := nil;
  inherited;
end;

initialization
  RegisterFrmClass(Tgdc_dlgUser);

finalization
  UnRegisterFrmClass(Tgdc_dlgUser);
end.
