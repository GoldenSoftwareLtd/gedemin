{******************************************}
{                                          }
{             FastReport v2.53             }
{            HTML export filter            }
{             Property Editors             } 
{                                          }
{  Copyright (c) 2003 by Kirichenko V.A.   }
{ http://fr2html.narod.ru, fr2html@mail.ru }
{                                          }
{******************************************}

unit FR_E_HTML2_EDITORS;

interface

{$I Fr.inc}

uses
  {$IFDEF Delphi6}
  DesignIntf, DesignEditors;
  {$ELSE}
  DsgnIntf;
  {$ENDIF}

type
  THNavigatorProperty = class(TClassProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
  end;

implementation

uses
  FR_E_HTML2;

{ THNavigatorProperty }

function THNavigatorProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paMultiSelect, paSubProperties, paReadOnly];
end;

end.
