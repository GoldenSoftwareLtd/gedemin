unit Unit1;

interface

uses
  ComObj, ActiveX, gsDRV_TLB, StdVcl, Windows, SysUtils, Dialogs, AdPort;

type
//  TGetDataType = (dtgMass, dtgLabelParams, dtgLabelFormat, dtgMainGoodInfo, dtgAddGoodInfo);

  TScale15T = class(TAutoObject, IScale15T)
  private
    FComPort: Integer;                 // ����� COM-�����, def = 1
    FBaudRate: Integer;                // �������� �����, def = 9600
    FProtocol: Smallint;               // ��� ��������� ����� (0/1), def=1
    FPortEnabled: Boolean;
//    FPLUInfo: Variant;

    ApdComPort: TApdComPort;           // ��������� - ApdComPort
(*    Mass: Double;                      // ����� ������ �� �����
    LabelParams: String;               //*)
//    GetDataType: TGetDataType;         // ��� ����������� ������
//    procedure TriggerAvail(CP : TObject; Count : Word);
  protected
    function Get_PortNumber: Smallint; safecall;
    procedure Set_PortNumber(Value: Smallint); safecall;
    function Get_BaudRate: Smallint; safecall;
    procedure Set_BaudRate(Value: Smallint); safecall;
    procedure AboutBox; safecall;
    function Get_Protocol: Smallint; safecall;
    procedure Set_Protocol(Value: Smallint); safecall;
    function Get_Weight: Double; safecall;
    function Get_LabelParams: WideString; safecall;
    function GetPLUInfo(out Name1, Name2, Cost, Code: OleVariant;
      var PLU: OleVariant): OleVariant; safecall;
    function SetPLUInfo(var Name1, Name2, Cost, Code,
      PLU: OleVariant): OleVariant; safecall;
    function GetAddPLUInfo(var PLU: OleVariant): OleVariant; safecall;
    function Get_PortEnabled: WordBool; safecall;
    procedure Set_PortEnabled(Value: WordBool); safecall;
    function GetKeys(var Keys: OleVariant): OleVariant; safecall;
    function SetKeys(var Keys: OleVariant): OleVariant; safecall;
    { Protected declarations }
  public
    procedure Initialize; override;
    destructor Destroy; override;
  end;

implementation

uses ComServ, Forms;

function sOEMToChar(const aText: String): String;
var
  s1, s2: array[0..255] of Char;
begin
  StrPCopy(s1, aText);
  OEMToChar(S1, S2);
  Result := StrPas(S2);
end;

function sCharToOEM(const aText: String): String;
var
  s1, s2: array[0..255] of Char;
begin
  StrPCopy(s1, aText);
  CharToOEM(S1, S2);
  Result := StrPas(S2);
end;

function sCostToText(const sCost: Integer): String;
begin
  Result := Chr(Lo(sCost)) + Chr(Lo(sCost div 256)) + Chr(Lo(sCost div 65536));
end;

function sTextToCost(const sText: String): Integer;
{var
  i: Byte;}
begin
{  Result := 0;
  for i = 1 to Length(sText) do
    Result := Result + Exp(256, i-1) * Ord(sText[2])}

  Result := Ord(sText[1])+ 256 * Ord(sText[2]) + 65536 * Ord(sText[3]);
end;

procedure TScale15T.Initialize;
begin
  inherited;

  ApdComPort := TApdComPort.Create(nil);
  ApdComPort.AutoOpen := False;
  ApdComPort.Parity := pSpace;
//  ApdComPort.OnTriggerAvail := TriggerAvail;

  FComPort := 1;             // 1-� COM-����
  FBaudRate := 9600;         // �� 9600 baud
  FProtocol := 1;            // ��� ��������� - 1

  ApdComPort.ComNumber := FComPort;
  ApdComPort.Baud := FBaudRate;
end;

destructor TScale15T.Destroy;
begin
  FreeAndNil(ApdComPort);

  inherited Destroy;
end;
(*
procedure TCassTest.TriggerAvail(CP : TObject; Count : Word);
{var
  i: Integer;
//  s: String;}
begin
//  ShowMessage('TriggerAvail');

  case GetDataType of
    dtgMass:
      begin
        if (ApdComPort.GetChar = #1) and (Count = 5) then
        begin
          Mass := Ord(ApdComPort.GetChar);
          Mass := Mass + 256 * Ord(ApdComPort.GetChar);
        end;
      end;    // dtgMass
    dtgLabelParams:
      begin
//        S := '';
//        ShowMessage(IntToStr(ApdComPort.InBuffUsed));
        for i := 1 to Count do
        begin
//          LabelParams := LabelParams + {IntToStr(Ord(}ApdComPort.GetChar{)) + '_'};
          LabelParams := LabelParams;// + ApdComPort.GetChar;
        end;
//        ShowMessage(Copy(S, 1, Length(S)-2));
      end;    // dtgLabelParams
  end    // case
end;
*)
function TScale15T.Get_PortNumber: Smallint;
begin
  Result := FComPort;
end;

procedure TScale15T.Set_PortNumber(Value: Smallint);
begin
  FComPort := Value;
  ApdComPort.ComNumber := FComPort;
end;

function TScale15T.Get_BaudRate: Smallint;
begin
  Result := FBaudRate;
end;

procedure TScale15T.Set_BaudRate(Value: Smallint);
begin
  FBaudRate := Value;
  ApdComPort.Baud := FBaudRate; 
end;

procedure TScale15T.AboutBox;
begin
  ShowMessage('This is AboutBox! :) ');
end;

function TScale15T.Get_Protocol: Smallint;
begin
  Result := FProtocol;
end;

procedure TScale15T.Set_Protocol(Value: Smallint);
begin
  FProtocol := Value;
end;

// Get_Weight - ��������� ����� � �����
function TScale15T.Get_Weight: Double;
var
  i: Byte;
begin
  Result := -1;

//  ApdComPort.Open := True;

  ApdComPort.PutChar(#$A5); // scales
  if ApdComPort.WaitForString('w', 10, True, True) then
    ApdComPort.PutChar(#$9)  // scales - �����
  else begin
    ShowMessage('���� �� ��������!');   
    Exit;
  end;
{  if not ApdComPort.WaitForString(#1, 10, True, True) then
    Exit;}

// ���� 1/2 �������
  for i := 1 to 100 do
  begin
    Sleep(5);
    Application.ProcessMessages;
//    if Mass <> -1 then Break;
    if ApdComPort.InBuffUsed = 5 then Break;     // ��� ���������
// ���������� 3-� ������ sleep(5)
// ��� 30-40 ��� sleep
  end;

  if not (ApdComPort.InBuffUsed = 5) then Exit; // ������ ������ �� ��������

  try
    ApdComPort.GetChar;
    Result := Ord(ApdComPort.GetChar);
    Result := Result + 256 * Ord(ApdComPort.GetChar);
  except
  end;

//  ApdComPort.Open := False;
end;

// Get_LabelParams - ��������� ��������� ��������
function TScale15T.Get_LabelParams: WideString;
var
  i: Integer;
begin
  Result := '';
  
//  ApdComPort.Open := True;

  ApdComPort.PutChar(#$A5); // scales
  if ApdComPort.WaitForString('w', 10, True, True) then
    ApdComPort.PutChar(#$0B); // scales - ��������� ��������
{  if not ApdComPort.WaitForString(#1, 10, True, True) then
    Exit;}

// ���� 1/2 �������
  for i := 1 to 100 do
  begin
    Sleep(5);
    Application.ProcessMessages;
//    if Length(LabelParams) = 108 then Break;
    if ApdComPort.InBuffUsed = 108 then Break;   // ��� ���������
// ���������� 10-� ������ sleep(5)
// ��� sleep �� ������� - ?
  end;
//  ShowMessage(IntToStr(ApdComPort.InBuffUsed));

  if not (ApdComPort.InBuffUsed = 108) then Exit; // ������ ������ �� ��������

  try
    for i := 2 to ApdComPort.InBuffUsed-1 do
      Result := Result + ApdComPort.GetChar;
  except                                 
  end;

//  ApdComPort.Open := False;
end;

// GetPLUInfo - ��������� �������� ��������� ������
function TScale15T.GetPLUInfo(out Name1, Name2, Cost, Code: OleVariant;
  var PLU: OleVariant): OleVariant;
var
  i, PLUNumber: Integer;
  S1, S2: String;
begin
  Result := False;
//  ApdComPort.Open := True;

  PLUNumber := PLU; // High Hi Lo as int

  ApdComPort.PutChar(#$A5); // scales
  if ApdComPort.WaitForString('w', 10, True, True) then
    ApdComPort.PutChar(#$6); // scales - ���. � ������ (��������)
  if ApdComPort.WaitForString(#1, 10, True, True) then
    ApdComPort.OutPut := Chr(Lo(PLUNumber))+Chr(Hi(PLUNumber))+#$21;   // scales - ���������� � ������

// ���� 1/2 �������
  for i := 1 to 100 do
  begin
    Sleep(5);
    Application.ProcessMessages;
    if ApdComPort.InBuffUsed = 63 then Break;     // ��� ���������
// ���������� 7-� ������ sleep(5)
  end;

  if not (ApdComPort.InBuffUsed = 63) then Exit; // ������ ������ �� ��������

{  S1 := '';
  for i := 1 to ApdComPort.InBuffUsed do
    S1 := S1 + IntToStr(Ord(ApdComPort.GetChar)) + '_';
  ShowMessage(S1);}
//1_0_0_6_1_0_110_10_0_0_0_0_0_0_138_160_224_46_145_173_165_166_174_170_32_167_160_162_46_32_32_32_32_32_32_32_32_32_224_174_170_160_171_174_173_164_40_145_175_160_224_226_160_170_41_49_170_163_32_32_32_32_16

//  ShowMessage(IntToStr(i));              
  try
    for i := 1 to 3 do ApdComPort.GetChar;
    try   
      Code := sTextToCost(ApdComPort.GetChar+ApdComPort.GetChar+ApdComPort.GetChar);
    except
    end;
    try
      Cost := sTextToCost(ApdComPort.GetChar+ApdComPort.GetChar+ApdComPort.GetChar);
    except
    end;
    for i := 1 to 5 do ApdComPort.GetChar;
    for i := 1 to 24 do
      S1 := S1 + ApdComPort.GetChar;
    for i := 1 to 24 do
      S2 := S2 + ApdComPort.GetChar;
  except
  end;

  if ApdComPort.GetChar <> #16 then Exit;        // ������. ������ 

  Name1 := sOEMToChar(Trim(S1));
  Name2 := sOEMToChar(Trim(S2));

  Result := True;

//  ApdComPort.Open := False;
end;

// SetPLUInfo - �������� �������� ��������� ������
function TScale15T.SetPLUInfo(var Name1, Name2, Cost, Code,
  PLU: OleVariant): OleVariant;
var
  PLUNumber: Integer;
  S1, S2: String;
begin
  Result := False;

//  ApdComPort.Open := True;

  PLUNumber := PLU; // High Hi Lo as int

  ApdComPort.PutChar(#$A5); // scales
  if ApdComPort.WaitForString('w', 10, True, True) then
    ApdComPort.PutChar(#$5); // scales - ���. � ������ (��������)
  if ApdComPort.WaitForString(#1, 10, True, True) then     // ���� ������ � ������ ������
    ApdComPort.OutPut := Chr(Lo(PLUNumber))+Chr(Hi(PLUNumber))+#$21; // scales - ���������� � ������
  if ApdComPort.WaitForString(#1, 10, True, True) then     // ���� ������ � ������ ������
  begin
//    ApdComPort.OutPut := '12345678901234567890123456789012345678'; // ���. ����   
    ApdComPort.OutPut := #0#0;
    ApdComPort.OutPut := sCostToText(Code); // ��� ������
    ApdComPort.OutPut := sCostToText(Cost); // ����
    ApdComPort.OutPut := #0#0#0#0#0;

// +++ ��������� � �������� ������������
    S1 := sCharToOEM(Copy(Name1, 1, 24));
    if Length(S1) < 24 then
      S1 := S1 + StringOfChar(' ', 24-Length(S1));
    S2 := sCharToOEM(Copy(Name2, 1, 24));
    if Length(S2) < 24 then
      S2 := S2 + StringOfChar(' ', 24-Length(S2));
    ApdComPort.OutPut := S1; // ������������ 1
    ApdComPort.OutPut := S2; // ������������ 2
// --- ��������� � �������� ������������
  end;
  if ApdComPort.WaitForString(#$10, 10, True, True) then     // ���� ������� ������
  begin
//    ShowMessage('������ ��������.');
    Result := True;
  end;
{  else
    ShowMessage('�� ������� �������� ������!');}

//  ApdComPort.Open := False;
end;

// GetAddPLUInfo - ��������� �������������� ��������� ������ - �� �������!!!!!
function TScale15T.GetAddPLUInfo(var PLU: OleVariant): OleVariant;
var
  i, PLUNumber: Integer;
  S1{, S2}: String;
begin
  Result := False;
//  ApdComPort.Open := True;

  PLUNumber := PLU; // High Hi Lo as int
                   
  ApdComPort.PutChar(#$A5); // scales
  if ApdComPort.WaitForString('w', 10, True, True) then
    ApdComPort.PutChar(#$6); // scales - ���. � ������ (��������)
  if ApdComPort.WaitForString(#1, 10, True, True) then
    ApdComPort.OutPut := Chr(Lo(PLUNumber)) + Chr(Hi(PLUNumber))+#1;   // scales - ���������� � ������
    
// ���� 1/2 �������
  for i := 1 to 100 do
  begin
    Sleep(5);
    Application.ProcessMessages;
    if ApdComPort.InBuffUsed = 50 then Break;     // ��� ���������
// ���������� ?-� ������ sleep(5)
  end;
                                    
//  if not (ApdComPort.InBuffUsed = 50) then Exit; // ������ ������ �� ��������

  S1 := '';
  for i := 1 to ApdComPort.InBuffUsed do
    S1 := S1 + IntToStr(Ord(ApdComPort.GetChar)) + '_';
  ShowMessage(S1);
//1_0_0_6_1_0_110_10_0_0_0_0_0_0_138_160_224_46_145_173_165_166_174_170_32_167_160_162_46_32_32_32_32_32_32_32_32_32_224_174_170_160_171_174_173_164_40_145_175_160_224_226_160_170_41_49_170_163_32_32_32_32_16

//  ShowMessage(IntToStr(i));
{  try
    for i := 1 to 6 do ApdComPort.GetChar;
    try
      Cost := sTextToCost(ApdComPort.GetChar+ApdComPort.GetChar+ApdComPort.GetChar);
    except
    end;
    for i := 1 to 5 do ApdComPort.GetChar;
    for i := 1 to 24 do
      S1 := S1 + ApdComPort.GetChar;
    for i := 1 to 24 do
      S2 := S2 + ApdComPort.GetChar;
  except
  end;}

//  if ApdComPort.GetChar <> #16 then Exit;        // ������. ������

{  Name1 := sOEMToChar(Trim(S1));
  Name2 := sOEMToChar(Trim(S2));}

  Result := True;

//  ApdComPort.Open := False;
end;

function TScale15T.Get_PortEnabled: WordBool;
begin
  Result := FPortEnabled;
end;

procedure TScale15T.Set_PortEnabled(Value: WordBool);
begin
  ApdComPort.Open := Value;               
//  Sleep(TimeToSleep);
//  if Value then SetCodeSet;                          
  FPortEnabled := Value;
end;

// GetKeys - ���������� ������ ������������ ����� ��������� � �������� �������
function TScale15T.GetKeys(var Keys: OleVariant): OleVariant;
var
  i: Integer;
begin
  Result := False;
  
  ApdComPort.PutChar(#$A5);  // scales
  if ApdComPort.WaitForString('w', 10, True, True) then
    ApdComPort.PutChar(#$8)  // scales - ��������� ���������� - �������
  else
    Exit;

// ���� 1/2 �������
  for i := 1 to 100 do
  begin
    Sleep(5);
    Application.ProcessMessages;
    if ApdComPort.InBuffUsed = 128 then Break;   // ��� ���������
// ���������� 13-� ������ sleep(5)
  end;

  if not (ApdComPort.InBuffUsed = 128) then Exit;// ������ ������ �� ��������

  ApdComPort.GetChar;
  for i := 0 to 62 do
    Keys[i] := Ord(ApdComPort.GetChar) + 256*Ord(ApdComPort.GetChar);

  if ApdComPort.GetChar <> #16 then Exit;        // ������. ������

  Result := True;
end;

// SetKeys - ������������� ������ ������������ ����� ��������� � �������� �������
function TScale15T.SetKeys(var Keys: OleVariant): OleVariant;
var
  i: Integer;
begin
  Result := False;

  ApdComPort.PutChar(#$A5); // scales
  if ApdComPort.WaitForString('w', 10, True, True) then
    ApdComPort.PutChar(#$7); // scales - ��������� ���������� - ��������

  if ApdComPort.WaitForString(#1, 10, True, True) then    // ���� ������ � ������ ������
  begin
    for i := 0 to 62 do
      ApdComPort.Output := Chr(Lo(Byte(Keys[i]))) + Chr(Lo(Byte(Keys[i]) div 256));
  end;

  if ApdComPort.WaitForString(#$10, 10, True, True) then     // ���� ������� ������
    Result := True;
end;


initialization
  TAutoObjectFactory.Create(ComServer, TScale15T, Class_Scale15T,
    ciMultiInstance, tmApartment);
end.
