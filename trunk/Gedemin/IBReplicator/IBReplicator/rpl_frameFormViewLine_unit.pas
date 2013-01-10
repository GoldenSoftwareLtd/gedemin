unit rpl_frameFormViewLine_unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, XPCheckBox, StdCtrls, rpl_BaseTypes_unit, rpl_ReplicationManager_unit,
  rpl_ResourceString_unit, xpDBComboBox, rpl_const, DBCtrls;

type
  TframeFormViewLine = class(TFrame)
    lFieldName: TLabel;
    cbNull: TXPCheckBox;
    procedure cbNullClick(Sender: TObject);
  private
    FField: TField;
    FControl: TxpDBComboBox;
    FDataSource: TDataSource;
    FLabelWidth: Integer;
    FDataLink: TFieldDataLink;
    FRelationName: string;

    procedure SetField(const Value: TField);
    procedure SetDataSource(const Value: TDataSource);
    procedure SetLabelWidth(const Value: Integer);
    procedure SetRelationName(const Value: string);
  protected
    procedure CreateControl;
    procedure OnComboChange(Sender: Tobject);
    procedure DataChange(Sender: TObject);
  public
    constructor Create(AOwner: Tcomponent); override;
    destructor Destroy; override;
    property DataSource: TDataSource read FDataSource write SetDataSource;
    property Field: TField read FField write SetField;
    property LabelWidth: Integer read FLabelWidth write SetLabelWidth;
    property RelationName: string read FRelationName write SetRelationName;
  end;

var
  frameFormViewLine: TframeFormViewLine;

implementation
{$R *.dfm}


{ TframeFormViewLine }

procedure TframeFormViewLine.SetField(const Value: TField);
begin
  FField := Value;
  if FField <> nil then
  begin
    lFieldName.Caption := FField.DisplayLabel;
    FDataLink.FieldName := FField.FieldName;

    cbNull.Checked := FField.IsNull;
    CreateControl;
  end else
  begin
    FDataLink.FieldName := '';
    if FControl <> nil then
      FreeAndNil(FControl);
  end;

end;

procedure TframeFormViewLine.cbNullClick(Sender: TObject);
var
  DataLink: TFieldDataLink;
  I: Integer;
begin
  if FField <> nil then
  begin
    if cbNull.Checked then
    begin
      if FControl <> nil then
      begin
        I := SendMessage(FControl.Handle, CM_GETDATALINK, 0, 0);
        DataLink := TFieldDataLink(I);
        DataLink.Edit;
        DataLink.Field.Clear;
      end;
    end;
  end;
end;

procedure TframeFormViewLine.CreateControl;
var
  TableName, FieldName: string;
  R: TrpRelation;
  F: TrpField;
  Index: Integer;
begin
  if FControl <> nil then
    FreeAndNil(FControl);

  if FField <> nil then
  begin
    TableName := FRelationName;
    FieldName := FField.FieldName; 
//    OriginNames(FField.Origin, TableName, FieldName);
    R := ReplicationManager.Relations.FindRelation(TableName);
    if R <> nil then
    begin
      Index := R.Fields.IndexOfField(FieldName);
      if Index > - 1 then
      begin
        F := R.Fields[Index];
        if F.IsForeign then
        begin
          FControl := TxpFKLookupComboBox.Create(Self);
          with FControl as TxpFKLookupComboBox do
          begin
            ListTable := F.ReferenceField.Relation.RelationName;
            KeyField := F.ReferenceField.FieldName;
            Transaction := ReplDataBase.Transaction;
            FControl.Width := 263;
          end;
        end else
        begin
          case F.FieldType of
            tfInteger, tfInt64, tfSmallInt, tfQuard, tfD_Float,
            tfDouble, tfFloat:
            begin
              FControl := TxpCalcDBComboBox.Create(Self);
              FControl.Width := 263;
            end;
            tfChar, tfCString, tfVarChar:
            begin
              FControl := TxpMemoDbComboBox.Create(Self);
              FControl.Width := 300;
            end;
            tfDate:
            begin
              FControl := TxpDateTimeDbComboBox.Create(Self);
              FControl.Width := 190;
            end;
            tfTime:
            begin
              FControl := TxpDateTimeDbComboBox.Create(Self);
              FControl.Width := 190;
            end;
            tfTimeStamp:
            begin
              FControl := TxpDateTimeDbComboBox.Create(Self);
              FControl.Width := 190;
            end;
            tfBlob:
            begin
              if F.FieldSubType = 1 then
                FControl := TxpMemoDbComboBox.Create(self)
              else
                FControl := TxpBlobDbComboBox.Create(Self);
              FControl.Width := 300;  
            end;
          end;
        end;
      end else
        raise Exception.Create(InvalidFieldName);
    end else
      raise Exception.Create(Format(InvalidRelationName, [TableName]));

    if FControl <> nil then
    begin
      FControl.OnChange := OnComboChange;

      FControl.Parent := Self;
      FControl.DataField := FieldName;
      Fcontrol.DataSource := FDataSource;

      FControl.Top := 1;
      FControl.Left := cbNull.Left + cbNull.Width + 3;

//      FControl.Anchors := FControl.Anchors + [akRight];
    end;
  end;
end;

procedure TframeFormViewLine.SetDataSource(const Value: TDataSource);
begin
  FDataSource := Value;
  FDataLink.DataSource := Value;
end;

procedure TframeFormViewLine.SetLabelWidth(const Value: Integer);
begin
  FLabelWidth := Value;
  cbNull.Left := Value + 50;

  if FControl <> nil then
  begin
    FControl.Left := cbNull.Left + cbNull.Width + 3;
//    FControl.Width := Width - FControl.Left - 3;
  end;
end;

procedure TframeFormViewLine.OnComboChange(Sender: Tobject);
var
  DataLink: TFieldDataLink;
  I: Integer;
begin
  if FField <> nil then
  begin
    if FControl <> nil then
    begin
      I := SendMessage(FControl.Handle, CM_GETDATALINK, 0, 0);
      DataLink := TFieldDataLink(I);
      cbNull.Checked := DataLink.Field.IsNull;
    end;
  end;
end;

constructor TframeFormViewLine.Create(AOwner: Tcomponent);
begin
  inherited;
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
end;

destructor TframeFormViewLine.Destroy;
begin
  FDataLink.Free;

  inherited;
end;

procedure TframeFormViewLine.DataChange(Sender: TObject);
begin
  if FDataLink.Field <> nil then
    cbNull.Checked := FDataLink.Field.IsNull;
end;

procedure TframeFormViewLine.SetRelationName(const Value: string);
begin
  FRelationName := Value;
end;

end.
