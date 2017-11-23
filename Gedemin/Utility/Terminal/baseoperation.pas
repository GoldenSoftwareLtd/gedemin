unit BaseOperation; 

{$mode objfpc}{$H+}

interface

uses
  Windows, Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, ProjectCommon;

const
  Separator = ';';
  DocumentLine = 6;

type

  { TBaseOperation }

  TBaseOperation = class(TForm)
    eWeight: TEdit;
    eGoods: TEdit;
    lEnter: TLabel;
    lExit: TLabel;
    lDelete: TLabel;
    lWeight: TLabel;
    lWeight1: TLabel;
    Panel1: TPanel;
    mTP: TMemo;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
    {$IFDEF SKORPIOX3}
    reqID: DWORD;
    hDcd: HWND;
    procedure Cleanup;
    {$ENDIF}
    procedure WM_BARCODE(var Message: TMessage); message AM_DCD_SCAN;
    function BeforeClose: Boolean;
  protected
    FPosition: TStringList;
    FMemoPositions: TStringList;
    FSHCODE: TStringList;
    FTotalWeight: Double;
    FEnterCount: Boolean;
    FGoodsCount: Integer;
    FSetBarCode: Boolean;

    function CheckBarCode(const AKey: String): Boolean; virtual;
    procedure SetBarCode(const AKey: String); virtual; abstract;
    procedure SaveToFile; virtual; abstract;
    procedure LoadSHCODE;
    procedure NewMemo; virtual;
    procedure DeleteLastItem; virtual; abstract;
    procedure GetInfoGoods(const AKey: String; out ACode: String; out ANameGoods: String; out AWeight: Integer; out ADate: TDateTime; out ANumber: Integer; out ANpart:String);
    function CreateBarCode(const AWeight: Integer; ADate: TDateTime; AProductCode: String; ANumber: Integer; ANpart: String): String;
    procedure DecodeBarCode(const ABarCode: String; out AWeight: Integer; out ADate: TDateTime; out AProductCode: Integer; out ANumber: Integer; out ANpart:String);
  public
    { public declarations }
    procedure AddPosition(const AString: String); virtual;
    procedure AddPositionToMemo(const AString: String); virtual;
  end;

  {$IFNDEF SKORPIOX3}
  function registerLabelMessage(hLabelWindow: HWND; uiLabelMessage: Cardinal): Boolean;
    stdcall; external 'scaner_dll.dll' name 'registerLabelMessage';

  procedure deregisterLabelMessage;
    stdcall; external 'scaner_dll.dll' name 'deregisterLabelMessage';

  function getLabelText(pDestBuffer: LPTSTR; nDestBufferCapacity: Integer): Integer;
    stdcall; external 'scaner_dll.dll' name 'getLabelText';

  function getLabelTextLength: Integer;
    stdcall; external 'scaner_dll.dll' name 'getLabelTextLength';
  {$ELSE}
    function DecodeEnumDevices(deviceCaps: Pointer): Boolean;
    stdcall; external 'DecodeApi.dll' name 'DecodeEnumDevices';

  function DecodeReadString(hFile: HWND; reqID: DWORD; stringLen: Pointer; readString: WideString; maxLen: DWORD; codeID: Pointer): Boolean;
    stdcall; external 'DecodeApi.dll' name 'DecodeReadString';

  function DecodePostRequestMsgEx(hFile: HWND; reqType: DWORD; hWnd: HWND; uMsgRead, uMsgTimeout: UINT): DWORD;
    stdcall; external 'DecodeApi.dll' name 'DecodePostRequestMsgEx';

  function DecodeCancelRequest(hFile: HWND; reqID: DWORD): Boolean;
    stdcall; external 'DecodeApi.dll' name 'DecodeCancelRequest';
  {$ENDIF}
implementation

{$R *.lfm}

uses
  JcfStringUtils, MessageForm, BaseAddInformation, DateUtils, terminal_common;

