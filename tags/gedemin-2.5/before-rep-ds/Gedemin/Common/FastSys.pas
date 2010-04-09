unit FastSys;
(*
Gabriel Corneanu (gabrielcorneanu(AT)gmail.com)

Part of the FastObj project.
It contains mainly patches to some RTL functions.

   JiYuan Xie (gdxjy at hotmail.com)
      - moved all conditional defines to FastObj.inc
      - added Delphi5 support (not tested)
      - added support for being used in package or dll which sharing classes,
        TExecBlockAllocator has been modified to support this
      - (Maybe) Faster System.@New, System.@Dispose, System.@InitializeArray,
        System.@FinalizeArray(System.@DynArrayClear need patched too for this),
        System.@IsClass

   TODO:
      - LOTS of testing :)
      - Measure if the patching really make sense
*)

interface
  
var
  NewAddr,
  DisposeAddr,
  InitializeArrayAddr,
  {$ifndef UseSysDynArrayClear}
  DynArrayClearAddr,
  FinalizeArrayAddr,
  {$endif}
  IsClassAddr : Pointer;

procedure PatchSystemFunctions;

procedure FinalizeSingleElementArray(P: Pointer; TypeInfo: Pointer);
  
{$Include FastObj.inc}

implementation
uses
  {$ifdef UseFastMM}
  fastmm4,
  {$endif}
  patchlib,
  {$ifdef Delphi6_Up}
  Variants,
  {$endif}
  Typinfo,
  Windows;

//from system.pas
type
  TFieldInfo = packed record
    TypeInfo : PTypeInfo;
    Offset_  : Cardinal;
  end;

{$ifdef PurePascal}
procedure LStrArrayClr(var StrArray; Count: longint);
asm
  jmp   System.@LStrArrayClr
end;

procedure WStrArrayClr(var StrArray; Count: Integer);
asm
  jmp   System.@WStrArrayClr
end;
{$endif}

{$ifndef UseSysDynArrayClear}
procedure DynArrayClear(var a: Pointer; TypeInfo: Pointer); forward;
{$endif}
procedure FinalizeRecord(P: Pointer; TypeInfo: Pointer); forward;
procedure FinalizeMultiElementArray(P: Pointer; TypeInfo: Pointer;
  ElemCount: Cardinal); forward;

procedure FinalizeSingleElementArray(P: Pointer; TypeInfo: Pointer);
{$ifdef PurePascal}
var
  FT: PFieldTable;
begin
  case PTypeInfo(TypeInfo).Kind of
  tkLString: String(P^) := '';
  tkWString: WideString(P^) := '';
  tkVariant:
    VarClear(PVariant(P)^);
  tkArray:
    begin
      FT := PFieldTable(Integer(TypeInfo) + Byte(PTypeInfo(TypeInfo).Name[0]));
      with FT^ do
      begin
        if Count > 0 then
        begin
          if Count > 1 then
            FinalizeMultiElementArray(P, Fields[0].TypeInfo^, Count)
          else
            FinalizeSingleElementArray(P, Fields[0].TypeInfo^);
        end;
      end;
    end;
  tkRecord:
    FinalizeRecord(P, TypeInfo);
  tkInterface:
    IInterface(P^) := nil;
  tkDynArray:
    DynArrayClear(PPointer(P)^, TypeInfo);
  else
    System.Error(reInvalidPtr);
  end;
end;
{$else}
asm
  { ->    EAX     pointer to data to be finalized         }
  {       EDX     pointer to type info describing data    }
@@Start:
  movzx ecx, byte ptr [edx]
  sub   ecx, tkLString
  cmp   ecx, (tkDynArray - tkLString)
  ja    @@error
  jmp   dword ptr [@@JumpTable + ecx * 4]

  nop
  nop
@@LString:
  jmp   System.@LStrClr
  ret

  nop
  nop
