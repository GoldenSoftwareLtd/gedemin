unit gsTransactionComboBox;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DB, dbctrls, IBHeader, IBDatabase, IBSQL, IBCustomDataSet, tr_Type_unit,
  gsTransaction;

type
  TgsTransactionComboBox = class(TComboBox)
  private
    { Private declarations }
    FDataLink: TFieldDataLink;
    FGTransaction: TgsTransaction;
    FIsLocalChange: Boolean;

    FOldTransactionKey: Integer;

    function GetDataSource: TDataSource;
    procedure SetDataSource(const Value: TDataSource);
    function GetFieldName: String;
    procedure SetFieldName(const Value: String);
    procedure CMEnter(var Message: TMessage);
      message CM_ENTER;
    procedure WMKeyDown(var Message: TWMKeyDown);
      message WM_KEYDOWN;
    procedure DataChange(Sender: TObject);

  protected
    procedure Notification(aComponent: TComponent; Operation: TOperation);
      override;
    procedure DoExit; override;

  public
    { Public declarations }
    constructor Create(aOwner: TComponent);
      override;
    procedure Loaded;
      override;
    destructor Destroy;
      override;
    procedure SetByTransactionKey(const aTransactionKey: Integer);  

  published
    { Published declarations }

    property GTransaction: TgsTransaction read FGTransaction write FGTransaction;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property DataField: String read GetFieldName write SetFieldName;

  end;

procedure Register;

implementation

{ TgsTransactionComboBox }

procedure TgsTransactionComboBox.CMEnter(var Message: TMessage);
var
  NameTransaction: String;
begin
  {
    TODO 1 -oденис -cнедочет :
    Вместо перехвата сообщения лучьше использовать
    dynamic метод DoEnter.

    Если же используется сообщение, то следует оставлять inherited - иначе
    сообщение дальше не проходит.

    Ну если же Вам нужно сделать все раньше всех других методов и не дать им об этом
    знать - тогда не знаю, может так и правильно...
  }

  if (csDesigning in ComponentState) then exit;

  if Assigned(FGTransaction) then
  begin
    NameTransaction := Text;

    FGTransaction.GetTransaction(Items);

    if NameTransaction > '' then
      ItemIndex := Items.IndexOf(NameTransaction);

    if Assigned(DataSource) and Assigned(DataSource.DataSet) then
    begin
      if not (DataSource.DataSet.State in [dsEdit, dsInsert]) then
        DataSource.DataSet.Edit;

    end;

  end;
end;

constructor TgsTransactionComboBox.Create(aOwner: TComponent);
begin
  inherited;

  FDataLink := TFieldDataLink.Create;
  FDataLink.OnDataChange := DataChange;
  FGTransaction := nil;
  FOldTransactionKey := -1;
  FIsLocalChange := False;

end;

procedure TgsTransactionComboBox.DataChange(Sender: TObject);
var
  T: TTransaction;
begin
  { DONE 1 -oденис -cнедочет : Вместо такой длинной проверки можно просто проверять DataLink.Active }
  if Assigned(FDataLink) and FDataLink.Active and (DataField > '') and
     Assigned(FGTransaction) and not FIsLocalChange and not Focused
  then
  begin
    FIsLocalChange := True;
    if (FOldTransactionKey <> DataSource.DataSet.FieldByName(DataField).AsInteger) or
       ((ItemIndex = -1) and (FOldTransactionKey > 0))
    then
    begin

      FOldTransactionKey := DataSource.DataSet.FieldByName(DataField).AsInteger;

      if DataSource.DataSet.FieldByName(DataField).IsNull then
        ItemIndex := -1
      else
      begin
        Items.Clear;
        T := FGTransaction.GetTransaction(nil);
        if Assigned(T) then
        begin
          Items.AddObject(T.TransactionName, T);
          ItemIndex := 0;
        end
        else
          ItemIndex := -1;
      end;

    end;
    FIsLocalChange := False;
  end;
end;

destructor TgsTransactionComboBox.Destroy;
begin
  if Assigned(FDataLink) then
    FreeAndNil(FDataLink);

  inherited;
