unit rp_FR4Functions;

interface

uses
  SysUtils, Classes, Windows, Forms, fs_iinterpreter,
  NumConv;

type
  TFR4Functions = class(TfsRTTIModule)
  private
    NumberConvert: TNumberConvert;

    CacheDBID: Integer;
    CacheTime: DWORD;
    CacheID: Integer;
    CacheName, CacheFullCentName,
    CacheName_0, CacheName_1,
    CacheCentName_0, CacheCentName_1: String;

    function CallMethod(Instance: TObject; ClassType: TClass;
      const MethodName: String; var Params: Variant): Variant;

    //Константы
    function GetConstByName(const AName: String): Variant;
    function GetConstByID(const AnID: Integer): Variant;
    function GetConstByNameForDate(const AName: String; const ADate: String): Variant;
    function GetConstByIDForDate(const AnID: Integer; const ADate: String): Variant;
    //Денежные
    procedure UpdateCache(const AnID: Integer);

    function GetSumCurr(D1, D2, D3: Variant; D4: Boolean = False): String;
    function GetSumStr(D1: Variant; D2: Byte = 0): String;
    function GetRubSumStr(D: Variant): String;
    function GetFullRubSumStr(D: Variant): String;
    //Дата
    function DateStr(D: Variant): String;
    //Остальные
    function AdvString: String;
  public
    constructor Create(AScript: TfsScript); override;
  end;

implementation

uses
  gdcConst, IBSQL, gd_security, gdcBaseInterface, gsMorph
  {$IFDEF GEDEMIN}
  , gdcCurr
  {$ENDIF}
  ;

const
  MonthNames: array[1..12] of String = (
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря'
  );

type
  TNameSelector = (nsName, nsCentName);

{ TFR4Functions }

function NameCase(const S: String): String;
begin
  if Length(S) > 1 then
    Result := AnsiUpperCase(Copy(S, 1, 1)) + AnsiLowerCase(Copy(S, 2, 8192))
  else
    Result := AnsiLowerCase(S);
end;

function GetRubbleWord(Value: Double): String;
var
  Num: Integer;
begin
  Num := Trunc(Abs(Value));

  if (Trunc(Num) mod 100 >= 20) or (Trunc(Num) mod 100 <= 10) then
    case Trunc(Num) mod 10 of
      1: Result := 'рубль';
      2, 3, 4: Result := 'рубля';
    else
      Result := 'рублей';
    end
  else
    Result := 'рублей';
end;

function GetKopWord(Value: Double): String;
var
  Num: Integer;
begin
  Num := Trunc(Abs(Value));

  if (Trunc(Num) mod 100 >= 20) or (Trunc(Num) mod 100 <= 10) then
    case Trunc(Num) mod 10 of
      1: Result := 'копейка';
      2, 3, 4: Result := 'копейки';
    else
      Result := 'копеек';
    end
  else
    Result := 'копеек';
end;

function DateToRusStr(ADate: TDateTime): String;
var
  MM, DD, YY: Word;
  DS: String;
begin
  DecodeDate(ADate, YY, MM, DD);
  DS := IntToStr(DD);
  if DD < 10 then
    DS := '0' + DS;
  Result := Format('%s %s %d', [DS, MonthNames[MM], YY]);
end;

function TFR4Functions.AdvString: String;
begin
  Result := 'Подготовлено в системе Гедымин. Тел.: (017) 292-13-33, 331-35-46. http://gsbelarus.com © Golden Software of Belarus Ltd. ';
end;

function TFR4Functions.CallMethod(Instance: TObject; ClassType: TClass;
  const MethodName: String; var Params: Variant): Variant;
begin
  if MethodName = 'ADVSTRING' then
    Result := AdvString
  else if MethodName = 'GETVALUEBYID' then
    Result := GetConstByID(Params[0])
  else if MethodName = 'GETVALUEBYNAME' then
    Result := GetConstByName(Params[0])
  else if MethodName = 'GETVALUEBYIDFORDATE' then
    Result := GetConstByIDForDate(Params[0], Params[1])
  else if MethodName = 'GETVALUEBYNAMEFORDATE' then
    Result := GetConstByNameForDate(Params[0], Params[1])
  else if MethodName = 'SUMCURRSTR' then
    Result := GetSumCurr(Params[0], Params[1], 1, Params[2])
  else if MethodName = 'SUMCURRSTR2' then
    Result := GetSumCurr(Params[0], Params[1], 0, Params[2])
  else if MethodName = 'SUMFULLRUBSTR' then
    Result := GetFullRubSumStr(Params[0])
  else if MethodName = 'SUMRUBSTR' then
    Result := GetRubSumStr(Params[0])
  else if MethodName = 'SUMSTR' then
    Result := GetSumStr(Params[0], Params[1])
  else if MethodName = 'DATESTR' then
    Result := DateStr(Params[0])
  else if MethodName = 'GETFIOCASE' then
    Result := FIOCase(Params[0], Params[1], Params[2], Params[3], Params[4])
  else if MethodName = 'GETCOMPLEXCASE' then
    Result := ComplexCase(Params[0], Params[1]);
