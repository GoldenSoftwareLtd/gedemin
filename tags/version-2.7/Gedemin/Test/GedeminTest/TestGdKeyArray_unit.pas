
unit TestGdKeyArray_unit;

interface

uses
  Classes, TestFrameWork;

type
  TgdKeyArrayTest = class(TTestCase)
  protected
    procedure SetUp; override;

  published
    procedure TestGdKeyArray;
  end;

implementation

uses
  gd_KeyAssoc;

{ TgsKeyArrayTest }

procedure TgdKeyArrayTest.SetUp;
begin
  inherited;
  Randomize;
end;

procedure TgdKeyArrayTest.TestGdKeyArray;
var
  KA1, KA2: TgdKeyArray;
  I, V, K: Integer;
begin
  KA1 := TgdKeyArray.Create;
  KA2 := TgdKeyarray.Create;
  try
    for I := 1 to 10000 do
    begin
      V := Random(MAXINT) - (MAXINT div 2);
      if not KA1.Find(V, K) then
        KA1.Add(V);
    end;

    KA1.Add(High(Integer));
    KA1.Add(Low(Integer));
    if not KA1.Find(0, K) then
      KA1.Add(0);

    for I := 1 to KA1.Count - 1 do
      Check(KA1[I - 1] <= KA1[I], 'Violation of sort order');

    KA2.Assign(KA1);
    Check(KA1.CommaText = KA2.CommaText);

    KA1.Clear;
    Check(KA1.Count = 0, 'Array #1 is not empty');

    KA1.CommaText := KA2.CommaText;
    Check(KA1.CommaText = KA2.CommaText);

    for I := 0 to KA2.Count - 1 do
      KA1.Remove(KA2[I]);
    Check(KA1.Count = 0, 'Array #1 is not empty');

    for I := KA2.Count - 1 downto 0 do
      KA2.Delete(I);
    Check(KA2.Count = 0, 'Array #2 is not empty');
  finally
    KA2.Free;
    KA1.Free;
  end;
end;

initialization
  RegisterTest('Internals', TgdKeyArrayTest.Suite);
end.

