// ShlTanya, 29.01.2019

unit dlgSelectValue_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, ComCtrls, ExtCtrls, IBCustomDataSet, IBUpdateSQL, Db,
  IBQuery, gd_security, IBDatabase, Grids, DBGrids, gsDBGrid, gsIBGrid,
  dmDatabase_unit, IBSQL, at_sql_setup;

type
  TdlgSelectValue = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    ActionList1: TActionList;
    actAddValue: TAction;
    actEditValue: TAction;
    actDelValue: TAction;
    btnOk: TButton;
    btnCancel: TButton;
    Button4: TButton;
    actShowValue: TAction;
    dsValue: TDataSource;
    actSelect: TAction;
    gsibgrSelValues: TgsIBGrid;
    ibdsValues: TIBDataSet;
    ibsqlAddNew: TIBSQL;
    ibsqlAddValue: TIBSQL;
    atSQLSetup: TatSQLSetup;
    procedure actAddValueExecute(Sender: TObject);
    procedure actEditValueExecute(Sender: TObject);
    procedure actDelValueExecute(Sender: TObject);
    procedure actSelectExecute(Sender: TObject);
    procedure gsibgrSelValuesDblClick(Sender: TObject);
    procedure gsibgrSelValuesKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actEditValueUpdate(Sender: TObject);
    procedure actDelValueUpdate(Sender: TObject);
  private
    { Private declarations }
    FGoodKey: TID;
  public
    { Public declarations }

    function ActiveDialog(const aGoodKey: TID; IsChoose: Boolean): Boolean;
  end;

var
  dlgSelectValue: TdlgSelectValue;

implementation

{$R *.DFM}

uses
  dlgAddValue_unit, Storages;

procedure TdlgSelectValue.actAddValueExecute(Sender: TObject);
begin
  with TdlgAddValue.Create(Self) do
    try
      ActiveDialog(-1);
      if ShowModal = mrOk then
      begin
        ibdsValues.Close;
        ibdsValues.Open;
        ibdsValues.Locate('id', TID2V(ValueKey), []);
      end;
    finally
      Free;
    end;
end;

procedure TdlgSelectValue.actEditValueExecute(Sender: TObject);
begin
  if ibdsValues.FieldByName('Name').AsString = '' then exit;

  with TdlgAddValue.Create(Self) do
    try
      ActiveDialog(GetTID(ibdsValues.FieldByName('id')));
      if ShowModal = mrOk then
        ibdsValues.Refresh;
    finally
      Free;
    end;

end;

procedure TdlgSelectValue.actDelValueExecute(Sender: TObject);
begin
  if ibdsValues.FieldByName('Name').AsString = '' then exit;

  if MessageBox(HANDLE, PChar(Format('Удалить единицу измерения ''%s''?', [ibdsValues.FieldByName('name').AsString])),
    'Внимание', mb_YesNo or mb_IconQuestion) = idYes
  then
    ibdsValues.Delete;
end;

function TdlgSelectValue.ActiveDialog(const aGoodKey: TID; isChoose: Boolean): Boolean;
begin
  Result := False;
  FGoodKey := aGoodKey;
  ibdsValues.Open;
  if (ShowModal = mrOk) and IsChoose then
  begin
    ibdsValues.DisableControls;
    try
      ibsqlAddNew.Transaction := ibdsValues.Transaction;
      ibdsValues.First;
      while not ibdsValues.EOF do
      begin
        if gsibgrSelValues.CheckBox.RecordChecked
        then
        begin
          if not ibsqlAddNew.Prepared then
            ibsqlAddNew.Prepare;
          SetTID(ibsqlAddNew.Params.ByName('goodkey'), FGoodKey);
          SetTID(ibsqlAddNew.Params.ByName('valuekey'), ibdsValues.FieldByName('ID'));
          try
            ibsqlAddNew.ExecQuery;
          except
          end;
          ibsqlAddNew.Close;
        end;
        ibdsValues.Next;
      end;
    finally
      ibdsValues.EnableControls;
    end;
    Result := True;
  end;
end;

procedure TdlgSelectValue.actSelectExecute(Sender: TObject);
var
  Bookmark: TBookmark;
begin
  // Отмечаем ед. изм. для добавления
  gsibgrSelValues.CheckBox.CheckList.Clear;
  ibdsValues.DisableControls;
  Bookmark := ibdsValues.GetBookmark;
  try
    ibdsValues.First;
    while not ibdsValues.EOF do
    begin
      gsibgrSelValues.CheckBox.AddCheck(GetTID(ibdsValues.FieldByName('ID')));
      ibdsValues.Next;
    end;
  finally
    ibdsValues.GotoBookmark(Bookmark);
    ibdsValues.FreeBookmark(Bookmark);
    ibdsValues.EnableControls;
  end;
end;

procedure TdlgSelectValue.gsibgrSelValuesDblClick(Sender: TObject);
begin
  actEditValue.Execute;
end;

procedure TdlgSelectValue.gsibgrSelValuesKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    actEditValue.Execute;
end;

procedure TdlgSelectValue.FormDestroy(Sender: TObject);
begin
  GlobalStorage.SaveComponent(gsibgrSelValues, gsibgrSelValues.SaveToStream);
end;

procedure TdlgSelectValue.FormCreate(Sender: TObject);
begin
  GlobalStorage.LoadComponent(gsibgrSelValues, gsibgrSelValues.LoadFromStream);
end;

procedure TdlgSelectValue.actEditValueUpdate(Sender: TObject);
begin
  actEditValue.Enabled := not ibdsValues.FieldByName('ID').IsNull;
end;

procedure TdlgSelectValue.actDelValueUpdate(Sender: TObject);
begin
  actDelValue.Enabled := not ibdsValues.FieldByName('ID').IsNull;
end;

end.
