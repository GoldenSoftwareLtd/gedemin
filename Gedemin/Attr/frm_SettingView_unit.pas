unit frm_SettingView_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, Db, DBClient, TB2Item, ActnList, TB2Dock,
  TB2Toolbar, SynEdit;

type
  Tfrm_SettingView = class(TForm)
    pnlMain: TPanel;
    pnlPositionText: TPanel;
    pnlBottom: TPanel;
    pnlLeft: TPanel;
    splInfo: TSplitter;
    pnlPositions: TPanel;
    lbPositions: TListBox;
    pnlPositionsCaption: TPanel;
    lblPositions: TLabel;
    pnlSettingInfo: TPanel;
    mSettingInfo: TMemo;
    pnlSettingInfoCaption: TPanel;
    lblSettingInfo: TLabel;
    splLeft: TSplitter;
    pnlButtons: TPanel;
    btnClose: TButton;
    TBDock1: TTBDock;
    TBToolbar1: TTBToolbar;
    alMain: TActionList;
    actFind: TAction;
    TBItem1: TTBItem;
    actSaveToFile: TAction;
    TBItem2: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    fdMain: TFindDialog;
    sePositionText: TSynEdit;
    actFindNext: TAction;
    procedure FormDestroy(Sender: TObject);
    procedure lbPositionsClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure actFindExecute(Sender: TObject);
    procedure fdMainFind(Sender: TObject);
    procedure actFindUpdate(Sender: TObject);
    procedure actFindNextExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FSelectionPos: Integer;

    procedure DoFind;
  public
    procedure ReadSetting(Stream: TStream);
  end;

var
  frm_SettingView: Tfrm_SettingView;

implementation

{$R *.DFM}

uses
  DBGrids, gdcBase
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  , gdcStreamSaver, prp_MessageConst, syn_ManagerInterface_unit;

procedure Tfrm_SettingView.ReadSetting(Stream: TStream);

  function StreamReadString(St: TStream): String;
  var
    L: Integer;
  begin
    St.ReadBuffer(L, SizeOf(L));
    SetLength(Result, L);
    if L > 0 then
      St.ReadBuffer(Result[1], L);
  end;

var
  I: Integer;
  MS: TMemoryStream;
  LoadClassName, LoadSubType: String;
  CDS: TClientDataSet;
  OS: TgdcObjectSet;
  OldPos: Integer;
  stRecord: TgsStreamRecord;
  stVersion: string;
  PrSet: TgdcPropertySet;
  OldCursor: TCursor;
  CurrentSettingText: String;
  SettingInfoAdded: Boolean;
  ClassRecordList: TStringList;
  ClassRecordListIndex: Integer;
  J: Integer;
  StreamLoadingOrderList: TgdcStreamLoadingOrderList;
  StreamDataObject: TgdcStreamDataObject;
  StreamWriterReader: TgdcStreamWriterReader;
  recCount: Integer;
  StreamType: TgsStreamType;
