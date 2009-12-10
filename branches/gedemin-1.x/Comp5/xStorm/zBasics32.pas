{++

  Module

    zBasics.pas

  Abstract

    Basic functions for all zStorm components.

  Author

    Vladimir Belyi (4 October 1996)

  Uses

    xBasics - a unit from xStorm collection

  Revisions history

    1.00   4-Oct-1996  belyi   Initial version
    1.01  10-Oct-1996  belyi   MinFloat and MaxFloat
    1.02  22-Dec-1996  belyi   DrawHyperText proc. DrawFloat proc.
    3.00  16-mar-1998  belyi   Delphi 3.0; SI units

  Known bugs

    -

  Wishes

    -

--}

unit zBasics32;

interface

uses
  SysUtils, zMath;

{
  values units:

  mass      - kg
  length    - m
  energy    - J

  < additional >

  speed     - m/s
}

const
  z_amu = 1.6605655e-27;

  z_eV = 1.60217733e-19;         // energy in 1 eV

  z_a0 = 0.52917706e-10;         // first Bohr's orbit
  z_v0 = 2.29e6;                 // speed an first Bohr's orbit

  z_e = 1.6e-19;                 // electron charge

  z_me = 0.9109534e-30;          // Mass of electron
  z_mn = 1.6749543e-27;          // Mass of neutron
  z_mp = 1.6726485e-27;          // Mass of proton

  z_h = 6.626176e-34;            // Plank's constant
  z_h_ = z_h / (2 * Pi);         // Plank's constant with 'plank'

  z_eps0 = 8.854187817e-12;      // dielectric permit.
  z_k = 1 / (4 * Pi * z_eps0);   // constant in Coulomb's law

  z_E0 = z_me * (z_e * z_e * z_e * z_e) / (2 * z_h_ * z_h_);

function Power(x, n: Float): Float;
function Sign(Value: Float): ShortInt;

function MinFloat(const a: array of Float): Float;
function MaxFloat(const a: array of Float): Float;

function MinInt(a, b: Integer): Integer;
function MaxInt(a, b: Integer): Integer;

{ the lowest level has number 0 }
function BohrEnergy(Z, n: Float): Float;

type
  EzStorm = class(Exception);
  EzBasics = class(Exception);

implementation

function Power(x, n: Float): Float;
begin
  if x > 0 then
    Result := Exp( n * Ln(x) )
  else if (x = 0) and (n > 0) then
    Result := 0
  else
    raise EzBasics.Create('Failed to calculate the power - negative argument.');
end;

function Sign(Value: Float): ShortInt;
begin
  if Value < 0 then Result := -1
  else if Value > 0 then Result := 1
  else Result := 0;
end;

function MinFloat(const a: Array of Float): Float;
var
  I: Integer;
begin
  Result := a[ Low(a) ];
  for i := Low(a) to High(a) do
    if a[i] < Result then Result := a[i];
end;

function MaxFloat(const a: Array of Float): Float;
var
  I: Integer;
begin
  Result := a[ Low(a) ];
  for i := Low(a) to High(a) do
    if a[i] > Result then Result := a[i];
end;

function MinInt(a, b: Integer): Integer;
begin
  if a < b then
    Result := a
  else
    Result := b;
end;

function MaxInt(a, b: Integer): Integer;
begin
  if a > b then
    Result := a
  else
    Result := b;
end;

function BohrEnergy(Z, n: Float): Float;
begin
  Result := z_E0 * Z * Z / ((n+1) * (n+1));
end;

end.

