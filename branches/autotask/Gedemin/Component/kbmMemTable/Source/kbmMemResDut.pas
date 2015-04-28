unit kbmMemResDut;

interface

const
  kbmMasterlinkErr = 'Het aantal hoofdvelden correspondeert niet met het aantal indexvelden.';
  kbmSelfRef = 'Circulaire referenties in een master/detail-relatie zijn niet toegestaan.';
  kbmFindNearestErr = 'FindNearest is niet mogelijk op ongesorteerde data.';
  kbminternalOpen1Err = 'Velddef ';
  kbminternalOpen2Err = ' Datatype %d wordt niet ondersteund.)';
  kbmReadOnlyErr = 'Veld %s is alleen lezen';
  kbmVarArrayErr = 'De variant array heeft een ongeldige dimensie';
  kbmVarReason1Err = 'Het aantal velden is groter dan het aantal waarden';
  kbmVarReason2Err = 'Er dient minstens een veld opgegeven te zijn';
  kbmBookmErr = 'Bookmark %d niet gevonden.';
  kbmUnknownFieldErr1 = 'Onbekend veldtype (%s)';
  kbmUnknownFieldErr2 = ' in CSV bestand. (%s)';
  kbmIndexErr = 'Indexering op veld %s is niet mogelijk';
  kbmEditModeErr = 'Dataset is niet in wijzigmodus.';
  kbmDatasetRemoveLockedErr = 'Een geblokkeerde dataset kan niet verwijderd worden.';
  kbmSetDatasetLockErr = 'Dataset is geblokkeerd en kan niet gewijzigd worden.';
  kbmOutOfBookmarks = 'Bookmark teller is buiten bereik. Sluit en heropen de tabel.';
  kbmIndexNotExist = 'Index %s bestaat niet';
  kbmKeyFieldsChanged = 'Bewerking kan niet uitgevoerd worden aangezien sleutelveld is gewijzigd.';
  kbmDupIndex = 'Dubbele index waarde. Bewerking afgebroken.';
  kbmMissingNames = 'Name of FieldNames ontbreekt in IndexDef!';
  kbmInvalidRecord = 'Ongeldig record ';
  kbmTransactionVersioning = 'Transacties vereisen multi-versie versiesysteem.';
  kbmNoCurrentRecord = 'Geen huidig record.';
  kbmCantAttachToSelf = 'Een geheugentabel kan niet met zichzelf gekoppeld worden.';
  kbmCantAttachToSelf2 = 'Kan niet koppelen met een tabel die al is gekoppeld.';
  kbmUnknownOperator = 'Onbekende operator (%d)';
  kbmUnknownFieldType = 'Onbekend veldtype (%d)';
  kbmOperatorNotSupported = 'Operator wordt niet ondersteund (%d).';
  kbmSavingDeltasBinary = 'Verschillen kunnen alleen in binair formaat opgeslagen worden.';
  kbmCantCheckpointAttached = 'Kan geen checkpoint aanbrengen in een gekoppelde tabel.';
  kbmDeltaHandlerAssign = 'Verschil afhandeling is niet toegekend aan een geheugentabel.';
  kbmOutOfRange = 'Buiten bereik (%d)';
  kbmInvArgument = 'Ongeldig argument.';
  kbmInvOptions = 'Ongeldige opties.';
  kbmTableMustBeClosed = 'Tabel dient gesloten te zijn voor deze bewerking.';
  kbmChildrenAttached = 'Er zijn subtabellen gekoppeld aan deze tabel.';
  kbmIsAttached = 'Tabel is gekoppeld aan een andere tabel.';
  kbmInvalidLocale = 'Ongeldige locatie.';
  kbmInvFunction = 'Ongeldige functie naam %s.';
  kbmInvMissParam = 'Ongeldige of ontbrekende parameter van functie %s.';
  kbmNoFormat = 'Geen formaat gespecificeerd.';
  kbmTooManyFieldDefs = 'Te veel fielddefs. Verhoog KBM_MAX_FIELDS waarde.';

  kbmCannotMixAppendStructure = 'Cannot both append and copy structure.';

implementation


end.
