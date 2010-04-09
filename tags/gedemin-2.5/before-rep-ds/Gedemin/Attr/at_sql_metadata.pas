
{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    at_sql_metadata

  Abstract

    TmetaRelationField, TmetaRelation - classes that make
    sql statements to create interbase metadata.

  Author

    Romanovski Denis  (04.01.2001)

  Revisions history

    1.00    04.01.2001    Denis    Initial Version.
    1.01    24.12.2001    Michael  Добавлена возможность формирования триггера для таблицы INV_CARD

--}

unit at_sql_metadata;

interface

uses
  Windows, SysUtils, Classes, Contnrs, DB, IBDatabase,
  IBCustomDataSet, IBSQL, at_Classes;

type
  TmetaMultiConnection = class
  private
    FOperations: TStringList;  //Список для sql
    FTransactions: TStringList;//Cписок для номера транзакций, сопоставимый с FOperations
    FOrders: TStringList; //Cписок для порядка действий, сопоставимый с FOperations
    FSuccessful: TStringList; //Список успешного завершения

    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;

    FCurrTransaction: Integer;
    FStartOrder: Integer;

    function ReadMultiTransaction: Boolean;
    procedure Delete(Index: Integer);

  public
    constructor Create;
    destructor Destroy; override;

    function RunScripts(Const TransferToModal: Boolean = True): Boolean;

  end;


  EmetaError = class(Exception);

function GetUniqueID(D: TIBDatabase; T: TIBTransaction;
  GenName: String = 'gd_g_triggercross'): String;

implementation

uses
  gd_security,
  at_frmSQLProcess,
  Graphics,
  IB,
  IBErrorCodes,
  at_frmIBUserList
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{
  *********************************************
  ***  Additional procedures and functions  ***
  *********************************************
}

// Уникальный идентификатор для Interbase-овских имен
function GetUniqueID(D: TIBDatabase; T: TIBTransaction;
  GenName: String = 'gd_g_triggercross'): String;
var
  ibsqlWork: TIBSQL;
begin
  ibsqlWork := TIBSQL.Create(nil);
  try
    ibsqlWork.Database := D;
    ibsqlWork.Transaction := T;
    ibsqlWork.SQL.Text := Format(
      'SELECT GEN_ID(%s, 1) FROM rdb$database', [GenName]
    );
    ibsqlWork.ExecQuery;
    Result := ibsqlWork.Fields[0].AsString;
  finally
    ibsqlWork.Close;
    ibsqlWork.Free;
  end;
end;


{ TmetaMultiConnection }

constructor TmetaMultiConnection.Create;
begin
  FOperations := TStringList.Create;
  FTransactions := TStringList.Create;
  FOrders := TStringList.Create;
  FSuccessful := TStringList.Create;

{  FDatabase := TIBDatabase.Create(nil); }

  FTransaction := TIBTransaction.Create(nil);
  FTransaction.Params.Text :=
    'read_committed'#13#10'rec_version'#13#10'nowait'#13#10;

  FCurrTransaction := 0;
  FStartOrder := 1;
end;

destructor TmetaMultiConnection.Destroy;
begin
  FOperations.Free;
  FTransactions.Free;
  FOrders.Free;
  FSuccessful.Free;

  FTransaction.Free;

  inherited;
end;

function TmetaMultiConnection.RunScripts(Const TransferToModal: Boolean = True): Boolean;
var
  ibsql: TIBSQL;
  OldScript: String;
  CurrTransaction: String;
