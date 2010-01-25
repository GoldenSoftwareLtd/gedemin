unit mmDBListView;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, DB;

type
  TmmDBListView = class(TListView)
  private
    FDataFieldName, FDataFieldImage, FDataFieldKey, FDataFieldParent: String;
    FDataSource: TDataSource;

    procedure SetDataSource(const Value: TDataSource);

  protected
  public
    ParentKey: Integer;
    constructor Create(AnOwner: TComponent); override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;

    procedure Loaded; override;
    procedure ShowIcon;
    procedure Enter;
    procedure Up;
    procedure MainGroup;
  published
    property DataSource: TDataSource read FDataSource write SetDataSource;
    property DataFieldName: String read FDataFieldName write FDataFieldName;
    property DataFieldImage: String read FDataFieldImage write FDataFieldImage;
    property DataFieldType: String read FDataFieldKey write FDataFieldKey;
    property DataFieldParent: String read FDataFieldParent write FDataFieldParent;
  end;

implementation

constructor TmmDBListView.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  Ctl3D := False;
  Color := $00E7F3F7;
  ParentKey := 0;
end;

procedure TmmDBListView.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and
    (AComponent = DataSource) then DataSource := nil;
end;

procedure TmmDBListView.Loaded;
begin
  inherited;
  if (Owner is TForm) and (ComponentState * [csDesigning] = []) then
    ShowIcon;
end;

procedure TmmDBListView.Enter;
begin
  if Selected <> nil then
  begin
    ParentKey := Integer(Selected.Data);
    ShowIcon;
  end;
end;

procedure TmmDBListView.Up;
begin
  if ParentKey <> 0 then
  begin
    FDataSource.DataSet.First;
    while not FDataSource.DataSet.Eof do
    begin
      if FDataSource.DataSet.FieldByName(FDataFieldKey).AsInteger = ParentKey then
      begin
        ParentKey := FDataSource.DataSet.FieldByName(FDataFieldParent).AsInteger;
        ShowIcon;
        exit;
      end;
      FDataSource.DataSet.Next;
    end;
  end;
end;

procedure TmmDBListView.MainGroup;
begin
  ParentKey := 0;
  ShowIcon;
end;

procedure TmmDBListView.ShowIcon;
var
  ListItem: TListItem;
  FName, FImage, FKey, FParent: TField;
begin
  if (FDataSource <> nil) and (FDataSource.DataSet <> nil) then
  begin
    FName := FDataSource.DataSet.FindField(FDataFieldName);
    FImage := FDataSource.DataSet.FindField(FDataFieldImage);
    FKey := FDataSource.DataSet.FindField(FDataFieldKey);
    FParent := FDataSource.DataSet.FindField(FDataFieldParent);
    if (FName <> nil) and (FImage <> nil) and (FKey <> nil) and
      (FParent <> nil) then
    begin
      Items.Clear;
      FDataSource.DataSet.First;
      while not FDataSource.DataSet.Eof do
      begin
        if FParent.AsInteger = ParentKey then
        begin
          ListItem := Items.Add;
          Listitem.Caption := FName.AsString;
          ListItem.ImageIndex := FImage.AsInteger;
          ListItem.Data := Pointer(FKey.AsInteger);
        end;
        FDataSource.DataSet.Next;
      end;
    end;
  end;
  Show;
end;

procedure TmmDBListView.SetDataSource(const Value: TDataSource);
begin
  FDataSource := Value;
  if Value <> nil then Value.FreeNotification(Self);
end;

end.
