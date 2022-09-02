// ShlTanya, 27.02.2019

unit rp_FR4Functions;

interface

uses
  SysUtils, Classes, Windows, Forms, fs_iinterpreter, gdcBaseInterface;

type
  TFR4Functions = class(TfsRTTIModule)
  private
    FCompanyCachedKey, FCompanyCachedDBID: TID;
    FCompanyCachedTime: DWORD;

    FCompanyName, FCompanyFullName, FCompanyAddress,
    FDirectorName, FChiefAccountantName, FTAXID,
    FDirectorRank, FChiefAccountantRank, FBankName, FBankAddress,
    FMainAccount, FBankCode: String;

    function CallMethod(Instance: TObject; ClassType: TClass;
      const MethodName: String; var Params: Variant): Variant;

  public
    //Константы
    function GetConstByName(const AName: String): Variant;
    function GetConstByID(const AnID: TID): Variant;
    function GetConstByNameForDate(const AName: String; const ADate: String): Variant;
    function GetConstByIDForDate(const AnID: TID; const ADate: String): Variant;

    //Денежные
    function GetSumCurr(D1, D2, D3: Variant; D4: Boolean = False): String;
    function GetSumStr(D1: Variant; D2: Byte = 0): String;
    function GetSumStr2(D1: Variant; const D2: String; D3: Integer): String;
    function GetRubSumStr(D: Variant): String;
    function GetFullRubSumStr(D: Variant): String;

    //Дата
    function DateStr(D: Variant): String;

    //Остальные
    function AdvString: String;

    function CompanyName: String;
    function CompanyFullName: String;
    function CompanyAddress: String;
    function DirectorName: String;
    function ChiefAccountantName: String;
    function ContactName: String;
    function TAXID: String;
    function DirectorRank: String;
    function ChiefAccountantRank: String;
    function BankName: String;
    function BankAddress: String;
    function MainAccount: String;
    function BankCode: String;

    procedure UpdateCompanyCache;

    function GetNameInitials(AFamilyName, AGivenName, AMiddleName: String;
      const ALeading: Boolean; const ASpace: String): String;

    constructor Create(AScript: TfsScript); override;
  end;

implementation

uses
  gdcConst, IBSQL, gd_security, gsMorph, gd_convert, NumConv;

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

{ TFR4Functions }

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
  Result := 'Подготовлено в системе Гедымин. Тел.: +375-17-2561759, 2562783. http://gsbelarus.com © 1994-2022 by Golden Software';
end;

function TFR4Functions.CallMethod(Instance: TObject; ClassType: TClass;
  const MethodName: String; var Params: Variant): Variant;
var
  MiddleName: String;
