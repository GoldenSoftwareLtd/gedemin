// ShlTanya, 29.01.2019

unit dlgCompleteGoodSet_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, Menus, StdCtrls, ComCtrls, IBCustomDataSet, IBUpdateSQL, Db,
  IBQuery, gd_security, IBSQL, IBStoredProc, Grids, DBGrids, gsDBGrid,
  gsIBGrid, IBDatabase, ExtCtrls, dmDatabase_unit, at_sql_setup;

type
  TdlgCompleteGoodSet = class(TForm)
    Label1: TLabel;
    lblName: TLabel;
    PopupMenu1: TPopupMenu;
    ActionList1: TActionList;
    actAddItem: TAction;
    actEditItem: TAction;
    actDelItem: TAction;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    dsGoodSet: TDataSource;
    ibsqlSetName: TIBSQL;
    ibdsGoodSet: TIBDataSet;
    gsibdsGoodSet: TgsIBGrid;
    IBTransaction: TIBTransaction;
    Panel2: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    acOk: TAction;
    atSQLSetup: TatSQLSetup;
    procedure actAddItemExecute(Sender: TObject);
    procedure actDelItemExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure acOkExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    SetKey: TID;
    function ActiveDialog(const aSetKey: TID): Boolean;
  end;

var
  dlgCompleteGoodSet: TdlgCompleteGoodSet;

implementation

uses
  dlgIncludeGood_unit, gd_security_OperationConst,
  Storages;

{$R *.DFM}

procedure TdlgCompleteGoodSet.actAddItemExecute(Sender: TObject);
begin
  // Добавление новых товаров в комплект
  with TdlgIncludeGood.Create(Self) do
    try
      ActiveDialog(Self.ibdsGoodSet, SetKey);
      if ShowModal = mrOk then
      begin
        Self.ibdsGoodSet.Close;
        Self.ibdsGoodSet.Open;
      end;
    finally
      Free;
    end;
end;

function TdlgCompleteGoodSet.ActiveDialog(const aSetKey: TID): Boolean;
begin
  if not IBTransaction.InTransaction then
    IBTransaction.StartTransaction;

  SetKey := aSetKey;
    
  Result := False;
  ibsqlSetName.Close;
  ibsqlSetName.SQL.Text := 'SELECT * FROM gd_good WHERE id = ' + TID2S(SetKey);
  ibsqlSetName.ExecQuery;
  if ibsqlSetName.FieldByName('isassembly').AsInteger = 1 then
    Result := True
  else
    Exit;
  lblName.Caption := ibsqlSetName.FieldByName('name').AsString;

  // Инициализация Д.О.
  // Выбираем товары принадлежащие данному комплекту
  ibdsGoodSet.Close;
  SetTID(ibdsGoodSet.Params.ByName('setkey'), SetKey);
  ibdsGoodSet.Open;
end;

procedure TdlgCompleteGoodSet.actDelItemExecute(Sender: TObject);
begin
  // Удаление комплектующей
  if ibdsGoodSet.FieldByName('Name').AsString = '' then exit;
  if MessageBox(HANDLE, PChar(Format('Удалить комплектующую %s из списка?', [gsibdsGoodSet.SelectedField.Text])),
       'Внимание', mb_YesNo or mb_IconQuestion) = idYes
  then
    ibdsGoodSet.Delete;     
end;

procedure TdlgCompleteGoodSet.FormCreate(Sender: TObject);
begin
  GlobalStorage.LoadComponent(gsibdsGoodSet, gsibdsGoodSet.LoadFromStream);
end;

procedure TdlgCompleteGoodSet.acOkExecute(Sender: TObject);
begin
  if IBTransaction.InTransaction then
    IBTransaction.Commit;
end;

procedure TdlgCompleteGoodSet.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if ModalResult <> mrOK then
  begin
    if IBTransaction.InTransaction then
      IBTransaction.RollBack;
  end;
end;

procedure TdlgCompleteGoodSet.FormDestroy(Sender: TObject);
begin
  GlobalStorage.SaveComponent(gsibdsGoodSet, gsibdsGoodSet.SaveToStream);
end;

end.
