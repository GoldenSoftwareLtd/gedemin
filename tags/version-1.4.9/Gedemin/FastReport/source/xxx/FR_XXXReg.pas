
{******************************************}
{                                          }
{     FastReport v2.4 - XXX components     }
{            Registration unit             }
{                                          }
{ Copyright (c) 1998-2001 by Tzyganenko A. }
{                                          }
{******************************************}

unit FR_XXXreg;

interface

{$I FR.inc}

procedure Register;

implementation

uses
  Windows, Messages, SysUtils, Classes
{$IFNDEF Delphi6}
, DsgnIntf
{$ELSE}
, DesignIntf, DesignEditors
{$ENDIF}
, FR_XXXDB;


procedure Register;
begin
  RegisterComponents('FastReport', [TfrXXXComponents]);
end;

end.
