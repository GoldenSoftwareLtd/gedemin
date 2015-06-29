unit boEmployee;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  boObject;

type
  TboEmployee = class(tboObject)
  private
  protected
  public
  published
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Phone', [TboEmployee]);
end;

end.
