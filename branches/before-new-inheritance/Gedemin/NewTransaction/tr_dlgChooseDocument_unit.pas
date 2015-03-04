unit tr_dlgChooseDocument_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBCustomDataSet, dmDatabase_unit, Grids, DBGrids, gsDBGrid, gsIBGrid,
  Ibdatabase, StdCtrls;

type
  TdlgChooseDocument = class(TForm)
    ibdsDocumentType: TIBDataSet;
    dsDocumentType: TDataSource;
    gsibgrDocumentType: TgsIBGrid;
    bOk: TButton;
    bCancel: TButton;
    ibdsDocumentTypeID: TIntegerField;
    ibdsDocumentTypePARENT: TIntegerField;
    ibdsDocumentTypeLB: TIntegerField;
    ibdsDocumentTypeRB: TIntegerField;
    ibdsDocumentTypeNAME: TIBStringField;
    ibdsDocumentTypeDESCRIPTION: TIBStringField;
    ibdsDocumentTypeAFULL: TIntegerField;
    ibdsDocumentTypeACHAG: TIntegerField;
    ibdsDocumentTypeAVIEW: TIntegerField;
    ibdsDocumentTypeDISABLED: TSmallintField;
    ibdsDocumentTypeRESERVED: TIntegerField;
  private
    { Private declarations }
  public
    { Public declarations }
    function SetupDialog(aTransaction: TIBTransaction): Boolean;
  end;

var
  dlgChooseDocument: TdlgChooseDocument;

implementation

{$R *.DFM}

{ TdlgChooseDocument }

function TdlgChooseDocument.SetupDialog(
  aTransaction: TIBTransaction): Boolean;
begin
  ibdsDocumentType.Transaction := aTransaction;
  ibdsDocumentType.Open;
  Result := ShowModal = mrOK;
end;

end.
