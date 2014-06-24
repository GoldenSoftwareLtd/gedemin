
unit gdcInvDocumentCache_unit;

interface

uses
  Classes, gdcBaseInterface;

type
  IgdcInvDocumentCache = interface
    function GetSubTypeList(const InvDocumentTypeBranchKey: TID;
      SubTypeList: TStrings; SubType: string = ''; OnlyDirect: Boolean = False): Boolean;
    function GetSubTypeList2(const ClassName: String;
      SubTypeList: TStrings; Subtype: string = ''; OnlyDirect: Boolean = False): Boolean;
    procedure Clear;
    function ClassParentSubtype(SubType: string): string;
  end;

var
  gdcInvDocumentCache: IgdcInvDocumentCache;

implementation

end.
 