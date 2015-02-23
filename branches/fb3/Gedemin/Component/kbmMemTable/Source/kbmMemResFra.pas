unit kbmMemResFra;

interface

const
  kbmMasterlinkErr = 'Le nombre de champs ma�tres ne correspond pas au nombre de champs de l''index.';
  kbmSelfRef = 'R�f�rence circulaire dans une relation ma�tre/d�tail non autoris�e.';
  kbmFindNearestErr = 'Ne peux effectuer une recherche par approximation (FindNearest) sur des donn�es non tri�es.';
  kbminternalOpen1Err = 'D�finition de champ ';
  kbminternalOpen2Err = 'Type de donn�e "%d" n''est pas support�.)';
  kbmReadOnlyErr = 'Le champ %s est en lecture seule';
  kbmVarArrayErr = 'Mauvais nombre de dimension d''un tableau Variant';
  kbmVarReason1Err = 'Plus de champs que de valeurs';
  kbmVarReason2Err = 'Il doit y avoir au moins un champ';
  kbmBookmErr = 'Marqueur %d non trouv�.';
  kbmUnknownFieldErr1 = 'Type de champ inconnu (%s)';
  kbmUnknownFieldErr2 = ' dans le fichier CSV. (%s)';
  kbmIndexErr = 'Ne peux indexer sur le champ %s';
  kbmEditModeErr = 'L''ensemble de donn�es n''est pas en mode �dition.';
  kbmDatasetRemoveLockedErr = 'Suppression de l''ensemble de donn�es durant un Lock.';
  kbmSetDatasetLockErr = 'Ensemble de donn�es prot�g� (Lock). Modifications rejet�es.';
  kbmOutOfBookmarks = 'Le Compteur de marques est satur�. Fermez puis r�ouvrez la table.';
  kbmIndexNotExist = 'L''Index %s n''existe pas';
  kbmKeyFieldsChanged = 'Op�ration refus�e : les champs de la cl� ont �t� modifi�s.';
  kbmDupIndex = 'Op�ration refus�e : cr�ation d''un doublon dans l''index.';

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
