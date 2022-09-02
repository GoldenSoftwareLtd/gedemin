// ShlTanya, 29.01.2019

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
    TNVDKey: TID;
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
  // Инициализация Д.О.
  New := False;
  // Выполнение запроса
  ibqryEditTNVD.Close;
  SetTID(ibqryEditTNVD.ParamByName('id'), TNVDKey);
  ibqryEditTNVD.Open;
  ibqryEditTNVD.First;
  // Если записей не найдено создаем новую
  if ibqryEditTNVD.Eof then
  begin
    if ((boAccess.GetRights(GD_OP_ADDTNVD)) and IBLogin.Ingroup = 0) then
    begin
      MessageBox(Self.Handle, 'Нет прав добавлять ТНВД', 'Внимание',
       MB_OK or MB_ICONWARNING);
      Exit;
    end;

    // Получаем ID новой записи
    ibqryTNVDID.Close;
    ibqryTNVDID.Open;

    New := True;
    ibqryEditTNVD.Insert;
    SetTID(ibqryEditTNVD.FieldByName('id'), ibqryTNVDID.FieldByName('id'));
  // Иначе редактируем существующую
  end else
  begin
    if ((boAccess.GetRights(GD_OP_EDITTNVD)) and IBLogin.Ingroup = 0) then
    begin
      MessageBox(Self.Handle, 'Нет прав редактировать ТНВД', 'Внимание',
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
    MessageBox(Self.Handle, 'Не введено наименование ед. изм.',
     'Внимание', MB_OK or MB_ICONINFORMATION);
    ModalResult := mrNone;
    Exit;
  end;
  // Сохранение изменений
  TNVDKey := GetTID(ibqryEditTNVD.FieldByName('id'));
  ibqryEditTNVD.Post;
  if ibtrTNVD.InTransaction then
    ibtrTNVD.CommitRetaining;
end;

procedure TdlgAddTNVD.btnCancelClick(Sender: TObject);
begin
  // Отмена
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
  // Удаление ед. изм.
  Result := True;
  try
    if (MessageBox(Self.Handle, 'Вы действительно хотите удалить ТНВД?',
     'Внимание', MB_YESNO or MB_ICONQUESTION) <> IDYES) then
      Exit;
    ibqryEditTNVD.Close;
    SetTID(ibqryEditTNVD.ParamByName('id'), TNVDKey);
    ibqryEditTNVD.Open;

    if ((boAccess.GetRights(GD_OP_DELETETNVD)) and IBLogin.Ingroup = 0) then
    begin
      MessageBox(Self.Handle, 'Нет прав удалять ТНВД', 'Внимание',
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
