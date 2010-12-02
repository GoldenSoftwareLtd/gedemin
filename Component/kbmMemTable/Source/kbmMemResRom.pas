unit kbmMemResRom;

interface

const
  kbmMasterlinkErr = 'Num�rul de c�mpuri master nu corespunde num�rului de c�mpuri indexate.';
  kbmSelfRef = 'Operatiile master/detail auto-referite nu sunt permise.';
  kbmFindNearestErr = 'Nu se poate executa FindNearest asupra unor date nesortate.';
  kbminternalOpen1Err = 'Fielddef ';
  kbminternalOpen2Err = ' Tipul de date %d nu este implementat.)';
  kbmReadOnlyErr = 'C�mpul %s poate fi doar citit';
  kbmVarArrayErr = 'Valorile vectorului Variant au o dimensiune nepermis�';
  kbmVarReason1Err = 'Exist� mai multe c�mpuri dec�t valori';
  kbmVarReason2Err = 'Trebuie s� existe cel putin un c�mp';
  kbmBookmErr = 'Punctul de �ntoarcere %d nu exist�.';
  kbmUnknownFieldErr1 = 'Tipul c�mpului este necunoscut (%s)';
  kbmUnknownFieldErr2 = ' �n fisierul CSV. (%s)';
  kbmIndexErr = 'Nu se poate indexa c�mpul %s';
  kbmEditModeErr = 'Setul de date nu este �n modul editare.';
  kbmDatasetRemoveLockedErr = 'Nu se poate sterge setul de date at�t timp c�t este blocat.';
  kbmSetDatasetLockErr = 'Setul de date este blocat si nu poate fi schimbat.';
  kbmOutOfBookmarks = 'Numar de punct de �ntoarcere in afara intervalului. V� rog inchideti si redeschideti tabela.';
  kbmIndexNotExist = 'Indexul %s nu exist�';
  kbmKeyFieldsChanged = 'Nu s-a putut executa operatia deoarece c�mpurile cheie s-au modificat.';
  kbmDupIndex = 'Valoare de index duplicat�. Operatiunea a fost oprit�.';
  kbmMissingNames = 'Lipseste Name sau FieldNames �n IndexDef!';
  kbmInvalidRecord = 'Inregistrare invalid� ';
  kbmTransactionVersioning = 'Transactionarea necesit� multiversion versioning.';
  kbmNoCurrentRecord = 'Nici o �nregistrare curent�.';
  kbmCantAttachToSelf = 'Nu pot atasa o tabela in memorie la ea �ns�si.';
  kbmCantAttachToSelf2 = 'Nu pot atasa la o alta tabela care este tot o tabela atasat�.';
  kbmUnknownOperator = 'Operator necunoscut (%d)';
  kbmUnknownFieldType = 'Tip de camp necunoscut (%d)';
  kbmOperatorNotSupported = 'Operatorul nu este suportat (%d).';
  kbmSavingDeltasBinary = 'Salvare delta este suportat� doar in format binar.';
  kbmCantCheckpointAttached = 'Nu pot verifica tabela atasat�.';
  kbmDeltaHandlerAssign = 'Delta handler nu este atribuit nici unei tabele �n memorie.';
  kbmOutOfRange = 'In afara intervalului (%d)';
  kbmInvArgument = 'Argument invalid.';
  kbmInvOptions = 'Optiuni invalide.';
  kbmTableMustBeClosed = 'Tabela trebuie sa fie inchisa pentru aceast� operatie.';
  kbmInvFunction = 'Nume de functie invalid %s';
  kbmInvMissParam = 'Parametru invalid sau lipseste pentru functia %s';
  kbmNoFormat = 'Nu este specificat nici un format.';
  kbmTooManyFieldDefs = 'Prea multe definitii de c�mpuri. Incrementati valoarea parametrului KBM_MAX_FIELDS.';

  kbmCannotMixAppendStructure = 'Cannot both append and copy structure.';

implementation


end.
