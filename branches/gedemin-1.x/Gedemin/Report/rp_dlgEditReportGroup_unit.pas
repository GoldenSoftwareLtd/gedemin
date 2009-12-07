unit rp_dlgEditReportGroup_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBCustomDataSet, StdCtrls, Mask, DBCtrls, gd_security;

type
  TdlgEditReportGroup = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    dbeName: TDBEdit;
    dbeDescription: TDBEdit;
    btnOk: TButton;
    btnCancel: TButton;
    ibdsReportGroup: TIBDataSet;
    dsReportGroup: TDataSource;
    btnRigth: TButton;
    procedure btnOkClick(Sender: TObject);
  private
    { Private declarations }
  public
    function AddGroup(const AnParent: Variant): Boolean;
    function EditGroup(const AnGroupKey: Integer): Boolean;
    function DeleteGroup(const AnGroupKey: Integer): Boolean;
  end;

var
  dlgEditReportGroup: TdlgEditReportGroup;

implementation

uses
  gd_SetDatabase;

{$R *.DFM}

function TdlgEditReportGroup.AddGroup(const AnParent: Variant): Boolean;
begin
  Result := False;
  ibdsReportGroup.Close;
  ibdsReportGroup.Open;
  ibdsReportGroup.Insert;
  ibdsReportGroup.FieldByName('afull').AsInteger := -1;
  ibdsReportGroup.FieldByName('achag').AsInteger := -1;
  ibdsReportGroup.FieldByName('aview').AsInteger := -1;
  ibdsReportGroup.FieldByName('parent').AsVariant := AnParent;
  if ShowModal = mrOk then
  try
    ibdsReportGroup.FieldByName('id').AsInteger :=
     GetUniqueKey(ibdsReportGroup.Database, ibdsReportGroup.Transaction);
    ibdsReportGroup.Post;
    Result := True;
  except
    on E: Exception do
    begin
      MessageBox(Self.Handle, PChar('��������� ������ ��� �������� ������'#13#10 +
       E.Message), '������', MB_OK or MB_ICONERROR);
      ibdsReportGroup.Cancel;
    end;
  end else
    ibdsReportGroup.Cancel;
end;

function TdlgEditReportGroup.EditGroup(const AnGroupKey: Integer): Boolean;
begin
  Result := False;
  ibdsReportGroup.Close;
  ibdsReportGroup.Params[0].AsInteger := AnGroupKey;
  ibdsReportGroup.Open;
  if ibdsReportGroup.Eof then
  begin
    MessageBox(Self.Handle, '��������� ������ ������� �� �������.',
     '��������', MB_OK or MB_ICONWARNING);
    Exit;
  end;

  ibdsReportGroup.Edit;
  if ShowModal = mrOk then
  try
    ibdsReportGroup.Post;
    Result := True;
  except
    on E: Exception do
    begin
      MessageBox(Self.Handle, PChar('��������� ������ ��� �������� ������'#13#10 +
       E.Message), '������', MB_OK or MB_ICONERROR);
      ibdsReportGroup.Cancel;
    end;
  end else
    ibdsReportGroup.Cancel;
end;

function TdlgEditReportGroup.DeleteGroup(const AnGroupKey: Integer): Boolean;
begin
  Result := False;
  ibdsReportGroup.Close;
  ibdsReportGroup.Params[0].AsInteger := AnGroupKey;
  ibdsReportGroup.Open;
  if ibdsReportGroup.Eof then
  begin
    MessageBox(Self.Handle, '��������� ������ ������� �� �������.',
     '��������', MB_OK or MB_ICONWARNING);
    Exit;
  end;

  if (MessageBox(Self.Handle, PChar(Format('�� ������������� ������ ������� ������ ''%s''?', [ibdsReportGroup.FieldByName('name').AsString])),
   '��������', MB_YESNO or MB_ICONQUESTION) = ID_YES) then
  try
    ibdsReportGroup.Delete;
    Result := True;
  except
    on E: Exception do
    begin
      MessageBox(Self.Handle, PChar('��������� ������ ��� �������� ������'#13#10 +
       E.Message), '������', MB_OK or MB_ICONERROR);
    end;
  end else
end;

procedure TdlgEditReportGroup.btnOkClick(Sender: TObject);
begin
  if Trim(dbeName.Text) = '' then
  begin
    MessageBox(Self.Handle, '�� ������� ������������ ������.', '��������', MB_OK or MB_ICONWARNING);
    dbeName.SetFocus;
    Exit;
  end;

  ModalResult := mrOk;
end;

end.
