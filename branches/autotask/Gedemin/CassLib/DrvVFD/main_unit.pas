unit main_unit;

interface

uses
  ComObj, ActiveX, gsDRV_TLB, StdVcl, Windows, SysUtils, AdPort;

type
  TFirichVFD = class(TAutoObject, IFirichVFD)
  private
    FPortNumber: Smallint;             // номер COM-порта, def = 1
    FBaudRate: Integer;                // скорость порта, def = 9600
    FPortEnabled: Boolean;             // признак, открыт ли порт
    FDisplayMode: Smallint;            // режим дисплея    
    ApdComPort: TApdComPort;           // компонент - ApdComPort

    procedure SetCodeSet;              // установить кодовую страницу ( = 866)
  protected
    function Get_PortNumber: Smallint; safecall;
    procedure Set_PortNumber(Value: Smallint); safecall;
    function Get_BaudRate: Integer; safecall;
    procedure Set_BaudRate(Value: Integer); safecall;
    function Get_PortEnabled: WordBool; safecall;
    procedure Set_PortEnabled(Value: WordBool); safecall;
    procedure ClearDisplay; safecall;
    procedure WriteText(const Text: WideString); safecall;
    procedure WriteToLowerLine(const Text: WideString); safecall;
    procedure WriteToUpperLine(const Text: WideString); safecall;
    function Get_DisplayMode: Smallint; safecall;
    procedure Set_DisplayMode(Value: Smallint); safecall;
    procedure InitializeDisplay; safecall;
    procedure MoveCursorTo(aPos: Smallint); safecall;
    procedure MoveCursorToPos(column, row: Smallint); safecall;
    { Protected declarations }
  public
    procedure Initialize; override;
    destructor Destroy; override;
  end;

implementation

uses ComServ;

{$I VFDconsts.inc}
const
  TimeToSleep = 20;

function sCharToOEM(const aText: String): String;
var
  s1, s2: array[0..255] of Char;
begin
  StrPCopy(s1, aText);
  CharToOEM(S1, S2);
  Result := StrPas(S2);
end;

procedure TFirichVFD.Initialize;
begin
  inherited;

  ApdComPort := TApdComPort.Create(nil);
  ApdComPort.AutoOpen := False;

  FPortNumber := 2;          // 1-й COM-порт
  FBaudRate := 9600;         // на 9600 baud

  ApdComPort.ComNumber := FPortNumber;
  ApdComPort.Baud := FBaudRate;

//  ApdComPort.Open := True;
end;

destructor TFirichVFD.Destroy;
begin
  FreeAndNil(ApdComPort);

  inherited Destroy;
end;


function TFirichVFD.Get_PortNumber: Smallint;
begin
  Result := FPortNumber;
end;

procedure TFirichVFD.Set_PortNumber(Value: Smallint);
begin
  FPortNumber := Value;
  ApdComPort.ComNumber := FPortNumber;
end;

function TFirichVFD.Get_BaudRate: Integer;
begin
  Result := FBaudRate;
end;

procedure TFirichVFD.Set_BaudRate(Value: Integer);
begin
  FBaudRate := Value;
  ApdComPort.Baud := FBaudRate;
end;

function TFirichVFD.Get_PortEnabled: WordBool;
begin
  Result := FPortEnabled;
end;

procedure TFirichVFD.Set_PortEnabled(Value: WordBool);
begin
  ApdComPort.Open := Value;
  Sleep(TimeToSleep);
  if Value then SetCodeSet;
  FPortEnabled := Value;
end;

// +++++++++++++++ methods +++++++++++++++

// SetCodeSet - установить кодовую страницу (= 866)
procedure TFirichVFD.SetCodeSet;
begin
{  ApdComPort.OutPut := Format(cSetFontSet, ['R']);
  Sleep(TimeToSleep);}
  ClearDisplay;   
  ApdComPort.OutPut := Format(cSetCodeTable, ['R']);
  Sleep(TimeToSleep);
end;

// ClearDisplay - очищает дисплей
procedure TFirichVFD.ClearDisplay;
begin
  ApdComPort.OutPut := cClearDisplay;
  Sleep(TimeToSleep);                                       
end;

// WriteString - выводит текст в текущую позицию
procedure TFirichVFD.WriteText(const Text: WideString);
begin
  ApdComPort.OutPut := sCharToOEM(Text);
  Sleep(TimeToSleep);
end;

// WriteToLowerLine - выводит текст в нижнюю строку
procedure TFirichVFD.WriteToLowerLine(const Text: WideString);
begin
  ApdComPort.OutPut := Format(cWriteToLowerLine, [sCharToOEM(Text)]);
  Sleep(TimeToSleep);
  FDisplayMode := 3; 
end;

// WriteToUpperLine - выводит текст в верхнюю строку
procedure TFirichVFD.WriteToUpperLine(const Text: WideString);
begin
  ApdComPort.OutPut := Format(cWriteToUpperLine, [sCharToOEM(Text)]);
  Sleep(TimeToSleep);
  FDisplayMode := 3;
end;

function TFirichVFD.Get_DisplayMode: Smallint;
begin
  Result := FDisplayMode;
end;

procedure TFirichVFD.Set_DisplayMode(Value: Smallint);
begin
  case Value of
    0: ApdComPort.OutPut := cOverwriteMode;
    1: ApdComPort.OutPut := cVertScrollMode;
    2: ApdComPort.OutPut := cHorizScrollMode;
  end;
  Sleep(TimeToSleep);
  FDisplayMode := Value;
end;

procedure TFirichVFD.InitializeDisplay;
begin
  ApdComPort.OutPut := cInitialize;
  Sleep(TimeToSleep);
end;

// MoveCursorTo - перемещает курсор в зарезев. позицию (left, right, up, down, home, bottom)
procedure TFirichVFD.MoveCursorTo(aPos: Smallint);
begin
//  ApdComPort.OutPut := Format(cWriteToUpperLine, [sCharToOEM(Text)]);
  ApdComPort.OutPut := Format(cMoveCursor, [aPos]);
  Sleep(TimeToSleep);
end;

// MoveCursorToPos - перемещает курсор в указанную позицию   
procedure TFirichVFD.MoveCursorToPos(column, row: Smallint);
begin
  ApdComPort.OutPut := Format(cCursorToPosition, [column, row]);  
  Sleep(TimeToSleep);
end;

initialization
  TAutoObjectFactory.Create(ComServer, TFirichVFD, Class_FirichVFD,
    ciMultiInstance, tmApartment);                            
end.
