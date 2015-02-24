
{++
   Component
   Copyright © 2000-2011 by Golden Software of Belarus

   Модуль

     gd_AttrComboBox

   Описание

     TgsDBComboBoxAttr  для работы с атрибутом элемент множества
     TgsComboBoxAttr    для работы с элементом множества (атрибутом)
     TgsComboBoxAttrSet для работы с множеством (атрибутом)

   Автор

     Andrey

   История

     ver    date    who    what
     1.00 - 16.06.2000 - JKL - Первая версия
     1.01 - 30.06.2000 - JKL - TgsComboBoxAttr
     1.02 - 08.07.2000 - JKL - TgsComboBoxAttrSet
     1.03 - 03.11.2001 - JKL - Condition for TgsComboBoxAttrSet has been added.

 --}

unit gd_AttrComboBox;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DB, IBSQL, DBCtrls, IBQuery, IBDatabase, ComCtrls,
  frmSelectSet_unit, IBCustomDataSet;

type
  TgsComboBoxSortOrder = (soNone, soAsc, soDesc);

const
  SetSeparator = '; ';
  DefSortOrder = soNone;

// ComboBox для заполнения атрибутов ''Множество'' и ''Элемент множества''
type
  TgsDBComboBoxAttr = class(TCustomComboBox)
  private
    FDataLink: TFieldDataLink;
    FPaintControl: TPaintControl;

    FibsqlList: TIBSQL;
    FAttrKey: Integer;
    FFullQry: Boolean;
    FValueID: Integer;
    FDropDowning: Boolean;
    FDialogType: Integer;

    function GetDataField: string;
    function GetDataSource: TDataSource;
    procedure SetDataField(const Value: string);
    procedure SetDataSource(Value: TDataSource);

    procedure CompileQry;

    procedure DataChange(Sender: TObject);
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
    procedure SetAttrKey(Value: Integer);
  protected
    procedure Loaded; override;
    procedure DropDown; override;
    procedure Change; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    property AttrKey: Integer read FAttrKey write SetAttrKey;
    property ValueID: Integer read FValueID;
    property DialogType: Integer read FDialogType write FDialogType;
  published
    property DataField: string read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
  end;

type
  TgsComboBoxAttr = class(TCustomComboBox)
  private
    FBase: TIBBase;
    FPaintControl: TPaintControl;

    FibsqlList: TIBSQL;
    FAttrKey: Integer;
    FFullQry: Boolean;
    FValueID: Integer;
    FDropDowning: Boolean;
    FDialogType: Integer;

    FUserAttr: Boolean;
    FTableName: String;
    FFieldName: String;
    FPrimaryName: String;

    function GetDatabase: TIBDatabase;
    function GetTransaction: TIBTransaction;
    procedure SetDatabase(Value: TIBDatabase);
    procedure SetTransaction(Value: TIBTransaction);

    procedure CompileQry;

    procedure DataChange(Sender: TObject);
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
    procedure SetAttrKey(Value: Integer);
    procedure SetValueID(Value: Integer);
  protected
    procedure Loaded; override;
    procedure DropDown; override;
    procedure Change; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    property UserAttr: Boolean read FUserAttr write FUserAttr;

    property AttrKey: Integer read FAttrKey write SetAttrKey;
    property ValueID: Integer read FValueID write SetValueID;
    property Text;
  published
    property TableName: String read FTableName write FTableName;
    property FieldName: String read FFieldName write FFieldName;
    property PrimaryName: String read FPrimaryName write FPrimaryName;
    property DialogType: Integer read FDialogType write FDialogType;

    property Database: TIBDatabase read GetDatabase write SetDatabase;
    property Transaction: TIBTransaction read GetTransaction
                                          write SetTransaction;
    property ShowHint;
    property OnEnter;
    property OnExit;
  end;

