unit gdClosingPeriod;

interface

uses
  IBDatabase, Classes, SysUtils, gd_KeyAssoc, gdcBaseInterface, stdctrls, comctrls,
  IBSQL;

type
  TgdClosingPeriod = class(TObject)
  private
    FWriteTransaction: TIBTransaction;

    FLocalStartTime: TDateTime;

    FExtDatabasePath: String;
    FExtDatabaseServer: String;
    FExtDatabaseUser: String;
    FExtDatabasePassword: String;
    FCloseDate: TDateTime;
    // Список внешних ключей на таблицы:
    //   имя таблицы - объект-список внешних ключей
    FTableReferenceForeignKeysList: TStringList;
    // Список полей-признаков складской карточки из настроек
    FFeatureList: TStringList;
    // Количество созданных записей в AC_ENTRY_BALANCE
    FInsertedEntryBalanceRecordCount: Integer;
    // Список бухгалтерских аналитик, в разрезе которых строится бух. сальдо
    FEntryAvailableAnalytics: TStringList;
    // Сущестует ли поле-ссылка на позицию прихода
    FAddLineKeyFieldExists: Boolean;
    FInvDocumentTypeKey: TID;

    FUserDocumentTypesToDelete: TgdKeyArray;
    FDontDeleteDocumentTypes: TgdKeyArray;

    FProgressBar: TProgressBar;
    FProgressBarLabel: TLabel;
    FMessageLogMemo: TMemo;
    FMessageLog: TStringList;
    FDoMaintainLog: Boolean;

    FQueriesInitialized: Boolean;
    FIBSQLInsertGdDocument: TIBSQL;
    FIBSQLInsertDocumentHeader: TIBSQL;
    FIBSQLInsertDocumentPosition: TIBSQL;
    FIBSQLInsertInvCard: TIBSQL;
    FIBSQLInsertInvMovement: TIBSQL;

    //procedure InsertDatabaseRecord;
    function GetFeatureFieldList(AAlias: String): String;
    function IIF(const Condition: Boolean; const TrueString, FalseString: String): String;

    function AddDepotHeader(const FromContact, ToContact, CompanyKey: TID): TID;
    function AddDepotPosition(const FromContact, ToContact, CompanyKey,
      ADocumentParentKey, CardGoodkey: TID; const GoodQuantity: Currency; FeatureDataset: TIBSQL = nil): TID;

    procedure InitialFillOptions;
    procedure InitializeIBSQLQueries;

    procedure AddLogMessage(const AMessage: String);
    procedure SetupProgressBar(const APosition, AMaxPosition: Integer);
    procedure StepProgressBar(const AStepValue: Integer = 1);
    procedure SetMessageLogMemo(const Value: TMemo);
  public
    constructor Create(Transaction: TIBTransaction);
    destructor Destroy; override;

    // Заполнение и очистка списка типов складских документов, которые нельзя 'закрывать'
    procedure AddDontDeleteDocumentType(DocType: TID);
    procedure ClearDontDeleteDocumentTypes;
    // Заполнение и очистка списка типов пользовательских докуметов подлежащих 'закрытию'
    procedure AddUserDocumentTypeToDelete(DocType: TID);
    procedure ClearUserDocumentTypesToDelete;
    // Заполнение и очистка списка актуальных складских признаков
    procedure AddInvCardFeature(FeatureFieldName: String);
    procedure ClearInvCardFeatures;

    // Включает\выключает триггеры которые мешают 'закрытию периода'
    procedure SetTriggerActive(SetActive: Boolean);
    // Подсчет бухгалтерского сальдо
    procedure CalculateEntryBalance;
    // Подсчет складских остатков
    procedure CalculateRemains;
    // Перепривязка складских карточек и движения
    procedure ReBindDepotCards;
    // Удаление проводок
    procedure DeleteEntry;
    // Процедура пытается удалить записи ссылающиеся на переданную
    procedure TryToDeleteDocumentReferences(AID: TID; AdditionalRelationName: String);
    // Удаление складских документов
    procedure DeleteDocuments;
    // Удаление пользовательских документов
    procedure DeleteUserDocuments;
    // Перенос бухгалтерского сальдо из AC_ENTRY_BALANCE в AC_ENTRY
    procedure TransferEntryBalance;

    // Последовательное выполение всех действий для 'закрытия периода'
    procedure DoClosePeriod;

    property WriteTransaction: TIBTransaction read FWriteTransaction write FWriteTransaction;

    property ExternalDatabasePath: String read FExtDatabasePath write FExtDatabasePath;
    property ExternalDatabaseServer: String read FExtDatabaseServer write FExtDatabaseServer;
    property ExternalDatabaseUser: String read FExtDatabaseUser write FExtDatabaseUser;
    property ExternalDatabasePassword: String read FExtDatabasePassword write FExtDatabasePassword;

    property CloseDate: TDateTime read FCloseDate write FCloseDate;

    property ProgressBarLabel: TLabel read FProgressBarLabel write FProgressBarLabel;
    property ProgressBar: TProgressBar read FProgressBar write FProgressBar;
    property MessageLogMemo: TMemo read FMessageLogMemo write SetMessageLogMemo;
    property DoMaintainLog: Boolean read FDoMaintainLog write FDoMaintainLog;
  end;

implementation

uses
  gdcInvDocument_unit, at_classes, gd_security,
  Windows, Forms, db, contnrs, AcctUtils, AcctStrings, controls;

const
  InvDocumentRUID = '174849703_1094302532';
  REFRESH_CLOSING_INFO_INTERVAL = 100;

{ TgdClosingPeriod }

constructor TgdClosingPeriod.Create(Transaction: TIBTransaction);
begin
  if Assigned(Transaction) then
    FWriteTransaction := Transaction;

  FTableReferenceForeignKeysList := TStringList.Create;
  // Список полей-признаков складской карточки из настроек
  FFeatureList := TStringList.Create;

  FUserDocumentTypesToDelete := TgdKeyArray.Create;
  FDontDeleteDocumentTypes := TgdKeyArray.Create;

  FEntryAvailableAnalytics := TStringList.Create;

  FInsertedEntryBalanceRecordCount := 0;

  FProgressBar := nil;
  FMessageLogMemo := nil;
  FMessageLog := TStringList.Create;
  FDoMaintainLog := False;

  FIBSQLInsertGdDocument := TIBSQL.Create(nil);
  FIBSQLInsertDocumentHeader := TIBSQL.Create(nil);
  FIBSQLInsertDocumentPosition := TIBSQL.Create(nil);
  FIBSQLInsertInvCard := TIBSQL.Create(nil);
  FIBSQLInsertInvMovement := TIBSQL.Create(nil);
  FQueriesInitialized := False;

  InitialFillOptions;
end;

destructor TgdClosingPeriod.Destroy;
begin
  // Если было указано вести лог, но никакой визуальной формы не использовалось
  if FDoMaintainLog and not Assigned(FMessageLogMemo) then
  begin
    // спросить у пользователя о сохранении лога закрытия
  end;

  FIBSQLInsertGdDocument.Free;
  FIBSQLInsertDocumentHeader.Free;
  FIBSQLInsertDocumentPosition.Free;
  FIBSQLInsertInvCard.Free;
  FIBSQLInsertInvMovement.Free;

  FMessageLog.Free;
  FEntryAvailableAnalytics.Free;
  FDontDeleteDocumentTypes.Free;
  FUserDocumentTypesToDelete.Free;
  FFeatureList.Free;
  FTableReferenceForeignKeysList.Free;
end;

procedure TgdClosingPeriod.AddDontDeleteDocumentType(DocType: TID);
begin
  FDontDeleteDocumentTypes.Add(DocType);
end;

procedure TgdClosingPeriod.ClearUserDocumentTypesToDelete;
begin
  FUserDocumentTypesToDelete.Clear;
end;

procedure TgdClosingPeriod.AddUserDocumentTypeToDelete(DocType: TID);
begin
  FUserDocumentTypesToDelete.Add(DocType);
end;

procedure TgdClosingPeriod.ClearDontDeleteDocumentTypes;
begin
  FDontDeleteDocumentTypes.Clear;
end;

procedure TgdClosingPeriod.AddInvCardFeature(FeatureFieldName: String);
begin
  FFeatureList.Add(FeatureFieldName);
end;

procedure TgdClosingPeriod.ClearInvCardFeatures;
begin
  FFeatureList.Clear;
end;

procedure TgdClosingPeriod.CalculateRemains;
var
  moveFieldList, balFieldList, cFieldList: String;
  PseudoClient: TID;
  ibsql: TIBSQL;
  CurrentContactKey, NextSupplierKey, CurrentSupplierKey: TID;
  LineCount: Integer;
  DocumentParentKey: TID;
