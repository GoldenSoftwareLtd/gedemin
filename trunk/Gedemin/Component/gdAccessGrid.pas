unit gdAccessGrid;

interface

uses
  Classes, Grids, Windows, Graphics;

type
  TgdAccessGrid = class(TStringGrid)
    private
      FAFull: Integer;
      FAChang: Integer;
      FAView: Integer;

      procedure GetUserGroupLst;

    protected
      procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;

    public
      constructor Create(AnOwner: TComponent); override;
      procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer);override;

    published
      property ColCount stored False;
      property RowCount stored False;

  end;

procedure Register;

implementation

uses
  Dialogs, SysUtils, gdcBaseInterface, DB, gdcBase,
  IBDatabase, IBSQL;

constructor TgdAccessGrid.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  ColCount := 5;
  FixedCols := 1;
  FixedRows := 1;

  Cells[0,0] := 'ИД';
  Cells[1,0] := 'Наименование';
  Cells[2,0] := 'Просмотр';
  Cells[3,0] := 'Изменение';
  Cells[4,0] := 'Полный доступ';

  GetUserGroupLst;

end;


procedure TgdAccessGrid.DrawCell(ACol, ARow: Integer; ARect: TRect;
  AState: TGridDrawState);
begin

  inherited DrawCell(ACol, ARow, ARect, AState);

end;

procedure TgdAccessGrid.GetUserGroupLst;
var
  q: TIBSQL;
  I: Integer;
begin
  if Assigned(gdcBaseManager) then
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcBaseManager.ReadTransaction;
      q.SQL.Text := 'SELECT id, name FROM gd_usergroup ORDER BY id';
      q.ExecQuery;
      I := 0;
      while not q.EOF do
      begin
        Inc(I);
        Cells[0, I] := q.FieldByName('id').AsString;
        Cells[1, I] := q.FieldByName('name').AsString;
        q.Next;
      end;
      RowCount := I + 1;
    finally
      q.Free;
    end;
  end;
end;

procedure TgdAccessGrid.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
var
  I: Integer;
  w: Integer;
begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  if (Parent <> nil) then
    begin
      for I := 0 to ColCount - 1 do
        ColWidths[I] := Canvas.TextWidth(cells[I,0]) + 5;
      w := Canvas.TextWidth(cells[1,0]);
      for I := 1 to RowCount - 2 do
        if Canvas.TextWidth(cells[1,I]) > w then
          w := Canvas.TextWidth(cells[1,I]);
      ColWidths[1] := w + 5;
    end;
end;

procedure Register;
begin
  RegisterComponents('gsNew', [TgdAccessGrid]);
end;

end.
