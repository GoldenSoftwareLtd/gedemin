unit SCARDSSPLib_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// PASTLWTR : 1.2
// File generated on 15.01.2004 19:27:01 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\WIN2000\System32\scardssp.dll (1)
// LIBID: {82C38704-19F1-11D3-A11F-00C04F79F800}
// LCID: 0
// Helpfile: 
// HelpString: scardssp 1.0 Type Library
// DepndLst: 
//   (1) v2.0 stdole, (C:\WIN2000\System32\stdole2.tlb)
// Parent TypeLibrary:
//   (0) v1.0 IBReplicator, (D:\PROJECTS\delphi\IBReplicator\IBReplicator.tlb)
// Errors:
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
//   Hint: Symbol 'type' renamed to 'type_'
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  SCARDSSPLibMajorVersion = 1;
  SCARDSSPLibMinorVersion = 0;

  LIBID_SCARDSSPLib: TGUID = '{82C38704-19F1-11D3-A11F-00C04F79F800}';

  IID_IByteBuffer: TGUID = '{E126F8FE-A7AF-11D0-B88A-00C04FD424B9}';
  CLASS_CByteBuffer: TGUID = '{E126F8FF-A7AF-11D0-B88A-00C04FD424B9}';
  IID_ISequentialStream: TGUID = '{0C733A30-2A1C-11CE-ADE5-00AA0044773D}';
  IID_IStream: TGUID = '{0000000C-0000-0000-C000-000000000046}';
  IID_ISCardTypeConv: TGUID = '{53B6AA63-3F56-11D0-916B-00AA00C18068}';
  CLASS_CSCardTypeConv: TGUID = '{53B6AA67-3F56-11D0-916B-00AA00C18068}';
  IID_IRecordInfo: TGUID = '{0000002F-0000-0000-C000-000000000046}';
  IID_ITypeInfo: TGUID = '{00020401-0000-0000-C000-000000000046}';
  IID_ITypeComp: TGUID = '{00020403-0000-0000-C000-000000000046}';
  IID_ITypeLib: TGUID = '{00020402-0000-0000-C000-000000000046}';
  IID_ISCardCmd: TGUID = '{D5778AE3-43DE-11D0-9171-00AA00C18068}';
  CLASS_CSCardCmd: TGUID = '{D5778AE7-43DE-11D0-9171-00AA00C18068}';
  IID_ISCardISO7816: TGUID = '{53B6AA68-3F56-11D0-916B-00AA00C18068}';
  CLASS_CSCardISO7816: TGUID = '{53B6AA6C-3F56-11D0-916B-00AA00C18068}';
  IID_ISCard: TGUID = '{1461AAC3-6810-11D0-918F-00AA00C18068}';
  CLASS_CSCard: TGUID = '{1461AAC7-6810-11D0-918F-00AA00C18068}';
  IID_ISCardDatabase: TGUID = '{1461AAC8-6810-11D0-918F-00AA00C18068}';
  CLASS_CSCardDatabase: TGUID = '{1461AACC-6810-11D0-918F-00AA00C18068}';
  IID_ISCardLocate: TGUID = '{1461AACD-6810-11D0-918F-00AA00C18068}';
  CLASS_CSCardLocate: TGUID = '{1461AAD1-6810-11D0-918F-00AA00C18068}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                    
// *********************************************************************//
// Constants for enum tagTYPEKIND
type
  tagTYPEKIND = TOleEnum;
const
  TKIND_ENUM = $00000000;
  TKIND_RECORD = $00000001;
  TKIND_MODULE = $00000002;
  TKIND_INTERFACE = $00000003;
  TKIND_DISPATCH = $00000004;
  TKIND_COCLASS = $00000005;
  TKIND_ALIAS = $00000006;
  TKIND_UNION = $00000007;
  TKIND_MAX = $00000008;

// Constants for enum tagDESCKIND
type
  tagDESCKIND = TOleEnum;
const
  DESCKIND_NONE = $00000000;
  DESCKIND_FUNCDESC = $00000001;
  DESCKIND_VARDESC = $00000002;
  DESCKIND_TYPECOMP = $00000003;
  DESCKIND_IMPLICITAPPOBJ = $00000004;
  DESCKIND_MAX = $00000005;

// Constants for enum tagFUNCKIND
type
  tagFUNCKIND = TOleEnum;
const
  FUNC_VIRTUAL = $00000000;
  FUNC_PUREVIRTUAL = $00000001;
  FUNC_NONVIRTUAL = $00000002;
  FUNC_STATIC = $00000003;
  FUNC_DISPATCH = $00000004;

// Constants for enum tagINVOKEKIND
type
  tagINVOKEKIND = TOleEnum;
const
  INVOKE_FUNC = $00000001;
  INVOKE_PROPERTYGET = $00000002;
  INVOKE_PROPERTYPUT = $00000004;
  INVOKE_PROPERTYPUTREF = $00000008;

// Constants for enum tagCALLCONV
type
  tagCALLCONV = TOleEnum;
const
  CC_FASTCALL = $00000000;
  CC_CDECL = $00000001;
  CC_MSCPASCAL = $00000002;
  CC_PASCAL = $00000002;
  CC_MACPASCAL = $00000003;
  CC_STDCALL = $00000004;
  CC_FPFASTCALL = $00000005;
  CC_SYSCALL = $00000006;
  CC_MPWCDECL = $00000007;
  CC_MPWPASCAL = $00000008;
  CC_MAX = $00000009;

// Constants for enum tagVARKIND
type
  tagVARKIND = TOleEnum;
const
  VAR_PERINSTANCE = $00000000;
  VAR_STATIC = $00000001;
  VAR_CONST = $00000002;
  VAR_DISPATCH = $00000003;

// Constants for enum tagSYSKIND
type
  tagSYSKIND = TOleEnum;
