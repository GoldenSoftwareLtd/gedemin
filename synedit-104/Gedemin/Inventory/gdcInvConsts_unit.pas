
{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    gdcInvConsts_unit.pas

  Abstract

    Part of inventory subsystem.

  Author

    Romanovski Denis (17-09-2001)

  Revisions history

    Initial  17-09-2001  Dennis  Initial version.

--}

unit gdcInvConsts_unit;

interface

uses Classes;

type
  // ������ �������� ���������
  TgdcInvFeatures = array of String;

  // ��� ��������
  TgdcInvMovementPart = (impIncome, impExpense, impAll);
  // impIncome - ������
  // impExpense - ������

  // ��� ��������
  TgdcInvFeatureKind = (ifkDest, ifkSource);
  // ifkSource - �� ��������-���������
  // ifkDest - �� ��������-����������

  // ��� ������������� �������� � ��������
  TgdcInvMovementContactType = (
    imctOurCompany, imctOurDepartment, imctOurPeople, imctCompany,
      imctCompanyDepartment, imctCompanyPeople, imctPeople
  );
  // imctOurCompany - ���� ��������
  // imctOurDepartment - ������������� ����� ��������
  // imctOurPeople - ��������� ����� ��������
  // imctCompany - ������ (����������� ����)
  // imctCompanyDepartment - ������������� �������
  // imctCompanyPeople - ��������� �������
  // imctPeople - ���������� ����

  // ��������� ������������ ��� ����������� ��������
  // ����������� �� �������� ��� ���������� ���
  // � ��������� ���������.
  TgdcInvMovementContactOption = class(TObject)
  public
    RelationName: String[31]; // ������������ �������
    SourceFieldName: String[31]; // ������������ ����-��������

    SubRelationName: String[31]; // ������������ �������
    SubSourceFieldName: String[31]; // ������������ ��������������� ����-��������

    ContactType: TgdcInvMovementContactType; // ��� ��������
    Predefined: array of Integer; // ����� ��������� ��������
    SubPredefined: array of Integer; // ����� ��������� ��������
  end;

  // ��� ��������� ���������� ����������
  TgdcInvReferenceSource = (irsGoodRef, irsRemainsRef, irsMacro);
  // irsGoodRef - � �������� ����������� ������������ ���������� �������
  // irsRemainsRef - � �������� ����������� ������������ ���������� �������� ���
  // irsMacro - � �������� ����������� ������������ ����������, ���������� �� �������

  // ����� ����� ��������� ����������
  TgdcInvReferenceSources = set of TgdcInvReferenceSource;

  // ����������� ������������� ��������
  TgdcInvMovementDirection = (imdFIFO, imdLIFO, imdDefault);
  // imdFIFO - �������
  // imLIFO - ����
  // imdDefault - �� ������� ���

  // ��� ������� ������� ���������� ���������
  TgdcInvRelationType = (irtSimple, irtFeatureChange, irtInventorization,
    irtTransformation, irtInvalid);
  // irtSimple -  ������� ������� ���������
  // irtFeatureChange - ��������� ��������� ���������
  // irtInventorization - ��������������
  // irtTransformation - �������������

  // ������ ��������� �������
  TgdcInvReserveInvents = array of Integer;

  // ��� ���������� ������� (�������� ��� ���� �������)
  TgdcInvPositionSaveMode = (ipsmDocument, ipsmPosition);

  TgdcInvErrorCode = (
    iecNoErr,
    iecGoodNotFound, // ��� ������ �� ������ �� ������ �������
    iecRemainsNotFound, // ������������ �������� �� ������� �������
    iecFoundOtherMovement,  // �� ������� ���� ��������
    iecFoundEarlyMovement,  // �� ������� ���� ����� ������ ��������
    iecRemainsNotFoundOnDate, // �� ��������� ���� ����������� �������
    iecDontDecreaseQuantity, // ������ ��������� ���������� �� ������ �������
    iecDontChangeDest, // ������ �������� �������� (�.�. �� ������� ������� ��������)
    iecDontChangeFeatures, // ������ �������� �������� (�.�. �� ���������� ������� ��������)
    iecDontDeleteFoundMovement, // ������ ������� ������� �� ������� ���� ��������
    iecDontDeleteDecreaseQuantity, // ������ ������� �������, ��-�� ���������� ��������
    iecRemainsLocked, // ������� ������� ������ �������������
    iecOtherIBError, // ������ �� ������
    iecDontDisableMovement, // ������ ��������������� ��������
    iecIncorrectCardField, // �� ���������� �������� ����
    iecUnknowError  // ����������� ������
  );