begin
  InitializeIBSQLQueries;

  // Запомним время начала расчета остатков
  FLocalStartTime := Time;
  // Визуализация процесса
  SetupProgressBar(0, 1);
  AddLogMessage(TimeToStr(FLocalStartTime) + ': Формирование остатков...');

  // Заполним список полей-признаков складской карточки из настроек
  moveFieldList := GetFeatureFieldList('move.');
  balFieldList := GetFeatureFieldList('bal.');
  cFieldList := GetFeatureFieldList('c.');

  // На Псевдоклиента будет оформлятся расход товара при формировании остатков
  PseudoClient := gdcBaseManager.GetIDByRUID(147004309, 31587988);            // TODO: заменить взятие ИД на выбор контакта в настройках

  ibsql := TIBSQL.Create(nil);
  try
    // Запрос на складские остатки
    // TODO: смотреть поле для поиска поставщика (usr$inv_addlinekey) по настройкам
    ibsql.Transaction := gdcBaseManager.ReadTransaction;
    ibsql.SQL.Text :=
      ' SELECT ' +
      '  move.contactkey, ' +
      '  cont.name AS ContactName, ' +
      '  move.SupplierKey, ' +
      '  move.goodkey, ' +
      '  move.companykey, ' +
      '  move.balance ' +
        IIF(moveFieldList <> '', ', ' + moveFieldList, '') +
      ' FROM ' +
      '  ( ' +
      '  SELECT ' +
      '    bal.contactkey, ' +
      '    inv_doc.usr$contactkey AS SupplierKey, ' +
      '    bal.goodkey, ' +
      '    bal.companykey, ' +
      '    SUM(bal.balance) AS balance ' +
        IIF(balFieldList <> '', ', ' + balFieldList, '') +
      '  FROM ' +
      '    ( ' +
      '    SELECT ' +
      '      b.contactkey, ' +
      '      c.goodkey, ' +
      '      c.companykey, ' +
      '      c.usr$inv_addlinekey, ' +
      '      SUM(b.balance) AS balance ' +
        IIF(cFieldList <> '', ', ' + cFieldList, '') +
      '    FROM ' +
      '      inv_balance b ' +
      '      JOIN inv_card c ON c.id = b.cardkey ' +
      '    WHERE ' +
      '      b.balance <> 0 ' +
      '    GROUP BY ' +
      '      b.contactkey, ' +
      '      c.goodkey, ' +
      '      c.companykey, ' +
      '      c.usr$inv_addlinekey ' +
        IIF(cFieldList <> '', ', ' + cFieldList, '') +
      ' ' +
      '    UNION ALL ' +
      ' ' +
      '    SELECT ' +
      '      m.contactkey, ' +
      '      c.goodkey, ' +
      '      c.companykey, ' +
      '      c.usr$inv_addlinekey, ' +
      '      - SUM(m.debit - m.credit) AS balance ' +
        IIF(cFieldList <> '', ', ' + cFieldList, '') +
      '    FROM ' +
      '      inv_movement m ' +
      '      JOIN inv_card c on m.cardkey = c.id ' +
      '    WHERE ' +
      '      m.disabled = 0 ' +
      '      AND m.movementdate > :remainsdate ' +
      '    GROUP BY ' +
      '      m.contactkey, ' +
      '      c.goodkey, ' +
      '      c.companykey, ' +
      '      c.usr$inv_addlinekey ' +
        IIF(cFieldList <> '', ', ' + cFieldList, '') +
      '    ) bal ' +
      '    LEFT JOIN usr$inv_addwbillline inv_line ON inv_line.documentkey = bal.usr$inv_addlinekey ' +
      '    LEFT JOIN usr$inv_addwbill inv_doc ON inv_doc.documentkey = inv_line.masterkey ' +
      '  GROUP BY ' +
      '    bal.contactkey, ' +
      '    inv_doc.usr$contactkey, ' +
      '    bal.goodkey, ' +
      '    bal.companykey ' +
        IIF(balFieldList <> '', ', ' + balFieldList, '') +
      '  HAVING ' +
      '    SUM(bal.balance) >= 0 ' +
      '  ) move ' +
      '   LEFT JOIN gd_contact cont ON cont.id = move.contactkey ' +
      ' ORDER BY ' +
      '   cont.name, move.SupplierKey ';
    ibsql.ParamByName('REMAINSDATE').AsDateTime := FCloseDate;
    ibsql.ExecQuery;                                              // Выберем все остатки ТМЦ

    LineCount := 0;
    CurrentContactKey := -1;
    CurrentSupplierKey := -1;
    DocumentParentKey := -1;

    // Цикл по остаткам ТМЦ
    while not ibsql.Eof do
    begin
      // При нажатии Escape прервем процесс
      if ((GetAsyncKeyState(VK_ESCAPE) shr 1) <> 0) then
      begin
        if Application.MessageBox('Остановить закрытие периода?', 'Внимание',
           MB_YESNO or MB_ICONQUESTION or MB_SYSTEMMODAL) = IDYES then
          raise Exception.Create('Выполнение прервано');
      end;

      // Если по полю USR$INV_ADDLINEKEY карточки нашли поставщика, создадим приход остатка с него
      if not ibsql.FieldByName('SUPPLIERKEY').IsNull then
        NextSupplierKey := ibsql.FieldByName('SUPPLIERKEY').AsInteger
      else
        NextSupplierKey := PseudoClient;

      // Если в цикле набрели на другой контакт, или другого поставщика,
      //   или кол-во позиций в документе превысило 2000 (оперативка не резиновая),
      //   то создадим новую шапку документа
      if (ibsql.FieldByName('CONTACTKEY').AsInteger <> CurrentContactKey)
         or (NextSupplierKey <> CurrentSupplierKey)
         or ((LineCount mod 2000) = 0) then
      begin
        // Если перешли на другой контакт
        if ibsql.FieldByName('CONTACTKEY').AsInteger <> CurrentContactKey then
        begin
          // Визуализация процесса
          // Выведем конечное число позиций предыдущего контакта
          if CurrentContactKey > 0 then
            AddLogMessage('  ' + IntToStr(LineCount) + ' позиций');
          AddLogMessage(Format('> Контакт: %s', [ibsql.FieldByName('CONTACTNAME').AsString]));
          // Сбросим счетчик позиций
          LineCount := 0;
          // Запомним текущий контакт
          CurrentContactKey := ibsql.FieldByName('CONTACTKEY').AsInteger;
        end;
        // Запомним текущего поставщика
        CurrentSupplierKey := NextSupplierKey;
        // Вставим шапку документа и получим ее ID
        DocumentParentKey := AddDepotHeader(CurrentSupplierKey, CurrentContactKey, ibsql.FieldByName('COMPANYKEY').AsInteger);
      end;

      // Увеличим счетчик позиций в одном документе
      Inc(LineCount);

      // Создадим позицию INV_DOCUMENT
      AddDepotPosition(CurrentSupplierKey, CurrentContactKey, ibsql.FieldByName('COMPANYKEY').AsInteger,
        DocumentParentKey, ibsql.FieldByName('GOODKEY').AsInteger, ibsql.FieldByName('BALANCE').AsCurrency, ibsql);

      // TODO: при выборе признаков карточки которые будут подлежать сохранению, указывать поля которые ссылаются
      //   на документы подлежащие удалению, предупреждать пользователя что, при выборе таких полей может
      //   появится рассинхронизация в данных

      ibsql.Next;
    end;

    // Визуализация процесса
    SetupProgressBar(FProgressBar.Position, FProgressBar.Position);
    AddLogMessage(TimeToStr(Time) + ': Формирование остатков завершено...');
    AddLogMessage('Продолжительность процесса: ' + TimeToStr(Time - FLocalStartTime));
  finally
    ibsql.Free;
  end;
end;

procedure TgdClosingPeriod.DeleteDocuments;
const
  UPDATE_INV_CARD_SET_NULL = 'UPDATE inv_card SET %0:s = NULL WHERE %0:s = :dockey;';
var
  ibsqlDocument: TIBSQL;
  ibsqlDeleteMovement: TIBSQL;
  ibsqlDeleteAddRecord: TIBSQL;
  ibsqlDeleteDocument: TIBSQL;
  ibsqlDeleteEntry: TIBSQL;
  ibsqlUpdateInvCard: TIBSQL;
  ibsqlSavepointManager: TIBSQL;
  DeletedCount, ErrorDocumentCount: Integer;
  I, DocumentListIndex: Integer;
  GDDocumentReferenceFieldList: TStringList;
  SQLText: String;
  R: TatRelation;
  DocumentKeysToDelayedDelete: TgdKeyStringAssoc;
  CurrentRefreshInfoStep: Integer;

  procedure DeleteSingleDocument(const AID: TID; const AdditionalTableName: String; const ForceDelete: Boolean = false);
  begin
    // Удалим ссылки на удаляемый документ из полей-признаков складских карточек
    ibsqlUpdateInvCard.Close;
    ibsqlUpdateInvCard.ParamByName('DOCKEY').AsInteger := AID;
    ibsqlUpdateInvCard.ExecQuery;

    // Удалим позицию документа из дополнительной таблицы
    try
      ibsqlDeleteAddRecord.Close;
      ibsqlDeleteAddRecord.SQL.Text :=
        ' DELETE FROM ' + AdditionalTableName + ' WHERE documentkey = :dockey ';
      ibsqlDeleteAddRecord.ParamByName('DOCKEY').AsInteger := AID;
      ibsqlDeleteAddRecord.ExecQuery;
    except
      if ForceDelete then
      begin
        // Пробуем удалить ссылки на текущую запись
        TryToDeleteDocumentReferences(AID, AdditionalTableName);
        // Снова пробуем удалить запись
        ibsqlDeleteAddRecord.Close;
        ibsqlDeleteAddRecord.SQL.Text :=
          ' DELETE FROM ' + AdditionalTableName + ' WHERE documentkey = :dockey ';
        ibsqlDeleteAddRecord.ParamByName('DOCKEY').AsInteger := AID;
        ibsqlDeleteAddRecord.ExecQuery;
      end
      else
        raise;
    end;

    // Удалим проводки по этому документу
    ibsqlDeleteEntry.Close;
    ibsqlDeleteEntry.ParamByName('DOCKEY').AsInteger := AID;
    ibsqlDeleteEntry.ExecQuery;

    // Удалим складское движение по этому документу
    ibsqlDeleteMovement.Close;
    ibsqlDeleteMovement.ParamByName('DOCKEY').AsInteger := AID;
    ibsqlDeleteMovement.ExecQuery;

    // Удалим документ из GD_DOCUMENT
    try
      ibsqlDeleteDocument.Close;
      ibsqlDeleteDocument.ParamByName('DOCKEY').AsInteger := AID;
      ibsqlDeleteDocument.ExecQuery;
    except
      if ForceDelete then
      begin
        // Пробуем удалить ссылки на текущую запись
        TryToDeleteDocumentReferences(AID, 'GD_DOCUMENT');
        // Снова пробуем удалить запись
        ibsqlDeleteDocument.Close;
        ibsqlDeleteDocument.ParamByName('DOCKEY').AsInteger := AID;
        ibsqlDeleteDocument.ExecQuery;
      end
      else
        raise;  
    end;
  end;

