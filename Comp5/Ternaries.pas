
unit Ternaries;

interface

uses
  Graphics;

function Ternary(const Cond: Boolean; const A, B: Integer): Integer; overload;
function Ternary(const Cond: Boolean; const A, B: Double): Double; overload;
function Ternary(const Cond: Boolean; const A, B: String): String; overload;
function Ternary(const Cond: Boolean; const A, B: Char): Char; overload;

implementation

function Ternary(const Cond: Boolean; const A, B: Integer): Integer;
begin
  if Cond then
    Result := A
  else
    Result := B;
end;

function Ternary(const Cond: Boolean; const A, B: Double): Double;
begin
  if Cond then
    Result := A
  else
    Result := B;
end;

function Ternary(const Cond: Boolean; const A, B: String): String;
begin
  if Cond then
    Result := A
  else
    Result := B;
end;

function Ternary(const Cond: Boolean; const A, B: Char): Char;
begin
  if Cond then
    Result := A
  else
    Result := B;
end;

end.

