{************************************************************************}
{                                                                        }
{       Borland Delphi Visual Component Library                          }
{       InterBase Express core components                                }
{                                                                        }
{       Copyright (c) 1998-2001 Borland Software Corporation             }
{                                                                        }
{    InterBase Express is based in part on the product                   }
{    Free IB Components, written by Gregory H. Deatz for                 }
{    Hoagland, Longo, Moran, Dunst & Doukas Company.                     }
{    Free IB Components is used under license.                           }
{                                                                        }
{    The contents of this file are subject to the InterBase              }
{    Public License Version 1.0 (the "License"); you may not             }
{    use this file except in compliance with the License. You may obtain }
{    a copy of the License at http://www.borland.com/interbase/IPL.html  }
{    Software distributed under the License is distributed on            }
{    an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either              }
{    express or implied. See the License for the specific language       }
{    governing rights and limitations under the License.                 }
{    The Original Code was created by InterBase Software Corporation     }
{       and its successors.                                              }
{    Portions created by Borland Software Corporation are Copyright      }
{       (C) Borland Software Corporation. All Rights Reserved.           }
{    Contributor(s): Jeff Overcash                                       }
{                                                                        }
{************************************************************************}

unit IBXConst;

interface

uses IBUtils;

const
//  IBX_Version = 5.03;
  IBX_Version = 5.033;

resourcestring

{$IFDEF GD_LOC_RUS}

{ generic strings used in code }
  SIBDatabaseEditor = 'Da&tabase Editor...';
  SIBTransactionEditor = '&Transaction Editor...';
  SDatabaseFilter = 'Database Files (*.gdb)|*.gdb|All files (*.*)|*.*';
  SDisconnectDatabase = 'Database is currently connected. Disconnect and continue?';
  SCommitTransaction = 'Transaction is currently Active. Rollback and continue?';
  SExecute = 'E&xecute';
  SNoDataSet = 'No dataset association';
  SSQLGenSelect = 'Must select at least one key field and one update field';
  SSQLNotGenerated = 'Update SQL statements not generated, exit anyway?';
  SIBUpdateSQLEditor = '&UpdateSQL Editor...';
  SIBDataSetEditor = '&Dataset Editor...';
  SSQLDataSetOpen = 'Unable to determine field names for %s';
  SDefaultTransaction = '%s, Default';

{ strings used in error messages}
  SUnknownError = 'Неизвестная ошибка';
  //!!!
  //SInterBaseMissing = 'InterBase library gds32.dll not found in the path. Please install InterBase to use this functionality';
  SInterBaseMissing = 'InterBase library gds32.dll or fbclient.dll not found in the path. Please install InterBase to use this functionality';
  //!!!
  SInterBaseInstallMissing = 'InterBase Install DLL ibinstall.dll not found in the path. Please install InterBase 6 to use this functionality';
  SIB60feature = '%s is an InterBase 6 function. Please upgrade to InterBase 6 to use this functonality';
  SNotSupported = 'Not supported';
  SNotPermitted = 'Not permitted';
  SFileAccessError = 'Temporary file access error';
  SConnectionTimeout = 'Database connection timed out';
  SCannotSetDatabase = 'Cannot set database';
  SCannotSetTransaction = 'Cannot set transaction';
  SOperationCancelled = 'Operation cancelled at user''s request';
  SDPBConstantNotSupported = 'DPB Constant (isc_dpb_%s) is unsupported';
  SDPBConstantUnknown = 'DPB Constant (%d) is unknown';
  STPBConstantNotSupported = 'TPB Constant (isc_tpb_%s) is unsupported';
  STPBConstantUnknown = 'TPB Constant (%d) is unknown';
  SDatabaseClosed = 'Невозможно выполнить операцию -- БД не открыта!';//'Cannot perform operation -- DB is not open';
  SDatabaseOpen = 'Невозможно выполнить операцию -- БД уже открыта!';//'Cannot perform operation -- DB is currently open';
  SDatabaseNameMissing = 'Пропущено имя базы данных';
  SNotInTransaction = 'Транзакция не активна';
  SInTransaction = 'Транзакция активна';
  STimeoutNegative = 'Timeout values cannot be negative';
  SNoDatabasesInTransaction = 'Не указана база данных для компонента транзакции';
  SUpdateWrongDB = 'Updating wrong database';
  SUpdateWrongTR = 'Updating wrong transaction. Unique transaction expected in set';
  SDatabaseNotAssigned = 'Не указана база данных!';//'Database not assigned';
  STransactionNotAssigned = 'Транзакция не присвоена';
  SXSQLDAIndexOutOfRange = 'XSQLDA index out of range';
  SXSQLDANameDoesNotExist = 'XSQLDA name does not exist (%s)';
  SEOF = 'Конец файла';
  SBOF = 'Начало файла';
  SInvalidStatementHandle = 'Invalid statement handle';
  SSQLOpen = 'IBSQL Open';
  SSQLClosed = 'IBSQL Closed';
  SDatasetOpen = 'Dataset open';
  SDatasetClosed = 'Dataset closed';
  SUnknownSQLDataType = 'Unknown SQL Data type (%d)';
  SInvalidColumnIndex = 'Invalid column index (index exceeds permitted range)';
  SInvalidParamColumnIndex = 'Invalid parameter index (index exceeds permitted range)';
  SInvalidDataConversion = 'Некорректное преобразование данных!';//'Invalid data conversion';
  SColumnIsNotNullable = 'Column cannot be set to null (%s)';
  SBlobCannotBeRead = 'Blob stream cannot be read';
  SBlobCannotBeWritten = 'Blob stream cannot be written';
  SEmptyQuery = 'Пустой запрос';
  SCannotOpenNonSQLSelect = 'Cannot "open" a non-select statement. Use ExecQuery';
  SNoFieldAccess = 'Нет доступа к полю "%s"';
  SFieldReadOnly = 'Поле "%s" только для чтения';
  SFieldNotFound = 'Поле "%s" не найдено';
  SNotEditing = 'Не в режиме редактирования';
  SCannotInsert = 'Cannot insert into dataset. (No insert query)';
  SCannotPost = 'Cannot post. (No update/insert query)';
  SCannotUpdate = 'Cannot update. (No update query)';
  SCannotDelete = 'Cannot delete from dataset. (No delete query)';
  SCannotRefresh = 'Невозможно обновить запись. (Отсутствует запрос для обновления)';
  SBufferNotSet = 'Буфер не установлен';
  SCircularReference = 'Циклические ссылки не разрешены!';//'Circular references not permitted';
  SSQLParseError = 'Ошибка разбора SQL:' + CRLF + CRLF + '%s';
  SUserAbort = 'User abort';
  SDataSetUniDirectional = 'Data set is uni-directional';
  SCannotCreateSharedResource = 'Cannot create shared resource. (Windows error %d)';
  SWindowsAPIError = 'Windows API error. (Windows error %d [$%.8x])';
  SColumnListsDontMatch = 'Column lists do not match';
  SColumnTypesDontMatch = 'Column types don''t match. (From index: %d; To index: %d)';
  SCantEndSharedTransaction = 'Can''t end a shared transaction unless it is forced and equal ' +
                             'to the transaction''s TimeoutAction';
  SFieldUnsupportedType = 'Неподдерживаемый тип поля';
  SCircularDataLink = 'Circular DataLink Reference';
  SEmptySQLStatement = 'Пустой SQL запрос';
  SIsASelectStatement = 'use Open for a Select Statement';
  SRequiredParamNotSet = 'Required Param value not set';
  SNoStoredProcName = 'No Stored Procedure Name assigned';
  SIsAExecuteProcedure = 'use ExecProc for Procedure; use TQuery for Select procedures';
  SUpdateFailed = 'Update Failed';
  SNotCachedUpdates = 'CachedUpdates not enabled';
  SNotLiveRequest = 'Request is not live - cannot modify';
  SNoProvider = 'No Provider';
  SNoRecordsAffected = 'No Records Affected';
  SNoTableName = 'Не присвоено имя таблицы';
  SCannotCreatePrimaryIndex = 'Cannot Create Primary Index; are created automatically';
  SCannotDropSystemIndex = 'Невозможно удалить системный индекс';
  STableNameMismatch = 'Table Name Mismatch';
  SIndexFieldMissing = 'Пропущено индексное поле';
  SInvalidCancellation = 'Cannot Cancel events while processing';
  SInvalidEvent = 'Неверное событие';
  SMaximumEvents = 'Exceded Maximum Event limits';
  SNoEventsRegistered = 'No Events Registered';
  SInvalidQueueing = 'Invalid Queueing';
  SInvalidRegistration = 'Неверная регистрация';
  SInvalidBatchMove = 'Invalid Batch Move';
  SSQLDialectInvalid = 'SQL Dialect Invalid';
  SSPBConstantNotSupported = 'SPB Constant Not supported';
  SSPBConstantUnknown = 'SPB Constant Unknown';
  SServiceActive = 'Cannot perform operation -- service is not attached';
  SServiceInActive = 'Cannot perform operation -- service is attached';
  SServerNameMissing = 'Пропущено имя сервера';
  SQueryParamsError = 'Query Parameters missing or incorrect';
  SStartParamsError = 'start Parameters missing or incorrect';
  SOutputParsingError = 'Unexpected Output buffer value';
  SUseSpecificProcedures = 'Generic ServiceStart not applicable: Use Specific Procedures to set configuration params';
  SSQLMonitorAlreadyPresent = 'SQL Monitor Instance is already present';
  SCantPrintValue = 'Невозможно распечатать значение';
  SEOFReached = 'SEOFReached';
  SEOFInComment = 'EOF in comment detected';
  SEOFInString = 'EOF in string detected';
  SParamNameExpected = 'Parameter name expected';
  SSuccess = 'Успешное выполнение';
  SDelphiException = 'Исключение Delphi %s';
  SNoOptionsSet = 'No Install Options selected';
  SNoDestinationDirectory = 'DestinationDirectory is not set';
  SNosourceDirectory = 'SourceDirectory is not set';
  SNoUninstallFile = 'Uninstall File Name is not set';
  SOptionNeedsClient = '%s component requires Client to function properly';
  SOptionNeedsServer = '%s component requires Server to function properly';
  SInvalidOption = 'Указана некорректная опция';
  SInvalidOnErrorResult = 'Unexpected onError return value';
  SInvalidOnStatusResult = 'Unexpected onStatus return value';

  SInterbaseExpressVersion = 'InterbaseExpress 5.3';
  SEditSQL = 'Edit SQL';
  SDPBConstantUnknownEx = 'DPB Constant (%s) is unknown';
  STPBConstantUnknownEx = 'TPB Constant (%s) is unknown';
  SInterbaseExpressVersionEx = 'InterbaseExpress %g';
  SUnknownPlan = 'Unknown Error - Can''t retrieve plan';
  SFieldSizeMismatch = 'Size Mismatch - Field %s size is too small for data';
  SEventAlreadyRegistered   = 'События уже зарегистрированы';
  SStringTooLarge = 'Trying to store a string of length %d into a field that can only contain %d';
  SIBServiceEditor = '&Service Editor ...';
  SIBSuccessConnect = 'Успешное подключение';
  SNoTimers = 'Not enough timers available';
  SIB65feature = '%s is an InterBase 6.5 function. Please upgrade to InterBase 6.5 to use this functonality';
  SLoginPromptFailure = 'Can not find default login prompt dialog.  Please add DBLogDlg to the uses section of your main file.';
  SIBMemoryError = 'Недостаточно памяти';

{$ELSE}

{ generic strings used in code }
  SIBDatabaseEditor = 'Da&tabase Editor...';
  SIBTransactionEditor = '&Transaction Editor...';
  SDatabaseFilter = 'Database Files (*.gdb)|*.gdb|All files (*.*)|*.*';
  SDisconnectDatabase = 'Database is currently connected. Disconnect and continue?';
  SCommitTransaction = 'Transaction is currently Active. Rollback and continue?';
  SExecute = 'E&xecute';
  SNoDataSet = 'No dataset association';
  SSQLGenSelect = 'Must select at least one key field and one update field';
  SSQLNotGenerated = 'Update SQL statements not generated, exit anyway?';
  SIBUpdateSQLEditor = '&UpdateSQL Editor...';
  SIBDataSetEditor = '&Dataset Editor...';
  SSQLDataSetOpen = 'Unable to determine field names for %s';
  SDefaultTransaction = '%s, Default';

{ strings used in error messages}
  SUnknownError = 'Unknown error';
  SInterBaseMissing = 'InterBase library gds32.dll not found in the path. Please install InterBase to use this functionality';
  SInterBaseInstallMissing = 'InterBase Install DLL ibinstall.dll not found in the path. Please install InterBase 6 to use this functionality';
  SIB60feature = '%s is an InterBase 6 function. Please upgrade to InterBase 6 to use this functonality';
  SNotSupported = 'Unsupported feature';
  SNotPermitted = 'Not permitted';
  SFileAccessError = 'Temporary file access error';
  SConnectionTimeout = 'Database connection timed out';
  SCannotSetDatabase = 'Cannot set database';
  SCannotSetTransaction = 'Cannot set transaction';
  SOperationCancelled = 'Operation cancelled at user''s request';
  SDPBConstantNotSupported = 'DPB Constant (isc_dpb_%s) is unsupported';
  SDPBConstantUnknown = 'DPB Constant (%d) is unknown';
  STPBConstantNotSupported = 'TPB Constant (isc_tpb_%s) is unsupported';
  STPBConstantUnknown = 'TPB Constant (%d) is unknown';
  SDatabaseClosed = 'Cannot perform operation -- DB is not open';
  SDatabaseOpen = 'Cannot perform operation -- DB is currently open';
  SDatabaseNameMissing = 'Database name is missing';
  SNotInTransaction = 'Transaction is not active';
  SInTransaction = 'Transaction is active';
  STimeoutNegative = 'Timeout values cannot be negative';
  SNoDatabasesInTransaction = 'No databases are listed in transaction component';
  SUpdateWrongDB = 'Updating wrong database';
  SUpdateWrongTR = 'Updating wrong transaction. Unique transaction expected in set';
  SDatabaseNotAssigned = 'Database not assigned';
  STransactionNotAssigned = 'Transaction not assigned';
  SXSQLDAIndexOutOfRange = 'XSQLDA index out of range';
  SXSQLDANameDoesNotExist = 'XSQLDA name does not exist (%s)';
  SEOF = 'End of file';
  SBOF = 'Beginning of file';
  SInvalidStatementHandle = 'Invalid statement handle';
  SSQLOpen = 'IBSQL Open';
  SSQLClosed = 'IBSQL Closed';
  SDatasetOpen = 'Dataset open';
  SDatasetClosed = 'Dataset closed';
  SUnknownSQLDataType = 'Unknown SQL Data type (%d)';
  SInvalidColumnIndex = 'Invalid column index (index exceeds permitted range)';
  SInvalidParamColumnIndex = 'Invalid parameter index (index exceeds permitted range)';
  SInvalidDataConversion = 'Invalid data conversion';
  SColumnIsNotNullable = 'Column cannot be set to null (%s)';
  SBlobCannotBeRead = 'Blob stream cannot be read';
  SBlobCannotBeWritten = 'Blob stream cannot be written';
  SEmptyQuery = 'Empty query';
  SCannotOpenNonSQLSelect = 'Cannot "open" a non-select statement. Use ExecQuery';
  SNoFieldAccess = 'No access to field "%s"';
  SFieldReadOnly = 'Field "%s" is read-only';
  SFieldNotFound = 'Field "%s" not found';
  SNotEditing = 'Not in edit mode';
  SCannotInsert = 'Cannot insert into dataset. (No insert query)';
  SCannotPost = 'Cannot post. (No update/insert query)';
  SCannotUpdate = 'Cannot update. (No update query)';
  SCannotDelete = 'Cannot delete from dataset. (No delete query)';
  SCannotRefresh = 'Cannot refresh row. (No refresh query)';
  SBufferNotSet = 'Buffer not set';
  SCircularReference = 'Circular references not permitted';
  SSQLParseError = 'SQL Parse Error:' + CRLF + CRLF + '%s';
  SUserAbort = 'User abort';
  SDataSetUniDirectional = 'Data set is uni-directional';
  SCannotCreateSharedResource = 'Cannot create shared resource. (Windows error %d)';
  SWindowsAPIError = 'Windows API error. (Windows error %d [$%.8x])';
  SColumnListsDontMatch = 'Column lists do not match';
  SColumnTypesDontMatch = 'Column types don''t match. (From index: %d; To index: %d)';
  SCantEndSharedTransaction = 'Can''t end a shared transaction unless it is forced and equal ' +
                             'to the transaction''s TimeoutAction';
  SFieldUnsupportedType = 'Unsupported Field Type';
  SCircularDataLink = 'Circular DataLink Reference';
  SEmptySQLStatement = 'Empty SQL Statement';
  SIsASelectStatement = 'use Open for a Select Statement';
  SRequiredParamNotSet = 'Required Param value not set';
  SNoStoredProcName = 'No Stored Procedure Name assigned';
  SIsAExecuteProcedure = 'use ExecProc for Procedure; use TQuery for Select procedures';
  SUpdateFailed = 'Update Failed';
  SNotCachedUpdates = 'CachedUpdates not enabled';
  SNotLiveRequest = 'Request is not live - cannot modify';
  SNoProvider = 'No Provider';
  SNoRecordsAffected = 'No Records Affected';
  SNoTableName = 'No Table Name assigned';
  SCannotCreatePrimaryIndex = 'Cannot Create Primary Index; are created automatically';
  SCannotDropSystemIndex = 'Cannot Drop System Index';
  STableNameMismatch = 'Table Name Mismatch';
  SIndexFieldMissing = 'Index Field Missing';
  SInvalidCancellation = 'Cannot Cancel events while processing';
  SInvalidEvent = 'Invalid Event';
  SMaximumEvents = 'Exceded Maximum Event limits';
  SNoEventsRegistered = 'No Events Registered';
  SInvalidQueueing = 'Invalid Queueing';
  SInvalidRegistration = 'Invalid Registration';
  SInvalidBatchMove = 'Invalid Batch Move';
  SSQLDialectInvalid = 'SQL Dialect Invalid';
  SSPBConstantNotSupported = 'SPB Constant Not supported';
  SSPBConstantUnknown = 'SPB Constant Unknown';
  SServiceActive = 'Cannot perform operation -- service is not attached';
  SServiceInActive = 'Cannot perform operation -- service is attached';
  SServerNameMissing = 'Server Name Missing';
  SQueryParamsError = 'Query Parameters missing or incorrect';
  SStartParamsError = 'start Parameters missing or incorrect';
  SOutputParsingError = 'Unexpected Output buffer value';
  SUseSpecificProcedures = 'Generic ServiceStart not applicable: Use Specific Procedures to set configuration params';
  SSQLMonitorAlreadyPresent = 'SQL Monitor Instance is already present';
  SCantPrintValue = 'Cannot print value';
  SEOFReached = 'SEOFReached';
  SEOFInComment = 'EOF in comment detected';
  SEOFInString = 'EOF in string detected';
  SParamNameExpected = 'Parameter name expected';
  SSuccess = 'Successful execution';
  SDelphiException = 'DelphiException %s';
  SNoOptionsSet = 'No Install Options selected';
  SNoDestinationDirectory = 'DestinationDirectory is not set';
  SNosourceDirectory = 'SourceDirectory is not set';
  SNoUninstallFile = 'Uninstall File Name is not set';
  SOptionNeedsClient = '%s component requires Client to function properly';
  SOptionNeedsServer = '%s component requires Server to function properly';
  SInvalidOption = 'Invalid option specified';
  SInvalidOnErrorResult = 'Unexpected onError return value';
  SInvalidOnStatusResult = 'Unexpected onStatus return value';

  SInterbaseExpressVersion = 'InterbaseExpress 4.3';
  SEditSQL = 'Edit SQL';
  SDPBConstantUnknownEx = 'DPB Constant (%s) is unknown';
  STPBConstantUnknownEx = 'TPB Constant (%s) is unknown';
  SInterbaseExpressVersionEx = 'InterbaseExpress %g';
  SUnknownPlan = 'Unknown Error - Can''t retrieve plan';
  SFieldSizeMismatch = 'Size Mismatch - Field %s size is too small for data';
  SEventAlreadyRegistered   = 'Events already registered';
  SStringTooLarge = 'Trying to store a string of length %d into a field that can only contain %d';
  SIBServiceEditor = '&Service Editor ...';
  SIBSuccessConnect = 'Successful Connection';
  SNoTimers = 'Not enough timers available';
  SIB65feature = '%s is an InterBase 6.5 function. Please upgrade to InterBase 6.5 to use this functonality';
  SIBMemoryError = 'Not enough memory';

{$ENDIF}

implementation

end.
