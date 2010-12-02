unit kbmMemResSky;

interface

const
  kbmMasterlinkErr = 'Poèet nadriadenıch [master] polí nezodpovedá poètu indexovıch polí !';
  kbmSelfRef = 'Vzah master/detail do tej istej tabu¾ky nie je povolenı !';
  kbmFindNearestErr = 'Funkcia h¾adania [FindNearest] sa nedá poui na netriedené dáta !';
  kbminternalOpen1Err = 'Definícia po¾a ';
  kbminternalOpen2Err = 'Dátovı typ %d nie je podporovanı !)';
  kbmReadOnlyErr = 'Pole %s je len na èítanie !';
  kbmVarArrayErr = 'Pole [variant] hodnôt má neplatné dimenzie !';
  kbmVarReason1Err = 'Je viac polí ako hodnôt !';
  kbmVarReason2Err = 'Musí by najmenej jedno pole !';
  kbmBookmErr = 'Záloku %d sa nepodarilo nájs !';
  kbmUnknownFieldErr1 = 'Neznámy typ po¾a (%s)';
  kbmUnknownFieldErr2 = ' v CSV súbore. (%s)';
  kbmIndexErr = 'Nedá sa indexova pole %s !';
  kbmEditModeErr = 'Dátovı súbor nie v reime editácie !';
  kbmDatasetRemoveLockedErr = 'Dátovı súbor bol odstránenı poèas uzmaknutia.';
  kbmSetDatasetLockErr = 'Dátovı súbor je uzamknutı a nedá sa zmeni !';
  kbmOutOfBookmarks = 'Poèítadlo záloiek ja mimo rozsah. Prosím, zatvorte a znova otvorte tabu¾ku.';
  kbmIndexNotExist = 'Index %s neexistuje !';
  kbmKeyFieldsChanged = 'Nie je moné vykona operáciu, pretoe boli zmenené k¾úèové polia !';
  kbmDupIndex = 'Duplicitná hodnota indexu. Operácia je prerušená !';
  kbmMissingNames = 'V definícii indexov [IndexDef] chıba hodnota poloky [Name] alebo [FieldNames] !';
  kbmInvalidRecord = 'Neplatnı záznam ';
  kbmTransactionVersioning = 'Pouitie transakcií vyaduje multiverzie !';
  kbmNoCurrentRecord = 'iadny aktuálny záznam.';
  kbmCantAttachToSelf = 'Pamäová tabu¾ka sa nedá pripoji sama na seba !';
  kbmCantAttachToSelf2 = 'Nedá sa prepoji na tabu¾ku, ktorá sama vznikla prepojením !';
  kbmUnknownOperator = 'Neznámy operátor (%d)';
  kbmUnknownFieldType = 'Neznámy typ po¾a (%d)';
  kbmOperatorNotSupported = 'Operátor nie je podporovanı (%d).';
  kbmSavingDeltasBinary = 'Ukladanie zmien je moné len v binárnom formáte !';
  kbmCantCheckpointAttached = 'V prepojenej tabu¾ke nie je moné monitorova zmeny !';
  kbmDeltaHandlerAssign = 'K iadnej pamäovej tabu¾ke nie je priradená procedúra na spracovanie zmien !';
  kbmOutOfRange = 'Mimo platnı rozsah (%d)';
  kbmInvArgument = 'Neplatnı argument !';
  kbmInvOptions = 'Neplatné nastavenie !';
  kbmTableMustBeClosed = 'Pred touto operáciou musí by tabu¾ka uzavretá !';
  kbmChildrenAttached = 'Na túto tabu¾ku sú pripojené podriadené tabu¾ky !';
  kbmIsAttached = 'Tabu¾ka je pripojená k inej tabu¾ke !';
  kbmInvalidLocale = 'Neplatné miesto [locale] !';
  kbmInvFunction = 'Funkcia %s : neplatné meno funkcie !';
  kbmInvMissParam = 'Funkcia %s : parameter je neplatnı alebo chıba !';

  kbmNoFormat = 'No format specified.';
  kbmTooManyFieldDefs = 'Too many fielddefs. Please raise KBM_MAX_FIELDS value.';
  kbmCannotMixAppendStructure = 'Cannot both append and copy structure.';
  
implementation


end.
