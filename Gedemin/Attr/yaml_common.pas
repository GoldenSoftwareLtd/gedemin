// ShlTanya, 03.02.2019

unit yaml_common;

interface

uses
  Classes, SysUtils;

type
  TyamlScalarQuoting = (
    qPlain,
    qSingleQuoted,
    qDoubleQuoted);

  TyamlScalarStyle = (
    sPlain,
    sLiteral,
    sFolded);

  EyamlException = class(Exception);
  EyamlSyntaxError = class(EyamlException);

const
  EOL             = [#13, #10];
  DefIndent       = 2;
  SpaceSubstitute = '@';
  dirYAML11       = 'YAML 1.1';

var
  TZBias: Integer;
  TZBiasString: String;

implementation

uses
  Windows;

var
  TZInfo: TTimeZoneInformation;

initialization
  if GetTimeZoneInformation(TZInfo) <> TIME_ZONE_ID_INVALID then
    TZBias := TZInfo.Bias
  else
    TZBias := 0;

  if TZBias = 0 then
    TZBiasString := 'Z'
  else begin
    if TZBias < 0 then
      TZBiasString := Format('+%2.2d:%2.2d', [-TZBias div 60, -TZBias mod 60])
    else
      TZBiasString := Format('-%2.2d:%2.2d', [TZBias div 60, TZBias mod 60]);
  end;
end.
