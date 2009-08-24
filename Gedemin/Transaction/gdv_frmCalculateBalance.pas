unit gdv_frmCalculateBalance;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Mask, xDateEdits, gd_createable_form, gd_ClassList,
  ComCtrls, IBDatabase;

type
  TfrmCalculateBalance = class(TCreateableForm)
    pnlMain: TPanel;
    gbMain: TGroupBox;
    lblCurrentDate: TLabel;
    xdeCurrentDate: TxDateEdit;
    btnClose: TButton;
    lblPreviousDate: TLabel;
    xdePreviousDate: TxDateEdit;
    pbMain: TProgressBar;
    btnCalculate: TButton;
    lblProgress: TLabel;
    lblTime: TLabel;
    procedure FormShow(Sender: TObject);
    procedure btnCalculateClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
    procedure SetProcessText(AText: String);
    procedure DoOnAbortProcess(Tr: TIBTransaction);
  end;

  // Расчитывает сальдо на дату и заносит данные в таблицу AC_ENTRY_BALANCE
  procedure CalculateBalance(ADate: TDate; ProgressBar: TProgressBar = nil; WriteTransaction: TIBTransaction = nil);

var
  frmCalculateBalance: TfrmCalculateBalance;

implementation

uses
  IBSQL, AcctUtils, at_classes, gdcBaseInterface;

{$R *.DFM}

procedure CalculateBalance(ADate: TDate; ProgressBar: TProgressBar = nil; WriteTransaction: TIBTransaction = nil);
const
  ibMainBegin =
    ' SELECT ' +
    '  companykey, ' +
    '  accountkey, ' +
    '  currkey, ' +
    '  SUM(debitncu) AS DebitNCU, ' +
    '  SUM(creditncu) AS CreditNCU, ' +
    '  SUM(debitcurr) AS DebitCURR, ' +
    '  SUM(creditcurr) AS CreditCURR, ' +
    '  SUM(debiteq) AS Debiteq, ' +
    '  SUM(crediteq) AS Crediteq ';
  ibMainMiddle =
    ' FROM ' +
    '  ac_entry ' +
    ' WHERE ' +
    '  accountkey = :acckey ' +
    '  AND entrydate < :balancedate ' +
    ' GROUP BY ' +
    '  companykey, ' +
    '  accountkey, ' +
    '  currkey ';
  ibMainEnd =
    ' HAVING ' +
    '   SUM(debitncu - creditncu) <> 0 ' +
    '   OR SUM(debitcurr - creditcurr) <> 0 ' +
    '   OR SUM(debiteq - crediteq) <> 0 ';
  ibWriteBegin =
    ' INSERT INTO ac_entry_balance ' +
    ' (companykey, accountkey, currkey, debitncu, creditncu, debitcurr, creditcurr, debiteq, crediteq ';
  ibWriteValues =
    ') VALUES (:companykey, :accountkey, :currkey, :debitncu, :creditncu, :debitcurr, :creditcurr, :debiteq, :crediteq ';

var
  ibsql: TIBSQL;
  ibsqlAccount: TIBSQL;
  ibsqlWrite: TIBSQL;
  Transaction: TIBTransaction;
  Relation: TatRelation;
  I: Integer;
  AvailableAnalytics: TStringList;
  Analytics: String;
  BalanceAnalytics, InsertAnalytics: String;
