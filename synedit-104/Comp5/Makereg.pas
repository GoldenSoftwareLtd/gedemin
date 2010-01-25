{ 1.01    06-aug-97    Minor change. Comments added. }
{ 1.02    10-nov-97    Minor change. }
{ 1.03    12-dec-97    Add currency information SumCur and NameCur }
{ 2.00    09-sen-99    Delphi 4.0 } 

unit MakeReg;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExList, DB, DBTables, xbkIni, xTable, xCommon_anj;

type
  TxSaveRegList = class(TExList)
    procedure DeleteRecord(Number: Longint);
  end;

  TxMakeRegister = class(TComponent)
  private
    FConstractReg: TxSaveRegList;
    AccountTable: TTable;
    KAUTable: TTable;
    KAUQuantity: TTable;
    NewRegTable: TxTable;
    RegTable: TxTable;
    RegQuantity: TxTable;
    xBookkeepIni: TxBookkeepIni;
    FFixedKAU: TKAUTypes;
    xtblRefKAU: TxTable;
    CurrentKAU: Integer;

  public
    constructor Create(anOwner: TComponent); override;
    destructor Destroy; override;

    function MakeKAU(Account, KAUName: String; isDebet: Boolean): String;
    function GetKAUCode(Account, KAUName: String; aTypeKAU: Integer): Integer;
    function GetKAUName(KAUCode, TypeKAU: Integer): String;
    procedure CloseRefKAU;

    { adds entry into the buffer }
    procedure AddConstract(
      aDate: TDateTime;                 { дата проводки                                        }
      const aDebet, aKredit: String;    { дебет, кредит                                        }
      aSum: Double;                     { сумма                                                }
      const aDebetKAU, aKreditKAU,      { КАУ по дебету и кредиту                              }
      aNameOper: String;                { наименование операции, задаваемое п/системой         }
      TypeFixedValue: array of Integer; { массив кодов справочников, за которые отвечает п/с   }
      FixedValue: array of Longint;     { массив КАУ для справочников, согласно пред. параметра}
      TypeQuantity: array of Integer;   { коды колич. показателей                              }
      Quantity: array of Double;        { значения кол. показателей                            }
      const CodeRegister: String;       { уникальный код проводки для хранения в п/системе     }
      aSumCur: Double;                  { сумма в валюте                                       }
      const aNameCur: String);          { наименование валюты                                  }

    { adds entry into the buffer }
    procedure AddNewConstract(
      aDate: TDateTime;                 { дата проводки                                        }
      const aDebet, aKredit: String;    { дебет, кредит                                        }
      aSum: Double;                     { сумма                                                }
      const aDebetKAU, aKreditKAU,      { КАУ по дебету и кредиту                              }
      aNameOper: String;                { наименование операции, задаваемое п/системой         }
      TypeFixedValue: array of Integer; { массив кодов справочников, за которые отвечает п/с   }
      FixedValue: array of Longint;     { массив КАУ для справочников, согласно пред. параметра}
      TypeDebetValue: array of Integer; { массив кодов справочников, для дебета                }
      DebetValue: array of Longint;     { массив КАУ для дебета                                }
      TypeKreditValue: array of Integer;{ массив кодов справочников для кредита                }
      KreditValue: array of Longint;    { массив КАУ для кредита                               }
      TypeQuantity: array of Integer;   { коды колич. показателей                              }
      Quantity: array of Double;        { значения кол. показателей                            }
      const CodeRegister: String;       { уникальный код проводки для хранения в п/системе     }
      aSumCur: Double;                  { сумма в валюте                                       }
      const aNameCur: String);          { наименование валюты                                  }

    { deletes entry from the registry by specified code }
    procedure DeleteConstract(const CodeRegister: String);

    { exports list of entries to the acc. kernel }
    procedure ExportToPrime;
    { exports list of entries to the text }
    procedure ExportToText;
    { empties list of entries }
    procedure EmptyList;
    { get information on account (currency or not }
    function IsCurrencyAccount(const Account: String): Boolean;

  published
    property FixedKAU: TKAUTypes read FFixedKAU write FFixedKAU;
  end;

procedure Register;

implementation

{uses
  Reg_Form;}

type
  TSaveConstract = class
    Date: TDateTime;
    Debet: PString;
    Kredit: PString;
    DebetKAU: PString;
    KreditKAU: PString;
    NameOper: PString;
    Sum: Double;
    CodeOper: PString;
    TypeQuantity: array[1..8] of Integer;
    Quantity: array[1..8] of Double;
    CountQuantity: Integer;
    SumCur: Double;
    NameCur: PString;
    Number: Longint;

    constructor Create(aDate: TDateTime; const aDebet, aKredit: String;
      aSum: Double; const aDebetKAU, aKreditKAU, aNameOper,
      aCodeOper: String; aTypeQuantity: array of Integer;
      aQuantity: array of Double; aSumCur: Double; aNameCur: String);
    destructor Destroy; override;

    procedure AddSum(aSum: Double; aTypeQuantity: array of Integer;
      aQuantity: array of Double; aSumCur: Double);
  end;

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


procedure TxSaveRegList.DeleteRecord(Number: Longint);
var
  i: Integer;
begin
  for i:= 0 to Count - 1 do
    if TSaveConstract(Items[i]).Number = Number then
    begin
      DeleteAndFree(i);
      Break;
    end;
end;

{ TSaveConstract ----------------------------------------------------------}

constructor TSaveConstract.Create(aDate: TDateTime; const aDebet, aKredit: String;
      aSum: Double; const aDebetKAU, aKreditKAU, aNameOper,
      aCodeOper: String; aTypeQuantity: array of Integer;
      aQuantity: array of Double; aSumCur: Double; aNameCur: String);
var
  i: Integer;
begin
  Date:= aDate;
  AssignStr(Debet, aDebet);
  AssignStr(Kredit, aKredit);
  Sum:= aSum;
  AssignStr(DebetKAU, aDebetKAU);
  AssignStr(KreditKAU, aKreditKAU);
  AssignStr(NameOper, aNameOper);
  AssignStr(CodeOper, aCodeOper);
  CountQuantity:= 1;
  for i:= Low(aTypeQuantity) to High(aTypeQuantity) do begin
    if aQuantity[i] <> 0 then begin
      TypeQuantity[CountQuantity]:= aTypeQuantity[i];
      Quantity[CountQuantity]:= aQuantity[i];
      Inc(CountQuantity);
    end;
  end;
  Dec(CountQuantity);
  AssignStr(NameCur, aNameCur);
  SumCur:= aSumCur;
  
end;

procedure TSaveConstract.AddSum(aSum: Double; aTypeQuantity: array of Integer;
   aQuantity: array of Double; aSumCur: Double);
var
  j, i: Integer;
  isFind: Boolean;
begin
  Sum:= Sum + aSum;
  SumCur:= SumCur + aSumCur;

  for i:= Low(aTypeQuantity) to High(aTypeQuantity) do begin
    isFind:= false;
    if aQuantity[i] <> 0 then begin
      for j:= 1 to CountQuantity do
        if aTypeQuantity[i] = TypeQuantity[j] then
        begin
          Quantity[j]:= Quantity[j] + aQuantity[i];
          isFind:= true;
          Break;
        end;
      if not isFind then
      begin
        Inc(CountQuantity);
        TypeQuantity[CountQuantity]:= aTypeQuantity[i];
        Quantity[CountQuantity]:= aQuantity[i];
      end;
    end;
  end;
end;

destructor TSaveConstract.Destroy;
begin
  DisposeStr(Debet);
  DisposeStr(Kredit);
  DisposeStr(DebetKAU);
  DisposeStr(KreditKAU);
  DisposeStr(NameOper);
  DisposeStr(CodeOper);
  DisposeStr(NameCur);

  inherited Destroy;
end;

{ TxMakeRegister-------------------------------------------------------------}

constructor TxMakeRegister.Create(anOwner: TComponent);
begin
  inherited Create(anOwner);
  FConstractReg:= TxSaveRegList.Create;
  FFixedKAU:= [];
  CurrentKAU:= -1;
  xBookkeepIni:= TxBookkeepIni.Create(Self);

  if xBookkeepIni.SystemCode > 0 then begin
    AccountTable:= TTable.Create(Self);
    AccountTable.DatabaseName:= xBookkeepIni.MainDir;
    AccountTable.TableName:= 'acount.db';
    AccountTable.IndexFieldNames:= 'Acount';

    KAUTable:= TTable.Create(Self);
    KAUTable.DatabaseName:= xBookkeepIni.MainDir;
    KAUTable.TableName:= 'refkau.db';
    KAUTAble.IndexFieldNames:= 'NumSchet';

    xTblRefKAU:= TxTable.Create(Self);

    NewRegTable:= TxTable.Create(Self);
    NewRegTable.DatabaseName:= xBookkeepIni.WorkingDir;
    NewRegTable.TableName:= 'newreg.db';
    NewRegTable.Exclusive:= True;

    RegQuantity:= TxTable.Create(Self);
    RegQuantity.DatabaseName:= xBookkeepIni.WorkingDir;
    RegQuantity.TableName:= 'regcount.db';

    RegTable:= TxTable.Create(Self);
    RegTable.DatabaseName:= xBookkeepIni.WorkingDir;
    RegTable.TableName:= 'register.db';
    RegTable.IndexFieldNames:= 'CodeDocument';

    KAUQuantity:= TTable.Create(Self);
    KAUQuantity.DatabaseName:= xBookkeepIni.MainDir;
    KAUQuantity.TableName:= 'refquant.db'
  end
  else begin
    AccountTable:= nil;
    KAUTable:= nil;
    KAUQuantity:= nil;
    NewRegTable:= nil;
    RegTable:= nil;
    RegQuantity:= nil;
    xtblRefKAU:= nil;
  end;
end;

destructor TxMakeRegister.Destroy;
begin
  if (KAUTable <> nil) and KAUTable.Active then KAUTable.Close;
  if (AccountTable <> nil) and AccountTable.Active then AccountTable.Close;

  if AccountTable <> nil then AccountTable.Free;
  if KAUTable <> nil then KAUTable.Free;
  if NewRegTable <> nil then NewRegTable.Free;
  if RegTable <> nil then RegTable.Free;
  if RegQuantity <> nil then RegQuantity.Free;
  if xtblRefKAU <> nil then xtblRefKAU.Free;
  xBookkeepIni.Free;
  FConstractReg.Free;

  inherited Destroy;
end;

procedure TxMakeRegister.AddConstract(aDate: TDateTime; const aDebet, aKredit: String;
      aSum: Double; const aDebetKAU, aKreditKAU, aNameOper: String;
      TypeFixedValue: array of Integer; FixedValue: array of Longint;
      TypeQuantity: array of Integer; Quantity: array of Double;
      const CodeRegister: String; aSumCur: Double;
      const aNameCur: String);
var
  i, Nom: Integer;
  DebetKAUCode, KreditKAUCode: String;

function MakeFixedValue(Account, AccountKAU: String): String;
var
  KAU: array[1..4] of string[8];
  Temp: string[32];
  i, k: Integer;
begin

  Result:= '';

  if xBookkeepIni.SystemCode > 0 then begin
    if not KAUTable.FindKey([Account]) then begin
      if Pos('.', Account) <> 0 then begin
        Account:= copy(Account, 1, Pos('.', Account) - 1);
        if not KAUTable.FindKey([Account]) then exit;
      end
      else
        exit;
    end;

    for i:= 1 to 4 do KAU[i]:= '';

    Temp:= AccountKAU;
    i:= 1;
    while Temp <> '' do begin
      if Pos('.', Temp) <> 0 then
        KAU[i]:= copy(Temp, 1, Pos('.', Temp) - 1)
      else
        KAU[i]:= Temp;
      Inc(i);
      if Pos('.', Temp) <> 0 then
        Temp:= copy(Temp, Pos('.', Temp) + 1, 255)
      else
        Temp:= '';
    end;

    for i:= 1 to 4 do begin
      if KAUTable.Fields[i].IsNull or (KAUTable.Fields[i].AsInteger = 0) then Break;
      for k:= Low(TypeFixedValue) to High(TypeFixedValue) do
        if (FixedValue[k] >= 0) and (TypeFixedValue[k] = KAUTable.Fields[i].AsInteger)
        then begin
          if KAU[i] = '' then
            KAU[i]:= IntToStr(FixedValue[k]);
          Break;
        end;
    end;

    Result:= '';
    for i:= 1 to 4 do begin
      if KAU[i] <> '' then
        Result:= Result + KAU[i] + '.';
    end;
    if (Result <> '') and (Result[Length(Result)] = '.') then
      Result:= copy(Result, 1, Length(Result) - 1);
  end;
end;

begin

  if xBookkeepIni.SystemCode > 0 then begin
    if not KAUTable.Active then KAUTable.Active:= true;
    DebetKAUCode:= MakeFixedValue(aDebet, aDebetKAU);
    KreditKAUCode:= MakeFixedValue(aKredit, aKreditKAU);
  end
  else begin
    DebetKAUCode:= '';
    KreditKAUCode:= '';
  end;

  Nom:= -1;

  for i:= 0 to FConstractReg.Count - 1 do begin
    with TSaveConstract(FConstractReg[i]) do begin
      if (Date = aDate) and (Debet^ = aDebet) and (Kredit^ = aKredit) and
         (DebetKAUCode = DebetKAU^) and (KreditKAUCode = KreditKAU^) and
         (CodeOper^ = CodeRegister) and
         ( ((NameCur = nil) and (aNameCur = '')) or
           ((NameCur <> nil) and (NameCur^ = aNameCur)) )
      then begin
        Nom:= i;
        Break;
      end;
    end;
  end;

  if Nom = -1 then begin
    FConstractReg.Add(TSaveConstract.Create(aDate, aDebet, aKredit,
      aSum, DebetKAUCode, KreditKAUCode, aNameOper, CodeRegister,
      TypeQuantity, Quantity, aSumCur, aNameCur));
    TSaveConstract(FConstractReg[FConstractReg.Count - 1]).Number:= FConstractReg.Count;
  end
  else
    TSaveConstract(FConstractReg[Nom]).AddSum(aSum, TypeQuantity, Quantity, aSumCur);
end;

procedure TxMakeRegister.AddNewConstract(
  aDate: TDateTime;                 { дата проводки                                        }
  const aDebet, aKredit: String;    { дебет, кредит                                        }
  aSum: Double;                     { сумма                                                }
  const aDebetKAU, aKreditKAU,      { КАУ по дебету и кредиту                              }
  aNameOper: String;                { наименование операции, задаваемое п/системой         }
  TypeFixedValue: array of Integer; { массив кодов справочников, за которые отвечает п/с   }
  FixedValue: array of Longint;     { массив КАУ для справочников, согласно пред. параметра}
  TypeDebetValue: array of Integer; { массив кодов справочников, для дебета                }
  DebetValue: array of Longint;     { массив КАУ для дебета                                }
  TypeKreditValue: array of Integer;{ массив кодов справочников для кредита                }
  KreditValue: array of Longint;    { массив КАУ для кредита                               }
  TypeQuantity: array of Integer;   { коды колич. показателей                              }
  Quantity: array of Double;        { значения кол. показателей                            }
  const CodeRegister: String;       { уникальный код проводки для хранения в п/системе     }
  aSumCur: Double;                  { сумма в валюте                                       }
  const aNameCur: String);          { наименование валюты                                  }
var
  i, Nom: Integer;
  DebetKAUCode, KreditKAUCode: String;

function MakeFixedValue(Account, AccountKAU: String; isDebet: Boolean): String;
var
  KAU: array[1..4] of string[8];
  Temp: string[32];
  i, k: Integer;
begin

  Result:= '';

  if xBookkeepIni.SystemCode > 0 then begin
    if not KAUTable.FindKey([Account]) then begin
      if Pos('.', Account) <> 0 then begin
        Account:= copy(Account, 1, Pos('.', Account) - 1);
        if not KAUTable.FindKey([Account]) then exit;
      end
      else
        exit;
    end;

    for i:= 1 to 4 do KAU[i]:= '';

    Temp:= AccountKAU;
    i:= 1;
    while Temp <> '' do begin
      if Pos('.', Temp) <> 0 then
        KAU[i]:= copy(Temp, 1, Pos('.', Temp) - 1)
      else
        KAU[i]:= Temp;
      Inc(i);
      if Pos('.', Temp) <> 0 then
        Temp:= copy(Temp, Pos('.', Temp) + 1, 255)
      else
        Temp:= '';
    end;

    for i:= 1 to 4 do begin
      if KAUTable.Fields[i].IsNull or (KAUTable.Fields[i].AsInteger = 0) then Break;

      if isDebet then begin
        for k:= Low(TypeDebetValue) to High(TypeDebetValue) do
          if (DebetValue[k] >= 0) and (TypeDebetValue[k] = KAUTable.Fields[i].AsInteger)
          then begin
            if KAU[i] = '' then
              KAU[i]:= IntToStr(DebetValue[k]);
            Break;
          end
      end
      else begin
        for k:= Low(TypeKreditValue) to High(TypeKreditValue) do
          if (KreditValue[k] >= 0) and (TypeKreditValue[k] = KAUTable.Fields[i].AsInteger)
          then begin
            if KAU[i] = '' then
              KAU[i]:= IntToStr(KreditValue[k]);
            Break;
          end
      end;

      if KAU[i] = '' then begin
        for k:= Low(TypeFixedValue) to High(TypeFixedValue) do
          if (FixedValue[k] >= 0) and (TypeFixedValue[k] = KAUTable.Fields[i].AsInteger)
          then begin
            if KAU[i] = '' then
              KAU[i]:= IntToStr(FixedValue[k]);
            Break;
          end;
      end;
    end;

    Result:= '';
    for i:= 1 to 4 do begin
      if KAU[i] <> '' then
        Result:= Result + KAU[i] + '.';
    end;
    if (Result <> '') and (Result[Length(Result)] = '.') then
      Result:= copy(Result, 1, Length(Result) - 1);
  end;
end;

begin

  if xBookkeepIni.SystemCode > 0 then begin
    if not KAUTable.Active then KAUTable.Active:= true;
    DebetKAUCode:= MakeFixedValue(aDebet, aDebetKAU, True);
    KreditKAUCode:= MakeFixedValue(aKredit, aKreditKAU, False);
  end
  else begin
    DebetKAUCode:= '';
    KreditKAUCode:= '';
  end;

  Nom:= -1;

  for i:= 0 to FConstractReg.Count - 1 do begin
    with TSaveConstract(FConstractReg[i]) do begin
      if (Date = aDate) and (Debet^ = aDebet) and (Kredit^ = aKredit) and
         (DebetKAUCode = DebetKAU^) and (KreditKAUCode = KreditKAU^) and
         (CodeOper^ = CodeRegister) and
         ( ((NameCur = nil) and (aNameCur = '')) or
           ((NameCur <> nil) and (NameCur^ = aNameCur)) )
      then begin
        Nom:= i;
        Break;
      end;
    end;
  end;

  if Nom = -1 then begin
    FConstractReg.Add(TSaveConstract.Create(aDate, aDebet, aKredit,
      aSum, DebetKAUCode, KreditKAUCode, aNameOper, CodeRegister,
      TypeQuantity, Quantity, aSumCur, aNameCur));
    TSaveConstract(FConstractReg[FConstractReg.Count - 1]).Number:= FConstractReg.Count;
  end
  else
    TSaveConstract(FConstractReg[Nom]).AddSum(aSum, TypeQuantity, Quantity, aSumCur);
end;


procedure TxMakeRegister.DeleteConstract(const CodeRegister: String);
begin
  RegTable.FindKey([CodeRegister]);
  while not RegTable.EOF and (RegTable.Fields[14].AsString = CodeRegister) and
        (RegTable.Fields[13].AsInteger = xBookkeepIni.SystemCode) do
    RegTable.Delete;
end;

procedure TxMakeRegister.ExportToText;

function MakeString(Date: TDateTime; const Debet, Kredit: String; Sum: Double;
  const NameOper: String): String;
var
  SubDebet, SubKredit: String[3];
  PerDebet, PerKredit: String[3];
  PerNameOper: String;
  I: Integer;
begin

  if Pos('.', Debet) > 0 then begin
    SubDebet:= copy(Debet, Pos('.', Debet) + 1, 255);
    for i:= Length(SubDebet) + 1 to 3 do
      SubDebet:= SubDebet + ' ';
  end
  else
    SubDebet:= '   ';

  if Pos('.', Kredit) > 0 then begin
    SubKredit:= copy(Kredit, Pos('.', Kredit) + 1, 255);
    for i:= Length(SubKredit) + 1 to 3 do
      SubKredit:= SubKredit + ' ';
  end
  else
    SubKredit:= '   ';

  if Pos('.', Debet) = 0 then
    PerDebet:= Debet
  else
    PerDebet:= copy(Debet, 1, Pos('.', Debet) - 1);

  for i:= Length(PerDebet) + 1 to 3 do
    PerDebet:= PerDebet + ' ';

  if Pos('.', Kredit) = 0 then
    PerKredit:= Kredit
  else
    PerKredit:= copy(Kredit, 1, Pos('.', Kredit) - 1);

  for i:= Length(PerKredit) + 1 to 3 do
    PerKredit:= PerKredit + ' ';

  if NameOper = '' then
    PerNameOper:= ' '
  else
    PerNameOper:= NameOper;

  Result:= Format('"0  ","%s","%s","%s","%s","%s",%f,"%s","","",,"   ",,"5"',
    [DateToStr(Date), PerDebet, SubDebet, PerKredit, SubKredit, Sum, PerNameOper])+#13#10;
end;

var
  F, i: Integer;
  Temp: array[0..300] of Char;
  ReOpenBuff: TOfStruct;
begin
  F:= OpenFile('impprov.txt', ReOpenBuff, OF_CREATE or OF_WRITE);
  for i:= 0 to FConstractReg.Count - 1 do begin
    with TSaveConstract(FConstractReg[i]) do begin
      StrPCopy(Temp, MakeString(Date, Debet^, Kredit^, Sum, NameOper^));
      _lwrite(F, Temp, StrLen(Temp));
    end;
  end;
  _lclose(F);
end;

procedure TxMakeRegister.ExportToPrime;
var
  i: Integer;
  Code: String;

procedure SetQuantityValue(Account, CodeRegister: String; TypeQuantity: array of Integer;
  Quantity: array of Double; isDebet: Integer);
var
  i, j: Integer;
  S: String;
begin
  if not KAUQuantity.Active then KAUQuantity.Open;

  S:= ' ';
  if not KAUTable.FindKey([Account]) then
    S:= copy(Account, 1, Pos('.', S) - 1);

  for i:= 1 to 4 do begin
    if KAUTable.Fields[i].AsInteger = 0 then Break
    else begin
      for j:= Low(TypeQuantity) to High(TypeQuantity) do
        if KAUQuantity.FindKey([KAUTable.Fields[i].AsInteger, TypeQuantity[j]])
        then begin
          if not RegQuantity.Active then RegQuantity.Open;
          RegQuantity.Append;
          RegQuantity.Fields[0].AsString:= CodeRegister;
          RegQuantity.Fields[1].AsInteger:= isDebet;
          RegQuantity.Fields[2].AsInteger:= KAUTable.Fields[i].AsInteger;
          RegQuantity.Fields[3].AsInteger:= TypeQuantity[j];
          RegQuantity.Fields[4].AsFloat:= Quantity[j];
          RegQuantity.Post;
        end;
    end;
  end;
end;

function GetRegisterCode: String;
var
  F: Integer;
  S: array[0..7] of Char;
  EnCount: Integer;
begin
  Result:= '';
  EnCount:= 0;
  repeat
    F:= FileOpen(xBookkeepIni.WorkingDir + '\balnomer.inf',
        fmOpenReadWrite or fmShareExclusive);
    Inc(EnCount);
  until (F > 0) or (EnCount > 100000);
  if F < 0 then begin
    MessageBox(0, 'Сетевая ошибка. Формирование проводок прервано.',
      'Внимание', mb_Ok or mb_IconStop);
    exit;
  end;
  FileRead(F, S, SizeOf(S));
  Result:= StrPas(S);
  Result:= GetNextAlphaCode(Result, SizeOf(S) - 1);
  StrPCopy(S, Result);
  FileSeek(F, 0, 0);
  FileWrite(F, S, SizeOf(S));
  FileClose(F);
end;

begin
  if xBookkeepIni.SystemCode <= 0 then begin
    ExportToText;
    exit;
  end;

  try
    NewRegTable.EmptyTable;
  except
    MessageBox(0, 'БД используется другим пользователем', 'Внимание',
      mb_Ok or mb_IconStop);
    exit;
  end;
  NewRegTable.Open;
  for i:= 0 to FConstractReg.Count - 1 do begin
    with TSaveConstract(FConstractReg[i]) do begin
      if Sum <> 0 then begin
        NewRegTable.Append;
        NewRegTable.FieldByName('Date').AsDateTime:= Date;
        Code:= GetRegisterCode;
        if Code = '' then begin
          NewRegTable.Cancel;
          Break;
        end;
        NewRegTable.FieldByName('NomPP').AsString:= Code;
        NewRegTable.FieldByName('Debet').Text:= Debet^;
        SetQuantityValue(Debet^, Code, TypeQuantity, Quantity, 1);
        NewRegTable.FieldByName('Kredit').Text:= Kredit^;
        SetQuantityValue(Kredit^, Code, TypeQuantity, Quantity, 2);
        NewRegTable.FieldByName('Summa').AsFloat:= Sum;
        NewRegTable.FieldByName('KAU Debet').AsString:= DebetKAU^;
        NewRegTable.FieldByName('KAU Kredit').AsString:= KreditKAU^;
        NewRegTable.FieldByName('DateMake').AsDateTime:= SysUtils.Date;
        NewRegTable.FieldByName('Name operation').Text:= NameOper^;
        NewRegTable.FieldByName('CodeSubSystem').AsInteger:= xBookkeepIni.SystemCode;
        NewRegTable.FieldByName('CodeDocument').Text:= CodeOper^;
        if (NameCur <> nil) and (SumCur <> 0) then
        begin
          NewRegTable.FieldByName('Summa in cur').AsFloat:= SumCur;
          NewRegTable.FieldByName('Currency').AsString:= NameCur^;
        end;
        NewRegTable.Post;
      end;
    end;
  end;
  NewRegTable.Close;
end;

procedure TxMakeRegister.EmptyList;
begin
  FConstractReg.Free;
  FConstractReg:= TxSaveRegList.Create;
end;

function TxMakeRegister.IsCurrencyAccount(const Account: String): Boolean;
begin
  Result:= False;
  if xBookkeepIni.SystemCode <= 0 then exit;

  if not AccountTable.Active then AccountTable.Open;
  if AccountTable.FindKey([Account]) then
    Result:= AccountTable.FieldByName('IsCurrency').AsInteger = 1;
end;

function TxMakeRegister.MakeKAU(Account, KAUName: String; isDebet: Boolean): String;
var
  CountRef: Integer;
  isOk: Boolean;
  OldRef: Integer;
  S: String;
begin
  Result:= '';
  if xBookkeepIni.SystemCode <= 0 then exit;
   
  if not KAUTable.Active then KAUTable.Open;
  isOk:= KAUTable.FindKey([Account]);
  if isOk then begin
    CountRef:= 1;
    OldRef:= -1;
    while (CountRef <= 4) and not KAUTable.Fields[CountRef].IsNull and
      (KAUTable.Fields[CountRef].AsInteger <> 0) do begin
      if OldRef <> KAUTable.Fields[CountRef].AsInteger then begin
        xtblRefKAU.Close;
        xBookkeepIni.TypeReferency:= KAUTable.Fields[CountRef].AsInteger;
        xtblRefKAU.DatabaseName:= xBookkeepIni.ReferencyDir;
        xtblRefKAU.TableName:=
          StrPas(KAUInfo[KAUTable.Fields[CountRef].AsInteger].NameFileKAU);
        xtblRefKAU.IndexFieldNames:= '';
        xtblRefKAU.Open;
        xtblRefKAU.IndexFieldNames:= xtblRefKAU.Fields[0].FieldName;
      end;
      OldRef:= KAUTable.Fields[CountRef].AsInteger;
      if Pos('.', KAUName) <> 0 then begin
        S:= copy(KAUName, 1, Pos('.', KAUName) - 1);
        KAUName := copy(KAUName, Pos('.', KAUName) + 1, 255);
      end
      else
        S := KAUName;
      if xtblRefKAU.FindKey([S]) then
        Result:= Result + xtblRefKAU.Fields[1].Text + ' ';
      Inc(CountRef);
    end;
  end;
  xtblRefKAU.Close;
end;

function TxMakeRegister.GetKAUCode(Account, KAUName: String; aTypeKAU: Integer): Integer;
var
  CountRef: Integer;
  isOk: Boolean;
  S: String;
begin
  Result:= -1;
  if KAUName = '' then exit;
  if not KAUTable.Active then KAUTable.Open;
  isOk:= KAUTable.FindKey([Account]);
  if isOk then begin
    CountRef:= 1;
    while (CountRef <= 4) and not KAUTable.Fields[CountRef].IsNull and
      (KAUTable.Fields[CountRef].AsInteger <> 0) do begin
      if Pos('.', KAUName) <> 0 then begin
        S:= copy(KAUName, 1, Pos('.', KAUName) - 1);
        KAUName := copy(KAUName, Pos('.', KAUName) + 1, 255);
      end
      else
        S := KAUName;
      if KAUTable.Fields[CountRef].AsInteger = aTypeKAU then begin
        try
          Result:= StrToInt(S);
        except
          Result:= -1;
        end;
        Break;
      end;
      Inc(CountRef);
    end;
  end;
end;

function TxMakeRegister.GetKAUName(KAUCode, TypeKAU: Integer): String;
begin
  if KAUCode = -1 then begin
    Result:= '';
    exit;
  end;
  if CurrentKAU <> TypeKAU then begin
    CurrentKAU:= TypeKAU;
    xBookkeepIni.TypeReferency:= TypeKAU;
    if xtblRefKAU.Active then xtblRefKAU.Close;
    xtblRefKAU.DatabaseName:= xBookkeepIni.ReferencyDir;
    xtblRefKAU.TableName:=
      StrPas(KAUInfo[TypeKAU].NameFileKAU);
    xtblRefKAU.IndexFieldNames:= '';
    xtblRefKAU.Open;
    xtblRefKAU.IndexFieldNames:= xtblRefKAU.Fields[0].FieldName;
  end;
  if xtblRefKAU.FindKey([KAUCode]) then
    Result:= xtblRefKAU.Fields[1].Text
  else
    Result:= '';
end;

procedure TxMakeRegister.CloseRefKAU;
begin
  if (xtblRefKAU <> nil) and xtblRefKAU.Active then
    xtblRefKAU.Close;
  CurrentKAU:= -1;
end;

{ Registration -------------------------------------------}

procedure Register;
begin
  RegisterComponents('xTool', [TxMakeRegister]);
end;

end.
