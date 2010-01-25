unit gp_frmPrice_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_frmMDHIBF_unit, Menus, flt_sqlFilter, Db, IBCustomDataSet, IBDatabase,
  ActnList,   ComCtrls, ToolWin, StdCtrls,
  ExtCtrls, Grids, DBGrids, gsDBGrid, gsIBGrid, at_sql_setup,
  gsReportRegistry, gd_security, gsReportManager, gdcBase, gdcConst;

type
  TfrmPrice = class(Tgd_frmMDHIBF)
    gsReportRegistry: TgsReportRegistry;
    atSQLSetup: TatSQLSetup;
    pmPrint: TPopupMenu;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    actOption: TAction;
    gsPriceFilter: TgsQueryFilter;
    gsPriceDetFilter: TgsQueryFilter;
    Label1: TLabel;
    procedure actNewExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actDuplicateExecute(Sender: TObject);
    procedure actDetailDeleteExecute(Sender: TObject);
    procedure actOptionExecute(Sender: TObject);
    procedure gsQFMainFilterChanged(Sender: TObject;
      const AnCurrentFilter: Integer);
    procedure gsQFDetailFilterChanged(Sender: TObject;
      const AnCurrentFilter: Integer);
    procedure actFilterExecute(Sender: TObject);
  private
    { Private declarations }
    procedure EditPrice(const aPriceKey, aCopyPriceKey: Integer);
    procedure DelPrice;
    procedure DelPricePos;
  public
    { Public declarations }
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  frmPrice: TfrmPrice;

implementation

{$R *.DFM}

uses gp_frmpriceoption_unit, gp_dlgPrice_unit;

{ TfrmPrice }

class function TfrmPrice.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(frmPrice) then
    frmPrice := TfrmPrice.Create(AnOwner);

  Result := frmPrice;
end;

procedure TfrmPrice.DelPrice;
begin
  if not ibdsMain.FieldByName('ID').IsNull and
    (MessageBox(HANDLE, PChar(Format('Удалить ''%s''?',
    [ibdsMain.FieldByName('name').AsString])), 'Внимание', mb_YesNo or mb_IconQuestion) = idYes)
  then
  begin
    try
      ibdsMain.Delete;
      IBTransaction.CommitRetaining;
    except
    end;
  end;
end;

procedure TfrmPrice.DelPricePos;
begin
  if not ibdsDetails.FieldByName('ID').IsNull and
    (MessageBox(HANDLE, PChar(Format('Удалить позицию ''%s'' в прайс-листе?',
    [ibdsDetails.FieldByName('name').AsString])),
    'Внимание',
     mb_YesNo or mb_IconQuestion) = idYes)
  then
  begin
    ibdsDetails.Delete;
    ibdsDetails.Transaction.CommitRetaining;
  end;  
end;

procedure TfrmPrice.EditPrice(const aPriceKey, aCopyPriceKey: Integer);
var
  isOk: Boolean;
  aID: Integer;
begin
  with TdlgPrice.Create(Self) do
    try
      SetupDialog(aPriceKey, aCopyPriceKey);
      isOk := ShowModal = mrOK;
      aID := PriceKey;
    finally
      Free;
    end;

  if isOk then
  begin
    if aPriceKey <> -1 then
      ibdsMain.Refresh
    else
    begin
      ibdsMain.Close;
      ibdsMain.Open;
      ibdsMain.Locate('ID', aID, []);
    end;
    ibdsDetails.Close;
    ibdsDetails.Open;
  end;
end;

procedure TfrmPrice.actNewExecute(Sender: TObject);
begin
  EditPrice(-1, -1);
end;

procedure TfrmPrice.actEditExecute(Sender: TObject);
begin
  EditPrice(ibdsMain.FieldByName('id').AsInteger, -1);
end;

procedure TfrmPrice.actDeleteExecute(Sender: TObject);
begin
  DelPrice;
end;

procedure TfrmPrice.actDuplicateExecute(Sender: TObject);
begin
  EditPrice(-1, ibdsMain.FieldByName('id').AsInteger);
end;

procedure TfrmPrice.actDetailDeleteExecute(Sender: TObject);
begin
  DelPricePos;
end;

procedure TfrmPrice.actOptionExecute(Sender: TObject);
begin
  with TfrmPriceOption.Create(Self) do
    try
      ShowModal;
    finally
      Free;
    end;
end;

procedure TfrmPrice.gsQFMainFilterChanged(Sender: TObject;
  const AnCurrentFilter: Integer);
begin
  sbMain.SimpleText := gsPriceFilter.FilterName +
    ', ' +
    gsPriceDetFilter.FilterName;
end;

procedure TfrmPrice.gsQFDetailFilterChanged(Sender: TObject;
  const AnCurrentFilter: Integer);
begin
  sbMain.SimpleText := gsPriceFilter.FilterName +
    ', ' +
    gsPriceDetFilter.FilterName;
end;

procedure TfrmPrice.actFilterExecute(Sender: TObject);
begin
  gsPriceFilter.PopupMenu;

end;

initialization
  RegisterClass(TfrmPrice);


end.
