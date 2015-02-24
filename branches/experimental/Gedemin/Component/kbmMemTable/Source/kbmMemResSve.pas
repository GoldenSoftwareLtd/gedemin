unit kbmMemResSve;

interface

const
  kbmMasterlinkErr = 'Antalet master-f�lt �verensst�mmer inte med antalet index-f�lt.';
  kbmSelfRef = 'Sj�lvrefererande master/detail-relationer �r inte till�tna.';
  kbmFindNearestErr = 'Kan inte utf�ra FindNearest p� osorterade data.';
  kbminternalOpen1Err = 'Fielddef ';
  kbminternalOpen2Err = ' Saknar st�d f�r Datatyp %d.)';
  kbmReadOnlyErr = 'F�lt %s �r skrivskyddat';
  kbmVarArrayErr = 'Values variant array �r felaktigt dimensionerad';
  kbmVarReason1Err = 'Fler f�lt �n v�rden';
  kbmVarReason2Err = 'Det m�ste finnas minst ett f�lt.';
  kbmBookmErr = 'Bookmark %d kunde inte hittas.';
  kbmUnknownFieldErr1 = 'Ok�nd f�lt-typ (%s)';
  kbmUnknownFieldErr2 = ' i CSV filen. (%s)';
  kbmIndexErr = 'Kan inte s�tta index p� f�lt %s';
  kbmEditModeErr = 'Datam�ngden �r inte i edit-l�ge.';
  kbmDatasetRemoveLockedErr = 'Datam�ngden h�ller p� att tas bort medan den �r l�st.';
  kbmSetDatasetLockErr = 'Datam�ngden �r l�st och kan inte �ndras.';
  kbmOutOfBookmarks = 'Bookmark-r�knaren har blivit f�r stor. V�nligen st�ng och �ppna tabellen igen.';
  kbmIndexNotExist = 'Index %s existerar inte';
  kbmKeyFieldsChanged = 'Kunde inte utf�ra �tg�rden eftersom n�gra f�lt �ndrats.';
  kbmDupIndex = 'Minst ett av index-v�rdena f�rekommer mer �n en g�ng. �tg�rden avbryts.';
  kbmMissingNames = 'Det saknas Name eller FieldNames i IndexDef!';
  kbmInvalidRecord = 'Ogiltig post ';
  kbmTransactionVersioning = 'Transaktionsstyrning kr�ver multiversion-versionering.';
  kbmNoCurrentRecord = 'Ingen nuvarande post.';
  kbmCantAttachToSelf = 'Memory-tabellen kan inte h�ktas p� sig sj�lv.';
  kbmCantAttachToSelf2 = 'Kan inte h�kta p� en p�h�ktad tabell.';
  kbmUnknownOperator = 'Ok�nd operator (%d)';
  kbmUnknownFieldType = 'Ok�nd f�lttyp (%d)';
  kbmOperatorNotSupported = 'Operator ej st�dd (%d).';
  kbmSavingDeltasBinary = 'Delta-paket kan endast sparas i bin�rt format.';
  kbmCantCheckpointAttached = 'Checkpoint kan inte utf�ras p� en p�h�ktad tabell.';
  kbmDeltaHandlerAssign = 'Delta-hantering ej knuten till n�gon Memory-tabell.';
  kbmOutOfRange = 'Gr�nsv�rde �verskridet (%d)';
  kbmInvArgument = 'Ogiltigt argument.';
  kbmInvOptions = 'Ogilitiga alternativ.';
  kbmTableMustBeClosed = 'Tabellen m�ste st�ngas f�re denna operation.';
  kbmInvFunction = 'Ok�nt funktionsnamn %s';
  kbmInvMissParam = 'Minst ett argument f�r funktionen %s saknas eller �r ogiltigt.';
  kbmNoFormat = 'Inget format angivet.';
  kbmTooManyFieldDefs = 'Antalet f�lt-definitioner �r f�r stort. V�nligen �ka KBM_MAX_FIELDS.';

  kbmCannotMixAppendStructure = 'Cannot both append and copy structure.';
implementation


end.
