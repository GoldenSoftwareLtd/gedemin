unit gsTRPOS_TLVClient;

interface

uses
  Windows, Classes, SysUtils, IdTCPClient, IdGlobal;

type
  TOutPutInfo = record
    MessageID: String;
    ECRnumber: Cardinal;
    ERN: Cardinal;
    ResponseCode: String;
    TransactionAmount: String;
    Pan: String;
    ExpDate: String;
    Approve: String;
    Receipt: String;
    InvoiceNumber: String;
    AuthorizationID: String;
  end;

  TgsTRPOS_TLVClient = class(TObject)
  private
    FTCPClient: TIdTCPClient;
    FHost: String;
    FPort: Integer;
    FReadTimeOut: Integer;

    procedure SetHost(const AValue: String);
    procedure SetPort(const AValue: Integer);
    function GetParamString(ATag: Cardinal; ALen: Integer;
      const AValue: String): String;
    function GetMessageID(const AMessage: String): String;
    function GetECRnumber(const ANumber: Cardinal): String;
    function GetERN(const ANumber: Cardinal): String;
    function GetCurrencyCode(const ANumber: Integer): String;
    function GetTransactionAmount(const ASumm: Currency): String;
   // function GetValue(const AStr: String; var I: Integer): String;
    function GetTag(const AStr: String; var I: Integer): Cardinal;
    function GetLen(const AStr: String; var I: Integer): Cardinal;
    function GetData(const AStr: String): TOutPutInfo;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;
    function Payment(ASumm: Currency; ATrNumber: Cardinal;
      ACashNumber: Cardinal; const ACurrCode: Integer = -1): TOutPutInfo;
    function Cancel(ASumm: Currency; ATrNumber: Cardinal;
      ACashNumber: Cardinal; const ACurrCode: Integer = -1): TOutPutInfo;
  //  function ResultByNumberOfCheck()
    property Host: String read FHost write SetHost;
    property Port: Integer read FPort write SetPort;
    property ReadTimeOut: Integer read FReadTimeOut write FReadTimeOut default IdTimeoutDefault;
  end;

  EgsTRPOS_TLVClient = class(Exception);

implementation

const      
  IT_MessageID         = $01;
  IT_ECRnumber         = $02;
  IT_ERN               = $03;
  IT_Currency          = $1B;
  IT_TransactionAmount = $04;
  LenTransactionAmount = $0C;
  LenERN               = $0A;
  LenECRnumber         = $02;
  LenMessageID         = $03;
  LenCurrency          = $03;

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

  OM_Payment           = 'PUR';
  OM_Cancel            = 'REF';



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

constructor TgsTRPOS_TLVClient.Create;
begin
  inherited;
  FTCPClient := TIdTCPClient.Create(nil);
end;

destructor TgsTRPOS_TLVClient.Destroy;
begin
  Disconnect;
  FTCPClient.Free; 
  inherited;
end;

function TgsTRPOS_TLVClient.GetParamString(ATag: Cardinal; ALen: Integer;
  const AValue: String): String;
begin
  if Length(AValue) > ALen then
    raise EgsTRPOS_TLVClient.Create('Incorrect input parameter!');
  SetLength(Result, ALen);
  FillChar(Result, SizeOf(Result), ord('0'));
  Move(AValue[1], Result[abs(ALen - Length(AValue)) + 1], Length(AValue));
  Result := chr(ATag) + chr(ALen) + Result;
end;

function TgsTRPOS_TLVClient.GetCurrencyCode(const ANumber: Integer): String;
begin
  Result := GetParamString(IT_Currency, LenCurrency, IntToStr(ANumber));
end;

function TgsTRPOS_TLVClient.GetTag(const AStr: String; var I: Integer): Cardinal;
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

function TgsTRPOS_TLVClient.GetLen(const AStr: String; var I: Integer): Cardinal;
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

{function TgsTRPOS_TLVClient.GetValue(const AStr: String; var I: Integer): String;
begin

end;}

function TgsTRPOS_TLVClient.GetMessageID(const AMessage: String): String;
begin
  Result := GetParamString(IT_MessageID, LenMessageID, AMessage);
end;

