{$B-}
unit SynRegExpr;

// SynEdit note: The name had to be changed to get SynEdit to install 
//   together with mwEdit into the same Delphi installation

{
 *  Copyright (c) 1986 by University of Toronto.
 *  Written by Henry Spencer.  Not derived from licensed software.
 *
 *  Permission is granted to anyone to use this software for any
 *  purpose on any computer system, and to redistribute it freely,
 *  subject to the following restrictions:
 *  1. The author is not responsible for the consequences of use of
 *      this software, no matter how awful, even if they arise
 *      from defects in it.
 *  2. The origin of this software must not be misrepresented, either
 *      by explicit claim or by omission.
 *  3. Altered versions must be plainly marked as such, and must not
 *      be misrepresented as being the original software.


 Converted to Delphi
 by Andrey Sorokin, Saint-Petersburg, Russia
 anso@mail.ru, anso@usa.net

 v. 0.7 1999.08.22
 -=- fixed bug - in some cases the r.e. [^...]
     incorrectly processed (as any symbol)
     (thanks to Jan Korycan)
 -=- Some changes and improvements in TestRExp.dpr

 v. 0.6 1999.08.13 (Friday 13 !)
 -=- changed header of TRegExpr.Substitute
 -=- added Split, Replace & appropriate
     global wrappers (thanks to Stephan Klimek for suggetions)

 v. 0.5 1999.08.12
 -=- TRegExpr.Substitute routine added
 -=- Some changes and improvements in TestRExp.dpr
 -=- Fixed bug in english version of documentation
     (Thanks to Jon Buckheit)

 v. 0.4 1999.07.20
 -=- Fixed bug with parsing of strings longer then 255 bytes
     (thanks to Guido Muehlwitz)
 -=- Fixed bug in RegMatch - mathes only first occurence of r.e.
     (thanks to Stephan Klimek)

 v. 0.3 1999.06.13
 -=- ExecRegExpr function

 v. 0.2 1999.06.10
 -=- packed into object-pascal class
 -=- code slightly rewriten for pascal
 -=- now macro correct proceeded in ranges
 -=- r.e.ranges syntax extended for russian letters ranges:
     à-ÿ - replaced with all small russian letters (Win1251)
     À-ß - replaced with all capital russian letters (Win1251)
     à-ß - replaced with all russian letters (Win1251)
 -=- added macro 'ö' and '\d' (opcode ANYDIGIT) - match any digit
 -=- added macro 'Ö' and '\D' (opcode NOTDIGIT) - match not digit
 -=- added macro '\w' (opcode ANYLETTER) - match any english letter or '_'
 -=- added macro '\W' (opcode NOTLETTER) - match not english letter or '_'
 (all r.e.syntax extensions may be turned off by flag ExtSyntax)

 v. 0.1 1999.06.09
 first version, with bugs, without help => must die :(
}

{$DEFINE DebugRegExpr} // define for dump/trace enabling

interface

uses
 Classes; // TStrings in Split method

const
 NSUBEXP = 10; // max number of substitutions

type
 TRegExpr = class
   private
    startp : array [0 .. NSUBEXP - 1] of PChar; // founded expr starting points
    endp : array [0 .. NSUBEXP - 1] of PChar; // founded expr end points

    // The "internal use only" fields to pass info from compile
    // to execute that permits the execute phase to run lots faster on
    // simple cases.
    regstart : char; // char that must begin a match; '\0' if none obvious
    reganch : char; // is the match anchored (at beginning-of-line only)?
    regmust : PChar; // string (pointer into program) that match must include, or nil
    regmlen : integer; // length of regmust string
    // Regstart and reganch permit very fast decisions on suitable starting points
    // for a match, cutting down the work a lot.  Regmust permits fast rejection
    // of lines that cannot possibly match.  The regmust tests are costly enough
    // that regcomp() supplies a regmust only if the r.e. contains something
    // potentially expensive (at present, the only such thing detected is * or +
    // at the start of the r.e., which can involve a lot of backup).  Regmlen is
    // supplied because the test in regexec() needs it and regcomp() is computing
    // it anyway.

    // work variables for Exec's routins - save stack in recursion}
    reginput : PChar; // String-input pointer.
    regbol : PChar; // Beginning of input, for ^ check.

    // work variables for compiler's routines
    regparse : PChar;  // Input-scan pointer.
    regnpar : integer; // count.
    regdummy : char;
    regcode : PChar;   // Code-emit pointer; @regdummy = don't.
    regsize : integer; // Code size.

    // programm is essentially a linear encoding
    // of a nondeterministic finite-state machine (aka syntax charts or
    // "railroad normal form" in parsing technology).  Each node is an opcode
    // plus a "next" pointer, possibly plus an operand.  "Next" pointers of
    // all nodes except BRANCH implement concatenation; a "next" pointer with
    // a BRANCH on both ends of it is connecting two alternatives.  (Here we
    // have one of the subtle syntax dependencies:  an individual BRANCH (as
    // opposed to a collection of them) is never concatenated with anything
    // because of operator precedence.)  The operand of some types of node is
    // a literal string; for others, it is a node leading into a sub-FSM.  In
    // particular, the operand of a BRANCH node is the first node of the branch.
    // (NB this is *not* a tree structure:  the tail of the branch connects
    // to the thing following the set of BRANCHes.)  The opcodes are:
    programm : PChar; // Unwarranted chumminess with compiler.

    fExpression : PChar; // source of compiled r.e.
    fInputString : PChar; // input string

    fExtSyntax : boolean; // use r.e.syntax extended for russian

    function GetExpression : string;
    procedure SetExpression (const s : string);
    procedure SetExtSyntax (b : boolean);

    procedure Error (s : PChar); virtual; // raise exception

    {==================== Compiler section ===================}
    function CompileRegExpr (exp : PChar) : boolean;
    // compile a regular expression into internal code

    procedure Tail (p : PChar; val : PChar);
    // set the next-pointer at the end of a node chain

    procedure OpTail (p : PChar; val : PChar);
    // regoptail - regtail on operand of first argument; nop if operandless

    function EmitNode (op : char) : PChar;
    // regnode - emit a node, return location

    procedure EmitC (b : char);
    // emit (if appropriate) a byte of code

    procedure InsertOperator (op : char; opnd : PChar);
    // insert an operator in front of already-emitted operand
    // Means relocating the operand.

    function ParseReg (paren : integer; var flagp : integer) : PChar;
    // regular expression, i.e. main body or parenthesized thing

    function ParseBranch (var flagp : integer) : PChar;
    // one alternative of an | operator

    function ParsePiece (var flagp : integer) : PChar;
    // something followed by possible [*+?]

    function ParseAtom (var flagp : integer) : PChar;
    // the lowest level

    {===================== Mathing section ===================}
    function regrepeat (p : PChar) : integer;
    // repeatedly match something simple, report how many

    function regnext (p : PChar) : PChar;
    // dig the "next" pointer out of a node

    function MatchPrim (prog : PChar) : boolean;
    // recursively matching routine

    function RegMatch (str : PChar) : boolean;
    // try match at specific point, uses MatchPrim for real work

    {$IFDEF DebugRegExpr}
    function DumpOp (op : char) : string;
    {$ENDIF}

    function GetMatchCount : integer;
    function GetMatchPos (Idx : integer) : integer;
    function GetMatchLen (Idx : integer) : integer;
   public
    constructor Create;
    destructor Destroy; override;

    property Expression : string read GetExpression write SetExpression;
    // regular expression

    property ExtSyntaxEnabled : boolean read fExtSyntax write SetExtSyntax;
    // use r.e.syntax extended for russian, true by default

    function Exec (const InputString : string) : boolean;
    // match a programm against a string InputString

    function Substitute (const ATemplate : string) : string;
    // Returns ATemplate with '&' replaced by r.e. 1st occurence
    // and '/n' replaced by 1st occurence by r.e. subexpression n.

    procedure Split (AInputStr : string; APieces : TStrings);
    // Split ASearchText into APieces by r.e. occurencies

    function Replace (AInputStr : string; const AReplaceStr : string) : string;
    // Returns AInputStr with r.e. occurencies replaced by AReplaceStr

    property MatchCount : integer read GetMatchCount;
    // number of entrance r.e. into tested in Exec string

    property MatchPos [Idx : integer] : integer read GetMatchPos;
    // pos of entrance # Idx r.e. into tested in Exec string
    // first entrance have index 0, last - (MatchCount - 1)

    property MatchLen [Idx : integer] : integer read GetMatchLen;
    // len of entrance # Idx r.e. into tested in Exec string
    // first entrance have index 0, last - (MatchCount - 1)

    {$IFDEF DebugRegExpr}
    function Dump : string;
    // dump a compiled regexp in vaguely comprehensible form
    {$ENDIF}
  end;

function ExecRegExpr (const ARegExpr, AInputStr : string) : boolean;
// true if string AInputString match regular expression ARegExpr
// ! will raise exeption if syntax errors in ARegExpr

procedure SplitRegExpr (const ARegExpr, AInputStr : string; APieces : TStrings);
// Split ASearchText into APieces by r.e. ARegExpr occurencies

function ReplaceRegExpr (const ARegExpr, AInputStr, AReplaceStr : string) : string;
// Returns AInputStr with r.e. occurencies replaced by AReplaceStr


implementation

uses
 SysUtils;


{=============================================================}
{===================== Global functions ======================}
{=============================================================}

function ExecRegExpr (const ARegExpr, AInputStr : string) : boolean;
 var r : TRegExpr;
 begin
  r := TRegExpr.Create;
  try
    r.Expression := ARegExpr;
    Result := r.Exec (AInputStr);
    finally r.Free;
   end;
 end; { of function ExecRegExpr
--------------------------------------------------------------}

procedure SplitRegExpr (const ARegExpr, AInputStr : string; APieces : TStrings);
 var r : TRegExpr;
 begin
  APieces.Clear;
  r := TRegExpr.Create;
  try
    r.Expression := ARegExpr;
    r.Split (AInputStr, APieces);
    finally r.Free;
   end;
 end; { of procedure SplitRegExpr
--------------------------------------------------------------}

function ReplaceRegExpr (const ARegExpr, AInputStr, AReplaceStr : string) : string;
 var r : TRegExpr;
 begin
  r := TRegExpr.Create;
  try
    r.Expression := ARegExpr;
    Result := r.Replace (AInputStr, AReplaceStr);
    finally r.Free;
   end;
 end; { of function ReplaceRegExpr
--------------------------------------------------------------}


const
 MAGIC = #156; // programm signature ($9C)

// name   opcode   opnd? meaning
 EEND    = #0;   // no   End of program
 BOL     = #1;   // no   Match "" at beginning of line
 EOL     = #2;   // no   Match "" at end of line
 ANY     = #3;   // no   Match any one character
 ANYOF   = #4;   // str  Match any character in this string
 ANYBUT  = #5;   // str  Match any char. not in this string
 BRANCH  = #6;   // node Match this alternative, or the next
 BACK    = #7;   // no   Match "", "next" ptr points backward
 EXACTLY = #8;   // str  Match this string
 NOTHING = #9;   // no   Match empty string
 STAR    = #10;  // node Match this (simple) thing 0 or more times
 PLUS    = #11;  // node Match this (simple) thing 1 or more times
 ANYDIGIT= #12;  // no   Match any digit (equiv [0-9])
 NOTDIGIT= #13;  // no   Match not digit (equiv [0-9])
 ANYLETTER=#14;  // no   Match any english letter (equiv [a-zA-Z_])
 NOTLETTER=#15;  // no   Match not english letter (equiv [a-zA-Z_])
 OPEN    = #20;  // no   Mark this point in input as start of #n
                 //      OPEN+1 is number 1, etc.
 CLOSE   = #30;  // no   Analogous to OPEN.

// A node is one char of opcode followed by two chars of "next" pointer.
// "Next" pointers are stored as two 8-bit pieces, high order first.  The
// value is a positive offset from the opcode of the node containing it.
// An operand, if any, simply follows the node.  (Note that much of the
// code generation knows about this implicit relationship.)
// Using two bytes for the "next" pointer is vast overkill for most things,
// but allows patterns to get big without disasters.

// Opcodes description:
//
// BRANCH   The set of branches constituting a single choice are hooked
//      together with their "next" pointers, since precedence prevents
//      anything being concatenated to any individual branch.  The
//      "next" pointer of the last BRANCH in a choice points to the
//      thing following the whole choice.  This is also where the
//      final "next" pointer of each individual branch points; each
//      branch starts with the operand node of a BRANCH node.
// BACK     Normal "next" pointers all implicitly point forward; BACK
//      exists to make loop structures possible.
// STAR,PLUS    '?', and complex '*' and '+', are implemented as circular
//      BRANCH structures using BACK.  Simple cases (one character
//      per match) are implemented with STAR and PLUS for speed
//      and to minimize recursive plunges.
// OPEN,CLOSE   ...are numbered at compile time.


{=============================================================}
{===================== Common section ========================}
{=============================================================}

constructor TRegExpr.Create;
 begin
  inherited;
  programm := nil;
  fExpression := nil;
  fInputString := nil;
  fExtSyntax := true;
 end; { of constructor TRegExpr.Create
--------------------------------------------------------------}

destructor TRegExpr.Destroy;
 begin
  if programm <> nil
   then FreeMem (programm);
  if fExpression <> nil
   then FreeMem (fExpression);
  if fInputString <> nil
   then FreeMem (fInputString);
 end; { of destructor TRegExpr.Destroy
--------------------------------------------------------------}

function TRegExpr.GetExpression : string;
 begin
  if fExpression <> nil
   then Result := fExpression
   else Result := '';
 end; { of function TRegExpr.GetExpression
--------------------------------------------------------------}

procedure TRegExpr.SetExpression (const s : string);
 begin
  if s <> fExpression then begin
    if fExpression <> nil then begin
      FreeMem (fExpression);
      fExpression := nil;
     end;
    if s <> '' then begin
      GetMem (fExpression, length (s) + 1);
      CompileRegExpr (StrPCopy (fExpression, s));
     end;
   end;
 end; { of procedure TRegExpr.SetExpression
--------------------------------------------------------------}

function TRegExpr.GetMatchCount : integer;
 begin
  Result := 0;
  if Assigned (fInputString) then
    while (Result < NSUBEXP) and Assigned (startp [Result])
          and Assigned (endp [Result])
     do inc (Result);
 end; { of function TRegExpr.GetMatchCount
--------------------------------------------------------------}

function TRegExpr.GetMatchPos (Idx : integer) : integer;
 begin
  if (Idx >= 0) and (Idx < NSUBEXP) and Assigned (fInputString)
     and Assigned (startp [Idx]) and Assigned (endp [Idx]) then begin
     Result := (startp [Idx] - fInputString) + 1;
    end
   else Result := -1;
 end; { of function TRegExpr.GetMatchPos
--------------------------------------------------------------}

function TRegExpr.GetMatchLen (Idx : integer) : integer;
 begin
  if (Idx >= 0) and (Idx < NSUBEXP) and Assigned (fInputString)
     and Assigned (startp [Idx]) and Assigned (endp [Idx]) then begin
     Result := endp [Idx] - startp [Idx];
    end
   else Result := -1;
 end; { of function TRegExpr.GetMatchLen
--------------------------------------------------------------}

procedure TRegExpr.SetExtSyntax (b : boolean);
 begin
  if fExtSyntax <> b then begin
    fExtSyntax := b;
    if (programm <> nil) and (fExpression <> nil)
     then CompileRegExpr (fExpression);
   end;
 end; { of procedure TRegExpr.SetExtSyntax
--------------------------------------------------------------}

procedure TRegExpr.Error (s : PChar);
 begin
  raise Exception.Create (s);
 end; { of procedure TRegExpr.Error
--------------------------------------------------------------}

function NEXT (p : PChar) : word;
 begin
  Result := (ord ((p + 1)^) ShL 8) + ord ((p + 2)^);
 end; { of function NEXT
--------------------------------------------------------------}

{=============================================================}
{==================== Compiler section =======================}
{=============================================================}

procedure TRegExpr.Tail (p : PChar; val : PChar);
// set the next-pointer at the end of a node chain
 var
  scan : PChar;
  temp : PChar;
  offset : integer;
 begin
  if p = @regdummy
   then EXIT;
  // Find last node.
  scan := p;
  REPEAT
   temp := regnext (scan);
   if temp = nil
    then BREAK;
   scan := temp;
  UNTIL false;

  if scan^ = BACK
   then offset := scan - val
   else offset := val - scan;
  (scan + 1)^ := Char ((offset ShR 8) and $FF);
  (scan + 2)^ := Char (offset and $FF);
 end; { of procedure TRegExpr.Tail
--------------------------------------------------------------}

procedure TRegExpr.OpTail (p : PChar; val : PChar);
// regtail on operand of first argument; nop if operandless
 begin
  // "Operandless" and "op != BRANCH" are synonymous in practice.
  if (p = nil) or (p = @regdummy) or (p^ <> BRANCH)
   then EXIT;
  Tail (p + 3, val);
 end; { of procedure TRegExpr.OpTail
--------------------------------------------------------------}

function TRegExpr.EmitNode (op : char) : PChar;
// emit a node, return location
 begin
  Result := regcode;
  if Result <> @regdummy then begin
     regcode^ := op;
     inc (regcode);
     regcode^ := #0; // "next" pointer := nil
     inc (regcode);
     regcode^ := #0;
     inc (regcode);
    end
   else inc (regsize, 3); // compute code size without code generation
 end; { of function TRegExpr.EmitNode
--------------------------------------------------------------}

procedure TRegExpr.EmitC (b : char);
// emit (if appropriate) a byte of code
 begin
  if regcode <> @regdummy then begin
     regcode^ := b;
     inc (regcode);
    end
   else inc (regsize);
 end; { of procedure TRegExpr.EmitC
--------------------------------------------------------------}

procedure TRegExpr.InsertOperator (op : char; opnd : PChar);
// insert an operator in front of already-emitted operand
// Means relocating the operand.
 var src, dst, place : PChar;
 begin
  if regcode = @regdummy then begin
    inc (regsize, 3);
    EXIT;
   end;
  src := regcode;
  inc (regcode, 3);
  dst := regcode;
  while src > opnd do begin
    dec (dst);
    dec (src);
    dst^ := src^;
   end;
  place := opnd; // Op node, where operand used to be.
  place^ := op;
  inc (place);
  place^ := #0;
  inc (place);
  place^ := #0;
 end; { of procedure TRegExpr.InsertOperator
--------------------------------------------------------------}

function strcspn (s1 : PChar; s2 : PChar) : integer;
// find length of initial segment of s1 consisting
// entirely of characters not from s2
 var scan1, scan2 : PChar;
 begin
  Result := 0;
  scan1 := s1;
  while scan1^ <> #0 do begin
    scan2 := s2;
    while scan2^ <> #0 do
     if scan1^ = scan2^
      then EXIT
      else inc (scan2);
    inc (Result);
    inc (scan1)
   end;
 end; { of function strcspn
--------------------------------------------------------------}

const
// Flags to be passed up and down.
 HASWIDTH =   01; // Known never to match nil string.
 SIMPLE   =   02; // Simple enough to be STAR/PLUS operand.
 SPSTART  =   04; // Starts with * or +.
 WORST    =   0;  // Worst case.
 META : array [0 .. 13] of char = (
  '^', '$', '.', '[', '(', ')', '|', '?', '+', '*', '\', 'ö', 'Ö', #0);

function TRegExpr.CompileRegExpr (exp : PChar) : boolean;
// compile a regular expression into internal code
// We can't allocate space until we know how big the compiled form will be,
// but we can't compile it (and thus know how big it is) until we've got a
// place to put the code.  So we cheat:  we compile it twice, once with code
// generation turned off and size counting turned on, and once "for real".
// This also means that we don't allocate space until we are sure that the
// thing really will compile successfully, and we never have to move the
// code and thus invalidate pointers into it.  (Note that it has to be in
// one piece because free() must be able to free it all.)
// Beware that the optimization-preparation code in here knows about some
// of the structure of the compiled regexp.
 var
  scan, longest : PChar;
  len : cardinal;
  flags : integer;
 begin
  Result := false; // life too dark

  if programm <> nil then begin
    FreeMem (programm);
    programm := nil;
   end;

  if exp = nil
   then raise Exception.Create ('NULL argument');

  // First pass: determine size, legality.
  regparse := exp;
  regnpar := 1;
  regsize := 0;
  regcode := @regdummy;
  EmitC (MAGIC);
  if ParseReg (0, flags) = nil
   then EXIT;

  // Small enough for 2-bytes programm pointers ?
  if regsize >= 64 * 1024
   then raise Exception.Create ('regexp too big');

  // Allocate space.
  GetMem (programm, regsize);

  // Second pass: emit code.
  regparse := exp;
  regnpar := 1;
  regcode := programm;
  EmitC (MAGIC);
  if ParseReg (0, flags) = nil
   then EXIT;

  // Dig out information for optimizations.
  regstart := #0; // Worst-case defaults.
  reganch := #0;
  regmust := nil;
  regmlen := 0;
  scan := programm + 1; // First BRANCH.
  if regnext (scan)^ = EEND then begin // Only one top-level choice.
    scan := scan + 3;

    // Starting-point info.
    if scan^ = EXACTLY
     then regstart := (scan + 3)^
     else if scan^ = BOL
           then inc (reganch);

    // If there's something expensive in the r.e., find the longest
    // literal string that must appear and make it the regmust.  Resolve
    // ties in favor of later strings, since the regstart check works
    // with the beginning of the r.e. and avoiding duplication
    // strengthens checking.  Not a strong reason, but sufficient in the
    // absence of others.
    if (flags and SPSTART) <> 0 then begin
        longest := nil;
        len := 0;
        while scan <> nil do begin
          if (scan^ = EXACTLY)
             and (strlen (scan + 3) >= len) then begin
              longest := scan + 3;
              len := strlen (scan + 3);
           end;
          scan := regnext (scan);
         end;
        regmust := longest;
        regmlen := len;
     end;
   end;
  Result := true;
 end; { of function TRegExpr.CompileRegExpr
--------------------------------------------------------------}

function TRegExpr.ParseReg (paren : integer; var flagp : integer) : PChar;
// regular expression, i.e. main body or parenthesized thing
// Caller must absorb opening parenthesis.
// Combining parenthesis handling with the base level of regular expression
// is a trifle forced, but the need to tie the tails of the branches to what
// follows makes it hard to avoid.
 var
  ret, br, ender : PChar;
  parno : integer;
  flags : integer;
 begin
  flagp := HASWIDTH; // Tentatively.
  parno := 0; // eliminate compiler stupid warning

  // Make an OPEN node, if parenthesized.
  if paren <> 0 then begin
      if regnpar >= NSUBEXP
       then raise Exception.Create ('too many ()');
      parno := regnpar;
      inc (regnpar);
      ret := EmitNode (char (ord (OPEN) + parno));
    end
   else ret := nil;

  // Pick up the branches, linking them together.
  br := ParseBranch (flags);
  if br = nil then begin
    Result := nil;
    EXIT;
   end;
  if ret <> nil
   then Tail (ret, br) // OPEN -> first.
   else ret := br;
  if (flags and HASWIDTH) = 0
   then flagp := flagp and not HASWIDTH;
  flagp := flagp or flags and SPSTART;
  while (regparse^ = '|') do begin
    inc (regparse);
    br := ParseBranch (flags);
    if br = nil then begin
       Result := nil;
       EXIT;
      end;
    Tail (ret, br); // BRANCH -> BRANCH.
    if (flags and HASWIDTH) = 0
     then flagp := flagp and not HASWIDTH;
    flagp := flagp or flags and SPSTART;
   end;

  // Make a closing node, and hook it on the end.
  if paren <> 0
   then ender := EmitNode (char (ord (CLOSE) + parno))
   else ender := EmitNode (EEND);
  Tail (ret, ender);

  // Hook the tails of the branches to the closing node.
  br := ret;
  while br <> nil do begin
    OpTail (br, ender);
    br := regnext (br);
   end;

  // Check for proper termination.
  if paren <> 0
   then if regparse^ <> ')'
         then raise Exception.Create ('unmatched ()')
         else inc (regparse);
  if (paren = 0) and (regparse^ <> #0) then begin
      if regparse^ = ')'
       then raise Exception.Create('unmatched ()')
       else raise Exception.Create('junk on end');
       // "Can't happen".
       // NOTREACHED
    end;
  Result := ret;
 end; { of function TRegExpr.ParseReg
--------------------------------------------------------------}

function TRegExpr.ParseBranch (var flagp : integer) : PChar;
// one alternative of an | operator
// Implements the concatenation operator.
 var
  ret, chain, latest : PChar;
  flags : integer;
 begin
  flagp := WORST; // Tentatively.

  ret := EmitNode (BRANCH);
  chain := nil;
  while (regparse^ <> #0) and (regparse^ <> '|')
        and (regparse^ <> ')') do begin
    latest := ParsePiece (flags);
    if latest = nil then begin
      Result := nil;
      EXIT;
     end;
    flagp := flagp or flags and HASWIDTH;
    if chain = nil // First piece.
     then flagp := flagp or flags and SPSTART
     else Tail (chain, latest);
    chain := latest;
   end;
  if chain = nil // Loop ran zero times.
   then EmitNode (NOTHING);
  Result := ret;
 end; { of function TRegExpr.ParseBranch
--------------------------------------------------------------}

function TRegExpr.ParsePiece (var flagp : integer) : PChar;
// something followed by possible [*+?]
// Note that the branching code sequences used for ? and the general cases
// of * and + are somewhat optimized:  they use the same NOTHING node as
// both the endmarker for their branch list and the body of the last branch.
// It might seem that this node could be dispensed with entirely, but the
// endmarker role is not redundant.
 var
  op : char;
  NextNode : PChar;
  flags : integer;
 begin
  Result := ParseAtom (flags);
  if Result = nil
   then EXIT;

  op := regparse^;
  if not ((op = '*') or (op = '+') or (op = '?')) then begin
    flagp := flags;
    EXIT;
   end;
  if ((flags and HASWIDTH) = 0) and (op <> '?')
   then raise Exception.Create ('*+ operand could be empty');
  if op = '+'
   then flagp := WORST or HASWIDTH
   else flagp := WORST or SPSTART;

  if (op = '*') and ((flags and SIMPLE) <> 0)
    then InsertOperator (STAR, Result)
   else if op = '*' then begin
     // Emit x* as (x&|), where & means "self".
     InsertOperator (BRANCH, Result); // Either x
     OpTail (Result, EmitNode (BACK)); // and loop
     OpTail (Result, Result); // back
     Tail (Result, EmitNode (BRANCH)); // or
     Tail (Result, EmitNode (NOTHING)); // nil.
    end
   else if (op = '+') and ((flags and SIMPLE) <> 0)
    then InsertOperator (PLUS, Result)
   else if op = '+' then begin
     // Emit x+ as x(&|), where & means "self".
     NextNode := EmitNode (BRANCH); // Either
     Tail (Result, NextNode);
     Tail (EmitNode (BACK), Result);    // loop back
     Tail (NextNode, EmitNode (BRANCH)); // or
     Tail (Result, EmitNode (NOTHING)); // nil.
    end
   else if op = '?' then begin
     // Emit x? as (x|)
     InsertOperator (BRANCH, Result); // Either x
     Tail (Result, EmitNode (BRANCH));  // or
     NextNode := EmitNode (NOTHING); // nil.
     Tail (Result, NextNode);
     OpTail (Result, NextNode);
    end;

  inc (regparse);
  if (regparse^ = '*') or (regparse^ = '+') or (regparse^ = '?')
   then raise Exception.Create ('nested *?+');
 end; { of function TRegExpr.ParsePiece
--------------------------------------------------------------}

function TRegExpr.ParseAtom (var flagp : integer) : PChar;
// the lowest level
// Optimization:  gobbles an entire sequence of ordinary characters so that
// it can turn them into a single node, which is smaller to store and
// faster to run.  Backslashed characters are exceptions, each becoming a
// separate node; the code is simpler that way and it's not worth fixing.
 var
  ret : PChar;
  flags : integer;
  RangeBeg, RangeEnd : char;
  len : integer;
  ender : char;
  n : integer;
 procedure EmitExactly (ch : char);
  begin
   ret := EmitNode (EXACTLY);
   EmitC (ch);
   EmitC (#0);
   flagp := flagp or HASWIDTH or SIMPLE;
  end;
 procedure EmitStr (const s : string);
  var i : integer;
  begin
   for i := 1 to length (s)
    do EmitC (s [i]);
  end;
 function HexDig (ch : char) : integer;
  begin
   if (ch >= 'a') and (ch <= 'f')
    then ch := char (ord (ch) - (ord ('a') - ord ('A')));
   if (ch < '0') or (ch > 'F') or ((ch > '9') and (ch < 'A'))
    then raise Exception.Create ('Bad hex digit "' + ch + '"');
   Result := ord (ch) - ord ('0');
   if ch >= 'A'
    then Result := Result - (ord ('A') - ord ('9') - 1);
  end;
 begin
  flagp := WORST; // Tentatively.

  inc (regparse);
  case (regparse - 1)^ of
    '^': ret := EmitNode (BOL);
    '$': ret := EmitNode (EOL);
    '.': begin
       ret := EmitNode (ANY);
       flagp := flagp or HASWIDTH or SIMPLE;
      end;
    'ö': if fExtSyntax then begin // r.e.extension - any digit ('0' .. '9')
         ret := EmitNode (ANYDIGIT);
         flagp := flagp or HASWIDTH or SIMPLE;
        end
       else EmitExactly ('ö');
    'Ö': if fExtSyntax then begin // r.e.extension - any digit ('0' .. '9')
         ret := EmitNode (NOTDIGIT);
         flagp := flagp or HASWIDTH or SIMPLE;
        end
       else EmitExactly ('Ö');
    '[': begin
            if regparse^ = '^' then begin // Complement of range.
               ret := EmitNode (ANYBUT);
               inc (regparse);
              end
             else ret := EmitNode (ANYOF);
            if (regparse^ = ']') or (regparse^ = '-') then begin
              EmitC (regparse^);
              inc (regparse);
             end;
            while (regparse^ <> #0) and (regparse^ <> ']') do begin
                if regparse^ = '-' then begin
                   inc (regparse);
                   if (regparse^ = ']') or (regparse^ = #0)
                    then EmitC ('-')
                    else begin
                      RangeBeg := (regparse - 2)^;
                      RangeEnd := regparse^;

                      // r.e.ranges extension for russian
                      if fExtSyntax and (RangeBeg = 'à') and (RangeEnd = 'ÿ') then begin
                        EmitStr ('àáâãäå¸æçèéêëìíîïðñòóôõö÷øùúûüýþÿ');
                       end
                      else if fExtSyntax and (RangeBeg = 'À') and (RangeEnd = 'ß') then begin
                        EmitStr ('ÀÁÂÃÄÅ¨ÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞß');
                       end
                      else if fExtSyntax and (RangeBeg = 'à') and (RangeEnd = 'ß') then begin
                        EmitStr ('àáâãäå¸æçèéêëìíîïðñòóôõö÷øùúûüýþÿ');
                        EmitStr ('ÀÁÂÃÄÅ¨ÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞß');
                       end
                      else begin // standard r.e. handling
                        if RangeBeg > RangeEnd
                         then raise Exception.Create ('Invalid [] range');
                        inc (RangeBeg);
                        while RangeBeg <= RangeEnd do begin
                          EmitC (RangeBeg);
                          inc (RangeBeg);
                         end;
                       end;
                      inc (regparse);
                     end;
                  end
                 else begin
                   if regparse^ = '\' then begin
                      inc (regparse);
                      if regparse^ = #0
                       then raise Exception.Create ('Trailing \');
                      case regparse^ of // r.e.extensions
                        'd': EmitStr ('0123456789');
                        'w': EmitStr ('abcdefghijklmnopqrstuvwxyz'
                              + 'ABCDEFGHIJKLMNOPQRSTUVWXYZ_');
                        't': EmitC (#9);
                        'n': EmitC (#$a);
                        'r': EmitC (#$d);
                        'e': EmitC (#$1b);
                        'x': begin
                              inc (regparse);
                              if regparse^ = #0
                               then raise Exception.Create ('No hex code after \x');
                              n := HexDig (regparse^);
                              inc (regparse);
                              if regparse^ = #0
                               then raise Exception.Create ('No hex code after \x');
                              n := (n ShL 4) or HexDig (regparse^);
                              EmitC (char (n)); // r.e.extension
                          end;
                        else EmitC (regparse^);
                       end; { of case}
                     end
                    else if regparse^ = 'ö'
                          then EmitStr ('0123456789')
                    else begin
                      EmitC (regparse^);
                     end;
                   inc (regparse);
                  end;
             end; { of while}
            EmitC (#0);
            if regparse^ <> ']'
             then raise Exception.Create ('Unmatched []');
            inc (regparse);
            flagp := flagp or HASWIDTH or SIMPLE;
      end;
    '(': begin
        ret := ParseReg (1, flags);
        if ret = nil then begin
          Result := nil;
          EXIT;
         end;
        flagp := flagp or flags and (HASWIDTH or SPSTART);
      end;
    #0, '|', ')': // Supposed to be caught earlier.
     raise Exception.Create ('Internal urp');
    '?', '+', '*':
     raise Exception.Create ('?+* follows nothing');
    '\': begin
        if regparse^ = #0
         then raise Exception.Create ('Trailing \');
        case regparse^ of // r.e.extensions
          'd': begin // r.e.extension - any digit ('0' .. '9')
             ret := EmitNode (ANYDIGIT);
             flagp := flagp or HASWIDTH or SIMPLE;
            end;
          'w': begin // r.e.extension - any english char or '_'
             ret := EmitNode (ANYLETTER);
             flagp := flagp or HASWIDTH or SIMPLE;
            end;
          'D': begin // r.e.extension - not digit ('0' .. '9')
             ret := EmitNode (NOTDIGIT);
             flagp := flagp or HASWIDTH or SIMPLE;
            end;
          'W': begin // r.e.extension - not english char or '_'
             ret := EmitNode (NOTLETTER);
             flagp := flagp or HASWIDTH or SIMPLE;
            end;
          't': EmitExactly (#9); // r.e.extension
          'n': EmitExactly (#$a); // r.e.extension
          'r': EmitExactly (#$d); // r.e.extension
          'e': EmitExactly (#$1b); // r.e.extension
          'x': begin
             inc (regparse);
             if regparse^ = #0
              then raise Exception.Create ('No hex code after \x');
             n := HexDig (regparse^);
             inc (regparse);
             if regparse^ = #0
              then raise Exception.Create ('No hex code after \x');
             n := (n ShL 4) or HexDig (regparse^);
             EmitExactly (char (n)); // r.e.extension
            end;
          else begin
            ret := EmitNode (EXACTLY);
            EmitC (regparse^);
            EmitC (#0);
            flagp := flagp or HASWIDTH or SIMPLE;
           end;
         end; { of case}
        inc (regparse);
      end;
    else begin
        dec (regparse);
        len := strcspn (regparse, META);
        if len <= 0
         then raise Exception.Create ('Internal disaster');
        ender := (regparse + len)^;
        if (len > 1)
           and ((ender = '*') or (ender = '+') or (ender = '?'))
         then dec (len); // Back off clear of ?+* operand.
        flagp := flagp or HASWIDTH;
        if len = 1
         then flagp := flagp or SIMPLE;
        ret := EmitNode (EXACTLY);
        while len > 0 do begin
          EmitC (regparse^);
          inc (regparse);
          dec (len);
         end;
        EmitC (#0);
      end; { of case else}
   end; { of case}

  Result := ret;
 end; { of function TRegExpr.ParseAtom
--------------------------------------------------------------}



{=============================================================}
{===================== Matching section ======================}
{=============================================================}

function TRegExpr.regrepeat (p : PChar) : integer;
// repeatedly match something simple, report how many
 var
  scan : PChar;
  opnd : PChar;
  buf : array [0 .. 1] of char;
 begin
  Result := 0;
  scan := reginput;
  opnd := p + 3; //OPERAND
  case p^ of
    ANY: begin
      Result := strlen (scan);
      inc (scan, Result);
     end;
    EXACTLY:
      while opnd^ = scan^ do begin
        inc (Result);
        inc (scan);
       end;
    ANYLETTER:
      while (scan^ >= 'a') and (scan^ <= 'z')
       or (scan^ >= 'A') and (scan^ <= 'Z') or (scan^ = '_') do begin
        inc (Result);
        inc (scan);
       end;
    NOTLETTER:
      while (scan^ <> #0) and
       not ((scan^ >= 'a') and (scan^ <= 'z')
           or (scan^ >= 'A') and (scan^ <= 'Z')
           or (scan^ = '_')) do begin
        inc (Result);
        inc (scan);
       end;
    ANYDIGIT:
      while (scan^ >= '0') and (scan^ <= '9') do begin
        inc (Result);
        inc (scan);
       end;
    NOTDIGIT:
      while (scan^ <> #0) and ((scan^ < '0') or (scan^ > '9')) do begin
        inc (Result);
        inc (scan);
       end;
    ANYOF:
      while (scan^ <> #0) and (StrPos (opnd, StrPCopy (buf, scan^)) <> nil) do begin
        inc (Result);
        inc (scan);
       end;
    ANYBUT:
      while (scan^ <> #0) and (StrPos (opnd, StrPCopy (buf, scan^)) = nil) do begin
        inc (Result);
        inc (scan);
       end;
    else begin // Oh dear.  Called inappropriately.
      Error ('Internal foulup');
      Result := 0; // Best compromise.
     end;
   end; { of case}
  reginput := scan;
 end; { of function TRegExpr.regrepeat
--------------------------------------------------------------}

function TRegExpr.regnext (p : PChar) : PChar;
// dig the "next" pointer out of a node
 var offset : integer;
 begin
  Result := nil;
  if p = @regdummy
   then EXIT;

  offset := NEXT (p);
  if offset = 0
   then EXIT;

  if p^ = BACK
   then Result := p - offset
   else Result := p + offset;
 end; { of function TRegExpr.regnext
--------------------------------------------------------------}

function TRegExpr.MatchPrim (prog : PChar) : boolean;
// recursively matching routine
// Conceptually the strategy is simple:  check to see whether the current
// node matches, call self recursively to see whether the rest matches,
// and then act accordingly.  In practice we make some effort to avoid
// recursion, in particular by going through "ordinary" nodes (that don't
// need to know whether the rest of the match failed) by a loop instead of
// by recursion.
 var
  scan : PChar; // Current node.
  next : PChar; // Next node.
  len : integer;
  opnd : PChar;
  no : integer;
  save : PChar;
  nextch : char;
  min : integer;
 begin
  Result := false;
  scan := prog;

  while scan <> nil do begin
     next := regnext (scan);
     case scan^ of
         BOL: if reginput <> regbol
               then EXIT;
         EOL: if reginput^ <> #0
               then EXIT;
         ANY: begin
            if reginput^ = #0
             then EXIT;
            inc (reginput);
           end;
         ANYLETTER: begin
            if (reginput^ = #0) or
             not ((reginput^ >= 'a') and (reginput^ <= 'z')
                 or (reginput^ >= 'A') and (reginput^ <= 'Z')
                 or (reginput^ = '_'))
             then EXIT;
            inc (reginput);
           end;
         NOTLETTER: begin
            if (reginput^ = #0) or
               (reginput^ >= 'a') and (reginput^ <= 'z')
                 or (reginput^ >= 'A') and (reginput^ <= 'Z')
                 or (reginput^ = '_')
             then EXIT;
            inc (reginput);
           end;
         ANYDIGIT: begin
            if (reginput^ = #0) or (reginput^ < '0') or (reginput^ > '9')
             then EXIT;
            inc (reginput);
           end;
         NOTDIGIT: begin
            if (reginput^ = #0) or ((reginput^ >= '0') and (reginput^ <= '9'))
             then EXIT;
            inc (reginput);
           end;
         EXACTLY: begin
            opnd := scan + 3; // OPERAND
            // Inline the first character, for speed.
            if opnd^ <> reginput^
             then EXIT;
            len := strlen (opnd);
            if (len > 1) and (StrLComp (opnd, reginput, len) <> 0)
             then EXIT;
            inc (reginput, len);
           end;
         ANYOF: begin
            if (reginput^ = #0) or (StrScan (scan + 3, reginput^) = nil)
             then EXIT;
            inc (reginput);
           end;
         ANYBUT: begin
            if (reginput^ = #0) or (StrScan (scan + 3, reginput^) <> nil)
             then EXIT; //###0.7 was skipped (found by Jan Korycan)
            inc (reginput);
           end;
         NOTHING: ;
         BACK: ;
         Succ (OPEN) .. Char (Ord (OPEN) + 9) : begin
            no := ord (scan^) - ord (OPEN);
            save := reginput;
            Result := MatchPrim (next);
            if Result and (startp [no] = nil)
             then startp [no] := save;
             // Don't set startp if some later invocation of the same
             // parentheses already has.
            EXIT;
           end;
         Succ (CLOSE) .. Char (Ord (CLOSE) + 9): begin
            no := ord (scan^) - ord (CLOSE);
            save := reginput;
            Result := MatchPrim (next);
            if Result and (endp [no] = nil)
             then endp [no] := save;
             // Don't set endp if some later invocation of the same
             // parentheses already has.
            EXIT;
           end;
         BRANCH: begin
            if (next^ <> BRANCH) // No choice.
             then next := scan + 3 // Avoid recursion.
             else begin
               REPEAT
                save := reginput;
                Result := MatchPrim (scan + 3);
                if Result
                 then EXIT;
                reginput := save;
                scan := regnext(scan);
               UNTIL (scan = nil) or (scan^ <> BRANCH);
               EXIT;
              end;
           end;
         STAR, PLUS: begin
                // Lookahead to avoid useless match attempts when we know
                // what character comes next.
                nextch := #0;
                if next^ = EXACTLY
                 then nextch := (next + 3)^;
                if scan^ = STAR
                 then min := 0  // STAR
                 else min := 1; // PLUS
                save := reginput;
                no := regrepeat (scan + 3);
                while no >= min do begin
                  // If it could work, try it.
                  if (nextch = #0) or (reginput^ = nextch) then
                    if MatchPrim (next) then begin
                      Result := true;
                      EXIT;
                     end;
                  // Couldn't or didn't -- back up.
                  dec (no);
                  reginput := save + no;
                 end; { of while}
                EXIT;
           end;
         EEND: begin
            Result := true;  // Success!
            EXIT;
           end;
        else begin
            Error ('MatchPrim: Memory corruption');
            EXIT;
          end;
        end; { of case scan^}
        scan := next;
    end; { of while scan <> nil}

  // We get here only if there's trouble -- normally "case END" is the
  // terminating point.
  Error ('MatchPrim: Corrupted pointers');
 end; { of function TRegExpr.MatchPrim
--------------------------------------------------------------}

function TRegExpr.RegMatch (str : PChar) : boolean;
// try match at specific point
 var i : integer;
 begin
  for i := 0 to NSUBEXP - 1 do begin
    startp [i] := nil;
    endp [i] := nil;
   end;
  reginput := str;
  Result := MatchPrim (programm + 1);
  if Result then begin
    startp [0] := str;
    endp [0] := reginput;
//    startp [1] := nil //###0.4 bugfix by Stephan Klimek
   end;
 end; { of function TRegExpr.RegMatch
--------------------------------------------------------------}

function TRegExpr.Exec (const InputString : string) : boolean;
// match a regexp prog against a string str
 var s : PChar;
 begin
  Result := false; // Be paranoid...
  if Assigned (fInputString) then begin
    FreeMem (fInputString);
    fInputString := nil;
   end;
  if programm = nil then begin
    Error ('Not assigned expression property');
    EXIT;
  end;
  // Check validity of program.
  if programm [0] <> MAGIC then begin
    Error ('Exec: Corrupted program');
    EXIT;
   end;

  GetMem (fInputString, length (InputString) + 1);

  //###0.4 bugfix by Guido Muehlwitz: StrPCopy works only with short strings
  StrLCopy (fInputString, PChar (InputString), Length (InputSTring));
  //StrPCopy (fInputString, InputString);

  // If there is a "must appear" string, look for it.
  if regmust <> nil then begin
    s := fInputString;
    REPEAT
     s := StrScan (s, regmust [0]);
     if s <> nil then begin
       if StrLComp (s, regmust, regmlen) = 0
        then BREAK; // Found it.
       inc (s);
      end;
    UNTIL s = nil;
    if s = nil // Not present.
     then EXIT;
   end;
  // Mark beginning of line for ^ .
  regbol := fInputString;

  // Simplest case:  anchored match need be tried only once.
  if reganch <> #0 then begin
    Result := RegMatch (fInputString);
    EXIT;
   end;

  // Messy cases:  unanchored match.
  s := fInputString;
  if regstart <> #0 then // We know what char it must start with.
    REPEAT
     s := StrScan (s, regstart);
     if s <> nil then begin
       Result := RegMatch (s);
       if Result
        then EXIT;
       inc (s);
      end;
    UNTIL s = nil
   else // We don't - general case.
    REPEAT
     Result := RegMatch (s);
     if Result
      then EXIT;
     inc (s);
    UNTIL s^ = #0;
  // Failure
 end; { of function TRegExpr.Exec
--------------------------------------------------------------}

function TRegExpr.Substitute (const ATemplate : string) : string;
// perform substitutions after a regexp match
 var
  src : PChar;
  c : char;
  no : integer;
  len : integer;
 begin
  Result := '';

  if programm = nil then begin
    Error ('Not assigned expression property');
    EXIT;
  end;
  // Check validity of program.
  if programm [0] <> MAGIC then begin
    Error ('Substitute: Corrupted programm');
    EXIT;
   end;

  src := PChar (ATemplate);
  while src^ <> #0 do begin
    c := src^;
    inc (src);
    if c = '&'
     then no := 0
     else if (c = '\') and ('0' <= src^) and (src^ <= '9')
	   then begin
              no := ord (src^) - ord ('0');
              inc (src);
             end
	   else no := -1;

    if no < 0 then begin // Ordinary character.
       if (c = '\') and ((src^ = '\') or (src^ = '&')) then begin
         c := src^;
         inc (src);
        end;
       Result := Result + c;
      end
     else if no < MatchCount then begin
       len := MatchLen [no];
       Result := Result + System.Copy (fInputString, MatchPos [no], len);
      end;
   end;
 end; { of function TRegExpr.Substitute
--------------------------------------------------------------}

procedure TRegExpr.Split (AInputStr : string; APieces : TStrings);
 begin
  while Exec (AInputStr) do begin
    APieces.Add (System.Copy (AInputStr, 1, MatchPos [0] - 1));
    AInputStr := System.Copy (AInputStr,
     MatchPos [0] + MatchLen [0], MaxInt);
   end;
  APieces.Add (AInputStr); // Tail
 end; { of procedure TRegExpr.Split
--------------------------------------------------------------}

function TRegExpr.Replace (AInputStr : string; const AReplaceStr : string) : string;
 begin
  Result := '';
  while Exec (AInputStr) do begin
    Result := Result + System.Copy (AInputStr, 1, MatchPos [0] - 1)
     + AReplaceStr;
    AInputStr := System.Copy (AInputStr, MatchPos [0] + MatchLen [0], MaxInt);
   end;
  Result := Result + AInputStr; // Tail
 end; { of function TRegExpr.Replace
--------------------------------------------------------------}


{$IFDEF DebugRegExpr}
function TRegExpr.DumpOp (op : char) : string;
// printable representation of opcode
 begin
  case op of
    BOL:     Result := 'BOL';
    EOL:     Result := 'EOL';
    ANY:     Result := 'ANY';
    ANYLETTER:Result := 'ANYLETTER';
    NOTLETTER:Result := 'NOTLETTER';
    ANYDIGIT:Result := 'ANYDIGIT';
    NOTDIGIT:Result := 'NOTDIGIT';
    ANYOF:   Result := 'ANYOF';
    ANYBUT:  Result := 'ANYBUT';
    BRANCH:  Result := 'BRANCH';
    EXACTLY: Result := 'EXACTLY';
    NOTHING: Result := 'NOTHING';
    BACK:    Result := 'BACK';
    EEND:    Result := 'END';
    Succ (OPEN) .. Char (Ord (OPEN) + 9):
      Result := Format ('OPEN%d', [ord (op) - ord (OPEN)]);
    Succ (CLOSE) .. Char (Ord (CLOSE) + 9):
      Result := Format ('CLOSE%d', [ord (op) - ord (CLOSE)]);
    STAR:    Result := 'STAR';
    PLUS:    Result := 'PLUS';
    else Error ('corrupted opcode');
   end; {of case op}
  Result := ':' + Result;
 end; { of function TRegExpr.DumpOp
--------------------------------------------------------------}

function TRegExpr.Dump : string;
// dump a regexp in vaguely comprehensible form
 var
  s : PChar;
  op : char; // Arbitrary non-END op.
  next : PChar;
 begin
  op := EXACTLY;
  Result := '';
  s := programm + 1;
  while op <> EEND do begin // While that wasn't END last time...
     op := s^;
     Result := Result + Format ('%2d%s', [s - programm, DumpOp (s^)]); // Where, what.
     next := regnext (s);
     if next = nil       // Next ptr.
      then Result := Result + '(0)'
      else Result := Result + Format ('(%d)', [(s - programm) + (next - s)]);
     inc (s, 3);
     if (op = ANYOF) or (op = ANYBUT) or (op = EXACTLY) then begin
         // Literal string, where present.
         while s^ <> #0 do begin
           Result := Result + s^;
           inc (s);
          end;
         inc (s);
      end;
     Result := Result + #$d#$a;
   end; { of while}

  // Header fields of interest.
  
  if regstart <> #0
   then Result := Result + 'start ' + regstart;
  if reganch <> #0
   then Result := Result + 'anchored ';
  if regmust <> nil
   then Result := Result + 'must have ' + regmust;
  Result := Result + #$d#$a;
 end; { of function TRegExpr.Dump
--------------------------------------------------------------}
{$ENDIF}


end.

