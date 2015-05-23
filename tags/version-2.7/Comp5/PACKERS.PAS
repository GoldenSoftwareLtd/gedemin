{$DEFINE xTool}

{*******************************************************}
{                                                       }
{       xTool - Component Collection                    }
{                                                       }
{       Copyright (c) 1995,96 Stefan Bother             }
{                                                       }
{*******************************************************}

{++

  Copyright (c) 1996 by Golden Software of Belarus

  Module

    packers.pas

  Abstract

    Components fro binary data compression.

  Author

     Vladimir Belyi (1-March-1996)

  Contact address

    goldsoft%swatogor.belpak.minsk.by@demos.su

  Revisions history

    2.00  14-Jun-1996   Belyi   Support by Delphi 2.0
    2.01  23-Jun-1996   Belyi   Modifications in extracting methods
    2.02  30-Aug-1996   Belyi   Sender in all events.

--}

unit Packers;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs;

type
  TBufferFull = procedure(Sender: TObject; const Buffer; Count: word) of object;
  TBufferEmpty = procedure(Sender: TObject; var Buffer; Count: word;
    var WasRead: Word) of object;

type
  ByteArray = array[0..High(word)-1] of byte;

const
  opFirstTime  = 0;
  opCompress   = 1;
  opdecompress = 2;

type
  TCustomPacker = class(TComponent)
  private
    { Private declarations }
    Buffer: ^ByteArray;
    BufferPos: word;
    BufferHave: word;
    BufferHasData: Boolean;

    Bitsbuffer: LongInt;
    BitsBufferPos: integer;

    LastOperation: word;

    FOnBufferFull: TBufferFull;
    FOnBufferEmpty: TBufferEmpty;
    FBufferSize: Word;
    procedure SetBufferSize(ASize: Word);

  protected
    { Protected declarations }
    procedure WriteByte(AByte: byte); virtual;
    procedure WriteBits(Source, Amount: word);
    procedure FlushBits;
    procedure ReadFlushBits;
    function ReadByte: byte; virtual;
    function ReadBits(Amount: word):word;
    procedure Compressing(const Data: ByteArray; Count: word); virtual;
    function Decompressing(var Data; Count: word): word; virtual;
    procedure FillBuffer; virtual;

  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ReInit; virtual;
    procedure Compress(const Data; Count: word);
    function Decompress(var Data; Count: word): word;
    procedure FlushBuffer; virtual;

    property BufferSize: Word read FBufferSize write SetBufferSize;
    property OnBufferFull: TBufferFull read FOnBufferFull
      write FOnBufferFull;
    property OnBufferEmpty: TBufferEmpty read FOnBufferEmpty
      write FOnBufferEmpty;
  end;

  TPacker = class(TCustomPacker)
  published
    property BufferSize;
    property OnBufferFull;
    property OnBufferEmpty;
  end;

{ LZW Packing }

const
  BITS = 12;
  TableSize = 5021;
  HASHING_SHIFT = BITS - 8;
  Table_refresh = 256;
  Block_End = 257;
  Min_Value = 258;
  MAX_CODE = (1 shl BITS) - 1;
  CHECK_TIME = 100;    { Check comp ratio every CHECK_TIME chars input }

type
  TPackRecord = record
    Code: Integer;
    Prefix: Word;
    AChar: byte;
  end;

  PPackTable = ^TPackTable;
  TPackTable = array[0..TableSize] of TPackRecord;

const
  PackRecSize = SizeOf(TPackRecord);
  DecodeStackSize = 4000;

var
  PackTable: PPackTable;

