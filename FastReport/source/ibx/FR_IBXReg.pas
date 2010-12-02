
{******************************************}
{                                          }
{     FastReport v2.4 - IBX components     }
{            Registration unit             }
{                                          }
{        Copyright (c) 2000 by EMS         }
{ Copyright (c) 1998-2001 by Tzyganenko A. }
{                                          }
{******************************************}

unit FR_IBXReg;

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
, FR_IBXDB;


procedure Register;
begin
  RegisterComponents('FastReport', [TfrIBXComponents]);
end;

end.
