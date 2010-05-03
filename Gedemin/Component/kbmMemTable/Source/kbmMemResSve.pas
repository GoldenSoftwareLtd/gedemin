unit kbmMemResSve;

interface

const
  kbmMasterlinkErr = 'Antalet master-fält överensstämmer inte med antalet index-fält.';
  kbmSelfRef = 'Självrefererande master/detail-relationer är inte tillåtna.';
  kbmFindNearestErr = 'Kan inte utföra FindNearest på osorterade data.';
  kbminternalOpen1Err = 'Fielddef ';
  kbminternalOpen2Err = ' Saknar stöd för Datatyp %d.)';
  kbmReadOnlyErr = 'Fält %s är skrivskyddat';
  kbmVarArrayErr = 'Values variant array är felaktigt dimensionerad';
  kbmVarReason1Err = 'Fler fält än värden';
  kbmVarReason2Err = 'Det måste finnas minst ett fält.';
  kbmBookmErr = 'Bookmark %d kunde inte hittas.';
  kbmUnknownFieldErr1 = 'Okänd fält-typ (%s)';
  kbmUnknownFieldErr2 = ' i CSV filen. (%s)';
  kbmIndexErr = 'Kan inte sätta index på fält %s';
  kbmEditModeErr = 'Datamängden är inte i edit-läge.';
  kbmDatasetRemoveLockedErr = 'Datamängden håller på att tas bort medan den är låst.';
  kbmSetDatasetLockErr = 'Datamängden är låst och kan inte ändras.';
  kbmOutOfBookmarks = 'Bookmark-räknaren har blivit för stor. Vänligen stäng och öppna tabellen igen.';
  kbmIndexNotExist = 'Index %s existerar inte';
  kbmKeyFieldsChanged = 'Kunde inte utföra åtgärden eftersom några fält ändrats.';
  kbmDupIndex = 'Minst ett av index-värdena förekommer mer än en gång. Åtgärden avbryts.';
  kbmMissingNames = 'Det saknas Name eller FieldNames i IndexDef!';
  kbmInvalidRecord = 'Ogiltig post ';
  kbmTransactionVersioning = 'Transaktionsstyrning kräver multiversion-versionering.';
  kbmNoCurrentRecord = 'Ingen nuvarande post.';
  kbmCantAttachToSelf = 'Memory-tabellen kan inte häktas på sig själv.';
  kbmCantAttachToSelf2 = 'Kan inte häkta på en påhäktad tabell.';
  kbmUnknownOperator = 'Okänd operator (%d)';
  kbmUnknownFieldType = 'Okänd fälttyp (%d)';
  kbmOperatorNotSupported = 'Operator ej stödd (%d).';
  kbmSavingDeltasBinary = 'Delta-paket kan endast sparas i binärt format.';
  kbmCantCheckpointAttached = 'Checkpoint kan inte utföras på en påhäktad tabell.';
  kbmDeltaHandlerAssign = 'Delta-hantering ej knuten till någon Memory-tabell.';
  kbmOutOfRange = 'Gränsvärde överskridet (%d)';
  kbmInvArgument = 'Ogiltigt argument.';
  kbmInvOptions = 'Ogilitiga alternativ.';
  kbmTableMustBeClosed = 'Tabellen måste stängas före denna operation.';
  kbmInvFunction = 'Okänt funktionsnamn %s';
  kbmInvMissParam = 'Minst ett argument för funktionen %s saknas eller är ogiltigt.';
  kbmNoFormat = 'Inget format angivet.';
  kbmTooManyFieldDefs = 'Antalet fält-definitioner är för stort. Vänligen öka KBM_MAX_FIELDS.';

  kbmCannotMixAppendStructure = 'Cannot both append and copy structure.';
implementation


end.
