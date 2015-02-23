
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
//  ����� � ������ ����������� �� ������ ���� � �����

const
  // ��� ��������
  DELIVERY_BRANCH = 1000;
  // ��� ����������
  DESTINATION_BRANCH = 2000;
  // ������/�������
  DISCOUNT_BRANCH = 3000;

//
//  ������������ ���������� � ��������� �� �����

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
    PaymentDate: Integer; // ���� �������
    Account: String; // ��������� ���� �����������
    ReceiverAccountType: Integer; // ��� ����� ����������

    Oper: String; // ��� ���.
    OperKind: String; // ��� �����.
    Dest: String; // ����. ����.
    Queue: String; // �����������

    Term: Integer; // ��� ����� �������
    GoodDate: Integer; // ��� ���� ������, ������

    Specification: String; // ��������� �������
    Destination: String; // ���������� �������
    TransactionKey: String; // ��������
  end;

type
  TctlTextKind = (tkText, tkField);

  TctlTextArea = record
    Text: String;
    Kind: TctlTextKind;
  end;

  TDestinationArray = array of TctlTextArea;


// ��������� ����� � ������ � ���������
procedure ParseDestination(const Destination: String;
  var DestinationArray: TDestinationArray);

// ������������ �������� ������� ������������� ������� �� ������  
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
  //  ������ ����� ����������
  if not Assigned(Stream) or (Stream.Size = 0) then Exit;

  Reader := TReader.Create(Stream, 1024);

  try
    // ��������� ������
    Reader.ReadString;

    Template.PaymentDate := Reader.ReadInteger;

    // ������ �� �����
    Template.Account := Reader.ReadString;

    // ��� ����� ����������
    Template.ReceiverAccountType := Reader.ReadInteger;

    // ��� ���������
    Template.Oper := Reader.ReadString;

    // ��� ��������
    Template.OperKind := Reader.ReadString;

    // ���������� �������
    Template.Dest := Reader.ReadString;

    // ����������� �������
    Template.Queue := Reader.ReadString;

    // ���� �������
    Template.Term := Reader.ReadInteger;

    // ���� ������, ������
    Template.GoodDate := Reader.ReadInteger;

    // ��������� �������
    Template.Specification := Reader.ReadString;

    // ���������� �������
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