end;

constructor TFR4Functions.Create(AScript: TfsScript);
begin
  inherited Create(AScript);
  with AScript do
  begin
    AddMethod('function AdvString: String', CallMethod, 'Golden Software', 'ADVSTRING()/');
    AddMethod('function GETVALUEBYID(AnID: Integer): Variant', CallMethod, 'Golden Software', 'GETVALUEBYID(<Идентификатор>)/Возвращает значение константы по идентификатору');
    AddMethod('function GETVALUEBYNAME(AName: String): Variant', CallMethod, 'Golden Software', 'GETVALUEBYNAME(<Наименование>)/Возвращает значение константы по наименованию');
    AddMethod('function GETVALUEBYIDFORDATE(AnID: Integer; ADate: String): Variant', CallMethod, 'Golden Software',
      'GETVALUEBYIDFORDATE(<Идентификатор>, <Дата>)/Возвращает значение периодической константы по идентификатору на указанную дату');
    AddMethod('function GETVALUEBYNAMEFORDATE(AName: String; ADate: String): Variant', CallMethod, 'Golden Software',
      'GETVALUEBYNAMEFORDATE(<Наименование>, <Дата>)/Возвращает значение периодической константы по наименованию на указанную дату');
    AddMethod('function SUMCURRSTR(D1: Integer; D2: Currency, D3: Boolean): String', CallMethod, 'Golden Software',
      'SUMCURRSTR(<Ключ валюты>, <Сумма>, <Ноль копеек>)/Возвращает сумму валюты прописью. (Флаг указывает, возвращать ли ноль копеек)');
    AddMethod('function SUMCURRSTR2(D1: Integer; D2: Currency, D3: Boolean): String', CallMethod, 'Golden Software',
      'SUMCURRSTR2(<Ключ валюты>, <Сумма>, <0 копеек>)/Возвращает сумму валюты прописью, а копейки цифрами. (Флаг указывает, возвращать ли ноль копеек)');
    AddMethod('function SUMFULLRUBSTR(D: Currency): String', CallMethod, 'Golden Software',
      'SUMFULLRUBSTR(<Число>)/Возвращает сумму прописью со словом рублей и копейками в нужном падеже');
    AddMethod('function SUMRUBSTR(D: Currency): String', CallMethod, 'Golden Software',
      'SUMRUBSTR(<Число>)/Возвращает сумму прописью со словом рублей в нужном падеже');
    AddMethod('function SUMSTR(D1: Currency; D2: Integer): String', CallMethod, 'Golden Software',
      'SUMSTR(<Число>, <Количество знаков после запятой>)/Возвращает сумму прописью, количество знаков после запятой не больше трех.');
    AddMethod('function DATESTR(Date: Variant): String', CallMethod , 'Golden Software',
      'DATESTR(<Дата>)/Возвращает дату (месяц на русском языке)');
    AddMethod('function GETFIOCASE(LastName, FirstName, MiddleName: String; Sex, TheCase: Word): String', CallMethod, 'Golden Software',
      'GETFIOCASE(<Фамилия>, <Имя>, <Отчество>, <Пол(0 - мужской, 1 - женский)>, <Падеж(1-6)>)/Возвращает ФИО в нужном падеже.');
    AddMethod('function GETCOMPLEXCASE(TheWord: String; TheCase: Word): String', CallMethod, 'Golden Software',
      'GETCOMPLEXCASE(<Строка>, <Падеж(1-6)>)/Возвращает строку вида [[Определение] [Определение]...] Наименование [Остаток] в нужном падеже.');
  end;
end;

function TFR4Functions.DateStr(D: Variant): String;
begin
  try
    if VarType(D) = varDate then
      Result := DateToRusStr(D)
    else
      Result := '';
  except
    Result := '';
  end;
end;

function TFR4Functions.GetConstByID(const AnID: Integer): Variant;
begin
  Result := TgdcConst.QGetValueByID(AnID);
end;

function TFR4Functions.GetConstByIDForDate(const AnID: Integer;
  const ADate: String): Variant;
begin
  Result := TgdcConst.QGetValueByIDAndDate(AnID, StrToDate(ADate));
end;

function TFR4Functions.GetConstByName(const AName: String): Variant;
begin
  Result := TgdcConst.QGetValueByName(AName);
end;

