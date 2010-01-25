unit frFieldValuesLineConfig_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  frFieldValuesLine_unit, xCalculatorEdit, StdCtrls, Mask, xDateEdits,
  gsIBLookupComboBox, ExtCtrls, ActnList, Buttons, gdv_InvCardConfig_unit;

type

  CfrFieldValuesLineConfig = class of TfrFieldValuesLineConfig;

  TfrFieldValuesLineConfig = class(TfrFieldValuesLine)
    chkInputParam: TCheckBox;
  private
  protected
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;
  public
    function IsEmpty: boolean; override;
  end;

var
  frFieldValuesLineConfig: TfrFieldValuesLineConfig;

implementation

uses frFieldVlues_unit;

{$R *.DFM}

{ TfrFieldValuesLineConfig }

function TfrFieldValuesLineConfig.GetValue: string;
begin
  if chkInputParam.Checked then begin
    Result:= cInputParam;
    Exit;
  end;
  Result:= inherited GetValue;
end;

function TfrFieldValuesLineConfig.IsEmpty: boolean;
begin
  Result := (inherited IsEmpty) and not chkInputParam.Checked;
end;

procedure TfrFieldValuesLineConfig.SetValue(const Value: string);
begin
  if Value = cInputParam then begin
    chkInputParam.Checked:= True;
    Exit;
  end;
  inherited SetValue(Value);
  (Parent.Parent as TfrFieldValues).UpdateFrameHeight;
end;

initialization
  RegisterClass(TfrFieldValuesLineConfig);

finalization
  UnRegisterClass(TfrFieldValuesLineConfig);

end.
