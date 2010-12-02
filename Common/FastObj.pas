unit FastObj;
(*
//Gabriel Corneanu (gabrielcorneanu(AT)gmail.com)
//General purpose object create/destroy optimization

   Gabriel Corneanu
      - added SafeAutoOptimize mode; read comments
      - added InitAutoOptimize function, can be called from outside
        (instead of define AutoOptimize)
      - Simplified list handling
      - avoid FreeInstance override when reimplemented in a class; it's a sign
        for a special case!
      - solved instance size not multiple of 4 problem
      - much simplified exe block allocation
      - some MMX code (from fastcode), suggested by JiYuan Xie and much simplified
        (no FPU - I measured it much slower)
      - NewInstanceCopyLargeSizeWithFill optimized and rounded clear part
      - Store only template header (if header much smaller than template size)
      - distinguish between newinstance and freeinstance redirection
      - added cleanup optimitation: build a concatenated list of fields for
        all parent classes
        it should be noticeable for classes with several parents,
        containing dynamic fields on several levels (classes)
        and for classes with no dynamic fields
      - changed TObjectNewInstanceTrap to standalone; part of another class
        might be missleading
      - moved patching utilities and dynamic code allocator to standalone unit
      - added several init strategies
      - renamed unit to FastObj and the main class to TObjectAccelerator
        there is no explicit pooling anymore in this version 
      - created allocator for dynamic code
      - created option to disable global optimization
        use OptimizeClass instead to optimize individual classes
      - switch for version independent (no direct calls to FastMM)
      - fixed memory leaks
      - removed class name from offset asm statements, to avoid trouble when
        renaming the class
   Eric Grange (egrange at glscene.org)
      - reengineered around faster InitInstance sequence
      - automatic creation/registration of TClassPool instances
      - should be thread-safe
   JiYuan Xie (gdxjy at hotmail.com)
      - moved all conditional defines to FastObj.inc
      - added Delphi5 support (not tested)
      - added support for being used in package or dll whith sharing classes,
        TExecBlockAllocator has been modified to support this

   TODO:
      - more efficient CleanupInstance
      - think if BuildFreeInstanceSmallRecord makes sense
      - LOTS of testing :)


Cautions:
  FastObj CAN NOT coexist (in AutoOptimize mode) with any class with custom logic
  in NewInstance, which is doing anything else but initializing. FastObj will create
  identical copies of the first cached instance.
  In some cases (found in a singleton implementation that was using NewInstance logic),
  it can cause completely wrong effects.
  Possible solutions:
  - do not use AutoOptimize mode.
  - avoid using FastObj in such classes by not calling TObject.NewInstance (FreeInstance is safe).
  Instead, duplicate its meaning using these lines:
  GetMem(Pointer(Result), InstanceSize);
  InitInstance(Result);

  The new option is "SafeAutoOptimize", which will optimize only classes that DO NOT
  override NewInstance.
  Some known classes like TInterfacedObject are known to be safe and still optimizeed.

*)

{$Include FastObj.inc}

interface


//optimize a specific class, when global optimization is OFF
//DO NOT add the same class twice
procedure OptimizeClass(const AClass: TClass);

procedure InitAutoOptimize;
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
implementation
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

uses
{$ifdef UseFastMM}
  FastMM4,
{$endif}
  classes,
  patchlib,
//  SysUtils,
  typinfo,
  Windows;

type
   PRedirectCode_NoParam = ^TRedirectCode_NoParam;
   TRedirectCode_NoParam = packed record
      moveax     : Byte;     //mov eax, selfobj
      selfobj    : Pointer;
      jmp        : Byte;     //jmp offset(new address)
      jmpoffset  : Integer;
      jmpref     : byte;     //not used, just for reference
   end;
   PRedirectCode_OneParam = ^TRedirectCode_OneParam;
   TRedirectCode_OneParam = packed record
      movedx_eax : word;    //$89$C2 mov edx, eax: the old self is passed as param
      Redir      : TRedirectCode_NoParam;
   end;
//compile time check for code alignment
{$ifdef Delphi6_Up}
{$if SizeOf(TRedirectCode_OneParam) > 16}
  {$message fatal 'Check record declaration!'}
{$ifend}
{$endif}

//I wanted to use constants with only one ifdef UseFastMM
//but constant assignment doesn't work
//a variable would create another redirection level
{
type
  TGetMem  = function(Size: Integer): Pointer;
  TFreeMem = function(P: Pointer): Integer;
const
  DoGetMem : TGetMem  = GetMem;
  DoFreeMem: TFreeMem = system.FreeMem;
}

//from system.pas
type
  TFieldInfo = packed record
    TypeInfo : PTypeInfo;
    Offset_  : Cardinal;
  end;

  PFieldTable = ^TFieldTable;
  TFieldTable = packed record
    X: Word;
    Size: Cardinal;
    Count: Cardinal;
    Fields: array [0..0] of TFieldInfo;
  end;

  PFieldInfoArray = ^TFieldInfoArray;
  TFieldInfoArray = array[0..0] of TFieldInfo;

const
  SizePtr  = SizeOf(Pointer);

var
  Allocator : THeapAllocator = nil;
  NeedRegisterModuleUnload : Boolean = false;

type
  // TObjectAccelerator
  //
  TObjectAccelerator = class(TObject)
  private
    FClass             : TClass;
    FClassNewInstance  : Pointer;
    FClassFreeInstance : Pointer;
    FInstanceSize      : Integer;
    FHeaderDWords      : Integer;
    FTemplate          : Pointer;
    FFinalizeArray     : PFieldInfoArray;
    FFinalizeCnt       : cardinal;

    procedure InitRedirect_New(ALocation: PRedirectCode_NoParam; NewMethod: Pointer);
    procedure InitRedirect_Free(ALocation: PRedirectCode_OneParam; NewMethod: Pointer);
    procedure CleanupTemplate;

    function  NewInstanceCopySmall : TObject;
    function  NewInstanceCopyLargeSizeWithFill: TObject;
    function  NewInstanceCopyLargeSizeNoFill: TObject;

    function  NewInstanceNoHeader : TObject;
    function  NewInstanceNoHeaderLargeSize : TObject;
    function  NewInstanceNoField : TObject;

    procedure FreeInstanceOptimized(AObject: TObject);
    procedure FreeInstanceNoRecord(AObject: TObject);
    //function  BuildFreeInstanceSmallRecord: Pointer;
  public
    constructor Create(const AClass: TClass);
    destructor  Destroy; override;
    procedure   CleanDestroy;
  end;

