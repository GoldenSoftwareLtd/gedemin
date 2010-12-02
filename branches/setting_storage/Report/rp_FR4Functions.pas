unit rp_FR4Functions;

interface

uses
  SysUtils, Classes, Windows, Forms, fs_iinterpreter,
  NumConv;

type
  TFR4Functions = class(TfsRTTIModule)
  private
    NumberConvert: TNumberConvert;

    FCompanyCachedKey, FCompanyCachedDBID: Integer;
    FCompanyCachedTime: DWORD;

    FCurrCachedKey, FCurrCachedDBID: Integer;
    FCurrCachedTime: DWORD;

    CacheName, CacheFullCentName,
    CacheName_0, CacheName_1,
    CacheCentName_0, CacheCentName_1: String;

    FCompanyName, FCompanyFullName, FCompanyAddress,
    FDirName, FChiefAccountantName, FTAXID,
    FDirRank, FBuhRank, FBankName, FBankAddress,
    FMainAccount, FBankCode: String;

    function CallMethod(Instance: TObject; ClassType: TClass;
      const MethodName: String; var Params: Variant): Variant;

    //���������
    function GetConstByName(const AName: String): Variant;
    function GetConstByID(const AnID: Integer): Variant;
    function GetConstByNameForDate(const AName: String; const ADate: String): Variant;
    function GetConstByIDForDate(const AnID: Integer; const ADate: String): Variant;

    //��������
    procedure UpdateCache(const AnID: Integer);

    function GetSumCurr(D1, D2, D3: Variant; D4: Boolean = False): String;
    function GetSumStr(D1: Variant; D2: Byte = 0): String;
    function GetSumStr2(D1: Variant; const D2: String; D3: Integer): String;
    function GetRubSumStr(D: Variant): String;
    function GetFullRubSumStr(D: Variant): String;

    //����
    function DateStr(D: Variant): String;

    //���������
    function AdvString: String;

    function CompanyName: String;
    function CompanyFullName: String;
    function CompanyAddress: String;
    function DirName: String;
    function ChiefAccountantName: String;
    function ContactName: String;
    function TAXID: String;
    function DirRank: String;
    function BuhRank: String;
    function BankName: String;
    function BankAddress: String;
    function MainAccount: String;
    function BankCode: String;

    procedure UpdateCompanyCache;

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
    '������',
    '�������',
    '�����',
    '������',
    '���',
    '����',
    '����',
    '�������',
    '��������',
    '�������',
    '������',
    '�������'
  );

  CacheFlushInterval = 120 * 60 * 1000; //2 hrs in msec

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
      1: Result := '�����';
      2, 3, 4: Result := '�����';
    else
      Result := '������';
    end
  else
    Result := '������';
end;

function GetKopWord(Value: Double): String;
var
  Num: Integer;
begin
  Num := Trunc(Abs(Value));

  if (Trunc(Num) mod 100 >= 20) or (Trunc(Num) mod 100 <= 10) then
    case Trunc(Num) mod 10 of
      1: Result := '�������';
      2, 3, 4: Result := '�������';
    else
      Result := '������';
    end
  else
    Result := '������';
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
  Result := '������������ � ������� �������. ���.: (017) 256-17-59, 256-27-83. http://gsbelarus.com � Golden Software of Belarus Ltd. ';
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
  else if MethodName = 'SUMSTR2' then
    Result := GetSumStr2(Params[0], Params[1], Params[2])
  else if MethodName = 'DATESTR' then
    Result := DateStr(Params[0])
  else if MethodName = 'GETFIOCASE' then
    Result := FIOCase(Params[0], Params[1], Params[2], Params[3], Params[4])
  else if MethodName = 'GETCOMPLEXCASE' then
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
    Result := DirName
  else if MethodName = 'CONTACTNAME' then
    Result := ContactName
  else if MethodName = 'TAXID' then
    Result := TAXID
  else if MethodName = 'DIRECTORRANK' then
    Result := DirRank
  else if MethodName = 'CHIEFACCOUNTANTRANK' then
    Result := BuhRank
  else if MethodName = 'BANKNAME' then
    Result := BankName
  else if MethodName = 'BANKADDRESS' then
    Result := BankAddress
  else if MethodName = 'MAINACCOUNT' then
    Result := MainAccount
  else if MethodName = 'BANKCODE' then
    Result := BankCode;
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

function TFR4Functions.DirName: String;
begin
  UpdateCompanyCache;
  Result := FDirName;
end;

function TFR4Functions.TAXID: String;
begin
  UpdateCompanyCache;
  Result := FTAXID;
end;

function TFR4Functions.BuhRank: String;
begin
  UpdateCompanyCache;
  Result := FBuhRank;
end;

