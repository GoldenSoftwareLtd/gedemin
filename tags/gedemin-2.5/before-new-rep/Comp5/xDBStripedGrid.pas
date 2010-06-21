unit xDBStripedGrid;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, DBGrids, DB;

type
  TxDBStripedGrid = class(TDBGrid)
  private
{    procedure DoDrawColumnCell(Sender: TObject;
      const Rect: TRect; DataCol: Integer; Column: TColumn;
      State: TGridDrawState);}
  protected
{    procedure Loaded; override;}

  public
{    constructor Create(AnOwner: TComponent); override;} 
    
  published
  end;

procedure Register;

implementation

{constructor TxDBStripedGrid.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  OnDrawColumnCell := DoDrawColumnCell;
end;}

{procedure TxDBStripedGrid.Loaded;
var
  I: Integer;
begin
  inherited;
  for I := 0 to Columns.Count - 1 do
    Columns.Items[I].Title.Color := $E7f3f7;
end;                                        }

{procedure TxDBStripedGrid.DoDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
var
  I, Step: Integer;
  R: TRect;
  S: String;
begin
  Canvas.Brush.Style := bsSolid;

  if not (gdSelected in State) then
  begin
    if Odd(DataSource.DataSet.RecNo) then
      Canvas.Brush.Color := RGB(247, 243, 231)
    else
      Canvas.Brush.Color := RGB(231, 231, 214);
  end else
    Canvas.Brush.Color := RGB(247, 223, 156);

  Canvas.FillRect(Rect);

  R := Rect;
  R.Left := R.Left + 1;
  R.Right := R.Right - 1;
  S := Column.Field.AsString;

  Canvas.Font.Color := clBlack;

  DrawText(Canvas.Handle, @S[1], Length(S), R, DT_LEFT + DT_VCENTER + DT_SINGLELINE);
end;}


procedure Register;
begin
  RegisterComponents('gsDB', [TxDBStripedGrid]);
end;

end.
