unit kbmMemResGer;

interface

const
  kbmMasterlinkErr = 'Die Anzahl der Hauptfelder stimmt nicht mit der Anzahl der Detailfelder überein.';
  kbmSelfRef = 'Zirkuläre Datenverbindungen sind nicht erlaubt.';
  kbmFindNearestErr = 'FindNearest kann bei nicht-sortierten Daten nicht ausgeführt werden .';
  kbminternalOpen1Err = 'Felddefinition ';
  kbminternalOpen2Err = ' Datentyp %d nicht unterstützt.)';
  kbmReadOnlyErr = 'Feld %s ist als schreibgeschützt markiert';
  kbmVarArrayErr = 'Das Varianten-Array hat eine ungültige Dimensionierung';
  kbmVarReason1Err = 'Mehr Felder als Werte';
  kbmVarReason2Err = 'Sie müssen mindestens ein Feld angeben';
  kbmBookmErr = 'Lesezeichen %d nicht gefunden.';
  kbmUnknownFieldErr1 = 'Unbekannter Feldtyp (%s)';
  kbmUnknownFieldErr2 = ' in der CSV Datei. (%s)';
  kbmIndexErr = 'Kann Index für das Feld %s nicht erzeugen';
  kbmEditModeErr = 'Datensatz nicht im Editiermodus.';
  
  kbmDatasetRemoveLockedErr = 'Dataset being removed while locked.';
  kbmSetDatasetLockErr = 'Dataset is locked and cant be changed.';
  kbmOutOfBookmarks = 'Bookmark counter is out of range. Please close and reopen table.';
  kbmIndexNotExist = 'Index %s does not exist';
  kbmKeyFieldsChanged = 'Could''nt perform operation since key fields changed.';
  kbmDupIndex = 'Duplicate index value. Operation aborted.';
  kbmMissingNames = 'Missing Name or FieldNames in IndexDef!';
  kbmInvalidRecord = 'Invalid record ';
  kbmTransactionVersioning = 'Transactioning requires multiversion versioning.';
  kbmNoCurrentRecord = 'No current record.';
  kbmCantAttachToSelf = 'Cant attach memorytable to it self.';
  kbmCantAttachToSelf2 = 'Cant attach to another table which itself is an attachment.';
  kbmUnknownOperator = 'Unknown operator (%d)';
  kbmUnknownFieldType = 'Unknown fieldtype (%d)';
  kbmOperatorNotSupported = 'Operator not supported (%d).';
  kbmSavingDeltasBinary = 'Saving deltas is supported only in binary format.';
  kbmCantCheckpointAttached = 'Cannot checkpoint attached table.';
  kbmDeltaHandlerAssign = 'Delta handler is not assigned to any memorytables.';
  kbmOutOfRange = 'Out of range (%d)';
  kbmInvArgument = 'Invalid argument.';
  kbmInvOptions = 'Invalid options.';
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
