unit xCommon_anj;

interface

uses SysUtils, WinTypes, WinProcs;

const
  CountKAURef = 14;

  kau_Klient = 1;      { Клиенты }
  kau_Object = 2;      { Объекты }
  kau_Goods = 3;       { Товары  }
  kau_MainMean = 4;    { ОС  }
  kau_People = 5;      { Сотрудники  }
  kau_IndExp = 6;      { Направления реализации  }
  kau_DeptRef = 7;     { Производственные подразделения  }
  kau_Otrsl = 8;       { Отрасли  }
  kau_Currency = 9;    { Валюты  }
  kau_KindOperation = 10; { Виды операций  }
  kau_KindPayment = 11;   { Виды платежей  }
  kau_GroupEquipment = 12; { Группы техники  }
  kau_ChildDepartment = 13; { Дочерние подразделения  }
  kau_KindProduction = 14; { Виды продукции  }


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
   (KodKAU: kau_Klient; NameKAU: 'Клиенты'; NameFileKAU: 'klient'),
   (KodKAU: kau_Object; NameKAU: 'Объекты'; NameFileKAU: 'object'),
   (KodKAU: kau_Goods; NameKAU: 'Товары'; NameFileKAU: 'refgoods'),
   (KodKAU: kau_MainMean; NameKAU: 'Осн.средства'; NameFileKAU: 'mainmean'),
   (KodKAU: kau_People; NameKAU: 'Сотрудники'; NameFileKAU: 'piple'),
   (KodKAU: kau_IndExp; NameKAU: 'Производственные затраты'; NameFileKAU: 'indExp'),
   (KodKAU: kau_DeptRef; NameKAU: 'Отделы'; NameFileKAU: 'DeptRef'),
   (KodKAU: kau_Otrsl; NameKAU: 'Виды операций'; NameFileKAU: 'Otrsl'),
   (KodKAU: kau_Currency; NameKAU: 'Виды валют'; NameFileKAU: 'RefCur'),
   (KodKAU: kau_KindOperation; NameKAU: 'Виды операций'; NameFileKAU: 'kauoper'),
   (KodKAU: kau_KindPayment; NameKAU: 'Виды платежей'; NameFileKAU: 'kaupaym'),
   (KodKAU: kau_GroupEquipment; NameKAU: 'Группы техники'; NameFileKAU: 'kauequip'),
   (KodKAU: kau_ChildDepartment; NameKAU: 'Дочерние подразделения'; NameFileKAU: 'kauchdp'),
   (KodKAU: kau_KindProduction; NameKAU: 'Виды продукции'; NameFileKAU: 'kauprod')
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
