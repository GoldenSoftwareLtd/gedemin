(***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is TurboPower Async Professional
 *
 * The Initial Developer of the Original Code is
 * TurboPower Software
 *
 * Portions created by the Initial Developer are Copyright (C) 1991-2002
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK ***** *)

{*********************************************************}
{*                   AWABSPCL.PAS 4.06                   *}
{*********************************************************}
{* Abstract protocol                                     *}
{*********************************************************}  

{Global defines potentially affecting this unit}
{$I AWDEFINE.INC}

{Options required for this unit}
{$V-,I-,B-,F+,X+,Q-,R-,N+}

{$IFDEF Win32}
{$J+}
{$ENDIF}

unit AwAbsPcl;
  {-Abstract protocol}

interface

uses
  WinTypes,
  WinProcs,
  Messages,
  SysUtils,
  AdExcept,                                                       
  AwTPcl,
  OoMisc,
  AwUser,
  AdPort;

const
  {Compile-time options}
  awpDefAbsStatusInterval = 10;   {1 second between status updates} 

{Constructors/destructors}
function apInitProtocolData(var P : PProtocolData;
                            H : TApdCustomComPort;                     
                            Options : Cardinal) : Integer;
procedure apDoneProtocol(P : PProtocolData);
procedure apSetProtocolWindow(P : PProtocolData; HW : TApdHwnd);

{Next file}
procedure apSetFileList(P : PProtocolData; FL : PFileList);
function apMakeFileList(P : PProtocolData; var FL : PFileList; Size : Cardinal) : Integer;
procedure apDisposeFileList(P : PProtocolData; FL : PFileList; Size : Cardinal);
function apAddFileToList(P : PProtocolData; FL : PFileList; PName : PChar) : Integer;
function apNextFileMask(P : PProtocolData; FName : PChar) : Bool;
function apNextFileList(P : PProtocolData; FName : PChar) : Bool;

{Protocol options}
procedure apSetFileMask(P : PProtocolData; NewMask : PChar);
procedure apSetReceiveFilename(P : PProtocolData; FName : PChar);
procedure apSetDestinationDirectory(P : PProtocolData; Dir : PChar);
procedure apSetHandshakeWait(P : PProtocolData; NewHandshake, NewRetry : Cardinal);
procedure apSetOverwriteOption(P : PProtocolData; Opt : Cardinal);
procedure apSetEfficiencyParms(P : PProtocolData;
                               BlockOverhead, TurnAroundDelay : Cardinal);
procedure apSetProtocolPort(P : PProtocolData; H : TApdCustomComPort);
procedure apSetActualBPS(P : PProtocolData; BPS : LongInt);
procedure apSetStatusInterval(P : PProtocolData; NewInterval : Cardinal);
procedure apOptionsOn(P : PProtocolData; OptionFlags : Cardinal);
procedure apOptionsOff(P : PProtocolData; OptionFlags : Cardinal);
function apOptionsAreOn(P : PProtocolData; OptionFlags : Cardinal): Bool;

{Status methods}
function apSupportsBatch(P : PProtocolData) : Bool;
function apGetInitialFilePos(P : PProtocolData) : LongInt;
function apEstimateTransferSecs(P : PProtocolData; Size : LongInt) : LongInt;
procedure apGetProtocolInfo(P : PProtocolData; var Info : TProtocolInfo);

function apGetBytesTransferred(P : PProtocolData) : LongInt;
function apGetBytesRemaining(P : PProtocolData) : LongInt;

{Finish control}
procedure apSignalFinish(P : PProtocolData);

{Default file handling procedures}
procedure aapPrepareReading(P : PProtocolData);
procedure aapFinishReading(P : PProtocolData);
function aapReadProtocolBlock(P : PProtocolData;
                              var Block : TDataBlock;
                              var BlockSize : Cardinal) : Bool;
procedure aapPrepareWriting(P : PProtocolData);
procedure aapFinishWriting(P : PProtocolData);
function aapWriteProtocolBlock(P : PProtocolData;
                               var Block : TDataBlock;
                               BlockSize : Cardinal) : Bool;

{Internal routines}
procedure apStartProtocol(P : PProtocolData;
                          Protocol : Byte;
                          Transmit : Bool;
                          StartProc : TPrepareProc;
                          ProtFunc : TProtocolFunc);
procedure apStopProtocol(P : PProtocolData);
function apCrc32OfFile(P : PProtocolData; FName : PChar; Len : Longint) : LongInt;
procedure apResetStatus(P : PProtocolData);
procedure apShowFirstStatus(P : PProtocolData);
procedure apShowLastStatus(P : PProtocolData);

{Default hooks, send messages to parent window}
procedure apMsgStatus(P : PProtocolData; Options : Cardinal);
function apMsgNextFile(P : PProtocolData; FName : PChar) : Bool;
procedure apMsgLog(P : PProtocolData; Log : Cardinal);
function apMsgAcceptFile(P : PProtocolData; FName : PChar) : Bool;

{All errors routed through here}
procedure apProtocolError(P : PProtocolData; ErrorCode : Integer);

{General}
function apUpdateChecksum(CurByte : Byte; CheckSum : Cardinal) : Cardinal;
function apUpdateCrc(CurByte : Byte; CurCrc : Cardinal) : Cardinal;
function apUpdateCrcKermit(CurByte : Byte; CurCrc : Cardinal) : Cardinal;
function apStatusMsg(P : PChar; Status : Cardinal) : PChar;

procedure apSetProtocolMsgBase(NewBase : Cardinal);
procedure apResetReadWriteHooks(P : PProtocolData);

const
  {All chars quoted}
  DQFull    : TQuoteArray = ($FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF);
  {ETX ENQ DLE XON XOFF NAK}
  DQDefault : TQuoteArray = ($14, $00, $D4, $00, $00, $00, $00, $00);

{Ymodem/Zmodem timestamp routines interfaced but not exported}
function apTrimZeros(S : String) : String;
function apCurrentTimeStamp : LongInt;
function apOctalStr(L : LongInt) : String;
function apOctalStr2Long(S : String) : LongInt;
function apPackToYMTimeStamp(RawTime : LongInt) : LongInt;
function apYMTimeStampToPack(YMTime : LongInt) : LongInt;

