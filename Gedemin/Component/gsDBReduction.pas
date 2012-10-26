
{++


         15.12.2003     Yuri     проверка на существование RUID удаляемой записи   
         24.01.2004     Yuri     Исправления, связанные со сложным ListTable в Lookup'е

--}


unit gsDBReduction;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IBDatabase, IBSQL, IBQuery, DB, IB;

const
  Def_ListField = 'NAME';

type
  TrField = class
  private
    FFieldName: String;
    FMasterValue: Variant;
    FCondemnedValue: Variant;
    FTransfer: Boolean;
    FSumma: Boolean;
    procedure SetSumma(const Value: Boolean);
    function GetSummable: Boolean;

  public
    constructor Create(
      const AFieldName: String;
      const AMasterValue: Variant;
      const ACondemnedValue: Variant;
      const ATransfer: Boolean;
      const ASumma: Boolean = False);
    procedure Assign(Field: TrField);

    property FieldName: String read FFieldName write FFieldName;
    property MasterValue: Variant read FMasterValue write FMasterValue;
    property CondemnedValue: Variant read FCondemnedValue write FCondemnedValue;
    property Transfer: Boolean read FTransfer write FTransfer;
    property Summa: Boolean read FSumma write SetSumma;
    property Summable: Boolean read GetSummable;
  end;

  TReductionField = class(TList)
  private
    function GetrField(Index: Integer): TrField;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear; override;
    procedure Delete(Index: Integer);
    property Fields[Index: Integer]: TrField read GetrField;
    procedure Assign(AReductionField: TReductionField);

    function AddField(const FieldName: String; const MasterValue, CondemnedValue: Variant;
      const Transfer: Boolean; const Summa: Boolean = False): Integer; overload;
    function AddField(rField: TrField): Integer; overload;
  end;

  TReductionTableList = class;

  TReductionTable = class
  private
    FName: String;
    FForeignKey: String;
    FReductionField: TReductionField;
    FReductionTableList: TReductionTableList;
    FOneToOne: Boolean;
    FTypeReduction: Integer;

    procedure SetReductionTableList(Value: TReductionTableList);
    procedure SetReductionField(Value: TReductionField);

  public
    constructor Create(const AName, AForeignKey: String); overload;
    constructor Create; overload;
    destructor Destroy; override;
    procedure Assign(ATable: TReductionTable);

    property Name: String read FName write FName;
    property ForeignKey: String read FForeignKey write FForeignKey;
    property ReductionField: TReductionField read FReductionField
      write SetReductionField;
    property ReductionTableList: TReductionTableList read FReductionTableList
      write SetReductionTableList;
    property OneToOne: Boolean read FOneToOne write FOneToOne;
    property TypeReduction: Integer read FTypeReduction write FTypeReduction;
    // Только если OneToOne = True 0: Master(1) - Condemned(1):
    //                             1: Master(1) - Condemned(0)
    //                             2: Master(0) - Condemned(1)
  end;

  TReductionTableList = class(TList)
  private
    function GetReductionTable(Index: Integer): TReductionTable;

  public
    destructor Destroy; override;

    procedure Clear; override;
    procedure Assign(AReductionTableList: TReductionTableList);
    procedure DeleteTable(Index: Integer);
    property Table[Index: Integer]: TReductionTable read GetReductionTable;

    function AddTable(const TableName, ForeignKey: string): Integer; overload;
    function AddTable(ATable: TReductionTable): Integer; overload;
  end;

  TgsDBReduction = class(TComponent)
  private
    FTable: String;
    FKeyField: String;
    FMasterKey: String;
    FCondemnedKey: String;
    FTransferData: Boolean;
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;
    FReductionTable: TReductionTable;
    FHideFields: String;
    FCondition: String;
    FAddCondition: String;
    FMainTable: String;
    FUserAsked: Boolean;
    FRenameRecord: Boolean;
    FIgnoryQuestion: Boolean;

    procedure SetDatabase(const Value: TIBDatabase);
    procedure SetTransaction(const Value: TIBTransaction);
    procedure SetReductionTable(const Value: TReductionTable);
    procedure SetCondemnedKey(const Value: String);
    // Сливание записи таблицы
    function ReduceRecord(RTable: TReductionTable): Boolean;
    function PrepareTable(RTable: TReductionTable): Boolean;
    function isHideField(const FieldName: String): Boolean;

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    // Приготовление к переносу с проверкой существования записей и
    // формированием списка ReduceField
    property HideFields: String read FHideFields write FHideFields;
    property Condition: String read FCondition write FCondition;

    property AddCondition: String read FAddCondition write FAddCondition;

  public
    // Список полей текущих и заменяемых значений
    property ReductionTable: TReductionTable read FReductionTable write SetReductionTable;
    // Имя ключевого поля
    property KeyField: String read FKeyField write FKeyField;
    //т.к. запрос для слияния может формироваться из нескольких таблиц,
    //укажем главную
    property MainTable: String read FMainTable write FMainTable;

    //
    property RenameRecord: Boolean read FRenameRecord write FRenameRecord;

    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    function GetPrimary(const aTableName: String): String;
    function GetUnique(const TableName, FieldName: String): String;

    function Prepare: Boolean;
    // Сливание
    function MakeReduction: Boolean;

    // Подготовка и слияние
    procedure Reduce;

    property IgnoryQuestion: Boolean read FIgnoryQuestion write FIgnoryQuestion;

  published
    property Table: String read FTable write FTable;
    // Имя таблицы.
    property MasterKey: String read FMasterKey write FMasterKey;
    // Ключ главной записи.
    property CondemnedKey: String read FCondemnedKey write SetCondemnedKey;
    // Ключ записи удаляемой.
    property TransferData: Boolean read FTransferData write FTransferData;
    property Database: TIBDatabase read FDatabase write SetDatabase;
    property Transaction: TIBTransaction read FTransaction write SetTransaction;
  end;

  TgsDBReductionWizard = class(TgsDBReduction)
  private
    FListField: String;

  protected

  public
    constructor Create(AnOwner: TComponent); override;

    // Этот метод выводит Wizard, после выбора записей,
    // вызывает Prepare, а затем после настроей пользователя
    // вызывает MakeReduce
    function Wizard(const AClassName: String = ''; const ASubType: String = ''): Boolean; overload;

  published
    property HideFields;
    property ListField: String read FListField write FListField;
    property Condition;
    property AddCondition;
  end;

  ExReductionError = class(Exception);


