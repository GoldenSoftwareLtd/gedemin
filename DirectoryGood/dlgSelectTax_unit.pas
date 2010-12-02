unit dlgSelectTax_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, ComCtrls, StdCtrls, ExtCtrls, Db, IBCustomDataSet, IBQuery,
  IBUpdateSQL, gd_security, IBDatabase, Grids, DBGrids, gsDBGrid, gsIBGrid,
  dmDatabase_unit, IBSQL, at_sql_setup,  Mask, xDateEdits, gd_createable_form;

type
  TdlgSelectTax = class(TCreateableForm)
    Panel2: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    ActionList1: TActionList;
    actAddTax: TAction;
    actEditTax: TAction;
    actDelTax: TAction;
    Button4: TButton;
    actShowTax: TAction;
    actSelect: TAction;
    dsTax: TDataSource;
    ibdsTax: TIBDataSet;
    ibsqlAddNew: TIBSQL;
    atSQLSetup: TatSQLSetup;
    ibsqlAddNewForGroup: TIBSQL;
    IBTransaction: TIBTransaction;
    Panel3: TPanel;
    gsibgrTax: TgsIBGrid;
    pDate: TPanel;
    Label1: TLabel;
    xdeDate: TxDateEdit;
    procedure actAddTaxExecute(Sender: TObject);
    procedure actEditTaxExecute(Sender: TObject);
    procedure actDelTaxExecute(Sender: TObject);
    procedure actSelectExecute(Sender: TObject);
    procedure gsibgrTaxDblClick(Sender: TObject);
    procedure gsibgrTaxKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actEditTaxUpdate(Sender: TObject);
    procedure actDelTaxUpdate(Sender: TObject);

  private
    FGoodKey: Integer;
    OldHeight: Integer;

    function GetTaxDate: TDate;

  public
    function ActiveDialog(const aGoodKey: Integer; isChoose: Boolean): Boolean;
    function SetForGroup(const aGroupKey: Integer): Boolean;
    function DelForGroup(const aGroupKey: Integer): Boolean;

    procedure LoadSettings; override;
    procedure SaveSettings; override;

    property TaxDate: TDate read GetTaxDate;
  end;

var
  dlgSelectTax: TdlgSelectTax;

implementation

uses
  dlgAddTax_unit, gd_security_OperationConst, gsDesktopManager,
  Storages;

{$R *.DFM}


function TdlgSelectTax.SetForGroup(const aGroupKey: Integer): Boolean;
var
  S: String;
begin
  // Инициализация
  Result := False;
  ibdsTax.Open;
  pDate.Height := OldHeight;
  if ShowModal = mrOK then
  begin
    if IBTransaction.InTransaction then
      IBTransaction.Commit;
    IBTransaction.StartTransaction;
    ibsqlAddNewForGroup.Transaction := IBTransaction;
    ibdsTax.DisableControls;
    ibdsTax.Open;    
    try
      ibdsTax.First;
      while not ibdsTax.EOF do
      begin
        if gsibgrTax.CheckBox.RecordChecked then
        begin
          DateTimeToString(S, 'dd.mm.yyyy', xdeDate.Date);
          ibsqlAddNewForGroup.SQL.Text :=
            Format(
            ' INSERT INTO gd_goodtax (goodkey, taxkey, datetax, rate) ' +
            'SELECT g.id, %d, ''%s'', :rate FROM ' +
            '  gd_good g JOIN gd_goodgroup gr ON g.groupkey = gr.id ' +
            'WHERE ' +
            '  gr.lb >= (SELECT lb FROM gd_goodgroup g2 WHERE g2.id = %2:d) AND ' +
            '  gr.rb <= (SELECT rb FROM gd_goodgroup g2 WHERE g2.id = %2:d) AND ' +
            '    not exists (SELECT * FROM gd_goodtax gt WHERE ' +
            '   gt.goodkey = g.id and taxkey = %0:d and datetax = ''%1:S'') ',
            [ibdsTax.FieldByName('ID').AsInteger, S, aGroupKey]);
          try
            ibsqlAddNewForGroup.ParamByName('rate').AsFloat := ibdsTax.FieldByName('Rate').AsFloat;
            ibsqlAddNewForGroup.ExecQuery;
          except
            raise;
          end;
          ibsqlAddNewForGroup.Close;
        end;
        ibdsTax.Next;
      end;
    finally
      ibdsTax.EnableControls;
    end;
    Result := True;
    ibsqlAddNewForGroup.Transaction.Commit;
  end;
