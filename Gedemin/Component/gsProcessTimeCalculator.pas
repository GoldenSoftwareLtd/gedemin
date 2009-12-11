unit gsProcessTimeCalculator;

interface

type
  TgsDurationRecord = record
    Hour: Integer;
    Minute: Integer;
    Second: Integer;
    MSecond: Integer;
  end;

  TgsProcessTimeCalculator = class
  private
    // ����� ������ ��������
    FStartTickCount: Integer;
    // ������� �������� ������ �� ����
    FPosition: Integer;
    // ������� ��������, ��� ���������� ������� ������� ��������� �����������
    FMaxPosition: Integer;

    function InternalGetApproximateEnd: TgsDurationRecord;
  public
    constructor Create;

    procedure StartCalculation(const AMaxPosition: Integer);
    function GetApproxEndMS: Integer;
    function GetApproxEndString: String;

    property Position: Integer read FPosition write FPosition;
    property MaxPosition: Integer read FMaxPosition write FMaxPosition;
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
  FPosition := -1;
  FMaxPosition := -1;
end;

function TgsProcessTimeCalculator.GetApproxEndString: String;
var
  Duration: TgsDurationRecord;
begin
  Duration := InternalGetApproximateEnd;
  if Duration.Hour > 0 then
    Result := Format('%d � %d ���', [Duration.Hour, Duration.Minute])
  else
    if Duration.Minute > 0 then
      Result := Format('%d ��� %d �', [Duration.Minute, Duration.Second])
    else
      Result := Format('%d �', [Duration.Second])
end;

function TgsProcessTimeCalculator.GetApproxEndMS: Integer;
var
  AverageTickPerPosition: Integer;
begin
  if FPosition <= 0 then
    FPosition := 1;
  // ���������� �������� ���-�� �����������, �������������� �� ���� ������� ��������
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
  MSDuration := MSDuration mod MSECOND_IN_SECOND;
  
  Result.MSecond := MSDuration;
end;

procedure TgsProcessTimeCalculator.StartCalculation(const AMaxPosition: Integer);
begin
  if AMaxPosition > 0 then
    FMaxPosition := AMaxPosition;

  if FMaxPosition > 0 then
  begin
    FPosition := 1;
    FStartTickCount := GetTickCount;
  end
  else
    raise Exception.Create('�� ������� ������������ �������� ��������');
end;

end.
