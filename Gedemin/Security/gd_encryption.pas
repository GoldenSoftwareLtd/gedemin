// ShlTanya, 06.02.2019

unit gd_encryption;

interface

uses
  Classes;

// шифрует переданную строку максимальной длиной 124 символа
// на выходе строка длиной 256 символов (состоит из последовательности
// шестнадцатеричных цифр.
function EncryptString(const AStr: AnsiString; const ACryptoKey: AnsiString): AnsiString;

// на вход передается зашифрованная строка строго длиной 256 символов
function DecryptString(const AStr: AnsiString; const ACryptoKey: AnsiString): AnsiString;

implementation

uses
  SysUtils, gd_common_functions, wcrypt2;

const
  MaxDataBlock = 128;
  Signature = '0001';

function DecryptString(const AStr: AnsiString; const ACryptoKey: AnsiString): AnsiString;
var
  hProv: HCRYPTPROV;
  Key: HCRYPTKEY;
  Hash: HCRYPTHASH;
  Len, I, P: Integer;
begin
  if Length(AStr) <> 256 then
    raise Exception.Create('String must be of 256 characters');

  if ACryptoKey = '' then
    raise Exception.Create('Empty password');

  Len := MaxDataBlock;
  SetLength(Result, Len);
  I := 1; P := 1;
  while P <= Len do
  begin
    Result[P] := HexToAnsiChar(AStr, I);
    Inc(I, 2);
    Inc(P);
  end;

  CryptAcquireContext(@hProv, nil, nil, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT);
  try
    CryptCreateHash(hProv, CALG_SHA, 0, 0, @Hash);
    try
      CryptHashData(Hash, @ACryptoKey[1], Length(ACryptoKey), 0);
      CryptDeriveKey(hProv, CALG_RC4, Hash, 0, @Key);
      CryptDecrypt(Key, 0, True, 0, @Result[1], @Len);
    finally
      CryptDestroyHash(Hash);
    end;
  finally
    CryptReleaseContext(hProv, 0);
  end;

  if Copy(Result, 1, 4) <> Signature then
    raise Exception.Create('Invalid encrypted data');

  if Pos(#00, Result) > 0 then
    SetLength(Result, Pos(#00, Result) - 1);

  Result := Copy(Result, Length(Signature) + 1, 1024);
end;

function EncryptString(const AStr: AnsiString; const ACryptoKey: AnsiString): AnsiString;
var
  S: AnsiString;
  hProv: HCRYPTPROV;
  Key: HCRYPTKEY;
  Hash: HCRYPTHASH;
  Len, I: Integer;
begin
  if Length(AStr) > (MaxDataBlock - Length(Signature)) then
    raise Exception.Create('Exceeded maximum string length');

  if ACryptoKey = '' then
    raise Exception.Create('Empty password');

  Len := MaxDataBlock;
  S := Signature + AStr + StringOfChar(#00, MaxDataBlock - Length(AStr) - Length(Signature));

  CryptAcquireContext(@hProv, nil, nil, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT);
  try
    CryptCreateHash(hProv, CALG_SHA, 0, 0, @Hash);
    try
      CryptHashData(Hash, @ACryptoKey[1], Length(ACryptoKey), 0);
      CryptDeriveKey(hProv, CALG_RC4, Hash, 0, @Key);
      CryptEncrypt(Key, 0, True, 0, @S[1], @Len, Len);
    finally
      CryptDestroyHash(Hash);
    end;
  finally
    CryptReleaseContext(hProv, 0);
  end;

  Result := '';
  for I := 1 to Length(S) do
    Result := Result + AnsiCharToHex(S[I]);
end;

end.
