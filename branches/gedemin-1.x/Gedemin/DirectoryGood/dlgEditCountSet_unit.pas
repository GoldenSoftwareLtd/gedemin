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
    SetKey: Integer;
    GoodKey: Integer;
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
  // Инициализация
  // Вытягиваем запись по ключу и переходим в режим редактирования
  ibqrySetCount.Close;
  ibqrySetCount.ParamByName('setkey').AsInteger := SetKey;
  ibqrySetCount.ParamByName('goodkey').AsInteger := GoodKey;
  ibqrySetCount.Open;
  ibqrySetCount.Edit;
end;

procedure TdlgEditCountSet.btnOkClick(Sender: TObject);
begin
  if dbeCount.Text = '' then
  begin
    MessageBox(Self.Handle, 'Не указано количество комплектующих',
     'Внимание', MB_OK or MB_ICONINFORMATION);
    ModalResult := mrNone;
    Exit;
  end;
  // Сохраняем изменения
  ibqrySetCount.Post;
end;

procedure TdlgEditCountSet.btnCancelClick(Sender: TObject);
begin
  // Отмена
  ibqrySetCount.Cancel;
end;

function TdlgEditCountSet.Delete: Boolean;
begin
  // Удаление товара из комплекта
  Result := False;
  try
    // Запрос на подтверждение на удаление
    if MessageBox(Self.Handle, 'Вы действительно хотите удалить товар?',
     'Внимание', MB_YESNO or MB_ICONQUESTION) = IDYES then
    begin
      Result := True;
      // Инициализация
      ActiveDialog;
      ibqrySetCount.Cancel;
      // Удаление
      ibqrySetCount.Delete;
    end;
  except
    Result := False;
  end;
end;

end.
