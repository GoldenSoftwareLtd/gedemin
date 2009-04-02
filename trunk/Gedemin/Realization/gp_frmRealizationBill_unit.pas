unit gp_frmRealizationBill_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_frmMDHIBF_unit, Menus, flt_sqlFilter, Db, IBCustomDataSet, IBDatabase,
  ActnList,  ComCtrls, ToolWin, StdCtrls, ExtCtrls, Grids,
  DBGrids, gsDBGrid, gsIBGrid, IBSQL, at_sql_setup, gsReportRegistry,
  dmDatabase_unit, gd_Security, contnrs,  gsReportManager,
  gdcBase, gdcConst;

type
  TfrmRealizationBill = class(Tgd_frmMDHIBF)
    pPrintMenu: TPopupMenu;
    atSQLSetup: TatSQLSetup;
    actDetailBill: TAction;
    actOption: TAction;
    ToolButton8: TToolButton;
    actEntry: TAction;
    gsQueryFilter: TgsQueryFilter;
    gsQFDetailPosReal: TgsQueryFilter;
    dsPrintDocRealPos: TDataSource;
    ibdsPrintDocRealPos: TIBDataSet;
    ibsqlUpdateGroupPrint: TIBSQL;
    ibsqlDocRealInfo: TIBSQL;
    ibsqlOurFirm: TIBSQL;
    ibsqlCustomer: TIBSQL;
    ibsqlDocReal: TIBSQL;
    pmMenu: TPopupMenu;
    actCheckContract: TAction;
    N1: TMenuItem;
    tbNew: TToolBar;
    tbDetail: TToolButton;
    ToolButton3: TToolButton;
    tbOption: TToolButton;
    tbEntry: TToolButton;
    procedure actNewExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actPrintExecute(Sender: TObject);
    procedure actDetailBillExecute(Sender: TObject);
    procedure actOptionExecute(Sender: TObject);
    procedure actEntryExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actDuplicateExecute(Sender: TObject);
    procedure actCheckContractExecute(Sender: TObject);
    procedure actFilterExecute(Sender: TObject);
  private
    { Private declarations }
    FCurDocumentKey: Integer;
    function EditDocument(const aDocumentKey, aCopyBill: Integer): Boolean;
    procedure SetDocRealPos;
  protected
    FTypeDocumentKey: Integer;
    procedure InternalOpenMain; override;
    function GetTypeDocumentKey: Integer; virtual;
    function CreateEditDialog: TForm; virtual;
    procedure DestroyEditDialog; virtual;
  public
    { Public declarations }
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  frmRealizationBill: TfrmRealizationBill;

implementation

{$R *.DFM}

uses gp_dlgRealizationBill_unit, gp_dlgRealizatoinOption_unit, gp_dlgDetailBill_unit,
  gp_dlgMakeEntry_unit, gp_dlgBill_unit;

{ TfrmRealizationBill }

class function TfrmRealizationBill.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(frmRealizationBill) then
    frmRealizationBill := TfrmRealizationBill.Create(AnOwner);

  Result := frmRealizationBill;

end;

function TfrmRealizationBill.EditDocument(const aDocumentKey, aCopyBill: Integer): Boolean;
begin
  with CreateEditDialog as Tgp_dlgBill do
  begin
    SetupDialog(aDocumentKey, aCopyBill);
    Result := ShowModal = mrOk;
    if Result then
      FCurDocumentKey := DocumentKey;
  end;


end;

procedure TfrmRealizationBill.InternalOpenMain;
begin
  SetDocRealPos;

  ibdsMain.Close;

  ibdsMain.ParamByName('dt').AsInteger := GetTypeDocumentKey;
  ibdsMain.Open;
  ibdsMain.Close;
  inherited;
end;

procedure TfrmRealizationBill.SetDocRealPos;
var
  ibsql: TIBSQL;
  S, S1: String;

