unit tst_TestInterface;

interface

type
  ITestInt = interface(IDispatch)
  ['{162B5B8B-D8E5-11D5-B62D-00C0DF0E09D1}']
    procedure Method1; safecall;
    procedure Method2; safecall;
    procedure Method3; safecall;
  end;

implementation

end.



