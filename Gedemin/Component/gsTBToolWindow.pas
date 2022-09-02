// ShlTanya, 20.02.2019

unit gsTBToolWindow;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  TB2Dock, TB2ToolWindow;

type
  TgsTBToolWindow = class(TTBToolWindow)
  private
    { Private declarations }
  protected
    { Protected declarations }
    function CalcSize(ADock: TTBDock): TPoint; override;
  public
    { Public declarations }
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Toolbar2000', [TgsTBToolWindow]);
end;

{ TgsTBToolWindow }

function TgsTBToolWindow.CalcSize(ADock: TTBDock): TPoint;
begin
  Result := inherited CalcSize(ADock);
{  if Assigned(ADock) and Stretch then
  begin
    if (ADock.Position in [dpLeft, dpRight]) then
    begin
      Result.x := ADock.ClientWidth;
    end else
      Result.Y := ADock.ClientHeight;
  end;}
end;

end.
