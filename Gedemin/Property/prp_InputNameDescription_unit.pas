// ShlTanya, 26.02.2019

unit prp_InputNameDescription_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TfrmNameDescription = class(TForm)
    edtName: TEdit;
    edtDesc: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    btnOk: TButton;
    btnCancel: TButton;
  private
    FIsNew: boolean;
    function GetInputDesc: string;
    function GetInputName: string;
    procedure SetInputDesc(const Value: string);
    procedure SetInputName(const Value: string);
    { Private declarations }
  public
    property InputDescription: string read GetInputDesc write SetInputDesc;
    property InputName: string read GetInputName write SetInputName;
    property IsNew: boolean read FIsNew write FIsNew;
  end;

var
  frmNameDescription: TfrmNameDescription;

implementation

{$R *.DFM}

{ TfrmNameDescription }

function TfrmNameDescription.GetInputDesc: string;
begin
  Result:= edtDesc.Text;
end;

function TfrmNameDescription.GetInputName: string;
begin
  Result:= edtName.Text;
end;

procedure TfrmNameDescription.SetInputDesc(const Value: string);
begin
  edtDesc.Text:= Value;
end;

procedure TfrmNameDescription.SetInputName(const Value: string);
begin
  edtName.Text:= Value;
end;

end.
