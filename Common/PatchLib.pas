unit PatchLib;
(*
  Gabriel Corneanu (gabrielcorneanu(AT)gmail.com)
  Utilities for patching exe code

  Changes:
  Gabriel Corneanu
   - fixed a bug in RoundInt
   - Removed ExecAllocator and unnecessary functions
   - Simple implementation of heap allocator
*)

{$Include FastObj.inc}

interface

uses
  Windows;

const
  SizePtr = SizeOf(Pointer);

var
  PageSize: Cardinal;
  PageStartAddrMask: Cardinal;

type
{$ifndef Delphi6_Up}
  PPointer = ^Pointer;
  //PPointerArray = ^TPointerArray;
  //TPointerArray = array[0..0] of Pointer;
{$endif}

  TPatchSimpleJump = packed record
    Jump: Byte;
    Offset: Integer;
  end;

//define of TRegisters copied from FastMM4.pas
type
  {Registers structure (for GetCPUID)}
  TRegisters = record
    RegEAX, RegEBX, RegECX, RegEDX: Integer;
  end;

type
  //heap allocator class
  //can mark memory as executable if specified
  THeapAllocator = class(TObject)
  private
    FHeap : THandle;
    FFlags: DWord;
  public
    constructor Create(MarkExecutable: boolean);
    destructor Destroy; override;
    function  GetBlock(ASize: integer): Pointer;
    procedure FreeBlock(ABlock: Pointer);
  end;

//helper function
function  RoundInt(const AValue: Integer; ARoundBase: integer; RoundUp: boolean): integer;

//generic functions
procedure ReadMem(const Location, Buffer: Pointer; const Size: Cardinal);
procedure WriteMem(const Location, Buffer: Pointer; const Size: Cardinal);

//more specific functions
function  GetVMTPointer(AClass: TClass; Offset: Integer): Pointer;
procedure SetVMTPointer(AClass: TClass; Offset: Integer; ATarget: Pointer);
procedure WriteJumpBuffer(Location: Pointer; const Buffer: TPatchSimpleJump);
procedure ReadJumpBuffer(Location: Pointer; var Buffer: TPatchSimpleJump);
procedure SetJump(PatchLocation: Pointer; JumpTarget: Pointer;
                  var PatchLocationBackup: TPatchSimpleJump);
function GetActualAddress(AnAddr: Pointer): Pointer;    
{$ifndef Delphi6_Up}
procedure RaiseLastOSError;
{$endif}

//Following three functions copied from FastMM4.pas
//Returns true if the CPUID instruction is supported
function IsCPUIDSupported: Boolean;
//Gets the CPUID
function GetCPUID(AInfoRequired: Integer): TRegisters;
//Returns true if the CPU supports MMX
function IsMMXSupported: Boolean;

implementation

uses
  SysUtils;

var
  CurrentProcess: Cardinal;

//round an int value to upper/lower nearest "Base" multiplier
function  RoundInt(const AValue: Integer; ARoundBase: integer; RoundUp: boolean): integer;
begin
  if RoundUp then
    Result := (1 + (AValue - 1) div ARoundBase) * ARoundBase
  else
    Result := (AValue div ARoundBase) * ARoundBase;
end;

{$ifndef Delphi6_Up}
procedure RaiseLastOSError;
asm
  jmp   RaiseLastWin32Error
end;
{$endif}

procedure ReadMem(const Location, Buffer: Pointer; const Size: Cardinal);
var
  ReadBytes: Cardinal;
begin
  if (not ReadProcessMemory(CurrentProcess, Location,
    Buffer, Size, ReadBytes)) or (ReadBytes <> Size) then
    RaiseLastOSError;
end;

procedure WriteMem(const Location, Buffer: Pointer; const Size: Cardinal);
var
  WrittenBytes: Cardinal;
begin
  if (not WriteProcessMemory(CurrentProcess, Location,
    Buffer, Size, WrittenBytes)) or (WrittenBytes <> Size) then
    RaiseLastOSError;
  // make sure that everything keeps working in a dual processor setting
  FlushInstructionCache(CurrentProcess, Location, Size);
end;

//copied from JCL, but simplified
function GetVMTPointer(AClass: TClass; Offset: Integer): Pointer;
begin
  Result := PPointer(Integer(AClass) + Offset)^;
end;

procedure SetVMTPointer(AClass: TClass; Offset: Integer; ATarget: Pointer);
begin
  WriteMem(Pointer(Integer(AClass) + Offset), @ATarget, SizeOf(ATarget));
end;

procedure WriteJumpBuffer(Location: Pointer; const Buffer: TPatchSimpleJump);
begin
  WriteMem(Location, @Buffer, SizeOf(Buffer));
end;

procedure ReadJumpBuffer(Location: Pointer; var Buffer: TPatchSimpleJump);
begin
  ReadMem(Location, @Buffer, SizeOf(Buffer));
end;

procedure SetJump(PatchLocation: Pointer; JumpTarget: Pointer;
                  var PatchLocationBackup: TPatchSimpleJump);
var
  Buffer: TPatchSimpleJump;
begin
  ReadJumpBuffer(PatchLocation, PatchLocationBackup);

  Buffer.Jump := $E9;
  Buffer.Offset := Integer(JumpTarget) - (Integer(PatchLocation) + SizeOf(Buffer));

  WriteJumpBuffer(PatchLocation, Buffer);
