unit kbmMemResDan;

interface

const
  kbmMasterlinkErr = 'Antallet af masterfelter passer ikke med antallet af indexfelter.';
  kbmSelfRef = 'Selvrefererende master/detail relationer er ikke tilladt.';
  kbmFindNearestErr = 'Kan ikke udføre FindNearest på ikke sorterede data.';
  kbminternalOpen1Err = 'Fielddef ';
  kbminternalOpen2Err = ' Datatype %d ej supporteret.)';
  kbmReadOnlyErr = 'Felt %s er skrivebeskyttet';
  kbmVarArrayErr = 'Values variant array er forkert dimensioneret';
  kbmVarReason1Err = 'Flere felter end værdier';
  kbmVarReason2Err = 'Der skal være mindst et felt';
  kbmBookmErr = 'Bookmark %d ej fundet.';
  kbmUnknownFieldErr1 = 'Ukendt felt type (%s)';
  kbmUnknownFieldErr2 = ' i CSV filen. (%s)';
  kbmIndexErr = 'Kan ikke sætte indeks på felt %s';
  kbmEditModeErr = 'Datasættet er ikke i edit tilstand.';
  kbmDatasetRemoveLockedErr = 'Datasættet forsøges slettet mens det er låst.';
  kbmSetDatasetLockErr = 'Datasættet er låst og kan ikke ændres.';
  kbmOutOfBookmarks = 'Bookmark tæller er blevet for stor. Luk og genåbn venligst tabellen.';
  kbmIndexNotExist = 'Indeks %s eksisterer ikke';
  kbmKeyFieldsChanged = 'Kunne ikke udføre handling eftersom nøgle felter er ændret.';
  kbmDupIndex = 'Duplikeret indeks værdi. Handling afbrudt.';
  kbmMissingNames = 'Manglende Name eller FieldNames i IndexDef!';
  kbmInvalidRecord = 'Ødelagt række ';
  kbmTransactionVersioning = 'Transaktionsstyring har brug for fler versions versionering.';
  kbmNoCurrentRecord = 'Ingen nuværende række.';
  kbmCantAttachToSelf = 'Kan ikke hægte memorytabellen på den selv.';
  kbmCantAttachToSelf2 = 'Kan ikke hægte på en anden tabel som selv er påhægtet.';
  kbmUnknownOperator = 'Ukendt operator (%d)';
  kbmUnknownFieldType = 'Ukendt felttype (%d)';
  kbmOperatorNotSupported = 'Operator ikke supporteret (%d).';
  kbmSavingDeltasBinary = 'Deltaer kan kun gemmes i binært format.';
  kbmCantCheckpointAttached = 'Kan ikke udføre checkpoint på påhægtet tabel.';
  kbmDeltaHandlerAssign = 'Delta håndtering er ikke tilknyttet nogen memorytabel.';
  kbmOutOfRange = 'Uden for grænser (%d)';
  kbmInvArgument = 'Ulovligt argument.';
  kbmInvOptions = 'Ulovlige optioner.';
  kbmTableMustBeClosed = 'Tabellen skal være lukket for denne operation.';
  kbmInvFunction = 'Ukendt funktions navn %s';
  kbmInvMissParam = 'Ukendt eller manglende argument for funktionen %s';
  kbmNoFormat = 'Format ej specificeret.';
  kbmTooManyFieldDefs = 'Der er for mange felt definitioner. Forøg venligst KBM_MAX_FIELDS.';
  kbmCannotMixAppendStructure = 'Kan ikke både appende og kopier struktur.';

implementation


end.
