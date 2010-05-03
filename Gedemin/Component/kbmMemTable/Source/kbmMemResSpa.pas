unit kbmMemResSpa;

interface

const
  kbmMasterlinkErr = 'El número de "masterfields" no corresponde con el número de "indexfields".';
  kbmSelfRef = 'No se admiten relaciones master/detail autoreferenciadas.';
  kbmFindNearestErr = 'No se puede usar FindNearest en datos no ordenados.';
  kbminternalOpen1Err = 'Fielddef ';
  kbminternalOpen2Err = ' Tipo de dato %d no soportado.';
  kbmReadOnlyErr = 'El campo %s es de sólo lectura';
  kbmVarArrayErr = 'El arreglo tipo variant del parámetro "Values" tiene un número de dimensiones no válido';
  kbmVarReason1Err = 'Más campos que valores';
  kbmVarReason2Err = 'Tiene que haber al menos un campo';
  kbmBookmErr = 'Bookmark %d no encontrado.';
  kbmUnknownFieldErr1 = 'Tipo de campo desconocido (%s)';
  kbmUnknownFieldErr2 = ' en archivo CSV. (%s)';
  kbmIndexErr = 'No puede indexarse con el campo %s';
  kbmEditModeErr = 'El Dataset no está en modo de edición.';

  kbmDatasetRemoveLockedErr = 'El Dataset está siendo removido mientras este está bloqueado';
  kbmSetDatasetLockErr = 'El Dataset está bloqueado y no puede modificarse';
  kbmOutOfBookmarks = 'El contador de Bookmarks está fuera de rango. Por favor cierre y vuelva a abrir la tabla.';
  kbmIndexNotExist = 'El índice %s no existe';
  kbmKeyFieldsChanged = 'No se puede efectuar la operación desde que los campos llave han cambiado.';
  kbmDupIndex = 'Valor de índice duplicado. Operación abortada.';
  kbmMissingNames = 'No se especificó la propiedad "Name" o "FieldNames" en IndexDef!';
  kbmInvalidRecord = 'Registro no válido ';
  kbmTransactionVersioning = 'El proceso de seguimiento de transacciones requiere "multiversion versioning".';
  kbmNoCurrentRecord = 'No hay registro actual.';
  kbmCantAttachToSelf = 'No se puede adjuntar la tabla de memoria a sí misma';
  kbmCantAttachToSelf2 = 'Esta tabla no puede adjuntarse a otra previamente ya adjuntada.';
  kbmUnknownOperator = 'Operador desconocido (%d)';
  kbmUnknownFieldType = 'Tipo de campo desconocido (%d)';
  kbmOperatorNotSupported = 'Operador no soportado (%d).';
  kbmSavingDeltasBinary = 'El guardado de deltas es solo soportado en el formato binario.';
  kbmCantCheckpointAttached = 'No se puede hacer el checkpoint en la tabla adjunta';
  kbmDeltaHandlerAssign = 'El Delta Handler no está asignado a ninguna tabla de memoria.';
  kbmOutOfRange = 'Fuera de rango (%d)';
  kbmInvArgument = 'Argumento no válido.';
  kbmInvOptions = 'Opciones no válidas.';
  kbmTableMustBeClosed = 'La tabla debe estar cerrada para esta operación.';
  kbmChildrenAttached = 'Existen tablas hijas adjuntas a esta tabla.';
  kbmIsAttached = 'La tabla está adjunta a otra tabla.';
  kbmInvalidLocale = 'Locale no válido.';
  kbmInvFunction = 'Nombre de función %s no válido';
  kbmInvMissParam = 'Parámetro no válido o no especificado para la función %s';
  kbmNoFormat = 'No se especificó ningún formato';
  kbmTooManyFieldDefs = 'Demasiados fielddefs. Por favor incremente el valor de KBM_MAX_FIELDS.';

  kbmCannotMixAppendStructure = 'Añadir y Copiar Estructura no pueden hacerse al mismo tiempo.';
implementation


end.
