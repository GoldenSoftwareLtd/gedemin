unit mtd_i_Inherited;

interface

type
//  TMethodInvoker = procedure(const AnEventName: WideString; AnParams: OleVariant) of object;
  TMethodInvoker = function(const AnEventName: WideString; AnParams: OleVariant): OleVariant of object;

type
  IgsInheritedMethodInvoker = interface
  ['{F3675E87-3CBD-11D6-B6C4-00C0DF0E09D1}']
    procedure RegisterMethodInvoker(AnSender: TObject; AnMethodInvoker: TMethodInvoker);
    procedure UnRegisterMethodInvoker(AnSender: TObject);
    function Get_Self: TObject;
  end;

var
  InheritedMethodInvoker: IgsInheritedMethodInvoker;

implementation

initialization
  InheritedMethodInvoker := nil;

finalization
  InheritedMethodInvoker := nil;

end.
