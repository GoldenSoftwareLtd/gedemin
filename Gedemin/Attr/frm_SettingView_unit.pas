unit frm_SettingView_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, Db, DBClient, TB2Item, ActnList, TB2Dock,
  TB2Toolbar, SynEdit, gdcStreamSaver, gsStreamHelper;

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
    {function ConvertBinaryToHex(const AStr: String): String;}
    {function ByteToHex(const B: Byte): String;}

    procedure ReadSettingOldStream(Stream: TStream);
    procedure ReadSettingNewStream(Stream: TStream; const StreamType: TgsStreamType);
    function FormatDatasetFieldValue(AField: TField): String;
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
  , prp_MessageConst, syn_ManagerInterface_unit;


const
  HexInRow = 16;
  HexDigits: array[0..15] of Char = '0123456789ABCDEF';
  RecordDivider = #13#10'----------------------------------------------------------------------'#13#10#13#10;
  LoadingOrderLineText = '0. Порядок загрузки записей';

procedure Tfrm_SettingView.ReadSetting(Stream: TStream);
var
  OldCursor: TCursor;
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

  OldCursor := Screen.Cursor;
  try
    Screen.Cursor := crHourGlass;
    // обрабатывать поток новым или старым методом
    try
      if StreamType <> sttBinaryOld then
        ReadSettingNewStream(Stream, StreamType)
      else
        ReadSettingOldStream(Stream);
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
  end;

  if lbPositions.Items.Count > 0 then
    sePositionText.Text := (lbPositions.Items.Objects[0] as TStrings).Text;
end;

procedure Tfrm_SettingView.ReadSettingNewStream(Stream: TStream; const StreamType: TgsStreamType);
var
  StreamDataObject: TgdcStreamDataObject;
  StreamLoadingOrderList: TgdcStreamLoadingOrderList;
  StreamWriterReader: TgdcStreamWriterReader;
  CurrentSettingText: String;
  ClassRecordList: TStringList;
  ElementCounter, DataSetCounter, recCount: Integer;
  CDS: TClientDataSet;
begin
  StreamDataObject := TgdcStreamDataObject.Create;
  StreamLoadingOrderList := TgdcStreamLoadingOrderList.Create;
  try
    if StreamType <> sttBinaryNew then
      StreamWriterReader := TgdcStreamXMLWriterReader.Create(StreamDataObject, StreamLoadingOrderList)
    else
      StreamWriterReader := TgdcStreamBinaryWriterReader.Create(StreamDataObject, StreamLoadingOrderList);

    // загружаем данные из потока
    try
      StreamWriterReader.LoadFromStream(Stream);
    finally
      StreamWriterReader.Free;
    end;

    // общая информация о настройке
    mSettingInfo.Lines.Add('Версия потока: ' + IntToStr(StreamDataObject.StreamVersion));
    mSettingInfo.Lines.Add('Идентификатор базы: ' + IntToStr(StreamDataObject.StreamDBID));

    // первый элемент списка - показывает общее содержимое настройки
    CurrentSettingText := 'Порядок загрузки записей:' + #13#10;
    for ElementCounter := 0 to StreamLoadingOrderList.Count - 1 do
      CurrentSettingText := CurrentSettingText +
        Format('%6d: %d - %s %s',
          [ElementCounter, StreamLoadingOrderList.Items[ElementCounter].RecordID,
          StreamDataObject.gdcObject[StreamLoadingOrderList.Items[ElementCounter].DSIndex].Classname,
          StreamDataObject.gdcObject[StreamLoadingOrderList.Items[ElementCounter].DSIndex].SubType]) + #13#10;
    ClassRecordList := TStringList.Create;
    ClassRecordList.Add(CurrentSettingText);
    lbPositions.Items.AddObject(LoadingOrderLineText, ClassRecordList);

    for DataSetCounter := 0 to StreamDataObject.Count - 1 do
    begin
      recCount := StreamDataObject.ClientDS[DataSetCounter].RecordCount;
      if recCount > 0 then
      begin
        CDS := StreamDataObject.ClientDS[DataSetCounter];
        ClassRecordList := TStringList.Create;
        lbPositions.Items.AddObject(StreamDataObject.gdcObject[DataSetCounter].ClassName + '(' +
          StreamDataObject.gdcObject[DataSetCounter].SubType + ') ' +
          StreamDataObject.gdcObject[DataSetCounter].SetTable, ClassRecordList);

        CDS.First;
        while not CDS.Eof do
        begin
          CurrentSettingText := '';
          // Заполнение значений полей
          for ElementCounter := 0 to CDS.FieldCount - 1 do
          begin
            if not CDS.Fields[ElementCounter].IsNull then
            begin
              CurrentSettingText := CurrentSettingText +
                Format('%2d: %20s', [ElementCounter, CDS.Fields[ElementCounter].FieldName]) + ':  ' +
                FormatDatasetFieldValue(CDS.Fields[ElementCounter]) + #13#10;
            end;
          end;
          // Занесем одну заполненную запись в список данного бизнес-объекта
          if CurrentSettingText <> '' then
            ClassRecordList.Add(CurrentSettingText);

          CDS.Next;
        end;
      end;
    end;
  finally
    StreamDataObject.Free;
    StreamLoadingOrderList.Free;
  end;