const
  SYS_WIN16 = $00000000;
  SYS_WIN32 = $00000001;
  SYS_MAC = $00000002;
  SYS_WIN64 = $00000001;

// Constants for enum tagISO_APDU_TYPE
type
  tagISO_APDU_TYPE = TOleEnum;
const
  ISO_CASE_1 = $00000001;
  ISO_CASE_2 = $00000002;
  ISO_CASE_3 = $00000003;
  ISO_CASE_4 = $00000004;

// Constants for enum tagSCARD_PROTOCOLS
type
  tagSCARD_PROTOCOLS = TOleEnum;
const
  T0 = $00000001;
  T1 = $00000002;
  RAW = $000000FF;

// Constants for enum tagSCARD_STATES
type
  tagSCARD_STATES = TOleEnum;
const
  ABSENT = $00000001;
  PRESENT = $00000002;
  SWALLOWED = $00000003;
  POWERED = $00000004;
  NEGOTIABLEMODE = $00000005;
  SPECIFICMODE = $00000006;

// Constants for enum tagSCARD_SHARE_MODES
type
  tagSCARD_SHARE_MODES = TOleEnum;
const
  EXCLUSIVE = $00000001;
  SHARED = $00000002;

// Constants for enum tagSCARD_DISPOSITIONS
type
  tagSCARD_DISPOSITIONS = TOleEnum;
const
  LEAVE = $00000000;
  RESET = $00000001;
  UNPOWER = $00000002;
  EJECT = $00000003;

