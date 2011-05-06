unit gdc_dlgTaxActual_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, ExtCtrls, Menus, Db, ActnList, StdCtrls, IBCustomDataSet,
  gdcBase, gdcGood, Mask, xDateEdits, gsIBLookupComboBox, dmDataBase_unit,
  XPBevel, Spin, gdcTaxFunction, IBQuery, DBCtrls, gdcCustomFunction,
  gdcFunction, gdcAutoTransaction, gd_i_ScriptFactory, wiz_Main_Unit,
  gd_security_operationconst, prm_ParamFunctions_unit, gd_security, IBSQL,
  rp_report_const, gdcConstants, gdcAcctTransaction;

type
  Tgdc_dlgTaxActual = class(Tgdc_dlgG)
    pnlMain: TPanel;
    ibcbTax: TgsIBLookupComboBox;
    lblTaxName: TLabel;
    lblActualDate: TLabel;
    xedTaxDate: TxDateDBEdit;
    XPBevel1: TXPBevel;
    lblReportDay: TLabel;
    speRepotDay: TSpinEdit;
    lblType: TLabel;
    dsType: TDataSource;
    dbcbType: TDBLookupComboBox;
    Label2: TLabel;
    dbeFumctionName: TDBEdit;
    btnConstructor: TButton;
    dsFunction: TDataSource;
    gdcFunction: TgdcFunction;
    actWizard: TAction;
    dsAutoTrRecord: TDataSource;
    gdcTrRecord: TgdcAutoTrRecord;

    procedure speRepotDayChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure actWizardExecute(Sender: TObject);
    procedure actWizardUpdate(Sender: TObject);
    procedure ibcbTaxChange(Sender: TObject);
  private
    FIBQuery: TIBQuery;
    FScriptChanged: Boolean;
  protected
    function TestCorrect: Boolean; override;
    procedure SetupRecord; override;
    procedure SetupDialog; override;
    procedure Post; override;
    procedure SetTransactionKey;
    procedure SetTrRecordName;
  public
    constructor Create(AnOwner: TComponent); override;
  end;

var
  gdc_dlgTaxActual: Tgdc_dlgTaxActual;

implementation

uses
  gd_ClassList, gdcBaseInterface{, wiz_FunctionBlock_unit};


{$R *.DFM}

procedure Tgdc_dlgTaxActual.speRepotDayChange(Sender: TObject);
begin
  inherited;
  if dsgdcBase.DataSet.FieldByName(fnReportDay).AsInteger <> speRepotDay.Value then
    dsgdcBase.DataSet.FieldByName(fnReportDay).AsInteger := speRepotDay.Value;
end;

procedure Tgdc_dlgTaxActual.FormShow(Sender: TObject);
begin
  inherited;
  try
    speRepotDay.Value :=
      dsgdcBase.DataSet.FieldByName(fnReportDay).AsInteger;
    btnConstructor.Enabled := not (sCopy in gdcObject.BaseState);
  except
  end;
end;

constructor Tgdc_dlgTaxActual.Create(AnOwner: TComponent);
begin
  inherited;
  FIBQuery := TIBQuery.Create(Self);
  FIBQuery.Transaction := gdcBaseManager.ReadTransaction;
  FIBQuery.SQL.Text :=
    'SELECT * FROM gd_taxtype';
  FIBQuery.Open;
  dsType.DataSet := FIBQuery;
end;