function TgsTRPOS_TLVClient.GetECRnumber(const ANumber: Cardinal): String;
begin
  Result := GetParamString(IT_ECRnumber, LenECRnumber, IntToStr(ANumber));
end;

function TgsTRPOS_TLVClient.GetERN(const ANumber: Cardinal): String;
begin
  Result := GetParamString(IT_ERN, LenERN, IntToStr(ANumber));
end;

function TgsTRPOS_TLVClient.GetTransactionAmount(const ASumm: Currency): String;
var
  TempS: String;
begin
  TempS:= CurrToStr(ASumm);
  TempS := StringReplace(TempS, DecimalSeparator, '', [rfReplaceAll]);
  Result := GetParamString(IT_TransactionAmount, LenTransactionAmount, TempS);
end;

function TgsTRPOS_TLVClient.GetData(const AStr: String): TOutPutInfo;
var
  I, Len, Tag: Integer;
begin
  FillChar(Result, SizeOf(Result), 0);
  I := 1;
  while I < Length(AStr) do
  begin
    Tag := GetTag(AStr, I);
    Len := GetLen(AStr, I);
    case Tag of
      OT_MessageID: Result.MessageID := System.Copy(AStr, I, Len);
      OT_ECRnumber: Result.ECRnumber := StrToInt(System.Copy(AStr, I, Len));
      OT_ERN: Result.ERN := StrToInt(System.Copy(AStr, I, Len));
      OT_ResponseCode:  Result.ResponseCode := System.Copy(AStr, I, Len);
      OT_TransactionAmount: Result.TransactionAmount := System.Copy(AStr, I, Len);
      OT_PAN: Result.Pan := System.Copy(AStr, I, Len);
      OT_ExpDate: Result.ExpDate := System.Copy(AStr, I, Len);
      OT_InvoiceNumber: Result.InvoiceNumber := System.Copy(AStr, I, Len);
      OT_AuthorizationID: Result.AuthorizationID := System.Copy(AStr, I, Len);
      OT_Approve: Result.Approve := System.Copy(AStr, I, Len);
      OT_Receipt: Result.Receipt := System.Copy(AStr, I, Len);
    end;
    Inc(I, Len);
  end;
end;

procedure TgsTRPOS_TLVClient.Connect;
begin
  if not FTCPClient.Connected then
  begin
    FTCPClient.Host := FHost;
    FTCPClient.Port := FPort;
    FTCPClient.Connect;
  end;
end;

procedure TgsTRPOS_TLVClient.Disconnect;
begin
  if FTCPClient.Connected then
    FTCPClient.Disconnect;
end;

procedure TgsTRPOS_TLVClient.SetHost(const AValue: String);
begin
  if FHost <> AValue then
  begin
    Disconnect;
    FHost := AValue;
  end;
end;

procedure TgsTRPOS_TLVClient.SetPort(const AValue: Integer);
begin
  if FPort <> AValue then
  begin
    Disconnect;
    FPort := AValue;
  end;
end;

function TgsTRPOS_TLVClient.Payment(ASumm: Currency; ATrNumber: Cardinal;
  ACashNumber: Cardinal; const ACurrCode: Integer = -1): TOutPutInfo;
var
  WriteString: String;
begin    
  WriteString := GetMessageID(OM_Payment) + GetTransactionAmount(ASumm) +
    GetECRnumber(ATrNumber) + GetERN(ACashNumber);
  if ACurrCode > -1 then
    WriteString := WriteString + GetCurrencyCode(ACurrCode);
  FTCPClient.WriteLn(WriteString);
  Result := GetData(FTCPClient.ReadLn('', FReadTimeOut));
end;

function TgsTRPOS_TLVClient.Cancel(ASumm: Currency; ATrNumber: Cardinal;
  ACashNumber: Cardinal; const ACurrCode: Integer = -1): TOutPutInfo;
var
  WriteString: String;
begin  
  WriteString := GetMessageID(OM_Cancel) + GetTransactionAmount(ASumm) +
    GetECRnumber(ATrNumber) + GetERN(ACashNumber);
  if ACurrCode > -1 then
    WriteString := WriteString + GetCurrencyCode(ACurrCode);
  FTCPClient.Write(WriteString);
  Result := GetData(FTCPClient.ReadLn('', FReadTimeOut));
end;  
end.
