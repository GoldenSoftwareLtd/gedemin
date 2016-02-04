unit gdc_dlgAcctTrEntry_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, Db, ActnList, StdCtrls, IBCustomDataSet, gdcBase,
  gdcAcctTransaction, Grids, DBGrids, gsDBGrid, gsIBGrid, Mask, DBCtrls,
  ExtCtrls, TB2Item, TB2Dock, TB2Toolbar, gsIBCtrlGrid, gdc_dlgTR_unit,
  IBDatabase, Menus, at_Classes, gsIBLookupComboBox, gdcCustomFunction,
  gdcFunction, AcctStrings, gd_i_ScriptFactory, rp_report_const, gdcConstants,
  prm_ParamFunctions_unit, gdcBaseInterface, gdcClasses_interface;

type
  Tgdc_dlgAcctTrEntry = class(Tgdc_dlgTR)
    actDetailNew: TAction;
    actDetailEdit: TAction;
    actDetailDuplicate: TAction;
    actDetailCut: TAction;
    actDetailCopy: TAction;
    actDetailPaste: TAction;
    actDetailMacro: TAction;
    actDetailDelete: TAction;
    actWizard: TAction;
    Bevel1: TBevel;
    dsFunction: TDataSource;
    gdcFunction: TgdcFunction;
    Panel2: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    lblRecordFunction: TLabel;
    Label3: TLabel;
    dbedDescription: TDBEdit;
    iblcDocumentType: TgsIBLookupComboBox;
    BtnFuncWizard: TButton;
    dbcbIsSaveNullEntry: TDBCheckBox;
    iblcAccountChart: TgsIBLookupComboBox;
    dbeFumctionName: TDBEdit;
    lDocType: TLabel;
    cbDocumentPart: TDBComboBox;
    iblcTransaction: TgsIBLookupComboBox;
    Label4: TLabel;
    dbcbIsDiasabled: TDBCheckBox;
    procedure actWizardExecute(Sender: TObject);
    procedure actWizardUpdate(Sender: TObject);
  private
    FScriptChanged: Boolean;
  protected
    procedure SetupRecord; override;
    procedure SetupDialog; override;
    procedure Post; override;
    procedure Cancel; override;
  public
    function TestCorrect: Boolean; override;
  end;

  Egdc_dlgAcctTrEntry = class(Exception);

var
  gdc_dlgAcctTrEntry: Tgdc_dlgAcctTrEntry;

implementation

{$R *.DFM}

uses
  dmImages_unit, Storages, gd_ClassList, gd_security, IBSQL,
  gdcAcctEntryRegister, gd_security_operationconst,
  wiz_Main_Unit;

function Tgdc_dlgAcctTrEntry.TestCorrect: Boolean;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_DLGACCTTRENTRY', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGACCTTRENTRY', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGACCTTRENTRY') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGACCTTRENTRY',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGACCTTRENTRY' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  if Trim(gdcObject.FieldByName(fnDescription).AsString) = '' then
  begin
    ShowMessage(MSG_ENTERDESCRIPTION);
    Result := False;
  end else
  if gdcObject.FieldByName(fnDocumenttypekey).AsInteger = 0 then
  begin
    ShowMessage(MSG_ENTERDOCUMENTTYPE);
    Result := False;
  end else
  if gdcObject.FieldByName(fnFunctionKey).AsInteger = 0 then
  begin
    ShowMessage(MSG_ENTERFUNCTIONKEY);
    Result := False;
  end;

  Result := Result and inherited TestCorrect;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGACCTTRENTRY', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGACCTTRENTRY', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgAcctTrEntry.SetupDialog;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGACCTTRENTRY', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGACCTTRENTRY', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGACCTTRENTRY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGACCTTRENTRY',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGACCTTRENTRY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  gdcFunction.Transaction := gdcObject.Transaction;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGACCTTRENTRY', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGACCTTRENTRY', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgAcctTrEntry.SetupRecord;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGACCTTRENTRY', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGACCTTRENTRY', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGACCTTRENTRY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGACCTTRENTRY',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGACCTTRENTRY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  if (gdcObject.State = dsInsert) then
  begin
    if (gdcObject.FieldByName(fnFunctionKey).AsInteger = 0) then
      gdcObject.FieldByName(fnFunctionKey).Clear;
    gdcObject.FieldByName(fnAccountKey).AsInteger := IbLogin.ActiveAccount;  
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGACCTTRENTRY', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGACCTTRENTRY', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgAcctTrEntry.Cancel;
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}var
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGACCTTRENTRY', 'CANCEL', KEYCANCEL)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGACCTTRENTRY', KEYCANCEL);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCANCEL]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGACCTTRENTRY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGACCTTRENTRY',
  {M}          'CANCEL', KEYCANCEL, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGACCTTRENTRY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if gdcFunction.State in [dsEdit, dsInsert] then
    gdcFunction.Cancel;

  inherited;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGACCTTRENTRY', 'CANCEL', KEYCANCEL)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGACCTTRENTRY', 'CANCEL', KEYCANCEL);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgAcctTrEntry.Post;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGACCTTRENTRY', 'POST', KEYPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGACCTTRENTRY', KEYPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGACCTTRENTRY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGACCTTRENTRY',
  {M}          'POST', KEYPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGACCTTRENTRY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if gdcFunction.State in [dsEdit, dsInsert] then
    gdcFunction.Post;

  inherited;

  if FScriptChanged then
  begin
    ScriptFactory.ReloadFunction(gdcObject.FieldByName(fnFunctionKey).AsInteger);
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGACCTTRENTRY', 'POST', KEYPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGACCTTRENTRY', 'POST', KEYPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgAcctTrEntry.actWizardExecute(Sender: TObject);
var
  F: TdlgFunctionWisard;
  D: TDataSet;
  Str, PStr: TStream;
  Params: TgsParamList;
  FunctionCreater: TNewTrEntryFunctionCreater;
  DS: TDataSetState;
