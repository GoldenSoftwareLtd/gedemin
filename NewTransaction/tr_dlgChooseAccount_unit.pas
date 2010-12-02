unit tr_dlgChooseAccount_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBCustomDataSet, Grids, DBGrids, gsDBGrid, gsIBGrid, ExtCtrls, dmDatabase_unit,
  StdCtrls;

type
  TfrmChooseAccount = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    gsibgrAccount: TgsIBGrid;
    ibdsAccount: TIBDataSet;
    dsAccount: TDataSource;
    ibdsAccountID: TIntegerField;
    ibdsAccountALIAS: TIBStringField;
    ibdsAccountNAME: TIBStringField;
    bCancel: TButton;
    bOk: TButton;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmChooseAccount: TfrmChooseAccount;

implementation

{$R *.DFM}

procedure TfrmChooseAccount.FormCreate(Sender: TObject);
begin
  ibdsAccount.Open;
end;


end.