function InsertTax(const SQLText, TaxField, AmountField: String; IncludeTax: Boolean): String;
begin
  Result := SQLText;

  if not IncludeTax then
  begin
    Insert(
      Format(
       'CAST(%s / (%s + 0.0001) * 100 as INTEGER) as %0:sPERC,',
       [Trim(TaxField), Trim(AmountField)]),
       Result, Pos('SELECT', UpperCase(SQLText)) + 6);
    Insert(Format(' %s + %s as E%1:s, ', [Trim(AmountField), Trim(TaxField)]),
      Result, Pos('SELECT', UpperCase(SQLText)) + 6);
  end
  else
  begin
    Insert(
      Format(
       'CAST(%s / (%s - %0:s + 0.0001) * 100 as INTEGER) as %0:sPERC,',
       [Trim(TaxField), Trim(AmountField)]),
       Result, Pos('SELECT', UpperCase(SQLText)) + 6);
    Insert(Format(' %s - %s as E%1:s, ', [Trim(AmountField), Trim(TaxField)]),
      Result, Pos('SELECT', UpperCase(Result)) + 6);
  end;
end;

begin
  ibsql := TIBSQL.Create(Self);
  try
    S := ibdsDetails.SelectSQL.Text;
    S1 := ibdsPrintDocRealPos.SelectSQL.Text;
    ibsql.Transaction := IBTransaction;
    ibsql.SQL.Text := 'SELECT * FROM gd_docrealposoption WHERE relationname = ''GD_DOCREALPOS''';
    ibsql.ExecQuery;
    while not ibsql.Eof do
    begin
      if ibsql.FieldByName('iscurrency').AsInteger = 1 then
      begin
        S := InsertTax(S, ibsql.FieldByName('fieldname').AsString, 'AMOUNTCURR',
               (ibsql.FieldByName('includetax').AsInteger = 1));
        S1 := InsertTax(S1, ibsql.FieldByName('fieldname').AsString, 'AMOUNTCURR',
               (ibsql.FieldByName('includetax').AsInteger = 1));
      end
      else
      begin
        S := InsertTax(S, ibsql.FieldByName('fieldname').AsString, 'AMOUNTNCU',
               (ibsql.FieldByName('includetax').AsInteger = 1));
        S1 := InsertTax(S1, ibsql.FieldByName('fieldname').AsString, 'AMOUNTNCU',
               (ibsql.FieldByName('includetax').AsInteger = 1));
      end;

      ibsql.Next;
    end;
    ibsql.Close;
    ibdsDetails.SelectSQL.Text := S;
    ibdsPrintDocRealPos.SelectSQL.Text := S1;
  finally
    ibsql.Free;
  end;
end;

procedure TfrmRealizationBill.actNewExecute(Sender: TObject);
begin
  { Добавление нового документа }
  if EditDocument(-1, -1) then
  begin
    ibdsMain.Close;
    ibdsMain.Open;
    ibdsMain.Locate('documentkey', FCurDocumentKey, []);

    ibdsDetails.Close;
    ibdsDetails.Open;
  end;

end;

procedure TfrmRealizationBill.actEditExecute(Sender: TObject);
begin
  { Изменение существующего документа }
  if EditDocument(ibdsMain.FieldByName('documentkey').AsInteger, -1) then
  begin
    ibdsMain.Refresh;

    ibdsDetails.Close;
    ibdsDetails.Open;
  end;

end;

procedure TfrmRealizationBill.actDeleteExecute(Sender: TObject);
begin
  { Удаление существующего документа }
  if MessageBox(HANDLE, PChar(Format('Удалить документ ''%s''?',
    [ibdsMain.FieldbyName('Number').AsString])),
    'Внимание', mb_YesNo or mb_IconQuestion) = id_Yes
  then
  begin
    ibdsMain.Delete;
    IBTransaction.CommitRetaining;
  end;
end;

procedure TfrmRealizationBill.actPrintExecute(Sender: TObject);
begin
  {}
end;

type
  TTaxInfo = class
    FTaxName: String;
    FStavka: Integer;
    FAmount: Currency;
    constructor Create(const aTaxName: String; aStavka: Integer; aAmount: Currency);
  end;

