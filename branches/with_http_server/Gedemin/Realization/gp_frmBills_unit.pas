unit gp_frmBills_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gp_frmRealizationBill_unit, gsReportManager, Menus, IBSQL, at_sql_setup,
  gsReportRegistry, flt_sqlFilter, Db, IBCustomDataSet, IBDatabase,
  ActnList,   StdCtrls, ComCtrls, ToolWin,
  ExtCtrls, Grids, DBGrids, gsDBGrid, gsIBGrid;

type
  TfrmBills = class(TfrmRealizationBill)
    tbBill: TToolBar;
    tbCheck: TToolButton;
    actGiveBill: TAction;
    procedure actGiveBillExecute(Sender: TObject);
  private
    { Private declarations }
    procedure IsPermitText(Sender: TField; var Text: String; DisplayText: Boolean);
  protected
    function GetTypeDocumentKey: Integer; override;
    function CreateEditDialog: TForm; override;
    procedure InternalOpenMain; override;
    procedure DestroyEditDialog; override;
  public
    { Public declarations }
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  frmBills: TfrmBills;

implementation

{$R *.DFM}

uses gp_dlgBill_unit;

{ TfrmBills }

class function TfrmBills.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(frmBills) then
    frmBills := TfrmBills.Create(AnOwner);


  Result := frmBills;

end;

function TfrmBills.CreateEditDialog: TForm;
begin

  Result := Tgp_dlgBill.CreateAndAssign(Self);

end;

function TfrmBills.GetTypeDocumentKey: Integer;
begin
  FTypeDocumentKey := 802004;
  Result := FTypeDocumentKey;
end;

procedure TfrmBills.actGiveBillExecute(Sender: TObject);
begin
  inherited;
  if MessageBox(HANDLE,
    PChar(Format('Установить разрешение на выдачу с\ф № %s от %s',
    [ibdsMain.FieldByName('Number').AsString, ibdsMain.FieldByName('documentdate').AsString])),
    'Внимание', mb_YesNo or mb_IconQuestion) = idYes
  then
  begin
    ibdsMain.Edit;
    ibdsMain.FieldByName('ispermit').AsInteger := 1;
    ibdsMain.Post;
    ibdsMain.Transaction.CommitRetaining;
  end;
end;

procedure TfrmBills.InternalOpenMain;
begin
  inherited;
  if ibdsMain.Active then
    ibdsMain.FieldByName('isPermit').OnGetText := IsPermitText;
end;

procedure TfrmBills.IsPermitText(Sender: TField; var Text: String;
  DisplayText: Boolean);
begin
  if Sender.AsInteger = 1 then
    Text := 'Да'
  else
    if not Sender.IsNull then
      Text := 'Нет';
end;

procedure TfrmBills.DestroyEditDialog;
begin
//  if Assigned(gp_dlgBill) then
//    FreeAndNil(gp_dlgBill);
  gp_dlgBill := nil;
end;

initialization
  RegisterClass(TfrmBills);

end.
