// ShlTanya, 24.02.2019

unit evt_i_Inherited;

interface

type
  TEventInheritedInvoker = procedure(const AnEventName: String; AnParams: OleVariant) of object;

type
  IgsEventInheritedInvoker = interface
  ['{1D0F57B5-954B-4B22-A84C-3CB111B00C85}']
    function Get_Self: TObject;
  end;

var
  EventInheritedInvoker: IgsEventInheritedInvoker;

implementation

initialization
  EventInheritedInvoker := nil;

end.