type
  TLZWPacker = class(TPacker)
  private
    PackTable: PPackTable;
    DecodeStackPos: integer;
    DecodeStack: array[0..DecodeStackSize] of byte;
    NewBuffer: Boolean;
    NewCode: word;
    OldCode: word;
    Character: integer;
    BytesIn, BytesOut: LongInt;
    RatioOld, RatioNew: integer;
    procedure WriteByte(AByte: byte); override;
    function DecodeByte: byte;
    function FindMatch(HashPrefix: integer; HashChar: word):integer;
    function DecodeString(BufPos: word; Code: word):word;
    procedure ClearTable;

  protected
    procedure Compressing(const Data: ByteArray; Count: word); override;
    function Decompressing(var Data; Count: word): word; override;
    procedure FillBuffer; override;

  public
    NextCode: word;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

  published
    property BufferSize: Word read FBufferSize write SetBufferSize;
    property OnBufferFull: TBufferFull read FOnBufferFull
      write FOnBufferFull;
    property OnBufferEmpty: TBufferEmpty read FOnBufferEmpty
      write FOnBufferEmpty;
  end;

type
  EPackerError = class(exception);
  EPackerReadError = class(EPackerError);
  EPackedDataError = class(EPackerError);

procedure Register;

implementation

{ ---------------------- TCustomPacker ----------------}
constructor TCustomPacker.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBufferSize := 30;
  GetMem(Buffer, FBufferSize);
  BufferPos := 0;
  BufferHave := 0;
  LastOperation := opFirstTime;
  BufferHasData := false;
  BitsBuffer := 0;
  BitsBufferPos := 0;
end;

destructor TCustomPacker.Destroy;
begin
  if (LastOperation = opCompress) and
     (BufferPos > 0) then FlushBuffer;
  if FBufferSize > 0 then FreeMem(Buffer, FBufferSize);
  inherited Destroy;
end;

procedure TCustomPacker.SetBufferSize(ASize: Word);
begin
  if ASize <> FBufferSize then
    begin
      if BufferPos > FBufferSize then FlushBuffer;
      if FBufferSize > 0 then FreeMem(Buffer, FBufferSize);
      FBufferSize := ASize;
      GetMem(Buffer, FBufferSize);
    end;
end;

procedure TCustomPacker.ReInit;
begin
  if (LastOperation = opCompress) and
     (BufferPos > 0) then FlushBuffer;
  LastOperation := opFirstTime;
  BitsBuffer := 0;
  BitsBufferPos := 0;
end;

procedure TCustomPacker.WriteByte(AByte: byte);
begin
  if BufferPos = FBufferSize then FlushBuffer;
  Buffer^[BufferPos] := AByte;
  inc(BufferPos);
end;

function TCustomPacker.ReadByte: byte;
begin
  ReadByte := Buffer^[BufferPos];
  inc(BufferPos);
  if BufferPos >= BufferHave then FillBuffer;
end;

procedure TCustomPacker.WriteBits(Source, Amount: word);
var
  SwapLong: LongInt;
begin
  SwapLong := Source;
  inc(BitsBufferPos, Amount);
  BitsBuffer := BitsBuffer or (SwapLong shl (32 - BitsBufferPos));
  while (BitsBufferPos >= 8) do
    begin
      WriteByte(byte(BitsBuffer shr 24));
      BitsBuffer := BitsBuffer shl 8;
      BitsBufferPos := BitsBufferPos - 8;
    end
end;

procedure TCustomPacker.FlushBits;
begin
  if BitsBufferPos > 0 then WriteBits(0, 8);
  BitsBufferPos := 0;
  BitsBuffer := 0;
end;

procedure TCustomPacker.ReadFlushBits;
begin
  BitsBufferPos := 0;
  BitsBuffer := 0;
{  if BitsBufferPos in [25..31] then ReadBits(BitsBufferPos - 24);}
end;

function TCustomPacker.ReadBits(Amount: word):word;
var
  SwapLong: LongInt;
begin
  while (BitsBufferPos < Amount) and BufferHasData do
    begin
      SwapLong := ReadByte;
      BitsBuffer := BitsBuffer or (swapLong shl (24-BitsBufferPos));
      inc(BitsBufferPos, 8);
    end;
  Result := BitsBuffer shr (32 - Amount);
  BitsBuffer := BitsBuffer shl Amount;
  dec(BitsBufferPos, Amount);
