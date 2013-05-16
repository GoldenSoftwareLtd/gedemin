unit frAcctQuantityLine_unit;

interface

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, xCalculatorEdit;

type
  TfrAcctQuantityLine = class(TFrame)
    lName: TLabel;
    eCalc: TxCalculatorEdit;
    procedure eCalcChange(Sender: TObject);
  private
    FOnValueChange: TNotifyEvent;
    FValueId: Integer;
    procedure SetOnValueChange(const Value: TNotifyEvent);
    function GetValue: Double;
    procedure SetValue(const Value: Double);
    procedure SetValueId(const Value: Integer);
  public
    property Value: Double read GetValue write SetValue;
    function IsEmpty: boolean;
    property ValueId: Integer read FValueId write SetValueId;
    property OnValueChange: TNotifyEvent read FOnValueChange write SetOnValueChange;
  end;

implementation

{$R *.DFM}

{ TfrAcctQuantityLine }

function TfrAcctQuantityLine.GetValue: Double;
begin
  Result := eCalc.Value;
end;

function TfrAcctQuantityLine.IsEmpty: Boolean;
begin
  Result := (eCalc.Text = '') or (eCalc.Value = 0);
end;

procedure TfrAcctQuantityLine.SetOnValueChange(const Value: TNotifyEvent);
begin
  FOnValueChange := Value;
end;

procedure TfrAcctQuantityLine.SetValue(const Value: Double);
begin
  eCalc.Value := Value;
end;

procedure TfrAcctQuantityLine.eCalcChange(Sender: TObject);
begin
  if Assigned(FOnValueChange) then
    FOnValueChange(Sender);
end;

procedure TfrAcctQuantityLine.SetValueId(const Value: Integer);
begin
  FValueId := Value;
end;

end.
