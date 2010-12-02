unit kbmMemResHun;

interface

const
  kbmMasterlinkErr = 'A master mezõk száma nem egyezik meg az index mezõk számával.';
  kbmSelfRef = 'Az önmagukra hivatkozó master/detail relációk nem megengedettek.';
  kbmFindNearestErr = 'Rendezetlen adatokon nem lehet FindNearest-et futtatni.';
  kbminternalOpen1Err = 'Fielddef ';
  kbminternalOpen2Err = ' A(z) %d adattípus nem támogatott.)';
  kbmReadOnlyErr = 'A(z) %s mezõ írásvédett.';
  kbmVarArrayErr = 'A Values variant tömb dimenziószáma invalid';
  kbmVarReason1Err = 'Több mezõ, mint érték';
  kbmVarReason2Err = 'Legalább egy mezõnek lennie kell';
  kbmBookmErr = 'A(z) %d bookmark nem található.';
  kbmUnknownFieldErr1 = 'Ismeretlen mezõtípus (%s)';
  kbmUnknownFieldErr2 = ' a CSV file-ban. (%s)';
  kbmIndexErr = 'Nem lehet indexelni a(z) %s mezõt';
  kbmEditModeErr = 'A dataset nincs Edit módban.';
  kbmDatasetRemoveLockedErr = 'A dataset el lett távolítva míg lockolva volt.';
  kbmSetDatasetLockErr = 'A dataset lockolva van, ezért nem lehet megváltoztatni.';
  kbmOutOfBookmarks = 'Túl sok bookmark. Zárja be és nyissa újra a táblát.';
  kbmIndexNotExist = 'A(z) %s index nem létezik';
  kbmKeyFieldsChanged = 'Ez a mûvelet nem megengedett, mivel a kulcs-mezõ megváltozott.';
  kbmDupIndex = 'Duplikált érték az indexben. Mûvelet leállítva.';
  kbmMissingNames = 'Hiányzó Name, vagy FieldName az IndexDef-ben!';
  kbmInvalidRecord = 'Invalid rekord ';
  kbmTransactionVersioning = 'A tranzakcióhoz szükséges a multiversion verzió nyilvántartás.';
  kbmNoCurrentRecord = 'Nincs aktuális rekord.';
  kbmCantAttachToSelf = 'Nem lehet a memória táblát magához csatolni.';
  kbmCantAttachToSelf2 = 'Nem lehet egy már csatolt táblához csatolni.';
  kbmUnknownOperator = 'Ismeretlen operátor (%d)';
  kbmUnknownFieldType = 'Ismeretlen mezõtípus (%d)';
  kbmOperatorNotSupported = 'Az operátor nem támogatott (%d).';
  kbmSavingDeltasBinary = 'A különbségeket csak bináris formában lehet kimenteni.';
  kbmCantCheckpointAttached = 'A csatolt táblára nem lehet Checkpoint-ot létrehozni.';
  kbmDeltaHandlerAssign = 'A Delta Handler-t nem lehet minden memória táblához kötni.';
  kbmOutOfRange = 'Túl van a határon (%d)';
  kbmInvArgument = 'Invalid paraméter.';
  kbmInvOptions = 'Invalid opció.';
  kbmTableMustBeClosed = 'Ennek végrehajtásához be kell zárni a táblát.';

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
