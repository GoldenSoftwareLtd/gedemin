unit Inventory_document_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, DBGrids, gsDBGrid, gsIBGrid, gdcInvDocument_unit, ExtCtrls,
  Db;

type
  TfrmNewDocument = class(TForm)
    ibMaster: TgsIBGrid;
    Splitter1: TSplitter;
    ibDetail: TgsIBGrid;
    Panel1: TPanel;
    btnAdd: TButton;
    btnEdit: TButton;
    btnDelete: TButton;
    dsMaster: TDataSource;
    dsDetail: TDataSource;
    btnAddDetail: TButton;
    btnEditDetail: TButton;
    btnDeleteDetail: TButton;

    procedure btnAddClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnAddDetailClick(Sender: TObject);
    procedure btnEditDetailClick(Sender: TObject);
    procedure btnDeleteDetailClick(Sender: TObject);

  private
    FDocument: TgdcInvDocument;
    FDocumentLine: TgdcInvDocumentLine;

  public
    constructor Create(AnOwner: TComponent; DocumentKey: Integer); reintroduce;

  end;

var
  frmNewDocument: TfrmNewDocument;

implementation

{$R *.DFM}

{ TForm2 }

constructor TfrmNewDocument.Create(AnOwner: TComponent; DocumentKey: Integer);
begin
  inherited Create(AnOwner);

  FDocument := TgdcInvDocument.CreateFromDocumentKey(Self, DocumentKey);
  FDocumentLine := TgdcInvDocumentLine.CreateFromDocumentKey(Self, DocumentKey);

  dsMaster.DataSet := FDocument;
  dsDetail.DataSet := FDocumentLine;

  FDocumentLine.MasterSource := dsMaster;
  FDocumentLine.MasterField := 'ID';
  FDocumentLine.DetailField := 'ID';

  FDocument.Open;
  FDocumentLine.Open;
end;

procedure TfrmNewDocument.btnAddClick(Sender: TObject);
begin
  FDocument.CreateDialog;
end;

procedure TfrmNewDocument.btnEditClick(Sender: TObject);
begin
  FDocument.EditDialog;
end;

procedure TfrmNewDocument.btnDeleteClick(Sender: TObject);
begin
  FDocument.DeleteMultiple(ibDetail.SelectedRows);
end;

procedure TfrmNewDocument.btnAddDetailClick(Sender: TObject);
begin
  FDocumentLine.CreateDialog
end;

procedure TfrmNewDocument.btnEditDetailClick(Sender: TObject);
begin
  FDocumentLine.EditDialog
end;

procedure TfrmNewDocument.btnDeleteDetailClick(Sender: TObject);
begin
  FDocumentLine.DeleteMultiple(ibMaster.SelectedRows)
end;

end.