const
  NewInstanceList : array[0..5] of pointer = (
    @TObjectAccelerator.NewInstanceCopySmall,
    @TObjectAccelerator.NewInstanceCopyLargeSizeWithFill,
    @TObjectAccelerator.NewInstanceCopyLargeSizeNoFill,

    @TObjectAccelerator.NewInstanceNoHeader,
    @TObjectAccelerator.NewInstanceNoHeaderLargeSize,
    @TObjectAccelerator.NewInstanceNoField
  );


var
  VmtOffsetNewInstance : Integer;
  VmtOffsetFreeInstance : Integer;

  AddrFinalizeArray : Pointer;
  AddrFreeMem       : Pointer;
  AddrTObjectNewInstance : Pointer;
  AddrTObjectFreeInstance : Pointer;

var
  vAccelerators: TList;
  vAcceleratorCS : TRTLCriticalSection;
  vTObjectNewInstanceFlag : Boolean = False;

  vTObjectNewInstanceJumpBackup : TPatchSimpleJump;
  AddrTObjectNewInstanceTrap : Pointer;
 {$ifdef SafeAutoOptimize}
  AddrTInterfacedObjectNewInstance : Pointer;
 {$endif}
 {$ifdef SafeNamesAutoOptimize}
  SafeClassList       : TStringList;
 {$endif}

 {$ifdef EnableMMX}
  {$ifndef ForceMMX}
  UseMMX: Boolean = false;
  {$endif}
{$endif}


const
{$ifdef EnableMMX}
  cSmallInstanceSize = 24;
{$else}
  cSmallInstanceSize = 32;
{$endif}

{$ifdef FastObjDebug}
procedure AddDebugText(const ALine: string);
var
  S : TStream;
begin
  S := TFileStream.Create(
    CreateFile(PChar(ParamStr(0) + '.fastobj'),
      GENERIC_WRITE, FILE_SHARE_READ, nil, OPEN_ALWAYS, 0, 0));
  S.Seek(0, soEnd);
  S.Write(ALine[1], Length(ALine));
  S.Write(sLineBreak[1], Length(sLineBreak));
  S.Free;
end;
{$endif}

//TypeInfo is dereferenced! to avoid extra operation
procedure BuildFinalizeInfoArray(const AClass: TClass;
                             var AnArray: PFieldInfoArray;
                             var AnArrayLength: Cardinal);
var
  FT: PFieldTable;
  typeinfo : pointer;
  I, S : integer;
  N : cardinal;
  LoopClass : TClass;
begin
  AnArray := nil;
  AnArrayLength := 0;
  N := 0;
  for S := 1 to 2 do
  begin
    LoopClass := AClass;
    if S = 2 then
    begin
      GetMem(AnArray, N * SizeOf(AnArray[0]));
    end;
    while LoopClass <> nil do
    begin
      typeinfo := PPointer(Integer(LoopClass) + vmtInitTable)^;
      if typeinfo <> nil then
      begin
        FT := PFieldTable(Integer(typeInfo) + Byte(PTypeInfo(typeInfo).Name[0]));
        //first step just count, second step build
        if S = 1 then
          Inc(N, FT.Count)
        else
        begin
          for I := 0 to FT.Count - 1 do
          begin
            AnArray[AnArrayLength] := FT.Fields[I];
            //dereference now!
            AnArray[AnArrayLength].TypeInfo := PPointer(AnArray[AnArrayLength].TypeInfo)^;
            Inc(AnArrayLength);
          end;
        end;
      end;
      LoopClass := LoopClass.ClassParent;
    end;
  end;
end;

{ TObjectAccelerator }
// Create
//
constructor TObjectAccelerator.Create(const AClass: TClass);
var
  i : Integer;
  HdrFld : PInteger;
  NewInstanceRedirect  : Pointer;
  FreeInstanceRedirect : Pointer;
