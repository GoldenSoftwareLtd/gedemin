unit xCommon_anj;

interface

uses SysUtils, WinTypes, WinProcs;

const
  CountKAURef = 14;

  kau_Klient = 1;      { ������� }
  kau_Object = 2;      { ������� }
  kau_Goods = 3;       { ������  }
  kau_MainMean = 4;    { ��  }
  kau_People = 5;      { ����������  }
  kau_IndExp = 6;      { ����������� ����������  }
  kau_DeptRef = 7;     { ���������������� �������������  }
  kau_Otrsl = 8;       { �������  }
  kau_Currency = 9;    { ������  }
  kau_KindOperation = 10; { ���� ��������  }
  kau_KindPayment = 11;   { ���� ��������  }
  kau_GroupEquipment = 12; { ������ �������  }
  kau_ChildDepartment = 13; { �������� �������������  }
  kau_KindProduction = 14; { ���� ���������  }


  PrimeSection = 'Golden Prime System';

type
  TKAUtype = (kauClient, kauObject, kauGoods, kauMainMean, kauPeople, kauIndExp,
    kauDeptRef, kauOtrsl, kauCurrency, kauKindOperation, kauKindPayment,
    kauGroupEquipment, kauChildDepartment, kauKindProduction);
  TKAUTypes = set of TKAUtype;

type
  TKAUInfo = record
    KodKAU: Integer;
    NameKAU: PChar;
    NameFileKAU: PChar;
  end;

const
  KAUInfo: array[1..CountKAURef] of TKAUInfo = (
   (KodKAU: kau_Klient; NameKAU: '�������'; NameFileKAU: 'klient'),
   (KodKAU: kau_Object; NameKAU: '�������'; NameFileKAU: 'object'),
   (KodKAU: kau_Goods; NameKAU: '������'; NameFileKAU: 'refgoods'),
   (KodKAU: kau_MainMean; NameKAU: '���.��������'; NameFileKAU: 'mainmean'),
   (KodKAU: kau_People; NameKAU: '����������'; NameFileKAU: 'piple'),
   (KodKAU: kau_IndExp; NameKAU: '���������������� �������'; NameFileKAU: 'indExp'),
   (KodKAU: kau_DeptRef; NameKAU: '������'; NameFileKAU: 'DeptRef'),
   (KodKAU: kau_Otrsl; NameKAU: '���� ��������'; NameFileKAU: 'Otrsl'),
   (KodKAU: kau_Currency; NameKAU: '���� �����'; NameFileKAU: 'RefCur'),
   (KodKAU: kau_KindOperation; NameKAU: '���� ��������'; NameFileKAU: 'kauoper'),
   (KodKAU: kau_KindPayment; NameKAU: '���� ��������'; NameFileKAU: 'kaupaym'),
   (KodKAU: kau_GroupEquipment; NameKAU: '������ �������'; NameFileKAU: 'kauequip'),
   (KodKAU: kau_ChildDepartment; NameKAU: '�������� �������������'; NameFileKAU: 'kauchdp'),
   (KodKAU: kau_KindProduction; NameKAU: '���� ���������'; NameFileKAU: 'kauprod')
  );


function GetNextAlphaCode(const S: String; Len: Integer): String;

implementation

function GetNextAlphaCode(const S: String; Len: Integer): String;
var
  i: Integer;
begin
  Result:= S;

  if S = '' then begin
    for i:= 1 to Len do
      Result:= Result + '@';
    exit;
  end;

  if Len < Length(S) then
    Len:= Length(S);

  for i:= Len downto 1 do
    if Ord(Result[i]) = 122 then
      Result[i]:= Chr(64)
    else begin
      if Chr(Ord(Result[i]) + 1) = '\' then
        Result[i]:= Chr(Ord(Result[i]) + 2)
      else
        Result[i]:= Chr(Ord(Result[i]) + 1);
      Break;
    end;

end;


end.
