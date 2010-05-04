{$ifdef VER180} //Delphi10
  {$define Delphi6_Up}
{$endif}

{$ifdef VER170} //Delphi9
  {$define Delphi6_Up}
{$endif}

{$ifdef VER160} //Delphi8
  {$define Delphi6_Up}
{$endif}

{$ifdef VER150} //Delphi7
  {$define Delphi6_Up}
{$endif}

{$ifdef VER140} //Delphi6, BCB6
  {$define Delphi6_Up}
{$endif}

/////////////////////////////////////////////////

{$RANGECHECKS OFF}
{$BOOLEVAL OFF}
{$OVERFLOWCHECKS OFF}
{$OPTIMIZATION ON}
{$STACKFRAMES OFF}
{$ALIGN ON}

//define this to use direct calls to FastMM; it saves a few calls
{$define UseFastMM}

//define this to directly start the global optimization
//when global optimization is OFF, use OptimizeClass to prepare
//individual classes, or call InitAutoOptimize
{$define AutoOptimize}

//define this to enable auto optimization only for classes
//which do NOT implement their own NewInstance
{$define SafeAutoOptimize}

//define this to enable auto optimization for classes
//which are known to be safe, using a list of names
//it is a little slower because of string lookup,
//and I don't know if it really gives more speed
//requires SafeAutoOptimize
{.$define SafeNamesAutoOptimize}

//define this to enable processing even when instancesize mod 4 <> 0!
//this rounds up all instance allocations
//normally this is no problem, because memory managers already do it
//it is also not necessary when alignment is > 4, so keep it disabled
{.$define ForceRoundInstanceSize}

//define this to directly apply the RTL patches in fastsys
//otherwise one can always call PatchSystemFunctions
{$define AutoPatchRTL}

{.$define UseSysDynArrayClear}

{$define EnableMMX}
  {$define ForceMMX}

{$ifndef EnableMMX}
  {$undef ForceMMX}
{$endif}

//to output some debug lines, to identify optimized and skipped classes
{.$define FastObjDebug}

//just to debug some asm functions
{.$define PurePascal}

