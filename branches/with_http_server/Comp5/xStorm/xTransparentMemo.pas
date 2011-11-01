unit xTransparentMemo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TxTransparentMemo = class(TMemo)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AnOwner: TComponent); override;
  published
    { Published declarations }
  end;

procedure Register;

implementation

constructor TxTransparentMemo.Create(AnOwner: TComponent); override;
begin
  inherited Create(AnOwner);
  ControlStyle = ControlStyle - csOpaque; 
end;

procedure Register;
begin
  RegisterComponents('Samples', [TxTransparentMemo]);
end;

end.
