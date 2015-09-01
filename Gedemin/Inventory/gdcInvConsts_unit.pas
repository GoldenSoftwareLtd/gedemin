
{++


  Copyright (c) 2001-2015 by Golden Software of Belarus

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

const
  //
  // ������ ��������� ��� ������

  // ������������� �������� (�� �� ����� ����������� ��������)
  gdcInv_Document_Undone = 'UNDONE';
  // ������ 1.6
  gdcInvDocument_Version1_6 = 'IDV1.6';
  // ������ 1.7
  gdcInvDocument_Version1_7 = 'IDV1.7';
  // ������ 1.8
  gdcInvDocument_Version1_8 = 'IDV1.8';
  // ������ 1.9
  gdcInvDocument_Version1_9 = 'IDV1.9';
  // ������ 2.0
  gdcInvDocument_Version2_0 = 'IDV2.0';
  // ������ 2.1
  gdcInvDocument_Version2_1 = 'IDV2.1';
  // ������ 2.2
  gdcInvDocument_Version2_2 = 'IDV2.2';
  // ������ 2.3
  gdcInvDocument_Version2_3 = 'IDV2.3';
  // ������ 2.4
  gdcInvDocument_Version2_4 = 'IDV2.4';
  // ������ 2.5
  gdcInvDocument_Version2_5 = 'IDV2.5';
  // ������ 2.6
  gdcInvDocument_Version2_6 = 'IDV2.6';
  // ������ 3.0 ������ ���������� �� ��������.
  gdcInvDocument_Version3_0 = 'IDV3.0';

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
      imctCompanyDepartment, imctCompanyPeople, imctPeople, imctOurDepartAndPeople
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

    procedure Assign(AnObject: TgdcInvMovementContactOption);
    procedure GetProperties(ASL: TStrings);
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
  'Sub %0:s(Sender) '#13#10 +
  '  If scrPublicVariables.Value("%1:s") <> "1" Then '#13#10 +
  '    scrPublicVariables.AddValue "%1:s", "1" '#13#10 +
  '    Sender.DataSet.FieldByName("%2:s").AsVariant = _ '#13#10 +
  '       Sender.AsVariant * Sender.DataSet.FieldByName("QUANTITY").AsVariant '#13#10 +
  '    scrPublicVariables.AddValue "%1:s", "0" '#13#10 +
  '  End If '#13#10#13#10 +
  '  Dim EventParams(0) '#13#10 +
  '  Set  EventParams(0) = Sender'#13#10 +
  '  Call Inherited(Sender, "OnChange", EventParams)'#13#10#13#10 +
  'End Sub ';

  gdcInvCalcPriceMacrosName =
  'Sub %0:s(Sender) '#13#10 +
  '  If scrPublicVariables.Value("%2:s") <> "1" Then '#13#10 +
  '    scrPublicVariables.AddValue "%2:s", "1" '#13#10 +
  '    If Not IsNull(Sender.DataSet.FieldByName("QUANTITY").AsVariant) And _'#13#10 +
  '       Sender.DataSet.FieldByName("QUANTITY").AsVariant <> 0 Then '#13#10 +
  '      Sender.DataSet.FieldByName("%2:s").AsVariant = _ '#13#10 +
  '         Sender.AsVariant / Sender.DataSet.FieldByName("QUANTITY").AsVariant '#13#10 +
  '    End If '#13#10 +
  '    scrPublicVariables.AddValue "%2:s", "0" '#13#10 +
  '  End If '#13#10#13#10 +
  '  Dim EventParams(0) '#13#10 +
  '  Set  EventParams(0) = Sender'#13#10 +
  '  Call Inherited(Sender, "OnChange", EventParams)'#13#10#13#10#13#10 +
  'End Sub ';

  gdcInvQuantityOnChangeHeader = 'Sub gdcInvDocumentLine%sOnChange(Sender)';
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

uses
  SysUtils, gd_common_functions;

{ TgdcInvMovementContactOption }

procedure TgdcInvMovementContactOption.Assign(
  AnObject: TgdcInvMovementContactOption);
begin
  RelationName := AnObject.RelationName;
  SourceFieldName := AnObject.SourceFieldName;

  SubRelationName := AnObject.SubRelationName;
  SubSourceFieldName := AnObject.SubSourceFieldName;

  ContactType := AnObject.ContactType;
  Predefined := Copy(AnObject.Predefined, 0, MaxInt);
  SubPredefined := Copy(AnObject.SubPredefined, 0, MaxInt);
end;

procedure TgdcInvMovementContactOption.GetProperties(ASL: TStrings);
var
  S: String;
  I: Integer;
begin
  Assert(ASL <> nil);

  ASL.Add(AddSpaces('Relation name:') + RelationName);
  ASL.Add(AddSpaces('Source field name:') + SourceFieldName);
  ASL.Add(AddSpaces('Sub relation name:') + SubRelationName);
  ASL.Add(AddSpaces('Sub source field name:') + SubSourceFieldName);

  case ContactType of
    imctOurCompany: S := '���� ��������';
    imctOurDepartment: S := '���� �������������';
    imctOurPeople: S := '��� ���������';
    imctCompany: S := '��������';
    imctCompanyDepartment: S := '�������������';
    imctCompanyPeople: S := '���������';
    imctPeople: S := '���������� ����';
    imctOurDepartAndPeople: S := '���� ������������� � ���������';
  end;

  ASL.Add(AddSpaces('ContactType:') + S);

  S := '';
  for I := 0 to High(Predefined) do
    S := S + IntToStr(Predefined[I]) + ', ';
  if S > '' then
    SetLength(S, Length(S) - 2);
  ASL.Add(AddSpaces('Predefined:') + S);

  S := '';
  for I := 0 to High(SubPredefined) do
    S := S + IntToStr(SubPredefined[I]) + ', ';
  if S > '' then
    SetLength(S, Length(S) - 2);
  ASL.Add(AddSpaces('SubPredefined:') + S);
end;

end.
