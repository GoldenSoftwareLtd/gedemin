unit kbmMemResBra;

interface

// Portugues - Brazil

const
  kbmMasterlinkErr = 'N�mero de campos em MASTERFIELDS n�o corresponde INDEXFIELDS.';
  kbmSelfRef = 'master/detail recursividade n�o permitida.';
  kbmFindNearestErr = 'FindNearest s� funciona em tabelas ordenadas (sort).';
  kbminternalOpen1Err = 'Erro na Defini��o dos campos ';
  kbminternalOpen2Err = ' Tipo de campo nao suportado: %d)';
  kbmReadOnlyErr = 'O campo %s � somente para leitura';
  kbmVarArrayErr = 'O vetor de Variant'' tem uma dimens�o inv�lida';
  kbmVarReason1Err = 'Mais campos que valores';
  kbmVarReason2Err = 'Pelo menos um campo � necess�rio';
  kbmBookmErr = 'Bookmark %d n�o encontrado.';
  kbmUnknownFieldErr1 = 'Tipo de campo desconhecido (%s)';
  kbmUnknownFieldErr2 = ' no arquivo CSV. (%s)';
  kbmIndexErr = 'Imposs�vel indexar o campo %s';
  kbmEditModeErr = 'N�o est� em mode inclus�o ou altera��o.';
  
  kbmDatasetRemoveLockedErr = 'Dataset sendo removido enquanto travado (lock).';
  kbmSetDatasetLockErr = 'Dataset est� travado (lock) e n�o pode ser mudado.';
  kbmOutOfBookmarks = 'Contador de bookmarks fora de intervalo. Favor fechar e reabrir a tabela.';
  kbmIndexNotExist = '�ndice %s n�o existe';
  kbmKeyFieldsChanged = 'N�o pode fazer opera��o pois campos chave foram mudados';
  kbmDupIndex = 'Valor de �ndice duplicado. Opera��o abortada.';
  kbmMissingNames = 'Falta nome ou Nome de campo em IndexDef!';
  kbmInvalidRecord = 'Registro inv�lido';
  kbmTransactionVersioning = 'Transa��o requer vers�o multivers�o.';
  kbmNoCurrentRecord = 'Sem registro corrente.';
  kbmCantAttachToSelf = 'N�o pode anexar tabela em mem�ria a si mesma.';
  kbmCantAttachToSelf2 = 'N�o pode anexar a outra tabela que j� � um anexo.';
  kbmUnknownOperator = 'Operador desconhecido (%d)';
  kbmUnknownFieldType = 'Tipo de dados desconhecido (%d)';
  kbmOperatorNotSupported = 'Operador n�o suportado (%d).';
  kbmSavingDeltasBinary = 'Salvar deltas somente � suportado em modo bin�rio.';
  kbmCantCheckpointAttached = 'N�o pode verificar tabela anexada.';
  kbmDeltaHandlerAssign = 'Gerenciador de deltas n�o atribuido a tabelas em mem�ria.';
  kbmOutOfRange = 'Fora de intervalo (%d)';

  kbmInvArgument = 'Invalid argument.';
  kbmInvOptions = 'Invalid options.';
  kbmTableMustBeClosed = 'Table must be closed for this operation.';
  kbmChildrenAttached = 'Children are attached to this table.';
  kbmIsAttached = 'Table is attached to another table.';
  kbmInvalidLocale = 'Invalid locale.';
  kbmInvFunction = 'Invalid function name %s';
  kbmInvMissParam = 'Invalid or missing parameter for function %s';
  kbmNoFormat = 'No format specified.';
  kbmTooManyFieldDefs = 'Too many fielddefs. Please raise KBM_MAX_FIELDS value.';
  kbmCannotMixAppendStructure = 'Cannot both append and copy structure.';

implementation


end.
