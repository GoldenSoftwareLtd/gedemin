unit xImportAnjelica;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  xTable, DB, DBTables, UserLogin, xBKIni, xOperation, xBasics;

type
  TxImportAnjelica = class(TComponent)
  private
  { Private declarations }

    FOpType: Integer;
    FAnalyzeTable: Integer;

    FBookkeepIni: TxBookkeepIni;
    FOperation: TxOperation;

    function ImportItemAnalyze(tblAnalyzeValue: TTable;
      ExternalKey: Integer; const Name: String): Integer;
    function ExportItemAnalyze(tblBookkeepTable: TxTable;
      ExternalKey: Integer; const Name: String): Integer;
    function GetLastCode: String;

  protected
  public
    LastOperation: TIntegerList;

    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    function ImportOperation: Boolean;
    procedure ExportOperation;
    procedure ImportAnalyzeTable;
    procedure ExportAnalyzeTable;
    procedure ImportCardAccount;

    property AnalyzeTable: Integer read FAnalyzeTable write FAnalyzeTable;

  published

    property OpType: Integer read FOpType write FOpType;
  end;


procedure Register;

implementation

uses
  xCommonOperation, dlgImportOperation, dlgEnterInterval, xCommon_anj,
  frmRunningBoy_unit;

procedure Register;
begin
  RegisterComponents('x-DataBase', [TxImportAnjelica]);
end;

{ TxImportAnjelica }

constructor TxImportAnjelica.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);

  FBookkeepIni := TxBookkeepIni.Create(Self);
  FOperation := TxOperation.Create(Self);
  LastOperation := TIntegerList.Create;

  FOpType := -1;
  FAnalyzeTable := -1;
end;

destructor TxImportAnjelica.Destroy;
begin
  if FBookkeepIni <> nil then
    FBookkeepIni.Free;
  FBookkeepIni := nil;

  if FOperation <> nil then
    FOperation.Free;
  FOperation := nil;
  LastOperation.Free;

  inherited Destroy;
end;

procedure TxImportAnjelica.ImportCardAccount;
var
  FolderKey, PlanKey, i: Integer;
  KAUs: array[1..4] of Integer;
  Temp: array[0..31] of Char;
  xtblAccount, xtblRefKAU: TxTable;
  spAccount: TStoredProc;
begin
  xtblAccount := TxTable.Create(Self);
  xtblRefKAU := TxTable.Create(Self);
  spAccount := TStoredProc.Create(Self);
  try
    if FBookkeepIni.SystemCode > 0 then
    begin
      xtblAccount.DatabaseName := FBookkeepIni.MainDir;
      xtblAccount.TableName := 'ACOUNT.DB';
      xtblAccount.Open;
      xtblRefKAU.DatabaseName := FBookkeepIni.MainDir;
      xtblRefKAU.TableName := 'REFKAU.DB';
      xtblRefKAU.Open;
      spAccount.DataBaseName := 'xxx';
      spAccount.StoredProcName := 'FIN_P_CARDACCOUNT_IMPORT';
      xtblAccount.First;
      PlanKey := -1;
      FolderKey := -1;
      spAccount.Prepare;
      while not xtblAccount.EOF do
      begin
        spAccount.ParamByName('ACCOUNT').AsString :=
          xtblAccount.FieldByName('Acount').Text;
        spAccount.ParamByName('TypeAccount').AsInteger :=
          xtblAccount.FieldByName('Active').AsInteger;
        spAccount.ParamByName('OffBalance').AsInteger :=
          xtblAccount.FieldByName('IncludeBalans').AsInteger;
        spAccount.ParamByName('MultyCurr').AsInteger :=
          xtblAccount.FieldByName('IsCurrency').AsInteger;
        spAccount.ParamByName('Name').Text :=
          xtblAccount.FieldByName('Name acount').Text;
        spAccount.ParamByName('Folder').AsString :=
          xtblAccount.FieldByName('NameGroup').Text;
        spAccount.ParamByName('PlanKey').AsInteger := PlanKey;
        spAccount.ParamByName('FolderKey').AsInteger := FolderKey;
        StrPCopy(Temp, xtblAccount.FieldByName('Acount').Text);
        ANSIToOEMBuff(Temp, Temp, SizeOf(Temp));
        if xtblRefKAU.FindKey([StrPas(Temp)]) then
        begin
          for i:= 1 to 4 do begin
            if xtblRefKAU.Fields[i].AsInteger = 0 then
              KAUs[i] := -1
            else
              KAUs[i] := xtblRefKAU.Fields[i].AsInteger;
          end;
        end
        else
          for i:= 1 to 4 do KAUs[i] := -1;
        spAccount.ParamByName('KAU1').AsInteger := KAUs[1];
        spAccount.ParamByName('KAU2').AsInteger := KAUs[2];
        spAccount.ParamByName('KAU3').AsInteger := KAUs[3];
        spAccount.ParamByName('KAU4').AsInteger := KAUs[4];
        spAccount.ExecProc;
        PlanKey := spAccount.ParamByName('OutPlanKey').AsInteger;
        FolderKey := spAccount.ParamByName('OutFolderKey').AsInteger;
        xtblAccount.Next;
      end;
      xtblAccount.Close;
      xtblRefKAU.Close;
    end;
  finally
    spAccount.Free;
    xtblAccount.Free;
    xtblRefKAU.Free;
  end;

