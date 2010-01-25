unit xButton;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TxButton = class(TButton)
  private
  protected
    procedure Paint; override;
  public
  published
  end;

procedure Register;

implementation

const
  clrButton = $0;
  clrNormalText = $0;
  clrNormalFrame = $0;
  clrFocusedText = $FFFFFF;

{ TxButton }

procedure TxButton.Paint;
var
  R: TRect;
begin
  R := ClientRect;
  Canvas.Brush.Color := clrNormalFrame;
  Canvas.FrameRect(R);
  R.Top := 1;
  R.Left := 1;
  Canvas.Brush.Color := clrButton;
  Canvas.FillRect(R);
end;

procedure Register;
begin
  RegisterComponents('gsBtn', [TxButton]);
end;

end.
