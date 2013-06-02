
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

implementation

end.