begin
  FLocalStartTime := Time;

  // Визуализация процесса
  SetupProgressBar(0, 1000000);
  AddLogMessage(TimeToStr(FLocalStartTime) + ': Удаление документов...');

  ibsqlDocument := TIBSQL.Create(Application);
  ibsqlDeleteAddRecord := TIBSQL.Create(Application);
  ibsqlDeleteMovement := TIBSQL.Create(Application);
  ibsqlDeleteDocument := TIBSQL.Create(Application);
  ibsqlDeleteEntry := TIBSQL.Create(Application);
  ibsqlUpdateInvCard := TIBSQL.Create(Application);
  ibsqlSavepointManager := TIBSQL.Create(Application);

  // Список отложенного удаления документов
  DocumentKeysToDelayedDelete := TgdKeyStringAssoc.Create;
  try

    GDDocumentReferenceFieldList := TStringList.Create;
    try
      // Получим все ссылки из AC_ENTRY на GD_DOCUMENT
      R := atDatabase.Relations.ByRelationName('AC_ENTRY');
      for I := 0 to R.RelationFields.Count - 1 do
      begin
        if Assigned(R.RelationFields[I].ForeignKey) and Assigned(R.RelationFields[I].References) then
          if R.RelationFields[I].References.RelationName = 'GD_DOCUMENT' then
            GDDocumentReferenceFieldList.Add(R.RelationFields[I].FieldName);
      end;
      // Запрос на удаление проводки
      ibsqlDeleteEntry.Transaction := FWriteTransaction;
      SQLText := '';
      for I := 0 to GDDocumentReferenceFieldList.Count - 1 do
      begin
        if SQLText <> '' then
          SQLText := SQLText + ' OR ';
        SQLText := SQLText + ' ( ' + GDDocumentReferenceFieldList.Strings[I] + ' = :dockey ) ';
      end;
      ibsqlDeleteEntry.SQL.Text :=
        'DELETE FROM ac_entry WHERE ' + SQLText;
      ibsqlDeleteEntry.Prepare;

      // Получим все пользовательские ссылки из INV_CARD на GD_DOCUMENT
      GDDocumentReferenceFieldList.Clear;
      R := atDatabase.Relations.ByRelationName('INV_CARD');
      for I := 0 to R.RelationFields.Count - 1 do
      begin
        if Assigned(R.RelationFields[I].ForeignKey) and Assigned(R.RelationFields[I].References) then
          if (R.RelationFields[I].References.RelationName = 'GD_DOCUMENT')
             and (R.RelationFields[I].IsUserDefined) then
            GDDocumentReferenceFieldList.Add(R.RelationFields[I].FieldName);
      end;
      // Запрос на удаление ссылок на удаляемые документы из складских карточек
      ibsqlUpdateInvCard.Transaction := FWriteTransaction;
      SQLText := #13#10;
      for I := 0 to GDDocumentReferenceFieldList.Count - 1 do
        SQLText := SQLText + Format(UPDATE_INV_CARD_SET_NULL, [GDDocumentReferenceFieldList.Strings[I]]) + #13#10;
      ibsqlUpdateInvCard.SQL.Text :=
        'EXECUTE BLOCK (dockey INTEGER = :dockey) AS BEGIN ' + SQLText + ' END ';
      ibsqlUpdateInvCard.Prepare;
    finally
      GDDocumentReferenceFieldList.Free;
    end;

    // Вытянем список документов на читающей транзакции, удалять будем на переданной
    ibsqlDocument.Transaction := gdcBaseManager.ReadTransaction;
    ibsqlDeleteAddRecord.Transaction := FWriteTransaction;
    // Запрос на удаление складского движения, относящегося к определенному документу
    ibsqlDeleteMovement.Transaction := FWriteTransaction;
    ibsqlDeleteMovement.SQL.Text :=
      ' DELETE FROM inv_movement WHERE documentkey = :dockey ';
    ibsqlDeleteMovement.Prepare;
    // Запрос на удаление документа из gd_document
    ibsqlDeleteDocument.Transaction := FWriteTransaction;
    ibsqlDeleteDocument.SQL.Text :=
      ' DELETE FROM gd_document WHERE id = :dockey ';
    ibsqlDeleteDocument.Prepare;
    // создание\уничтожение savepoint
    ibsqlSavepointManager.Transaction := FWriteTransaction;

    // Запрос на получение складского движения, пытаемся упорядочить движение по времени создания,
    //   начиная с новейших записей
    ibsqlDocument.SQL.Text :=
      'SELECT ' +
      '  doc.id AS documentkey, ' +
      '  IIF(doc.parent IS NULL, headtable.relationname, linetable.relationname) AS addtablename ' +
      'FROM ' +
      '  gd_document doc ' +
      '  LEFT JOIN gd_documenttype t ON t.id = doc.documenttypekey ' +
      '  LEFT JOIN at_relations headtable ON headtable.id = t.headerrelkey ' +
      '  LEFT JOIN at_relations linetable ON linetable.id = t.linerelkey ' +
      'WHERE ' +
      '  doc.documentdate < :closedate ' +
      '  AND t.classname = ''TgdcInvDocumentType'' ' +
      '  AND t.documenttype = ''D'' ' +
      '  AND NOT headtable.id IS NULL ' +
      '  AND NOT linetable.id IS NULL ' +
      'ORDER BY ' +
      '  doc.documentdate DESC, doc.creationdate DESC ';
    ibsqlDocument.ParamByName('CLOSEDATE').AsDateTime := FCloseDate;
    ibsqlDocument.ExecQuery;

    DeletedCount := 0;
    ErrorDocumentCount := 0;
    CurrentRefreshInfoStep := 0;
    // Цикл по найденным документам, подлежащим удалению
    while not ibsqlDocument.Eof do
    begin
      // При нажатии Escape прервем процесс
      if ((GetAsyncKeyState(VK_ESCAPE) shr 1) <> 0) then
      begin
        if Application.MessageBox('Остановить закрытие периода?', 'Внимание',
           MB_YESNO or MB_ICONQUESTION or MB_SYSTEMMODAL) = IDYES then
        begin
          // Выведем список документов, которые не получилось удалить
          AddLogMessage('Не удаленные документы:');
          for I := 0 to DocumentKeysToDelayedDelete.Count - 1 do
            AddLogMessage(DocumentKeysToDelayedDelete.ValuesByIndex[I] +
              ' ( ' + IntToStr(DocumentKeysToDelayedDelete.Keys[I]) + ' )');

          raise Exception.Create('Выполнение прервано');
        end;
      end;

      // Удалим текущий документ и его проводки
      try
        // Пробуем удалить документ
        DeleteSingleDocument(ibsqlDocument.FieldByName('DOCUMENTKEY').AsInteger,
          ibsqlDocument.FieldByName('ADDTABLENAME').AsString);
        Inc(DeletedCount);

        // Каждые 100 документов будем запускать отложенное удаление
        if DeletedCount mod 100 = 0 then
          for I := 0 to DocumentKeysToDelayedDelete.Count - 1 do
          begin
            try
              // Пробуем удалить документ
              DeleteSingleDocument(DocumentKeysToDelayedDelete.Keys[I],
                DocumentKeysToDelayedDelete.ValuesByIndex[I]);
              // Удаляем документ из списка отложенных
              DocumentKeysToDelayedDelete.Delete(I);
              Inc(DeletedCount);
              Dec(ErrorDocumentCount);
            except
              // Если не получилось удалить, то ничего не делаем - пробуем удалить в следующий раз
            end;
          end;
      except
        // Обрабатываем ошибку удаления документа
        on E: Exception do
        begin
          // Занесем документ в список отложенного удаления
          DocumentListIndex := DocumentKeysToDelayedDelete.Add(ibsqlDocument.FieldByName('DOCUMENTKEY').AsInteger);
          DocumentKeysToDelayedDelete.ValuesByIndex[DocumentListIndex] := ibsqlDocument.FieldByName('ADDTABLENAME').AsString;

          Inc(ErrorDocumentCount);
          // Визуализация процесса
          {AddLogMessage(E.Message + #13#10 +
            ibsqlDocument.FieldByName('ADDTABLENAME').AsString +
            ' ( ' + ibsqlDocument.FieldByName('DOCUMENTKEY').AsString + ' )');}
        end;
      end;

      // Визуализация процесса
      if CurrentRefreshInfoStep >= REFRESH_CLOSING_INFO_INTERVAL then
      begin
        StepProgressBar(CurrentRefreshInfoStep);
        CurrentRefreshInfoStep := 0;
      end
      else
        Inc(CurrentRefreshInfoStep);

      // Перейдем к следующему документу
      ibsqlDocument.Next;
    end;

    // Визуализация процесса
    SetupProgressBar(FProgressBar.Position, FProgressBar.Position);

    // Последний раз пробуем удалить отложенные документы
    for I := 0 to DocumentKeysToDelayedDelete.Count - 1 do
    begin
      try
        // Пробуем удалить документ
        DeleteSingleDocument(DocumentKeysToDelayedDelete.Keys[I],
          DocumentKeysToDelayedDelete.ValuesByIndex[I]);
        // Удаляем документ из списка отложенных
        DocumentKeysToDelayedDelete.Delete(I);
        Inc(DeletedCount);
        Dec(ErrorDocumentCount);
      except
        {on E: Exception do
        begin
          AddLogMessage(E.Message + #13#10 +
            DocumentKeysToDelayedDelete.ValuesByIndex[I] +
            ' ( ' + IntToStr(DocumentKeysToDelayedDelete.Keys[I]) + ' )');
        end;}
      end;
    end;

    // Выведем список документов, которые не получилось удалить
    AddLogMessage('Не удаленные документы:');
    for I := 0 to DocumentKeysToDelayedDelete.Count - 1 do
      AddLogMessage(DocumentKeysToDelayedDelete.ValuesByIndex[I] +
        ' ( ' + IntToStr(DocumentKeysToDelayedDelete.Keys[I]) + ' )');
    AddLogMessage(TimeToStr(Time) + ': Завершен процесс удаления документов...');
    AddLogMessage(IntToStr(DeletedCount) + ' удалено, ' + IntToStr(ErrorDocumentCount) + ' ошибок');
    AddLogMessage('Продолжительность процесса: ' + TimeToStr(Time - FLocalStartTime));
  finally
    DocumentKeysToDelayedDelete.Free;

    ibsqlUpdateInvCard.Free;
    ibsqlDeleteEntry.Free;
    ibsqlDeleteAddRecord.Free;
    ibsqlDeleteDocument.Free;
    ibsqlDeleteMovement.Free;
    ibsqlDocument.Free;
  end;
end;

procedure TgdClosingPeriod.DeleteEntry;
var
  ibsql: TIBSQL;
begin
  FLocalStartTime := Time;

  // Визуализация процесса
  SetupProgressBar(0, 1);
  AddLogMessage(TimeToStr(FLocalStartTime) + ': Удаление проводок...');

  ibsql := TIBSQL.Create(Application);
  try
    ibsql.Transaction := FWriteTransaction;
    ibsql.SQL.Text := 'DELETE FROM ac_entry WHERE entrydate < :closedate ';
    ibsql.ParamByName('CLOSEDATE').AsDateTime := FCloseDate;
    ibsql.ExecQuery;
  finally
    ibsql.Free;
  end;

  // Визуализация процесса
  SetupProgressBar(1, 1);
  AddLogMessage(TimeToStr(Time) + ': Удаление проводок завершено');
  AddLogMessage('Продолжительность процесса: ' + TimeToStr(Time - FLocalStartTime));
end;

procedure TgdClosingPeriod.DeleteUserDocuments;
var
  ibsqlSelectDocument: TIBSQL;
  ibsqlDeleteDocument, ibsqlDeleteUserRecord: TIBSQL;
  DocumentTypeCounter: Integer;
  DocumentTypeListStr: String;
  CurrentRelationName, NextRelationName: String;
  CurrentDocumentKey: Integer;
begin
  FLocalStartTime := Time;

  // Визуализация процесса
  SetupProgressBar(0, 1);
  AddLogMessage(TimeToStr(FLocalStartTime) + ': Удаление пользовательских документов...');

  // Если выбран хотя бы один тип пользовательских документов
  if FUserDocumentTypesToDelete.Count > 0 then
  begin
    // Сформируем строку с ID типов пользовательских документов
    for DocumentTypeCounter := 0 to FUserDocumentTypesToDelete.Count - 1 do
    begin
      if DocumentTypeListStr <> '' then
        DocumentTypeListStr := DocumentTypeListStr + ', ';
      DocumentTypeListStr := DocumentTypeListStr + IntToStr(FUserDocumentTypesToDelete.Keys[DocumentTypeCounter]);
    end;

    ibsqlSelectDocument := TIBSQL.Create(Application);
    ibsqlDeleteDocument := TIBSQL.Create(Application);
    ibsqlDeleteUserRecord := TIBSQL.Create(Application);
    try
      // Запрос для удаления записи из gd_document по переданному ID
      ibsqlDeleteDocument.Transaction := FWriteTransaction;
      ibsqlDeleteDocument.SQL.Text := 'DELETE FROM gd_document WHERE id = :documentkey';
      ibsqlDeleteDocument.Prepare;

      ibsqlDeleteUserRecord.Transaction := FWriteTransaction;

      // Запрос выбирает пользовательские документы переданных типов, которые созданы до даты закрытия
      //   сортирует их в порядке убывания по дате, потом по ID
      ibsqlSelectDocument.Transaction := FWriteTransaction;
      ibsqlSelectDocument.SQL.Text := Format(
        'SELECT ' +
        '  d.id AS documentkey, ' +
        '  IIF(d.parent IS NULL, h_rel.relationname, l_rel.relationname) AS add_rel_name ' +
        'FROM ' +
        '  gd_document d ' +
        '  LEFT JOIN gd_documenttype t ON t.id = d.documenttypekey ' +
        '  LEFT JOIN at_relations h_rel ON h_rel.id = t.headerrelkey ' +
        '  LEFT JOIN at_relations l_rel ON l_rel.id = t.linerelkey ' +
        'WHERE ' +
        '  d.documentdate < :closedate ' +
        '  AND d.documenttypekey IN (%0:s) ' +
        '  AND NOT t.headerrelkey IS NULL ' +
        'ORDER BY ' +
        '  d.documentdate DESC, d.id DESC', [DocumentTypeListStr]);
      ibsqlSelectDocument.ParamByName('CLOSEDATE').AsDateTime := FCloseDate;
      ibsqlSelectDocument.ExecQuery;

      CurrentRelationName := '';
      while not ibsqlSelectDocument.Eof do
      begin
        CurrentDocumentKey := ibsqlSelectDocument.FieldByName('DOCUMENTKEY').AsInteger;
        NextRelationName := ibsqlSelectDocument.FieldByName('ADD_REL_NAME').AsString;
        if CurrentRelationName <> NextRelationName then
        begin
          CurrentRelationName := NextRelationName;
          ibsqlDeleteUserRecord.Close;
          ibsqlDeleteUserRecord.SQL.Text :=
            Format('DELETE FROM %0:s WHERE documentkey = :documentkey', [CurrentRelationName]);
          ibsqlDeleteUserRecord.Prepare;
        end;

        // Удалим запись из пользовательской таблицы
        try
          ibsqlDeleteUserRecord.Close;
          ibsqlDeleteUserRecord.ParamByName('DOCUMENTKEY').AsInteger := CurrentDocumentKey;
          ibsqlDeleteUserRecord.ExecQuery;
        except
          // Пробуем удалить ссылки на текущую запись
          TryToDeleteDocumentReferences(CurrentDocumentKey, CurrentRelationName);
        end;
        // Удалим запись из gd_document
        try
          ibsqlDeleteDocument.Close;
          ibsqlDeleteDocument.ParamByName('DOCUMENTKEY').AsInteger := CurrentDocumentKey;
          ibsqlDeleteDocument.ExecQuery;
        except
          // Пробуем удалить ссылки на текущую запись
          TryToDeleteDocumentReferences(CurrentDocumentKey, 'GD_DOCUMENT');
        end;

        ibsqlSelectDocument.Next;
      end;
    finally
      ibsqlDeleteUserRecord.Free;
      ibsqlDeleteDocument.Free;
      ibsqlSelectDocument.Free;
    end;
  end;

  // Визуализация процесса
  SetupProgressBar(1, 1);
  AddLogMessage(TimeToStr(Time) + ': Завершен процесс удаления пользовательских документов...');
  AddLogMessage('Продолжительность процесса: ' + TimeToStr(Time - FLocalStartTime));
