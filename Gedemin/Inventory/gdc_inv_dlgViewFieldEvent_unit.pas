unit gdc_inv_dlgViewFieldEvent_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  Tgdc_inv_dlgViewFieldEvent = class(TForm)
    rgFields: TRadioGroup;
    bOk: TButton;
    bCancel: TButton;
  private
    function GetTypeField: Integer;
    { Private declarations }
  public
    { Public declarations }
    property TypeField: Integer read GetTypeField;
  end;

var
  gdc_inv_dlgViewFieldEvent: Tgdc_inv_dlgViewFieldEvent;

implementation

{$R *.DFM}

{ Tgdc_inv_dlgViewFieldEvent }

function Tgdc_inv_dlgViewFieldEvent.GetTypeField: Integer;
begin
  Result := rgFields.ItemIndex;
end;

end.
