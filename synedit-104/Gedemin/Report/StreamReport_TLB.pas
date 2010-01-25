unit StreamReport_TLB;

interface

uses Windows, ActiveX, Classes, Graphics, OleServer, OleCtrls, StdVCL;

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:
//   Type Libraries     : LIBID_xxxx
//   CoClasses          : CLASS_xxxx
//   DISPInterfaces     : DIID_xxxx
//   Non-DISP interfaces: IID_xxxx
// *********************************************************************//
const
  IID_Irtrtretr: TGUID = '{B5CC4034-1ED7-11D5-AECE-006052067F0D}';
  CLASS_rtrtretr: TGUID = '{B5CC4036-1ED7-11D5-AECE-006052067F0D}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary
// *********************************************************************//
  Irtrtretr = interface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library
// (NOTE: Here we map each CoClass to its Default Interface)
// *********************************************************************//
  rtrtretr = Irtrtretr;


// *********************************************************************//
// Interface: Irtrtretr
// Flags:     (0)
// GUID:      {B5CC4034-1ED7-11D5-AECE-006052067F0D}
// *********************************************************************//
  Irtrtretr = interface(IUnknown)
    ['{B5CC4034-1ED7-11D5-AECE-006052067F0D}']
    procedure Method1; safecall;
  end;

// *********************************************************************//
// The Class Cortrtretr provides a Create and CreateRemote method to
// create instances of the default interface Irtrtretr exposed by
// the CoClass rtrtretr. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
implementation

end.
