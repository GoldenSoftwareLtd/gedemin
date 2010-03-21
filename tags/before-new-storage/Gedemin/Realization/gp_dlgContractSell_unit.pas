unit gp_dlgContractSell_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DBCtrls, Mask, xDateEdits, gsIBLookupComboBox, IBDatabase, Db,
  IBCustomDataSet, dmDatabase_unit, gsDocNumerator, gd_createable_form,
  at_Container, ComCtrls, at_sql_setup;

type
  Tdlg_gpContractSell = class(TCreateableForm)
    bOk: TButton;
    bNext: TButton;
    ibdsContract: TIBDataSet;
    IBTransaction: TIBTransaction;
    dsContract: TDataSource;
    ibdsDocument: TIBDataSet;
    dsDocument: TDataSource;
    bCancel: TButton;
    gsDocNumerator: TgsDocNumerator;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    lContact: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label1: TLabel;
    gsiblcContact: TgsIBLookupComboBox;
    dbedNumber: TDBEdit;
    xdbedDocumentDate: TxDateDBEdit;
    dbmDescription: TDBMemo;
    dbedPercent: TDBEdit;
    atContainer1: TatContainer;
    atSQLSetup1: TatSQLSetup;
    procedure bOkClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure bNextClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FDocumentKey: Integer;
    FCustomerKey: Integer;
    FIsOk: Boolean;
    FDocumentInfo: String;

    procedure AppendDocument;
    procedure EditDocument;
    function Save: Boolean;
  public
    { Public declarations }
    procedure SetupDialog(const aDocumentKey, aCustomerKey: Integer);
    property isOK: Boolean read FIsOk;
    property DocumentKey: Integer read FDocumentKey;
    property DocumentInfo: String read FDocumentInfo;
  end;

var
  dlg_gpContractSell: Tdlg_gpContractSell;

implementation

{$R *.DFM}

{ Tdlg_gpContractSell }

procedure Tdlg_gpContractSell.AppendDocument;
begin
  FDocumentKey := GenUniqueID;
  ibdsDocument.Open;
  ibdsContract.Open;

  ibdsDocument.Insert;
  ibdsDocument.FieldByName('id').AsInteger := FDocumentKey;

  ibdsContract.Insert;
  ibdsContract.FieldByName('documentkey').AsInteger := FDocumentKey;

  if FCustomerKey <> -1 then
  begin
    ibdsContract.FieldByName('contactkey').AsInteger := FCustomerKey;
    gsiblcContact.Enabled := False;
    lContact.Enabled := False;
  end;  
end;

procedure Tdlg_gpContractSell.EditDocument;
begin
  ibdsDocument.ParamByName('dk').AsInteger := FDocumentKey;
  ibdsDocument.Open;

  ibdsContract.ParamByName('dk').AsInteger := FDocumentKey;
  ibdsContract.Open;

  bNext.Enabled := False;
end;

function Tdlg_gpContractSell.Save: Boolean;
begin
  Result := True;
  try
    if ibdsDocument.State in [dsEdit, dsInsert] then
      ibdsDocument.Post;

    if ibdsContract.State in [dsEdit, dsInsert] then
      ibdsContract.Post;

    FDocumentInfo := Format('N %s от %s', [ibdsDocument.FieldByName('Number').AsString,
      ibdsDocument.FieldByName('documentdate').AsString]);  

    if IBTransaction.InTransaction then
      IBTransaction.Commit;
  except
    on E: Exception do
    begin
      MessageBox(HANDLE, PChar(Format('Во время сохранения возникла следующая ошибка %s',
        [E.Message])), 'Внимание', mb_Ok or mb_IconInformation);
      Result := False;  
    end;
  end;
  FisOk := FisOK or Result;
end;

procedure Tdlg_gpContractSell.SetupDialog(const aDocumentKey, aCustomerKey: Integer);
begin
  if not IBTransaction.InTransaction then
    IBTransaction.StartTransaction;

  FDocumentKey := aDocumentKey;
  FCustomerKey := aCustomerKey;
  
  if FDocumentKey = -1 then
    AppendDocument
  else
    EditDocument;
end;

procedure Tdlg_gpContractSell.bOkClick(Sender: TObject);
begin
  if Save then
    ModalResult := mrOk;
end;

procedure Tdlg_gpContractSell.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if ModalResult <> mrOk then
  begin
    if ibdsContract.State in [dsEdit, dsInsert] then
      ibdsContract.Cancel;

    if ibdsDocument.State in [dsEdit, dsInsert] then
      ibdsDocument.Cancel;

    if IBTransaction.InTransaction then
      IBTransaction.RollBack;    
  end;
end;

procedure Tdlg_gpContractSell.bNextClick(Sender: TObject);
begin
  if Save then
    SetupDialog(-1, FCustomerKey);
end;

procedure Tdlg_gpContractSell.FormCreate(Sender: TObject);
begin
  FisOK := False;
end;

end.
