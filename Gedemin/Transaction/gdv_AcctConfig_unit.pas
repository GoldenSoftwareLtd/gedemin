unit gdv_AcctConfig_unit;

interface

uses
  classes, gd_common_functions, Sysutils, AcctUtils, IBSQL, gdcBaseInterface,
  gdcConstants;

type
  TAbstractConfig = class(TPersistent)
  public
    procedure SaveToStream(const Stream: TStream);virtual; abstract;
    procedure LoadFromStream(const Stream: TStream);virtual; abstract;
  end;

  TBaseAcctConfigClass = class of TBaseAcctConfig;
  TBaseAcctConfig = class(TAbstractConfig)
  private
    FIncSubAccounts: boolean;
    FIncludeInternalMovement: boolean;
    FAccounts: string;
    FInCurr: boolean;
    FInNcu: boolean;
    FCurrDecDigits: Integer;
    FNcuDecDigits: Integer;
    FCurrScale: Integer;
    FCurrKey: Integer;
    FNcuScale: Integer;
    FQuantity: string;
    FAnalytics: string;
    FExtendedFields: boolean;
    FAllHoldingCompanies: Boolean;
    FCompanyKey: Integer;
    FStreamVersion: Integer;
    FGridSettings: TStream;
    FInEQ: boolean;
    FEQDecDigits: Integer;
    FEQScale: Integer;
    FQuantityDecDigits: Integer;
    FQuantityScale: Integer;

    procedure SetAccounts(const Value: string);
    procedure SetIncludeInternalMovement(const Value: boolean);
    procedure SetIncSubAccounts(const Value: boolean);
    procedure SetCurrDecDigits(const Value: Integer);
    procedure SetCurrKey(const Value: Integer);
    procedure SetCurrScale(const Value: Integer);
    procedure SetInCurr(const Value: boolean);
    procedure SetInNcu(const Value: boolean);
    procedure SetNcuDecDigits(const Value: Integer);
    procedure SetNcuScale(const Value: Integer);
    procedure SetAnalytics(const Value: string);
    procedure SetQuantity(const Value: string);
    procedure SetExtendedFields(const Value: boolean);
    function GetAccounts: string;
    procedure SetAllHoldingCompanies(const Value: Boolean);
    procedure SetCompanyKey(const Value: Integer);
    function GetGridSettings: TStream;
    procedure SetEQDecDigits(const Value: Integer);
    procedure SetEQScale(const Value: Integer);
    procedure SetInEQ(const Value: boolean);
    procedure SetQuantityDecDigits(const Value: Integer);
    procedure SetQuantityScale(const Value: Integer);
  protected
    procedure Reset; virtual;
    procedure ResetSize; virtual;
    procedure CopyToStream(Source, Dest: TStream);
    procedure CopyFromStream(Source, Dest: TStream);

    function _GetAccounts(RUIDList: string): string;
    procedure _SetAccounts(const Value: string; var RUIDList: string);
  public
    constructor Create;
    destructor Destroy; override;
    procedure SaveToStream(const Stream: TStream); override;
    procedure LoadFromStream(const Stream: TStream); override;
    class function EditDialogName: string;virtual;

    property Accounts: string read GetAccounts write SetAccounts;
    property AccountsRUIDList: string read FAccounts write FAccounts;
    property IncSubAccounts: boolean read FIncSubAccounts write SetIncSubAccounts;
    property IncludeInternalMovement: boolean read FIncludeInternalMovement write SetIncludeInternalMovement;

    property InNcu: boolean read FInNcu write SetInNcu;
    property NcuDecDigits: Integer read FNcuDecDigits write SetNcuDecDigits;
    property NcuScale: Integer read FNcuScale write SetNcuScale;
    property InCurr: boolean read FInCurr write SetInCurr;
    property CurrDecDigits: Integer read FCurrDecDigits write SetCurrDecDigits;
    property CurrScale: Integer read FCurrScale write SetCurrScale;
    property CurrKey: Integer read FCurrKey write SetCurrKey;

    property InEQ: boolean read FInEQ write SetInEQ;
    property EQDecDigits: Integer read FEQDecDigits write SetEQDecDigits;
    property EQScale: Integer read FEQScale write SetEQScale;

    property QuantityDecDigits: Integer read FQuantityDecDigits write SetQuantityDecDigits;
    property QuantityScale: Integer read FQuantityScale write SetQuantityScale;

    property Quantity: string read FQuantity write SetQuantity;
    property Analytics: string read FAnalytics write SetAnalytics;
    property ExtendedFields: boolean read FExtendedFields write SetExtendedFields;

    property CompanyKey: Integer read FCompanyKey write SetCompanyKey;
    property AllHoldingCompanies: Boolean read FAllHoldingCompanies write SetAllHoldingCompanies;
    property GridSettings: TStream read GetGridSettings;
  end;

  TAccReviewConfig = class(TBaseAcctConfig)
  private
    FShowCorrSubAccounts: boolean;
    FCorrAccounts: string;
    FAccountPart: string;

    procedure SetAccountPart(const Value: string);
    procedure SetCorrAccounts(const Value: string);
    function GetCorrAccounts: string;
    procedure SetShowCorrSubAccounts(const Value: boolean);
  public
    class function EditDialogName: string;override;
    procedure SaveToStream(const Stream: TStream); override;
    procedure LoadFromStream(const Stream: TStream); override;

    property ShowCorrSubAccounts: boolean read FShowCorrSubAccounts write SetShowCorrSubAccounts;
    property CorrAccounts: string read GetCorrAccounts write SetCorrAccounts;
    property CorrAccountsRUIDList: string read FCorrAccounts write FCorrAccounts;
    property AccountPart: string read FAccountPart write SetAccountPart;
  end;

  TAccCardConfig = class(TBaseAcctConfig)
  private
    FIncCorrSubAccounts: Boolean;
    FAccountPart: string;
    FCorrAccounts: string;
    FGroup: Boolean;
    procedure SetAccountPart(const Value: string);
    procedure SetCorrAccounts(const Value: string);
    procedure SetIncCorrSubAccounts(const Value: Boolean);
    procedure SetGroup(const Value: Boolean);
    function GetCorrAccounts: string;
  public
    procedure SaveToStream(const Stream: TStream); override;
    procedure LoadFromStream(const Stream: TStream); override;
    class function EditDialogName: string;override;

    property CorrAccounts: string read GetCorrAccounts write SetCorrAccounts;
    property CorrAccountsRUIDList: string read FCorrAccounts write FCorrAccounts;
    property AccountPart: string read FAccountPart write SetAccountPart;
    property IncCorrSubAccounts: Boolean read FIncCorrSubAccounts write SetIncCorrSubAccounts;
    property Group: Boolean read FGroup write SetGroup;
  end;

  TAccLedgerConfig = class(TBaseAcctConfig)
  private
    FShowDebit: Boolean;
    FShowCredit: Boolean;
    FShowCorrSubAccounts: boolean;
    FAnalyticsGroup: TStream;
    FAnalyticListField: String;
    FSumNull: Boolean;
    FEnchancedSaldo: Boolean;
    FTreeAnalytic: string;
    procedure SetShowCorrSubAccounts(const Value: boolean);
    procedure SetShowCredit(const Value: Boolean);
    procedure SetShowDebit(const Value: Boolean);
    function GetAnalyticsGroup: TStream;
    procedure SetEnchancedSaldo(const Value: Boolean);
    procedure SetSumNull(const Value: Boolean);
    procedure SetTreeAnalytic(const Value: string);
  protected
    procedure Reset; override;
    procedure ResetSize; override;
  public
    destructor Destroy; override;
    procedure SaveToStream(const Stream: TStream); override;
    procedure LoadFromStream(const Stream: TStream); override;
    class function EditDialogName: string;override;

    property ShowDebit: Boolean read FShowDebit write SetShowDebit;
    property ShowCredit: Boolean read FShowCredit write SetShowCredit;
    property ShowCorrSubAccounts: boolean read FShowCorrSubAccounts write SetShowCorrSubAccounts;
    property AnalyticsGroup: TStream read GetAnalyticsGroup;
    property AnalyticListField: String read FAnalyticListField write FAnalyticListField;
    property SumNull: Boolean read FSumNull write SetSumNull;
    property EnchancedSaldo: Boolean read FEnchancedSaldo write SetEnchancedSaldo;
    property TreeAnalytic: string read FTreeAnalytic write SetTreeAnalytic;
  end;

  TAccCirculationListConfig = class(TBaseAcctConfig)
  private
    FShowDebit: Boolean;
    FShowCredit: Boolean;
    FShowCorrSubAccounts: boolean;
    FDisplaceSaldo: boolean;
    FSubAccountsInMain: boolean;
    procedure SetShowCorrSubAccounts(const Value: boolean);
    procedure SetShowCredit(const Value: Boolean);
    procedure SetShowDebit(const Value: Boolean);
    procedure SetDisplaceSaldo(const Value: boolean);
    procedure SetSubAccountsInMain(const Value: boolean);
  public
    procedure SaveToStream(const Stream: TStream); override;
    procedure LoadFromStream(const Stream: TStream); override;
    class function EditDialogName: string;override;

    property ShowDebit: Boolean read FShowDebit write SetShowDebit;
    property ShowCredit: Boolean read FShowCredit write SetShowCredit;
    property ShowCorrSubAccounts: boolean read FShowCorrSubAccounts write SetShowCorrSubAccounts;
    property SubAccountsInMain: boolean read FSubAccountsInMain write SetSubAccountsInMain;
    property DisplaceSaldo: boolean read FDisplaceSaldo write SetDisplaceSaldo;
  end;

  TAccGeneralLedgerConfig = class(TAccCirculationListConfig)
  public
    class function EditDialogName: string;override;
  end;

