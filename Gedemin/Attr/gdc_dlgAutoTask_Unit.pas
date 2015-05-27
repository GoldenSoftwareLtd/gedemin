unit gdc_dlgAutoTask_Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTR_unit, IBDatabase, Menus, Db, ActnList, StdCtrls, Mask, DBCtrls,
  gsIBLookupComboBox, ExtCtrls, xDateEdits;

type
  Tgdc_dlgAutoTask = class(Tgdc_dlgTR)
    dbedName: TDBEdit;
    lbName: TLabel;
    lbDescription: TLabel;
    dbmDescription: TDBMemo;
    lbUser: TLabel;
    iblkupUser: TgsIBLookupComboBox;
    gbTimeInterval: TGroupBox;
    lbStartTime: TLabel;
    xdbeStartTime: TxDateDBEdit;
    lbEndTime: TLabel;
    xdbeEndTime: TxDateDBEdit;
    gbTimeTables: TGroupBox;
    rbExactDate: TRadioButton;
    xdbeExactDate: TxDateDBEdit;
    rbMonthly: TRadioButton;
    dbcbMonthly: TDBComboBox;
    rbWeekly: TRadioButton;
    dbcbWeekly: TDBComboBox;
    lbMonthly: TLabel;
    lbWeekly: TLabel;
    gbType: TGroupBox;
    rbFunction: TRadioButton;
    iblkupFunction: TgsIBLookupComboBox;
    rbCmdLine: TRadioButton;
    dbeCmdLine: TDBEdit;
    rbBackupFile: TRadioButton;
    dbeBackupFile: TDBEdit;
    btnCmdLine: TButton;
    btnBackupFile: TButton;
    odCmdLine: TOpenDialog;
    dbcbDisabled: TDBCheckBox;
    rbAutoTr: TRadioButton;
    rbReport: TRadioButton;
    iblkupAutoTr: TgsIBLookupComboBox;
    iblkupReport: TgsIBLookupComboBox;
    procedure rbFunctionClick(Sender: TObject);
    procedure rbCmdLineClick(Sender: TObject);
    procedure rbBackupFileClick(Sender: TObject);
    procedure rbExactDateClick(Sender: TObject);
    procedure rbMonthlyClick(Sender: TObject);
    procedure rbWeeklyClick(Sender: TObject);
    procedure btnCmdLineClick(Sender: TObject);
    procedure btnBackupFileClick(Sender: TObject);
  private
    { Private declarations }
  protected
    procedure UpdateTypeTabs;
    procedure UpdateSettingsTabs;

  public
    procedure SetupRecord; override;
    procedure BeforePost; override;
    function TestCorrect: Boolean; override;
  end;

var
  gdc_dlgAutoTask: Tgdc_dlgAutoTask;

implementation

{$R *.DFM}

uses
  gd_ClassList, gd_security;

procedure Tgdc_dlgAutoTask.UpdateTypeTabs;
begin
  if rbFunction.Checked then
  begin
    rbCmdLine.Checked := False;
    rbBackupFile.Checked := False;
  end
  else if rbCmdLine.Checked then
  begin
    rbFunction.Checked := False;
    rbBackupFile.Checked := False;
  end
  else if rbBackupFile.Checked then
  begin
    rbFunction.Checked := False;
    rbCmdLine.Checked := False;
  end;

  iblkupFunction.Enabled := rbFunction.Checked;
  dbeCmdLine.Enabled := rbCmdLine.Checked;
  dbeBackupFile.Enabled := rbBackupFile.Checked;

  btnCmdLine.Enabled := rbCmdLine.Checked;
  btnBackupFile.Enabled := rbBackupFile.Checked;
end;

