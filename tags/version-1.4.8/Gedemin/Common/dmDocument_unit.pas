 {++
   Project TRANSACTION
   Copyright © 2000- by Golden Software

   Модуль

     dmDocument_unit

   Описание

     Работа с документами

   Автор

    Anton

   История

     ver    date    who    what
     1.00 - 24.08.2000 - anton - Первая версия

 --}

unit dmDocument_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_security_OperationConst, Db, IBCustomDataSet, IBQuery, gd_security,
  IBSQL, gsDBGrid;

type
  TdmDocument = class(TDataModule)
    qryGetDocumentType: TIBSQL;
    qryNewDocument: TIBSQL;
    qryNewNumber: TIBSQL;
    qryNewPaymentNumber: TIBSQL;
    QRY: TIBSQL;

  protected
    function DeleteDoc(DocumentKey: Integer): Boolean;

  public
    // Номер документа
    function GetNewNumber(DocumentType: Integer): String;
    function GetNewPaymentNumber(DocumentType, AccountKey: Integer): String;
    // Новый ключ документа
    function GetNewKey: Integer;
    // Тип документа
    function GetDocumentType(DocumentKey: Integer): Integer;
  end;

var
  dmDocument: TdmDocument;

implementation

{$R *.DFM}

function TdmDocument.DeleteDoc(DocumentKey: Integer): Boolean;
begin
  try
    QRY.SQL.Text := 'DELETE FROM gd_document WHERE id = ' + IntToStr(DocumentKey);
    QRY.ExecQuery;
    Result := True;
  except
    Result := False;
  end;
end;

// Номер документа
function TdmDocument.GetNewPaymentNumber(DocumentType, AccountKey: Integer): String;
var
  N: Integer;
begin
  qryNewPaymentNumber.Close;
  qryNewPaymentNumber.Params.ByName('doctypekey').AsInteger := DocumentType;
  qryNewPaymentNumber.Params.ByName('accountkey').AsInteger := AccountKey;
  qryNewPaymentNumber.ExecQuery;
  if qryNewPaymentNumber.RecordCount = 0 then
    Result := '1'
  else
    try
      N := StrToInt(qryNewPaymentNumber.FieldByName('number').AsString);
      Result := IntToStr(N + 1);
    except
      Result := '1';
    end;
end;

// Номер документа
function TdmDocument.GetNewNumber(DocumentType: Integer): String;
var
  N: Integer;
begin
  qryNewNumber.Close;
  qryNewNumber.Params.ByName('doctypekey').AsInteger := DocumentType;
  qryNewNumber.Params.ByName('companykey').AsInteger := IBLogin.CompanyKey;
  qryNewNumber.ExecQuery;
  if qryNewNumber.RecordCount = 0 then
    Result := '1'
  else
    try
      N := StrToInt(qryNewNumber.FieldByName('number').AsString);
      Result := IntToStr(N + 1);
    except
      Result := '1';
    end;
end;

// Новый ключ документа
function TdmDocument.GetNewKey: Integer;
begin
  qryNewDocument.Close;
  qryNewDocument.ExecQuery;
  Result := qryNewDocument.FieldByName('v').AsInteger;
  qryNewDocument.Close;
end;

function TdmDocument.GetDocumentType(DocumentKey: Integer): Integer;
begin
  qryGetDocumentType.Close;
  qryGetDocumentType.Params.ByName('id').AsInteger := DocumentKey;
  qryGetDocumentType.ExecQuery;
  if qryGetDocumentType.RecordCount = 0 then
    Result := -1
  else
    Result := qryGetDocumentType.FieldByName('documenttypekey').AsInteger;
end;

end.
