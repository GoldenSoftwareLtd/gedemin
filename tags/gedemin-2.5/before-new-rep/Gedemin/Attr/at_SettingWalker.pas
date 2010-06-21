
unit at_SettingWalker;

interface

uses
  Classes, DB, DBClient, SysUtils, gdcBaseInterface, gdcBase;

type
  TatSettingWalker = class;

  TgdcStartLoadingCallBack = procedure(Sender: TatSettingWalker;
    AnObjectSet: TgdcObjectSet) of object;
  TgdcObjectLoadCallBack = procedure(Sender: TatSettingWalker;
    const AClassName, ASubType: String;
    ADataSet: TDataSet; APrSet: TgdcPropertySet;
    const ASR: TgsStreamRecord) of object;

  TgdcStartLoadingNewCallBack = procedure(Sender: TatSettingWalker) of object;
  TgdcObjectLoadNewCallBack = procedure(Sender: TatSettingWalker;
    const AClassName, ASubType: String; ADataSet: TDataSet) of object;

  TatSettingWalker = class(TObject)
  private
    FStartLoading: TgdcStartLoadingCallBack;
    FObjectLoad: TgdcObjectLoadCallBack;
    FStartLoadingNew: TgdcStartLoadingNewCallBack;
    FObjectLoadNew: TgdcObjectLoadNewCallBack;

    FStream: TStream;
    FSettingObj: TgdcBase;

    procedure InternalParseStream(WorkingStream: TStream);
  public
    // при вызове предполагается что свойству Stream присвоен поток данных
    procedure ParseStream;
    // при вызове предполагается что свойству Stream присвоен поток настройки
    //  или свойству SettingObj присвоен бизнес-объект настройки
    procedure ParseSetting;

    property StartLoading: TgdcStartLoadingCallBack read FStartLoading write FStartLoading;
    property ObjectLoad: TgdcObjectLoadCallBack read FObjectLoad write FObjectLoad;
    property StartLoadingNew: TgdcStartLoadingNewCallBack read FStartLoadingNew write FStartLoadingNew;
    property ObjectLoadNew: TgdcObjectLoadNewCallBack read FObjectLoadNew write FObjectLoadNew;

    property Stream: TStream read FStream write FStream;
    property SettingObj: TgdcBase read FSettingObj write FSettingObj;
  end;

implementation

uses
  gdcStreamSaver, gsStreamHelper, gdcSetting, zlib;

{ TatSettingWalker }

procedure TatSettingWalker.ParseStream;
begin
  InternalParseStream(FStream);
end;

procedure TatSettingWalker.ParseSetting;
var
  I: Integer;
  PackedStream: TZDecompressionStream;
  UnpackedStream, SettingObjectStream, SettingDataStream: TMemoryStream;
  LoadClassName, LoadSubType: String;
  CDS: TDataset;
  OS: TgdcObjectSet;
  OldPos: Integer;
  stRecord: TgsStreamRecord;
  stVersion: string;
  PrSet: TgdcPropertySet;
  StreamLoadingOrderList: TgdcStreamLoadingOrderList;
  StreamDataObject: TgdcStreamDataObject;
  StreamWriterReader: TgdcStreamWriterReader;
  StreamType: TgsStreamType;

  SizeRead: Integer;
  Buffer: array[0..1023] of Char;
  TempInt: Integer;