constructor TTaxInfo.Create(const aTaxName: String; aStavka: Integer; aAmount: Currency);
begin
  FTaxName := aTaxName;
  FStavka := aStavka;
  FAmount := aAmount;
end;

procedure TfrmRealizationBill.actDetailBillExecute(Sender: TObject);
begin
  with TdlgDetailBill.Create(Self) do
    try
      ShowModal;
      if Ok then
      begin
        ibdsMain.Close;
        ibdsMain.Open;
        ibdsDetails.Close;
        ibdsDetails.Open;
      end;
    finally
      Free;
    end;
end;

procedure TfrmRealizationBill.actOptionExecute(Sender: TObject);
begin
  with TdlgRealizatoinOption.Create(Self) do
    try
      SetupDialog;
      ShowModal;
    finally
      Free;
    end;

end;

procedure TfrmRealizationBill.actEntryExecute(Sender: TObject);
begin
  with TdlgMakeEntry.Create(Self) do
    try
      DocumentTypeKey := GetTypeDocumentKey;
      ShowModal;
    finally
      Free;
    end;
end;

procedure TfrmRealizationBill.FormDestroy(Sender: TObject);
begin
  DestroyEditDialog;
  inherited;
end;

procedure TfrmRealizationBill.DestroyEditDialog;
begin
  dlgRealizationBill := nil;
//  if Assigned() then
//    FreeAndNil(dlgRealizationBill);
end;

procedure TfrmRealizationBill.actDuplicateExecute(Sender: TObject);
var
  aCopyBill: Integer;
begin
  if ibdsMain.FieldByName('documentkey').AsInteger > 0 then
    aCopyBill := ibdsMain.FieldByName('documentkey').AsInteger
  else
    aCopyBill := -1;

  if EditDocument(-1, aCopyBill) then
  begin
    ibdsMain.Close;
    ibdsMain.Open;
    ibdsMain.Locate('documentkey', FCurDocumentKey, []);

    ibdsDetails.Close;
    ibdsDetails.Open;
  end;

end;

function TfrmRealizationBill.GetTypeDocumentKey: Integer;
begin
  FTypeDocumentKey := 802001;
  Result := FTypeDocumentKey;
end;

function TfrmRealizationBill.CreateEditDialog: TForm;
begin
  Result := TdlgRealizationBill.CreateAndAssign(Self);
end;

procedure TfrmRealizationBill.actCheckContractExecute(Sender: TObject);
var
  ibsql: TIBSQL;
begin
  if MessageBox(HANDLE, 'Данная процедура может занять продолжительное время. Продолжить?',
     'Внимание', mb_YesNo or mb_IconInformation) = idNo
  then
    exit;
  ibsql := TIBSQL.Create(Self);
  try

    ibsql.Transaction := IBTransaction;
    ibsql.SQL.Text :=
      '    UPDATE gd_docrealinfo doci ' +
      'SET doci.contractkey  = ' +
      '(SELECT MAX(c.documentkey) FROM gd_docrealization docr JOIN ' +

      '  gd_contract c ON docr.tocontactkey = c.contactkey and ' +
      '   docr.documentkey = doci.documentkey) ' +
      'WHERE doci.contractkey IS NULL ';
    ibsql.ExecQuery;
    
    ibsql.Close;
    IBTransaction.CommitRetaining;
    ibsql.SQL.Text :=
      'UPDATE gd_docrealinfo doci ' +
      'SET doci.contractnum = ' +
      ' (SELECT CAST(''№ '' || doc.number || '' от '' || CAST(doc.documentdate AS VARCHAR(11)) AS VARCHAR(40))' +
      '  FROM gd_document doc where doc.id = doci.contractkey) ' +
      'WHERE doci.contractnum = '''' or doci.contractnum IS NULL ';
    ibsql.ExecQuery;
    ibsql.Close;
    IBTransaction.CommitRetaining;
  finally
    ibsql.Free;
  end;

end;

procedure TfrmRealizationBill.actFilterExecute(Sender: TObject);
begin
  gsQueryFilter.PopupMenu;
end;

initialization
  RegisterClass(TfrmRealizationBill);


end.


