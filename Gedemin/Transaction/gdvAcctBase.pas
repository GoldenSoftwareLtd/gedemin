
unit gdvAcctBase;

interface

uses
  Windows, classes, IBCustomDataSet, Controls, IBSQL, gdcBaseInterface,
  gd_KeyAssoc, at_classes, contnrs, DB, gdv_AvailAnalytics_unit, AcctUtils,
  gdv_AcctConfig_unit;

type
  TgdvFieldVisible = (fvUnknown, fvVisible, fvHidden);

  TgdvFieldInfoRec = record
    FieldName: string;
    Caption: string;
    DisplayFieldName: string;
  end;

  TgdvQuantityFieldInfoRec = record
    FieldName: string;
    Caption: string;
    DisplayFieldName: string;
  end;

  TgdvFieldInfoClass = class of TgdvFieldInfo;

  TgdvFieldInfo = class
  private
    FCaption: string;
    FFieldName: string;
    FDisplayFormat: string;
    FVisible: TgdvFieldVisible;
    FDisplayFields:TStrings;
    FCondition: boolean;
    FTotal: Boolean;
    FAnalytic: Boolean;
    FValueFieldName: String;
    procedure SetFieldName(const Value: string);
    procedure SetCaption(const Value: string);
    procedure SetDisplayFormat(const Value: string);
    procedure SetVisible(const Value: TgdvFieldVisible);
    function GetDistlayFields: TStrings;
    procedure SetCondition(const Value: boolean);
    procedure SetTotal(const Value: Boolean);
    procedure SetAnalytic(const Value: Boolean);
    procedure SetValueFieldName(const Value: String);
  public
    destructor Destroy; override;
    property FieldName: string read FFieldName write SetFieldName;
    property Caption: string read FCaption write SetCaption;
    property DisplayFormat: string read FDisplayFormat write SetDisplayFormat;
    property Visible: TgdvFieldVisible read FVisible write SetVisible;
    property DisplayFields: TStrings read GetDistlayFields;
    property Condition: boolean read FCondition write SetCondition;
    property Total: Boolean read FTotal write SetTotal;
    //Данные свойства необходимы для журнал-ордера во время подсчета итого
    property Analytic: Boolean read FAnalytic write SetAnalytic;
    property ValueFieldName: String read FValueFieldName write SetValueFieldName;
  end;


  TgdvFieldInfos = class(TObjectList)
  private
    function GetItems(Index: Integer): TgdvFieldInfo;
  public
    function AddInfo: TgdvFieldInfo; overload;
    function AddInfo(C: TgdvFieldInfoClass): TgdvFieldInfo; overload;

    function IndexByFieldName(FieldName: string): Integer;
    function FindInfo(FieldName: string): TgdvFieldInfo;
    property Items[Index: Integer]: TgdvFieldInfo read GetItems; default;
  end;

  TgdvAcctBase = class(TIBCustomDataSet)
  private
    FKeyAliasList: TStrings;
    FNameAliasList: TStrings;

    FUseEntryBalanceWasSetManually: Boolean;

    procedure SetCompanyKey(const Value: TID);
    procedure FillCompanyList;
    procedure SetAllHolding(const Value: Boolean);
    procedure SetUseEntryBalance(const Value: Boolean);
    function GetCompanyName: String;

    { Уменьшает длину текста запроса путем удаления лишних пробелов и отступов }
    {$IFNDEF DEBUG}
    procedure PackSQL(const S: TStrings);
    {$ENDIF}
  protected
    FMakeEmpty: Boolean;
    FEntryBalanceDate: TDate;
    FUseEntryBalance: Boolean;
    FConfigKey: TID;

    FDateBegin: TDate;
    FDateEnd: TDate;
    FCompanyKey: TID;
    FAllHolding: Boolean;
    FCompanyList: String;
    FWithSubAccounts: Boolean;
    FIncludeInternalMovement: Boolean;
    FShowExtendedFields: Boolean;

    FNcuSumInfo: TgdvSumInfo;
    FCurrSumInfo: TgdvSumInfo;
    FEQSumInfo: TgdvSumInfo;
    FQuantitySumInfo: TgdvSumInfo;
    FCurrKey: TID;
    FNCUCurrKey: TID;

    FAccounts: TgdKeyArray;
    FCorrAccounts: TgdKeyArray;
    FAcctConditions: TStrings;
    FAcctValues: TStringList;

    // Описания полей
    FFieldInfos: TgdvFieldInfos;

    class function ConfigClassName: string; virtual;
    procedure DoLoadConfig(const Config: TBaseAcctConfig); virtual;
    procedure DoSaveConfig(Config: TBaseAcctConfig); virtual;

    procedure DoBeforeBuildReport; virtual;
    procedure SetSQLParams; virtual;
    procedure DoBuildSQL; virtual;
    procedure DoEmptySQL; virtual;
    procedure DoAfterBuildSQL; virtual;
    procedure DoAfterBuildReport; virtual;

    function GetNameAlias(Name: String): String;

    procedure FillSubAccounts(var AccountArray: TgdKeyArray); virtual;
    procedure SetDefaultParams; virtual;
    function DomainName(Field: TatField): String;
    procedure ExtendedFields(Field: TatRelationField; Alias: string; var Select, Group: string;
      UseTemplate: Boolean = False; Template: string = '');
    procedure ExtendedFieldsBalance(Field: TatrelationField; Alias: string;
      var Returns, Select, Into: string);

    function LargeSQLErrorMessage: String; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function GetKeyAlias(ID: Integer): String; overload;
    function GetKeyAlias(ID: String): String; overload;

    procedure ShowInNCU(Show: Boolean; DecDigits: Integer = -1; Scale: Integer = 0);
    procedure ShowInCurr(Show: Boolean; DecDigits: Integer = -1; Scale: Integer = 0; CurrKey: TID = -1);
    procedure ShowInEQ(Show: Boolean; DecDigits: Integer = -1; Scale: Integer = 0);
    procedure ShowInQuantity(DecDigits: Integer = -1; Scale: Integer = 0);

    // Добавляет счета, по которому будет выполняться расчет
    procedure AddAccount(AccountKey: TID);
    // Добавляет счета, по котором будут считаться корреспондирующие проводки
    procedure AddCorrAccount(AccountKey: TID);
    // Добавляет условие, например USR$GS_CUSTOMER = 147567392
    procedure AddCondition(FieldName: String; AValue: String);
    // Добавляет количественную аналитику
    procedure AddValue(ValueKey: TID; ValueName: String = '');

    procedure LoadConfig(AID: TID);
    function SaveConfig(const AConfigKey: TID = -1): TID;

    procedure Clear; virtual;
    procedure BuildReport;
    procedure Execute(ConfigID: TID);
    function ParamByName(Idx: String): TIBXSQLVAR;

    function InternalMovementClause(TableAlias: String = 'e'): string; virtual;
    function GetCondition(Alias: String): String;

    property Accounts: TgdKeyArray read FAccounts;
    property CorrAccounts: TgdKeyArray read FCorrAccounts;
    property FieldInfos: TgdvFieldInfos read FFieldInfos write FFieldInfos;

    property DateBegin: TDate read FDateBegin write FDateBegin;
    property DateEnd: TDate read FDateEnd write FDateEnd;
    property MakeEmpty: Boolean read FMakeEmpty write FMakeEmpty;
    property CompanyKey: TID read FCompanyKey write SetCompanyKey;
    property CompanyName: String read GetCompanyName;
    property AllHolding: Boolean read FAllHolding write SetAllHolding;
    property WithSubAccounts: Boolean read FWithSubAccounts write FWithSubAccounts;
    property IncludeInternalMovement: Boolean read FIncludeInternalMovement write FIncludeInternalMovement;
    property ShowExtendedFields: Boolean read FShowExtendedFields write FShowExtendedFields;
    property UseEntryBalance: Boolean read FUseEntryBalance write SetUseEntryBalance;

  published
    { TIBCustomDataSet }
    property BufferChunks;
    property CachedUpdates;
    property DeleteSQL;
    property InsertSQL;
    property RefreshSQL;
    property SelectSQL;
    property ModifySQL;
    property ParamCheck;
    property UniDirectional;
    property Filtered;
    property GeneratorField;
    property BeforeDatabaseDisconnect;
    property AfterDatabaseDisconnect;
    property DatabaseFree;
    property BeforeTransactionEnd;
    property AfterTransactionEnd;
    property TransactionFree;
    property UpdateObject;
    ///!!!!b
    property OnCalcAggregates;
    //!!!!e
    { TIBDataSet }
    property Active;
    property AutoCalcFields;
    property DataSource read GetDataSource write SetDataSource;

    property AfterCancel;
    property AfterClose;
    property AfterDelete;
    property AfterEdit;
    property AfterInsert;
    property AfterOpen;
    property AfterPost;
    property AfterScroll;
    property BeforeCancel;
    property BeforeClose;
    property BeforeDelete;
    property BeforeEdit;
    property BeforeInsert;
    property BeforeOpen;
    property BeforePost;
    property BeforeScroll;
    property OnCalcFields;
    property OnDeleteError;
    property OnEditError;
    property OnFilterRecord;
    property OnNewRecord;
    property OnPostError;

    //andreik!
    property ReadTransaction;
  end;

