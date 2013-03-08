unit unit_MegaWDriver;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows, SysUtils, ActiveX, Classes, ComObj, MegaWDriverCOM_TLB, StdVcl, ShellApi, Variants, Dialogs;

type
  TCurrArray = array[0..4] of ^Currency;
  PCurrArray = ^TCurrArray;
  TMegaWDriver = class(TAutoObject, IMegaWDriver)
  protected
    function FrWConnect: SYSINT; safecall;
    function FrWLogIn(const pszPw: WideString; Mode: SYSINT): SYSINT; safecall;
    function FrWLogOut: SYSINT; safecall;
    function FrWCutReceipt: SYSINT; safecall;
    function FrWFeed(Count: SYSINT): SYSINT; safecall;
    function FrWOpenDrawer: SYSINT; safecall;
    function FrWPrintData(const strDate: WideString): SYSINT; safecall;
    function FrWCreateDoc(DocType: Shortint; Slip: SYSINT; fLinePrn: WordBool;
      const pathOne, pathTwo: WideString): SYSINT; safecall;
    function FrWCreateDocCopy(DocType: Shortint; const serialKSA: WideString;
      DateTime: TDateTime; lRcptNo: Integer; Slip: SYSINT;
      fLinePrn: WordBool; const pathOne, pathTwo: WideString): SYSINT;
      safecall;
    function FrWAddItem(Dept: Shortint; Quantity, Price: Currency; const Code,
      pszName, pszComment: WideString; out Cost,
      iStrCheck: OleVariant): SYSINT; safecall;
    function FrWAdjustment(fPercent: Byte; Summ: Currency; DocFlag: Byte;
      var RealSumm, TotalSumm: OleVariant): SYSINT; safecall;
    function FrWTax(IdTax: Byte; fInclude: WordBool; DocFlag: Byte; var Summ,
      TotalSumm: OleVariant): SYSINT; safecall;
    function FrWCancelItem(ItemNo: SYSINT; pSumm: Currency): SYSINT; safecall;
    function FrWTotal(var Summ: OleVariant): SYSINT; safecall;
    function FrWPrintAdvItem(const strType, strValue: WideString): SYSINT;
      safecall;
    function FrWPayment(var Summ: OleVariant): SYSINT; safecall;
    function FrWPrintReport(TypeRep: SYSINT): SYSINT; safecall;
    function FrWCancelReceipt: SYSINT; safecall;
{    function FrWGetErrorDescription(Code, Len: SYSINT;
      out Description: WideString): SYSINT; safecall; }

{
    function FrWPrintAdvItem(strType, strValue: string): integer;
    function FrWCancelReceipt: integer;
    function FrWPayment(var summ: TCurrArray; var CardNo: string; var Curr: integer; iType:Integer=0): integer;  }
  private
     LibHandle: THandle; // MegaVDriver.dll
  public
//    function InitObject: boolean;
 //   procedure CloseObject;
    procedure Initialize; override;
    destructor Destroy; override;
  end;

implementation

uses ComServ;
//***************
function InitObject(C: TMegaWDriver): boolean;
begin
  C.LibHandle := LoadLibrary('MegaWDriver.dll');
  Result := (C.LibHandle > 0);
end;
//***************
procedure CloseObject(C: TMegaWDriver);
begin
  if C.LibHandle > 0 then
    FreeLibrary(C.LibHandle);
end;

procedure TMegaWDriver.Initialize;
begin
  inherited;
  InitObject(Self);
end;

destructor TMegaWDriver.Destroy;
begin
  CloseObject(Self);
  inherited Destroy;
