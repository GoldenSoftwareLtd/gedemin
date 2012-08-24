unit scr_i_FunctionList;

interface

uses
  Classes, rp_BaseReport_unit;

type
  IScriptFunctions = interface
  ['{9332430B-277F-11D6-B69E-00C0DF0E09D1}']
    function Get_Self: TObject;
    function Get_Function(Index: Integer): TrpCustomFunction;

    // ����� ������� � ������ � ��
    function FindFunction(const AnFunctionKey: Integer): TrpCustomFunction;
    function FindFunctionWithoutDB(const AnFunctionKey: Integer): TrpCustomFunction;
//    function IndexOf(const AnFunctionKey: Integer): Integer;
//    function IndexOf(F: TrpCustomFunction): Integer;
    function ReleaseFunction(AnFunction: TrpCustomFunction): Integer;
    // ������������ ������ ��� �������, ������������ � ������.
    function  UpdateList: Boolean;
    // ������� �-���, ������ ���� ����
    procedure RemoveFunction(const AnFunctionKey: Integer);
    // ��������� � ��. ������ �-���
    procedure AddFunction(const AnFunction: TrpCustomFunction);
    procedure Clear;
    //����� ������ �������. ��������� ������ � ��� �������
    procedure Drop;
    property Items[Index: Integer]: TrpCustomFunction read Get_Function;
  end;

var
  glbFunctionList: IScriptFunctions;

implementation

initialization
  glbFunctionList := nil;

end.
