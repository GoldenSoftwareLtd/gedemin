// ShlTanya, 24.02.2019

unit scr_i_FunctionList;

interface

uses
  Classes, rp_BaseReport_unit, gdcBaseInterface;

type
  IScriptFunctions = interface
  ['{9332430B-277F-11D6-B69E-00C0DF0E09D1}']
    function Get_Self: TObject;
    function Get_Function(Index: Integer): TrpCustomFunction;

    // Поиск функции в списке и БД
    function FindFunction(const AnFunctionKey: TID): TrpCustomFunction;
    function FindFunctionWithoutDB(const AnFunctionKey: TID): TrpCustomFunction;
//    function IndexOf(const AnFunctionKey: Integer): Integer;
//    function IndexOf(F: TrpCustomFunction): Integer;
    function ReleaseFunction(AnFunction: TrpCustomFunction): Integer;
    // Перечитывает данные для функций, содержащихся в списке.
    function  UpdateList: Boolean;
    // Удаляет ф-цию, чистит файл кэша
    procedure RemoveFunction(const AnFunctionKey: TID);
    // Добавляет в гл. список ф-цию
    procedure AddFunction(const AnFunction: TrpCustomFunction);
    procedure Clear;
    //Сброс списка функций. Ощичается список и кэш функций
    procedure Drop;
    property Items[Index: Integer]: TrpCustomFunction read Get_Function;
  end;

var
  glbFunctionList: IScriptFunctions;

implementation

initialization
  glbFunctionList := nil;

end.
