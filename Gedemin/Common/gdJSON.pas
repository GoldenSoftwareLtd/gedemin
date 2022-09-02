// ShlTanya, 24.02.2019

unit gdJSON;

interface

uses
  Classes, DB;

type
  TgdJSONWriter = class
  private
    FSL: TStringList;
    FWasValue: Boolean;

  public
    constructor Create(ASL: TStringList);

    procedure BeginObject;
    procedure EndObject;
    procedure BeginArray(const AName: String);
    procedure EndArray;
    procedure AddValue(const AName, AValue: String);
    procedure AddField(F: TField);
  end;

function EscapeJSON(const S: String): String;

implementation

function EscapeJSON(const S: String): String;
var
  I, J: Integer;
begin
  SetLength(Result, Length(S) * 2 + 2);
  J := 2;
  for I := 1 to Length(S) do
  begin
    case S[I] of
      '"':
      begin
        Result[J] := '\';
        Result[J + 1] := '"';
        Inc(J, 2);
      end;

      '\':
      begin
        Result[J] := '\';
        Result[J + 1] := '\';
        Inc(J, 2);
      end;

      {'/':
      begin
        Result[J] := '\';
        Result[J + 1] := '/';
        Inc(J, 2);
      end;}

      #10:
      begin
        Result[J] := '\';
        Result[J + 1] := 'n';
        Inc(J, 2);
      end;

      #13:
      begin
        Result[J] := '\';
        Result[J + 1] := 'r';
        Inc(J, 2);
      end;

      #09:
      begin
        Result[J] := '\';
        Result[J + 1] := 't';
        Inc(J, 2);
      end;

      #08:
      begin
        Result[J] := '\';
        Result[J + 1] := 'b';
        Inc(J, 2);
      end;

      #12:
      begin
        Result[J] := '\';
        Result[J + 1] := 'f';
        Inc(J, 2);
      end;

    else
      if Ord(S[I]) < 32 then
        Result[J] := ' '
      else
        Result[J] := S[I];
      Inc(J);
    end;
  end;
  Result[1] := '"';
  Result[J] := '"';
  SetLength(Result, J);
end;

{ TgdJSONWriter }

procedure TgdJSONWriter.AddField(F: TField);
begin
  AddValue(F.Name, F.AsString);
end;

procedure TgdJSONWriter.AddValue(const AName, AValue: String);
begin
  if FWasValue and (FSL.Count > 0) then
    FSL[FSL.Count - 1] := FSL[FSL.Count - 1] + ',';
  FSL.Add('"' + AName + '":' + EscapeJSON(AValue));
  FWasValue := True;
end;

procedure TgdJSONWriter.BeginArray(const AName: String);
begin
  if FWasValue and (FSL.Count > 0) then
    FSL[FSL.Count - 1] := FSL[FSL.Count - 1] + ',';
  FSL.Add('"' + AName + '":[');
  FWasValue := False;
end;

procedure TgdJSONWriter.BeginObject;
begin
  if (FSL.Count > 0) and (FSL[FSL.Count - 1] = '}') then
    FSL[FSL.Count - 1] := '},';
  FSL.Add('{');
  FWasValue := False;
end;

constructor TgdJSONWriter.Create(ASL: TStringList);
begin
  FSL := ASL;
end;

procedure TgdJSONWriter.EndArray;
begin
  FSL.Add(']');
  FWasValue := True;
end;

procedure TgdJSONWriter.EndObject;
begin
  FSL.Add('}');
  FWasValue := False;
end;

end.