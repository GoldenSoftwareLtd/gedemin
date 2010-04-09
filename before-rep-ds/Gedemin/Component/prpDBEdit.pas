unit prpDBEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, DBCtrls;

type
  TprpDBEdit = class(TDBEdit)
  private
    { Private declarations }
  protected
    { Protected declarations }
    function GetClientRect: TRect; override;
  public
    { Public declarations }
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Data Controls', [TprpDBEdit]);
end;

{ TprpDBEdit }

function TprpDBEdit.GetClientRect: TRect;
begin
  Result.Left := 0;
  Result.Top := 0;
  Result.Right := Width - Height;
  Result.Bottom := Height;
end;

end.
