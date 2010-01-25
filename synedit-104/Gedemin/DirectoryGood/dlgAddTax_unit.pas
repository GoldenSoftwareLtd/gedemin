unit dlgAddTax_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, DBCtrls, Db, IBCustomDataSet, IBUpdateSQL, IBQuery,
  gd_security, IBDatabase, dmDatabase_unit;

type
  TdlgAddTax = class(TForm)
    dbeName: TDBEdit;
    dbeShot: TDBEdit;
    dbeRate: TDBEdit;
    Label1: TLabel;
    Label2: TLabel;
    lblRate: TLabel;
    btnOk: TButton;
    btnCancel: TButton;
    dsTax: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FTaxKey: Integer;

  public
    { Public declarations }

    property TaxKey: Integer read FTaxKey;
    procedure ActiveDialog(const aTaxKey: Integer);
  end;

var
  dlgAddTax: TdlgAddTax;

implementation

uses gd_security_OperationConst;

{$R *.DFM}

procedure TdlgAddTax.FormCreate(Sender: TObject);
begin
  FTaxKey := -1;
end;

procedure TdlgAddTax.ActiveDialog(const aTaxKey: Integer);
begin
  FTaxKey := aTaxKey;
  if FTaxKey = -1 then
  begin
    FTaxKey := GenUniqueID;
    dsTax.DataSet.Insert;
    dsTax.DataSet.FieldByName('ID').AsInteger := FTaxKey;
  end
  else
    dsTax.DataSet.Edit;
  if ShowModal = mrOK then
    dsTax.DataSet.Refresh;
end;


procedure TdlgAddTax.btnOkClick(Sender: TObject);
begin
  dbeName.Text := Trim(dbeName.Text);
  if dbeName.Text = '' then
  begin
    MessageBox(Self.Handle, 'Не введено наименование налога.',
     'Внимание', MB_OK or MB_ICONINFORMATION);
    ModalResult := mrNone;
    dbeName.SetFocus;
    Exit;
  end;

  dbeShot.Text := Trim(dbeShot.Text);

  if dbeShot.Text = '' then
  begin
    MessageBox(Self.Handle, 'Не введено наименование переменной.',
     'Внимание', MB_OK or MB_ICONINFORMATION);
    ModalResult := mrNone;
    dbeShot.SetFocus;
    Exit;
  end;

  if dbeRate.Text = '' then
  begin
    MessageBox(Self.Handle, 'Не введена ставка налога.',
     'Внимание', MB_OK or MB_ICONINFORMATION);
    ModalResult := mrNone;
    dbeRate.SetFocus;
    Exit;
  end;

  if dsTax.DataSet.State in [dsEdit, dsInsert] then
    dsTax.DataSet.Post;

end;

procedure TdlgAddTax.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if dsTax.DataSet.State in [dsEdit, dsInsert] then
    dsTax.DataSet.Cancel;
end;

end.