procedure Register;

implementation

uses
  gsDBReduction_dlgWizard, gsDBReduction_dlgErrorRecord, gd_resourcestring,
  jclStrings, Contnrs, at_Classes, iberrorcodes
  {$IFDEF GEDEMIN}
  , gd_security
  {$ENDIF}
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{TrField ---------------------------------------------------------}

constructor TrField.Create(
  const AFieldName: String;
  const AMasterValue: Variant;
  const ACondemnedValue: Variant;
  const ATransfer: Boolean;
  const ASumma: Boolean = False);
begin
  FFieldName := AFieldName;
  FMasterValue := AMasterValue;
  FCondemnedValue := ACondemnedValue;
  FTransfer := ATransfer;
  FSumma := ASumma;
end;

procedure TrField.Assign(Field: TrField);
begin
  FFieldName := Field.FieldName;
  FMasterValue := Field.MasterValue;
  FCondemnedValue := Field.CondemnedValue;
  FTransfer := Field.Transfer;
  FSumma := Field.Summa;
end;

{TReductionTable -------------------------------------------------}

constructor TReductionTable.Create;
begin
  inherited Create;

  FReductionField := TReductionField.Create;
  FReductionTableList := TReductionTableList.Create;
  FTypeReduction := 0;
end;

constructor TReductionTable.Create(const AName, AForeignKey: String);
begin
  inherited Create;

  FName := AName;
  FForeignKey := AForeignKey;

  FReductionField := TReductionField.Create;
  FReductionTableList := TReductionTableList.Create;
  FOneToOne := False;
end;

procedure TReductionTable.Assign(ATable: TReductionTable);
begin
  FName := ATable.Name;
  FForeignKey := ATable.ForeignKey;
  FReductionField.Assign(ATable.ReductionField);
  FReductionTableList.Assign(ATable.ReductionTableList);
end;

destructor TReductionTable.Destroy;
begin
  FReductionField.Free;
  FReductionTableList.Free;

  inherited Destroy;
end;

procedure TReductionTable.SetReductionTableList(Value: TReductionTableList);
begin
  if Value <> nil then
   FReductionTableList.Assign(Value);
end;

procedure TReductionTable.SetReductionField(Value: TReductionField);
begin
end;

{TReductionField -----------------------------------------}

function TReductionField.GetrField(Index: Integer): TrField;
begin
  Assert((Index >= 0) or (Self.Count > Index), 'Индекс вне диапазона.');
  Assert(Self.Items[Index] <> nil, 'Блок данных пуст.');
  Result := TrField(Items[Index]);
end;

constructor TReductionField.Create;
begin
  inherited;
end;

destructor TReductionField.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TReductionField.Clear;
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do
    Delete(I);

  inherited;
end;

procedure TReductionField.Delete(Index: Integer);
begin
  Assert((Index >= 0) or (Self.Count > Index), 'Индекс вне диапазона.');
  TrField(Items[Index]).Free;
  inherited Delete(Index);
end;

