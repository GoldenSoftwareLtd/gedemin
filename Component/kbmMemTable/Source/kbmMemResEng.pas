unit kbmMemResEng;

interface

const
  kbmMasterlinkErr = 'Number of masterfields doesn''t correspond to number of indexfields.';
  kbmSelfRef = 'Selfreferencing master/detail relations not allowed.';
  kbmFindNearestErr = 'Can''t do FindNearest on non sorted data.';
  kbminternalOpen1Err = 'Fielddef ';
  kbminternalOpen2Err = ' Datatype %d not supported.';
  kbmReadOnlyErr = 'Field %s is read only';
  kbmVarArrayErr = 'Values variant array has invalid dimension count';
  kbmVarReason1Err = 'More fields than values';
  kbmVarReason2Err = 'There must be at least one field';
  kbmBookmErr = 'Bookmark %d not found.';
  kbmUnknownFieldErr1 = 'Unknown field type (%s)';
  kbmUnknownFieldErr2 = ' in CSV file. (%s)';
  kbmIndexErr = 'Can''t index on field %s';
  kbmEditModeErr = 'Dataset is not in edit mode.';
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

