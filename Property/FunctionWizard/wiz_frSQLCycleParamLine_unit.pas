unit wiz_frSQLCycleParamLine_unit;

interface

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, BtnEdit, ExtCtrls, wiz_FunctionBlock_unit;

type
  TSQLCycleParamLine = class(TFrame)
    eParam: TBtnEdit;
    lName: TLabel;
    cbNull: TCheckBox;
    Bevel1: TBevel;
    procedure eParamBtnOnClick(Sender: TObject);
    procedure eParamChange(Sender: TObject);
  private
    FParamName: string;
    FBlock: TVisualBlock;
    procedure SetIsNull(const Value: boolean);
    procedure SetParamName(const Value: string);
    procedure SetValue(const Value: string);
    function GetIsNull: boolean;
    function GetValue: string;
    procedure SetBlock(const Value: TVisualBlock);
  public
    { Public declarations }
    property ParamName: string read FParamName write SetParamName;
    property IsNull: boolean read GetIsNull write SetIsNull;
    property Value: string read GetValue write SetValue;
    property Block: TVisualBlock read FBlock write SetBlock;
  end;

implementation

{$R *.DFM}

procedure TSQLCycleParamLine.eParamBtnOnClick(Sender: TObject);
begin
  Value := FBlock.EditExpression(eParam.Text, FBlock);
end;

function TSQLCycleParamLine.GetIsNull: boolean;
begin
  Result := cbNull.Checked
end;

function TSQLCycleParamLine.GetValue: string;
begin
  if IsNull then
    Result := 'NULL'
  else
    Result := eParam.Text;  
end;

procedure TSQLCycleParamLine.SetBlock(const Value: TVisualBlock);
begin
  FBlock := Value;
end;

procedure TSQLCycleParamLine.SetIsNull(const Value: boolean);
begin
  cbNull.Checked := Value;
end;

procedure TSQLCycleParamLine.SetParamName(const Value: string);
begin
  FParamName := Value;
  lName.Caption := Value + ':';
end;

procedure TSQLCycleParamLine.SetValue(const Value: string);
begin
  if Value <> 'NULL' then
    eParam.Text := Value
  else
    eParam.Text := '';
//  IsNull := (eParam.Text = '') or (eParam.Text = 'ISNULL');
end;

procedure TSQLCycleParamLine.eParamChange(Sender: TObject);
begin
  IsNull := eParam.Text = '';
end;

end.
