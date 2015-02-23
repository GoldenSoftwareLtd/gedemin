unit frmTestMethod3_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  frmTestMethod2_unit;

type
  TfrmTestMethod3 = class(TfrmTestMethod2)
  private
    { Private declarations }
  public
    procedure Close2(Param1, Param2: Integer);
    procedure Close3(Param1, Param2: Integer);
  end;

var
  frmTestMethod3: TfrmTestMethod3;

implementation

uses mtd_i_Base, gd_ClassList, TypInfo;

var
  Param1, Param2: TgdcMethodParam;
  Method: TgdcMethod;
{$R *.DFM}

{ TfrmTestMethod2 }

procedure TfrmTestMethod3.Close2(Param1, Param2: Integer);
var
  Params, Result: Variant;
  CurrClass: TClass;
begin
  CurrClass := Self.ClassType;
  repeat
    Params := VarArrayOf([Param1, Param2]);
 //   MethodControl.ExecuteMethod(CurrClass.ClassName, 'Close2', Params, Result);
    CurrClass := CurrClass.ClassParent;
  until CurrClass = nil;
end;

procedure TfrmTestMethod3.Close3(Param1, Param2: Integer);
var
  Params, result: Variant;
  CurrClass: TClass;
begin
  CurrClass := Self.ClassType;
  repeat
    Params := VarArrayOf([Param1, Param2]);
//    MethodControl.ExecuteMethod(CurrClass.ClassName, 'Close3', Params, result);
    CurrClass := CurrClass.ClassParent;
  until CurrClass = nil;
end;

initialization

  RegisterGdcClass(TfrmTestMethod3);
{
  Param1 := TgdcMethodParam.Create('Param1', 'Integer', pfConst);
  try
    Param2 := TgdcMethodParam.Create('Param2', 'Integer', pfConst);
    try
      Method := TgdcMethod.Create('Close2', mkProcedure);
      try
        Method.AddParam(Param1);
        Method.AddParam(Param2);

        RegisterGdcClassMethod(TfrmTestMethod3, Method);
      finally
        Method.Free;
      end;
    finally
      Param2.Free;
    end;
  finally
    Param1.Free;
  end;

  Param1 := TgdcMethodParam.Create('Param1', 'Integer', pfConst);
  try
    Param2 := TgdcMethodParam.Create('Param2', 'Integer', pfConst);
    try
      Method := TgdcMethod.Create('Close3',mkProcedure);
      try
       // MyMethod.AddParam(MyParam1);
       // MyMethod.AddParam(MyParam2);

        RegisterGdcClassMethodParams(TfrmTestMethod3, Method, [Param1, Param2]);
      finally
        Method.Free;
      end;
    finally
      Param2.Free;
    end;
  finally
    Param1.Free;
  end;
}
end.
