
unit gdcLedger;

interface

uses
  Classes, gdcBase, gdcBaseInterface, gd_createable_form, Forms, gdv_AcctConfig_unit;

type
  TgdcAcctBaseConfig = class(TgdcBase)
  protected
    procedure DeleteSF;
    procedure CreateSF;
    procedure CreateCommand(SFRUID: TRUID);
    procedure DeleteCommand(SFRUID: TRUID);
    procedure HideCommand;
    procedure DoAfterCustomProcess(Buff: Pointer; Process: TgsCustomProcess); override;

    function GetGDVViewForm: string; virtual;
  public
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
    class function IsAbstractClass: Boolean; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
  end;

  TgdcAcctLedgerConfig = class(TgdcAcctBaseConfig)
  protected
    procedure GetWhereClauseConditions(S: TStrings); override;
    function GetGDVViewForm: string; override;
  public
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcAcctAccConfig = class(TgdcAcctBaseConfig)
  protected
    procedure GetWhereClauseConditions(S: TStrings); override;
    function GetGDVViewForm: string; override;
  public
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcAcctCicrilationListConfig = class(TgdcAcctBaseConfig)
  protected
    procedure GetWhereClauseConditions(S: TStrings); override;
    function GetGDVViewForm: string; override;
  public
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcAcctGeneralLedgerConfig = class(TgdcAcctBaseConfig)
  protected
    procedure GetWhereClauseConditions(S: TStrings); override;
    function GetGDVViewForm: string; override;
  public
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcAcctAccReviewConfig = class(TgdcAcctBaseConfig)
  protected
    procedure GetWhereClauseConditions(S: TStrings); override;
    function GetGDVViewForm: string; override;
  public
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
  end;

procedure Register;

implementation

uses
  IB, IBErrorCodes, SysUtils, IBSQL, IBHeader, gd_ClassList,
  prm_ParamFunctions_unit, IBDatabase, at_classes, gd_security, Windows, DB,
  AcctStrings, AcctUtils, gdcConstants, gd_common_functions, gd_i_ScriptFactory,
  Clipbrd, gdcFunction, gdcExplorer, rp_report_const, gd_security_operationconst;
const
  cFunctionName = 'AcctReportScriptFunction%s';

procedure Register;
begin
  RegisterComponents('gdc', [TgdcAcctAccConfig, TgdcAcctLedgerConfig,
    TgdcAcctBaseConfig, TgdcAcctCicrilationListConfig,
    TgdcAcctGeneralLedgerConfig, TgdcAcctAccReviewConfig ]);
end;
{ TgdcAcctBaseConfig }

procedure TgdcAcctBaseConfig.CreateCommand(SFRUID: TRUID);
var
  SQL: TIBSQL;
  gdcExplorer: TgdcExplorer;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := Transaction;
    SQL.SQL.Text := 'SELECT id, disabled FROM gd_command WHERE cmd = :C';
    SQL.ParamByName('C').AsString := RUIDToStr(SFRUID);
    SQL.ExecQuery;

    gdcExplorer := TgdcExplorer.Create(nil);
    try
      gdcExplorer.Transaction := Transaction;
      gdcExplorer.ReadTransaction := ReadTransaction;
      gdcExplorer.SubSet := 'ByID';
      gdcExplorer.Id := SQL.FieldByName('id').AsInteger;
      gdcExplorer.Open;
      gdcExplorer.Edit;
      try
        if (not SQL.FieldByName('id').IsNull) and (SQL.FieldByName('disabled').AsInteger = 1) then
          gdcExplorer.FieldByName('disabled').Clear;
        if FieldByName('folder').IsNull then
          gdcExplorer.FieldByName('parent').Clear
        else
          gdcExplorer.FieldByName('parent').AsInteger := FieldByName('folder').AsInteger;
        gdcExplorer.FieldByName('name').AsString := FieldByName('name').AsString;
        gdcExplorer.FieldByName('cmd').AsString := RUIDToStr(SFRUID);
        gdcExplorer.FieldByName('cmdtype').AsInteger := cst_expl_cmdtype_function;
        gdcExplorer.FieldByName('imgindex').AsInteger := FieldByName('imageindex').AsInteger;
        gdcExplorer.Post;
      except
        gdcExplorer.Cancel;
        raise;
      end;
    finally
      gdcExplorer.Free;
    end;
  finally
    SQL.Free;
  end;
end;

procedure TgdcAcctBaseConfig.CreateSF;
var
  gdcFunction: TgdcFunction;
  SQL: TIBSQL;
  Params: TgsParamList;
  P: TgsParamData;
  S: TStream;
  I: Integer;
  V: TStrings;

  C: TBaseAcctConfigClass;
  Config: TBaseAcctConfig;
  CName: string;

  InputParams, SetParams: string;

  F: TatRelationField;