function Tgdc_dlgTaxActual.TestCorrect: Boolean;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
var
  SQL: TIBSQL;
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_DLGTAXACTUAL', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGTAXACTUAL', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGTAXACTUAL') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGTAXACTUAL',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGTAXACTUAL' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  gdcObject.FieldByName(fntaxname).AsString := ibcbTax.Text;

  if gdcObject.FieldByName(fnreportgroupkey).IsNull then
    gdcObject.FieldByName(fnreportgroupkey).AsInteger := 0;

  Result := inherited TestCorrect;

  if gdcObject.FieldByName(fnreportgroupkey).AsInteger = 0 then
    gdcObject.FieldByName(fnreportgroupkey).Clear;

  if Result then
  begin
    if gdcTrRecord.FieldByName(fnfunctionkey).AsInteger = 0 then
    begin
      Result := False;
      ShowMessage('Не задана функция расчета налога');
    end else
    begin
      SQL := TIBSQL.Create(nil);
      try
        SQL.Transaction := gdcBaseManager.ReadTransaction;
        SQL.SQL.Text :=  Format('SELECT %s FROM %s WHERE taxnamekey = %s AND actualdate = ''%s'' AND id <> %d ',
          [gdcObject.GetKeyField(gdcObject.SubType), gdcObject.GetListTable(gdcObject.SubType),
          gdcObject.FieldByName(fntaxnamekey).AsString,
          gdcObject.FieldByName(fnactualdate).AsString,
          gdcObject.FieldByName(fnid).AsInteger]);
        SQL.ExecQuery;
        Result := SQL.RecordCount = 0;
        if not Result then
        begin
          ShowMessage(Format(
            'Налог %s с актуальной датой %s уже сужествует.'#13#10 +
            'Пожадуйста введите другой налог или актуальную'#13#10 +
            'дату налога', [gdcObject.FieldByName('taxname').AsString,
            gdcObject.FieldByName(fnactualdate).AsString]));
        end;
      finally
        SQL.Free;
      end;
    end;
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGTAXACTUAL', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGTAXACTUAL', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgTaxActual.SetupDialog;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGTAXACTUAL', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGTAXACTUAL', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGTAXACTUAL') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGTAXACTUAL',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGTAXACTUAL' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if gdcObject <> nil then
  begin
    gdcFunction.Transaction := gdcObject.Transaction;
    gdcTrRecord.Transaction := gdcObject.Transaction;
    gdcTrRecord.MasterSource := nil;
    gdcTrRecord.MasterSource := dsgdcBase;
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGTAXACTUAL', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGTAXACTUAL', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgTaxActual.SetupRecord;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGTAXACTUAL', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGTAXACTUAL', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGTAXACTUAL') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGTAXACTUAL',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGTAXACTUAL' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FScriptChanged := False;
  if {(gdcObject.State = dsInsert) or}
    (gdcObject.FieldByName(fnTrRecordKey).AsInteger = 0) then
  begin
    gdcTrRecord.Insert;
    gdcTrRecord.FieldByName(fnid).AsInteger := gdcTrRecord.GetNextID;
    gdcObject.FieldByName(fntrrecordkey).AsInteger := gdcTrRecord.ID;
  end else
    gdcTrRecord.Edit;

  SetTransactionKey;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGTAXACTUAL', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGTAXACTUAL', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgTaxActual.Post;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGTAXACTUAL', 'POST', KEYPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGTAXACTUAL', KEYPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGTAXACTUAL') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGTAXACTUAL',
  {M}          'POST', KEYPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGTAXACTUAL' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  SetTrRecordName;

  if gdcFunction.State in [dsEdit, dsInsert] then
    gdcFunction.Post;

  gdcTrRecord.Post;

  inherited;

  if FScriptChanged then
  begin
    ScriptFactory.Reset;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGTAXACTUAL', 'POST', KEYPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGTAXACTUAL', 'POST', KEYPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgTaxActual.actWizardExecute(Sender: TObject);
var
  F: TdlgFunctionWisard;
  D: TDataSet;
  Str, PStr: TStream;
  Params: TgsParamList;
  FunctionCreater: TNewTaxFunctionCreater;
  DidActivated: Boolean;