procedure TBaseOperation.FormCreate(Sender: TObject);
var
  {$IFDEF SKORPIOX3}
  Num: array [0..8] of DWORD;
  DevIndex: Integer;
  DeviceName: WideString;
  B: DWORD;
  {$ENDIF}
  Temps: String;
begin
  BorderStyle := bsNone;
  WindowState := wsNormal;

  mTP.Height := ((GetSystemMetrics(SM_CYSCREEN) - 2*ChildSizing.TopBottomSpacing)*65) div 100;

  Temps := 'F4-ручной ввод ';
  if Self.ClassName <> 'TOperationRQ' then
    Temps := Temps + 'F1-сброс о/вес';
  {$IFNDEF SKORPIOX3}
  lEnter.Caption := 'Ctrl+Enter-сохр. ESC-выход';
  {$ELSE}
  lEnter.Caption := 'F10-сохр. ESC-выход';
  {$ENDIF}

  //lManual.Caption := 'F4-ручной ввод';
  lExit.Caption := Temps;
  lDelete.Caption := 'F2-отмена последней позиции';

  eWeight.Text := '0';

  FPosition := TStringList.Create;
  FMemoPositions := TStringList.Create;
  FMemoPositions.QuoteChar := ';';
  FTotalWeight := 0;
  FEnterCount := False;
  FGoodsCount := 0;
  FSetBarCode := False;

  LoadSHCODE;
  {$IFNDEF SKORPIOX3}
  registerLabelMessage(Handle, AM_DCD_SCAN);
  {$ELSE}
  if not DecodeEnumDevices(@Num) then
    raise Exception.Create('Device error!');
  DevIndex := 0;
  B := 1 or 2;
  for DevIndex := 0 to 8 do
  begin
    if (Num[DevIndex] and B) = B then
      break;
  end;

  DeviceName := 'DCD' + WideString(IntToStr(DevIndex + 1)) + ':';
  hDcd := CreateFile(PWideChar(deviceName), GENERIC_READ or GENERIC_WRITE, 0,
    nil, OPEN_EXISTING, 0, 0);

  if hDcd = INVALID_HANDLE_VALUE then
    raise Exception.Create('hDcd = INVALID_HANDLE_VALUE!');
  reqID := DecodePostRequestMsgEx(hDcd, (2 and 255) or 256,
    Self.Handle,
    AM_DCD_SCAN,
    AM_DCD_TIMEOUT);

  if reqID = -1 then
    raise Exception.Create('reqID = -1');
  {$ENDIF}
end;

procedure TBaseOperation.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if not BeforeClose then
    exit;

  if ModalResult = mrOk then
  begin
    if FPosition.Count > DocumentLine then
      SaveToFile
    else
    begin
      MessageForm.MessageDlg('Нет позиций в документе!', 'Внимание', mtInformation, [mbOK]);
      Application.ProcessMessages;
      ModalResult := mrNone;
      CanClose := False;
      Exit;
    end;
  end;
end;

procedure TBaseOperation.FormDestroy(Sender: TObject);
begin
  {$IFNDEF SKORPIOX3}
  deregisterLabelMessage();
  {$ELSE}
  Cleanup;
  {$ENDIF}
  FPosition.Free;
  FSHCODE.Free;
  FMemoPositions.Free;
end;

procedure TBaseOperation.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Temps: String;
  Count: Integer;
  Weight: Integer;
  Date: TDateTime;
  ProductCode: String;
  NameGood: String;
  NPart: String;
  Number: Integer;
  TotalWeight: Integer;