procedure Tgdc_dlgAutoTask.UpdateSettingsTabs;
begin
  if rbExactDate.Checked then
  begin
    rbMonthly.Checked := False;
    rbWeekly.Checked := False;
  end
  else if rbMonthly.Checked then
  begin
    rbExactDate.Checked := False;
    rbWeekly.Checked := False;
  end
  else if rbWeekly.Checked then
  begin
    rbExactDate.Checked := False;
    rbMonthly.Checked := False;
  end;

  xdbeExactDate.Enabled := rbExactDate.Checked;
  dbcbMonthly.Enabled := rbMonthly.Checked;
  dbcbWeekly.Enabled := rbWeekly.Checked;

  gbTimeInterval.Visible := rbMonthly.Checked or rbWeekly.Checked;
end;

procedure Tgdc_dlgAutoTask.SetupRecord;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGAUTOTASK', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGAUTOTASK', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGAUTOTASK') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGAUTOTASK',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGAUTOTASK' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if not gdcObject.FieldByName('functionkey').IsNull then
    rbFunction.Checked := True
  else if not gdcObject.FieldByName('cmdline').IsNull then
    rbCmdLine.Checked := True
  else if not gdcObject.FieldByName('backupfile').IsNull then
    rbBackupFile.Checked := True;

  iblkupFunction.Enabled := rbFunction.Checked;
  dbeCmdLine.Enabled := rbCmdLine.Checked;
  dbeBackupFile.Enabled := rbBackupFile.Checked;

  btnCmdLine.Enabled := rbCmdLine.Checked;
  btnBackupFile.Enabled := rbBackupFile.Checked;


  if not gdcObject.FieldByName('exactdate').IsNull  then
    rbExactDate.Checked := True
  else if not gdcObject.FieldByName('monthly').IsNull then
    rbMonthly.Checked := True
  else if not gdcObject.FieldByName('weekly').IsNull then
    rbWeekly.Checked := True;

  xdbeExactDate.Enabled := rbExactDate.Checked;
  dbcbMonthly.Enabled := rbMonthly.Checked;
  dbcbWeekly.Enabled := rbWeekly.Checked;
  gbTimeInterval.Visible := rbMonthly.Checked or rbWeekly.Checked;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGEXPLORER', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGEXPLORER', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgAutoTask.BeforePost;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGAUTOTASK', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGAUTOTASK', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGAUTOTASK') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGAUTOTASK',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGAUTOTASK' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if rbFunction.Checked then
  begin
    gdcObject.FieldByName('cmdline').Clear;
    gdcObject.FieldByName('backupfile').Clear;
  end
  else if rbCmdLine.Checked then
  begin
    gdcObject.FieldByName('functionkey').Clear;
    gdcObject.FieldByName('backupfile').Clear;
  end
  else if rbBackupFile.Checked then
  begin
    gdcObject.FieldByName('functionkey').Clear;
    gdcObject.FieldByName('cmdline').Clear;
  end;

  if rbExactDate.Checked then
  begin
    gdcObject.FieldByName('monthly').Clear;
    gdcObject.FieldByName('weekly').Clear;
    gdcObject.FieldByName('starttime').Clear;
    gdcObject.FieldByName('endtime').Clear;
  end
  else if rbMonthly.Checked then
  begin
    gdcObject.FieldByName('exactdate').Clear;
    gdcObject.FieldByName('weekly').Clear;
  end
  else if rbWeekly.Checked then
  begin
    gdcObject.FieldByName('exactdate').Clear;
    gdcObject.FieldByName('monthly').Clear;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGAUTOTASK', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGAUTOTASK', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