end;

{ returns real address of proc/var if it is located in run-time package }
function GetDirectedAddr(AnAddr: Pointer): Pointer;

type
  PAbsoluteIndirectJmp = ^TAbsoluteIndirectJmp;
  TAbsoluteIndirectJmp = packed record
    OpCode: Word;   //$FF25(Jmp, FF /4), $FF15(Call, FF /2)
    Addr: ^Pointer;
  end;
  PRelativeJmpOrCall = ^TRelativeJmpOrCall;
  TRelativeJmpOrCall = packed record
    OpCode: Byte;   //$E9(Jmp),$E8(Call)
    Offset: LongInt;
  end;

begin
  if Assigned(AnAddr) then
  begin
    if (PAbsoluteIndirectJmp(AnAddr).OpCode = $25FF) or (PAbsoluteIndirectJmp(AnAddr).OpCode = $15FF) then
    begin
      Result := PAbsoluteIndirectJmp(AnAddr).Addr^;
    end
    else if (PRelativeJmpOrCall(AnAddr).OpCode = $E9){ or (PRelativeJmpOrCall(AnAddr).OpCode = $E8)} then
    begin
      Result := Pointer(Integer(AnAddr) + SizeOf(TRelativeJmpOrCall) + PRelativeJmpOrCall(AnAddr).Offset);
    end
    else begin
      Result := AnAddr;
    end;
  end
  else begin
    Result := nil;
  end;
end;

type
  PWin9xDebugThunk = ^TWin9xDebugThunk;
  TWin9xDebugThunk = packed record
    PUSH: Byte;    // PUSH instruction opcode ($68)
    Addr: Pointer; // The actual address of the DLL routine
    JMP: Byte;     // JMP instruction opcode ($E9)
    Rel: Integer;  // Relative displacement (a Kernel32 address)
  end;

function IsWin9xDebugThunk(AnAddr: Pointer): Boolean;
{ -> EAX: AnAddr }
asm
  TEST EAX, EAX
  JZ  @@NoThunk
  CMP BYTE PTR [EAX].TWin9xDebugThunk.PUSH, $68
  JNE @@NoThunk
  CMP BYTE PTR [EAX].TWin9xDebugThunk.JMP, $E9
  JNE @@NoThunk
  XOR EAX, EAX
  MOV AL, 1
  JMP @@exit
@@NoThunk:
  XOR EAX, EAX
@@exit:
end;

function GetActualAddress(AnAddr: Pointer): Pointer;
begin
  if Assigned(AnAddr) then
  begin
    if (SysUtils.Win32Platform <> VER_PLATFORM_WIN32_NT) and IsWin9xDebugThunk(AnAddr) then
      AnAddr := PWin9xDebugThunk(AnAddr).Addr;
    Result := GetDirectedAddr(AnAddr);
  end
  else
    Result := nil;
end;

//copied from FastMM4.pas
{----------------Utility Functions------------------}

//Returns true if the CPUID instruction is supported
function IsCPUIDSupported: Boolean;
asm
  pushfd
  pop eax
  mov edx, eax
  xor eax, $200000
  push eax
  popfd
  pushfd
  pop eax
  xor eax, edx
  setnz al
end;

//Gets the CPUID
function GetCPUID(AInfoRequired: Integer): TRegisters;
asm
  push ebx
  push esi
  mov esi, edx
  //cpuid instruction
{$ifndef Delphi6_Up}
  db $0f, $a2
{$else}
  cpuid
{$endif}
  //Save registers
  mov TRegisters[esi].RegEAX, eax
  mov TRegisters[esi].RegEBX, ebx
  mov TRegisters[esi].RegECX, ecx
  mov TRegisters[esi].RegEDX, edx
  pop esi
  pop ebx
end;

//Returns true if the CPU supports MMX
function IsMMXSupported: Boolean;
var
  LReg: TRegisters;
begin
  if IsCPUIDSupported then
  begin
    //Get the CPUID
    LReg := GetCPUID(1);
    //Bit 23 must be set for MMX support
    Result := LReg.RegEDX and $800000 <> 0;
  end
  else
    Result := False;
end;

{ THeapAllocator }
constructor THeapAllocator.Create(MarkExecutable: boolean);
begin
  inherited Create;
  FHeap := HeapCreate(0, 0, 0);
  if MarkExecutable then FFlags := PAGE_EXECUTE_READWRITE
                    else FFlags := 0; 
end;

function THeapAllocator.GetBlock(ASize: integer): Pointer;
var
  OldP : DWord;
begin
  Result := HeapAlloc(FHeap, 0, ASize);
  if (Result <> nil) and (FFlags <> 0) then
    if not VirtualProtect(Result, ASize, FFlags, OldP) then
      RaiseLastOSError;
end;

procedure THeapAllocator.FreeBlock(ABlock: Pointer);
begin
  HeapFree(FHeap, 0, ABlock);
end;

destructor THeapAllocator.Destroy;
begin
  HeapDestroy(FHeap);
  inherited Destroy; 
end;

initialization
  CurrentProcess := GetCurrentProcess;
finalization

end.
