// as discussed here http://stackoverflow.com/questions/10199531/how-can-i-improve-the-wmi-performance-using-delphi

unit gd_wmi;

interface

procedure InitWMI;
procedure DoneWMI;
function GetWMIString(const WMIClass, WMIProperty: String): String;

implementation

uses
  ActiveX, ComObj, SysUtils;

var
  FSWbemLocator: OLEVariant;
  FWMIService: OLEVariant;

procedure InitWMI;
begin
  if VarIsEmpty(FSWbemLocator) then
  begin
    FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
    FWMIService := FSWbemLocator.ConnectServer('localhost', 'root\CIMV2', '', '');
  end;
end;

procedure DoneWMI;
begin
  FSWbemLocator := Unassigned;
  FWMIService := Unassigned;
end;

function GetWMIstring(const WMIClass, WMIProperty:string): string;
const
  wbemFlagForwardOnly = $00000020;
var
  FWbemObjectSet: OLEVariant;
  FWbemObject   : OLEVariant;
  oEnum         : IEnumVariant;
  iValue        : LongWord;
begin;
  InitWMI;

  Result:='';

  FWbemObjectSet := FWMIService.ExecQuery(
    Format('SELECT %s FROM %s', [WMIProperty, WMIClass]), 'WQL',
    wbemFlagForwardOnly);

  oEnum := IUnknown(FWbemObjectSet._NewEnum) as IEnumVariant;

  if oEnum.Next(1, FWbemObject, iValue) = 0 then
    if not VarIsNull(FWbemObject.Properties_.Item(WMIProperty).Value) then
      Result := FWbemObject.Properties_.Item(WMIProperty).Value;

  FWbemObject := Unassigned;
end;

initialization
  FSWbemLocator := Unassigned;
  FWMIService := Unassigned;

finalization
  FSWbemLocator := Unassigned;
  FWMIService := Unassigned;
end.