type
  TgsComboBoxAttrSet = class(TComboBox)
  private
    FBase: TIBBase;
    FPaintControl: TPaintControl;

    FibsqlList: TIBSQL;
    FAttrKey: Integer;
    FFullQry: Boolean;
    FDialogType: Boolean;

    FUserAttr: Boolean;
    FValueID: TStrings;
    FDroping: Boolean;

    FTableName: String;
    FFieldName: String;
    FPrimaryName: String;
    FItemList: TfrmSelectSet;
    FCondition: String;
    FSortField: String;
    FSortOrder: TgsComboBoxSortOrder;

    procedure CompileQry;

    function GetDatabase: TIBDatabase;
    function GetTransaction: TIBTransaction;
    procedure SetDatabase(Value: TIBDatabase);
    procedure SetTransaction(Value: TIBTransaction);

    procedure DataChange(Sender: TObject);
    procedure SetAttrKey(Value: Integer);
    procedure SetValueID(Value: TStrings);
    procedure SetSortField(const Value: String);
    procedure SetSortOrder(const Value: TgsComboBoxSortOrder);
  protected
    procedure Loaded; override;
    procedure DropDown; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure ValueIDChange(Sender: TObject);

    property UserAttr: Boolean read FUserAttr write FUserAttr;

    property AttrKey: Integer read FAttrKey write SetAttrKey;
    property ValueID: TStrings read FValueID write SetValueID;
  published
    property TableName: String read FTableName write FTableName;
    property FieldName: String read FFieldName write FFieldName;
    property PrimaryName: String read FPrimaryName write FPrimaryName;
    property DialogType: Boolean read FDialogType write FDialogType;

    property Database: TIBDatabase read GetDatabase write SetDatabase;
    property Transaction: TIBTransaction read GetTransaction
                                          write SetTransaction;
    property Condition: String read FCondition write FCondition;
    property SortField: String read FSortField write SetSortField;
    property SortOrder: TgsComboBoxSortOrder read FSortOrder write SetSortOrder
      default DefSortOrder;
  end;

procedure Register;

implementation

uses
  gd_attrcb_dlgSelectAttr_unit, gd_attrcb_dlgSelectAttrSet_unit, gd_attrcb_dlgSelectF_unit, gd_attrcb_dlgSelectFSet_unit;

{TgsDBComboBoxAttr ------------------------------------------}

constructor TgsDBComboBoxAttr.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FPaintControl := TPaintControl.Create(Self, 'COMBOBOX');
  FDropDowning := False;
  FDialogType := 0;

  if not (csDesigning in ComponentState) then
  begin
    FibsqlList := TIBSQL.Create(Self);
    FFullQry := False;
  end;
end;

destructor TgsDBComboBoxAttr.Destroy;
begin
  if not (csDesigning in ComponentState) then
  begin
    FibsqlList.Free;
  end;

  FPaintControl.Free;
  FDataLink.Free;
  FDataLink := nil;

  inherited Destroy;
end;

procedure TgsDBComboBoxAttr.DataChange(Sender: TObject);
begin
  if DataSource = nil then
    Exit;
  //Assert(DataSource <> nil);
  // Действия по изменению ДатаСорса
  if not FFullQry then
    CompileQry;
  if not FDropDowning then
  begin
    if FDialogType = 0 then
    begin
      FibsqlList.Close;
      FibsqlList.SQL.Text := 'SELECT id, name FROM gd_attrset WHERE id = '
       + IntToStr(DataSource.DataSet.FieldByName(DataField).AsInteger);
      FibsqlList.ExecQuery;
      FValueID := FibsqlList.FieldByName('id').AsInteger;
      Text := FibsqlList.FieldByName('name').AsString;
    end else
    begin
      FValueID := -1;
      Items.Clear;
      FibsqlList.Close;
      FibsqlList.SQL.Text := 'SELECT id, name FROM gd_attrset WHERE attrkey = '
       + IntToStr(FAttrKey);
      FibsqlList.ExecQuery;
      while not FibsqlList.EOF do
      begin
        Items.AddObject(FibsqlList.FieldByName('name').AsString,
         Pointer(FibsqlList.FieldByName('id').AsInteger));
        if FibsqlList.FieldByName('id').AsInteger =
         DataSource.DataSet.FieldByName(DataField).AsInteger then
        begin
          FValueID := FibsqlList.FieldByName('id').AsInteger;
          Text := FibsqlList.FieldByName('name').AsString;
        end;
        FibsqlList.Next;
      end;
      if FValueID = -1 then
        Text := '';
    end;
  end;