begin
   case Key of
    VK_UP:
    begin
      SendMessage(mTP.Handle, EM_SCROLL, SB_LINEUP,0);
      Key := 0;
    end;
    VK_DOWN:
    begin
      SendMessage(mTP.Handle, EM_SCROLL, SB_LINEDOWN,0);
      Key := 0;
    end;
    VK_ESCAPE: ModalResult := mrCancel;
    {$IFNDEF SKORPIOX3}
    VK_RETURN: if ssCtrl in Shift then ModalResult := mrOk;
    {$ELSE}
    VK_F10: ModalResult := mrOk;
    {$ENDIF}
    VK_F4:
    begin
      Temps := Trim(TBaseAddInformation.Execute('Введите код товара: '));
      if Length(Temps) <> 0 then
        SetBarCode(Temps);

      {$IFNDEF SKORPIOX3}
      registerLabelMessage(Handle, AM_DCD_SCAN);
      {$ENDIF}
      Key := 0;
    end;
    VK_F2:
    begin
      if (FPosition.Count > DocumentLine) then
      begin
        if (MessageForm.MessageDlg(PChar('Удалить последнюю позицию документа "' + FMemoPositions[FMemoPositions.Count - 1] + 'кг "?'),
          'Внимание', mtInformation, [mbYes, mbNo]) = mrYes) then
        begin
          DeleteLastItem;
          Key := 0;
          NewMemo;
        end;
      end;
    end;
    VK_F3:
    begin
      if FPosition.Count > DocumentLine then
      begin
        TempS := Trim(TBaseAddInformation.Execute('Введите кол-во товара: '));
        if (Length(Temps) <> 0) and
          TryStrToInt(TempS, Count) then
        begin
          TempS := FPosition[FPosition.Count - 1];
          SetLength(TempS, Length(TempS) - 1);
          GetInfoGoods(TempS, ProductCode, NameGood, Weight, Date, Number, Npart);
          DeleteLastItem;
          TotalWeight := Weight * Count;
          Weight := maxweight;
          FEnterCount := True;
          try
            while Weight = maxweight do
            begin
              if TotalWeight >= maxweight + 1 then
                TotalWeight := TotalWeight - Weight
              else
                Weight := TotalWeight;
              SetBarCode(CreateBarCode(Weight, Date, ProductCode, Count, Npart));
              Date := IncMinute(Date, 1);
              Count := 0;
            end;
          finally
            FEnterCount := False;
          end;
        end;

        {$IFNDEF SKORPIOX3}
        registerLabelMessage(Handle, AM_DCD_SCAN);
        {$ENDIF}
        Key := 0;
      end;
    end;
  end;
end;

procedure TBaseOperation.FormShow(Sender: TObject);
var
  ScreenWidth, ScreenHeight: Integer;
  TaskBarWnd: THandle;
begin
  ScreenWidth := GetSystemMetrics(SM_CXSCREEN);
  ScreenHeight := GetSystemMetrics(SM_CYSCREEN);
  SetWindowPos(Handle, HWND_TOPMOST, 0, 0, ScreenWidth, ScreenHeight, 0);
  TaskBarWnd := FindWindow('HHTaskBar', '');
  if (TaskBarWnd <> 0) then
    SetWindowPos(TaskBarWnd, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOSIZE or SWP_NOMOVE);
  NewMemo;
end;

{$IFDEF SKORPIOX3}
procedure TBaseOperation.Cleanup;
begin
  if (hDcd <> INVALID_HANDLE_VALUE) then
  begin
    DecodeCancelRequest(hDcd, reqID);
    CloseHandle(hDcd);
    hDcd := INVALID_HANDLE_VALUE;
  end;
end;
{$ENDIF}

procedure TBaseOperation.WM_BARCODE(var Message: TMessage);
var
  {$IFNDEF SKORPIOX3}
  Count: Integer;
  LabelText: array [0..100] of Widechar;
  {$ELSE}
  msgReqID, maxLen, stringLen: DWORD;
  lpString: WideString;
  {$ENDIF}
begin
  {$IFNDEF SKORPIOX3}
  FillChar(LabelText, SizeOf(LabelText), 0);
  count := getLabelTextLength();
  getLabelText(@LabelText, count);
  SetBarCode(String(Trim(LabelText)));
  {$ELSE}
  msgReqID := Message.LPARAM;
  maxLen := Message.WPARAM div sizeof(WideChar);
  SetLength(lpString, maxLen);
  DecodeReadString(hDcd, msgReqID, @stringLen, lpString, maxLen - 1, nil);
  SetBarCode(Trim(lpString));
  {$ENDIF}
