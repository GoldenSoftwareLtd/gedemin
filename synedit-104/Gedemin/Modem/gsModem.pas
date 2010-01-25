unit gsModem;

interface

uses
  Classes, SysUtils, AdTapi,
  AdPacket, AdProtcl, AdPort, AdTStat, OoMisc, AdPStat, AdMdm,
  comctrls;

type
  TgsModemState = (msIdle, msReceive, msSend);
  TModemReceive = procedure(Sender: TObject; AFileName: String) of object;
  TgsModemError = procedure(Sender: TObject; ErrorCode: Integer; ErrorDescription: String) of Object;
  TgsModem = class(TComponent)
  private

    FApdTapiDevice: TApdTapiDevice;
    FApdComPort: TApdComPort;
    FApdTapiStatus: TApdTapiStatus;
    FApdProtocol: TApdProtocol;
    FOnReceive: TModemReceive;
    FOnSend: TNotifyEvent;
    FOnClosePort: TNotifyEvent;
    FOnOpenPort: TNotifyEvent;
    FOnError: TgsModemError;
    FAutoReceive: Boolean;
    FApdProtocolStatus: TApdProtocolStatus;
    FFileList: TStringList;
    FModemState : TgsModemState;
    FProtocolStatusCaption: String;

    function GetSelectedModem: String;
    procedure SetSelectedModem(const Value: String);
    function GetDialing: Boolean;
    function GetTapiState: TTapiState;

    procedure SetBaud(const Value: Longint);
    function GetBaud: Longint;
    procedure SetAnswerOnRing(const Value: Byte);
    function GetAnswerOnRing: Byte;
    procedure SetMaxAttempts(const Value: word);
    function GetMaxAttempts: word;
    procedure SetRetryWait(const Value: Word);
    function GetRetryWait: Word;
    procedure SetTimeOut(const Value: Integer);
    function GetTimeOut: Integer;
    procedure SetAutoReceive(const Value: Boolean);
    function GetAutoReceive: Boolean;
    //
    procedure TapiPortOpen(Sender: TObject);
    procedure TapiPortClose(Sender: TObject);
    procedure OnProtocolNextFile(CP : TObject; var FName : TPassString);
    procedure OnProtocolFinish(CP : TObject; ErrorCode : Integer);
    procedure SetDestinationDirectory(const Value: String);
    function GetDestinationDirectory: String;
    function GetProtocolStatusCaption: String;
    procedure SetProtocolStatusCaption(const Value: String);
    //
  protected
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Cancel;
    function ChooseModem: Boolean;
    // Состояние модема
    property TapiState: TTapiState read GetTapiState;
    property Dialing: Boolean read GetDialing;

    //
    procedure Call(const AnPhone: String);
    procedure Send(const AFileName: String);
    procedure WaitFile;
    //
  published
    property SelectedModem: String read GetSelectedModem write SetSelectedModem;
    property OnReceive: TModemReceive read FOnReceive write FOnReceive;
    property OnSend: TNotifyEvent read FonSend write FOnSend;
    property OnOpenPort: TNotifyEvent read FOnOpenPort write FOnOpenPort;
    property OnClosePort: TNotifyEvent read FOnClosePort write FOnClosePort;
    property OnError: TgsModemError read FOnError write FOnError;
    property Baud: Longint read GetBaud write SetBaud;
    property AnswerOnRing: Byte read GetAnswerOnRing write SetAnswerOnRing;
    property MaxAttempts: word read GetMaxAttempts write SetMaxAttempts;
    property RetryWait: Word read GetRetryWait write SetRetryWait;
    property TimeOut: Integer read GetTimeOut write SetTimeOut;
    property AutoReceive: Boolean read GetAutoReceive write SetAutoReceive;
    property DestinationDirectory: String read GetDestinationDirectory write SetDestinationDirectory;
    property ProtocolStatusCaption: String read GetProtocolStatusCaption write SetProtocolStatusCaption;
  end;

procedure Register;

implementation
uses Controls, forms, ADExcept,Dialogs;

procedure Register;
begin
  RegisterComponents('gsModem', [TgsModem]);
end;

{ TgsModemOil }


procedure TgsModem.Call(const AnPhone: String);
begin
  while not FApdTapiDevice.CancelCall do;
  FApdTapiDevice.Dial(AnPhone);
end;

procedure TgsModem.Cancel;
begin
  FApdTapiDevice.CancelCall;
 // if FAutoReceive then
 //   FApdTapiDevice.AutoAnswer;
end;

function TgsModem.ChooseModem: Boolean;
begin
  Result := FApdTapiDevice.SelectDevice = mrOk;
end;

constructor TgsModem.Create(AOwner: TComponent);
begin
  inherited;
  FModemState := msIdle;
  FFileList := TStringList.Create;

  FApdComPort := TApdComPort.Create(Self);

  FApdComPort.AutoOpen := False;
  FApdComPort.TapiMode := tmOn;


  FApdTapiStatus := TApdTapiStatus.Create(Self);
  FApdTapiStatus.Position := poScreenCenter;


  FApdTapiDevice := TApdTapiDevice.Create(Self);
  FApdTapiDevice.ComPort := FApdComPort;
  FApdTapiDevice.ShowPorts := False;
  FApdTapiDevice.StatusDisplay := FApdTapiStatus;
  FApdTapiDevice.OnTapiPortOpen := TapiPortOpen;
  FApdTapiDevice.OnTapiPortClose := TapiPortClose;

  FApdProtocol := TApdProtocol.Create(Self);
  FApdProtocol.ComPort := FApdComPort;
  FApdProtocol.WriteFailAction := wfWriteAnyway;
  FApdProtocol.OnProtocolNextFile := OnProtocolNextFile;
  FApdProtocol.OnProtocolFinish := OnProtocolFinish;

  FApdProtocolStatus := TApdProtocolStatus.Create(Self);
  FApdProtocolStatus.Position := poScreenCenter;
  FApdProtocol.StatusDisplay := FApdProtocolStatus;
  FApdProtocolStatus.Protocol := FApdProtocol;
