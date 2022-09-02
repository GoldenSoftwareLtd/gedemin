// ShlTanya, 09.03.2019

unit wiz_dlgReserveVarName_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TdlgReserveVarName = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Edit1: TEdit;
  private
    procedure SetVarName(const Value: string);
    function GetVarName: string;
    { Private declarations }
  public
    { Public declarations }
    property VarName: string read GetVarName write SetVarName;
  end;

var
  dlgReserveVarName: TdlgReserveVarName;

implementation

{$R *.DFM}

{ TdlgReserveVarName }

function TdlgReserveVarName.GetVarName: string;
begin
  Result := Edit1.Text;
end;

procedure TdlgReserveVarName.SetVarName(const Value: string);
begin
  Edit1.Text := Value;
end;

end.
