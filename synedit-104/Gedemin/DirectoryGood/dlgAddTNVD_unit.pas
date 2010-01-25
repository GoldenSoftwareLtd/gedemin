unit dlgAddTNVD_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, DBCtrls, IBCustomDataSet, IBUpdateSQL, Db, IBQuery, gd_security,
  IBDatabase;

type
  TdlgAddTNVD = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    dbeName: TDBEdit;
    ibqryEditTNVD: TIBQuery;
    ibudEditTNVD: TIBUpdateSQL;
    ibqryTnvdID: TIBQuery;
    dsTNVD: TDataSource;
    lblTNVD: TLabel;
    dbmDescription: TDBMemo;
    ibtrTNVD: TIBTransaction;
    procedure FormCreate(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
    New: Boolean;
  public
    { Public declarations }
    TNVDKey: Integer;
    function DeleteValue: Boolean;
    procedure ActiveDialog;
  end;

var
  dlgAddTNVD: TdlgAddTNVD;

implementation

uses gd_security_OperationConst;

{$R *.DFM}

procedure TdlgAddTNVD.FormCreate(Sender: TObject);
begin
  TNVDKey := -1;
end;

procedure TdlgAddTNVD.ActiveDialog;
begin
  if not ibtrTNVD.InTransaction then
    ibtrTNVD.StartTransaction;
  // ������������� �.�.
  New := False;
  // ���������� �������
  ibqryEditTNVD.Close;
  ibqryEditTNVD.ParamByName('id').AsInteger := TNVDKey;
  ibqryEditTNVD.Open;
  ibqryEditTNVD.First;
  // ���� ������� �� ������� ������� �����
  if ibqryEditTNVD.Eof then
  begin
    if ((boAccess.GetRights(GD_OP_ADDTNVD)) and IBLogin.Ingroup = 0) then
    begin
      MessageBox(Self.Handle, '��� ���� ��������� ����', '��������',
       MB_OK or MB_ICONWARNING);
      Exit;
    end;

    // �������� ID ����� ������
    ibqryTNVDID.Close;
    ibqryTNVDID.Open;

    New := True;
    ibqryEditTNVD.Insert;
    ibqryEditTNVD.FieldByName('id').AsInteger := ibqryTNVDID.FieldByName('id').AsInteger;
  // ����� ����������� ������������
  end else
  begin
    if ((boAccess.GetRights(GD_OP_EDITTNVD)) and IBLogin.Ingroup = 0) then
    begin
      MessageBox(Self.Handle, '��� ���� ������������� ����', '��������',
       MB_OK or MB_ICONWARNING);
      Exit;
    end;
    ibqryEditTNVD.Edit;
  end;
end;

procedure TdlgAddTNVD.btnOkClick(Sender: TObject);
begin
  dbeName.Text := Trim(dbeName.Text);
  if dbeName.Text = '' then
  begin
    MessageBox(Self.Handle, '�� ������� ������������ ��. ���.',
     '��������', MB_OK or MB_ICONINFORMATION);
    ModalResult := mrNone;
    Exit;
  end;
  // ���������� ���������
  TNVDKey := ibqryEditTNVD.FieldByName('id').AsInteger;
  ibqryEditTNVD.Post;
  if ibtrTNVD.InTransaction then
    ibtrTNVD.CommitRetaining;
end;

procedure TdlgAddTNVD.btnCancelClick(Sender: TObject);
begin
  // ������
  ibqryEditTNVD.Cancel;
  if ibtrTNVD.InTransaction then
    ibtrTNVD.Rollback;
end;

function TdlgAddTNVD.DeleteValue: Boolean;
var
  VN: String;
begin
  if not ibtrTNVD.InTransaction then
    ibtrTNVD.StartTransaction;
  // �������� ��. ���.
  Result := True;
  try
    if (MessageBox(Self.Handle, '�� ������������� ������ ������� ����?',
     '��������', MB_YESNO or MB_ICONQUESTION) <> IDYES) then
      Exit;
    ibqryEditTNVD.Close;
    ibqryEditTNVD.ParamByName('id').AsInteger := TNVDKey;
    ibqryEditTNVD.Open;

    if ((boAccess.GetRights(GD_OP_DELETETNVD)) and IBLogin.Ingroup = 0) then
    begin
      MessageBox(Self.Handle, '��� ���� ������� ����', '��������',
       MB_OK or MB_ICONWARNING);
      Exit;
    end;

    VN := ibqryEditTNVD.FieldByName('name').AsString;

    ibqryEditTNVD.Delete;
  except
    Result := False;
  end;
  if ibtrTNVD.InTransaction then
    ibtrTNVD.CommitRetaining;
end;

end.