const
  cFunctionBody =
    'Sub %s (DatePeriod%s)'#13 +
    '  Set F = Designer.CreateObject(Application, "%s", "") '#13#10 +
    '  F.Caption = "%s" '#13#10 +
    '  F.DateBegin = DatePeriod(0) '#13#10 +
    '  F.DateEnd = DatePeriod(1) '#13#10 +
    '  F.GetComponent("iblConfiguratior").CurrentKeyInt = gdcBaseManager.GetIdByRuidString("%s") '#13#10 +
    '%s' +
    '  F.GetComponent("actRun").Execute'#13#10 +
    '  F.Show '#13#10 +
    'End Sub';
begin
  if FieldByName('showinexplorer').AsInteger <> 1 then
   HideCommand
  else
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := ReadTransaction;
      SQL.SQl.Text := 'SELECT id FROM gd_function WHERE name = :N';
      SQL.ParamByName('N').AsString := Format(cFunctionName, [RUIDToStr(GetRUID)]);
      SQL.ExecQuery;

      gdcFunction := TgdcFunction.Create(nil);
      try
        gdcFunction.Transaction := Transaction;
        gdcFunction.ReadTransaction := ReadTransaction;
        gdcFunction.SubSet := 'ByID';
        gdcFunction.Id := SQL.FieldByName('id').AsInteger;
        gdcFunction.Open;
        gdcFunction.Edit;
        try
          gdcFunction.FieldByName(fnName).AsString := Format(cFunctionName, [RUIDToStr(GetRUID)]);
          gdcFunction.FieldByName(fnModule).AsString := scrUnkonownModule;
          gdcFunction.FieldByName(fnModuleCode).AsInteger := OBJ_APPLICATION;
          InputParams := '';
          SetParams := '';
          Params := TgsParamList.Create;
          try
            P := TgsParamData.Create(DatePeriod, 'Период', prmPeriod, '');
            Params.Add(P);

            S := CreateBlobStream(FieldByName('config'), bmRead);
            try
              CName := ReadStringFromStream(S);
              TPersistentClass(C) := GetClass(CName);
              if C <> nil then
              begin
                Config := C.Create;
                try
                  Config.LoadFromStream(S);

                  V := TStringList.Create;
                  try
                    V.Text := Config.Analytics;
                    for I := 0 to V.Count - 1 do
                    begin
                      if V.Values[V.Names[I]] = cInputParam then
                      begin
                        F := atDatabase.FindRelationField(AC_ENTRY, V.Names[I]);
                        V[I] := StringReplace(V[I], 'USR$', '', [rfReplaceAll]);
                        InputParams := InputParams + Format(', %s', [V.Names[I]]);

                        if F <> nil then
                        begin
                          if (F.ReferencesField <> nil) then
                          begin
                            // Если поле ссылка то к параметру необходимо обращатся как к массиву
                            SetParams := SetParams + #13#10 + Format(
                              '  If CStr(%s(0)) > "" Then'#13 +
                              '    If Values > "" Then _'#13 +
                              '      Values = Values + Chr(13) + Chr(10)'#13#10 +
                              '    Values = Values + "%s=" + CStr(%s(0))'#13#10 +
                              '  End If', [V.Names[I], F.FieldName, V.Names[I]]);
                           P := TgsParamData.Create(V.Names[I], F.LName, prmLinkElement, '');
                           P.LinkTableName := F.References.RelationName;
                           P.LinkDisplayField := F.Field.RefListFieldName;
                           P.LinkPrimaryField := F.ReferencesField.FieldName;
                           Params.Add(P);
                          end else
                          begin
                            SetParams := SetParams + #13#10 + Format(
                              '  If CStr(%s) > "" Then'#13#10 +
                              '    If Values > "" Then _'#13#10 +
                              '      Values = Values + Chr(13) + Chr(10)'#13#10 +
                              '    Values = Values + "%s=" + CStr(%s)'#13#10 +
                              '  End If', [V.Names[I], F.FieldName, V.Names[I]]);
                           P := TgsParamData.Create(V.Names[I], F.LName, prmString, '');
                           Params.Add(P);
                          end;
                        end;
                      end;
                    end;
                  finally
                    V.Free;
                  end;
                finally
                  Config.Free;
                end;
              end;
            finally
              S.Free;
            end;

            S := gdcFunction.CreateBlobStream(gdcFunction.FieldByName('ENTEREDPARAMS'), bmWrite);
            try
              Params.SaveToStream(S);
            finally
              S.Free;
            end;
          finally
            Params.Free;
          end;

          if SetParams > '' then
            SetParams := '  Set frAcctAnalytics = F.GetComponent("frAcctAnalytics")'#13#10 +
              '  Values = frAcctAnalytics.Values'#13#10 + SetParams + #13#10'  frAcctAnalytics.Values = Values'#13#10;

          gdcFunction.FieldByName(fnScript).AsString := Format(cFunctionBody,
            [gdcFunction.FieldByName(fnName).AsString,
            InputParams,
            GetGDVViewForm,
            FieldByName(fnName).AsString,
            RUIDToStr(GetRUID),
            SetParams]);
          gdcFunction.FieldByName(fnLanguage).AsString := DefaultLanguage;
          gdcFunction.Post;

          if ScriptFactory <> nil then
            ScriptFactory.ReloadFunction(gdcFunction.FieldByName(fnID).AsInteger);
        except
          gdcFunction.Cancel;
          raise;
        end;
        CreateCommand(gdcFunction.GetRUID);
      finally
        gdcFunction.Free;
      end;
    finally
      SQL.Free;
    end;
  end;
