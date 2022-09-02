// ShlTanya, 27.02.2019

unit scrOpenSaveDialog_unit;

interface

uses
  Classes, SysUtils, Dialogs, contnrs, ComServ, ComObj, Gedemin_TLB;

type
  TscrPublicVariables = class(TAutoObject, IscrPublicVariables)
  private
    FStrings: TStringList;

  protected
    function  Value(const Name: WideString): OleVariant; safecall;
    procedure AddValue(const Name: WideString; Value: OleVariant); safecall;
    procedure Clear; safecall;
    procedure DeleteValue(const Name: WideString); safecall;
    function  ValueExists(const ValueName: WideString): WordBool; safecall;
    function  ValueNames: WideString; safecall;

  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  gdcOLEClassList;

{ TscrPublicVariables }

procedure TscrPublicVariables.AddValue(const Name: WideString;
  Value: OleVariant);
var
  I: Integer;
  P: PVariant;
begin
  I := FStrings.IndexOf(Name);

  if I = -1 then
    I := FStrings.Add(Name)
  else
  begin
    P := PVariant(FStrings.Objects[I]);
    if P <> nil then
      Dispose(P);
  end;

  New(P);
  P^ := Value;
  FStrings.Objects[I] := TObject(P);
end;

procedure TscrPublicVariables.Clear;
var
  I: Integer;
  P: PVariant;
begin
  for I := 0 to FStrings.Count - 1 do
  begin
    P := PVariant(FStrings.Objects[I]);
    if P <> nil then
      Dispose(P);
  end;
  FStrings.Clear;
end;

constructor TscrPublicVariables.Create;
begin
  inherited;
  FStrings := TStringList.Create;
  FStrings.Sorted := True;
  FStrings.Duplicates := dupError;
end;

procedure TscrPublicVariables.DeleteValue(const Name: WideString);
var
  P: PVariant;
  I: Integer;
begin
  I := FStrings.IndexOf(Name);
  if I <> -1 then
  begin
    P := PVariant(FStrings.Objects[I]);
    if P <> nil then
      Dispose(P);
    FStrings.Delete(I);  
  end;
end;

destructor TscrPublicVariables.Destroy;
begin
  Clear;
  FStrings.Free;
  inherited;
end;

function TscrPublicVariables.Value(const Name: WideString): OleVariant;
var
  P: PVariant;
  I: Integer;
begin
  Result := Unassigned;
  I := FStrings.IndexOf(Name);
  if I <> -1 then
  begin
    P := PVariant(FStrings.Objects[I]);
    if P <> nil then
      Result := P^;
  end;
end;

function TscrPublicVariables.ValueExists(
  const ValueName: WideString): WordBool;
begin
  Result := FStrings.IndexOf(ValueName) > -1;
end;

function TscrPublicVariables.ValueNames: WideString;
begin
  Result := FStrings.CommaText;
end;

initialization
  TAutoObjectFactory.Create(ComServer, TscrPublicVariables, CLASS_scr_PublicVariables,
    ciMultiInstance, tmApartment);
end.
