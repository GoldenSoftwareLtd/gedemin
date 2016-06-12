
unit gd_convert;

interface

uses
  NumConv;

const
  CacheFlushInterval = 120 * 60 * 1000; //2 hrs in msec

function GetSumCurr(const ACurrKey: Integer; const AValue: Double; const ACentAsString: Boolean;
  const AnIncludeCent: Boolean): String;
function GetSumStr(const AValue: Double; const APrecision: Byte = 0): String;
function GetSumStr2(const AValue: Double; const AGender: TGender): String;
function GetRubSumStr(const AValue: Double): String;
function GetFullRubSumStr(const AValue: Double): String;

implementation

uses
  Windows, Forms, SysUtils, gdcCurr, IBSQL, gdcBaseInterface, gd_security,
  gd_common_functions;

type
  TNameSelector = (nsName, nsCentName);

var
  NumberConvert: TNumberConvert;
  FCurrCachedKey, FCurrCachedDBID: Integer;
  FCurrCachedTime: DWORD;
  CacheName, CacheCentName,
  CacheName_0, CacheName_1,
  CacheCentName_0, CacheCentName_1: String;

function GetRubbleWord(const Value: Double): String;
var
  Num: Int64;
begin
  Num := Trunc(Abs(Value));

  if (Num mod 100 >= 20) or (Num mod 100 <= 10) then
    case Num mod 10 of
      1: Result := 'рубль';
      2, 3, 4: Result := 'рубл€';
    else
      Result := 'рублей';
    end
  else
    Result := 'рублей';
end;

function GetKopWord(const Value: Double): String;
var
  Num: Int64;
begin
  Num := Trunc(Abs(Value));

  if (Num mod 100 >= 20) or (Num mod 100 <= 10) then
    case Num mod 10 of
      1: Result := 'копейка';
      2, 3, 4: Result := 'копейки';
    else
      Result := 'копеек';
    end
  else
    Result := 'копеек';
end;

function UpdateCache(const AnID: Integer; const AForce: Boolean = False): Boolean;
var
  q: TIBSQL;
begin
  Assert(Assigned(IBLogin));

  if AForce or (AnID <> FCurrCachedKey)
    or (FCurrCachedDBID <> IBLogin.DBID)
    or (GetTickCount - FCurrCachedTime > CacheFlushInterval) then
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcBaseManager.ReadTransaction;
      q.SQL.Text := 'SELECT * FROM gd_curr WHERE id = :ID';
      q.ParamByName('ID').AsInteger := AnID;
      q.ExecQuery;
      if not q.EOF then
      begin
        CacheCentName := AnsiLowerCase(q.FieldByName('fullcentname').AsString);
        CacheName := AnsiLowerCase(q.FieldByName('name').AsString);
        CacheCentName_0 := AnsiLowerCase(q.FieldByName('centname_0').AsString);
        CacheCentName_1 := AnsiLowerCase(q.FieldByName('centname_1').AsString);
        CacheName_0 := AnsiLowerCase(q.FieldByName('name_0').AsString);
        CacheName_1 := AnsiLowerCase(q.FieldByName('name_1').AsString);

        FCurrCachedKey := AnID;
      end else
        FCurrCachedKey := -1;

      FCurrCachedDBID := IBLogin.DBID;
      FCurrCachedTime := GetTickCount;
    finally
      q.Free;
    end;
  end;

  Result := FCurrCachedKey <> -1;
end;

function GetSumStr(const AValue: Double; const APrecision: Byte = 0): String;
begin
  if NumberConvert = nil then
  begin
    NumberConvert := TNumberConvert.Create(nil);
    NumberConvert.Language := lRussian;
  end;

  NumberConvert.Value := AValue;
  NumberConvert.Precision := APrecision;
  if (APrecision > 0)  then
    NumberConvert.Gender := gFemale
  else
    NumberConvert.Gender := gMale;

  Result := NumberConvert.Numeral;
end;

function GetSumStr2(const AValue: Double; const AGender: TGender): String;
begin
  if NumberConvert = nil then
  begin
    NumberConvert := TNumberConvert.Create(nil);
    NumberConvert.Language := lRussian;
  end;

  NumberConvert.Value := AValue;
  NumberConvert.Gender := AGender;
  Result := NumberConvert.Numeral;
end;

function GetSumCurr(const ACurrKey: Integer; const AValue: Double; const ACentAsString: Boolean;
  const AnIncludeCent: Boolean): String;

  function GetName(const Num: Int64; const Name: TNameSelector): String;
  var
    gdcCurr: TgdcCurr;
  begin
    repeat
      if (Num mod 100 >= 20) or (Num mod 100 <= 10) then
      begin
        case Num mod 10 of
          1:
             if Name = nsCentName then
               Result := CacheCentName
             else
               Result := CacheName;
          2, 3, 4:
             if Name = nsCentName then
               Result := CacheCentName_1
             else
               Result := CacheName_1
        else
          begin
           if Name = nsCentName then
             Result := CacheCentName_0
           else
             Result := CacheName_0
          end;
        end
      end else
      begin
        if Name = nsCentName then
          Result := CacheCentName_0
        else
          Result := CacheName_0
      end;

      if Result > '' then
        break;

      if (Screen.ActiveCustomForm = nil) or (not Screen.ActiveCustomForm.Visible) then
        break;

      MessageBox(0,
        PChar('”кажите наименование целых и разменных единиц валюты ' + CacheName + '.'),
        '¬нимание',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);

      gdcCurr := TgdcCurr.Create(nil);
      try
        gdcCurr.SubSet := 'ByID';
        gdcCurr.ParamByName('ID').AsInteger := FCurrCachedKey;
        gdcCurr.Open;
        if gdcCurr.EOF or (not gdcCurr.EditDialog)
          or (not UpdateCache(FCurrCachedKey, True)) then
        begin
          break;
        end;  
      finally
        gdcCurr.Free;
      end;
    until False;
  end;

var
  Whole, Cent: Int64;
  S: String;
begin
  if UpdateCache(ACurrKey) then
  begin
    Whole := Trunc(Abs(AValue));
    Cent := Round(Frac(Abs(AValue))  * 100);

    Result := GetSumStr2(Whole, TNumberConvert.GenderOf(CacheName, CacheName_1)) + ' ' + GetName(Whole, nsName);

    if (Cent <> 0) or AnIncludeCent then
    begin
      if ACentAsString then
        S := GetSumStr2(Cent, TNumberConvert.GenderOf(CacheCentName, CacheCentName_1))
      else
      begin
        S := IntToStr(Cent);
        if Length(S) = 1 then
          S := '0' + S;
      end;
      Result := Result + ' ' + S + ' ' + GetName(Cent, nsCentName);
    end;

    Result := NameCase(Result);
  end else
    Result := '';
end;

function GetRubSumStr(const AValue: Double): String;
begin
  Result := NameCase(GetSumStr2(AValue, gMale) + ' ' + GetRubbleWord(AValue));
end;

function GetFullRubSumStr(const AValue: Double): String;
var
  N: Int64;
begin
  Result := GetRubSumStr(AValue);
  N := Round(Frac(Abs(AValue)) * 100);
  if N <> 0 then
    Result := Result + ' ' + GetSumStr2(N, gFemale) + ' ' + GetKopWord(N);
end;

initialization
  NumberConvert := nil;
  FCurrCachedKey := -1;

finalization
  FreeAndNil(NumberConvert);
end.