end;

procedure TgsDBComboBoxAttr.SetAttrKey(Value: Integer);
begin
  FAttrKey := Value;
  if FDialogType <> 0 then
    DataChange(Self);
end;

procedure TgsDBComboBoxAttr.CMExit(var Message: TCMExit);
var
  DSState: Boolean;
begin
  if DataSource = nil then
    Exit;
  // Действия по выходу из Бокса
  // Предпологалось, что можно очистить поле, однако возникли проблемы.
  try
    if Text = '' then
    begin
      FDropDowning := True;
      DSState := (DataSource.DataSet.State = dsEdit) or (DataSource.DataSet.State = dsInsert);
      if not DSState then
        DataSource.DataSet.Edit;
      FDropDowning := False;
      DataSource.DataSet.FieldByName(DataField).Clear;
      FValueID := -1;
      FDropDowning := True;
      if not DSState then
        DataSource.DataSet.Post;
      FDropDowning := False;
    end else
      DataChange(Self);
  except
    SelectAll;
    SetFocus;
    raise;
  end;
  inherited;
end;

procedure TgsDBComboBoxAttr.CompileQry;
begin
  // Начальные установки
  // Предполагается, что подключается TIBQuery.
  // При желании можно добавить другие или найти способ по другому вытянуть
  if DataSource = nil then
    Exit;
  //Assert(DataSource <> nil);

  FibsqlList.Close;
  if (DataSource.DataSet is TIBQuery) then
  begin
    FibsqlList.Database := (DataSource.DataSet as TIBQuery).Database;
    FibsqlList.Transaction := (DataSource.DataSet as TIBQuery).Transaction;
  end else
    if (DataSource.DataSet is TIBDataSet) then
    begin
    // Если не TIBQuery то что то другое может TIBDataSet
      FibsqlList.Database := (DataSource.DataSet as TIBDataSet).Database;
      FibsqlList.Transaction := (DataSource.DataSet as TIBDataSet).Transaction;
    end;
  FFullQry := True;
end;

procedure TgsDBComboBoxAttr.Loaded;
begin
  inherited Loaded;
  // Впринципе не используется

  {if not (csDesigning in ComponentState) then
  begin
    DataSource.OnStateChange := StateChange;
    DataSource.OnDataChange := DataChange;
  end; }
end;

function TgsDBComboBoxAttr.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TgsDBComboBoxAttr.SetDataSource(Value: TDataSource);
begin
  if not (FDataLink.DataSourceFixed and (csLoading in ComponentState)) then
    FDataLink.DataSource := Value;
  if Value <> nil then Value.FreeNotification(Self);
end;

function TgsDBComboBoxAttr.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

procedure TgsDBComboBoxAttr.SetDataField(const Value: string);
begin
  FDataLink.FieldName := Value;
end;

procedure TgsDBComboBoxAttr.KeyDown(var Key: Word; Shift: TShiftState);
begin
  // Действия по клавишам
  inherited KeyDown(Key, Shift);
  if Key in [VK_UP, VK_DOWN, 13] then
  begin
    DropDown;
  end;
end;

procedure TgsDBComboBoxAttr.DropDown;
var
  S: String;
  I: Integer;
  DSState: Boolean;
begin
  if DataSource = nil then
    Exit;
  if FDialogType = 0 then
  // Действия по поиску
  with TdlgSelectAttr.Create(Self) do
  try
    ibqryFind.Database := FibsqlList.Database;
    ibqryFind.Transaction := FibsqlList.Transaction;
    S := Text;
    // Получаем результат
    I := GetElement(FAttrKey, S);
    if (I <> -1) and (I <> FValueID) then
    begin
      // Присваиваем новое значение
      FDropDowning := True;
      DSState := (DataSource.DataSet.State = dsEdit) or (DataSource.DataSet.State = dsInsert);
      if not DSState then
        DataSource.DataSet.Edit;
      FDropDowning := False;
      DataSource.DataSet.FieldByName(DataField).AsInteger := I;
      FDropDowning := True;
      if not DSState then
        DataSource.DataSet.Post;
    end else
      DataChange(Self);
  finally
    FDropDowning := False;
    Free;
    Self.Repaint;
  end
  else begin
    inherited DropDown;

  end;
