unit tr_dlgChooseDocumentType_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBCustomDataSet, StdCtrls, Grids, DBGrids, gsDBGrid, gsIBGrid, IBDatabase;

type
  TdlgChooseDocumentType = class(TForm)
    ibdsDocumentType: TIBDataSet;
    dsDocumentType: TDataSource;
    gsIBGrid1: TgsIBGrid;
    bOk: TButton;
    Button2: TButton;
    procedure Button2Click(Sender: TObject);
  private
    function GetDocTypeKey: Integer;
    { Private declarations }
  public
    { Public declarations }
    property DocTypeKey: Integer read GetDocTypeKey;

    function SetupDialog(const aTrTypeKey: Integer; aTransaction: TIBTransaction): Boolean;
  end;

var
  dlgChooseDocumentType: TdlgChooseDocumentType;

implementation

{$R *.DFM}

{ TdlgChooseDocumentType }

function TdlgChooseDocumentType.GetDocTypeKey: Integer;
begin
  Result := ibdsDocumentType.FieldByName('id').AsInteger;
end;

function TdlgChooseDocumentType.SetupDialog(
  const aTrTypeKey: Integer; aTransaction: TIBTransaction): Boolean;
begin
  ibdsDocumentType.Transaction := aTransaction;

  ibdsDocumentType.SelectSQL.Text :=
    'SELECT d.name, d.id FROM ' +
    'gd_documenttype d JOIN gd_documenttrtype dt ON d.id = dt.documenttypekey ';
  if aTrTypeKey <> -1 then
    ibdsDocumentType.SelectSQL.Text := ibdsDocumentType.SelectSQL.Text +
      'AND dt.trtypekey = ' +  IntToStr(aTrTypeKey);
  ibdsDocumentType.SelectSQL.Text := ibdsDocumentType.SelectSQL.Text +
     ' ORDER BY d.name';

  ibdsDocumentType.Open;
  Result := ShowModal = mrOk;
end;

procedure TdlgChooseDocumentType.Button2Click(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.
