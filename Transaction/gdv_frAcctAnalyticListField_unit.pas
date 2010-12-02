unit gdv_frAcctAnalyticListField_unit;

interface

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, at_classes;

type
  Tgdv_frAcctAnalyticListField = class(TFrame)
    lAnaliticName: TLabel;
    cbListFieldName: TComboBox;
  private
    FAnalyticField: TatRelationField;

    procedure FillListFieldList;

    procedure SetAnalyticField(const Value: TatRelationField);
    function GetListField: String;
    procedure SetListField(const Value: String);
  public
    function IsEmpty: Boolean;

    property AnalyticField: TatRelationField read FAnalyticField write SetAnalyticField;
    property ListField: String read GetListField write SetListField;
  end;

implementation

{$R *.DFM}

{ Tgdv_frAcctAnalyticListField }

procedure Tgdv_frAcctAnalyticListField.FillListFieldList;
const
  PassFieldName = ';EDITIONDATE;CREATIONDATE;CREATORKEY;EDITORKEY;ACHAG;AVIEW;AFULL;LB;RB;';
var
  RefTable: TatRelation;
  FieldCounter: Integer;
  FieldName: String;
begin
  // ������� ���������� ������
  cbListFieldName.Clear;
  // ������� ������ ������� ������
  cbListFieldName.Items.Add('');

  // ��������� � �������, �� ������� ��������� ���������� ����,
  //  ������� ��� ����������� ��� ����
  RefTable := FAnalyticField.References;
  if Assigned(RefTable) then
  begin
    for FieldCounter := 0 to RefTable.RelationFields.Count - 1 do
    begin
      // ��� �� ����� ����-������
      if Assigned(RefTable.RelationFields[FieldCounter].References) then
        Continue;
      // �� ����� ���� ������, ����, ���� ��������������
      if AnsiPos(';' + AnsiUpperCase(Trim(RefTable.RelationFields[FieldCounter].FieldName)) + ';', PassFieldName) <> 0 then
        Continue;
      // �� ����� ����������� ��������� ���� ID
      if AnsiCompareText(RefTable.RelationFields[FieldCounter].FieldName, 'ID') = 0 then
        Continue;

      if RefTable.RelationFields[FieldCounter].LName <> '' then
        FieldName := RefTable.RelationFields[FieldCounter].LName
      else
        FieldName := RefTable.RelationFields[FieldCounter].FieldName;

      cbListFieldName.Items.AddObject(FieldName, RefTable.RelationFields[FieldCounter]);
    end;
  end;
end;

procedure Tgdv_frAcctAnalyticListField.SetAnalyticField(const Value: TatRelationField);
begin
  FAnalyticField := Value;
  // ������� ��� ���� � �����
  if FAnalyticField.LName <> '' then
    lAnaliticName.Caption := FAnalyticField.LName
  else
    lAnaliticName.Caption := FAnalyticField.FieldName;
  // �������� ���������� ������ ������ �����������
  FillListFieldList;
end;

function Tgdv_frAcctAnalyticListField.GetListField: String;
begin
  // ���� � ������ ���-������ �������, � ��� �� ������ �������
  if (cbListFieldName.ItemIndex > -1) and Assigned(cbListFieldName.Items.Objects[cbListFieldName.ItemIndex]) then
    Result := TatRelationField(cbListFieldName.Items.Objects[cbListFieldName.ItemIndex]).FieldName
  else
    Result := '';
end;

procedure Tgdv_frAcctAnalyticListField.SetListField(const Value: String);
var
  Index: Integer;
  FieldCounter: Integer;
begin
  Index := -1;
  for FieldCounter := 0 to cbListFieldName.Items.Count - 1 do
  begin
    if Assigned(cbListFieldName.Items.Objects[FieldCounter]) and
       (AnsiCompareText(TatRelationField(cbListFieldName.Items.Objects[FieldCounter]).FieldName, Value) = 0) then
    begin
      Index := FieldCounter;
      Break;
    end;
  end;

  cbListFieldName.ItemIndex := Index;
end;

function Tgdv_frAcctAnalyticListField.IsEmpty: Boolean;
begin
  Result := not (cbListFieldName.ItemIndex > -1);
end;

end.