end;

procedure TgsDBComboBoxAttr.Change;
var
  DSState: Boolean;
begin
  if DataSource = nil then
    Exit;
  if ItemIndex > -1 then
  begin
    FDropDowning := True;
    DSState := (DataSource.DataSet.State = dsEdit) or (DataSource.DataSet.State = dsInsert);
    if not DSState then
      DataSource.DataSet.Edit;
    DataSource.DataSet.FieldByName(DataField).AsInteger := Integer(Items.Objects[ItemIndex]);
    Text := Items.Strings[ItemIndex];
    FValueID := DataSource.DataSet.FieldByName(DataField).AsInteger;
    if not DSState then
      DataSource.DataSet.Post;
    FDropDowning := False;
  end;
end;

{TgsComboBoxAttr ------------------------------------------}

constructor TgsComboBoxAttr.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FBase := TIBBase.Create(Self);
  FPaintControl := TPaintControl.Create(Self, 'COMBOBOX');
  FDropDowning := False;
  FDialogType := 0;
  FUserAttr := False;

  if not (csDesigning in ComponentState) then
  begin
    FibsqlList := TIBSQL.Create(Self);
    FFullQry := False;
  end;
end;

destructor TgsComboBoxAttr.Destroy;
begin
  if not (csDesigning in ComponentState) then
  begin
    FibsqlList.Free;
  end;

  FPaintControl.Free;
  FBase.Free;

  inherited Destroy;
end;

procedure TgsComboBoxAttr.DataChange(Sender: TObject);
var
  Flag: Boolean;
begin
  if (FBase.Database = nil) or (FBase.Transaction = nil) then
    Exit;
  // Действия по изменению ДатаСорса
  if not FFullQry then
    CompileQry;
  if not FDropDowning then
  begin
    if FUserAttr then
      if FDialogType = 0 then
      begin
        FibsqlList.Close;
        FibsqlList.SQL.Text := 'SELECT id, name FROM gd_attrset WHERE id = '
         + IntToStr(FValueID);
        FibsqlList.ExecQuery;
        FValueID := FibsqlList.FieldByName('id').AsInteger;
        Text := FibsqlList.FieldByName('name').AsString;
      end else
      begin
        Flag := False;
        Items.Clear;
        FibsqlList.Close;
        FibsqlList.SQL.Text := 'SELECT id, name FROM gd_attrset WHERE attrkey = '
         + IntToStr(FAttrKey);
        FibsqlList.ExecQuery;
        while not FibsqlList.EOF do
        begin
          Items.AddObject(FibsqlList.FieldByName('name').AsString,
           Pointer(FibsqlList.FieldByName('id').AsInteger));
          if FibsqlList.FieldByName('id').AsInteger = FValueID then
          begin
            //FValueID := FibsqlList.FieldByName('id').AsInteger;
            Text := FibsqlList.FieldByName('name').AsString;
            Flag := True;
          end;
          FibsqlList.Next;
        end;
        if not Flag then
        begin
          FValueID := -1;
          Text := '';
        end;
      end
    else
      if FDialogType = 0 then
      begin
        FibsqlList.Close;
        FibsqlList.SQL.Text := 'SELECT ' + Trim(FPrimaryName) + ','
         + Trim(FFieldName) + ' FROM ' + FTableName + ' WHERE '
         + FPrimaryName + ' = ' + IntToStr(FValueID);
        FibsqlList.ExecQuery;
        FValueID := FibsqlList.FieldByName(Trim(FPrimaryName)).AsInteger;
        Text := FibsqlList.FieldByName(Trim(FFieldName)).AsString;
      end else
      begin
        Flag := False;
        Items.Clear;
        FibsqlList.Close;
        FibsqlList.SQL.Text := 'SELECT ' + Trim(FPrimaryName) + ','
         + Trim(FFieldName) + ' FROM ' + FTableName;
        FibsqlList.ExecQuery;
        while not FibsqlList.EOF do
        begin
          Items.AddObject(FibsqlList.FieldByName(FFieldName).AsString,
           Pointer(FibsqlList.FieldByName(FPrimaryName).AsInteger));
          if FibsqlList.FieldByName(FPrimaryName).AsInteger = FValueID then
          begin
            //FValueID := FibsqlList.FieldByName('id').AsInteger;
            Text := FibsqlList.FieldByName(FFieldName).AsString;
            Flag := True;
          end;
          FibsqlList.Next;
        end;
        if not Flag then
        begin
          FValueID := -1;
          Text := '';
        end;
      end;
  end;
