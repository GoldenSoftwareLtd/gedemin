unit amc_unit;

interface

uses
  ComObj, ActiveX, gsDRV_TLB, StdVcl;

type
  TTAMC100F = class(TAutoObject, ITAMC100F)
  protected
    function Connect(Port, NetNum: SYSINT): SYSINT; safecall;
    procedure Disconnect; safecall;
    function AddSale(const Name: WideString; Price, Quantity: Double;
      Section: SYSINT): SYSINT; safecall;
    function PrintCheck: SYSINT; safecall;
    procedure ClearSales; safecall;
    function GetErrorMessage: WideString; safecall;
    procedure SetSupplierCode(const Code: WideString); safecall;
    function ClearDisplay: SYSINT; safecall;
    function Get_CashSum: Double; safecall;
    procedure Set_CashSum(Value: Double); safecall;
    function Get_CheckSum: Double; safecall;
    function Get_ClearBufMode: SYSINT; safecall;
    procedure Set_ClearBufMode(Value: SYSINT); safecall;
    function Get_CreditMode: SYSINT; safecall;
    procedure Set_CreditMode(Value: SYSINT); safecall;
    function Get_ReturnMode: SYSINT; safecall;
    procedure Set_ReturnMode(Value: SYSINT); safecall;
    procedure BringSum(Sum: Double); safecall;
    procedure RemoveSum(Sum: Double); safecall;
    function GetErrorCode: SYSINT; safecall;
    function GetCashSum: Double; safecall;
    { Protected declarations }
  end;

  function ConnectKKM(Port, NetNum: Integer): Integer; stdcall; external 'chon100bel.dll';
  procedure DisconnectKKM; stdcall; external 'chon100bel.dll';
  function cbAddSale(Name: PChar; Price, Qty: Double; Section: Integer): Integer; stdcall; external 'chon100bel.dll';
  function dll_PrintCheck: Integer; stdcall; external 'chon100bel.dll' name 'PrintCheck';
  procedure cbClearSales; stdcall; external 'chon100bel.dll';
  function GetErrorMsg: PChar; stdcall; external 'chon100bel.dll';
  procedure dll_SetSupplierCode(Code: PChar); stdcall; external 'chon100bel.dll' name 'SetSupplierCode';
  function cbSetCash(Value: Double): Integer; stdcall; external 'chon100bel.dll';
  function cbGetCash: Double; stdcall; external 'chon100bel.dll';
  function cbGetSum: Double; stdcall; external 'chon100bel.dll';
  function DoubleReset: Integer; stdcall; external 'chon100bel.dll';
  procedure cbSetClearBufMode(Mode: Integer); stdcall; external 'chon100bel.dll';
  function cbGetClearBufMode: Integer; stdcall; external 'chon100bel.dll';
  procedure cbSetCreditMode(Mode: Integer); stdcall; external 'chon100bel.dll';
  function cbGetCreditMode: Integer; stdcall; external 'chon100bel.dll';
  procedure cbSetReturnMode(Mode: Integer); stdcall; external 'chon100bel.dll';
  function cbGetReturnMode: Integer; stdcall; external 'chon100bel.dll';
  function dll_BringSum(Sum: Double): Integer; stdcall; external 'chon100bel.dll' name 'BringSum';
  function dll_RemoveSum(Sum: Double): Integer; stdcall; external 'chon100bel.dll' name 'RemoveSum';
  function dll_GetErrorCode: Integer; stdcall; external 'chon100bel.dll' name 'GetErrorCode';
  function dll_GetCashSum(var Sum: Double): Integer; stdcall; external 'chon100bel.dll' name 'GetCashSum';

implementation

uses ComServ, SysUtils, Dialogs;

function TTAMC100F.Connect(Port, NetNum: SYSINT): SYSINT;
begin
  Result := ConnectKKM(Port, NetNum);
end;

procedure TTAMC100F.Disconnect;
begin
  DisconnectKKM;
end;

// строка продажи
function TTAMC100F.AddSale(const Name: WideString; Price, Quantity: Double;
  Section: SYSINT): SYSINT;
var
  S: String;
begin
  S := Name;
  Result := cbAddSale(PChar(S), Price, Quantity, Section);
end;

// печать чека
function TTAMC100F.PrintCheck: SYSINT;
begin
  Result := dll_PrintCheck;
end;

// очистка базы данных описателей товаров
procedure TTAMC100F.ClearSales;
begin
 cbClearSales;
end;
                                
// текст сообщени€ об ошибке
function TTAMC100F.GetErrorMessage: WideString;
begin
  Result := StrPas(GetErrorMsg);
end;
                             
// передача кода разработчика
procedure TTAMC100F.SetSupplierCode(const Code: WideString);
var
  S: String;
begin
  S := Code;
  dll_SetSupplierCode(PChar(S));
end;
                        
// очистка диспле€
function TTAMC100F.ClearDisplay: SYSINT;
begin
  Result := DoubleReset;
end;

// сумма оплаты
function TTAMC100F.Get_CashSum: Double;
begin
  Result := cbGetCash;
end;
// сумма оплаты 
procedure TTAMC100F.Set_CashSum(Value: Double);
begin
  if cbSetCash(Value) <> 1 then
    ShowMessage(GetErrorMsg);
end;

// сумма чека
function TTAMC100F.Get_CheckSum: Double;
begin
  Result := cbGetSum;
end;

// режим очистки списка описателей после печати чека (0 - не очищать/1 - очищать)
function TTAMC100F.Get_ClearBufMode: SYSINT;
begin
  Result := cbGetClearBufMode;
end;
procedure TTAMC100F.Set_ClearBufMode(Value: SYSINT);
begin
  cbSetClearBufMode(Value);
end;

// вид платежа (0 - нал/1 - безнал)
function TTAMC100F.Get_CreditMode: SYSINT;
begin
  Result := cbGetCreditMode;
end;
procedure TTAMC100F.Set_CreditMode(Value: SYSINT);
begin               
  cbSetCreditMode(Value);
end;
                                
// тип чека (0 - продажа/1 - возврат)
function TTAMC100F.Get_ReturnMode: SYSINT;
begin
 Result := cbGetReturnMode;
end;
procedure TTAMC100F.Set_ReturnMode(Value: SYSINT);
begin
  cbSetReturnMode(Value);
end;

// внести нал в кассу
procedure TTAMC100F.BringSum(Sum: Double);
begin
  dll_BringSum(Sum);
end;
                      
// изъ€ть нал из кассы
procedure TTAMC100F.RemoveSum(Sum: Double);
begin
  dll_RemoveSum(Sum);
end;
                       
// код последней ошибки
function TTAMC100F.GetErrorCode: SYSINT;
begin
  Result := dll_GetErrorCode;
end;
                          
// сумма наличности в чеке
function TTAMC100F.GetCashSum: Double;
begin
  dll_GetCashSum(Result);
end;
 
initialization
  TAutoObjectFactory.Create(ComServer, TTAMC100F, Class_TAMC100F,
    ciMultiInstance, tmApartment);
end.
