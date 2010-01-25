
unit prp_methods;

interface

uses
  classes, Gedemin_TLB, Windows;

function IgsStringsToTStrings(const AnOleStrings: IgsStrings): TStrings;
function TStringsToIgsStrings(const AStrings: TStrings): IgsStrings;
function InterfaceToObject(AValue: IDispatch): TObject;

implementation

uses
  Dialogs, sysutils, dbctrls, gdcOLEClassList;

function  IgsStringsToTStrings(const AnOleStrings: IgsStrings): TStrings;
begin
  Result := InterfaceToObject(AnOleStrings) as TStrings;
end;

function  TStringsToIgsStrings(const AStrings: TStrings): IgsStrings;
begin
  Result := GetGDCOleObject(AStrings) as IgsStrings;
end;

function InterfaceToObject(AValue: IDispatch): TObject;
begin
  if AValue <> nil then
  begin
    try
      Result := TObject((AValue as IgsObject).Self);
    except
      raise Exception.Create('Передан некорректный интерфейс');
    end
  end else
    Result := nil;
//    raise Exception.Create('Переданный объект не существует');
end;

end.
