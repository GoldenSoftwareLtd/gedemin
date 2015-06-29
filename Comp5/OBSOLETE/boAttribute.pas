unit boAttribute;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, BoObject, DB, DBTables, DBGrids, UserLogin, xMsgBox, dbCtrls, xDBLooku,
  xDBLookupStored, xCtrlGrid, xMemTable, ExList;

type
  TboAttribute = class(TboObject)
  private
    { Private declarations }
    FdbGrid: TdbGrid;
    FDataSource: TDataSource;
    FID: Integer;

    tblAttrGoods: TTable;
    tblAttrGoodsValue: TTable;
    mtblAttrGoodsValue: TxMemTable;
    dsAttrGoodsValue: TDataSource;

    FControlsGrid: TExList;
    FDataField: String;
    FAttrKeyField: String;

    procedure DoOnSetCtrl(Sender: TObject; Ctrl: TWinControl;
       Column: TColumn; var Show: Boolean);
    function SearchAttrPosition: Boolean;
    procedure AddAttrPosition;    

  protected
    { Protected declarations }
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Loaded; override;

    function GetID: Integer; override;
    procedure SetID(const Value: Integer); override;

    function GetActive: Boolean; override;
    procedure SetActive(const Value: Boolean); override;

  public
    { Public declarations }
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    procedure MakeAfterAppend(DataSet: TDataSet);
    procedure SetDataSetField(DataSet: TDataSet);
    procedure SetAttributeValue(DataSet: TDataSet);
    procedure SetDBGridEdit;
    procedure ReadAttribute;

    function SaveAttribute: Boolean;


  published
    { Published declarations }
    property dbGrid: TdbGrid read FdbGrid write FdbGrid;
    property DataSource: TDataSource read FDataSource write FDataSource;
    property DataField: String read FDataField write FDataField;
    property AttrKeyField: String read FAttrKeyField write FAttrKeyField;
  end;

procedure Register;

implementation

const
  NameProc = 'ALTER PROCEDURE fin_p_getuniqueid_attrgoods';

(*
  Проблема:
    При редактировании документа возникает необходимость изменения
    постоянных параметров. Данные параметры хранятся в отедльной таблице и
    собственно независимы от докмуента. Таблица параметров хранит уникальный набор
    параметров только один раз. А на этот набор может ссылаться множество различных
    позиций в разных документах. По этой причине нельзя редактировать данные параметры
    напрямую в указанной таблице.

  Пути решений:
    1. Можно добавить еще одну таблицу, которая будет хранить значения параметров
    для каждого документа. Соответственно изменения производить в этой таблице, а затем
    уже сверять их с основной таблицей.
       Этот путь проще и в каких-то случаях достаточно быстрый. Однако для этого
    необходимо иметь еще одну таблицу, которая вообщем случае будет достаточно большой и
    вообщемто ненужной.

    2. Можно создавать временную таблицу (memTable) в нее при открытии документа сохранять
    значения параметров, в ней их изменять, а затем при сохранении уже производить
    изменения кода.
       Этот путь достаточно хорош в плане размера базы. Но в плане скорости работы может
    быть достаточно долгим. А также достаточно трудоемкий.

    Необходимо оценить оба метода и затем выбрать лучший.
    Вообще мне ближе второй метод.

    Рассмотрим 2-й метод более подробнее:

    Необходимо в начале работы создать MemTable с полями аттрибутов и полем отвечающее
    за уникальность позиции, затем закачать туда данные. В конце работы необходимо
    пробежаться по всем записям, проверить произведенные изменения.

*)


procedure Register;
begin
  RegisterComponents('gsBO', [TboAttribute]);
end;

{ TboAttribute }

constructor TboAttribute.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);

  FControlsGrid := TExList.Create;
  
  tblAttrGoods := TTable.Create(Self);
  tblAttrGoods.DatabaseName := 'xxx';
  tblAttrGoods.TableName := 'fin_attrgoods';

  tblAttrGoodsValue := TTable.Create(Self);
  tblAttrGoodsValue.DatabaseName := 'xxx';
  tblAttrGoodsValue.TableName := 'fin_attrgoodsvalex';

  mtblAttrGoodsValue := TxMemTable.Create(Self);
  mtblAttrGoodsValue.TableName := 'mtblatt';

  dsAttrGoodsValue := TDataSource.Create(Self);
  dsAttrGoodsValue.DataSet := mtblAttrGoodsValue;

  FdbGrid := nil;
  FID := -1;

  FDataField := '';
  FAttrKeyField := '';
