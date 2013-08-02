unit gsTRPOS_TLVClient;

interface

uses
  Windows, Classes, SysUtils, IdTCPClient, IdGlobal;

type
  TgsTRPOSOutPutData = class(TObject)
  public
    MessageID: AnsiString;
    ECRnumber: Cardinal;
    ERN: Cardinal;
    ResponseCode: AnsiString;
    TransactionAmount: AnsiString;
    Pan: AnsiString;
    ExpDate: AnsiString;
    Approve: AnsiString;
    Receipt: AnsiString;
    InvoiceNumber: AnsiString;
    AuthorizationID: AnsiString;
    Date: AnsiString;
    Time: AnsiString;
    VerificationChr: AnsiString;
    RRN: AnsiString;
    TVR: AnsiString;
    TerminalID: AnsiString;
    CardDataEnc: AnsiString;

    procedure Clear;
  end;

  TgsTRPOSParamData = class(TObject)
  private
    FTrack1Data: String;
    FTrack2Data: String;
    FTrack3Data: String;
    FPan: String;
    FExpDate: String;
    FInvoiceNumber: Integer;
    FAuthorizationID: Integer;
    FMerchantID: Integer;
    FRRN: String;
    FCardDataEnc: String;
  public 
    property Track1Data: String read FTrack1Data write FTrack1Data;
    property Track2Data: String read FTrack2Data write FTrack2Data;
    property Track3Data: String read FTrack3Data write FTrack3Data;
    property Pan: String read FPan write FPan;
    property ExpDate: String read FExpDate write FExpDate;
    property InvoiceNumber: Integer read FInvoiceNumber write FInvoiceNumber default -1;
    property AuthorizationID: Integer read FAuthorizationID write FAuthorizationID default -1;
    property MerchantID: Integer read FMerchantID write FMerchantID default -1;
    property RRN: String read FRRN write FRRN;
    property CardDataEnc: String read FCardDataEnc write FCardDataEnc;
  end;


  TgsTRPOSClient = class(TObject)
  private
    FTCPClient: TIdTCPClient;
    FHost: String;
    FPort: Integer;
    FReadTimeOut: Integer;

    function GetParamString(ATag: Cardinal; ALen: Integer;
      const AValue: String; const AFixedLen: Boolean = True): String; overload;
    function GetParamString(AParam: TgsTRPOSParamData): String; overload;
    function GetConnected: Boolean;

    function GetTrack1Data(const AData: String): String;
    function GetTrack2Data(const AData: String): String;
    function GetTrack3Data(const AData: String): String;
    function GetPan(const AData: String): String;
    function GetExpDate(const AData: String): String;
    function GetInvoiceNumber(const ANumber: Integer): String;
    function GetMessageID(const AMessage: String): String;
    function GetECRnumber(const ANumber: Cardinal): String;
    function GetERN(const ANumber: Cardinal): String;
    function GetCurrencyCode(const ANumber: Integer): String;
    function GetTransactionAmount(const ASumm: Currency): String;
    function GetSubFunction(const AID: Cardinal): String;
    function GetTag(const AStr: String; var I: Integer): Cardinal;
    function GetLen(const AStr: String; var I: Integer): Cardinal;
    procedure GetData(const AStr: String; AParams: TgsTRPOSOutPutData);
    procedure InternalMessages(const ATag: String; ATrNumber: Cardinal;
      ACashNumber: Cardinal; const ASumm: Currency = -1; const ACurrCode: Integer = -1;
      const AParam: TgsTRPOSParamData = nil);
    procedure SetHost(const AValue: String);
    procedure SetPort(const AValue: Integer);
    procedure WriteBuffer(const ABuffer: String);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadData(AParams: TgsTRPOSOutPutData);
    procedure Connect;
    procedure Disconnect;
    procedure Payment(ASumm: Currency; ATrNumber: Cardinal;
      ACashNumber: Cardinal; const ACurrCode: Integer = -1;
      const APreAUT: Boolean = False; const AParam: TgsTRPOSParamData = nil);
    procedure Cash(ASumm: Currency; ATrNumber: Cardinal;
      ACashNumber: Cardinal; const ACurrCode: Integer = -1;
      const AParam: TgsTRPOSParamData = nil);
    procedure Replenishment(ASumm: Currency; ATrNumber: Cardinal;
      ACashNumber: Cardinal; const ACurrCode: Integer = -1;
      const AParam: TgsTRPOSParamData = nil);
    procedure Cancel(ASumm: Currency; ATrNumber: Cardinal;
      ACashNumber: Cardinal; const ACurrCode: Integer = -1;
      const AParam: TgsTRPOSParamData = nil);
    procedure Return(ASumm: Currency; ATrNumber: Cardinal;
      ACashNumber: Cardinal; const ACurrCode: Integer = -1;
      const AParam: TgsTRPOSParamData = nil);
    procedure ReadJournal(ATrNumber: Cardinal; ACashNumber: Cardinal;
      const AParam: TgsTRPOSParamData = nil);  
    procedure PreAuthorize(ASumm: Currency; ATrNumber: Cardinal;
      ACashNumber: Cardinal; const ACurrCode: Integer = -1;
      const AParam: TgsTRPOSParamData = nil);
    procedure Balance(ATrNumber: Cardinal; ACashNumber: Cardinal;
      const AParam: TgsTRPOSParamData = nil);
    procedure ResetLockJournal(ATrNumber: Cardinal; ACashNumber: Cardinal;
      const AParam: TgsTRPOSParamData = nil);
    procedure Calculation(ATrNumber: Cardinal; ACashNumber: Cardinal;
      const AParam: TgsTRPOSParamData = nil);
    procedure Ping(ATrNumber: Cardinal; ACashNumber: Cardinal;
      const AParam: TgsTRPOSParamData = nil);
    procedure ReadCard(ATrNumber: Cardinal; ACashNumber: Cardinal;
      const AParam: TgsTRPOSParamData = nil);
    procedure ReconciliationResults(ATrNumber: Cardinal; ACashNumber: Cardinal);
    procedure TestPinPad(ATrNumber: Cardinal; ACashNumber: Cardinal);
    procedure TestHost(ATrNumber: Cardinal; ACashNumber: Cardinal);
    procedure Duplicate(ATrNumber: Cardinal; ACashNumber: Cardinal);
    procedure JRNClean(ATrNumber: Cardinal; ACashNumber: Cardinal);
    procedure RVRClean(ATrNumber: Cardinal; ACashNumber: Cardinal);
    procedure FullClean(ATrNumber: Cardinal; ACashNumber: Cardinal);
    procedure MenuPrintReport(ATrNumber: Cardinal; ACashNumber: Cardinal);
    procedure DSortByDate(ATrNumber: Cardinal; ACashNumber: Cardinal);
    procedure DSortByIssuer(ATrNumber: Cardinal; ACashNumber: Cardinal);
    procedure SSortByDate(ATrNumber: Cardinal; ACashNumber: Cardinal);
    procedure RePrint(ATrNumber: Cardinal; ACashNumber: Cardinal);

    property Host: String read FHost write SetHost;
    property Port: Integer read FPort write SetPort;
    property ReadTimeOut: Integer read FReadTimeOut write FReadTimeOut default IdTimeoutDefault;
    property Connected: Boolean read GetConnected;
  end;

  EgsTRPOSClient = class(Exception);

