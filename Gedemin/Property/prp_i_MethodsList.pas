// ShlTanya, 26.02.2019

unit prp_i_MethodsList;

interface

uses
  Contnrs, Classes;

type
  IMethodsList = interface
  ['{6E7822E8-D843-11D5-B62A-00C0DF0E09D1}']
    function Get_Count: Integer;
    function AddProcedure(Name: String): integer;
    procedure Delete(const Index: Integer);
    procedure Clear;
    property Count: Integer read Get_Count;
  end;

  IgsTypeInfo = interface
  ['{6E7822EC-D843-11D5-B62A-00C0DF0E09D1}']
    procedure GetMethodsList(const AiMethodsList, AiEventsList: IMethodsList);
  end;

procedure RegisterGsClass(AClass: TPersistentClass);
procedure RegisterGsClasses(AClasses: array of TPersistentClass);
function GetGsClass(const AClassName: string): TPersistentClass;

var
  gsClassList: TClassList;

implementation

uses
  SysUtils;

procedure RegisterGsClass(AClass: TPersistentClass);
begin
  if not Assigned(gsClassList) then
    gsClassList := TClassList.Create;

  with gsClassList do
    if IndexOf(AClass) = -1 then Add(AClass);
  Classes.RegisterClass(AClass);
end;

procedure RegisterGsClasses(AClasses: array of TPersistentClass);
var
  I: Integer;
begin
  for I := Low(AClasses) to High(AClasses) do
    RegisterGsClass(AClasses[I]);
end;

function GetGsClass(const AClassName: string): TPersistentClass;
var
  I: Integer;
begin
  for I := 0 to gsClassList.Count - 1 do
  begin
    Result := TPersistentClass(gsClassList.Items[I]);
    if Result.ClassNameIs(AClassName) then Exit;
  end;
  Result := nil;
end;

initialization

finalization
  FreeAndNil(gsClassList);

end.