@@WString:
  jmp   System.@WStrClr
  ret

  nop
  nop
@@Variant:
  jmp   System.@VarClear
  ret

  nop
  nop
@@Array:
  movzx ecx, byte ptr [edx + 1] //ecx = Name[0]
  lea   ecx, [edx + ecx + 2 + 4] //ecx = @PFieldTable(Integer(TypeInfo) + Byte(PTypeInfo(typeinfo)^.Name[0]))^.Count

  mov   edx, [ecx + 4] //edx = FT.Fields[0].TypeInfo
  mov   ecx, [ecx] //ecx = FT.Count
  mov   edx, [edx] //edx = FT.Fields[0].TypeInfo^
  cmp   ecx, 1
  jb    @@ArrayIsEmpty
  je    @@Start
  jmp   FinalizeMultiElementArray //System.@FinalizeArray
@@ArrayIsEmpty:
  ret

  nop
  nop
@@Record:
  jmp    FinalizeRecord
  ret

  nop
  nop
@@Interface:
  jmp    System.@IntfClear
  ret

  nop
  nop
@@DynArray:
  {$ifdef UseSysDynArrayClear}
  jmp    System.@DynArrayClear
  {$else}
  jmp    DynArrayClear
  {$endif}
  ret

  nop
  nop
@@error:
  mov   al, reInvalidPtr
  jmp   System.Error

  nop
@@JumpTable:
  {
  dd    @@error     //tkUnknown
  dd    @@error     //tkInteger
  dd    @@error     //tkChar
  dd    @@error     //tkEnumeration
  dd    @@error     //tkFloat
  dd    @@error     //tkString
  dd    @@error     //tkSet
  dd    @@error     //tkClass
  dd    @@error     //tkMethod
  dd    @@error     //tkWChar
  }
  dd    @@LString   //tkLString   = 10
  dd    @@WString   //tkWString   = 11
  dd    @@Variant   //tkVairnat   = 12
  dd    @@Array     //tkArray     = 13
  dd    @@Record    //tkRecord    = 14
  dd    @@Interface //tkInterface = 15
  dd    @@error     //tkInt64
  dd    @@DynArray  //tkDynArray  = 17
end;
{$endif}

procedure FinalizeMultiElementArray(P: Pointer; TypeInfo: Pointer; ElemCount: Cardinal);
{$ifdef PurePascal}
var
  FT: PFieldTable;
  TI: Pointer;
begin
  case PTypeInfo(TypeInfo).Kind of
  tkLString: LStrArrayClr(P^, ElemCount);
  tkWString: WStrArrayClr(P^, ElemCount);
  tkVariant:
    begin
      repeat
        VarClear(PVariant(P)^);
        Inc(Integer(P), SizeOf(Variant));
        Dec(ElemCount);
      until elemcount = 0;
    end;
  tkArray:
    begin
      FT := PFieldTable(Integer(TypeInfo) + Byte(PTypeInfo(TypeInfo).Name[0]));
      with FT^ do
      begin
        if Count > 0 then
        begin
          TI := Fields[0].TypeInfo^;
          if Count > 1 then
          begin
            repeat
              FinalizeMultiElementArray(P, TI, Count);
              Inc(Integer(P), Size);
              Dec(ElemCount);
            until elemcount = 0;
          end
          else begin
            repeat
              FinalizeSingleElementArray(P, TI);
              Inc(Integer(P), Size);
              Dec(ElemCount);
            until elemcount = 0;
          end;
        end;
      end;
    end;
  tkRecord:
    begin
      FT := PFieldTable(Integer(TypeInfo) + Byte(PTypeInfo(TypeInfo).Name[0]));
      repeat
        FinalizeRecord(P, TypeInfo);
        Inc(Integer(P), FT.Size);
        Dec(ElemCount);
      until elemcount = 0;
    end;
  tkInterface:
    repeat
      IInterface(P^) := nil;
      Inc(Integer(P), 4);
      Dec(ElemCount);
    until elemcount = 0;
  tkDynArray:
    repeat
      DynArrayClear(PPointer(P)^, TypeInfo);
      Inc(Integer(P), 4);
      Dec(ElemCount);
    until elemcount = 0;
  else
    System.Error(reInvalidPtr);
  end;
