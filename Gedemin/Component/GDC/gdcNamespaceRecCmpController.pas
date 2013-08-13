
unit gdcNamespaceRecCmpController;

interface

uses
  Classes, Grids, gdcBase, yaml_parser;

type
  TgdcNamespaceRecCmpController = class(TObject)
  private
    FInequalFields: TStringList;
    FOverwriteFields: TStringList;
    FObj: TgdcBase;
    FMapping: TYAMLMapping;
    FDisplayFields: TStringList;

  public
    constructor Create;
    destructor Destroy; override;

    function Compare(AnOwner: TComponent; AnObj: TgdcBase; AMapping: TYAMLMapping): Boolean;
    procedure FillGrid(AGrid: TStringGrid; const AShowEqual: Boolean);

    property InequalFields: TStringList read FInequalFields;
    property OverwriteFields: TStringList read FOverwriteFields;
    property DisplayFields: TStringList read FDisplayFields;
  end;

implementation

uses
  Forms, Controls, at_dlgCompareNSRecords_unit;

{ TgdcNamespaceRecCmpController }

function TgdcNamespaceRecCmpController.Compare(AnOwner: TComponent; AnObj: TgdcBase;
  AMapping: TYAMLMapping): Boolean;
const
  IgnoreFields = ';ID;EDITIONDATE;CREATIONDATE;CREATORKEY;EDITORKEY;ACHAG;AVIEW;AFULL;LB;RB;RESERVED;';
var
  I: Integer;
begin
  Assert(AnObj <> nil);
  Assert(AMapping <> nil);

  FObj := AnObj;
  FMapping := AMapping;

  FOverwriteFields.Clear;
  FInequalFields.Clear;
  FDisplayFields.Clear;

  for I := 0 to FObj.FieldCount - 1 do
    if FObj.Fields[I].CanModify and (not FObj.Fields[I].Calculated)
      and (Pos('RDB$', FObj.Fields[I].FieldName) <> 1)
      and (Pos(';' + FObj.Fields[I].FieldName + ';', IgnoreFields) = 0)
      and (FMapping.FindByName('Fields\' + FObj.Fields[I].FieldName) <> nil) then
    begin
      FDisplayFields.Add(FObj.Fields[I].FieldName);

      if FMapping.ReadString('Fields\' + FObj.Fields[I].FieldName) <> FObj.Fields[I].AsString then
        FInequalFields.Add(FObj.Fields[I].FieldName);
    end;

  with TdlgCompareNSRecords.Create(AnOwner) do
  try
    FgdcNamespaceRecCmpController := Self;
    FillGrid(sgMain, not chbxShowOnlyDiff.Checked);
    Result := ShowModal = mrOk;
  finally
    Free;
  end;
end;

constructor TgdcNamespaceRecCmpController.Create;
begin
  FInequalFields := TStringList.Create;
  FInequalFields.Sorted := True;
  FInequalFields.Duplicates := dupError;

  FOverwriteFields := TStringList.Create;
  FOverwriteFields.Sorted := True;
  FOverwriteFields.Duplicates := dupError;

  FDisplayFields := TStringList.Create;
  FDisplayFields.Sorted := True;
  FDisplayFields.Duplicates := dupError;
end;

destructor TgdcNamespaceRecCmpController.Destroy;
begin
  FInequalFields.Free;
  FOverwriteFields.Free;
  FDisplayFields.Free;
  inherited;
end;

procedure TgdcNamespaceRecCmpController.FillGrid(AGrid: TStringGrid;
  const AShowEqual: Boolean);
var
  I: Integer;
begin
  Assert(FObj <> nil);
  Assert(FMapping <> nil);

  if AShowEqual then
  begin
    AGrid.RowCount := FDisplayFields.Count + 1;

    for I := 0 to FDisplayFields.Count - 1 do
    begin
      AGrid.Cells[0, I + 1] := FDisplayFields[I];
      AGrid.Cells[1, I + 1] := FObj.FieldByName(FDisplayFields[I]).AsString;
      AGrid.Cells[2, I + 1] := FMapping.ReadString('Fields\' + FDisplayFields[I]);
    end;
  end else
  begin
    AGrid.RowCount := FInequalFields.Count + 1;

    for I := 0 to FInequalFields.Count - 1 do
    begin
      AGrid.Cells[0, I + 1] := FInequalFields[I];
      AGrid.Cells[1, I + 1] := FObj.FieldByName(FInequalFields[I]).AsString;
      AGrid.Cells[2, I + 1] := FMapping.ReadString('Fields\' + FInequalFields[I]);
    end;
  end;

  AGrid.Cells[0, 0] := 'Имя поля';
  AGrid.Cells[1, 0] := 'В базе данных';
  AGrid.Cells[2, 0] := 'В файле';
end;

end.