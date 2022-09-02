// ShlTanya, 29.01.2019

unit dlgSelectPrMetal_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, ComCtrls, StdCtrls, ExtCtrls, Db, IBCustomDataSet, IBQuery,
  IBUpdateSQL, gd_security, IBSQL, IBDatabase, Grids, DBGrids, gsDBGrid,
  gsIBGrid, dmDatabase_unit, at_sql_setup;

type
  TdlgSelectPrMetal = class(TForm)
    Panel2: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    ActionList1: TActionList;
    actAddPrMetal: TAction;
    actEditPrMetal: TAction;
    Button4: TButton;
    actSelect: TAction;
    dsPrMetal: TDataSource;
    gsibgrPrMetal: TgsIBGrid;
    ibdsPrMetal: TIBDataSet;
    ibsqlAddNew: TIBSQL;
    Button3: TButton;
    actDelPrMetal: TAction;
    atSQLSetup: TatSQLSetup;
    procedure actAddPrMetalExecute(Sender: TObject);
    procedure actEditPrMetalExecute(Sender: TObject);
    procedure actDelPrMetalExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actEditPrMetalUpdate(Sender: TObject);
    procedure actDelPrMetalUpdate(Sender: TObject);
  private
    { Private declarations }
    FGoodKey: TID;
  public
    { Public declarations }
    function ActiveDialog(const aGoodKey: TID; isChoose: Boolean): Boolean;
  end;

var
  dlgSelectPrMetal: TdlgSelectPrMetal;

implementation

uses
  dlgSetParam_unit, Storages;

{$R *.DFM}

function TdlgSelectPrMetal.ActiveDialog(const aGoodKey: TID; isChoose: Boolean): Boolean;
begin
  Result := False;

  // Èíèöèàëèçàöèÿ
  FGoodKey := aGoodKey;
  ibdsPrMetal.Open;
  if (ShowModal = mrOk) and IsChoose then
  begin
    ibsqlAddNew.Transaction := ibdsPrMetal.Transaction;
    ibdsPrMetal.DisableControls;
    try
      ibdsPrMetal.First;
      while not ibdsPrMetal.EOF do
      begin
        if gsibgrPrMetal.CheckBox.RecordChecked
        then
        begin
          if not ibsqlAddNew.Prepared then
            ibsqlAddNew.Prepare;
          SetTID(ibsqlAddNew.Params.ByName('goodkey'), FGoodKey);
          SetTID(ibsqlAddNew.Params.ByName('prmetalkey'), ibdsPrMetal.FieldByName('ID'));
          try
            ibsqlAddNew.ExecQuery;
          except
          end;
          ibsqlAddNew.Close;
        end;
        ibdsPrMetal.Next;
      end;
    finally
      ibdsPrMetal.EnableControls;
    end;
    Result := True;
  end;
end;

procedure TdlgSelectPrMetal.actAddPrMetalExecute(Sender: TObject);
begin
  with TdlgSetParam.Create(Self) do
  try
    Caption := 'Äîáàâëåíèå äğàã.ìåòàëëà';
    if ShowModal = mrOK then
    begin
      ibdsPrMetal.Insert;
      SetTID(ibdsPrMetal.FieldByName('ID'), GenUniqueID);
      ibdsPrMetal.FieldByName('Name').AsString := ParamName;
      ibdsPrMetal.FieldByName('Description').AsString := Description;
      ibdsPrMetal.Post;
      ibdsPrMetal.Refresh;
    end;
  finally
    Free;
  end;
end;

procedure TdlgSelectPrMetal.actEditPrMetalExecute(Sender: TObject);
begin
  if ibdsPrMetal.FieldByName('Name').AsString = '' then exit;

  with TdlgSetParam.Create(Self) do
    try
      ParamName := ibdsPrMetal.FieldByName('Name').AsString;
      Description := ibdsPrMetal.FieldByName('Description').AsString;
      Caption := 'Ğåäàêòèğîâàíèå äğàã.ìåòàëëà';
      if ShowModal = mrOk then
      begin
        ibdsPrMetal.Edit;
        ibdsPrMetal.FieldByName('Name').AsString := ParamName;
        ibdsPrMetal.FieldByName('Description').AsString := Description;
        ibdsPrMetal.Post;
      end;
    finally
      Free;
    end;
end;

procedure TdlgSelectPrMetal.actDelPrMetalExecute(Sender: TObject);
begin
  if ibdsPrMetal.FieldByName('Name').AsString = '' then exit;
  if MessageBox(HANDLE, PChar(Format('Óäàëèòü äğàãìåòàëë ''%s''?', [ibdsPrMetal.FieldByName('name').AsString])),
    'Âíèìàíèå',
     mb_YesNo or mb_IconQuestion) = idYes
  then
    try
      ibdsPrMetal.Delete;
    except
      MessageBox(HANDLE, 'Íåâîçìîæíî óäàëèòü òåêóùèé äğàãìåòàëë, ò.ê. îí óæå èñïîëüçóåòñÿ.',
        'Âíèìàíèå', mb_Ok or mb_IconExclamation);
    end;
end;

procedure TdlgSelectPrMetal.FormCreate(Sender: TObject);
begin
  GlobalStorage.LoadComponent(gsibgrPrMetal, gsibgrPrMetal.LoadFromStream);
end;

procedure TdlgSelectPrMetal.FormDestroy(Sender: TObject);
begin
  GlobalStorage.SaveComponent(gsibgrPrMetal, gsibgrPrMetal.SaveToStream);
end;

procedure TdlgSelectPrMetal.actEditPrMetalUpdate(Sender: TObject);
begin
  actEditPrMetal.Enabled := ibdsPrMetal.FieldByName('Name').AsString > '';
end;

procedure TdlgSelectPrMetal.actDelPrMetalUpdate(Sender: TObject);
begin
  actDelPrMetal.Enabled := ibdsPrMetal.FieldByName('Name').AsString > '';
end;

end.
