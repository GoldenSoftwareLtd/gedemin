// ShlTanya, 29.01.2019

unit dlgAddValue_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, DBCtrls, IBCustomDataSet, IBUpdateSQL, Db, IBQuery, gd_security,
  IBDatabase, dmDatabase_unit, gsIBLookupComboBox;

type
  TdlgAddValue = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    dbeName: TDBEdit;
    ibqryEditValue: TIBQuery;
    ibudEditValue: TIBUpdateSQL;
    dsValue: TDataSource;
    ibtrValue: TIBTransaction;
    Label2: TLabel;
    dbedDescription: TDBEdit;
    Label3: TLabel;
    gsIBLookupComboBox1: TgsIBLookupComboBox;
    DBCheckBox1: TDBCheckBox;
    procedure btnOkClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FValueKey: TID;
    New: Boolean;
  public
    { Public declarations }
    procedure ActiveDialog(const aValueKey: TID);
    property ValueKey: TID read FValueKey;
  end;

var
  dlgAddValue: TdlgAddValue;

implementation

uses
  gd_security_OperationConst;

{$R *.DFM}

procedure TdlgAddValue.ActiveDialog(const aValueKey: TID);
begin
  if not ibtrValue.InTransaction then
    ibtrValue.StartTransaction;
  // ������������� �.�.
  FValueKey := aValueKey;
  New := False;
  // ���������� �������
  ibqryEditValue.Close;
  SetTID(ibqryEditValue.ParamByName('id'), FValueKey);
  ibqryEditValue.Open;
  ibqryEditValue.First;
  // ���� ������� �� ������� ������� �����
  if ibqryEditValue.Eof then
  begin
    // �������� ID ����� ������
    New := True;
    ibqryEditValue.Insert;
    SetTID(ibqryEditValue.FieldByName('id'), GenUniqueID);
  // ����� ����������� ������������
  end else
    ibqryEditValue.Edit;
end;

procedure TdlgAddValue.btnOkClick(Sender: TObject);
begin
  dbeName.Text := Trim(dbeName.Text);
  if dbeName.Text = '' then
  begin
    MessageBox(Self.Handle, '�� ������� ������������ ������� ���������',
     '��������', MB_OK or MB_ICONINFORMATION);
    ModalResult := mrNone;
    Exit;
  end;
  // ���������� ���������
  FValueKey := GetTID(ibqryEditValue.FieldByName('id'));
  ibqryEditValue.Post;
  if ibtrValue.InTransaction then
    ibtrValue.Commit;
end;

procedure TdlgAddValue.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if ModalResult <> mrOk then
  begin
    // ������
    if ibqryEditValue.State in [dsEdit, dsInsert] then ibqryEditValue.Cancel;
    if ibtrValue.InTransaction then
      ibtrValue.Rollback;
  end;
end;

end.
