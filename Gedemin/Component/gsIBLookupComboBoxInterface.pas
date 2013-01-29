
unit gsIBLookupComboBoxInterface;

interface

uses
  Windows, Messages, gdcBaseInterface;

(*

  Першапачаткова мы стварылі гэты інтэрфэйс каб пазбегнуць
  цыркулрных спасылак паміж комба боксам і выпадаючым акном.

*)

type
  IgsIBLookupComboBox = interface
    ['{755C69A1-42F6-11D5-B4A9-0060520A1991}']

    procedure SetDropDownDialogWidth(const Value: Integer);
    function GetDropDownDialogWidth: Integer;
    function GetHandle: HWND;
    function GetgdClassName: TgdcClassName;
    procedure SetgdClassName(const Value: TgdcClassName);

    property DropDownDialogWidth: Integer read GetDropDownDialogWidth
      write SetDropDownDialogWidth;
    property Handle: HWND read GetHandle;
    property gdClassName: TgdcClassName read GetgdClassName write SetgdClassName;
  end;

const
  WM_GD_SELECTDOCUMENT            = WM_USER + 2220;
  WM_GD_OPENACCTACCCARD           = WM_USER + 2221;

implementation

end.



