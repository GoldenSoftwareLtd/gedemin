// ShlTanya, 24.02.2019

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
    function DeleteDoc(DocumentKey: TID): Boolean;

  public
    // Номер документа
    function GetNewNumber(DocumentType: TID): String;
    function GetNewPaymentNumber(DocumentType, AccountKey: TID): String;
    // Новый ключ документа
    function GetNewKey: TID;
    // Тип документа
    function GetDocumentType(DocumentKey: TID): TID;
  end;

var
  dmDocument: TdmDocument;

implementation

{$R *.DFM}

function TdmDocument.DeleteDoc(DocumentKey: TID): Boolean;
begin
  try
    QRY.SQL.Text := 'DELETE FROM gd_document WHERE id = ' + TID2S(DocumentKey);
    QRY.ExecQuery;
    Result := True;
  except
    Result := False;
  end;
end;

// Номер документа
function TdmDocument.GetNewPaymentNumber(DocumentType, AccountKey: TID): String;
var
  N: Integer;
begin
  qryNewPaymentNumber.Close;
  SetTID(qryNewPaymentNumber.Params.ByName('doctypekey'), DocumentType);
  SetTID(qryNewPaymentNumber.Params.ByName('accountkey'), AccountKey);
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
function TdmDocument.GetNewNumber(DocumentType: TID): String;
var
  N: Integer;
begin
  qryNewNumber.Close;
  SetTID(qryNewNumber.Params.ByName('doctypekey'), DocumentType);
  SetTID(qryNewNumber.Params.ByName('companykey'), IBLogin.CompanyKey);
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
function TdmDocument.GetNewKey: TID;
begin
  qryNewDocument.Close;
  qryNewDocument.ExecQuery;
  Result := GetTID(qryNewDocument.FieldByName('v'));
  qryNewDocument.Close;
end;

function TdmDocument.GetDocumentType(DocumentKey: TID): TID;
begin
  qryGetDocumentType.Close;
  SetTID(qryGetDocumentType.Params.ByName('id'), DocumentKey);
  qryGetDocumentType.ExecQuery;
  if qryGetDocumentType.RecordCount = 0 then
    Result := -1
  else
    Result := GetTID(qryGetDocumentType.FieldByName('documenttypekey'));
end;

end.