begin
   FClass     := AClass;
   //we always need multiple of 4!
   //if this is not valid, it is rejected in CreateOptimizer
   FInstanceSize  := patchlib.RoundInt(FClass.InstanceSize, 4, true);

   // get vmt entries!
   // keep them to be able to restore
   FClassNewInstance  := GetActualAddress(GetVMTPointer(FClass, VmtOffsetNewInstance));
   FClassFreeInstance := GetActualAddress(GetVMTPointer(FClass, VmtOffsetFreeInstance));
   //NewInstanceRedirect  := nil;
   FreeInstanceRedirect := nil;

   //gc: usually NewInstance has some interface related tricks
   //it is safe as long as the result is constant, and NewInstance is reentrant

   // get template
   FTemplate      := FClass.NewInstance;
   // analyse template
   FHeaderDWORDs := 0;
   HdrFld       := FTemplate;
   for i := 0 to (FInstanceSize div SizePtr) -1 do
   begin
     if HdrFld^ <> 0 then FHeaderDWORDs:=i+1;
     Inc(HdrFld);
   end;

   //always cleanup, because we just keep the data!
   TObject(FTemplate).CleanupInstance;

   //initialize the dynamic code here
   NewInstanceRedirect  := Allocator.GetBlock(SizeOf(TRedirectCode_NoParam));
     
   // prepare dynamic code
   // different strategies
   if FHeaderDWORDs > 1 then
   begin
     I := FHeaderDWords * SizePtr;
     if (FInstanceSize >= cSmallInstanceSize) then
     begin
       //GC: important
       //make fill part multiple of 32, to simplify and gain speed in fill instructions
       I := FInstanceSize - RoundInt(FInstanceSize - I, 32, false);
       FHeaderDWords := I div SizePtr;
       if I > 0 then
            InitRedirect_New(NewInstanceRedirect,  @TObjectAccelerator.NewInstanceCopyLargeSizeWithFill)
       else InitRedirect_New(NewInstanceRedirect,  @TObjectAccelerator.NewInstanceCopyLargeSizeNoFill);
       //if difference is significant (to be defined), keep only necessary information from the template
       if FInstanceSize - I > 64 then
         ReallocMem(FTemplate, I);
     end
     else
       InitRedirect_New(NewInstanceRedirect,  @TObjectAccelerator.NewInstanceCopySmall);
   end
   else begin
     CleanupTemplate;
     if FInstanceSize > SizePtr then
     begin
       if FInstanceSize >= cSmallInstanceSize then
          InitRedirect_New(NewInstanceRedirect,  @TObjectAccelerator.NewInstanceNoHeaderLargeSize)
       else InitRedirect_New(NewInstanceRedirect,  @TObjectAccelerator.NewInstanceNoHeader)
     end
     else InitRedirect_New(NewInstanceRedirect,  @TObjectAccelerator.NewInstanceNoField);
   end;

   //GC: do NOT override FreeInstance when it's reimplemented!
   //it's sign of a tricky class
   if FClassFreeInstance <> AddrTObjectFreeInstance then
     FClassFreeInstance := nil
   else
   begin
     BuildFinalizeInfoArray(FClass, FFinalizeArray, FFinalizeCnt);
     {
       GC:
       BuildFreeInstanceSmallRecord is building a simple dynamic asm code
       I don't know if it makes sense, and plus we need variable size allocator
     }
     {
     if (FFinalizeCnt > 0) and (FFinalizeCnt <= 2) then
       FreeInstanceRedirect := BuildFreeInstanceSmallRecord
     else
     }
     begin
       FreeInstanceRedirect := Allocator.GetBlock(SizeOf(TRedirectCode_OneParam));
       if FFinalizeCnt > 0 then
         InitRedirect_Free(FreeInstanceRedirect, @TObjectAccelerator.FreeInstanceOptimized)
       else InitRedirect_Free(FreeInstanceRedirect, @TObjectAccelerator.FreeInstanceNoRecord);
     end;
   end;

   // rewrite vmt entries
   if NewInstanceRedirect <> nil then
     SetVMTPointer(FClass, VmtOffsetNewInstance,   NewInstanceRedirect);
   if FreeInstanceRedirect <> nil then
     SetVMTPointer(FClass, VmtOffsetFreeInstance,  FreeInstanceRedirect);

   if (NewInstanceRedirect = nil) and (FreeInstanceRedirect = nil) then
     FClass := nil;
end;

// Destroy
//
destructor TObjectAccelerator.Destroy;
begin
   // restore vmt entries
   if FClass <> nil then
   begin
     SetVMTPointer(FClass, VmtOffsetNewInstance,   FClassNewInstance);
     SetVMTPointer(FClass, VmtOffsetFreeInstance,  FClassFreeInstance);
   end;
   FreeMem(FFinalizeArray);
   CleanupTemplate;
end;

procedure TObjectAccelerator.CleanDestroy;
var
  RedirectBlock : Pointer;
begin
  if NeedRegisterModuleUnload then
  begin
    RedirectBlock := GetVMTPointer(FClass, VmtOffsetNewInstance);
    if (RedirectBlock <> FClassNewInstance) then
       Allocator.FreeBlock(RedirectBlock);
    RedirectBlock := GetVMTPointer(FClass, VmtOffsetFreeInstance);
    if (RedirectBlock <> FClassFreeInstance) then
       Allocator.FreeBlock(RedirectBlock);
  end;
  Destroy;
end;

// InitRedirect
//
procedure TObjectAccelerator.InitRedirect_New(ALocation: PRedirectCode_NoParam; NewMethod: Pointer);
begin
   with ALocation^ do begin
      moveax     := $B8;   //move eax, self
      selfobj    := self;  //self is our object
      jmp        := $E9;   //jump call
      jmpoffset  := Integer(NewMethod) - Integer(@ALocation.jmpref);
   end;
end;

procedure TObjectAccelerator.InitRedirect_Free(ALocation: PRedirectCode_OneParam; NewMethod: Pointer);
begin
  InitRedirect_New(@ALocation.Redir, NewMethod);
  ALocation.movedx_eax := $C289; //$89$C2 mov edx, eax: the old self is passed as param
end;

// CleanupTemplate
//
procedure TObjectAccelerator.CleanupTemplate;
begin
   if FTemplate<>nil then begin
      FreeMem(FTemplate);
      FTemplate := nil;
   end;
end;

// NewInstanceCopySmall
//
function TObjectAccelerator.NewInstanceCopySmall: TObject;
//   Result:=TObject(FastGetMem(FInstanceSize));
//   Move(Pointer(FTemplate)^, Pointer(Result)^, FInstanceSize);
asm
   push  ebx
   mov   ebx, eax

   mov   eax, [eax + offset FInstanceSize]
{$ifdef UseFastMM}
   call  FastGetMem
{$else}
   call  system.@GetMem
{$endif}

   mov   ecx, [ebx + offset FInstanceSize]
   mov   ebx, [ebx + offset FTemplate]

@@CopyLoop:
   //shorter code
   sub   ecx, SizePtr
   mov   edx, [ebx+ecx]
   mov   [eax+ecx], edx
   jnz   @@CopyLoop

   pop   ebx
end;

// NewInstanceCopyLargeSizeNoFill
// Large copy without filling
function TObjectAccelerator.NewInstanceCopyLargeSizeNoFill: TObject;
asm
  push  esi
  push  edi

  mov   edi, eax  //save self

  mov   eax, [eax + FInstanceSize]
  mov   esi, eax //save FInstanceSize
{$ifdef UseFastMM}
  call  FastGetMem
{$else}
  call  System.@GetMem
{$endif}

  mov   ecx, esi
  mov   esi, [edi + FTemplate] //esi = FTemplate
  mov   edi, eax //edi = NewInstance

{$ifndef ForceMMX}
  {$ifdef EnableMMX}
  cmp   UseMMX, True
  je    @@MMXMove
  {$endif}

  shr   ecx,  2
  rep   movsd

  {$ifdef EnableMMX}
  pop   edi
  pop   esi
  ret
  {$endif}
{$endif} //ForceMMX