end;
{$else}
asm
  { ->    EAX     pointer to data to be finalized         }
  {       EDX     pointer to type info describing data    }
  {       ECX     number of elements of that type         }

  push  edi
  mov   edi, ecx

  movzx ecx, [edx]
  sub   ecx, tkLString
  cmp   ecx, (tkDynArray - tkLString)
  ja    @@error
  jmp   dword ptr [@@JumpTable + ecx * 4]
  nop
  nop
  nop
@@LStringArray:
  mov   edx, edi
  pop   edi
  jmp   System.@LStrArrayClr
  ret

  nop
  nop
@@WStringArray:
  mov   edx, edi
  pop   edi
  jmp   System.@WStrArrayClr
  ret
@@VariantArray:
  push  ebx
  mov   ebx, eax
@@VariantLoop:
  mov   eax, ebx
  add   ebx, 16
  call  System.@VarClear
  dec   edi
  jg    @@VariantLoop
  pop   ebx
  pop   edi
  ret

  nop
@@ArrayArray:
  push  ebx
  push  esi
  mov   ebx, eax
  movzx ecx, [edx + 1]
  lea   esi, [edx + ecx + 2]
  mov   ecx, [esi + 4] //ecx = Count
  cmp   ecx, 1

  jb    @@ArrayIsEmpty

  push  ebp
  mov   ebp, [esi + 8]
  mov   ebp, [ebp]  //ebp = TypeInfo^

  je    @@ArraySingleElementLoop

@@ArrayMultiElementLoop:
  mov   edx, ebp
  call  FinalizeMultiElementArray
  add   ebx, [esi]
  mov   eax, ebx
  mov   ecx, [esi + 4]
  dec   edi
  jg    @@ArrayMultiElementLoop

  pop   ebp
@@ArrayIsEmpty:
  pop   esi
  pop   ebx
  pop   edi
  ret
  nop
@@ArraySingleElementLoop:
  mov   edx, ebp
  call  FinalizeSingleElementArray
  add   ebx, [esi]
  mov   eax, ebx
  dec   edi
  jg    @@ArraySingleElementLoop
  pop   ebp
  pop   esi
  pop   ebx
  pop   edi
  ret

@@RecordArray:
  push  ebp
  push  ebx
  push  esi
  mov   ebx, eax
  mov   esi, edx
  movzx ecx, [edx + 1]
  mov   ebp, [edx + ecx + 2] //ebp = Size
@@RecordLoop:
  mov   eax, ebx
  add   ebx, ebp
  mov   edx, esi
  call  FinalizeRecord
  dec   edi
  jg    @@RecordLoop
  pop   esi
  pop   ebx
  pop   ebp
  pop   edi
  ret

  nop
  nop
@@InterfaceArray:
  push  ebx
  mov   ebx, eax
@@InterfaceLoop:
  mov   eax, ebx
  add   ebx, 4
  call  System.@IntfClear
  dec   edi
  jg    @@InterfaceLoop
  pop   ebx
  pop   edi
  ret

  nop
@@DynArrayArray:
  push  ebx
  push  esi
  mov   ebx, eax
  mov   esi, edx
@@DynArrayLoop:
  mov   eax, ebx
  mov   edx, esi
  add   ebx, 4
  {$ifdef UseSysDynArrayClear}
  call  System.@DynArrayClear
  {$else}
  call  DynArrayClear
  {$endif}
  dec   edi
  jg    @@DynArrayLoop
  pop   esi
  pop   ebx
  pop   edi
  ret

  nop
  nop
  nop