end;

procedure TgdClosingPeriod.DoClosePeriod;
begin

end;

{procedure TgdClosingPeriod.InsertDatabaseRecord;
var
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := FWriteTransaction;
    ibsql.SQL.Text :=
      'INSERT INTO db_closehistory (databasepath, server, username, userpassword, closedate) ' +
      'VALUES (:path, :server, :username, :userpassword, :closedate) ';
    ibsql.ParamByName('PATH').AsString := FExtDatabasePath;
    ibsql.ParamByName('SERVER').AsString := FExtDatabaseServer;
    ibsql.ParamByName('USERNAME').AsString := FExtDatabaseUser;
    ibsql.ParamByName('USERPASSWORD').AsString := FExtDatabasePassword;
    ibsql.ParamByName('CLOSEDATE').AsDateTime := FCloseDate;
    ibsql.ExecQuery;
  finally
    ibsql.Free;
  end;
end;}

procedure TgdClosingPeriod.ReBindDepotCards;
const
  UpdateDocumentCardkeyTemplate =
    'UPDATE ' +
    '  %0:s line ' +
    'SET ' +
    '  line.%1:s = :new_cardkey ' +
    'WHERE ' +
    '  line.%1:s = :old_cardkey ' +
    '  AND (SELECT doc.documentdate FROM gd_document doc WHERE doc.id = line.documentkey) >= :closedate ';
  SearchNewCardkeyTemplate =
    'SELECT FIRST(1) ' +
    '  card.id AS cardkey ' +
    'FROM ' +
    '  usr$inv_document head ' +
    '  LEFT JOIN gd_document doc ON doc.id = head.documentkey ' +
    '  LEFT JOIN usr$inv_documentline line ON line.masterkey = head.documentkey ' +
    '  LEFT JOIN inv_card card ON card.id = line.fromcardkey ' +
    'WHERE ' +
    '  doc.documentdate = :closedate ' +
    '  AND card.goodkey = :goodkey ' +
    '  AND ' +
    '    ((head.usr$in_contactkey = :contact_01) ' +
    '    OR (head.usr$in_contactkey = :contact_02)) ';
  SearchNewCardkeySimpleTemplate =
    'SELECT FIRST(1) ' +
    '  card.id AS cardkey ' +
    'FROM ' +
    '  usr$inv_documentline line ' +
    '  JOIN gd_document doc ON doc.id = line.documentkey ' +
    '  JOIN inv_card card ON card.id = line.fromcardkey ' +
    'WHERE ' +
    '  doc.documentdate = :closedate ' +
    '  AND doc.documenttypekey = :doctypekey ' + 
    '  AND card.goodkey = :goodkey ';
  CardkeyFieldCount = 2;
  CardkeyFieldNames: array[0..CardkeyFieldCount - 1] of String = ('FROMCARDKEY', 'TOCARDKEY');
