unit rpl_frameFormView_unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, xpDBComboBox, DB, Contnrs, DBCtrls;

type
  TframeFormView = class(TFrame)
    ScrollBox: TScrollBox;
  private
    FDataSource: TDataSource;
    FLines: TObjectList;
    FDataLink: TFieldDataLink;
    FRelationName: string;
    procedure SetDataSource(const Value: TDataSource);
    procedure ActiveChange(Source: TObject);
    procedure UpdateState;
    procedure SetRelationName(const Value: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property DataSource: TDataSource read FDataSource write SetDataSource;
    property RelationName: string read FRelationName write SetRelationName;
  end;

implementation
uses rpl_frameFormViewLine_unit, Math;
{$R *.dfm}

{ TframeFormView }

constructor TframeFormView.Create(AOwner: TComponent);
begin
  inherited;
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnActiveChange := ActiveChange;
end;

destructor TframeFormView.Destroy;
begin
  FLines.Free;
  FDataLink.Free;
  
  inherited;
end;

procedure TframeFormView.ActiveChange(Source: TObject);
begin
  UpdateState
end;

procedure TframeFormView.SetDataSource(const Value: TDataSource);
begin
  if FDataSource  <> Value then
  begin
    FDataSource := Value;

    FDataLink.DataSource := Value;
  end;
end;

procedure TframeFormView.UpdateState;
var
  I: Integer;
  L: TframeFormViewLine;
  W: Integer;
  T: Integer;
begin
  if FLines = nil then
    FLines := TObjectList.Create;

  with DataSource do
  begin
    case State of
      dsInactive:
        FLines.Clear;
      dsBrowse:
      begin
        Flines.Clear;
        W := 0;
        if DataSet <> nil then
        begin
          for I := 0 to DataSet.FieldCount - 1 do
          begin
            L := TframeFormViewLine.Create(ScrollBox);
            L.Name := '';
            FLines.Add(L);
            L.RelationName := FRelationName;
            L.DataSource := DataSource;
            L.Field := DataSet.Fields[I];
            W := Max(W, L.lFieldName.Width);
          end;

          T := 0;
          for I := 0 to FLines.Count - 1 do
          begin
            L := TframeFormViewLine(FLines[I]);
            L.LabelWidth := W;
            L.Parent := ScrollBox;
            L.Top := T;
            Inc(T, L.Height);
          end;
        end;
      end;
    end;
  end;
end;

procedure TframeFormView.SetRelationName(const Value: string);
begin
  FRelationName := Value;
end;

end.