const
  cwHeader = 'шапка';
  cwLine   = 'позиция';

begin
  F := TdlgFunctionWisard.Create(Application);
  try
    D := dsgdcBase.DataSet;
    if D <> nil then
    begin
      DS := gdcFunction.State;
      if not (gdcFunction.State in [dsEdit, dsInsert]) then
      begin
        if D.FieldByName(fnFunctionKey).AsInteger = 0 then
        begin
          if not D.FieldByName(fnFunctionKey).IsNull then
            D.FieldByName(fnFunctionKey).Clear;
            
          gdcFunction.Insert;
          gdcFunction.FieldByName(fnModuleCode).AsInteger := OBJ_APPLICATION;
          gdcFunction.FieldByName(fnModule).AsString := scrEntryModuleName;
          gdcFunction.FieldByName(fnName).AsString := Format('TrEntryScript%d_%d',
            [gdcFunction.FieldByName(fnId).AsInteger, IbLogin.DBID]);
          gdcFunction.FieldByName(fnLanguage).AsString := DefaultLanguage;
        end else
          gdcFunction.Edit;
      end;

      Str := D.CreateBlobStream(D.FieldByName(fnFunctionTemplate), bmReadWrite);
      try
        FunctionCreater := TNewTrEntryFunctionCreater.Create;
        try
          FunctionCreater.FunctionRUID := RUIDToStr(gdcFunction.GetRUID);
          FunctionCreater.Stream := Str;
          FunctionCreater.FunctionName := gdcFunction.FieldByName(fnName).AsString;
          FunctionCreater.TransactionRUID := gdcBaseManager.GetRUIDStringByID(D.FieldByName(fnTransactionkey).AsInteger);
          FunctionCreater.TrRecordRUID := gdcBaseManager.GetRUIDStringByID(D.FieldByName(fnId).AsInteger);
          FunctionCreater.CardOfAccountRUID := gdcBaseManager.GetRuidStringById(gdcObject.FieldByName(fnAccountKey).AsInteger);
          FunctionCreater.DocumentRUID := gdcBaseManager.GetRUIDStringByID(gdcObject.FieldByName(fnDocumentTypeKey).AsInteger);
          FunctionCreater.SaveEmpty := gdcObject.FieldByName(fnIsSaveNull).AsInteger = 1;
          if gdcObject.FieldByName(fnDocumentPart).AsString = cwHeader then
            FunctionCreater.DocumentPart := dcpHeader
          else
            FunctionCreater.DocumentPart := dcpLine;

          F.CreateNewFunction(FunctionCreater);
        finally
          FunctionCreater.Free;
        end;
        FScriptChanged := F.ShowModal = mrOk;
        if FScriptChanged then
        begin
          Str.size := 0;
          Str.Position := 0;
          F.SaveToStream(Str);
          gdcFunction.FieldByName(fnScript).AsString := F.Script;
          gdcFunction.FieldByName(fnName).AsString := F.MainFunctionName;
          Params := TgsParamList.Create;
          try
            Params.Assign(F.Params);
            PStr := gdcFunction.CreateBlobStream(gdcFunction.FieldByName(fnEnteredParams), DB.bmWrite);
            try
              Pstr.Size := 0;
              PStr.Position := 0;
              Params.SaveToStream(PStr);
            finally
              PStr.Free;
            end;
          finally
            Params.Free;
          end;
          D.FieldByName(fnFunctionKey).AsInteger :=
            gdcFunction.FieldByName(fnID).AsInteger;
        end else
        begin
          if not (DS in [dsEdit, dsInsert]) then
          begin
            gdcFunction.Cancel;
          end;
        end;
      finally
        Str.Free;
      end;
    end;
  finally
    F.Free;
  end;
end;

procedure Tgdc_dlgAcctTrEntry.actWizardUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (gdcObject <> nil) and
    (gdcObject.FieldByName(fndocumenttypekey).AsInteger > 0) and
    (gdcObject.FieldByName(fndocumentpart).AsString > '') and
    (gdcObject.FieldByName(fnAccountKey).AsInteger > 0) and
    IBLogin.IsIBUserAdmin
end;

initialization
  RegisterFrmClass(Tgdc_dlgAcctTrEntry);

finalization
  UnRegisterFrmClass(Tgdc_dlgAcctTrEntry);

end.