end;

procedure TgdcAcctBaseConfig.DeleteCommand(SFRUID: TRUID);
var
  SQL: TIBSQL;
  gdcExplorer: TgdcExplorer;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := Transaction;
    SQL.SQL.Text := 'SELECT * FROM gd_command WHERE cmd = ''' + RUIDToStr(SFRUID) + '''';
    SQL.ExecQuery;

    gdcExplorer := TgdcExplorer.Create(nil);
    try
      gdcExplorer.Transaction := Transaction;
      gdcExplorer.ReadTransaction := ReadTransaction;
      gdcExplorer.SubSet := 'ByID';
      gdcExplorer.Id := SQL.FieldByName('id').AsInteger;
      gdcExplorer.Open;
      if not gdcExplorer.Eof then
        gdcExplorer.Delete;
    finally
      gdcExplorer.Free;
    end;
  finally
    SQL.Free;
  end;
end;

procedure TgdcAcctBaseConfig.DeleteSF;
var
  gdcFunction: TgdcFunction;
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := ReadTransaction;
    SQL.SQL.Text := 'SELECT id FROM gd_function WHERE name = ''' +
      Format(cFunctionName, [RUIDToStr(GetRUID)]) + '''';
    SQL.ExecQuery;
    if not SQL.EOF then
    begin
      gdcFunction := TgdcFunction.Create(nil);
      try
        gdcFunction.Transaction := Transaction;
        gdcFunction.ReadTransaction := ReadTransaction;
        gdcFunction.SubSet := 'ByID';
        gdcFunction.Id := SQL.FieldByName('id').AsInteger;
        gdcFunction.Open;
        DeleteCommand(gdcFunction.GetRUID);
        gdcFunction.Delete;
      finally
        gdcFunction.Free;
      end;
    end;
  finally
    SQL.Free;
  end;
end;

procedure TgdcAcctBaseConfig.HideCommand;
var
  gdcFunction: TgdcFunction;
  SQL: TIBSQL;
  gdcExplorer: TgdcExplorer;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := ReadTransaction;
    SQL.SQl.Text := 'SELECT id FROM gd_function WHERE name = ''' +
      Format(cFunctionName, [RUIDToStr(GetRUID)]) + '''';
    SQL.ExecQuery;
    if not SQL.EOF then
    begin
      gdcFunction := TgdcFunction.Create(nil);
      try
        gdcFunction.Transaction := Transaction;
        gdcFunction.ReadTransaction := ReadTransaction;
        gdcFunction.SubSet := 'ByID';
        gdcFunction.Id := SQL.FieldByName('Id').AsInteger;
        gdcFunction.Open;

        SQL.Close;
        SQL.SQL.Text := 'SELECT id FROM gd_command WHERE cmd = ''' + RUIDToStr(gdcFunction.GetRUID) + '''';
        SQL.ExecQuery;
        if not SQL.Eof then
        begin
          gdcExplorer := TgdcExplorer.Create(nil);
          try
            gdcExplorer.Transaction := Transaction;
            gdcExplorer.ReadTransaction := ReadTransaction;
            gdcExplorer.SubSet := 'ByID';
            gdcExplorer.Id := SQL.FieldByName('id').AsInteger;
            gdcExplorer.Open;
            gdcExplorer.Edit;
            if not gdcExplorer.Eof then
            begin
              gdcExplorer.FieldByName('disabled').AsInteger := 1;
              gdcExplorer.Post;
            end
          finally
            gdcExplorer.Free;
          end;
        end;
      finally
        gdcFunction.Free;
      end;
    end;
  finally
    SQL.Free;
  end;
end;

procedure TgdcAcctBaseConfig.DoAfterCustomProcess(Buff: Pointer;
  Process: TgsCustomProcess);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_DOAFTERCUSTOMPROCESS('TGDCACCTBASECONFIG', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCACCTBASECONFIG', KEYDOAFTERCUSTOMPROCESS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERCUSTOMPROCESS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCACCTBASECONFIG') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self),
  {M}          Integer(Buff), TgsCustomProcess(Process)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCACCTBASECONFIG',
  {M}          'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCACCTBASECONFIG' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if Process = cpDelete then
    DeleteSF
  else
    CreateSF;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCACCTBASECONFIG', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCACCTBASECONFIG', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS);
  {M}  end;
  {END MACRO}
end;

class function TgdcAcctBaseConfig.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'TdlgBaseAcctConfig'
end;

function TgdcAcctBaseConfig.GetGDVViewForm: string;
begin
  Result := 'Tgdv_frmAcctBaseConfig'
end;

class function TgdcAcctBaseConfig.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Name'
end;

class function TgdcAcctBaseConfig.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'AC_ACCT_CONFIG'
end;

class function TgdcAcctBaseConfig.IsAbstractClass: Boolean;
begin
  Result := Self.ClassNameIs('TgdcAcctBaseConfig');
end;

{ TgdcAcctLedgerConfig }

class function TgdcAcctLedgerConfig.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'TdlgAcctLedgerConfig'
end;

class function TgdcAcctAccConfig.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'TdlgAcctAccCardConfig'
end;

class function TgdcAcctBaseConfig.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmAcctBaseConfig'
end;

function TgdcAcctLedgerConfig.GetGDVViewForm: string;
begin
  Result := 'Tgdv_frmAcctLedger'
end;

class function TgdcAcctLedgerConfig.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmAcctLedger'
end;

function TgdcAcctAccConfig.GetGDVViewForm: string;
begin
  Result := 'Tgdv_frmAcctAccCard';
end;

class function TgdcAcctAccConfig.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmAcctAccCard';
end;

procedure TgdcAcctLedgerConfig.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  S.Add('z.CLASSNAME = ''TAccLedgerConfig''')
end;