{$ifdef EnableMMX}
@@MMXMove:
  //GC: the fastmove code using edx as source,
  //TODO: could change to esi, because it already contains the source
  //any points against? Delphi 5 code must be adapted

  mov   edx, esi
  add   edi, ecx //edi now is the start address
  add   edx, ecx
  neg   ecx
  add   ecx, 32

@@MMXMove32Loop:
  {$ifndef Delphi6_Up}
  db    $0F, $6F, $44, $11, $E0
  db    $0F, $6F, $4C, $11, $E8
  db    $0F, $6F, $54, $11, $F0
  db    $0F, $6F, $5C, $11, $F8
  db    $0F, $7F, $44, $39, $E0
  db    $0F, $7F, $4C, $39, $E8
  db    $0F, $7F, $54, $39, $F0
  db    $0F, $7F, $5C, $39, $F8
  {$else}
  movq  mm0, [edx + ecx - 32]
  movq  mm1, [edx + ecx - 24]
  movq  mm2, [edx + ecx - 16]
  movq  mm3, [edx + ecx - 8]
  movq  [edi + ecx - 32], mm0
  movq  [edi + ecx - 24], mm1
  movq  [edi + ecx - 16], mm2
  movq  [edi + ecx - 8], mm3
  {$endif}
  add   ecx, 32
  jle   @@MMXMove32Loop
  nop
  nop
  nop
@@MMXMoveDWords:
  jmp   dword ptr [@@MMXMoveJumpTable + ecx]
  nop
  nop
  nop
@@MMXMoveJumpTable:
  dd    @@MMXMove32
  dd    @@MMXMove28
  dd    @@MMXMove24
  dd    @@MMXMove20
  dd    @@MMXMove16
  dd    @@MMXMove12
  dd    @@MMXMove8
  dd    @@MMXMove4
  dd    @@MMXMove0

  //Exit mmx state
  //will be called later in clear part
  //emms
@@MMXMove28:
  {$ifndef Delphi6_Up}
  db    $0F, $6F, $44, $11, $E0
  db    $0F, $6F, $4C, $11, $E8
  db    $0F, $6F, $54, $11, $F0
  {$else}
  movq  mm0, [edx + ecx - 32]
  movq  mm1, [edx + ecx - 24]
  movq  mm2, [edx + ecx - 16]
  {$endif}
  mov   edx, [edx + ecx - 8]
  {$ifndef Delphi6_Up}
  db    $0F, $7F, $44, $39, $E0
  db    $0F, $7F, $4C, $39, $E8
  db    $0F, $7F, $54, $39, $F0
  {$else}
  movq  [edi + ecx - 32], mm0
  movq  [edi + ecx - 24], mm1
  movq  [edi + ecx - 16], mm2
  {$endif}
  mov   [edi + ecx - 8], edx
  jmp   @@MMXMoveDone
  nop
@@MMXMove24:
  {$ifndef Delphi6_Up}
  db    $0F, $6F, $44, $11, $E0
  db    $0F, $6F, $4C, $11, $E8
  db    $0F, $6F, $54, $11, $F0
  db    $0F, $7F, $44, $39, $E0
  db    $0F, $7F, $4C, $39, $E8
  db    $0F, $7F, $54, $39, $F0
  {$else}
  movq  mm0, [edx + ecx - 32]
  movq  mm1, [edx + ecx - 24]
  movq  mm2, [edx + ecx - 16]
  movq  [edi + ecx - 32], mm0
  movq  [edi + ecx - 24], mm1
  movq  [edi + ecx - 16], mm2
  {$endif}
  jmp   @@MMXMoveDone
@@MMXMove20:
  {$ifndef Delphi6_Up}
  db    $0F, $6F, $44, $11, $E0
  db    $0F, $6F, $4C, $11, $E8
  {$else}
  movq  mm0, [edx + ecx - 32]
  movq  mm1, [edx + ecx - 24]
  {$endif}
  mov   edx, [edx + ecx - 16]
  {$ifndef Delphi6_Up}
  db    $0F, $7F, $44, $39, $E0
  db    $0F, $7F, $4C, $39, $E8
  {$else}
  movq  [edi + ecx - 32], mm0
  movq  [edi + ecx - 24], mm1
  {$endif}
  mov   [edi + ecx - 16], edx
  jmp   @@MMXMoveDone
  nop
  nop
@@MMXMove16:
  {$ifndef Delphi6_Up}
  db    $0F, $6F, $44, $11, $E0
  db    $0F, $6F, $4C, $11, $E8
  db    $0F, $7F, $44, $39, $E0
  db    $0F, $7F, $4C, $39, $E8
  {$else}
  movq  mm0, [edx + ecx - 32]
  movq  mm1, [edx + ecx - 24]
  movq  [edi + ecx - 32], mm0
  movq  [edi + ecx - 24], mm1
  {$endif}
  jmp   @@MMXMoveDone
  nop
  nop
@@MMXMove12:
  {$ifndef Delphi6_Up}
  db    $0F, $6F, $44, $11, $E0
  {$else}
  movq  mm0, [edx + ecx - 32]
  {$endif}
  mov   edx, [edx + ecx - 24]
  {$ifndef Delphi6_Up}
  db    $0F, $7F, $44, $39, $E0
  {$else}
  movq  [edi + ecx - 32], mm0
  {$endif}
  mov   [edi + ecx - 24], edx
  jmp   @@MMXMoveDone
@@MMXMove8:
  {$ifndef Delphi6_Up}
  db    $0F, $6F, $44, $11, $E0
  db    $0F, $7F, $44, $39, $E0
  {$else}
  movq  mm0, [edx + ecx - 32]
  movq  [edi + ecx - 32], mm0
  {$endif}
  jmp   @@MMXMoveDone
@@MMXMove4:
  mov   edx, [edx + ecx - 32]
  mov   [edi + ecx - 32], edx
@@MMXMove32:
@@MMXMove0:
@@MMXMoveDone:
  {Exit mmx state}
  {$ifndef Delphi6_Up}
  db    $0F, $77
  {$else}
  emms
  {$endif}
{$endif}

@@Exit:
  pop   edi
  pop   esi
end;


