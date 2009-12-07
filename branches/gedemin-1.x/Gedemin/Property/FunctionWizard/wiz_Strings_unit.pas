unit wiz_Strings_unit;

interface
const
  ENG_BEGINDATE = 'BeginDate';
  ENG_ENDDATE = 'EndDate';
  ENG_ENTRYDATE = 'EntryDate';
  ISZERO = 'IsZero';

  RUS_BEGINDATE = '���� ������ �������';
  RUS_ENDDATE = '���� ��������� �������';
  RUS_ENTRYDATE = '���� ��������';

  ENG_GDCENTRY = 'gdcEntry';
  ENG_GDCDOCUMENT = 'gdcDocument';
  RUS_GDCENTRY = '������ ������ ��������';
  RUS_GDCDOCUMENT = '������ ������ ���������';
  RUS_DONOTDELETE = '�� �������!';

  ENG_GDCTAXDESIGNDATE = 'gdcTaxDesignDate';
  ENG_GDCTAXRESULT = 'gdcTaxResult';

  RUS_ACCOUNT = '����...';
  RUS_INVALIDDOCUMENTTYPE = '������ ������������ ��������.';
  RUS_CURR = '������...';
  RUS_COMPANY = '��������...';
  RUS_EXPRESSION = '���������...';

  cwHeader = '�����';
  cwLine   = '�������';

  AC_ACCOUNT = 'AC_ACCOUNT';
  AC_ENTRY = 'AC_ENTRY';
  GD_CURR = 'GD_CURR';
  AC_QUANTITY = 'AC_QUANTITY';
  AC_RECORD = 'AC_RECORD';

  RUS_INVALIDACCOUNT = '������� ������������ �������� �����.';
  RUS_INVALIDTYPE = '��� ������� �� ���������.';

  RUS_TRENTRY_ERROR1 = '���������� �������� ��� ������� ��� ������� ������� ��������.';
  RUS_TRENTRY_ERROR2 =
    '���������� ������� ������� �������� � ����� ����� ''�����'' � '#13#10 +
    '���������� ������� ������� �������� � ����� ����� ''������'' ��'#13#10 +
    '����� ������������ ���� ������ 1. ������� ������ '#13#10 +
    '������� ������� �������� ��� �������� ���� ������.';
  RUS_TRENTRY_ERROR3 = '���������� �������� ������� ������� �������� � ����� ����� ''������''.';
  RUS_TRENTRY_ERROR4 = '���������� �������� ������� ������� �������� � ����� ����� ''�����''.';
  RUS_TRENTRY_ERROR5 =
    '���������� ������� ������� �������� � ����������� ������� �'#13#10 +
    '����������� ������ ������ �� ����� ��������� 1. � ��������� '#13#10 +
    '�������� ������� �������� ������� ���������� ����� � ���� ������:'#13#10+
    '%s';
  RUS_TRENTRY_DEBIT = '''�����''';
  RUS_TRENTRY_CREDIT = '''������''';

  ENG_DEBITNCU = 'DebitNcu';
  ENG_CREDITNCU = 'CreditNcu';
  ENG_DEBITCURR = 'DebitCurr';
  ENG_CREDITCURR = 'CreditCurr';
  ENG_RECORDKEY = 'RecordKey';
  ENG_DEBITEQ = 'DebitEq';
  ENG_CREDITEQ= 'CreditEq';

  RUS_INVALID_VISUALBLOCK_NAME = '��� "%s" ������ �������� �� ���� ����������� ��������';
  RUS_NO_FOREIGN_KEY_ON_AC_QUANTITY =
    '� ������� AC_QUANTITY �� ���� VALUEKEY ����������� '#13#10 +
    '������� ������ �� ���� ID ������� GD_VALUE.';

  RUS_SAVECHANGES = '������� ���� ��������. ��������� ���������?';
  RUS_QUESTION  = '������';

  MSG_INVALID_NAME = '������� ����������� ������������.';
  MSG_INVALID_EXPRESSION = '����������, ������� �������.';
  MSG_INPUT_DEBIT_ACCOUNT = '����������, ������� ���� �� ������.';
  MSG_INPUT_CREDIT_ACCOUNT = '����������, ������� ���� �� �������.';
  MSG_INPUT_SUM = '����������, ������� ����� �������� � ��� ���'#13#10 +
    '����� � ������ � ������.';
  MSG_INPUT_ENTRYDATE = '����������, ��������� ���� "������ �������", '#13#10 +
    '"����� �������", "���� ��������".';
  MSG_INPUT_EVAL = '����������, ��������� ���� "���������".';

  MSG_SQL_ERROR = 'SQL ������ �������� �������� ������:'#13#10'%s';
implementation

end.
