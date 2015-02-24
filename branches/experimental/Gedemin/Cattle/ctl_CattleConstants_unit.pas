
{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    ctl_CattleConstants_unit.pas

  Abstract

    Window.

  Author

    Denis Romanosvki  (01.04.2001)

  Revisions history

    1.0    01.04.2001    Denis    Initial version.


--}

unit ctl_CattleConstants_unit;

interface

uses Classes;

//
//  Ветви в общего справочника по приему мяса и скота

const
  // Вид поставки
  DELIVERY_BRANCH = 1000;
  // Вид назначения
  DESTINATION_BRANCH = 2000;
  // Скидки/наценки
  DISCOUNT_BRANCH = 3000;

//
//  Наименования переменных в хранилице по скоту

const
  VALUE_CATTLEBRANCH = 'CATTLEBRANCH';
  
  FOLDER_CATTLE_SETTINGS = 'CATTLE SETTINGS';

  VALUE_PRICELIST_COMPANYCATTLE = 'COMPANYCATTLE';
  VALUE_PRICELIST_COMPANYMEATCATTLE = 'COMPANYMEATCATTLE';

  VALUE_PRICELIST_FACECATTLE = 'FACECOMPANYCATTLE';
  VALUE_PRICELIST_FACEMEATCATTLE = 'FACECOMPANYMEATCATTLE';

  VALUE_SUPPLIER_VAT = 'VALUESUPPLIERVAT';
  VALUE_SUPPLIER_FARMTAX = 'VALUESUPPLIERFARMTAX';
  VALUE_SUPPLIER_DISTANCE = 'VALUESUPPLIERDISTANCE';
  VALUE_SUPPLIER_NDSTRANS = 'VALUESUPPLIERNDSTRANS';

  VALUE_GOODGROUP_COEFFICIENT = 'VALUEGOODGROUPCOEFFICIENT';

  VALUE_RECEIPT_FORMULA = 'VALUERECEIPTFORMULA';
  VALUE_RECEIPT_TRANSACTION = 'VALUERECEIPTTRANSACTION';

  VALUE_PAYMENT_FORMAT = 'VALUEPAYMENTFORMAT';

  LAST_CATTLE_KIND = 'LASTCATTLEKIND';
  LAST_CATTLE_DEPARTMENT = 'LASTCATTLEDEPARTMENT';
  LAST_CATTLE_PURCHASEKIND = 'LAST_CATTLE_PURCHASEKIND';
  LAST_CATTLE_REGION = 'LASTCATTLEREGION';
  LAST_CATTLE_SUPPLIER = 'LASTCATTLESUPPLIER';
  LAST_CATTLE_DELIVERYKIND = 'LASTCATTLEDELIVERYKIND';
  LAST_CATTLE_RECEIVING = 'LASTCATTLERECEIVING';
  LAST_CATTLE_FORCESLAUGHTER = 'LASTCATTLEFORCESLAUGHTER';
  LAST_CATTLE_DESTINATION = 'LASTCATTLEDESTINATION';
  VALUE_RECEIPT_CoeffTariff = 'VALUERECEIPTCoeffTariff';
  Def_CoeffTariff = 718;

type
  TReceiptPaymentTemplate = record
    PaymentDate: Integer; // Дата платежа
    Account: String; // Расчетный счет плательщика
    ReceiverAccountType: Integer; // Вид счета получателя

    Oper: String; // Вид обр.
    OperKind: String; // Вид опера.
    Dest: String; // Назн. плат.
    Queue: String; // Очередность

    Term: Integer; // Вид срока платежа
    GoodDate: Integer; // Вид даты товара, услуги

    Specification: String; // Уточнение платежа
    Destination: String; // Назначение платежа
    TransactionKey: String; // Операция
  end;

type
  TctlTextKind = (tkText, tkField);

  TctlTextArea = record
    Text: String;
    Kind: TctlTextKind;
  end;

  TDestinationArray = array of TctlTextArea;


// разбирает строк с полями в структуру
procedure ParseDestination(const Destination: String;
  var DestinationArray: TDestinationArray);

// осуществляет загрузку шаблона определенного формата из потока  
procedure LoadTemplate(Stream: TStream; var Template: TReceiptPaymentTemplate);


implementation


procedure ParseDestination(const Destination: String;
  var DestinationArray: TDestinationArray);
var
  I: Integer;
  C: Char;
  W: String;
  SquareBracketOpened: Boolean;
begin
  I := 1;
  SquareBracketOpened := False;
  SetLength(DestinationArray, 0);

  while I < Length(Destination) do
  begin
    C := Destination[I];
    Inc(I);

    case C of
      '[':
      begin
        if SquareBracketOpened then
        begin
          W := W + C;
          Continue;
        end;

        SetLength(DestinationArray, Length(DestinationArray) + 1);

        with DestinationArray[Length(DestinationArray) - 1] do
        begin
          Text := W;
          Kind := tkText;
        end;

        W := '';
        SquareBracketOpened := True;
      end;
      ']':
      begin
        if not SquareBracketOpened then
        begin
          W := W + C;
          Continue;
        end;

        SetLength(DestinationArray, Length(DestinationArray) + 1);

        with DestinationArray[Length(DestinationArray) - 1] do
        begin
          Text := W;
          Kind := tkField;
        end;

        W := '';
        SquareBracketOpened := False;
      end;
    else
      W := W + C;
    end;
  end;

  if (W > '') then
  begin
    SetLength(DestinationArray, Length(DestinationArray) + 1);

    with DestinationArray[Length(DestinationArray) - 1] do
    begin
      Text := W;
      Kind := tkText;
    end;
  end;
end;

procedure LoadTemplate(Stream: TStream;
  var Template: TReceiptPaymentTemplate);
var
  Reader: TReader;
begin
  //  Чистый поток пропускаем
  if not Assigned(Stream) or (Stream.Size = 0) then Exit;

  Reader := TReader.Create(Stream, 1024);

  try
    // Считываем версию
    Reader.ReadString;

    Template.PaymentDate := Reader.ReadInteger;

    // Оплата со счета
    Template.Account := Reader.ReadString;

    // Вид счета получателя
    Template.ReceiverAccountType := Reader.ReadInteger;

    // Вид обработки
    Template.Oper := Reader.ReadString;

    // Вид операции
    Template.OperKind := Reader.ReadString;

    // Назначение платежа
    Template.Dest := Reader.ReadString;

    // Очередность платежа
    Template.Queue := Reader.ReadString;

    // Срок платежа
    Template.Term := Reader.ReadInteger;

    // Дата товара, услуги
    Template.GoodDate := Reader.ReadInteger;

    // Уточнение платежа
    Template.Specification := Reader.ReadString;

    // Назначение платежа
    Template.Destination := Reader.ReadString;
    try
      Template.TransactionKey := Reader.ReadString;
    except
      Template.TransactionKey := '';
    end;
  finally
    Reader.Free;
  end;
end;



end.