implementation

type
  TInputTag = (IT_MessageID, IT_ECRnumber, IT_ERN, IT_Currency, IT_TransactionAmount,
    IT_SRVsubfunction, IT_Track1Data, IT_Track2Data, IT_Track3Data, IT_Pan,
    IT_ExpDate, IT_InvoiceNumber);

const 
  TagValue: array [TInputTag] of Cardinal = ($01, $02, $03, $1B, $04, $1A, $05,
    $06, $07, $09, $0A, $0B);
  TagLength: array [TInputTag] of Integer = ($03, $02, $0A, $03, $0C, $01, $4C,
    $25, $6B, $13, $04, $06);

  OT_MessageID         = $81;
  OT_ECRnumber         = $82;
  OT_ERN               = $83;
  OT_ResponseCode      = $9B;
  OT_TransactionAmount = $84;
  OT_PAN               = $89;
  OT_ExpDate           = $8A;
  OT_InvoiceNumber     = $8B;
  OT_AuthorizationID   = $8C;
  OT_Approve           = $A1;
  OT_Receipt           = $9C;
  OT_Date              = $8D;
  OT_Time              = $8E;
  OT_VerificationChr   = $94;
  OT_RRN               = $98;
  OT_TVR               = $95;
  OT_TerminalID        = $9D;
  OT_CardDataEnc       = $C0;
  

  OM_Payment           = 'PUR';
  OM_Cancel            = 'VOI';
  OM_SRVOperation      = 'SRV';
  OM_Return            = 'REF';
  OM_Journal           = 'JRN';
  OM_PreAuthorize      = 'AUT';
  OM_PMNPreAuthorize   = 'AUH';
  OM_Balance           = 'BAL';
  OM_ResetLockJRN      = 'CLR';
  OM_Calculation       = 'CMP';
  OM_Ping              = 'PNG';
  OM_ReadCard          = 'VER';
  OM_Cash              = 'CSH';
  OM_Replenishment     = 'CRE';

  SRV_RevResult        = $02;
  SRV_TestPinpad       = $03;
  SRV_TestHost         = $04;
  SRV_Duplicate        = $05;
  SRV_JRNClean         = $09;
  SRV_RVRClean         = $0A;
  SRV_FullClean        = $0B;
  SRV_MenuPrintReport  = $0C;
  SRV_DSortByDate      = $0D;
  SRV_DSortByIssuer    = $0E;
  SRV_SSortByDate      = $0F;
  SRV_RePrint          = $10;


