unit gd_encrypt;

interface
function DecodeString(Const S1, S2: String): String;
function EncodeString(Const S1, S2: String): String;

implementation
uses
  SysUtils;

function DecodeString(Const S1, S2: String): String;
var
  I1, I2: Integer;
begin
  I2 := 1;
  Result := '';
  for I1 := 0 to (Length(S1) div 4) - 1 do
  begin
    if I2 > Length(S2) then I2 := 1;    
    Result := Result + Chr(StrToInt('$' + Copy(S1, I1*4 + 1, 4)) xor ord(S2[I2]));
    inc(I2);
  end;
end;

function EncodeString(Const S1, S2: String): String;
var
  I1, I2: Integer;
begin
  I2 := 1;
  Result := '';
  for I1 := 1 to Length(S1) do
  begin
    if I2 > Length(S2) then I2 := 1;    
    Result := Result + IntToHex(Ord(S1[I1]) xor Ord(S2[I2]), 4);
    inc(I2);
  end;
end;
end.
