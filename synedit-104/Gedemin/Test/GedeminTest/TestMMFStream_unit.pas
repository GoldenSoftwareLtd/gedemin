
unit TestMMFStream_unit;

interface

uses
  Classes, TestFrameWork, gsMMFStream;

type
  TMMFStreamTest = class(TTestCase)
  published
    procedure TestBasicStreamBehavior;
    procedure Test2GBLimit;
  end;

implementation

uses
  SysUtils;

const
  MaxBuffSize   = 1000;       // in Int64
  MaxStreamSize = 30000000;    // size in bytes = MaxStreamSize * SizeOf(Int64)

{ TMMFStreamTest }

procedure TMMFStreamTest.Test2GBLimit;
var
  St1: TgsStream64;
  A: array[0..MaxBuffSize - 1] of Int64;
  C, J, P: Int64;
  I, K, S: Integer;
begin
  St1 := TgsStream64.Create;
  try
    Check(St1.Size = 0, 'Invalid initial size');
    Check(St1.Position = 0, 'Invalid initial position');

    C := 0;
    while C < MaxStreamSize do
    begin
      I := Random(MaxBuffSize);
      if (C + Cardinal(I)) >= MaxStreamSize then
        I := MaxStreamSize - C - 1;
      J := 0;
      while J <= I do
      begin
        A[J] := C + J;
        Inc(J);
      end;
      Check(St1.Write(A, (I + 1) * SizeOf(A[0])) = (I + 1) * SizeOf(A[0]),
        'Cannot write whole buffer to the file');
      Inc(C, I + 1);
    end;

    Check(St1.Size = C * SizeOf(Int64), 'Invalid size after fill up');
    Check(St1.Position = St1.Size, 'Invalid position after fill up');
    Check(St1.Position = St1.Seek(0, soFromCurrent));
    Check(St1.Size = St1.Seek(0, soFromEnd));

    for I := 1 to 1000 do
    begin
      P := Random(C);
      Check(St1.Seek(P * SizeOf(Int64), soFromBeginning) = P * SizeOf(Int64), 'Seek failure');

      S := Random(St1.ViewSize);  // take care that ViewSize is in bytes and S is in Cardinals
      if S > MaxBuffSize then
        S := MaxBuffSize;
      if St1.Position + S * SizeOf(Int64) > St1.Size then
        S := (St1.Size - St1.Position) div SizeOf(Int64);
      try
        Check(St1.Read(A[0], S * SizeOf(A[0])) = S * SizeOf(A[0]), 'Invalid bytes count');
      except
        on E: Exception do
        begin
          Check(False,
            E.ClassName + ', I=' + IntToStr(I) + ', P=' + IntToStr(P) + ', S=' + IntToStr(S));
        end;
      end;
      for K := 0 to S - 1 do
        Check(A[K] = P + K, 'Data inconsistence');
    end;
  finally
    St1.Free;
  end;
end;

procedure TMMFStreamTest.TestBasicStreamBehavior;
const
  A = '0123456789';
var
  St: TgsStream64;
begin
  St := TgsStream64.Create;
  try
    Check(St.Size = 0, 'Size <> 0');
    Check(St.Position = 0, 'Position <> 0');
    Check(St.Write(A[1], Length(A) * SizeOf(Char)) = Length(A) * SizeOf(Char),
      'Cannot write a string');
    Check(St.Size = Length(A) * SizeOf(Char), 'Invalid size');
    Check(St.Position = St.Seek(0, soFromEnd), 'Invalid position');
    Check(St.Size = St.Position, 'Size <> Position');
    St.Seek(-Length(A) * SizeOf(Char), soFromEnd);
    Check(St.Position = 0, 'Position <> 0');
    Check(St.ReadString(Length(A)) = A, 'Incorrect read from stream');
    Check(St.Size = St.Position, 'Size <> Position');
  finally
    St.Free;
  end;
end;

initialization
  RegisterTest('', TMMFStreamTest.Suite);
end.
