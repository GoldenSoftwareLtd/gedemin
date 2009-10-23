unit xOperation;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DBTables, xCalc, UserLogin;

type
  TxOperation = class(TComponent)
  private
    FOpType: Integer;
    FDocumentKey: Integer;
    FFinishTime: TDateTime;
    FStartTime: TDateTime;
    FSumCurr: Double;
    FSumNCU: Double;
    FCurr: Integer;
    FDateDoc: TDateTime;
    FError: Boolean;
    FVariables: TStringList;
    FAnalyzes: TStringList;
    FOperationKey: Integer;
    FFixedAnalyze: TStringList;
    FExternalEntryKey: String;
    FComment: String;

    procedure SetVariables(const Value: TStringList);
    procedure SetAnalyzes(const Value: TStringList);

    procedure SetOperationValueAnalyze(OpKey: Integer);
    procedure SetEntryValueAnalyze(EntryKey, AccountKey,
      DebitCredit, TypeEntryKey: Integer);
    procedure SetFixedAnalyze(const Value: TStringList);
    procedure SearchOperationKey;

  protected
  public
    destructor Destroy;
      override;

    constructor Create(aOwner: TComponent);
      override;

    procedure BeginOp;
    procedure PostOp;
    procedure DeleteOp;
    procedure ShowAnalyze;

    property ExternalEntryKey: String read FExternalEntryKey write
      FExternalEntryKey;
  published
    { Published declarations }

    property DocumentKey: Integer read FDocumentKey write FDocumentKey;
    property OperationKey: Integer read FOperationKey write FOperationKey;
    property OpType: Integer read FOpType write FOpType;
    property Comment: String read FComment write FComment;
    property StartTime: TDateTime read FStartTime write FStartTime;
    property FinishTime: TDateTime read FFinishTime write FFinishTime;

    property SumNCU: Double read FSumNCU write FSumNCU;
    property SumCurr: Double read FSumCurr write FSumCurr;
    property Curr: Integer read FCurr write FCurr;
    property DateDoc: TDateTime read FDateDoc write FDateDoc;
    property Error: Boolean read FError;
    property Variables: TStringList read FVariables write SetVariables;
    property FixedAnalyze: TStringList read FFixedAnalyze
      write SetFixedAnalyze;
    property Analyzes: TStringList read FAnalyzes write SetAnalyzes;
  end;

procedure Register;

implementation

uses
  dlgAnalyzeOperation_unit, xCommonOperation;

procedure Register;
begin
  RegisterComponents('gsDB', [TxOperation]);
end;

{ TxOperation }

procedure TxOperation.SearchOperationKey;
var
  SQL: TQuery;
begin
  SQL := TQuery.Create(Self);
  try
    SQL.DataBaseName := 'xxx';
    SQL.SQL.Text := 'SELECT operationkey FROM fin_opdocvalue, fin_operation ' +
     ' WHERE fin_opdocvalue.operationkey = fin_operation.operationkey AND ' +
     ' optype = ' + IntToStr(OpType) + 'and Documentkey = ' + IntToStr(DocumentKey);
    SQL.Open;
    if SQL.RecordCount <> 0 then
      OperationKey := SQL.FieldByName('operationkey').AsInteger;
  finally
    SQL.Free;
  end;
end;

procedure TxOperation.DeleteOp;
var
  SQL: TQuery;
begin
  SearchOperationKey;
  SQL := TQuery.Create(Self);
  try
    SQL.DataBaseName := 'xxx';
    SQL.SQL.Text := 'DELETE FROM fin_opdocvalue WHERE operationkey = ' +
      IntToStr(operationKey);
    SQL.ExecSQL;
    SQL.SQL.Text := 'DELETE FROM fin_opanalyzeval WHERE operationkey = ' +
      IntToStr(operationKey);
    SQL.ExecSQL;

    SQL.SQL.Text :=
    ' DELETE FROM fin_entryanalyze WHERE entrykey IN ' +
    ' (SELECT id FROM fin_entrylist WHERE operationkey = ' + IntToStr(operationKey) + ')';
    SQL.ExecSQL;

    SQL.SQL.Text := 'DELETE FROM fin_entrylist WHERE operationkey = ' +
      IntToStr(operationKey);
    SQL.ExecSQL;

    SQL.SQL.Text := 'DELETE FROM fin_operation WHERE operationkey = ' +
      IntToStr(operationKey);
    SQL.ExecSQL;
  finally
    SQL.Free;
  end;