function TFR4Functions.DirRank: String;
begin
  UpdateCompanyCache;
  Result := FDirRank;
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
    AddMethod('function GETVALUEBYID(AnID: Integer): Variant', CallMethod, 'Golden Software', 'GETVALUEBYID(<�������������>)/���������� �������� ��������� �� ��������������');
    AddMethod('function GETVALUEBYNAME(AName: String): Variant', CallMethod, 'Golden Software', 'GETVALUEBYNAME(<������������>)/���������� �������� ��������� �� ������������');
    AddMethod('function GETVALUEBYIDFORDATE(AnID: Integer; ADate: String): Variant', CallMethod, 'Golden Software',
      'GETVALUEBYIDFORDATE(<�������������>, <����>)/���������� �������� ������������� ��������� �� �������������� �� ��������� ����');
    AddMethod('function GETVALUEBYNAMEFORDATE(AName: String; ADate: String): Variant', CallMethod, 'Golden Software',
      'GETVALUEBYNAMEFORDATE(<������������>, <����>)/���������� �������� ������������� ��������� �� ������������ �� ��������� ����');
    AddMethod('function SUMCURRSTR(D1: Integer; D2: Currency, D3: Boolean): String', CallMethod, 'Golden Software',
      'SUMCURRSTR(<���� ������>, <�����>, <���� ������>)/���������� ����� ������ ��������. (���� ���������, ���������� �� ���� ������)');
    AddMethod('function SUMCURRSTR2(D1: Integer; D2: Currency, D3: Boolean): String', CallMethod, 'Golden Software',
      'SUMCURRSTR2(<���� ������>, <�����>, <0 ������>)/���������� ����� ������ ��������, � ������� �������. (���� ���������, ���������� �� ���� ������)');
    AddMethod('function SUMFULLRUBSTR(D: Currency): String', CallMethod, 'Golden Software',
      'SUMFULLRUBSTR(<�����>)/���������� ����� �������� �� ������ ������ � ��������� � ������ ������');
    AddMethod('function SUMRUBSTR(D: Currency): String', CallMethod, 'Golden Software',
      'SUMRUBSTR(<�����>)/���������� ����� �������� �� ������ ������ � ������ ������');
    AddMethod('function SUMSTR(D1: Currency; D2: Integer): String', CallMethod, 'Golden Software',
      'SUMSTR(<�����>, <���������� ������ ����� �������>)/���������� ����� ��������, ���������� ������ ����� ������� �� ������ ����.');
    AddMethod('function SUMSTR2(D1: Currency; D2: String; D3: Integer): String', CallMethod, 'Golden Software',
      'SUMSTR2(<�����> , <��������������� ��� ����������� ����>/��. �. ��. ����� , <���>/���� ������ �������� �� �����. 0 - ���, 1 - ���, 2 - ��.') ;
    AddMethod('function DATESTR(Date: Variant): String', CallMethod , 'Golden Software',
      'DATESTR(<����>)/���������� ���� (����� �� ������� �����)');
    AddMethod('function GETFIOCASE(LastName, FirstName, MiddleName: String; Sex, TheCase: Word): String', CallMethod, 'Golden Software',
      'GETFIOCASE(<�������>, <���>, <��������>, <���(0 - �������, 1 - �������)>, <�����(1-6)>)/���������� ��� � ������ ������.');
    AddMethod('function GETCOMPLEXCASE(TheWord: String; TheCase: Word): String', CallMethod, 'Golden Software',
      'GETCOMPLEXCASE(<������>, <�����(1-6)>)/���������� ������ ���� [[�����������] [�����������]...] ������������ [�������] � ������ ������.');
    AddMethod('function GETNUMERICWORDFORM(ANum: Integer; const AStrForm1, AStrForm2, AStrForm5: String): String', CallMethod, 'Golden Software',
      'GETNUMERICWORDFORM(<����� �����>, <����� ��� ������ �������>, <... ��� ����>, <... ��� ����>)/���������� ���������� ��������������� � ����� ��������������� ����������� �����.');
    AddMethod('function COMPANYNAME: String', CallMethod, 'Golden Software', 'COMPANYNAME()/���������� �������� ������� �����������.');
    AddMethod('function COMPANYFULLNAME: String', CallMethod, 'Golden Software', 'COMPANYFULLNAME()/���������� ������ �������� ������� �����������.');
    AddMethod('function COMPANYADDRESS: String', CallMethod, 'Golden Software', 'COMPANYADDRESS()/���������� ����� ������� �����������.');
    AddMethod('function DIRECTORNAME: String', CallMethod, 'Golden Software', 'DIRECTORNAME()/���������� ��� ��������� ������� �����������.');
    AddMethod('function CHIEFACCOUNTANTNAME: String', CallMethod, 'Golden Software', 'CHIEFACCOUNTANTNAME()/���������� ��� ��.���������� ������� �����������.');
    AddMethod('function CONTACTNAME: String', CallMethod, 'Golden Software', 'CONTACTNAME()/���������� ��� �������� ������������.');
    AddMethod('function TAXID: String', CallMethod, 'Golden Software', 'TAXID()/���������� ��� ������� �����������.');
    AddMethod('function DIRECTORRANK: String', CallMethod, 'Golden Software', 'DIRECTORRANK()/���������� ��������� ��������� ������� �����������.');
    AddMethod('function CHIEFACCOUNTANTRANK: String', CallMethod, 'Golden Software', 'CHIEFACCOUNTANTRANK()/���������� ��������� ���������� ������� �����������.');
    AddMethod('function BANKNAME: String', CallMethod, 'Golden Software', 'BANKNAME()/���������� ������������ ����� ������� �����������.');
    AddMethod('function BANKADDRESS: String', CallMethod, 'Golden Software', 'BANKADDRESS()/���������� ����� ����� ������� �����������.');
    AddMethod('function MAINACCOUNT: String', CallMethod, 'Golden Software', 'MAINACCOUNT()/���������� ������� ���� ������� �����������.');
    AddMethod('function BANKCODE: String', CallMethod, 'Golden Software', 'BANKCODE()/���������� ��� ����� ������� �����������.');
  end;

  FCompanyCachedKey := -1;
  FCurrCachedKey := -1;
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
        PChar('������� ������������ ����� � ������� ������ ������ ' +
          CacheName + ' � ����������� �����.'),
        '��������',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);

      {$IFDEF GEDEMIN}
      gdcCurr := TgdcCurr.Create(nil);
      try
        gdcCurr.SubSet := 'ByID';
        gdcCurr.ParamByName('ID').AsInteger := FCurrCachedKey;
        gdcCurr.Open;
        if gdcCurr.EOF then
          break;
        if not gdcCurr.EditDialog then
          break;
        FCurrCachedDBID := -1;
        UpdateCache(FCurrCachedKey);
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

  if FCurrCachedKey = -1 then
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
    raise Exception.Create('� ������� GetSumStr �������� �������� NULL.');

  NumberConvert.Value := D1;
  NumberConvert.Precision := D2;
  if (D2 > 0)  then
    NumberConvert.Gender := gFemale
  else
    NumberConvert.Gender := gMale;
    Result := NumberConvert.Numeral;
