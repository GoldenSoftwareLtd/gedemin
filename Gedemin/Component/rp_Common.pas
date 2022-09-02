// ShlTanya, 20.02.2019

unit rp_Common;

interface

function EditFile(FileName: String): Boolean;
function EditBlobFile(var BLOB: String): Boolean;

implementation

uses
  Windows, SysUtils, Forms, ShellApi, msg_attachment
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

function EditBlobFile(var BLOB: String): Boolean;
var
  FileName: String;
  NameRTFChar, Path: array [0..255] of Char;
begin
  GetTempPath(SizeOf(Path), Path);
  GetTempFileName(Path, 'rtf', 0, NameRTFChar);

  FileName := StrPas(NameRTFChar);
  FileName := Copy(FileName, 0, Length(FileName) - 3);
  FileName := FileName + 'rtf';

  attSaveToFile(FileName, Blob);

  Result := EditFile(FileName);

  if Result then
    Result := MessageBox(Application.Handle, 'Сохранить изменения?', 'Внимание',
      MB_YESNO or MB_ICONQUESTION) = idYes;

  if Result then
    BLOB := attLoadFromFile(FileName)
end;

function EditFile(FileName: String): Boolean;
var
  Operation: array[0..4] of Char;
  Directory: array[0..254] of Char;
begin
  StrPCopy(Operation, 'open');
  StrPCopy(Directory, ExtractFilePath(FileName));
  FileName := FileName + #0;
  if ShellExecute(Application.Handle, Operation, @FileName[1], nil, Directory, SW_SHOW) <= 32 then
  begin
    MessageBox(Application.Handle,
      'Невозможно открыть файл.',
      'Внимание', MB_OK or MB_ICONEXCLAMATION);
    Result := False
  end
  else
    Result := True;
end;

{procedure EditFile(FileName: String);
var
  Operation: array[0..4] of Char;
  Directory: array[0..254] of Char;

begin
  SetLength(FileName, 400);
  SetLength(FileName, GetTempPath(399, @FileName[1]));
  FileName := IncludeTrailingBackslash(FileName) + ibsqlAttachmentData.Fields[1].AsString;
  attSaveToFile(FileName, ibsqlAttachmentData.Fields[0].AsString);
  FileList.Add(FileName);

  StrPCopy(Operation, 'open');
  StrPCopy(Directory, ExtractFilePath(FileName));
  FileName := FileName + #0;
  if ShellExecute(Handle, Operation, @FileName[1], nil, Directory, SW_SHOW) <= 32 then
  begin
    MessageBox(Handle,
      'Невозможно открыть файл.',
      'Внимание', MB_OK or MB_ICONEXCLAMATION);
  end;
end;}

end.