function LoadConfigFromStream(Str: TStream): TBaseAcctConfig;
function LoadConfigById(Id: Integer): TBaseAcctConfig;
procedure SaveConfigToStream(const Config: TBaseAcctConfig; const Stream: TStream);

implementation

const
  StreamVersion = 10;

procedure SaveConfigToStream(const Config: TBaseAcctConfig; const Stream: TStream);
begin
  SaveStringToStream(Config.ClassName, Stream);
  Config.SaveToStream(Stream);
end;

function LoadConfigById(Id: Integer): TBaseAcctConfig;
var
  SQL: TIBSQL;
  Str: TStream;
begin
  Result := nil;
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcBaseManager.ReadTransaction;
    SQL.SQL.text := 'SELECT * FROM ac_acct_config WHERE id = :id';
    SQL.ParamByName(fnId).AsInteger := id;
    SQL.ExecQuery;

    if SQL.RecordCount > 0 then
    begin
      Str := TMemoryStream.Create;
      try
        SQL.FieldByName(fnConfig).SaveToStream(Str);

        Str.Position := 0;
        Result := LoadConfigFromStream(Str);
      finally
        Str.Free;
      end;
    end else
      raise Exception.Create(Format('Не найдена конфигурация с ИД: %d', [id]))
  finally
    SQl.Free;
  end;
