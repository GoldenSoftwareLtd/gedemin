
unit rdzGanttChart;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, Radzivill_Gantt, IBDatabase;

type
  TrdzGanttChart = class(TDrawGrid)
  private
    FProject: TrdzProject;
    FStartDate: TDateTime;
    FFixedColWidth: Integer;
    procedure SetStartDate(const Value: TDateTime);
    procedure SetFixedColWidth(const Value: Integer);

  protected
    procedure DrawCell(ACol, ARow: LongInt; ARect: TRect; AState: TGridDrawState); override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure LoadFromDatabase(IBDatabase: TIBDatabase);

  published
    property StartDate: TDateTime read FStartDate write SetStartDate;
    property FixedColWidth: Integer read FFixedColWidth write SetFixedColWidth
      default 64;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('gsVC', [TrdzGanttChart]);
end;

{ TrdzGanttChart }

constructor TrdzGanttChart.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FProject := TrdzProject.Create;
  FFixedColWidth := 64;
  ColWidths[0] := FFixedColWidth;
end;

destructor TrdzGanttChart.Destroy;
begin
  inherited;
  FProject.Free;
end;

procedure TrdzGanttChart.DrawCell(ACol, ARow: Integer; ARect: TRect;
  AState: TGridDrawState);
var
  D: TDateTime;
begin
  inherited DrawCell(ACol, ARow, ARect, AState);

  if (ARow >= 0) and (ARow < FProject.Actions.Count) then
  begin
    D := FStartDate;
    D := D + ACol;

    if TrdzAction(FProject.Actions[ARow + 1]).DateInInterval(D) then
    begin
      Canvas.Brush.Color := clRed;
      Canvas.FillRect(ARect);
    end;

  end;
end;

procedure TrdzGanttChart.LoadFromDatabase(IBDatabase: TIBDatabase);
begin
  FProject.LoadFromDatabase(IBDatabase);
  Invalidate;
end;

procedure TrdzGanttChart.SetFixedColWidth(const Value: Integer);
begin
  FFixedColWidth := Value;
  ColWidths[0] := FFixedColWidth;
end;

procedure TrdzGanttChart.SetStartDate(const Value: TDateTime);
begin
  FStartDate := Value;
  Invalidate;
end;

end.

