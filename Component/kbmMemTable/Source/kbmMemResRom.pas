unit kbmMemResRom;

interface

const
  kbmMasterlinkErr = 'Numãrul de câmpuri master nu corespunde numãrului de câmpuri indexate.';
  kbmSelfRef = 'Operatiile master/detail auto-referite nu sunt permise.';
  kbmFindNearestErr = 'Nu se poate executa FindNearest asupra unor date nesortate.';
  kbminternalOpen1Err = 'Fielddef ';
  kbminternalOpen2Err = ' Tipul de date %d nu este implementat.)';
  kbmReadOnlyErr = 'Câmpul %s poate fi doar citit';
  kbmVarArrayErr = 'Valorile vectorului Variant au o dimensiune nepermisã';
  kbmVarReason1Err = 'Existã mai multe câmpuri decât valori';
  kbmVarReason2Err = 'Trebuie sã existe cel putin un câmp';
  kbmBookmErr = 'Punctul de întoarcere %d nu existã.';
  kbmUnknownFieldErr1 = 'Tipul câmpului este necunoscut (%s)';
  kbmUnknownFieldErr2 = ' în fisierul CSV. (%s)';
  kbmIndexErr = 'Nu se poate indexa câmpul %s';
  kbmEditModeErr = 'Setul de date nu este în modul editare.';
  kbmDatasetRemoveLockedErr = 'Nu se poate sterge setul de date atât timp cât este blocat.';
  kbmSetDatasetLockErr = 'Setul de date este blocat si nu poate fi schimbat.';
  kbmOutOfBookmarks = 'Numar de punct de întoarcere in afara intervalului. Vã rog inchideti si redeschideti tabela.';
  kbmIndexNotExist = 'Indexul %s nu existã';
  kbmKeyFieldsChanged = 'Nu s-a putut executa operatia deoarece câmpurile cheie s-au modificat.';
  kbmDupIndex = 'Valoare de index duplicatã. Operatiunea a fost opritã.';
  kbmMissingNames = 'Lipseste Name sau FieldNames în IndexDef!';
  kbmInvalidRecord = 'Inregistrare invalidã ';
  kbmTransactionVersioning = 'Transactionarea necesitã multiversion versioning.';
  kbmNoCurrentRecord = 'Nici o înregistrare curentã.';
  kbmCantAttachToSelf = 'Nu pot atasa o tabela in memorie la ea însãsi.';
  kbmCantAttachToSelf2 = 'Nu pot atasa la o alta tabela care este tot o tabela atasatã.';
  kbmUnknownOperator = 'Operator necunoscut (%d)';
  kbmUnknownFieldType = 'Tip de camp necunoscut (%d)';
  kbmOperatorNotSupported = 'Operatorul nu este suportat (%d).';
  kbmSavingDeltasBinary = 'Salvare delta este suportatã doar in format binar.';
  kbmCantCheckpointAttached = 'Nu pot verifica tabela atasatã.';
  kbmDeltaHandlerAssign = 'Delta handler nu este atribuit nici unei tabele în memorie.';
  kbmOutOfRange = 'In afara intervalului (%d)';
  kbmInvArgument = 'Argument invalid.';
  kbmInvOptions = 'Optiuni invalide.';
  kbmTableMustBeClosed = 'Tabela trebuie sa fie inchisa pentru aceastã operatie.';
  kbmInvFunction = 'Nume de functie invalid %s';
  kbmInvMissParam = 'Parametru invalid sau lipseste pentru functia %s';
  kbmNoFormat = 'Nu este specificat nici un format.';
  kbmTooManyFieldDefs = 'Prea multe definitii de câmpuri. Incrementati valoarea parametrului KBM_MAX_FIELDS.';

  kbmCannotMixAppendStructure = 'Cannot both append and copy structure.';

implementation


end.