end;

procedure TxOperation.BeginOp;
begin
  FStartTime := Now;
  FError := False;
  FOperationKey := -1;
end;

constructor TxOperation.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FDocumentKey := -1;
  FOperationKey := -1;
  FCurr := -1;
  FSumNCU := 0;
  FSumCurr := 0;
  FError := False;

  FVariables := TStringList.Create;
  FAnalyzes := TStringList.Create;
  FFixedAnalyze := TStringList.Create;
  FExternalEntryKey := '';
end;

destructor TxOperation.Destroy;
begin
  FVariables.Free;
  FAnalyzes.Free;
  FFixedAnalyze.Free;
  inherited Destroy;
end;

procedure TxOperation.PostOp;
var
  Duration: Integer;
  stAddOperation, stAddEntry: TStoredProc;
  qryTypeEntry: TQuery;
  xFocal: TxFocal;
  aSumNCU, aSumCurr: Double;
begin
  FFinishTime := Now;
  Duration := Round((FFinishTime - FStartTime) * 24 * 60 * 60 * 1000);
  stAddOperation := TStoredProc.Create(Self);
  try
    stAddOperation.DatabaseName := 'xxx';
    stAddOperation.StoredProcName := 'fin_p_addoperation';
    stAddOperation.Prepare;
    stAddOperation.ParamByName('CommitDate').AsDateTime :=
      DateDoc;
    stAddOperation.ParamByName('EnterDate').AsDateTime := Date;
    stAddOperation.ParamByName('Duration').AsInteger := Duration;
    stAddOperation.ParamByName('SubSystemKey').AsInteger :=
      CurrentUser.SubSystemKey;
    stAddOperation.ParamByName('SessionKey').AsInteger :=
      CurrentUser.SessionKey;
    stAddOperation.ParamByName('UserKey').AsInteger :=
      CurrentUser.UserKey;
    stAddOperation.ParamByName('SumNCU').AsFloat :=
      FSumNCU;
    stAddOperation.ParamByName('SumCurr').AsFloat :=
      FSumCurr;

    if FCurr = -1 then
      stAddOperation.ParamByName('Curr').Clear
    else
      stAddOperation.ParamByName('Curr').AsInteger := FCurr;
    stAddOperation.ParamByName('OperationKey').AsInteger :=
      FOperationKey;
    stAddOperation.ParamByName('OpTypeKey').AsInteger :=
      FOpType;
    stAddOperation.ParamByName('DocumentKey').AsInteger :=
      FDocumentKey;
    if FExternalEntryKey = '' then
      stAddOperation.ParamByName('EntryExtKey').Clear
    else
      stAddOperation.ParamByName('EntryExtKey').AsString := FExternalEntryKey;
    try
      stAddOperation.ExecProc;
      FError := False;
    except
      FError := True;
      exit;
    end;
    FOperationKey :=
      stAddOperation.ParamByName('OutOperationKey').AsInteger;

    SetOperationValueAnalyze(FOperationKey);

  finally
    stAddOperation.Free;
  end;

  stAddEntry := TStoredProc.Create(Self);
  try
    qryTypeEntry := TQuery.Create(Self);
    try
      stAddEntry.DatabaseName := 'xxx';
      stAddEntry.StoredProcName := 'fin_p_entrylist_append';
      stAddEntry.Prepare;
      qryTypeEntry.DatabaseName := 'xxx';
      qryTypeEntry.SQL.Add('SELECT * FROM fin_entrytype');
      qryTypeEntry.SQL.Add(FORMAT('WHERE optypekey = %d', [FOpType]));
      qryTypeEntry.Open;
      if not qryTypeEntry.EOF then begin
        xFocal := TxFocal.Create(Self);
        try
          while not qryTypeEntry.EOF do begin
            xFocal.Variables := FVariables;
            xFocal.AssignVariable('SumNCU', FSumNCU);
            xFocal.AssignVariable('SumCurr', FSumCurr);
            xFocal.StrictVars := False;
            xFocal.Expression :=
              qryTypeEntry.FieldByName('Expression').AsString;
            aSumNCU := xFocal.Value;
            xFocal.Expression :=
              qryTypeEntry.FieldByName('ExpressionCurr').AsString;
            aSumCurr := xFocal.Value;
            stAddEntry.ParamByName('operation').AsInteger :=
              FOperationKey;
            stAddEntry.ParamByName('debit').AsInteger :=
              qryTypeEntry.FieldByName('debitid').AsInteger;
            stAddEntry.ParamByName('credit').AsInteger :=
              qryTypeEntry.FieldByName('creditid').AsInteger;
            stAddEntry.ParamByName('sumncu').AsFloat :=
              aSumNcu;
            stAddEntry.ParamByName('sumcurr').AsFloat :=
              aSumCurr;
            if Curr = -1 then
              stAddEntry.ParamByName('Curr').Clear
            else
              stAddEntry.ParamByName('curr').AsInteger := Curr;
            stAddEntry.ParamByName('comment').AsString :=
              FComment;
            if FExternalEntryKey = '' then
              stAddEntry.ParamByName('externalkey').Clear
            else
              stAddEntry.ParamByName('externalkey').AsString :=
                FExternalEntryKey;
            stAddEntry.ExecProc;

            SetEntryValueAnalyze(stAddEntry.ParamByName('EntryId').AsInteger,
              qryTypeEntry.FieldByName('DebitId').AsInteger, 1,
              qryTypeEntry.FieldByName('Id').AsInteger);

            SetEntryValueAnalyze(stAddEntry.ParamByName('EntryId').AsInteger,
              qryTypeEntry.FieldByName('CreditId').AsInteger, 0,
              qryTypeEntry.FieldByName('Id').AsInteger);
              
            qryTypeEntry.Next;
          end;
        finally
          xFocal.Free;
        end;
      end;
    finally
      qryTypeEntry.Free;
    end;
  finally
    stAddEntry.Free;
  end;