end;

function TBaseOperation.BeforeClose: Boolean;
begin
  Result := True;
  if ModalResult = mrCancel then
  begin
    case MessageForm.MessageDlg(
      'Документ будет закрыт, сохранить изменения?',
      'Внимание', mtInformation,
      [mbYes, mbNo, mbCancel]) of
        mrYes: ModalResult := mrOk;
        mrNO: ModalResult := mrCancel;
        mrCANCEL:
        begin
          ModalResult := mrNone;
          Result := False;
        end;
    end;
    Application.ProcessMessages;
  end;
end;

procedure TBaseOperation.GetInfoGoods(const AKey: String; out ACode: String; out ANameGoods: String; out AWeight: Integer; out ADate: TDateTime; out ANumber: Integer; out ANpart: String);
var
  Index: Integer;
  Fmt: TFormatSettings;
  StrDate: String;
begin
  Assert(Length(AKey) >= 23);

  fmt.ShortDateFormat:= 'dd/mm/yyyy';
  fmt.DateSeparator  := '/';
  fmt.LongTimeFormat := 'hh:nn:ss';
  fmt.TimeSeparator  := ':';

  StrDate:= Copy(AKey, 7, 2) + '/' + Copy(AKey, 9, 2) + '/20' +
    Copy(AKey, 11, 2) + ' ' + Copy(AKey, 13, 2) + ':' + Copy(AKey, 15, 2);
  ADate := StrToDateTime(StrDate, fmt);
  AWeight := StrToInt(Copy(AKey, 1, 6));
  ACode := Copy(AKey, 17, 4);
  if Length(AKey) = 23 then
    ANumber := StrToInt(Copy(AKey, 21, 3))
  else
    if  StrToInt(Copy(AKey, 21, 3)) > 0 then
      ANumber := StrToInt(Copy(AKey, 21, 3))
    else
      ANumber := StrToInt(Copy(AKey, 21, 4));

  if  Length(AKey) >= 28 then
    ANpart := Copy(AKey, 25, 4)
  else
    ANpart := '9999';

  Index := FSHCODE.IndexOfName(ACode);
  if Index <> - 1 then
    ANameGoods := Copy(FSHCODE.ValueFromIndex[Index], 1,  StrIPos('=', FSHCODE.ValueFromIndex[Index]) - 1)
  else
    ANameGoods := 'Неизвестный';
end;

function TBaseOperation.CreateBarCode(const AWeight: Integer; ADate: TDateTime; AProductCode: String; ANumber: Integer; ANpart: String): String;
var
  TempS: String;
  CurrPos: Integer;
begin
  Result := '';
  Setlength(Result, 28);
  FillChar(Result[1], Length(Result), '0');
  TempS := IntToStr(AWeight);
  Move(TempS[1], Result[6 - Length(Temps) + 1], Length(TempS));
  Temps := FormatDateTime('DDMMYYhhnn', ADate);
  Move(TempS[1], Result[16 - Length(Temps) + 1], Length(TempS));
  Move(AProductCode[1], Result[20 - Length(AProductCode)  + 1], Length(AProductCode));
  TempS := IntToStr(ANumber);
  Move(TempS[1], Result[24 - Length(TempS)  + 1], Length(TempS));
  TempS := ANpart;
  Move(TempS[1], Result[28 - Length(TempS)  + 1], Length(TempS));
end;

procedure TBaseOperation.DecodeBarCode(const ABarCode: String; out AWeight: Integer;
  out ADate: TDateTime; out AProductCode: Integer; out ANumber: Integer; out ANpart: String);
var
  Fmt: TFormatSettings;
  StrDate: String;