end;

function TFR4Functions.GetSumStr2(D1: Variant; const D2: String; D3: Integer): String;
begin
  if VarIsNull(D1) then
    raise Exception.Create('�� ������� �������� ��������!');

  if (D3 < gdMasculine) or (D3 > gdMedium) then
    raise Exception.Create('������� ������ ��� �������������!');

  if NumberConvert = nil then
  begin
    NumberConvert := TNumberConvert.Create(nil);
    NumberConvert.Language := lRussian;
  end;

  NumberConvert.Value := D1;

  if D2 > '' then
  begin
    case D2[Length(D2)] of
      '�', '�', '�', '�', '�', '�': D3 := gdFeminine;
      '�', '�', '�', '�': D3 := gdMedium;
    else
      D3 := gdMasculine;
    end;
  end;

  NumberConvert.Gender := TGender(D3);

  Result := NumberConvert.Numeral;
end;

procedure TFR4Functions.UpdateCache(const AnID: Integer);
var
  q: TIBSQL;
begin
  Assert(Assigned(IBLogin));

  if (AnID <> FCurrCachedKey)
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
        CacheFullCentName := q.FieldByName('FULLCENTNAME').AsString;
        CacheName := q.FieldByName('name').AsString;
        CacheCentName_0 := q.FieldByName('centname_0').AsString;
        CacheCentName_1 := q.FieldByName('centname_1').AsString;
        CacheName_0 := q.FieldByName('name_0').AsString;
        CacheName_1 := q.FieldByName('name_1').AsString;

        FCurrCachedKey := AnID;
      end else
        FCurrCachedKey := -1;
        
      FCurrCachedDBID := IBLogin.DBID;
      FCurrCachedTime := GetTickCount;
    finally
      q.Free;
    end;
  end;
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
        '  DIRECTOR.NAME AS DIRNAME, IIF(DIRECTORPOS.NAME IS NOT NULL, DIRECTORPOS.NAME, ''��������'') AS DIRPOS, ' +
        '  BUH.NAME AS BUHNAME, IIF(BUHPOS.NAME IS NOT NULL, BUHPOS.NAME, ''��. ���������'') AS BUHPOS ' +
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
      q.ParamByName('ID').AsInteger := IBLogin.CompanyKey;
      q.ExecQuery;
      if not q.EOF then
      begin
        FCompanyName := q.FieldByName('NAME').AsString;
        FCompanyFullName := q.FieldByName('COMPFULLNAME').AsString;
        FCompanyAddress := q.FieldByName('ADDRESS').AsString;
        FDirName := q.FieldByName('DIRNAME').AsString;
        FChiefAccountantName := q.FieldByName('BUHNAME').AsString;
        FTAXID := q.FieldByName('TAXID').AsString;
        FDirRank := q.FieldByName('DIRPOS').AsString;
        FBuhRank := q.FieldByName('BUHPOS').AsString;
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
        FDirName := '';
        FChiefAccountantName := '';
        FTAXID := '';
        FDirRank := '��������';
        FBuhRank := '��. ���������';
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

initialization
  fsRTTIModules.Add(TFR4Functions);

end.
