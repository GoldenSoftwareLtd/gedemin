
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
    '��� ���������� ����� ��������� ��������� ��������� ������ %s.';
  s_InvErrorEditDocument =
    '� ���������� �������������� �������� ������ %s, ���������� ����� ���������';
  s_InvErrorSaveMovement =    
    '��� ������������ �������� �������� ����������� ������. ���������� ����� ���� ���������.';
  s_InvFullErrorSaveMovement =
    '��� ������������ �������� �������� ������������ ������: %s. ���������� ����� ���� ���������.';
  s_InvErrorChooseRemains = '������ ������� ������ ���, ��� �������.';
  
  sDBConnect = '���������� � ����� ������';
  sReadingDbScheme = '���������� ��������� ���� ������';
  sLoadingUserDefinedClasses = '�������� ������-�������';
  sSinchronizationAtRelations = '������������� ������';
  sReadingDomens = '���������� �������';
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

implementation

end.