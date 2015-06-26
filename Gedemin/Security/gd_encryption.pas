unit gd_encryption;

interface

uses
  Classes;
//на вход строка 256 символов
function DecryptionString(const Str: String; ACryptoKey: String): String;
// на вход строка не более 124 символа
// на выходе 256
function EncryptionString(const Str: String; ACryptoKey: String): String;

implementation

uses
  SysUtils, gd_common_functions, wcrypt2;

function DecryptionString(const Str: String; ACryptoKey: String): String;
var
  hProv: HCRYPTPROV;
  Key: HCRYPTKEY;
  Hash: HCRYPTHASH;
  CryptoKey, PassHex: AnsiString;
  Len, I, P: Integer;
begin
  Len := Length(Str);

  if Length(Str) <> 256 then
    raise Exception.Create('is not the right length');

  Result := '';

  PassHex := Str;
  Len := Length(PassHex) div 2;
  SetLength(Result, Len);
  I := 1; P := 1;
  while P <= Len do
  begin
    try
      Result[P] := HexToAnsiChar(PassHex, I);
    except
      Result := '';
      break;
    end;
    Inc(I, 2);
    Inc(P);
  end;
  if Result > '' then
  begin
    CryptAcquireContext(@hProv, nil, nil, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT);
    try
      CryptCreateHash(hProv, CALG_SHA, 0, 0, @Hash);
      try
        CryptoKey := ACryptoKey;
        CryptHashData(Hash, @CryptoKey[1], Length(CryptoKey), 0);
        CryptDeriveKey(hProv, CALG_RC4, Hash, 0, @Key);
        CryptDecrypt(Key, 0, True, 0, @Result[1], @Len);
      finally
        CryptDestroyHash(Hash);
      end;
    finally
      CryptReleaseContext(hProv, 0);
    end;

    if Copy(Result, 1, 4) = '0001' then
    begin
      if Pos(#00, Result) > 0 then
        SetLength(Result, Pos(#00, Result) - 1);
      Result := Copy(Result, 5, 1024);
    end;
  end;
end;

function EncryptionString(const Str: String; ACryptoKey: String): String;
const
  MaxDataBlock = 128;
var
  S: String;
  hProv: HCRYPTPROV;
  Key: HCRYPTKEY;
  Hash: HCRYPTHASH;
  CryptoKey: String;
  Len, I: Integer;
begin
  if Length(Str) > (MaxDataBlock - 4) then
    raise Exception.Create('exceeded maximum string length');

  Result := '';

  S := '0001' + Str;
  Len := MaxDataBlock;

  S := S + StringOfChar(#00, Len - Length(S));

  CryptAcquireContext(@hProv, nil, nil, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT);
  try
    CryptCreateHash(hProv, CALG_SHA, 0, 0, @Hash);
    try
      CryptoKey := ACryptoKey;
      CryptHashData(Hash, @CryptoKey[1], Length(CryptoKey), 0);
      CryptDeriveKey(hProv, CALG_RC4, Hash, 0, @Key);
      CryptEncrypt(Key, 0, True, 0, @S[1], @Len, Len);
    finally
      CryptDestroyHash(Hash);
    end;
  finally
    CryptReleaseContext(hProv, 0);
  end;

  Result := '';
  I := 1;
  while I <= Len do
  begin
    Result := Result + AnsiCharToHex(S[I]);
    inc(I);
  end;
end;

end.