end;

procedure TxOperation.SetAnalyzes(const Value: TStringList);
begin
  FAnalyzes.Assign(Value);
end;

procedure TxOperation.SetEntryValueAnalyze(EntryKey, AccountKey,
  DebitCredit, TypeEntryKey: Integer);
var
  qryAnEntryType: TQuery;
  qryAnValueType: TQuery;
  spAddAnalyzeEntry: TStoredProc;
  i, ValueID: Integer;
  isFind: Boolean;
begin
  if FAnalyzes.Count > 0 then
  begin
    qryAnEntryType := TQuery.Create(Self);
    qryAnValueType := TQuery.Create(Self);
    spAddAnalyzeEntry := TStoredProc.Create(Self);
    try
      qryAnValueType.DatabaseName := 'xxx';
      spAddAnalyzeEntry.DatabaseName := 'xxx';
      spAddAnalyzeEntry.StoredProcName := 'fin_p_entryanalyze_insert';
      spAddAnalyzeEntry.Prepare;
      qryAnEntryType.DatabaseName := 'xxx';
      qryAnEntryType.SQL.Add(
        Format('SELECT * FROM fin_p_getantypevalue (%d, %d, %d)',
        [AccountKey, DebitCredit, TypeEntryKey]));

      qryAnEntryType.Open;
      while not qryAnEntryType.EOF do begin
        isFind := False;
        for i := 0 to FAnalyzes.Count - 1 do
        begin
          if (GetAnalyzeFromString(FAnalyzes[i], ValueID) =
            qryAnEntryType.FieldByName('analyzeid').AsInteger) and
            (ValueID <> -1)
          then begin
            spAddAnalyzeEntry.ParamByName('entrykey').AsInteger :=
              EntryKey;
            spAddAnalyzeEntry.ParamByName('analyzetable').AsInteger :=
              qryAnEntryType.FieldByName('analyzeid').AsInteger;
            spAddAnalyzeEntry.ParamByName('analyzevalue').AsInteger :=
              ValueID;
            spAddAnalyzeEntry.ParamByName('DebitCredit').AsInteger := DebitCredit;
            spAddAnalyzeEntry.ExecProc;
            isFind := True;
          end;
        end;
        if not isFind and
          (qryAnEntryType.FieldByName('valueid').AsInteger > 0)
        then
        begin
          spAddAnalyzeEntry.ParamByName('entrykey').AsInteger :=
            EntryKey;
          spAddAnalyzeEntry.ParamByName('analyzetable').AsInteger :=
            qryAnEntryType.FieldByName('analyzeid').AsInteger;
          spAddAnalyzeEntry.ParamByName('analyzevalue').AsInteger :=
            qryAnEntryType.FieldByName('valueid').AsInteger;
          spAddAnalyzeEntry.ParamByName('DebitCredit').AsInteger := DebitCredit;  
          spAddAnalyzeEntry.ExecProc;
        end;
        qryAnEntryType.Next;
      end;
    finally
      qryAnEntryType.Close;
      qryAnEntryType.Free;
      spAddAnalyzeEntry.Free;
      qryAnValueType.Free;
    end;
  end;
