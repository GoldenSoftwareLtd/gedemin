unit gsStreamHelper;

interface

uses
  classes, DB;

const
  STORAGE_VALUE_STREAM_DEFAULT_FORMAT = 'StreamDefaultFormat';
  STORAGE_VALUE_STREAM_SETTING_DEFAULT_FORMAT = 'StreamSettingDefaultFormat';

  STREAM_FORMAT_COUNT = 3;
  STREAM_FORMATS: array[0..STREAM_FORMAT_COUNT - 1] of String = (
    'Двоичный формат версии 1.0',
    'Двоичный формат версии 2.0',
    'XML');

  // Расширение для DAT файлов
  datExtension = 'dat';
  datDialogFilter = 'Файлы DAT|*.' + datExtension;
  // Расширение для XML файлов
  xmlExtension = 'xml';
  xmlDialogFilter = 'Файлы XML|*.' + xmlExtension;
  // Расширения для DAT-XML
  datxmlDialogFilter = 'Файлы данных|*.' + datExtension + ';*.' + xmlExtension;
  // Расширение для файлов настроек
  gsfExtension = 'gsf';
  gsfLoadDialogFilter = 'Файлы настроек|*.' + gsfExtension + '|' + datDialogFilter;
  gsfSaveDialogFilter = 'Файлы настроек|*.' + gsfExtension;
  gsfxmlDialogFilter = 'Файлы настроек|*.' + gsfExtension + ';' + '*.' + xmlExtension;

type 
  // Формат потока данных
  //  sttUnknown - неизвеcтный тип
  //  sttBinaryOld - Двоичный формат версии 1.0
  //  sttBinaryNew - Двоичный формат версии 2.0
  //  sttXML - XML
  TgsStreamType = (sttUnknown, sttBinaryOld, sttBinaryNew, sttXML);

  // Читает строку из переданного потока, принимая первый символ за длину строки
  function StreamReadString(St: TStream): String;
  // Пишет строку в поток, проставляя перед ей ее длину
  procedure StreamWriteString(St: TStream; const S: String);

  function GetDefaultStreamFormat(const ForSetting: Boolean): TgsStreamType;

  function FieldTypeToString(const AFieldType: TFieldType): String;
  function StringToFieldType(const AFieldTypeStr: String): TFieldType;

  function StreamTypeToString(const AStreamType: TgsStreamType): String;
  function StringToStreamType(const AStreamTypeStr: String): TgsStreamType;

implementation

uses
  gdcBase, gdcSetting, Storages, sysutils, TypInfo;

function StreamReadString(St: TStream): String;
var
  L: Integer;
begin
  St.ReadBuffer(L, SizeOf(L));
  SetLength(Result, L);
  if L > 0 then
    St.ReadBuffer(Result[1], L);
end;

procedure StreamWriteString(St: TStream; const S: String);
var
  L: Integer;
begin
  L := Length(S);
  St.Write(L, SizeOf(L));
  if L > 0 then
    St.Write(S[1], L);
end;

function GetDefaultStreamFormat(const ForSetting: Boolean): TgsStreamType;
var
  StreamFormat: TgsStreamType;