end;

procedure TxImportAnjelica.ExportAnalyzeTable;
var
  tblAnalyzeTable: TTable;
  tblBookkeepTable: TxTable;
  tblAnalyzeValue: TTable;
  ExternalKey: Integer;
begin
  if (FAnalyzeTable = -1) or                  // Не задана таблица аналитики
     (FBookkeepIni.SystemCode <= 0) then exit;// Не зарегистрирована в бухгалтерии

  if FAnalyzeTable = taCustomer then exit; // Для синхронизации клиентов используется
                                           // отдельная компонента !!!

  tblAnalyzeTable := TTable.Create(Self);
  try
    tblAnalyzeTable.DatabaseName := 'xxx';
    tblAnalyzeTable.TableName := 'fin_analyzetable';
    tblAnalyzeTable.Open;
    if tblAnalyzeTable.FindKey([FAnalyzeTable]) and
       (tblAnalyzeTable.FieldByName('ExternalKey').AsInteger > 0)
    then
    begin
      tblAnalyzeValue := TTable.Create(Self);
      tblBookkeepTable := TxTable.Create(Self);
      try

        tblAnalyzeValue.DatabaseName := 'xxx';
        if FAnalyzeTable >= taUserDefine then
          tblAnalyzeValue.TableName := 'fin_antablevalue'
        else
          tblAnalyzeValue.TableName :=
            tblAnalyzeTable.FieldByName('TableName').AsString;

        tblAnalyzeValue.Open;

        if FAnalyzeTable >= taUserDefine then
          tblAnalyzeValue.IndexFieldNames := 'AnalyzeKey;ExternalKey'
        else
          tblAnalyzeValue.IndexFieldNames := 'ExternalKey';

        FBookkeepIni.TypeReferency :=
          tblAnalyzeTable.FieldByName('ExternalKey').AsInteger;
        tblBookkeepTable.DatabaseName := FBookkeepIni.ReferencyDir;
        tblBookkeepTable.TableName :=
          KAUInfo[FBookkeepIni.TypeReferency].NameFileKAU;
        tblBookkeepTable.Open;

        if FAnalyzeTable >= taUserDefine then
          tblAnalyzeValue.SetRange([FAnalyzeTable], [FAnalyzeTable]);

        tblAnalyzeValue.First;
        while not tblAnalyzeValue.EOF do
        begin
          ExternalKey := ExportItemAnalyze(tblBookkeepTable,
            tblAnalyzeValue.FieldByName('ExternalKey').AsInteger,
            tblAnalyzeValue.FieldByName('Name').AsString);
          if ExternalKey <> tblAnalyzeValue.FieldByName('ExternalKey').AsInteger
          then
          begin
            tblAnalyzeValue.Edit;
            tblAnalyzeValue.FieldByName('ExternalKey').AsInteger := ExternalKey;
            tblAnalyzeValue.Post;
          end;
          tblAnalyzeValue.Next;
        end;

        tblBookkeepTable.Close;
        tblAnalyzeTable.Close;
      finally
        tblAnalyzeValue.Free;
        tblBookkeepTable.Free;
      end;
    end;
  finally
    tblAnalyzeTable.Free;
  end;