end;

function LoadConfigFromStream(Str: TStream): TBaseAcctConfig;
var
  C: TBaseAcctConfigClass;
  CName: string;
begin
  Result := nil;
  CName := ReadStringFromStream(Str);
  TPersistentClass(C) := GetClass(CName);
  if C <> nil then
  begin
    Result := C.Create;
    Result.LoadFromStream(Str);
  end;
end;
{ TBaseAcctConfig }

procedure TBaseAcctConfig.CopyFromStream(Source, Dest: TStream);
var
  S: Longint;
begin
  Dest.Size := 0;
  Source.Read(S, SizeOf(S));
  if S > 0 then
  begin
    Dest.CopyFrom(Source, S);
  end;
end;

procedure TBaseAcctConfig.CopyToStream(Source, Dest: TStream);
var
  S: Longint;
begin
  S := Source.Size;
  Dest.Write(S, SizeOf(Source.Size));
  if S > 0 then
  begin
    Source.Position := 0;
    Dest.CopyFrom(Source, S);
  end;
end;

destructor TBaseAcctConfig.Destroy;
begin
  inherited;
  FGridSettings.Free;
end;

class function TBaseAcctConfig.EditDialogName: string;
begin
  Result := 'TdlgBaseAcctConfig';
end;

function TBaseAcctConfig.GetAccounts: string;
begin
  Result := _GetAccounts(FAccounts);
end;