begin
  if MethodName = 'ADVSTRING' then
    Result := AdvString
  else if MethodName = 'GETVALUEBYID' then
    Result := GetConstByID(GetTID(Params[0]))
  else if MethodName = 'GETVALUEBYNAME' then
    Result := GetConstByName(Params[0])
  else if MethodName = 'GETVALUEBYIDFORDATE' then
    Result := GetConstByIDForDate(GetTID(Params[0]), Params[1])
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
  else if MethodName = 'SUMSTR2' then
    Result := GetSumStr2(Params[0], Params[1], Params[2])
  else if MethodName = 'DATESTR' then
    Result := DateStr(Params[0])
  else if MethodName = 'GETFIOCASE' then
  begin
    // issue 4277
    if (VarType(Params[2]) = varString) or (VarType(Params[2]) = varOleStr) then
      MiddleName := Params[2]
    else
      MiddleName := '';
    Result := FIOCase(Params[0], Params[1], MiddleName, Params[3], Params[4]);
  end else if MethodName = 'GETCOMPLEXCASE' then
    Result := ComplexCase(Params[0], Params[1])
  else if MethodName = 'GETNUMERICWORDFORM' then
    Result := gsMorph.GetNumericWordForm(Params[0], Params[1], Params[2], Params[3])
  else if MethodName = 'COMPANYNAME' then
    Result := CompanyName
  else if MethodName = 'COMPANYFULLNAME' then
    Result := CompanyFullName
  else if MethodName = 'CHIEFACCOUNTANTNAME' then
    Result := ChiefAccountantName
  else if MethodName = 'COMPANYADDRESS' then
    Result := CompanyAddress
  else if MethodName = 'DIRECTORNAME' then
    Result := DirectorName
  else if MethodName = 'CONTACTNAME' then
    Result := ContactName
  else if MethodName = 'TAXID' then
    Result := TAXID
  else if MethodName = 'DIRECTORRANK' then
    Result := DirectorRank
  else if MethodName = 'CHIEFACCOUNTANTRANK' then
    Result := ChiefAccountantRank
  else if MethodName = 'BANKNAME' then
    Result := BankName
  else if MethodName = 'BANKADDRESS' then
    Result := BankAddress
  else if MethodName = 'MAINACCOUNT' then
    Result := MainAccount
  else if MethodName = 'BANKCODE' then
    Result := BankCode
  else if MethodName = 'GETNAMEINITIALS' then
    Result := GetNameInitials(Params[0], Params[1], Params[2], Params[3], Params[4])
  else if MethodName = 'GETNUMERAL' then
    Result := GetNumeral(Params[0], Params[1], Params[2], Params[3], Params[4], Params[5], Params[6])
  else if MethodName = 'GETCURRNUMERAL' then
    Result := GetCurrNumeral(GetTID(Params[0]), Params[1], Params[2], Params[3], Params[4], Params[5], Params[6], Params[7], Params[8])
  else if MethodName = 'MULDIV' then
    Result := gd_convert.MulDiv(Params[0], Params[1], Params[2], Params[3], Params[4]);
end;

function TFR4Functions.ChiefAccountantName: String;
begin
  UpdateCompanyCache;
  Result := FChiefAccountantName;
end;

function TFR4Functions.CompanyAddress: String;
begin
  UpdateCompanyCache;
  Result := FCompanyAddress;
end;

function TFR4Functions.CompanyFullName: String;
begin
  UpdateCompanyCache;
  Result := FCompanyFullName;
end;

function TFR4Functions.CompanyName: String;
begin
  UpdateCompanyCache;
  Result := FCompanyName;
end;

function TFR4Functions.ContactName: String;
begin
  Result := IBLogin.ContactName;
end;

function TFR4Functions.DirectorName: String;
begin
  UpdateCompanyCache;
  Result := FDirectorName;
end;

function TFR4Functions.TAXID: String;
begin
  UpdateCompanyCache;
  Result := FTAXID;
end;

function TFR4Functions.ChiefAccountantRank: String;
begin
  UpdateCompanyCache;
  Result := FChiefAccountantRank;
end;

function TFR4Functions.DirectorRank: String;
begin
  UpdateCompanyCache;
  Result := FDirectorRank;
end;

function TFR4Functions.BankAddress: String;
begin
  UpdateCompanyCache;
  Result := FBankAddress;
end;

function TFR4Functions.BankName: String;
begin
  UpdateCompanyCache;
  Result := FBankName;
end;

function TFR4Functions.MainAccount: String;
begin
  UpdateCompanyCache;
  Result := FMainAccount;
end;

function TFR4Functions.BankCode: String;
begin
  UpdateCompanyCache;
  Result := FBankCode;
end;

