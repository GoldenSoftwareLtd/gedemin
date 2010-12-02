unit kbmMemResHun;

interface

const
  kbmMasterlinkErr = 'A master mez�k sz�ma nem egyezik meg az index mez�k sz�m�val.';
  kbmSelfRef = 'Az �nmagukra hivatkoz� master/detail rel�ci�k nem megengedettek.';
  kbmFindNearestErr = 'Rendezetlen adatokon nem lehet FindNearest-et futtatni.';
  kbminternalOpen1Err = 'Fielddef ';
  kbminternalOpen2Err = ' A(z) %d adatt�pus nem t�mogatott.)';
  kbmReadOnlyErr = 'A(z) %s mez� �r�sv�dett.';
  kbmVarArrayErr = 'A Values variant t�mb dimenzi�sz�ma invalid';
  kbmVarReason1Err = 'T�bb mez�, mint �rt�k';
  kbmVarReason2Err = 'Legal�bb egy mez�nek lennie kell';
  kbmBookmErr = 'A(z) %d bookmark nem tal�lhat�.';
  kbmUnknownFieldErr1 = 'Ismeretlen mez�t�pus (%s)';
  kbmUnknownFieldErr2 = ' a CSV file-ban. (%s)';
  kbmIndexErr = 'Nem lehet indexelni a(z) %s mez�t';
  kbmEditModeErr = 'A dataset nincs Edit m�dban.';
  kbmDatasetRemoveLockedErr = 'A dataset el lett t�vol�tva m�g lockolva volt.';
  kbmSetDatasetLockErr = 'A dataset lockolva van, ez�rt nem lehet megv�ltoztatni.';
  kbmOutOfBookmarks = 'T�l sok bookmark. Z�rja be �s nyissa �jra a t�bl�t.';
  kbmIndexNotExist = 'A(z) %s index nem l�tezik';
  kbmKeyFieldsChanged = 'Ez a m�velet nem megengedett, mivel a kulcs-mez� megv�ltozott.';
  kbmDupIndex = 'Duplik�lt �rt�k az indexben. M�velet le�ll�tva.';
  kbmMissingNames = 'Hi�nyz� Name, vagy FieldName az IndexDef-ben!';
  kbmInvalidRecord = 'Invalid rekord ';
  kbmTransactionVersioning = 'A tranzakci�hoz sz�ks�ges a multiversion verzi� nyilv�ntart�s.';
  kbmNoCurrentRecord = 'Nincs aktu�lis rekord.';
  kbmCantAttachToSelf = 'Nem lehet a mem�ria t�bl�t mag�hoz csatolni.';
  kbmCantAttachToSelf2 = 'Nem lehet egy m�r csatolt t�bl�hoz csatolni.';
  kbmUnknownOperator = 'Ismeretlen oper�tor (%d)';
  kbmUnknownFieldType = 'Ismeretlen mez�t�pus (%d)';
  kbmOperatorNotSupported = 'Az oper�tor nem t�mogatott (%d).';
  kbmSavingDeltasBinary = 'A k�l�nbs�geket csak bin�ris form�ban lehet kimenteni.';
  kbmCantCheckpointAttached = 'A csatolt t�bl�ra nem lehet Checkpoint-ot l�trehozni.';
  kbmDeltaHandlerAssign = 'A Delta Handler-t nem lehet minden mem�ria t�bl�hoz k�tni.';
  kbmOutOfRange = 'T�l van a hat�ron (%d)';
  kbmInvArgument = 'Invalid param�ter.';
  kbmInvOptions = 'Invalid opci�.';
  kbmTableMustBeClosed = 'Ennek v�grehajt�s�hoz be kell z�rni a t�bl�t.';

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