procedure TgdcAcctAccConfig.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  S.Add('z.CLASSNAME = ''TAccCardConfig''')
end;

{ TgdcAcctCicrilationListConfig }

class function TgdcAcctCicrilationListConfig.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'TdlgAcctCirculationList'
end;

function TgdcAcctCicrilationListConfig.GetGDVViewForm: string;
begin
  Result := 'Tgdv_frmAcctCirculationList';
end;

class function TgdcAcctCicrilationListConfig.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmAcctCirculationList'
end;

procedure TgdcAcctCicrilationListConfig.GetWhereClauseConditions(
  S: TStrings);
begin
  inherited;
  S.Add('z.CLASSNAME = ''TAccCirculationListConfig''')
end;

{ TgdcAcctGeneralLedgerConfig }

class function TgdcAcctGeneralLedgerConfig.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'TdlgAcctGeneralLedger'
end;

function TgdcAcctGeneralLedgerConfig.GetGDVViewForm: string;
begin
  Result := 'Tgdv_frmGeneralLedger'
end;

class function TgdcAcctGeneralLedgerConfig.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmAcctGeneralLedger'
end;

procedure TgdcAcctGeneralLedgerConfig.GetWhereClauseConditions(
  S: TStrings);
begin
  inherited;
  S.Add('z.CLASSNAME = ''TAccGeneralLedgerConfig''')
end;

{ TgdcAcctAccReviewConfig }

class function TgdcAcctAccReviewConfig.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'TdlgAcctAccReviewConfig';
end;

function TgdcAcctAccReviewConfig.GetGDVViewForm: string;
begin
  Result := 'Tgdv_frmAcctAccReview'
end;

class function TgdcAcctAccReviewConfig.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmAcctAccReview'
end;

procedure TgdcAcctAccReviewConfig.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  S.Add('z.CLASSNAME = ''TAccReviewConfig''')
end;

initialization
  RegisterGdcClass(TgdcAcctBaseConfig);
  RegisterGdcClass(TgdcAcctAccConfig);
  RegisterGdcClass(TgdcAcctLedgerConfig);
  RegisterGdcClass(TgdcAcctCicrilationListConfig);
  RegisterGdcClass(TgdcAcctGeneralLedgerConfig );
  RegisterGdcClass(TgdcAcctAccReviewConfig);
finalization
  UnRegisterGdcClass(TgdcAcctBaseConfig);
  UnRegisterGdcClass(TgdcAcctAccConfig);
  UnRegisterGdcClass(TgdcAcctLedgerConfig);
  UnRegisterGdcClass(TgdcAcctCicrilationListConfig);
  UnRegisterGdcClass(TgdcAcctGeneralLedgerConfig );
  UnRegisterGdcClass(TgdcAcctAccReviewConfig);
end.