function IsBitSet(Value: Cardinal; BitNum: Byte): Boolean;
begin
  Result:=((Value shr BitNum) and 1) = 1;
end;

function BitOff(const Val: Longint; const TheBit: Byte): LongInt;
begin
  Result := Val and ((1 shl TheBit) xor $FFFFFFFF);
end;

function String2Hex(const Buffer: String): String;
begin
  SetLength(Result, 2 * Length(Buffer));
  BinToHex(@Buffer[1], @Result[1], Length(Buffer));
end;

constructor TgsTRPOSClient.Create;
begin
  inherited Create;
  FTCPClient := TIdTCPClient.Create(nil);
end;

destructor TgsTRPOSClient.Destroy;
begin
  Disconnect;
  FTCPClient.Free;
  inherited;
end;

procedure TgsTRPOSClient.ReconciliationResults(ATrNumber: Cardinal; ACashNumber: Cardinal);
begin
  WriteBuffer(GetMessageID(OM_SRVOperation) +
    GetECRnumber(ACashNumber) +
    GetSubFunction(SRV_RevResult) +
    GetERN(ATrNumber));
end;

procedure TgsTRPOSClient.TestPinPad(ATrNumber: Cardinal; ACashNumber: Cardinal);
begin
  WriteBuffer(GetMessageID(OM_SRVOperation) +
    GetECRnumber(ACashNumber) +
    GetSubFunction(SRV_TestPinpad) +
    GetERN(ATrNumber));
end;

procedure TgsTRPOSClient.TestHost(ATrNumber: Cardinal; ACashNumber: Cardinal);
begin
  WriteBuffer(GetMessageID(OM_SRVOperation) +
    GetECRnumber(ACashNumber) +
    GetSubFunction(SRV_TestHost) +
    GetERN(ATrNumber));
end;

procedure TgsTRPOSClient.Duplicate(ATrNumber: Cardinal; ACashNumber: Cardinal);
begin
  WriteBuffer(GetMessageID(OM_SRVOperation) +
    GetECRnumber(ACashNumber) +
    GetSubFunction(SRV_Duplicate) +
    GetERN(ATrNumber));
end;

procedure TgsTRPOSClient.JRNClean(ATrNumber: Cardinal; ACashNumber: Cardinal);
begin
  WriteBuffer(GetMessageID(OM_SRVOperation) +
    GetECRnumber(ACashNumber) +
    GetSubFunction(SRV_JRNClean) +
    GetERN(ATrNumber));
