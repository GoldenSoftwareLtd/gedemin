unit Inventory_doc_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdcInvDocument_unit, Grids, DBGrids, gsDBGrid, gsIBGrid, Db, StdCtrls;

type
  TForm1 = class(TForm)
    dsMain: TDataSource;
    ibMain: TgsIBGrid;
    btnNew: TButton;
    btnEdit: TButton;
    btnDelete: TButton;
    btnDocument: TButton;
    btnAttribute: TButton;
    btnRestart: TButton;
   btnShutdown: TButton;
    btnDisconnect: TButton;
    btnConnect: TButton;
    btnReopen: TButton;

    procedure FormCreate(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnDocumentClick(Sender: TObject);
    procedure btnAttributeClick(Sender: TObject);

    procedure btnConnectClick(Sender: TObject);
    procedure btnDisconnectClick(Sender: TObject);
    procedure btnShutdownClick(Sender: TObject);
    procedure btnRestartClick(Sender: TObject);
    procedure btnReopenClick(Sender: TObject);

  private
    FDocumentType: TgdcInvDocumentType;

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

uses gd_security, gd_security_operationconst, Inventory_document_unit,
     at_frmUserDefined;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FDocumentType := TgdcInvDocumentType.Create(Self);
  dsMain.DataSet := FDocumentType;
  FDocumentType.Open;
end;

procedure TForm1.btnNewClick(Sender: TObject);
begin
  FDocumentType.CreateDialog;
end;

procedure TForm1.btnEditClick(Sender: TObject);
begin
  FDocumentType.EditDialog;
end;

procedure TForm1.btnDeleteClick(Sender: TObject);
begin
  FDocumentType.DeleteMultiple(ibMain.SelectedRows);
end;

procedure TForm1.btnDocumentClick(Sender: TObject);
begin
  frmNewDocument := TfrmNewDocument.Create(Self,
    FDocumentType.FieldByName('ID').AsInteger);

  try
    frmNewDocument.ShowModal;
  finally
    frmNewDocument.Free;
  end;
end;

procedure TForm1.btnAttributeClick(Sender: TObject);
begin
  frmUserDefined := TfrmUserDefined.Create(Self);
  
  try
    frmUserDefined.ShowModal;
  finally
    frmUserDefined.Free
  end;
end;

procedure TForm1.btnConnectClick(Sender: TObject);
begin
  IBLogin.Login(True);
  FDocumentType.Open;
end;

procedure TForm1.btnDisconnectClick(Sender: TObject);
begin
  IBLogin.LogOff;
end;

procedure TForm1.btnShutdownClick(Sender: TObject);
begin
  IBLogin.LoginSingle;
end;

procedure TForm1.btnRestartClick(Sender: TObject);
begin
  IBLogin.BringOnLine;
end;

procedure TForm1.btnReopenClick(Sender: TObject);
begin
  FDocumentType.Active := not FDocumentType.Active;
end;

end.
