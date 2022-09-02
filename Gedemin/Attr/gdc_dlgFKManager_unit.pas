// ShlTanya, 03.02.2019

unit gdc_dlgFKManager_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTRPC_unit, IBDatabase, Menus, Db, ActnList, at_Container, DBCtrls,
  StdCtrls, ComCtrls, Mask, ExtCtrls;

type
  Tgdc_dlgFKManager = class(Tgdc_dlgTRPC)
    Label1: TLabel;
    dbedConstraintName: TDBEdit;
    Label2: TLabel;
    dbedConstraintRel: TDBEdit;
    Label3: TLabel;
    dbedConstraintField: TDBEdit;
    Label4: TLabel;
    dbedRefRel: TDBEdit;
    Label5: TLabel;
    dbedRefField: TDBEdit;
    Label6: TLabel;
    dbedUpdateRule: TDBEdit;
    Label7: TLabel;
    dbedDeleteRule: TDBEdit;
    Label8: TLabel;
    dbedRefState: TDBEdit;
    Label9: TLabel;
    dbcbRefNextState: TDBComboBox;
    actShowValues: TAction;
    gbStat: TGroupBox;
    Label10: TLabel;
    DBText1: TDBText;
    Label12: TLabel;
    DBText3: TDBText;
    Label11: TLabel;
    DBText2: TDBText;
    btnUq: TButton;
    actShowConstraintRel: TAction;
    btnConstr: TButton;
    actShowRefRel: TAction;
    btnRef: TButton;
    btnActiveValues: TButton;
    actShowActiveValues: TAction;
    TabSheet1: TTabSheet;
    dbmmCheckIdList: TDBMemo;
    Panel1: TPanel;
    Button1: TButton;
    actFillCheckIdFromTable: TAction;
    procedure actShowValuesExecute(Sender: TObject);
    procedure actShowConstraintRelExecute(Sender: TObject);
    procedure actShowRefRelExecute(Sender: TObject);
    procedure actShowActiveValuesUpdate(Sender: TObject);
    procedure actShowActiveValuesExecute(Sender: TObject);
    procedure actFillCheckIdFromTableExecute(Sender: TObject);
    procedure actFillCheckIdFromTableUpdate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SetupRecord; override;
    function TestCorrect: Boolean; override;
  end;

var
  gdc_dlgFKManager: Tgdc_dlgFKManager;

implementation

{$R *.DFM}

uses
  gd_ClassList, flt_frmSQLEditorSyn_unit, gdcBaseInterface, IBSQL;

procedure Tgdc_dlgFKManager.actShowValuesExecute(Sender: TObject);
begin
  with TfrmSQLEditorSyn.Create(nil) do
  try
    ShowSQL(
      'SELECT ' + Trim(gdcObject.FieldByName('constraint_field').AsString) + ', COUNT(*)' +
      ' FROM ' + Trim(gdcObject.FieldByName('constraint_rel').AsString) +
      ' GROUP BY 1 ORDER BY 2 DESC');
  finally
    Free;
  end;
end;

procedure Tgdc_dlgFKManager.actShowConstraintRelExecute(Sender: TObject);
begin
  with TfrmSQLEditorSyn.Create(nil) do
  try
    ShowSQL('SELECT * FROM ' + Trim(gdcObject.FieldByName('constraint_rel').AsString));
  finally
    Free;
  end;
end;

procedure Tgdc_dlgFKManager.actShowRefRelExecute(Sender: TObject);
begin
  with TfrmSQLEditorSyn.Create(nil) do
  try
    ShowSQL('SELECT * FROM ' + Trim(gdcObject.FieldByName('ref_rel').AsString));
  finally
    Free;
  end;
end;

procedure Tgdc_dlgFKManager.actShowActiveValuesUpdate(Sender: TObject);
begin
  actShowActiveValues.Enabled := (gdcObject <> nil)
    and (gdcObject.FieldByName('ref_state').AsString <> 'ORIGINAL');
end;

