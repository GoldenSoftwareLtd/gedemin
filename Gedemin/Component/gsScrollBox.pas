unit gsScrollBox;

interface

uses
  Windows, Classes, Forms;

type
  TgsScrollBox = class(TScrollBox)
  private
    procedure _DoMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('gsNew', [TgsScrollBox]);
end;

constructor TgsScrollBox.Create(AOwner: TComponent);
begin
  inherited;

  OnMouseWheel := _DoMouseWheel;
end;

procedure TgsScrollBox._DoMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  if Sender is TgsScrollBox then
  begin
    if WheelDelta > 0 then
      (Sender as TgsScrollBox).VertScrollBar.Position :=
        (Sender as TgsScrollBox).VertScrollBar.Position -
        (Sender as TgsScrollBox).VertScrollBar.Increment
    else
      (Sender as TgsScrollBox).VertScrollBar.Position :=
        (Sender as TgsScrollBox).VertScrollBar.Position +
        (Sender as TgsScrollBox).VertScrollBar.Increment;

    Handled := True;
  end;
end;

end.
