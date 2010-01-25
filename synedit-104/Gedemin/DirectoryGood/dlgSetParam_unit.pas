unit dlgSetParam_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, DBCtrls, Db, IBCustomDataSet, IBUpdateSQL, IBQuery,
  ComCtrls, gd_security;

type
  TdlgSetParam = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    lblTNVD: TLabel;
    edName: TEdit;
    edDescription: TEdit;
    procedure btnOkClick(Sender: TObject);
  private
    function GetDescription: String;
    function GetParamName: String;
    procedure SetDescription(const Value: String);
    procedure SetParamName(const Value: String);
  public
    { Public declarations }
    property ParamName: String read GetParamName write SetParamName;
    property Description: String read GetDescription write SetDescription;
  end;

var
  dlgSetParam: TdlgSetParam;

implementation

{$R *.DFM}

procedure TdlgSetParam.btnOkClick(Sender: TObject);
begin
  if edName.Text = '' then
  begin
    MessageBox(Handle, 'Не указано наименование единицы измеренияю', 'Внимание', MB_OK or MB_ICONINFORMATION);
    edName.SetFocus;
    ModalResult := mrNone;
    abort;
  end;
end;


function TdlgSetParam.GetDescription: String;
begin
  Result := edDescription.Text;
end;

function TdlgSetParam.GetParamName: String;
begin
  Result := edName.Text;
end;

procedure TdlgSetParam.SetDescription(const Value: String);
begin
  edDescription.Text := Value;
end;

procedure TdlgSetParam.SetParamName(const Value: String);
begin
  edName.Text := Value;
end;

end.
