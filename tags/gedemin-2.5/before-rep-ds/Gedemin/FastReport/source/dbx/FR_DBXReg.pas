
{******************************************}
{                                          }
{     FastReport v2.4 - DBX components     }
{            Registration unit             }
{                                          }
{ Copyright (c) 1998-2001 by Tzyganenko A. }
{                                          }
{******************************************}

unit FR_DBXreg;

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
, FR_DBXDB;


procedure Register;
begin
  RegisterComponents('FastReport', [TfrDBXComponents]);
end;

end.
