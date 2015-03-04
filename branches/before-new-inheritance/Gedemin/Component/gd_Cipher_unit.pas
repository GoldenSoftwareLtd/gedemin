unit gd_Cipher_unit;

interface

uses
  gd_SetDatabase;

procedure CipherBuffer(const AnSource: TDnByteArray; var AnResult: TDnByteArray);
procedure UncipherBuffer(const AnSource: TDnByteArray; var AnResult: TDnByteArray);

implementation

uses
  ZLib, Classes;

procedure CipherBuffer(const AnSource: TDnByteArray; var AnResult: TDnByteArray);
var
  CompStr: TZCompressionStream;
  MStr: TMemoryStream;
  LocSize: Integer;
begin
  SetLength(String(AnResult), 0);
  try
    if Length(AnSource) > 0 then
    begin
      MStr := TMemoryStream.Create;
      try
        LocSize := Length(AnSource);
        MStr.Write(LocSize, SizeOf(LocSize));
        CompStr := TZCompressionStream.Create(MStr);
        try
          CompStr.Write(AnSource[0], LocSize);
        finally
          CompStr.Free;
        end;
        SetLength(String(AnResult), MStr.Size);
        MStr.Position := 0;
        if Mstr.Size > 0 then
          MStr.ReadBuffer(AnResult[0], MStr.Size);
      finally
        MStr.Free;
      end;
    end;
  except
  end;
end;

procedure UncipherBuffer(const AnSource: TDnByteArray; var AnResult: TDnByteArray);
var
  DecompStr: TZDecompressionStream;
  MStr: TMemoryStream;
  LocSize: Integer;
begin
  SetLength(String(AnResult), 0);
  try
    if Length(AnSource) > 0 then
    begin
      MStr := TMemoryStream.Create;
      try
        MStr.Write(AnSource[0], Length(AnSource));
        MStr.Position := 0;
        MStr.ReadBuffer(LocSize, SizeOf(LocSize));
        SetLength(String(AnResult), LocSize);
        DecompStr := TZDecompressionStream.Create(MStr);
        try
          DecompStr.ReadBuffer(AnResult[0], LocSize);
        finally
          DecompStr.Free;
        end;
      finally
        MStr.Free;
      end;
    end;
  except
  end;
end;

end.
