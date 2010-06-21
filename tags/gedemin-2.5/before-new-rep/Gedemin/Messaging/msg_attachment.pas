
(*

  ћы будзем захоҐваць атачменты €к ЅЋќЅы Ґ базе дадзеных.
  ѕакольк≥ большасьць атачментаҐ мус€ць быць тэкставым≥ файлам≥
  (ц≥ –“‘, ц≥ ƒќ ) дык цалкам лаг≥чна Ґпаковываць ≥х перад
  зап≥сам у базу.

   ожны блок дадзеных атачмента мы будзем пап€рэджваць зап≥сам
  з подп≥сам, нумарам вэрс≥≥ аттачмэнта.

*)

unit msg_attachment;                       

interface

uses
  Classes;

const
  attSignature           = $AF049912; // подп≥с патрэбен каб апрацоҐваць стары€ атачменты, без загалоҐка
  attVersion             = $01;       // б€гуча€ вэрс≥€

  attNoCompression       = $00;       // дадзены€ не Ґпакованы€
  attZLibCompression     = $01;       // упакованы€ «этЋ≥б

  attUnknownDataType     = $00;       // currently only this type is supported

type
  TAttachmentHeader = record
    Signature: Longword;
    Version: Byte;
    Compression: Byte;
    DataType: Byte;
    Size: Longint;
    CompressedSize: Longint;
    ReservedB: Byte;
    ReservedL: Longint;
  end;

// загружае дадзены€ з файла, упакоҐвае ≥ дадае загаловак
// выхадную страку можна зап≥сваць у базу Ґ €касьц≥ дадзеных аттачмэнта
function attLoadFromFile(const AFileName: String): String;
function attLoadFromStream(const Stream: TStream): String;

// б€рэ страку €ка€ Ґтрымл≥вае аттачмэнт
// ≥ захоҐвае Ґ файл, кал≥ трэба распакоҐвае
// апрацоҐвае атачмэнты з загалоҐкам ≥ без €го
// адрозн≥вае па на€Ґнасьц≥ подп≥су
procedure attSaveToFile(const AFileName, AData: String; const Overwrite: Boolean = False);

procedure attSaveToStream(const AStream: TStream; const AData: String);

{¬озвращает CRC содержимого файла}
function GetFileCRC(const AFileName: String): Integer;
function GetStreamCRC(const Stream: TStream): Integer;

implementation

uses
  ZLib, SysUtils, jclMath;

function attLoadFromFile(const AFileName: String): String;
var
  CS: TZCompressionStream;
  SSH, SSD: TStringStream;
  FS: TFileStream;
  H: TAttachmentHeader;
  I: Integer;
  Buf: array[1..1024] of Byte;
begin
  FS := TFileStream.Create(AFileName, fmOpenRead);
  try
    SSH := TStringStream.Create('');
    SSD := TStringStream.Create('');
    try
      CS := TZCompressionStream.Create(SSD);
      try
        repeat
          I := FS.Read(Buf, SizeOf(Buf));
          CS.Write(Buf, I);
        until I = 0;
      finally
        CS.Free;
      end;

      H.Signature := attSignature;
      H.Version := attVersion;
      H.Compression := attZLibCompression;
      H.DataType := 0;
      H.Size := FS.Size;
      H.CompressedSize := SSD.Size;
      H.ReservedB := 0;
      H.ReservedL := 0;
      SSH.WriteBuffer(H, SizeOf(H));

      Result := SSH.DataString + SSD.DataString;
    finally
      SSH.Free;
      SSD.Free;
    end;
  finally
    FS.Free;
  end;
end;

function attLoadFromStream(const Stream: TStream): String;
var
  CS: TZCompressionStream;
  SSH, SSD: TStringStream;
  H: TAttachmentHeader;
  I: Integer;
  Buf: array[1..1024] of Byte;
