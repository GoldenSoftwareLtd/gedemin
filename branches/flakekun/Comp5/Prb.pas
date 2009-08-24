unit Prb;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls;

type
  TPrb = class(TImage)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

  published
    { Published declarations }
  end;

procedure Register;

implementation

constructor TPrb.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

end;

destructor TPrb.Destroy;
begin

  inherited Destroy;
end;

procedure Register;
begin
  RegisterComponents('Samples', [TPrb]);
end;

end.
