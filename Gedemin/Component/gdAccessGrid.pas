// ShlTanya, 11.02.2019

unit gdAccessGrid;

interface

uses
  Classes, Grids, Windows, Graphics;

type
  TgdAccessGrid = class(TStringGrid)
  private
    FAFull: Integer;
    FAChag: Integer;
    FAView: Integer;
    FTick, FCross: TBitmap;

    procedure GetUserGroupList;

  protected
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure Refresh;

  published
    property ColCount stored False;
    property RowCount stored False;
    property FixedCols stored False;
    property FixedRows stored False;
    property DefaultRowHeight stored False;
  end;

procedure Register;

implementation

{$R GDACCESSGRID.RES}

uses
  Dialogs, SysUtils, gdcBaseInterface, DB, gdcBase,
  IBDatabase, IBSQL;

constructor TgdAccessGrid.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  ColCount := 5;
  FixedCols := 0;
  FixedRows := 1;
  DoubleBuffered := True;
  DefaultRowHeight := 18;
  
  ColWidths[0] := 144;
  ColWidths[1] := 22;
  ColWidths[2] := 38;
  ColWidths[3] := 38;
  ColWidths[4] := 38;

  Cells[0,0] := 'Наименование';
  Cells[1,0] := 'ИД';
  Cells[2,0] := 'Просм';
  Cells[3,0] := 'Изм';
  Cells[4,0] := 'Полн';

  GetUserGroupList;

  FTick := TBitmap.Create;
  FTick.Transparent := True;
  FTick.TransparentColor := clBlack;
  FTick.LoadFromResourceName(hInstance, 'GDACCESSGRID_TICK');

  FCross := TBitmap.Create;
  FCross.Transparent := True;
  FCross.TransparentColor := clBlack;
  FCross.LoadFromResourceName(hInstance, 'GDACCESSGRID_CROSS');
end;


destructor TgdAccessGrid.Destroy;
begin
  FTick.Free;
  FCross.Free;
  inherited;
end;

procedure TgdAccessGrid.DrawCell(ACol, ARow: Integer; ARect: TRect;
  AState: TGridDrawState);
var
  Mask: Integer;
  Bm: TBitmap;
begin
  if (ARow > 0) and (ACol > 1) then
  begin
    case ACol of
      2: Mask := FAView;
      3: Mask := FAChag;
    else
      Mask := FAFull;
    end;

    if Mask and StrToIntDef(Cells[1, ARow], 0) <> 0 then
      Bm := FTick
    else
      Bm := FCross;

    Canvas.Draw(ARect.Left + (ARect.Right - ARect.Left - Bm.Width) div 2,
      ARect.Top + (ARect.Bottom - ARect.Top - Bm.Height) div 2, Bm);
  end else
    inherited DrawCell(ACol, ARow, ARect, AState);
end;

procedure TgdAccessGrid.GetUserGroupList;
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
        Cells[0, I] := q.FieldByName('name').AsString;
        Cells[1, I] := q.FieldByName('id').AsString;
        q.Next;
      end;
      RowCount := I + 1;
    finally
      q.Free;
    end;
  end;
end;

procedure TgdAccessGrid.Refresh;
begin
  GetUserGroupList;
  Invalidate;
end;

procedure TgdAccessGrid.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  ColWidths[0] := Width - ColWidths[1] - ColWidths[2] - ColWidths[3] - ColWidths[4] - 8;
end;

procedure Register;
begin
  RegisterComponents('gsNew', [TgdAccessGrid]);
end;

end.