end;

function TxImportAnjelica.ExportItemAnalyze(tblBookkeepTable: TxTable;
  ExternalKey: Integer; const Name: String): Integer;
var
  MaxNumber: Integer;
begin
  Result := ExternalKey;
  if (ExternalKey <= 0) or not tblBookkeepTable.FindKey([ExternalKey]) then
  begin
    tblBookkeepTable.Last;
    MaxNumber := tblBookkeepTable.Fields[0].AsInteger + 1;
    tblBookkeepTable.Append;
    tblBookkeepTable.Fields[0].AsInteger := MaxNumber;
    tblBookkeepTable.Fields[1].Text := Name;
    repeat
      try
        tblBookkeepTable.Post;
        Break;
      except
        Inc(MaxNumber);
        tblBookkeepTable.Fields[0].AsInteger := MaxNumber;
      end;
    until False;
    Result := MaxNumber;
  end
  else
  begin
    tblBookkeepTable.Edit;
    tblBookkeepTable.Fields[1].Text := Name;
    tblBookkeepTable.Post;
  end;
end;

procedure TxImportAnjelica.ExportOperation;
var
  qryExportEntry: TQuery;
  qrySearchAnalyze: TQuery;
  tblAnalyzeTable: TTable;
  tblRegister: TxTable;
  isOk: Boolean;
  DateBegin, DateEnd: TDateTime;
  N: Integer;

  function MakeKAU(const OldKAU: String): String;
  var
    S: String;
    NumAnalyze: Integer;
    ValueAnalyze: Integer;
  begin
    Result := '';
    S := OldKAU;
    while Pos('.', S) > 0 do
    begin
      NumAnalyze := StrToInt(copy(S, 1, Pos('_', S) - 1));
      ValueAnalyze := StrToInt(copy(S, Pos('_', S) + 1, Pos('.', S) -
        Pos('_', S) - 1));
      if tblAnalyzeTable.FindKey([NumAnalyze]) then
      begin
        qrySearchAnalyze.SQL.Clear;
        if tblAnalyzeTable.FieldByName('tablename').AsString = '' then
        begin
          qrySearchAnalyze.SQL.Add('SELECT externalkey FROM fin_antablevalue');
          qrySearchAnalyze.SQL.Add(FORMAT('  WHERE id = %d AND', [ValueAnalyze]));
          qrySearchAnalyze.SQL.Add(FORMAT('  analyzekey = %d', [NumAnalyze]));
        end
        else begin
          qrySearchAnalyze.SQL.Add('SELECT externalkey FROM ' +
            tblAnalyzeTable.FieldByName('tablename').AsString);
          qrySearchAnalyze.SQL.Add(FORMAT('  WHERE id = %d', [ValueAnalyze]));
        end;
        qrySearchAnalyze.Open;
        try
          if qrySearchAnalyze.RecordCount > 0 then begin
            if Result <> '' then Result := Result + '.';
            Result := Result + qrySearchAnalyze.Fields[0].AsString;
          end;
        finally
          qrySearchAnalyze.Close;
        end;  
      end;
      S := copy(S, Pos('.', S) + 1, 255);
    end;
  end;