begin
  F := TdlgFunctionWisard.Create(Self);
  try
    D := gdcTrRecord;
    if D <> nil then
    begin
      DidActivated := not (gdcFunction.State in [dsEdit, dsInsert]);
      if DidActivated then
      begin
        if D.FieldByName(fnfunctionkey).AsInteger = 0 then
        begin
          gdcFunction.Insert;
          gdcFunction.FieldByName(fnmodulecode).AsInteger := OBJ_APPLICATION;
          gdcFunction.FieldByName(fnmodule).AsString := scrEntryModuleName;
          gdcFunction.FieldByName(fnname).AsString := Format('AutoEntryScript%d_%d',
            [gdcFunction.FieldByName(fnid).AsInteger, IbLogin.DBID]);
          gdcFunction.FieldByName(fnLANGUAGE).AsString := DefaultLanguage;
        end else
          gdcFunction.Edit;
      end;

      Str := D.CreateBlobStream(D.FieldByName(fnFunctionTemplate), bmReadWrite);
      try
        FunctionCreater := TNewTaxFunctionCreater.Create;
        try
          FunctionCreater.FunctionRUID := RUIDToStr(gdcFunction.GetRUID);
          FunctionCreater.Stream := Str;
          FunctionCreater.FunctionName := gdcFunction.FieldByName(fnName).AsString;
          FunctionCreater.TaxActualRuid := gdcBaseManager.GetRUIDStringByID(gdcObject.FieldByName(fnid).AsInteger);
          FunctionCreater.TaxNameRuid := gdcBaseManager.GetRUIDStringByID(gdcObject.FieldByName(fnTaxNameKey).AsInteger);
          FunctionCreater.TransactionRUID := gdcBaseManager.GetRUIDStringByID(D.FieldByName(fnTransactionKey).AsInteger);
          FunctionCreater.TrRecordRUID := gdcBaseManager.GetRUIDStringByID(D.FieldByName(fnID).AsInteger);
          FunctionCreater.CardOfAccountRUID := gdcBaseManager.GetRuidStringById(D.FieldByName(fnAccountKey).AsInteger);

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
          gdcFunction.FieldByName(fnscript).AsString := F.Script;
          gdcFunction.FieldByName(fnname).AsString := F.MainFunctionName;
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
          D.FieldByName(fnfunctionkey).AsInteger :=
            gdcFunction.FieldByName(fnid).AsInteger;
        end else
        begin
          if DidActivated then
            gdcFunction.Cancel;
        end;    
      finally
        Str.Free;
      end;
    end;
  finally
    F.Free;
  end;
end;

procedure Tgdc_dlgTaxActual.actWizardUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled :=
    (gdcTrRecord.FieldByName(fnTransactionKey).AsInteger > 0) and
    (gdcObject.FieldByName(fnTaxNameKey).AsInteger > 0) and
    (gdcTrRecord.FieldByName(fnAccountKey).AsInteger > 0);
end;

procedure Tgdc_dlgTaxActual.ibcbTaxChange(Sender: TObject);
begin
  if (ibcbTax.CurrentKey = '') and gdcTrRecord.Active then
  begin
    gdcTrRecord.FieldByName(fntransactionkey).Clear
  end else
    SetTransactionKey;  
end;

procedure Tgdc_dlgTaxActual.SetTransactionKey;
var
  SQL: TIBSQL;
begin
  if (ibcbTax.CurrentKey > '') and (gdcTrRecord.State in [dsEdit, dsInsert]) then
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcBaseManager.ReadTransaction;
      SQL.SQL.Text := 'SELECT * FROM gd_taxname WHERE id = :id';
      SQL.ParamByName(fnid).AsInteger := ibcbTax.CurrentKeyInt;
      SQL.ExecQuery;
      gdcTrRecord.FieldByName(fntransactionkey).AsVariant := SQL.FieldByName(fnTransactionKey).Value;
      gdcTrRecord.FieldByName(fnAccountKey).AsVariant := SQL.FieldByName(fnAccountKey).Value;
    finally
       SQL.Free;
    end;
  end;
end;

procedure Tgdc_dlgTaxActual.SetTrRecordName;
var
  SQL: TIBSQL;
begin
  if (ibcbTax.CurrentKey > '') and (gdcTrRecord.State in [dsEdit, dsInsert]) then
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcBaseManager.ReadTransaction;
      SQL.SQL.Text := 'SELECT * FROM gd_taxname WHERE id = :id';
      SQL.ParamByName(fnId).AsInteger := ibcbTax.CurrentKeyInt;
      SQL.ExecQuery;
      gdcTrRecord.FieldByName(fnDescription).AsVariant :=
        SQL.FieldByName(fnName).Value +  ' (''' +
        gdcObject.FieldByName(fnactualdate).AsString + ''')';;
    finally
       SQL.Free;
    end;
  end;
end;

initialization
  RegisterFrmClass(Tgdc_dlgTaxActual);

finalization
  UnRegisterFrmClass(Tgdc_dlgTaxActual);

end.
