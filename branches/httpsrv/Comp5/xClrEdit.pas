
{++

  Copyright (c) 1996-97 by Golden Software of Belarus

  Module

    xclredit.pas

  Abstract

    A TEdit that allows to edit color as text.

  Author

    Anton Smirnov (1-Feb-96)

  Contact address

    andreik@gs.minsk.by

  Revisions history

    1.00    16-Feb-96    anton,     Initial version.
                         andreik
    1.02    20-Oct-97    andreik    Ported to Delphi32.

--}

unit xClrEdit;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

const
  DefColor = clWhite;

type
  TxColorEdit = class(TEdit)
  private
    FColor: TColor;
    InitialColor: TColor;
    OldOnChange: TNotifyEvent;
    OldOnEnter: TNotifyEvent;
    OldOnExit: TNotifyEvent;

    procedure SetColor(AColor: TColor);

    procedure DoOnChange(Sender: TObject);
    procedure DoOnEnter(Sender: TObject);
    procedure DoOnExit(Sender: TObject);

  protected
    procedure Loaded; override;
    procedure CreateWnd; override;

  public
    constructor Create(AOwner: TComponent); override;

  published
    property Color: TColor read FColor write SetColor
      default DefColor;
end;

procedure Register;

implementation

{ Auxiliry functions -------------------------------------}

{ deletes all leading and trailing white spaces }
function StripStr(const S: String): String;
var
  B, E: Integer;
begin
  B := 1;
  while (B < Length(S)) and (S[B] in [#32, #9]) do Inc(B);
  E := Length(S);
  while (E >= B) and (S[E] in [#32, #9]) do Dec(E);
  Result := Copy(S, B, E - B + 1);
end;

function ColorAsString(AColor: TColor): String;
begin
  Result := ColorToString(AColor);
  { now we need in to strip leading cl prefix or
    remove first two zeroes in a long hex number }
  if (Length(Result) > 2) and (UpCase(Result[1]) = 'C') and (UpCase(Result[2]) = 'L') then
    Delete(Result, 1, 2)
  else if (Length(Result) > 7) and (Result[1] = '$') and (Result[2] = '0')
    and (Result[3] = '0') then Delete(Result, 2, 2);
end;

{ converts give string into TColor value
  string can be either color name or numeric
  value (decimal or hexadecimal) that represents
  color in RGB format (i.e. $FFFF00 is RGB($FF, $FF, 00)
  or Yellow color). If specified string is not
  valid number nor valid color name value
  TColor(-1) will be returned. }
function StringAsColor(S: String): TColor;
var
  Code: Integer;
begin
  if S <> '' then
  begin
    S := UpperCase(StripStr(S));
    if not (S[1] in ['0'..'9', '$']) then
    begin
      if Copy(S, 1, 2) <> 'CL' then S := 'CL' + S;
      if not IdentToColor(S, LongInt(Result)) then
        Result := -1;
    end else
    begin
      Val(S, Result, Code);
      if (Code <> 0) or (Result > $FFFFFF) or (Result < 0) then
        Result := -1;
    end;
  end else
    Result := -1;
end;

{ TxColorEdit --------------------------------------------}

constructor TxColorEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FColor := DefColor;
  InitialColor := DefColor;
  Text := ColorAsString(FColor);
end;

procedure TxColorEdit.Loaded;
begin
  inherited Loaded;
  InitialColor := FColor;
end;

procedure TxColorEdit.CreateWnd;
begin
  inherited CreateWnd;

  if not (csDesigning in ComponentState) then
  begin
    OldOnChange := OnChange;
    OnChange := DoOnChange;

    OldOnEnter := OnEnter;
    OnEnter := DoOnEnter;

    OldOnExit := OnExit;
    OnExit := DoOnExit;
  end;  
end;

procedure TxColorEdit.DoOnChange(Sender: TObject);
begin
  FColor := StringAsColor(Text);

  if FColor = -1 then FColor := InitialColor;

  if Focused and Assigned(OldOnChange) then
    OldOnChange(Self);
end;

procedure TxColorEdit.DoOnEnter(Sender: TObject);
begin
  if Assigned(OldOnEnter) then OldOnEnter(Self);
  DoOnChange(Self);
end;

procedure TxColorEdit.DoOnExit(Sender: TObject);
begin
  FColor := StringAsColor(Text);

  if FColor = -1 then Color := InitialColor;

  if Assigned(OldOnExit) then OldOnExit(Self);
end;

procedure TxColorEdit.SetColor(AColor: TColor);
begin
  if AColor <> FColor then
  begin
    FColor := AColor;
    Text := ColorAsString(FColor);
  end;
end;

{ Registration -------------------------------------------}

procedure Register;
begin
  RegisterComponents('x-VisualControl', [TxColorEdit]);
end;

end.

