unit DiffUnit;

(*******************************************************************************
* Component         TDiff                                                      *
* Version:          2.5.1                                                      *
* Date:             22 June 2005                                               *
* Compilers:        Delphi 3 - Delphi 7                                        *
* Author:           Angus Johnson - angusj-AT-myrealbox-DOT-com                *
* Copyright:        © 2001-2005 Angus Johnson                                  *
*                                                                              *
* Licence to use, terms and conditions:                                        *
*                   The code in the TDiff component is released as freeware    *
*                   provided you agree to the following terms & conditions:    *
*                   1. the copyright notice, terms and conditions are          *
*                   left unchanged                                             *
*                   2. modifications to the code by other authors must be      *
*                   clearly documented and accompanied by the modifier's name. *
*                   3. the TDiff component may be freely compiled into binary  *
*                   format and no acknowledgement is required. However, a      *
*                   discrete acknowledgement would be appreciated (eg. in a    *
*                   program's 'About Box').                                    *
*                                                                              *
* Description:      Component to list differences between two integer arrays   *
*                   using a "longest common subsequence" algorithm.            *
*                   Typically, this component is used to diff 2 text files     *
*                   once their individuals lines have been hashed.             *
*                   By uncommenting {$DEFINE DIFF_CHARS} this component        *
*                   can also diff char arrays.                                 *
*                                                                              *
* Acknowledgements: The key algorithm in this component is based on:           *
*                   "An O(ND) Difference Algorithm and its Variations"         *
*                   By E Myers - Algorithmica Vol. 1 No. 2, 1986, pp. 251-266  *
*                   http://www.cs.arizona.edu/people/gene/                     *
*                   http://www.cs.arizona.edu/people/gene/PAPERS/diff.ps       *
*                                                                              *
*******************************************************************************)


(*******************************************************************************
* History:                                                                     *
* 13 December 2001 - Original Release                                          *
* 24 February 2002 - OnProgress event added, improvements to code comments     *
* 15 April 2003    - Bug fix in diff algorithm                                 *
* 20 January 2004  - Minor bug fix, code and documentation improvements        *
* 24 January 2004  - Fixed minor bug introduced in 20-Jan changes.             *
*                    Further code and documentation improvements               *
* 16 February 2004 - Added Precision property to enable suboptimal (but very   *
*                    much faster) searches of large and dissimilar arrays      *
* 11 March 2005    - Minor bug fix                                             *
* 22 June 2005     - Removed buggy Precision property (at least until fixed)   *
*******************************************************************************)

interface

uses
  Windows, SysUtils, Classes, extctrls, Forms, Graphics;

const
  //Max realistic deviation from centre diagonal vector ...
  MAX_DIAGONAL = $FFFFFF;
  //the following empirical values are used for suboptimal (but fast) matches...
  BIG_SLIDE = 20;
  LOOK_FOR_EXIT = 200;
type
  PDiagVectorArray = ^TDiagVectorArray;
  TDiagVectorArray = array [-MAX_DIAGONAL .. +MAX_DIAGONAL] of integer;
  TScriptKind = (skAddRange, skDelRange, skAddDel);

  //nb: the OnProgress event has only a small effect on overall performance
//  {$DEFINE DIFF_PROGRESS}

  {.$DEFINE DIFF_CHARS}

  {$IFDEF DIFF_CHARS}
  TCharArray = array[1..(MAXINT div sizeof(Char))] of Char;
  PCharArray = ^TCharArray;
  {$ELSE}
  TIntArray = array[1..(MAXINT div sizeof(integer))] of integer;
  PIntArray = ^TIntArray;
  {$ENDIF}

  TChangeKind = (ckAdd, ckDelete, ckModify);

  PChangeRec =^TChangeRec;
  TChangeRec = record
    Kind     : TChangeKind; //(ckAdd, ckDelete, ckModify)
    x        : integer;     //Array1 offset (where to add, delete, modify)
    y        : integer;     //Array2 offset (what to add, modify)
    Range    : integer;     //range :-)
  end;

  TProgressEvent = procedure (Sender: TObject; ProgressPercent: integer) of object;

  TDiff = class(TComponent)
  private
    MaxD: integer;
    fChangeList: TList;
    fLastAdd, fLastDel, fLastMod: PChangeRec;
    diagVecB,
    diagVecF: PDiagVectorArray; //forward and backward arrays
    Array1,
    Array2: {$IFDEF DIFF_CHARS} PCharArray{$ELSE}PIntArray{$ENDIF};
    fCancelled: boolean;

    {$IFDEF DIFF_PROGRESS}
    fQpc1, fQpc2, fQpc3: TLargeInteger;
    fHpfcEnabled: boolean;
    fMaxX: integer;
    fForwardX: integer;
    fBackwardX: integer;
    fProgressTimer: TTimer;
    fProgressInterval: integer;
    fOnProgress: TProgressEvent;
    procedure DoProgressTimer(Sender: TObject);
    {$ENDIF}
    function RecursiveDiff(bottom1, bottom2, top1, top2: integer): boolean;
    procedure AddToScript(bottom1, bottom2, top1, top2: integer; ScriptKind: TScriptKind);
    procedure ClearChanges;
    function GetChangeCount: integer;
    function GetChanges(index: integer): TChangeRec;
    procedure PushAdd;
    procedure PushDel;
    procedure PushMod;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    {$IFDEF DIFF_CHARS}
    function Execute(const Arr1, Arr2: PCharArray; ArrSize1, ArrSize2: integer): boolean;
    {$ELSE}
    function Execute(const Arr1, Arr2: PIntArray; ArrSize1, ArrSize2: integer): boolean;
    {$ENDIF}
    procedure Cancel; //allow cancelling prolonged comparisons
    property ChangeCount: integer read GetChangeCount;
    property Changes[index: integer]: TChangeRec read GetChanges; default;

    {$IFDEF DIFF_PROGRESS}
    property OnProgress: TProgressEvent read fOnProgress write fOnProgress;
    property ProgressInterval: integer read fProgressInterval
      write fProgressInterval;
    {$ENDIF}
  end;

implementation

type
  {$IFDEF DIFF_CHARS}
  PArray = PByteArray;
  {$ELSE}
  PArray = PIntArray;
  {$ENDIF}

//------------------------------------------------------------------------------
// Miscellaneous Functions ...
//------------------------------------------------------------------------------

function min(a,b: integer): integer;
begin
  if a < b then result := a else result := b;
end;
//------------------------------------------------------------------------------

function max(a,b: integer): integer;
begin
  if a > b then result := a else result := b;
end;

//------------------------------------------------------------------------------
// TDiff Class ...
//------------------------------------------------------------------------------

constructor TDiff.Create(aOwner: TComponent);
begin
  inherited;
  fChangeList := TList.create;
  //fPrecision := 5; //maximum precision
  {$IFDEF DIFF_PROGRESS}
  fProgressTimer := TTimer.Create(self);
  fProgressTimer.Enabled := false;
  fProgressTimer.OnTimer := DoProgressTimer;
  fProgressInterval := 1000; //1 second
  fHpfcEnabled := QueryPerformanceFrequency(fQpc1);
  {$ENDIF}
end;
//------------------------------------------------------------------------------

destructor TDiff.Destroy;
begin
  ClearChanges;
  fChangeList.free;
  inherited;
end;
//------------------------------------------------------------------------------

{$IFDEF DIFF_PROGRESS}
procedure TDiff.DoProgressTimer(Sender: TObject);
const
  EmpiricalPC = 46;
begin
  if not fHpfcEnabled or not assigned(fOnProgress) then exit
  else if fBackwardX > fForwardX then
  begin
    //if fPrecision = 5 then EmpiricalPC := 46 else EmpiricalPC := 10;
    //still trying to find the midpoint of the whole editpath ...
    //empirically it takes about 46% of the time just to find the midpoint.
    fOnProgress(self, (fMaxX - (fBackwardX - fForwardX))*EmpiricalPC div fMaxX)
  end else
  begin
    //if fPrecision = 5 then EmpiricalPC := 46 else EmpiricalPC := 10;
    //after the midpoint is found, the simplest way to estimate progress
    //is to use a high-resolution counter ...
    {$IFDEF VER100}
    if fQpc2.quadpart = 0 then QueryPerformanceCounter(fQpc2);
    QueryPerformanceCounter(fQpc3);
    fOnProgress(self, trunc((fQpc3.quadpart-fQpc1.quadpart)*EmpiricalPC /
      (fQpc2.quadpart-fQpc1.quadpart)) );
    {$ELSE}
    if fQpc2 = 0 then QueryPerformanceCounter(fQpc2);
    QueryPerformanceCounter(fQpc3);
    fOnProgress(self, ((fQpc3-fQpc1)*EmpiricalPC div (fQpc2-fQpc1)) );
    {$ENDIF}
  end;
end;
{$ENDIF}
//------------------------------------------------------------------------------

procedure TDiff.Cancel;
begin
  fCancelled := true;
end;
//------------------------------------------------------------------------------

{$IFDEF DIFF_CHARS}
function TDiff.Execute(const Arr1, Arr2: PCharArray; ArrSize1, ArrSize2: integer): boolean;
{$ELSE}
function TDiff.Execute(const Arr1, Arr2: PIntArray; ArrSize1, ArrSize2: integer): boolean;
{$ENDIF}
var
  IntArr_f, IntArr_b: PArray;
  bottom1, bottom2, top1, top2: integer;
begin
  result := false;
  ClearChanges;

  if not assigned(Arr1) or not assigned(Arr2) then exit;
  Array1 := Arr1;
  Array2 := Arr2;

  //MaxD == Maximum possible deviation from centre diagonal vector
  //which can't be more than the largest intArray (with upperlimit = MAX_DIAGONAL) ...
  MaxD := min(max(ArrSize1,ArrSize2), MAX_DIAGONAL);

  //estimate the no. changes == 1/8 total size rounded to a 32bit boundary
  fChangeList.Capacity := (max(MaxD,1024) div 32)*4;

  {$IFDEF DIFF_PROGRESS}
  fMaxX := ArrSize1;
  fForwardX := 0;
  fBackwardX := fMaxX;
  fProgressTimer.Enabled := true;
  fProgressTimer.Interval := fProgressInterval;
  QueryPerformanceCounter(fQpc1);
  {$IFDEF VER100}
  fQpc2.QuadPart := 0;
  {$ELSE}
  fQpc2 := 0;
  {$ENDIF}
  {$ENDIF}

  IntArr_f := nil; IntArr_b := nil;
  try
    //allocate the vector memory ...
    GetMem(IntArr_f, sizeof(integer)*(MaxD*2+1));
    GetMem(IntArr_b,sizeof(integer)*(MaxD*2+1));
    //Align the forward and backward diagonal vector arrays
    //with the memory which has just been allocated ...
    pchar(diagVecF) := pchar(IntArr_f) - sizeof(integer)*(MAX_DIAGONAL-MaxD);
    pchar(diagVecB) := pchar(IntArr_b) - sizeof(integer)*(MAX_DIAGONAL-MaxD);

    fCancelled := false;

    bottom1 := 1;
    bottom2 := 1;
    top1 := ArrSize1;
    top2 := ArrSize2;

    //ignore leading and trailing matches, we're only interested in diffs...
    //20-Jan-04: this code block was moved from RecursiveDiff()
     while (bottom1 <= top1) and (bottom2 <= top2) and
      (Array1[bottom1]=Array2[bottom2]) do
    begin
      inc(bottom1); inc(bottom2);
    end;
    while (top1 >= bottom1) and (top2 >= bottom2) and //11-Mar-2005
      (Array1[top1]=Array2[top2]) do
    begin
      dec(top1); dec(top2);
    end;

    //NOW DO IT HERE...
    if (bottom1 > top1) and (bottom2 > top2) then //24-Jan-04
      result := true else //ie identical arrays
      result := RecursiveDiff(bottom1 -1, bottom2 -1, top1, top2);

    //add remaining range buffers onto ChangeList...
    PushAdd; PushDel;
    if not result then fChangeList.clear;
  finally
    FreeMem(IntArr_f);
    FreeMem(IntArr_b);
    {$IFDEF DIFF_PROGRESS}
    fProgressTimer.Enabled := false;
    {$ENDIF}
  end;
end;
//------------------------------------------------------------------------------

function TDiff.RecursiveDiff(bottom1, bottom2, top1, top2: integer): boolean;
var
  //Recursive functions should generally use the heap (rather than the stack)
  //for local vars. However, as the maximum depth of recursion here is
  //relatively small (<25), the risk of stack overflow is negligible.
  i, curr1, curr2, Delta, D, k: integer;
begin
    result := true;

    //check if just all additions or all deletions...
    if (top1 = bottom1) then
    begin
      AddToScript(bottom1,bottom2,top1,top2,skAddRange);
      exit;
    end else if (top2 = bottom2) then
    begin
      AddToScript(bottom1,bottom2,top1,top2,skDelRange);
      exit;
    end;

    //Delta = offset of bottomright from topleft corner
    Delta := (top1 - bottom1) - (top2 - bottom2);
    //initialize the forward and backward diagonal vectors including the
    //outer bounds ...
    diagVecF[0] := bottom1;
    diagVecB[Delta] := top1;
    //24-Jan-04 ...
    diagVecF[top1 - bottom1] := top1;
    diagVecB[top1 - bottom1] := top1;
    //the following avoids the -(top2 - bottom2) vectors being assigned
    //invalid values. Also, the algorithm is a little faster than when
    //initialising the -(top2 - bottom2) vectors instead...
    if Delta > 0 then
    begin
      diagVecF[-(top2 - bottom2 +1)] := bottom1;
      diagVecB[-(top2 - bottom2 +1)] := bottom1;
    end;

    //nb: the 2 arrays of diagonal vectors diagVecF and diagVecB store the
    //current furthest forward and backward Array1 coords respectively
    //(something between bottom1 and top1). The Array2 coords can be derived
    //from these (see added comments (1) at the bottom of this unit).

    //When the forward and backward arrays cross over at some point the
    //curr1 and curr2 values represent a relative mid-point on the 'shortest
    //common sub-sequence' path. By recursively finding these points the
    //whole path can be constructed.

    //OUTER LOOP ...
    //MAKE INCREASING OSCILLATIONS ABOUT CENTRE DIAGONAL UNTIL A FORWARD
    //DIAGONAL VECTOR IS GREATER THAN OR EQUAL TO A BACKWARD DIAGONAL.
    for D := 1 to MaxD do
    begin
//    application.processmessages;
      if fCancelled then
      begin
        result := false;
        exit;
      end;

      //forward loop...............................................
      //nb: k == index of current diagonal vector and
      //    will oscillate (in increasing swings) between -MaxD and MaxD
      k := -D;
      //stop going outside the grid ...
      while k < -(top2 - bottom2) do inc(k, 2);

      i := min(D, top1 - bottom1 -1); //24-Jan-04
      while (k <= i) do
      begin
        //derive curr1 from the larger of adjacent vectors...
        if (k = -D) or ((k < D) and (diagVecF[k-1]<diagVecF[k+1])) then
          curr1 := diagVecF[k+1] else
          curr1 := diagVecF[k-1]+1;
        //derive curr2 (see above) ...
        curr2 := curr1 - bottom1 + bottom2 -k;
        //while (curr1+1,curr2+1) match, increment them...
        while (curr1 < top1) and (curr2 < top2) and (Array1[curr1+1]= Array2[curr2+1]) do
        begin
          inc(curr1); inc(curr2);
        end;
        //update current vector ...
        diagVecF[k] := curr1;

        {$IFDEF DIFF_PROGRESS}
        if curr1 > fForwardX then fForwardX := curr1;
        {$ENDIF}

        //check if a vector in diagVecF overlaps the corresp. diagVecB vector.
        //(If a crossover point found here then further recursion is required.)
        if odd(Delta) and (k > -D+Delta) and (k < D+Delta) and (diagVecF[k]>=diagVecB[k]) then
        begin
          //find subsequent points by recursion ...

          //To avoid declaring 2 extra variables in this recursive function ..
          //Delta & k are simply reused to store the curr1 & curr2 values ...
          Delta := curr1; k := curr2;
          //ignore trailing matches in lower block ...
          while (curr1 > bottom1) and (curr2 > bottom2) and (Array1[curr1]= Array2[curr2]) do
          begin
            dec(curr1); dec(curr2);
          end;
          result := RecursiveDiff(bottom1,bottom2,curr1,curr2);
          //do recursion with the upper block...
          if not result then exit;
          //and again with the lower block (nb: Delta & k are stored curr1 & curr2)...
          result := RecursiveDiff(Delta,k,top1,top2);
          exit; //All done!!!
        end;
        inc(k,2);
      end;

      //backward loop..............................................
      //nb: k will oscillate (in increasing swings) between -MaxD and MaxD
      k := -D+Delta;
      //stop going outside grid and also ensure we remain within the diagVecB[]
      //and diagVecF[] array bounds.
      //nb: in the backward loop it is necessary to test the bottom left corner.
      while k < -(top2 - bottom2) do inc(k, 2);

      i := min(D+Delta, top1 - bottom1 -1); //24-Jan-04
      while (k <= i) do
      begin
        //derive curr1 from the adjacent vectors...
        if (k = D+Delta) or ((k > -D+Delta) and (diagVecB[k+1]>diagVecB[k-1])) then
          curr1 := diagVecB[k-1] else
          curr1 := diagVecB[k+1]-1;

        curr2 := curr1 - bottom1 + bottom2 -k;
        //if curr2 < bottom2 then break; //shouldn't be necessary and adds a 3% time penalty

        //slide up and left if possible ...
        while (curr1 > bottom1) and (curr2 > bottom2) and (Array1[curr1]= Array2[curr2]) do
        begin
          dec(curr1); dec(curr2);
        end;
        //update current vector ...
        diagVecB[k] := curr1;

        {$IFDEF DIFF_PROGRESS}
        if curr1 < fBackwardX then fBackwardX := curr1;
        {$ENDIF}

        //check if a crossover point reached...
        if not odd(Delta) and (k >= -D) and (k <= D) and (diagVecF[k]>=diagVecB[k]) then
        begin
          if (bottom1+1 = top1) and (bottom2+1 = top2) then
          begin
            //ie smallest divisible unit
            //(nb: skAddDel could also have been skDelAdd)
            AddToScript(bottom1, bottom2, top1, top2, skAddDel);
          end else
          begin
            //otherwise process the lower block ...
            result := RecursiveDiff(bottom1, bottom2, curr1, curr2);
            if not result then exit;
            //strip leading matches in upper block ...
            while (curr1 < top1) and (curr2 < top2) and (Array1[curr1+1]= Array2[curr2+1]) do
            begin
              inc(curr1); inc(curr2);
            end;
            //and finally process the upper block ...
            result := RecursiveDiff(curr1, curr2, top1, top2);
          end;
          exit; //All done!!!
        end;
        inc(k,2);
      end;
    end;
    result := false;
end;
//------------------------------------------------------------------------------

(*//buggy lowered precision stuff ...
function TDiff.RecursiveDiff2(bottom1, bottom2, top1, top2: integer): boolean;
var
  i, j, curr1, curr2, Delta, D, k, big_slide_vec: integer;
begin
    result := true;

    //check if just all additions or all deletions...
    if (top1 = bottom1) then
    begin
      AddToScript(bottom1,bottom2,top1,top2,skAddRange);
      exit;
    end else if (top2 = bottom2) then
    begin
      AddToScript(bottom1,bottom2,top1,top2,skDelRange);
      exit;
    end;

    //Delta = offset of bottomright from topleft corner
    Delta := (top1 - bottom1) - (top2 - bottom2);
    //initialize the forward and backward diagonal vectors including the
    //outer bounds ...
    diagVecF[0] := bottom1;
    diagVecB[Delta] := top1;
    //24-Jan-04 ...
    diagVecF[top1 - bottom1] := top1;
    diagVecB[top1 - bottom1] := top1;
    //the following avoids the -(top2 - bottom2) vectors being assigned
    //invalid values. Also, the algorithm is a little faster than when
    //initialising the -(top2 - bottom2) vectors instead...
    if Delta > 0 then
    begin
      diagVecF[-(top2 - bottom2 +1)] := bottom1;
      diagVecB[-(top2 - bottom2 +1)] := bottom1;
    end;

    //nb: the 2 arrays of diagonal vectors diagVecF and diagVecB store the
    //current furthest forward and backward Array1 coords respectively
    //(something between bottom1 and top1). The Array2 coords can be derived
    //from these (see added comments (1) at the bottom of this unit).

    //When the forward and backward arrays cross over at some point the
    //curr1 and curr2 values represent a relative mid-point on the 'shortest
    //common sub-sequence' path. By recursively finding these points the
    //whole path can be constructed.

    //OUTER LOOP ...
    //MAKE INCREASING OSCILLATIONS ABOUT CENTRE DIAGONAL UNTIL A FORWARD
    //DIAGONAL VECTOR IS GREATER THAN OR EQUAL TO A BACKWARD DIAGONAL.
    for D := 1 to MaxD do
    begin
      application.processmessages;
      if fCancelled then
      begin
        result := false;
        exit;
      end;

      big_slide_vec := D;

      //forward loop...............................................
      //nb: k == index of current diagonal vector and
      //    will oscillate (in increasing swings) between -MaxD and MaxD
      k := -D;
      //stop going outside the grid ...
      while k < -(top2 - bottom2) do inc(k, 2);

      i := min(D, top1 - bottom1 -1); //24-Jan-04
      while (k <= i) do
      begin
        //derive curr1 from the larger of adjacent vectors...
        if (k = -D) or ((k < D) and (diagVecF[k-1]<diagVecF[k+1])) then
          curr1 := diagVecF[k+1] else
          curr1 := diagVecF[k-1]+1;
        j := 0;
        //derive curr2 (see above) ...
        curr2 := curr1 - bottom1 + bottom2 -k;
        //while (curr1+1,curr2+1) match, increment them...
        while (curr1 < top1) and (curr2 < top2) and (Array1[curr1+1]= Array2[curr2+1]) do
        begin
          inc(curr1); inc(curr2); inc(j);
        end;
        //update current vector ...
        diagVecF[k] := curr1;

        //OK, if we've gone a relative long way without finding a midpoint then
        //let's see if we can find a compromise point ...
        if (D > LOOK_FOR_EXIT) and (j > BIG_SLIDE) then
          if (big_slide_vec = D) or
            ((diagVecF[k]*2 - k) > (diagVecF[big_slide_vec]*2 - big_slide_vec)) then
              big_slide_vec := k;

        {$IFDEF DIFF_PROGRESS}
        if curr1 > fForwardX then fForwardX := curr1;
        {$ENDIF}

        //check if a vector in diagVecF overlaps the corresp. diagVecB vector.
        //(If a crossover point found here then further recursion is required.)
        if odd(Delta) and (k > -D+Delta) and (k < D+Delta) and (diagVecF[k]>=diagVecB[k]) then
        begin
          //find subsequent points by recursion ...

          //To avoid declaring 2 extra variables in this recursive function ..
          //Delta & k are simply reused to store the curr1 & curr2 values ...
          Delta := curr1; k := curr2;
          //ignore trailing matches in lower block ...
          while (curr1 > bottom1) and (curr2 > bottom2) and (Array1[curr1]= Array2[curr2]) do
          begin
            dec(curr1); dec(curr2);
          end;
          result := RecursiveDiff2(bottom1,bottom2,curr1,curr2);
          //do recursion with the upper block...
          if not result then exit;
          //and again with the lower block (nb: Delta & k are stored curr1 & curr2)...
          result := RecursiveDiff2(Delta,k,top1,top2);
          exit; //All done!!!
        end;
        inc(k,2);
      end;

      if (big_slide_vec < D) then
      begin
        //OK, we've found a compromise point so let's use it ...
        curr1 := diagVecF[big_slide_vec];
        curr2 := curr1 - bottom1 + bottom2 -big_slide_vec;

        //To avoid declaring 2 extra variables in this recursive function ..
        //Delta & k are simply reused to store the curr1 & curr2 values ...
        Delta := curr1; k := curr2;
        //ignore trailing matches in lower block ...
        while (curr1 > bottom1) and (curr2 > bottom2) and (Array1[curr1]= Array2[curr2]) do
        begin
          dec(curr1); dec(curr2);
        end;
        result := RecursiveDiff2(bottom1,bottom2,curr1,curr2);
        //do recursion with the upper block...
        if not result then exit;
        //and again with the lower block (nb: Delta & k are stored curr1 & curr2)...
        result := RecursiveDiff2(Delta,k,top1,top2);
        exit; //All done!!!
      end;

      //backward loop..............................................
      //nb: k will oscillate (in increasing swings) between -MaxD and MaxD
      k := -D+Delta;
      //stop going outside grid and also ensure we remain within the diagVecB[]
      //and diagVecF[] array bounds.
      //nb: in the backward loop it is necessary to test the bottom left corner.
      while k < -(top2 - bottom2) do inc(k, 2);

      i := min(D+Delta, top1 - bottom1 -1); //24-Jan-04
      while (k <= i) do
      begin
        //derive curr1 from the adjacent vectors...
        if (k = D+Delta) or ((k > -D+Delta) and (diagVecB[k+1]>diagVecB[k-1])) then
          curr1 := diagVecB[k-1] else
          curr1 := diagVecB[k+1]-1;

        j := 0;
        curr2 := curr1 - bottom1 + bottom2 -k;

        //slide up and left if possible ...
        while (curr1 > bottom1) and (curr2 > bottom2) and (Array1[curr1]= Array2[curr2]) do
        begin
          dec(curr1); dec(curr2); inc(j);
        end;
        //update current vector ...
        diagVecB[k] := curr1;

        //OK, if we've gone a relative long way without finding a midpoint then
        //let's see if we can find a compromise point ...
        if (D > LOOK_FOR_EXIT) and (j > BIG_SLIDE) then
          if (big_slide_vec = D) or
            ((diagVecB[k]*2 - k) < (diagVecB[big_slide_vec]*2 - big_slide_vec)) then
              big_slide_vec := k;

        {$IFDEF DIFF_PROGRESS}
        if curr1 < fBackwardX then fBackwardX := curr1;
        {$ENDIF}

        //check if a crossover point reached...
        if not odd(Delta) and (k >= -D) and (k <= D) and (diagVecF[k]>=diagVecB[k]) then
        begin
          if (bottom1+1 = top1) and (bottom2+1 = top2) then
          begin
            //ie smallest divisible unit
            //(nb: skAddDel could also have been skDelAdd)
            AddToScript(bottom1, bottom2, top1, top2, skAddDel);
          end else
          begin
            //otherwise process the lower block ...
            result := RecursiveDiff2(bottom1, bottom2, curr1, curr2);
            if not result then exit;
            //strip leading matches in upper block ...
            while (curr1 < top1) and (curr2 < top2) and (Array1[curr1+1]= Array2[curr2+1]) do
            begin
              inc(curr1); inc(curr2);
            end;
            //and finally process the upper block ...
            result := RecursiveDiff2(curr1, curr2, top1, top2);
          end;
          exit; //All done!!!
        end;
        inc(k,2);
      end;

      if (big_slide_vec < D) then
      begin
        //OK, we've found a compromise point so let's use it ...
        curr1 := diagVecB[big_slide_vec];
        curr2 := curr1 - bottom1 + bottom2 -big_slide_vec;
        result := RecursiveDiff2(bottom1, bottom2, curr1, curr2);
        if not result then exit;
        //strip leading matches in upper block ...
        while (curr1 < top1) and (curr2 < top2) and (Array1[curr1+1]= Array2[curr2+1]) do
        begin
          inc(curr1); inc(curr2);
        end;
        //and finally process the upper block ...
        result := RecursiveDiff2(curr1, curr2, top1, top2);
        exit; //All done!!!
      end;

      {nb ...
      case fPrecision of
        1: fMustExitVal := 256;
        2: fMustExitVal := 512;
        3: fMustExitVal := 1024;
        4: fMustExitVal := 4096;
        5: fMustExitVal := 0;
      end;}

      if (D > fMustExitVal) then
      begin
        //OK, we've gone more than far enough, so simply pick the
        //most advanced forward vector so far to derive a suboptimal "midpoint"
        k := -D;
        while k < -(top2 - bottom2) do inc(k, 2);
        i := min(D, top1 - bottom1 -1);
        big_slide_vec := k;
        inc(k,2);
        while (k <= i) do
        begin
          if ((diagVecF[k]*2 - k) > (diagVecF[big_slide_vec]*2 - big_slide_vec)) then
            big_slide_vec := k;
          inc(k,2);
        end;
        curr1 := diagVecF[big_slide_vec];
        curr2 := curr1 - bottom1 + bottom2 -big_slide_vec;
        //To avoid declaring 2 extra variables in this recursive function ..
        //Delta & k are simply reused to store the curr1 & curr2 values ...
        Delta := curr1; k := curr2;
        //ignore trailing matches in lower block ...
        while (curr1 > bottom1) and (curr2 > bottom2) and (Array1[curr1]= Array2[curr2]) do
        begin
          dec(curr1); dec(curr2);
        end;
        result := RecursiveDiff2(bottom1,bottom2,curr1,curr2);
        //do recursion with the upper block...
        if not result then exit;
        //and again with the lower block (nb: Delta & k are stored curr1 & curr2)...
        result := RecursiveDiff2(Delta,k,top1,top2);
        exit; //All done!!!
      end;

    end;
    result := false;
end; *)
//------------------------------------------------------------------------------

procedure TDiff.PushAdd;
begin
  PushMod;
  if assigned(fLastAdd) then fChangeList.Add(fLastAdd);
  fLastAdd := nil;
end;
//------------------------------------------------------------------------------
procedure TDiff.PushDel;
begin
  PushMod;
  if assigned(fLastDel) then fChangeList.Add(fLastDel);
  fLastDel := nil;
end;
//------------------------------------------------------------------------------
procedure TDiff.PushMod;
begin
  if assigned(fLastMod) then fChangeList.Add(fLastMod);
  fLastMod := nil;
end;
//------------------------------------------------------------------------------

//This is a bit UGLY but simply reduces many adds & deletes to many fewer
//add, delete & modify ranges which are then stored in ChangeList...
procedure TDiff.AddToScript(bottom1, bottom2, top1, top2: integer; ScriptKind: TScriptKind);
var
  i: integer;

  //---------------------------------------------------

  procedure TrashAdd;
  begin
    Dispose(fLastAdd); fLastAdd := nil;
  end;
  //---------------------------------------------------

  procedure TrashDel;
  begin
    Dispose(fLastDel); fLastDel := nil;
  end;
  //---------------------------------------------------

  procedure NewAdd(bottom1,bottom2: integer);
  begin
    New(fLastAdd);
    fLastAdd.Kind := ckAdd;
    fLastAdd.x := bottom1;
    fLastAdd.y := bottom2;
    fLastAdd.Range := 1;
  end;
  //---------------------------------------------------

  procedure NewMod(bottom1,bottom2: integer);
  begin
    New(fLastMod);
    fLastMod.Kind := ckModify;
    fLastMod.x := bottom1;
    fLastMod.y := bottom2;
    fLastMod.Range := 1;
  end;
  //---------------------------------------------------

  procedure NewDel(bottom1: integer);
  begin
    New(fLastDel);
    fLastDel.Kind := ckDelete;
    fLastDel.x := bottom1;
    fLastDel.y := 0;
    fLastDel.Range := 1;
  end;
  //---------------------------------------------------

  // 1. there can NEVER be concurrent fLastAdd and fLastDel record ranges.
  // 2. fLastMod is always pushed onto ChangeList before fLastAdd & fLastDel.

  procedure Add(bottom1,bottom2: integer);
  begin
    if assigned(fLastAdd) then                  //OTHER ADDS PENDING
    begin
      if (fLastAdd.x = bottom1) and
        (fLastAdd.y + fLastAdd.Range = bottom2) then
        inc(fLastAdd.Range)                     //add in series
      else begin PushAdd; NewAdd(bottom1,bottom2); end;   //add NOT in series
    end
    else if assigned(fLastDel) then             //NO ADDS BUT DELETES PENDING
    begin
      if bottom1 = fLastDel.x then                   //add matches pending del so modify ...
      begin
        if assigned(fLastMod) and (fLastMod.x + fLastMod.Range -1 = bottom1) and
          (fLastMod.y + fLastMod.Range -1 = bottom2) then
          inc(fLastMod.Range)                   //modify in series
        else begin PushMod; NewMod(bottom1,bottom2); end; //start NEW modify

        if fLastDel.Range = 1 then TrashDel     //decrement or remove existing del
        else begin dec(fLastDel.Range); inc(fLastDel.x); end;
      end
      else begin PushDel; NewAdd(bottom1,bottom2); end;   //add does NOT match pending del's
    end
    else
      NewAdd(bottom1,bottom2);                            //NO ADDS OR DELETES PENDING
  end;
  //---------------------------------------------------

  procedure Delete(bottom1: integer);
  begin
    if assigned(fLastDel) then                  //OTHER DELS PENDING
    begin
      if (fLastDel.x + fLastDel.Range = bottom1) then
        inc(fLastDel.Range)                     //del in series
      else begin PushDel; NewDel(bottom1); end;      //del NOT in series
    end
    else if assigned(fLastAdd) then             //NO DELS BUT ADDS PENDING
    begin
      if bottom1 = fLastAdd.x then                   //del matches pending add so modify ...
      begin
        if assigned(fLastMod) and (fLastMod.x + fLastMod.Range = bottom1) then
          inc(fLastMod.Range)                           //mod in series
        else begin PushMod; NewMod(bottom1,fLastAdd.y); end; //start NEW modify ...
        if fLastAdd.Range = 1 then TrashAdd     //decrement or remove existing add
        else begin dec(fLastAdd.Range); inc(fLastAdd.x); inc(fLastAdd.y); end;
      end
      else begin PushAdd; NewDel(bottom1); end;      //del does NOT match pending add's
    end
    else
      NewDel(bottom1);                               //NO ADDS OR DELETES PENDING
  end;
  //---------------------------------------------------

begin
  case ScriptKind of
    skAddRange:     for i := bottom2 to top2-1 do Add(bottom1,i);
    skDelRange:     for i := bottom1 to top1-1 do Delete(i);
    skAddDel:       begin Add(bottom1,bottom2); Delete(top1-1); end;
  end;
end;
//------------------------------------------------------------------------------

procedure TDiff.ClearChanges;
var
  i: integer;
begin
  for i := 0 to fChangeList.Count-1 do
    dispose(PChangeRec(fChangeList[i]));
  fChangeList.clear;
end;
//------------------------------------------------------------------------------

function TDiff.GetChangeCount: integer;
begin
  result := fChangeList.count;
end;
//------------------------------------------------------------------------------

function TDiff.GetChanges(index: integer): TChangeRec;
begin
  result := PChangeRec(fChangeList[index])^;
end;
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

(*******************************************************************************
*                                                                              *
* ADDITIONAL NOTES:                                                            *
*                                                                              *
* (1)  formula: curr2 := curr1 - bottom1 + bottom2 -k;                         *
*               (k = index of current diagonal vector)                         *
*                                                                              *
*      a r r 1                                                                 *
*    \ • • o •                                                                 *
*  a • \ • • •  given bottom1 = 0 and bottom2 = 0 and                          *
*  r • • \ • •  given that k = 0 and curr1 = 3, then                           *
*  r o • • + •  curr2 := 3 - 0 + 0 - 0; (ie 3)                                 *
*  2 • • • • \                                                                 *
*                                                                              *
*      a r r 1                                                                 *
*    • • o • •                                                                 *
*  a • • • • •  given bottom1 = 0 and bottom2 = 0 and                          *
*  r \ • • • •  given that k = -2 and curr1 = 2, then                          *
*  r • \ • • •                                                                 *
*  2 o • + • •  curr2 := 2 - 0 + 0 - -2; (ie 4)                                *
*    • • • \ •                                                                 *
*                                                                              *
*                                                                              *
*******************************************************************************)

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

end.
