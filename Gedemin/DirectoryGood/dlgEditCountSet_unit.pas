// ShlTanya, 29.01.2019

unit dlgEditCountSet_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DBCtrls, Mask, Db, IBCustomDataSet, IBUpdateSQL, IBQuery,
  gd_security;

type
  TdlgEditCountSet = class(TForm)
    Label1: TLabel;
    Label3: TLabel;
    btnOk: TButton;
    btnCancel: TButton;
    dbeCount: TDBEdit;
    ibqrySetCount: TIBQuery;
    ibudSetCount: TIBUpdateSQL;
    dsSetCount: TDataSource;
    lblName: TLabel;
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Name: String;
    SetKey: TID;
    GoodKey: TID;
    procedure ActiveDialog;
    function Delete: Boolean;
  end;

var
  dlgEditCountSet: TdlgEditCountSet;

implementation

uses gd_security_OperationConst;

{$R *.DFM}

procedure TdlgEditCountSet.ActiveDialog;
begin
  // �������������
  // ���������� ������ �� ����� � ��������� � ����� ��������������
  ibqrySetCount.Close;
  SetTID(ibqrySetCount.ParamByName('setkey'), SetKey);
  SetTID(ibqrySetCount.ParamByName('goodkey'), GoodKey);
  ibqrySetCount.Open;
  ibqrySetCount.Edit;
end;

procedure TdlgEditCountSet.btnOkClick(Sender: TObject);
begin
  if dbeCount.Text = '' then
  begin
    MessageBox(Self.Handle, '�� ������� ���������� �������������',
     '��������', MB_OK or MB_ICONINFORMATION);
    ModalResult := mrNone;
    Exit;
  end;
  // ��������� ���������
  ibqrySetCount.Post;
end;

procedure TdlgEditCountSet.btnCancelClick(Sender: TObject);
begin
  // ������
  ibqrySetCount.Cancel;
end;

function TdlgEditCountSet.Delete: Boolean;
begin
  // �������� ������ �� ���������
  Result := False;
  try
    // ������ �� ������������� �� ��������
    if MessageBox(Self.Handle, '�� ������������� ������ ������� �����?',
     '��������', MB_YESNO or MB_ICONQUESTION) = IDYES then
    begin
      Result := True;
      // �������������
      ActiveDialog;
      ibqrySetCount.Cancel;
      // ��������
      ibqrySetCount.Delete;
    end;
  except
    Result := False;
  end;
end;

end.
