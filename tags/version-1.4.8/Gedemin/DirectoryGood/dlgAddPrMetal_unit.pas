unit dlgAddPrMetal_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, DBCtrls, Db, IBCustomDataSet, IBUpdateSQL, IBQuery,
  gd_security, IBDatabase;

type
  TdlgAddPrMetal = class(TForm)
    dbeName: TDBEdit;
    Label1: TLabel;
    btnOk: TButton;
    btnCancel: TButton;
    lblTNVD: TLabel;
    dbmDescription: TDBMemo;
    procedure btnOkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function AddPrMetal(var PrMetalKey: Integer): Boolean;
    function EditPrMetal(const PrMetalKey: Integer): Boolean;
    function DeletePrMetal(const PrMetalKey: Integer): Boolean;
  end;

var
  dlgAddPrMetal: TdlgAddPrMetal;

implementation

uses gd_security_OperationConst;

{$R *.DFM}

function TdlgAddPrMetal.AddPrMetal(var PrMetalKey: Integer): Boolean;
begin
  Result := False;
  try
    if not ibtrPrMetal.InTransaction then
      ibtrPrMetal.StartTransaction;

    if ((boAccess.GetRights(GD_OP_ADDPRMETAL)) and IBLogin.Ingroup = 0) then
    begin
      MessageBox(Self.Handle, 'Нет прав добавлять драгметалл.', 'Внимание',
       MB_OK or MB_ICONWARNING);
      Exit;
    end;

    ibqryEditPrMetal.Open;
    ibqryEditPrMetal.Insert;

    ibqryPrMetalID.Close;
    ibqryPrMetalID.Open;
    ibqryEditPrMetal.FieldByName('id').AsInteger := ibqryPrMetalID.Fields[0].AsInteger;
    PrMetalKey := ibqryPrMetalID.Fields[0].AsInteger;

    if ShowModal = mrOk then
    try
      ibqryEditPrMetal.Post;
      Result := True;
       ibqryEditPrMetal.FieldByName('name').AsString, 0, nil);
      if ibtrPrMetal.InTransaction then
        ibtrPrMetal.CommitRetaining;
    except
      on E: Exception do
      begin
        MessageBox(Self.Handle, @E.Message[1], 'Ошибка', MB_OK or MB_ICONERROR);
        ibqryEditPrMetal.Cancel;
        if ibtrPrMetal.InTransaction then
          ibtrPrMetal.Rollback;
      end;
    end else
    begin
      ibqryEditPrMetal.Cancel;
      if ibtrPrMetal.InTransaction then
        ibtrPrMetal.Rollback;
    end;

  except
    on E: Exception do
      MessageBox(Self.Handle, @E.Message[1], 'Ошибка', MB_OK or MB_ICONERROR);
  end;
end;

function TdlgAddPrMetal.EditPrMetal(const PrMetalKey: Integer): Boolean;
begin
  Result := False;
  try
    if not ibtrPrMetal.InTransaction then
      ibtrPrMetal.StartTransaction;

    if ((boAccess.GetRights(GD_OP_EDITPRMETAL)) and IBLogin.Ingroup = 0) then
    begin
      MessageBox(Self.Handle, 'Нет прав редактировать драгметалл', 'Внимание',
       MB_OK or MB_ICONWARNING);
      Exit;
    end;

    ibqryEditPrMetal.Close;
    ibqryEditPrMetal.Params[0].AsInteger := PrMetalKey;
    ibqryEditPrMetal.Open;
    ibqryEditPrMetal.Edit;

    if ShowModal = mrOk then
    try
      ibqryEditPrMetal.Post;
      Result := True;
       ibqryEditPrMetal.FieldByName('name').AsString, 0, nil);
      if ibtrPrMetal.InTransaction then
        ibtrPrMetal.CommitRetaining;
    except
      on E: Exception do
      begin
        MessageBox(Self.Handle, @E.Message[1], 'Ошибка', MB_OK or MB_ICONERROR);
        ibqryEditPrMetal.Cancel;
        if ibtrPrMetal.InTransaction then
          ibtrPrMetal.Rollback;
      end;
    end else
    begin
      ibqryEditPrMetal.Cancel;
      if ibtrPrMetal.InTransaction then
        ibtrPrMetal.Rollback;
    end;

  except
    on E: Exception do
      MessageBox(Self.Handle, @E.Message[1], 'Ошибка', MB_OK or MB_ICONERROR);
  end;
end;

function TdlgAddPrMetal.DeletePrMetal(const PrMetalKey: Integer): Boolean;
var
  OldName: String;
begin
  Result := False;
  try
    if not ibtrPrMetal.InTransaction then
      ibtrPrMetal.StartTransaction;

    if ((boAccess.GetRights(GD_OP_DELETEPRMETAL)) and IBLogin.Ingroup = 0) then
    begin
      MessageBox(Self.Handle, 'Нет прав удалять драгметалл', 'Внимание',
       MB_OK or MB_ICONWARNING);
      Exit;
    end;

    if (MessageBox(Self.Handle, 'Драгметалл может использоваться в товарах.'#13#10 +
     'Вы действительно хотите удалить драгметалл?',
     'Внимание', MB_YESNO or MB_ICONQUESTION) = IDYES) then
    begin
      ibqryEditPrMetal.Close;
      ibqryEditPrMetal.Params[0].AsInteger := PrMetalKey;
      ibqryEditPrMetal.Open;
      OldName := ibqryEditPrMetal.FieldByName('name').AsString;
      try
        ibqryEditPrMetal.Delete;
        Result := True;
        if ibtrPrMetal.InTransaction then
          ibtrPrMetal.CommitRetaining;
      except
        on E: Exception do
        begin
          MessageBox(Self.Handle, @E.Message[1], 'Ошибка', MB_OK or MB_ICONERROR);
          if ibtrPrMetal.InTransaction then
            ibtrPrMetal.Rollback;
        end;
      end;
    end;
  except
    on E: Exception do
      MessageBox(Self.Handle, @E.Message[1], 'Ошибка', MB_OK or MB_ICONERROR);
  end;
end;

procedure TdlgAddPrMetal.btnOkClick(Sender: TObject);
begin
  dbeName.Text := Trim(dbeName.Text);
  if dbeName.Text = '' then
  begin
    MessageBox(Self.Handle, 'Не введено наименование драгметалла.',
     'Внимание', MB_OK or MB_ICONINFORMATION);
    ModalResult := mrNone;
    dbeName.SetFocus;
    Exit;
  end;
end;

end.