procedure Tgdc_dlgFKManager.actShowActiveValuesExecute(Sender: TObject);
begin
  with TfrmSQLEditorSyn.Create(nil) do
  try
    ShowSQL('SELECT * FROM gd_ref_constraint_data WHERE constraintkey = ' + gdcObject.FieldByName('id').AsString);
  finally
    Free;
  end;
end;

procedure Tgdc_dlgFKManager.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGFKMANAGER', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGFKMANAGER', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGFKMANAGER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGFKMANAGER',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGFKMANAGER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  dbcbRefNextState.Items.Clear;
  dbcbRefNextState.Items.Add('ORIGINAL');

  if (Trim(gdcObject.FieldByName('ref_state').AsString) = 'ORIGINAL') then
  begin
    dbcbRefNextState.Items.Add('TRIGGER');
    dbcbRefNextState.Items.Add('CHECK');
  end
  else
    dbcbRefNextState.Items.Add(gdcObject.FieldByName('ref_state').AsString);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGFKMANAGER', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGFKMANAGER', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}

end;

function Tgdc_dlgFKManager.TestCorrect: Boolean;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  {Temp: String;
  Res: OleVariant;}
  idList, id, newIdList: string;
  p: integer;
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_DLGFKMANAGER', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGFKMANAGER', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGFKMANAGER') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGFKMANAGER',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGFKMANAGER' then
  {M}      begin
  {M}        Result := inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  Result := true;
  if Trim(gdcObject.FieldByName('ref_next_state').AsString) = 'CHECK' then
  begin
    idList := StringReplace(gdcObject.FieldByName('check_id').AsString, ' ', '', [rfReplaceAll]) + ',';
    while Length(idList) > 1 do
    begin
      p := pos(',', idList);
      id := copy(idList, 0, pos(',', idList) - 1);
      if GetTID(id,0) > 0 then
      begin
        if  length(newIdList) > 0 then
          newIdList := newIdList + ',';

        newIdList := newIdList + id;
      end;;
      idList := copy(idList, p + 1, Length(idList));
    end;

    gdcObject.FieldByName('check_id').AsString := newIdList;
   end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGFKMANAGER', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGFKMANAGER', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}

end;

procedure Tgdc_dlgFKManager.actFillCheckIdFromTableExecute(
  Sender: TObject);
var   ibsql: TIBSQL;
begin
  if Trim(gdcObject.FieldByName('ref_next_state').AsString) = 'CHECK' then
  begin
    ibsql := TIBSQL.Create(nil);
    try
      ibsql.Transaction := gdcBaseManager.ReadTRansaction;
      ibsql.SQL.Text := Format('SELECT LIST(DISTINCT %s , '','') as IDList FROM %s',
        [Trim(gdcObject.FieldByName('ref_field').AsString), Trim(gdcObject.FieldByName('ref_rel').AsString)]);
      ibsql.ExecQuery;

      if (not ibsql.EOF) then
      begin
        if Length(ibsql.FieldByName('IDList').asString) >  gdcObject.FieldByName('check_id').Size then
        begin
          MessageBox(Handle,
            'Длина списка идентификаторов для создания ограничения превышает допустимое значение! По данному полю нельзя создать ограничение CHECK.',
            'Внимание',
            MB_OK or MB_ICONHAND or MB_TASKMODAL);
          gdcObject.FieldByName('check_id').Clear;
          gdcObject.FieldByName('ref_next_state').AsString := 'ORIGINAL';
        end
        else
          gdcObject.FieldByName('check_id').AsString := ibsql.FieldByName('IDList').asString;
      end;
    finally
      ibsql.Free;
    end;
  end;
end;

procedure Tgdc_dlgFKManager.actFillCheckIdFromTableUpdate(Sender: TObject);
begin
  inherited;
  actFillCheckIdFromTable.Enabled := (Trim(gdcObject.FieldByName('ref_next_state').AsString) = 'CHECK') and
    (Trim(gdcObject.FieldByName('ref_state').AsString) = 'ORIGINAL');
end;

initialization
  RegisterFrmClass(Tgdc_dlgFKManager);

finalization
  UnRegisterFrmClass(Tgdc_dlgFKManager);

end.