begin
  with TfrmEnterInterval.Create(Self) do
  begin
    try
      isOk := ShowModal = mrOk;
      if isOk then
      begin
        DateBegin := DateBegin_int;
        DateEnd := DateEnd_int;
      end;
    finally
      Free;
    end;
  end;

  if not isOk then exit;

  qryExportEntry := TQuery.Create(Self);
  qrySearchAnalyze := TQuery.Create(Self);
  tblAnalyzeTable := TTable.Create(Self);
  tblRegister := TxTable.Create(Self);
  try
    qryExportEntry.DatabaseName := 'xxx';
    qrySearchAnalyze.DatabaseName := 'xxx';
    tblAnalyzeTable.DatabaseName := 'xxx';
    tblAnalyzeTable.TableName := 'fin_analyzetable';
    tblAnalyzeTable.IndexFieldNames := 'ID';
    tblAnalyzeTable.Open;

    tblRegister.DatabaseName := FBookkeepIni.WorkingDir;
    tblRegister.TableName := 'newreg.db';
    tblRegister.EmptyTable;
    tblRegister.Open;
    qryExportEntry.SQL.Add(
     'SELECT * FROM fin_p_entrylist_export(:OpType, :DateBegin, :DateEnd)');
    qryExportEntry.Prepare;
    qryExportEntry.ParamByName('OpType').AsInteger := FOpType;
    qryExportEntry.ParamByName('DateBegin').AsDateTime := DateBegin;
    qryExportEntry.ParamByName('DateEnd').AsDateTime := DateEnd;
    qryExportEntry.Open;
    qryExportEntry.First;
    frmRunningBoy.xRunMan.Value := 0;
    N := 0;
    frmRunningBoy.lblName.Caption := 'Экспорт операций';
    frmRunningBoy.Show;
    while not qryExportEntry.EOF do
    begin
      tblRegister.Append;
      tblRegister.FieldByName('Date').AsDateTime :=
        qryExportEntry.FieldByName('DateEntry').AsDateTime;
      tblRegister.FieldByName('Nompp').AsString :=
        GetLastCode;
      tblRegister.FieldByName('Debet').Text :=
        qryExportEntry.FieldByName('Debit').AsString;
      tblRegister.FieldByName('Kredit').Text :=
        qryExportEntry.FieldByName('Credit').AsString;
      tblRegister.FieldByName('KAU debet').Text :=
        MakeKAU(qryExportEntry.FieldByName('DebitKAU').AsString);
      tblRegister.FieldByName('KAU kredit').Text :=
        MakeKAU(qryExportEntry.FieldByName('CreditKAU').AsString);
      tblRegister.FieldByName('Summa').AsFloat :=
        qryExportEntry.FieldByName('SumNCU').AsFloat;
      tblRegister.FieldByName('Summa in cur').AsFloat :=
        qryExportEntry.FieldByName('SumCurr').AsFloat;
      tblRegister.FieldByName('Name operation').Text :=
        qryExportEntry.FieldByName('NameOper').AsString;
      if qryExportEntry.FindField('COMMENT') <> nil then
        tblRegister.FieldByName('Number payment').AsString :=
          qryExportEntry.FieldByName('COMMENT').AsString;
      tblRegister.FieldByName('Codesubsystem').AsInteger :=
        FBookkeepIni.SystemCode;
      tblRegister.Post;
      Inc(N);
      if (N / qryExportEntry.RecordCount * 20) >
        frmRunningBoy.xRunMan.Value then
          frmRunningBoy.xRunMan.Value := frmRunningBoy.xRunMan.Value + 1;
      qryExportEntry.Next;
    end;
    frmRunningBoy.Hide;
    tblRegister.Close;
    tblAnalyzeTable.Close;
  finally
    qryExportEntry.Free;
    qrySearchAnalyze.Free;
    tblRegister.Free;
    tblAnalyzeTable.Free;
  end;
end;

function TxImportAnjelica.GetLastCode: String;
var
  F: Integer;
  ReOpenBuff: TOfStruct;
  S: String;
  Temp: array[0..255] of Char;
  Times: Integer;
begin
  Result := '';
  S := FBookkeepIni.WorkingDir + '\' + 'balnomer.inf';
  if not FileExists(S) then
  begin
    F := OpenFile(StrPCopy(Temp, S), ReOpenBuff,  OF_CREATE);
    Result := GetNextAlphaCode(Result, 7);
    _lwrite(F, StrPCopy(Temp, S), StrLen(Temp) + 1);
    _lclose(F);
    exit;
  end;

  Times := GetTickCount;
  repeat
    F := OpenFile(StrPCopy(Temp, S), ReOpenBuff,
      OF_READWRITE + OF_SHARE_EXCLUSIVE);
    if F <> -1 then
    begin
      _lread(F, @Temp, SizeOf(Temp));
      Result := GetNextAlphaCode(StrPas(Temp), 7);
      _llseek(F, 0, FILE_BEGIN);
      _lwrite(F, StrPCopy(Temp, Result), StrLen(Temp) + 1);
      _lclose(F);
      Break;
    end
    else
      if GetTickCount - Times > 10000 then Break;
  until False;

