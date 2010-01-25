{++

  Copyright (c) 1999 by Golden Software of Belarus

  Project

    Phone

  Module

    gsdmModem_unit.pas

  Abstract

    DataModule for work with modem.

  Author

    Shadevsky Andrey (25-01-00)

  Revisions history

    Initial   25-01-00  JKL  Initial version.
    //BugFixed  05-11-99  Dennis  Bug fixed on empty employee.

--}

unit gsdmModem;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  AdPort, AdFax, AdFStat, OoMisc, VML_Modem, VML_Profile,
  VML_NoModem, VML_IS101, VML_USRobotics, CommPort, VML_Port, VML_Log,
  ExtCtrls, VML_Consts, FileCtrl, AdModem;

const
  gsVCON        =$1501;
  gsCONNECT     =$1502;
  gsERROR       =$1503;
  gsOK          =$1504;
  gsBUSY        =$1505;
  gsNO_CARRIER  =$1506;
  gsNO_DIALTONE =$1507;
  gsRING        =$1508;
  gsTIMER       =$1509;
  gs0           =$1510;
  gs1           =$1511;
  gs2           =$1512;
  gs3           =$1513;
  gs4           =$1514;
  gs5           =$1515;
  gs6           =$1516;
  gs7           =$1517;
  gs8           =$1518;
  gs9           =$1519;
{  msgSetVoice           = 'AT#CLS=8'#13;
  msgSetDevice          = 'AT#VLS=0'#13;
  msgAnswer             = 'ATA'#13;
  msgTransmitVoice      = 'AT#VTX'#13;
  msgReceiveVoice       = 'AT#VRX'#13;
  msgEndTRVoice         = #16#03#13;
  msgResetVoice         = 'ATZ'#13;
  msgHangDown           = 'ATH'#13;
  msgHangUp             = 'ATH1'#13;
  msgEhoOn              = 'ATE1'#13;
  msgSetSilence         = 'AT#VSS=2'#13;
  msgVoiceBit           = 'AT#VBS=8'#13;}

type
  TPortState = (psNonAct, psListen, psFaxTransmit, psFaxTransmitNow,
   psFaxRecieve, psFaxRecieveNow, psVoicePlay, psVoiceRecord, psMakeCall);

  TMesaga = procedure(CP : TObject; Str: String) of object;
  TListenAnswer = procedure(CP : TObject; AnConst: Integer) of object;
  TFaxRecieveEnd = procedure(CP : TObject; Code: Integer) of object;
  TFaxTransmitEnd = procedure(CP : TObject; Code: Integer) of object;

type
  TgsModem = class(TDataModule)
    ModemTraceFile: TModemLogFile;
    ModemLogFile: TModemLogFile;
    ModemPort: TModemPort;
    USRobotics: TUSRobotics;
    ModemProfile: TModemProfile;
    VoiceModem: TVoiceModem;
    ApdReceiveFax: TApdReceiveFax;
    ApdFaxStatus: TApdFaxStatus;
    ApdSendFax: TApdSendFax;
    ComPort: TApdComPort;
    ApdModem: TApdModem;
    RecordTimer: TTimer;
    {То стандартные. Типа}
    procedure DataModuleDestroy(Sender: TObject);
    procedure ComPortTriggerAvail(CP: TObject; Count: Word);
    procedure DataModuleCreate(Sender: TObject);
    procedure ApdReceiveFaxFaxFinish(CP: TObject; ErrorCode: Integer);
    procedure RecordTimerTimer(Sender: TObject);
    procedure VoiceModemYield(Sender: TObject);
    procedure ApdSendFaxFaxFinish(CP: TObject; ErrorCode: Integer);
    procedure ComPortTriggerTimer(CP: TObject; TriggerHandle: Word);
    procedure ApdReceiveFaxFaxLog(CP: TObject; LogCode: TFaxLogCode);
  private
    { Private declarations }
    Responce: String;
    WaitHnd: Integer;
    FEnableModem: Boolean;
    FVoiceEnable: Boolean;
    AnswerConst: Integer;
    TimerCaput: Boolean;
    FFileSendFax: String;
    FFileVoiceAnswer: String;
    FFileHelp: String;
    FFileVoiceMsg: String;
    FUseVoice: Boolean;
    FOnMess: TMesaga;
    FOnListen: TListenAnswer;
    FOnEndTransmit: TFaxTransmitEnd;
    FOnEndRecieve: TFaxRecieveEnd;
    FmsgSetVoice: String;
    FmsgSetDevice: String;
    FmsgAnswer: String;
    FmsgTransmitVoice: String;
    FmsgReceiveVoice: String;
    FmsgEndTRVoice: String;
    FmsgResetVoice: String;
    FmsgHangDown: String;
    FmsgHangUp: String;
    FmsgEhoOn: String;
    FmsgSetSilence: String;
    FmsgVoiceBit: String;
    procedure ClearResponce;
    procedure SetState;
    {Запись как таковая}
    function RecordVoice: String;
    {Воспроизведение как таковое}
    function PlayVoice(FileName: String): Integer;
    {Послать команду в модем и получить ответ}
    function SendComMessage(Msg: String; WaitTime: Integer): Integer;
    {Звонок как таковой}
    function Call(PhoneNum: String; Tone: Boolean): Integer;
    procedure FaxAutoSend(PhoneNum, FileName: String);
    procedure FaxAutoSendVoice(PhoneNum, FileName: String);
  public
    { Public declarations }
    PortState: TPortState;
    ToneFlag: Boolean;
    {Действия по звонку. Play file FFileVoiceAnswer and HangUp}
    function AnswerVoice: Boolean;
    {Определение очередного файла для голосового сообщения}
    function FindNewFile(BegMask, FullMask: String): String;
    {Проигрывает файл в линию. До запуска этой функции модем д.б.
     установлен в VOICE и VCON}
    function PlayFile(FileName: String): Boolean;
    function EndListen: Boolean; // Заканчивает слушать линию и закрывает порт.
    {Начинает записывать. Предварительно установлен VOICE и VCON}
    procedure StartRec;
    {Имя файла зв. сопровождения при отсылке файла}
    property FileSendFax: String read FFileSendFax write FFileSendFax;
    property FileVoiceAnswer: String read FFileVoiceAnswer write FFileVoiceAnswer;
    property FileHelp: String read FFileHelp write FFileHelp;
    property FileVoiceMsg: String read FFileVoiceMsg write FFileVoiceMsg;
    property UseVoice: Boolean read FUseVoice write FUseVoice;
    property EnableModem: Boolean read FEnableModem;
    {Modem comand's}
    property msgAnswer: String read FmsgAnswer write FmsgAnswer;
    property msgSetVoice: String read FmsgSetVoice write FmsgSetVoice;
    property msgSetDevice: String read FmsgSetDevice write FmsgSetDevice;
    property msgTransmitVoice: String read FmsgTransmitVoice write FmsgTransmitVoice;
    property msgReceiveVoice: String read FmsgReceiveVoice write FmsgReceiveVoice;
    property msgEndTRVoice: String read FmsgEndTRVoice write FmsgEndTRVoice;
    property msgResetVoice: String read FmsgResetVoice write FmsgResetVoice;
    property msgHangDown: String read FmsgHangDown write FmsgHangDown;
    property msgHangUp: String read FmsgHangUp write FmsgHangUp;
    property msgEhoOn: String read FmsgEhoOn write FmsgEhoOn;
    {Modem message}
    property OnMess: TMesaga read FOnMess write FOnMess;
    property OnListen: TListenAnswer read FOnListen write FOnListen;
    property OnEndTransmit: TFaxTransmitEnd read FOnEndTransmit write FOnEndTransmit;
    property OnEndRecieve: TFaxRecieveEnd read FOnEndRecieve write FOnEndRecieve;
    {Listen message}
    procedure FaxAutoRecieve;
    procedure FaxNowSend(FileName: String);
    procedure FaxNowRecieve;
    function InitModem: Boolean;
    procedure StopModem;
    property VoiceEnable: Boolean read FVoiceEnable;
    function SetVoice: Boolean;
    function ResetVoice: Boolean;
    {Начало прослушивания порта}
    procedure VoiceAnswer;
    {Послать голосовое сообщение по номеру}
    function MakeCall(PhoneNum, FileName: String): Integer;
    {Переключить звонок по миниАТС}
    function SwitchCall(PhoneNum: String): Boolean;
    {Опустить трубку}
    function HangDown: Boolean;
    function SendFax(PhoneNum, FileName: String): Boolean;
    {Определение номера факса}
    function FindNumber(Fax: String): String;
  end;

{var
  gsModem: TgsModem;}

implementation

{$R *.DFM}

function TgsModem.SendFax(PhoneNum, FileName: String): Boolean;
begin
  if FUseVoice then
    FaxAutoSendVoice(PhoneNum, FileName)
  else
    FaxAutoSend(PhoneNum, FileName);
end;

function TgsModem.FindNumber(Fax: String): String;
var
  S: String;
  I: Integer;
begin
  if Pos(',', Fax) > 0 then
    S := Copy(Fax, 1, Pos(',', Fax) - 1)
  else if Pos(' ', Fax) > 0 then
    S := Copy(Fax, 1, Pos(' ', Fax) - 1)
  else
    S := Fax;
  if Fax <> '' then
  begin
    if S[1] = '8' then
      if (S[2] <> 'w') and (S[2] <> 'W') then
        Insert('w', S, 2);
    I := 1;
    while I <= Length(S) do
    begin
      case S[I] of
      '-', '(', ')': Delete(S, I, 1);
      else
        Inc(I);
      end;
    end;
    Result := S;
  end else
    Result := '';
end;

procedure TgsModem.FaxAutoSend(PhoneNum, FileName: String);
begin
  if FEnableModem then
  begin
    FEnableModem := False;
    PortState := psFaxTransmit;
    ApdSendFax.PhoneNumber := PhoneNum;
    ApdSendFax.FaxFile := FileName;
    ApdSendFax.StatusDisplay := ApdFaxStatus;
    ApdFaxStatus.Fax := ApdSendFax;
    ApdSendFax.StartTransmit;
  end;
end;

procedure TgsModem.FaxAutoSendVoice(PhoneNum, FileName: String);
begin
  if FEnableModem then
  begin
    if InitModem then
    begin
      FEnableModem := False;
      if SetVoice then
        if Call(PhoneNum, ToneFlag) = gsVCON then
        begin
          if SendComMessage(FmsgTransmitVoice, 1000) = gsCONNECT then
          begin
            PortState := psVoicePlay;
            PlayVoice(FFileSendFax);
          end;
//          SendComMessage(FmsgEndTRVoice, 100);
          if SendComMessage(FmsgEndTRVoice, 100) = gsVCON then
          begin
            PortState := psFaxTransmit;
            FEnableModem := True;
            FaxNowSend(FileName);
          end;
        end else begin
          ResetVoice;
          FEnableModem := True;
        end
      else begin
        StopModem;
      end;
    end;
  end;
end;

procedure TgsModem.FaxAutoRecieve;
begin
  if FEnableModem then
  begin
    FEnableModem := False;
    PortState := psFaxRecieve;
    ApdReceiveFax.StatusDisplay := ApdFaxStatus;
    ApdFaxStatus.Fax := ApdReceiveFax;
    ApdReceiveFax.StartReceive;
  end;
end;

procedure TgsModem.FaxNowSend(FileName: String);
begin
  if FEnableModem then
  begin
    FEnableModem := False;
    PortState := psFaxTransmitNow;
    ApdSendFax.PhoneNumber := '0';
    ApdSendFax.FaxFile := FileName;
    ApdSendFax.StatusDisplay := ApdFaxStatus;
    ApdFaxStatus.Fax := ApdSendFax;
    ApdSendFax.FaxClass := fcUnknown;
    SendComMessage('AT#CLS=0'#13, 1000);
    ApdSendFax.StartManualTransmit;
  end;
end;

procedure TgsModem.FaxNowRecieve;
begin
  if FEnableModem then
  begin
    FEnableModem := False;
    PortState := psFaxRecieveNow;
    ApdReceiveFax.StatusDisplay := ApdFaxStatus;
    ApdFaxStatus.Fax := ApdReceiveFax;
    //ApdReceiveFax.FaxFile := 'c:\temp\www.apf';
//    ApdReceiveFax.PrepareConnectInProgress;
    ApdReceiveFax.InitModemForFaxReceive;
    ApdReceiveFax.StartManualReceive(True);
  end;
end;

procedure TgsModem.DataModuleDestroy(Sender: TObject);
begin
  ComPort.Open := False;
end;

procedure TgsModem.ComPortTriggerAvail(CP: TObject; Count: Word);
var
  ArrFlt: Array[0..$7FFF] of Char;
  I: Integer;
begin
  ComPort.GetBlock(ArrFlt, Count);
  for I := 0 to Count - 1 do
  begin
    Responce := Responce + ArrFlt[I];
  end;
  if Assigned(FOnMess) then
    FOnMess(Self, Responce);
  {ListBox1.Items.Add(Responce);
  ListBox1.ItemIndex := ListBox1.Items.Count - 1;}
//  if WaitHnd > -1 then
//  begin
    if (Pos('BUSY', Responce) > 0) or (Pos(#$10'b', Responce) > 0) then begin
      AnswerConst := gsBUSY;
      ClearResponce;
    end else if Pos('OK', Responce) > 0 then begin
      AnswerConst := gsOK;
      ClearResponce;
    end else if Pos('CONNECT', Responce) > 0 then begin
      AnswerConst := gsCONNECT;
      ClearResponce;
    end else if (Pos('VCON', Responce) > 0) or (Pos(FmsgEndTRVoice, Responce) > 0) then begin
      AnswerConst := gsVCON;
      ClearResponce;
    end else if Pos('RING', Responce) > 0 then begin
      AnswerConst := gsRING;
      ClearResponce;
    end else if Pos('NO CARRIER', Responce) > 0 then begin
      AnswerConst := gsNO_CARRIER;
      ClearResponce;
    end else if Pos('NO DIALTONE', Responce) > 0 then begin
      AnswerConst := gsNO_DIALTONE;
      ClearResponce;
    end else if Pos('ERROR', Responce) > 0 then begin
      AnswerConst := gsERROR;
      ClearResponce;
    end else if Pos(#$10'0', Responce) > 0 then begin
      AnswerConst := gs0;
      ClearResponce;
    end else if Pos(#$10'1', Responce) > 0 then begin
      AnswerConst := gs1;
      ClearResponce;
    end else if Pos(#$10'2', Responce) > 0 then begin
      AnswerConst := gs2;
      ClearResponce;
    end else if Pos(#$10'3', Responce) > 0 then begin
      AnswerConst := gs3;
      ClearResponce;
    end else if Pos(#$10'4', Responce) > 0 then begin
      AnswerConst := gs4;
      ClearResponce;
    end else if Pos(#$10'5', Responce) > 0 then begin
      AnswerConst := gs5;
      ClearResponce;
    end else if Pos(#$10'6', Responce) > 0 then begin
      AnswerConst := gs6;
      ClearResponce;
    end else if Pos(#$10'7', Responce) > 0 then begin
      AnswerConst := gs7;
      ClearResponce;
    end else if Pos(#$10'8', Responce) > 0 then begin
      AnswerConst := gs8;
      ClearResponce;
    end else if Pos(#$10'9', Responce) > 0 then begin
      AnswerConst := gs9;
      ClearResponce;
    end;
  //end;
  if (WaitHnd = -1) and (psListen <> PortState) then
    ClearResponce;
  if (psListen = PortState) {and (AnswerConst = gsRing) }and (WaitHnd = -1) then
    {if AnswerConst = gsRing then
    begin
      if AnswerVoice then
        PortState := psListen
      else
        EndListen;
    end else}
      if Assigned(FOnListen) then
        FOnListen(Self, AnswerConst);
    //StartRec;
end;

procedure TgsModem.ClearResponce;
begin
  Responce := '';
end;

procedure TgsModem.DataModuleCreate(Sender: TObject);
begin
//  InitModem;
//  ComPort.Open := False;
  FmsgSetVoice           := 'AT#CLS=8'#13;
  FmsgSetDevice          := 'AT#VLS=0'#13;
  FmsgAnswer             := 'ATA'#13;
  FmsgTransmitVoice      := 'AT#VTX'#13;
  FmsgReceiveVoice       := 'AT#VRX'#13;
  FmsgEndTRVoice         := #16#03#13;
  FmsgResetVoice         := 'ATZ'#13;
  FmsgHangDown           := 'ATH'#13;
  FmsgHangUp             := 'ATH1'#13;
  FmsgEhoOn              := 'ATE1'#13;
  FmsgSetSilence         := 'AT#VSS=2'#13;
  FmsgVoiceBit           := 'AT#VBS=8'#13;
  ToneFlag := True;
  FUseVoice := False;
  ApdReceiveFax.DestinationDir := ExtractFilePath(Application.ExeName) + 'RecieveFax';
  if not DirectoryExists(ExtractFilePath(Application.ExeName) + 'RecieveFax') then
    CreateDir(ExtractFilePath(Application.ExeName) + 'RecieveFax');
  if not DirectoryExists(ExtractFilePath(Application.ExeName) + 'VoiceMsg') then
    CreateDir(ExtractFilePath(Application.ExeName) + 'VoiceMsg');
end;

procedure TgsModem.SetState;
begin
  FEnableModem := True;
  PortState := psNonAct;
end;

function TgsModem.InitModem: Boolean;
begin
  Result := False;
  ApdModem.Initialize;
  if ResetVoice then
  begin
    SetState;
//    FEnableModem := True;
    Result := True;
  end else
    FEnableModem := False;
end;

procedure TgsModem.StopModem;
begin
  case PortState of
    psNonAct:;
    psListen:
      //ComPort.Open := False
      ;
    psFaxTransmit, psFaxTransmitNow:
    begin
      ApdSendFax.CancelFax;
    end;
    psFaxRecieve, psFaxRecieveNow:
    begin
      ApdReceiveFax.CancelFax;
    end;
    psVoicePlay, psVoiceRecord:
    begin
      VoiceModem.Stop;
    end;
  end;
  Application.ProcessMessages;
  PortState := psNonAct;
  FEnableModem := True;
  if ComPort.Open then
  begin
    ResetVoice;
    SendComMessage(FmsgHangDown, 100);
  end;
  VoiceModem.Close;
  ComPort.Open := False;
end;

function TgsModem.SetVoice: Boolean;
begin
//  Result := True;
//  if not FVoiceEnable then
  if ComPort.Open then
  begin
    Result := False;
    FVoiceEnable := False;
    if SendComMessage(FmsgSetVoice, 1000) = gsOK then
      if SendComMessage(FmsgSetDevice, 1000) = gsOK then
      begin
        Result := True;
        FVoiceEnable := True;
        SendComMessage(FmsgEhoOn, 100);
        //SendComMessage(FmsgVoiceBit, 100);
        //SendComMessage(FmsgSetSilence, 100);
      end;
  end;
end;

function TgsModem.ResetVoice: Boolean;
begin
  if ComPort.Open then
  begin
    Result := False;
    FVoiceEnable := False;
    case SendComMessage(FmsgResetVoice, 1000) of
      {gsOK, gsBUSY:
      begin
        Result := True;
        FVoiceEnable := True;
      end}
    //end else
      gsTIMER:
      begin
        if SendComMessage(FmsgEndTRVoice, 100) <> gsTIMER then
          if SendComMessage(FmsgResetVoice, 100) = gsOK then
          begin
            Result := True;
            FVoiceEnable := True;
          end;
      end
      else begin
        Result := True;
        FVoiceEnable := True;
      end;
   end;
  end;
end;

function TgsModem.SendComMessage(Msg: String; WaitTime: Integer): Integer;
  function WaitMessage: Boolean;
  begin
    while (not TimerCaput) and (AnswerConst < 0) do
    begin
      Application.ProcessMessages;
    end;
    RecordTimer.Enabled := False;
    if TimerCaput then
      Result := False
    else begin
      Result := True;
      ComPort.RemoveTrigger(WaitHnd);
      WaitHnd := -1;
    end;
  end;
begin
  if ComPort.Open then
  begin
    WaitHnd := ComPort.AddTimerTrigger;
    AnswerConst := -1;
    TimerCaput := False;
    ComPort.SetTimerTrigger(WaitHnd, WaitTime, True);
    Application.ProcessMessages;
    ClearResponce;
    ComPort.Output := Msg;
    RecordTimer.Interval := WaitTime * 10;
    RecordTimer.Enabled := True;
    WaitMessage;
    Result := AnswerConst;
    if Result = -1 then Result := gsTIMER;
  end;
end;

procedure TgsModem.VoiceAnswer;
begin
  if FEnableModem then
  begin
    if InitModem then
    begin
//      FEnableModem := False;
      if SetVoice then
      begin
        PortState := psListen;
      end else StopModem;
    end else StopModem;
  end;
end;

procedure TgsModem.ApdReceiveFaxFaxFinish(CP: TObject; ErrorCode: Integer);
begin
  if ComPort.Open then
  begin
    ResetVoice;
    SendComMessage(FmsgHangDown, 100);
  end;
  ApdFaxStatus.Display.Hide;// := False;
  PortState := psNonAct;
  ComPort.Open := False;
{  if Assigned(FOnEndRecieve) then
    FOnEndRecieve(Self, ErrorCode);}
  if Assigned(FOnMess) then
    FOnMess(Self, 'Fax recieve finish: ' + IntToStr(ErrorCode));
  FEnableModem := True;
end;

function TgsModem.Call(PhoneNum: String; Tone: Boolean): Integer;
var
  T: Char;
begin
  if Tone then
    T := 'T'
  else
    T := 'P';
  Result := SendComMessage('ATD' + T + PhoneNum + #13, 2000);
end;

function TgsModem.EndListen;
begin
  ResetVoice;
  HangDown;
  PortState := psNonAct;
  ComPort.Open := False;
  FEnableModem := True;
end;

function TgsModem.FindNewFile(BegMask, FullMask: String): String;
var
  SearchRec: TSearchRec;
  Found: Integer;
  S: String;
  Num, Min: Integer;
begin
  Min := -1;
  Found := FindFirst(FullMask, $3F, SearchRec);
  while Found = 0 do
  begin
    S := Copy(SearchRec.Name, Length(BegMask) + 1, Length(SearchRec.Name) - Length(BegMask) - 4);
    try
      Num := StrToInt(S);
      if Num > Min then
        Min := Num;
    except
    end;
    Found := FindNext(SearchRec);
  end;
  Inc(Min);
  Result := ExtractFilePath(FullMask) + BegMask + FormatFloat('0000', Min) +
   Copy(FullMask, Length(FullMask) - 3, Length(FullMask));
end;

function TgsModem.HangDown: Boolean;
begin
  Result := (SendComMessage(FmsgHangDown, 100) = gsOK);
end;

function TgsModem.SwitchCall(PhoneNum: String): Boolean;
var
  S: String;
  I: Integer;
begin
//  if FEnableModem then
  begin
    FEnableModem := False;
    //if SendComMessage(FmsgAnswer, 100) = gsVCON then
    begin
      S := '';
      for I := 1 to Length(PhoneNum) do
        S := S + ',' + PhoneNum[I];
      if SendComMessage('AT#VTS=!' + S + #13, 100) = gsOK then
      begin end;
        SendComMessage(FmsgHangDown, 100);
        ResetVoice;
        HangDown;
        if SetVoice then
        begin
          PortState := psListen;
        end else begin
          ComPort.Open := False;
          PortState := psNonAct;
        end;
      //end;
    end;
    FEnableModem := True;
  end;
end;

function TgsModem.MakeCall(PhoneNum, FileName: String): Integer;
begin
  if FEnableModem then
  begin
    try
      PortState := psMakeCall;
      if InitModem then
      begin
        FEnableModem := False;
        if SetVoice then
          if Call(PhoneNum, ToneFlag) = gsVCON then
            if SendComMessage(FmsgTransmitVoice, 1000) = gsCONNECT then
            begin
              PortState := psVoicePlay;
              PlayVoice(FileName);
            end;
            SendComMessage(FmsgEndTRVoice, 100);
      end;
    finally
      Result := AnswerConst;
      ResetVoice;
      SendComMessage(FmsgHangDown, 100);
      ComPort.Open := False;
      PortState := psNonAct;
      FEnableModem := True;
    end;
  end;
end;

function TgsModem.PlayVoice(FileName: String): Integer;
begin
  ComPort.Open := False;
  Result := FAIL;
  try
    case VoiceModem.OpenDevice of
      OK: begin
        Result := VoiceModem.PlayFile(FileName);
        case Result of
          OK: ;
          FAIL: ;
          INTERRUPTED: ;
        end;
      end;
    end;
  finally
    VoiceModem.CloseDevice;
    ComPort.Open := True;
  end;
end;

function TgsModem.PlayFile(FileName: String): Boolean;
var
  PS: TPortState;
begin
  PS := PortState;
  Result := False;
  if SendComMessage(FmsgTransmitVoice, 1000) = gsCONNECT then
  begin
    PortState := psVoicePlay;
    PlayVoice(FileName);
    Result := True;
  end;
  SendComMessage(FmsgEndTRVoice, 100);
  PortState := PS;
end;

function TgsModem.AnswerVoice: Boolean;
var
  I: Integer;
begin
  Result := False;
  if SendComMessage(FmsgAnswer, 1000) = gsVCON then
  begin
    if SendComMessage(FmsgTransmitVoice, 1000) = gsCONNECT then
    begin
      PortState := psVoicePlay;
      I := PlayVoice(FFileVoiceAnswer);
    end;
    SendComMessage(FmsgEndTRVoice, 100);
    if (I <> INTERRUPTED) and (SendComMessage(FmsgHangUp, 1000) = gsOK) then
    begin
      Result := True;
    end;
  end;
  PortState := psListen;
end;

procedure TgsModem.StartRec;
var
  I: Integer;
begin
//  if SendComMessage(FmsgAnswer, 1000) = gsVCON then
  begin
    I := OK;
    if SendComMessage(FmsgTransmitVoice, 1000) = gsCONNECT then
    begin
      PortState := psVoicePlay;
      I := PlayVoice(FFileVoiceMsg);
    end;
    if (I <> INTERRUPTED) and (SendComMessage(FmsgEndTRVoice, 100) = gsVCON) then
    begin
      PortState := psVoiceRecord;
      RecordTimer.Enabled := True;
      RecordVoice;
      //ComPort.Output := 'End Record'#13;
    end;
  end;
  ResetVoice;
  SendComMessage(FmsgHangDown, 100);
//  ComPort.Open := False;
//  PortState := psNonAct;
  if SetVoice then
  begin
    PortState := psListen;
  end else begin
    ComPort.Open := False;
    PortState := psNonAct;
  end;
end;

function TgsModem.RecordVoice: String;
var
  F: File;
begin
  Result := FindNewFile('VMSG', ExtractFilePath(Application.ExeName) + 'VoiceMsg\VMSG*.wav');// 'c:\temp\50.wav';
//  DeleteFile(Result);
  ComPort.Open := False;
  try
    case VoiceModem.OpenDevice of
      OK: begin
        ModemProfile.CommandEcho := True;
        case VoiceModem.RecordFile(Result) of
          OK: ;
          FAIL: ;
          INTERRUPTED: ;
        end;
      end;
    end;
  finally
    VoiceModem.CloseDevice;
    ComPort.Open := True;
  end;
end;

procedure TgsModem.RecordTimerTimer(Sender: TObject);
begin
  RecordTimer.Enabled := False;
  TimerCaput := True;
//  VoiceModem.Stop;
end;

procedure TgsModem.VoiceModemYield(Sender: TObject);
begin
  Application.ProcessMessages;
end;

procedure TgsModem.ApdSendFaxFaxFinish(CP: TObject; ErrorCode: Integer);
begin
//  ApdReceiveFax.CancelFax;
  if Assigned(FOnEndTransmit) then
    FOnEndTransmit(Self, ErrorCode);
  if Assigned(FOnMess) then
    FOnMess(Self, 'Fax finish: ' + IntToStr(ErrorCode));
  if ComPort.Open and (PortState <> psNonAct) then
  begin
    ResetVoice;
    SendComMessage(FmsgHangDown, 100);
    ComPort.Open := False;
  end;
  PortState := psNonAct;
  FEnableModem := True;
end;

procedure TgsModem.ComPortTriggerTimer(CP: TObject; TriggerHandle: Word);
begin
  if TriggerHandle = WaitHnd then
    TimerCaput := True;
end;

procedure TgsModem.ApdReceiveFaxFaxLog(CP: TObject; LogCode: TFaxLogCode);
var
  S: String;
begin
  S := '';
  case LogCode of
  lfaxReceiveStart:   S := 'fax receive is starting';
  lfaxReceiveOk:      S := 'fax was received successfully';
  lfaxReceiveSkip:    S := 'incoming fax was rejected';
  lfaxReceiveFail:    S := 'fax was not received successfully';
  end;
  if LogCode = lfaxReceiveOk then
  begin
    if Assigned(FOnEndRecieve) then
      FOnEndRecieve(Self, 0);
  end else
    if Assigned(FOnEndRecieve) then
      FOnEndRecieve(Self, 1);


{  case LogCode of
  lfaxReceiveOk, lfaxReceiveFail:    ApdReceiveFax.CancelFax;
  end;
 } if Assigned(FOnMess) then
    FOnMess(Self, S);
end;

end.