end;

procedure TgsTRPOSClient.FullClean(ATrNumber: Cardinal; ACashNumber: Cardinal);
begin
  WriteBuffer(GetMessageID(OM_SRVOperation) +
    GetECRnumber(ACashNumber) +
    GetSubFunction(SRV_FullClean) +
    GetERN(ATrNumber));
end;

procedure TgsTRPOSClient.RVRClean(ATrNumber: Cardinal; ACashNumber: Cardinal);
begin
  WriteBuffer(GetMessageID(OM_SRVOperation) +
    GetECRnumber(ACashNumber) +
    GetSubFunction(SRV_RVRClean) +
    GetERN(ATrNumber));
end;

procedure TgsTRPOSClient.MenuPrintReport(ATrNumber: Cardinal; ACashNumber: Cardinal);
begin
  WriteBuffer(GetMessageID(OM_SRVOperation) +
    GetECRnumber(ACashNumber) +
    GetSubFunction(SRV_MenuPrintReport) +
    GetERN(ATrNumber));
end;

procedure TgsTRPOSClient.DSortByDate(ATrNumber: Cardinal; ACashNumber: Cardinal);
begin
  WriteBuffer(GetMessageID(OM_SRVOperation) +
    GetECRnumber(ACashNumber) +
    GetSubFunction(SRV_DSortByDate) +
    GetERN(ATrNumber));
end;

procedure TgsTRPOSClient.DSortByIssuer(ATrNumber: Cardinal; ACashNumber: Cardinal);
begin
  WriteBuffer(GetMessageID(OM_SRVOperation) +
    GetECRnumber(ACashNumber) +
    GetSubFunction(SRV_DSortByIssuer) +
    GetERN(ATrNumber));
end;

procedure TgsTRPOSClient.SSortByDate(ATrNumber: Cardinal; ACashNumber: Cardinal);
begin
  WriteBuffer(GetMessageID(OM_SRVOperation) +
    GetECRnumber(ACashNumber) +
    GetSubFunction(SRV_SSortByDate) +
    GetERN(ATrNumber));
end;

procedure TgsTRPOSClient.RePrint(ATrNumber: Cardinal; ACashNumber: Cardinal);
begin
  WriteBuffer(GetMessageID(OM_SRVOperation) +
    GetECRnumber(ACashNumber) +
    GetSubFunction(SRV_SSortByDate) +
    GetERN(ATrNumber));
end;

function TgsTRPOSClient.GetTrack1Data(const AData: String): String;
begin
  Result := GetParamString(TagValue[IT_Track1Data], TagLength[IT_Track1Data], AData, False);
end;

function TgsTRPOSClient.GetTrack2Data(const AData: String): String;
begin
  Result := GetParamString(TagValue[IT_Track2Data], TagLength[IT_Track2Data], AData, False);
end;

function TgsTRPOSClient.GetTrack3Data(const AData: String): String;
begin
  Result := GetParamString(TagValue[IT_Track3Data], TagLength[IT_Track3Data], AData, False);
end;

function TgsTRPOSClient.GetPan(const AData: String): String;
begin
  Result := GetParamString(TagValue[IT_Pan], TagLength[IT_Pan], AData, False);
end;

function TgsTRPOSClient.GetExpDate(const AData: String): String;
begin
  Result := GetParamString(TagValue[IT_ExpDate], TagLength[IT_ExpDate], AData);
end;

function TgsTRPOSClient.GetInvoiceNumber(const ANumber: Integer): String;
begin
  Result := GetParamString(TagValue[IT_InvoiceNumber], TagLength[IT_InvoiceNumber], IntToStr(ANumber));
end;

function TgsTRPOSClient.GetParamString(AParam: TgsTRPOSParamData): String;
begin
  Result := '';
  if AParam <> nil then
  begin
    if AParam.Track1Data > '' then
      Result := Result + GetTrack1Data(AParam.Track1Data);
    if AParam.Track2Data > '' then
      Result := Result + GetTrack2Data(AParam.Track2Data);
    if AParam.Track3Data > '' then
      Result := Result + GetTrack3Data(AParam.Track3Data);
    if AParam.Pan > '' then
      Result := Result + GetPan(AParam.Pan);
    if AParam.ExpDate > '' then
      Result := Result + GetExpDate(AParam.ExpDate);
    if AParam.InvoiceNumber > -1 then
      Result := Result + GetInvoiceNumber(AParam.InvoiceNumber);
  end;