// NewInstanceCopyLargeSizeWithFill
// Intended for larger amount of data to copy
function TObjectAccelerator.NewInstanceCopyLargeSizeWithFill: TObject;
//   Result:=TObject(FastGetMem(FInstanceSize));
//   Move(Pointer(FTemplate)^, Pointer(Result)^, FHeaderDWords*4);
//   FillChar(Pointer(FTemplate)^, FInstanceSize - FHeaderDWords*4);
asm
  push  esi
  push  edi

  mov   edi, eax  //save self

  mov   eax, [eax + FInstanceSize]
  mov   esi, eax //save FInstanceSize
{$ifdef UseFastMM}
  call  FastGetMem
{$else}
  call  System.@GetMem
{$endif}

{$ifndef ForceMMX}
  {$ifdef EnableMMX}
  cmp   UseMMX, True
  je    @@MMXMove
  {$endif}

  mov   edx,  esi
  shr   edx,  2
  mov   esi, [edi + FTemplate] //esi = FTemplate
  mov   ecx, [edi + FHeaderDWords] //ecx = FHeaderDWords
  sub   edx, ecx //edx = size to fill

  mov   edi, eax //edi = NewInstance
  rep   movsd

  mov   ecx, edx //ecx = size to fill
  mov   edx, eax //edx = NewInstance
  xor   eax, eax //eax = 0
  rep   stosd

  mov   eax, edx
{$endif} //ForceMMX

{$ifdef EnableMMX}
@@MMXMove:

//move part
  mov   ecx, [edi + FHeaderDWords]
  shl   ecx, 2
  sub   esi, ecx //size to fill

  mov   edx, [edi + FTemplate]
  mov   edi, eax

  add   edx, ecx
  add   edi, ecx //edi now is the start address
  neg   ecx
  add   ecx, 32

  jnle  @@MMXMoveDWords

@@MMXMove32Loop:
  {$ifndef Delphi6_Up}
  db    $0F, $6F, $44, $11, $E0
  db    $0F, $6F, $4C, $11, $E8
  db    $0F, $6F, $54, $11, $F0
  db    $0F, $6F, $5C, $11, $F8
  db    $0F, $7F, $44, $39, $E0
  db    $0F, $7F, $4C, $39, $E8
  db    $0F, $7F, $54, $39, $F0
  db    $0F, $7F, $5C, $39, $F8
  {$else}
  movq  mm0, [edx + ecx - 32]
  movq  mm1, [edx + ecx - 24]
  movq  mm2, [edx + ecx - 16]
  movq  mm3, [edx + ecx - 8]
  movq  [edi + ecx - 32], mm0
  movq  [edi + ecx - 24], mm1
  movq  [edi + ecx - 16], mm2
  movq  [edi + ecx - 8], mm3
  {$endif}
  add   ecx, 32
  jle   @@MMXMove32Loop
  nop
  nop
  nop
@@MMXMoveDWords:
  jmp   dword ptr [@@MMXMoveJumpTable + ecx]
  nop
  nop
  nop
@@MMXMoveJumpTable:
  dd    @@MMXMove32
  dd    @@MMXMove28
  dd    @@MMXMove24
  dd    @@MMXMove20
  dd    @@MMXMove16
  dd    @@MMXMove12
  dd    @@MMXMove8
  dd    @@MMXMove4
  dd    @@MMXMove0

  //Exit mmx state
  //will be called later in clear part
  //emms
@@MMXMove28:
  {$ifndef Delphi6_Up}
  db    $0F, $6F, $44, $11, $E0
  db    $0F, $6F, $4C, $11, $E8
  db    $0F, $6F, $54, $11, $F0
  {$else}
  movq  mm0, [edx + ecx - 32]
  movq  mm1, [edx + ecx - 24]
  movq  mm2, [edx + ecx - 16]
  {$endif}
  mov   edx, [edx + ecx - 8]
  {$ifndef Delphi6_Up}
  db    $0F, $7F, $44, $39, $E0
  db    $0F, $7F, $4C, $39, $E8
  db    $0F, $7F, $54, $39, $F0
  {$else}
  movq  [edi + ecx - 32], mm0
  movq  [edi + ecx - 24], mm1
  movq  [edi + ecx - 16], mm2
  {$endif}
  mov   [edi + ecx - 8], edx
  jmp   @@MMXMoveDone
  nop
@@MMXMove24:
  {$ifndef Delphi6_Up}
  db    $0F, $6F, $44, $11, $E0
  db    $0F, $6F, $4C, $11, $E8
  db    $0F, $6F, $54, $11, $F0
  db    $0F, $7F, $44, $39, $E0
  db    $0F, $7F, $4C, $39, $E8
  db    $0F, $7F, $54, $39, $F0
  {$else}
  movq  mm0, [edx + ecx - 32]
  movq  mm1, [edx + ecx - 24]
  movq  mm2, [edx + ecx - 16]
  movq  [edi + ecx - 32], mm0
  movq  [edi + ecx - 24], mm1
  movq  [edi + ecx - 16], mm2
  {$endif}
  jmp   @@MMXMoveDone
@@MMXMove20:
  {$ifndef Delphi6_Up}
  db    $0F, $6F, $44, $11, $E0
  db    $0F, $6F, $4C, $11, $E8
  {$else}
  movq  mm0, [edx + ecx - 32]
  movq  mm1, [edx + ecx - 24]
  {$endif}
  mov   edx, [edx + ecx - 16]
  {$ifndef Delphi6_Up}
  db    $0F, $7F, $44, $39, $E0
  db    $0F, $7F, $4C, $39, $E8
  {$else}
  movq  [edi + ecx - 32], mm0
  movq  [edi + ecx - 24], mm1
  {$endif}
  mov   [edi + ecx - 16], edx
  jmp   @@MMXMoveDone
  nop
  nop
@@MMXMove16:
  {$ifndef Delphi6_Up}
  db    $0F, $6F, $44, $11, $E0
  db    $0F, $6F, $4C, $11, $E8
  db    $0F, $7F, $44, $39, $E0
  db    $0F, $7F, $4C, $39, $E8
  {$else}
  movq  mm0, [edx + ecx - 32]
  movq  mm1, [edx + ecx - 24]
  movq  [edi + ecx - 32], mm0
  movq  [edi + ecx - 24], mm1
  {$endif}
  jmp   @@MMXMoveDone
  nop
  nop