end;

destructor TboAttribute.Destroy;
begin
  FControlsGrid.Free;

  tblAttrGoods.Close;
  tblAttrGoods.Free;

  tblAttrGoodsValue.Close;
  tblAttrGoodsValue.Free;

  mtblAttrGoodsValue.Close;
  mtblAttrGoodsValue.Free;

  dsAttrGoodsValue.Free;

  inherited Destroy;
end;

function TboAttribute.SearchAttrPosition: Boolean;
var
  Bookmark: TBookmark;
begin
  Result := False;
  if (FDataSource <> nil) and (FDataSource.DataSet <> nil) then
  begin
    Bookmark := mtblAttrGoodsValue.GetBookmark;
    try
      while not mtblAttrGoodsValue.EOF do
      begin
        if mtblAttrGoodsValue.FieldByName(FDataField).AsInteger =
           FDataSource.DataSet.FieldByName(FDataField).AsInteger  then
        begin
          Result := True;
          Break;
        end;
        mtblAttrGoodsValue.Next;
      end;
      if not Result then
      begin
        mtblAttrGoodsValue.GotoBookmark(Bookmark);
        mtblAttrGoodsValue.Prior;
        while not mtblAttrGoodsValue.BOF do
        begin
          if mtblAttrGoodsValue.FieldByName(FDataField).AsInteger =
             FDataSource.DataSet.FieldByName(FDataField).AsInteger  then
          begin
            Result := True;
            Break;
          end;
          mtblAttrGoodsValue.Prior;
        end;
      end;
    finally
      mtblAttrGoodsValue.FreeBookmark(Bookmark);
    end;
  end;
end;

procedure TboAttribute.AddAttrPosition;
var
  i: Integer;
begin
  if (FDataSource <> nil) and (FDataSource.DataSet <> nil) then
  begin
    mtblAttrGoodsValue.Append;
    for i:= 0 to mtblAttrGoodsValue.FieldCount - 1 do
    begin
      if not FDataSource.DataSet.FieldByName(mtblAttrGoodsValue.Fields[i].FieldName).IsNull then
        mtblAttrGoodsValue.Fields[i].AsString :=
          FDataSource.DataSet.FieldByName(mtblAttrGoodsValue.Fields[i].FieldName).AsString
      else
        mtblAttrGoodsValue.Fields[i].Clear;
    end;
    mtblAttrGoodsValue.Post;
  end;
end;

procedure TboAttribute.DoOnSetCtrl(Sender: TObject; Ctrl: TWinControl;
  Column: TColumn; var Show: Boolean);
begin
  if not SearchAttrPosition then
    AddAttrPosition;
end;

function TboAttribute.GetActive: Boolean;
begin
  Result := tblAttrGoodsValue.Active;
end;

function TboAttribute.GetID: Integer;
begin
  Result := FID;
end;

procedure TboAttribute.Loaded;
begin
  inherited Loaded;

end;

procedure TboAttribute.MakeAfterAppend(DataSet: TDataSet);
var
  S, S1: String;
  qryAlterTable: TQuery;
