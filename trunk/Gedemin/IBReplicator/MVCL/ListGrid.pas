unit ListGrid;

interface

uses
  SysUtils, Classes, Controls, Grids;

type
  TCustomListGrid = class(TCustomGrid)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
  published
    { Published declarations }
  end;

  TListGrid = class(TCustomListGrid)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Standard', [TListGrid]);
end;

end.