@@error:
  pop   edi
  mov   al, reInvalidPtr
  jmp   System.Error

@@JumpTable:
  {
  dd    @@error     //tkUnknown
  dd    @@error     //tkInteger
  dd    @@error     //tkChar
  dd    @@error     //tkEnumeration
  dd    @@error     //tkFloat
  dd    @@error     //tkString
  dd    @@error     //tkSet
  dd    @@error     //tkClass
  dd    @@error     //tkMethod
  dd    @@error     //tkWChar
  }
  dd    @@LStringArray   //tkLString   = 10
  dd    @@WStringArray   //tkWString   = 11
  dd    @@VariantArray   //tkVairnat   = 12
  dd    @@ArrayArray     //tkArray     = 13
  dd    @@RecordArray    //tkRecord    = 14
  dd    @@InterfaceArray //tkInterface = 15
  dd    @@error     //tkInt64
  dd    @@DynArrayArray  //tkDynArray  = 17
end;
{$endif}

procedure FinalizeRecord(P: Pointer; TypeInfo: Pointer);
{$ifdef PurePascal}
var
  FT: PFieldTable;
  I: Cardinal;
  FI: PFieldInfo;
begin
  FT := PFieldTable(Integer(TypeInfo) + Byte(PTypeInfo(TypeInfo).Name[0]));
  with FT^ do
  begin
    FI := @Fields[0];
    I := Count;
  end;

  repeat
    with FI^ do
    begin
      FinalizeSingleElementArray(Pointer(Cardinal(P) + Offset_), TypeInfo^);
    end;
    Inc(FI);
    Dec(I);
  until I = 0;
end;
{$else}
asm
  { ->    EAX pointer to record to be finalized   }
  {       EDX pointer to type info                }

  push  ebx
  push  esi
  push  edi

  movzx ecx, byte ptr [edx + 1]
  mov   ebx, eax
  lea   esi, [edx + ecx + 2 + 8]
  mov   edi, [esi - 4]
@@Loop:
  mov   edx, [esi]
  mov   eax, [esi + 4]
  add   eax, ebx
  mov   edx, [edx]
  call  FinalizeSingleElementArray
  add   esi, TYPE TFieldInfo
  dec   edi
  jg    @@Loop

  pop   edi
  pop   esi
  pop   ebx
end;
{$endif}

