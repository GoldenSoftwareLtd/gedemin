unit inst_memsize;

interface

uses
  Windows;

function GetPageBuffers(AnBufferSize: Word): Word;

implementation

function GetPageBuffers(AnBufferSize: Word): Word;

const
  MaxBufSize   = 8192;
  ServerMem    = 1024 * 1024 * 8;

var
  MemoryStatus: TMemoryStatus;

begin
  if AnBufferSize = 0 then
    Result := 0
  else begin
    FillChar(MemoryStatus, SizeOf(MemoryStatus), 0);
    MemoryStatus.dwLength := SizeOf(MemoryStatus);
    GlobalMemoryStatus(MemoryStatus);

    if MemoryStatus.dwAvailPhys > ServerMem then
      Result := (MemoryStatus.dwAvailPhys - ServerMem) div (AnBufferSize * 2)
    else
      Result := 0;

    if Result > MaxBufSize then
      Result := MaxBufSize;
  end;
end;

end.