type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IByteBuffer = interface;
  ISequentialStream = interface;
  IStream = interface;
  ISCardTypeConv = interface;
  IRecordInfo = interface;
  ITypeInfo = interface;
  ITypeComp = interface;
  ITypeLib = interface;
  ISCardCmd = interface;
  ISCardISO7816 = interface;
  ISCard = interface;
  ISCardDatabase = interface;
  ISCardLocate = interface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  CByteBuffer = IByteBuffer;
  CSCardTypeConv = ISCardTypeConv;
  CSCardCmd = ISCardCmd;
  CSCardISO7816 = ISCardISO7816;
  CSCard = ISCard;
  CSCardDatabase = ISCardDatabase;
  CSCardLocate = ISCardLocate;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  LPSTATSTRUCT = ^STATSTRUCT; 
  LPBYTE = ^BYTE; 
  LPBYTEARRAY = ^BYTEARRAY; 
  wireHGLOBAL = ^_userHGLOBAL; 
  wirePSAFEARRAY = ^PUserType1; 
  PUserType2 = ^_FLAGGED_WORD_BLOB; {*}
  PUserType3 = ^_wireVARIANT; {*}
  PUserType11 = ^_wireBRECORD; {*}
  PUserType1 = ^_wireSAFEARRAY; {*}
  PPUserType1 = ^PUserType1; {*}
  PUserType8 = ^tagTYPEDESC; {*}
  PUserType9 = ^tagARRAYDESC; {*}
  PByte1 = ^BYTE; {*}
  PByte2 = ^Byte; {*}
  POleVariant1 = ^OleVariant; {*}
  PUserType4 = ^tagTYPEATTR; {*}
  PUserType5 = ^tagFUNCDESC; {*}
  PUserType6 = ^tagVARDESC; {*}
  PUserType7 = ^TGUID; {*}
  PUserType10 = ^tagTLIBATTR; {*}
  PInteger1 = ^Integer; {*}
  PUserType12 = ^SCARDINFO; {*}

  _LARGE_INTEGER = packed record
    QuadPart: Int64;
  end;

  _ULARGE_INTEGER = packed record
    QuadPart: Largeuint;
  end;

  _FILETIME = packed record
    dwLowDateTime: LongWord;
    dwHighDateTime: LongWord;
  end;

  tagSTATSTG = packed record
    pwcsName: PWideChar;
    type_: LongWord;
    cbSize: _ULARGE_INTEGER;
    mtime: _FILETIME;
    ctime: _FILETIME;
    atime: _FILETIME;
    grfMode: LongWord;
    grfLocksSupported: LongWord;
    clsid: TGUID;
    grfStateBits: LongWord;
    reserved: LongWord;
  end;

  BYTE = Byte; 

  tagSTATSTRUCT = packed record
    type_: Integer;
    cbSize: Integer;
    grfMode: Integer;
    grfLocksSupported: Integer;
    grfStateBits: Integer;
  end;

  STATSTRUCT = tagSTATSTRUCT; 

  tagBYTEARRAY = packed record
    hMem: wireHGLOBAL;
    dwSize: LongWord;
    pbyData: ^Byte;
  end;

  BYTEARRAY = tagBYTEARRAY; 

  _FLAGGED_BYTE_BLOB = packed record
    fFlags: LongWord;
    clSize: LongWord;
    abData: ^Byte;
  end;

  __MIDL_IWinTypes_0003 = record
    case Integer of
      0: (hInproc: Integer);
      1: (hRemote: ^_FLAGGED_BYTE_BLOB);
      2: (hInproc64: Int64);
  end;

  _userHGLOBAL = packed record
    fContext: Integer;
    u: __MIDL_IWinTypes_0003;
  end;


  _wireSAFEARR_BSTR = packed record
    Size: LongWord;
    aBstr: ^PUserType2;
  end;

  _wireSAFEARR_UNKNOWN = packed record
    Size: LongWord;
    apUnknown: ^IUnknown;
  end;

  _wireSAFEARR_DISPATCH = packed record
    Size: LongWord;
    apDispatch: ^IDispatch;
  end;

  _FLAGGED_WORD_BLOB = packed record
    fFlags: LongWord;
    clSize: LongWord;
    asData: ^Word;
  end;


  _wireSAFEARR_VARIANT = packed record
    Size: LongWord;
    aVariant: ^PUserType3;
  end;


  _wireBRECORD = packed record
    fFlags: LongWord;
    clSize: LongWord;
    pRecInfo: IRecordInfo;
    pRecord: ^Byte;
  end;


  __MIDL_IOleAutomationTypes_0005 = record
    case Integer of
      0: (lptdesc: PUserType8);
      1: (lpadesc: PUserType9);
      2: (hreftype: LongWord);
  end;

  tagTYPEDESC = packed record
    __MIDL_0008: __MIDL_IOleAutomationTypes_0005;
    vt: Word;
  end;

  tagSAFEARRAYBOUND = packed record
    cElements: LongWord;
    lLbound: Integer;
  end;

  ULONG_PTR = LongWord; 

  tagIDLDESC = packed record
    dwReserved: ULONG_PTR;
    wIDLFlags: Word;
  end;

  DWORD = LongWord; 

  tagPARAMDESCEX = packed record
    cBytes: LongWord;
    varDefaultValue: OleVariant;
  end;

  tagPARAMDESC = packed record
    pparamdescex: ^tagPARAMDESCEX;
    wParamFlags: Word;
  end;

  tagELEMDESC = packed record
    tdesc: tagTYPEDESC;
    paramdesc: tagPARAMDESC;
  end;

  tagFUNCDESC = packed record
    memid: Integer;
    lprgscode: ^SCODE;
    lprgelemdescParam: ^tagELEMDESC;
    funckind: tagFUNCKIND;
    invkind: tagINVOKEKIND;
    callconv: tagCALLCONV;
    cParams: Smallint;
    cParamsOpt: Smallint;
    oVft: Smallint;
    cScodes: Smallint;
    elemdescFunc: tagELEMDESC;
    wFuncFlags: Word;
  end;

  __MIDL_IOleAutomationTypes_0006 = record
    case Integer of
      0: (oInst: LongWord);
      1: (lpvarValue: ^OleVariant);
  end;

  tagVARDESC = packed record
    memid: Integer;
    lpstrSchema: PWideChar;
    __MIDL_0009: __MIDL_IOleAutomationTypes_0006;
    elemdescVar: tagELEMDESC;
    wVarFlags: Word;
    varkind: tagVARKIND;
  end;

  tagTLIBATTR = packed record
    guid: TGUID;
    lcid: LongWord;
    syskind: tagSYSKIND;
    wMajorVerNum: Word;
    wMinorVerNum: Word;
    wLibFlags: Word;
  end;

  _wireSAFEARR_BRECORD = packed record
    Size: LongWord;
    aRecord: ^PUserType11;
  end;

  _wireSAFEARR_HAVEIID = packed record
    Size: LongWord;
    apUnknown: ^IUnknown;
    iid: TGUID;
  end;

  _BYTE_SIZEDARR = packed record
    clSize: LongWord;
    pData: ^Byte;
  end;

  _SHORT_SIZEDARR = packed record
    clSize: LongWord;
    pData: ^Word;
  end;

  _LONG_SIZEDARR = packed record
    clSize: LongWord;
    pData: ^LongWord;
  end;

  _HYPER_SIZEDARR = packed record
    clSize: LongWord;
    pData: ^Int64;
  end;

  ISO_APDU_TYPE = tagISO_APDU_TYPE; 
  HSCARD = ULONG_PTR; 
  HSCARDCONTEXT = ULONG_PTR; 
  SCARD_PROTOCOLS = tagSCARD_PROTOCOLS; 
  SCARD_STATES = tagSCARD_STATES; 
  SCARD_SHARE_MODES = tagSCARD_SHARE_MODES; 
  SCARD_DISPOSITIONS = tagSCARD_DISPOSITIONS; 

  tagSCARDINFO = packed record
    hCard: LongWord;
    hContext: LongWord;
    ActiveProtocol: tagSCARD_PROTOCOLS;
    ShareMode: tagSCARD_SHARE_MODES;
    hwndOwner: Integer;
    lpfnConnectProc: Integer;
    lpfnCheckProc: Integer;
    lpfnDisconnectProc: Integer;
  end;

  SCARDINFO = tagSCARDINFO; 

  __MIDL_IOleAutomationTypes_0004 = record
    case Integer of
      0: (lVal: Integer);
      1: (bVal: Byte);
      2: (iVal: Smallint);
      3: (fltVal: Single);
      4: (dblVal: Double);
      5: (boolVal: WordBool);
      6: (scode: SCODE);
      7: (cyVal: Currency);
      8: (date: TDateTime);
      9: (bstrVal: ^_FLAGGED_WORD_BLOB);
      10: (punkVal: {!!IUnknown}Pointer);
      11: (pdispVal: {!!IDispatch}Pointer);
      12: (parray: ^PUserType1);
      13: (brecVal: ^_wireBRECORD);
      14: (pbVal: ^Byte);
      15: (piVal: ^Smallint);
      16: (plVal: ^Integer);
      17: (pfltVal: ^Single);
      18: (pdblVal: ^Double);
      19: (pboolVal: ^WordBool);
      20: (pscode: ^SCODE);
      21: (pcyVal: ^Currency);
      22: (pdate: ^TDateTime);
      23: (pbstrVal: ^PUserType2);
      24: (ppunkVal: {!!^IUnknown}Pointer);
      25: (ppdispVal: {!!^IDispatch}Pointer);
      26: (ppArray: ^PPUserType1);
      27: (pvarVal: ^PUserType3);
      28: (cVal: Byte);
      29: (uiVal: Word);
      30: (ulVal: LongWord);
      31: (intVal: SYSINT);
      32: (uintVal: SYSUINT);
      33: (decVal: TDecimal);
      34: (pdecVal: ^TDecimal);
      35: (pcVal: ^Byte);
      36: (puiVal: ^Word);
      37: (pulVal: ^LongWord);
      38: (pintVal: ^SYSINT);
      39: (puintVal: ^SYSUINT);
  end;

  __MIDL_IOleAutomationTypes_0001 = record
    case Integer of
      0: (BstrStr: _wireSAFEARR_BSTR);
      1: (UnknownStr: _wireSAFEARR_UNKNOWN);
      2: (DispatchStr: _wireSAFEARR_DISPATCH);
      3: (VariantStr: _wireSAFEARR_VARIANT);
      4: (RecordStr: _wireSAFEARR_BRECORD);
      5: (HaveIidStr: _wireSAFEARR_HAVEIID);
      6: (ByteStr: _BYTE_SIZEDARR);
      7: (WordStr: _SHORT_SIZEDARR);
      8: (LongStr: _LONG_SIZEDARR);
      9: (HyperStr: _HYPER_SIZEDARR);
  end;

  _wireSAFEARRAY_UNION = packed record
    sfType: LongWord;
    u: __MIDL_IOleAutomationTypes_0001;
  end;

  _wireVARIANT = packed record
    clSize: LongWord;
    rpcReserved: LongWord;
    vt: Word;
    wReserved1: Word;
    wReserved2: Word;
    wReserved3: Word;
    __MIDL_0006: __MIDL_IOleAutomationTypes_0004;
  end;


  tagTYPEATTR = packed record
    guid: TGUID;
    lcid: LongWord;
    dwReserved: LongWord;
    memidConstructor: Integer;
    memidDestructor: Integer;
    lpstrSchema: PWideChar;
    cbSizeInstance: LongWord;
    typekind: tagTYPEKIND;
    cFuncs: Word;
    cVars: Word;
    cImplTypes: Word;
    cbSizeVft: Word;
    cbAlignment: Word;
    wTypeFlags: Word;
    wMajorVerNum: Word;
    wMinorVerNum: Word;
    tdescAlias: tagTYPEDESC;
    idldescType: tagIDLDESC;
  end;

  tagARRAYDESC = packed record
    tdescElem: tagTYPEDESC;
    cDims: Word;
    rgbounds: ^tagSAFEARRAYBOUND;
  end;


  _wireSAFEARRAY = packed record
    cDims: Word;
    fFeatures: Word;
    cbElements: LongWord;
    cLocks: LongWord;
    uArrayStructs: _wireSAFEARRAY_UNION;
    rgsabound: ^tagSAFEARRAYBOUND;
  end;


