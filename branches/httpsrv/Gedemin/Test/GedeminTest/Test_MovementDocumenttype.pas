unit Test_MovementDocumenttype;

interface

uses
  Classes, TestFrameWork, gsTestFrameWork, IBSQL;

type
  Tgs_MovementDocumentTypeTest = class(TgsDBTestCase)
  published
    procedure Test_MovementDocumentType;
  end;

implementation

uses
  SysUtils, gd_security, IB, gdcBaseInterface;

procedure Tgs_MovementDocumentTypeTest.Test_MovementDocumentType;

  procedure InsertDocumentType(q: TIBSQL; const AnID, AParent: TID; const AName, ARUID: String);
  begin
    q.Close;
    q.SQL.Text :=
      'INSERT INTO gd_documenttype (id, parent, name, ruid)' +
      'VALUES (:id, :parent, :name, :ruid)';
    q.ParamByName('id').AsInteger := AnID;
    q.ParamByName('parent').AsInteger := AParent;
    q.ParamByName('name').AsString := AName;
    q.ParamByName('ruid').AsString := ARUID;
    q.ExecQuery;
  end;
const
  InvDocType = 804000;
  PriceListDocType = 805000;
var
  DocumentType1, DocumentType2: TID;
begin
  DocumentType1 := gdcBaseManager.GetNextID;
  InsertDocumentType(FQ, DocumentType1, InvDocType,  'Тип складского документа 1', gdcBaseManager.GetRUIDStringByID(DocumentType1));

  FQ2.Close;
  FQ2.SQL.Text := 'UPDATE gd_documenttype SET parent = :parent WHERE id = :id';
  FQ2.ParamByName('id').AsInteger := DocumentType1;
  FQ2.ParamByName('parent').AsInteger := 801000;
  StartExpectingException(EIBInterBaseError);
  FQ2.ExecQuery;
  StopExpectingException('');

  DocumentType2 := gdcBaseManager.GetNextID;
  InsertDocumentType(FQ, DocumentType2, DocumentType1,  'Тип складского документа 2', gdcBaseManager.GetRUIDStringByID(DocumentType2));

  FQ2.Close;
  FQ2.SQL.Text := 'UPDATE gd_documenttype SET parent = :parent WHERE id = :id';
  FQ2.ParamByName('id').AsInteger := DocumentType2;
  FQ2.ParamByName('parent').AsInteger := InvDocType;
  FQ2.ExecQuery;

  FQ.Close;
  FQ.SQL.Text := 'SELECT * FROM gd_documenttype WHERE id = :id AND parent = :parent';
  FQ.ParamByName('id').AsInteger := DocumentType2;
  FQ.ParamByName('parent').AsInteger := InvDocType;
  FQ.ExecQuery;
  Check(not FQ.EOF);

  DocumentType1 := gdcBaseManager.GetNextID;
  InsertDocumentType(FQ, DocumentType1, PriceListDocType,  'Тип прайс-лист 1', gdcBaseManager.GetRUIDStringByID(DocumentType1));

  FQ2.Close;
  FQ2.SQL.Text := 'UPDATE gd_documenttype SET parent = :parent WHERE id = :id';
  FQ2.ParamByName('id').AsInteger := DocumentType1;
  FQ2.ParamByName('parent').AsInteger := 801000;
  StartExpectingException(EIBInterBaseError);
  FQ2.ExecQuery;
  StopExpectingException('');

  DocumentType2 := gdcBaseManager.GetNextID;
  InsertDocumentType(FQ,  DocumentType2, DocumentType1,  'Тип прай-лист 2', gdcBaseManager.GetRUIDStringByID(DocumentType2));

  FQ2.Close;
  FQ2.SQL.Text := 'UPDATE gd_documenttype SET parent = :parent WHERE id = :id';
  FQ2.ParamByName('id').AsInteger := DocumentType2;
  FQ2.ParamByName('parent').AsInteger := PriceListDocType;
  FQ2.ExecQuery;

  FQ.Close;
  FQ.SQL.Text := 'SELECT * FROM gd_documenttype WHERE id = :id AND parent = :parent';
  FQ.ParamByName('id').AsInteger := DocumentType2;
  FQ.ParamByName('parent').AsInteger := PriceListDocType;
  FQ.ExecQuery;
  Check(not FQ.EOF);

  DocumentType1 := gdcBaseManager.GetNextID;
  InsertDocumentType(FQ, DocumentType1, 801000,  'Тип документа пользователя 1', gdcBaseManager.GetRUIDStringByID(DocumentType1));

  FQ2.Close;
  FQ2.SQL.Text := 'UPDATE gd_documenttype SET parent = :parent WHERE id = :id';
  FQ2.ParamByName('id').AsInteger := DocumentType1;
  FQ2.ParamByName('parent').AsInteger := InvDocType;
  StartExpectingException(EIBInterBaseError);
  FQ2.ExecQuery;
  StopExpectingException('');

  FQ2.Close;
  FQ2.SQL.Text := 'UPDATE gd_documenttype SET parent = :parent WHERE id = :id';
  FQ2.ParamByName('id').AsInteger := DocumentType1;
  FQ2.ParamByName('parent').AsInteger := PriceListDocType;
  StartExpectingException(EIBInterBaseError);
  FQ2.ExecQuery;
  StopExpectingException('');

  DocumentType2 := gdcBaseManager.GetNextID;
  InsertDocumentType(FQ, DocumentType2, 800001,  'Тип выписка и картотека 1', gdcBaseManager.GetRUIDStringByID(DocumentType2));

  FQ2.Close;
  FQ2.SQL.Text := 'UPDATE gd_documenttype SET parent = :parent WHERE id = :id';
  FQ2.ParamByName('id').AsInteger := DocumentType2;
  FQ2.ParamByName('parent').AsInteger := DocumentType1;
  FQ2.ExecQuery;      

  FQ.Close;
  FQ.SQL.Text := 'SELECT * FROM gd_documenttype WHERE id = :id AND parent = :parent';
  FQ.ParamByName('id').AsInteger := DocumentType2;
  FQ.ParamByName('parent').AsInteger := DocumentType1;
  FQ.ExecQuery;
  Check(not FQ.EOF);
end;

initialization
  RegisterTest('DB', Tgs_MovementDocumentTypeTest.Suite);
end.