const
  cMaxSQLLength = 256 * 256 - 1;

  BaseAcctFieldCount = 18;
  BaseAcctQuantityFieldCount = 6;
  baNCU_Debit_Index = 0;
  baNCU_Credit_Index = 1;
  baCurr_Debit_Index = 6;
  baCurr_Credit_Index = 7;

  cNCUPrefix = 'NCU';
  cCURRPrefix = 'CURR';
  cEQPrefix = 'EQ';

  BaseAcctFieldList: array[0 .. BaseAcctFieldCount - 1] of TgdvFieldInfoRec =(
    (FieldName: 'NCU_DEBIT'; Caption: 'Оборот Д'; DisplayFieldName: ''),
    (FieldName: 'NCU_CREDIT'; Caption: 'Оборот К'; DisplayFieldName: ''),
    (FieldName: 'NCU_BEGIN_DEBIT'; Caption: 'Сальдо НД'; DisplayFieldName: ''),
    (FieldName: 'NCU_BEGIN_CREDIT'; Caption: 'Сальдо НК'; DisplayFieldName: ''),
    (FieldName: 'NCU_END_DEBIT'; Caption: 'Сальдо КД'; DisplayFieldName: ''),
    (FieldName: 'NCU_END_CREDIT'; Caption: 'Сальдо КК'; DisplayFieldName: ''),

    (FieldName: 'CURR_DEBIT'; Caption: 'Оборот Д, вал'; DisplayFieldName: 'NCU_DEBIT'),
    (FieldName: 'CURR_CREDIT'; Caption: 'Оборот К, вал'; DisplayFieldName: 'NCU_CREDIT'),
    (FieldName: 'CURR_BEGIN_DEBIT'; Caption: 'Сальдо НД, вал'; DisplayFieldName: 'NCU_BEGIN_DEBIT'),
    (FieldName: 'CURR_BEGIN_CREDIT'; Caption: 'Сальдо НК, вал'; DisplayFieldName: 'NCU_BEGIN_CREDIT'),
    (FieldName: 'CURR_END_DEBIT'; Caption: 'Сальдо КД, вал'; DisplayFieldName: 'NCU_END_DEBIT'),
    (FieldName: 'CURR_END_CREDIT'; Caption: 'Сальдо КК, вал'; DisplayFieldName: 'NCU_END_CREDIT'),

    (FieldName: 'EQ_DEBIT'; Caption: 'Оборот Д, экв'; DisplayFieldName: 'NCU_DEBIT'),
    (FieldName: 'EQ_CREDIT'; Caption: 'Оборот К, экв'; DisplayFieldName: 'NCU_CREDIT'),
    (FieldName: 'EQ_BEGIN_DEBIT'; Caption: 'Сальдо НД, экв'; DisplayFieldName: 'NCU_BEGIN_DEBIT'),
    (FieldName: 'EQ_BEGIN_CREDIT'; Caption: 'Сальдо НК, экв'; DisplayFieldName: 'NCU_BEGIN_CREDIT'),
    (FieldName: 'EQ_END_DEBIT'; Caption: 'Сальдо КД, экв'; DisplayFieldName: 'NCU_END_DEBIT'),
    (FieldName: 'EQ_END_CREDIT'; Caption: 'Сальдо КК, экв'; DisplayFieldName: 'NCU_END_CREDIT')
    );

  BaseAcctQuantityFieldList: array[0 .. BaseAcctQuantityFieldCount - 1] of TgdvQuantityFieldInfoRec =(
    (FieldName: 'Q_D_%s'; Caption: 'Оборот Д, %s'; DisplayFieldName: '%s_DEBIT'),
    (FieldName: 'Q_C_%s'; Caption: 'Оборот К, %s'; DisplayFieldName: '%s_CREDIT'),
    (FieldName: 'Q_B_D_%s'; Caption: 'Сальдо НД, %s'; DisplayFieldName: '%s_BEGIN_DEBIT'),
    (FieldName: 'Q_B_C_%s'; Caption: 'Сальдо НК, %s'; DisplayFieldName: '%s_BEGIN_CREDIT'),
    (FieldName: 'Q_E_D_%s'; Caption: 'Сальдо КД, %s'; DisplayFieldName: '%s_END_DEBIT'),
    (FieldName: 'Q_E_C_%s'; Caption: 'Сальдо КК, %s'; DisplayFieldName: '%s_END_CREDIT')
    );

