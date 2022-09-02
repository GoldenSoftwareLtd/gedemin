// ShlTanya, 09.03.2019

{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module


  Abstract

    Gedemin project.

  Author

    Karpuk Alexander

  Revisions history

    1.00    30.05.03    tiptop        Initial version.
--}
unit wiz_Utils_unit;

interface
uses classes, Sysutils;

procedure ParseString(const Str: string; const S: TStrings);
implementation

procedure ParseString(const Str: string; const S: TStrings);
var
  I, B, L: Integer;
begin
  if Str > '' then
  begin
    I := 1; B := 1; L := Length(Str);
    while I <= L do
    begin
      if Str[I] = ';' then
      begin
        if Trim(Copy(Str, B, I - B)) > '' then
          S.Add(Trim(Copy(Str, B, I - B)));
        B := I + 1;
      end;
      Inc(I);
    end;
    if I > B then  S.Add(Trim(Copy(Str, B, I - B)));
  end;
end;
end.
