unit kbmMemResDan;

interface

const
  kbmMasterlinkErr = 'Antallet af masterfelter passer ikke med antallet af indexfelter.';
  kbmSelfRef = 'Selvrefererende master/detail relationer er ikke tilladt.';
  kbmFindNearestErr = 'Kan ikke udf�re FindNearest p� ikke sorterede data.';
  kbminternalOpen1Err = 'Fielddef ';
  kbminternalOpen2Err = ' Datatype %d ej supporteret.)';
  kbmReadOnlyErr = 'Felt %s er skrivebeskyttet';
  kbmVarArrayErr = 'Values variant array er forkert dimensioneret';
  kbmVarReason1Err = 'Flere felter end v�rdier';
  kbmVarReason2Err = 'Der skal v�re mindst et felt';
  kbmBookmErr = 'Bookmark %d ej fundet.';
  kbmUnknownFieldErr1 = 'Ukendt felt type (%s)';
  kbmUnknownFieldErr2 = ' i CSV filen. (%s)';
  kbmIndexErr = 'Kan ikke s�tte indeks p� felt %s';
  kbmEditModeErr = 'Datas�ttet er ikke i edit tilstand.';
  kbmDatasetRemoveLockedErr = 'Datas�ttet fors�ges slettet mens det er l�st.';
  kbmSetDatasetLockErr = 'Datas�ttet er l�st og kan ikke �ndres.';
  kbmOutOfBookmarks = 'Bookmark t�ller er blevet for stor. Luk og gen�bn venligst tabellen.';
  kbmIndexNotExist = 'Indeks %s eksisterer ikke';
  kbmKeyFieldsChanged = 'Kunne ikke udf�re handling eftersom n�gle felter er �ndret.';
  kbmDupIndex = 'Duplikeret indeks v�rdi. Handling afbrudt.';
  kbmMissingNames = 'Manglende Name eller FieldNames i IndexDef!';
  kbmInvalidRecord = '�delagt r�kke ';
  kbmTransactionVersioning = 'Transaktionsstyring har brug for fler versions versionering.';
  kbmNoCurrentRecord = 'Ingen nuv�rende r�kke.';
  kbmCantAttachToSelf = 'Kan ikke h�gte memorytabellen p� den selv.';
  kbmCantAttachToSelf2 = 'Kan ikke h�gte p� en anden tabel som selv er p�h�gtet.';
  kbmUnknownOperator = 'Ukendt operator (%d)';
  kbmUnknownFieldType = 'Ukendt felttype (%d)';
  kbmOperatorNotSupported = 'Operator ikke supporteret (%d).';
  kbmSavingDeltasBinary = 'Deltaer kan kun gemmes i bin�rt format.';
  kbmCantCheckpointAttached = 'Kan ikke udf�re checkpoint p� p�h�gtet tabel.';
  kbmDeltaHandlerAssign = 'Delta h�ndtering er ikke tilknyttet nogen memorytabel.';
  kbmOutOfRange = 'Uden for gr�nser (%d)';
  kbmInvArgument = 'Ulovligt argument.';
  kbmInvOptions = 'Ulovlige optioner.';
  kbmTableMustBeClosed = 'Tabellen skal v�re lukket for denne operation.';
  kbmInvFunction = 'Ukendt funktions navn %s';
  kbmInvMissParam = 'Ukendt eller manglende argument for funktionen %s';
  kbmNoFormat = 'Format ej specificeret.';
  kbmTooManyFieldDefs = 'Der er for mange felt definitioner. For�g venligst KBM_MAX_FIELDS.';
  kbmCannotMixAppendStructure = 'Kan ikke b�de appende og kopier struktur.';

implementation


end.