end;

procedure TgsComboBoxAttr.SetAttrKey(Value: Integer);
begin
  FAttrKey := Value;
  if FDialogType <> 0 then
    DataChange(Self);
end;

procedure TgsComboBoxAttr.SetValueID(Value: Integer);
begin
  if FValueID <> Value then
  begin
    FValueID := Value;
    //if (FDialogType <> 0) or not FUserAttr then
      DataChange(Self);
  end;
end;

procedure TgsComboBoxAttr.CMExit(var Message: TCMExit);
begin
  if (FBase.Database = nil) or (FBase.Transaction = nil) then
    Exit;
  // Действия по выходу из Бокса
  // Предпологалось, что можно очистить поле, однако возникли проблемы.
  try
    if Text = '' then
    begin
      FValueID := -1;
    end else
      DataChange(Self);
  except
    SelectAll;
    SetFocus;
    raise;
  end;
  inherited;
end;

procedure TgsComboBoxAttr.CompileQry;
begin
  if (FBase.Database = nil) or (FBase.Transaction = nil) then
    Exit;
  // Начальные установки
  // Предполагается, что подключается TIBQuery.
  // При желании можно добавить другие или найти способ по другому вытянуть
  FibsqlList.Close;
  FibsqlList.Database := FBase.Database;
  FibsqlList.Transaction := FBase.Transaction;
  FFullQry := True;
end;

procedure TgsComboBoxAttr.Loaded;
begin
  inherited Loaded;
  // Впринципе не используется

  {if not (csDesigning in ComponentState) then
  begin
    DataSource.OnStateChange := StateChange;
    DataSource.OnDataChange := DataChange;
  end; }
  {FBase.CheckDatabase;
  FBase.CheckTransaction;
  DataChange(Self);}
end;

function TgsComboBoxAttr.GetDatabase: TIBDatabase;
begin
  result := FBase.Database;
end;

function TgsComboBoxAttr.GetTransaction: TIBTransaction;
begin
  result := FBase.Transaction;
end;

procedure TgsComboBoxAttr.SetDatabase(Value: TIBDatabase);
begin
  if FBase.Database <> Value then
  begin
    //CheckDatasetClosed;
    FBase.Database := Value;
  end;
end;

procedure TgsComboBoxAttr.SetTransaction(Value: TIBTransaction);
begin
  if (FBase.Transaction <> Value) then
  begin
    //CheckDatasetClosed;
    FBase.Transaction := Value;
  end;
end;

procedure TgsComboBoxAttr.KeyDown(var Key: Word; Shift: TShiftState);
begin
  // Действия по клавишам
  inherited KeyDown(Key, Shift);
  if Key in [VK_UP, VK_DOWN, 13] then
  begin
    DropDown;
  end;
end;

procedure TgsComboBoxAttr.DropDown;
var
  S: String;
  I: Integer;
begin
  if (FBase.Database = nil) or (FBase.Transaction = nil) then
    Exit;
  if FDialogType = 0 then
    if FUserAttr then
    // Действия по поиску
      with TdlgSelectAttr.Create(Self) do
      try
        ibqryFind.Database := FBase.Database;
        ibqryFind.Transaction := FBase.Transaction;
        S := Text;
        // Получаем результат
        I := GetElement(FAttrKey, S);
        if (I <> -1) and (I <> FValueID) then
        begin
          // Присваиваем новое значение
          FValueID := I;
          Text := S;
        end else
          DataChange(Self);
      finally
        FDropDowning := False;
        Free;
        Self.Repaint;
      end
    else
      with TdlgSelectF.Create(Self) do
      try
        ibsqlTree.Database := FBase.Database;
        ibsqlTree.Transaction := FBase.Transaction;
        ibqryFind.Database := FBase.Database;
        ibqryFind.Transaction := FBase.Transaction;
        S := Text;
        // Получаем результат
        I := GetElement(FTableName, FFieldName, FPrimaryName, S);
        if (I <> -1) and (I <> FValueID) then
        begin
          // Присваиваем новое значение
          FValueID := I;
          Text := S;
        end else
          DataChange(Self);
      finally
        FDropDowning := False;
        Free;
        Self.Repaint;
      end
  else begin
    inherited DropDown;

  end
