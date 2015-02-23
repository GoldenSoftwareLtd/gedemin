unit kbmMemResSky;

interface

const
  kbmMasterlinkErr = 'Po�et nadriaden�ch [master] pol� nezodpoved� po�tu indexov�ch pol� !';
  kbmSelfRef = 'Vz�ah master/detail do tej istej tabu�ky nie je povolen� !';
  kbmFindNearestErr = 'Funkcia h�adania [FindNearest] sa ned� pou�i� na netrieden� d�ta !';
  kbminternalOpen1Err = 'Defin�cia po�a ';
  kbminternalOpen2Err = 'D�tov� typ %d nie je podporovan� !)';
  kbmReadOnlyErr = 'Pole %s je len na ��tanie !';
  kbmVarArrayErr = 'Pole [variant] hodn�t m� neplatn� dimenzie !';
  kbmVarReason1Err = 'Je viac pol� ako hodn�t !';
  kbmVarReason2Err = 'Mus� by� najmenej jedno pole !';
  kbmBookmErr = 'Z�lo�ku %d sa nepodarilo n�js� !';
  kbmUnknownFieldErr1 = 'Nezn�my typ po�a (%s)';
  kbmUnknownFieldErr2 = ' v CSV s�bore. (%s)';
  kbmIndexErr = 'Ned� sa indexova� pole %s !';
  kbmEditModeErr = 'D�tov� s�bor nie v re�ime edit�cie !';
  kbmDatasetRemoveLockedErr = 'D�tov� s�bor bol odstr�nen� po�as uzmaknutia.';
  kbmSetDatasetLockErr = 'D�tov� s�bor je uzamknut� a ned� sa zmeni� !';
  kbmOutOfBookmarks = 'Po��tadlo z�lo�iek ja mimo rozsah. Pros�m, zatvorte a znova otvorte tabu�ku.';
  kbmIndexNotExist = 'Index %s neexistuje !';
  kbmKeyFieldsChanged = 'Nie je mo�n� vykona� oper�ciu, preto�e boli zmenen� k���ov� polia !';
  kbmDupIndex = 'Duplicitn� hodnota indexu. Oper�cia je preru�en� !';
  kbmMissingNames = 'V defin�cii indexov [IndexDef] ch�ba hodnota polo�ky [Name] alebo [FieldNames] !';
  kbmInvalidRecord = 'Neplatn� z�znam ';
  kbmTransactionVersioning = 'Pou�itie transakci� vy�aduje multiverzie !';
  kbmNoCurrentRecord = '�iadny aktu�lny z�znam.';
  kbmCantAttachToSelf = 'Pam�ov� tabu�ka sa ned� pripoji� sama na seba !';
  kbmCantAttachToSelf2 = 'Ned� sa prepoji� na tabu�ku, ktor� sama vznikla prepojen�m !';
  kbmUnknownOperator = 'Nezn�my oper�tor (%d)';
  kbmUnknownFieldType = 'Nezn�my typ po�a (%d)';
  kbmOperatorNotSupported = 'Oper�tor nie je podporovan� (%d).';
  kbmSavingDeltasBinary = 'Ukladanie zmien je mo�n� len v bin�rnom form�te !';
  kbmCantCheckpointAttached = 'V prepojenej tabu�ke nie je mo�n� monitorova� zmeny !';
  kbmDeltaHandlerAssign = 'K �iadnej pam�ovej tabu�ke nie je priraden� proced�ra na spracovanie zmien !';
  kbmOutOfRange = 'Mimo platn� rozsah (%d)';
  kbmInvArgument = 'Neplatn� argument !';
  kbmInvOptions = 'Neplatn� nastavenie !';
  kbmTableMustBeClosed = 'Pred touto oper�ciou mus� by� tabu�ka uzavret� !';
  kbmChildrenAttached = 'Na t�to tabu�ku s� pripojen� podriaden� tabu�ky !';
  kbmIsAttached = 'Tabu�ka je pripojen� k inej tabu�ke !';
  kbmInvalidLocale = 'Neplatn� miesto [locale] !';
  kbmInvFunction = 'Funkcia %s : neplatn� meno funkcie !';
  kbmInvMissParam = 'Funkcia %s : parameter je neplatn� alebo ch�ba !';

  kbmNoFormat = 'No format specified.';
  kbmTooManyFieldDefs = 'Too many fielddefs. Please raise KBM_MAX_FIELDS value.';
  kbmCannotMixAppendStructure = 'Cannot both append and copy structure.';
  
implementation


end.