begin
  //
  // Устанавливаем настройки для подключения

  FDataBase := IBLogin.Database;

  FTransaction.DefaultDatabase := FDatabase;

  Assert(atDatabase <> nil);
  CurrTransaction := '';

  Result := True;
  //Сбрасываем флаг "Требуется переподключение"
  atDatabase.CancelMultiConnectionTransaction(True);

  //Проверяем, есть ли у нас что-либо в таблице at_transaction
  if ReadMultiTransaction then
  begin
    try
      ibsql := TIBSQL.Create(nil);
      frmIBUserList := nil;

      if TransferToModal then
        AddText('Начато создание мета-данных.', clBlack);

      try
        ibsql.Transaction := FTransaction;
        ibsql.Database := FDatabase;
        ibsql.ParamCheck := False;

        while FOperations.Count > 0 do
        begin
          //
          //  Подключаемся открываем транзакцию

          Self.FDatabase.Connected := True;
          Self.FTransaction.Active := True;

          //
          //  Вносим sql-скрипт
          try
            if OldScript = '' then
            begin
              AddText(TranslateText(FOperations[0]), clBlack);
              AddText(FOperations[0], clBlack);
            end;
            ibsql.SQL.Text := FOperations[0];

            if frmIBUserList = nil then
              frmIBUserList := TfrmIBUserList.Create(nil);

            if not frmIBUserList.CheckUsers then
              raise EmetaError.Create('К базе подключены другие пользователи! ' +
                ' Процесс создания метаданных приостановлен!');

            ibsql.ExecQuery;
            ibsql.FreeHandle;

            ibsql.SQL.Text := Format(
              'DELETE FROM at_transaction WHERE trkey = %s AND numorder = %s',
              [FTransactions[0], FOrders[0]]
            );

            ibsql.ExecQuery;

            Self.FTransaction.Commit;

            Delete(0);

            OldScript := '';
          except
            // Теперь мы делаем переподключение к базе, только если иначе не выполняется скрипт
            //Сохраняем скрипт который не выполнился
            on E: Exception do
            begin
              if (E is EIBError) and (EIBError(E).IBErrorCode = 335544721) then
              begin
                MessageBox(0,
                  'Внимание! '#13#10#13#10 +
                  'Потеряно соединение с сервером базы данных.'#13#10#13#10 +
                  'Обратитесь к системному администратору.',
                  'Серьезная ошибка',
                  MB_OK or MB_ICONHAND or MB_TASKMODAL);
                //Application.Terminate;
                System.Halt(1);
              end;

              if OldScript = '' then
                OldScript := FOperations[0]
                //если этот скрип не выполнился уже второй раз
              else if OldScript = FOperations[0] then
              begin
                //Проверяем обязательно ли выполнение скрипта
                //Если нет, выдаем сообщение об ошибке и удаляем этот скрипт
                if FSuccessful[0] = '0' then
                begin
                  AddMistake('Ошибка при выполнении скрипта: '#13#10 + E.Message +
                  #13#10 + 'Скрипт будет удален!', clRed);
                  CurrTransaction := FTransactions[0];
                  try
                    Self.FTransaction.Rollback;
                    Self.FTransaction.StartTransaction;
                    ibsql.Close;
                    ibsql.SQL.Text := Format(
                      'DELETE FROM at_transaction WHERE trkey = %s AND numorder = %s ',
                      [FTransactions[0], FOrders[0]]);
                    ibsql.ExecQuery;
                    Self.FTransaction.Commit;
                    AddMistake('Скрипт удален!', clRed);
                  except
                  end;
                  Delete(0);
                end else
                begin
                  //Если выполнение скрипта обязательно,
                  //то выдаем запрос на удаление всех скриптов на этой транзакции
                  AddMistake('Ошибка! Попробуйте перезагрузиться или обратитесь к администратору!', clRed);
                  AddMistake(E.Message, clRed);
                  CurrTransaction := FTransactions[0];

                  if MessageBox(0, PChar('При выполнении скрипта '#13#10 +
                    Copy(FOperations[0], 1, 100) + #13#10 +
                    ' произошла ошибка: '#13#10 +
                    E.Message + #13#10 +
                    ' Вы можете попробовать перезагрузиться и ' +
                    ' выполнить скрипт еще раз или удалить этот скрипт из списка. ' +
                    ' Удалить этот скрипт из списка? '), 'Ошибка!', MB_ICONSTOP or MB_YESNO or MB_TASKMODAL) = IDYES
                  then
                  try
                    Self.FTransaction.Rollback;
                    Self.FTransaction.StartTransaction;
                    ibsql.Close;
                    ibsql.SQL.Text := Format(
                      'DELETE FROM at_transaction WHERE trkey = %s ',
                      [FTransactions[0]]);
                    ibsql.ExecQuery;
                    Self.FTransaction.Commit;
                    AddMistake('Скрипт удален!', clRed);
                  except
                  end;

                  //Удалим все остальные операции на этой транзакции
                  while (FTransactions.Count > 0) and (FTransactions[0] = CurrTransaction) do
                  begin
                    Delete(0);
                  end;
                end;
                OldScript := '';
              end;
              //  Закрываем транзакцию, отключаемся
              if Self.FTransaction.InTransaction then
                Self.FTransaction.Rollback;
              Self.FDatabase.Connected := False;
            end;
          end;
        end;
        Self.FDatabase.Connected := False;

      finally
        ibsql.Free;
        frmIBUserList.Free;
        if FTransaction.Active then
          FTransaction.Rollback;
        if TransferToModal then
        begin
          AddText('Закончено создание мета-данных.', clBlack);
          if Assigned(frmSQLProcess) then
          begin
            if frmSQLProcess.Visible then
              frmSQLProcess.Hide;
            frmSQLProcess.ShowModal;
          end;
        end;
      end;

    except
      Result := False;
    end;

  end;
end;

function TmetaMultiConnection.ReadMultiTransaction: Boolean;
var
  ibsql: TIBSQL;
  WasActivate, WasConnected: Boolean;
begin
  ibsql := TIBSQL.Create(nil);
  WasConnected := FDatabase.Connected;
  WasActivate := FTransaction.Active;
  try
    ibsql.Transaction := FTransaction;
    ibsql.Database := FDatabase;

    FOperations.Clear;
    FTransactions.Clear;
    FOrders.Clear;
    FSuccessful.Clear;

    try
      if not WasConnected then
        FDatabase.Connected := True;
      if not WasActivate then
        FTransaction.Active := True;

      ibsql.SQL.Text := 'SELECT * FROM at_transaction tr ORDER BY tr.trkey, tr.numorder';
      ibsql.ExecQuery;
      //
      //  Считываем операции транзакции
      while not ibsql.EOF do
      begin
        FOperations.Add(ibsql.FieldByName('script').AsString);
        FTransactions.Add(ibsql.FieldByName('trkey').AsString);
        FOrders.Add(ibsql.FieldByName('numorder').AsString);
        FSuccessful.Add(ibsql.FieldByName('successfull').AsString);
        ibsql.Next;
      end;

      if (not WasActivate) and FTransaction.InTransaction then
        FTransaction.Commit;
      if not WasConnected then
        FDatabase.Connected := False;

      Result := FOperations.Count > 0;
    except
      if (not WasActivate) and FTransaction.InTransaction then
        FTransaction.Rollback;
      if not WasConnected then
        FDatabase.Connected := False;
      Result := False;
    end;

  finally
    ibsql.Free;
  end;
end;

procedure TmetaMultiConnection.Delete(Index: Integer);
begin
  if FOperations.Count > 0 then
  begin
    FOperations.Delete(Index);
    FTransactions.Delete(Index);
    FOrders.Delete(Index);
    FSuccessful.Delete(Index);
  end;
end;

end.

