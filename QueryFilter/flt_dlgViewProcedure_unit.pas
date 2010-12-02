unit flt_dlgViewProcedure_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, ComCtrls, StdCtrls, Db, IBCustomDataSet, IBSQL;

type
  TdlgViewProcedure = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    lvProcedure: TListView;
    ActionList1: TActionList;
    actAddProcedure: TAction;
    actEditProcedure: TAction;
    actDeleteProcedure: TAction;
    ibsqlProcedure: TIBSQL;
    procedure actAddProcedureExecute(Sender: TObject);
    procedure actEditProcedureExecute(Sender: TObject);
    procedure actDeleteProcedureExecute(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure actEditProcedureUpdate(Sender: TObject);
  private
    FComponentKey: Integer;
    FSQLText: String;

    // ��������� ������ ������ ��������� �������� ��� ������ ����������.
    procedure ShowProcedure;
  public
    // ����� ���������
    function SelectProcedure(const AnSQLText: String; const AnComponentKey: Integer): String;
  end;

var
  dlgViewProcedure: TdlgViewProcedure;

implementation

uses
  flt_dlgCreateProcedure_unit, gd_security
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$R *.DFM}

procedure TdlgViewProcedure.ShowProcedure;
var
  L: TListItem;
begin
  ibsqlProcedure.Close;
  // ���� ���������� IBLogin, �� ��������� �� ����� �������.
(*  if IBLogin <> nil then
    ibsqlProcedure.SQL.Strings[ibsqlProcedure.SQL.Count - 1] := 'AND g_sec_test(aview, ' +
     IntToStr(IBLogin.Ingroup) + ') <> 0';
  ibsqlProcedure.Params[0].AsInteger := FComponentKey;*)
  ibsqlProcedure.SQL.Text := 'SELECT rdb$procedure_name name, ' +
   'CAST('''' as VARCHAR(1)) description FROM rdb$procedures WHERE rdb$procedure_outputs > 0';
  ibsqlProcedure.ExecQuery;
  lvProcedure.Items.BeginUpdate;
  lvProcedure.Items.Clear;
  // ���������������� �����
  while not ibsqlProcedure.Eof do
  begin
    L := lvProcedure.Items.Add;
    L.Caption := Trim(ibsqlProcedure.FieldByName('name').AsString);
    L.SubItems.Add(Trim(ibsqlProcedure.FieldByName('description').AsString));

    ibsqlProcedure.Next;
  end;
  lvProcedure.Items.EndUpdate;
end;

function TdlgViewProcedure.SelectProcedure(const AnSQLText: String; const AnComponentKey: Integer): String;
begin
  // ����������� ��������� �� ���������
  Result := '';
  // ����������� ���� ����������
  FComponentKey := AnComponentKey;
  // ����������� ����� �������
  FSQLText := AnSQLText;
  // ������� ������ ��������
  ShowProcedure;
  // ������������
  if ShowModal = mrOk then
    if lvProcedure.Selected <> nil then
      Result := lvProcedure.Selected.Caption;
end;

procedure TdlgViewProcedure.actAddProcedureExecute(Sender: TObject);
var
  F: TdlgCreateProcedure;
begin
  F := TdlgCreateProcedure.Create(Self);
  try
    F.ibsqlCreate.Database := ibsqlProcedure.Database;
    F.ibtrCreateProcedure.DefaultDatabase := ibsqlProcedure.Database;
    // �������� ������� �������� ������-���������
    if F.AddProcedure(FSQLText, FComponentKey) then
      ShowProcedure;
  finally
    F.Free;
  end;
end;

procedure TdlgViewProcedure.actEditProcedureExecute(Sender: TObject);
var
  F: TdlgCreateProcedure;
begin
  // �������� �� �����
  if lvProcedure.Selected = nil then
  begin
    MessageBox(Self.Handle, '�� ������� ��������� ��� ��������������', '��������', MB_OK or MB_ICONSTOP);
    Exit;
  end;

  F := TdlgCreateProcedure.Create(Self);
  try
    F.ibsqlCreate.Database := ibsqlProcedure.Database;
    F.ibtrCreateProcedure.DefaultDatabase := ibsqlProcedure.Database;
    // �������� ��������������
    if F.EditProcedure(lvProcedure.Selected.Caption) then
      ShowProcedure;
  finally
    F.Free;
  end;
end;

procedure TdlgViewProcedure.actDeleteProcedureExecute(Sender: TObject);
var
  F: TdlgCreateProcedure;
begin
  // �������� �� �����
  if lvProcedure.Selected = nil then
  begin
    MessageBox(Self.Handle, '�� ������� ��������� ��� ��������', '��������', MB_OK or MB_ICONSTOP);
    Exit;
  end;

  F := TdlgCreateProcedure.Create(Self);
  try
    F.ibsqlCreate.Database := ibsqlProcedure.Database;
    F.ibtrCreateProcedure.DefaultDatabase := ibsqlProcedure.Database;
    // �������� ��������
    if F.DeleteProcedure(lvProcedure.Selected.Caption) then
      ShowProcedure;
  finally
    F.Free;
  end;
end;

procedure TdlgViewProcedure.btnOkClick(Sender: TObject);
begin
  // ��� ��� �������� ��������� ��-�� ActionUpdate
  // �������� �� �����
  if lvProcedure.Selected = nil then
  begin
    MessageBox(Self.Handle, '�� ������� ���������.', '��������', MB_OK or MB_ICONSTOP);
    lvProcedure.SetFocus;
    ModalResult := mrNone;
  end;
end;

procedure TdlgViewProcedure.actEditProcedureUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := lvProcedure.Selected <> nil;
  btnOk.Enabled := (Sender as TAction).Enabled;
end;

end.