begin
  if ForSetting then
  begin
    if Assigned(GlobalStorage) then
    begin
      // Перейдем от старых переменных хранилища к новым
      if GlobalStorage.ValueExists('Options', 'UseNewStreamForSetting')
         and GlobalStorage.ValueExists('Options', 'StreamSettingType') then
      begin
        if GlobalStorage.ReadBoolean('Options', 'UseNewStreamForSetting', True) then
        begin
          if GlobalStorage.ReadInteger('Options', 'StreamSettingType', 0) = 0 then
            GlobalStorage.WriteInteger('Options', STORAGE_VALUE_STREAM_SETTING_DEFAULT_FORMAT, Integer(sttBinaryNew))
          else
            GlobalStorage.WriteInteger('Options', STORAGE_VALUE_STREAM_SETTING_DEFAULT_FORMAT, Integer(sttXML));
        end
        else
          GlobalStorage.WriteInteger('Options', STORAGE_VALUE_STREAM_SETTING_DEFAULT_FORMAT, Integer(sttBinaryOld));
        GlobalStorage.DeleteValue('Options', 'UseNewStreamForSetting');
        GlobalStorage.DeleteValue('Options', 'StreamSettingType');
      end;
      // Считаем новые переменные
      StreamFormat := TgsStreamType(GlobalStorage.ReadInteger('Options', STORAGE_VALUE_STREAM_SETTING_DEFAULT_FORMAT, -1));
      if (StreamFormat < Low(TgsStreamType)) or (StreamFormat > High(TgsStreamType)) or (StreamFormat = sttUnknown) then
      begin
        StreamFormat := sttBinaryOld;
        GlobalStorage.WriteInteger('Options', STORAGE_VALUE_STREAM_SETTING_DEFAULT_FORMAT, Integer(StreamFormat));
      end;
    end
    else
      StreamFormat := sttBinaryOld;
  end
  else
  begin
    if Assigned(GlobalStorage) then
    begin
      // Перейдем от старых переменных хранилища к новым
      if GlobalStorage.ValueExists('Options', 'UseNewStream')
         and GlobalStorage.ValueExists('Options', 'StreamType') then
      begin
        if GlobalStorage.ReadBoolean('Options', 'UseNewStream', True) then
        begin
          if GlobalStorage.ReadInteger('Options', 'StreamType', 0) = 0 then
            GlobalStorage.WriteInteger('Options', STORAGE_VALUE_STREAM_DEFAULT_FORMAT, Integer(sttBinaryNew))
          else
            GlobalStorage.WriteInteger('Options', STORAGE_VALUE_STREAM_DEFAULT_FORMAT, Integer(sttXML));
        end
        else
          GlobalStorage.WriteInteger('Options', STORAGE_VALUE_STREAM_DEFAULT_FORMAT, Integer(sttBinaryOld));
        GlobalStorage.DeleteValue('Options', 'UseNewStream');
        GlobalStorage.DeleteValue('Options', 'StreamType');
      end;

      StreamFormat := TgsStreamType(GlobalStorage.ReadInteger('Options', STORAGE_VALUE_STREAM_DEFAULT_FORMAT, -1));
      if (StreamFormat < Low(TgsStreamType)) or (StreamFormat > High(TgsStreamType)) or (StreamFormat = sttUnknown) then
      begin
        StreamFormat := sttBinaryOld;
        GlobalStorage.WriteInteger('Options', STORAGE_VALUE_STREAM_DEFAULT_FORMAT, Integer(StreamFormat));
      end;
    end
    else
      StreamFormat := sttBinaryOld;
  end;
  Result := StreamFormat;
end;

function FieldTypeToString(const AFieldType: TFieldType): String;
begin
  Result := GetEnumName(TypeInfo(TFieldType), Integer(AFieldType));
end;

function StringToFieldType(const AFieldTypeStr: String): TFieldType;
var
  I: Integer;
begin
  if AFieldTypeStr > '' then
  begin
    I := GetEnumValue(TypeInfo(TFieldType), AFieldTypeStr);
    if I <> -1 then
    begin
      Result := TFieldType(I);
      exit;
    end;
  end;

  raise Exception.Create('Invalid type specified.');
end;

function StreamTypeToString(const AStreamType: TgsStreamType): String;
begin
  Result := GetEnumName(TypeInfo(TgsStreamType), Integer(AStreamType));
end;

function StringToStreamType(const AStreamTypeStr: String): TgsStreamType;
var
  I: Integer;
begin
  if AStreamTypeStr > '' then
  begin
    I := GetEnumValue(TypeInfo(TgsStreamType), AStreamTypeStr);
    if I <> -1 then
    begin
      Result := TgsStreamType(I);
      exit;
    end;
  end;

  raise Exception.Create('Invalid type specified: ' + AStreamTypeStr);
end;

end.