end;

procedure TgsTRPOSClient.ReadData(AParams: TgsTRPOSOutPutData);
begin
  GetData(FTCPClient.ReadLn('', FReadTimeOut), AParams);
end;

function TgsTRPOSClient.GetSubFunction(const AID: Cardinal): String;
begin
  Result := GetParamString(TagValue[IT_SRVsubfunction], TagLength[IT_SRVsubfunction], chr(AID));
end;

function TgsTRPOSClient.GetParamString(ATag: Cardinal; ALen: Integer;
  const AValue: String; const AFixedLen: Boolean = True): String;
begin
  if Length(AValue) > ALen then
    raise EgsTRPOSClient.Create('Incorrect input parameter!');
  if AFixedLen then
  begin
    SetLength(Result, ALen);
    FillChar(Result[1], Length(Result), ord('0'));
    Move(AValue[1], Result[abs(ALen - Length(AValue)) + 1], Length(AValue));
    Result := chr(ATag) + chr(ALen) + Result;
  end else
    Result := chr(ATag) + chr(Length(AValue)) + AValue;
end;

function TgsTRPOSClient.GetCurrencyCode(const ANumber: Integer): String;
begin
  Result := GetParamString(TagValue[IT_Currency], TagLength[IT_Currency], IntToStr(ANumber));
end;

function TgsTRPOSClient.GetTag(const AStr: String; var I: Integer): Cardinal;
var
  Tag: String;
  IsTag: Boolean;
  Value: Integer;
begin
  Tag := AStr[I];
  Value := ord(AStr[I]);
  IsTag := (not IsBitSet(Value, 0))
    or (not IsBitSet(Value, 1))
    or (not IsBitSet(Value, 2))
    or (not IsBitSet(Value, 3))
    or (not IsBitSet(Value, 4));
  while not IsTag do
  begin
    Inc(I);
    Tag := Tag + AStr[I];
    IsTag := not IsBitSet(ord(AStr[I]), 7);
  end;
  Result := StrToInt('$' + String2Hex(Tag));
  Inc(I);
end;

function TgsTRPOSClient.GetLen(const AStr: String; var I: Integer): Cardinal;
var
  Count: Integer;
begin
  Count := 1;
  if IsBitSet(ord(AStr[I]), 7) then
  begin 
    Count := BitOff(ord(AStr[I]), 7);
    Inc(I);
  end;
  Result := StrToInt('$' + String2Hex(System.Copy(AStr, I, Count)));
  Inc(I, Count);
end;

function TgsTRPOSClient.GetMessageID(const AMessage: String): String;
begin
  Result := GetParamString(TagValue[IT_MessageID], TagLength[IT_MessageID], AMessage);
end;

function TgsTRPOSClient.GetECRnumber(const ANumber: Cardinal): String;
begin
  Result := GetParamString(TagValue[IT_ECRnumber], TagLength[IT_ECRnumber], IntToStr(ANumber));
end;

function TgsTRPOSClient.GetERN(const ANumber: Cardinal): String;
begin
  Result := GetParamString(TagValue[IT_ERN], TagLength[IT_ERN], IntToStr(ANumber));
end;

function TgsTRPOSClient.GetTransactionAmount(const ASumm: Currency): String;
var
  TempS: String;
begin
  TempS:= CurrToStr(ASumm);
  TempS := StringReplace(TempS, DecimalSeparator, '', [rfReplaceAll]);
  Result := GetParamString(TagValue[IT_TransactionAmount], TagLength[IT_TransactionAmount], TempS);
end;

procedure TgsTRPOSClient.GetData(const AStr: String; AParams: TgsTRPOSOutPutData);
var
  I, Len, Tag: Integer;