procedure Register;

implementation

uses
  Sysutils, Dialogs, IB, gd_security, AcctStrings, IBBlob, gd_common_functions,
  Forms, dmImages_unit, gdcConstants, gd_security_operationconst, IBHeader,
  gdcCurr, flt_frmSQLEditorSyn_unit;

type
  EgsLargeSQLStatement = class(Exception);

const
  cQuantityDisplayFormat = '### ##0.##';

procedure Register;
begin
  RegisterComponents('gdv', [TgdvAcctBase]);
end;

{ TgdvAcctBase }

constructor TgdvAcctBase.Create(AOwner: TComponent);
begin
  inherited;

  FUseEntryBalanceWasSetManually := False;

  FMakeEmpty := False;
  FDateBegin := Date;
  FDateEnd := Date;
  Self.SetDefaultParams;

  // Для возможности редактировать и добавлять записи в объекте
  Self.CachedUpdates := True;
  Self.InsertSQL.Text := 'INSERT INTO AC_LEDGER_ACCOUNTS (ACCOUNTKEY) VALUES (-1)';
  Self.ModifySQL.Text := 'UPDATE AC_LEDGER_ACCOUNTS SET ACCOUNTKEY = -1';

  FAccounts := TgdKeyArray.Create;
  FCorrAccounts := TgdKeyArray.Create;
  FAcctConditions := TStringList.Create;
  FAcctValues := TStringList.Create;
end;

destructor TgdvAcctBase.Destroy;
begin
  FAccounts.Free;
  FCorrAccounts.Free;
  FAcctConditions.Free;
  FAcctValues.Free;

  FNameAliasList.Free;
  FKeyAliasList.Free;

  inherited;
end;

procedure TgdvAcctBase.SetSQLParams;
begin
  Self.ParamByName(BeginDate).AsDateTime := FDateBegin;
  Self.ParamByName(EndDate).AsDateTime := FDateEnd;
end;

procedure TgdvAcctBase.DoBuildSQL;
begin
  DoEmptySQL;
end;

procedure TgdvAcctBase.Clear;
begin
  SetDefaultParams;

  FAccounts.Clear;
  FCorrAccounts.Clear;
  FAcctValues.Clear;
  FAcctConditions.Clear;

  if Assigned(FKeyAliasList) then
    FKeyAliasList.Clear;
  if Assigned(FNameAliasList) then
    FNameAliasList.Clear;
end;

procedure TgdvAcctBase.DoAfterBuildSQL;
begin
  // в дебаге не будем сжимать запрос (путем удаления пробелов и отступов)
  {$IFNDEF DEBUG}
  PackSQL(Self.SelectSQL);
  {$ENDIF}
  if Length(Self.SelectSQL.Text) > cMaxSQLLength then
    raise EgsLargeSQLStatement.Create(LargeSQLErrorMessage);

  // Подставим необходимые параметры в запрос
  if not FMakeEmpty then
  begin
    try
      SetSQLParams;
    except
      on E: EIBError do
      begin
        if (IBLogin <> nil) and IBLogin.IsIBUserAdmin then
        begin
          MessageBox(0,
            PChar(E.Message),
            'Ошибка',
            MB_OK or MB_ICONHAND or MB_TASKMODAL);

          with TfrmSQLEditorSyn.Create(nil) do
          try
            ShowSQL(Self.SelectSQL.Text, nil, True);
          finally
            Free;
          end;
        end;

        raise;
      end;
    end;
  end;
end;

procedure TgdvAcctBase.DoBeforeBuildReport;
begin
  // получим дату последнего расчета данных в таблице AC_ENTRY_BALANCE
  FEntryBalanceDate := GetCalculatedBalanceDate;
  if (not FUseEntryBalanceWasSetManually) and (FEntryBalanceDate <> 0) then
    FUseEntryBalance := True;

  if FUseEntryBalance then
  begin
    // новые отчеты будут строится только на FB2.0+, после добавления модифаем необходимых метаданных
    if not (Assigned(atDatabase.Relations.ByRelationName('AC_ENTRY_BALANCE'))
       and Self.Database.IsFirebirdConnect and (Self.Database.ServerMajorVersion >= 2)) then
      FUseEntryBalance := False;
  end;

  // При выборе количественных показателей будем строить старым методом
  if FUseEntryBalance and (FAcctValues.Count > 0) then
    FUseEntryBalance := False;

  if FWithSubAccounts then
    FillSubAccounts(FAccounts);

  if Self.Active then
    Self.Close;
