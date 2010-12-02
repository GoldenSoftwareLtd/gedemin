unit kbmMemResCsy;

interface

const
  kbmMasterlinkErr = 'Poèet hlavních polí neodpovídá poètu indexových polí.';
  kbmSelfRef = 'Tabulka nemùže být detailem sebe sama.';
  kbmFindNearestErr = 'Funkce NajítNejbližší se nedá použít na netøídìná data.';
  kbminternalOpen1Err = 'Definice pole ';
  kbminternalOpen2Err = 'Datový typ %d není podporován.';
  kbmReadOnlyErr = 'Pole %s je pouze ke ètení.';
  kbmVarArrayErr = 'Pole variantních hodnot má neplatné dimenze.';
  kbmVarReason1Err = 'Je více polí než hodnot.';
  kbmVarReason2Err = 'Je vyžadováno alespoò jedno pole.';
  kbmBookmErr = 'Záložku %d se nepodaøilo najít.';
  kbmUnknownFieldErr1 = 'Neznámý typ pole (%s)';
  kbmUnknownFieldErr2 = ' v CSV souboru. (%s)';
  kbmIndexErr = 'Pole %s se nedá indexovat.';
  kbmEditModeErr = 'Datový soubor není v editaèním režimu.';
  kbmDatasetRemoveLockedErr = 'Uzamèený datový soubor byl odstranìn.';
  kbmSetDatasetLockErr = 'Datový soubor je uzamèen a nemùže být mìnìn.';
  kbmOutOfBookmarks = 'Poèítadlo záložek je mimo rozsah. Uzavøete prosím tabulku a znovu ji otevøete.';
  kbmIndexNotExist = 'Index %s neexistuje';
  kbmKeyFieldsChanged = 'Operaci nelze provést protože pole indexu byla zmìnìna.';
  kbmDupIndex = 'Duplikovaná hodnota klíèe. Operace zrušena.';

  kbmMissingNames = 'Chybìjící jméno èi jména sloupcù v definici indexù!';
  kbmInvalidRecord = 'Neplatný záznam ';
  kbmTransactionVersioning = 'Tansakèní zpracování vyžaduje multiverzní versioning.';
  kbmNoCurrentRecord = 'Není aktuální záznam.';
  kbmCantAttachToSelf = 'Nemohu napojit tabulku samu na sebe.';
  kbmCantAttachToSelf2 = 'Nemohu napojit tabulku do jiné, již napojené, tabulky.';
  kbmUnknownOperator = 'Neznámý operátor (%d)';
  kbmUnknownFieldType = 'Neznámý typ pole (%d)';
  kbmOperatorNotSupported = 'Operátor není podporován (%d).';
  kbmSavingDeltasBinary = 'Ukládání delta je podporováno pouze v binárním formátu.';
  kbmCantCheckpointAttached = 'Nemohu provést checkpoint na napojenou tabulku.';
  kbmDeltaHandlerAssign = 'Delta handler není napojen do žádné tabulky.';
  kbmOutOfRange = 'Mimo rámec (%d)';
  kbmInvArgument = 'Neplatný argument.';
  kbmInvOptions = 'Neplatné nastavení.';
  kbmTableMustBeClosed = 'Tabulka musí být pro tuto operaci uzavøena.';
  kbmChildrenAttached = 'Potomci jsou napojeni na tuto tabulku.';
  kbmIsAttached = 'Tabulka je napojená na jinou tabulku.';
  kbmInvalidLocale = 'Neplatná lokalizace.';
  kbmInvFunction = 'Neplatný název funkce %s';
  kbmInvMissParam = 'Neplatný nebo chybìjící parametr pro funkci %s';

  kbmNoFormat = 'No format specified.';
  kbmTooManyFieldDefs = 'Too many fielddefs. Please raise KBM_MAX_FIELDS value.';
  kbmCannotMixAppendStructure = 'Cannot both append and copy structure.';

implementation


end.