const
  { UnixDaysBase gets "overwritten" in the this unit's init code for Delphi }
  UnixDaysBase : LongInt = 719163;{Days between 1/1/1 and 1/1/1970}
  SecsPerDay = 86400;             {Number of seconds in one day}

const
  ProtocolDataPtr = 1;

  Crc32Table : array[0..255] of DWORD = (                            
  $00000000, $77073096, $ee0e612c, $990951ba, $076dc419, $706af48f, $e963a535,
  $9e6495a3, $0edb8832, $79dcb8a4, $e0d5e91e, $97d2d988, $09b64c2b, $7eb17cbd,
  $e7b82d07, $90bf1d91, $1db71064, $6ab020f2, $f3b97148, $84be41de, $1adad47d,
  $6ddde4eb, $f4d4b551, $83d385c7, $136c9856, $646ba8c0, $fd62f97a, $8a65c9ec,
  $14015c4f, $63066cd9, $fa0f3d63, $8d080df5, $3b6e20c8, $4c69105e, $d56041e4,
  $a2677172, $3c03e4d1, $4b04d447, $d20d85fd, $a50ab56b, $35b5a8fa, $42b2986c,
  $dbbbc9d6, $acbcf940, $32d86ce3, $45df5c75, $dcd60dcf, $abd13d59, $26d930ac,
  $51de003a, $c8d75180, $bfd06116, $21b4f4b5, $56b3c423, $cfba9599, $b8bda50f,
  $2802b89e, $5f058808, $c60cd9b2, $b10be924, $2f6f7c87, $58684c11, $c1611dab,
  $b6662d3d, $76dc4190, $01db7106, $98d220bc, $efd5102a, $71b18589, $06b6b51f,
  $9fbfe4a5, $e8b8d433, $7807c9a2, $0f00f934, $9609a88e, $e10e9818, $7f6a0dbb,
  $086d3d2d, $91646c97, $e6635c01, $6b6b51f4, $1c6c6162, $856530d8, $f262004e,
  $6c0695ed, $1b01a57b, $8208f4c1, $f50fc457, $65b0d9c6, $12b7e950, $8bbeb8ea,
  $fcb9887c, $62dd1ddf, $15da2d49, $8cd37cf3, $fbd44c65, $4db26158, $3ab551ce,
  $a3bc0074, $d4bb30e2, $4adfa541, $3dd895d7, $a4d1c46d, $d3d6f4fb, $4369e96a,
  $346ed9fc, $ad678846, $da60b8d0, $44042d73, $33031de5, $aa0a4c5f, $dd0d7cc9,
  $5005713c, $270241aa, $be0b1010, $c90c2086, $5768b525, $206f85b3, $b966d409,
  $ce61e49f, $5edef90e, $29d9c998, $b0d09822, $c7d7a8b4, $59b33d17, $2eb40d81,
  $b7bd5c3b, $c0ba6cad, $edb88320, $9abfb3b6, $03b6e20c, $74b1d29a, $ead54739,
  $9dd277af, $04db2615, $73dc1683, $e3630b12, $94643b84, $0d6d6a3e, $7a6a5aa8,
  $e40ecf0b, $9309ff9d, $0a00ae27, $7d079eb1, $f00f9344, $8708a3d2, $1e01f268,
  $6906c2fe, $f762575d, $806567cb, $196c3671, $6e6b06e7, $fed41b76, $89d32be0,
  $10da7a5a, $67dd4acc, $f9b9df6f, $8ebeeff9, $17b7be43, $60b08ed5, $d6d6a3e8,
  $a1d1937e, $38d8c2c4, $4fdff252, $d1bb67f1, $a6bc5767, $3fb506dd, $48b2364b,
  $d80d2bda, $af0a1b4c, $36034af6, $41047a60, $df60efc3, $a867df55, $316e8eef,
  $4669be79, $cb61b38c, $bc66831a, $256fd2a0, $5268e236, $cc0c7795, $bb0b4703,
  $220216b9, $5505262f, $c5ba3bbe, $b2bd0b28, $2bb45a92, $5cb36a04, $c2d7ffa7,
  $b5d0cf31, $2cd99e8b, $5bdeae1d, $9b64c2b0, $ec63f226, $756aa39c, $026d930a,
  $9c0906a9, $eb0e363f, $72076785, $05005713, $95bf4a82, $e2b87a14, $7bb12bae,
  $0cb61b38, $92d28e9b, $e5d5be0d, $7cdcefb7, $0bdbdf21, $86d3d2d4, $f1d4e242,
  $68ddb3f8, $1fda836e, $81be16cd, $f6b9265b, $6fb077e1, $18b74777, $88085ae6,
  $ff0f6a70, $66063bca, $11010b5c, $8f659eff, $f862ae69, $616bffd3, $166ccf45,
  $a00ae278, $d70dd2ee, $4e048354, $3903b3c2, $a7672661, $d06016f7, $4969474d,
  $3e6e77db, $aed16a4a, $d9d65adc, $40df0b66, $37d83bf0, $a9bcae53, $debb9ec5,
  $47b2cf7f, $30b5ffe9, $bdbdf21c, $cabac28a, $53b39330, $24b4a3a6, $bad03605,
  $cdd70693, $54de5729, $23d967bf, $b3667a2e, $c4614ab8, $5d681b02, $2a6f2b94,
  $b40bbe37, $c30c8ea1, $5a05df1b, $2d02ef8d
  );

var
  Crc32TableOfs : Cardinal;

  function apUpdateCrc32(CurByte : Byte; CurCrc : LongInt) : LongInt;
    {-Returns an updated crc32}

  {$IFNDEF Win32}
  { Model for inline code below
      UpdateCrc32 := Crc32Table[Byte(CurCrc xor LongInt(CurByte))] xor
                     ((CurCrc shr 8) and $00FFFFFF);
  }
  Inline(
                           {;Get args -- DX:BX = CurCrc, CX = CurByte;}
    $5B/                   {        POP     BX}
    $5A/                   {        POP     DX}
    $59/                   {        POP     CX}
    $52/                   {        PUSH    DX}
    $53/                   {        PUSH    BX      ;Save original CurCrc}
                           {;CX:AX := Get Crc32Table[CurCrc xor CurByte];}
    $31/$CB/               {        XOR     BX,CX   ;DX:BX = CurCrc xor CurByte}
    $30/$FF/               {        XOR     BH,BH   ;Byte(DX:BX)}
    $D1/$E3/               {        SHL     BX,1    ;LongInt index}
    $D1/$E3/               {        SHL     BX,1}
    $03/$1E/>CRC32TABLEOFS/{        ADD     BX,[>Crc32TableOfs]}
    $8B/$07/               {        MOV     AX,[BX]}
    $8B/$4F/$02/           {        MOV     CX,[BX+2]}
                           {;DX:BX := (CurCrc shr 8) and $00FFFFFF;}
    $5B/                   {        POP     BX      ;Get original CurCrc}
    $5A/                   {        POP     DX}
    $51/                   {        PUSH    CX      ;Save CX}
    $B9/$08/$00/           {        MOV     CX,8    ;Shift 8 bits}
    $D1/$EA/               {C1:     SHR     DX,1    ;Hi reg into carry}
    $D1/$DB/               {        RCR     BX,1    ;Carry into lo reg}
    $E2/$FA/               {        LOOP    C1      ; for 8 bits}
    $81/$E2/$FF/$00/       {        AND     DX,$00FF}
                           {;DX:AX := ES:AX xor DX:BX (sets function result)}
    $59/                   {        POP     CX}
    $31/$D8/               {        XOR     AX,BX}
    $89/$CB/               {        MOV     BX,CX}
    $31/$DA);              {        XOR     DX,BX}
  {$ENDIF}

const
  CrcTable: array[0..255] of Cardinal = (
    $0000,  $1021,  $2042,  $3063,  $4084,  $50a5,  $60c6,  $70e7,
    $8108,  $9129,  $a14a,  $b16b,  $c18c,  $d1ad,  $e1ce,  $f1ef,
    $1231,  $0210,  $3273,  $2252,  $52b5,  $4294,  $72f7,  $62d6,
    $9339,  $8318,  $b37b,  $a35a,  $d3bd,  $c39c,  $f3ff,  $e3de,
    $2462,  $3443,  $0420,  $1401,  $64e6,  $74c7,  $44a4,  $5485,
    $a56a,  $b54b,  $8528,  $9509,  $e5ee,  $f5cf,  $c5ac,  $d58d,
    $3653,  $2672,  $1611,  $0630,  $76d7,  $66f6,  $5695,  $46b4,
    $b75b,  $a77a,  $9719,  $8738,  $f7df,  $e7fe,  $d79d,  $c7bc,
    $48c4,  $58e5,  $6886,  $78a7,  $0840,  $1861,  $2802,  $3823,
    $c9cc,  $d9ed,  $e98e,  $f9af,  $8948,  $9969,  $a90a,  $b92b,
    $5af5,  $4ad4,  $7ab7,  $6a96,  $1a71,  $0a50,  $3a33,  $2a12,
    $dbfd,  $cbdc,  $fbbf,  $eb9e,  $9b79,  $8b58,  $bb3b,  $ab1a,
    $6ca6,  $7c87,  $4ce4,  $5cc5,  $2c22,  $3c03,  $0c60,  $1c41,
    $edae,  $fd8f,  $cdec,  $ddcd,  $ad2a,  $bd0b,  $8d68,  $9d49,
    $7e97,  $6eb6,  $5ed5,  $4ef4,  $3e13,  $2e32,  $1e51,  $0e70,
    $ff9f,  $efbe,  $dfdd,  $cffc,  $bf1b,  $af3a,  $9f59,  $8f78,
    $9188,  $81a9,  $b1ca,  $a1eb,  $d10c,  $c12d,  $f14e,  $e16f,
    $1080,  $00a1,  $30c2,  $20e3,  $5004,  $4025,  $7046,  $6067,
    $83b9,  $9398,  $a3fb,  $b3da,  $c33d,  $d31c,  $e37f,  $f35e,
    $02b1,  $1290,  $22f3,  $32d2,  $4235,  $5214,  $6277,  $7256,
    $b5ea,  $a5cb,  $95a8,  $8589,  $f56e,  $e54f,  $d52c,  $c50d,
    $34e2,  $24c3,  $14a0,  $0481,  $7466,  $6447,  $5424,  $4405,
    $a7db,  $b7fa,  $8799,  $97b8,  $e75f,  $f77e,  $c71d,  $d73c,
    $26d3,  $36f2,  $0691,  $16b0,  $6657,  $7676,  $4615,  $5634,
    $d94c,  $c96d,  $f90e,  $e92f,  $99c8,  $89e9,  $b98a,  $a9ab,
    $5844,  $4865,  $7806,  $6827,  $18c0,  $08e1,  $3882,  $28a3,
    $cb7d,  $db5c,  $eb3f,  $fb1e,  $8bf9,  $9bd8,  $abbb,  $bb9a,
    $4a75,  $5a54,  $6a37,  $7a16,  $0af1,  $1ad0,  $2ab3,  $3a92,
    $fd2e,  $ed0f,  $dd6c,  $cd4d,  $bdaa,  $ad8b,  $9de8,  $8dc9,
    $7c26,  $6c07,  $5c64,  $4c45,  $3ca2,  $2c83,  $1ce0,  $0cc1,
    $ef1f,  $ff3e,  $cf5d,  $df7c,  $af9b,  $bfba,  $8fd9,  $9ff8,
    $6e17,  $7e36,  $4e55,  $5e74,  $2e93,  $3eb2,  $0ed1,  $1ef0
  );

implementation

const
  Separator = ';';
  EndOfListMark = #0;

  function apInitProtocolData(var P : PProtocolData;
                              H : TApdCustomComPort;                  
                              Options : Cardinal) : Integer;
    {-Allocates and initializes a protocol control block with options}
  var
    Parity   : Word;
    Baud     : LongInt;
    DataBits : TDataBits;
    StopBits : TStopBits;
  begin
    {Allocate TProtocolData}
    P := AllocMem(SizeOf(TProtocolData));

    {Initialize the protocol fields}
    with P^ do begin
      {$IFDEF Win32}
      {Make a critical section object}
      InitializeCriticalSection(aProtSection);
      {$ENDIF}

      {Init values other than zero}
      aHC := H;
      aUpcaseFileNames := True;
      aCurProtocol := NoProtocol;
      aHandshakeWait := awpDefHandshakeWait;
      aHandshakeRetry := awpDefHandshakeRetry;
      aBlockLen := 128;
      aWriteFailOpt := wfcWriteRename;
      aTransTimeout := awpDefTransTimeout;
      aStatusInterval := awpDefAbsStatusInterval;
      aFlags := Options;
      if (H <> nil) and (H.Open) then begin
        H.Dispatcher.GetLine(Baud, Parity, DataBits, StopBits);
        aActCPS := Baud div 10;
      end else
        aActCPS := 0;
      StrPCopy(aSearchMask, '*.*');

      {Assign file handling methods}
      apResetReadWriteHooks(P);

      {Assign default hooks}
      apShowStatus := apMsgStatus;
      apLogFile := apMsgLog;
      apAcceptFile := apMsgAcceptFile;
      apNextFile := apMsgNextFile;
    end;
    apInitProtocolData := ecOk;
  end;

  procedure apDoneProtocol(P : PProtocolData);
    {-Destroys a protocol}
  begin
    {$IFDEF Win32}
    {Free the critical section}
    DeleteCriticalSection(P^.aProtSection);
    {$ENDIF}

    FreeMem(P, SizeOf(TProtocolData));
  end;

  procedure apResetReadWriteHooks(P : PProtocolData);
    {-Reset read/write hooks to the defaults}
  begin
    with P^ do begin
      {Assign file handling methods}
      apPrepareReading := aapPrepareReading;
      apReadProtocolBlock := aapReadProtocolBlock;
      apFinishReading := aapFinishReading;
      apPrepareWriting := aapPrepareWriting;
      apWriteProtocolBlock := aapWriteProtocolBlock;
      apFinishWriting := aapFinishWriting;
    end;
  end;

  procedure apSetProtocolWindow(P : PProtocolData; HW : TApdHwnd);
    {-Set HW as the protocol window handle}
  begin
    P^.aHWindow := HW;
  end;

  procedure apSetFileList(P : PProtocolData; FL : PFileList);
    {-Set FL as the file list}
  begin
    P^.aFileList := FL;
  end;

  function apMakeFileList(P : PProtocolData;
                          var FL : PFileList; Size : Cardinal) : Integer;
    {-Allocates a new file list of Size bytes}
  type
    PWord = ^Cardinal;
  begin
    FL := AllocMem(Size);
    PWord(FL)^ := Size;
    apMakeFileList := ecOk;
  end;

  procedure apDisposeFileList(P : PProtocolData;
                              FL : PFileList; Size : Cardinal);
    {-Disposes of file list FL}
  type
    PWord = ^Cardinal;
  begin
    FreeMem(FL, PWord(FL)^);
  end;

  function apAddFileToList(P : PProtocolData;
                           FL : PFileList; PName : PChar) : Integer;
    {-Adds pathname PName to file list FL}
  type
    PWord = ^Cardinal;
  var
    MaxList : Cardinal;
    NewP    : PChar;
  begin
    with P^ do begin
      {First Cardinal of list is size}
      MaxList := PWord(FL)^;
      if MaxList <= 3 then begin
        apAddFileToList := ecBadArgument;
        Exit;
      end;

      {Search for the current end of the list}
      NewP := Pointer(FL);
      Inc(NewP, 2);
      NewP := StrScan(NewP, EndOfListMark);
      if NewP = nil then begin
        apAddFileToList := ecBadFileList;
        Exit;
      end;

      {Enough room?}
      if StrLen(PName)+1 > MaxList then begin
        apAddFileToList := ecOutOfMemory;
        Exit;
      end;

      {Add separator if not the first item in the list}
      if (NewP-2) <> Pointer(FL) then begin
        NewP[0] := ';';
        Inc(NewP);
      end;

      {Add the string}
      StrCopy(NewP, PName);
      apAddFileToList := ecOK;
    end;
  end;

  function apNextFileMask(P : PProtocolData; FName : PChar) : Bool;
    {-Built-in function that works with file mask fields}
  const
    AnyFileButDir = faAnyFile and not (faDirectory or faVolumeID);
  var
    DosError : Integer;
    PName    : array[0..255] of Char;
  begin
    with P^ do begin
      {Check for uninitialized search mask}
      if aSearchMask[0] = #0 then begin
        apProtocolError(P, ecNoSearchMask);
        apNextFileMask := False;
        Exit;
      end;

      {Search for a matching file}
      if aFindingFirst then begin
        DosError :=
          Abs(FindFirst(aSearchMask, AnyFileButDir, aCurRec));
        aFFOpen := True;
        {$IFDEF WIN32}
        if DosError <> 0 then
          aCurRec.FindHandle := INVALID_HANDLE_VALUE;
        {$ENDIF}                                                     
        if DosError = 18 then begin
          apProtocolError(P, ecNoMatchingFiles);
          FName[0] := #0;
          apNextFileMask := False;
          FindClose(aCurRec);
          aFFOpen := False;
          Exit;
        end else
          aFindingFirst := False;
      end else
        DosError := Abs(FindNext(aCurRec));

      {Check for errors}
      if DosError <> 0 then begin
        {Failed to find file, return error status}
        if DosError = 3 then
          apProtocolError(P, ecDirNotFound)
        else if DosError <> 18 then
          apProtocolError(P, -DosError);
        FName[0] := #0;
        apNextFileMask := False;
        FindClose(aCurRec);
        aFFOpen := False;
      end else begin
        {If search mask contains a path, return that path}
        JustPathNameZ(FName, aSearchMask);
        if FName[0] <> #0 then begin
          AddBackSlashZ(FName, FName);
          StrPCopy(PName, aCurRec.Name);
          StrCat(FName, PName);
        end else begin
          StrPCopy(PName, aCurRec.Name);
          StrCopy(FName, PName);
        end;
        apNextFileMask := True;
      end;
    end;
  end;

  function apNextFileList(P : PProtocolData; FName : PChar) : Bool;
    {-Built-in function that works with a list of files}
  type
    PWord = ^Cardinal;
  const
    MaxLen = 79;
  var
    MaxSize : Cardinal;
    MaxNext : Cardinal;
    I       : Cardinal;
    Len     : Cardinal;
  begin
    with P^ do begin
      aProtocolError := ecOK;
      MaxSize := PWord(aFileList)^;
      if MaxSize <= 3 then begin
        apNextFileList := False;
        FName[0] := #0;
        Exit;
      end;

      {Return immediately if no more files}
      if aFileList^[aFileListIndex] = EndOfListMark then begin
        apNextFileList := False;
        FName[0] := #0;
        Exit;
      end;

      {Increment past the last separator}
      if aFileListIndex <> 2 then
        Inc(aFileListIndex);

      {Define how far to look for the next marker}
      if LongInt(aFileListIndex) + MaxLen > Integer(MaxSize) then    
        MaxNext := MaxSize
      else
        MaxNext := aFileListIndex + MaxLen;

      {Look for the next marker}
      for I := aFileListIndex to MaxNext do begin
        if (aFileList^[I] = Separator) or
           (aFileList^[I] = EndOfListMark) then begin
          {Extract the pathname}
          Len := I - aFileListIndex;
          Move(aFileList^[aFileListIndex], FName[0], Len);
          FName[Len] := #0;
          apNextFileList := True;
          Inc(aFileListIndex, Len);
          Exit;
        end;
      end;

      {Bad format list (no separator) -- show error}
      apProtocolError(P, ecBadFileList);
      apNextFileList := False;
      FName[0] := #0;
    end;
  end;

  function apGetBytesTransferred(P : PProtocolData) : LongInt;
    {-Returns bytes already transferred}
  var
    TotalOverhead : Cardinal;
    OutBuff       : Cardinal;
    BT            : LongInt;
  begin
    with P^ do begin
      if aHC = nil then begin
        Result := 0;
        exit;
      end else
        OutBuff := aHC.OutBuffUsed;
      if OutBuff >= aBlockLen then begin
        {Upload in progress, subtract outbuff from bytestransferred}
        if aBlockLen <> 0 then
          TotalOverhead := aOverhead * (OutBuff div aBlockLen)
        else
          TotalOverhead := 0;
        BT := DWORD(aBytesTransferred) - (OutBuff - TotalOverhead);  
        if BT > 0 then
          apGetBytesTransferred := BT
        else
          apGetBytesTransferred := 0;
      end else
        apGetBytesTransferred := aBytesTransferred;
    end;
  end;

  function apGetBytesRemaining(P : PProtocolData) : LongInt;
    {-Return bytes not yet transferred}
  var
    BR : Longint;
  begin
    with P^ do begin
      BR := aSrcFileLen - apGetBytesTransferred(P);
      if BR < 0 then
        BR := 0;
      apGetBytesRemaining := BR;
    end;
  end;

  function apSupportsBatch(P : PProtocolData) : Bool;
    {-Returns True if this protocol supports batch file transfers}
  begin
    apSupportsBatch := P^.aBatchProtocol;
  end;

  function apGetInitialFilePos(P : PProtocolData) : LongInt;
    {-Returns the file position at the start of resumed file transfer}
  begin
    apGetInitialFilePos := P^.aInitFilePos;
  end;

  function apEstimateTransferSecs(P : PProtocolData; Size : LongInt) : LongInt;
    {-Return estimated seconds to transfer Size bytes}
  var
    Efficiency   : LongInt;
    EffectiveCPS : LongInt;
  begin
    with P^ do begin
      if Size = 0 then
        apEstimateTransferSecs := 0
      else begin
        {Calculate efficiency of this protocol}
        Efficiency := (Integer(aBlockLen) * LongInt(100)) div
                      Longint(aBlockLen + aOverHead +
                      (DWORD(aTurnDelay * aActCPS) div 1000));
        EffectiveCPS := (aActCPS * DWORD(Efficiency)) div 100;       

        {Calculate remaining seconds}
        if EffectiveCPS > 0 then
          apEstimateTransferSecs := Size div EffectiveCPS
        else
          apEstimateTransferSecs := 0;
      end;
    end;
  end;

  procedure apGetProtocolInfo(P : PProtocolData; var Info : TProtocolInfo);
    {-Returns a protocol information block}
  begin
    with P^, Info do begin
      piStatus           := aProtocolStatus;
      piError            := aProtocolError;
      piProtocolType     := aCurProtocol;
      StrLCopy(piFileName, aPathName, SizeOf(piFileName));
      piFileSize         := aSrcFileLen;
      piBytesTransferred := apGetBytesTransferred(P);
      piBytesRemaining   := apGetBytesRemaining(P);
      piInitFilePos      := aInitFilePos;
      piElapsedTicks     := aElapsedTicks;
      piBlockErrors      := aBlockErrors;
      piTotalErrors      := aTotalErrors;
      piBlockSize        := aBlockLen;
      if aBlockLen <> 0 then
        piBlockNum := piBytesTransferred div Integer(aBlockLen)
      else
        piBlockNum := 0;
      piBlockCheck       := aCheckType;
      piFlags            := aFlags;
    end;
  end;

  procedure apSetFileMask(P : PProtocolData; NewMask : PChar);
    {-Set the search mask}
  begin
    StrLCopy(P^.aSearchMask, NewMask, SizeOf(P^.aSearchMask));
  end;

  procedure apSetReceiveFilename(P : PProtocolData; FName : PChar);
    {-Set or change the incoming file name}
  var
    Temp : TCharArray;
  begin
    with P^ do begin
      if StrScan(FName, '\') = nil then begin
        {Set aPathname to DestDir path + FName}
        StrLCopy(aPathname, AddBackSlashZ(Temp, aDestDir), SizeOf(aPathname));
        StrLCat(aPathname, FName, SizeOf(aPathname));
      end else
        {Set aPathname directly to FName}
        StrLCopy(aPathName, FName, SizeOf(aPathname));
    end;
  end;

  procedure apSetDestinationDirectory(P : PProtocolData; Dir : PChar);
    {-Set the directory used to hold received files}
  begin
    StrLCopy(P^.aDestDir, Dir, SizeOf(P^.aDestDir));
  end;

  procedure apSetHandshakeWait(P : PProtocolData; NewHandshake, NewRetry : Cardinal);
    {-Set the wait Ticks and retry count for the initial handshake}
  begin
    with P^ do begin
      if NewHandshake <> 0 then
        aHandshakeWait := NewHandshake;
      if NewRetry <> 0 then
        aHandshakeRetry := NewRetry;
    end;
  end;

  procedure apSetEfficiencyParms(P : PProtocolData;
                                 BlockOverhead, TurnAroundDelay : Cardinal);
    {-Sets efficiency parameters for EstimateTransferSecs}
  begin
    with P^ do begin
      aOverhead := BlockOverhead;
      aTurnDelay := TurnAroundDelay;
    end;
  end;

  procedure apSetProtocolPort(P : PProtocolData; H : TApdCustomComPort);
    {-Set H as the port object for this protocol}
  begin
    P^.aHC := H;
  end;

  procedure apSetOverwriteOption(P : PProtocolData; Opt : Cardinal);
    {-Set option for what to do when the destination file already exists}
  begin
    if Opt <= wfcWriteResume then
      P^.aWriteFailOpt := Opt;
  end;

  procedure apSetActualBPS(P : PProtocolData; BPS : LongInt);
    {-Sets actual BPS rate (only needed if modem differs from port)}
  var
    Baud     : LongInt;
    Parity   : Word;
    Bits     : Word;
    Databits : TDatabits;
    Stopbits : TStopbits;
  begin
    if (P^.aHC = nil) or not P^.aHC.Open then
      Bits := 10
    else begin
      P^.aHC.Dispatcher.GetLine(Baud, Parity, Databits, Stopbits);
      Bits := Databits + 2;
    end;                                                             
    if Parity <> NoParity then
      Inc(Bits);
    P^.aActCPS := BPS div Bits;
  end;

  procedure apSetStatusInterval(P : PProtocolData; NewInterval : Cardinal);
    {-Set new status update interval to NewInterval ticks}
  begin
    P^.aStatusInterval := NewInterval;
  end;

  procedure apOptionsOn(P : PProtocolData; OptionFlags : Cardinal);
    {-Activate multiple options}
  begin
    with P^ do
      aFlags := aFlags or (OptionFlags and not BadProtocolOptions);
  end;

  procedure apOptionsOff(P : PProtocolData; OptionFlags : Cardinal);
    {-Deactivate multiple options}
  begin
    with P^ do
      aFlags := aFlags and not (OptionFlags and not BadProtocolOptions);
  end;

  function apOptionsAreOn(P : PProtocolData; OptionFlags : Cardinal) : Bool;
    {-Return True if all bits in OptionsFlags are on}
  begin
    with P^ do
      apOptionsAreOn := aFlags and OptionFlags = OptionFlags;
  end;

  procedure apStartProtocol(P : PProtocolData;
                            Protocol : Byte;
                            Transmit : Bool;
                            StartProc : TPrepareProc;
                            ProtFunc : TProtocolFunc);
    {-Setup standard protocol triggers}
  var
    lParam : LongInt;
  begin
    with P^ do begin
      {Note the protocol}
      aCurProtocol := Protocol;
      aCurProtFunc := ProtFunc;

      {Next file stuff}
      aFilesSent := False;
      aFindingFirst := True;
      aFileListIndex := 2;

      if not aHC.Open then begin                                       
        aProtocolError := ecNotOpen;                                   
        apSignalFinish (P);                                            
        Exit;                                                          
      end;                                                             
      
      {Set up standard triggers}
      aHC.Dispatcher.ChangeLengthTrigger(1);                         
      aTimeoutTrigger := aHC.AddTimerTrigger;
      aStatusTrigger := aHC.AddTimerTrigger;
      aOutBuffFreeTrigger := aHC.AddStatusTrigger(stOutBuffFree);
      aOutBuffUsedTrigger := aHC.AddStatusTrigger(stOutBuffUsed);
      aNoCarrierTrigger := aHC.AddStatusTrigger(stModem);

      {All set?}
      if (aTimeoutTrigger < 0) or
         (aStatusTrigger < 0) or (aOutBuffFreeTrigger < 0) or
         (aOutBuffUsedTrigger < 0) or (aNoCarrierTrigger < 0) then begin
        {Send error message and give up}
        aProtocolError := ecNoMoreTriggers;
        apSignalFinish(P);
        Exit;
      end;

      with aHC.Dispatcher do begin

        {Store protocol pointer}
        SetDataPointer(Pointer(P), 1);

        {Prepare protocol}
        StartProc(P);
        if aProtocolError = ecOK then begin
          {Call the notification function directly the first time}
          LH(lParam).H := Handle;
          LH(lParam).L := 0;
          ProtFunc(0, 0, lParam);

          if aProtocolError <> ecOk then exit;                      

          {Activate status timer now}
          aHC.SetTimerTrigger(aStatusTrigger, aStatusInterval, True);

          {Set DCD trigger if necessary}
          if FlagIsSet(aFlags, apAbortNoCarrier) then begin
            if CheckDCD then
              {Set modem status trigger to look for carrier loss}
              SetStatusTrigger(aNoCarrierTrigger, msDCDDelta, True)
            else begin
              {Carrier not present now, abort}
              aProtocolError := ecAbortNoCarrier;
              apSignalFinish(P);
              Exit;
            end;
          end;

          {Register the protocol notification procedure}
          RegisterProcTriggerHandler(ProtFunc);
        end else
          {Couldn't get started, finish now}
          apSignalFinish(P);
      end;
    end;
  end;

  procedure apStopProtocol(P : PProtocolData);
    {-Stop the protocol}

    procedure RemoveIt(Trig : Integer);
    begin
      if Trig > 0 then
        P^.aHC.RemoveTrigger(Trig);
    end;

  begin
    with P^ do begin
      {Remove the protocol triggers}
      if aTimeoutTrigger <> 0 then
        RemoveIt(aTimeoutTrigger);
      aTimeoutTrigger := 0;
      if aStatusTrigger <> 0 then
        RemoveIt(aStatusTrigger);
      aStatusTrigger := 0;
      if aOutBuffFreeTrigger <> 0 then
        RemoveIt(aOutBuffFreeTrigger);
      aOutBuffFreeTrigger := 0;
      if aOutBuffUsedTrigger <> 0 then
        RemoveIt(aOutBuffUsedTrigger);
      aOutBuffUsedTrigger := 0;
      if aNoCarrierTrigger <> 0 then
        RemoveIt(aNoCarrierTrigger);
      aNoCarrierTrigger := 0;                                         

      {Remove our trigger handler}
      if (aHC <> nil) and aHC.Open then
        aHC.Dispatcher.DeregisterProcTriggerHandler(aCurProtFunc);

      {Close findfirst, if it's still open}
      if aFFOpen then begin
        aFFOpen := False;
        FindClose(aCurRec);
      end;
      {Close the file, if it's still open}
      if aFileOpen then begin
        Close(aWorkFile);
        aFileOpen := False;
      end;                                                           
    end;
  end;

{Internal routines}

  procedure apResetStatus(P : PProtocolData);
    {-Reset status vars}
  begin
    with P^ do begin
      if aInProgress = 0 then begin
        aSrcFileLen := 0;
        aBytesRemaining := 0;
      end;
      aBytesTransferred := 0;
      aBlockNum := 0;
      aElapsedTicks := 0;
      aBlockErrors := 0;
      aTotalErrors := 0;
      aProtocolStatus := psOK;
      aProtocolError := ecOK;
    end;
  end;

  procedure apShowFirstStatus(P : PProtocolData);
    {-Show (possible) first status}
  const
    Option : array[Boolean] of Cardinal = ($00, $01);
  begin
    with P^ do begin
      apShowStatus(P, Option[aInProgress=0]);
      Inc(aInProgress);
    end;
  end;

  procedure apShowLastStatus(P : PProtocolData);
    {-Reset field and show last status}
  const
    Option : array[Boolean] of Cardinal = ($00, $02);                
  begin
    with P^ do begin
      if aInProgress <> 0 then begin
        Dec(aInProgress);
        apShowStatus(P, Option[aInProgress=0]);
      end;
    end;
  end;

  procedure apSignalFinish(P : PProtocolData);
    {-Send finish message to parent window}
  var
    DT: TDispatchType;
    ErrMsg: String;
  begin
    with P^ do begin
      apStopProtocol(P);

      {Flag some final status codes as error codes}
      if aProtocolError = ecOk then begin
        case aProtocolStatus of
          psCancelRequested : aProtocolError := ecCancelRequested;
          psTimeout         : aProtocolError := ecTimeout;
          psProtocolError   : aProtocolError := ecProtocolError;
          psSequenceError   : aProtocolError := ecSequenceError;
          psFileRejected    : aProtocolError := ecFileRejected;
          psCantWriteFile   : aProtocolError := ecCantWriteFile;
          psAbortNoCarrier  : aProtocolError := ecAbortNoCarrier;
          psAbort           : aProtocolError := ecProtocolAbort;       
        end;
      end;
      case aCurProtocol of
        Xmodem,
        XmodemCRC,
        Xmodem1K,
        Xmodem1KG   : DT := dtXModem;
        Ymodem,
        YmodemG     : DT := dtYModem;
        Zmodem      : DT := dtZModem;
        Kermit      : DT := dtKermit;
        Ascii       : DT := dtAscii;
        BPlus       : DT := dtBPlus;
        else          DT := dtNone;
      end;
      ErrMsg := 'ErrorCode:' + IntToStr(aProtocolError);
      aHC.ValidDispatcher.AddDispatchEntry(DT, dstStatus, 0,
        @ErrMsg[1], Length(ErrMsg));                                   
      PostMessage(aHWindow, apw_ProtocolFinish,
                  Cardinal(aProtocolError), Longint(P));
    end;
  end;

  procedure aapPrepareReading(P : PProtocolData);
    {-Prepare to send protocol blocks (usually opens a file)}
  var
    Res : Cardinal;
  begin
    with P^ do begin
      aProtocolError := ecOK;

      {If file is already open then leave without doing anything}
      if aFileOpen then
        Exit;

      {Report notfound error for empty filename}
      if aPathName[0] = #0 then begin
        apProtocolError(P, ecFileNotFound);
        Exit;
      end;

      {Allocate a file buffer}
      aFileBuffer := AllocMem(FileBufferSize);

      {Open up the previously specified file}
      aSaveMode := FileMode;
      FileMode := fmOpenRead or fmShareDenyWrite;                      
      Assign(aWorkFile, aPathName);
      Reset(aWorkFile, 1);
      FileMode := aSaveMode;
      Res := IOResult;
      if Res <> 0 then begin
        apProtocolError(P, -Res);
        FreeMem(aFileBuffer, FileBufferSize);
        Exit;
      end;

      {Show file name and size}
      aSrcFileLen := FileSize(aWorkFile);
      if IOResult <> 0 then
        aSrcFileLen := 0;
      aBytesRemaining := aSrcFileLen;
      apShowStatus(P, 0);

      {Note file date/time stamp (for those protocols that care)}
      aSrcFileDate := FileGetDate(TFileRec(aWorkFile).Handle);

      {Initialize the file buffering variables}
      aFileOfs := 0;
      aStartOfs := 0;
      aEndOfs := 0;
      aLastOfs := 0;
      aEndPending := False;
      aFileOpen := True;
    end;
  end;

  procedure aapFinishReading(P : PProtocolData);
    {-Clean up after reading protocol blocks}
  begin
    with P^ do begin
      if aFileOpen then begin
        Close(aWorkFile);
        if IOResult <> 0 then ;
        FreeMem(aFileBuffer, FileBufferSize);
        aFileOpen := False;
      end;
    end;
  end;

  function aapReadProtocolBlock(P : PProtocolData;
                                var Block : TDataBlock;
                                var BlockSize : Cardinal) : Bool;
    {-Return with a block to transmit (True to quit)}
  var
    BytesRead   : Integer;
    BytesToMove : Integer;
    BytesToRead : Integer;
    Res         : Cardinal;
  begin
    with P^ do begin
      if aFileOfs >= aSrcFileLen then begin
        BlockSize := 0;
        aapReadProtocolBlock := True;
        Exit;
      end;

      {Check for a request to start further along in the file (recovering)}
      if aFileOfs > aEndOfs then
        {Skipping blocks - force a read}
        aEndOfs := aFileOfs;

      {Check for a request to retransmit an old block}
      if aFileOfs < aLastOfs then
        {Retransmit - reset end-of-buffer to force a read}
        aEndOfs := aFileOfs;

      if (aFileOfs + Integer(BlockSize)) > aEndOfs then begin          
        {Buffer needs to be updated, first shift end section to beginning}
        BytesToMove := aEndOfs - aFileOfs;
        if BytesToMove > 0 then
          Move(aFileBuffer^[aFileOfs - aStartOfs], aFileBuffer^, BytesToMove);

        {Fill end section from file}
        BytesToRead := FileBufferSize - BytesToMove;
        Seek(aWorkFile, aEndOfs);
        BlockRead(aWorkFile, aFileBuffer^[BytesToMove], BytesToRead, BytesRead);
        Res := IOResult;
        if (Res <> 0) then begin
          {Exit on error}
          apProtocolError(P, -Res);
          aapReadProtocolBlock := True;
          BlockSize := 0;
          Exit;
        end else begin
          {Set buffering variables}
          aStartOfs := aFileOfs;
          aEndOfs := aFileOfs + FileBufferSize;
        end;

        {Prepare for the end of the file}
        if BytesRead < BytesToRead then begin
          aEndOfDataOfs := BytesToMove + BytesRead;
          FillChar(aFileBuffer^[aEndofDataOfs], FileBufferSize - aEndOfDataOfs,
                   BlockFillChar);
          Inc(aEndOfDataOfs, aStartOfs);
          aEndPending := True;
        end else
          aEndPending := False;
      end;

      {Return the requested block}
      Move(aFileBuffer^[(aFileOfs - aStartOfs)], Block, BlockSize);
      aapReadProtocolBlock := False;
      aLastOfs := aFileOfs;

      {If it's the last block then say so}
      if aEndPending and ((aFileOfs + Integer(BlockSize)) >= aEndOfDataOfs) then begin  
        aapReadProtocolBlock := True;
        BlockSize := aEndOfDataOfs - aFileOfs;
      end;
    end;
  end;

  procedure aapPrepareWriting(P : PProtocolData);
    {-Prepare to save protocol blocks (usually opens a file)}
  var
    Res  : Cardinal;
    S    : string[fsPathName];
    Dir  : string[fsDirectory];
    Name : string[fsName];
  label
    ExitPoint;
  begin
    with P^ do begin
      {Allocate a file buffer}
      aFileBuffer := AllocMem(FileBufferSize);

      {Does the file exist already?}
      aSaveMode := FileMode;
      FileMode := 0;
      Assign(aWorkFile, aPathName);
      Reset(aWorkFile, 1);
      FileMode := aSaveMode;
      Res := IOResult;

      {Exit on errors other than FileNotFound}
      if (Res <> 0) and (Res <> 2) then begin
        apProtocolError(P, -Res);
        goto ExitPoint;
      end;

      {Exit if file exists and option is WriteFail}
      if (Res = 0) and (aWriteFailOpt = wfcWriteFail) then begin
        aProtocolStatus := psCantWriteFile;
        aForceStatus := True;
        goto ExitPoint;
      end;

      Close(aWorkFile);
      if IOResult = 0 then ;

      {Change the file name if it already exists and the option is WriteRename}
      if (Res = 0) and (aWriteFailOpt = wfcWriteRename) then begin
        S := StrPas(aPathName);
        Dir := ExtractFilePath(S);
        Name := ExtractFileName(S);
        Name[1] := '$';
        S := Dir + Name;
        StrPCopy(aPathName, S);
      end;

      {Give status a chance to show that the file was renamed}
      apShowStatus(P, 0);

      {Ok to rewrite file now}
      Assign(aWorkFile, aPathname);
      Rewrite(aWorkFile, 1);
      Res := IOResult;
      if Res <> 0 then begin
        apProtocolError(P, -Res);
        goto ExitPoint;
      end;

      {Initialized the buffer management vars}
      aStartOfs := 0;
      aLastOfs := 0;
      aEndOfs := aStartOfs + FileBufferSize;
      aFileOpen := True;
      Exit;

ExitPoint:
      Close(aWorkFile);
      if IOResult <> 0 then ;
      FreeMem(aFileBuffer, FileBufferSize);
    end;
  end;

  procedure aapFinishWriting(P : PProtocolData);
    {-Cleans up after saving all protocol blocks}
  var
    Res          : Cardinal;
    BytesToWrite : Integer;
    BytesWritten : Integer;
  begin
    with P^ do begin
      if aFileOpen then begin
        {Error or end-of-protocol, commit buffer and cleanup}
        BytesToWrite := aFileOfs - aStartOfs;
        BlockWrite(aWorkFile, aFileBuffer^, BytesToWrite, BytesWritten);
        Res := IOResult;
        if Res <> 0 then
          apProtocolError(P, -Res)
        else if BytesToWrite <> BytesWritten then
          apProtocolError(P, ecDiskFull);

        {Get file size and time for those protocols that don't know}
        aSrcFileLen := FileSize(aWorkFile);
        aSrcFileDate := FileGetDate(TFileRec(aWorkFile).Handle);

        Close(aWorkFile);
        Res := IOResult;
        if Res <> 0 then
          apProtocolError(P, -Res);
        FreeMem(aFileBuffer, FileBufferSize);
        aFileOpen := False;
      end;
    end;
  end;

  function aapWriteProtocolBlock(P : PProtocolData;
                                 var Block : TDataBlock;
                                 BlockSize : Cardinal) : Bool;
    {-Write a protocol block (return True to quit)}
  var
    Res          : Cardinal;
    BytesToWrite : Integer;
    BytesWritten : Integer;

    procedure BlockWriteRTS;
      {-Set RTS before BlockWrite}
    begin
      with P^ do begin
        {Lower RTS if requested}
        if FlagIsSet(aFlags, apRTSLowForWrite) then
          if (aHC <> nil) and aHC.Open then
            aHC.Dispatcher.SetRTS(False);

        BlockWrite(aWorkFile, aFileBuffer^, BytesToWrite, BytesWritten);

        {Raise RTS if it was lowered}
        if FlagIsSet(aFlags, apRTSLowForWrite) then
          if (aHC <> nil) and aHC.Open then
            aHC.Dispatcher.SetRTS(True);
      end;
    end;

  begin
    with P^ do begin
      aProtocolError := ecOK;
      aapWriteProtocolBlock := True;

      if not aFileOpen then begin
        apProtocolError(P, ecNotOpen);
        Exit;
      end;

      if aFileOfs < aLastOfs then
        {This is a retransmitted block}
        if aFileOfs > aStartOfs then begin
          {aFileBuffer has some good data, commit that data now}
          Seek(aWorkFile, aStartOfs);
          BytesToWrite := aFileOfs - aStartOfs;
          BlockWriteRTS;
          Res := IOResult;
          if (Res <> 0) then begin
            apProtocolError(P, -Res);
            Exit;
          end;
          if (BytesToWrite <> BytesWritten) then begin
            apProtocolError(P, ecDiskFull);
            Exit;
          end;
        end else begin
          {Block is before data in buffer, discard data in buffer}
          aStartOfs := aFileOfs;
          aEndOfs := aStartOfs + FileBufferSize;
          {Position file just past last good data}
          Seek(aWorkFile, aFileOfs);
          Res := IOResult;
          if Res <> 0 then begin
            apProtocolError(P, -Res);
            Exit;
          end;
        end;

      {Will this block fit in the buffer?}
      if (aFileOfs + Integer(BlockSize)) > aEndOfs then begin
        {Block won't fit, commit current buffer to disk}
        BytesToWrite := aFileOfs - aStartOfs;
        BlockWriteRTS;
        Res := IOResult;
        if (Res <> 0) then begin
          apProtocolError(P, -Res);
          Exit;
        end;
        if (BytesToWrite <> BytesWritten) then begin
          apProtocolError(P, ecDiskFull);
          Exit;
        end;

        {Reset the buffer management vars}
        aStartOfs := aFileOfs;
        aEndOfs   := aStartOfs + FileBufferSize;
        aLastOfs  := aFileOfs;
      end;

      {Add this block to the buffer}
      Move(Block, aFileBuffer^[aFileOfs - aStartOfs], BlockSize);
      Inc(aLastOfs, BlockSize);
      aapWriteProtocolBlock := False;
    end;
  end;

  procedure apProtocolError(P : PProtocolData; ErrorCode : Integer);
    {-Sends message and sets aProtocolError}
  {$IFDEF WIN32}
  var
    Res : DWORD;
  {$ENDIF}
  begin
    with P^ do begin
      {$IFDEF WIN32}
      SendMessageTimeout(aHWindow, apw_ProtocolError, Cardinal(ErrorCode),
                         0, SMTO_ABORTIFHUNG + SMTO_BLOCK,
                         1000, Res);
      {$ELSE}
      SendMessage(aHWindow, apw_ProtocolError, Cardinal(ErrorCode), 0);
      {$ENDIF}
      aProtocolError := ErrorCode;
    end;
  end;

  function apTrimZeros(S: string): String;
  var
    I, J : Integer;
  begin
    I := Length(S);
    while (I > 0) and (S[I] <= ' ') do
      Dec(I);
    J := 1;
    while (J < I) and ((S[J] <= ' ') or (S[J] = '0')) do
      Inc(J);
    Result := Copy(S, J, (I-J)+1);
  end;

  function apOctalStr(L : LongInt) : String;
    {-Convert L to octal base string}
  const
    Digits : array[0..7] of Char = '01234567';
  var
    I : Cardinal;
  begin
    {$IFDEF HugeStr}
    SetLength(Result, 12);
    {$ELSE}
    apOctalStr[0] := #12;
    {$ENDIF}
    for I := 0 to 11 do begin
      apOctalStr[12-I] := Digits[L and 7];
      L := L shr 3;
    end;
  end;

  function apOctalStr2Long(S : String) : LongInt;
    {-Convert S from an octal string to a longint}
  const
    HiMag = 11;
    Magnitude : array[1..HiMag] of LongInt = (1, 8, 64, 512, 4096,
      32768, 262144, 2097152, 16777216, 134217728, 1073741824);        
  var
    Len  : Byte;
    I    : Integer;
    J    : Integer;
    Part : LongInt;
    Res  : LongInt;
  begin
    {Assume failure}
    apOctalStr2Long := 0;

    {Remove leading blanks and zeros}
    S := apTrimZeros(S);
    Len := Length(S);

    {Return 0 for invalid strings}
    if Len > HiMag then
      Exit;

    {Convert it}
    Res := 0;
    J := 1;
    for I := Len downto 1 do begin
      if (S[I] < '0') or (S[I] > '7') then
        Exit;
      Part := Byte(S[I]) - $30;
      Res := Res + Part * Magnitude[J];
      Inc(J);
    end;
    apOctalStr2Long := Res
  end;

  function apPackToYMTimeStamp(RawTime : LongInt) : LongInt;
    {-Return date/time stamp as seconds since 1/1/1970 00:00 GMT}
  var
    Days  : LongInt;
    Secs  : LongInt;
    DT    : TDateTime;
  begin
    try
      {Get file date as Delphi-style date/time}
      DT := FileDateToDateTime(RawTime);

      {Calculate number of seconds since 1/1/1970}
      Days := Trunc(DT) - UnixDaysBase;
      Secs := Round(Frac(DT) * SecsPerDay);
      Result := (Days * SecsPerDay) + Secs;
    except
      Result := 0;
    end;
  end;

  function apYMTimeStampToPack(YMTime : LongInt) : LongInt;
    {-Return a file time stamp in packed format from a Ymodem time stamp}
  var
    DT : TDateTime;
  begin
    try
      {Convert to Delphi style date, add in unix base}
      DT := YMTime / SecsPerDay;
      DT := DT + UnixDaysBase;

      {Return as packed}
      Result := DateTimeToFileDate(DT);
    except
      Result := 0
    end;
  end;

  function apCurrentTimeStamp : LongInt;
    {-Return a Ymodem format file time stamp of the current date/time}
  begin
    Result := apPackToYMTimeStamp(DateTimeToFileDate(Now));
  end;

  function apCrc32OfFile(P : PProtocolData; FName : PChar; Len : Longint) : LongInt;
    {-Returns Crc32 of FName}
  const
    BufSize = 8192;
  type
    BufArray = array[1..BufSize] of Byte;
  var
    I         : Cardinal;
    BytesRead : Integer;
    Res       : Cardinal;
    FileLoc   : LongInt;
    Buffer    : ^BufArray;
    F         : File;

  begin
    with P^ do begin
      aBlockCheck := 0;

      {If Len is zero then check the entire file}
      if Len = 0 then
        Len := MaxLongint;

      {Get a buffer}
      Buffer := AllocMem(BufSize);

      try

        {Open the file}
        aSaveMode := FileMode;
        FileMode := fmOpenRead or fmShareDenyWrite;                  
        Assign(F, FName);
        Reset(F, 1);
        FileMode := aSaveMode;
        Res := IOResult;
        if Res <> 0 then
          apProtocolError(P, -Res)
        else begin

          {Initialize Crc}
          aBlockCheck := $FFFFFFFF;

          {Start at beginning, loop thru file calculating Crc32}
          FileLoc := 0;
          repeat
            BlockRead(F , Buffer^, BufSize, BytesRead);
            Res := IOResult;
            if Res = 0 then begin
              if Len <> MaxLongint then begin
                Inc(FileLoc, BytesRead);
                if FileLoc > Len then
                  BytesRead := BytesRead - (FileLoc - Len);
              end;
              for I := 1 to BytesRead do
                aBlockCheck := apUpdateCrc32(Byte(Buffer^[I]), aBlockCheck)
            end;
          until (BytesRead = 0) or (Res <> 0) or (FileLoc >= Len);

          Close(F);
          if IOResult = 0 then ;
        end;

      finally
        apCrc32OfFile := aBlockCheck;
        FreeMem(Buffer, BufSize);
      end;
    end;
  end;

  procedure apMsgStatus(P : PProtocolData; Options : Cardinal);
    {-Send an apw_ProtocolStatus message to the protocol window}
  {$IFDEF Win32}
  var
    Res : DWORD;
  {$ENDIF}
  begin
    with P^ do
      {$IFDEF Win32}
      SendMessageTimeout(aHWindow, apw_ProtocolStatus, Options,
                         Longint(P), SMTO_ABORTIFHUNG + SMTO_BLOCK,
                         1000, Res);
      {$ELSE}
      SendMessage(aHWindow, apw_ProtocolStatus, Options, Longint(P));
      {$ENDIF}
  end;

  function apMsgNextFile(P : PProtocolData; FName : PChar) : Bool;
    {-Virtual method for calling NextFile procedure}
  {$IFDEF Win32}
  var
    Res : DWORD;
  {$ENDIF}
  begin
    with P^ do begin
      {$IFDEF Win32}
      SendMessageTimeout(aHWindow, apw_ProtocolNextFile, 0,
                         Longint(FName),
                         SMTO_ABORTIFHUNG + SMTO_BLOCK,
                         1000, Res);
      apMsgNextFile := Res <> 0;
      {$ELSE}
      apMsgNextFile :=
        SendMessage(aHWindow, apw_ProtocolNextFile, 0, LongInt(FName)) <> 0;
      {$ENDIF}
    end;
  end;

  procedure apMsgLog(P : PProtocolData; Log : Cardinal);
    {-Send an apw_ProtocolLog message to the protocol window}
  {$IFDEF Win32}
  var
    Res : DWORD;
  {$ENDIF}
  begin
    with P^ do
      {$IFDEF Win32}
      SendMessageTimeout(aHWindow, apw_ProtocolLog,
                         Cardinal(Log), Longint(P),
                         SMTO_ABORTIFHUNG + SMTO_BLOCK,
                         1000, Res);
      {$ELSE}
      SendMessage(aHWindow, apw_ProtocolLog, Cardinal(Log), LongInt(P));
      {$ENDIF}
  end;

  function apMsgAcceptFile(P : PProtocolData; FName : PChar) : Bool;
    {-Send apw_ProtocolAcceptFile message to TProtocolWindow}
  var
    {$IFDEF Win32}
    Res : DWORD;
    {$ELSE}
    Res : Cardinal;
    {$ENDIF}
  begin
    with P^ do begin
      {$IFDEF Win32}
      SendMessageTimeout(aHWindow, apw_ProtocolAcceptFile,
                         0, Longint(FName),
                         SMTO_ABORTIFHUNG + SMTO_BLOCK,
                         1000, Res);
      {$ELSE}
      Res := SendMessage(aHWindow, apw_ProtocolAcceptFile, 0, LongInt(FName));
      {$ENDIF}
      apMsgAcceptFile := Res = 1;
    end;
  end;

  function apUpdateChecksum(CurByte : Byte; CheckSum : Cardinal) : Cardinal;
    {-Returns an updated checksum}
  begin
    apUpdateCheckSum := CheckSum + CurByte;
  end;

  function apUpdateCrc(CurByte : Byte; CurCrc : Cardinal) : Cardinal;
    {-Returns an updated CRC16}
  begin
    Result := (CrcTable[((CurCrc shr 8) and 255)] xor
              (CurCrc shl 8) xor CurByte) and $FFFF;                 
  end;

  function apUpdateCrcKermit(CurByte : Byte; CurCrc : Cardinal) : Cardinal;
    {-Returns an updated Crc16 (kermit style)}
  var
    I    : Integer;
    Temp : Cardinal;
  begin
    for I := 0 to 7 do begin
      Temp := CurCrc xor CurByte;
      CurCrc := CurCrc shr 1;
      if Odd(Temp) then
        CurCrc := CurCrc xor $8408;
      CurByte := CurByte shr 1;
    end;
    Result := CurCrc;
  end;

  function apStatusMsg(P : PChar; Status : Cardinal) : PChar;
    {-Return an appropriate error message from the stringtable}
  begin
    case Status of
      psOK..psHostResume, psAbort :                                    
        AproLoadZ(P, Status);
      else
        P[0] := #0;
    end;
    Result := P;
  end;

  procedure apRegisterProtocolClass;
    {-Register the protocol window class}
  const
    Registered : Bool = False;
  var
    WClass : TWndClass;
  begin
    if Registered then
      Exit;
    Registered := True;

    with WClass do begin
      Style         := 0;
      lpfnWndProc   := @DefWindowProc;
      cbClsExtra    := 0;
      cbWndExtra    := SizeOf(Pointer);
      {$IFDEF VERSION3}
      if ModuleIsLib and not ModuleIsPackage then
        hInstance     := SysInit.hInstance
      else
        hInstance     := System.MainInstance;
      {$ELSE}
      hInstance     := System.hInstance;
      {$ENDIF}                                                     
      hIcon         := 0;
      hCursor       := LoadCursor(0, idc_Arrow);
      hbrBackground := hBrush(color_Window + 1);
      lpszMenuName  := nil;
      lpszClassName := ProtocolClassName;
    end;
    RegisterClass(WClass);
  end;

  procedure apSetProtocolMsgBase(NewBase : Cardinal);
    {-Set new base for protocol string table}
  begin
    {nothing} 
  end;

  {$IFDEF Win32}
  function apUpdateCrc32(CurByte : Byte; CurCrc : LongInt) : LongInt;
    {-Return the updated 32bit CRC}
    {-Normally a good candidate for basm, but Delphi32's code
      generation couldn't be beat on this one!}
  begin
    apUpdateCrc32 := Crc32Table[Byte(CurCrc xor CurByte)] xor
                     DWORD((CurCrc shr 8) and $00FFFFFF);             
  end;
  {$ENDIF}

procedure InitializeUnit;
var
  TmpDateSeparator : string[1];
  TmpDateFormat : string[15];
  TmpDateTime : TDateTime;
begin
  {Set Unix days base}
  TmpDateFormat := ShortDateFormat;
  {$IFDEF win32}
  SetLength(TmpDateSeparator,1);
  {$ENDIF}
  TmpDateSeparator[1] := DateSeparator;
  DateSeparator := '/';
  ShortDateFormat := 'mm/dd/yyyy';
  TmpDateTime := StrToDateTime('01/01/1970');
  UnixDaysBase := Trunc(TmpDateTime);
  DateSeparator := TmpDateSeparator[1];
  ShortDateFormat := TmpDateFormat;

  {$IFNDEF Win32}
  Crc32TableOfs := Ofs(Crc32Table);
  {$ENDIF}

  {Register protocol window class}
  apRegisterProtocolClass;
end;

initialization
  InitializeUnit;

end.

