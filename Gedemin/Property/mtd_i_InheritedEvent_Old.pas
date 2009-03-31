unit mtd_i_InheritedEvent_Old;

interface

type
  TEventInvoker = procedure(const AnEventName: String; AnParams: OleVariant) of object;

type
  IgsInheritedEventInvoker = interface
  ['{F3675E87-3CBD-11D6-B6C4-00C0DF0E09D1}']
    procedure RegisterEventInvoker(AnSender: TObject; AnEventInvoker: TEventInvoker);
    procedure UnRegisterEventInvoker(AnSender: TObject);
    function Get_Self: TObject;
  end;

var
  InheritedEventInvoker: IgsInheritedEventInvoker;

implementation

initialization
  InheritedEventInvoker := nil;

end.
