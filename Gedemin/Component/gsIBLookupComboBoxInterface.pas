// ShlTanya, 20.02.2019

unit gsIBLookupComboBoxInterface;

interface

uses
  Windows, Messages, gdcBaseInterface;

(*

  �������������� �� ������� ���� ��������� ��� ����������
  ���������� �������� ���� ����� ������ � ���������� �����.

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

implementation

end.