begin
  I := 1;
  while I < Length(AStr) do
  begin
    Tag := GetTag(AStr, I);
    Len := GetLen(AStr, I);
    case Tag of
      OT_MessageID: AParams.MessageID := System.Copy(AStr, I, Len);
      OT_ECRnumber: AParams.ECRnumber := StrToInt(System.Copy(AStr, I, Len));
      OT_ERN: AParams.ERN := StrToInt(System.Copy(AStr, I, Len));
      OT_ResponseCode: AParams.ResponseCode := System.Copy(AStr, I, Len);
      OT_TransactionAmount: AParams.TransactionAmount := System.Copy(AStr, I, Len);
      OT_PAN: AParams.Pan := System.Copy(AStr, I, Len);
      OT_ExpDate: AParams.ExpDate := System.Copy(AStr, I, Len);
      OT_InvoiceNumber: AParams.InvoiceNumber := System.Copy(AStr, I, Len);
      OT_AuthorizationID: AParams.AuthorizationID := System.Copy(AStr, I, Len);
      OT_Approve: AParams.Approve := System.Copy(AStr, I, Len);
      OT_Receipt: AParams.Receipt := System.Copy(AStr, I, Len);
      OT_Date: AParams.Date := System.Copy(AStr, I, Len);
      OT_Time: AParams.Time := System.Copy(AStr, I, Len);
      OT_VerificationChr: AParams.VerificationChr := System.Copy(AStr, I, Len);
      OT_RRN: AParams.RRN := System.Copy(AStr, I, Len);
      OT_TVR: AParams.TVR := System.Copy(AStr, I, Len);
      OT_TerminalID: AParams.TerminalID := System.Copy(AStr, I, Len);
      OT_CardDataEnc: AParams.CardDataEnc := System.Copy(AStr, I, Len);
    end;
    Inc(I, Len);
  end;
end;

procedure TgsTRPOSClient.Connect;
begin
  if not FTCPClient.Connected then
  begin
    FTCPClient.Host := FHost;
    FTCPClient.Port := FPort;
    FTCPClient.Connect;
  end;
end;

procedure TgsTRPOSClient.Disconnect;
begin
  if FTCPClient.Connected then
    FTCPClient.Disconnect;
end;

procedure TgsTRPOSClient.SetHost(const AValue: String);
begin
  if FHost <> AValue then
  begin
    Disconnect;
    FHost := AValue;
  end;
end;

procedure TgsTRPOSClient.SetPort(const AValue: Integer);
begin
  if FPort <> AValue then
  begin
    Disconnect;
    FPort := AValue;
  end;
end;

function TgsTRPOSClient.GetConnected: Boolean;
begin
  Result := FTCPClient.Connected;
end;

procedure TgsTRPOSClient.Payment(ASumm: Currency; ATrNumber: Cardinal;
  ACashNumber: Cardinal; const ACurrCode: Integer = -1;
  const APreAUT: Boolean = False; const AParam: TgsTRPOSParamData = nil);
begin
  if APreAUT then
    InternalMessages(OM_PMNPreAuthorize, ATrNumber, ACashNumber, ASumm, ACurrCode, AParam)
  else
    InternalMessages(OM_Payment, ATrNumber, ACashNumber, ASumm, ACurrCode, AParam);
end;

procedure TgsTRPOSClient.Return(ASumm: Currency; ATrNumber: Cardinal;
  ACashNumber: Cardinal; const ACurrCode: Integer = -1;
  const AParam: TgsTRPOSParamData = nil);
begin
  InternalMessages(OM_Return, ATrNumber, ACashNumber, ASumm, ACurrCode, AParam);
end;

procedure TgsTRPOSClient.Cancel(ASumm: Currency; ATrNumber: Cardinal;
  ACashNumber: Cardinal; const ACurrCode: Integer = -1;
  const AParam: TgsTRPOSParamData = nil);
begin  
  InternalMessages(OM_Cancel, ATrNumber, ACashNumber, ASumm, ACurrCode, AParam);
end;

procedure TgsTRPOSClient.ReadJournal(ATrNumber: Cardinal; ACashNumber: Cardinal;
  const AParam: TgsTRPOSParamData = nil);