end;

procedure TCustomPacker.Compress(const Data; Count: word);
begin
  if (LastOperation = opFirstTime) or
     (LastOperation = opDecompress) then
    begin
      BufferPos := 0;
      BufferHave := 0;
    end;
  LastOperation := opCompress;
  Compressing(ByteArray(Data), Count);
end;

procedure TCustomPacker.Compressing(const Data: ByteArray; Count: word);
var
  i: word;
begin
  for i:=0 to count-1 do
    WriteBits( Data[i] , 8);
end;

function TCustomPacker.Decompress(var Data; Count: word): Word;
begin
  if ( LastOperation = opCompress ) and
     ( BufferPos > 0 ) then FlushBuffer;
  LastOperation := opDecompress;
  If not BufferHasData then FillBuffer;
  Result := Decompressing(Data, Count);
end;

function TCustomPacker.Decompressing(var Data; Count: word): word;
var
  i: Word;
begin
  i := 0;
  while (i < Count) and BufferHasData do
    begin
      ByteArray(Data)[i] := ReadByte;
      inc(i);
    end;
  Result := i;
end;

procedure TCustomPacker.FlushBuffer;
begin
  if Assigned(FOnBufferFull) and (BufferPos>0) then
    begin
      FOnBufferFull(self, BufferPos, SizeOf(BufferPos));
      FOnBufferFull(self, Buffer^, BufferPos);
    end;
  BufferPos := 0;
end;

procedure TCustomPacker.FillBuffer;
var
  ToRead: Word;
  WasRead: word;
begin
  if Assigned(FOnBufferEmpty) then
    begin
      BufferPos := 0;
      FOnBufferEmpty(self, ToRead, SizeOf(BufferPos), WasRead);
      if WasRead<SizeOf(BufferPos) then
        begin
           BufferHasData := false;
           exit
        end;
      if ToRead > BufferSize then BufferSize := ToRead;
      FOnBufferEmpty(self, Buffer^, ToRead, WasRead);
      if WasRead<>ToRead then
        raise EPackerReadError.Create('Couldn''t read neccessary data');
      BufferHave := ToRead;
      BufferHasData := true;
    end
  else BufferHasData := false;
end;


{ ---------------------- TCustomPacker ----------------}
constructor TLZWPacker.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  New(PackTable);
  ClearTable;
  DecodeStackPos := 0;
  NewBuffer := true;
end;

destructor TLZWPacker.Destroy;
begin
  Dispose(PackTable);
  inherited Destroy;
end;

procedure TLZWPacker.WriteByte(AByte: byte);
begin
  inherited WriteByte(Abyte);
  inc(BytesOut);
end;

procedure TLZWPacker.ClearTable;
begin
  FillChar(PackTable^, SizeOf(Packtable^), $ff);
  NextCode := Min_Value; { next available string code }
  BytesIn := 0;
  BytesOut := 0;
  RatioOld := 100;
end;

function TLZWPacker.FindMatch(HashPrefix: integer; HashChar: word):integer;
var
  Index, Offset: integer;
begin
  index := (HashChar shl HASHING_SHIFT) xor HashPrefix;
  if (index = 0) then offset := 1
    else offset := TableSize - index;
  while true do
    begin
      with PackTable^[index] do
        begin
          if (code = -1) then
            begin
              Result := index;
              exit;
            end;
          if (prefix = HashPrefix) and (achar = HashChar) then
            begin
              Result := index;
              exit;
            end;
        end;
      index := index - offset;
      if (index<0) then index := index + TableSize;
    end
end;

