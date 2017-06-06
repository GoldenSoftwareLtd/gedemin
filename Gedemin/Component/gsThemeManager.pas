
unit gsThemeManager;

interface

uses
  Classes, Graphics;

type
  TgsCSS = class(TObject)
  end;

  TgsThemeManager = class(TComponent)
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    class function AdjustColor(const Cl: TColor; Delta: Integer): TColor;
    class function MixColors(const Cl1, Cl2: TColor): TColor;
  end;

var
  ThemeManager: TgsThemeManager;

procedure Register;

implementation

uses
  Windows;

procedure Register;
begin
  RegisterComponents('xTool-2', [TgsThemeManager]);
end;

{ TgsThemeManager }

constructor TgsThemeManager.Create(AnOwner: TComponent);
begin
  inherited;

  if ThemeManager = nil then
    ThemeManager := Self;
end;

destructor TgsThemeManager.Destroy;
begin
  if ThemeManager = Self then
    ThemeManager := nil;
  inherited;
end;

class function TgsThemeManager.AdjustColor(const Cl: TColor; Delta: Integer): TColor;

  function _f(const I: Integer): Integer;
  begin
    if I < 0 then Result := 0
    else if I > 255 then Result := 255
    else Result := I;
  end;

var
  vRGB: Longint;
  R, G, B: Integer;
begin
  vRGB := ColorToRGB(Cl);
  R := GetRValue(vRGB);
  G := GetGValue(vRGB);
  B := GetBValue(vRGB);
  if (R + G + B) div 3 < 150 then
    Delta := - Delta;
  R := _f(R + Delta);
  G := _f(G + Delta);
  B := _f(B + Delta);
  Result := RGB(R, G, B);
end;

class function TgsThemeManager.MixColors(const Cl1, Cl2: TColor): TColor;
var
  vRGB1, vRGB2: Longint;
begin
  vRGB1 := ColorToRGB(Cl1);
  vRGB2 := ColorToRGB(Cl2);
  Result := RGB(
    (GetRValue(vRGB1) + GetRValue(vRGB2)) div 2,
    (GetGValue(vRGB1) + GetGValue(vRGB2)) div 2,
    (GetBValue(vRGB1) + GetBValue(vRGB2)) div 2
  );
end;

end.
