// ShlTanya, 29.01.2019

unit dlgSetParamValue_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, DBCtrls, Db, IBCustomDataSet, IBUpdateSQL, IBQuery, gd_security;

type
  TdlgSetParamValue = class(TForm)
    Label1: TLabel;
    lblBaseValue: TLabel;
    dbeScale: TDBEdit;
    dbeDiscount: TDBEdit;
    Label2: TLabel;
    Label3: TLabel;
    btnOk: TButton;
    btnCancel: TButton;
    ibqryEditGoodValue: TIBQuery;
    ibudEditGoodValue: TIBUpdateSQL;
    dsEditGoodValue: TDataSource;
    Label4: TLabel;
    dbeDecDigit: TDBEdit;
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    GoodKey: TID;
    ValueKey: TID;
    procedure ActiveDialog;
  end;

var
  dlgSetParamValue: TdlgSetParamValue;

implementation

uses gd_security_OperationConst;

{$R *.DFM}

procedure TdlgSetParamValue.ActiveDialog;
begin
  // Инициализация Д.О.
  if (GoodKey < 1) or (ValueKey < 1) then
    ModalResult := mrCancel
  else begin
    // Вытягиваем запись и устанавливаем режим редактирования
    ibqryEditGoodValue.Close;
    SetTID(ibqryEditGoodValue.ParamByName('goodkey'), GoodKey);
    SetID(ibqryEditGoodValue.ParamByName('valuekey'), ValueKey);
    ibqryEditGoodValue.Open;
    lblBaseValue.Caption := ibqryEditGoodValue.FieldByName('name').AsString;
    ibqryEditGoodValue.Edit;
  end;
end;

procedure TdlgSetParamValue.btnOkClick(Sender: TObject);
begin
  // Проверяем диапозон скидки
  if (dbeScale.Text = '') then
  begin
    MessageBox(Self.Handle, 'Не введен коэффициент перерасчета.',
     'Внимание', MB_OK or MB_ICONINFORMATION);
    ModalResult := mrNone;
    dbeScale.SetFocus;
    Exit;
  end;
  if (dbeDiscount.Text = '') or (StrToFloat(dbeDiscount.Text) >= 1) OR
   (StrToFloat(dbeDiscount.Text) < 0) then
  begin
    MessageBox(Self.Handle, 'Скидка должна находится в пределах от 0 до 1',
     'Внимание', MB_OK or MB_ICONINFORMATION);
    ModalResult := mrNone;
    dbeDiscount.SetFocus;
    Exit;
  end;
  if (dbeDecDigit.Text = '') or (StrToInt(dbeDecDigit.Text) > 16) OR
   (StrToInt(dbeDecDigit.Text) < 0) then
  begin
    MessageBox(Self.Handle, 'Количество знаков после запятой должно быть в пределах от 0 до 16',
     'Внимание', MB_OK or MB_ICONINFORMATION);
    ModalResult := mrNone;
    dbeDecDigit.SetFocus;
    Exit;
  end;

  try
    // Сохраняем изменения
    ibqryEditGoodValue.Post;
  except
    on E: Exception do
      MessageBox(Self.Handle, @E.Message[1], 'Ошибка', MB_OK or MB_ICONERROR);
  end;
end;

procedure TdlgSetParamValue.btnCancelClick(Sender: TObject);
begin
  // Отмена
  ibqryEditGoodValue.Cancel;
end;

procedure TdlgSetParamValue.FormCreate(Sender: TObject);
begin
  GoodKey := -1;
  ValueKey := -1;
end;

end.
