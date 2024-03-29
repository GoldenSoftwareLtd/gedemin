// ShlTanya, 24.02.2019

unit gd_resourcestring;

interface

resourcestring
  sDeleteMessageQuestion = '�� ������������� ������ ������� ���������(�)?';

  sMailDownloadCaption   = '����� ���������';
  sMailDownloadServer    = '������ %s';
  sMailDownloadCount     = '�������� ���������: %d';
  sMailUploadServer      = '������ %s';
  sMailUploadCount       = '���������� ���������: %d';

  sConnectionLostToIBServer = '���������� ���������� ���������� � �������� ���� ������.'#13#10 +
    '���������� ��������� ����� ����������.'#13#10 +
    '��� �������: %s'#13#10 +
    '��� ������ IBError: %d' +
    ''
    ;
  sCannotConnectToSpecifiedFile = '���� ���� ������ �� ������.'#13#10 +
    '���������� ��������� ����� ����������.'#13#10 +
    '��� �������: %s'#13#10 +
    '��� ������ IBError: %d' +
    ''
    ;

  sError                 = '������!';
  sAttention             = '��������!';

  sIncorrectPassword     = '������ �������� ������.'#13#10#13#10'����������, ��������� ��������� �� '#13#10'����������� ��������� ����������.';

  sBugBaseIncorrectRecordUpdate =
                           '��������� ������������ ���������� ���� �����.';

  sAttrNotInAdministratorModeCannotDropRelation =
                           '������ ������������� ������� ����� ����� �� �������� �������.';

  sgsDatabaseShutdownShutdownDlgCaption =
                           '������� ���� � �������������������� �����';
  sgsDatabaseShutdownShowUsersDlgCaption =
                           '������������, ������������ � ���� ������';

  sIncorrectShutdown     = '����� ������ ��� �������� �����������.';

  sDeleteDesktopQuery    = '�� ������������� ������ ������� ������� ���� "%s"?';

  s_gdcRelationField_NameTooLong =
    '����� ����� ���� ��������� 16 ��������. ����-������ ����� ���� �� ������� '#13#10 +
    '��� �������� ����-������, ����-���������. ����������?';

  sDublicateDocumentNumber = '����������� ����� ���������!';
  sSetDocumentDate = '���������� ������� ���� ���������!';
  s_InvBadChangeCloseWindow = '���������� ������ ��������� ������! ���� ����� ������� ��� ���������� ���� ��������� !';
  s_InvChooseGood = '���������� ������� ��� !';
  s_InvEmptyField = '����������� ���� ';
  s_InvErrorSaveHeadDocument =
    '��� ���������� ����� ��������� ��������� ��������� ������: %s';
  s_InvErrorEditDocument =
    '� ���������� �������������� �������� ������: %s'#13#10'����������� ������ ���������.';
  s_InvErrorSaveMovement =    
    '��� ������������ �������� �������� ������. ����������� ������ ���������.';
  s_InvFullErrorSaveMovement =
    '��� ������������ �������� �������� ������: %s'#13#10'����������� ������ ���������.';
  s_InvErrorChooseRemains = '������ ������� ������ ���, ��� ������� �� ������ �����.';
  
  sDBConnect = '���������� � ����� ������';
  sReadingDbScheme = '���������� ��������� ���� ������';
  sLoadingStorage = '�������� ���������';
  sLoadingUserDefinedClasses = '�������� ������-�������';
  sSynchronizationAtRelations = '������������� ������';
  sReadingDomains = '���������� �������';
  sReadingRelations = '���������� ������';
  sReadingFields = '���������� �����';
  sReadingPrimKeys = '���������� ��������� ������';
  sReadingForeignKeys = '���������� ������� ������';
  sLoadingGlobalStorage = '�������� ����������� ���������';
  sLoadingUserStorage = '�������� ����������������� ���������';
  //sLoadingCompanyStorage = '�������� ��������� �����������';
  sInitMacrosSystem = '������������� ������� ��������';
  sLoadingExplorer = '�������� �������������';
  sLoadingDesktop = '�������� �������� �����';
  sItisAll = '�������� ���������';
  sInventoryDocumentDontFound = '��������� �������� �� ������!';

  sEntryNotFound = 
    '�������� �� ������� � ������� ������������� ��������.'#13#10 +
    '��������, � ������ ��������� ���������� ��� ����������� ����� �� ��������.';

implementation

end.