end;

procedure TgsComboBoxAttr.Change;
begin
  if (FBase.Database = nil) or (FBase.Transaction = nil) then
    Exit;
  if ItemIndex > -1 then
  begin
    FValueID := Integer(Items.Objects[ItemIndex]);
    Text := Items.Strings[ItemIndex];
  end;
end;

{TgsComboBoxAttrSet ------------------------------------------}

constructor TgsComboBoxAttrSet.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  if not (csDesigning in ComponentState) then
  begin
    FValueID := TStringList.Create;
    FibsqlList := TIBSQL.Create(Self);
    //FValueID.OnChange := ValueIDChange;
  end;
  FBase := TIBBase.Create(Self);
  FPaintControl := TPaintControl.Create(Self, 'COMBOBOX');
  FDialogType := True;
  FDroping := False;
  FFullQry := False;
  FUserAttr := False;
  FCondition := '';
  FSortField := '';
  FSortOrder := DefSortOrder;
end;

destructor TgsComboBoxAttrSet.Destroy;
begin
  if not (csDesigning in ComponentState) then
  begin
    FibsqlList.Free;
    FValueID.Free;
    FItemList.Free;
  end;

  FPaintControl.Free;
  FBase.Free;

  inherited Destroy;
end;

procedure TgsComboBoxAttrSet.DataChange(Sender: TObject);
var
  I: Integer;
  LI: TListItem;
  S, T: String;
  NotEnough: Boolean;
