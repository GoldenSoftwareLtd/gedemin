
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
    FCancelLoad: Boolean;

  public
    constructor Create;
    destructor Destroy; override;

    function Compare(AnOwner: TComponent; AnObj: TgdcBase; AMapping: TYAMLMapping): Boolean;
    procedure FillGrid(AGrid: TStringGrid; const AShowEqual: Boolean);
    function OverwriteField(const AFieldName: String): Boolean;
    procedure EditObject;
    procedure ViewObjectProperties;

    property InequalFields: TStringList read FInequalFields;
    property OverwriteFields: TStringList read FOverwriteFields;
    property DisplayFields: TStringList read FDisplayFields;
    property CancelLoad: Boolean read FCancelLoad write FCancelLoad;
  end;

implementation

uses
  SysUtils, Forms, Controls, DB, gdcBaseInterface, gdcNamespace,
  at_dlgCompareNSRecords_unit;

{ TgdcNamespaceRecCmpController }

function TgdcNamespaceRecCmpController.Compare(AnOwner: TComponent; AnObj: TgdcBase;
  AMapping: TYAMLMapping): Boolean;
var
  I: Integer;
  FN, RUIDString, ObjName: String;
  S: TYAMLScalar;
begin
  Assert(AnObj <> nil);
  Assert(AMapping <> nil);

  FObj := AnObj;
  FMapping := AMapping;

  FOverwriteFields.Clear;
  FInequalFields.Clear;
  FDisplayFields.Clear;

  for I := 0 to FObj.FieldCount - 1 do
  begin
    FN := FObj.Fields[I].FieldName;

    if FObj.Fields[I].CanModify
      and (not FObj.Fields[I].Calculated)
      and (not TgdcNamespace.SkipField(FN))
      and (FMapping.FindByName('Fields\' + FN) is TYAMLScalar) then
    begin
      FDisplayFields.Add(FN);

      S := FMapping.FindByName('Fields\' + FN) as TYAMLScalar;

      if FObj.Fields[I].IsNull and (not S.IsNull) then
        FInequalFields.Add(FN)
      else if (not FObj.Fields[I].IsNull) and S.IsNull then
        FInequalFields.Add(FN)
      else if (FObj.Fields[I] is TIntegerField)
        and ParseReferenceString(S.AsString, RUIDString, ObjName) then
      begin
        if gdcBaseManager.GetIDByRUIDString(RUIDString) <> FObj.Fields[I].AsInteger then
          FInequalFields.Add(FN);
      end
      else if (FObj.Fields[I] is TBLOBField) then
      begin
        if S.AsString <> FObj.Fields[I].AsString then
          FInequalFields.Add(FN);
      end else
      begin
        if S.AsVariant <> FObj.Fields[I].Value then
          FInequalFields.Add(FN);
      end;
    end;
  end;

  FCancelLoad := False;

  if FInequalFields.Count = 0 then
    Result := False
  else if (FInequalFields.Count = 1) and (AnsiCompareText(FInequalFields[0], 'EDITIONDATE') = 0) then
  begin
    if FMapping.ReadDateTime('Fields\EDITIONDATE', 0) > FObj.FieldByName('EDITIONDATE').AsDateTime then
      FOverwriteFields.Text := 'EDITIONDATE';

    Result := True;
  end else
    with TdlgCompareNSRecords.Create(AnOwner) do
    try
      FgdcNamespaceRecCmpController := Self;
      FillGrid(sgMain, not chbxShowOnlyDiff.Checked);
      mObject.Lines.Text := StringReplace(mObject.Lines.Text, '%s',
        AnObj.ObjectName, []);
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

procedure TgdcNamespaceRecCmpController.EditObject;
begin
  Assert(FObj <> nil);
  with FObj.CreateSingularByID(nil, FObj.Database, FObj.Transaction, FObj.ID, FObj.SubType) do
  try
    EditDialog;
  finally
    Free;
  end;
end;

procedure TgdcNamespaceRecCmpController.FillGrid(AGrid: TStringGrid;
  const AShowEqual: Boolean);
var
  I: Integer;
  SL: TStringList;
  RUIDString, ObjName: String;
begin
  Assert(FObj <> nil);
  Assert(FMapping <> nil);

  if AShowEqual then
    SL := FDisplayFields
  else
    SL := FInequalFields;

  AGrid.RowCount := SL.Count + 1;

  for I := 0 to SL.Count - 1 do
  begin
    AGrid.Cells[0, I + 1] := SL[I];

    if (FObj.FieldByName(SL[I]) is TIntegerField)
      and ParseReferenceString(FMapping.ReadString('Fields\' + SL[I]), RUIDString, ObjName) then
    begin
      AGrid.Cells[1, I + 1] := gdcBaseManager.GetRUIDStringByID(FObj.FieldByName(SL[I]).AsInteger);
      AGrid.Cells[2, I + 1] := RUIDString;
    end else
    begin
      if FObj.FieldByName(SL[I]).IsNull then
        AGrid.Cells[1, I + 1] := '<NULL>'
      else
        AGrid.Cells[1, I + 1] := FObj.FieldByName(SL[I]).Value;

      if FMapping.ReadNull('Fields\' + SL[I]) then
        AGrid.Cells[2, I + 1] := '<NULL>'
      else
        AGrid.Cells[2, I + 1] := FMapping.ReadValue('Fields\' + SL[I], '');
    end;
  end;

  AGrid.Cells[0, 0] := '��� ����';
  AGrid.Cells[1, 0] := '� ���� ������';
  AGrid.Cells[2, 0] := '� �����';
end;

procedure TgdcNamespaceRecCmpController.ViewObjectProperties;
begin
  Assert(FObj <> nil);
  with FObj.CreateSingularByID(nil, FObj.Database, FObj.Transaction, FObj.ID, FObj.SubType) do
  try
    EditDialog('TGDC_DLGOBJECTPROPERTIES');
  finally
    Free;
  end;
end;

function TgdcNamespaceRecCmpController.OverwriteField(
  const AFieldName: String): Boolean;
begin
  Result := FOverwriteFields.IndexOf(AFieldName) > -1;
end;

end.