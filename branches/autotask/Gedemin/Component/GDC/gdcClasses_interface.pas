unit gdcClasses_interface;

interface

type
  TgdcDocumentClassPart = (
    dcpHeader,        // dcpHeader - ����� ���������
    dcpLine           // dcpLine - ������� ���������
  );

  TIsCheckNumber = (
    icnNever,         // �� ��������� ������������ ������
    icnAlways,        // ��������� ��� ���� ����������
    icnYear,          // ��������� ������ � ������� ����
    icnMonth          // ��������� ������ � ������� ������
  );

implementation

end.