@@MMXMove12:
  {$ifndef Delphi6_Up}
  db    $0F, $6F, $44, $11, $E0
  {$else}
  movq  mm0, [edx + ecx - 32]
  {$endif}
  mov   edx, [edx + ecx - 24]
  {$ifndef Delphi6_Up}
  db    $0F, $7F, $44, $39, $E0
  {$else}
  movq  [edi + ecx - 32], mm0
  {$endif}
  mov   [edi + ecx - 24], edx
  jmp   @@MMXMoveDone
@@MMXMove8:
  {$ifndef Delphi6_Up}
  db    $0F, $6F, $44, $11, $E0
  db    $0F, $7F, $44, $39, $E0
  {$else}
  movq  mm0, [edx + ecx - 32]
  movq  [edi + ecx - 32], mm0
  {$endif}
  jmp   @@MMXMoveDone
@@MMXMove4:
  mov   edx, [edx + ecx - 32]
  mov   [edi + ecx - 32], edx
@@MMXMove32:
@@MMXMove0:
@@MMXMoveDone:

//clear part
  //should ensure size to fill multiple of 32 bytes
  //fill start addr

@@MMXClear:
  //gc: xor was missing!
  {$ifndef Delphi6_Up}
  xor   edx, edx
  db    $0F, $6E, $C2
  {$else}
  pxor  mm0, mm0
  {$endif}

  mov   ecx, esi //size to fill

  add   edi, ecx
  neg   ecx
  add   ecx, 32
  jnle  @@MMXClearDWords

@@MMXClear32Loop:
  {$ifndef Delphi6_Up}
  db    $0F, $7F, $44, $39, $E0
  db    $0F, $7F, $44, $39, $E8
  db    $0F, $7F, $44, $39, $F0
  db    $0F, $7F, $44, $39, $F8
  {$else}
  movq  [edi + ecx - 32], mm0
  movq  [edi + ecx - 24], mm0
  movq  [edi + ecx - 16], mm0
  movq  [edi + ecx - 8], mm0
  {$endif}
  add   ecx, 32
  jle   @@MMXClear32Loop

@@MMXClearDWords:
//nothig here! all clear should be 32 byte
@@MMXClearDone:
  {Exit mmx state}
  {$ifndef Delphi6_Up}
  db    $0F, $77
  {$else}
  emms
  {$endif}
{$endif}

@@Exit:
  pop   edi
  pop   esi
end;

// NewInstanceNoHeader
//
function TObjectAccelerator.NewInstanceNoHeader : TObject;
asm
   push  eax

   mov   eax, [eax + offset FInstanceSize]
{$ifdef UseFastMM}
   call  FastGetMem
{$else}
   call  system.@GetMem
{$endif}

   pop   edx
   mov   ecx, [edx + offset FClass]
   mov   [eax], ecx
   mov   ecx, [edx + offset FInstanceSize]
   xor   edx, edx
   sub   ecx, SizePtr
@@RAZLoop:
   mov   [eax+ecx], edx
   sub   ecx, SizePtr
   jnz   @@RAZLoop
end;

// NewInstanceNoHeaderLargeSize
// For larger sizes
function TObjectAccelerator.NewInstanceNoHeaderLargeSize : TObject;
asm
  push  edi

  push  dword ptr [eax + offset FClass]
  mov   eax, [eax + offset FInstanceSize]
  mov   edi, eax

{$ifdef UseFastMM}
  call  FastGetMem
{$else}
  call  system.@GetMem
{$endif}

  mov   ecx, edi
  mov   edi, eax

{$ifndef ForceMMX}
  {$ifdef EnableMMX}
  cmp   UseMMX, True
  je    @@MMXClear
  {$endif}

  shr   ecx, 2     //count DIV 4 dwords
  mov   edx, eax
  xor   eax, eax

  rep   stosd

  mov   eax, edx
  pop   dword ptr [eax]
  pop   edi
  ret   
{$endif}

{$ifdef EnableMMX}
@@MMXClear:
  add   edi, ecx      //edi point to end of NewInstance
  sub   ecx, SizePtr  //exclude the class pointer
  xor   edx, edx

  {$ifndef Delphi6_Up}
  db    $0F, $6E, $C2
  {$else}
  movd  mm0, edx
  {$endif}

  neg   ecx
  add   ecx, 32
  jnle  @@MMXClearDWords
  
@@MMXClear32Loop:
  {$ifndef Delphi6_Up}
  db    $0F, $7F, $44, $39, $E0
  db    $0F, $7F, $44, $39, $E8
  db    $0F, $7F, $44, $39, $F0
  db    $0F, $7F, $44, $39, $F8
  {$else}
  movq  [edi + ecx - 32], mm0
  movq  [edi + ecx - 24], mm0
  movq  [edi + ecx - 16], mm0
  movq  [edi + ecx - 8], mm0
  {$endif}
  add   ecx, 32
  jle   @@MMXClear32Loop

@@MMXClearDWords:
  jmp   dword ptr [@@MMXClearJumpTable + ecx]
  nop
  nop
  nop
@@MMXClearJumpTable:
  dd    @@MMXClear32
  dd    @@MMXClear28
  dd    @@MMXClear24
  dd    @@MMXClear20
  dd    @@MMXClear16
  dd    @@MMXClear12
  dd    @@MMXClear8
  dd    @@MMXClear4
  dd    @@MMXClear0

@@MMXClear28:
  mov   [edi + ecx - 8], edx
@@MMXClear24:
  {$ifndef Delphi6_Up}
  db    $0F, $7F, $44, $39, $E0
  db    $0F, $7F, $44, $39, $E8
  db    $0F, $7F, $44, $39, $F0
  {$else}
  movq  [edi + ecx - 32], mm0
  movq  [edi + ecx - 24], mm0
  movq  [edi + ecx - 16], mm0
  {$endif}
  jmp   @@MMXClearDone
  nop
  nop
@@MMXClear20:
  mov   [edi + ecx - 16], edx
@@MMXClear16:
  {$ifndef Delphi6_Up}
  db    $0F, $7F, $44, $39, $E0
  db    $0F, $7F, $44, $39, $E8
  {$else}
  movq  [edi + ecx - 32], mm0
  movq  [edi + ecx - 24], mm0
  {$endif}
  jmp   @@MMXClearDone
