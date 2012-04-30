unit gsComScaner;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  AdPort, AdPacket;

type
  TgsComScaner = class(TComponent)
  private
    { Private declarations }
    FComNumber: Byte;
    FParity: TParity;
    FBaudRate: Integer;
    FDataBits: Byte;
    FStopBits: Byte;
    FBeforeChar: Word;
    FAfterChar: Word;
    FCRSuffix: Boolean;
    FLFSuffix: Boolean;
    FPacketSize: Integer;

    //
    FApdComPort: TApdComPort;
    FApdDataPacket: TApdDataPacket;

    //
    FEnabled: Boolean;
    FBarCode: String;
    FTestCode: String;
    FIntCode: Integer;

    FOnChange: TNotifyEvent;
    FAllowStreamedEnabled: Boolean;
    FStreamedEnabled: Boolean;

    procedure SetBarCode(Value: String);
    procedure SetEnabled(Value: Boolean);

    procedure OnStringPacket(Sender: TObject; Data : string);
    procedure OnPacket(Sender: TObject; Data: Pointer; Size: Integer);
  protected
    { Protected declarations }
    procedure DoOnChange; virtual;
    procedure Loaded; override;
  public
    { Public declarations }
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
    procedure PutString(S: String);

  published
    { Published declarations }
    property ComNumber: Byte read FComNumber write FComNumber default 1;
    property Parity: TParity read FParity write FParity default pSpace;
    property BaudRate: Integer read FBaudRate write FBaudRate default 9600;
    property DataBits: Byte read FDataBits write FDataBits default 7;
    property StopBits: Byte read FStopBits write FStopBits default 2;
    property BeforeChar: Word read FBeforeChar write FBeforeChar default 0;
    property AfterChar: Word read FAfterChar write FAfterChar default 0;
    property CRSuffix: Boolean read FCRSuffix write FCRSuffix default True;
    property LFSuffix: Boolean read FLFSuffix write FLFSuffix default True;

    property BarCode: String read FBarCode;
    property TestCode: String read FTestCode write FTestCode;
    property Enabled: Boolean read FEnabled write SetEnabled default False;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property AllowStreamedEnabled: Boolean read FAllowStreamedEnabled write FAllowStreamedEnabled
      default False;
    property PacketSize: Integer read FPacketSize write FPacketSize default 0;
    property IntCode: Integer read FIntCode;
  end;

procedure Register;

implementation

constructor TgsComScaner.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FApdComPort := TApdComPort.Create(nil);
  FApdComPort.AutoOpen := False;

  FApdDataPacket := TApdDataPacket.Create(nil);
  FApdDataPacket.IncludeStrings := False;
  FApdDataPacket.OnStringPacket := OnStringPacket;
  FApdDataPacket.OnPacket := OnPacket;
  FApdDataPacket.ComPort := FApdComPort;
  FApdDataPacket.TimeOut := 0;
  FApdDataPacket.Enabled := False;

  FAllowStreamedEnabled := False;

  FComNumber  := 1;
  FParity     := pSpace;
  FBaudRate   := 9600;
  FDataBits   := 7;
  FStopBits   := 2;
  FBeforeChar := 0;
  FAfterChar  := 0;
  FCRSuffix   := True;
  FLFSuffix   := True;
end;

destructor TgsComScaner.Destroy;
begin
  FreeAndNil(FApdComPort);
  FreeAndNil(FApdDataPacket);
  inherited Destroy;
end;

// Штрих-код
procedure TgsComScaner.SetBarCode(Value: String);
begin
  FBarCode := Value;
  DoOnChange;
end;

// Enabled/Disabled
procedure TgsComScaner.SetEnabled(Value: Boolean);
var
  S: String;
begin
  if (csReading in ComponentState) and
     (not (csDesigning in ComponentState)) then
    FStreamedEnabled := Value
  else
    try
      if not FApdComPort.Open then
      begin
        FApdComPort.ComNumber := FComNumber;
        FApdComPort.Parity := FParity;
        FApdComPort.Baud := FBaudRate;
        FApdComPort.DataBits := FDataBits;
        FApdComPort.StopBits := FStopBits;
      end;

      FApdComPort.Open := Value;

      if Value then
      begin
        if FBeforeChar <> 0 then
        begin
          FApdDataPacket.StartCond := scString;
          FApdDataPacket.StartString := Chr(FBeforeChar);
        end else
        begin
          FApdDataPacket.StartCond := scAnyData;
          FApdDataPacket.StartString := '';
        end;

        S := '';
        if FAfterChar <> 0 then
          S := S + Chr(FAfterChar);
        if FCRSuffix then
          S := S + #13;
        if FLFSuffix then
          S := S + #10;

        if S > '' then
        begin
          FApdDataPacket.EndCond := [ecString];
          FApdDataPacket.EndString := S;
        end else
        begin
          FApdDataPacket.EndCond := [ecPacketSize];
          FApdDataPacket.EndString := '';
          FApdDataPacket.PacketSize := FPacketSize;
        end;
      end;

      FApdDataPacket.Enabled := Value;

      FEnabled := FApdComPort.Open and FApdDataPacket.Enabled;
    except
      on E: Exception do
      begin
        if csLoading in ComponentState then
          Application.HandleException(E)
        else
          raise;
      end;
    end;
end;

// пришли данные
procedure TgsComScaner.OnStringPacket(Sender: TObject; Data: string);
begin
  if not (ecPacketSize in FApdDataPacket.EndCond) then
    SetBarCode(Data);
end;

procedure TgsComScaner.OnPacket(Sender: TObject; Data: Pointer; Size: Integer);
var
  I: Integer;
  S: String;
begin
  if ecPacketSize in FApdDataPacket.EndCond then
  begin
    S := '';
    FIntCode := 0;
    for I := 0 to Size - 1 do
    begin
      S := S + IntToHex(PByteArray(Data)^[I], 2);

      if FPacketSize <= SizeOf(FIntCode) then
        PByteArray(@FIntCode)^[I] := PByteArray(Data)^[I];
    end;
    SetBarCode(S);
  end;
end;

// считался (или был установлен) штрих-код
procedure TgsComScaner.DoOnChange;
begin
  try
    if Assigned(FOnChange) then FOnChange(Self);
  except
    on E: Exception do
      Application.HandleException(E);
  end;
end;

procedure TgsComScaner.PutString(S: String);
begin
  FApdComPort.PutString(S);
end;

procedure TgsComScaner.Loaded;
begin
  if (not Enabled) and FAllowStreamedEnabled and FStreamedEnabled then
    Enabled := True;

  inherited Loaded;
end;

procedure Register;
begin
  RegisterComponents('gsNew', [TgsComScaner]);
end;

end.
