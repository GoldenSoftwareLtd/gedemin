// ShlTanya, 29.01.2019

unit dlgSetParamTax_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, DBCtrls, Db, IBCustomDataSet, IBUpdateSQL, IBQuery,
  ComCtrls, gd_security;

type
  TdlgSetParamTax = class(TForm)
    dbeName: TDBEdit;
    dbeRate: TDBEdit;
    Label1: TLabel;
    lblRate: TLabel;
    btnOk: TButton;
    btnCancel: TButton;
    ibudEditGoodTax: TIBUpdateSQL;
    ibqryEditGoodTax: TIBQuery;
    dsGoodTax: TDataSource;
    Label3: TLabel;
    dtpDate: TDateTimePicker;
    procedure FormCreate(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    TaxKey: TID;
    GoodKey: TID;
    DateTax: TDate;
    procedure ActiveDialog;
  end;

var
  dlgSetParamTax: TdlgSetParamTax;

implementation

uses
  gd_security_OperationConst;

{$R *.DFM}

procedure TdlgSetParamTax.FormCreate(Sender: TObject);
begin
  TaxKey := -1;
  GoodKey := -1;
  DateTax := 0;
end;

procedure TdlgSetParamTax.ActiveDialog;
begin
  // Инициализация Д.О.
  // Проверка на заполнение начальных данных
  if (GoodKey < 1) or (TaxKey < 1) or (DateTax = 0) then
    ModalResult := mrCancel
  else begin
    // Вытягиваем нужную запись и устанавливаем режим редактирования
    ibqryEditGoodTax.Close;
    SetTID(ibqryEditGoodTax.ParamByName('goodkey'), GoodKey);
    SetTID(ibqryEditGoodTax.ParamByName('taxkey'), TaxKey);
    ibqryEditGoodTax.ParamByName('datetax').AsDateTime := DateTax;
    ibqryEditGoodTax.Open;
    ibqryEditGoodTax.Edit;
    dtpDate.Date := DateTax;
  end;
end;

procedure TdlgSetParamTax.btnOkClick(Sender: TObject);
begin
  // Сохраняем изменения
  ibqryEditGoodTax.FieldByName('datetax').AsDateTime := Trunc(dtpDate.Date);
  ibqryEditGoodTax.Post;
end;

procedure TdlgSetParamTax.btnCancelClick(Sender: TObject);
begin
  // Отмена
  ibqryEditGoodTax.Cancel;
end;

end.
