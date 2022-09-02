// ShlTanya, 24.02.2019

unit msg_filelist;

interface

uses
  Classes;

var
  FileList: TStringList;

implementation

uses
  SysUtils;

procedure ClearList;
var
  I: Integer;
begin
  for I := 0 to FileList.Count - 1 do
  try
    DeleteFile(FileList[I]);
  except
    //...
  end;
  FileList.Free;
end;

initialization
  FileList := TStringList.Create;

finalization
  ClearList;
end.