end;

function TdlgSelectTax.DelForGroup(const aGroupKey: Integer): Boolean;
var
  S: String;
begin
  // Инициализация
  Result := False;
  ibdsTax.Open;
  pDate.Height := OldHeight;
  if ShowModal = mrOK then
  begin
    if MessageBox(HANDLE, PChar('Будут удалены выбранные налоги на указанную дату для всех товаров ' +
      'в указанной группе. Продолжить?'), 'Внимание', mb_YesNo or mb_IconQuestion) = idNo
    then
      exit;
    if MessageBox(HANDLE, 'Произвести удаление выбранных налогов по товарам для группы?',
      'Внимание', mb_YesNo or mb_IconQuestion) = idYes
    then
    begin
      if IBTransaction.InTransaction then
        IBTransaction.Commit;
      IBTransaction.StartTransaction;
      ibsqlAddNewForGroup.Transaction := IBTransaction;
      ibdsTax.DisableControls;
      ibdsTax.Open;
      try
        ibdsTax.First;
        while not ibdsTax.EOF do
        begin
          if gsibgrTax.CheckBox.RecordChecked then
          begin
            DateTimeToString(S, 'dd.mm.yyyy', xdeDate.Date);
            ibsqlAddNewForGroup.SQL.Text :=
              Format(
                'DELETE FROM gd_goodtax WHERE goodkey IN ( ' +
                '  SELECT g.id ' +
                '  FROM   gd_good g JOIN gd_goodgroup gr ON g.groupkey = gr.id ' +
                '  WHERE ' +
                '  gr.lb >= (SELECT lb FROM gd_goodgroup g2 WHERE g2.id = %0:d) ' +
                '  AND   gr.rb <= (SELECT rb FROM gd_goodgroup g2 WHERE g2.id = %0:d)) ' +
                '  AND  taxkey = %1:d and datetax = ''%2:s''',
                [aGroupKey, ibdsTax.FieldByName('ID').AsInteger, S]);
            try
              ibsqlAddNewForGroup.ExecQuery;
            except
              raise;
            end;
            ibsqlAddNewForGroup.Close;
          end;
          ibdsTax.Next;
        end;
      finally
        ibdsTax.EnableControls;
      end;
    end;
    Result := True;
    ibsqlAddNewForGroup.Transaction.Commit;
  end;
end;


function TdlgSelectTax.ActiveDialog(const aGoodKey: Integer; isChoose: Boolean): Boolean;
begin
  // Инициализация
  Result := False;
  FGoodKey := aGoodKey;
  ibdsTax.Open;
  if ShowModal = mrOK then
  begin
    if isChoose then
    begin
      ibsqlAddNew.Transaction := ibdsTax.Transaction;
      ibdsTax.DisableControls;
      try
        ibdsTax.First;
        while not ibdsTax.EOF do
        begin
          if gsibgrTax.CheckBox.RecordChecked then
          begin
            if not ibsqlAddNew.Prepared then
              ibsqlAddNew.Prepare;
            ibsqlAddNew.Params.ByName('goodkey').AsInteger := FGoodKey;
            ibsqlAddNew.Params.ByName('taxkey').AsInteger := ibdsTax.FieldByName('ID').AsInteger;
            ibsqlAddNew.Params.ByName('datetax').AsDateTime := xdeDate.Date;
            ibsqlAddNew.Params.ByName('rate').AsFloat := ibdsTax.FieldByName('Rate').AsFloat;
            try
              ibsqlAddNew.ExecQuery;
            except
            end;
            ibsqlAddNew.Close;
          end;
          ibdsTax.Next;
        end;
      finally
        ibdsTax.EnableControls;
      end;
      Result := True;
    end;
  end;
