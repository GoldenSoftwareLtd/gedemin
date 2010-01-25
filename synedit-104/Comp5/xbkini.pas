
unit Xbkini;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, IniFiles, xCommon_anj;

type
  TxBookkeepIni = class(TComponent)
  private
    { Private declarations }
    FIniFile: TIniFile;
    FReferencyDir: String;
    FTypeReferency: Integer;

    function GetWorkingDir: String;
    function GetMainDir: String;
    function GetSystemCode: Integer;
    procedure SetTypeReferency(aValue: Integer);
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(aOwner: TComponent);
      override;
    destructor Destroy;
      override;
  published
    { Published declarations }
    property WorkingDir: String read GetWorkingDir;
    property MainDir: String read GetMainDir;
    property ReferencyDir: String read FReferencyDir write FReferencyDir;
    property TypeReferency: Integer read FTypeReferency write SetTypeReferency;
    property SystemCode: Integer read GetSystemCode;
  end;

procedure Register;

implementation

constructor TxBookkeepIni.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FReferencyDir := '';
  FTypeReferency := 1;
  FIniFile := TIniFile.Create(
    copy(Application.ExeName, 1, Pos('.', Application.ExeName))+'ini');
end;

destructor TxBookkeepIni.Destroy;
begin
  if FIniFile <> nil then
  begin
    FIniFile.Free;
    FIniFile := nil;
  end;  
  inherited Destroy;
end;

function TxBookkeepIni.GetWorkingDir: String;
begin
  if FIniFile <> nil then
    Result := FIniFile.ReadString(PrimeSection, 'WorkBookkeepDir', '')
  else
    Result := '';
end;

function TxBookkeepIni.GetMainDir: String;
begin
  if FIniFile <> nil then
    Result := FIniFile.ReadString(PrimeSection, 'MainBookkeepDir', '')
  else
    Result := '';
end;

function TxBookkeepIni.GetSystemCode: Integer;
begin
  if FIniFile <> nil then
    Result := FIniFile.ReadInteger(PrimeSection, 'CodeSystem', -1)
  else
    Result := -1;  
end;

procedure TxBookkeepIni.SetTypeReferency(aValue: Integer);
begin
  if (aValue < 1) or (aValue > CountKAURef) then
    raise Exception.Create('Value is out of range');

  FTypeReferency:= aValue;
  FReferencyDir:= '';
  case FTypeReferency of
  kau_Klient : FReferencyDir:= MainDir;
  kau_Object : FReferencyDir:= WorkingDir;
  kau_Goods : FReferencyDir:= MainDir;
  kau_MainMean : FReferencyDir:= WorkingDir;
  kau_People : FReferencyDir:= MainDir;
  kau_IndExp : FReferencyDir:= MainDir;
  kau_DeptRef : FReferencyDir:= MainDir;
  kau_Otrsl : FReferencyDir:= MainDir;
  kau_Currency : FReferencyDir:= MainDir;
  kau_KindOperation : FReferencyDir:= MainDir;
  kau_KindPayment : FReferencyDir:= MainDir;
  kau_GroupEquipment : FReferencyDir:= MainDir;
  kau_ChildDepartment: FReferencyDir:= MainDir;
  kau_KindProduction: FReferencyDir:= MainDir;
  end;
end;

procedure Register;
begin
  RegisterComponents('xTool', [TxBookkeepIni]);
end;

end.