end;

procedure TgdvAcctBase.DoEmptySQL;
var
  I: Integer;
  SQLText: String;
begin
  SQLText := '';

  for I := 0 to BaseAcctFieldCount - 1 do
  begin
    if SQLText > '' then
      SQLText := SQLText + ', '#13#10;
    SQLText := SQLText + Format('CAST(NULL AS NUMERIC(15, 4)) AS %s', [BaseAcctFieldList[I].FieldName]);
  end;
  SQLText := 'SELECT ' + SQLText + ', CAST(NULL AS VARCHAR(180)) AS NAME FROM rdb$database WHERE RDB$CHARACTER_SET_NAME = ''_''';

  Self.SelectSQL.Text := SQLText;
end;

procedure TgdvAcctBase.Execute(ConfigID: TID);
begin
  FConfigKey := ConfigID;
  LoadConfig(ConfigID);
  BuildReport;
end;

procedure TgdvAcctBase.BuildReport;
begin
  DoBeforeBuildReport;
  if FMakeEmpty then
    DoEmptySQL      // сформируем запрос на пустой отчет
  else
    DoBuildSQL;     // сформируем нормальный запрос
  try
    DoAfterBuildSQL;
  except
    on E: EgsLargeSQLStatement do
    begin
      DoEmptySQL;
      Application.MessageBox(PChar(E.Message), 'Внимание!', MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
    end;
  end;
  Self.Open;
  DoAfterBuildReport;
end;

procedure TgdvAcctBase.ExtendedFields(Field: TatRelationField;
  Alias: string; var Select, Group: string; UseTemplate: Boolean;
  Template: string);
var
  R: TatRelation;
  E: TStrings;
  I: Integer;
  F: TatRelationField;
  FI: TgdvFieldInfo;
begin
  if FShowExtendedFields then
  begin
    if (Field <> nil) and (Field.ReferencesField <> nil) then
    begin
      R := Field.ReferencesField.Relation;
      if R.ExtendedFields > '' then
      begin
        E := TStringList.Create;
        try
          E.Text := StringReplace(R.ExtendedFields, ';', #13#10, [rfReplaceAll]);
          E.Text := StringReplace(R.ExtendedFields, ',', #13#10, [rfReplaceAll]);
          for I := 0 to E.Count - 1 do
          begin
            E[I] := Trim(E[I]);
            F := R.RelationFields.ByFieldName(E[I]);
            if F <> nil then
            begin
              if Select > '' then Select := Select + ', '#13#10;
              if not UseTemplate then
              begin
                Select := Select + Format('%0:s.%1:s AS %0:s_%1:s', [Alias, F.FieldName]);
                // Заполним информацию о поле
                if Assigned(FFieldInfos) then
                begin
                  FI := FFieldInfos.AddInfo;
                  FI.FieldName := Format('%s_%s', [Alias, F.FieldName]);
                  FI.Caption := F.LName;
                  FI.Visible := fvVisible;
                  FI.Condition := True;
                end;

                if Group > '' then Group := Group + ', '#13#10;
                Group := Group + Format('%s.%s', [Alias, F.FieldName]);
              end
              else
                Select := Select + Format('CAST(%s AS %s)', [Template, DomainName(F.Field)]);
            end;
          end;
        finally
          E.Free
        end;
      end;
    end;
  end
end;

procedure TgdvAcctBase.ExtendedFieldsBalance(Field: TatrelationField;
  Alias: string; var Returns, Select, Into: string);
var
  R: TatRelation;
  E: TStrings;
  I: Integer;
  F: TatRelationField;
  FI: TgdvFieldInfo;
begin
  if FShowExtendedFields then
  begin
    if (Field <> nil) and (Field.ReferencesField <> nil) then
    begin
      R := Field.ReferencesField.Relation;
      if R.ExtendedFields > '' then
      begin
        E := TStringList.Create;
        try
          E.Text := StringReplace(R.ExtendedFields, ';', #13#10, [rfReplaceAll]);
          E.Text := StringReplace(R.ExtendedFields, ',', #13#10, [rfReplaceAll]);
          for I := 0 to E.Count - 1 do
          begin
            E[I] := Trim(E[I]);
            F := R.RelationFields.ByFieldName(E[I]);
            if F <> nil then
            begin
              // Заполним информацию о поле
              if Assigned(FFieldInfos) then
              begin
                FI := FFieldInfos.AddInfo;
                FI.FieldName := Format('%s_%s', [Alias, F.FieldName]);
                FI.Caption := F.LName;
                FI.Visible := fvVisible;
                FI.Condition := True;
              end;

              if Returns > '' then
                Returns := Returns + ', '#13#10;
              Returns := Returns + Format('%s_%s VARCHAR(180)', [Alias, F.FieldName]);
              if Select > '' then
                Select := Select + ', '#13#10;
              Select := Select + Format('%s.%s', [Alias, F.FieldName]);
              if Into > '' then
                Into := Into + ', '#13#10;
              Into := Into + ':' + Format('%s_%s', [Alias, F.FieldName]);
            end;
          end;
        finally
          E.Free
        end;
      end;
    end;
  end
end;

function TgdvAcctBase.InternalMovementClause(TableAlias: String = 'e'): string;
var
  I: Integer;
  F: TatRelationField;
  InternalMovementWhereClause: string;
begin
  Result := '';
  // Если установлен флаг 'Включать внутренние проводки'
  if not FIncludeInternalMovement then
  begin
    InternalMovementWhereClause := '';

    // Использовать новый метод построения бух. отчетов
    if FUseEntryBalance then
    begin
      for I := 0 to FAcctConditions.Count  - 1 do
      begin
        F := atDatabase.FindRelationField(AC_ENTRY, FAcctConditions.Names[I]);
        if Assigned(F) and (F.FieldName <> EntryDate) then
        begin
          // Если тип INTEGER
          if F.SQLType in [blr_short, blr_long, blr_int64] then
            InternalMovementWhereClause := InternalMovementWhereClause +
              Format(' AND'#13#10' %0:s.%1:s = e_cm.%1:s + 0 ', [TableAlias, F.FieldName])
          else
            InternalMovementWhereClause := InternalMovementWhereClause +
              Format(' AND'#13#10' %0:s.%1:s = e_cm.%1:s ', [TableAlias, F.FieldName]);
        end;
      end;

      Result := Format(cInternalMovementClauseTemplateNew,
        [TableAlias, InternalMovementWhereClause]);
    end
    else
    begin
      for I := 0 to FAcctConditions.Count - 1 do
      begin
        F := atDatabase.FindRelationField(AC_ENTRY, FAcctConditions.Names[I]);
        if Assigned(F) and (F.FieldName <> EntryDate) then
        begin
          // Если тип INTEGER
          if F.SQLType in [blr_short, blr_long, blr_int64] then
            InternalMovementWhereClause := InternalMovementWhereClause +
              Format(' AND'#13#10' e_m.%0:s = e_cm.%0:s + 0 ', [F.FieldName])
          else
            InternalMovementWhereClause := InternalMovementWhereClause +
              Format(' AND'#13#10' e_m.%0:s = e_cm.%0:s ', [F.FieldName]);
        end;
      end;

      Result := Format(cInternalMovementClauseTemplate, [InternalMovementWhereClause]);
    end;
  end;
end;

procedure TgdvAcctBase.LoadConfig(AID: TID);
var
  ibsql: TIBSQL;
  bs: TIBBlobStream;
  C: TBaseAcctConfigClass;
  Config: TBaseAcctConfig;
  CName: string;
begin
  if AID > -1 then
  begin
    ibsql := TIBSQl.Create(nil);
    try
      ibsql.Transaction := gdcBaseManager.ReadTransaction;
      ibsql.SQL.Text := 'SELECT config FROM ac_acct_config WHERE id = :id';
      ibsql.ParamByName('id').AsInteger := AID;
      ibsql.ExecQuery;
      if ibsql.RecordCount > 0 then
      begin
        bs := TIBBlobStream.Create;
        try
          bs.Mode := bmRead;
          bs.Database := ibsql.Database;
          bs.Transaction := ibsql.Transaction;
          bs.BlobID := ibsql.FieldByName('config').AsQuad;
          // Смотрим класс конфигурации
          CName := ReadStringFromStream(bs);
          TPersistentClass(C) := GetClass(CName);
          if Assigned(C) then
          begin
            Config := C.Create;
            try
              try
                Config.LoadFromStream(bs);
                DoLoadConfig(Config);
              except
                on E: Exception do
                begin
                  Application.ShowException(E);
                  MessageBox(0,
                    'Возникла ошибка при считывании конфигурации бухгалтерского отчета.'#13#10 +
                    'Пожалуйста, пересохраните конфигурацию.',
                    'Ошибка',
                    MB_OK or MB_ICONHAND or MB_TASKMODAL);
                end;
              end;
            finally
              Config.Free;
            end;
          end;
        finally
          bs.Free;
        end;
      end;
    finally
      ibsql.Free;
    end;
  end;
end;

function TgdvAcctBase.SaveConfig(const AConfigKey: TID = -1): TID;
var
  Str: TMemoryStream;
  SQL: TIBSQL;
  C: TBaseAcctConfigClass;
  Config: TBaseAcctConfig;
  DidActivate: Boolean;
begin
  Result := -1;

  Str := TMemoryStream.Create;
  try
    // Сохраним настройки объекта в поток
    TPersistentClass(C) := GetClass(ConfigClassName);
    if Assigned(C) then
    begin
      Config := C.Create;
      try
        SaveStringToStream(ConfigClassName, Str);
        DoSaveConfig(Config);
        Config.SaveToStream(Str);
      finally
        Config.Free;
      end;

      // Сохраним полученный поток в базу
      if Str.Size > 0 then
      begin
        Str.Position := 0;
        SQL := TIBSQL.Create(nil);
        try
          SQL.Transaction := Transaction;
          DidActivate := not Transaction.InTransaction;
          if DidActivate then
            Transaction.StartTransaction;
          try

            // если нам передали ключ существующей конфигурации, то обновим ее данные,
            //   иначе создадим новую
            if AConfigKey > -1 then
            begin
              SQL.SQL.Text := 'UPDATE ac_acct_config SET config = :config WHERE id = :id';
              SQL.ParamByName(fnId).AsInteger := AConfigKey;
              FConfigKey := AConfigKey;
            end
            else
            begin
              FConfigKey := gdcBaseManager.GetNextID;

              SQL.SQL.Text := 'INSERT INTO ac_acct_config (id, name, config, ' +
                'imageindex, folder, showinexplorer, classname) VALUES (:id, ' +
                ' :name, :config, :imageindex, :folder, :showinexplorer, :classname)';
              SQL.ParamByName(fnImageIndex).AsInteger := iiGreenCircle;
              SQL.ParamByName(fnFolder).AsInteger := AC_ACCOUNTANCY;
              SQL.ParamByName(fnShowInExplorer).AsInteger := 0;
              SQL.ParamByName(fnClassName).AsString := ConfigClassName;
              SQL.ParamByName(fnId).AsInteger := FConfigKey;
              SQL.ParamByName(fnName).AsString := 'Конфигурация ' + IntToStr(FConfigKey);
            end;

            SQL.ParamByName(fnConfig).LoadFromStream(Str);
            SQL.ExecQuery;

            Result := FConfigKey;

            Transaction.Commit;
            if not DidActivate then
              Transaction.StartTransaction;
          except
            Transaction.Rollback;
            raise;  
          end;
        finally
          SQL.Free;
        end;
      end;
    end;  
  finally
    Str.Free;
  end;
end;

procedure TgdvAcctBase.DoLoadConfig(const Config: TBaseAcctConfig);
var
  StringList: TStringList;
  I: Integer;
begin
  Self.Clear;

  StringList := TStringList.Create;
  try
    with Config do
    begin
      // загрузка счетов
      StringList.Text := AccountsRUIDList;
      for I := 0 to StringList.Count - 1 do
        AddAccount(gdcBaseManager.GetIDByRUIDString(Trim(StringList.Strings[I])));
      StringList.Clear;
      StringList.Text := Quantity;
      for I := 0 to StringList.Count - 1 do
        AddValue(gdcBaseManager.GetIDByRUIDString(Trim(StringList.Strings[I])));
      StringList.Clear;
      StringList.Text := Analytics;
      for I := 0 to StringList.Count - 1 do
        AddCondition(Trim(StringList.Names[I]), StringList.Values[Trim(StringList.Names[I])]);

      FWithSubAccounts := IncSubAccounts;
      FIncludeInternalMovement := IncludeInternalMovement;
      FShowExtendedFields := ExtendedFields;

      // настройки вывода сумм
      FNcuSumInfo.Show := InNcu;
      FNcuSumInfo.DecDigits := NcuDecDigits;
      FNcuSumInfo.Scale := NcuScale;

      FCurrSumInfo.Show := InCurr;
      FCurrSumInfo.DecDigits := CurrDecDigits;
      FCurrSumInfo.Scale := CurrScale;
      FCurrkey := CurrKey;

      FEQSumInfo.Show := InEQ;
      FEQSumInfo.DecDigits := EQDecDigits;
      FEQSumInfo.Scale := EQScale;

      FQuantitySumInfo.DecDigits := QuantityDecDigits;
      FQuantitySumInfo.Scale := QuantityScale;

      if CompanyKey > 0 then
      begin
        FCompanyKey := CompanyKey;
        FAllHolding := AllHoldingCompanies;
      end else
      begin
        FCompanyKey := IbLogin.CompanyKey;
        FAllHolding := IbLogin.IsHolding;
      end;
    end;
  finally
    StringList.Free;
  end;
end;

procedure TgdvAcctBase.DoSaveConfig(Config: TBaseAcctConfig);
var
  StringList: TStringList;
  I: Integer;
begin
  Assert(Config <> nil);
  
  StringList := TStringList.Create;
  try
    for I := 0 to FAccounts.Count - 1 do
      StringList.Add(gdcBasemanager.GetRUIDStringByID(FAccounts.Keys[I]));
    Config.AccountsRUIDList := StringList.Text;
    StringList.Clear;
    for I := 0 to FAcctValues.Count - 1 do
      StringList.Add(FAcctValues.Names[I]);
    Config.Quantity := StringList.Text;
  finally
    StringList.Free;
  end;
  Config.Analytics := FAcctConditions.Text;

  Config.IncSubAccounts := FWithSubAccounts;
  Config.IncludeInternalMovement := FIncludeInternalMovement;
  Config.ExtendedFields := FShowExtendedFields;

  Config.InNcu := FNcuSumInfo.Show;
  Config.NcuDecDigits := FNcuSumInfo.DecDigits;
  Config.NcuScale := FNcuSumInfo.Scale;

  Config.InCurr := FCurrSumInfo.Show;
  Config.CurrDecDigits := FCurrSumInfo.DecDigits;
  Config.CurrScale := FCurrSumInfo.Scale;
  Config.CurrKey := FCurrkey;

  Config.InEQ := FEQSumInfo.Show;
  Config.EQDecDigits := FEQSumInfo.DecDigits;
  Config.EQScale := FEQSumInfo.Scale;

  Config.QuantityDecDigits := FQuantitySumInfo.DecDigits;
  Config.QuantityScale := FQuantitySumInfo.Scale;

  Config.CompanyKey := FCompanyKey;
  Config.AllHoldingCompanies := FAllHolding;
end;

procedure TgdvAcctBase.ShowInNCU(Show: Boolean; DecDigits: Integer = -1; Scale: Integer = 0);
begin
  FNcuSumInfo.Show := Show;
  if DecDigits > -1 then
    FNcuSumInfo.DecDigits := DecDigits;
  if Scale > 0 then
    FNcuSumInfo.Scale := Scale;
end;

procedure TgdvAcctBase.ShowInCurr(Show: Boolean; DecDigits: Integer = -1; Scale: Integer = 0;
  CurrKey: TID = -1);
begin
  FCurrSumInfo.Show := Show;
  if DecDigits > -1 then
    FCurrSumInfo.DecDigits := DecDigits;
  if Scale > 0 then
    FCurrSumInfo.Scale := Scale;
  FCurrKey := CurrKey;  
end;

procedure TgdvAcctBase.ShowInEQ(Show: Boolean; DecDigits: Integer = -1; Scale: Integer = 0);
begin
  FEQSumInfo.Show := Show;
  if DecDigits > -1 then
    FEQSumInfo.DecDigits := DecDigits;
  if Scale > 0 then
    FEQSumInfo.Scale := Scale;
end;

procedure TgdvAcctBase.ShowInQuantity(DecDigits, Scale: Integer);
begin
  if DecDigits > -1 then
    FQuantitySumInfo.DecDigits := DecDigits;
  if Scale > 0 then
    FQuantitySumInfo.Scale := Scale;
end;

procedure TgdvAcctBase.AddAccount(AccountKey: TID);
begin
  if FAccounts.IndexOf(AccountKey) = -1 then
    FAccounts.Add(AccountKey);
end;

procedure TgdvAcctBase.AddCorrAccount(AccountKey: TID);
begin
  if FCorrAccounts.IndexOf(AccountKey) = -1 then
    FCorrAccounts.Add(AccountKey);
end;

procedure TgdvAcctBase.AddCondition(FieldName: String; AValue: String);
begin
  if FieldName <> '' then
    FAcctConditions.Add(FieldName + ' = ' + AValue);
end;

procedure TgdvAcctBase.SetCompanyKey(const Value: TID);
begin
  FCompanyKey := Value;
  FillCompanyList;
end;

procedure TgdvAcctBase.SetAllHolding(const Value: Boolean);
begin
  FAllHolding := Value;
  FillCompanyList;
end;

procedure TgdvAcctBase.AddValue(ValueKey: TID; ValueName: String = '');
var
  ibsql: TIBSQL;
begin
  if FAcctValues.IndexOfName(IntToStr(ValueKey)) = -1 then
  begin
    if ValueName <> '' then
    begin
      FAcctValues.Add(IntToStr(ValueKey) + '=' + ValueName);
    end
    else
    begin
      ibsql := TIBSQL.Create(nil);
      try
        ibsql.Transaction := gdcBaseManager.ReadTransaction;
        ibsql.SQL.Text := 'SELECT name FROM gd_value WHERE id = :id';
        ibsql.ParamByName('ID').AsInteger := ValueKey;
        ibsql.ExecQuery;
        if ibsql.RecordCount > 0 then
          FAcctValues.Add(IntToStr(ValueKey) + '=' + ibsql.FieldByName('NAME').AsString)
        else
          FAcctValues.Add(IntToStr(ValueKey));
      finally
        ibsql.Free;
      end;
    end;
  end;
end;

function TgdvAcctBase.DomainName(Field: TatField): String;
begin
  Result := '';
  if Field <> nil then
  begin
    case Field.SQLType of
      14: Result := Format('CHAR(%d)', [Field.FieldLength]);
      37: Result := Format('VARCHAR(%d)', [Field.FieldLength]);
      12: Result := 'DATE';
      13: Result := 'TIME';
      35: Result := 'TIMESTAMP';
      7: Result := 'SMALLINT';
      8: Result := 'INTEGER';
      11: Result := 'D_FLOAT';
      10: Result := 'FLOAT';
      27, 16, 9: Result := Format('NUMERIC(18, %d)', [Field.FieldScale]);
    end;
  end;
end;

function TgdvAcctBase.GetKeyAlias(ID: String): String;
var
  Index: Integer;
begin
  if not Assigned(FKeyAliasList) then
    FKeyAliasList := TStringList.Create;

  Index := FKeyAliasList.IndexOf(ID);
  if Index = - 1 then
    Index := FKeyAliasList.Add(ID);
  Result := IntToStr(Index);
end;

function TgdvAcctBase.GetKeyAlias(ID: Integer): String;
begin
  Result := Self.GetKeyAlias(IntToStr(ID));
end;

function TgdvAcctBase.GetNameAlias(Name: String): String;
var
  Index: Integer;
begin
  if not Assigned(FNameAliasList) then
    FNameAliasList := TStringList.Create;

  Index := FNameAliasList.IndexOf(UpperCase(Name));
  if Index = - 1 then
    Index := FNameAliasList.Add(Name);

  Result := Format('Field_%d', [Index]);
end;

procedure TgdvAcctBase.FillCompanyList;
var
  ibsql: TIBSQL;
begin
  if FAllHolding and Assigned(IBLogin) then
  begin
    if (FCompanyKey > -1) and (FCompanyKey <> IBLogin.CompanyKey) then
    begin
      ibsql := TIBSQL.Create(nil);
      try
        ibsql.Transaction := gdcBaseManager.ReadTransaction;
        ibsql.SQL.Text := 'SELECT companykey FROM gd_holding WHERE holdingkey = :holdingkey';
        ibsql.ParamByName('holdingkey').AsInteger := FCompanyKey;
        ibsql.ExecQuery;

        FCompanyList := IntToStr(FCompanyKey);
        while not ibsql.Eof do
        begin
          FCompanyList := FCompanyList + ',' + ibsql.FieldByName('companykey').AsString;
          ibsql.Next;
        end;
      finally
        ibsql.Free;
      end;
    end
    else
      FCompanyList := IBLogin.HoldingList;
  end
  else
  begin
    FCompanyList := IntToStr(FCompanyKey);
  end;
end;

function TgdvAcctBase.GetCondition(Alias: String): String;
var
  I: Integer;
begin
  Result := '';
  if Alias <> '' then
  begin
    for I := 0 to FAcctConditions.Count - 1 do
    begin
      if Result > '' then
        Result := Result + ' AND '#13#10;
      if Trim(FAcctConditions.Values[FAcctConditions.Names[I]]) <> '' then
        Result := Result + Format('%s.%s IN(%s)', [Alias, FAcctConditions.Names[I], FAcctConditions.Values[FAcctConditions.Names[I]]])
      else
        Result := Result + Alias + '.' + FAcctConditions.Names[I] + ' IS NULL ';
    end;
  end;
end;

procedure TgdvAcctBase.SetDefaultParams;
var
  DefaultDecDigits: Integer;
begin
  FConfigKey := -1;

  if Assigned(IBLogin) then
  begin
    FCompanyKey := IBLogin.CompanyKey;
    FillCompanyList;
  end else
    FCompanyKey := -1;

  FAllHolding := True;

  FWithSubAccounts := False;
  FIncludeInternalMovement := False;
  FShowExtendedFields := False;

  // настройки вывода сумм
  DefaultDecDigits := LocateDecDigits;
  with FNcuSumInfo do
  begin
    Show := True;
    DecDigits := DefaultDecDigits;
    Scale := 1;
  end;
  with FCurrSumInfo do
  begin
    Show := False;
    DecDigits := DefaultDecDigits;
    Scale := 1;
  end;
  with FEQSumInfo do
  begin
    Show := False;
    DecDigits := DefaultDecDigits;
    Scale := 1;
  end;
  with FQuantitySumInfo do
  begin
    DecDigits := DefaultDecDigits;
    Scale := 1;
  end;
  FCurrKey := -1;
  FNCUCurrKey := AcctUtils.GetNCUKey;
end;

procedure TgdvAcctBase.DoAfterBuildReport;
begin

end;

function TgdvAcctBase.LargeSQLErrorMessage: String;
begin
  Result := MSG_LARGESQL;
end;

function TgdvAcctBase.ParamByName(Idx: String): TIBXSQLVAR;
begin
  InternalPrepare;
  Result := QSelect.ParamByName(Idx);
end;

procedure TgdvAcctBase.SetUseEntryBalance(const Value: Boolean);
begin
  FUseEntryBalance := Value;
  FUseEntryBalanceWasSetManually := True;
end;

procedure TgdvAcctBase.FillSubAccounts(var AccountArray: TgdKeyArray);
var
  ibsql: TIBSQL;
begin
  if AccountArray.Count > 0 then
  begin
    ibsql := TIBSQL.Create(nil);
    try
      ibsql.Transaction := gdcBaseManager.ReadTransaction;
      ibsql.SQL.Text := Format(
        ' SELECT a2.id FROM ac_account a1, ac_account a2 WHERE a1.id in(%s) and ' +
        ' a2.lb >= a1.lb and a2.rb <= a1.rb and a2.ACCOUNTTYPE in (''A'', ''S'')',
        [IDList(AccountArray)]);
      ibsql.ExecQuery;
      AccountArray.Clear;
      while not ibsql.Eof do
      begin
        if AccountArray.IndexOf(ibsql.Fields[0].AsInteger) = -1 then
          AccountArray.Add(ibsql.Fields[0].AsInteger);
        ibsql.Next;
      end;
    finally
      ibsql.Free;
    end;
  end;
end;

class function TgdvAcctBase.ConfigClassName: string;
begin
  Result := 'TBaseAcctConfigClass';
end;

{$IFNDEF DEBUG}
procedure TgdvAcctBase.PackSQL(const S: TStrings);
var
  I, J: Integer;
  LastSymbol: Char;
  Str: string;
const
  Symbols = ['(', ')', ',', ' ', #13, #10, '<', '>', '=', '-', '+', '''', '/', '*'];
begin
  for I := S.Count - 1 downto 0 do
  begin
    S[I] := Trim(S[I]);
    if S[I] = '' then
      S.Delete(I)
    else
    begin
      LastSymbol := #0;
      for J := Length(S[I]) downto 1 do
      begin
        if (S[I][J] = ' ') and (LastSymbol in Symbols) then
        begin
          Str := S[I];
          System.Delete(Str, J, 1);
          S[I] := Str;
        end else
          LastSymbol := S[I][J];
      end;

      J := 1;
      while J < Length(S[I]) do
      begin
        if (S[I][J] = ' ') and (LastSymbol in Symbols) then
        begin
          Str := S[I];
          System.Delete(Str, J, 1);
          S[I] := Str;
        end else
        begin
          LastSymbol := S[I][J];
          Inc(J);
        end;
      end;
    end;
  end;
end;
{$ENDIF}

function TgdvAcctBase.GetCompanyName: String;
var
  q: TIBSQL;
begin
  Assert(gdcBaseManager <> nil);

  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;

    q.SQL.Text :=
      'SELECT ' +
      '  LIST(s.name) ' +
      'FROM ' +
      '  (SELECT c.name ' +
      '   FROM gd_contact c JOIN gd_holding h ' +
      '     ON h.companykey = c.id ' +
      '   WHERE h.holdingkey = :HK ' +
      ' ' +
      '   UNION ' +
      ' ' +
      '   SELECT c.name ' +
      '   FROM gd_contact c ' +
      '   WHERE c.id = :CK) s';
    if AllHolding then
      q.ParamByName('HK').AsInteger := CompanyKey
    else
      q.ParamByName('HK').AsInteger := -1;
    q.ParamByName('CK').AsInteger := CompanyKey;
    q.ExecQuery;
    Result := q.Fields[0].AsString;
  finally
    q.Free;
  end;
end;

{ TgdvFieldInfo }

procedure TgdvFieldInfo.SetDisplayFormat(const Value: string);
begin
  FDisplayFormat := Value;
end;

procedure TgdvFieldInfo.SetFieldName(const Value: string);
begin
  FFieldName := UpperCase(Value);
end;

procedure TgdvFieldInfo.SetCaption(const Value: string);
begin
  FCaption := Value;
end;

procedure TgdvFieldInfo.SetVisible(const Value: TgdvFieldVisible);
begin
  FVisible := Value;
end;

function TgdvFieldInfo.GetDistlayFields: TStrings;
begin
  if FDisplayFields = nil then
    FDisplayFields := TStringList.Create;
  Result := FDisplayFields;
end;

destructor TgdvFieldInfo.Destroy;
begin
  FDisplayFields.Free;
end;

procedure TgdvFieldInfo.SetCondition(const Value: boolean);
begin
  FCondition := Value;
end;

procedure TgdvFieldInfo.SetTotal(const Value: Boolean);
begin
  FTotal := Value;
end;

procedure TgdvFieldInfo.SetAnalytic(const Value: Boolean);
begin
  FAnalytic := Value;
end;

procedure TgdvFieldInfo.SetValueFieldName(const Value: String);
begin
  FValueFieldName := Value;
end;

{ TgdvFieldInfos }

function TgdvFieldInfos.AddInfo: TgdvFieldInfo;
begin
  Result := TgdvFieldInfo.Create;
  Add(Result);
end;

function TgdvFieldInfos.AddInfo(C: TgdvFieldInfoClass): TgdvFieldInfo;
begin
  Result := C.Create;
  Add(Result);
end;

function TgdvFieldInfos.FindInfo(FieldName: string): TgdvFieldInfo;
var
  Index: Integer;
begin
  Result := nil;
  Index := IndexByFieldName(FieldName);
  if Index > - 1 then
    Result := Items[Index];
end;

function TgdvFieldInfos.GetItems(Index: Integer): TgdvFieldInfo;
begin
  Result := TgdvFieldInfo(inherited Items[Index]);
end;

function TgdvFieldInfos.IndexByFieldName(FieldName: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
  begin
    if FieldName = Items[I].FieldName then
    begin
      Result := I;
      Break;
    end;
  end;
end;

end.