end;


procedure TxOperation.SetFixedAnalyze(const Value: TStringList);
begin
  FFixedAnalyze.Assign(Value);
end;

procedure TxOperation.SetOperationValueAnalyze(OpKey: Integer);
var
  qryAnOpType: TQuery;
  spAddAnalyzeOp: TStoredProc;
  i, ValueID: Integer;
begin
  if FAnalyzes.Count > 0 then
  begin
    qryAnOpType := TQuery.Create(Self);
    spAddAnalyzeOp := TStoredProc.Create(Self);
    try
      spAddAnalyzeOp.DatabaseName := 'xxx';
      spAddAnalyzeOp.StoredProcName := 'fin_p_opanalyzeval_insert';
      spAddAnalyzeOp.Prepare;
      qryAnOpType.DatabaseName := 'xxx';
      qryAnOptype.SQL.Clear;
      qryAnOptype.SQL.Add(
        Format('DELETE FROM fin_opanalyzeval WHERE operationkey = %d',
          [OpKey]));
      qryAnOpType.ExecSQL;
      qryAnOptype.SQL.Clear;

      qryAnOptype.SQL.Add(
        Format('SELECT * FROM fin_optypeanalyze WHERE optypekey = %d',
        [FOpType]));

      qryAnOpType.Open;
      while not qryAnOpType.EOF do begin
        for i := 0 to FAnalyzes.Count - 1 do
        begin
          if (GetAnalyzeFromString(FAnalyzes[i], ValueID) =
            qryAnOpType.FieldByName('analyzekey').AsInteger) and
            (ValueID <> -1)
          then begin
            spAddAnalyzeOp.ParamByName('operationkey').AsInteger :=
              FOperationKey;
            spAddAnalyzeOp.ParamByName('analyzetable').AsInteger :=
              qryAnOpType.FieldByName('analyzekey').AsInteger;
            spAddAnalyzeOp.ParamByName('analyzevalue').AsInteger :=
              ValueID;
            spAddAnalyzeOp.ExecProc;
          end;
        end;
        qryAnOpType.Next;
      end;
    finally
      qryAnOpType.Close;
      qryAnOpType.Free;
      spAddAnalyzeOp.Free;
    end;
  end;
end;

procedure TxOperation.SetVariables(const Value: TStringList);
begin
  FVariables.Assign(Value);
end;

procedure TxOperation.ShowAnalyze;
begin
{  with TfrmAnalyzeOperation.Create(Self, FOpType, FAnalyzes, FFixedAnalyze) do
  begin
    try
      ShowModal;
    finally
      Free;
    end;
  end;}
end;

end.