// *********************************************************************//
// Interface: IByteBuffer
// Flags:     (4096) Dispatchable
// GUID:      {E126F8FE-A7AF-11D0-B88A-00C04FD424B9}
// *********************************************************************//
  IByteBuffer = interface(IDispatch)
    ['{E126F8FE-A7AF-11D0-B88A-00C04FD424B9}']
    function Get_Stream(out ppStream: IStream): HResult; stdcall;
    function Set_Stream(const ppStream: IStream): HResult; stdcall;
    function Clone(var ppByteBuffer: IByteBuffer): HResult; stdcall;
    function Commit(grfCommitFlags: Integer): HResult; stdcall;
    function CopyTo(var ppByteBuffer: IByteBuffer; cb: Integer; var pcbRead: Integer; 
                    var pcbWritten: Integer): HResult; stdcall;
    function Initialize(lSize: Integer; var pData: BYTE): HResult; stdcall;
    function LockRegion(libOffset: Integer; cb: Integer; dwLockType: Integer): HResult; stdcall;
    function Read(var pByte: BYTE; cb: Integer; var pcbRead: Integer): HResult; stdcall;
    function Revert: HResult; stdcall;
    function Seek(dlibMove: Integer; dwOrigin: Integer; var plibNewPosition: Integer): HResult; stdcall;
    function SetSize(libNewSize: Integer): HResult; stdcall;
    function Stat(var pstatstg: STATSTRUCT; grfStatFlag: Integer): HResult; stdcall;
    function UnlockRegion(libOffset: Integer; cb: Integer; dwLockType: Integer): HResult; stdcall;
    function Write(var pByte: BYTE; cb: Integer; var pcbWritten: Integer): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: ISequentialStream
// Flags:     (0)
// GUID:      {0C733A30-2A1C-11CE-ADE5-00AA0044773D}
// *********************************************************************//
  ISequentialStream = interface(IUnknown)
    ['{0C733A30-2A1C-11CE-ADE5-00AA0044773D}']
    function RemoteRead(out pv: Byte; cb: LongWord; out pcbRead: LongWord): HResult; stdcall;
    function RemoteWrite(var pv: Byte; cb: LongWord; out pcbWritten: LongWord): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IStream
// Flags:     (0)
// GUID:      {0000000C-0000-0000-C000-000000000046}
// *********************************************************************//
  IStream = interface(ISequentialStream)
    ['{0000000C-0000-0000-C000-000000000046}']
    function GhostMethod_IStream_0_1: HResult; stdcall;
    function GhostMethod_IStream_4_2: HResult; stdcall;
    function GhostMethod_IStream_8_3: HResult; stdcall;
    function GhostMethod_IStream_12_4: HResult; stdcall;
    function GhostMethod_IStream_16_5: HResult; stdcall;
    function RemoteSeek(dlibMove: _LARGE_INTEGER; dwOrigin: LongWord; 
                        out plibNewPosition: _ULARGE_INTEGER): HResult; stdcall;
    function SetSize(libNewSize: _ULARGE_INTEGER): HResult; stdcall;
    function RemoteCopyTo(const pstm: IStream; cb: _ULARGE_INTEGER; out pcbRead: _ULARGE_INTEGER; 
                          out pcbWritten: _ULARGE_INTEGER): HResult; stdcall;
    function Commit(grfCommitFlags: LongWord): HResult; stdcall;
    function Revert: HResult; stdcall;
    function LockRegion(libOffset: _ULARGE_INTEGER; cb: _ULARGE_INTEGER; dwLockType: LongWord): HResult; stdcall;
    function UnlockRegion(libOffset: _ULARGE_INTEGER; cb: _ULARGE_INTEGER; dwLockType: LongWord): HResult; stdcall;
    function Stat(out pstatstg: tagSTATSTG; grfStatFlag: LongWord): HResult; stdcall;
    function Clone(out ppstm: IStream): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: ISCardTypeConv
