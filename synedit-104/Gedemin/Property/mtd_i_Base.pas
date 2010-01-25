
unit mtd_i_Base;

interface

uses
  Classes, evt_i_Base, Contnrs, gd_KeyAssoc, gdcBaseInterface;

type
  IMethodControl = interface
  ['{AF83FB96-DD8F-11D5-B631-00C0DF0E09D1}']

    // �������������
    procedure LoadLists;
    // ������������ ��� ���������� ��������� ���������� ������� �����
    // ������-�������� (����������� � �����-��� �����������������).
    function ExecuteMethodNew(AClassMethodAssoc: TgdKeyIntAndStrAssoc;
      AgdcBase: TObject; const AClassName, AMethodName: String; const AnMethodKey: Integer;
      var AnParams, AnResult: Variant): Boolean;

    // ������� ��� ���������� �������
    // ������ ���������� ��� �������� � ���������� ������-�������
    procedure ClearMacroCache;

    procedure Drop;

    function  FindMethodClass(const AnFullClassName: TgdcFullClassName): TObject;

    // !!! ���� TObject, ������ ���������� TCustomMethodClass
    function  AddClass(const AnClassKey: Integer;  const AnFullClassName: TgdcFullClassName;
      const AnClassReference: TClass): TObject;// overload;

    procedure SaveDisableFlag(
      const ID: Integer; const DisableFlag: Boolean);
  end;

  function  ChangeIncorrectSymbol(const SubType: String): String;

var
  MethodControl: IMethodControl;
  UnMethodMacro: Boolean;

implementation

uses
  Sysutils;

function ChangeIncorrectSymbol(const SubType: String): String;
var
  i: Integer;
begin
  Result := SubType;
  for i := 1 to Length(Result) do
    if Result[i] = '$' then
      Result[i] := '_';
end;

{ TClassListForMethod }

{function TClassListForMethod.Add(const S: string): Integer;
begin
  Result := IndexOf(S);
  if Result = -1 then
    Result := inherited Add(S)
end;}

initialization
  MethodControl := nil;

finalization


end.
