
unit gdcInvDocumentCache_unit;

interface

uses
  Classes, gdcBaseInterface;

type
  IgdcInvDocumentCache = interface
    function GetSubTypeList(const InvDocumentTypeBranchKey: TID;
      SubTypeList: TStrings): Boolean;
    function GetSubTypeList2(const ClassName: String;
      SubTypeList: TStrings): Boolean;
    procedure Clear;  
  end;

var
  gdcInvDocumentCache: IgdcInvDocumentCache;

implementation

end.
 