function TBaseAcctConfig._GetAccounts(RUIDList: string): string;
var
  S: TStrings;
  I: Integer;
begin
  try
    S := TStringList.Create;
    try
      S.Text := RUIDList;
      Result := '';
      for I := 0 to S.Count - 1 do
      begin
        if Result > '' then Result := Result + ', ';
        Result := Result + GetAliasByRUIDString(Trim(S[I]));
      end;
    finally
      S.Free;
    end;
  except
    Result := '';
  end;
end;

procedure TBaseAcctConfig.LoadFromStream(const Stream: TStream);
var
  Size: Integer;
begin
  ResetSize;
  Stream.Read(FStreamVersion, SizeOf(FStreamVersion));
  if FStreamVersion >= 0 then
  begin
    FAccounts := ReadStringFromStream(Stream);
    Stream.Read(FIncSubAccounts, SizeOf(FIncSubAccounts));
    Stream.Read(FIncludeInternalMovement, SizeOf(FIncludeInternalMovement));

    FInNcu := ReadBooleanFromStream(Stream);
    FNcuDecDigits := ReadIntegerFromStream(Stream);
    FNcuScale := ReadIntegerFromStream(Stream);

    FInCurr := ReadBooleanFromStream(Stream);
    FCurrDecDigits := ReadIntegerFromStream(Stream);
    FCurrScale := ReadIntegerFromStream(Stream);
    FCurrKey := ReadIntegerFromStream(Stream);

    if FStreamVersion > 6 then begin
      FInEQ := ReadBooleanFromStream(Stream);
      FEQDecDigits := ReadIntegerFromStream(Stream);
      FEQScale := ReadIntegerFromStream(Stream);
    END;

    FQuantity := ReadStringFromStream(Stream);
    FAnalytics := ReadStringFromStream(Stream);

    if FStreamVersion >= 1 then
    begin
      FExtendedFields := ReadBooleanFromStream(Stream);

      if FStreamVersion >= 2 then
      begin
        FCompanyKey := ReadIntegerFromStream(Stream);
        FAllHoldingCompanies := ReadBooleanFromStream(Stream);
      end;
    end;
  end;
  if FStreamVersion >= 4 then
  begin
    Size := ReadIntegerFromStream(Stream);
    if Size > 0 then
    begin
      GridSettings.CopyFrom(Stream, Size);
      GridSettings.Position := 0;
    end;
  end;
  if FStreamVersion > 5 then
  begin
    FInEQ := ReadBooleanFromStream(Stream);
    FEQDecDigits := ReadIntegerFromStream(Stream);
    FEQScale := ReadIntegerFromStream(Stream);
  end;

  if FStreamVersion >= 10 then
  begin
    FQuantityDecDigits := ReadIntegerFromStream(Stream);
    FQuantityScale := ReadIntegerFromStream(Stream);
  end;
end;

procedure TBaseAcctConfig.Reset;
begin
//  Analytics.Position := 0;
//  Company.Position := 0;
//  Quantity.Position := 0;
//  Sum.Position := 0;
end;

procedure TBaseAcctConfig.ResetSize;
begin
//  Analytics.Size := 0;
//  Company.Size := 0;
//  Quantity.Size := 0;
//  Sum.Size := 0;
end;

procedure TBaseAcctConfig.SaveToStream(const Stream: TStream);
var
  SV: Integer;
begin
  SV := StreamVersion;
  Stream.Write(SV, SizeOf(SV));
  SaveStringToStream(FAccounts, Stream);
  Stream.Write(FIncSubAccounts, SizeOf(FIncSubAccounts));
  Stream.Write(FIncludeInternalMovement, SizeOf(FIncludeInternalMovement));

  SaveBooleanToStream(FInNcu, Stream);
  SaveIntegerToStream(FNcuDecDigits, Stream);
  SaveIntegerToStream(FNcuScale, Stream);

  SaveBooleanToStream(FInCurr, Stream);
  SaveIntegerToStream(FCurrDecDigits, Stream);
  SaveIntegerToStream(FCurrScale, Stream);
  SaveIntegerToStream(FCurrKey, Stream);

  SaveBooleanToStream(FInEQ, Stream);
  SaveIntegerToStream(FEQDecDigits, Stream);
  SaveIntegerToStream(FEQScale, Stream);

  SaveStringToStream(FQuantity, Stream);
  SaveStringToStream(FAnalytics, Stream);
  SaveBooleanToStream(FExtendedFields, Stream);

  SaveIntegerToStream(FCompanyKey, Stream);
  SaveBooleanToStream(FAllHoldingCompanies, Stream);

  SaveIntegerToStream(GridSettings.Size, Stream);
  if GridSettings.Size > 0 then
  begin
    GridSettings.Position := 0;
    Stream.CopyFrom(GridSettings, GridSettings.Size);
  end;

  SaveBooleanToStream(FInEQ, Stream);
  SaveIntegerToStream(FEQDecDigits, Stream);
  SaveIntegerToStream(FEQScale, Stream);

  SaveIntegerToStream(FQuantityDecDigits, Stream);
  SaveIntegerToStream(FQuantityScale, Stream);