{$ifndef UseSysDynArrayClear}
procedure DynArrayClear(var a: Pointer; TypeInfo: Pointer);
asm
  {     ->EAX     Pointer to dynamic array (Pointer to pointer to heap object }
  {       EDX     Pointer to type info                                        }
  {       Nothing to do if Pointer to heap object is nil                      }
  mov   ecx, [eax]
  test  ecx, ecx
  je    @@exit

  //Set the variable to be finalized to nil
  mov   dword ptr [eax], 0

  //Decrement ref count. Nothing to do if not zero now.
  lock  dec dword ptr [ecx - 8]
  jne   @@exit

  //Save the source - we're supposed to return it
  push  eax
  mov   eax, ecx

  //Fetch the type descriptor of the elements
  xor   ecx, ecx
  mov   cl, [edx].TDynArrayTypeInfo.name;
  mov   edx, [edx + ecx].TDynArrayTypeInfo.elType;

  //If it's non-nil, finalize the elements
  test  edx, edx
  je    @@noFinalize
  mov   ecx, [eax - 4]
  cmp   ecx, 1
  jb    @@noFinalize
  mov   edx, [edx]
  je    @@SingleElementArray
  push  eax
  call  FinalizeMultiElementArray 
  pop   eax
@@noFinalize:
  //Now deallocate the array
  sub   eax, 8
  {$ifdef UseFastMM}
  call  FastFreeMem
  {$else}
  call  system.@FreeMem
  {$endif}
  pop   eax
@@exit:
  ret
  nop
@@SingleElementArray:
  push  eax
  call  FinalizeSingleElementArray
  pop   eax
  //Now deallocate the array
  sub   eax, 8
  {$ifdef UseFastMM}
  call  FastFreeMem
  {$else}
  call  system.@FreeMem
  {$endif}
  pop   eax
end;
{$endif}

procedure FasterFinalizeArray(P: Pointer; TypeInfo: Pointer;
  ElemCount: Cardinal);
asm
  cmp ecx, 1
  jb  @@exit
  je  FinalizeSingleElementArray
  jmp FinalizeMultiElementArray
@@exit:
end;

function FasterIsClass(Child: TObject; Parent: TClass): Boolean;
// -> EAX:  Child
//    EDX:  Parent
//Result := (Child <> nil) and Child.InheritsFrom(Parent);
asm

  test  eax, eax
  je    @@Exit
  //mov   eax, [eax]
  //call  TObject.InheritsFrom
  //inline
@@loop:
  mov   eax, [eax]
@@haveVMT:
  cmp   eax, edx
  je    @@success
  mov   eax, [eax].vmtParent
  test  eax, eax
  jne   @@loop
  ret
@@success:
  mov   al, 1
@@Exit:
end;

var
  vNewJumpBackup, vDisposeJumpBackup,
  {$ifndef UseSysDynArrayClear}
  vDynArrayClearJumpBackup,
  vFinalizeArrayJumpBackup,
  {$endif}
  vInitializeArrayJumpBackup,
  vIsClassJumpBackup: TPatchSimpleJump;

procedure InitializeRecord(P: Pointer; TypeInfo: Pointer); forward;
procedure InitializeMultiElementArray(P: Pointer; TypeInfo: Pointer;
  ElemCount: Cardinal); forward;

procedure InitializeSingleElementArray(P: Pointer; TypeInfo: Pointer);
{$ifdef PurePascal}
var
  FT: PFieldTable;
begin
  case PTypeInfo(TypeInfo).Kind of
  tkLString, tkWString, tkInterface, tkDynArray:
    PInteger(P)^ := 0;
  tkVariant:
    begin
      PInteger(P)^ := 0;
      PInteger(Integer(P) + 4)^ := 0;
      PInteger(Integer(P) + 8)^ := 0;
      PInteger(Integer(P) + 12)^ := 0;
    end;
  tkArray:
    begin
      FT := PFieldTable(Integer(TypeInfo) + Byte(PTypeInfo(TypeInfo).Name[0]));
      with FT^ do
      begin
        if Count > 0 then
        begin
          if Count > 1 then
            InitializeMultiElementArray(P, FT.Fields[0].TypeInfo^, FT.Count)
          else
            InitializeSingleElementArray(P, FT.Fields[0].TypeInfo^);
        end;
      end;
    end;
  tkRecord:
    begin
      InitializeRecord(P, TypeInfo);
    end;
  else
    System.Error(reInvalidPtr);
  end;
end;
{$else}
asm
        { ->    EAX     pointer to data to be initialized       }
        {       EDX     pointer to type info describing data    }
@@Start:
  movzx ecx, byte ptr [edx]
  sub   ecx, tkLString
  cmp   ecx, (tkDynArray - tkLString)
  ja    @@error
  jmp   dword ptr [@@JumpTable + ecx * 4]
  nop
  nop

@@LString:
@@WString:
@@Interface:
@@DynArray:
  xor   ecx, ecx
  mov   [eax], ecx
  ret

  nop
  nop
  nop
@@Variant:
  xor   ecx, ecx
  mov   [eax], ecx
  mov   [eax + 4], ecx
  mov   [eax + 8], ecx
  mov   [eax + 12], ecx
  ret

  nop
  nop
@@Array:
  movzx ecx, byte ptr [edx + 1] //ecx = Name[0]
  lea   ecx, [edx + ecx + 2 + 4] //ecx = @PFieldTable(Integer(TypeInfo) + Byte(PTypeInfo(typeinfo)^.Name[0]))^.Count

  mov   edx, [ecx + 4] //edx = FT.Fields[0].TypeInfo
  mov   ecx, [ecx] //ecx = FT.Count
  mov   edx, [edx] //edx = FT.Fields[0].TypeInfo^
  cmp   ecx, 1
  jb    @@ArrayIsEmpty
  je    @@Start
  jmp   InitializeMultiElementArray //System.@FinalizeArray
@@ArrayIsEmpty:
  ret

@@Record:
  jmp   InitializeRecord
  ret

  nop
  nop
@@error:
  mov   al, reInvalidPtr
  jmp   System.Error

  nop
@@JumpTable:
  {
  dd    @@error     //tkUnknown
  dd    @@error     //tkInteger
  dd    @@error     //tkChar
  dd    @@error     //tkEnumeration
  dd    @@error     //tkFloat
  dd    @@error     //tkString
  dd    @@error     //tkSet
  dd    @@error     //tkClass
  dd    @@error     //tkMethod
  dd    @@error     //tkWChar
  }
  dd    @@LString   //tkLString   = 10
  dd    @@WString   //tkWString   = 11
  dd    @@Variant   //tkVairnat   = 12
  dd    @@Array     //tkArray     = 13
  dd    @@Record    //tkRecord    = 14
  dd    @@Interface //tkInterface = 15
  dd    @@error     //tkInt64
  dd    @@DynArray  //tkDynArray  = 17
end;
{$endif}

procedure InitializeMultiElementArray(P: Pointer; TypeInfo: Pointer; ElemCount: Cardinal);
{$ifdef PurePascal}
var
  FT: PFieldTable;
  TI: Pointer;
begin
  case PTypeInfo(TypeInfo).Kind of
  tkLString, tkWString, tkInterface, tkDynArray:
    repeat
      PInteger(P)^ := 0;
      Inc(Integer(P), 4);
      Dec(ElemCount);
    until ElemCount = 0;
  tkVariant:
    repeat
      PInteger(P)^ := 0;
      PInteger(Integer(P) + 4)^ := 0;
      PInteger(Integer(P) + 8)^ := 0;
      PInteger(Integer(P) + 12)^ := 0;
      Inc(Integer(P), Sizeof(Variant));
      Dec(ElemCount);
    until ElemCount = 0;
  tkArray:
    begin
      FT := PFieldTable(Integer(TypeInfo) + Byte(PTypeInfo(TypeInfo).Name[0]));
      with FT^ do
      begin
        if Count > 0 then
        begin
          TI := Fields[0].TypeInfo^;
          if Count > 1 then
          begin
            repeat
              InitializeMultiElementArray(P, TI, Count);
              Inc(Integer(P), Size);
              Dec(ElemCount);
            until ElemCount = 0;
          end
          else begin
            repeat
              InitializeSingleElementArray(P, TI);
              Inc(Integer(P), Size);
              Dec(ElemCount);
            until ElemCount = 0;
          end;
        end;
      end;
    end;
  tkRecord:
    begin
      FT := PFieldTable(Integer(TypeInfo) + Byte(PTypeInfo(TypeInfo).Name[0]));
      repeat
        InitializeRecord(P, TypeInfo);
        Inc(Integer(P), FT.Size);
        Dec(ElemCount);
      until ElemCount = 0;
    end;
  else
    System.Error(reInvalidPtr);
  end;
end;
{$else}
asm
  { ->    EAX     pointer to data to be initialized       }
  {       EDX     pointer to type info describing data    }
  {       ECX     number of elements of that type         }

  push  edi
  mov   edi, ecx

  movzx ecx, [edx]
  sub   ecx, tkLString
  cmp   ecx, (tkDynArray - tkLString)
  ja    @@error
  jmp   dword ptr [@@JumpTable + ecx * 4]

  nop
  nop
  nop
@@LStringArray:
@@WStringArray:
@@InterfaceArray:
@@DynArrayArray:
  xor   ecx, ecx
@@InitPtrLoop:
  mov   [eax], ecx
  add   eax, 4
  dec   edi
  jg    @@InitPtrLoop
  pop   edi
  ret

@@VariantArray:
  xor   ecx, ecx
@@InitVariantLoop:
  mov   [eax], ecx
  mov   [eax + 4], ecx
  mov   [eax + 8], ecx
  mov   [eax + 12], ecx
  add   eax, 16
  dec   edi
  jg    @@InitVariantLoop
  pop   edi
  ret

  nop
  nop
  nop
@@ArrayArray:
  push  ebx
  push  esi
  mov   ebx, eax
  movzx ecx, [edx + 1]
  lea   esi, [edx + ecx + 2]
  mov   ecx, [esi + 4] //ecx = Count
  cmp   ecx, 1

  jb    @@ArrayIsEmpty

  push  ebp
  mov   ebp, [esi + 8]
  mov   ebp, [ebp]  //ebp = TypeInfo^

  je    @@ArraySingleElementLoop

@@ArrayMultiElementLoop:
  mov   edx, ebp
  call  InitializeMultiElementArray
  add   ebx, [esi]
  mov   eax, ebx
  mov   ecx, [esi + 4]
  dec   edi
  jg    @@ArrayMultiElementLoop

  pop   ebp
@@ArrayIsEmpty:
  pop   esi
  pop   ebx
  pop   edi
  ret
  nop
@@ArraySingleElementLoop:
  mov   edx, ebp
  call  InitializeSingleElementArray
  add   ebx, [esi]
  mov   eax, ebx
  dec   edi
  jg    @@ArraySingleElementLoop
  pop   ebp
  pop   esi
  pop   ebx
  pop   edi
  ret

  nop
@@RecordArray:
  push  ebp
  push  ebx
  push  esi
  mov   ebx, eax
  mov   esi, edx
  movzx ecx, [edx + 1]
  mov   ebp, [edx + ecx + 2] //ebp = Size
@@RecordLoop:
  mov   eax, ebx
  add   ebx, ebp
  mov   edx, esi
  call  InitializeRecord
  dec   edi
  jg    @@RecordLoop
  pop   esi
  pop   ebx
  pop   ebp
  pop   edi
  ret
  
  nop
  nop
@@error:
  pop   edi
  mov   al, reInvalidPtr
  jmp   System.Error

@@JumpTable:
  {
  dd    @@error     //tkUnknown
  dd    @@error     //tkInteger
  dd    @@error     //tkChar
  dd    @@error     //tkEnumeration
  dd    @@error     //tkFloat
  dd    @@error     //tkString
  dd    @@error     //tkSet
  dd    @@error     //tkClass
  dd    @@error     //tkMethod
  dd    @@error     //tkWChar
  }
  dd    @@LStringArray   //tkLString   = 10
  dd    @@WStringArray   //tkWString   = 11
  dd    @@VariantArray   //tkVairnat   = 12
  dd    @@ArrayArray     //tkArray     = 13
  dd    @@RecordArray    //tkRecord    = 14
  dd    @@InterfaceArray //tkInterface = 15
  dd    @@error     //tkInt64
  dd    @@DynArrayArray  //tkDynArray  = 17
end;
{$endif}

procedure InitializeRecord(P: Pointer; TypeInfo: Pointer);
{$ifdef PurePascal}
var
  FT: PFieldTable;
  I: Cardinal;
  FI: PFieldInfo;
begin
  FT := PFieldTable(Integer(TypeInfo) + Byte(PTypeInfo(TypeInfo).Name[0]));
  with FT^ do
  begin
    FI := @Fields[0];
    I := Count;
  end;

  repeat
    with FI^ do
    begin
      InitializeSingleElementArray(Pointer(Cardinal(P) + Offset_), TypeInfo^);
    end;
    Inc(FI);
    Dec(I);
  until I = 0;
end;
{$else}
asm
  { ->    EAX pointer to record to be initialized }
  {       EDX pointer to type info                }

  push  ebx
  push  esi
  push  edi

  movzx ecx, byte ptr [edx + 1]
  mov   ebx, eax
  lea   esi, [edx + ecx + 2 + 8]
  mov   edi, [esi - 4]
@@loop:

  mov   edx, [esi]
  mov   eax, [esi + 4]
  add   eax, ebx
  mov   edx, [edx]
  call  InitializeSingleElementArray
  add   esi, 8
  dec   edi
  jg    @@loop

  pop   edi
  pop   esi
  pop   ebx
end;
{$endif}

procedure FasterInitializeArray(P: Pointer; TypeInfo: Pointer; ElemCount: Cardinal);
asm
  cmp ecx, 1
  jb  @@exit
  je  @@SingleElement
  jmp InitializeMultiElementArray
@@SingleElement:
  jmp InitializeSingleElementArray
@@exit:
end;

function FasterNew(Size: Longint; TypeInfo: Pointer): Pointer;
asm
  { ->    EAX size of object to allocate  }
  {       EDX pointer to TypeInfo         }

  push  edx
  {$ifdef UseFastMM}
  call  FastGetMem
  {$else}
  call  system.@GetMem
  {$endif}
  pop   edx
  test  eax, eax
  je    @@exit
  push  eax
  call  InitializeSingleElementarray //_Initialize
  pop   eax
@@exit:
end;

procedure FasterDispose(P: Pointer; TypeInfo: Pointer);
{$ifdef PurePascal}
begin
  FinalizeSingleElementArray(P, TypeInfo);
  {$ifdef UseFastMM}
  FastFreeMem(P);
  {$else}
  FreeMem(P);
  {$endif}
end;
{$else}
asm
  { ->    EAX     Pointer to object to be disposed        }
  {       EDX     Pointer to type info            }

  push  eax
  call  FinalizeSingleElementArray
  pop   eax
  {$ifdef UseFastMM}
  jmp   FastFreeMem //call  FastFreeMem
  {$else}
  jmp   System.@FreeMem //call  System.@FreeMem
  {$endif}
end;
{$endif}

var
  IsPatchApplied : boolean = false;

procedure PatchSystemFunctions;
begin
  if IsPatchApplied then exit;
  IsPatchApplied := true;
  SetJump(GetActualAddress(NewAddr), @FasterNew, vNewJumpBackup);
  SetJump(GetActualAddress(DisposeAddr), @FasterDispose, vDisposeJumpBackup);
  SetJump(GetActualAddress(InitializeArrayAddr), @FasterInitializeArray, vInitializeArrayJumpBackup);
  SetJump(GetActualAddress(DynArrayClearAddr), @DynArrayClear, vDynArrayClearJumpBackup);
  SetJump(GetActualAddress(FinalizeArrayAddr), @FasterFinalizeArray, vFinalizeArrayJumpBackup);
  SetJump(GetActualAddress(IsClassAddr), @FasterIsClass, vIsClassJumpBackup);
end;

initialization
//new constants
   asm
    lea  eax, system.@new
    mov  [NewAddr], eax
    lea  eax, system.@dispose
    mov  [DisposeAddr], eax
    lea  eax, system.@InitializeArray
    mov  [InitializeArrayAddr], eax
    lea  eax, system.@DynArrayClear
    mov  [DynArrayClearAddr], eax
    lea  eax, system.@FinalizeArray
    mov  [FinalizeArrayAddr], eax
    lea  eax, system.@IsClass
    mov  [IsClassAddr], eax
  end;

{$ifdef AutoPatchRTL}
   PatchSystemFunctions;
{$endif}
end.
