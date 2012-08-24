unit gdv_frameMapOfAnalitic_unit;

interface

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, gsIBLookupComboBox, at_classes, Db, Mask, DBCtrls, ExtCtrls;

type
  TframeMapOfAnaliticLine = class(TFrame)
    lAnaliticName: TLabel;
    cbAnalitic: TgsIBLookupComboBox;
    eAnalitic: TEdit;
    cbInputParam: TCheckBox;
    Bevel1: TBevel;
    procedure eAnaliticChange(Sender: TObject);
  private
    FField: TatRelationField;
    procedure SetField(const Value: TatRelationField);
  protected
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
    { Private declarations }
  public
    { Public declarations }
    property Field: TatRelationField read FField write SetField;
  end;

implementation

{$R *.DFM}

{ TframeMapOfAnaliticLine }

procedure TframeMapOfAnaliticLine.AlignControls(AControl: TControl;
  var Rect: TRect);
begin
  inherited;
  cbAnalitic.Width := Width - {2 -} cbAnalitic.Left;
  eAnalitic.Width := Width - {2 -} eAnalitic.Left;
end;

procedure TframeMapOfAnaliticLine.SetField(const Value: TatRelationField);
begin
  FField := Value;
  if FField <> nil then
  begin
    lAnaliticName.Caption := FField.LName + ':';
    if FField.References <> nil then
    begin
      cbAnalitic.ListTable := FField.References.RelationName;
      cbAnalitic.ListField := FField.Field.RefListFieldName;
      cbAnalitic.KeyField := FField.ReferencesField.FieldName;
      cbAnalitic.Visible := True;

      cbAnalitic.Condition := 'EXISTS (SELECT * FROM ac_entry e WHERE e.' +
        Value.FieldName + ' = ' +
        Value.Field.RefTable.RelationName + '.' +
        Value.Field.RefTable.PrimaryKey.ConstraintFields[0].FieldName + ')';
    end else
      eAnalitic.Visible := True;
  end;
end;

procedure TframeMapOfAnaliticLine.eAnaliticChange(Sender: TObject);
begin
  cbInputParam.Checked := False
end;

end.
