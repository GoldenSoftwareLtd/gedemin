unit frmTestMethod2_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  frmTestMethod1_unit;

type
  TfrmTestMethod2 = class(TfrmTestMethod1)
  private
    { Private declarations }
  public
    procedure Close2(Param1, Param2: Integer);
    procedure Close3(Param1, Param2: Integer);

    procedure Close44(Param1, Param2: Real);
    procedure Close55;
  end;

var
  frmTestMethod2: TfrmTestMethod2;

implementation

uses mtd_i_Base, gd_ClassList, TypInfo;

var
  MyParam1, MyParam2: TgdcMethodParam;
  MyMethod: TgdcMethod;
{$R *.DFM}

{ TfrmTestMethod2 }

procedure TfrmTestMethod2.Close2(Param1, Param2: Integer);
var
  Params, Result: Variant;
  CurrClass: TClass;
begin
  CurrClass := Self.ClassType;
  repeat
    Params := VarArrayOf([Param1, Param2]);
//    MethodControl.ExecuteMethod(CurrClass.ClassName, 'Close2', Params, Result);
    CurrClass := CurrClass.ClassParent;
  until CurrClass = nil;
end;

procedure TfrmTestMethod2.Close3(Param1, Param2: Integer);
var
  Params, Result: Variant;
  CurrClass: TClass;
begin
  CurrClass := Self.ClassType;
  repeat
    Params := VarArrayOf([Param1, Param2]);
//    MethodControl.ExecuteMethod(CurrClass.ClassName, 'Close3', Params, Result);
    CurrClass := CurrClass.ClassParent;
  until CurrClass = nil;
end;

procedure TfrmTestMethod2.Close44(Param1, Param2: Real);
var
  Params, result: Variant;
  CurrClass: TClass;
begin
  CurrClass := Self.ClassType;
  repeat
    Params := VarArrayOf([Param1, Param2]);
//    MethodControl.ExecuteMethod(CurrClass.ClassName, 'Close44', Params, Result);
    CurrClass := CurrClass.ClassParent;
  until CurrClass = nil;
end;

procedure TfrmTestMethod2.Close55;
var
  Params, Result: Variant;
  CurrClass: TClass;
begin
  CurrClass := Self.ClassType;
  repeat
    Params := VarArrayOf([]);
//    MethodControl.ExecuteMethod(CurrClass.ClassName, 'Close55', Params, Result);
    CurrClass := CurrClass.ClassParent;
  until CurrClass = nil;
end;

initialization
  RegisterClassMethod(TfrmTestMethod1, 'Close2', 'const Param1: Integer; const Param2: Integer', '');
{  MyParam1 := TgdcMethodParam.Create('Param1', 'Integer', pfConst);
  try
    MyParam2 := TgdcMethodParam.Create('Param2', 'Integer', pfConst);
    try
      MyMethod := TgdcMethod.Create('Close2',mkProcedure);
      try
        MyMethod.AddParam(MyParam1);
        MyMethod.AddParam(MyParam2);

        RegisterGdcClassMethod(TfrmTestMethod2, MyMethod);
      finally
        MyMethod.Free;
      end;
    finally
      MyParam2.Free;
    end;
  finally
    MyParam1.Free;
  end;}

  RegisterClassMethod(TfrmTestMethod1, 'Close44', 'const Param1: Integer; const Param2: Integer', '');
{  MyParam1 := TgdcMethodParam.Create('Param1', 'Integer', pfConst);
  try
    MyParam2 := TgdcMethodParam.Create('Param2', 'Integer', pfConst);
    try
      MyMethod := TgdcMethod.Create('Close44',mkProcedure);
      try
        RegisterGdcClassMethodParams(TfrmTestMethod2, MyMethod, [MyParam1,MyParam2]);
      finally
        MyMethod.Free;
      end;
    finally
      MyParam2.Free;
    end;
  finally
    MyParam1.Free;
  end;}
  RegisterClassMethod(TfrmTestMethod1, 'Close55', '', '');
 {
      MyMethod := TgdcMethod.Create('Close55',mkProcedure);
      try
        RegisterGdcClassMethod(TfrmTestMethod2, MyMethod);
      finally
        MyMethod.Free;
      end;}

end.