// Flags:     (4096) Dispatchable
// GUID:      {53B6AA63-3F56-11D0-916B-00AA00C18068}
// *********************************************************************//
  ISCardTypeConv = interface(IDispatch)
    ['{53B6AA63-3F56-11D0-916B-00AA00C18068}']
    function ConvertByteArrayToByteBuffer(var pbyArray: BYTE; dwArraySize: LongWord; 
                                          out ppbyBuffer: IByteBuffer): HResult; stdcall;
    function ConvertByteBufferToByteArray(const pbyBuffer: IByteBuffer; out ppArray: LPBYTEARRAY): HResult; stdcall;
    function ConvertByteBufferToSafeArray(const pbyBuffer: IByteBuffer; 
                                          out ppbyArray: wirePSAFEARRAY): HResult; stdcall;
    function ConvertSafeArrayToByteBuffer(pbyArray: wirePSAFEARRAY; out ppbyBuff: IByteBuffer): HResult; stdcall;
    function CreateByteArray(dwAllocSize: LongWord; out ppbyArray: LPBYTE): HResult; stdcall;
    function CreateByteBuffer(dwAllocSize: LongWord; out ppbyBuff: IByteBuffer): HResult; stdcall;
    function CreateSafeArray(nAllocSize: SYSUINT; out ppArray: wirePSAFEARRAY): HResult; stdcall;
    function FreeIStreamMemoryPtr(const pStrm: IStream; var pMem: BYTE): HResult; stdcall;
    function GetAtIStreamMemory(const pStrm: IStream; out ppMem: LPBYTEARRAY): HResult; stdcall;
    function SizeOfIStream(const pStrm: IStream; out puliSize: _ULARGE_INTEGER): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IRecordInfo
// Flags:     (0)
// GUID:      {0000002F-0000-0000-C000-000000000046}
// *********************************************************************//
  IRecordInfo = interface(IUnknown)
    ['{0000002F-0000-0000-C000-000000000046}']
    function RecordInit(out pvNew: Pointer): HResult; stdcall;
    function RecordClear(var pvExisting: Pointer): HResult; stdcall;
    function RecordCopy(var pvExisting: Pointer; out pvNew: Pointer): HResult; stdcall;
    function GetGuid(out pguid: TGUID): HResult; stdcall;
    function GetName(out pbstrName: WideString): HResult; stdcall;
    function GetSize(out pcbSize: LongWord): HResult; stdcall;
    function GetTypeInfo(out ppTypeInfo: ITypeInfo): HResult; stdcall;
    function GetField(var pvData: Pointer; szFieldName: PWideChar; out pvarField: OleVariant): HResult; stdcall;
    function GetFieldNoCopy(var pvData: Pointer; szFieldName: PWideChar; out pvarField: OleVariant; 
                            out ppvDataCArray: Pointer): HResult; stdcall;
    function PutField(wFlags: LongWord; var pvData: Pointer; szFieldName: PWideChar; 
                      var pvarField: OleVariant): HResult; stdcall;
    function PutFieldNoCopy(wFlags: LongWord; var pvData: Pointer; szFieldName: PWideChar; 
                            var pvarField: OleVariant): HResult; stdcall;
    function GetFieldNames(var pcNames: LongWord; out rgBstrNames: WideString): HResult; stdcall;
    function IsMatchingType(const pRecordInfo: IRecordInfo): Integer; stdcall;
    function RecordCreate: Pointer; stdcall;
    function RecordCreateCopy(var pvSource: Pointer; out ppvDest: Pointer): HResult; stdcall;
    function RecordDestroy(var pvRecord: Pointer): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: ITypeInfo
// Flags:     (0)
// GUID:      {00020401-0000-0000-C000-000000000046}
// *********************************************************************//
  ITypeInfo = interface(IUnknown)
    ['{00020401-0000-0000-C000-000000000046}']
    function RemoteGetTypeAttr(out ppTypeAttr: PUserType4; out pDummy: DWORD): HResult; stdcall;
    function GetTypeComp(out ppTComp: ITypeComp): HResult; stdcall;
    function RemoteGetFuncDesc(index: SYSUINT; out ppFuncDesc: PUserType5; out pDummy: DWORD): HResult; stdcall;
    function RemoteGetVarDesc(index: SYSUINT; out ppVarDesc: PUserType6; out pDummy: DWORD): HResult; stdcall;
    function RemoteGetNames(memid: Integer; out rgBstrNames: WideString; cMaxNames: SYSUINT; 
                            out pcNames: SYSUINT): HResult; stdcall;
    function GetRefTypeOfImplType(index: SYSUINT; out pRefType: LongWord): HResult; stdcall;
    function GetImplTypeFlags(index: SYSUINT; out pImplTypeFlags: SYSINT): HResult; stdcall;
    function LocalGetIDsOfNames: HResult; stdcall;
    function LocalInvoke: HResult; stdcall;
    function RemoteGetDocumentation(memid: Integer; refPtrFlags: LongWord; 
                                    out pbstrName: WideString; out pBstrDocString: WideString; 
                                    out pdwHelpContext: LongWord; out pBstrHelpFile: WideString): HResult; stdcall;
    function RemoteGetDllEntry(memid: Integer; invkind: tagINVOKEKIND; refPtrFlags: LongWord; 
                               out pBstrDllName: WideString; out pbstrName: WideString; 
                               out pwOrdinal: Word): HResult; stdcall;
    function GetRefTypeInfo(hreftype: LongWord; out ppTInfo: ITypeInfo): HResult; stdcall;
    function LocalAddressOfMember: HResult; stdcall;
    function RemoteCreateInstance(var riid: TGUID; out ppvObj: IUnknown): HResult; stdcall;
    function GetMops(memid: Integer; out pBstrMops: WideString): HResult; stdcall;
    function RemoteGetContainingTypeLib(out ppTLib: ITypeLib; out pIndex: SYSUINT): HResult; stdcall;
    function LocalReleaseTypeAttr: HResult; stdcall;
    function LocalReleaseFuncDesc: HResult; stdcall;
    function LocalReleaseVarDesc: HResult; stdcall;
  end;