end;

destructor TgsModem.Destroy;
begin
  FFileList.Free;
// if FApdTapiDevice.CancelCall
  if not FApdTapiDevice.Cancelled then
    FApdTapiDevice.CancelCall;
  inherited;
end;

function TgsModem.GetAnswerOnRing: Byte;
begin
  Result := FApdTapiDevice.AnswerOnRing;
end;

function TgsModem.GetAutoReceive: Boolean;
begin
  Result := FAutoReceive;
end;

function TgsModem.GetBaud: Longint;
begin
  Result := FApdComPort.Baud;
end;

function TgsModem.GetDestinationDirectory: String;
begin
  Result := FApdProtocol.DestinationDirectory;
end;

function TgsModem.GetDialing: Boolean;
begin
  Result := FApdTapiDevice.Dialing;
end;

function TgsModem.GetMaxAttempts: word;
begin
  Result := FApdTapiDevice.MaxAttempts;
end;

function TgsModem.GetProtocolStatusCaption: String;
begin

end;

function TgsModem.GetRetryWait: Word;
begin
  Result := FApdTapiDevice.RetryWait;
end;

function TgsModem.GetSelectedModem: String;
begin
  Result := FApdTapiDevice.SelectedDevice
end;

function TgsModem.GetTapiState: TTapiState;
begin
  Result := FApdTapiDevice.TapiState;
end;

function TgsModem.GetTimeOut: Integer;
begin
  Result := FApdProtocol.TransmitTimeout
end;


procedure TgsModem.OnProtocolFinish(CP : TObject; ErrorCode : Integer);
begin
  if ErrorCode = 0 then
  begin
    if FModemState = msReceive then
    begin
      FmodemState := msIdle;
      if Assigned(FOnReceive) then
        FonReceive(Self, FApdProtocol.FileName);
    end
    else
    if FModemState = msSend then
    begin
      FmodemState := msIdle;
      if Assigned(FOnSend) then
      begin
        FonSend(Self);
      end
    end;
  end
  else
  begin
    if Assigned(FOnError) then
      FOnError(Self, ErrorCode, ErrorMsg(ErrorCode));
  //  ShowMessage(ErrorMsg(ErrorCode))
  end
        end;

procedure TgsModem.OnProtocolNextFile(CP: TObject; var FName: TPassString);
begin
  if FFileList.Count > 0 then
  begin
    FName := FFileList[0];
    FFileList.Delete(0);
  end
  else
    FName := '';
end;


procedure TgsModem.Send(const AFileName: String);
begin
  FModemState := msSend;
  FFileList.Add(AFileName);
  FApdProtocol.FileName := AFileName;
  if not FApdProtocol.InProgress then
    FApdProtocol.StartTransmit;
end;

procedure TgsModem.SetAnswerOnRing(const Value: Byte);
begin
  FApdTapiDevice.AnswerOnRing := Value;
end;

procedure TgsModem.SetAutoReceive(const Value: Boolean);
begin
  try
    FAutoReceive := Value;
    FApdTapiDevice.CancelCall;
    if FAutoReceive then
      FApdTapiDevice.AutoAnswer;
  except
  end
end;

procedure TgsModem.SetBaud(const Value: Longint);
begin
  FApdComPort.Baud := Value;
end;

procedure TgsModem.SetDestinationDirectory(const Value: String);
begin
  FApdProtocol.DestinationDirectory := Value;
end;

procedure TgsModem.SetMaxAttempts(const Value: word);
begin
  FApdTapiDevice.MaxAttempts := Value;
end;

procedure TgsModem.SetProtocolStatusCaption(const Value: String);
begin
  FProtocolStatusCaption := Value;
  if Assigned(FApdProtocolStatus) then
    FApdProtocolStatus.Caption := FProtocolStatusCaption;
end;

procedure TgsModem.SetRetryWait(const Value: Word);
begin
  FApdTapiDevice.RetryWait := Value;
end;

procedure TgsModem.SetSelectedModem(const Value: String);
begin
  FApdTapiDevice.SelectedDevice := Value;
end;


procedure TgsModem.SetTimeOut(const Value: Integer);
begin
  FApdProtocol.TransmitTimeout := Value;
end;

procedure TgsModem.TapiPortClose(Sender: TObject);
begin
  FApdProtocol.CancelProtocol;
  FModemState := msIdle;
  if Assigned(FOnClosePort) then
    FOnClosePort(Self);
  if FAutoReceive then
    AutoReceive;
  FFileList.Clear;
end;

procedure TgsModem.TapiPortOpen(Sender: TObject);
begin
  FFileList.Clear;
  FApdProtocol.CancelProtocol;
  FModemState := msIdle;
  FApdProtocol.WriteFailAction := wfWriteAnyway;
  FApdProtocol.ZmodemOptionOverride := True;
  FApdProtocol.ZmodemFileOption := zfoWriteClobber;
  FApdProtocol.ZmodemFinishRetry := 50;
  FApdProtocol.FinishWait := 182;
  FApdProtocol.ProtocolType := ptZmodem;
  
  if Assigned(FOnOpenPort) then
    FOnOpenPort(Self);
end;

procedure TgsModem.WaitFile;
begin
  FModemState := msReceive;
  FApdProtocol.StartReceive;
end;

end.