end;

procedure TxImportAnjelica.ImportAnalyzeTable;
var
  tblAnalyzeTable: TTable;
  tblBookkeepTable: TTable;
  tblAnalyzeValue: TTable;
begin
  if (FAnalyzeTable = -1) or                  // Не задана таблица аналитики
     (FBookkeepIni.SystemCode <= 0) then exit;// Не зарегистрирована в бухгалтерии

  if FAnalyzeTable = taCustomer then exit; // Для синхронизации клиентов используется
                                           // отдельная компонента !!!

  tblAnalyzeTable := TTable.Create(Self);
  try
    tblAnalyzeTable.DatabaseName := 'xxx';
    tblAnalyzeTable.TableName := 'fin_analyzetable';
    tblAnalyzeTable.Open;
    if tblAnalyzeTable.FindKey([FAnalyzeTable]) and
       (tblAnalyzeTable.FieldByName('ExternalKey').AsInteger > 0)
    then
    begin
      tblAnalyzeValue := TTable.Create(Self);
      tblBookkeepTable := TxTable.Create(Self);
      try

        tblAnalyzeValue.DatabaseName := 'xxx';
        if FAnalyzeTable >= taUserDefine then
          tblAnalyzeValue.TableName := 'fin_antablevalue'
        else
          tblAnalyzeValue.TableName :=
            tblAnalyzeTable.FieldByName('TableName').AsString;

        tblAnalyzeValue.Open;
        if FAnalyzeTable >= taUserDefine then
          tblAnalyzeValue.IndexFieldNames := 'AnalyzeKey;ExternalKey'
        else
          tblAnalyzeValue.IndexFieldNames := 'ExternalKey';

        FBookkeepIni.TypeReferency :=
          tblAnalyzeTable.FieldByName('ExternalKey').AsInteger;
        tblBookkeepTable.DatabaseName := FBookkeepIni.ReferencyDir;
        tblBookkeepTable.TableName :=
          KAUInfo[FBookkeepIni.TypeReferency].NameFileKAU;
        tblBookkeepTable.Open;

        while not tblBookkeepTable.EOF do
        begin
          ImportItemAnalyze(tblAnalyzeValue,
            tblBookkeepTable.Fields[0].AsInteger,
            tblBookkeepTable.Fields[1].Text);
          tblBookkeepTable.Next;
        end;

        tblBookkeepTable.Close;
        tblAnalyzeTable.Close;
      finally
        tblAnalyzeValue.Free;
        tblBookkeepTable.Free;
      end;
    end;
  finally
    tblAnalyzeTable.Free;
  end;
end;

function TxImportAnjelica.ImportItemAnalyze(tblAnalyzeValue: TTable;
  ExternalKey: Integer; const Name: String): Integer;
begin
  if ((FAnalyzeTable >= taUserDefine) and
     tblAnalyzeValue.FindKey([FAnalyzeTable, ExternalKey])) or
     ((FAnalyzeTable < taUserDefine) and
       tblAnalyzeValue.FindKey([ExternalKey]))
  then
  begin
    tblAnalyzeValue.Edit;
  end else
  begin
    tblAnalyzeValue.Append;
    tblAnalyzeValue.FieldByName('ExternalKey').AsInteger :=
      ExternalKey;
    if FAnalyzeTable >= taUserDefine then
      tblAnalyzeValue.FieldByName('AnalyzeKey').AsInteger := FAnalyzeTable;
  end;
  tblAnalyzeValue.FieldByName('Name').AsString := Name;
  tblAnalyzeValue.Post;
  tblAnalyzeValue.Refresh;
  Result := tblAnalyzeValue.Fields[0].AsInteger;
end;