begin
  // Проверим тип потока
  StreamType := GetStreamType(Stream);
  if StreamType = sttUnknown then
    Exit;

  // обрабатывать поток новым или старым методом
  if StreamType = sttXML then
  begin
    StreamLoadingOrderList := TgdcStreamLoadingOrderList.Create;
    StreamDataObject := TgdcStreamDataObject.Create;
    try
      StreamWriterReader := TgdcStreamXMLWriterReader.Create(StreamDataObject, StreamLoadingOrderList);
      // загружаем данные из потока
      try
        StreamWriterReader.LoadFromStream(Stream);
      finally
        FreeAndNil(StreamWriterReader);
      end;

      I := StreamDataObject.Find('TgdcSetting');
      if I > -1 then
      begin
        SettingDataStream := TMemoryStream.Create;
        try
          TBlobField(StreamDataObject.ClientDS[I].FieldByName('data')).SaveToStream(SettingDataStream);
          SettingDataStream.Position := 0;
          InternalParseStream(SettingDataStream);
        finally
          FreeAndNil(SettingDataStream);
        end;
      end
      else
      begin
        raise Exception.Create('Переданный поток не является потоком настройки');
      end;
    finally
      StreamDataObject.Free;
      StreamLoadingOrderList.Free;
    end;
  end
  else
  begin
    // Обычная настройка в сжатом потоке
    with TGSFHeader.Create do
    try
      if GetGSFInfo(Stream) then           // проверяем корректность файла
      begin
        Stream.Position := 2 * SizeOf(Integer) + Size + 1;

        UnpackedStream := TMemoryStream.Create;
        try
          // распакуем поток
          PackedStream := TZDecompressionStream.Create(Stream);
          try
            repeat
              SizeRead := PackedStream.Read(Buffer, 1024);
              UnpackedStream.WriteBuffer(Buffer, SizeRead);
            until (SizeRead < 1024);
            UnpackedStream.Position := 0;
          finally
            PackedStream.Free;
          end;

          // Определим версию потока и способ загрузки
          UnpackedStream.ReadBuffer(TempInt, SizeOf(TempInt));
          UnpackedStream.Position := 0;
          if TempInt > 1024 then
          begin
            // новый бинарный поток
            StreamLoadingOrderList := TgdcStreamLoadingOrderList.Create;
            StreamDataObject := TgdcStreamDataObject.Create;
            try
              StreamWriterReader := TgdcStreamBinaryWriterReader.Create(StreamDataObject, StreamLoadingOrderList);
              // загружаем данные из потока
              try
                StreamWriterReader.LoadFromStream(UnpackedStream);
              finally
                FreeAndNil(StreamWriterReader);
              end;

              I := StreamDataObject.Find('TgdcSetting');
              if I > -1 then
              begin
                SettingDataStream := TMemoryStream.Create;
                try
                  TBlobField(StreamDataObject.ClientDS[I].FieldByName('data')).SaveToStream(SettingDataStream);
                  SettingDataStream.Position := 0;
                  InternalParseStream(SettingDataStream);
                finally
                  FreeAndNil(SettingDataStream);
                end;
              end
              else
              begin
                raise Exception.Create('Переданный поток не является потоком настройки');
              end;
            finally
              StreamDataObject.Free;
              StreamLoadingOrderList.Free;
            end;
          end
          else
          begin
            OS := TgdcObjectSet.Create(TgdcBase, '');
            PrSet := TgdcPropertySet.Create('', nil, '');
            try
              OS.LoadFromStream(UnpackedStream);

              while UnpackedStream.Position < UnpackedStream.Size do
              begin
                UnpackedStream.ReadBuffer(I, SizeOf(I));
                if I <> cst_StreamLabel then
                  raise Exception.Create('Invalid stream format');

                OldPos := Stream.Position;
                SetLength(stVersion, Length(cst_WithVersion));
                UnpackedStream.ReadBuffer(stVersion[1], Length(cst_WithVersion));
                if stVersion = cst_WithVersion then
                begin
                  UnpackedStream.ReadBuffer(stRecord.StreamVersion, SizeOf(stRecord.StreamVersion));
                  if stRecord.StreamVersion >= 1 then
                    UnpackedStream.ReadBuffer(stRecord.StreamDBID, SizeOf(stRecord.StreamDBID));
                end
                else
                begin
                  stRecord.StreamVersion := 0;
                  stRecord.StreamDBID := -1;
                  UnpackedStream.Position := OldPos;
                end;

                LoadClassName := StreamReadString(UnpackedStream);
                LoadSubType := StreamReadString(UnpackedStream);

                if stRecord.StreamVersion >= 2 then
                begin
                  PrSet.LoadFromStream(UnpackedStream);
                end;

                if LoadClassName = 'TgdcSetting' then
                begin
                  UnpackedStream.ReadBuffer(I, SizeOf(I));
                  SettingObjectStream := TMemoryStream.Create;
                  try
                    SettingObjectStream.CopyFrom(UnpackedStream, I);
                    SettingObjectStream.Position := 0;
                    CDS := TClientDataSet.Create(nil);
                    try
                      TClientDataSet(CDS).LoadFromStream(SettingObjectStream);
                      CDS.Open;
                      if CDS.RecordCount = 1 then
                      begin
                        SettingDataStream := TMemoryStream.Create;
                        try
                          TBlobField(CDS.FieldByName('data')).SaveToStream(SettingDataStream);
                          SettingDataStream.Position := 0;
                          InternalParseStream(SettingDataStream);
                        finally
                          SettingDataStream.Free;
                        end;
                      end;
                    finally
                      FreeAndNil(CDS);
                    end;
                  finally
                    SettingObjectStream.Free;
                  end;
                  // выход из цикла по данным потока
                  Break;
                end;
              end;
            finally
              PrSet.Free;
              OS.Free;
            end;
          end;
        finally
          UnpackedStream.Free;
        end;
      end
      else
        raise Exception.Create('Переданный поток не является потоком настройки');
    finally
      Free;
    end;
  end;