begin
  lbPositions.Clear;
  sePositionText.Lines.Clear;
  mSettingInfo.Clear;
  FSelectionPos := 0;

  // Проверим тип потока
  StreamType := GetStreamType(Stream);
  if StreamType = sttUnknown then
    Exit;

  // обрабатывать поток новым или старым методом
  if StreamType <> sttBinaryOld then
  begin

    StreamDataObject := TgdcStreamDataObject.Create;
    StreamLoadingOrderList := TgdcStreamLoadingOrderList.Create;
    try
      if StreamType = sttXML then
        StreamWriterReader := TgdcStreamXMLWriterReader.Create(StreamDataObject, StreamLoadingOrderList)
      else
        StreamWriterReader := TgdcStreamBinaryWriterReader.Create(StreamDataObject, StreamLoadingOrderList);

      // загружаем данные из потока
      try
        StreamWriterReader.LoadFromStream(Stream);
      finally
        StreamWriterReader.Free;
      end;

      OldCursor := Screen.Cursor;
      PrSet := TgdcPropertySet.Create('', nil, '');
      try
        Screen.Cursor := crHourGlass;

        // общая информация о настройке
        mSettingInfo.Lines.Add('Версия потока: ' + IntToStr(StreamDataObject.StreamVersion));
        mSettingInfo.Lines.Add('Идентификатор базы: ' + IntToStr(StreamDataObject.StreamDBID));

        // первый элемент списка - показывает общее содержимое настройки
        CurrentSettingText := 'Порядок загрузки записей:' + #13#10;
        for I := 0 to StreamLoadingOrderList.Count - 1 do
          CurrentSettingText := CurrentSettingText +
            Format('%6d: %d - %s %s',
              [I, StreamLoadingOrderList.Items[I].RecordID,
              StreamDataObject.gdcObject[StreamLoadingOrderList.Items[I].DSIndex].Classname,
              StreamDataObject.gdcObject[StreamLoadingOrderList.Items[I].DSIndex].SubType]) + #13#10;
        ClassRecordList := TStringList.Create;
        ClassRecordList.Add(CurrentSettingText);
        lbPositions.Items.AddObject('0. ID', ClassRecordList);

        try
          for J := 0 to StreamDataObject.Count - 1 do
          begin
            recCount := StreamDataObject.ClientDS[J].RecordCount;
            if recCount > 0 then
            begin
              CDS := StreamDataObject.ClientDS[J];
              try
                ClassRecordList := TStringList.Create;
                lbPositions.Items.AddObject(StreamDataObject.gdcObject[J].ClassName + '(' +
                  StreamDataObject.gdcObject[J].SubType + ') ' + StreamDataObject.gdcObject[J].SetTable, ClassRecordList);

                CDS.First;               
                while not CDS.Eof do
                begin
                  // Заполнение значений полей
                  for I := 0 to CDS.FieldCount - 1 do
                  begin
                    if not CDS.Fields[I].IsNull then
                    begin
                      if CDS.Fields[I] is TBlobField then
                      begin
                        {CurrentSettingText := CurrentSettingText +
                          Format('%2d: %20s', [I, CDS.Fields[I].FieldName]) + ':  < BLOB >'#13#10}
                        CurrentSettingText := CurrentSettingText +
                          Format('%2d: %20s', [I, CDS.Fields[I].FieldName]) + ':  ' + CDS.Fields[I].AsString + #13#10
                      end
                      else
                      begin
                        CurrentSettingText := CurrentSettingText +
                          Format('%2d: %20s', [I, CDS.Fields[I].FieldName]) + ':  ' + CDS.Fields[I].AsString + #13#10;
                      end;
                    end;
                  end;

                  // Заполнение дополнительных свойств объекта
                  if PrSet.Count > 0 then
                  begin
                    CurrentSettingText := CurrentSettingText + #13#10'Свойства'#13#10;
                    for I := 0 to PrSet.Count - 1 do
                    begin
                      CurrentSettingText := CurrentSettingText +
                        Format('%2d: %20s', [I, PrSet.Name[I]]) + ':  ' + VarToStr(PrSet.Value[PrSet.Name[I]]) + #13#10;
                    end;
                  end;

                  if CurrentSettingText <> '' then
                  begin
                    CurrentSettingText := CurrentSettingText + #13#10'--------------------------------------------------------'#13#10#13#10;
                    ClassRecordList.Add(CurrentSettingText);
                  end;

                  CDS.Next;
                end;
              finally
                CDS := nil;
              end;
            end;
          end;
        except
          on E: EOutOfMemory do
          begin
            MessageBox(0,
              'Для отображения всех данных настройки недостаточно свободной оперативной памяти.',
              'Внимание',
              MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
          end;
        end;
      finally
        Screen.Cursor := OldCursor;
        PrSet.Free;
      end;
    finally
      StreamDataObject.Free;
      StreamLoadingOrderList.Free;
    end;

  end
  else
  begin

    OldCursor := Screen.Cursor;
    SettingInfoAdded := False;
    OS := TgdcObjectSet.Create(TgdcBase, '');
    PrSet := TgdcPropertySet.Create('', nil, '');
    try
      Screen.Cursor := crHourGlass;
      OS.LoadFromStream(Stream);

      // первый элемент списка - показывает общее содержимое настройки
      CurrentSettingText := 'Порядок загрузки записей:' + #13#10;
      for I := 0 to OS.Count - 1 do
        CurrentSettingText := CurrentSettingText + Format('%6d: %d', [I, OS.Items[I]]) + #13#10;

      ClassRecordList := TStringList.Create;
      ClassRecordList.Add(CurrentSettingText);
      lbPositions.Items.AddObject('0. ID', ClassRecordList);

      try
        while Stream.Position < Stream.Size do
        begin
          Stream.ReadBuffer(I, SizeOf(I));
          if I <> $55443322 then
            raise Exception.Create('error');

          OldPos := Stream.Position;
          SetLength(stVersion, Length(cst_WithVersion));
          Stream.ReadBuffer(stVersion[1], Length(cst_WithVersion));
          if stVersion = cst_WithVersion then
          begin
            Stream.ReadBuffer(stRecord.StreamVersion, SizeOf(stRecord.StreamVersion));
            if stRecord.StreamVersion >= 1 then
              Stream.ReadBuffer(stRecord.StreamDBID, SizeOf(stRecord.StreamDBID));
          end else
          begin
            stRecord.StreamVersion := 0;
            stRecord.StreamDBID := -1;
            Stream.Position := OldPos;
          end;

          // общая информация о настройке
          if not SettingInfoAdded then
          begin
            mSettingInfo.Lines.Add('Версия потока: ' + IntToStr(stRecord.StreamVersion));
            mSettingInfo.Lines.Add('Идентификатор базы: ' + IntToStr(stRecord.StreamDBID));
            SettingInfoAdded := True;
          end;

          LoadClassName := StreamReadString(Stream);
          LoadSubType := StreamReadString(Stream);

          ClassRecordListIndex := lbPositions.Items.IndexOf(LoadClassName + '(' + LoadSubType + ')');
          if ClassRecordListIndex > -1 then
          begin
            ClassRecordList := (lbPositions.Items.Objects[ClassRecordListIndex] as TStringList);
          end
          else
          begin
            ClassRecordList := TStringList.Create;
            lbPositions.Items.AddObject(LoadClassName + '(' + LoadSubType + ')', ClassRecordList);
          end;

          if stRecord.StreamVersion >= 2 then
            PrSet.LoadFromStream(Stream);

          Stream.ReadBuffer(I, SizeOf(I));
          MS := TMemoryStream.Create;
          try
            MS.CopyFrom(Stream, I);
            MS.Position := 0;
            CDS := TClientDataSet.Create(nil);
            try
              CDS.LoadFromStream(MS);
              CDS.Open;

              CurrentSettingText := '';
              for I := 0 to CDS.FieldCount - 1 do
              begin
                if not CDS.Fields[I].IsNull then
                begin
                  if CDS.Fields[I] is TBlobField then
                  begin
                    {CurrentSettingText := CurrentSettingText +
                      Format('%2d: %20s', [I, CDS.Fields[I].FieldName]) + ':  < BLOB >'#13#10}
                    CurrentSettingText := CurrentSettingText +
                      Format('%2d: %20s', [I, CDS.Fields[I].FieldName]) + ':  ' + CDS.Fields[I].AsString + #13#10
                  end
                  else
                  begin
                    CurrentSettingText := CurrentSettingText +
                      Format('%2d: %20s', [I, CDS.Fields[I].FieldName]) + ':  ' + CDS.Fields[I].AsString + #13#10;
                  end;
                end;
              end;

              if PrSet.Count > 0 then
                CurrentSettingText := CurrentSettingText + #13#10'Свойства'#13#10;
              for I := 0 to PrSet.Count - 1 do
                CurrentSettingText := CurrentSettingText +
                  Format('%2d: %20s', [I, PrSet.Name[I]]) + ':  ' + VarToStr(PrSet.Value[PrSet.Name[I]]) + #13#10;

              if CurrentSettingText <> '' then
              begin
                CurrentSettingText := CurrentSettingText + #13#10'--------------------------------------------------------'#13#10#13#10;
                ClassRecordList.Add(CurrentSettingText);
              end;
            finally
              FreeAndNil(CDS);
            end;
          finally
            MS.Free;
          end;
        end;

      except
        On E: EOutOfMemory do
        begin
          MessageBox(0,
            'Для отображения всех данных настройки недостаточно свободной оперативной памяти.',
            'Внимание',
            MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
        end;
      end;
    finally
      Screen.Cursor := OldCursor;
      PrSet.Free;
      OS.Free;
    end;
  end;

  if lbPositions.Items.Count > 0 then
    sePositionText.Text := (lbPositions.Items.Objects[0] as TStrings).Text;
end;

procedure Tfrm_SettingView.FormDestroy(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to lbPositions.Items.Count - 1 do
    if Assigned(lbPositions.Items.Objects[I]) then
      lbPositions.Items.Objects[I].Free;
end;

procedure Tfrm_SettingView.lbPositionsClick(Sender: TObject);
var
  ClassRecordList: TStringList;
  RecordCount: Integer;
  TempStr: String;
  I: Integer;
begin
  sePositionText.Lines.Clear;

  ClassRecordList := TStringList(lbPositions.Items.Objects[lbPositions.ItemIndex]);
  RecordCount := ClassRecordList.Count;
  if RecordCount > 1 then
  begin
    TempStr := 'Количество записей: ' + IntToStr(RecordCount) + #13#10#13#10;
    for I := 0 to RecordCount - 1 do
    begin
      TempStr := TempStr + IntToStr(I + 1) + ' из ' + IntToStr(RecordCount) + #13#10 +
        ClassRecordList.Strings[I];
    end;
  end
  else
  begin
    // Тут выводится последовательность загрузки объектов
    TempStr := ClassRecordList.Text;
  end;

  sePositionText.Text := TempStr;
end;

procedure Tfrm_SettingView.btnCloseClick(Sender: TObject);
begin
  Self.Close;
end;

procedure Tfrm_SettingView.actFindExecute(Sender: TObject);
begin
  if sePositionText.SelAvail then
    fdMain.FindText := sePositionText.SelText
  else
    fdMain.FindText := sePositionText.WordAtCursor;
  fdMain.Execute;
end;

procedure Tfrm_SettingView.fdMainFind(Sender: TObject);
begin
  DoFind;
end;

procedure Tfrm_SettingView.actFindUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := sePositionText.Lines.Count > 0;
end;

procedure Tfrm_SettingView.actFindNextExecute(Sender: TObject);
begin
  if Length(fdMain.FindText) > 0 then
    DoFind
  else
    actFind.Execute;
end;

procedure Tfrm_SettingView.DoFind;
var
  rOptions: TSynSearchOptions;
  sSearch: String;
begin
  sSearch := fdMain.FindText;
  if Length(sSearch) = 0 then
  begin
    Beep;
    MessageBox(Application.Handle, MSG_FIND_EMPTY_STRING, MSG_WARNING,
     MB_OK or MB_ICONWARNING or MB_TASKMODAL);
  end else
  begin
    rOptions := [];
    if not (frDown in fdMain.Options) then
      Include(rOptions, ssoBackwards);
    if frMatchCase in fdMain.Options then
      Include(rOptions, ssoMatchCase);
    if frWholeWord in fdMain.Options then
      Include(rOptions, ssoWholeWord);
    if sePositionText.SearchReplace(sSearch, '', rOptions) = 0 then
    begin
      Beep;
      MessageBox(Application.Handle, PChar(MSG_SEACHING_TEXT + sSearch + MSG_NOT_FIND), MSG_WARNING,
       MB_OK or MB_ICONWARNING or MB_TASKMODAL);
    end;
  end;
end;

procedure Tfrm_SettingView.FormCreate(Sender: TObject);
begin
  if Assigned(SynManager) then
  begin
    sePositionText.Font.Assign(SynManager.GetHighlighterFont);
    sePositionText.Gutter.Font.Assign(SynManager.GetHighlighterFont);
    mSettingInfo.Font.Assign(SynManager.GetHighlighterFont);
  end;
end;

end.
