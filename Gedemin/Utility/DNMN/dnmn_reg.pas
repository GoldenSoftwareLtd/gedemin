unit dnmn_reg;

interface

uses
  IBDatabase;

function CheckReg(DB: TIBDatabase): Boolean;
function GetMask(const AKey: Cardinal): Cardinal;
function StripNumber(const S: String): String;

implementation

uses
  Classes, SysUtils, Forms, Controls, IB, IBSQL, dnmn_frmReg_unit, gd_getmacaddress, jclMath;

function StripNumber(const S: String): String;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(S) do
    if S[I] in ['0'..'9'] then
      Result := Result + S[I];
end;

function GetMask(const AKey: Cardinal): Cardinal;
var
  I: Integer;
begin
  Result := 0;
  RandSeed := LongInt(AKey);
  for I := 1 to 4 do
    Result := (Result shl 8) or Byte(Random(256));
end;

function CheckReg(DB: TIBDatabase): Boolean;
var
  Tr: TIBTransaction;
  q: TIBSQL;
  F: Tdnmn_frmReg;
  S: AnsiString;
  KeyNumber, Code, V: Cardinal;
  SL: TStringList;
begin
  Result := False;

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := DB;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q.SQL.Text :=
      'SELECT c.name ' +
      'FROM ' +
      '  gd_user u ' +
      '  JOIN gd_usercompany uc ON uc.userkey = u.id ' +
      '  JOIN gd_contact c ON c.id = uc.companykey ' +
      'WHERE ' +
      '  u.ibname = ''SYSDBA'' ';
    q.ExecQuery;

    if q.EOF then
    begin
      q.Close;
      q.SQL.Text :=
        'SELECT c.name ' +
        'FROM ' +
        '  gd_usercompany uc  ' +
        '  JOIN gd_contact c ON c.id = uc.companykey ';
      q.ExecQuery;
    end;

    if not q.EOF then
    begin
      SL := TStringList.Create;
      try
        Get_EthernetAddresses(SL);
        S := SL.Text;
      finally
        SL.Free;
      end;

      S := S + q.FieldByName('name').AsTrimString;

      KeyNumber := Crc32_P(@S[1], Length(S), 0);

      F := Tdnmn_frmReg.Create(nil);
      try
        F.m.Lines.Add('Организация: ' + q.FieldByName('name').AsTrimString);
        F.m.Lines.Add('Контрольное число: ' + FormatFloat('#,###', KeyNumber));
        if F.ShowModal = mrOk then
        begin
          V := $19760212;
          Code := StrToInt64Def(StripNumber(F.edCode.Text), 0);
          Result := (Code xor GetMask(KeyNumber)) = V;
        end;
      finally
        F.Free;
      end;
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;

end.
