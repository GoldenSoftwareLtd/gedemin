unit kbmMemResUkr;

interface

const
  kbmMasterlinkErr = '����� master-���� �� ������� ����� ��������� ����.';
  kbmSelfRef = '����������� ��������, �� ���������������, master/detail.';
  kbmFindNearestErr = 'FindNearest ����������� ��� �� ������������ �����.';
  kbminternalOpen1Err = '���������� ���� ';
  kbminternalOpen2Err = ' ��� ����� %d �� �����������.)';
  kbmReadOnlyErr = '���� %s ����� ��� �������';
  kbmVarArrayErr = '����� ����� variant �� ������������ ���������';
  kbmVarReason1Err = '���� �����, �� �����';
  kbmVarReason2Err = '������� ���� �������� ���� ����';
  kbmBookmErr = '�������� %d �� ��������.';
  kbmUnknownFieldErr1 = '�������� ��� ���� (%s)';
  kbmUnknownFieldErr2 = ' � ���� CSV (%s).';
  kbmIndexErr = '������������� ������ ��� ���� %s';
  kbmEditModeErr = '������� �� � ����� �����������.';
  kbmDatasetRemoveLockedErr = '������ �������� ������� ���� ���� �����������';
  kbmSetDatasetLockErr = '������� ����������� � �� ���� ���� ������.';
  kbmOutOfBookmarks = '˳������� �������� ���� ����������� ���������. �������� � ����� �������� �������.';
  kbmIndexNotExist = '������ %s �� ����';
  kbmKeyFieldsChanged = '�� ���� �������� �������� ����� ���� ��������� ����.';
  kbmDupIndex = '���������� �������� �������. �������� ���������.';
  kbmMissingNames = '��������� Name �� FieldNames � IndexDef!';
  kbmInvalidRecord = '����������� ����� ';
  kbmTransactionVersioning = '�������������� ������ ��������������� ������������.';
  kbmNoCurrentRecord = '���� ��������� ������.';
  kbmCantAttachToSelf = '�� ���� ��������� �������-�-���''�� ���� �� ����.';
  kbmCantAttachToSelf2 = '�� ���� ����������� �� ���� �������, �� ���� ��� ���������.';
  kbmUnknownOperator = '�������� �������� (%d)';
  kbmUnknownFieldType = '�������� ��� ������ (%d)';
  kbmOperatorNotSupported = '�������� �� ����������� (%d).';
  kbmSavingDeltasBinary = '���������� ����� ����������� ����� � �������� ������.';
  kbmCantCheckpointAttached = '��������� �������������� � �������, �� ��� �����������.';
  kbmDeltaHandlerAssign = '���������� ����� �� ����������� � ���� �������-�-���''��.';
  kbmOutOfRange = '���� ��������� (%d)';
  kbmInvArgument = '����������� ��������.';
  kbmInvOptions = '���������� �����.';

  kbmTableMustBeClosed = 'Table must be closed for this operation.';
  kbmChildrenAttached = 'Children are attached to this table.';
  kbmIsAttached = 'Table is attached to another table.';
  kbmInvalidLocale = 'Invalid locale.';
  kbmInvFunction = 'Invalid function name %s';
  kbmInvMissParam = 'Invalid or missing parameter for function %s';
  kbmNoFormat = 'No format specified.';
  kbmTooManyFieldDefs = 'Too many fielddefs. Please raise KBM_MAX_FIELDS value.';
  kbmCannotMixAppendStructure = 'Cannot both append and copy structure.';

implementation


end.
