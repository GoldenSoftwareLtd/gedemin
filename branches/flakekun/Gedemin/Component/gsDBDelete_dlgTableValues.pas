
 {++

   Copyright © 2000 by Golden Software

   Модуль

     gsDBDelete_dlgTableValues.pas

   Описание

     Форма, для отображения таблиц, ссылающихся на к-л запись.
     Вызывается из бизнес-объекта при попытке удалить запись,
     на которую есть ссылки


   История

     ver    date       who     what

     1.01   10.04.2002 Julia

 --}
unit gsDBDelete_dlgTableValues;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBCustomDataSet, IBQuery, Grids, DBGrids, gsDBGrid,
  gsIBGrid, ComCtrls, ExtCtrls, StdCtrls, at_sql_setup, gdcBase, gd_KeyAssoc,
  contnrs, dmImages_unit, ActnList, TB2Dock, TB2Toolbar, TB2Item;

type
  TObjectValues = class
  private
    FFullObject: TgdcFullClass;
    FIdList: TgdKeyArray;
    FDisplayName: String;
    FNotEOF: Boolean;

  public
    constructor Create(ADisplayName: String; AFullObject: TgdcFullClass;
      ANotEOF: Boolean);
    destructor Destroy; override;

    property FullObject: TgdcFullClass read FFullObject;// write FFullObject;
    property IdList: TgdKeyArray read FIdList;
    property DisplayName: String read FDisplayName; // write FDisplayName;
    //При установке в True указывает, что не все записи были вытянуты из БД
    //Необходим при большом количестве записей
    //Вытягивает первую тысячу
    property NotEOF: Boolean read FNotEOF;

    function CreateCurrObject: TgdcBase;
  end;

  TdlgTableValues = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Panel4: TPanel;
    Panel5: TPanel;
    Splitter1: TSplitter;
    lvTables: TListView;
    dbgValue: TgsIBGrid;
    dsValue: TDataSource;
    tbDelete: TTBToolbar;
    alDelete: TActionList;
    actEdit: TAction;
    actDelete: TAction;
    tbiEdit: TTBItem;
    tbiDelete: TTBItem;
    lblEof: TLabel;
    procedure lvTablesChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure FormActivate(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actEditUpdate(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actDeleteUpdate(Sender: TObject);

  private
    FObjectValueList: TObjectList;
    gdcDynamic: TgdcBase;
{    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;}
//    procedure ChangeTable;
    procedure ChangeObject;

  public
//    Key: String;
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure AddNewObject(ADisplayName: String; AnObject: TgdcFullClass;
      AnID: TStrings; NotEof: Boolean);
    property ObjectValueList: TObjectList read FObjectValueList;

{    property Transaction: TIBTransaction read FTransaction write FTransaction;
    property Database: TIBDatabase read FDatabase write FDatabase;}
  end;

var
  dlgTableValues: TdlgTableValues;

implementation

{$R *.DFM}

uses
  at_Classes, at_Classes_Body, gdcBaseInterface;

{ TObjectValues }

constructor TObjectValues.Create(ADisplayName: String; AFullObject: TgdcFullClass;
  ANotEOF: Boolean);
begin
  FIdList := TgdKeyArray.Create;
  FDisplayName := ADisplayName;
  FFullObject := AFullObject;
  FNotEof := ANotEof;
end;

function TObjectValues.CreateCurrObject: TgdcBase;
begin
  Result := FFullObject.gdClass.CreateSubType(nil, FFullObject.SubType, 'OnlySelected');
  Result.BaseState := Result.BaseState + [sView];
  Result.SelectedID.Assign(FIdList);
end;

destructor TObjectValues.Destroy;
begin
  FIdList.Free;
  inherited;
end;

{ TdlgTableValues }

procedure TdlgTableValues.lvTablesChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  ChangeObject;
end;

procedure TdlgTableValues.FormActivate(Sender: TObject);
begin
  ChangeObject;
end;

{procedure TdlgTableValues.ChangeTable;
begin
  if Key = '' then Exit;
  qryValue.Close;
  if lvTables.Selected <> nil then
  begin
    qryValue.SQL.Text := 'SELECT * FROM ' + lvTables.Selected.SubItems[1] + ' ' +
      ' WHERE ' + lvTables.Selected.SubItems[0] + ' = ' + Key;
    qryValue.Open;
    LocalizeDataSet(qryValue);
  end;
end;}

constructor TdlgTableValues.Create(AnOwner: TComponent);
begin
  inherited;
  FObjectValueList := TObjectList.Create;
end;

destructor TdlgTableValues.Destroy;
begin
  FObjectValueList.Free;
  gdcDynamic.Free;
  inherited;
end;


procedure TdlgTableValues.AddNewObject(ADisplayName: String;
  AnObject: TgdcFullClass; AnID: TStrings; NotEof: Boolean);
var
  NewObject: TObjectValues;
  I: Integer;
begin
  NewObject := TObjectValues.Create(ADisplayName, AnObject, NotEof);
  NewObject.IdList.Clear;
  try
    for I := 0 to AnID.Count - 1 do
      NewObject.IdList.Add(StrToInt(AnID[I]));
  except
    raise Exception.Create('Ошибка при создании объекта. Недействительный идентификатор!');
  end;
  FObjectValueList.Add(NewObject);
end;

procedure TdlgTableValues.ChangeObject;
begin
  if lvTables.Selected <> nil then
  begin
    FreeAndNil(gdcDynamic);
    gdcDynamic := TObjectValues(FObjectValueList[lvTables.Selected.Index]).CreateCurrObject;
    gdcDynamic.Open;
    dsValue.DataSet := gdcDynamic;
    if TObjectValues(FObjectValueList[lvTables.Selected.Index]).NotEof then
      lblEof.Caption := 'Считаны не все записи. Используйте прокрутку вниз.'
    else
      lblEof.Caption := '';
  end;
end;

procedure TdlgTableValues.actEditExecute(Sender: TObject);
begin
  gdcDynamic.EditMultiple(dbgValue.SelectedRows);
end;

procedure TdlgTableValues.actEditUpdate(Sender: TObject);
begin
  actEdit.Enabled := (gdcDynamic <> nil)
    and (gdcDynamic.RecordCount > 0)
    and (gdcDynamic.CanEdit)
    and (gdcDynamic.State = dsBrowse);
end;

procedure TdlgTableValues.actDeleteExecute(Sender: TObject);
begin
  gdcDynamic.DeleteMultiple(dbgValue.SelectedRows);
end;

procedure TdlgTableValues.actDeleteUpdate(Sender: TObject);
begin
  actDelete.Enabled := (gdcDynamic <> nil) and (gdcDynamic.RecordCount > 0) and
    (gdcDynamic.CanDelete) and (gdcDynamic.State = dsBrowse);
end;

end.
