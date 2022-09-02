// ShlTanya, 25.02.2019

{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    obj_FinallyObject.pas

  Abstract

    Gedemin project. TFinallyObject.

  Author

    Dubrovnik Alexander

  Revisions history

     1.00     18.06.03    DAlex    Global object for exceptions in VBScript are handled within 'Except' statements.
--}

unit obj_FinallyObject;

interface

uses
  ComObj, Gedemin_TLB, Comserv, Controls, Classes;

type
  TFinallyObject = class(TAutoObject, IFinallyObject)
  protected
    procedure Declaration(ParamArray: OleVariant; const Script: WideString; Line: Integer); safecall;
    procedure Clear; safecall;

  end;

var
  FinallyObject: IFinallyObject;


implementation

uses
  obj_i_Debugger, gd_i_ScriptFactory;

{ TFinallyObject }

procedure TFinallyObject.Clear;
begin
  Debugger.ClearLastFinallyParams;
end;

procedure TFinallyObject.Declaration(ParamArray: OleVariant;
  const Script: WideString; Line: Integer); safecall;
begin
  Debugger.SetLastFinallyParams(ParamArray, Script, Line)
end;

initialization
  TAutoObjectFactory.Create(ComServer, TFinallyObject, CLASS_CoFinallyObject,
    ciMultiInstance, tmApartment);
  FinallyObject := TFinallyObject.Create;

finalization
  FinallyObject := nil;

end.