@@MMXClear12:
  mov   [edi + ecx - 24], edx
@@MMXClear8:
  {$ifndef Delphi6_Up}
  db    $0F, $7F, $44, $39, $E0
  {$else}
  movq  [edi + ecx - 32], mm0
  {$endif}
  jmp   @@MMXClearDone
  nop
@@MMXClear4:
  mov   [edi + ecx - 32], edx
@@MMXClear32:
@@MMXClear0:
@@MMXClearDone:
  {Exit mmx state}
  {$ifndef Delphi6_Up}
  db    $0F, $77
  {$else}
  emms
  {$endif}
{$endif}
  pop   dword ptr [eax]
  pop   edi
end;

// NewInstanceNoField
//
function TObjectAccelerator.NewInstanceNoField : TObject;
asm
   push  dword ptr [eax + offset FClass]

   mov   eax, [eax + offset FInstanceSize]
{$ifdef UseFastMM}
   call  FastGetMem
{$else}
   call  system.@GetMem
{$endif}

   pop   dword ptr [eax]
end;

//BuildFreeInstanceSmallRecord
//builds a dynamic code for faster cleanup
(*
function TObjectAccelerator.BuildFreeInstanceSmallRecord: Pointer;
var
  Buffer : PByteArray;
  L      : cardinal;
  procedure StoreBytes(const Bytes: array of byte);
  var
    S : integer;
  begin
    S := Length(Bytes);
    move(Bytes[0], Buffer[L], S);
    Inc(L, S);
  end;
  procedure StoreByteAndDWord(const AByte: byte; const ADWord: DWord);
  begin
    StoreBytes([AByte]);
    StoreBytes(LongRec(ADWord).Bytes);
  end;
var
  I, N : integer;
begin
  N := 3 + (-2) + FFinalizeCnt * (2 + 5 + 5 + 5 + 5) + 3 + 5;
  //GC: not valid anymore!!
  {$message warn 'solve this'}
  //Result := nil;
  Result := Allocator.GetBlock(N);
  Buffer := Result;
  L := 0;
  StoreBytes([$53, //push ebx
    $89,$C3]);     //mov ebx, eax
  for I := 0 to FFinalizeCnt - 1 do
  begin
    //mov eax, ebx
    if I > 0 then StoreBytes([$89,$D8]);
    //add eax, offset
    StoreByteAndDWord($05, FFinalizeArray[I].Offset_);
    //mov edx, typeinfo
    StoreByteAndDWord($BA, dword(FFinalizeArray[I].TypeInfo));
    //mov ecx, 1
    StoreByteAndDWord($B9, 1);
    //call FinalizeArray
    StoreByteAndDWord($E8, DWord(AddrFinalizeArray) - (DWord(Result) + L + 5));
  end;

  StoreBytes([
    $89,$D8,      //mov eax, ebx
    $5B           //pop ebx
  ]);
  //jmp freemem
  StoreByteAndDWord($E9, DWord(AddrFreeMem) - (DWord(Result) + L + 5));
end;
*)

// FreeInstanceNoRecord
//
procedure TObjectAccelerator.FreeInstanceNoRecord(AObject: TObject);
asm
  mov  eax, edx
{$ifdef UseFastMM}
  jmp  FastFreeMem
{$else}
  jmp  system.@FreeMem
{$endif}
end;

// FreeInstanceOptimized
//
procedure TObjectAccelerator.FreeInstanceOptimized(AObject: TObject);
{$ifdef purepascal}
var
  I   : integer;
  Adr : Pointer;
  TI  : Pointer;
begin
  for I := 0 to FFinalizeCnt - 1 do
  begin
    Cardinal(Adr) := Cardinal(AObject)+FFinalizeArray[I].Offset;
    TI            := FFinalizeArray[I].TypeInfo;
    asm
      mov eax, Adr
      mov edx, TI
      mov ecx, 1
      call system.@FinalizeArray
    end;
  end;
  FreeMem(Pointer(AObject));
{$else}
asm
  push edi
  push esi
  push ebx
  mov  ebx, [eax + offset FFinalizeCnt]
  mov  edi, edx
  mov  esi, [eax + offset FFinalizeArray]

@loop:
  mov  eax, TFieldInfo[esi].Offset_
  add  eax, edi
  mov  edx, TFieldInfo[esi].TypeInfo
  mov  ecx, 1
  call system.@FinalizeArray
  //GC: I don't see any real speed improvment
  //call fastsys.FinalizeSingleElementArray
  add  esi, TYPE TFieldInfo  //SizeOf(TFieldInfo)
  dec  ebx
  jnz  @loop

  mov  eax, edi
  pop  ebx
  pop  esi
  pop  edi

{$ifdef UseFastMM}
  jmp  FastFreeMem
{$else}
  jmp  system.@FreeMem
{$endif}
{$endif}
end;

// CleanupList
//
procedure CleanupList;
var
  I : integer;
begin
  EnterCriticalSection(vAcceleratorCS);
  for I := 0 to vAccelerators.Count - 1 do
  begin
    TObject(vAccelerators[I]).Free;
  end;
  vAccelerators.Free;
  LeaveCriticalSection(vAcceleratorCS);
end;

procedure CreateOptimizer(const AClass: TClass);
type
  TCheckAlign = record
    X : byte;
    Y : dword;
  end;
var
  NewObj : TObjectAccelerator;
begin
  if not vTObjectNewInstanceFlag then begin
{$ifndef ForceRoundInstanceSize}
  {$ifdef Delphi6_Up}
  {$if SizeOf(TCheckAlign) mod 4 <> 0 }
    {$message warn 'It seems that alignment is < 4. FastObj might not process some classes. Define "ForceRoundInstanceSize" to force it.'}
  {$ifend}
  {$endif}
    if AClass.InstanceSize mod 4 <> 0 then exit;
{$endif ForceRoundInstanceSize}
    EnterCriticalSection(vAcceleratorCS);
    vTObjectNewInstanceFlag:=True;
    NewObj := TObjectAccelerator.Create(AClass);
    //this means the class was rejected for any reason
    if NewObj.FClass = nil then
         NewObj.Free
    else vAccelerators.Add(NewObj);
{$ifdef FastObjDebug}
    AddDebugText('Optimize class: '+AClass.ClassName);
{$endif}
    vTObjectNewInstanceFlag:=False;
    LeaveCriticalSection(vAcceleratorCS);
  end;
