
unit gsDBLookupComboBoxInterface;

interface

uses
  Windows;

(*

  �������������� �� ������� ���� ��������� ��� ����������
  ���������� �������� ���� ����� ������ � ���������� �����.

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