begin
  if Assigned(frmCalculateBalance) then
    frmCalculateBalance.SetProcessText('Расчет начался...');

  // Занесем названия всех полей-аналитик в строку
  Relation := atDatabase.Relations.ByRelationName('AC_ACCOUNT');
  Analytics := '';
  AvailableAnalytics := TStringList.Create;
  try
    for I := 0 to Relation.RelationFields.Count - 1 do
    begin
      if Relation.RelationFields.Items[I].IsUserDefined then
      begin
        if Analytics <> '' then
          Analytics := Analytics + ',';
        Analytics := Analytics + ' ac.' + Relation.RelationFields.Items[I].FieldName;
        AvailableAnalytics.Add(Relation.RelationFields.Items[I].FieldName);
      end;
    end;

    Transaction := TIBTransaction.Create(nil);
    ibsql := TIBSQL.Create(nil);
    ibsqlAccount := TIBSQL.Create(nil);
    ibsqlWrite := TIBSQL.Create(nil);
    try
      Transaction.DefaultDatabase := gdcBaseManager.Database;
      Transaction.StartTransaction;
      try
        ibsql.Transaction := Transaction;
        ibsqlAccount.Transaction := Transaction;
        if Assigned(WriteTransaction) then
          ibsqlWrite.Transaction := WriteTransaction    // Транзакция должна прийти активной
        else
          ibsqlWrite.Transaction := Transaction;

        // Получим кол-во счетов
        ibsql.SQL.Text := 'SELECT COUNT(ag.id) as AccCount FROM ac_account ag';
        ibsql.ExecQuery;

        // Визуализация процесса
        if Assigned(frmCalculateBalance) then
        begin
          frmCalculateBalance.SetProcessText('Удаление устаревших данных...');
        end;
        if Assigned(ProgressBar) then
        begin
          ProgressBar.Position := 0;
          ProgressBar.Max := ibsql.FieldByName('AccCount').AsInteger;
          if Assigned(ProgressBar.Owner) then
            UpdateWindow(TWinControl(ProgressBar.Owner).Handle);
        end;

        // Удалим старые данные сальдо
        ibsqlWrite.SQL.Text := 'DELETE FROM ac_entry_balance';
        ibsqlWrite.ExecQuery;

        // Вытянем все счета
        ibsqlAccount.SQL.Text :=
          ' SELECT ' +
          '   ac.id, ac.alias ' +
            IIF(Analytics <> '', ', ' + Analytics, '') +
          ' FROM ' +
          '   ac_account ac ' +
          ' ORDER BY ' +
          '   ac.alias ';
        ibsqlAccount.ExecQuery;

        while not ibsqlAccount.Eof do
        begin
          // При нажатии Escape прервем процесс
          if (GetAsyncKeyState(VK_ESCAPE) shr 1) <> 0 then
          begin
            if Assigned(frmCalculateBalance) then
              frmCalculateBalance.DoOnAbortProcess(Transaction);
            Exit;
          end;

          // Визуализация процесса
          if Assigned(frmCalculateBalance) then
          begin
            frmCalculateBalance.SetProcessText(IntToStr(ProgressBar.Position) + ' из ' +
              IntToStr(ProgressBar.Max) + ': ' + ibsqlAccount.FieldByName('ALIAS').AsString);
          end;
          if Assigned(ProgressBar) then
          begin
            ProgressBar.StepBy(1);
            if Assigned(ProgressBar.Owner) then
              UpdateWindow(TWinControl(ProgressBar.Owner).Handle);
          end;

          // возьмем выбранные аналитики по расчитываемому счету
          BalanceAnalytics := '';
          InsertAnalytics := '';
          for I := 0 to AvailableAnalytics.Count - 1 do
          begin
            if ibsqlAccount.FieldByName(AvailableAnalytics.Strings[I]).AsInteger = 1 then
            begin
              BalanceAnalytics := BalanceAnalytics + ', ' + AvailableAnalytics.Strings[I];
              InsertAnalytics := InsertAnalytics + ', :' + AvailableAnalytics.Strings[I];
            end;
          end;

          // Сформируем запрос на запись
        {  ibsqlWrite.Close;
          ibsqlWrite.SQL.Text := ibWriteBegin + BalanceAnalytics + ibWriteValues + InsertAnalytics + ') ';
          ibsqlWrite.Prepare;

          // Сформируем запрос на чтение проводок
          ibsql.Close;
          ibsql.SQL.Text := ibMainBegin +
            BalanceAnalytics + ibMainMiddle + BalanceAnalytics + ibMainEnd;
          ibsql.ParamByName('BALANCEDATE').AsDateTime := ADate;
          ibsql.ParamByName('ACCKEY').AsInteger := ibsqlAccount.FieldByName('ID').AsInteger;
          ibsql.ExecQuery;

          while not ibsql.Eof do
          begin
            for I := 0 to ibsqlWrite.Params.Count - 1 do
              ibsqlWrite.Params[I].AsXSQLVAR := ibsql.Fields[I].AsXSQLVAR;
            ibsqlWrite.ExecQuery;
            ibsql.Next;
          end;  }

          // Сформируем запрос на запись
          ibsql.Close;
          ibsql.SQL.Text := ibWriteBegin + BalanceAnalytics + ') ' + ibMainBegin +
            BalanceAnalytics + ibMainMiddle + BalanceAnalytics + ibMainEnd;
          ibsql.ParamByName('BALANCEDATE').AsDateTime := ADate;
          ibsql.ParamByName('ACCKEY').AsInteger := ibsqlAccount.FieldByName('ID').AsInteger;
          ibsql.ExecQuery;

          ibsqlAccount.Next;
        end;

        // Установим новое значение генератора gd_g_entry_balance_date
        ibsqlWrite.Close;
        ibsqlWrite.SQL.Text :=
          Format('SET GENERATOR gd_g_entry_balance_date TO %d', [Round(ADate) + IBDateDelta]);
        ibsqlWrite.ExecQuery;

        // Визуализация процесса
        if Assigned(frmCalculateBalance) then
        begin
          frmCalculateBalance.SetProcessText('Расчет сальдо закончен');
        end;
        if Assigned(ProgressBar) then
        begin
          ProgressBar.Max := ProgressBar.Position;
          if Assigned(ProgressBar.Owner) then
            UpdateWindow(TWinControl(ProgressBar.Owner).Handle);
        end;

        if Transaction.InTransaction then
          Transaction.Commit;

      except
        if Transaction.InTransaction then
          Transaction.Rollback;
        raise;    
      end;
    finally
      ibsqlAccount.Free;
      ibsql.Free;
      Transaction.Free;
    end;
  finally
    AvailableAnalytics.Free;
  end;
