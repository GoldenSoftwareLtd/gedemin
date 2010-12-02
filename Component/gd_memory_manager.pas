
unit gd_memory_manager;

{$IFNDEF DEBUG}

interface
implementation

{$ELSE}
interface

function gdGetMem(Size: Integer): Pointer;
function gdFreeMem(P: Pointer): Integer;
function gdReallocMem(P: Pointer; Size: Integer): Pointer;

implementation

uses
  Classes, SysUtils, Windows;

const
  BuffSize = 1000000;

var
  LP, LS, LK: TList;
  OldMM, MM: TMemoryManager;
  KeyNum: Integer;

function IndexOf(P: Pointer): Integer;
var
  I: Integer;
begin
  for I := LP.Count - 1 downto 0 do
  begin
    if LP[I] = P then
    begin
      Result := I;
      exit;
    end;
  end;
  Result := -1;
end;

function gdGetMem(Size: Integer): Pointer;
const
  Prev: Integer = 0;
  PrevPrev: Integer = 0;
  PrevPrevPrev: Integer = 0;
  PrevPrevPrevPrev: Integer = 0;
var
  Q: Integer;
begin
  Inc(KeyNum);
  Q := KeyNum;

  try
    if (Prev = 20) and (Size = 28) and (KeyNum >= 152000) then
    begin
      Q := KeyNum;
    end;
  except
  end;

  Result := OldMM.GetMem(Size);

  if LP.Count < BuffSize then
  begin
    LP.Add(Result);
    LS.Add(Pointer(Size));
    LK.Add(Pointer(Q));
  end;

  PrevPrevPrevPrev := PrevPrevPrev;
  PrevPrevPrev := PrevPrev;
  PrevPrev := Prev;
  Prev := Size;
end;

function gdFreeMem(P: Pointer): Integer;
var
  I: Integer;
begin
  I := IndexOf(P);
  if I <> -1 then
  begin
    LP.Delete(I);
    LS.Delete(I);
    LK.Delete(I);
  end;
  Result := OldMM.FreeMem(P);
end;

function gdReallocMem(P: Pointer; Size: Integer): Pointer;
var
  I, Q: Integer;
begin
  Inc(KeyNum);
  Q := KeyNum;

  try
    if (Size = 304) and (KeyNum < -500477) then
    begin
      Q := KeyNum;
    end;
  except
  end;

  I := IndexOf(P);
  {if I <> -1 then
  begin
    LP.Delete(I);
    LS.Delete(I);
    LK.Delete(I);
  end;}

  Result := OldMM.ReallocMem(P, Size);

  if I <> -1 then
  begin
    if Size = 0 then
    begin
      LP.Delete(I);
      LS.Delete(I);
      LK.Delete(I);
    end else
    begin
      LP[I] := Result;
      LS[I] := Pointer(Size);
      LK[I] := Pointer(-Q);
    end;
  end;
end;

procedure SaveMemoryLeak;
var
  St: String;
  J: Integer;
  T: TextFile;
  I, S: Integer;
begin
  try
    S := 0;
    AssignFile(T, 'd:\temp.log');
    Rewrite(T);
  except
    exit;
  end;

  for I := 0 to LS.Count - 1 do
  begin
    St := '';
    for J := 0 to Integer(LS[I]) do
    begin
      if J > 44 then break;
      try
        if PChar(LP[I])[J] in [#0..#31] then
          St := St + '.'
        else
          St := St + PChar(LP[I])[J];
      except
        on E: Exception do ;
      end;
    end;

    Writeln(T, Format('%-5d:%10d %4d, $%s, %s', [I, Integer(LK[I]), Integer(LS[I]), IntToHex(Integer(LP[I]), 8), St]));
    Inc(S, Integer(LS[I]));
  end;
  Writeln(T, IntToStr(S));
  CloseFile(T);

  if LS.Count > 14 then
  begin
    MessageBox(0,
      'Не вся память удалена. Подробно: d:\temp.log',
      'Память!',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
  end;
end;

initialization
  KeyNum := 0;

  LS := TList.Create;
  LS.Capacity := BuffSize;
  LP := TList.Create;
  LP.Capacity := BuffSize;
  LK := TList.Create;
  LK.Capacity := BuffSize;

  // Для чистоты эксперимента
  Classes.RegisterClass(TPersistent);

  GetMemoryManager(OldMM);

  MM.GetMem := gdGetMem;
  MM.FreeMem := gdFreeMem;
  MM.ReallocMem := gdReallocMem;

  SetMemoryManager(MM);

finalization
  SetMemoryManager(OldMM);

  Classes.UnRegisterClass(TPersistent);

  SaveMemoryLeak;

  LS.Free;
  LP.Free;
  LK.Free;

{$ENDIF}
end.