begin
  Assert(Length(ABarCode) >= 23);

  fmt.ShortDateFormat:= 'dd/mm/yyyy';
  fmt.DateSeparator  := '/';
  fmt.LongTimeFormat := 'hh:nn:ss';
  fmt.TimeSeparator  := ':';

  StrDate:= Copy(ABarCode, 7, 2) + '/' + Copy(ABarCode, 9, 2) + '/20' +
    Copy(ABarCode, 11, 2) + ' ' + Copy(ABarCode, 13, 2) + ':' + Copy(ABarCode, 15, 2);
  ADate := StrToDateTime(StrDate, fmt);
  AWeight := StrToInt(Copy(ABarCode, 1, 6));
  AProductCode := StrToInt(Copy(ABarCode, 17, 4));
  ANumber := StrToInt(Copy(ABarCode, 21, 3));
  if  Length(ABarCode) >= 27 then
    ANpart := Copy(ABarCode, 25, 4)
  else
    ANpart := '9999';
end;

procedure TBaseOperation.AddPosition(const AString: String);
var
  Weight: Integer;
  Date: TDateTime;
  ProductCode: String;
  NameGood: String;
  Number: Integer;
  NPart: String;
begin
  if FSetBarCode then
  begin
    FPosition.Add(AString + Separator);
    GetInfoGoods(AString, ProductCode, NameGood, Weight, Date, Number, NPart);
    if (Weight > weight_for_checking_sites) and
      (Length(AString) = length_code_for_checking_sites)
    then
      Inc(FGoodsCount, Number)
    else
       if  Number > 0 then Inc(FGoodsCount);
    eGoods.Text := IntToStr(FGoodsCount);
  end else
    FPosition.Add(AString + Separator);
end;

procedure TBaseOperation.AddPositionToMemo(const AString: String);
begin
  FMemoPositions.Add(AString);
end;

procedure TBaseOperation.LoadSHCODE;
var
  Temps: String;
begin
  if FSHCODE = nil then
    FSHCODE := TStringList.Create;

  FSHCODE.Delimiter := ',';
  FSHCODE.QuoteChar := ';';
  Temps := Trim(ReadFileToString(ExtractFilePath(Application.ExeName) + '\cl\SHCODE_GOODS.TXT'));
  Temps := Copy(Temps, StrIPos(';', Temps), Length(Temps));
  FSHCODE.DelimitedText := Temps;
end;

procedure TBaseOperation.NewMemo;
const
  EndStr = #13#10;
var
  I: Integer;
  Temps: String;
begin
  Temps := '';
  mTP.Clear;
  for I := 0 to FMemoPositions.Count - 1 do
  begin
    if I < DocumentLine then
      Temps := Temps + FMemoPositions[I] + EndStr
    else
      Temps := Temps + FMemoPositions.Names[I] + ' ' + FMemoPositions.ValueFromIndex[I] + 'кг' + EndStr;
  end;

  mTP.Lines.Text := Temps;
  mTP.SelStart := Length(Temps);
  mTP.SelLength := 0;
end;

function TBaseOperation.CheckBarCode(const AKey: String): Boolean;
var
  StrDate: string;
  Fmt: TFormatSettings;
  dt: TDateTime;
begin
  Result := False;

  fmt.ShortDateFormat:= 'dd/mm/yyyy';
  fmt.DateSeparator  := '/';
  fmt.LongTimeFormat := 'hh:nn:ss';
  fmt.TimeSeparator  := ':';

  if FPosition.IndexOf(AKey + Separator) >= DocumentLine then
  begin
    MessageForm.MessageDlg('Товар уже добавлен в документ', 'Внимание', mtInformation, [mbOK])
  end else
  begin
    if (Length(AKey) >= 23) then
    begin
      StrDate:= Copy(AKey, 7, 2) + '/' + Copy(AKey, 9, 2) + '/20' +
        Copy(AKey, 11, 2) + ' ' + Copy(AKey, 13, 2) + ':' + Copy(AKey, 15, 2);

      if TryStrToDateTime (StrDate, dt, fmt) then
        Result := True
    end;
    if not Result then
      MessageForm.MessageDlg('Некорректный штрих-код', 'Внимание', mtInformation, [mbOk]);
  end;
end;
end.