end;

{ TfrmCalculateBalance }

class function TfrmCalculateBalance.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(frmCalculateBalance) then
    frmCalculateBalance := TfrmCalculateBalance.Create(AnOwner);
  Result := frmCalculateBalance;
end;

procedure TfrmCalculateBalance.FormShow(Sender: TObject);
var
  PreviousBalanceDate: TDate;
  Year, Month, Day: Word;
begin
  PreviousBalanceDate := GetCalculatedBalanceDate;
  // Если сальдо уже рассчитывалось, то текущий расчет будем производить на месяц позже
  if PreviousBalanceDate > 0 then
  begin
    xdePreviousDate.Date := PreviousBalanceDate;
    xdeCurrentDate.Date := IncMonth(PreviousBalanceDate, 1);
  end
  else
  begin
    // ...иначе на начало текущего месяца
    DecodeDate(Date, Year, Month, Day);
    xdePreviousDate.Clear;
    xdeCurrentDate.Date := EncodeDate(Year, Month, 1);
  end;

  pbMain.Position := 0;
  lblProgress.Caption := '';
  lblTime.Caption := '';
end;

procedure TfrmCalculateBalance.btnCalculateClick(Sender: TObject);
var
  StartTime: TDateTime;
begin
  if Assigned(atDatabase.Relations.ByRelationName('AC_ENTRY_BALANCE'))
     and (xdeCurrentDate.Date > 0) then
  begin
    btnCalculate.Enabled := False;
    btnClose.Enabled := False;
    StartTime := Time;
    lblTime.Caption := 'Расчет начат в ' + TimeToStr(StartTime);
    try
      CalculateBalance(xdeCurrentDate.Date, pbMain);
    except
      Self.SetProcessText('Произошла ошибка! Расчет прерван');
      btnCalculate.Enabled := True;
      btnClose.Enabled := True;
      raise;
    end;
    lblTime.Caption := 'Расчет начат в ' + TimeToStr(StartTime) +
      ', продолжался ' + TimeToStr(Time - StartTime);
    btnCalculate.Enabled := True;
    btnClose.Enabled := True;
  end;
end;

procedure TfrmCalculateBalance.btnCloseClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmCalculateBalance.DoOnAbortProcess(Tr: TIBTransaction);
begin
  if Tr.InTransaction then
    Tr.Rollback;
  Self.SetProcessText('Расчет прерван');
  btnCalculate.Enabled := True;
  btnClose.Enabled := True;
end;

procedure TfrmCalculateBalance.SetProcessText(AText: String);
begin
  lblProgress.Caption := AText;
  Self.BringToFront;
  UpdateWindow(Self.Handle);
end;

initialization
  RegisterClass(TfrmCalculateBalance);
finalization
  UnRegisterClass(TfrmCalculateBalance);

end.
