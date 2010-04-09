
{

  Copyright (c) 1999 by Golden Software of Belarus

  Module

    newDateEdits.pas

  Abstract

    visual Component - DataBase EditField to input Date more faster

  Author

    Alex Tsobkalo (January-1999)

  Revisions history

    10-Dec-98  Initial Version

}

unit DateDBEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, DBCtrls, DB;

type
  TDateDBEdit = class(TDBEdit)
  private
    D, M, Y: Word;
    sD, sM, sY: string;
    FFullYear: Boolean;
    procedure SetFullYear(const Value: Boolean);

  protected
    procedure Change; override;
    procedure Loaded; override;
    procedure KeyPress(var Key: Char); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;

  public
    constructor Create(anOwner: TComponent); override;
    function GoodValue(Value: Word): Boolean;

  published
    property FullYear: Boolean read FFullYear write SetFullYear
      default False;
  end;

procedure Register;

implementation

//   CREATE
constructor TDateDBEdit.Create(anOwner: TComponent);
begin
  inherited;
  FFullYear := False;
end;

//   SET_FULL_YEAR
procedure TDateDBEdit.SetFullYear(const Value: Boolean);
begin
  if FFullYear <> Value then FFullYear := Value;
end;

//   LOADED
procedure TDateDBEdit.Loaded;
begin
  inherited;
  DecodeDate(Now, Y, M, D);
  if D < 10 then sD := '0' + IntToStr(D)
  else sD := IntToStr(D);
  if M < 10 then sM := '0' + IntToStr(M)
  else sM := IntToStr(M);
  if FullYear then sY := IntToStr(Y)
  else sY := Copy(IntToStr(Y), 3, 2);
end;

//   CHANGE
procedure TDateDBEdit.Change;
begin
  inherited;
  if (Length(Text) = 2) or (Length(Text) = 5) then begin
    Text := Text + '.';
    SelStart := Length(Text);
  end;
end;

//   KEY_DOWN
procedure TDateDBEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_DELETE) or (Key = VK_LEFT) or (Key = VK_RIGHT) or (Key = VK_UP) or
    (Key = VK_DOWN) or (Key = VK_HOME) or (Key = VK_END) then
      Key := VK_CLEAR;
  inherited;
end;

//   GOOD_VALUE
function TDateDBEdit.GoodValue(Value: Word): Boolean;
begin
  Result := False;
  case Length(Text) of
    0:
      if Value < 4 then Result := True;
    1:
      case StrToInt(Text[1]) of
        0:
          if Value <> 0 then Result := True;
        3:
          if Value < 2 then Result := True;
        else
          Result := True;
      end;
    3:
      if Value < 2 then Result := True;
    4:
      case StrToInt(Text[4]) of
        0:
          if Value > 0 then Result := True;
        1:
          if Value < 3 then Result := True;
      end;
  end;
end;

//   KEY_PRESS
procedure TDateDBEdit.KeyPress(var Key: Char);
var
  Len: Integer;
begin
  inherited;
  if (Ord(Key) = 8) or (Ord(Key) in [48..57]) or (Ord(Key) = 32) and
     not (DataSource.DataSet.State in [dsEdit, dsInsert]) then DataSource.DataSet.Edit;

  if SelText  = Text then Text := '';

  Len := Length(Text);
  SelStart := Len;

  case Ord(Key) of
    8:
      begin
        if Len in [0..3] then Text := '';
        if Len in [4..6] then Text := Copy(Text, 1, 3);
        if Len > 6 then Text := Copy(Text, 1, 6);
      end;

    32:
      begin
        if Len < 3 then Text := sD;
        if Len in [3..5] then Text := Copy(Text, 1, 3) + sM;
        if Len > 5 then
          case FFullYear of
            True:
              if Len < 10 then Text := Copy(Text, 1, 6) + sY;

            False:
              if Len < 8 then Text := Copy(Text, 1, 6) + sY;
          end;
        Key := #0;
      end;

    48..57:
      begin
        if (Len >= Length(sD + sM + sY) + 2) or (not GoodValue(StrToInt(Key))) then Key := #0;
      end;

    else Key := #0;
  end;

  SelStart := Length(Text);
end;


//   REGISTER
procedure Register;
begin
  RegisterComponents('xTools-DB', [TDateDBEdit]);
end;

end.
