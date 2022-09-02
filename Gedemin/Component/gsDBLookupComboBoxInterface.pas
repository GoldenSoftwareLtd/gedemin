// ShlTanya, 17.02.2019

unit gsDBLookupComboBoxInterface;

interface

uses
  Windows;

(*

  Першапачаткова мы стварылі гэты інтэрфэйс каб пазбегнуць
  цыркулрных спасылак паміж комба боксам і выпадаючым акном.

*)

type
  IgsDBLookupComboBox = interface
    ['{DED456A4-5F68-4296-9255-24BD590B7E33}']

    procedure SetDropDownDialogWidth(const Value: Integer);
    function GetDropDownDialogWidth: Integer;
    function GetHandle: HWND;

    property DropDownDialogWidth: Integer read GetDropDownDialogWidth
      write SetDropDownDialogWidth;
    property Handle: HWND read GetHandle;
  end;

implementation

end.