// *********************************************************************//
// Interface: ITypeComp
// Flags:     (0)
// GUID:      {00020403-0000-0000-C000-000000000046}
// *********************************************************************//
  ITypeComp = interface(IUnknown)
    ['{00020403-0000-0000-C000-000000000046}']
    function RemoteBind(szName: PWideChar; lHashVal: LongWord; wFlags: Word; 
                        out ppTInfo: ITypeInfo; out pDescKind: tagDESCKIND; 
                        out ppFuncDesc: PUserType5; out ppVarDesc: PUserType6; 
                        out ppTypeComp: ITypeComp; out pDummy: DWORD): HResult; stdcall;
    function RemoteBindType(szName: PWideChar; lHashVal: LongWord; out ppTInfo: ITypeInfo): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: ITypeLib
// Flags:     (0)
// GUID:      {00020402-0000-0000-C000-000000000046}
// *********************************************************************//
  ITypeLib = interface(IUnknown)
    ['{00020402-0000-0000-C000-000000000046}']
    function RemoteGetTypeInfoCount(out pcTInfo: SYSUINT): HResult; stdcall;
    function GetTypeInfo(index: SYSUINT; out ppTInfo: ITypeInfo): HResult; stdcall;
    function GetTypeInfoType(index: SYSUINT; out pTKind: tagTYPEKIND): HResult; stdcall;
    function GetTypeInfoOfGuid(var guid: TGUID; out ppTInfo: ITypeInfo): HResult; stdcall;
    function RemoteGetLibAttr(out ppTLibAttr: PUserType10; out pDummy: DWORD): HResult; stdcall;
    function GetTypeComp(out ppTComp: ITypeComp): HResult; stdcall;
    function RemoteGetDocumentation(index: SYSINT; refPtrFlags: LongWord; 
                                    out pbstrName: WideString; out pBstrDocString: WideString; 
                                    out pdwHelpContext: LongWord; out pBstrHelpFile: WideString): HResult; stdcall;
    function RemoteIsName(szNameBuf: PWideChar; lHashVal: LongWord; out pfName: Integer; 
                          out pBstrLibName: WideString): HResult; stdcall;
    function RemoteFindName(szNameBuf: PWideChar; lHashVal: LongWord; out ppTInfo: ITypeInfo; 
                            out rgMemId: Integer; var pcFound: Word; out pBstrLibName: WideString): HResult; stdcall;
    function LocalReleaseTLibAttr: HResult; stdcall;
  end;

// *********************************************************************//
// Interface: ISCardCmd
// Flags:     (4096) Dispatchable
// GUID:      {D5778AE3-43DE-11D0-9171-00AA00C18068}
// *********************************************************************//
  ISCardCmd = interface(IDispatch)
    ['{D5778AE3-43DE-11D0-9171-00AA00C18068}']
    function Get_Apdu(out ppApdu: IByteBuffer): HResult; stdcall;
    function Set_Apdu(const ppApdu: IByteBuffer): HResult; stdcall;
    function Get_ApduLength(out plSize: Integer): HResult; stdcall;
    function Get_ApduReply(out ppReplyApdu: IByteBuffer): HResult; stdcall;
    function Set_ApduReply(const ppReplyApdu: IByteBuffer): HResult; stdcall;
    function Get_ApduReplyLength(out plSize: Integer): HResult; stdcall;
    function Set_ApduReplyLength(plSize: Integer): HResult; stdcall;
    function Get_ClassId(out pbyClass: BYTE): HResult; stdcall;
    function Set_ClassId(pbyClass: BYTE): HResult; stdcall;
    function Get_Data(out ppData: IByteBuffer): HResult; stdcall;
    function Set_Data(const ppData: IByteBuffer): HResult; stdcall;
    function Get_InstructionId(out pbyIns: BYTE): HResult; stdcall;
    function Set_InstructionId(pbyIns: BYTE): HResult; stdcall;
    function Get_LeField(out plSize: Integer): HResult; stdcall;
    function Get_P1(out pbyP1: BYTE): HResult; stdcall;
    function Set_P1(pbyP1: BYTE): HResult; stdcall;
    function Get_P2(out pbyP2: BYTE): HResult; stdcall;
    function Set_P2(pbyP2: BYTE): HResult; stdcall;
    function Get_P3(out pbyP3: BYTE): HResult; stdcall;
    function Get_ReplyStatus(out pwStatus: Word): HResult; stdcall;
    function Set_ReplyStatus(pwStatus: Word): HResult; stdcall;
    function Get_ReplyStatusSW1(out pbySW1: BYTE): HResult; stdcall;
    function Get_ReplyStatusSW2(out pbySW2: BYTE): HResult; stdcall;
    function Get_type_(out pType: ISO_APDU_TYPE): HResult; stdcall;
    function Get_Nad(out pbNad: BYTE): HResult; stdcall;
    function Set_Nad(pbNad: BYTE): HResult; stdcall;
    function Get_ReplyNad(out pbNad: BYTE): HResult; stdcall;
    function Set_ReplyNad(pbNad: BYTE): HResult; stdcall;
    function BuildCmd(byClassId: BYTE; byInsId: BYTE; byP1: BYTE; byP2: BYTE; 
                      const pbyData: IByteBuffer; var plLe: Integer): HResult; stdcall;
    function Clear: HResult; stdcall;
    function Encapsulate(const pApdu: IByteBuffer; ApduType: ISO_APDU_TYPE): HResult; stdcall;
    function Get_AlternateClassId(out pbyClass: BYTE): HResult; stdcall;
    function Set_AlternateClassId(pbyClass: BYTE): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: ISCardISO7816
