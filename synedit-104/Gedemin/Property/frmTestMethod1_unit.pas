unit frmTestMethod1_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  TfrmTestMethod1 = class(TForm)
  private
    { Private declarations }
  public
    procedure Close3(Param1, Param2: Integer);
  end;

var
  frmTestMethod1: TfrmTestMethod1;

implementation

uses mtd_i_Base, gd_ClassList, TypInfo;

var
  MyParam1, MyParam2: TgdcMethodParam;
  MyMethod: TgdcMethod;

{$R *.DFM}

{ TfrmTestMethod1 }

procedure TfrmTestMethod1.Close3(Param1, Param2: Integer);
var
  Params, Result: Variant;
  CurrClass: TClass;
begin
  CurrClass := Self.ClassType;
  repeat
    Params := VarArrayOf([Param1, Param2]);
{    MethodControl.ExecuteMethod(CurrClass.ClassName, 'Close3', Params, Result);}
    CurrClass := CurrClass.ClassParent;
  until CurrClass = nil;
end;


initialization
  RegisterClassMethod(TfrmTestMethod1, 'Close3', 'const Param1: Integer; const Param2: Integer', '')
{  MyParam1 := TgdcMethodParam.Create('Param1', 'Integer', pfConst);
  try
    MyParam2 := TgdcMethodParam.Create('Param2', 'Integer', pfConst);
    try
      MyMethod := TgdcMethod.Create('Close3',mkProcedure);
      try
        (*MyMethod.AddParam(MyParam1);
        MyMethod.AddParam(MyParam2);*)

        RegisterGdcClassMethodParams(TfrmTestMethod1, MyMethod, [MyParam1, MyParam2]);
      finally
        MyMethod.Free;
      end;
    finally
      MyParam2.Free;
    end;
  finally
    MyParam1.Free;
  end;}

end.
