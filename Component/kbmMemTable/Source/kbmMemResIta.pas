unit kbmMemResIta;

interface

const
  kbmMasterlinkErr = 'Il numero di campi principali non corrisponde a quello dei campi indice.';
  kbmSelfRef = 'Riferimento circolare non ammesso.';
  kbmFindNearestErr = 'Impossibile eseguire FindNearest su dati non ordinati.';
  kbminternalOpen1Err = 'Definizione Campo ';
  kbminternalOpen2Err = ' Tipo di dato %d non supportato.)';
  kbmReadOnlyErr = 'Il Campo %s � a sola lettura';
  kbmVarArrayErr = 'La matrice di valori variabili ha la dimensione errata';
  kbmVarReason1Err = 'Pi� campi rispetto ai valori';
  kbmVarReason2Err = 'Deve esserci almeno un campo';
  kbmBookmErr = 'Segnalibro %d non trovato.';
  kbmUnknownFieldErr1 = 'Tipo di campo sconosciuto (%s)';
  kbmUnknownFieldErr2 = ' nel file CSV. (%s)';
  kbmIndexErr = 'Impossibile indicizzare sul campo %s';
  kbmEditModeErr = 'Il dataset non � in modalit� di edit.';
  
  kbmDatasetRemoveLockedErr = 'Dataset being removed while locked.';
  kbmSetDatasetLockErr = 'L''archivio � lock e non pu� essere cambiato.';
  kbmOutOfBookmarks = 'L''indice Bookmark � out of range. Chiudere e riaprire la tabella.';
  kbmIndexNotExist = 'L''indice %s non esiste';
  kbmKeyFieldsChanged = 'Non posso effettuare l''operazione fino a quando i campi chiave non sono cambiati.';
  kbmDupIndex = 'Chiave duplicata. Operazione Fallita.';
  kbmMissingNames = 'Definire "Name" o "FieldNames" in IndexDef!';
  kbmInvalidRecord = 'Record Invalido ';
  kbmTransactionVersioning = 'La transazione richiede multiversion versioning.';
  kbmNoCurrentRecord = 'No record corrente.';
  kbmCantAttachToSelf = 'Impossibile collegare una memorytable a se stessa.';
  kbmCantAttachToSelf2 = 'Impossibile collegarsi ad una tabella che � a sua volta collegata a se stessa.';
  kbmUnknownOperator = 'Operatore Sconosciuto (%d)';
  kbmUnknownFieldType = 'Tipo di campo sconosciuto (%d)';
  kbmOperatorNotSupported = 'Operatore non sopportato (%d).';
  kbmSavingDeltasBinary = 'La registrazione dei delta � sopportata soltanto nel formato binario.';
  kbmCantCheckpointAttached = 'Impossibile controllare la tabella collegata.';
  kbmDeltaHandlerAssign = 'Il "Delta handler" non � assegnato a nessuna memorytables.';
  kbmOutOfRange = 'Out of range (%d)';
  kbmInvArgument = 'Argomento Invalido.';
  kbmInvOptions = 'Opzione non Valida.';
  kbmTableMustBeClosed = 'La Tabella deve essere chiusa per questa operazione.';
  kbmChildrenAttached = 'Figli collegati a questa tabella.';
  kbmIsAttached = 'La tabella � collegata ad un''altra tabella.';
  kbmInvalidLocale = 'Invalid locale.';
  kbmInvFunction = 'La funzione %s non � valida';
  kbmInvMissParam = 'Parametro non valido o mancante per la funzione %s';
  kbmNoFormat = 'Nessun formato specificato.';
  kbmTooManyFieldDefs = 'Sono stati definiti troppi campi. ( KBM_MAX_FIELDS ).';

  kbmCannotMixAppendStructure = 'Cannot both append and copy structure.';
implementation


end.