begin
  InternalMessages(OM_Journal, ATrNumber, ACashNumber, -1, -1, AParam);
end; 

procedure TgsTRPOSClient.PreAuthorize(ASumm: Currency; ATrNumber: Cardinal;
  ACashNumber: Cardinal; const ACurrCode: Integer = -1;
  const AParam: TgsTRPOSParamData = nil);
begin
  InternalMessages(OM_PreAuthorize, ATrNumber, ACashNumber, ASumm, ACurrCode, AParam);
end;

procedure TgsTRPOSClient.ResetLockJournal(ATrNumber: Cardinal; ACashNumber: Cardinal;
  const AParam: TgsTRPOSParamData = nil);
begin
  InternalMessages(OM_ResetLockJRN, ATrNumber, ACashNumber, -1, -1, AParam);
end;

procedure TgsTRPOSClient.Calculation(ATrNumber: Cardinal; ACashNumber: Cardinal;
  const AParam: TgsTRPOSParamData = nil);
begin
  InternalMessages(OM_Calculation, ATrNumber, ACashNumber, -1, -1, AParam);
end;

procedure TgsTRPOSClient.ReadCard(ATrNumber: Cardinal; ACashNumber: Cardinal;
  const AParam: TgsTRPOSParamData = nil);
begin
  InternalMessages(OM_ReadCard, ATrNumber, ACashNumber, -1, -1, AParam);
end;

procedure TgsTRPOSClient.Ping(ATrNumber: Cardinal; ACashNumber: Cardinal;
  const AParam: TgsTRPOSParamData = nil);
begin
  InternalMessages(OM_Ping, ATrNumber, ACashNumber, -1, -1, AParam);
end;

procedure TgsTRPOSClient.Cash(ASumm: Currency; ATrNumber: Cardinal;
  ACashNumber: Cardinal; const ACurrCode: Integer = -1;
  const AParam: TgsTRPOSParamData = nil);
begin
  InternalMessages(OM_Cash, ATrNumber, ACashNumber, ASumm, ACurrCode, AParam);
end;

procedure TgsTRPOSClient.Replenishment(ASumm: Currency; ATrNumber: Cardinal;
  ACashNumber: Cardinal; const ACurrCode: Integer = -1;
  const AParam: TgsTRPOSParamData = nil);
begin
  InternalMessages(OM_Replenishment, ATrNumber, ACashNumber, ASumm, ACurrCode, AParam);
end;

procedure TgsTRPOSClient.InternalMessages(const ATag: String; ATrNumber: Cardinal;
  ACashNumber: Cardinal; const ASumm: Currency = -1; const ACurrCode: Integer = -1;
  const AParam: TgsTRPOSParamData = nil);
var
  TempS: String;
begin
  TempS := GetMessageID(ATag);
  if ASumm > 0 then
    TempS := TempS + GetTransactionAmount(ASumm);
  TempS := Temps + GetECRnumber(ACashNumber) + GetERN(ATrNumber);
  if ACurrCode > -1 then
    TempS := TempS + GetCurrencyCode(ACurrCode);
  if AParam <> nil then
    TempS := TempS + GetParamString(AParam);
  WriteBuffer(TempS);
end;

procedure TgsTRPOSClient.Balance(ATrNumber: Cardinal; ACashNumber: Cardinal;
  const AParam: TgsTRPOSParamData = nil);
begin
  InternalMessages(OM_Balance, ATrNumber, ACashNumber, -1, -1, AParam);
end;

procedure TgsTRPOSClient.WriteBuffer(const ABuffer: String);
begin
  FTCPClient.WriteLn(ABuffer);
end;

procedure TgsTRPOSOutPutData.Clear;
begin
  MessageID := '';
  ECRnumber := 0;
  ERN := 0;
  ResponseCode := '';
  TransactionAmount := '';
  Pan := '';
  ExpDate := '';
  Approve := '';
  Receipt := '';
  InvoiceNumber := '';
  AuthorizationID := '';
  Date := '';
  Time := '';
  VerificationChr := '';
  RRN := '';
  TVR := '';
  TerminalID := '';
  CardDataEnc := '';
end;

end.
