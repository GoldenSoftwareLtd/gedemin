
{******************************************}
{                                          }
{     FastReport v2.4 - ADO components     }
{            Registration unit             }
{                                          }
{ Copyright (c) 1998-2001 by Tzyganenko A. }
{                                          }
{******************************************}

unit FR_ADOreg;

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
, FR_ADODB;

procedure Register;
begin
  RegisterComponents('FastReport', [TfrADOComponents]);
end;

end.