function TReductionField.AddField(rField: TrField): Integer;
begin
  Result := Add(TrField.Create(rField.FieldName, rField.MasterValue,
    rField.CondemnedValue, rField.Transfer, rField.Summa));
end;

procedure TReductionField.Assign(AReductionField: TReductionField);
var
  I: Integer;
begin
  for I := 0 to AReductionField.Count - 1 do
    Self.AddField(AReductionField.Fields[I]);
end;

function TReductionField.AddField(const FieldName: String; const MasterValue, CondemnedValue: Variant;
  const Transfer: Boolean; const Summa: Boolean = False): Integer;
begin
  Result := Self.Add(TrField.Create(FieldName, MasterValue, CondemnedValue, Transfer, Summa));
end;

{TReductionTableList -----------------------------------------}

function TReductionTableList.GetReductionTable(Index: Integer): TReductionTable;
begin
  Assert((Index >= 0) or (Self.Count > Index), 'Индекс вне диапазона.');
  Assert(Self.Items[Index] <> nil, 'Блок данных пуст.');
  Result := TReductionTable(Items[Index]);
end;

destructor TReductionTableList.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TReductionTableList.Assign(AReductionTableList: TReductionTableList);
var
  I: Integer;
begin                                        
  Assert(AReductionTableList <> nil, 'Передаваемый парметр nil.');

  Self.Clear;
  for I := 0 to Count - 1 do
    Self.AddTable(AReductionTableList.Table[I]);
end;

procedure TReductionTableList.Clear;
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do
    DeleteTable(I); // было Delete!!! Yuri

  inherited;
end;

procedure TReductionTableList.DeleteTable(Index: Integer);
begin
  Assert((Index >= 0) or (Self.Count > Index), 'Индекс вне диапазона.');
  TReductionTable(Items[Index]).Free;
  inherited Delete(Index);
end;

function TReductionTableList.AddTable(const TableName, ForeignKey: String): Integer;
begin
  Result := Add(TReductionTable.Create(TableName, ForeignKey));
end;

function TReductionTableList.AddTable(ATable: TReductionTable): Integer;
begin
  Result := Self.Add(TReductionTable.Create(ATable.Name, ATable.ForeignKey));
  TReductionTable(Items[Result]).Assign(ATable);
end;

{TgsDBReduction ------------------------------------------}

constructor TgsDBReduction.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FReductionTable := TReductionTable.Create;
  FTransferData := True;

  FIgnoryQuestion := False;

  FDatabase := nil;
  FTransaction := nil;

  FUserAsked := False;
end;

destructor TgsDBReduction.Destroy;
begin
  FReductionTable.Free;

  inherited Destroy;
end;

procedure TgsDBReduction.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if Operation = opRemove then
  begin
    if AComponent = FDatabase then
      FDatabase := nil
    else if AComponent = FTransaction then
      FTransaction := nil;
  end;
end;
 
function TgsDBReduction.GetPrimary(const aTableName: String): String;
var
  I: Integer;
  TableName: String;
  R: TatRelation;
begin
  Assert(atDatabase <> nil);

  TableName := Trim(aTableName);
  I := Pos(' ', TableName);
  if I > 0 then
    SetLength(TableName, I - 1);

  Result := '';
  R := atDatabase.Relations.ByRelationName(TableName);
  if R <> nil then
  begin
    for I := 0 to R.PrimaryKey.ConstraintFields.Count - 1 do
    begin
      if I > 0 then
        Result := Result + ',';
      Result := Result + R.PrimaryKey.ConstraintFields[I].FieldName;
    end;
  end;
end;

function TgsDBReduction.GetUnique(const TableName, FieldName: String): String;
var
  sql: TIBSQL;
  {First, }DidActivate: Boolean;
