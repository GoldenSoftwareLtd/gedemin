// ShlTanya, 25.02.2019

unit prp_dlgInputLineNumber_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, xCalculatorEdit, ExtCtrls;

type
  TdlgInputLineNumber = class(TForm)
    Bevel1: TBevel;
    btnOk: TButton;
    btnCancel: TButton;
    edtLine: TxCalculatorEdit;
    Label1: TLabel;
    procedure btnOkKeyPress(Sender: TObject; var Key: Char);
  private
    function ReadLineNumber: integer;
    procedure WriteLineNumber(const Value: integer);
  public
    property LineNumber: integer read ReadLineNumber write WriteLineNumber;
  end;

var
  dlgInputLineNumber: TdlgInputLineNumber;

implementation

{$R *.DFM}

{ TdlgInputLineNumber }

function TdlgInputLineNumber.ReadLineNumber: integer;
begin
  Result:= Round(edtLine.Value);
end;

procedure TdlgInputLineNumber.WriteLineNumber(const Value: integer);
begin
  edtLine.Value:= Value;
end;

procedure TdlgInputLineNumber.btnOkKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Ord(Key) = VK_ESCAPE then
    btnCancel.Click;
end;

end.