procedure TLZWPacker.Compressing(const Data: ByteArray; count: word);
var
  Index: word;
  HaveRead: word;
  StringCode: Word;
{  SelfES, SelfDI: word;}
begin
  if NewBuffer then
    begin
      ClearTable;
      NewBuffer := false;
    end;
  HaveRead := 0;
  StringCode := Data[HaveRead];      { get the first code }
  inc(HaveRead);
  inc(BytesIn);
  while HaveRead<Count do
    begin
      Character := Data[HaveRead];
      inc(HaveRead);
      inc(BytesIn);
      index := FindMatch(StringCode, Character);
      with PackTable^[index] do
        if code <> -1 then StringCode := code
        else
          begin
            if (NextCode <= MAX_CODE) then
              begin
                code := NextCode;
                inc(NextCode);
                prefix := StringCode;
                achar := character;
              end;
            WriteBits(StringCode, BITS);
            StringCode := Character;
            if (NextCode > Max_Code) and (BytesIn > check_time) then         { At checkpoint? }
              begin
                RatioNew := bytesOut*100 div bytesIn; { New compression ratio }
                if (RatioNew > RatioOld) then        { Has ratio degraded? }
                 begin
                   WriteBits(TABLE_refresh, BITS); { YES,flush string table }
                   ClearTable;
                 end
                else                                { NO, then save new }
                 RatioOld := RatioNew;            { compression ratio }
              end;
          end;
    end;
  WriteBits(StringCode, BITS);
  WriteBits(Block_End, BITS);
  FlushBits;
end;

function TLZWPacker.Decompressing(var Data; Count: word): word;
var
  i: Word;
begin
  i := 0;
  while (i < Count) and (BufferHasData or
        ( (DecodeStackPos > 0) or (BitsBufferPos >= BITS))) do
    begin
      ByteArray(Data)[i] := DecodeByte;
      inc(i);
    end;
  Result := i;
end;

function TLZWPacker.DecodeString(BufPos: word; Code: word):word;
var
  i: integer;
begin
  i := 0;
  while (code > 255) do
    begin
      DecodeStack[bufpos] := PackTable^[code].achar;
      inc(Bufpos);
      code := PackTable^[code].prefix;
      inc(i);
      if (i > 4000) then
       raise EPackerError.Create('Fatal error during code expansion.');
    end;
  DecodeStack[bufpos] := code;
  result := BufPos;
end;

function TLZWPacker.DecodeByte: byte;
begin
  if DecodeStackPos > 0 then
    begin
      dec(DecodeStackPos);
      DecodeByte := DecodeStack[DecodeStackPos];
    end
  else
    if NewBuffer then
      begin
        NextCode := Min_Value; { next available string code }
        OldCode := ReadBits(BITS);
        character := OldCode;
        Result := OldCode;
        NewCode := ReadBits(BITS);
        NewBuffer := false;
      end
    else
     if (NewCode <> Block_End) then
       begin
        if (NewCode >= NextCode) then
          begin
            DecodeStack[0] := character;
            DecodeStackPos := DecodeString(1, OldCode);
          end
        else DecodeStackPos := DecodeString(0, NewCode);
        character := DecodeStack[DecodeStackPos];
        Result := Character;
        if (NextCode <= MAX_CODE) then
          begin
            PackTable^[NextCode].prefix := OldCode;
            PackTable^[NextCode].achar := character;
            inc(NextCode);
          end;
        OldCode := NewCode;
        NewCode := ReadBits(BITS);
        if NewCode = Block_End then ReadFlushBits;
        if NewCode = Table_Refresh then
          begin
            ClearTable;
            NewCode := Block_End;
          end;
      end
     else {if NewCode = Block_End then}
          begin
            OldCode := ReadBits(BITS);
            DecodeStackPos := DecodeString(0, OldCode);
            character := DecodeStack[DecodeStackPos];
            Result := Character;
            NewCode := ReadBits(BITS);
            if NewCode = Table_Refresh then
              begin
                ClearTable;
                NewCode := Block_End;
              end;
          end;
end;

procedure TLZWPacker.FillBuffer;
begin
  inherited FillBuffer;
{  if BufferHasData then NewBuffer := true;}
end;


{ ---------------------- Registration part ----------------}
procedure Register;
begin
  RegisterComponents('xStorm', [TLZWPacker]);
end;

end.
