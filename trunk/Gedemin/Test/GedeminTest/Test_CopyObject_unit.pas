
unit Test_CopyObject_unit;

interface

uses
  TestFrameWork, gsTestFrameWork;

type
  TTestCopyObject = class(TgsDBTestCase)
  published
    procedure TestCopySimpleObject;
    {procedure TestCopyObjectWithDetail;} 
    procedure TestCopyProcedure;
  end;

implementation

uses
  gdcBase, gdcBaseInterface, IBDatabase, Classes, SysUtils,
  db, gdcInvDocument_unit, gdcAttrUserDefined, gdcWgPosition,
  gdcConstants, gdcMetadata, ibsql, at_frmSQLProcess;

procedure TTestCopyObject.TestCopySimpleObject;
var
  WriteTransaction: TIBTransaction;
  gdcObject: TgdcBase;
  OriginalRecordKey: TID;
begin
  // Транзакция на запись
  WriteTransaction := TIBTransaction.Create(nil);
  try
    WriteTransaction.DefaultDatabase := gdcBaseManager.Database;
    WriteTransaction.StartTransaction;
    try
      // Создаем новый объект типа Курс валюты
      gdcObject := TgdcWgPosition.
        CreateWithParams(nil, gdcBaseManager.Database, WriteTransaction, '', ssById);
      try
        gdcObject.Transaction := WriteTransaction;
        gdcObject.ReadTransaction := WriteTransaction;
        gdcObject.Open;
        // Вставим новую запись
        gdcObject.Insert;
        gdcObject.FieldByName('NAME').AsString := 'test_pos';
        gdcObject.Post;

        OriginalRecordKey := gdcObject.ID;

        // Скопируем запись
        gdcObject.CopyObject(False, False);

        Check((gdcObject.ID > -1) and (OriginalRecordKey <> gdcObject.ID), 'Объект не указывает на скопированную запись');

        gdcObject.Close;
      finally
        FreeAndNil(gdcObject);
      end;
    except
      if WriteTransaction.InTransaction then
        WriteTransaction.Rollback;
    end;
  finally
    // Откатим транзакцию после окончания теста
    if WriteTransaction.InTransaction then
      WriteTransaction.Rollback;
    FreeAndNil(WriteTransaction);
  end;
end;

{procedure TTestCopyObject.TestCopyObjectWithDetail;
const
  GDC_SUBTYPE = '147012468_486813904';
  GDC_ADDINFO = 'USR$INV_ADDINFO';
var
  WriteTransaction: TIBTransaction;
  gdcObject, gdcObjectLine, gdcAttrUser: TgdcBase;
  ibsqlGood: TIBSQL;
  DS: TDataSource;
  OriginalRecordKey, GoodKey: TID;
begin
  // Транзакция на запись
  WriteTransaction := TIBTransaction.Create(nil);
  try
    WriteTransaction.DefaultDatabase := gdcBaseManager.Database;
    WriteTransaction.StartTransaction;
    try
      // Создаем новый объект типа Накладная на приход
      try
        gdcObject := TgdcInvDocument.
          CreateWithParams(nil, gdcBaseManager.Database, WriteTransaction, GDC_SUBTYPE, ssById);
      except
        Check(False, 'Нет складского документа с SubType = 147012468_486813904')
      end;
      DS := TDataSource.Create(nil);
      gdcObjectLine := TgdcInvDocumentLine.
        CreateWithParams(nil, gdcBaseManager.Database, WriteTransaction, GDC_SUBTYPE, ssById);
      gdcAttrUser := TgdcAttrUserDefined.
        CreateWithParams(nil, gdcBaseManager.Database, WriteTransaction, GDC_ADDINFO, ssById);
      ibsqlGood := TIBSQL.Create(nil);
      try
        GoodKey := -1;
        // Берем любой товар
        ibsqlGood.Transaction := WriteTransaction;
        ibsqlGood.SQL.Text := 'SELECT FIRST(1) id FROM gd_good';
        ibsqlGood.ExecQuery;
        if ibsqlGood.RecordCount > 0 then
          GoodKey := ibsqlGood.FieldByName('ID').AsInteger;
        ibsqlGood.Close;

        if GoodKey > -1 then
        begin
          gdcObject.Transaction := WriteTransaction;
          gdcObject.ReadTransaction := WriteTransaction;
          gdcObjectLine.Transaction := WriteTransaction;
          gdcObjectLine.ReadTransaction := WriteTransaction;
          gdcAttrUser.Transaction := WriteTransaction;
          gdcAttrUser.ReadTransaction := WriteTransaction;

          // Свяжем и откроем объекты
          DS.DataSet := gdcObject;
          gdcObjectLine.MasterSource := DS;
          gdcObjectLine.MasterField := 'ID';
          gdcObjectLine.DetailField := 'PARENT';
          gdcObjectLine.SubSet := ssByParent;

          gdcAttrUser.MasterSource := DS;
          gdcAttrUser.MasterField := 'ID';
          gdcAttrUser.DetailField := 'ID';

          gdcObject.Open;
          gdcObjectLine.Open;

          // Вставим новую запись
          gdcObject.Insert;
          gdcObject.FieldByName('USR$CONTACTKEY').AsInteger := gdcBaseManager.GetIDByRUID(650010, 17);
          gdcObject.FieldByName('USR$DEPTKEY').AsInteger := gdcBaseManager.GetIDByRUID(650010, 17);
          gdcObject.Post;

          gdcAttrUser.Insert;
          gdcAttrUser.FieldByName('USR$CUSTOMERKEY').AsInteger := gdcBaseManager.GetIDByRUID(650010, 17);
          gdcAttrUser.Post;

          // Вставим позиции
          gdcObjectLine.Insert;
          gdcObjectLine.FieldByName('GOODKEY').AsInteger := GoodKey;
          gdcObjectLine.FieldByName('QUANTITY').AsCurrency := 33;
          gdcObjectLine.Post;

          gdcObjectLine.Insert;
          gdcObjectLine.FieldByName('GOODKEY').AsInteger := GoodKey;
          gdcObjectLine.FieldByName('QUANTITY').AsCurrency := 66;
          gdcObjectLine.Post;

          gdcObjectLine.Insert;
          gdcObjectLine.FieldByName('GOODKEY').AsInteger := GoodKey;
          gdcObjectLine.FieldByName('QUANTITY').AsCurrency := 11;
          gdcObjectLine.Post;

          OriginalRecordKey := gdcObject.ID;

          // Скопируем запись
          gdcObject.CopyObject(True, False);

          Check((gdcObject.ID > -1) and (OriginalRecordKey <> gdcObject.ID), 'Объект не указывает на скопированную запись');
          Check((gdcAttrUser.ID > -1) and (gdcAttrUser.ID <> OriginalRecordKey), '1-к-1 не скопирован');
          Check(gdcAttrUser.FieldByName('USR$CUSTOMERKEY').AsInteger = gdcBaseManager.GetIDByRUID(650010, 17),
            '1-к-1 скопирован неверно');

          // Пройдем по всем позициям для верного RecordCount
          while not gdcObjectLine.Eof do
            gdcObjectLine.Next;

          Check(gdcObjectLine.RecordCount = 3, 'Скопированы не все позиции');

          gdcObjectLine.Close;
          gdcAttrUser.Close;
          gdcObject.Close;
        end
        else
        begin
          Fail('Нет ни одного товара (TgdcGood) для копирования!');
        end;
      finally
        FreeAndNil(ibsqlGood);
        FreeAndNil(gdcObjectLine);
        FreeAndNil(gdcAttrUser);
        FreeAndNil(DS);
        FreeAndNil(gdcObject);
      end;
    except
      if WriteTransaction.InTransaction then
        WriteTransaction.Rollback;
    end;
  finally
    // Откатим транзакцию после окончания теста
    if WriteTransaction.InTransaction then
      WriteTransaction.Rollback;
    FreeAndNil(WriteTransaction);
  end;
end;}