// Flags:     (4096) Dispatchable
// GUID:      {53B6AA68-3F56-11D0-916B-00AA00C18068}
// *********************************************************************//
  ISCardISO7816 = interface(IDispatch)
    ['{53B6AA68-3F56-11D0-916B-00AA00C18068}']
    function AppendRecord(byRefCtrl: BYTE; const pData: IByteBuffer; var ppCmd: ISCardCmd): HResult; stdcall;
    function EraseBinary(byP1: BYTE; byP2: BYTE; const pData: IByteBuffer; var ppCmd: ISCardCmd): HResult; stdcall;
    function ExternalAuthenticate(byAlgorithmRef: BYTE; bySecretRef: BYTE; 
                                  const pChallenge: IByteBuffer; var ppCmd: ISCardCmd): HResult; stdcall;
    function GetChallenge(lBytesExpected: Integer; var ppCmd: ISCardCmd): HResult; stdcall;
    function GetData(byP1: BYTE; byP2: BYTE; lBytesToGet: Integer; var ppCmd: ISCardCmd): HResult; stdcall;
    function GetResponse(byP1: BYTE; byP2: BYTE; lDataLength: Integer; var ppCmd: ISCardCmd): HResult; stdcall;
    function InternalAuthenticate(byAlgorithmRef: BYTE; bySecretRef: BYTE; 
                                  const pChallenge: IByteBuffer; lReplyBytes: Integer; 
                                  var ppCmd: ISCardCmd): HResult; stdcall;
    function ManageChannel(byChannelState: BYTE; byChannel: BYTE; var ppCmd: ISCardCmd): HResult; stdcall;
    function PutData(byP1: BYTE; byP2: BYTE; const pData: IByteBuffer; var ppCmd: ISCardCmd): HResult; stdcall;
    function ReadBinary(byP1: BYTE; byP2: BYTE; lBytesToRead: Integer; var ppCmd: ISCardCmd): HResult; stdcall;
    function ReadRecord(byRecordId: BYTE; byRefCtrl: BYTE; lBytesToRead: Integer; 
                        var ppCmd: ISCardCmd): HResult; stdcall;
    function SelectFile(byP1: BYTE; byP2: BYTE; const pData: IByteBuffer; lBytesToRead: Integer; 
                        var ppCmd: ISCardCmd): HResult; stdcall;
    function SetDefaultClassId(byClass: BYTE): HResult; stdcall;
    function UpdateBinary(byP1: BYTE; byP2: BYTE; const pData: IByteBuffer; var ppCmd: ISCardCmd): HResult; stdcall;
    function UpdateRecord(byRecordId: BYTE; byRefCtrl: BYTE; const pData: IByteBuffer; 
                          var ppCmd: ISCardCmd): HResult; stdcall;
    function Verify(byRefCtrl: BYTE; const pData: IByteBuffer; var ppCmd: ISCardCmd): HResult; stdcall;
    function WriteBinary(byP1: BYTE; byP2: BYTE; const pData: IByteBuffer; var ppCmd: ISCardCmd): HResult; stdcall;
    function WriteRecord(byRecordId: BYTE; byRefCtrl: BYTE; const pData: IByteBuffer; 
                         var ppCmd: ISCardCmd): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: ISCard
// Flags:     (4096) Dispatchable
// GUID:      {1461AAC3-6810-11D0-918F-00AA00C18068}
// *********************************************************************//
  ISCard = interface(IDispatch)
    ['{1461AAC3-6810-11D0-918F-00AA00C18068}']
    function Get_Atr(out ppAtr: IByteBuffer): HResult; stdcall;
    function Get_CardHandle(out pHandle: HSCARD): HResult; stdcall;
    function Get_Context(out pContext: HSCARDCONTEXT): HResult; stdcall;
    function Get_Protocol(out pProtocol: SCARD_PROTOCOLS): HResult; stdcall;
    function Get_Status(out pStatus: SCARD_STATES): HResult; stdcall;
    function AttachByHandle(hCard: HSCARD): HResult; stdcall;
    function AttachByReader(const bstrReaderName: WideString; ShareMode: SCARD_SHARE_MODES; 
                            PrefProtocol: SCARD_PROTOCOLS): HResult; stdcall;
    function Detach(Disposition: SCARD_DISPOSITIONS): HResult; stdcall;
    function LockSCard: HResult; stdcall;
    function ReAttach(ShareMode: SCARD_SHARE_MODES; InitState: SCARD_DISPOSITIONS): HResult; stdcall;
    function Transaction(var ppCmd: ISCardCmd): HResult; stdcall;
    function UnlockSCard(Disposition: SCARD_DISPOSITIONS): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: ISCardDatabase
// Flags:     (4096) Dispatchable
// GUID:      {1461AAC8-6810-11D0-918F-00AA00C18068}
// *********************************************************************//
  ISCardDatabase = interface(IDispatch)
    ['{1461AAC8-6810-11D0-918F-00AA00C18068}']
    function GetProviderCardId(const bstrCardName: WideString; out ppguidProviderId: PUserType7): HResult; stdcall;
    function ListCardInterfaces(const bstrCardName: WideString; out ppInterfaceGuids: wirePSAFEARRAY): HResult; stdcall;
    function ListCards(const pAtr: IByteBuffer; pInterfaceGuids: wirePSAFEARRAY; localeId: Integer; 
                       out ppCardNames: wirePSAFEARRAY): HResult; stdcall;
    function ListReaderGroups(localeId: Integer; out ppReaderGroups: wirePSAFEARRAY): HResult; stdcall;
    function ListReaders(localeId: Integer; out ppReaders: wirePSAFEARRAY): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: ISCardLocate
