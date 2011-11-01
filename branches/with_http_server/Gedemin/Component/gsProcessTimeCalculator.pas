unit gsProcessTimeCalculator;

interface

type
  TgsDurationRecord = record
    Hour: Integer;
    Minute: Integer;
    Second: Integer;
  end;

  TgsProcessTimeCalculator = class
  private
    // Время начала подсчета
    FStartTickCount: Cardinal;
    // Позиция процесса считая от нуля
    FPosition: Cardinal;
    // Позиция процесса, при достижении которой процесс считается завершенным
    FMaxPosition: Cardinal;

    function InternalGetApproximateEnd: TgsDurationRecord;
  public
    constructor Create;

    procedure StartCalculation(const AMaxPosition: Cardinal);
    function GetApproxEndMS: Cardinal;
    function GetApproxEndString: String;

    property Position: Cardinal read FPosition write FPosition;
    property MaxPosition: Cardinal read FMaxPosition write FMaxPosition;
  end;


implementation

uses
  SysUtils, Windows;

const
  SEC_IN_MIN_IN_HOUR = 60;
  MSECOND_IN_SECOND = 1000;
  MSECOND_IN_MINUTE = 60000;
  MSECOND_IN_HOUR = 3600000;

{ TgsProcessTimeCalculator }

constructor TgsProcessTimeCalculator.Create;
begin
  FStartTickCount := 0;
  FPosition := 0;
  FMaxPosition := 0;
end;

function TgsProcessTimeCalculator.GetApproxEndString: String;
var
  Duration: TgsDurationRecord;
begin
  Duration := InternalGetApproximateEnd;
  if Duration.Hour > 0 then
    Result := Format('%d ч %d мин', [Duration.Hour, Duration.Minute])
  else
    if Duration.Minute > 0 then
      Result := Format('%d мин %d с', [Duration.Minute, Duration.Second])
    else
      Result := Format('%d с', [Duration.Second])
end;

function TgsProcessTimeCalculator.GetApproxEndMS: Cardinal;
var
  AverageTickPerPosition: Cardinal;
begin
  if FPosition = 0 then
    FPosition := 1;
  // Вычисление среднего кол-во миллисекунд, затрачиваемого на одну позицию процесса
  AverageTickPerPosition := (GetTickCount - FStartTickCount) div FPosition;
  Result := (FMaxPosition - FPosition) * AverageTickPerPosition;
end;

function TgsProcessTimeCalculator.InternalGetApproximateEnd: TgsDurationRecord;
var
  MSDuration: Integer;
begin
  MSDuration := GetApproxEndMS;

  if MSDuration >= MSECOND_IN_HOUR then
  begin
    Result.Hour := MSDuration div MSECOND_IN_HOUR;
    MSDuration := MSDuration mod MSECOND_IN_HOUR;
  end
  else
    Result.Hour := 0;

  if MSDuration >= MSECOND_IN_MINUTE then
  begin
    Result.Minute := MSDuration div MSECOND_IN_MINUTE;
    MSDuration := MSDuration mod MSECOND_IN_MINUTE;
  end
  else
    Result.Minute := 0;

  Result.Second := MSDuration div MSECOND_IN_SECOND;
  // Всегда оставляем последнюю секунду видимой
  if (Result.Hour = 0) and (Result.Minute = 0) and (Result.Second = 0) then
    Result.Second := 1;
end;

procedure TgsProcessTimeCalculator.StartCalculation(const AMaxPosition: Cardinal);
begin
  if AMaxPosition > 0 then
    FMaxPosition := AMaxPosition;

  if FMaxPosition > 0 then
  begin
    FPosition := 1;
    FStartTickCount := GetTickCount;
  end
  else
    raise Exception.Create('Не указано максимальное значение процесса');
end;

end.