begin
  if (Database = nil) or (Transaction = nil) then
    Exit;
  // Действия по изменению ДатаСорса
  if not FFullQry then
    CompileQry;
  if FUserAttr then
    if FDialogType then
    begin
      S := '';
      FibsqlList.Close;
      FibsqlList.SQL.Text := 'SELECT id, name FROM gd_attrset '
       + ' WHERE attrkey = ' + IntToStr(FAttrKey) + ' AND id IN(';
      if FValueID.Count > 0 then
        FibsqlList.SQL.Add(IntToStr(Integer(FValueID.Objects[0])))
      else
        FibsqlList.SQL.Add('0');
      for I := 1 to FValueID.Count - 1 do
        FibsqlList.SQL.Add(', ' + IntToStr(Integer(FValueID.Objects[I])));
      FibsqlList.SQL.Add(')');
      FibsqlList.ExecQuery;
      FValueID.Clear;
      while not FibsqlList.EOF do
      begin
        FValueID.AddObject(FibsqlList.FieldByName('name').AsString,
         Pointer(FibsqlList.FieldByName('id').AsInteger));
        S := S + FibsqlList.FieldByName('name').AsString + SetSeparator;
        FibsqlList.Next;
      end;
    end else
    begin
      Items.Clear;
      FibsqlList.Close;
      FibsqlList.SQL.Text := 'SELECT id, name FROM gd_attrset WHERE attrkey = '
       + IntToStr(FAttrKey);
      FibsqlList.ExecQuery;
      S := '';
      FItemList.ListView.Items.Clear;
      while not FibsqlList.EOF do
      begin
        LI := FItemList.ListView.Items.Add;
        LI.Caption := FibsqlList.FieldByName('name').AsString;
        LI.Data := Pointer(FibsqlList.FieldByName('id').AsInteger);
        for I := 0 to ValueID.Count - 1 do
          if Integer(ValueID.Objects[I]) = Integer(LI.Data) then
          begin
            ValueID.Strings[I] := LI.Caption;
            LI.Checked := True;
            S := S + LI.Caption + SetSeparator;
          end;

        FibsqlList.Next;
      end;
    end
  else
    if FDialogType then
    begin
      S := '';
      FibsqlList.Close;
      FibsqlList.SQL.Text := 'SELECT ' + Trim(FPrimaryName) + ','
       + Trim(FFieldName) + ' FROM ' + FTableName + ' WHERE '
       + FPrimaryName + ' IN(';
      if FValueID.Count > 0 then
      begin
        FibsqlList.SQL.Add(IntToStr(Integer(FValueID.Objects[0])));
        for I := 1 to 1498 do
        begin
          if I < FValueID.Count then
            FibsqlList.SQL.Add(', ' + IntToStr(Integer(FValueID.Objects[I])))
          else
            break;
        end;
      end else
        FibsqlList.SQL.Add('0');
      FibsqlList.SQL.Add(')');
      FibsqlList.ExecQuery;
      FValueID.Clear;
      NotEnough := True;
      while not FibsqlList.EOF do
      begin
        T := FibsqlList.FieldByName(FFieldName).AsString;
        FValueID.AddObject(T, Pointer(FibsqlList.FieldByName(FPrimaryName).AsInteger));
        if NotEnough then
        begin
          if (Length(S) + Length(T)) < 128 then
            S := S + T + SetSeparator
          else begin
            S := S + ' и другие...';
            NotEnough := False;
          end;
        end;
        FibsqlList.Next;
      end;
    end else
    begin
      S := '';
      Items.Clear;
      FibsqlList.Close;
      FibsqlList.SQL.Text := 'SELECT ' + Trim(FPrimaryName) + ','
       + Trim(FFieldName) + ' FROM ' + FTableName;
      FibsqlList.ExecQuery;
      FItemList.ListView.Items.Clear;
      while not FibsqlList.EOF do
      begin
        LI := FItemList.ListView.Items.Add;
        LI.Caption := FibsqlList.FieldByName(FFieldName).AsString;
        LI.Data := Pointer(FibsqlList.FieldByName(FPrimaryName).AsInteger);
        for I := 0 to ValueID.Count - 1 do
          if Integer(ValueID.Objects[I]) = Integer(LI.Data) then
          begin
            ValueID.Strings[I] := LI.Caption;
            LI.Checked := True;
            S := S + LI.Caption + SetSeparator;
          end;

        FibsqlList.Next;
      end;
    end;
  Items.Clear;
  Items.Add(S);
  ItemIndex := 0;
  Hint := S;
end;

procedure TgsComboBoxAttrSet.SetAttrKey(Value: Integer);
begin
  FAttrKey := Value;
  if not FDialogType then
    DataChange(Self);
end;

procedure TgsComboBoxAttrSet.SetValueID(Value: TStrings);
begin
  if FValueID <> Value then
  begin
    FValueID.Assign(Value);
    DataChange(Self);
  end;
end;

procedure TgsComboBoxAttrSet.ValueIDChange(Sender: TObject);
begin
  if not FDroping then
    DataChange(Self);
end;

procedure TgsComboBoxAttrSet.SetSortField(const Value: String);
begin
  FSortField := Trim(Value);
  if (not (csLoading in ComponentState)) and (FSortField > '') then
    FSortOrder := soNone;
end;

procedure TgsComboBoxAttrSet.SetSortOrder(const Value: TgsComboBoxSortOrder);
begin
  FSortOrder := Value;
  if (not (csLoading in ComponentState)) and (FSortOrder <> soNone) then
    FSortField := '';
end;

procedure TgsComboBoxAttrSet.CompileQry;
begin
  // Начальные установки
  // Предполагается, что подключается TIBQuery.
  // При желании можно добавить другие или найти способ по другому вытянуть
  //Assert(DataSource <> nil);
  FibsqlList.Close;
  FibsqlList.Database := FBase.Database;
  FibsqlList.Transaction := FBase.Transaction;
  FBase.Database.Connected := True;
  if not FBase.Transaction.InTransaction then
    FBase.Transaction.StartTransaction;
  FFullQry := True;
end;

function TgsComboBoxAttrSet.GetDatabase: TIBDatabase;
begin
  Result := FBase.Database;
end;

function TgsComboBoxAttrSet.GetTransaction: TIBTransaction;
begin
  Result := FBase.Transaction;