end;

procedure TgsTransactionComboBox.DoExit;
begin
  { TODO 1 -oденис -cпросто : В дизайн реджиме такого не будет... }
  if csDesigning in ComponentState then
    exit;

  { DONE 1 -oденис -cнедочет : Вместо такой длинной проверки можно просто проверять DataLink.Active }
  if Assigned(FDataLink) and FDataLink.Active then
  begin
    FIsLocalChange := True;

    if not (DataSource.DataSet.State in [dsEdit, dsInsert]) then
      DataSource.DataSet.Edit;

    if ItemIndex >= 0 then
      DataSource.DataSet.FieldByName(DataField).AsInteger :=
        TTransaction(Items.Objects[ItemIndex]).TransactionKey
    else
      DataSource.DataSet.FieldByName(DataField).Clear;

    FOldTransactionKey := DataSource.DataSet.FieldByName(DataField).AsInteger;

    FIsLocalChange := False;
  end;

  inherited;
end;

function TgsTransactionComboBox.GetDataSource: TDataSource;
begin
  if Assigned(FDataLink) then
    Result := FDataLink.DataSource
  else
    Result := nil;
end;

function TgsTransactionComboBox.GetFieldName: String;
begin
  if Assigned(FDataLink) then
    Result := FDataLink.FieldName
  else
    Result := '';  
end;

procedure TgsTransactionComboBox.Loaded;
begin
  inherited;

  Hint := 'Используйте клавиши: '#13#10 +
          '     F4 - просмотр и редактирование проводок.';
  ShowHint := True;

end;

procedure TgsTransactionComboBox.Notification(aComponent: TComponent;
  Operation: TOperation);
begin
  inherited;

  if Operation = opRemove then
  begin
    if Assigned(FDataLink) and (aComponent = FDataLink.DataSource) then
      FDataLink.DataSource := nil
    else if aComponent = FGTransaction then
      FGTransaction := nil;
  end;
end;

procedure TgsTransactionComboBox.SetByTransactionKey(
  const aTransactionKey: Integer);
begin
{}
end;

procedure TgsTransactionComboBox.SetDataSource(const Value: TDataSource);
begin
  if Assigned(FDataLink) then
    FDataLink.DataSource := Value;
end;

procedure TgsTransactionComboBox.SetFieldName(const Value: String);
begin
  if Assigned(FDataLink) then
    FDataLink.FieldName := Value;
end;

procedure TgsTransactionComboBox.WMKeyDown(var Message: TWMKey);
begin
  if Message.CharCode = VK_F4 then
  begin
  { DONE 1 -oденис -cнедочет : Вместо такой длинной проверки можно просто проверять DataLink.Active }
    if Assigned(FGTransaction) and Assigned(FDataLink) and FDataLink.Active
    then
    begin
      if (ItemIndex >= 0) then
      begin
        if DataSource.DataSet.FieldByName(DataField).AsInteger <>
            TTransaction(Items.Objects[ItemIndex]).TransactionKey
        then
        begin
          if not (DataSource.DataSet.State in [dsEdit, dsInsert]) then
            DataSource.DataSet.Edit;
          DataSource.DataSet.FieldByName(DataField).AsInteger :=
            TTransaction(Items.Objects[ItemIndex]).TransactionKey;
        end;

        FGTransaction.CreateTransactionOnPosition(
          FGTransaction.CurrencyKey, FGTransaction.TransactionDate,
          nil, nil);
{        if DataSource.DataSet.State in [dsEdit, dsInsert] then
          DataSource.DataSet.Post;}  
      end;
    end;
  end
  else
    if (Message.CharCode = VK_DELETE) and (ItemIndex <> -1) then
    begin
      ItemIndex := -1;
      if not (DataSource.DataSet.State in [dsEdit, dsInsert]) then
        DataSource.DataSet.Edit;
      DataSource.DataSet.FieldByName(DataField).Clear;
    end
    else
      inherited;
end;



procedure Register;
begin
  RegisterComponents('gsNew', [TgsTransactionComboBox]);
end;



end.
