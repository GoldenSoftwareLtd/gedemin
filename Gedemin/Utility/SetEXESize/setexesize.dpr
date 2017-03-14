program setexesize;
{$APPTYPE CONSOLE}
uses
  Classes, SysUtils;

var
  MS: TMemoryStream;
  S, EC: Integer;
  B: Byte;
begin
  EC := 1;
  S := StrToIntDef(ParamStr(2), 0);

  if (ParamCount < 2) or (not FileExists(ParamStr(1)))
    or (S = 0) then
  begin
    Writeln('Copyright (c) 2015-2017 by Golden Software of Belarus, Ltd');
    Writeln('Usage: setexesize <exe_file_name> <new_size_in_bytes>');
    exit;
  end;

  MS := TMemoryStream.Create;
  try
    try
      MS.LoadFromFile(ParamStr(1));
      MS.Position := MS.Size;

      if MS.Size < S then
      begin
        RandSeed := S;
        while MS.Position < S do
        begin
          B := Random(256);
          MS.WriteBuffer(B, 1);
        end;
        MS.SaveToFile(ParamStr(1));
        EC := 0;
      end
      else if MS.Size > S then
        Writeln('Size of the file exceeds specified limit!');
    except
      on E: Exception do
        Writeln(E.Message);
    end;
  finally
    MS.Free;
  end;

  if EC <> 0 then
  begin
    DeleteFile(ParamStr(1));
    Halt(EC);
  end;
end.