const
  INV_SOURCEFEATURE_PREFIX = 'FROM_';
  INV_DESTFEATURE_PREFIX = 'TO_';

  gdcInvErrorMessage: array[TgdcInvErrorCode] of String =
    ('��� ������ ',
     '��������� ��� �� ������ �� ��������� ������',
     '�� ���������� ��� ������������� ���-�� ��������',
     '������ ������� ������������ � ������ ����������',
     '�� ������ ������� ���� ����� ������ ��������',
     '�� ��������� ���� �� ������� ����������� �������', 
     '������ ��������� ���������� �� ������ �������',
     '������ �������� �������� (�.�. �� ����������� ������� ��������)',
     '������ �������� �������� (�.�. �� ���������� ������� ��������)',
     '������ ������� ������� �� ������� ���� ��������',
     '������ ������� �������, ��-�� ���������� ��������',
     '������� �� ������ ������� �������� ������ �������������. ���������� ��������� ��� �������� ����� ������ �������',
     '������ Interbase: %s',
     '������ ��������������� �������� �� ������ �������',
     '������������ �������� ����', 
     '%s');

const
  gdcInvCalcAmountMacrosName =
  'sub %0:s(Sender) '#13#10 +
  '  if scrPublicVariables.Value("%1:s") <> "1" then '#13#10 +
  '    scrPublicVariables.AddValue "%1:s", "1" '#13#10 +
  '    Sender.DataSet.FieldByName("%2:s").AsVariant = _ '#13#10 +
  '       Sender.AsVariant * Sender.DataSet.FieldByName("QUANTITY").AsVariant '#13#10 +
  '    scrPublicVariables.AddValue "%1:s", "0" '#13#10 +
  '  end if '#13#10#13#10 +
  '  dim EventParams(0) '#13#10 +
  '  set  EventParams(0) = Sender'#13#10 +
  '  call Inherited(Sender, "OnChange", EventParams)'#13#10#13#10 +
  'end sub ';

  gdcInvCalcPriceMacrosName =
  'sub %0:s(Sender) '#13#10 +
  '  if scrPublicVariables.Value("%2:s") <> "1" then '#13#10 +
  '    scrPublicVariables.AddValue "%2:s", "1" '#13#10 +
  '    if not IsNull(Sender.DataSet.FieldByName("QUANTITY").AsVariant) and _'#13#10 +
  '       Sender.DataSet.FieldByName("QUANTITY").AsVariant <> 0 then '#13#10 +
  '      Sender.DataSet.FieldByName("%2:s").AsVariant = _ '#13#10 +
  '         Sender.AsVariant / Sender.DataSet.FieldByName("QUANTITY").AsVariant '#13#10 +
  '    end if '#13#10 +
  '    scrPublicVariables.AddValue "%2:s", "0" '#13#10 +
  '  end if '#13#10#13#10 +
  '  dim EventParams(0) '#13#10 +
  '  set  EventParams(0) = Sender'#13#10 +
  '  call Inherited(Sender, "OnChange", EventParams)'#13#10#13#10#13#10 +
  'end sub ';

  gdcInvQuantityOnChangeHeader = 'sub gdcInvDocumentLine%sOnChange(Sender)';
  gdcInvQuantityOnChangeBodyLine = '  Sender.DataSet.FieldByName("%0:s").AsVariant = Sender.DataSet.FieldByName("%0:s").AsVariant ';


type
  // ������ ��� �������� ���� �����-�����
  TgdcInvPriceField = record
    FieldName: String[31]; // ������������ ����
    CurrencyKey: Integer; // ��� ������
    ContactKey: Integer; // ��� ��������
  end;

  // ������ ����� �����-�����
  TgdcInvPriceFields = array of TgdcInvPriceField;

implementation

end.
