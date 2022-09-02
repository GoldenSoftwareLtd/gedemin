// ShlTanya, 30.01.2019

unit bn_frmCurrCommission_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_frmSIBF_unit, gsReportManager, flt_sqlFilter, Db, IBCustomDataSet,
  IBDatabase, Menus, ActnList, ComCtrls,
  ToolWin, ExtCtrls, Grids, DBGrids, gsDBGrid, gsIBGrid, StdCtrls,
  gsIBLookupComboBox, at_sql_setup, dmDatabase_unit;

type
  Tbn_frmCurrCommission = class(Tgd_frmSIBF)
    tbAccount: TToolBar;
    atSQLSetup: TatSQLSetup;
    gsqfCurrCommiss: TgsQueryFilter;
    Panel1: TPanel;
    Label1: TLabel;
    gsibluAccount: TgsIBLookupComboBox;
    actPrintOptions: TAction;
    N1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure gsibluAccountChange(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actNewExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actPrintOptionsExecute(Sender: TObject);
  private
    { Private declarations }
    CurrDocumentKey: TID;
    procedure Add;
    procedure Edit;
  protected
    procedure InternalStartTransaction; override;
    procedure InternalOpenMain; override;
    function GetDocumentType: TID; virtual;
  public
    { Public declarations }
    function Get_SelectedKey: OleVariant; override;
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;

  end;

var
  bn_frmCurrCommission: Tbn_frmCurrCommission;

implementation

{$R *.DFM}

uses gd_security, gsDesktopManager,
     bn_dlgCurrCommission, gd_security_OperationConst, bn_dlgPrintOptions_unit;

class function Tbn_frmCurrCommission.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(bn_frmCurrCommission) then
    bn_frmCurrCommission := Tbn_frmCurrCommission.Create(AnOwner);

  Result := bn_frmCurrCommission;

end;

function Tbn_frmCurrCommission.Get_SelectedKey: OleVariant;
var
  A: Variant;
  I: Integer;
  Mark: TBookmark;

begin
  if not (ibdsMain.Active and (ibdsMain.RecordCount > 0)) then
    Result := VarArrayOf([])
  else
    if ibgrMain.SelectedRows.Count = 0 then
      Result := VarArrayOf(GetTID([ibdsMain.FieldByName('documentkey'))])
    else
    begin
      A := VarArrayCreate([0, ibgrMain.SelectedRows.Count - 1], varVariant);
      Mark := ibdsMain.GetBookmark;
      ibdsMain.DisableControls;

      for I := 0 to ibgrMain.SelectedRows.Count - 1 do
      begin
        ibdsMain.GotoBookMark(Pointer(ibgrMain.SelectedRows.Items[I]));
        A[I] := GetTID(ibdsMain.FieldByName('documentkey'));
      end;
      ibdsMain.GotoBookMark(Mark);
      ibdsMain.EnableControls;

      Result := A;
    end;

end;


procedure Tbn_frmCurrCommission.InternalOpenMain;
begin
  ibdsMain.Close;

  ibdsMain.SelectSQL.Text :=
    ' SELECT D.ID, D.NUMBER, D.DOCUMENTDATE, ' +
    '   CC.*, C.name as currname, c.shortname as currshortname ' +
    ' FROM bn_currcommission cc ' +
    '  JOIN GD_DOCUMENT D ON D.ID = CC.DOCUMENTKEY ' +
    ' JOIN GD_COMPANYACCOUNT CA ON CA.ID = CC.ACCOUNTKEY ' +
    ' LEFT JOIN GD_CURR C ON C.ID = CA.CURRKEY ' +
    ' WHERE D.COMPANYKEY = :CompanyKey AND D.DOCUMENTTYPEKEY = :DT ';

  if gsibluAccount.CurrentKey > '' then
   ibdsMain.SelectSQL.Text := ibdsMain.SelectSQL.Text +
     ' AND  CC.ACCOUNTKEY = :ID ';

  ibdsMain.Prepare;

  SetTID(ibdsMain.Params.ByName('CompanyKey'), IBLogin.CompanyKey);

  SetTID(ibdsMain.ParamByName('dt'), GetDocumentType);

  if gsibluAccount.CurrentKey > '' then
    SetTID(ibdsMain.Params.ByName('ID'), gsibluAccount.CurrentKeyInt);
  ibdsMain.Open;

  if CurrDocumentKey <> -1 then
    ibdsMain.Locate('DOCUMENTKEY', CurrDocumentKey, []);

end;

procedure Tbn_frmCurrCommission.FormCreate(Sender: TObject);
begin
  gsibluAccount.Condition := Format('companykey=%d', [TID264(IBLogin.CompanyKey)]);
  CurrDocumentKey := -1;
  
  inherited;

end;

procedure Tbn_frmCurrCommission.gsibluAccountChange(Sender: TObject);
begin
  InternalOpenMain;
end;

procedure Tbn_frmCurrCommission.Add;
begin
  with TdlgCurrCommission.Create(Self) do
  try
    if gsibluAccount.CurrentKey > '' then
      Account := gsibluAccount.CurrentKeyInt;

    Add(ibdsMain);

    if ShowModal = mrOK then
      CurrDocumentKey := ID
    else
      CurrDocumentKey := -1;
  finally
    Free;
  end;
  if CurrDocumentKey <> -1 then
    InternalOpenMain;
end;


procedure Tbn_frmCurrCommission.Edit;
begin
  with TdlgCurrCommission.Create(Self) do
  try
    ID := GetTID(ibdsMain.FieldByName('DOCUMENTKEY'));

    if gsibluAccount.CurrentKey > '' then
      Account := gsibluAccount.CurrentKeyInt;

    Edit(ibdsMain);

    if ShowModal = mrOK then
      ibdsMain.Refresh;
  finally
    Free;
  end;

end;

procedure Tbn_frmCurrCommission.actDeleteExecute(Sender: TObject);
var
  i: Integer;
begin
  if ibgrMain.SelectedRows.Count = 0 then
  begin
    if MessageBox(Handle, PChar(Format('Удалить документ № ''%s''?', [ibdsMain.FieldByName('number').AsString])),
      'Внимание', MB_ICONQUESTION or MB_YESNO) =
      ID_YES then
    begin
      ibdsMain.Delete;
      IBTransaction.CommitRetaining;
    end;
  end
  else
    if MessageBox(Handle, 'Удалить выделенные документы?',
      'Внимание', MB_ICONQUESTION or MB_YESNO) =
      ID_YES then
    begin
      for i:= 0 to ibgrMain.SelectedRows.Count - 1 do
      begin
        ibdsMain.GotoBookmark(TBookmark(ibgrMain.SelectedRows[i]));
        ibdsMain.Delete;
      end;
      IBTransaction.CommitRetaining;
    end;
end;

function Tbn_frmCurrCommission.GetDocumentType: TID;
begin
  Result := BN_DOC_CURRCOMMISION;
end;

procedure Tbn_frmCurrCommission.actNewExecute(Sender: TObject);
begin
  Add;

end;

procedure Tbn_frmCurrCommission.actEditExecute(Sender: TObject);
begin
  Edit;
end;

procedure Tbn_frmCurrCommission.InternalStartTransaction;
begin
  inherited;
  gsibluAccount.CurrentKey := CompanyStorage.ReadString('Bank', 'CurrentAccount', '');
end;

procedure Tbn_frmCurrCommission.actPrintOptionsExecute(Sender: TObject);
begin
  with TdlgPrintOptions.CreateAndAssign(Self) do
  begin
    ShowModal;
  end;
end;

initialization
  RegisterClass(Tbn_frmCurrCommission);


end.
