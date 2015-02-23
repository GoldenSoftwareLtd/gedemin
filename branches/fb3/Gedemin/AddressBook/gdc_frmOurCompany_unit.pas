
unit gdc_frmOurCompany_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, Db, IBCustomDataSet, gdcBase, gdcTree, gdcContacts,
  gd_MacrosMenu, Menus, ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid,
  StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar, ComCtrls;

type
  Tgdc_frmOurCompany = class(Tgdc_frmSGR)
    gdcOurCompany: TgdcOurCompany;
    procedure FormCreate(Sender: TObject);
    procedure actNewExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_frmOurCompany: Tgdc_frmOurCompany;

implementation

{$R *.DFM}

uses
  gd_ClassList,
  IBSQL,
  gdcBaseInterface,
  gd_security
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

procedure Tgdc_frmOurCompany.FormCreate(Sender: TObject);
begin
  gdcObject := gdcOurCompany;
  inherited;
end;

procedure Tgdc_frmOurCompany.actNewExecute(Sender: TObject);
var
  DidActivate: Boolean;
  q: TIBSQL;
  K: TID;
begin
  case MessageBox(Handle,
    'Добавить в рабочие уже существующую организацию или создать новую запись?'#13#10#13#10 +
    'Да (Yes) -- Добавить существующую организацию.'#13#10 +
    'Нет (No) -- Создать новую запись.',
    'Внимание',
    MB_YESNOCANCEL or MB_ICONQUESTION) of
  IDYES:
    begin
      K := TgdcCompany.SelectObject('', '', 0, 'contacttype = 3');

      if K <> -1 then
      begin
        DidActivate := False;
        q := TIBSQL.Create(nil);
        try
          q.Transaction := gdcObject.Transaction;
          DidActivate := not q.Transaction.InTransaction;
          if DidActivate then
            q.Transaction.StartTransaction;
          q.SQL.Text := 'INSERT INTO gd_ourcompany (companykey, afull, achag, aview, disabled) VALUES (:CK, :A, :A, :A, 0) ';
          q.Prepare;
          q.ParamByName('CK').AsInteger := K;
          q.ParamByName('A').AsInteger := IBLogin.InGroup;
          try
            q.ExecQuery;
            q.Close;
            if DidActivate and gdcObject.Transaction.InTransaction then
              gdcObject.Transaction.Commit;
            gdcObject.Close;
            gdcObject.Open;
          except
            // подавляем исключение на случай
            // если кто-то пытается добавить компанию
            // второй раз
          end;
        finally
          q.Free;
          if DidActivate and gdcObject.Transaction.InTransaction then
            gdcObject.Transaction.Commit;
        end;
      end;
    end;
  IDNO:
    inherited;
  else
    ;
  end;
end;

procedure Tgdc_frmOurCompany.actDeleteExecute(Sender: TObject);
begin
  try
    case MessageBox(Handle,
      'Убрать выбранную компанию из списка рабочих организаций или удалить запись из базы данных?'#13#10#13#10 +
      'Да (Yes) -- Убрать из рабочих организаций. Компания останется в базе, в справочнике клиентов.'#13#10 +
      'Нет (No) -- Удалить компанию из базы данных.',
      'Внимание',
      MB_YESNOCANCEL or MB_ICONQUESTION) of
    IDYES: gdcOurCompany.OnlyOurCompany := True;
    IDNO: gdcOurCompany.OnlyOurCompany := False;
    else
      exit;
    end;

    inherited;
  finally
    gdcOurCompany.OnlyOurCompany := False;
  end;
end;

initialization
  RegisterFRMClass(Tgdc_frmOurCompany);

finalization
  UnRegisterFRMClass(Tgdc_frmOurCompany);
end.