function TxImportAnjelica.ImportOperation: Boolean;
var
  xtblRefKAU: TTable;
  tblAnalyzeTable: TTable;
  qryGetValue: TQuery;
  DebitsKAU: array[1..4] of Integer;
  CreditsKAU: array[1..4] of Integer;
  AnalyzeDebit: array[1..4] of Integer;
  AnalyzeCredit: array[1..4] of Integer;
  DebitKAUTable: array[1..4] of String[79];
  CreditKAUTable: array[1..4] of String[79];
  CountDebitKAU: Integer;
  CountCreditKAU: Integer;
  k, N: Integer;
  TempInt: Integer;
  FNestedTransaction: Boolean;

  procedure SetAnalyzeTable(const Debit, Credit: String);
  var
    i: Integer;
  begin
    xtblRefKAU := TxTable.Create(Self);
    try
      xtblRefKAU.DatabaseName := FBookkeepIni.MainDir;
      xtblRefKAU.TableName := 'refkau.db';
      xtblRefKAU.IndexFieldNames := 'NumSchet';
      xtblRefKAU.Open;
      CountDebitKAU := 0;
      CountCreditKAU := 0;
      if xtblRefKAU.FindKey([Debit]) then
      begin
        for i:= 1 to 4 do begin
          if xtblRefKAU.Fields[i].IsNull or
             (xtblRefKAU.Fields[i].AsInteger = 0)
          then Break;
          if tblAnalyzeTable.FindKey([xtblRefKAU.Fields[i].AsInteger]) then
          begin
            AnalyzeDebit[i] := tblAnalyzeTable.FieldByName('id').AsInteger;
            DebitKAUTable[i] :=
              tblAnalyzeTable.FieldByName('tablename').AsString;
          end;
          CountDebitKAU := i;
        end;
      end;

      if xtblRefKAU.FindKey([Credit]) then
      begin
        for i:= 1 to 4 do begin
          if xtblRefKAU.Fields[i].IsNull or
             (xtblRefKAU.Fields[i].AsInteger = 0)
          then
            Break;
          if tblAnalyzeTable.FindKey([xtblRefKAU.Fields[i].AsInteger]) then
          begin
            AnalyzeCredit[i] := tblAnalyzeTable.FieldByName('ID').AsInteger;
            CreditKAUTable[i] :=
              tblAnalyzeTable.FieldByName('tablename').AsString;
          end;
          CountCreditKAU := i;
        end;
      end;
      xtblRefKAU.Close;
    finally
      xtblRefKAU.Free;
    end;
  end;

  procedure MakeKAUValue(const KAU: String; CountKAU: Integer;
    var KAUValue: array of Integer);
  var
    i, Code: Integer;
    S: String;
  begin
    for i:= 0 to CountKAU - 1 do
      KAUValue[i] := 0;
    S := KAU;
    if S = '' then exit;
    for i:= 0 to CountKAU - 1 do begin
      if Pos('.', S) > 0 then
      begin
        val(copy(S, 1, Pos('.', S) - 1), KAUValue[i], Code);
        S := copy(S, Pos('.', S) + 1, 255);
      end
      else begin
        val(S, KAUValue[i], Code);
        Break;
      end;
    end;
  end;

  function SetAnalyzeValue(TypeAnalyze, AnalyzeValue: Integer;
    KAUTable: String): Integer;
  begin
    Result := -1;
    if TypeAnalyze <> 0 then
    begin

      qryGetValue.SQL.Clear;
      if KAUTable = '' then
      begin
        qryGetValue.SQL.Text := Format(
        ' SELECT id FROM fin_antablevalue WHERE externalkey = %d AND ' +
        ' analyzekey = %d',
        [AnalyzeValue, TypeAnalyze]
        );
  {      qryGetValue.SQL.Add('SELECT id FROM fin_analyzevalue');
        qryGetValue.SQL.Add('   WHERE externalkey = :Code AND');
        qryGetValue.SQL.Add('         analyzekey = :CodeAnalyze');
        qryGetValue.ParamByName('CodeAnalyze').AsInteger :=
          TypeAnalyze;}
      end
      else begin
        qryGetValue.SQL.Add(FORMAT('SELECT * FROM %s', [KAUTable]));
        qryGetValue.SQL.Add('   WHERE externalkey = :Code');
        qryGetValue.ParamByName('Code').AsInteger := AnalyzeValue;
      end;
  {    qryGetValue.ParamByName('Code').AsInteger := AnalyzeValue;}
      qryGetValue.Open;
      if qryGetValue.RecordCount = 0 then
      begin

  { Тут необходимо предусмотреть проведение синхронизации данных }

      end
      else
        Result := qryGetValue.Fields[0].AsInteger;
    end;
  end;