// Flags:     (4096) Dispatchable
// GUID:      {1461AACD-6810-11D0-918F-00AA00C18068}
// *********************************************************************//
  ISCardLocate = interface(IDispatch)
    ['{1461AACD-6810-11D0-918F-00AA00C18068}']
    function ConfigureCardGuidSearch(pCardGuids: wirePSAFEARRAY; pGroupNames: wirePSAFEARRAY; 
                                     const bstrTitle: WideString; lFlags: Integer): HResult; stdcall;
    function ConfigureCardNameSearch(pCardNames: wirePSAFEARRAY; pGroupNames: wirePSAFEARRAY; 
                                     const bstrTitle: WideString; lFlags: Integer): HResult; stdcall;
    function FindCard(ShareMode: SCARD_SHARE_MODES; Protocols: SCARD_PROTOCOLS; lFlags: Integer; 
                      out ppCardInfo: PUserType12): HResult; stdcall;
  end;

// *********************************************************************//
// The Class CoCByteBuffer provides a Create and CreateRemote method to          
// create instances of the default interface IByteBuffer exposed by              
// the CoClass CByteBuffer. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCByteBuffer = class
    class function Create: IByteBuffer;
    class function CreateRemote(const MachineName: string): IByteBuffer;
  end;

// *********************************************************************//
// The Class CoCSCardTypeConv provides a Create and CreateRemote method to          
// create instances of the default interface ISCardTypeConv exposed by              
// the CoClass CSCardTypeConv. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCSCardTypeConv = class
    class function Create: ISCardTypeConv;
    class function CreateRemote(const MachineName: string): ISCardTypeConv;
  end;

// *********************************************************************//
// The Class CoCSCardCmd provides a Create and CreateRemote method to          
// create instances of the default interface ISCardCmd exposed by              
// the CoClass CSCardCmd. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCSCardCmd = class
    class function Create: ISCardCmd;
    class function CreateRemote(const MachineName: string): ISCardCmd;
  end;

// *********************************************************************//
// The Class CoCSCardISO7816 provides a Create and CreateRemote method to          
// create instances of the default interface ISCardISO7816 exposed by              
// the CoClass CSCardISO7816. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCSCardISO7816 = class
    class function Create: ISCardISO7816;
    class function CreateRemote(const MachineName: string): ISCardISO7816;
  end;

// *********************************************************************//
// The Class CoCSCard provides a Create and CreateRemote method to          
// create instances of the default interface ISCard exposed by              
// the CoClass CSCard. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCSCard = class
    class function Create: ISCard;
    class function CreateRemote(const MachineName: string): ISCard;
  end;

// *********************************************************************//
// The Class CoCSCardDatabase provides a Create and CreateRemote method to          
// create instances of the default interface ISCardDatabase exposed by              
// the CoClass CSCardDatabase. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCSCardDatabase = class
    class function Create: ISCardDatabase;
    class function CreateRemote(const MachineName: string): ISCardDatabase;
  end;

// *********************************************************************//
// The Class CoCSCardLocate provides a Create and CreateRemote method to          
// create instances of the default interface ISCardLocate exposed by              
// the CoClass CSCardLocate. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCSCardLocate = class
    class function Create: ISCardLocate;
    class function CreateRemote(const MachineName: string): ISCardLocate;
  end;

implementation

uses ComObj;

class function CoCByteBuffer.Create: IByteBuffer;
begin
  Result := CreateComObject(CLASS_CByteBuffer) as IByteBuffer;
end;

class function CoCByteBuffer.CreateRemote(const MachineName: string): IByteBuffer;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_CByteBuffer) as IByteBuffer;
end;

class function CoCSCardTypeConv.Create: ISCardTypeConv;
begin
  Result := CreateComObject(CLASS_CSCardTypeConv) as ISCardTypeConv;
end;

class function CoCSCardTypeConv.CreateRemote(const MachineName: string): ISCardTypeConv;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_CSCardTypeConv) as ISCardTypeConv;
end;

class function CoCSCardCmd.Create: ISCardCmd;
begin
  Result := CreateComObject(CLASS_CSCardCmd) as ISCardCmd;
end;

class function CoCSCardCmd.CreateRemote(const MachineName: string): ISCardCmd;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_CSCardCmd) as ISCardCmd;
end;

class function CoCSCardISO7816.Create: ISCardISO7816;
begin
  Result := CreateComObject(CLASS_CSCardISO7816) as ISCardISO7816;
end;

class function CoCSCardISO7816.CreateRemote(const MachineName: string): ISCardISO7816;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_CSCardISO7816) as ISCardISO7816;
end;

class function CoCSCard.Create: ISCard;
begin
  Result := CreateComObject(CLASS_CSCard) as ISCard;
end;

class function CoCSCard.CreateRemote(const MachineName: string): ISCard;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_CSCard) as ISCard;
end;

class function CoCSCardDatabase.Create: ISCardDatabase;
begin
  Result := CreateComObject(CLASS_CSCardDatabase) as ISCardDatabase;
end;

class function CoCSCardDatabase.CreateRemote(const MachineName: string): ISCardDatabase;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_CSCardDatabase) as ISCardDatabase;
end;

class function CoCSCardLocate.Create: ISCardLocate;
begin
  Result := CreateComObject(CLASS_CSCardLocate) as ISCardLocate;
end;

class function CoCSCardLocate.CreateRemote(const MachineName: string): ISCardLocate;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_CSCardLocate) as ISCardLocate;
end;

end.
