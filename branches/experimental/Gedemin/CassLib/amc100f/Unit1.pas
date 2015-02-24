unit Unit1;

interface

uses
  Windows, ActiveX, Classes, ComObj, gsDRV_TLB, StdVcl;

type
  TTAMC100F = class(TTypedComObject, ITAMC100F)
  protected
    function ConnectECR(Port, NetNum: SYSINT): HResult; stdcall;
    procedure DisconnectECR; stdcall;
    function AddSale(const Name: WideString; Price, Quantity: Double;
      Section: SYSINT): HResult; stdcall;
    procedure PrintCheck; stdcall;
    procedure ClearSales; stdcall;
//    function GetDiscountMode: Integer; stdcall; external 'chon100bel.dll';
//        function GetErrorCode: Integer; stdcall; external 'chon100bel.dll';
//    function GetErrorMsg: PChar; stdcall; external 'chon100bel.dll';
//    function Feed(LineCount: Integer): Integer; stdcall; external 'chon100bel.dll';
//    function GetBroughtSum(var Sum: Double): Integer; stdcall; external 'chon100bel.dll';
//    function GetCashSum(var Sum: Double): Integer; stdcall; external 'chon100bel.dll';
//    function GetKKMNum(var KKMNum: Integer): Integer; stdcall; external 'chon100bel.dll';
//    function GetKLNum(var KLNum: Integer): Integer; stdcall; external 'chon100bel.dll';
//    function GetRemovedQty(var Qty: Integer): Integer; stdcall; external 'chon100bel.dll';
//    function GetRemovedSum(var Sum: Double): Integer; stdcall; external 'chon100bel.dll';
//    function GetReturnedSum (var Sum: Double): Integer; stdcall; external 'chon100bel.dll';
//    function GetReturnedSumOnSection (Section: Integer; var Sum: Double): Integer; stdcall; external 'chon100bel.dll';
//    function GetEJRecNum(var RecNum: Integer): Integer; stdcall; external 'chon100bel.dll';
//    function GetSalesSumOnSection (Section: Integer; var Sum: Double): Integer; stdcall; external 'chon100bel.dll';
//    function GetKKMVers: Integer; stdcall; external 'chon100bel.dll';
//    function Lock: Integer; stdcall; external 'chon100bel.dll';
//    procedure SetSupplierCode(Code: PChar); stdcall; external 'chon100bel.dll';
//    function UnLock: Integer; stdcall; external 'chon100bel.dll';
//    function WaitingStatus: Integer; stdcall; external 'chon100bel.dll';
//    procedure SetProgressEvent(Ptr: TAppProgress); stdcall; external 'chon100bel.dll';
//    function BringSum(Sum: Double): Integer; stdcall; external 'chon100bel.dll';
//    function RemoveSum(Sum: Double): Integer; stdcall; external 'chon100bel.dll';
//    function PrintCheck: Integer; stdcall; external 'chon100bel.dll';
//    function CheckRegKass: Integer; stdcall; external 'chon100bel.dll';
//    function KKMPrintStr(Str: PChar): Integer; stdcall; external 'chon100bel.dll';
//    function GetSaleCountInCBKKM(var SaleCount: Integer): Integer; stdcall; external 'chon100bel.dll';
  end;

  function ConnectKKM(Port, NetNum: Integer): Integer; stdcall; external 'chon100bel.dll';
  procedure DisconnectKKM; stdcall; external 'chon100bel.dll';
  function cbAddSale(Name: PChar; Price, Qty: Double; Section: Integer): Integer; stdcall; external 'chon100bel.dll';
  function dll_PrintCheck: Integer; stdcall; external 'chon100bel.dll' name 'PrintCheck';
  procedure cbClearSales; stdcall; external 'chon100bel.dll';

implementation

uses ComServ;

function TTAMC100F.ConnectECR(Port, NetNum: SYSINT): HResult;
begin
  Result := ConnectKKM(Port, NetNum);
end;

procedure TTAMC100F.DisconnectECR;
begin
  DisconnectKKM;
end;

function TTAMC100F.AddSale(const Name: WideString; Price, Quantity: Double;
  Section: SYSINT): HResult;
begin
  Result := cbAddSale(PChar(Name), Price, Quantity, Section);
end;

procedure TTAMC100F.PrintCheck;
begin
  dll_PrintCheck;
end;

procedure TTAMC100F.ClearSales;
begin
  cbClearSales;  
end;

initialization
  TTypedComObjectFactory.Create(ComServer, TTAMC100F, Class_TAMC100F,
    ciMultiInstance, tmApartment);
end.