function Tgdc_dlgAutoTask.TestCorrect: Boolean;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_DLGAUTOTASK', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGAUTOTASK', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGAUTOTASK') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGAUTOTASK',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGAUTOTASK' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  Result := inherited TestCorrect;

  if not Result then
    exit;

  if rbFunction.Checked then
  begin
    if iblkupFunction.CurrentKey = '' then
    begin
      MessageBox(Handle,
        PChar('Не задана скрипт-функция.'),
        'Внимание',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
      Result := False;
      iblkupFunction.SetFocus;
      exit;
    end
  end
  else if rbCmdLine.Checked then
  begin
    if dbeCmdLine.Text = '' then
    begin
      MessageBox(Handle,
        PChar('Не задан исполняемый файл.'),
        'Внимание',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
      Result := False;
      dbeCmdLine.SetFocus;
      exit;
    end;
  end
  else if rbBackupFile.Checked then
  begin
    if dbeBackupFile.Text = '' then
    begin
      MessageBox(Handle,
        PChar('Не задан архив.'),
        'Внимание',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
      Result := False;
      rbBackupFile.SetFocus;
      exit;
    end;
  end
  else
  begin
    MessageBox(Handle,
      PChar('Не выбран тип задачи.'),
      'Внимание',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
    Result := False;
    gbType.SetFocus;
    exit;
  end;

  if rbExactDate.Checked then
  begin
    if gdcObject.FieldByname('exactdate').IsNull then
    begin
      MessageBox(Handle,
        PChar('Не заполнены дата и время запуска.'),
        'Внимание',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
      Result := False;
      xdbeExactDate.SetFocus;
      exit;
    end;
  end
  else if rbMonthly.Checked then
  begin
    if gdcObject.FieldByname('monthly').IsNull then
    begin
      MessageBox(Handle,
        PChar('Не заполнен день месяца.'),
        'Внимание',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
      Result := False;
      rbMonthly.SetFocus;
      exit;
    end;
  end
  else if rbWeekly.Checked then
  begin
    if gdcObject.FieldByname('weekly').IsNull then
    begin
      MessageBox(Handle,
        PChar('Не заполнен день недели.'),
        'Внимание',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
      Result := False;
      rbWeekly.SetFocus;
      exit;
    end;
  end
  else
  begin
    MessageBox(Handle,
      PChar('Не выбрано расписание.'),
      'Внимание',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
    Result := False;
    gbTimeTables.SetFocus;
    exit;
  end;

  if rbMonthly.Checked or rbWeekly.Checked then
  begin
    if gdcObject.FieldByname('starttime').IsNull then
    begin
      MessageBox(Handle,
        PChar('Не заполнено начало временного интервала.'),
        'Внимание',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
        Result := False;
      xdbeStartTime.SetFocus;
      exit;
    end;
    
    if gdcObject.FieldByname('endtime').IsNull then
    begin
      MessageBox(Handle,
        PChar('Не заполнен конец временного интервала.'),
        'Внимание',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
        Result := False;
      xdbeEndTime.SetFocus;
      exit;
    end;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGAUTOTASK', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGAUTOTASK', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgAutoTask.rbFunctionClick(Sender: TObject);
begin
  UpdateTypeTabs;
end;

procedure Tgdc_dlgAutoTask.rbCmdLineClick(Sender: TObject);
begin
  UpdateTypeTabs;
end;

procedure Tgdc_dlgAutoTask.rbBackupFileClick(Sender: TObject);
begin
  UpdateTypeTabs;
end;

procedure Tgdc_dlgAutoTask.rbExactDateClick(Sender: TObject);
begin
  UpdateSettingsTabs;
end;

procedure Tgdc_dlgAutoTask.rbMonthlyClick(Sender: TObject);
begin
  UpdateSettingsTabs;
end;

procedure Tgdc_dlgAutoTask.rbWeeklyClick(Sender: TObject);
begin
  UpdateSettingsTabs;
end;

procedure Tgdc_dlgAutoTask.btnCmdLineClick(Sender: TObject);
begin
  if odCmdLine.Execute then
    dbeCmdLine.Text := odCmdLine.FileName;
end;

procedure Tgdc_dlgAutoTask.btnBackupFileClick(Sender: TObject);
begin
  //
end;

initialization
  RegisterFrmClass(Tgdc_dlgAutoTask);

finalization
  UnRegisterFrmClass(Tgdc_dlgAutoTask);

end.
