unit kbmMemResSpa;

interface

const
  kbmMasterlinkErr = 'El n�mero de "masterfields" no corresponde con el n�mero de "indexfields".';
  kbmSelfRef = 'No se admiten relaciones master/detail autoreferenciadas.';
  kbmFindNearestErr = 'No se puede usar FindNearest en datos no ordenados.';
  kbminternalOpen1Err = 'Fielddef ';
  kbminternalOpen2Err = ' Tipo de dato %d no soportado.';
  kbmReadOnlyErr = 'El campo %s es de s�lo lectura';
  kbmVarArrayErr = 'El arreglo tipo variant del par�metro "Values" tiene un n�mero de dimensiones no v�lido';
  kbmVarReason1Err = 'M�s campos que valores';
  kbmVarReason2Err = 'Tiene que haber al menos un campo';
  kbmBookmErr = 'Bookmark %d no encontrado.';
  kbmUnknownFieldErr1 = 'Tipo de campo desconocido (%s)';
  kbmUnknownFieldErr2 = ' en archivo CSV. (%s)';
  kbmIndexErr = 'No puede indexarse con el campo %s';
  kbmEditModeErr = 'El Dataset no est� en modo de edici�n.';

  kbmDatasetRemoveLockedErr = 'El Dataset est� siendo removido mientras este est� bloqueado';
  kbmSetDatasetLockErr = 'El Dataset est� bloqueado y no puede modificarse';
  kbmOutOfBookmarks = 'El contador de Bookmarks est� fuera de rango. Por favor cierre y vuelva a abrir la tabla.';
  kbmIndexNotExist = 'El �ndice %s no existe';
  kbmKeyFieldsChanged = 'No se puede efectuar la operaci�n desde que los campos llave han cambiado.';
  kbmDupIndex = 'Valor de �ndice duplicado. Operaci�n abortada.';
  kbmMissingNames = 'No se especific� la propiedad "Name" o "FieldNames" en IndexDef!';
  kbmInvalidRecord = 'Registro no v�lido ';
  kbmTransactionVersioning = 'El proceso de seguimiento de transacciones requiere "multiversion versioning".';
  kbmNoCurrentRecord = 'No hay registro actual.';
  kbmCantAttachToSelf = 'No se puede adjuntar la tabla de memoria a s� misma';
  kbmCantAttachToSelf2 = 'Esta tabla no puede adjuntarse a otra previamente ya adjuntada.';
  kbmUnknownOperator = 'Operador desconocido (%d)';
  kbmUnknownFieldType = 'Tipo de campo desconocido (%d)';
  kbmOperatorNotSupported = 'Operador no soportado (%d).';
  kbmSavingDeltasBinary = 'El guardado de deltas es solo soportado en el formato binario.';
  kbmCantCheckpointAttached = 'No se puede hacer el checkpoint en la tabla adjunta';
  kbmDeltaHandlerAssign = 'El Delta Handler no est� asignado a ninguna tabla de memoria.';
  kbmOutOfRange = 'Fuera de rango (%d)';
  kbmInvArgument = 'Argumento no v�lido.';
  kbmInvOptions = 'Opciones no v�lidas.';
  kbmTableMustBeClosed = 'La tabla debe estar cerrada para esta operaci�n.';
  kbmChildrenAttached = 'Existen tablas hijas adjuntas a esta tabla.';
  kbmIsAttached = 'La tabla est� adjunta a otra tabla.';
  kbmInvalidLocale = 'Locale no v�lido.';
  kbmInvFunction = 'Nombre de funci�n %s no v�lido';
  kbmInvMissParam = 'Par�metro no v�lido o no especificado para la funci�n %s';
  kbmNoFormat = 'No se especific� ning�n formato';
  kbmTooManyFieldDefs = 'Demasiados fielddefs. Por favor incremente el valor de KBM_MAX_FIELDS.';

  kbmCannotMixAppendStructure = 'A�adir y Copiar Estructura no pueden hacerse al mismo tiempo.';
implementation


end.