var
  ibsql: TIBSQL;
  ibsqlSearchNewCardkey: TIBSQL;
  ibsqlUpdateCard: TIBSQL;
  ibsqlUpdateInvMovement: TIBSQL;
  ibsqlUpdateDocumentCardkey: TIBSQL;
  CurrentCardKey, CurrentFromContactkey, CurrentToContactkey: Integer;
  CurrentRelationName: String;
  DocumentParentKey: TID;
  NewCardKey: Integer;
  FeatureCounter: Integer;
  cFeatureList: String;

  procedure UpdateInvCard(const OldCardkey, NewCardkey: TID);
  begin
    // обновим ссылку на родительскую карточку
    ibsqlUpdateCard.Close;
    ibsqlUpdateCard.ParamByName('OLD_PARENT').AsInteger := OldCardkey;
    ibsqlUpdateCard.ParamByName('NEW_PARENT').AsInteger := NewCardkey;
    ibsqlUpdateCard.ExecQuery;
  end;

  procedure UpdateInvMovement(const OldCardkey, NewCardkey: TID);
  begin
    // обновим ссылки на карточки из движения
    ibsqlUpdateInvMovement.Close;
    ibsqlUpdateInvMovement.ParamByName('OLD_CARDKEY').AsInteger := OldCardkey;
    ibsqlUpdateInvMovement.ParamByName('NEW_CARDKEY').AsInteger := NewCardkey;
    ibsqlUpdateInvMovement.ExecQuery;
  end;

  procedure UpdateDocumentCardkey(const RelationName: String; const OldCardkey, NewCardkey: TID);
  var
    I: Integer;
  begin
    for I := 0 to CardkeyFieldCount - 1 do
    begin
      try
        ibsqlUpdateDocumentCardkey.Close;
        ibsqlUpdateDocumentCardkey.SQL.Text := Format(UpdateDocumentCardkeyTemplate, [RelationName, CardkeyFieldNames[I]]);
        ibsqlUpdateDocumentCardkey.ParamByName('OLD_CARDKEY').AsInteger := OldCardkey;
        ibsqlUpdateDocumentCardkey.ParamByName('NEW_CARDKEY').AsInteger := NewCardkey;
        ibsqlUpdateDocumentCardkey.ParamByName('CLOSEDATE').AsDateTime := FCloseDate;
        ibsqlUpdateDocumentCardkey.ExecQuery;
      except
        // в некоторых документах нет поля TOCARDKEY
        {on E: Exception do
        begin
          AddLogMessage('---'#13#10 + RelationName + #13#10 + E.Message + #13#10'---');
        end}
      end;
    end;
  end;

begin
  InitializeIBSQLQueries;
  
  FLocalStartTime := Time;

  // Визуализация процесса
  SetupProgressBar(0, 35000);
  AddLogMessage(TimeToStr(FLocalStartTime) + ': Перепривязка складских карточек...');

  ibsql := TIBSQL.Create(Application);
  ibsqlSearchNewCardkey := TIBSQL.Create(Application);
  ibsqlUpdateCard := TIBSQL.Create(Application);
  ibsqlUpdateInvMovement := TIBSQL.Create(Application);
  ibsqlUpdateDocumentCardkey := TIBSQL.Create(Application);
  try
    // обновляет ссылку на родительскую карточку
    ibsqlUpdateCard.Transaction := FWriteTransaction;
    ibsqlUpdateCard.SQL.Text :=
      'UPDATE ' +
      '  inv_card c ' +
      'SET ' +
      '  c.parent = :new_parent ' +
      'WHERE ' +
      '  c.parent = :old_parent ' +
      '  AND (SELECT FIRST(1) m.movementdate ' +
      '       FROM inv_movement m ' +
      '       WHERE m.cardkey = c.id ' +
      '       ORDER BY m.movementdate DESC) >= :closedate ';
    ibsqlUpdateCard.ParamByName('CLOSEDATE').AsDateTime := FCloseDate;
    ibsqlUpdateCard.Prepare;
    // обновляет в движении ссылки на складские карточки
    ibsqlUpdateInvMovement.Transaction := FWriteTransaction;
    ibsqlUpdateInvMovement.SQL.Text :=
      'UPDATE ' +
      '  inv_movement m ' +
      'SET ' +
      '  m.cardkey = :new_cardkey ' +
      'WHERE ' +
      '  m.cardkey = :old_cardkey ' +
      '  AND m.movementdate >= :closedate ';
    ibsqlUpdateInvMovement.ParamByName('CLOSEDATE').AsDateTime := FCloseDate;
    ibsqlUpdateInvMovement.Prepare;
    // обновляет в дополнительнных таблицах складских документов ссылки на складские карточки
    ibsqlUpdateDocumentCardkey.Transaction := FWriteTransaction;

    // находит подходящую карточку в документе остатков
    ibsqlSearchNewCardkey.Transaction := FWriteTransaction;

    // Получим список выбранных признаков складской карточки
    cFeatureList := GetFeatureFieldList('c.');
    // выбирает все карточки которые находятся в движении во время закрытия
    ibsql.Transaction := gdcBaseManager.ReadTransaction;
    {ibsql.SQL.Text :=
      'SELECT ' + 
      '  CAST(0 AS INTEGER), ' +
      '  mfrom.contactkey AS fromcontactkey, ' +
      '  mto.contactkey AS tocontactkey, ' +
      '  linerel.relationname, ' +
      '  c.goodkey, ' +
      '  c.id AS cardkey, ' +
      '  c.companykey ' +
        IIF(cFeatureList <> '', ', ' + cFeatureList + ' ', '') +
      'FROM ' +
      '  inv_card c ' +
      '  LEFT JOIN inv_movement mfrom ON mfrom.cardkey = c.id ' +
      '  LEFT JOIN inv_movement mto ON mto.cardkey = c.id ' +
      '  LEFT JOIN gd_document doc ON doc.id = mto.documentkey ' +
      '  LEFT JOIN gd_documenttype t ON t.id = doc.documenttypekey ' +
      '  LEFT JOIN at_relations linerel ON linerel.id = t.linerelkey ' +
      'WHERE ' +
      '  mfrom.movementdate < :closedate AND mto.movementdate >= :closedate ' +
      ' ' +
      'UNION ALL ' +
      ' ' +
      'SELECT ' +
      '  CAST(1 AS INTEGER), ' +
      '  CAST(-1 AS INTEGER), ' +
      '  CAST(-1 AS INTEGER), ' +
      '  linerel.relationname, ' +
      '  c.goodkey, ' +
      '  c.id AS cardkey, ' +
      '  c.companykey ' +
        IIF(cFeatureList <> '', ', ' + cFeatureList + ' ', '') +
      'FROM ' +
      '  inv_card c ' +
      '  LEFT JOIN inv_card c_child ON c_child.parent = c.id ' +
      '  LEFT JOIN gd_document d_parent ON d_parent.id = c.documentkey ' +
      '  LEFT JOIN gd_document d_child ON d_child.id = c_child.documentkey ' +
      '  LEFT JOIN gd_documenttype t ON t.id = d_child.documenttypekey ' +
      '  LEFT JOIN at_relations linerel ON linerel.id = t.linerelkey ' +
      'WHERE ' +
      '  d_parent.documentdate < :closedate AND d_child.documentdate >= :closedate ' +
      'ORDER BY ' +
      '  1, 6 ';}
    ibsql.SQL.Text :=
      'SELECT' + #13#10 +
      '  m1.contactkey as fromcontactkey,' + #13#10 +
      '  m.contactkey as tocontactkey,' + #13#10 +
      '  linerel.relationname,' + #13#10 +
      '  c1.id as cardkey,' + #13#10 +
      '  c1.goodkey,' + #13#10 +
      '  c1.companykey' + #13#10 +
        IIF(cFeatureList <> '', ', ' + cFeatureList + #13#10, '') +
      'FROM' + #13#10 +
      '  gd_document d' + #13#10 +
      '  JOIN gd_documenttype t ON t.id = d.documenttypekey' + #13#10 +
      '  LEFT JOIN inv_movement m ON m.documentkey = d.id' + #13#10 +
      '  LEFT JOIN inv_movement m1 ON m1.movementkey = m.movementkey AND m1.id <> m.id' + #13#10 +
      '  LEFT JOIN inv_card c ON c.id = m.cardkey' + #13#10 +
      '  LEFT JOIN inv_card c1 ON c1.id = m1.cardkey' + #13#10 +
      '  LEFT JOIN gd_document d_old ON (/*(d_old.id = c.documentkey) or */(d_old.id = c1.documentkey))' + #13#10 +
      '  LEFT JOIN at_relations linerel ON linerel.id = t.linerelkey' + #13#10 +
      'WHERE' + #13#10 +
      '  d.documentdate >= :closedate' + #13#10 +
      '  AND t.classname = ''TgdcInvDocumentType''' + #13#10 +
      '  AND t.documenttype = ''D''' + #13#10 +
      '  AND d_old.documentdate < :closedate';
    ibsql.ParamByName('CLOSEDATE').AsDateTime := FCloseDate;
    ibsql.ExecQuery;

    while not ibsql.Eof do
    begin
      // При нажатии Escape прервем процесс
      if ((GetAsyncKeyState(VK_ESCAPE) shr 1) <> 0) then
      begin
        if Application.MessageBox('Остановить закрытие периода?', 'Внимание',
           MB_YESNO or MB_ICONQUESTION or MB_SYSTEMMODAL) = IDYES then
          raise Exception.Create('Выполнение прервано');
      end;
      
      // Визуализация процесса
      StepProgressBar(1);  

      CurrentCardKey := ibsql.FieldByName('CARDKEY').AsInteger;
      CurrentFromContactkey := ibsql.FieldByName('FROMCONTACTKEY').AsInteger;
      CurrentToContactkey := ibsql.FieldByName('TOCONTACTKEY').AsInteger;
      CurrentRelationName := ibsql.FieldByName('RELATIONNAME').AsString;

      if (CurrentFromContactkey > 0) or (CurrentToContactkey > 0) then
      begin
        // Поищем подходящую карточку для замены удаляемой
        ibsqlSearchNewCardkey.Close;
        ibsqlSearchNewCardkey.SQL.Text := SearchNewCardkeyTemplate;
        for FeatureCounter := 0 to FFeatureList.Count - 1 do
        begin
          if not ibsql.FieldByName(FFeatureList.Strings[FeatureCounter]).IsNull then
            ibsqlSearchNewCardkey.SQL.Text := ibsqlSearchNewCardkey.SQL.Text +
              Format(' AND card.%0:s = :%0:s ', [FFeatureList.Strings[FeatureCounter]])
          else
            ibsqlSearchNewCardkey.SQL.Text := ibsqlSearchNewCardkey.SQL.Text +
              Format(' AND card.%0:s IS NULL ', [FFeatureList.Strings[FeatureCounter]]);
        end;
        ibsqlSearchNewCardkey.ParamByName('CLOSEDATE').AsDateTime := FCloseDate;
        ibsqlSearchNewCardkey.ParamByName('GOODKEY').AsInteger := ibsql.FieldByName('GOODKEY').AsInteger;
        ibsqlSearchNewCardkey.ParamByName('CONTACT_01').AsInteger := CurrentFromContactkey;
        ibsqlSearchNewCardkey.ParamByName('CONTACT_02').AsInteger := CurrentToContactkey;
        for FeatureCounter := 0 to FFeatureList.Count - 1 do
        begin
          if not ibsql.FieldByName(FFeatureList.Strings[FeatureCounter]).IsNull then
            ibsqlSearchNewCardkey.ParamByName(FFeatureList.Strings[FeatureCounter]).AsVariant :=
              ibsql.FieldByName(FFeatureList.Strings[FeatureCounter]).AsVariant;
        end;
        ibsqlSearchNewCardkey.ExecQuery;

        // Если мы нашли подходящую карточку, созданную документом остатков INV_DOCUMENT
        if ibsqlSearchNewCardkey.RecordCount > 0 then
        begin
          NewCardKey := ibsqlSearchNewCardkey.FieldByName('CARDKEY').AsInteger;
        end
        else
        begin
          // Иначе вставим документ нулевого прихода, и перепривяжем на созданную им карточку
          DocumentParentKey := AddDepotHeader(CurrentFromContactkey, CurrentFromContactkey, ibsql.FieldByName('COMPANYKEY').AsInteger);
          NewCardKey := AddDepotPosition(CurrentFromContactkey, CurrentFromContactkey, ibsql.FieldByName('COMPANYKEY').AsInteger,
            DocumentParentKey, ibsql.FieldByName('GOODKEY').AsInteger, 0);

          AddLogMessage(Format('  Создан документ нулевого прихода ID = %0:d', [DocumentParentKey]));
        end;
      end
      else
      begin
        // Поищем подходящую карточку для замены удаляемой
        ibsqlSearchNewCardkey.Close;
        ibsqlSearchNewCardkey.SQL.Text := SearchNewCardkeySimpleTemplate;
        for FeatureCounter := 0 to FFeatureList.Count - 1 do
        begin
          if not ibsql.FieldByName(FFeatureList.Strings[FeatureCounter]).IsNull then
            ibsqlSearchNewCardkey.SQL.Text := ibsqlSearchNewCardkey.SQL.Text +
              Format(' AND card.%0:s = :%0:s ', [FFeatureList.Strings[FeatureCounter]])
          else
            ibsqlSearchNewCardkey.SQL.Text := ibsqlSearchNewCardkey.SQL.Text +
              Format(' AND card.%0:s IS NULL ', [FFeatureList.Strings[FeatureCounter]]);
        end;
        ibsqlSearchNewCardkey.ParamByName('CLOSEDATE').AsDateTime := FCloseDate;
        ibsqlSearchNewCardkey.ParamByName('DOCTYPEKEY').AsInteger := FInvDocumentTypeKey;
        ibsqlSearchNewCardkey.ParamByName('GOODKEY').AsInteger := ibsql.FieldByName('GOODKEY').AsInteger;
        for FeatureCounter := 0 to FFeatureList.Count - 1 do
        begin
          if not ibsql.FieldByName(FFeatureList.Strings[FeatureCounter]).IsNull then
            ibsqlSearchNewCardkey.ParamByName(FFeatureList.Strings[FeatureCounter]).AsVariant :=
              ibsql.FieldByName(FFeatureList.Strings[FeatureCounter]).AsVariant;
        end;
        ibsqlSearchNewCardkey.ExecQuery;

        if ibsqlSearchNewCardkey.RecordCount > 0 then
          NewCardKey := ibsqlSearchNewCardkey.FieldByName('CARDKEY').AsInteger
        else
          NewCardKey := -1;
      end;

      if NewCardKey > 0 then
      begin
        UpdateInvCard(CurrentCardKey, NewCardKey);                                // обновим ссылку на родительскую карточку
        UpdateInvMovement(CurrentCardKey, NewCardKey);                            // обновим ссылки на карточки из движения
        UpdateDocumentCardkey(CurrentRelationName, CurrentCardKey, NewCardKey);   // обновим ссылки на карточки в складских документах
      end
      else
      begin
        AddLogMessage(Format('  Ошибка перепривязки карточки OLD_CARDKEY = %0:d', [CurrentCardKey]));
      end;

      ibsql.Next;
    end;

    // Визуализация процесса
    SetupProgressBar(FProgressBar.Position, FProgressBar.Position);
    AddLogMessage(TimeToStr(Time) + ': Завершен процесс перепривязки складских карточек...');
    AddLogMessage('Продолжительность процесса: ' + TimeToStr(Time - FLocalStartTime));
  finally
    ibsqlUpdateDocumentCardkey.Free;
    ibsqlUpdateInvMovement.Free;
    ibsqlUpdateCard.Free;
    ibsqlSearchNewCardkey.Free;
    ibsql.Free;
  end;
end;

procedure TgdClosingPeriod.SetTriggerActive(SetActive: Boolean);
const
  AlterTriggerCount = 3;
  AlterTriggerArray: array[0 .. AlterTriggerCount - 1] of String =
    ('INV_BD_MOVEMENT', 'INV_BU_MOVEMENT', 'AC_ENTRY_DO_BALANCE');
var
  ibsql: TIBSQL;
  WasActive: Boolean;
  StateStr: String;
  I: Integer;
begin
  WasActive := FWriteTransaction.Active;
  if not WasActive then
    FWriteTransaction.StartTransaction;

  if SetActive then
    StateStr := 'ACTIVE'
  else
    StateStr := 'INACTIVE';

  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := FWriteTransaction;

    for I := 0 to AlterTriggerCount - 1 do
    begin
      ibsql.SQL.Text := 'ALTER TRIGGER ' + AlterTriggerArray[I] + ' '  + StateStr;
      ibsql.ExecQuery;
      ibsql.Close;
    end;
  finally
    ibsql.Free;
  end;

  FWriteTransaction.Commit;
  if WasActive then
    FWriteTransaction.StartTransaction;
end;

procedure TgdClosingPeriod.TryToDeleteDocumentReferences(AID: TID; AdditionalRelationName: String);
var
  TableReferenceIndex: Integer;
  OL: TObjectList;
  ibsql, ibsqlUpdate, ibsqlSelect: TIBSQL;
  ReferencesRelationName, ReferencesFieldName: String;
  AdditionalFieldName: String;
  ForeignKeyCounter: Integer;
begin
  // Заполним для переданной таблицы список внешних ключей, если его еще нет
  if not FTableReferenceForeignKeysList.Find(AdditionalRelationName, TableReferenceIndex) then
  begin
    // Создадим новый список внешних ключей ссылающихся на переданную таблицу
    TableReferenceIndex := FTableReferenceForeignKeysList.AddObject(AdditionalRelationName, TObjectList.Create(False));
    OL := TObjectList.Create(False);
    try
      // Получим список внешних ключей ссылающихся на переданную таблицу
      atDatabase.ForeignKeys.ConstraintsByReferencedRelation(AdditionalRelationName, OL);
      // Возьмем только простые внешние ключи
      for ForeignKeyCounter := 0 to OL.Count - 1 do
      begin
        if TatForeignKey(OL.Items[ForeignKeyCounter]).IsSimpleKey
           and TatForeignKey(OL.Items[ForeignKeyCounter]).ConstraintField.IsUserDefined then
          TObjectList(FTableReferenceForeignKeysList.Objects[TableReferenceIndex]).Add(OL.Items[ForeignKeyCounter]);
      end;
    except
      OL.Free;
    end;
  end;

  // Пройдем по списку внешних ключей, и поищем записи ссылающиеся на переданную
  OL := TObjectList(FTableReferenceForeignKeysList.Objects[TableReferenceIndex]);
  ibsql := TIBSQL.Create(nil);
  ibsqlUpdate := TIBSQL.Create(nil);
  ibsqlSelect := TIBSQL.Create(nil);
  try
    ibsql.Transaction := FWriteTransaction;
    ibsqlUpdate.Transaction := FWriteTransaction;
    ibsqlSelect.Transaction := FWriteTransaction;
    // Цикл по внешним ключам
    for ForeignKeyCounter := 0 to OL.Count - 1 do
    begin
      // Имя таблицы которая содержит ссылку на переданную запись
      ReferencesRelationName := TatForeignKey(OL[ForeignKeyCounter]).Relation.RelationName;
      // Имя поля-ссылки на переданную запись
      ReferencesFieldName := TatForeignKey(OL.Items[ForeignKeyCounter]).ConstraintField.FieldName;
      // Имя поля из таблицы AdditionalRelationName на которое ссылается ReferencesFieldName
      AdditionalFieldName := TatForeignKey(OL.Items[ForeignKeyCounter]).ReferencesField.FieldName;
      // Найдем записи ссылающиеся на переданную запись в таблице по текущему внешнему ключу
      ibsql.Close;
      ibsql.SQL.Text := Format('SELECT * FROM %0:s WHERE %1:s = :aid', [ReferencesRelationName, ReferencesFieldName]);
      ibsql.ParamByName('AID').AsInteger := AID;
      ibsql.ExecQuery;
      // Если нашли запись
      if ibsql.RecordCount > 0 then
      begin
        // Если поле-ссылку можно обнулить, сделаем это.
        // TODO: Иначе поставим ссылку на любую другую подходящую запись ???
        if TatForeignKey(OL.Items[ForeignKeyCounter]).ConstraintField.IsNullable then
        begin
          ibsqlUpdate.Close;
          ibsqlUpdate.SQL.Text := Format('UPDATE %0:s SET %1:s = NULL WHERE %1:s = :aid', [ReferencesRelationName, ReferencesFieldName]);
          ibsqlUpdate.ParamByName('AID').AsInteger := AID;
          ibsqlUpdate.ExecQuery;
        end
        else
        begin
          ////
          AddLogMessage(Format('NOT NULL: %1:s(%2:s) -> %0:s', [AdditionalRelationName, ReferencesRelationName, ReferencesFieldName]));
          ////
          {ibsqlSelect.Close;
          ibsqlSelect.SQL.Text := Format('SELECT FIRST(1) %1:s FROM %0:s WHERE %1:s = :aid', [AdditionalRelationName, AdditionalFieldName]);
          ibsqlSelect.ExecQuery;

          if ibsqlSelect.RecordCount > 0 then
          begin

          end;}
        end;
      end;
    end;
  finally
    ibsqlSelect.Free;
    ibsqlUpdate.Free; 
    ibsql.Free;
  end;
end;

function TgdClosingPeriod.GetFeatureFieldList(AAlias: String): String;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to FFeatureList.Count - 1 do
  begin
    if Result <> '' then
      Result := Result + ', ';
    Result := Result + AAlias + FFeatureList.Strings[i];
  end;
end;

function TgdClosingPeriod.IIF(const Condition: Boolean; const TrueString, FalseString: String): String;
begin
  if Condition then
    Result := TrueString
  else
    Result := FalseString;
end;

procedure TgdClosingPeriod.CalculateEntryBalance;
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
  AnalyticCounter: Integer;
  Analytics: String;
  BalanceAnalytics, InsertAnalytics: String;
begin
  FLocalStartTime := Time;

  // Визуализация процесса
  AddLogMessage(TimeToStr(FLocalStartTime) + ': Вычисление бухгалтерских остатков...');

  // Занесем названия всех полей-аналитик в строку
  Analytics := '';
  for AnalyticCounter := 0 to FEntryAvailableAnalytics.Count - 1 do
  begin
    if Analytics <> '' then
      Analytics := Analytics + ',';
    Analytics := Analytics + ' ac.' + FEntryAvailableAnalytics.Strings[AnalyticCounter];
  end;

  ibsql := TIBSQL.Create(nil);
  ibsqlAccount := TIBSQL.Create(nil);
  try
    ibsql.Transaction := FWriteTransaction;
    ibsqlAccount.Transaction := gdcBaseManager.ReadTransaction;

    // Получим кол-во счетов
    ibsqlAccount.SQL.Text := 'SELECT COUNT(ag.id) as AccCount FROM ac_account ag';
    ibsqlAccount.ExecQuery;

    // Визуализация процесса
    SetupProgressBar(0, ibsqlAccount.FieldByName('AccCount').AsInteger);
    AddLogMessage('Удаление устаревших данных...');

    // Удалим старые данные сальдо
    ibsql.SQL.Text := 'DELETE FROM ac_entry_balance';
    ibsql.ExecQuery;

    AddLogMessage('Вычисление бухгалтерских остатков...');

    // Вытянем все счета
    ibsqlAccount.Close;
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
      if {Self.Active and }((GetAsyncKeyState(VK_ESCAPE) shr 1) <> 0) then
      begin
        if Application.MessageBox('Остановить закрытие периода?', 'Внимание',
           MB_YESNO or MB_ICONQUESTION or MB_SYSTEMMODAL) = IDYES then
          raise Exception.Create('Выполнение прервано');
      end;

      // Визуализация процесса
      StepProgressBar;

      // возьмем выбранные аналитики по расчитываемому счету
      BalanceAnalytics := '';
      InsertAnalytics := '';
      for AnalyticCounter := 0 to FEntryAvailableAnalytics.Count - 1 do
      begin
        if ibsqlAccount.FieldByName(FEntryAvailableAnalytics.Strings[AnalyticCounter]).AsInteger = 1 then
        begin
          BalanceAnalytics := BalanceAnalytics + ', ' + FEntryAvailableAnalytics.Strings[AnalyticCounter];
          InsertAnalytics := InsertAnalytics + ', :' + FEntryAvailableAnalytics.Strings[AnalyticCounter];
        end;
      end;

      // Сформируем запрос на запись
      ibsql.Close;
      ibsql.SQL.Text := ibWriteBegin + BalanceAnalytics + ') ' + ibMainBegin +
        BalanceAnalytics + ibMainMiddle + BalanceAnalytics + ibMainEnd;
      ibsql.ParamByName('BALANCEDATE').AsDateTime := FCloseDate;
      ibsql.ParamByName('ACCKEY').AsInteger := ibsqlAccount.FieldByName('ID').AsInteger;
      ibsql.ExecQuery;

      // Запомним кол-во вставленных записей, будем использовать его при переносе бух. остатков в AC_ENTRY
      FInsertedEntryBalanceRecordCount := FInsertedEntryBalanceRecordCount + ibsql.RowsAffected;

      ibsqlAccount.Next;
    end;

    // Установим новое значение генератора gd_g_entry_balance_date
    ibsql.Close;
    ibsql.SQL.Text :=
      Format('SET GENERATOR gd_g_entry_balance_date TO %d', [Round(FCloseDate) + IBDateDelta]);
    ibsql.ExecQuery;

    // Визуализация процесса
    SetupProgressBar(ProgressBar.Position, ProgressBar.Position);
    AddLogMessage(TimeToStr(FLocalStartTime) + ': Вычисление бухгалтерских остатков завершено');
    AddLogMessage('Продолжительность процесса: ' + TimeToStr(Time - FLocalStartTime));
  finally
    ibsqlAccount.Free;
    ibsql.Free;
  end;
end;

procedure TgdClosingPeriod.TransferEntryBalance;
const
  DocumentTypeKeyRUID = '806001_17';
  TRRecordKeyRUID = '807100_17';
  TransactionKeyRUID = '807001_17';

  ibMainBegin =
    ' SELECT ' +
    '  companykey, ' +
    '  accountkey, ' +
    '  currkey, ' +
    '  debitncu, ' +
    '  creditncu, ' +
    '  debitcurr, ' +
    '  creditcurr, ' +
    '  debiteq, ' +
    '  crediteq ';
  ibMainMiddle =
    ' FROM ' +
    '  ac_entry_balance ';
  ibACEntryWriteBegin =
    ' INSERT INTO ac_entry ' +
    ' (recordkey, entrydate, transactionkey, documentkey, masterdockey, companykey, accountkey, accountpart, currkey, issimple, ' +
    '  debitncu, creditncu, debitcurr, creditcurr, debiteq, crediteq ';
  ibACEntryWriteValues =
    ' VALUES ' +
    ' (:recordkey, :entrydate, :transactionkey, :documentkey, :masterdockey, :companykey, :accountkey, :accountpart, :currkey, 1, ' +
    '  :debitncu, :creditncu, :debitcurr, :creditcurr, :debiteq, :crediteq ';
var
  ibsqlSelect: TIBSQL;
  ibsqlInsertGDDocument: TIBSQL;
  ibsqlInsertACRecord: TIBSQL;
  ibsqlInsertACEntry: TIBSQL;
  DocumentTypeKey, TransactionKey, TRRecordKey: TID;
  NextDocumentKey, NextRecordKey: TID;
  InsertAnalytics, ValuesAnalytics: String;
  AnalyticCounter: Integer;
  CurrentCompanyKey: TID;
  CurrentRefreshInfoStep: Integer;
begin
  FLocalStartTime := Time;

  // Визуализация процесса
  AddLogMessage(TimeToStr(FLocalStartTime) + ': Копирование бухгалтерских остатков...');

  ibsqlSelect := TIBSQL.Create(nil);
  ibsqlInsertACRecord := TIBSQL.Create(nil);
  ibsqlInsertGDDocument := TIBSQL.Create(nil);
  ibsqlInsertACEntry := TIBSQL.Create(nil);
  try
    ibsqlSelect.Transaction := FWriteTransaction;
    ibsqlInsertACRecord.Transaction := FWriteTransaction;
    ibsqlInsertGDDocument.Transaction := FWriteTransaction;
    ibsqlInsertACEntry.Transaction := FWriteTransaction;

    // Получим ключ типа складского документа для остатков
    DocumentTypeKey := gdcBaseManager.GetIDByRUIDString(DocumentTypeKeyRUID);
    // Запрос на вставку записи в gd_document
    ibsqlInsertGDDocument.SQL.Text := Format(
      'INSERT INTO gd_document ' +
      '  (id, documenttypekey, number, documentdate, companykey, afull, achag, aview, creatorkey, editorkey) ' +
      'VALUES ' +
      '  (:id, %0:d, ''1'', :documentdate, :companykey, -1, -1, -1, %1:d, %1:d) ', [DocumentTypeKey, IBLogin.ContactKey]);
    ibsqlInsertGDDocument.Prepare;

    // Получим ключ типовой проводки
    TRRecordKey := gdcBaseManager.GetIDByRUIDString(TRRecordKeyRUID);
    // Получим ключ типовой операции
    TransactionKey := gdcBaseManager.GetIDByRUIDString(TransactionKeyRUID);
    // Запрос на вставку проводки в AC_RECORD
    ibsqlInsertACRecord.SQL.Text := Format(
      'INSERT INTO ac_record ' +
      '  (id, trrecordkey, transactionkey, recorddate, documentkey, masterdockey, companykey, afull, achag, aview) ' +
      'VALUES ' +
      '  (:id, %0:d, %1:d, :recorddate, :documentkey, :documentkey, :companykey, -1, -1, -1) ', [TRRecordKey, TransactionKey]);
    ibsqlInsertACRecord.Prepare;

    // возьмем выбранные аналитики по расчитываемому счету
    ValuesAnalytics := '';
    for AnalyticCounter := 0 to FEntryAvailableAnalytics.Count - 1 do
      ValuesAnalytics := ValuesAnalytics + ', ' + FEntryAvailableAnalytics.Strings[AnalyticCounter];

    // Получим сальдо из AC_ENTRY_BALANCE
    ibsqlSelect.SQL.Text :=
      ' SELECT ' +
      '   companykey, accountkey, currkey, debitncu, creditncu, debitcurr, creditcurr, debiteq, crediteq ' +
        ValuesAnalytics +
      ' FROM ' +
      '   ac_entry_balance ';
    ibsqlSelect.ExecQuery;

    SetupProgressBar(0, FInsertedEntryBalanceRecordCount);

    CurrentCompanyKey := -1;
    NextDocumentKey := -1;
    CurrentRefreshInfoStep := 0;
    while not ibsqlSelect.Eof do
    begin
      // При нажатии Escape прервем процесс
      if {Self.Active and }((GetAsyncKeyState(VK_ESCAPE) shr 1) <> 0) then
      begin
        if Application.MessageBox('Остановить закрытие периода?', 'Внимание',
           MB_YESNO or MB_ICONQUESTION or MB_SYSTEMMODAL) = IDYES then
          raise Exception.Create('Выполнение прервано');
      end;

      if CurrentCompanyKey <> ibsqlSelect.FieldByName('COMPANYKEY').AsInteger then
      begin
        CurrentCompanyKey := ibsqlSelect.FieldByName('COMPANYKEY').AsInteger;
        // Получение ключа для документа
        NextDocumentKey := gdcBaseManager.GetNextID;
        // Создание документа
        ibsqlInsertGDDocument.ParamByName('ID').AsInteger := NextDocumentKey;
        ibsqlInsertGDDocument.ParamByName('DOCUMENTDATE').AsDateTime := FCloseDate - 1;
        ibsqlInsertGDDocument.ParamByName('COMPANYKEY').AsInteger := CurrentCompanyKey;
        ibsqlInsertGDDocument.ExecQuery;
      end;

      // Получение ключа заголовка проводки
      NextRecordKey := gdcBaseManager.GetNextID;
      // Вставка заголовка проводки
      ibsqlInsertACRecord.Close;
      ibsqlInsertACRecord.ParamByName('ID').AsInteger := NextRecordKey;
      ibsqlInsertACRecord.ParamByName('RECORDDATE').AsDateTime := FCloseDate - 1;
      ibsqlInsertACRecord.ParamByName('DOCUMENTKEY').AsInteger := NextDocumentKey;
      ibsqlInsertACRecord.ParamByName('COMPANYKEY').AsInteger := CurrentCompanyKey;
      ibsqlInsertACRecord.ExecQuery;

      // возьмем выбранные аналитики по расчитываемому счету
      InsertAnalytics := '';
      ValuesAnalytics := '';
      for AnalyticCounter := 0 to FEntryAvailableAnalytics.Count - 1 do
      begin
        if not ibsqlSelect.FieldByName(FEntryAvailableAnalytics.Strings[AnalyticCounter]).IsNull then
        begin
          InsertAnalytics := InsertAnalytics + ', ' + FEntryAvailableAnalytics.Strings[AnalyticCounter];
          ValuesAnalytics := ValuesAnalytics + ', :' + FEntryAvailableAnalytics.Strings[AnalyticCounter];
        end;
      end;
      // Сформируем запрос на вставку проводки в AC_ENTRY
      ibsqlInsertACEntry.SQL.Text :=
        ibACEntryWriteBegin + InsertAnalytics + ')' +
        ibACEntryWriteValues + ValuesAnalytics + ')';
      // Вставка дебетовой части проводки
      ibsqlInsertACEntry.Close;
      ibsqlInsertACEntry.ParamByName('RECORDKEY').AsInteger := NextRecordKey;
      ibsqlInsertACEntry.ParamByName('ENTRYDATE').AsDateTime := FCloseDate - 1;
      ibsqlInsertACEntry.ParamByName('TRANSACTIONKEY').AsInteger := TransactionKey;
      ibsqlInsertACEntry.ParamByName('DOCUMENTKEY').AsInteger := NextDocumentKey;
      ibsqlInsertACEntry.ParamByName('COMPANYKEY').AsInteger := CurrentCompanyKey;
      ibsqlInsertACEntry.ParamByName('ACCOUNTKEY').AsInteger := ibsqlSelect.FieldByName('ACCOUNTKEY').AsInteger;
      ibsqlInsertACEntry.ParamByName('ACCOUNTPART').AsString := 'D';
      ibsqlInsertACEntry.ParamByName('CURRKEY').AsInteger := ibsqlSelect.FieldByName('CURRKEY').AsInteger;
      ibsqlInsertACEntry.ParamByName('DEBITNCU').AsCurrency := ibsqlSelect.FieldByName('DEBITNCU').AsCurrency;
      ibsqlInsertACEntry.ParamByName('DEBITCURR').AsCurrency := ibsqlSelect.FieldByName('DEBITCURR').AsCurrency;
      ibsqlInsertACEntry.ParamByName('DEBITEQ').AsCurrency := ibsqlSelect.FieldByName('DEBITEQ').AsCurrency;
      ibsqlInsertACEntry.ParamByName('CREDITNCU').AsCurrency := 0;
      ibsqlInsertACEntry.ParamByName('CREDITCURR').AsCurrency := 0;
      ibsqlInsertACEntry.ParamByName('CREDITEQ').AsCurrency := 0;
      for AnalyticCounter := 0 to FEntryAvailableAnalytics.Count - 1 do
      begin
        if not ibsqlSelect.FieldByName(FEntryAvailableAnalytics.Strings[AnalyticCounter]).IsNull then
        begin
          ibsqlInsertACEntry.ParamByName(FEntryAvailableAnalytics.Strings[AnalyticCounter]).AsVariant :=
            ibsqlSelect.FieldByName(FEntryAvailableAnalytics.Strings[AnalyticCounter]).AsVariant;
        end;
      end;
      ibsqlInsertACEntry.ExecQuery;
      // Вставка кредитовой части проводки
      ibsqlInsertACEntry.Close;
      ibsqlInsertACEntry.ParamByName('RECORDKEY').AsInteger := NextRecordKey;
      ibsqlInsertACEntry.ParamByName('ENTRYDATE').AsDateTime := FCloseDate - 1;
      ibsqlInsertACEntry.ParamByName('TRANSACTIONKEY').AsInteger := TransactionKey;
      ibsqlInsertACEntry.ParamByName('DOCUMENTKEY').AsInteger := NextDocumentKey;
      ibsqlInsertACEntry.ParamByName('COMPANYKEY').AsInteger := CurrentCompanyKey;
      ibsqlInsertACEntry.ParamByName('ACCOUNTKEY').AsInteger := ibsqlSelect.FieldByName('ACCOUNTKEY').AsInteger;
      ibsqlInsertACEntry.ParamByName('ACCOUNTPART').AsString := 'C';
      ibsqlInsertACEntry.ParamByName('CURRKEY').AsInteger := ibsqlSelect.FieldByName('CURRKEY').AsInteger;
      ibsqlInsertACEntry.ParamByName('DEBITNCU').AsCurrency := 0;
      ibsqlInsertACEntry.ParamByName('DEBITCURR').AsCurrency := 0;
      ibsqlInsertACEntry.ParamByName('DEBITEQ').AsCurrency := 0;
      ibsqlInsertACEntry.ParamByName('CREDITNCU').AsCurrency := ibsqlSelect.FieldByName('CREDITNCU').AsCurrency;
      ibsqlInsertACEntry.ParamByName('CREDITCURR').AsCurrency := ibsqlSelect.FieldByName('CREDITCURR').AsCurrency;
      ibsqlInsertACEntry.ParamByName('CREDITEQ').AsCurrency := ibsqlSelect.FieldByName('CREDITEQ').AsCurrency;
      for AnalyticCounter := 0 to FEntryAvailableAnalytics.Count - 1 do
      begin
        if not ibsqlSelect.FieldByName(FEntryAvailableAnalytics.Strings[AnalyticCounter]).IsNull then
        begin
          ibsqlInsertACEntry.ParamByName(FEntryAvailableAnalytics.Strings[AnalyticCounter]).AsVariant :=
            ibsqlSelect.FieldByName(FEntryAvailableAnalytics.Strings[AnalyticCounter]).AsVariant;
        end;
      end;
      ibsqlInsertACEntry.ExecQuery;

      // Визуализация процесса
      if CurrentRefreshInfoStep >= REFRESH_CLOSING_INFO_INTERVAL then
      begin
        StepProgressBar(CurrentRefreshInfoStep);
        CurrentRefreshInfoStep := 0;
      end
      else
        Inc(CurrentRefreshInfoStep);

      ibsqlSelect.Next;
    end;

    AddLogMessage('Удаление временных данных...');

    ibsqlSelect.Close;
    ibsqlSelect.SQL.Text := 'DELETE FROM ac_entry_balance';
    ibsqlSelect.ExecQuery;

    ibsqlSelect.Close;
    ibsqlSelect.SQL.Text := 'SET GENERATOR gd_g_entry_balance_date TO 0';
    ibsqlSelect.ExecQuery;
  finally
    ibsqlInsertACEntry.Free;
    ibsqlInsertGDDocument.Free;
    ibsqlInsertACRecord.Free;
    ibsqlSelect.Free;
  end;
  // Визуализация процесса
  SetupProgressBar(FInsertedEntryBalanceRecordCount, FInsertedEntryBalanceRecordCount);
  AddLogMessage(TimeToStr(FLocalStartTime) + ': Копирование бухгалтерских остатков завершено');
  AddLogMessage('Продолжительность процесса: ' + TimeToStr(Time - FLocalStartTime));
end;

procedure TgdClosingPeriod.AddLogMessage(const AMessage: String);
begin
  // Если указали вести лог закрытия
  if FDoMaintainLog then
  begin
    FMessageLog.Add(AMessage);
    // Если присвоили TMemo для отображения лога
    if Assigned(FMessageLogMemo) then
    begin
      FMessageLogMemo.Lines.Add(AMessage);
      UpdateWindow(FMessageLogMemo.Handle);
    end;
  end;
end;

procedure TgdClosingPeriod.SetMessageLogMemo(const Value: TMemo);
begin
  FMessageLogMemo := Value;
  // Если передан существующий TMemo, значит будем вести лог
  if Assigned(Value) then
    FDoMaintainLog := True
  else
    FDoMaintainLog := False;
end;

procedure TgdClosingPeriod.SetupProgressBar(const APosition, AMaxPosition: Integer);
begin
  if Assigned(FProgressBar) then
  begin
    FProgressBar.Position := APosition;
    FProgressBar.Max := AMaxPosition;
    UpdateWindow(FProgressBar.Handle);
  end;

  if Assigned(FProgressBarLabel) then
  begin
    FProgressBarLabel.Caption := IntToStr(APosition) + ' / ' + IntToStr(AMaxPosition);
    if Assigned(FProgressBarLabel.Owner) then
      UpdateWindow(TWinControl(FProgressBarLabel.Owner).Handle);
  end;
end;

procedure TgdClosingPeriod.StepProgressBar(const AStepValue: Integer = 1);
begin
  if Assigned(FProgressBar) then
  begin
    // Если мы достигли конца ПрогрессБара, а процесс еще идет, увеличим его размер
    if FProgressBar.Position >= FProgressBar.Max then
      FProgressBar.Max := FProgressBar.Max * 2;
    FProgressBar.StepBy(AStepValue);
    UpdateWindow(FProgressBar.Handle);
  end;

  if Assigned(FProgressBarLabel) then
  begin
    FProgressBarLabel.Caption := IntToStr(FProgressBar.Position) + ' / ' + IntToStr(FProgressBar.Max);
    if Assigned(FProgressBarLabel.Owner) then
      UpdateWindow(TWinControl(FProgressBarLabel.Owner).Handle);
  end;
end;

procedure TgdClosingPeriod.InitialFillOptions;
var
  AcAccountRelation: TatRelation;
  AnalyticCounter: Integer;
begin
  // Выберем подходящие бухгалтерские аналитики
  AcAccountRelation := atDatabase.Relations.ByRelationName('AC_ACCOUNT');
  if Assigned(AcAccountRelation) then
  begin
    for AnalyticCounter := 0 to AcAccountRelation.RelationFields.Count - 1 do
    begin
      if AcAccountRelation.RelationFields.Items[AnalyticCounter].IsUserDefined
         and (AnsiPos(';' + AcAccountRelation.RelationFields.Items[AnalyticCounter].FieldName + ';', DontBalanceAnalytic) = 0) then
        FEntryAvailableAnalytics.Add(AcAccountRelation.RelationFields.Items[AnalyticCounter].FieldName);
    end;
  end
  else
    raise Exception.Create('AC_ACCOUNT not found!');
end;

function TgdClosingPeriod.AddDepotHeader(const FromContact, ToContact, CompanyKey: TID): TID;
var
  NextDocumentKey: TID;
begin
  // Получим ИД документа шапки
  NextDocumentKey := gdcBaseManager.GetNextID;
  // Вставим запись в gd_document
  FIBSQLInsertGdDocument.Close;
  FIBSQLInsertGdDocument.ParamByName('ID').AsInteger := NextDocumentKey;
  FIBSQLInsertGdDocument.ParamByName('PARENT').Clear;
  FIBSQLInsertGdDocument.ParamByName('COMPANYKEY').AsInteger := CompanyKey;
  FIBSQLInsertGdDocument.ParamByName('DOCUMENTDATE').AsDateTime := FCloseDate;
  FIBSQLInsertGdDocument.ExecQuery;

  // Вставим запись в дополнительную таблицу документа шапки
  FIBSQLInsertDocumentHeader.Close;
  FIBSQLInsertDocumentHeader.ParamByName('DOCUMENTKEY').AsInteger := NextDocumentKey;
  FIBSQLInsertDocumentHeader.ParamByName('OUTCONTACT').AsInteger := FromContact;
  FIBSQLInsertDocumentHeader.ParamByName('INCONTACT').AsInteger := ToContact;
  FIBSQLInsertDocumentHeader.ExecQuery;

  Result := NextDocumentKey;
end;

function TgdClosingPeriod.AddDepotPosition(const FromContact, ToContact, CompanyKey,
  ADocumentParentKey, CardGoodkey: TID; const GoodQuantity: Currency; FeatureDataset: TIBSQL = nil): TID;
var
  NextDocumentKey, NextMovementKey, NextCardKey: TID;
  FieldCounter: Integer;
begin
  // Получим ИД документа позиции
  NextDocumentKey := gdcBaseManager.GetNextID;
  // Вставим запись в gd_document
  FIBSQLInsertGdDocument.Close;
  FIBSQLInsertGdDocument.ParamByName('ID').AsInteger := NextDocumentKey;
  FIBSQLInsertGdDocument.ParamByName('PARENT').AsInteger := ADocumentParentKey;
  FIBSQLInsertGdDocument.ParamByName('COMPANYKEY').AsInteger := CompanyKey;
  FIBSQLInsertGdDocument.ParamByName('DOCUMENTDATE').AsDateTime := FCloseDate;
  FIBSQLInsertGdDocument.ExecQuery;

  // Получим ИД новой складской карточки
  NextCardKey := gdcBaseManager.GetNextID;
  // Создадим новую складскую карточку
  FIBSQLInsertInvCard.Close;
  FIBSQLInsertInvCard.ParamByName('ID').AsInteger := NextCardKey;
  FIBSQLInsertInvCard.ParamByName('GOODKEY').AsInteger := CardGoodkey;
  FIBSQLInsertInvCard.ParamByName('DOCUMENTKEY').AsInteger := NextDocumentKey;
  FIBSQLInsertInvCard.ParamByName('COMPANYKEY').AsInteger := CompanyKey;
  for FieldCounter := 0 to FFeatureList.Count - 1 do
    if Assigned(FeatureDataset) then
      FIBSQLInsertInvCard.ParamByName(FFeatureList.Strings[FieldCounter]).AsVariant :=
        FeatureDataset.FieldByName(FFeatureList.Strings[FieldCounter]).AsVariant
    else
      FIBSQLInsertInvCard.ParamByName(FFeatureList.Strings[FieldCounter]).Clear;
  // Заполним поле USR$INV_ADDLINEKEY карточки нового остатка ссылкой на позицию
  if FAddLineKeyFieldExists then
    FIBSQLInsertInvCard.ParamByName('USR$INV_ADDLINEKEY').AsInteger := NextDocumentKey;
  FIBSQLInsertInvCard.ExecQuery;

  // Получим ИД складского движения
  NextMovementKey := gdcBaseManager.GetNextID;
  // Создадим дебетовую часть складского движения
  FIBSQLInsertInvMovement.Close;
  FIBSQLInsertInvMovement.ParamByName('MOVEMENTKEY').AsInteger := NextMovementKey;
  FIBSQLInsertInvMovement.ParamByName('DOCUMENTKEY').AsInteger := NextDocumentKey;
  FIBSQLInsertInvMovement.ParamByName('CONTACTKEY').AsInteger := ToContact;
  FIBSQLInsertInvMovement.ParamByName('CARDKEY').AsInteger := NextCardKey;
  FIBSQLInsertInvMovement.ParamByName('DEBIT').AsCurrency := GoodQuantity;
  FIBSQLInsertInvMovement.ParamByName('CREDIT').AsCurrency := 0;
  FIBSQLInsertInvMovement.ExecQuery;
  // Создадим кредитовую часть складского движения
  FIBSQLInsertInvMovement.Close;
  FIBSQLInsertInvMovement.ParamByName('MOVEMENTKEY').AsInteger := NextMovementKey;
  FIBSQLInsertInvMovement.ParamByName('DOCUMENTKEY').AsInteger := NextDocumentKey;
  FIBSQLInsertInvMovement.ParamByName('CONTACTKEY').AsInteger := FromContact;
  FIBSQLInsertInvMovement.ParamByName('CARDKEY').AsInteger := NextCardKey;
  FIBSQLInsertInvMovement.ParamByName('DEBIT').AsCurrency := 0;
  FIBSQLInsertInvMovement.ParamByName('CREDIT').AsCurrency := GoodQuantity;
  FIBSQLInsertInvMovement.ExecQuery;

  // Вставим запись в дополнительную таблицу документа позиции
  FIBSQLInsertDocumentPosition.Close;
  FIBSQLInsertDocumentPosition.ParamByName('DOCUMENTKEY').AsInteger := NextDocumentKey;
  FIBSQLInsertDocumentPosition.ParamByName('MASTERKEY').AsInteger := ADocumentParentKey;
  FIBSQLInsertDocumentPosition.ParamByName('FROMCARDKEY').AsInteger := NextCardKey;
  FIBSQLInsertDocumentPosition.ParamByName('QUANTITY').AsCurrency := GoodQuantity;
  FIBSQLInsertDocumentPosition.ExecQuery;

  Result := NextCardKey;
end;

procedure TgdClosingPeriod.InitializeIBSQLQueries;
var
  gdcObject: TgdcInvDocument;
  InvDocumentInField, InvDocumentOutField: ShortString;
  InvRelationName, InvRelationLineName: ShortString;
  FieldCounter: Integer;
  SQLText: String;
begin
  if not FQueriesInitialized then
  begin
    // Получим ключ типа складского документа для остатков
    FInvDocumentTypeKey := gdcBaseManager.GetIDByRUIDString(InvDocumentRUID);
    // Сущестует ли поле-ссылка на позицию прихода
    FAddLineKeyFieldExists := Assigned(atDatabase.FindRelationField('INV_CARD', 'USR$INV_ADDLINEKEY'));
    // Получим необходимые наименования таблиц и полей
    gdcObject := TgdcInvDocument.Create(nil);
    try
      gdcObject.Transaction := FWriteTransaction;
      gdcObject.SubType := InvDocumentRUID;
      gdcObject.SubSet := 'ByID';
      // Названия полей-ссылок на контакты, на которые и с которых приходуются ТМЦ
      InvDocumentInField := gdcObject.MovementTarget.SourceFieldName;
      InvDocumentOutField := gdcObject.MovementSource.SourceFieldName;
      InvRelationName := gdcObject.RelationName;
      InvRelationLineName := gdcObject.RelationLineName;
    finally
      gdcObject.Free;
    end;

    // Запрос на вставку записи в gd_document
    FIBSQLInsertGdDocument.Transaction := FWriteTransaction;
    FIBSQLInsertGdDocument.SQL.Text := Format(
      'INSERT INTO gd_document ' +
      '  (id, parent, documenttypekey, number, documentdate, companykey, afull, achag, aview, creatorkey, editorkey) ' +
      'VALUES ' +
      '  (:id, :parent, %0:d, ''1'', :documentdate, :companykey, -1, -1, -1, %1:d, %1:d) ', [FInvDocumentTypeKey, IBLogin.ContactKey]);
    FIBSQLInsertGdDocument.Prepare;

    // Запрос на вставку записи в шапку складского документа
    FIBSQLInsertDocumentHeader.Transaction := FWriteTransaction;
    FIBSQLInsertDocumentHeader.SQL.Text := Format(
      'INSERT INTO %0:s ' +
      '  (documentkey, %1:s, %2:s) ' +
      'VALUES ' +
      '  (:documentkey, :incontact, :outcontact) ', [InvRelationName, InvDocumentInField, InvDocumentOutField]);
    FIBSQLInsertDocumentHeader.Prepare;

    // Запрос на вставку записи в позиции складского документа
    FIBSQLInsertDocumentPosition.Transaction := FWriteTransaction;
    FIBSQLInsertDocumentPosition.SQL.Text := Format(
      'INSERT INTO %0:s ' +
      '  (documentkey, masterkey, fromcardkey, quantity) ' +
      'VALUES ' +
      '  (:documentkey, :masterkey, :fromcardkey, :quantity) ', [InvRelationLineName]);
    FIBSQLInsertDocumentPosition.Prepare;

    // Запрос на создание складской карточки
    FIBSQLInsertInvCard.Transaction := FWriteTransaction;
    SQLText :=
      'INSERT INTO inv_card ' +
      '  (id, goodkey, documentkey, firstdocumentkey, firstdate, companykey';
    // Поля-признаки
    for FieldCounter := 0 to FFeatureList.Count - 1 do
      SQLText := SQLText + ', ' + FFeatureList.Strings[FieldCounter];
    // Если сущестует поле-ссылка на позицию прихода
    if FAddLineKeyFieldExists then
      SQLText := SQLText + ', USR$INV_ADDLINEKEY';
    SQLText := SQLText + ') VALUES ' +
      '  (:id, :goodkey, :documentkey, :documentkey, :firstdate, :companykey';
    // Поля-признаки
    for FieldCounter := 0 to FFeatureList.Count - 1 do
      SQLText := SQLText + ', :' + FFeatureList.Strings[FieldCounter];
    // Если сущестует поле-ссылка на позицию прихода
    if FAddLineKeyFieldExists then
      SQLText := SQLText + ', :USR$INV_ADDLINEKEY';
    SQLText := SQLText + ')';
    FIBSQLInsertInvCard.SQL.Text := SQLText;
    FIBSQLInsertInvCard.ParamByName('FIRSTDATE').AsDateTime := FCloseDate;
    FIBSQLInsertInvCard.Prepare;

    // Запрос на создание складского движения
    FIBSQLInsertInvMovement.Transaction := FWriteTransaction;
    FIBSQLInsertInvMovement.SQL.Text :=
      'INSERT INTO inv_movement ' +
      '  (movementkey, movementdate, documentkey, contactkey, cardkey, debit, credit) ' +
      'VALUES ' +
      '  (:movementkey, :movementdate, :documentkey, :contactkey, :cardkey, :debit, :credit) ';
    FIBSQLInsertInvMovement.ParamByName('MOVEMENTDATE').AsDateTime := FCloseDate;
    FIBSQLInsertInvMovement.Prepare;

    FQueriesInitialized := True;
  end;
end;

end.