procedure TTestCopyObject.TestCopyProcedure;
var
  WriteTransaction: TIBTransaction;
  gdcObject: TgdcBase;
  ProcKey: TID;
  ibsqlProc: TIBSQL;
  OriginalProcName: String;
begin
  // Транзакция на запись
  WriteTransaction := TIBTransaction.Create(nil);
  try
    WriteTransaction.DefaultDatabase := gdcBaseManager.Database;
    WriteTransaction.StartTransaction;
    try
      // Создаем новый объект типа Курс валюты
      gdcObject := TgdcStoredProc.
        CreateWithParams(nil, gdcBaseManager.Database, WriteTransaction, '', ssById);
      ibsqlProc := TIBSQL.Create(nil);
      try
        ProcKey := -1;

        ibsqlProc.Transaction := WriteTransaction;
        ibsqlProc.SQL.Text := 'SELECT FIRST(1) id FROM at_procedures WHERE procedurename STARTING WITH ''USR$''';
        ibsqlProc.ExecQuery;
        if ibsqlProc.RecordCount > 0 then
          ProcKey := ibsqlProc.FieldByName('ID').AsInteger;
        ibsqlProc.Close;

        Check(ProcKey > -1, 'Нет ни одной пользовательской процедуры для копирования!');

        gdcObject.Transaction := WriteTransaction;
        gdcObject.ReadTransaction := WriteTransaction;
        gdcObject.Open;
        // Перейдем на выбранную процедуру
        gdcObject.ID := ProcKey;
        OriginalProcName := gdcObject.FieldByName('PROCEDURENAME').AsString;

        // Скопируем запись
        gdcObject.CopyObject(False, False);

        Check((gdcObject.ID > -1) and (ProcKey <> gdcObject.ID), 'Объект не указывает на скопированную запись');
        Check((gdcObject.FieldByName('PROCEDURENAME').AsString <> '') and (gdcObject.FieldByName('PROCEDURENAME').AsString <> OriginalProcName),
          'Ошибка в наименовании скопированного объекта');

        gdcObject.Close;
      finally
        FreeAndNil(ibsqlProc);
        FreeAndNil(gdcObject);
      end;
    except
      if WriteTransaction.InTransaction then
        WriteTransaction.Rollback;
    end;
  finally
    // Откатим транзакцию после окончания теста
    if WriteTransaction.InTransaction then
      WriteTransaction.Rollback;
    FreeAndNil(WriteTransaction);
  end;

  if frmSQLProcess <> nil then
    Check(not frmSQLProcess.IsError);
end;

initialization
  RegisterTest('DB', TTestCopyObject.Suite);
end.

