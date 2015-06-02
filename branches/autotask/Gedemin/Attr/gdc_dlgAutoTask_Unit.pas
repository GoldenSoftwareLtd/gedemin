unit gdc_dlgAutoTask_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTR_unit, IBDatabase, Menus, Db, ActnList, StdCtrls, Mask, DBCtrls,
  gsIBLookupComboBox, ExtCtrls, xDateEdits, ComCtrls;

type
  Tgdc_dlgAutoTask = class(Tgdc_dlgTR)
    gbTimeTables: TGroupBox;
    rbExactDate: TRadioButton;
    xdbeExactDate: TxDateDBEdit;
    rbMonthly: TRadioButton;
    rbWeekly: TRadioButton;
    dbcbWeekly: TDBComboBox;
    odCmdLine: TOpenDialog;
    dbcbDisabled: TDBCheckBox;
    lbPriority: TLabel;
    rbDaily: TRadioButton;
    Label2: TLabel;
    lbStartTime: TLabel;
    xdbeStartTime: TxDateDBEdit;
    lbEndTime: TLabel;
    xdbeEndTime: TxDateDBEdit;
    DBComboBox1: TDBComboBox;
    Label3: TLabel;
    Label4: TLabel;
    dbcbPriority: TDBComboBox;
    lbName: TLabel;
    dbedName: TDBEdit;
    lbDescription: TLabel;
    dbmDescription: TDBMemo;
    pcTask: TPageControl;
    tsFunction: TTabSheet;
    iblkupFunction: TgsIBLookupComboBox;
    tsCmd: TTabSheet;
    Label1: TLabel;
    dbeCmdLine: TDBEdit;
    btnCmdLine: TButton;
    lbUser: TLabel;
    iblkupUser: TgsIBLookupComboBox;
    procedure btnCmdLineClick(Sender: TObject);

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

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGAUTOTASK', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGAUTOTASK', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgAutoTask.btnCmdLineClick(Sender: TObject);
begin
  if odCmdLine.Execute then
    dbeCmdLine.Text := odCmdLine.FileName;
end;

initialization
  RegisterFrmClass(Tgdc_dlgAutoTask);

finalization
  UnRegisterFrmClass(Tgdc_dlgAutoTask);

end.