end;

procedure TatSettingWalker.InternalParseStream(WorkingStream: TStream);
var
  I: Integer;
  MS: TMemoryStream;
  LoadClassName, LoadSubType: String;
  CDS: TDataset;
  OS: TgdcObjectSet;
  OldPos: Integer;
  stRecord: TgsStreamRecord;
  stVersion: string;
  PrSet: TgdcPropertySet;
  StreamLoadingOrderList: TgdcStreamLoadingOrderList;
  StreamDataObject: TgdcStreamDataObject;
  StreamWriterReader: TgdcStreamWriterReader;
  OrderElement: TStreamOrderElement;
  Obj: TgdcBase;
  StreamType: TgsStreamType;
begin
  // Проверим тип потока
  StreamType := GetStreamType(WorkingStream);
  if StreamType = sttUnknown then
    Exit;

  // обрабатывать поток новым или старым методом
  if StreamType <> sttBinaryOld then
  begin

    if Assigned(FStartLoadingNew) then
      FStartLoadingNew(Self);

    if Assigned(FObjectLoadNew) then
    begin
      StreamLoadingOrderList := TgdcStreamLoadingOrderList.Create;
      StreamDataObject := TgdcStreamDataObject.Create;
      try

        if StreamType <> sttBinaryNew then
          StreamWriterReader := TgdcStreamXMLWriterReader.Create(StreamDataObject, StreamLoadingOrderList)
        else
          StreamWriterReader := TgdcStreamBinaryWriterReader.Create(StreamDataObject, StreamLoadingOrderList);

        // загружаем данные из потока
        try
          StreamWriterReader.LoadFromStream(WorkingStream);
        finally
          StreamWriterReader.Free;
        end;

        while StreamLoadingOrderList.PopNextElement(OrderElement) do
        begin
          Obj := StreamDataObject.gdcObject[OrderElement.DSIndex];
          CDS := StreamDataObject.ClientDS[OrderElement.DSIndex];
          if CDS.Locate(Obj.GetKeyField(Obj.SubType), OrderElement.RecordID, []) then
            FObjectLoadNew(Self, Obj.ClassName, Obj.SubType, CDS)
          else
            raise Exception.Create('TatSettingWalker.ParseStream: В клиент-датасете не найден необходимый ID');
        end;

      finally
        StreamDataObject.Free;
        StreamLoadingOrderList.Free;
      end;
    end;
  end
  else
  begin
    OS := TgdcObjectSet.Create(TgdcBase, '');
    PrSet := TgdcPropertySet.Create('', nil, '');
    try
      OS.LoadFromStream(WorkingStream);

      if Assigned(FStartLoading) then
        FStartLoading(Self, OS);

      while WorkingStream.Position < WorkingStream.Size do
      begin
        WorkingStream.ReadBuffer(I, SizeOf(I));
        if I <> cst_StreamLabel then
          raise Exception.Create('Stream reading error');

        OldPos := WorkingStream.Position;
        SetLength(stVersion, Length(cst_WithVersion));
        WorkingStream.ReadBuffer(stVersion[1], Length(cst_WithVersion));
        if stVersion = cst_WithVersion then
        begin
          WorkingStream.ReadBuffer(stRecord.StreamVersion, SizeOf(stRecord.StreamVersion));
          if stRecord.StreamVersion >= 1 then
            WorkingStream.ReadBuffer(stRecord.StreamDBID, SizeOf(stRecord.StreamDBID));
        end else
        begin
          stRecord.StreamVersion := 0;
          stRecord.StreamDBID := -1;
          WorkingStream.Position := OldPos;
        end;

        LoadClassName := StreamReadString(WorkingStream);
        LoadSubType := StreamReadString(WorkingStream);

        if stRecord.StreamVersion >= 2 then
        begin
          PrSet.LoadFromStream(WorkingStream);
        end;

        WorkingStream.ReadBuffer(I, SizeOf(I));
        CDS := nil;
        MS := TMemoryStream.Create;
        try
          MS.CopyFrom(WorkingStream, I);
          MS.Position := 0;
          CDS := TClientDataset.Create(nil);
          TClientDataset(CDS).LoadFromStream(MS);
          CDS.Open;

          if Assigned(FObjectLoad) then
            FObjectLoad(Self, LoadClassName, LoadSubType, CDS, PrSet, stRecord);
        finally
          CDS.Free;
          MS.Free;
        end;
      end;
    finally
      PrSet.Free;
      OS.Free;
    end;
  end;
end;

end.
