unit kbmMemResCsy;

interface

const
  kbmMasterlinkErr = 'Po�et hlavn�ch pol� neodpov�d� po�tu indexov�ch pol�.';
  kbmSelfRef = 'Tabulka nem��e b�t detailem sebe sama.';
  kbmFindNearestErr = 'Funkce Naj�tNejbli��� se ned� pou��t na net��d�n� data.';
  kbminternalOpen1Err = 'Definice pole ';
  kbminternalOpen2Err = 'Datov� typ %d nen� podporov�n.';
  kbmReadOnlyErr = 'Pole %s je pouze ke �ten�.';
  kbmVarArrayErr = 'Pole variantn�ch hodnot m� neplatn� dimenze.';
  kbmVarReason1Err = 'Je v�ce pol� ne� hodnot.';
  kbmVarReason2Err = 'Je vy�adov�no alespo� jedno pole.';
  kbmBookmErr = 'Z�lo�ku %d se nepoda�ilo naj�t.';
  kbmUnknownFieldErr1 = 'Nezn�m� typ pole (%s)';
  kbmUnknownFieldErr2 = ' v CSV souboru. (%s)';
  kbmIndexErr = 'Pole %s se ned� indexovat.';
  kbmEditModeErr = 'Datov� soubor nen� v edita�n�m re�imu.';
  kbmDatasetRemoveLockedErr = 'Uzam�en� datov� soubor byl odstran�n.';
  kbmSetDatasetLockErr = 'Datov� soubor je uzam�en a nem��e b�t m�n�n.';
  kbmOutOfBookmarks = 'Po��tadlo z�lo�ek je mimo rozsah. Uzav�ete pros�m tabulku a znovu ji otev�ete.';
  kbmIndexNotExist = 'Index %s neexistuje';
  kbmKeyFieldsChanged = 'Operaci nelze prov�st proto�e pole indexu byla zm�n�na.';
  kbmDupIndex = 'Duplikovan� hodnota kl��e. Operace zru�ena.';

  kbmMissingNames = 'Chyb�j�c� jm�no �i jm�na sloupc� v definici index�!';
  kbmInvalidRecord = 'Neplatn� z�znam ';
  kbmTransactionVersioning = 'Tansak�n� zpracov�n� vy�aduje multiverzn� versioning.';
  kbmNoCurrentRecord = 'Nen� aktu�ln� z�znam.';
  kbmCantAttachToSelf = 'Nemohu napojit tabulku samu na sebe.';
  kbmCantAttachToSelf2 = 'Nemohu napojit tabulku do jin�, ji� napojen�, tabulky.';
  kbmUnknownOperator = 'Nezn�m� oper�tor (%d)';
  kbmUnknownFieldType = 'Nezn�m� typ pole (%d)';
  kbmOperatorNotSupported = 'Oper�tor nen� podporov�n (%d).';
  kbmSavingDeltasBinary = 'Ukl�d�n� delta je podporov�no pouze v bin�rn�m form�tu.';
  kbmCantCheckpointAttached = 'Nemohu prov�st checkpoint na napojenou tabulku.';
  kbmDeltaHandlerAssign = 'Delta handler nen� napojen do ��dn� tabulky.';
  kbmOutOfRange = 'Mimo r�mec (%d)';
  kbmInvArgument = 'Neplatn� argument.';
  kbmInvOptions = 'Neplatn� nastaven�.';
  kbmTableMustBeClosed = 'Tabulka mus� b�t pro tuto operaci uzav�ena.';
  kbmChildrenAttached = 'Potomci jsou napojeni na tuto tabulku.';
  kbmIsAttached = 'Tabulka je napojen� na jinou tabulku.';
  kbmInvalidLocale = 'Neplatn� lokalizace.';
  kbmInvFunction = 'Neplatn� n�zev funkce %s';
  kbmInvMissParam = 'Neplatn� nebo chyb�j�c� parametr pro funkci %s';

  kbmNoFormat = 'No format specified.';
  kbmTooManyFieldDefs = 'Too many fielddefs. Please raise KBM_MAX_FIELDS value.';
  kbmCannotMixAppendStructure = 'Cannot both append and copy structure.';

implementation


end.
