unit gp_frmNewDemand_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  bn_frmDemand_unit, Db, DBClient, Menus, IBCustomDataSet, flt_sqlFilter,
  gsReportRegistry, xReport, at_sql_setup, ImgList, NumConv,
   IBDatabase, ActnList, StdCtrls, gsIBLookupComboBox,
  ExtCtrls, Grids, DBGrids, gsDBGrid, gsIBGrid, ComCtrls, ToolWin,
  gd_Security, gsReportManager;

type
  TfrmNewDemand = class(Tbn_frmDemand)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    CodeBills: TStrings;
    procedure ShowPayment(ID: Integer);  reintroduce;
  end;

var
  frmNewDemand: TfrmNewDemand;

implementation

{$R *.DFM}

{ TfrmNewDemand }

procedure TfrmNewDemand.ShowPayment(ID: Integer);
var
  i: Integer;
  S: String;
begin
  if not Assigned(CodeBills) then exit;

  ibdsDemandPayment.Close;
  ibdsDemandPayment.SelectSQL.Text :=
    ' SELECT D.NUMBER, D.DOCUMENTDATE, D.TRTYPEKEY, DP.* ' +
    ' FROM GD_DOCUMENT D, BN_DEMANDPAYMENT DP ' +
    ' WHERE D.ID = DP.DOCUMENTKEY ' +
    '     AND D.DocumentTypeKey = 800200 ' +
    '     AND D.COMPANYKEY = :CompanyKey ' +
    '     AND D.ID IN (SELECT DL.destdockey FROM gd_documentlink dl WHERE ' +
    '         DL.SOURCEDOCKEY IN  ';
  S := '(';
  for i:= 0 to CodeBills.Count - 1 do
  begin
    S := S + CodeBills[i];
    if i <> CodeBills.Count - 1 then
      S := S + ',';
  end;
  S := S + '))';
  ibdsDemandPayment.SelectSQL.Text := ibdsDemandPayment.SelectSQL.Text + S;
  
  if gsibluAccount.CurrentKey > '' then
    ibdsDemandPayment.SelectSQL.Text := ibdsDemandPayment.SelectSQL.Text +
    ' AND DP.ACCOUNTKEY = :ID';

  ibdsDemandPayment.Prepare;
  ibdsDemandPayment.Params.ByName('CompanyKey').AsInteger :=
    IBLogin.CompanyKey;
  if gsibluAccount.CurrentKey > '' then
    ibdsDemandPayment.Params.ByName('ID').AsInteger :=
      gsibluAccount.CurrentKeyInt;
  ibdsDemandPayment.Open;

  if ID <> -1 then
    ibdsDemandPayment.Locate('DOCUMENTKEY', ID, []);
end;

procedure TfrmNewDemand.FormCreate(Sender: TObject);
begin
  CodeBills := nil;
  inherited;
end;

end.
