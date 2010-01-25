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

    //
    FApdComPort: TApdComPort;
    FApdDataPacket: TApdDataPacket;

    //
    FEnabled: Boolean;
    FBarCode: String;
    FTestCode: String;

    FOnChange: TNotifyEvent;
    FAllowStreamedEnabled: Boolean;
    FStreamedEnabled: Boolean;

    procedure SetComNumber(Value: Byte);
    procedure SetParity(Value: TParity);
    procedure SetBaudRate(Value: Integer);
    procedure SetDataBits(Value: Byte);
    procedure SetStopBits(Value: Byte);
    procedure SetBeforeChar(Value: Word);
    procedure SetAfterChar(Value: Word);
    procedure SetCRSuffix(Value: Boolean);
    procedure SetLFSuffix(Value: Boolean);
    procedure SetEndString;

    procedure SetBarCode(Value: String);
    procedure SetEnabled(Value: Boolean);


    procedure OnStringPacket(Sender: TObject; Data : string);
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
    property ComNumber: Byte read FComNumber write SetComNumber default 1;
    property Parity: TParity read FParity write SetParity default pSpace;
    property BaudRate: Integer read FBaudRate write SetBaudRate default 9600;
    property DataBits: Byte read FDataBits write SetDataBits default 7;
    property StopBits: Byte read FStopBits write SetStopBits default 2;
    property BeforeChar: Word read FBeforeChar write SetBeforeChar default 0;
    property AfterChar: Word read FAfterChar write SetAfterChar default 0;
    property CRSuffix: Boolean read FCRSuffix write SetCRSuffix default True;
    property LFSuffix: Boolean read FLFSuffix write SetLFSuffix default True;

    property BarCode: String read FBarCode write SetBarCode;
    property TestCode: String read FTestCode write FTestCode;
    property Enabled: Boolean read FEnabled write SetEnabled default False;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property AllowStreamedEnabled: Boolean read FAllowStreamedEnabled write FAllowStreamedEnabled
      default False;
  end;

procedure Register;

implementation

constructor TgsComScaner.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FApdComPort := TApdComPort.Create(Self);
  FApdComPort.AutoOpen := False;

  FApdDataPacket := TApdDataPacket.Create(Self);
  FApdDataPacket.IncludeStrings := False;
  FApdDataPacket.OnStringPacket := OnStringPacket;
  FApdDataPacket.ComPort := FApdComPort;
  FApdDataPacket.TimeOut := 0;
  FApdDataPacket.Enabled := True;
  FAllowStreamedEnabled := False;

  ComNumber := 1;
  Parity    := pSpace;
  BaudRate  := 9600;
  DataBits  := 7;
  StopBits  := 2;
  BeforeChar := 0;
  AfterChar  := 0;
  CRSuffix   := True;
  LFSuffix   := True;

end;

destructor TgsComScaner.Destroy;
begin
  if FApdComPort <> nil then
    FreeAndNil(FApdComPort);

  if FApdDataPacket <> nil then
    FreeAndNil(FApdDataPacket);

  inherited Destroy;
end;

// Номер COM-порта
procedure TgsComScaner.SetComNumber(Value: Byte);
begin
  FApdComPort.ComNumber := Value;
  FComNumber := FApdComPort.ComNumber;
end;

// Четность
procedure TgsComScaner.SetParity(Value: TParity);
begin
  FApdComPort.Parity := Value;
  FParity := FApdComPort.Parity;
end;

// Скорость
procedure TgsComScaner.SetBaudRate(Value: Integer);
begin
  FApdComPort.Baud := Value;
  FBaudRate := FApdComPort.Baud;
end;

// Биты данных
procedure TgsComScaner.SetDataBits(Value: Byte);
begin
  FApdComPort.DataBits := Value;
  FDataBits := FApdComPort.DataBits;
end;

// Стоповые биты
procedure TgsComScaner.SetStopBits(Value: Byte);
begin
  FApdComPort.StopBits := Value;
  FStopBits := FApdComPort.StopBits;
end;

// Начальный символ
procedure TgsComScaner.SetBeforeChar(Value: Word);
begin
  FBeforeChar := Value;
  if FBeforeChar <> 0 then
  begin
    FApdDataPacket.StartCond := scString;
    FApdDataPacket.StartString := Chr(FBeforeChar);
  end else
  begin
    FApdDataPacket.StartCond := scAnyData;
    FApdDataPacket.StartString := '';
  end
end;

// Конечный символ
procedure TgsComScaner.SetAfterChar(Value: Word);
begin
  FAfterChar := Value;
  SetEndString;
end;

// Суффикс - возврат коретки
procedure TgsComScaner.SetCRSuffix(Value: Boolean);
begin
  FCRSuffix := Value;
  SetEndString;
end;

// Суффикс - новая строка
procedure TgsComScaner.SetLFSuffix(Value: Boolean);
begin
  FLFSuffix := Value;
  SetEndString;
end;

// установка параметров
procedure TgsComScaner.SetEndString;
var
  S: String;
begin
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
    FApdDataPacket.EndCond := [];
    FApdDataPacket.EndString := '';
  end;
end; 

// Штрих-код
procedure TgsComScaner.SetBarCode(Value: String);
begin
  FBarCode := Value;
  DoOnChange;
end;

// Enabled/Disabled
procedure TgsComScaner.SetEnabled(Value: Boolean);
begin
  if (csReading in ComponentState) and
     (not (csDesigning in ComponentState)) then
    FStreamedEnabled := Value
  else
    try
      FApdComPort.Open := Value;
      if Value then
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
  FBarCode := Data;
  DoOnChange;
end;

// считался (или был установлен) штрих-код
procedure TgsComScaner.DoOnChange;
begin
  try
    if Assigned(FOnChange) then FOnChange(Self);
  except
  end;
end;

procedure Register;
begin
  RegisterComponents('gsNew', [TgsComScaner]);
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

end.