begin
  qryAlterTable := TQuery.Create(Self);
  try
    qryAlterTable.DatabaseName := 'xxx';
    qryAlterTable.ParamCheck := False;

    S := 'ALTER TABLE fin_attrgoodsvalex ADD ' + 'N' + DataSet.FieldByName('ID').Text;
    case DataSet.FieldByName('TypeAttr').AsInteger of
    0: S := S + ' VARCHAR(' + DataSet.FieldByName('FieldSize').Text + ')';
    1: S := S + ' DECIMAL(' + DataSet.FieldByName('FieldSize').Text + ',' +
      DataSet.FieldByName('DecSize').Text + ')';
    2,
    4: S := S + ' INTEGER';
    3: S := S + ' DATE';
    end;

    qryAlterTable.SQL.Text := S;
    qryAlterTable.ExecSQL;
    qryAlterTable.SQL.Clear;
    case DataSet.FieldByName('TypeAttr').AsInteger of
    4: qryAlterTable.SQL.Text :=
       'ALTER TABLE fin_attrgoodsvalex ADD CONSTRAINT fin_fk_attrgd_' + 'N' +
         DataSet.FieldByName('ID').Text +
       ' FOREIGN KEY ' + '(N' + DataSet.FieldByName('ID').Text + ')' +
       ' REFERENCES cst_customer (customerkey)';
    end;

    if qryAlterTable.SQL.Count > 0 then
      qryAlterTable.ExecSQl;

    qryAlterTable.SQL.Clear;
    qryAlterTable.SQL.Add(NameProc + '(');

    S := '';
    S1 := '';
    DataSet.First;
    while not DataSet.EOF do
    begin
      if S <> '' then
        S := S + ',';
      S := S + 'NN' + DataSet.FieldByName('ID').Text + ' ';
      case DataSet.FieldByName('ATTRTYPE').AsInteger of
      0: S := S + 'VARCHAR(' + DataSet.FieldByName('FieldSize').Text + ')';
      1: S := S + 'DECIMAL(' + DataSet.FieldByName('FieldSize').Text + ',' +
        DataSet.FieldByName('DecSize').Text + ')';
      3: S := S + 'DATE';
      else
        S := S + 'INTEGER';
      end;
      if S1 <> '' then
        S1 := S1 + ' AND ';
      S1 := S1 +
        '((:NN' + DataSet.FieldByName('ID').Text + ' IS NULL AND ' +
        'N' + DataSet.FieldByName('ID').Text + ' IS NULL) OR ' +
        '(N' + DataSet.FieldByName('ID').Text + ' = ' +
        ':NN' + DataSet.FieldByName('ID').Text + '))';
      DataSet.Next;
    end;
    S := S + ')';
    qryAlterTable.SQL.Add(S);
    qryAlterTable.SQL.Add('RETURNS (id INTEGER)');
    qryAlterTable.SQL.Add('AS');
    qryAlterTable.SQL.Add('BEGIN');
    qryAlterTable.SQL.Add('id = NULL;');
    qryAlterTable.SQL.Add('SELECT id FROM fin_attrgoodsvalex ');
    qryAlterTable.SQL.Add('WHERE ' + S1);
    qryAlterTable.SQL.Add(' INTO :id;');
    qryAlterTable.SQL.Add(' IF (id IS NULL) THEN');
    qryAlterTable.SQL.Add('   id = GEN_ID(fin_g_attrgoodsvalid, 1);');
    qryAlterTable.SQL.Add('SUSPEND;');
    qryAlterTable.SQL.Add('END');
    qryAlterTable.ExecSQL;

  finally
    qryAlterTable.Free;
  end;

end;

procedure TboAttribute.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(aComponent, Operation);

  if (Operation = opRemove) and (aComponent = FDataSource) then
    FDataSource := nil;

  if (Operation = opRemove) and (aComponent = FdbGrid) then
    FdbGrid := nil;
end;

procedure TboAttribute.SetActive(const Value: Boolean);
begin
  tblAttrGoodsValue.Active := Value;
end;

procedure TboAttribute.SetAttributeValue(DataSet: TDataSet);
begin
  tblAttrGoods.Open;
  while not tblAttrGoods.EOF do
  begin
    DataSet.FieldByName('N' + tblAttrGoods.FieldByName('ID').Text).Text :=
      tblAttrGoodsValue.FieldByName('N' + tblAttrGoods.FieldByName('ID').Text).Text;
    tblAttrGoods.Next;
  end;
end;

procedure TboAttribute.ReadAttribute;
var
  i: Integer;
begin
  DataSource.DataSet.DisableControls;
  try
    DataSource.DataSet.First;
    while not DataSource.DataSet.EOF do
    begin
      mtblAttrGoodsValue.Append;
      for i:= 0 to mtblAttrGoodsValue.FieldCount - 1 do
        mtblAttrGoodsValue.Fields[i].AsString :=
          DataSource.DataSet.FieldByName(mtblAttrGoodsValue.Fields[i].FieldName).AsString;
      mtblAttrGoodsValue.Post;
      DataSource.DataSet.Next;
    end;
  finally
    DataSource.DataSet.First;
    DataSource.DataSet.EnableControls;
  end;
