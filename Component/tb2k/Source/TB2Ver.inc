{ $jrsoftware: tb2k/Source/TB2Ver.inc,v 1.7 2006/03/12 23:11:59 jr Exp $ }

{ Determine Delphi/C++Builder version }
{$IFNDEF VER90}  { if it's not Delphi 2.0 }
  {$IFNDEF VER93}  { and it's not C++Builder 1.0 }
    {$DEFINE JR_D3}  { then it must be at least Delphi 3 or C++Builder 3 }
    {$IFNDEF VER100}  { if it's not Delphi 3.0 }
      {$IFNDEF VER120}  { Delphi 4/5's command line compiler doesn't like the ObjExportAll directive, so don't include it on Delphi 4/5 }
        {$IFNDEF VER130}
          {$ObjExportAll On}  { <- needed for compatibility with run-time packages in C++Builder 3+ }
        {$ENDIF}
      {$ENDIF}
      {$IFNDEF VER110}  { and it's not C++Builder 3.0 }
        {$DEFINE JR_D4}  { then it must be at least Delphi 4 or C++Builder 4 }
        {$IFNDEF VER120} {$IFNDEF VER125}  { if it's not Delphi 4 or C++Builder 4 }
          {$DEFINE JR_D5}  { then it must be at least Delphi 5 or C++Builder 5 } 
          {$IFNDEF VER130}  { if it's not Delphi 5 or C++Builder 5 }
            {$DEFINE JR_D6}  { then it must be at least Delphi 6 or C++Builder 6 }
            {$IFNDEF VER140}  { if it's not Delphi 6 or C++Builder 6 }
              {$DEFINE JR_D7}  { then it must be at least Delphi 7 }
              {$IFNDEF VER150}  { if it's not Delphi 7 }
                {$DEFINE JR_D9}  { then it must be at least Delphi 9 (2005) }
              {$ENDIF}
            {$ENDIF}
          {$ENDIF}
        {$ENDIF} {$ENDIF}
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}
{$ENDIF}

{$IFDEF JR_D6}
  {$IF SizeOf(Char) > 1}
    {$DEFINE JR_WIDESTR}  { defined if String type = WideString }
  {$IFEND}
{$ENDIF}

{$ALIGN ON}
{$BOOLEVAL OFF}
{$LONGSTRINGS ON}
{$TYPEDADDRESS OFF}
{$WRITEABLECONST ON}
{$IFDEF JR_D6}
  {$WARN SYMBOL_PLATFORM OFF}
{$ENDIF}