constructor TFR4Functions.Create(AScript: TfsScript);
begin
  inherited Create(AScript);

  with AScript do
  begin
    AddMethod('function AdvString: String', CallMethod, 'Golden Software', 'ADVSTRING()/');
    AddMethod('function GETVALUEBYID(AnID: TID): Variant', CallMethod, 'Golden Software', 'GETVALUEBYID(<Идентификатор>)/Возвращает значение константы по идентификатору');
    AddMethod('function GETVALUEBYNAME(AName: String): Variant', CallMethod, 'Golden Software', 'GETVALUEBYNAME(<Наименование>)/Возвращает значение константы по наименованию');
    AddMethod('function GETVALUEBYIDFORDATE(AnID: TID; ADate: String): Variant', CallMethod, 'Golden Software',
      'GETVALUEBYIDFORDATE(<Идентификатор>, <Дата>)/Возвращает значение периодической константы по идентификатору на указанную дату');
    AddMethod('function GETVALUEBYNAMEFORDATE(AName: String; ADate: String): Variant', CallMethod, 'Golden Software',
      'GETVALUEBYNAMEFORDATE(<Наименование>, <Дата>)/Возвращает значение периодической константы по наименованию на указанную дату');
    AddMethod('function SUMCURRSTR(D1: Integer; D2: Currency, D3: Boolean): String', CallMethod, 'Golden Software',
      'SUMCURRSTR(<ИД валюты>, <Сумма>, <Выводить или нет ноль копеек>)/Возвращает сумму валюты прописью.');
    AddMethod('function SUMCURRSTR2(D1: Integer; D2: Currency, D3: Boolean): String', CallMethod, 'Golden Software',
      'SUMCURRSTR2(<ИД валюты>, <Сумма>, <Выводить или нет ноль копеек>)/Возвращает сумму валюты прописью (копейки цифрами).');
    AddMethod('function SUMFULLRUBSTR(D: Currency): String', CallMethod, 'Golden Software',
      'SUMFULLRUBSTR(<Число>)/Возвращает сумму прописью со словом рублей и копейками в нужном падеже');
    AddMethod('function SUMRUBSTR(D: Currency): String', CallMethod, 'Golden Software',
      'SUMRUBSTR(<Число>)/Возвращает сумму прописью со словом рублей в нужном падеже');
    AddMethod('function SUMSTR(D1: Currency; D2: Integer): String', CallMethod, 'Golden Software',
      'SUMSTR(<Число>, <Количество десятичных знаков>)/Возвращает число прописью, количество знаков после запятой должно быть не больше трех.');
    AddMethod('function SUMSTR2(D1: Currency; D2: String; D3: Integer): String', CallMethod, 'Golden Software',
      'SUMSTR2(<Число> , <Пустая строка. Не используется>, <Род: 0 - мужской, 1 - женский, 2 - средний>)/Число прописью для заданного рода.') ;
    AddMethod('function DATESTR(Date: Variant): String', CallMethod , 'Golden Software',
      'DATESTR(<Дата>)/Возвращает дату (месяц на русском языке)');
    AddMethod('function GETFIOCASE(LastName, FirstName, MiddleName: String; Sex, TheCase: Word): String', CallMethod, 'Golden Software',
      'GETFIOCASE(<Фамилия>, <Имя>, <Отчество>, <Пол(0 - мужской, 1 - женский)>, <Падеж(1-6)>)/Возвращает ФИО в нужном падеже.');
    AddMethod('function GETCOMPLEXCASE(TheWord: String; TheCase: Word): String', CallMethod, 'Golden Software',
      'GETCOMPLEXCASE(<Строка>, <Падеж(1-6)>)/Возвращает строку вида [[Определение] [Определение]...] Наименование [Остаток] в нужном падеже.');
    AddMethod('function GETNUMERICWORDFORM(ANum: Integer; const AStrForm1, AStrForm2, AStrForm5: String): String', CallMethod, 'Golden Software',
      'GETNUMERICWORDFORM(<Целое число>, <Форма для одного объекта>, <... для двух>, <... для пяти>)/Возвращает переданное существительное в форме соответствующей переданному числу.');
    AddMethod('function COMPANYNAME: String', CallMethod, 'Golden Software', 'COMPANYNAME()/Возвращает название текущей организации.');
    AddMethod('function COMPANYFULLNAME: String', CallMethod, 'Golden Software', 'COMPANYFULLNAME()/Возвращает полное название текущей организации.');
    AddMethod('function COMPANYADDRESS: String', CallMethod, 'Golden Software', 'COMPANYADDRESS()/Возвращает адрес текущей организации.');
    AddMethod('function DIRECTORNAME: String', CallMethod, 'Golden Software', 'DIRECTORNAME()/Возвращает ФИО директора текущей организации.');
    AddMethod('function CHIEFACCOUNTANTNAME: String', CallMethod, 'Golden Software', 'CHIEFACCOUNTANTNAME()/Возвращает ФИО гл.бухгалтера текущей организации.');
    AddMethod('function CONTACTNAME: String', CallMethod, 'Golden Software', 'CONTACTNAME()/Возвращает ФИО текущего пользователя.');
    AddMethod('function TAXID: String', CallMethod, 'Golden Software', 'TAXID()/Возвращает УНП текущей организации.');
    AddMethod('function DIRECTORRANK: String', CallMethod, 'Golden Software', 'DIRECTORRANK()/Возвращает должность директора текущей организации.');
    AddMethod('function CHIEFACCOUNTANTRANK: String', CallMethod, 'Golden Software', 'CHIEFACCOUNTANTRANK()/Возвращает должность бухгалтера текущей организации.');
    AddMethod('function BANKNAME: String', CallMethod, 'Golden Software', 'BANKNAME()/Возвращает наименование банка текущей организации.');
    AddMethod('function BANKADDRESS: String', CallMethod, 'Golden Software', 'BANKADDRESS()/Возвращает адрес банка текущей организации.');
    AddMethod('function MAINACCOUNT: String', CallMethod, 'Golden Software', 'MAINACCOUNT()/Возвращает главный счёт текущей организации.');
    AddMethod('function BANKCODE: String', CallMethod, 'Golden Software', 'BANKCODE()/Возвращает код банка текущей организации.');
    AddMethod('function GETNAMEINITIALS(AFamilyName, AGivenName, AMiddleName: String; const ALeading: Boolean; const ASpace: String): String',
      CallMethod, 'Golden Software',
      'GETNAMEINITIALS(<Фамилия или Полное имя>, <Имя>, <Отчество>, <Сначала инициалы>, <Разделитель инициалов>)/Возвращает строку вида "Фамилия И.О."');
    AddMethod('function GetNumeral(const AFormat: String; AValue: Double; const ARounding: Double; const AFracBase: Integer; const ACase: Integer; const AParts: Integer; const ANames: String): String',
      CallMethod, 'Golden Software',
      'GETNUMERAL(<Формат>, <Значение>, <Округление>, <База дробной величины, дес. знаков>, <Регистр>, <Флаги>, <Названия>)/Возвращает числительное.');
    AddMethod('function GetCurrNumeral(const ACurrKey: TID; const AFormat: String; AValue: Double; const ARounding: Double; const ACase: Integer; const AParts: Integer; const ASubst: String; const ADecimalSeparator: String; const AThousandSeparator: String): String',
      CallMethod, 'Golden Software',
      'GETCURRNUMERAL(<ИД валюты>, <Формат>, <Значение>, <Регистр>, <Флаги>, <Подстановка 0>, <Дес. разделитель>, <Разделитель тысяч>)/Возвращает денежную величину как числительное.');
    AddMethod('function MulDiv(const Number: Double; const ANumerator: Double; const ADenominator: Double; const ARoundMethod: Integer; const ADecPlaces: Integer): Double',
      CallMethod, 'Golden Software',
      'MULDIV(<Число>, <Множитель>, <Делитель>, <Способ округления>, <Десятичные цифры>)/Умножает два числа и делит на третье. Если задано, результат округляется.');
  end;

  FCompanyCachedKey := -1;
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

