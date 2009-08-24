unit dlgSetParamPrMetal_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, DBCtrls, Db, IBCustomDataSet, IBUpdateSQL, IBQuery,
  ComCtrls, gd_security;

type
  TdlgSetParamPrMetal = class(TForm)
    dbeName: TDBEdit;
    dbeQuantity: TDBEdit;
    Label1: TLabel;
    lblRate: TLabel;
    btnOk: TButton;
    btnCancel: TButton;
    ibudEditGoodPrMetal: TIBUpdateSQL;
    ibqryEditGoodPrMetal: TIBQuery;
    dsGoodPrMetal: TDataSource;
    procedure btnOkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function SetParams(const GoodKey, PrMetalKey: Integer): Boolean;
  end;

var
  dlgSetParamPrMetal: TdlgSetParamPrMetal;

implementation

uses gd_security_OperationConst;

{$R *.DFM}

function TdlgSetParamPrMetal.SetParams(const GoodKey, PrMetalKey: Integer): Boolean;
begin
  Result := False;
  try
    if ((boAccess.GetRights(GD_OP_EDITGOODPRMETAL)) and IBLogin.Ingroup = 0) then
    begin
      MessageBox(Self.Handle, 'Нет прав редактировать драгметалл в товаре', 'Внимание',
       MB_OK or MB_ICONWARNING);
      Exit;
    end;

    ibqryEditGoodPrMetal.Close;
    ibqryEditGoodPrMetal.ParamByName('goodkey').AsInteger := GoodKey;
    ibqryEditGoodPrMetal.ParamByName('prmetalkey').AsInteger := PrMetalKey;
    ibqryEditGoodPrMetal.Open;
    if ibqryEditGoodPrMetal.Eof then
    begin
      MessageBox(Self.Handle, 'Драгметалл не найден в базе данных',
       'Ошибка', MB_OK or MB_ICONERROR);
      Exit;
    end;

    ibqryEditGoodPrMetal.Edit;

    if ShowModal = mrOk then
    try
      ibqryEditGoodPrMetal.Post;
      Result := True;
    except
      on E: Exception do
      begin
        MessageBox(Self.Handle, @E.Message[1], 'Ошибка', MB_OK or MB_ICONERROR);
        ibqryEditGoodPrMetal.Cancel;
      end;
    end else
      ibqryEditGoodPrMetal.Cancel;

  except
    on E: Exception do
      MessageBox(Self.Handle, @E.Message[1], 'Ошибка', MB_OK or MB_ICONERROR);
  end;
end;

procedure TdlgSetParamPrMetal.btnOkClick(Sender: TObject);
begin
  if dbeQuantity.Text = '' then
  begin
    MessageBox(Self.Handle, 'Не указано количество драгметалла',
     'Внимание', MB_OK or MB_ICONINFORMATION);
    dbeQuantity.SetFocus;
    ModalResult := mrNone;
    Exit;
  end;
end;

end.