begin
  Assert(FDataBase <> nil, 'Не подключен DataBase.');
  Assert(FTransaction <> nil, 'Не подключен Transaction.');
  Assert(TableName > '', 'Table name is not specified');

  DidActivate := False;
  sql := TIBSQL.Create(nil);
  try
    DidActivate := not FTransaction.InTransaction;
    if DidActivate then
      FTransaction.StartTransaction;
    sql.Database := FDataBase;
    sql.Transaction := FTransaction;
    sql.sql.Text :=
      ' SELECT ind.FIELDSLIST list ' +
      ' FROM AT_INDICES ind ' +
      ' WHERE ind.RELATIONNAME = UPPER(''' + TableName + ''') ' +
      ' AND ind.UNIQUE_FLAG = 1 ';
    sql.ExecQuery;
    while not sql.Eof do
    begin
      if Pos(',' + FieldName + ',', ',' + sql.FieldByName('list').AsString + ',') > 0 then
      begin
        Result := sql.FieldByName('list').AsString;
        Break;
      end;
      sql.Next;
    end;
    sql.Close;
  finally
    sql.Free;
    if DidActivate and FTransaction.InTransaction then
      FTransaction.Commit;
  end;
end;

procedure TgsDBReduction.SetDatabase(const Value: TIBDatabase);
begin
  if FDatabase <> Value then
  begin
    if FDatabase <> nil then
      FDatabase.RemoveFreeNotification(Self);
    FDatabase := Value;
    if FDatabase <> nil then
      FDatabase.FreeNotification(Self);
  end;
end;

procedure TgsDBReduction.SetReductionTable(const Value: TReductionTable);
begin
  if Value <> nil then
    FReductionTable.Assign(Value);
end;

procedure TgsDBReduction.SetCondemnedKey(const Value: String);
begin
  if FCondemnedKey <> Value then
  begin
    FCondemnedKey := Value;
    FUserAsked := False;
  end;
end;

procedure TgsDBReduction.SetTransaction(const Value: TIBTransaction);
begin
  if FTransaction <> Value then
  begin
    if FTransaction <> nil then
      FTransaction.RemoveFreeNotification(Self);
    FTransaction := Value;
    if FTransaction <> nil then
      FTransaction.FreeNotification(Self);
  end;
end;

function TgsDBReduction.ReduceRecord(RTable: TReductionTable): Boolean;
var
  sql: TIBSQL;
  I, k, l: Integer;
  S, Sign, UpdateSQL: String;
  F: TStringList;
  DidActivate: Boolean;
begin
  Assert(FDataBase <> nil, 'Не подключен DataBase.');
  Assert(FTransaction <> nil, 'Не подключен Transaction.');

  Result := True;
  if RTable.TypeReduction <> 1 then
  begin
    DidActivate := False;
    try
      sql := TIBSQL.Create(nil);
      try
        DidActivate := not FTransaction.InTransaction;
        if DidActivate then
          FTransaction.StartTransaction;

        sql.Database := FDataBase;
        sql.Transaction := FTransaction;

{ TODO : проверить удаляемую запись по GD_RUID и настройкам. }
        if not FUserAsked then         // ReduceRecord вызывается в цикле, но FCondemnedKey не меняется
        begin
          sql.Close;
          sql.sql.Text := 'SELECT * FROM GD_RUID WHERE ID = :ID';
          sql.ParamByName('ID').AsInteger := StrToInt(FCondemnedKey);
          sql.ExecQuery;
          if sql.RecordCount > 0  then      // есть RUID
          begin
            i := sql.FieldByName('XID').AsInteger;
            k := sql.FieldByName('DBID').AsInteger;
            sql.Close;
            sql.sql.Text := 'SELECT SETT.NAME FROM AT_SETTING SETT JOIN AT_SETTINGPOS POS ON POS.SETTINGKEY = SETT.ID ' +
            ' WHERE POS.XID = :XID AND POS.DBID = :DBID';
            sql.ParamByName('XID').AsInteger := i;
            sql.ParamByName('DBID').AsInteger := k;
            sql.ExecQuery;
            if sql.RecordCount > 0  then    // RUID есть в настройке
            begin
              S := '';
              while not sql.EOF do
              begin
                S := S + '"' + sql.FieldByName('NAME').AsString + '"'#13#10;
                sql.Next;
             end;
             if not FIgnoryQuestion then
             begin
               MessageBox(0,
                  PChar('Невозможно произвести удаление записи! '#13#10 +
                        'Запись используется в настройках: '#13#10 + S),
                  PChar(sAttention),
                  MB_OK or MB_ICONERROR or MB_TASKMODAL);
                Result := False;
                Exit;
              end;
            end else
            begin
              if not FIgnoryQuestion then
              begin
                if MessageBox(0,
                     PChar('Для записи существует уникальный идентификатор (RUID). ' +
                     'Удаление записи может привести к ошибкам в работе системы. '#13#10 +
                     'Удалить запись все равно?'),
                     PChar(sAttention),
                     MB_YESNO or MB_ICONWARNING or MB_TASKMODAL) = idNo then
                begin
                  Result := False;
                  Exit;
                end;
              end;
            end;
          end;
          FUserAsked := True;
        end;

        for I := 0 to RTable.FReductionTableList.Count - 1 do
        begin
          if RTable.ReductionTableList.Table[I].OneToOne then
          begin
            Result := ReduceRecord(RTable.ReductionTableList.Table[I]);
            if not Result then
              exit;
          end;

          try
            sql.Close;
            if not (FRenameRecord and RTable.ReductionTableList.Table[I].OneToOne) then
            begin
              sql.sql.Text := 'UPDATE ' + RTable.ReductionTableList.Table[I].Name +
                ' SET ' + RTable.ReductionTableList.Table[I].ForeignKey + ' = ' + FMasterKey +
                ' WHERE ' + RTable.ReductionTableList.Table[I].ForeignKey + ' = ' + FCondemnedKey;
              sql.ExecQuery;
            end;
          except
            on EE: EIBError{Exception} do
            begin
              l := -1;
              F := TStringList.Create;
              try
                if EE.IBErrorCode = isc_unique_key_violation then    // primary key
                  S := GetPrimary(RTable.ReductionTableList.Table[I].Name)
                else
                  if EE.IBErrorCode = isc_no_dup then                // unique index
                    S := GetUnique(RTable.ReductionTableList.Table[I].Name, Trim(RTable.ReductionTableList.Table[I].ForeignKey))
                  else begin
                    if not FIgnoryQuestion then
                      MessageBox(0,
                        PChar('Невозможно произвести объединение. Процесс приостановлен.'#13#10#13#10 +
                        'Возникла следующая исключительная ситуация:'#13#10#13#10 +
                        EE.Message), PChar(sAttention), MB_OK or MB_ICONHAND or MB_TASKMODAL);
                    Result := False;
                    exit;
                  end;
                if Trim(S) = 'ID' then
                  S := GetUnique(RTable.ReductionTableList.Table[I].Name, Trim(RTable.ReductionTableList.Table[I].ForeignKey));

                F.CommaText := S;
                if (F.Count > 1) or
                   (F[0] = Trim(RTable.ReductionTableList.Table[I].ForeignKey)) then
                begin
                  for k := 0 to F.Count-1 do
                    if F[k] = Trim(RTable.ReductionTableList.Table[I].ForeignKey) then
                    begin
                      l := k;
                      Break;
                    end;
                end;

                with TdlgErrorRecord.Create(Self) do
                try
                  qryErrorRecord.DataBase := FDataBase;
                  qryErrorRecord.Transaction := FTransaction;

                  qryErrorRecord.SQL.Text := 'SELECT * FROM ' + RTable.ReductionTableList.Table[I].Name + ' a ' +
                    ' WHERE a.' + RTable.ReductionTableList.Table[I].ForeignKey + ' = ' + FCondemnedKey +
                    ' and exists (SELECT * FROM ' + RTable.ReductionTableList.Table[I].Name + ' b ' +
                    ' WHERE b.' + RTable.ReductionTableList.Table[I].ForeignKey + ' = ' + FMasterKey;
                  for k := 0 to F.Count-1 do
                    if k <> l then
                      qryErrorRecord.SQL.Text := qryErrorRecord.SQL.Text +
                        ' and a.' + F[k] + ' = b.' + F[k];
                  qryErrorRecord.SQL.Text := qryErrorRecord.SQL.Text + ')';

                  qryErrorRecord.Open;
                  lbTable.Caption := RTable.ReductionTableList.Table[I].Name;
                  if ShowModal = mrOk then
                  begin
                    try
                      sql.Close;
                      sql.sql.Text := 'DELETE FROM ' + RTable.ReductionTableList.Table[I].Name + ' a ' +
                        ' WHERE a.' + RTable.ReductionTableList.Table[I].ForeignKey + ' = ' + FCondemnedKey +
                        ' and exists (SELECT * FROM ' + RTable.ReductionTableList.Table[I].Name + ' b ' +
                        ' WHERE b.' + RTable.ReductionTableList.Table[I].ForeignKey + ' = ' + FMasterKey;
                      for k := 0 to F.Count-1 do
                        if k <> l then
                          sql.SQL.Text := sql.SQL.Text +
                            ' and a.' + F[k] + ' = b.' + F[k];
                      sql.SQL.Text := sql.SQL.Text + ')';

                      sql.ExecQuery;

                      sql.Close;
                      sql.sql.Text := 'UPDATE ' + RTable.ReductionTableList.Table[I].Name +
                        ' SET ' + RTable.ReductionTableList.Table[I].ForeignKey + ' = ' + FMasterKey +
                        ' WHERE ' + RTable.ReductionTableList.Table[I].ForeignKey + ' = ' + FCondemnedKey;
                      sql.ExecQuery;

                    except
                      on E: Exception do
                      begin
                        if not FIgnoryQuestion then
                          MessageBox(0,
                            PChar('Невозможно произвести удаление. Процесс приостановлен.'#13#10#13#10 +
                            'Возникла следующая исключительная ситуация:'#13#10#13#10 +
                            E.Message),
                            PChar(sAttention),
                            MB_OK or MB_ICONHAND or MB_TASKMODAL);
                        Result := False;
                        exit;
                      end;
                    end;
                  end
                  else begin
                    Result := False;
                    exit;
                  end;
                finally
                  Free;
                end;
              finally
                F.Free;
              end;
            end;
          end;
        end;

        if RTable.TypeReduction = 2 then
        begin
          sql.Close;
          sql.sql.Text := 'UPDATE ' + RTable.Name +
            ' SET ' + RTable.ForeignKey + ' = ' + FMasterKey +
            ' WHERE ' + RTable.ForeignKey + ' = ' + FCondemnedKey;
          sql.ExecQuery;
        end
        else begin // TypeReduction = 0
          if FTransferData then
          begin
            UpdateSQL := '';

            for I := 0 to RTable.ReductionField.Count - 1 do
              if RTable.ReductionField.Fields[I].Summa then
              begin
                if VarType(RTable.ReductionField.Fields[I].MasterValue) = varString then
                  Sign := ' || '' '' || '
                else
                  Sign := ' + ';
                if UpdateSQL = '' then
                  UpdateSQL := RTable.ReductionField.Fields[I].FieldName + ' = :' +
                    RTable.ReductionField.Fields[I].FieldName + Sign +
                    RTable.ReductionField.Fields[I].FieldName
                else
                  UpdateSQL := UpdateSQL + ', ' + RTable.ReductionField.Fields[I].FieldName + ' = :' +
                    RTable.ReductionField.Fields[I].FieldName + Sign +
                    RTable.ReductionField.Fields[I].FieldName;
              end else

              if RTable.ReductionField.Fields[I].Transfer then
                if UpdateSQL = '' then
                  UpdateSQL := RTable.ReductionField.Fields[I].FieldName + ' = :' +
                    RTable.ReductionField.Fields[I].FieldName
                else
                  UpdateSQL := UpdateSQL + ', ' + RTable.ReductionField.Fields[I].FieldName + ' = :' +
                    RTable.ReductionField.Fields[I].FieldName;


            if UpdateSQL > '' then
            begin
              sql.Close;
              sql.sql.Text := 'UPDATE ' + RTable.Name + ' SET ' + UpdateSQL +
                ' WHERE ' + RTable.ForeignKey + ' = ' + FMasterKey;
              sql.Prepare;

              for I := 0 to RTable.ReductionField.Count - 1 do
              begin
                if RTable.ReductionField.Fields[I].Transfer or
                  RTable.ReductionField.Fields[I].Summa then
                begin
                  sql.Params.ByName(RTable.ReductionField.Fields[I].FieldName).Value :=
                    RTable.ReductionField.Fields[I].CondemnedValue;
                end;
              end;

              try
                sql.ExecQuery;
              except
                on E: Exception do
                begin
                  if not FIgnoryQuestion then
                    MessageBox(0,
                      PChar('В процессе обновления таблиц произошла ошибка: ' + E.Message),
                      PChar(sAttention),
                      MB_OK or MB_ICONHAND or MB_TASKMODAL);
                  Result := False;
                  exit;
                end;
              end;
            end;
          end;

          sql.Close;
          if not FRenameRecord then
          begin
            sql.sql.Text := 'DELETE FROM ' + RTable.Name + ' WHERE ' + RTable.ForeignKey +
              ' = ' + FCondemnedKey;
            sql.ExecQuery;
          end;
        end;
      finally
        sql.Free;
        if DidActivate and FTransaction.InTransaction then
        begin
          if Result then
            FTransaction.Commit
          else
            FTransaction.Rollback;
        end;
      end;
    except
      if DidActivate and FTransaction.InTransaction then
        FTransaction.Rollback;
      raise;
    end;

    {$IFDEF GEDEMIN}
    if Assigned(IBLogin) then
    begin
      IBLogin.AddEvent('Объединение записей: ' + FCondemnedKey + ' -> ' + FMasterKey,
        FMainTable,
        StrToIntDef(FMasterKey, -1));
    end;
    {$ENDIF}
  end;
end;

procedure TgsDBReduction.Reduce;
begin
  Assert(FDataBase <> nil, 'Не подключен DataBase.');
  Assert(FTransaction <> nil, 'Не подключен Transaction.');
  Prepare;
  MakeReduction;
end;

function TgsDBReduction.isHideField(const FieldName: String): Boolean;
begin
  Result := StrIPos(';' + FieldName + ';' , ';' + FHideFields) > 0;
end;

function TgsDBReduction.PrepareTable(RTable: TReductionTable): Boolean;
var
  sqlMaster: TIBQuery;
  sqlCondemned: TIBQuery;
  I, J: Integer;
  Transfer, DidActivate: Boolean;
  FK: TatForeignKey;
  Lst: TObjectList;
begin
  Assert(atDatabase <> nil);

  Result := True;

  DidActivate := False;
  RTable.OneToOne := True;
  sqlMaster := TIBQuery.Create(nil);
  sqlCondemned := TIBQuery.Create(nil);
  try
    DidActivate := not FTransaction.InTransaction;
    if DidActivate then
      FTransaction.StartTransaction;

    sqlMaster.Database := FDatabase;
    sqlMaster.Transaction := FTransaction;
    sqlMaster.sql.Text := 'SELECT * FROM ' + RTable.Name +
        ' WHERE ' + RTable.ForeignKey +' = ' + FMasterKey;
    sqlMaster.Open;

    if (RTable.Name = FTable) and sqlMaster.IsEmpty then
    begin
      Result := False;
      if not FIgnoryQuestion then
        MessageBox(0,
          'Такой записи не существует',
          PChar(sAttention),
          MB_OK or MB_ICONHAND or MB_TASKMODAL);
      exit;
    end;

    sqlCondemned.Database := FDatabase;
    sqlCondemned.Transaction := FTransaction;
    sqlCondemned.sql.Text := 'SELECT * FROM ' + RTable.Name +
        ' WHERE ' + RTable.ForeignKey + ' = ' + FCondemnedKey;
    sqlCondemned.Open;

    if (RTable.Name = FTable) and sqlCondemned.IsEmpty then
    begin
      Result := False;
      if not FIgnoryQuestion then
        MessageBox(0,
          'Такой записи не существует',
          PChar(sAttention),
          MB_OK or MB_ICONHAND or MB_TASKMODAL);
      exit;
    end;

    if (sqlMaster.RecordCount <> sqlCondemned.Recordcount) then
    begin
      if sqlMaster.RecordCount = 0 then
        RTable.TypeReduction := 2;
      if sqlCondemned.RecordCount = 0 then
        RTable.TypeReduction := 1;
    end
    else
      if sqlCondemned.RecordCount > 0 then
      begin
        if RTable.TypeReduction = 0 then
          for I := 0 to sqlMaster.Fields.Count - 1 do
          if not isHideField(sqlMaster.Fields[I].FieldName) and
            (sqlMaster.Fields[I].FieldName <> RTable.ForeignKey) then
          begin
            Transfer := (sqlMaster.Fields[I].IsNull or ((sqlMaster.Fields[I] is TStringField)
              and ((sqlMaster.Fields[I] as TStringField).AsString = ''))) and (not sqlMaster.Fields[I].ReadOnly);
            RTable.FReductionField.AddField(sqlMaster.Fields[I].FieldName,
              sqlMaster.Fields[I].Value, sqlCondemned.Fields[I].Value, Transfer);
          end;

        Lst := TObjectList.Create(False);
        try
          atDatabase.ForeignKeys.ConstraintsByReferencedRelation(RTable.Name, Lst);
          for I := 0 to Lst.Count - 1 do
          begin
            FK := Lst[I] as TatForeignKey;

            if FK.IsSimpleKey then
            begin
              J := RTable.ReductionTableList.AddTable(
                FK.Relation.RelationName, FK.ConstraintFields[0].FieldName);

              if (FK.Relation.PrimaryKey <> nil) and (FK.Relation.PrimaryKey.ConstraintFields.Count = 1)
                and (FK.ConstraintFields[0].FieldName = FK.Relation.PrimaryKey.ConstraintFields[0].FieldName) then
              begin
                Result := PrepareTable(RTable.ReductionTableList.Table[J]);
              end;

              if not Result then
                exit;
            end;
          end;
        finally
          Lst.Free;
        end;
      end;

  finally
    sqlMaster.Free;
    sqlCondemned.Free;

    if DidActivate and FTransaction.InTransaction then
      FTransaction.Commit;
  end;
end;

function TgsDBReduction.Prepare: Boolean;
  function GetMainTableName: String;
  var
    i: Integer;
  begin
    i := Pos(' ', Trim(FTable));
    if i = 0 then
      Result := FTable
    else
      Result := Copy(Trim(FTable), 1, i - 1);
  end;
begin
  Assert(FDataBase <> nil, 'Не подключен DataBase.');
  Assert(FTransaction <> nil, 'Не подключен Transaction.');

  if FKeyField = '' then
    FKeyField := GetPrimary(FTable);
  Assert(FKeyField > '', 'У данной таблицы отсутствует PRIMARY KEY.');
  if FMainTable = '' then
    FMainTable := GetMainTableName;
  FReductionTable.Name := FMainTable;
  FReductionTable.ForeignKey := FKeyField;
  FReductionTable.FReductionTableList.Clear;
  FReductionTable.FReductionField.Clear;
  FTransaction.CommitRetaining;
  Result := PrepareTable(FReductionTable);
end;

function TgsDBReduction.MakeReduction: Boolean;
var
  q: TIBSQL;
  DidActivate: Boolean;
begin
  Assert(FDataBase <> nil, 'Не подключен DataBase.');
  Assert(FTransaction <> nil, 'Не подключен Transaction.');

  q := TIBSQL.Create(nil);
  try
    DidActivate := not FTransaction.InTransaction;
    if DidActivate then
      FTransaction.StartTransaction;

    q.Transaction := FTransaction;
    q.SQL.Text :=
      'EXECUTE BLOCK AS'#13#10 +
      'BEGIN'#13#10 +
      '  RDB$SET_CONTEXT(''USER_TRANSACTION'', ''GD_MERGING_RECORDS'', 1);'#13#10 +
      'END';
    q.ExecQuery;

    Result := ReduceRecord(ReductionTable);

    if DidActivate then
    begin
      if Result then
        FTransaction.Commit
      else
        FTransaction.Rollback;
    end else
    begin
      if Result then
        FTransaction.CommitRetaining
      else
        FTransaction.RollbackRetaining;

      q.SQL.Text :=
        'EXECUTE BLOCK AS'#13#10 +
        'BEGIN'#13#10 +
        '  RDB$SET_CONTEXT(''USER_TRANSACTION'', ''GD_MERGING_RECORDS'', NULL);'#13#10 +
        'END';
      q.ExecQuery;
    end;
  finally
    q.Free;
  end;                       
end;

{TgsDBReductionWizard ------------------------------------}

constructor TgsDBReductionWizard.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FListField := Def_ListField;
end;

function TgsDBReductionWizard.Wizard(const AClassName: String = ''; const ASubType: String = ''): Boolean;
begin
  Assert(FDataBase <> nil, 'Не подключен DataBase.');
  Assert(FTransaction <> nil, 'Не подключен Transaction.');

  with TdlgWizard.Create(Self) do
  try
    if FKeyField = '' then
      FKeyField := GetPrimary(FTable);
    Assert(FKeyField > '', 'Primary key is not defined');
    Reduction := Self;
    cbChangeDest.Checked := FTransferData;
    ChangeDestEnabled := FTransferData;
    pcReduce.ActivePage := tsFirst;

    gsibluMaster.Database := FDatabase;
    gsibluMaster.Transaction := FTransaction;

    gsibluCondemned.Database := FDatabase;
    gsibluCondemned.Transaction := FTransaction;

    if AClassName > '' then
    begin
      gsibluMaster.SubType := ASubType;
      gsibluCondemned.SubType := ASubType;
      gsibluMaster.gdClassName := AClassName;
      gsibluCondemned.gdClassName := AClassName;
    end else
    begin
      gsibluMaster.Condition := Condition;
      gsibluCondemned.Condition := Condition;
    end;

    if AddCondition > '' then
    begin
      if (gsibluMaster.Condition > '')  then
        gsibluMaster.Condition := gsibluMaster.Condition + ' AND ';
      gsibluMaster.Condition := gsibluMaster.Condition + AddCondition;
      if gsibluCondemned.Condition > '' then
        gsibluCondemned.Condition := gsibluCondemned.Condition + ' AND ';
      gsibluCondemned.Condition := gsibluCondemned.Condition + AddCondition;
    end;

    gsibluMaster.ListTable := FTable;
    gsibluMaster.ListField := FListField;
    gsibluMaster.KeyField := FKeyField;
    gsibluMaster.CurrentKey := FMasterKey;

    gsibluCondemned.ListTable := FTable;
    gsibluCondemned.ListField := FListField;
    gsibluCondemned.KeyField := FKeyField;
    gsibluCondemned.CurrentKey := FCondemnedKey;

    if Assigned(atDatabase)
      and (atDatabase.Relations.ByRelationName('RPL$LOG') <> nil) then
    begin
      rgAfterAction.ItemIndex := 1;
      rgAfterAction.Enabled := False;
    end else
    begin
      rgAfterAction.ItemIndex := 0;
      rgAfterAction.Enabled := True;
    end;

    ShowModal;
    Result := isReduction;
  finally
    Free;
  end;
end;

procedure Register;
begin
  RegisterComponents('gsNV', [TgsDBReduction]);
  RegisterComponents('gsNV', [TgsDBReductionWizard]);
end;

procedure TrField.SetSumma(const Value: Boolean);
begin
  if Summa <> Value then
  begin
    if Value and (not Summable) then
      raise Exception.Create('Данные невозможно суммировать!');
    FSumma := Value;
  end;
end;

function TrField.GetSummable: Boolean;
begin
  Result := (VarType(MasterValue) in [varSmallint..varCurrency])
    or (VarType(CondemnedValue) in [varSmallint..varCurrency])
    or (VarType(MasterValue) = varString)
    or (VarType(CondemnedValue) = varString);
end;

end.