function TFR4Functions.GetConstByNameForDate(const AName: String;
  const ADate: String): Variant;
begin
  Result := TgdcConst.QGetValueByNameAndDate(AName, StrToDate(ADate));
end;

function TFR4Functions.GetFullRubSumStr(D: Variant): String;
var
  N: Integer;
  F: Double;
begin
  try
    Result := GetRubSumStr(D);
    F := D;
    N := Round(Abs((F - Trunc(F))) * 100);
    if N <> 0 then
      Result := Result + ' ' + GetSumStr(N, 1) + ' ' + GetKopWord(N);
  except
    Result := '';
  end;
end;

function TFR4Functions.GetRubSumStr(D: Variant): String;
begin
  try
    Result := NameCase(GetSumStr(D)) + ' ' + GetRubbleWord(D);
  except
    Result := '';
  end;
end;

function TFR4Functions.GetSumCurr(D1, D2, D3: Variant;
  D4: Boolean): String;
var
  Num: Integer;
  Cent: String;

  function GetName(const Name: TNameSelector): String;
  var
    {$IFDEF GEDEMIN}
    gdcCurr: TgdcCurr;
    {$ENDIF}
  begin
    repeat
      if (Trunc(Num) mod 100 >= 20) or (Trunc(Num) mod 100 <= 10) then
      begin
        case Trunc(Num) mod 10 of
          1:
             if Name = nsCentName then
               Result := CacheFullCentName
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
        PChar('Укажите наименование целых и дробных единиц валюты ' +
          CacheName + ' в справочнике валют.'),
        'Внимание',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);

      {$IFDEF GEDEMIN}
      gdcCurr := TgdcCurr.Create(nil);
      try
        gdcCurr.SubSet := 'ByID';
        gdcCurr.ParamByName('ID').AsInteger := CacheID;
        gdcCurr.Open;
        if gdcCurr.EOF then
          break;
        if not gdcCurr.EditDialog then
          break;
        CacheDBID := -1;
        UpdateCache(CacheID);
      finally
        gdcCurr.Free;
      end;
      {$ELSE}
      break;
      {$ENDIF}

    until False;
  end;

begin
  UpdateCache(VarAsType(D1, varInteger));

  if CacheID = -1 then
    Result := ''
  else begin
    Num := Trunc(Abs(D2));
    Result := GetName(nsName);
    Num := Round(Abs((Double(D2) - Trunc(D2))) * 100);
    Result := NameCase(GetSumStr(D2)) + ' ' + Result;
    if (Num <> 0) or D4 then
    begin
      if D3 = 1 then
        Cent := GetSumStr(Num)
      else
      begin
        Cent := IntToStr(Num);
        if Length(Cent) = 1 then
          Cent := '0' + Cent;
      end;
      Result := Result + ' ' + Cent + ' ' + GetName(nsCentName);
    end;
  end;
end;

function TFR4Functions.GetSumStr(D1: Variant; D2: Byte): String;
begin
  if NumberConvert = nil then
  begin
    NumberConvert := TNumberConvert.Create(nil);
    NumberConvert.Language := lRussian;
  end;

  if VarIsNull(D1) then
    raise Exception.Create('В функцию GetSumStr передано значение NULL.');

  NumberConvert.Value := D1;
  NumberConvert.Precision := D2;
  if (D2 > 0)  then
    NumberConvert.Gender := gFemale
  else
    NumberConvert.Gender := gMale;
  Result := NumberConvert.Numeral;
end;

procedure TFR4Functions.UpdateCache(const AnID: Integer);
var
  q: TIBSQL;
begin
  Assert(Assigned(IBLogin));

  if (AnID <> CacheID)
    or (CacheDBID <> IBLogin.DBID)
    or (GetTickCount - CacheTime > 4 * 60 * 1000) then
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcBaseManager.ReadTransaction;
      q.SQL.Text := 'SELECT * FROM gd_curr WHERE id = :ID';
      q.ParamByName('ID').AsInteger := AnID;
      q.ExecQuery;
      if not q.EOF then
      begin
        CacheFullCentName := q.FieldByName('FULLCENTNAME').AsString;
        CacheName := q.FieldByName('name').AsString;
        CacheCentName_0 := q.FieldByName('centname_0').AsString;
        CacheCentName_1 := q.FieldByName('centname_1').AsString;
        CacheName_0 := q.FieldByName('name_0').AsString;
        CacheName_1 := q.FieldByName('name_1').AsString;

        CacheID := AnID;
        CacheDBID := IBLogin.DBID;
        CacheTime := GetTickCount;
      end else
      begin
        CacheID := -1;
      end;
    finally
      q.Free;
    end;
  end;
end;

initialization
  fsRTTIModules.Add(TFR4Functions);

end.
 