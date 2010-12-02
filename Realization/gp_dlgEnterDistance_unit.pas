unit gp_dlgEnterDistance_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, xSpin;

type
  Tgp_dlgEnterDistance = class(TForm)
    Label1: TLabel;
    speDistance: TxSpinEdit;
    bOk: TButton;
    bCancel: TButton;
  private
    function GetDistance: Integer;
    { Private declarations }
  public
    { Public declarations }
    property Distance: Integer read GetDistance; 
  end;

var
  gp_dlgEnterDistance: Tgp_dlgEnterDistance;

implementation

{$R *.DFM}

{ Tgp_dlgEnterDistance }

function Tgp_dlgEnterDistance.GetDistance: Integer;
begin
  Result := speDistance.IntValue;
end;

end.