end;

procedure TdlgSelectTax.actAddTaxExecute(Sender: TObject);
begin
  // Добавляем новый налог
  with TdlgAddTax.Create(Self) do
  begin
    try
      dsTax.DataSet := ibdsTax;
      ActiveDialog(-1);
    finally
      Free;
    end;
  end;
end;

procedure TdlgSelectTax.actEditTaxExecute(Sender: TObject);
begin
  // Редактирование налога
  // Проверка на выбор налога для редактирования
  if ibdsTax.FieldByName('ID').IsNull  then exit;
  with TdlgAddTax.Create(Self) do
  begin
    try
      dsTax.DataSet := ibdsTax;
      ActiveDialog(ibdsTax.FieldByName('ID').AsInteger);
    finally
      Free;
    end;
  end;
end;

procedure TdlgSelectTax.actDelTaxExecute(Sender: TObject);
begin
  // Удаление налога
  // Проверка на выбор налога для удаления
  if ibdsTax.FieldByName('ID').IsNull  then exit;
  if MessageBox(HANDLE, PChar(Format('Удалить налог %s?', [ibdsTax.FieldByName('name').AsString])),
   'Внимание', mb_YesNo or mb_IconQuestion) = idYes
  then
  begin
    try
      ibdsTax.Delete;
    except
      MessageBox(HANDLE, 'Невозможно удалить налог, т.к. он уже используется',
        'Внимание', mb_Ok or mb_IconExclamation);
    end;
  end;
end;

procedure TdlgSelectTax.actSelectExecute(Sender: TObject);
var
  Bookmark: TBookmark;
begin
  // Отмечаем для добавления выделенные налоги
  Bookmark := ibdsTax.GetBookmark;
  ibdsTax.DisableControls;
  try
    ibdsTax.First;
    while not ibdsTax.EOF do
    begin
      gsibgrTax.CheckBox.AddCheck(ibdsTax.FieldByName('ID').AsInteger);
      ibdsTax.Next;
    end;
  finally
    ibdsTax.GotoBookmark(Bookmark);
    ibdsTax.FreeBookmark(Bookmark);
    ibdsTax.EnableControls;
  end;
end;

procedure TdlgSelectTax.gsibgrTaxDblClick(Sender: TObject);
begin
  // Редактирование налога по двойному щелчку
  actEditTax.Execute;
end;

procedure TdlgSelectTax.gsibgrTaxKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    actEditTax.Execute;
end;

procedure TdlgSelectTax.FormCreate(Sender: TObject);
begin
  GlobalStorage.LoadComponent(gsibgrTax, gsibgrTax.LoadFromStream);
{  OldHeight := pDate.Height;
  pDate.Height := 0;}
end;

procedure TdlgSelectTax.FormDestroy(Sender: TObject);
begin
  GlobalStorage.SaveComponent(gsibgrTax, gsibgrTax.SaveToStream);
end;

procedure TdlgSelectTax.actEditTaxUpdate(Sender: TObject);
begin
  actEditTax.Enabled := not ibdsTax.FieldByName('ID').IsNull;
end;

procedure TdlgSelectTax.actDelTaxUpdate(Sender: TObject);
begin
  actDelTax.Enabled := not ibdsTax.FieldByName('ID').IsNull;
end;

procedure TdlgSelectTax.LoadSettings;
begin
  inherited;
  UserStorage.LoadComponent(gsibgrTax, gsibgrTax.LoadFromStream);
end;

procedure TdlgSelectTax.SaveSettings;
begin
  inherited;
  UserStorage.SaveComponent(gsibgrTax, gsibgrTax.SaveToStream);
end;

function TdlgSelectTax.GetTaxDate: TDate;
begin
  Result := xdeDate.Date;
end;

end.
