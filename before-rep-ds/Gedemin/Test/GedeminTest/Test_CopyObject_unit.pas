
unit Test_CopyObject_unit;

interface

uses
  TestFrameWork;

type
  TTestCopyObject = class(TTestCase)
  published
    procedure TestCopySimpleObject;
    procedure TestCopyObjectWithDetail;
    procedure TestCopyProcedure;
  end;

implementation

uses
  gdcBase, gdcBaseInterface, IBDatabase, Classes, SysUtils, db, gdcInvDocument_unit,
  gdcAttrUserDefined, gdcCurr, gdcConstants, gdcMetadata, ibsql;

procedure TTestCopyObject.TestCopySimpleObject;
var
  WriteTransaction: TIBTransaction;
  gdcObject: TgdcBase;
  OriginalRecordKey: TID;
begin
  // ���������� �� ������
  WriteTransaction := TIBTransaction.Create(nil);
  try
    WriteTransaction.DefaultDatabase := gdcBaseManager.Database;
    WriteTransaction.StartTransaction;
    try
      // ������� ����� ������ ���� ���� ������
      gdcObject := TgdcCurrRate.
        CreateWithParams(nil, gdcBaseManager.Database, WriteTransaction, '', ssById);
      try
        gdcObject.Transaction := WriteTransaction;
        gdcObject.ReadTransaction := WriteTransaction;
        gdcObject.Open;
        // ������� ����� ������
        gdcObject.Insert;
        gdcObject.FieldByName('FROMCURR').AsInteger := gdcBaseManager.GetIDByRUID(200010, 17);
        gdcObject.FieldByName('TOCURR').AsInteger := gdcBaseManager.GetIDByRUID(200020, 17);
        gdcObject.FieldByName('FORDATE').AsDateTime := Date;
        gdcObject.FieldByName('COEFF').AsCurrency := 100.65;
        gdcObject.Post;

        OriginalRecordKey := gdcObject.ID;

        // ��������� ������
        gdcObject.CopyObject(False, True);

        Check((gdcObject.ID > -1) and (OriginalRecordKey <> gdcObject.ID), '������ �� ��������� �� ������������� ������');

        gdcObject.Close;
      finally
        FreeAndNil(gdcObject);
      end;
    except
      if WriteTransaction.InTransaction then
        WriteTransaction.Rollback;
    end;
  finally
    // ������� ���������� ����� ��������� �����
    if WriteTransaction.InTransaction then
      WriteTransaction.Rollback;
    FreeAndNil(WriteTransaction);
  end;
end;

procedure TTestCopyObject.TestCopyObjectWithDetail;
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
  // ���������� �� ������
  WriteTransaction := TIBTransaction.Create(nil);
  try
    WriteTransaction.DefaultDatabase := gdcBaseManager.Database;
    WriteTransaction.StartTransaction;
    try
      // ������� ����� ������ ���� ��������� �� ������
      gdcObject := TgdcInvDocument.
        CreateWithParams(nil, gdcBaseManager.Database, WriteTransaction, GDC_SUBTYPE, ssById);
      DS := TDataSource.Create(nil);
      gdcObjectLine := TgdcInvDocumentLine.
        CreateWithParams(nil, gdcBaseManager.Database, WriteTransaction, GDC_SUBTYPE, ssById);
      gdcAttrUser := TgdcAttrUserDefined.
        CreateWithParams(nil, gdcBaseManager.Database, WriteTransaction, GDC_ADDINFO, ssById);
      ibsqlGood := TIBSQL.Create(nil);
      try
        GoodKey := -1;
        // ����� ����� �����
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

          // ������ � ������� �������
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

          // ������� ����� ������
          gdcObject.Insert;
          gdcObject.FieldByName('USR$CONTACTKEY').AsInteger := gdcBaseManager.GetIDByRUID(650010, 17);
          gdcObject.FieldByName('USR$DEPTKEY').AsInteger := gdcBaseManager.GetIDByRUID(650010, 17);
          gdcObject.Post;

          gdcAttrUser.Insert;
          gdcAttrUser.FieldByName('USR$CUSTOMERKEY').AsInteger := gdcBaseManager.GetIDByRUID(650010, 17);
          gdcAttrUser.Post;

          // ������� �������
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

          // ��������� ������
          gdcObject.CopyObject(True, False);

          Check((gdcObject.ID > -1) and (OriginalRecordKey <> gdcObject.ID), '������ �� ��������� �� ������������� ������');
          Check((gdcAttrUser.ID > -1) and (gdcAttrUser.ID <> OriginalRecordKey), '1-�-1 �� ����������');
          Check(gdcAttrUser.FieldByName('USR$CUSTOMERKEY').AsInteger = gdcBaseManager.GetIDByRUID(650010, 17),
            '1-�-1 ���������� �������');

          // ������� �� ���� �������� ��� ������� RecordCount
          while not gdcObjectLine.Eof do
            gdcObjectLine.Next;

          Check(gdcObjectLine.RecordCount = 3, '����������� �� ��� �������');

          gdcObjectLine.Close;
          gdcAttrUser.Close;
          gdcObject.Close;
        end
        else
        begin
          Fail('��� �� ������ ������ (TgdcGood) ��� �����������!');
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
    // ������� ���������� ����� ��������� �����
    if WriteTransaction.InTransaction then
      WriteTransaction.Rollback;
    FreeAndNil(WriteTransaction);
  end;
end;

procedure TTestCopyObject.TestCopyProcedure;
var
  WriteTransaction: TIBTransaction;
  gdcObject: TgdcBase;
  ProcKey: TID;
  ibsqlProc: TIBSQL;
  OriginalProcName: String;
begin
  // ���������� �� ������
  WriteTransaction := TIBTransaction.Create(nil);
  try
    WriteTransaction.DefaultDatabase := gdcBaseManager.Database;
    WriteTransaction.StartTransaction;
    try
      // ������� ����� ������ ���� ���� ������
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

        if ProcKey > -1 then
        begin
          gdcObject.Transaction := WriteTransaction;
          gdcObject.ReadTransaction := WriteTransaction;
          gdcObject.Open;
          // �������� �� ��������� ���������
          gdcObject.ID := ProcKey;
          OriginalProcName := gdcObject.FieldByName('PROCEDURENAME').AsString;

          // ��������� ������
          gdcObject.CopyObject(False, False);

          Check((gdcObject.ID > -1) and (ProcKey <> gdcObject.ID), '������ �� ��������� �� ������������� ������');
          Check((gdcObject.FieldByName('PROCEDURENAME').AsString <> '') and (gdcObject.FieldByName('PROCEDURENAME').AsString <> OriginalProcName),
            '������ � ������������ �������������� �������');

          gdcObject.Close;
        end
        else
        begin
          Fail('��� �� ����� ���������������� ��������� ��� �����������!');
        end;
      finally
        FreeAndNil(ibsqlProc);
        FreeAndNil(gdcObject);
      end;
    except
      if WriteTransaction.InTransaction then
        WriteTransaction.Rollback;
    end;
  finally
    // ������� ���������� ����� ��������� �����
    if WriteTransaction.InTransaction then
      WriteTransaction.Rollback;
    FreeAndNil(WriteTransaction);
  end;
end;

initialization
  RegisterTest('', TTestCopyObject.Suite);
end.