end;

procedure TgsComboBoxAttrSet.SetDatabase(Value: TIBDatabase);
begin
  if FBase.Database <> Value then
  begin
    FBase.Database := Value;
  end;
end;

procedure TgsComboBoxAttrSet.SetTransaction(Value: TIBTransaction);
begin
  if (FBase.Transaction <> Value) then
  begin
    FBase.Transaction := Value;
  end;
end;

procedure TgsComboBoxAttrSet.Loaded;
begin
  inherited Loaded;

  if not (csDesigning in ComponentState) then
  begin
    Style := csDropDownList;
    FItemList := TfrmSelectSet.Create(Self);
  end;
end;

procedure TgsComboBoxAttrSet.KeyDown(var Key: Word; Shift: TShiftState);
begin
  // Действия по клавишам
  inherited KeyDown(Key, Shift);
  if Key in [VK_UP, VK_DOWN, 13] then
  begin
    DropDown;
  end;
  if Key = VK_DELETE then
  begin
    FValueID.Clear;
    DataChange(Self);
  end;
end;

procedure TgsComboBoxAttrSet.DropDown;
var
  Flag: Boolean;
  I: Integer;
  S: String;
  Temps: String;
begin
  FDroping := True;
  if FDialogType then
    if FUserAttr then
    // Действия по поиску
      with TdlgSelectAttrSet.Create(Self) do
      try
        ibqryFind.Database := Database;
        ibqryFind.Transaction := Transaction;
        ibsqlTarget.Database := Database;
        ibsqlTarget.Transaction := Transaction;
        // Получаем результат
        Flag := GetElements(FAttrKey, FValueID);
        if Flag then
        begin
          Items.Clear;
          S := '';
          for I := 0 to FValueID.Count - 1 do
            S := S + FValueID.Strings[I] + SetSeparator;
          Items.Add(S);
          ItemIndex := 0;
        end;
      finally
        Free;
        Self.Repaint;
      end
    else
    // Действия по поиску
      with TdlgSelectFSet.Create(Self) do
      try
        ibsqlTree.Database := Database;
        ibsqlTree.Transaction := Transaction;
        ibsqlTarget.Database := Database;
        ibsqlTarget.Transaction := Transaction;
        ibqryFind.Database := Database;
        ibqryFind.Transaction := Transaction;

        Temps := '';
        if FSortField = '' then
        begin
          if FSortOrder = soAsc then
            Temps := ' ASC '
          else if FSortOrder = soDesc then
            Temps := ' DESC ';
        end;

        // Получаем результат
        Flag := GetElements(FValueID, TableName, FieldName, PrimaryName, FCondition, FSortField, Temps);
        if Flag then
        begin
          Items.Clear;
          S := '';
          for I := 0 to FValueID.Count - 1 do
            S := S + FValueID.Strings[I] + SetSeparator;
          Items.Add(S);
          ItemIndex := 0;
        end;
      finally
        Free;
        Self.Repaint;
      end
  else
  begin
    FItemList.Left := ClientToScreen(Point(0, Height)).x;
    FItemList.Top := ClientToScreen(Point(0, Height)).y;
    FItemList.ListView.Column[0].Width := Width - 24;
    FItemList.Width := Width;
    if FItemList.ShowModal = mrOk then
    begin
      FValueID.Clear;
      S := '';
      for I := 0 to FItemList.ListView.Items.Count - 1 do
        if FItemList.ListView.Items[I].Checked then
        begin
          FValueID.AddObject(FItemList.ListView.Items[I].Caption,
           FItemList.ListView.Items[I].Data);
          S := S + FItemList.ListView.Items[I].Caption + SetSeparator;
        end;
      Items.Clear;
      Items.Add(S);
      ItemIndex := 0;
    end else
      DataChange(Self);
  end;
  Hint := Text;
  FDroping := False;
end;

procedure Register;
begin
  RegisterComponents('gsNew', [TgsDBComboBoxAttr]);
  RegisterComponents('gsNew', [TgsComboBoxAttr]);
  RegisterComponents('gsNew', [TgsComboBoxAttrSet]);
end;

end.


