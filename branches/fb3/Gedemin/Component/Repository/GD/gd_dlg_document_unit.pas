unit gd_dlg_document_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gsDocNumerator, Db, IBCustomDataSet, at_sql_setup, ActnList, IBDatabase,
  gd_createable_form, StdCtrls, at_Container, Mask, xDateEdits, DBCtrls,
  ExtCtrls, ComCtrls, IBSQL;

type
  Tgd_dlg_document = class(TCreateableForm)
    IBTransaction: TIBTransaction;
    alDocument: TActionList;
    actOk: TAction;
    actCancel: TAction;
    actNext: TAction;
    atSQLSetup: TatSQLSetup;
    dsDocument: TDataSource;
    ibdsDocument: TIBDataSet;
    gsDocNumerator: TgsDocNumerator;
    pcDocument: TPageControl;
    tsMain: TTabSheet;
    pnlMain: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    dbeNumber: TDBEdit;
    dbeDate: TxDateDBEdit;
    tsAttribute: TTabSheet;
    atcLocal: TatContainer;
    pnlButtons: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    Button1: TButton;
    Splitter1: TSplitter;
    atcDocument: TatContainer;
    procedure actOkExecute(Sender: TObject);
    procedure actNextExecute(Sender: TObject);
  private
    FDocumentKey: Integer;
    FCopyDocumentKey: Integer;
    { Private declarations }
  protected
    function Save: Boolean; virtual;
    procedure InitDocumentTransaction; virtual;

    procedure NewDocument; virtual;
    procedure EditDocument; virtual;
    procedure CopyDocument; virtual;
  public
    { Public declarations }
    function Execute: Boolean; virtual;

    property DocumentKey: Integer read FDocumentKey write FDocumentKey;
    property CopyDocumentKey: Integer read FCopyDocumentKey write FCopyDocumentKey;
  end;

var
  gd_dlg_document: Tgd_dlg_document;

implementation

{$R *.DFM}

uses dmDatabase_unit;

procedure Tgd_dlg_document.actOkExecute(Sender: TObject);
begin
  if Save then
    ModalResult := mrOK;
end;

procedure Tgd_dlg_document.actNextExecute(Sender: TObject);
begin
  if Save then
  begin
    InitDocumentTransaction;
    NewDocument;
  end;
end;

function Tgd_dlg_document.Save: Boolean;
begin
  Result := True;
  try
    if ibdsDocument.State in [dsEdit, dsInsert] then
      ibdsDocument.Post;
  except
    on E: Exception do
    begin
      MessageBox(HANDLE, PChar(Format('При сохранении документа возникла следующая ошибка %s',
        [E.Message])), 'Внимание', mb_OK or mb_IconInformation);
      Result := False;
    end;
  end;
end;

procedure Tgd_dlg_document.InitDocumentTransaction;
begin
  if not IBTransaction.InTransaction then
    IBTransaction.StartTransaction;

  ibdsDocument.ParamByName('ID').AsInteger := DocumentKey;
  ibdsDocument.Open;
end;

procedure Tgd_dlg_document.NewDocument;
begin
  DocumentKey := GenUniqueID;

  ibdsDocument.Insert;
  ibdsDocument.FieldByName('id').AsInteger := DocumentKey;
end;

procedure Tgd_dlg_document.EditDocument;
begin
  ibdsDocument.Edit;
end;

function Tgd_dlg_document.Execute: Boolean;
begin
  InitDocumentTransaction;
  
  if DocumentKey <> -1 then
    EditDocument
  else
    if CopyDocumentKey <> -1 then
      CopyDocument
    else
      NewDocument;

  Result := ShowModal = mrOk;
end;

procedure Tgd_dlg_document.CopyDocument;
var
  ibsql: TIBSQL;
  i: Integer;
begin
  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := IBTransaction;
    ibsql.SQL.Text := 'SELECT * FROM gd_document WHERE id = :id';
    ibsql.Prepare;
    ibsql.ParamByName('id').AsInteger := CopyDocumentKey;
    ibsql.ExecQuery;
    if ibsql.RecordCount = 1 then
    begin
      DocumentKey := GenUniqueID;
      ibdsDocument.Insert;
      for i:= 0 to ibdsDocument.FieldCount - 1 do
        if (UpperCase(ibdsDocument.Fields[i].FieldName) <> 'NUMBER') and
           (UpperCase(ibdsDocument.Fields[i].FieldName) <> 'DOCUMENTDATE')
        then
          ibdsDocument.Fields[i].Value :=
            ibsql.FieldByName(ibdsDocument.Fields[i].FieldName).Value;
            
      ibdsDocument.FieldByName('id').AsInteger := DocumentKey;
    end
    else
      NewDocument;
  finally
    ibsql.Free;
  end;
end;

end.