end;

procedure TBaseAcctConfig.SetAccounts(const Value: string);
begin
  _SetAccounts(Value, FAccounts);
end;

procedure TBaseAcctConfig._SetAccounts(const Value: string; var RUIDList: string);
var
  S: TStrings;
  I: Integer;
begin
  S := TStringList.Create;
  try
    S.Text := StringReplace(Value, ',', #13#10, [rfReplaceAll, rfIgnoreCase]);
    for I := 0 to S.Count - 1 do
    begin
      try
        S[I] := GetAccountRUIDStringByAlias(Trim(S[I]));
      except
      end;
    end;
    RUIDList := S.Text;
  finally
    S.Free;
  end;
end;

procedure TBaseAcctConfig.SetAnalytics(const Value: string);
begin
  FAnalytics := Value;
end;

procedure TBaseAcctConfig.SetCurrDecDigits(const Value: Integer);
begin
  FCurrDecDigits := Value;
end;

procedure TBaseAcctConfig.SetCurrKey(const Value: Integer);
begin
  FCurrKey := Value;
end;

procedure TBaseAcctConfig.SetCurrScale(const Value: Integer);
begin
  FCurrScale := Value;
end;

procedure TBaseAcctConfig.SetExtendedFields(const Value: boolean);
begin
  FExtendedFields := Value;
end;

procedure TBaseAcctConfig.SetIncludeInternalMovement(const Value: boolean);
begin
  FIncludeInternalMovement := Value;
end;

procedure TBaseAcctConfig.SetIncSubAccounts(const Value: boolean);
begin
  FIncSubAccounts := Value;
end;

procedure TBaseAcctConfig.SetInCurr(const Value: boolean);
begin
  FInCurr := Value;
end;

procedure TBaseAcctConfig.SetInNcu(const Value: boolean);
begin
  FInNcu := Value;
end;

procedure TBaseAcctConfig.SetNcuDecDigits(const Value: Integer);
begin
  FNcuDecDigits := Value;
end;

procedure TBaseAcctConfig.SetNcuScale(const Value: Integer);
begin
  FNcuScale := Value;
end;

procedure TBaseAcctConfig.SetQuantity(const Value: string);
begin
  FQuantity := Value;
end;
constructor TBaseAcctConfig.Create;
begin
  FInNcu := True;
  FNcuDecDigits := 2;
  FNcuScale := 1;
end;

procedure TBaseAcctConfig.SetAllHoldingCompanies(const Value: Boolean);
begin
  FAllHoldingCompanies := Value;
end;

procedure TBaseAcctConfig.SetCompanyKey(const Value: Integer);
begin
  FCompanyKey := Value;
end;

function TBaseAcctConfig.GetGridSettings: TStream;
begin
  if FGridSettings = nil then
    FGridSettings := TMemoryStream.Create;

  Result := FGridSettings;  
end;

procedure TBaseAcctConfig.SetEQDecDigits(const Value: Integer);
begin
  FEQDecDigits := Value;
end;

procedure TBaseAcctConfig.SetEQScale(const Value: Integer);
begin
  FEQScale := Value;
end;

procedure TBaseAcctConfig.SetInEQ(const Value: boolean);
begin
  FInEQ := Value;
end;

procedure TBaseAcctConfig.SetQuantityDecDigits(const Value: Integer);
begin
  FQuantityDecDigits := Value;
end;

procedure TBaseAcctConfig.SetQuantityScale(const Value: Integer);
begin
  FQuantityScale := Value;
end;

{ TAccCardConfig }

class function TAccCardConfig.EditDialogName: string;
begin
  Result := 'TdlgAcctAccCardConfig';
end;

function TAccCardConfig.GetCorrAccounts: string;
begin
  Result := _GetAccounts(FCorrAccounts);
end;

procedure TAccCardConfig.LoadFromStream(const Stream: TStream);
begin
  inherited;

  FCorrAccounts := ReadStringFromStream(Stream);
  FAccountPart := ReadStringFromStream(Stream);
  FIncCorrSubAccounts := ReadBooleanFromStream(Stream);
  FGroup := ReadBooleanFromStream(Stream);
end;

procedure TAccCardConfig.SaveToStream(const Stream: TStream);
begin
  inherited;

  SaveStringToStream(FCorrAccounts, Stream);
  SaveStringToStream(FAccountPart, Stream);
  SaveBooleanToStream(FIncCorrSubAccounts, Stream);
  SaveBooleanToStream(FGroup, Stream);
end;

procedure TAccCardConfig.SetAccountPart(const Value: string);
begin
  FAccountPart := Value;
end;

procedure TAccCardConfig.SetCorrAccounts(const Value: string);
begin
  _SetAccounts(Value, FCorrAccounts);
end;

procedure TAccCardConfig.SetGroup(const Value: Boolean);
begin
  FGroup := Value;
end;

procedure TAccCardConfig.SetIncCorrSubAccounts(const Value: Boolean);
begin
  FIncCorrSubAccounts := Value;
end;

{ TAccLedger }

destructor TAccLedgerConfig.Destroy;
begin
  inherited;
  if Assigned(FAnalyticsGroup) then
    FreeAndNil(FAnalyticsGroup);
end;

class function TAccLedgerConfig.EditDialogName: string;
begin
  Result := 'TdlgAcctLedgerConfig';
end;

function TAccLedgerConfig.GetAnalyticsGroup: TStream;
begin
  if FAnalyticsGroup = nil then
    FAnalyticsGroup := TMemoryStream.Create;
  Result := FAnalyticsGroup;
end;

procedure TAccLedgerConfig.LoadFromStream(const Stream: TStream);
begin
  inherited;
  FShowDebit := ReadBooleanFromStream(Stream);
  FShowCredit := ReadBooleanFromStream(Stream);
  FShowCorrSubAccounts := ReadBooleanFromStream(Stream);
  CopyFromStream(Stream, AnalyticsGroup);
  if FStreamVersion >= 3 then
  begin
    FSumNull := ReadBooleanFromStream(Stream);
    FEnchancedSaldo := ReadBooleanFromStream(Stream);
  end;

  if FStreamVersion >= 5 then
    FTreeAnalytic := ReadStringFromStream(Stream);

  if FStreamVersion >= 9 then
    AnalyticListField := ReadStringFromStream(Stream);
end;

procedure TAccLedgerConfig.Reset;
begin
  inherited;
  AnalyticsGroup.Position := 0;
end;

procedure TAccLedgerConfig.ResetSize;
begin
  inherited;
  AnalyticsGroup.Size := 0;
end;

procedure TAccLedgerConfig.SaveToStream(const Stream: TStream);
begin
  inherited;
  SaveBooleanToStream(FShowDebit, Stream);
  SaveBooleanToStream(FShowCredit, Stream);
  SaveBooleanToStream(FShowCorrSubAccounts, Stream);
  CopyToStream(AnalyticsGroup, Stream);
  SaveBooleanToStream(FSumNull, Stream);
  saveBooleanToStream(FEnchancedSaldo, Stream);
  SaveStringToStream(FTreeAnalytic, Stream);
  SaveStringToStream(FAnalyticListField, Stream);
end;

procedure TAccLedgerConfig.SetEnchancedSaldo(const Value: Boolean);
begin
  FEnchancedSaldo := Value;
end;

procedure TAccLedgerConfig.SetShowCorrSubAccounts(const Value: boolean);
begin
  FShowCorrSubAccounts := Value;
end;

procedure TAccLedgerConfig.SetShowCredit(const Value: Boolean);
begin
  FShowCredit := Value;
end;

procedure TAccLedgerConfig.SetShowDebit(const Value: Boolean);
begin
  FShowDebit := Value;
end;

procedure TAccLedgerConfig.SetSumNull(const Value: Boolean);
begin
  FSumNull := Value;
end;

{ TAccCirculationListConfig }

class function TAccCirculationListConfig.EditDialogName: string;
begin
  Result := 'TdlgAcctCirculationList';
end;

procedure TAccCirculationListConfig.LoadFromStream(const Stream: TStream);
begin
  inherited;
  FShowDebit := ReadBooleanFromStream(Stream);
  FShowCredit := ReadBooleanFromStream(Stream);
  FShowCorrSubAccounts := ReadBooleanFromStream(Stream);
  if FStreamVersion > 7 then begin
    FSubAccountsInMain:= ReadBooleanFromStream(Stream);
    FDisplaceSaldo:= ReadBooleanFromStream(Stream);
  end;
end;

procedure TAccCirculationListConfig.SaveToStream(const Stream: TStream);
begin
  inherited;
  SaveBooleanToStream(FShowDebit, Stream);
  SaveBooleanToStream(FShowCredit, Stream);
  SaveBooleanToStream(FShowCorrSubAccounts, Stream);
  SaveBooleanToStream(FSubAccountsInMain, Stream);
  SaveBooleanToStream(FDisplaceSaldo, Stream);
end;

procedure TAccCirculationListConfig.SetDisplaceSaldo(const Value: boolean);
begin
  FDisplaceSaldo := Value;
end;

procedure TAccCirculationListConfig.SetShowCorrSubAccounts(
  const Value: boolean);
begin
  FShowCorrSubAccounts := Value;
end;

procedure TAccCirculationListConfig.SetShowCredit(const Value: Boolean);
begin
  FShowCredit := Value;
end;

procedure TAccCirculationListConfig.SetShowDebit(const Value: Boolean);
begin
  FShowDebit := Value;
end;

procedure TAccLedgerConfig.SetTreeAnalytic(const Value: string);
begin
  FTreeAnalytic := Value;
end;

procedure TAccCirculationListConfig.SetSubAccountsInMain(
  const Value: boolean);
begin
  FSubAccountsInMain := Value;
end;

{ TAccGeneralLedgerConfig }

class function TAccGeneralLedgerConfig.EditDialogName: string;
begin
  Result := 'TdlgAcctGeneralLedger';
end;

{ TAccReviewConfig }

class function TAccReviewConfig.EditDialogName: string;
begin
  Result := 'TdlgAcctReviewConfig';
end;

function TAccReviewConfig.GetCorrAccounts: string;
begin
  Result := _GetAccounts(FCorrAccounts);
end;

procedure TAccReviewConfig.LoadFromStream(const Stream: TStream);
begin
  inherited;

  FShowCorrSubAccounts := ReadBooleanFromStream(Stream);
  FCorrAccounts := ReadStringFromStream(Stream);
  FAccountPart := ReadStringFromStream(Stream);
end;

procedure TAccReviewConfig.SaveToStream(const Stream: TStream);
begin
  inherited;

  SaveBooleanToStream(FShowCorrSubAccounts, Stream);
  SaveStringToStream(FCorrAccounts, Stream);
  SaveStringToStream(FAccountPart, Stream);
end;

procedure TAccReviewConfig.SetAccountPart(const Value: string);
begin
  FAccountPart := Value;
end;

procedure TAccReviewConfig.SetCorrAccounts(const Value: string);
begin
  _SetAccounts(Value, FCorrAccounts);
end;

procedure TAccReviewConfig.SetShowCorrSubAccounts(const Value: boolean);
begin
  FShowCorrSubAccounts := Value;
end;

initialization
  RegisterClasses([TBaseAcctConfig, TAccCardConfig, TAccLedgerConfig,
    TAccCirculationListConfig, TAccGeneralLedgerConfig, TAccReviewConfig]);
finalization
  UnRegisterClasses([TBaseAcctConfig, TAccCardConfig, TAccLedgerConfig,
    TAccCirculationListConfig, TAccGeneralLedgerConfig, TAccReviewConfig]);
end.

