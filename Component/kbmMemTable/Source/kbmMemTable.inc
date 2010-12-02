{$ifdef VER100}      // Delphi 3
  {$define LEVEL3}
  {$define DELPHI}
{$endif}

{$ifdef VER110}      // C++ Builder 3
  {$define LEVEL3}
  {$define BCB}
{$endif}

{$ifdef VER120}      // Delphi 4
  {$define LEVEL4}
  {$define DELPHI}
{$endif}

{$ifdef VER125}      // C++ Builder 4
  {$define LEVEL4}
  {$define BCB}
{$endif}

{$ifdef VER130}      // Delphi 5 or Builder 5
  {$define LEVEL4}
  {$define LEVEL5}
  {$ifndef BCB}        // Delphi 5
    {$define DELPHI}
  {$else}              // Builder 5
    {$undef DELPHI}	     // ( Ensure Delphi off )
  {$endif}
{$endif}

{$ifdef VER140}      // Delphi/BCB 6 & Kylix 1/2/3.
  {$define LEVEL4}
  {$define LEVEL5}
  {$define LEVEL6}
  {$ifndef BCB}        // Delphi 6
    {$define DELPHI}
  {$else}              // Builder 6
    {$undef DELPHI}	     // ( Ensure Delphi off )
  {$endif}
  {$ifdef LINUX}
    {$ifdef CONDITIONALEXPRESSIONS}  // Figure out which Kylix.
      {$if Declared(CompilerVersion) and (CompilerVersion=14.10)}
        {$define KYLIX2}
	{$ifend}
      {$if Declared(CompilerVersion) and (CompilerVersion=14.50)}
        {$define KYLIX3}
	{$ifend}
    {$ELSE}
      {$define KYLIX1}
    {$endif}
  {$endif}
{$endif}

{$ifdef VER150}      // Delphi 7.
  {$define LEVEL4}
  {$define LEVEL5}
  {$define LEVEL6}
  {$define LEVEL7}
  {$ifndef BCB}        // Delphi 7
    {$define DELPHI}
  {$else}              // Builder 7
    {$undef DELPHI}	     // ( Ensure Delphi off )
  {$endif}
  {$ifdef LINUX}
    Sorry this level of Kylix not yet supported.
  {$endif}
{$endif}

{$ifdef VER170}      // Delphi 9.
  {$define LEVEL4}
  {$define LEVEL5}
  {$define LEVEL6}
  {$define LEVEL7}
  {$define LEVEL9}
  {$ifndef BCB}        // Delphi 9/BDS 2005
    {$define DELPHI}
  {$else}
    {$undef DELPHI}	     // ( Ensure Delphi off )
  {$endif}
  {$ifdef LINUX}
    Sorry this level of Kylix not yet supported.
  {$endif}
{$endif}

{$ifdef VER180}      // Delphi 10/BDS 2006.
  {$define LEVEL4}
  {$define LEVEL5}
  {$define LEVEL6}
  {$define LEVEL7}
  {$define LEVEL9}
  {$define LEVEL10}
  {$ifndef BCB}        // Delphi 10/BDS 2006
    {$define DELPHI}
  {$else}
    {$undef DELPHI}	     // ( Ensure Delphi off )
  {$endif}
  {$ifdef LINUX}
    Sorry this level of Kylix not yet supported.
  {$endif}
{$endif}

{$ifdef CLR}
  {$define DOTNET}
  {$define LEVEL4}
  {$define LEVEL5}
  {$define LEVEL6}
  {$define LEVEL7}
  {$define LEVEL9}
  {$UNSAFECODE ON}
{$ENDIF}

{$ifdef LINUX}
  {$define CLX}
{$endif}

//***********************************************************************

{$ifndef DOTNET}
 {$ifdef LEVEL7}
  {$WARN UNSAFE_CODE OFF}
  {$WARN UNSAFE_TYPE OFF}
  {$WARN UNSAFE_CAST OFF}
 {$endif}
 {$ifdef LEVEL6}
  {$WARN SYMBOL_PLATFORM OFF}
 {$endif}
{$endif}

{$B-}    // Enable short circuit evaluation.

{$ifdef BCB}
{$ObjExportAll On}
{$ASSERTIONS ON}
{$endif}