function TFR4Functions.GetConstByID(const AnID: TID): Variant;
begin
  Result := TgdcConst.QGetValueByID(AnID);
end;

function TFR4Functions.GetConstByIDForDate(const AnID: TID;
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
begin
  try
    Result := gd_convert.GetFullRubSumStr(D);
  except
    Result := '';
  end;
end;

function TFR4Functions.GetRubSumStr(D: Variant): String;
begin
  try
    Result := gd_convert.GetRubSumStr(D);
  except
    Result := '';
  end;
end;

function TFR4Functions.GetSumCurr(D1, D2, D3: Variant; D4: Boolean): String;
begin
  if VarType(D3) = varBoolean then
    Result := gd_convert.GetSumCurr(GetTID(D1), D2, D3, D4)
  else
    Result := gd_convert.GetSumCurr(GetTID(D1), D2, D3 <> 0, D4);
end;

function TFR4Functions.GetSumStr(D1: Variant; D2: Byte): String;
begin
  if VarIsNull(D1) then
    raise Exception.Create('В функцию GetSumStr передано значение NULL.');

  Result := gd_convert.GetSumStr(D1, D2);
end;

function TFR4Functions.GetSumStr2(D1: Variant; const D2: String; D3: Integer): String;
var
  GD: TGender;
begin
  if VarIsNull(D1) then
    raise Exception.Create('В функцию GetSumStr2 передано значение NULL.');

  if D3 = gdMasculine then
    GD := gMale
  else if D3 = gdFeminine then
    GD := gFemale
  else if D3 = gdMedium then
    GD := gNeuter
  else
    raise Exception.Create('Неверно указан род числительного!');

  Result := gd_convert.GetSumStr2(D1, GD);
end;

procedure TFR4Functions.UpdateCompanyCache;
var
  q: TIBSQL;
begin
  Assert(Assigned(IBLogin));

  if (FCompanyCachedKey <> IBLogin.CompanyKey) or (FCompanyCachedDBID <> IBLogin.DBID)
    or (GetTickCount - FCompanyCachedTime > CacheFlushInterval) then
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcBaseManager.ReadTransaction;
      q.SQL.Text :=
        'SELECT ' +
        '  C.ID, C.NAME, COMP.FULLNAME AS COMPFULLNAME, COMP.COMPANYTYPE, ' +
        '  C.ADDRESS, C.CITY, C.COUNTRY, C.PHONE, C.FAX, ' +
        '  AC.ACCOUNT, BANK.BANKCODE, BANK.BANKMFO, ' +
        '  BANKC.NAME AS BANKNAME, BANKC.ADDRESS AS BANKADDRESS, BANKC.CITY, BANKC.COUNTRY, ' +
        '  CC.TAXID, CC.OKPO, CC.LICENCE, CC.OKNH, CC.SOATO, CC.SOOU, ' +
        '  DIRECTOR.NAME AS DirectorName, IIF(DIRECTORPOS.NAME IS NOT NULL, DIRECTORPOS.NAME, ''Директор'') AS DIRPOS, ' +
        '  BUH.NAME AS BUHNAME, IIF(BUHPOS.NAME IS NOT NULL, BUHPOS.NAME, ''Гл. бухгалтер'') AS BUHPOS ' +
        'FROM ' +
        '  GD_CONTACT C ' +
        '  JOIN GD_COMPANY COMP ON COMP.CONTACTKEY = C.ID ' +
        '  LEFT JOIN GD_COMPANYACCOUNT AC ON COMP.COMPANYACCOUNTKEY = AC.ID ' +
        '  LEFT JOIN GD_BANK BANK ON AC.BANKKEY = BANK.BANKKEY ' +
        '  LEFT JOIN GD_COMPANYCODE CC ON COMP.CONTACTKEY = CC.COMPANYKEY ' +
        '  LEFT JOIN GD_CONTACT BANKC ON BANK.BANKKEY = BANKC.ID ' +
        '  LEFT JOIN GD_CONTACT DIRECTOR ON DIRECTOR.ID = COMP.DIRECTORKEY ' +
        '  LEFT JOIN GD_PEOPLE DIRECTOREMPL ON DIRECTOREMPL.CONTACTKEY = DIRECTOR.ID ' +
        '  LEFT JOIN WG_POSITION DIRECTORPOS ON DIRECTORPOS.ID = DIRECTOREMPL.WPOSITIONKEY ' +
        '  LEFT JOIN GD_CONTACT BUH ON BUH.ID = COMP.CHIEFACCOUNTANTKEY ' +
        '  LEFT JOIN GD_PEOPLE BUHEMPL ON BUHEMPL.CONTACTKEY = BUH.ID ' +
        '  LEFT JOIN WG_POSITION BUHPOS ON BUHPOS.ID = BUHEMPL.WPOSITIONKEY ' +
        'WHERE C.ID = :ID ';
      SetTID(q.ParamByName('ID'), IBLogin.CompanyKey);
      q.ExecQuery;
      if not q.EOF then
      begin
        FCompanyName := q.FieldByName('NAME').AsString;
        FCompanyFullName := q.FieldByName('COMPFULLNAME').AsString;
        FCompanyAddress := q.FieldByName('ADDRESS').AsString;
        FDirectorName := q.FieldByName('DirectorName').AsString;
        FChiefAccountantName := q.FieldByName('BUHNAME').AsString;
        FTAXID := q.FieldByName('TAXID').AsString;
        FDirectorRank := q.FieldByName('DIRPOS').AsString;
        FChiefAccountantRank := q.FieldByName('BUHPOS').AsString;
        FBankName := q.FieldByName('BANKNAME').AsString;
        FBankAddress := q.FieldByName('BANKADDRESS').AsString;
        FMainAccount := q.FieldByName('ACCOUNT').AsString;
        FBankCode := q.FieldByName('BANKCODE').AsString;

        FCompanyCachedKey := IBLogin.CompanyKey;
      end else
      begin
        FCompanyCachedKey := -1;
        FCompanyName := '';
        FCompanyFullName := '';
        FCompanyAddress := '';
        FDirectorName := '';
        FChiefAccountantName := '';
        FTAXID := '';
        FDirectorRank := 'Директор';
        FChiefAccountantRank := 'Гл. бухгалтер';
        FBankName := '';
        FBankAddress := '';
        FMainAccount := '';
        FBankCode := '';
      end;

      FCompanyCachedDBID := IBLogin.DBID;
      FCompanyCachedTime := GetTickCount;
    finally
      q.Free;
    end;
  end;
end;

function TFR4Functions.GetNameInitials(AFamilyName, AGivenName,
  AMiddleName: String; const ALeading: Boolean; const ASpace: String): String;
var
  B, E, I: Integer;
  S: array[1..3] of String;
  P: array[1..3] of Boolean;
begin
  AFamilyName := Trim(AFamilyName);

  for I := 1 to 3 do
  begin
    S[I] := '';
    P[I] := False;
  end;

  B := 1;
  E := 1;
  I := 1;
  while (I <= 3) and (E <= Length(AFamilyName)) do
  begin
    if AFamilyName[E] = '.' then
    begin
      S[I] := Copy(AFamilyName, B, E - B);
      P[I] := True;
      Inc(I);

      B := E + 1;
      while (B <= Length(AFamilyName)) and (AFamilyName[B] = ' ') do
        Inc(B);
      E := B + 1;
    end
    else if AFamilyName[E] = ' ' then
    begin
      S[I] := Copy(AFamilyName, B, E - B);
      Inc(I);

      B := E + 1;
      while (B <= Length(AFamilyName)) and (AFamilyName[B] = ' ') do
        Inc(B);
      E := B + 1;
    end else
      Inc(E);
  end;

  if I <= 3 then
    S[I] := Copy(AFamilyName, B, 255);

  // И.О. Фамилия
  if (S[1] > '') and P[1] and (S[2] > '') and P[2] and (S[3] > '') then
  begin
    AGivenName := S[1];
    AMiddleName := S[2];
    AFamilyName := S[3];
  end
  // Фамилия И.О. или Фамилия Имя Отчество
  else if (S[1] > '') and (not P[1]) and (S[2] > '') then
  begin
    AFamilyName := S[1];
    AGivenName := S[2];
    AMiddleName := S[3];
  end
  // И. Фамилия
  else if (S[1] > '') and P[1] and (S[2] > '') and (S[3] = '') then
  begin
    AGivenName := S[1];
    AFamilyName := S[2];
    AMiddleName := '';
  end else
  begin
    AGivenName := Trim(AGivenName);
    AMiddleName := Trim(AMiddleName);
  end;

  if AGivenName > '' then
  begin
    Result := Copy(AGivenName, 1, 1) + '.';
    if AMiddleName > '' then
      Result := Result + ASpace + Copy(AMiddleName, 1, 1) + '.';
  end else
    Result := '';

  if ALeading then
  begin
    if Result > '' then
      Result := Result + ' ';
    Result := Result + AFamilyName;
  end else
  begin
    if Result > '' then
      AFamilyName := AFamilyName + ' ';
    Result := AFamilyName + Result;
  end;
end;

initialization
  fsRTTIModules.Add(TFR4Functions);
end.