end;
//***************
{

//***************
function TMegaWDriver.FrWPrintAdvItem(strType, strValue: string): integer;
var proc: function(strType, strValue: PChar): integer;
begin
  Result := -1;
  if LibHandle > 0 then
  begin
    @proc := GetProcAddress(LibHandle, 'FrWPrintAdvItem');
    if Assigned(@proc) then
    try
      Result := proc(PChar(strType), PChar(strValue));
    except
    end;
  end;
end;
//***************
function TMegaWDriver.FrWCancelReceipt: integer;
var proc: function(): integer;
begin
  Result := -1;
  if LibHandle > 0 then
  begin
    @proc := GetProcAddress(LibHandle, 'FrWCancelReceipt');
    if Assigned(@proc) then
    try
      Result := proc;
    except
    end;
  end;
end;
//***************
function TMegaWDriver.FrWPayment(var summ: TCurrArray; var CardNo: string; var Curr: integer; iType:Integer=0): integer;
var proc: function(var summ: TCurrArray; var Curr: Integer; var iType: Integer): integer;
begin
  Result := -1;
  if LibHandle > 0 then
  begin
    @proc := GetProcAddress(LibHandle, 'FrWPayment');
    if Assigned(@proc) then
    try
      Result := proc(summ, Curr, iType);
    except
    end;
  end;
end;
//***************   }


//***************
function TMegaWDriver.FrWConnect: SYSINT;
var
  proc: function(): integer stdcall;
begin
  Result := -1000;
  if LibHandle > 0 then
  begin
    @proc := GetProcAddress(LibHandle, 'FrWConnect');
    if Assigned(@proc) then
    try
      Result := proc;
    except
    end;
  end;
end;

//***************
function TMegaWDriver.FrWLogIn(const pszPw: WideString;
  Mode: SYSINT): SYSINT;
var
  proc: function(Code: LongWord; pszPw: PChar; Mode: integer; pszName: PChar): integer stdcall;
  pszPwTemp: array[0..255] of Char;
begin
  Result := -1000;
  if LibHandle > 0 then
  begin
    @proc := GetProcAddress(LibHandle, 'FrWLogIn');
    if Assigned(@proc) then
    begin
      if pszPw <> '' then
        StrPCopy(pszPwTemp, pszPw)
      else
        pszPwTemp[0] := #0;
      try
         Result := proc(1, pszPwTemp, Mode, 'Kassir');
      except
      end;
    end;
  end;
end;

//***************
function TMegaWDriver.FrWLogOut: SYSINT;
var proc: function(): integer stdcall;
begin
  Result := -1000;
  if LibHandle > 0 then
  begin
    @proc := GetProcAddress(LibHandle, 'FrWLogOut');
    if Assigned(@proc) then
    try
      Result := proc;
    except
    end;
  end;
end;
//***************
function TMegaWDriver.FrWCutReceipt: SYSINT;
var proc: function(): integer stdcall;
begin
  Result := -1000;
  if LibHandle > 0 then
  begin
    @proc := GetProcAddress(LibHandle, 'FrWCutReceipt');
    if Assigned(@proc) then
    try
      Result := proc;
    except
    end;
  end;
end;
//***************

//!!!!!!!!!!!!!!!!!!!!!!!!
function TMegaWDriver.FrWFeed(Count: SYSINT): SYSINT;
var proc: function(Count: integer): integer stdcall;
begin
  Result := -1;
  if LibHandle > 0 then
  begin
    @proc := GetProcAddress(LibHandle, 'FrWFeed');
    if Assigned(@proc) then
    try
      Result := proc(integer(Count));
    except
    end;
  end;
end;
//!!!!!!!!!!!!!!!!!!!!!!!!
//***************
function TMegaWDriver.FrWOpenDrawer: SYSINT;
var proc: function(): integer stdcall;
begin
  Result := -1;
  if LibHandle > 0 then
  begin
    @proc := GetProcAddress(LibHandle, 'FrWOpenDrawer');
    if Assigned(@proc) then
    try
      Result := proc;
    except
    end;
  end;
end;
//***************

function TMegaWDriver.FrWPrintData(const strDate: WideString): SYSINT;
var proc: function(strData: PChar;  Station: integer=0; strFName: PChar=nil): integer stdcall;
    strDataTemp: array[0..255] of char;
begin
  Result := -1000;
  if LibHandle > 0 then
  begin
    @proc := GetProcAddress(LibHandle, 'FrWPrintData');
    if Assigned(@proc) then
    begin
      if strDate <> '' then
        StrPCopy(strDataTemp, strDate)
      else
        strDataTemp := #0;
      try
        Result := proc(strDataTemp, 0, '');
      except
      end;
    end
  end;
end;
//***************

{function TMegaWDriver.FrWGetErrorDescription(Code, Len: SYSINT;
  out Description: WideString): SYSINT;
var proc: function(Code: integer; Description: PChar; Len: integer): integer;
    DescriptionTemp: array[0..255] of Char;
begin
  Result := -1;
  if LibHandle > 0 then
  begin
    @proc := GetProcAddress(LibHandle, 'FrWGetErrorDescription');
    if Assigned(@proc) then
    begin
//      GetMem(DescriptionTemp, SizeOf(byte) * Len);
      try
        Result := proc(Code, DescriptionTemp, Len);
//        Description := Copy(DescriptionTemp, 1, Len);
      finally
//        FreeMem(DescriptionTemp);
      end;
    end;
  end;
end;  }

function TMegaWDriver.FrWCreateDoc(DocType: Shortint; Slip: SYSINT;
  fLinePrn: WordBool; const pathOne, pathTwo: WideString): SYSINT;
var proc: function(DocType: byte; Slip: integer; fLinePrn: boolean; pathOne: PChar; pathTwo: PChar): integer stdcall;
    pathOneTemp, pathTwoTemp: array[0..255] of Char;
begin

  Result := -1000;
  if LibHandle > 0 then
  begin
    @proc := GetProcAddress(LibHandle, 'FrWCreateDoc');
    if Assigned(@proc) then
    begin
      try
        if pathOne <> '' then
          StrPCopy(pathOneTemp, pathOne)
        else
          pathOneTemp[0] := #0;
        if pathTwo <> '' then
          StrPCopy(pathTwoTemp, pathTwo)
        else
          pathTwoTemp[0] := #0;

        Result := proc(DocType, Slip, fLinePrn, pathOneTemp, pathTwoTemp);
      except
      end;
    end;
  end;
end;

function TMegaWDriver.FrWCreateDocCopy(DocType: Shortint;
  const serialKSA: WideString; DateTime: TDateTime; lRcptNo: Integer;
  Slip: SYSINT; fLinePrn: WordBool; const pathOne,
  pathTwo: WideString): SYSINT;
var proc: function(DocType: byte; serialKSA: PChar=nil; DateTime: PDateTime=nil;
                   lRcptNo: LongInt=0; strKasir: PChar=nil; Slip: integer=0;
                   fLinePrn: boolean=true; pathOne: PChar=nil; pathTwo: PChar=nil): integer stdcall;
                   
    serialKSATemp, pathOneTemp, pathTwoTemp: array[0..255] of Char;
begin
  Result := -1000;
  if LibHandle > 0 then
  begin
    @proc := GetProcAddress(LibHandle, 'FrWCreateDocCopy');
    if Assigned(@proc) then
    begin
        if serialKSA <> '' then
          StrPCopy(serialKSATemp, serialKSA)
        else
          serialKSATemp[0] := #0;
        if pathOne <> '' then
          StrPCopy(pathOneTemp, pathOne)
        else
          pathOneTemp[0] := #0;
        if pathTwo <> '' then
          StrPCopy(pathTwoTemp, pathTwo)
        else
          pathTwoTemp[0] := #0;
      {GetMem(serialKSATemp, SizeOf(byte) * Length(serialKSA));
      GetMem(strKasirTemp, SizeOf(byte) * Length(strKasir));
      GetMem(pathOneTemp, SizeOf(byte) * Length(pathOne));
      GetMem(pathTwoTemp, SizeOf(byte) * Length(pathTwo));  }
      try
        Result := proc(DocType, serialKSATemp, @DateTime, lRcptNo,
                     'Kassir', Slip, fLinePrn, pathOneTemp, pathTwoTemp);
      finally
        {FreeMem(serialKSATemp);
        FreeMem(strKasirTemp);
        FreeMem(pathOneTemp);
        FreeMem(pathTwoTemp);}
      end;
    end;
  end;
end;
//***************

function TMegaWDriver.FrWAddItem(Dept: Shortint; Quantity, Price: Currency;
  const Code, pszName, pszComment: WideString; out Cost,
  iStrCheck: OleVariant): SYSINT;
var proc: function(Dept: byte; Quantity, Price: CURRENCY; Code, pszName,
                   pszComment: PChar; Cost: PCURRENCY; iStrCheck: PWord): integer stdcall;
    pszNameTemp, pszCommentTemp, CodeTemp: array[0..255] of Char;
    CostTemp: Currency;

begin
  Result := -1000;
  if LibHandle > 0 then
  begin
    @proc := GetProcAddress(LibHandle, 'FrWAddItem');
    if Assigned(@proc) then
    begin
      if pszName <> '' then
          StrPCopy(pszNameTemp, pszName)
      else
          pszNameTemp[0] := #0;
      if pszComment <> '' then
          StrPCopy(pszCommentTemp, pszComment)
      else
          pszCommentTemp[0] := #0;
      if Code <> '' then
          StrPCopy(CodeTemp, Code)
      else
          CodeTemp[0] := #0;
      CostTemp := Quantity * Price;
      iStrCheck := 0;
      try
        Result := proc(Dept, Quantity, Price, CodeTemp, pszNameTemp, pszCommentTemp, @CostTemp, @iStrCheck);
        Cost := CostTemp;
      except
      end;
    end;
  end;
end;
//***************

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
function TMegaWDriver.FrWAdjustment(fPercent: Byte; Summ: Currency;
  DocFlag: Byte; var RealSumm, TotalSumm: OleVariant): SYSINT;
var proc: function(fPercent: byte; Summ: PCurrency; DocFlag: byte; RealSumm, TotalSumm: PCurrency): integer stdcall;
begin
  Result := -1000;
  if LibHandle > 0 then
  begin
    @proc := GetProcAddress(LibHandle, 'FrWAdjustment');
    if Assigned(@proc) then
    try
      Result := proc(fPercent, @Summ, DocFlag, nil, nil);
    except
    end;
  end;
end;
//***************


function TMegaWDriver.FrWTax(IdTax: Byte; fInclude: WordBool;
  DocFlag: Byte; var Summ, TotalSumm: OleVariant): SYSINT;
var proc: function(IdTax: byte; fInclude: boolean; DocFlag: byte;
                   Summ, TotalSumm: PCurrency): integer stdcall;
    SummTemp, TotalSummTemp: PInt64;
begin
  Result := -1;
  if LibHandle > 0 then
  begin
    @proc := GetProcAddress(LibHandle, 'FrWTax');
    if Assigned(@proc) then
    try
      Result := proc(IdTax, fInclude, DocFlag, @Summ, @TotalSumm);
    except
    end;
  end;
end;


//***************
function TMegaWDriver.FrWCancelItem(ItemNo: SYSINT;
  pSumm: Currency): SYSINT;
var proc: function(ItemNo: integer; pSumm: PCurrency): integer stdcall;
begin
  Result := -1;
  if LibHandle > 0 then
  begin
    @proc := GetProcAddress(LibHandle, 'FrWCancelItem');
    if Assigned(@proc) then
    try
      Result := proc(ItemNo, @pSumm);
    except
    end;
  end;
end;

function TMegaWDriver.FrWTotal(var Summ: OleVariant): SYSINT;
var proc: function(Summ: PCURRENCY): integer stdcall;
begin
  Result := -1000;
  if LibHandle > 0 then
  begin
    @proc := GetProcAddress(LibHandle, 'FrWTotal');
    if Assigned(@proc) then
    try
      Result := proc(@Summ);
    except
    end;
  end;
end;
//***************

function TMegaWDriver.FrWPrintAdvItem(const strType,
  strValue: WideString): SYSINT;
var proc: function(strType, strValue: PChar): integer stdcall;
    strTypeTemp, strValueTemp: PChar;
begin
  Result := -1;
  if LibHandle > 0 then
  begin
    @proc := GetProcAddress(LibHandle, 'FrWPrintAdvItem');
    if Assigned(@proc) then
    begin
      GetMem(strTypeTemp, SizeOf(byte) * Length(strType));
      GetMem(strValueTemp, SizeOf(byte) * Length(strValue));
      try
        Result := proc(strTypeTemp, strValueTemp);
      except
      end;
      FreeMem(strTypeTemp);
      FreeMem(strValueTemp);
    end
  end;
end;
//***************

function TMegaWDriver.FrWPayment(var Summ: OleVariant): SYSINT;
var
  proc: function(Summ: TCurrArray; Types: Integer; CardNo: PChar; Curr: Integer): integer stdcall;
  Summs: TCurrArray;
  SummsTemp: array[0..4] of Currency;
  i: integer;
begin

  Result := -1000;
  if LibHandle > 0 then
  begin
    @proc := GetProcAddress(LibHandle, 'FrWPayment');
    if Assigned(@proc) then
    begin
      try
        for i := VarArrayLowBound(Summ, 1) to VarArrayHighBound(Summ, 1) do
        begin
          SummsTemp[i] := Summ[i] {* 10000};
          Summs[i] := @SummsTemp[i];

        end;
        Result := proc(Summs, 0, 'CASH', 0);
      except
      end;
    end
  end;

end;

function TMegaWDriver.FrWPrintReport(TypeRep: SYSINT): SYSINT;
var
  proc: function(TypeRep: Integer; Beg: pvariant=nil; End_: pvariant=nil): integer stdcall;
begin
  Result := -1000;
  if LibHandle > 0 then
  begin
    @proc := GetProcAddress(LibHandle, 'FrWPrintReport');
    if Assigned(@proc) then
    try
      Result := proc(TypeRep, nil, nil);
    except
    end;
  end;
end;

function TMegaWDriver.FrWCancelReceipt: SYSINT;
var proc: function(): integer;
begin
  Result := -1000;
  if LibHandle > 0 then
  begin
    @proc := GetProcAddress(LibHandle, 'FrWCancelReceipt');
    if Assigned(@proc) then
    try
      Result := proc;
    except
    end;
  end;
end;
//***************

initialization
  TAutoObjectFactory.Create(ComServer, TMegaWDriver, Class_MegaWDriver,
    ciMultiInstance, tmApartment);
end.