end;

procedure Tfrm_SettingView.ReadSettingOldStream(Stream: TStream);
var
  I: Integer;
  MS: TMemoryStream;
  LoadClassName, LoadSubType: String;
  CDS: TClientDataSet;
  OS: TgdcObjectSet;
  OldPos: Integer;
  stRecord: TgsStreamRecord;
  stVersion: String;
  PrSet: TgdcPropertySet;
  CurrentSettingText: String;
  SettingInfoAdded: Boolean;
  ClassRecordList: TStringList;
  ClassRecordListIndex: Integer;
begin
  SettingInfoAdded := False;
  OS := TgdcObjectSet.Create(TgdcBase, '');
  PrSet := TgdcPropertySet.Create('', nil, '');
  try
    OS.LoadFromStream(Stream);

    // первый элемент списка - показывает общее содержимое настройки
    CurrentSettingText := 'Порядок загрузки записей:' + #13#10;
    for I := 0 to OS.Count - 1 do
      CurrentSettingText := CurrentSettingText + Format('%6d: %d', [I, OS.Items[I]]) + #13#10;

    ClassRecordList := TStringList.Create;
    ClassRecordList.Add(CurrentSettingText);
    lbPositions.Items.AddObject(LoadingOrderLineText, ClassRecordList);

    while Stream.Position < Stream.Size do
    begin
      Stream.ReadBuffer(I, SizeOf(I));
      if I <> cst_StreamLabel then
        raise Exception.Create('Invalid stream format');

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
              CurrentSettingText := CurrentSettingText +
                Format('%2d: %20s', [I, CDS.Fields[I].FieldName]) + ':  ' + FormatDatasetFieldValue(CDS.Fields[I]) + #13#10;
            end;
          end;

          if PrSet.Count > 0 then
            CurrentSettingText := CurrentSettingText + #13#10'Свойства'#13#10;
          for I := 0 to PrSet.Count - 1 do
            CurrentSettingText := CurrentSettingText +
              Format('%2d: %20s', [I, PrSet.Name[I]]) + ':  ' + VarToStr(PrSet.Value[PrSet.Name[I]]) + #13#10;

          if CurrentSettingText <> '' then
          begin
            ClassRecordList.Add(CurrentSettingText);
          end;
        finally
          FreeAndNil(CDS);
        end;
      finally
        MS.Free;
      end;
    end;
  finally
    PrSet.Free;
    OS.Free;
  end;
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
  // Нулевой элемент - порядок загрузки объектов
  if lbPositions.ItemIndex = 0 then
  begin
    TempStr := ClassRecordList.Text;
  end
  else
  begin
    RecordCount := ClassRecordList.Count;
    TempStr := 'Количество записей: ' + IntToStr(RecordCount) + #13#10#13#10;

    for I := 0 to RecordCount - 1 do
    begin
      TempStr := TempStr + IntToStr(I + 1) + ' из ' + IntToStr(RecordCount) + #13#10 +
        ClassRecordList.Strings[I] + RecordDivider;
    end;
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

{function Tfrm_SettingView.ConvertBinaryToHex(const AStr: String): String;
var
  CharCounter: Integer;
  Size: Integer;
  B, C: PChar;
begin
  Result := '';

  Size := Length(AStr);
  Size := Size * 3 + ((Size div HexInRow) + 1) * (2 + 4) + 32;
  GetMem(B, Size);
  try
    C := B;
    C[0] := #0;
    for CharCounter := 1 to Length(AStr) do
    begin
      if CharCounter mod HexInRow = 1 then
        C := StrCat(C, '    ') + StrLen(C);
      C := StrCat(C, PChar(ByteToHex(Byte(AStr[CharCounter])) + ' ')) + StrLen(C);
      if CharCounter mod HexInRow = 0 then
        C := StrCat(C, #13#10) + StrLen(C);
    end;
    StrCat(C, #13#10);
    Result := #13#10'Size ' + IntToStr(Size) + #13#10 + B;
  finally
    FreeMem(B, Size);
  end;
end;}

{function Tfrm_SettingView.ByteToHex(const B: Byte): String;
begin
  Result := HexDigits[B div 16] + HexDigits[B mod 16];
end;}

function Tfrm_SettingView.FormatDatasetFieldValue(AField: TField): String;
begin
  case AField.DataType of
    ftString:
      Result := '"' + AField.AsString + '"';

    ftMemo:
      Result := #13#10#13#10 + AField.AsString + #13#10;

    ftBLOB, ftGraphic:
      //Result := #13#10 + ConvertBinaryToHex(AField.AsString);
      Result := '<BLOB> Size: ' + IntToStr(Length(AField.AsString));
  else
    Result := AField.AsString;
  end;
end;

end.
