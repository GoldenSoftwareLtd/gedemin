unit gp_frmpriceoption_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ToolWin, ExtCtrls, ActnList, Grids, DBGrids, gsDBGrid,
  gsIBGrid, Db, IBDatabase, IBCustomDataSet, dmDatabase_unit, IBSQL;

type
  TfrmPriceOption = class(TForm)
    CoolBar1: TCoolBar;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    Panel1: TPanel;
    ActionList1: TActionList;
    actNewOption: TAction;
    actEditOption: TAction;
    actDelOption: TAction;
    dsPricePosOption: TDataSource;
    gsibgrPricePosOption: TgsIBGrid;
    ibdsPricePosOption: TIBDataSet;
    IBTransaction: TIBTransaction;
    procedure FormCreate(Sender: TObject);
    procedure actNewOptionExecute(Sender: TObject);
    procedure actEditOptionExecute(Sender: TObject);
    procedure actDelOptionExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPriceOption: TfrmPriceOption;

implementation

{$R *.DFM}

uses
  gp_dlgpriceoption_unit, Storages;

procedure TfrmPriceOption.FormCreate(Sender: TObject);
begin
  if not IBTransaction.InTransaction then
    IBTransaction.StartTransaction;

  UserStorage.LoadComponent(gsibgrPricePosOption, gsibgrPricePosOption.LoadFromStream);

  ibdsPricePosOption.Open;
  ibdsPricePosOption.FieldByName('NAME').Required := False;
end;

procedure TfrmPriceOption.actNewOptionExecute(Sender: TObject);
begin
  with TdlgPriceOption.Create(Self) do
    try
      SetupDialog(ibdsPricePosOption, True);
    finally
      Free;
    end;
end;

procedure TfrmPriceOption.actEditOptionExecute(Sender: TObject);
begin
  with TdlgPriceOption.Create(Self) do
    try
      if SetupDialog(ibdsPricePosOption, False) then
        ibdsPricePosOption.Refresh;
    finally
      Free;
    end;
end;

procedure TfrmPriceOption.actDelOptionExecute(Sender: TObject);
begin
  if MessageBox(Handle, 'Удалить поле?', 'Внимание!', MB_YESNO or MB_ICONQUESTION) =
    ID_YES then
  begin
    ibdsPricePosOption.Delete;
    IBTransaction.CommitRetaining;
  end;
end;

procedure TfrmPriceOption.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  UserStorage.SaveComponent(gsibgrPricePosOption, gsibgrPricePosOption.SaveToStream);
end;

end.
