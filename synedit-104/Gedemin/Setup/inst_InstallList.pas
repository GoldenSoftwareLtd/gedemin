unit inst_InstallList;

interface

uses
  Classes;

const
  cU = 'U';     // Unknown
  cB = 'B';     // Database
  cS = 'S';     // Interbase Server
  cA = 'A';     // Server DLL
  cC = 'C';     // Interbase Client
  cD = 'D';     // Database
  cG = 'G';     // Gedemin
//  cR = 'R';     // Report Server 
  cL = 'L';     // Link

type
  TInstallList = class(TStringList)
  private
    function GetFileName(Index: Integer): String;
    function GetIsShared(Index: Integer): Boolean;
    function GetRegister(Index: Integer): Boolean;
    function GetValue(Index: Integer): String;
    procedure SetValue(Index: Integer; const Value: String);
    function GetFileModule(Index: Integer): Char;
  public
    function AddFile(AnFileModule: Char; AnFileName: String; AnIsShared, AnIsRegister: Boolean): Integer;
    function FindFile(AnFileModule: Char; AnFileName: String): Integer;
    procedure MergeList(AnSource: TInstallList);
    property FileModule[Index: Integer]: Char read GetFileModule;
    property FileName[Index: Integer]: String read GetFileName;
    property IsShared[Index: Integer]: Boolean read GetIsShared;
    property IsRegister[Index: Integer]: Boolean read GetRegister;
    property ValueByIndex[Index: Integer]: String read GetValue write SetValue;
  end;

implementation

uses
  SysUtils;

const
  cTrue = 'TRUE';
  cFalse = 'FALSE';

{ TInstallList }

function TInstallList.AddFile(AnFileModule: Char; AnFileName: String;
  AnIsShared, AnIsRegister: Boolean): Integer;
var
  S1, S2: String;
begin
  if AnIsShared then
    S1 := cTrue
  else
    S1 := cFalse;
  if AnIsRegister then
    S2 := cTrue
  else
    S2 := cFalse;
  Result := Add(AnsiUpperCase(AnFileModule) + '|' + AnsiUpperCase(AnFileName) + '=' + S1 + ';' + S2 + ';');
end;

function TInstallList.FindFile(AnFileModule: Char;
  AnFileName: String): Integer;
begin
  Result := IndexOfName(AnsiUpperCase(AnFileModule) + '|' + AnsiUpperCase(AnFileName));
end;

function TInstallList.GetFileModule(Index: Integer): Char;
var
  S: String;
begin
  Result := cU;
  S := Names[Index];
  if (Length(S) >= 2) and (S[2] = '|') then
    Result := S[1];
end;

function TInstallList.GetFileName(Index: Integer): String;
var
  S: String;
begin
  S := Names[Index];
  if (Length(S) >= 2) and (S[2] = '|') then
    Result := Copy(S, 3, Length(S) - 2)
  else
    Result := S;
end;

function TInstallList.GetIsShared(Index: Integer): Boolean;
var
  S: String;
  I: Integer;
begin
  Assert((Index >= 0) and (Index < Count));
  S := Copy(Strings[Index], Length(Names[Index]) + 2, MaxInt);
  I := Pos(';', S);
  S := Copy(S, 1, I - 1);
  if Pos(cTrue, S) > 0 then
    Result := True
  else
    if Pos(cFalse, S) > 0 then
      Result := False
    else
      raise Exception.Create('Неверное значение переменной');
end;

function TInstallList.GetRegister(Index: Integer): Boolean;
var
  S: String;
  I, J: Integer;
begin
  Assert((Index >= 0) and (Index < Count));
  S := Copy(Strings[Index], Length(Names[Index]) + 2, MaxInt);
  J := Pos(';', S);
  if J > 0 then
    S[J] := '_'
  else
    raise Exception.Create('Неверный формат данных');
  I := Pos(';', S);
  S := Copy(S, J + 1, I - J - 1);
  if Pos(cTrue, S) > 0 then
    Result := True
  else
    if Pos(cFalse, S) > 0 then
      Result := False
    else
      raise Exception.Create('Неверное значение переменной');
end;

function TInstallList.GetValue(Index: Integer): String;
begin
  Assert((Index >= 0) and (Index < Count));
  Result := Copy(Strings[Index], Length(Names[Index]) + 2, MaxInt);
end;

procedure TInstallList.MergeList(AnSource: TInstallList);
var
  I, J: Integer;
  SL: TStrings;
begin
  { DONE -oJKL :
Не будет корректно работать если после установки сервера компьютер
перегружается и ставится клиент. Не будут файлы дублироваться }
  { DONE -oJKL :
Другая проблема. Если сначала ставиться сервер. Потом отдельно клиент,
то gds32.dll например, будет в файле 1 раз, в то время как пропишет она себя 2
раза. При деинсталляции некоторые файлы не удаляться. }
  // Чтобы дублирующиеся файлы попадали
  SL := TStringList.Create;
  try
    for I := 0 to AnSource.Count - 1 do
    begin
      J := IndexOfName(AnSource.Names[I]);
      if J = -1 then
        J := IndexOfName(AnSource.FileName[I]);
      if J > -1 then
        Delete(J);
      SL.Add(AnSource.Strings[I]);
    end;
    for I := 0 to SL.Count - 1 do
      Add(SL[I]);
  finally
    SL.Free;
  end;
end;

procedure TInstallList.SetValue(Index: Integer; const Value: String);
begin
  Assert((Index >= 0) and (Index < Count));
  Strings[Index] := Names[Index] + '=' + Value;
end;


end.