end;


procedure TboAttribute.SetDataSetField(DataSet: TDataSet);
var
  F: TField;
begin
  tblAttrGoods.Open;
  while not tblAttrGoods.Active do
  begin

    case tblAttrGoods.FieldByName('AttrType').AsInteger of
    0: F := TStringField.Create(Owner);
    1: F := TFloatField.Create(Owner);
    2, 4: F := TIntegerField.Create(Owner);
    3: F := TDateTimeField.Create(Owner);
    else
      F := nil;
    end;

    if F <> nil then
    begin
      F.FieldName := 'N' + tblAttrGoods.FieldByName('ID').Text;
      if tblAttrGoods.FieldByName('AttrType').AsInteger = 0 then
        F.Size := tblAttrGoods.FieldByName('FieldSize').AsInteger;
      F.Calculated := True;
      F.DisplayLabel := tblAttrGoods.FieldByName('Name').Text;
      F.Visible := True;
      F.DataSet := DataSet;
    end;

    tblAttrGoods.Next;

  end;
  tblAttrGoods.Close;
end;

{DONE 1 -oMikle : Доделать метод SetDBGridEdit }

procedure TboAttribute.SetDBGridEdit;
var
  E: TCustomEdit;
  F: TField;
  ControlOnExit: TNotifyEvent;
  ControlOnKeyDown: TKeyEvent;
begin
  if FdbGrid is TxCtrlGrid then
  begin
    tblAttrGoods.Open;
    while not tblAttrGoods.EOF do
    begin
      E := nil;
      case tblAttrGoods.FieldByName('AttrType').AsInteger of
      0:
        begin
          F := TStringField.Create(Owner);
          F.Size := tblAttrGoods.FieldByName('FieldSize').AsInteger;
        end;
      1: F := TFloatField.Create(Owner);
      2,
      4: F := TIntegerField.Create(Owner);
      3: F := TDateTimeField.Create(Owner);
      else
        F := nil;
      end;

      if (F <> nil) then
      begin
        F.FieldName := 'N' + tblAttrGoods.FieldByName('ID').Text;
        F.DataSet := mtblAttrGoodsValue;
      end;

      if tblAttrGoodsValue.FieldByName('AttrType').AsInteger >= 4 then
      begin
        if tblAttrGoods.FieldByName('SEARCHSTORED').AsString = '' then
        begin
          E := TxDBLookupCombo.Create(Self);
          (E as TxDBLookupCombo).DataSource := dsAttrGoodsValue;
          (E as TxDBLookupCombo).DataField := 'N' + tblAttrGoods.FieldByName('ID').Text;
          (E as TxDBLookupCombo).LookupField := 'ID';
          (E as TxDBLookupCombo).LookupDisplay := 'Name';
        end
        else
        begin
          E := TxDBLookupCombo2.Create(Self);
          (E as TxDBLookupCombo2).DataSource := dsAttrGoodsValue;
          (E as TxDBLookupCombo2).DataField := 'N' + tblAttrGoods.FieldByName('ID').Text;
          (E as TxDBLookupCombo2).LookupStoredProc := tblAttrGoods.FieldByName('SearchStored').Text;
          (E as TxDBLookupCombo2).LookupViewStoredProc := tblAttrGoods.FieldByName('ViewStored').Text;
          (E as TxDBLookupCombo2).LookupField := 'ID';
          (E as TxDBLookupCombo2).LookupDisplay := 'Name';
        end;

      end
      else
      begin
        E := TDBEdit.Create(Self);
        (E as TDBEdit).DataSource := dsAttrGoodsValue;
        (E as TDBEdit).DataField := 'N' + tblAttrGoods.FieldByName('ID').Text;
      end;

      FControlsGrid.Add(E);

      if FdbGrid is TxCtrlGrid then
        (FdbGrid as TxCtrlGrid).AddControl('N' + tblAttrGoods.FieldByName('ID').Text, E,
          ControlOnExit, ControlOnKeyDown);

      tblAttrGoods.Next;
    end;
  end;