begin
  Result := False;
  LastOperation.Clear;
  FNestedTransaction := Database.InTransaction;
  if not FNestedTransaction then
    Database.StartTransaction;
  qryGetValue := TQuery.Create(Self);
  tblAnalyzeTable := TTable.Create(Self);
  try
    tblAnalyzeTable.DatabaseName := 'xxx';
    tblAnalyzeTable.TableName := 'fin_analyzetable';
    tblAnalyzeTable.IndexFieldNames := 'externalkey';
    tblAnalyzeTable.Open;
    qryGetValue.DatabaseName := 'xxx';


    with TfrmImportOperation.Create(Self, FOpType) do
    begin
      try
        qryRegister.DatabaseName := FBookkeepIni.WorkingDir;

        if ShowModal = mrOk then
        begin
          Result := True;
//          SetAnalyzeTable(qryEntryDebit.Value, qryEntryCredit.Value);
          tblAnalyzeTable.Open;
//          TestCalc := False;

          qryRegister.DisableControls;
          qryRegister.First;
          frmRunningBoy.xRunMan.Value := 0;
          N := 0;
          frmRunningBoy.lblName.Caption := 'Импорт операций';
          frmRunningBoy.Show;
          while not qryRegister.EOF do
          begin
            if mdbcgrRegister.SearchInList(qryRegisterKey.Value) > 0 then
            begin
              SetAnalyzeTable(qryRegisterDebet.Value, qryRegisterKredit.Value);
              FOperation.Analyzes.Clear;
              if qryRegisterKAUDebet.Value <> '' then
              begin
                MakeKAUValue(qryRegisterKAUDebet.Value, CountDebitKAU,
                  DebitsKAU);
                for k:= 1 to CountDebitKAU do begin
                  if DebitsKAU[k] > 0 then begin
                    TempInt := SetAnalyzeValue(AnalyzeDebit[k], DebitsKAU[k],
                      DebitKAUTable[k]);
                    FOperation.Analyzes.Add(Format('%d=%d',
                      [AnalyzeDebit[k], TempInt]));
                  end;

                end;
              end;
              if qryRegisterKAUKredit.Value <> '' then
              begin
                MakeKAUValue(qryRegisterKAUKredit.Value, CountCreditKAU,
                  CreditsKAU);
                for k:= 1 to CountCreditKAU do begin
                  if CreditsKAU[k] > 0 then begin
                    TempInt := SetAnalyzeValue(AnalyzeCredit[k], CreditsKAU[k],
                      CreditKAUTable[k]);
                    FOperation.Analyzes.Add(Format('%d=%d',
                      [AnalyzeCredit[k], TempInt]));
                  end;
                end;
              end;
              FOperation.BeginOp;
              FOperation.DateDoc := qryRegisterDate.Value;
              FOperation.OperationKey := -1;
              FOperation.SumNCU := qryRegisterSumma.Value;
              FOperation.SumCurr := qryRegisterSummaInCurrency.Value;
              FOperation.OpType := qryEntry.FieldByName('OpType').AsInteger;
              FOperation.ExternalEntryKey := qryRegisterNompp.Value;
              FOperation.PostOp;
              LastOperation.Add(FOperation.OperationKey);
            end;
            Inc(N);
            if (N / qryRegister.RecordCount * 20) >
              frmRunningBoy.xRunMan.Value then
                frmRunningBoy.xRunMan.Value := frmRunningBoy.xRunMan.Value + 1;
            qryRegister.Next;
          end;
          frmRunningBoy.Hide;
        end;
      finally
        Free;
      end;
    end;
  finally
    qryGetValue.Free;
    tblAnalyzeTable.Free;
  end;
  if not FNestedTransaction then
    Database.Commit;

end;

end.