begin
  Stream.Position := 0;
  SSH := TStringStream.Create('');
  SSD := TStringStream.Create('');
  try
    CS := TZCompressionStream.Create(SSD);
    try
      repeat
        I := Stream.Read(Buf, SizeOf(Buf));
        CS.Write(Buf, I);
      until I = 0;
    finally
      CS.Free;
    end;

    H.Signature := attSignature;
    H.Version := attVersion;
    H.Compression := attZLibCompression;
    H.DataType := 0;
    H.Size := Stream.Size;
    H.CompressedSize := SSD.Size;
    H.ReservedB := 0;
    H.ReservedL := 0;
    SSH.WriteBuffer(H, SizeOf(H));

    Result := SSH.DataString + SSD.DataString;
  finally
    SSH.Free;
    SSD.Free;
  end;
end;

procedure attSaveToFile(const AFileName, AData: String; const Overwrite: Boolean = False);
var
  SS: TStringStream;
  DS: TZDecompressionStream;
  FS: TFileStream;
  H: TAttachmentHeader;
  Buf: array[1..1024] of Byte;
  I: Integer;
begin
  if FileExists(AFileName) and (not Overwrite) then
    exit;

  FS := TFileStream.Create(AFileName, fmCreate);
  try

    SS := TStringStream.Create(AData);
    try

      if (SS.Read(H, SizeOf(H)) <> SizeOf(H)) or (H.Signature <> attSignature) or (H.Version <> attVersion) then
      begin
        // это просто данные, у них нет заголовка и они не упакованы
        FS.CopyFrom(SS, 0);
      end else
      begin
        if H.Compression = attZLibCompression then
        begin

          DS := TZDecompressionStream.Create(SS);
          try
            repeat
              I := DS.Read(Buf, SizeOf(Buf));
              FS.Write(Buf, I);
            until I = 0;
          finally
            DS.Free;
          end;

        end else
        begin
          FS.CopyFrom(SS, SS.Size - SizeOf(H));
        end;
      end;

    finally
      SS.Free;
    end;

  finally
    FS.Free;
  end;
end;

procedure attSaveToStream(const AStream: TStream; const AData: String);
var
  SS: TStringStream;
  DS: TZDecompressionStream;
  H: TAttachmentHeader;
  Buf: array[1..1024] of Byte;
  I: Integer;
begin
  if AStream = nil then
    exit;

  SS := TStringStream.Create(AData);
  try

    if (SS.Read(H, SizeOf(H)) <> SizeOf(H)) or (H.Signature <> attSignature) or (H.Version <> attVersion) then
    begin
      // это просто данные, у них нет заголовка и они не упакованы
      AStream.CopyFrom(SS, 0);
    end else
      begin
        if H.Compression = attZLibCompression then
        begin
          DS := TZDecompressionStream.Create(SS);
          try
            repeat
              I := DS.Read(Buf, SizeOf(Buf));
              AStream.Write(Buf, I);
            until I = 0;
          finally
            DS.Free;
          end;
        end else
          begin
            AStream.CopyFrom(SS, SS.Size - SizeOf(H));
          end;
      end;
  finally
    SS.Free;
  end;
end;


function GetFileCRC(const AFileName: String): Integer;
var
  Str: TFileStream;
  ArBt: array of Byte;
begin
  if not(FileExists(AFileName)) then
    raise Exception.Create('‘айл ' + AFileName + ' не найден!');

  Str := TFileStream.Create(AFileName, fmOpenRead);
  try
    SetLength(ArBt, Str.Size);
    Str.Position := 0;
    if Str.Size > 0 then
      Str.Read(ArBt[0], Str.Size);
    Result := Integer(Crc32(ArBt, Length(ArBt)));
  finally
    Str.Free;
  end;
end;

function GetStreamCRC(const Stream: TStream): Integer;
var
  ArBt: array of Byte;
begin
  SetLength(ArBt, Stream.Size);
  Stream.Position := 0;
  if Stream.Size > 0 then
    Stream.Read(ArBt[0], Stream.Size);
  Result := Integer(Crc32(ArBt, Length(ArBt)));
end;

end.