end;

procedure TboAttribute.SetID(const Value: Integer);
begin
  FID := Value;
  if Value <> -1 then
  begin
    Active := True;
    tblAttrGoodsValue.FindKey([FID]);
  end;
end;

{ TODO 1 -oMikle : Необходимо доделать сохранение атрибутов }

function TboAttribute.SaveAttribute: Boolean;
var
  Bookmark: TBookmark;
  spGetID: TStoredProc;
  isOK: Boolean;
  i, ID: Integer;
begin
  Result := False;
  if (DataSource <> nil) and (DataSource.DataSet <> nil) then
  begin
    if not tblAttrGoods.Active then tblAttrGoods.Open;
    spGetID := TStoredProc.Create(Self);
    spGetID.DatabaseName := 'xxx';
    spGetID.StoredProcName := 'fin_p_getuniqueid_attrgoods';
    Bookmark := DataSource.DataSet.GetBookmark;
    DataSource.DataSet.DisableControls;
    try
      DataSource.DataSet.First;
      while not DataSource.DataSet.EOF do
      begin
        isOK := SearchMemTable;
        
        tblAttrGoods.First;
        while not tblAttrGoods.EOF do
        begin
          if not isOk or mtblAttrGoodsValue.FieldByName('N' + tblAttrGoods.FieldByName('ID').Text).IsNull then
            spGetID.ParamByName('NN' + tblAttrGoods.FieldByName('ID').Text).Clear
          else
          begin
            case tblAttrGoods.FieldByName('AttrType').AsInteger of
            0: spGetID.ParamByName('NN' + tblAttrGoods.FieldByName('ID').Text).AsString :=
                 mtblAttrGoodsValue.FieldByName('N' + tblAttrGoods.FieldByName('ID').Text).AsString;
            1: spGetID.ParamByName('NN' + tblAttrGoods.FieldByName('ID').Text).AsFloat :=
                 mtblAttrGoodsValue.FieldByName('N' + tblAttrGoods.FieldByName('ID').Text).AsFloat;
            3: spGetID.ParamByName('NN' + tblAttrGoods.FieldByName('ID').Text).AsDateTime :=
                 mtblAttrGoodsValue.FieldByName('N' + tblAttrGoods.FieldByName('ID').Text).AsDateTime;
            else
              spGetID.ParamByName('NN' + tblAttrGoods.FieldByName('ID').Text).AsInteger :=
                mtblAttrGoodsValue.FieldByName('N' + tblAttrGoods.FieldByName('ID').Text).AsInteger;
            end;
          end;
          tblAttrGoods.Next;
        end;

        spGetID.ExecProc;

        if spGetID.ParamByName('ID').IsNull then
        begin
          tblAttrGoodsValue.Append;
          for i:= 0 to mtblAttrGoodsValue.FieldCount - 1 do
          begin
            if CompareText(mtblAttrGoodsValue.Fields[i].FieldName, FAttrKeyField) <> 0 then
              tblAttrGoodsValue.FieldByName(mtblAttrGoodsValue.Fields[i].FieldName).AsString :=
                mtblAttrGoodsValue.Fields[i].AsString;
          end;
          tblAttrGoodsValue.Post;
          tblAttrGoodsValue.Refresh;
          ID := tblAttrGoodsValue.FieldByName('ID').AsInteger;
        else
          ID := spGetID.ParamByName('ID').AsInteger;

        if ID <> mtblAttrGoodsValue.FieldByName(FAttrKeyField).AsInteger then
        begin
          if mtblAttrGoodsValue.FieldByName(FAttrKeyField).AsInteger = 0 then
          begin
            mtblAttrGoodsValue.Edit;
            mtblAttrGoodsValue.FieldByName(FAttrKeyField).AsInteger := ID;
            mtblAttrGoodsValue.Post;
          end
          else
          begin
          
          end;
        end;
        DataSource.DataSet.Next;
      end;
    finally
      DataSource.DataSet.GotoBookmark(Bookmark);
      DataSource.DataSet.FreeBookmark(Bookmark);
      DataSource.DataSet.EnableControls;
    end;
  end;
end;


end.
