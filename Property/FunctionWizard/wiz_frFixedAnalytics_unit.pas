unit wiz_frFixedAnalytics_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  wiz_frAnalytics_unit, ExtCtrls, wiz_frAnalyticLine_unit, gdcBaseInterface;

type
  TfrFixedAnalytics = class(TfrAnalytics)
  private
    FShowAnalyticName: Boolean;
    procedure SetShowAnalyticName(const Value: Boolean);
    { Private declarations }
  protected
    function GetAnalytics: string; override;
  public
    { Public declarations }
    property ShowAnalyticName: Boolean read FShowAnalyticName write SetShowAnalyticName;
  end;

var
  frFixedAnalytics: TfrFixedAnalytics;

implementation

{$R *.DFM}

{ TfrFixedAnalytics }

function TfrFixedAnalytics.GetAnalytics: string;
var
  I: Integer;
begin
  Result := '';
  if (FAnalyticLines <> nil) and (FAnalyticLines.Count > 0) then
  begin
    for I := 0 to FAnalyticLines.Count - 1 do
    begin
      if TfrAnalyticLine(FAnalyticLines[I]).eAnalytic.Text > '' then
      begin
        if FShowAnalyticName then
        begin
          if Result > '' then Result := Result + ' + ";" + ';
          if (TfrAnalyticLine(FAnalyticLines[I]).Field.ReferencesField <> nil) and
            (TfrAnalyticLine(FAnalyticLines[I]).AnalyticKey > 0) then
          begin
            Result := Result +
              '"' + TfrAnalyticLine(FAnalyticLines[I]).Field.FieldName +
              '= ' + gdcBaseManager.GetRUIDStringById(TfrAnalyticLine(FAnalyticLines[I]).AnalyticKey) + '"'
          end else
            Result := Result + '"' + TfrAnalyticLine(FAnalyticLines[I]).Field.FieldName +
              '= " + ' + TfrAnalyticLine(FAnalyticLines[I]).eAnalytic.Text;
        end else
        begin
          if Result > '' then Result := Result + ';';
          if (TfrAnalyticLine(FAnalyticLines[I]).Field.ReferencesField <> nil) and
            (TfrAnalyticLine(FAnalyticLines[I]).AnalyticKey > 0) then
          begin
            Result := Result + '"' +
              gdcBaseManager.GetRUIDStringById(TfrAnalyticLine(FAnalyticLines[I]).AnalyticKey) + '"'
          end else
            Result := Result + TfrAnalyticLine(FAnalyticLines[I]).eAnalytic.Text;
        end;
      end;
    end;
  end;
end;

procedure TfrFixedAnalytics.SetShowAnalyticName(const Value: Boolean);
begin
  FShowAnalyticName := Value;
end;

end.
