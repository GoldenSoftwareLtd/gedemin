unit kbmMemResBra;

interface

// Portugues - Brazil

const
  kbmMasterlinkErr = 'Número de campos em MASTERFIELDS não corresponde INDEXFIELDS.';
  kbmSelfRef = 'master/detail recursividade não permitida.';
  kbmFindNearestErr = 'FindNearest só funciona em tabelas ordenadas (sort).';
  kbminternalOpen1Err = 'Erro na Definição dos campos ';
  kbminternalOpen2Err = ' Tipo de campo nao suportado: %d)';
  kbmReadOnlyErr = 'O campo %s é somente para leitura';
  kbmVarArrayErr = 'O vetor de Variant'' tem uma dimensão inválida';
  kbmVarReason1Err = 'Mais campos que valores';
  kbmVarReason2Err = 'Pelo menos um campo é necessário';
  kbmBookmErr = 'Bookmark %d não encontrado.';
  kbmUnknownFieldErr1 = 'Tipo de campo desconhecido (%s)';
  kbmUnknownFieldErr2 = ' no arquivo CSV. (%s)';
  kbmIndexErr = 'Impossível indexar o campo %s';
  kbmEditModeErr = 'Não está em mode inclusão ou alteração.';
  
  kbmDatasetRemoveLockedErr = 'Dataset sendo removido enquanto travado (lock).';
  kbmSetDatasetLockErr = 'Dataset está travado (lock) e não pode ser mudado.';
  kbmOutOfBookmarks = 'Contador de bookmarks fora de intervalo. Favor fechar e reabrir a tabela.';
  kbmIndexNotExist = 'Índice %s não existe';
  kbmKeyFieldsChanged = 'Não pode fazer operação pois campos chave foram mudados';
  kbmDupIndex = 'Valor de índice duplicado. Operação abortada.';
  kbmMissingNames = 'Falta nome ou Nome de campo em IndexDef!';
  kbmInvalidRecord = 'Registro inválido';
  kbmTransactionVersioning = 'Transação requer versão multiversão.';
  kbmNoCurrentRecord = 'Sem registro corrente.';
  kbmCantAttachToSelf = 'Não pode anexar tabela em memória a si mesma.';
  kbmCantAttachToSelf2 = 'Não pode anexar a outra tabela que já é um anexo.';
  kbmUnknownOperator = 'Operador desconhecido (%d)';
  kbmUnknownFieldType = 'Tipo de dados desconhecido (%d)';
  kbmOperatorNotSupported = 'Operador não suportado (%d).';
  kbmSavingDeltasBinary = 'Salvar deltas somente é suportado em modo binário.';
  kbmCantCheckpointAttached = 'Não pode verificar tabela anexada.';
  kbmDeltaHandlerAssign = 'Gerenciador de deltas não atribuido a tabelas em memória.';
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