end;

procedure OptimizeClass(const AClass: TClass);
var
  Addr : Pointer;
  I : integer;
begin
  Addr := GetActualAddress(GetVMTPointer(AClass, VmtOffsetNewInstance));
  for I := 0 to High(NewInstanceList) do
    if Addr = NewInstanceList[I] then exit;

  CreateOptimizer(AClass);
end;

// TObjectNewInstanceTrap
// This trap replaces TObject's NewInstance
//
function TObjectNewInstanceTrap(AClass: TClass): TObject;
{$ifdef SafeAutoOptimize}
var
  AdrNewInstance : Pointer;
{$endif}
begin
//Duplicate TObject.NewInstance behavior
{$ifdef UseFastMM}
  Result := AClass.InitInstance(FastGetMem(AClass.InstanceSize));
{$else}
  GetMem(Pointer(Result), AClass.InstanceSize);
  AClass.InitInstance(Result);
{$endif}

{$ifdef SafeAutoOptimize}
  AdrNewInstance := GetActualAddress(GetVMTPointer(AClass,VmtOffsetNewInstance));
  if (AdrNewInstance <> AddrTObjectNewInstanceTrap)
    and (AdrNewInstance <> AddrTObjectNewInstance)
    and (AdrNewInstance <> AddrTInterfacedObjectNewInstance)
  {$ifdef SafeNamesAutoOptimize}
    and (SafeClassList.IndexOf(AClass.ClassName) < 0)
  {$endif}
    then
    begin
 {$ifdef FastObjDebug}
      AddDebugText('Skip class: '+AClass.ClassName);
 {$endif}
      exit;
    end;
{$endif}
  CreateOptimizer(AClass);
end;

procedure ModuleUnload(Instance: Cardinal);
var
  Obj: TObjectAccelerator;
  I : integer;
begin
  if (Instance = 0) or (Instance = HInstance) then exit;

  EnterCriticalSection(vAcceleratorCS);
  try
    for I := 0 to vAccelerators.Count - 1 do
    begin
      Obj := vAccelerators[I];
      if FindHInstance(Obj.FClass) = HMODULE(Instance) then
      begin
        Obj.CleanDestroy;
        vAccelerators[I] := nil;
      end;
    end;
  finally
    vAccelerators.Pack;
    LeaveCriticalSection(vAcceleratorCS);
  end;
end;

procedure InitAutoOptimize;
begin
  if vTObjectNewInstanceJumpBackup.Jump = 0 then
    SetJump(AddrTObjectNewInstance, AddrTObjectNewInstanceTrap, vTObjectNewInstanceJumpBackup);
end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
initialization
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
  
  InitializeCriticalSection(vAcceleratorCS);

  Allocator := THeapAllocator.Create(true);

  vAccelerators := TList.Create;

  {$IFNDEF Delphi6_Up}
   VmtOffsetNewInstance := vmtNewInstance;
   VmtOffsetFreeInstance := vmtFreeInstance;
  {$ENDIF Delphi6_Up}
//prepare some constants
  asm
    {$IFDEF Delphi6_Up}
    mov [VmtOffsetNewInstance],  VMTOFFSET TObject.NewInstance
    mov [VmtOffsetFreeInstance], VMTOFFSET TObject.FreeInstance
    {$ENDIF Delphi6_Up}
    lea eax,                     system.@FinalizeArray
    mov [AddrFinalizeArray],     eax
{$ifdef UseFastMM}
    lea  eax,                    fastmm4.FastFreeMem
{$else}
    lea  eax,                    system.@FreeMem
{$endif}
    mov  [AddrFreeMem],          eax
  end;

  AddrFinalizeArray := GetActualAddress(AddrFinalizeArray);
  AddrFreeMem       := GetActualAddress(AddrFreeMem);
  AddrTObjectNewInstance  := GetActualAddress(@TObject.NewInstance);
  AddrTObjectFreeInstance := GetActualAddress(@TObject.FreeInstance);

  NeedRegisterModuleUnload := AddrTObjectNewInstance <> @TObject.NewInstance;

{$ifdef EnableMMX}
{$ifndef ForceMMX}
  UseMMX := IsMMXSupported;
{$endif}
{$endif}
  
  AddrTObjectNewInstanceTrap := @TObjectNewInstanceTrap;

 {$ifdef SafeAutoOptimize}
  AddrTInterfacedObjectNewInstance := GetActualAddress(@TInterfacedObject.NewInstance);
 {$endif}
 {$ifdef SafeNamesAutoOptimize}
  SafeClassList       := TStringList.Create;
  SafeClassList.Sorted := true;
  //SafeClassList.CaseSensitive := false;
  //add all safe classes here:
  //we add them by name, because we don't want to use units
  //this will not work for their descendants
  SafeClassList.Add('TInvokableClass');
  SafeClassList.Add('TRIO');
  SafeClassList.Add('TSoapDataModule');
  SafeClassList.Add('TSOAPDOMProcessor');
  SafeClassList.Add('THTTPReqResp');
  SafeClassList.Add('TXMLDocument');
 {$endif}

  vTObjectNewInstanceJumpBackup.Jump := 0;
{$ifdef AutoOptimize}
  InitAutoOptimize;
{$endif}

  if NeedRegisterModuleUnload then
    AddModuleUnloadProc(ModuleUnload);

finalization
  if vTObjectNewInstanceJumpBackup.Jump <> 0 then
    WriteJumpBuffer(AddrTObjectNewInstance, vTObjectNewInstanceJumpBackup);
 {$ifdef SafeNamesAutoOptimize}
  SafeClassList.Free;
 {$endif}

  if NeedRegisterModuleUnload then
    RemoveModuleUnloadProc(ModuleUnload);

  CleanupList;
  
  DeleteCriticalSection(vAcceleratorCS);

  Allocator.Free;
end.

