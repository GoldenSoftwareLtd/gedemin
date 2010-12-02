unit gp_frmContractSelll_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_frmSIBF_unit, Menus, flt_sqlFilter, Db, IBCustomDataSet, IBDatabase,
  ActnList,  ComCtrls, ToolWin, StdCtrls, ExtCtrls, Grids,
  DBGrids, gsDBGrid, gsIBGrid, at_sql_setup, gsReportManager,
  dmImages_unit;

type
  TfrmContractSell = class(Tgd_frmSIBF)
    ibdsContract: TIBDataSet;
    gsqryContract: TgsQueryFilter;
    atSQLSetup1: TatSQLSetup;
    procedure actNewExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actDeleteUpdate(Sender: TObject);
    procedure actFilterExecute(Sender: TObject);
  private
    { Private declarations }
    FContractKey: Integer;
    function EditContract(const aContractKey: Integer): Boolean;
  public
    { Public declarations }
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
    procedure InternalOpenMain; override;
  end;

var
  frmContractSell: TfrmContractSell;

implementation

{$R *.DFM}

uses gp_dlgContractSell_unit;

procedure TfrmContractSell.actNewExecute(Sender: TObject);
begin
  if EditContract(-1) then
  begin
    ibdsContract.Close;
    ibdsContract.Open;
    ibdsContract.Locate('id', IntToStr(FContractKey), []);
  end;
end;

function TfrmContractSell.EditContract(
  const aContractKey: Integer): Boolean;
begin
  with Tdlg_gpContractSell.Create(Self) do
    try
      SetupDialog(aContractKey, -1);
      ShowModal;
      Result := isOK;
      if Result then
        FContractKey := DocumentKey;
    finally
      Free;
    end;
end;

procedure TfrmContractSell.actEditExecute(Sender: TObject);
begin
  if EditContract(ibdsContract.FieldByName('id').AsInteger) then
    ibdsContract.Refresh;
end;

class function TfrmContractSell.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(frmContractSell) then
    frmContractSell := TfrmContractSell.Create(AnOwner);

  Result := frmContractSell;

end;

procedure TfrmContractSell.InternalOpenMain;
begin
  ibdsContract.Open;
end;

procedure TfrmContractSell.actDeleteExecute(Sender: TObject);
begin
  if MessageBox(Handle,
    'Вы действительно желаете удалить текущую запись?',
    'Внимание',
    MB_YESNO or MB_ICONQUESTION) = IDYES then
  begin
    ibdsContract.Delete;
  end;
end;

procedure TfrmContractSell.actDeleteUpdate(Sender: TObject);
begin
  actDelete.Enabled := ibdsContract.Active and (lmDelete in ibdsContract.LiveMode) and
    (not ibdsContract.IsEmpty);
end;

procedure TfrmContractSell.actFilterExecute(Sender: TObject);
begin
  gsqryContract.PopupMenu;
end;

initialization
  RegisterClass(TfrmContractSell);


end.
