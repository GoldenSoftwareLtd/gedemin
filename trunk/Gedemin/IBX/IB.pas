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

unit IB;

interface

uses
  Windows, SysUtils, Classes, IBHeader, IBExternals, IBUtils, DB, IBXConst;

type
  TTraceFlag = (tfQPrepare, tfQExecute, tfQFetch, tfError, tfStmt, tfConnect,
     tfTransact, tfBlob, tfService, tfMisc);
  TTraceFlags = set of TTraceFlag;

  EIBError                  = class(EDatabaseError)
  private
    FSQLCode: Long;
    FIBErrorCode: Long;
  public
    constructor Create(ASQLCode: Long; Msg: string); overload;
    constructor Create(ASQLCode: Long; AIBErrorCode: Long; Msg: string); overload;
    property SQLCode: Long read FSQLCode;
    property IBErrorCode: Long read FIBErrorCode;
  end;

  EIBInterBaseError         = class(EIBError);
  EIBInterBaseRoleError     = class(EIBError);
  EIBClientError            = class(EIBError);
  EIBPlanError              = class(EIBError);

  TIBDataBaseErrorMessage    = (ShowSQLCode,
                                ShowIBMessage,
                                ShowSQLMessage);
  TIBDataBaseErrorMessages   = set of TIBDataBaseErrorMessage;
  TIBClientError            = (
    ibxeUnknownError,
    ibxeInterBaseMissing,
    ibxeInterBaseInstallMissing,
    ibxeIB60feature,
    ibxeNotSupported,
    ibxeNotPermitted,
    ibxeFileAccessError,
    ibxeConnectionTimeout,
    ibxeCannotSetDatabase,
    ibxeCannotSetTransaction,
    ibxeOperationCancelled,
    ibxeDPBConstantNotSupported,
    ibxeDPBConstantUnknown,
    ibxeTPBConstantNotSupported,
    ibxeTPBConstantUnknown,
    ibxeDatabaseClosed,
    ibxeDatabaseOpen,
    ibxeDatabaseNameMissing,
    ibxeNotInTransaction,
    ibxeInTransaction,
    ibxeTimeoutNegative,
    ibxeNoDatabasesInTransaction,
    ibxeUpdateWrongDB,
    ibxeUpdateWrongTR,
    ibxeDatabaseNotAssigned,
    ibxeTransactionNotAssigned,
    ibxeXSQLDAIndexOutOfRange,
    ibxeXSQLDANameDoesNotExist,
    ibxeEOF,
    ibxeBOF,
    ibxeInvalidStatementHandle,
    ibxeSQLOpen,
    ibxeSQLClosed,
    ibxeDatasetOpen,
    ibxeDatasetClosed,
    ibxeUnknownSQLDataType,
    ibxeInvalidColumnIndex,
    ibxeInvalidParamColumnIndex,
    ibxeInvalidDataConversion,
    ibxeColumnIsNotNullable,
    ibxeBlobCannotBeRead,
    ibxeBlobCannotBeWritten,
    ibxeEmptyQuery,
    ibxeCannotOpenNonSQLSelect,
    ibxeNoFieldAccess,
    ibxeFieldReadOnly,
    ibxeFieldNotFound,
    ibxeNotEditing,
    ibxeCannotInsert,
    ibxeCannotPost,
    ibxeCannotUpdate,
    ibxeCannotDelete,
    ibxeCannotRefresh,
    ibxeBufferNotSet,
    ibxeCircularReference,
    ibxeSQLParseError,
    ibxeUserAbort,
    ibxeDataSetUniDirectional,
    ibxeCannotCreateSharedResource,
    ibxeWindowsAPIError,
    ibxeColumnListsDontMatch,
    ibxeColumnTypesDontMatch,
    ibxeCantEndSharedTransaction,
    ibxeFieldUnsupportedType,
    ibxeCircularDataLink,
    ibxeEmptySQLStatement,
    ibxeIsASelectStatement,
    ibxeRequiredParamNotSet,
    ibxeNoStoredProcName,
    ibxeIsAExecuteProcedure,
    ibxeUpdateFailed,
    ibxeNotCachedUpdates,
    ibxeNotLiveRequest,
    ibxeNoProvider,
    ibxeNoRecordsAffected,
    ibxeNoTableName,
    ibxeCannotCreatePrimaryIndex,
    ibxeCannotDropSystemIndex,
    ibxeTableNameMismatch,
    ibxeIndexFieldMissing,
    ibxeInvalidCancellation,
    ibxeInvalidEvent,
    ibxeMaximumEvents,
    ibxeNoEventsRegistered,
    ibxeInvalidQueueing,
    ibxeInvalidRegistration,
    ibxeInvalidBatchMove,
    ibxeSQLDialectInvalid,
    ibxeSPBConstantNotSupported,
    ibxeSPBConstantUnknown,
    ibxeServiceActive,
    ibxeServiceInActive,
    ibxeServerNameMissing,
    ibxeQueryParamsError,
    ibxeStartParamsError,
    ibxeOutputParsingError,
    ibxeUseSpecificProcedures,
    ibxeSQLMonitorAlreadyPresent,
    ibxeCantPrintValue,
    ibxeEOFReached,
    ibxeEOFInComment,
    ibxeEOFInString,
    ibxeParamNameExpected,
    ibxeSuccess,
    ibxeDelphiException,
    ibxeNoOptionsSet,
    ibxeNoDestinationDirectory,
    ibxeNosourceDirectory,
    ibxeNoUninstallFile,
    ibxeOptionNeedsClient,
    ibxeOptionNeedsServer,
    ibxeInvalidOption,
    ibxeInvalidOnErrorResult,
    ibxeInvalidOnStatusResult,
    ibxeDPBConstantUnknownEx,
    ibxeTPBConstantUnknownEx,
    ibxeUnknownPlan,
    ibxeFieldSizeMismatch,
    ibxeEventAlreadyRegistered,
    ibxeStringTooLarge
    );

  TStatusVector              = array[0..19] of ISC_STATUS;
  PStatusVector              = ^TStatusVector;


const
  IBPalette1 = 'InterBase'; {do not localize}
  IBPalette2 = 'InterBase Admin'; {do not localize}

  IBLocalBufferLength = 512;
  IBBigLocalBufferLength = IBLocalBufferLength * 2;
  IBHugeLocalBufferLength = IBBigLocalBufferLength * 20;

  IBErrorMessages: array[TIBClientError] of string = (
    SUnknownError,
    SInterBaseMissing,
    SInterBaseInstallMissing,
    SIB60feature,
    SNotSupported,
    SNotPermitted,
    SFileAccessError,
    SConnectionTimeout,
    SCannotSetDatabase,
    SCannotSetTransaction,
    SOperationCancelled,
    SDPBConstantNotSupported,
    SDPBConstantUnknown,
    STPBConstantNotSupported,
    STPBConstantUnknown,
    SDatabaseClosed,
    SDatabaseOpen,
    SDatabaseNameMissing,
    SNotInTransaction,
    SInTransaction,
    STimeoutNegative,
    SNoDatabasesInTransaction,
    SUpdateWrongDB,
    SUpdateWrongTR,
    SDatabaseNotAssigned,
    STransactionNotAssigned,
    SXSQLDAIndexOutOfRange,
    SXSQLDANameDoesNotExist,
    SEOF,
    SBOF,
    SInvalidStatementHandle,
    SSQLOpen,
    SSQLClosed,
    SDatasetOpen,
    SDatasetClosed,
    SUnknownSQLDataType,
    SInvalidColumnIndex,
    SInvalidParamColumnIndex,
    SInvalidDataConversion,
    SColumnIsNotNullable,
    SBlobCannotBeRead,
    SBlobCannotBeWritten,
    SEmptyQuery,
    SCannotOpenNonSQLSelect,
    SNoFieldAccess,
    SFieldReadOnly,
    SFieldNotFound,
    SNotEditing,
    SCannotInsert,
    SCannotPost,
    SCannotUpdate,
    SCannotDelete,
    SCannotRefresh,
    SBufferNotSet,
    SCircularReference,
    SSQLParseError,
    SUserAbort,
    SDataSetUniDirectional,
    SCannotCreateSharedResource,
    SWindowsAPIError,
    SColumnListsDontMatch,
    SColumnTypesDontMatch,
    SCantEndSharedTransaction,
    SFieldUnsupportedType,
    SCircularDataLink,
    SEmptySQLStatement,
    SIsASelectStatement,
    SRequiredParamNotSet,
    SNoStoredProcName,
    SIsAExecuteProcedure,
    SUpdateFailed,
    SNotCachedUpdates,
    SNotLiveRequest,
    SNoProvider,
    SNoRecordsAffected,
    SNoTableName,
    SCannotCreatePrimaryIndex,
    SCannotDropSystemIndex,
    STableNameMismatch,
    SIndexFieldMissing,
    SInvalidCancellation,
    SInvalidEvent,
    SMaximumEvents,
    SNoEventsRegistered,
    SInvalidQueueing,
    SInvalidRegistration,
    SInvalidBatchMove,
    SSQLDialectInvalid,
    SSPBConstantNotSupported,
    SSPBConstantUnknown,
    SServiceActive,
    SServiceInActive,
    SServerNameMissing,
    SQueryParamsError,
    SStartParamsError,
    SOutputParsingError,
    SUseSpecificProcedures,
    SSQLMonitorAlreadyPresent,
    SCantPrintValue,
    SEOFReached,
    SEOFInComment,
    SEOFInString,
    SParamNameExpected,
    SSuccess,
    SDelphiException,
    SNoOptionsSet,
    SNoDestinationDirectory,
    SNosourceDirectory,
    SNoUninstallFile,
    SOptionNeedsClient,
    SOptionNeedsServer,
    SInvalidOption,
    SInvalidOnErrorResult,
    SInvalidOnStatusResult,
    SDPBConstantUnknownEx,
    STPBConstantUnknownEx,
    SUnknownPlan,
    SFieldSizeMismatch,
    SEventAlreadyRegistered,
    SStringTooLarge
  );

var
  IBCS: TRTLCriticalSection;

procedure IBAlloc(var P; OldSize, NewSize: Integer);

procedure IBError(ErrMess: TIBClientError; const Args: array of const);
procedure IBDataBaseError;

function StatusVector: PISC_STATUS;
function StatusVectorArray: PStatusVector;
function CheckStatusVector(ErrorCodes: array of ISC_STATUS): Boolean;
function StatusVectorAsText: string;

procedure SetIBDataBaseErrorMessages(Value: TIBDataBaseErrorMessages);
function GetIBDataBaseErrorMessages: TIBDataBaseErrorMessages;

{$IFDEF GEDEMIN}
function IntegerToTraceFlags(I: Integer): TTraceFlags;
function TraceFlagsToInteger(S: TTraceFlags): Integer;
{$ENDIF}

implementation

uses
  IBIntf
  {$IFDEF LOCALIZATION}
  , gd_localization
  {$ENDIF}
  {$IFDEF GEDEMIN}
  , IBSQL, IBDataBase, IBErrorCodes, gd_security, IBSQLMonitor_Gedemin
  {$ELSE}
  , IBSQLMonitor
  {$ENDIF};

var
  IBDataBaseErrorMessages: TIBDataBaseErrorMessages;
threadvar
  FStatusVector : TStatusVector;

{$IFDEF GEDEMIN}
var
  ExceptionCache: TStringList;
  CheckExceptionCache: TStringList;

function IntegerToTraceFlags(I: Integer): TTraceFlags;
var
  T: TTraceFlag;
begin
  Result := [];
  for T := Low(TTraceFlag) to High(TTraceFlag) do
  begin
    if (I and (1 shl Integer(T))) <> 0 then
      Include(Result, T);
  end;
end;

function TraceFlagsToInteger(S: TTraceFlags): Integer;
var
  T: TTraceFlag;
begin
  Result := 0;
  for T := Low(TTraceFlag) to High(TTraceFlag) do
  begin
    if T in S then
      Result := Result or (1 shl Integer(T));
  end;
end;
{$ENDIF}

procedure IBAlloc(var P; OldSize, NewSize: Integer);
begin
  if Assigned(Pointer(P)) then
    ReallocMem(Pointer(P), NewSize)
  else
    GetMem(Pointer(P), NewSize);
  if NewSize > OldSize then
    FillChar(PChar(P)[OldSize], NewSize - OldSize, 0);
end;

procedure IBError(ErrMess: TIBClientError; const Args: array of const);
begin
  if ErrMess <> ibxeCannotCreateSharedResource then
    MonitorHook.SendError(Format(IBErrorMessages[ErrMess], Args));
  raise EIBClientError.Create(Ord(ErrMess),
          Format(IBErrorMessages[ErrMess], Args));
end;

{$IFDEF GEDEMIN}
{!!!!!b Необходимо каким-то образом локализовать сие сообщение. По другому не получилось...}
function LocalizeMsg(const usr_msg: String): String;
begin
  Result := usr_msg;

  {$IFDEF GED_LOC_RUS}

  //  violation of FOREIGN KEY constraint "AT_FK_RELATIONS_EDITORKEY" on table "AT_RELATIONS
  if (AnsiPos('violation of FOREIGN KEY constraint', Result) > 0) and
    (AnsiPos('on table', Result) > 0) then
  begin
    Result := StringReplace(Result,
      'violation of FOREIGN KEY constraint',
      {$IFDEF LOCALIZATION}Translate({$ENDIF}'Нарушение ссылочной целостности. Внешний ключ'{$IFDEF LOCALIZATION}, nil, True){$ENDIF},
      [rfIgnoreCase]);
    Result := StringReplace(Result,
      'on table',
      {$IFDEF LOCALIZATION}Translate({$ENDIF}'в таблице'{$IFDEF LOCALIZATION}, nil, True){$ENDIF},
      [rfIgnoreCase]);
    exit;
  end;

  //'violation of PRIMARY or UNIQUE KEY constraint "GD_PK_COMMAND_ID" on table "GD_COMMAND"'
  if (AnsiPos('violation of PRIMARY or UNIQUE KEY constraint', Result) > 0) and
    (AnsiPos('on table', Result) > 0) then
  begin
    Result := StringReplace(usr_msg,
      'violation of PRIMARY or UNIQUE KEY constraint',
      {$IFDEF LOCALIZATION}Translate({$ENDIF}'Нарушение условий первичного или уникального ключа'{$IFDEF LOCALIZATION}, nil, True){$ENDIF},
      [rfIgnoreCase]);
    Result := StringReplace(Result,
      'on table',
      {$IFDEF LOCALIZATION}Translate({$ENDIF}'в таблице'{$IFDEF LOCALIZATION}, nil, True){$ENDIF},
      [rfIgnoreCase]);
    exit;
  end;

  if (AnsiPos('unsuccessful metadata update', Result) > 0) then
  begin
    Result := StringReplace(Result,
      'unsuccessful metadata update',
      {$IFDEF LOCALIZATION}Translate({$ENDIF}'Неудачное обновление метаданных:'{$IFDEF LOCALIZATION}, nil, True){$ENDIF},
      [rfIgnoreCase]);
  end;

  //'unsuccessful metadata update'#$D#$A'Procedure AC_CIRCULATIONLIST already exists'
  if (AnsiPos('already exists', Result) > 0) then
  begin
    Result := StringReplace(Result,
      'procedure',
      {$IFDEF LOCALIZATION}Translate({$ENDIF}'процедура'{$IFDEF LOCALIZATION}, nil, True){$ENDIF},
      [rfIgnoreCase]);
    Result := StringReplace(Result,
      'table',
      {$IFDEF LOCALIZATION}Translate({$ENDIF}'таблица'{$IFDEF LOCALIZATION}, nil, True){$ENDIF},
      [rfIgnoreCase]);
    Result := StringReplace(Result,
      'already exists',
      {$IFDEF LOCALIZATION}Translate({$ENDIF}'уже существует'{$IFDEF LOCALIZATION}, nil, True){$ENDIF},
      [rfIgnoreCase]);
    exit;
  end;

  //'unsuccessful metadata update'#$D#$A'DEFINE FUNCTION failed'#$D#$A'attempt to store duplicate value
  //(visible to active transactions) in unique index "RDB$INDEX_9"'
  if (AnsiPos('attempt to store duplicate value (visible to active transactions) in unique index', Result) > 0) then
  begin
    Result := StringReplace(Result,
      'attempt to store duplicate value (visible to active transactions) in unique index',
      {$IFDEF LOCALIZATION}Translate({$ENDIF}'попытка сохранить дублирующиеся значения (видимые в активной транзакции) в уникальном индексе'{$IFDEF LOCALIZATION}, nil, True){$ENDIF},
      [rfIgnoreCase]);
    exit;
  end;

  //'unsuccessful metadata update'#$D#$A'
  //Column not found for table
  if (AnsiPos('Column not found for table', Result) > 0) then
  begin
    Result := StringReplace(Result,
      'Column not found for table',
      {$IFDEF LOCALIZATION}Translate({$ENDIF}'В таблице не найдена колонка'{$IFDEF LOCALIZATION}, nil, True){$ENDIF},
      [rfIgnoreCase]);
    exit;
  end;

  //  'Operation violates CHECK constraint INTEG_45 on view or table BN_BANKSTATEMENTLINE'
  if (AnsiPos('Operation violates CHECK constraint', Result) > 0) and
    (AnsiPos('on view or table', Result) > 0) then
  begin
    Result := StringReplace(Result,
      'Operation violates CHECK constraint',
      {$IFDEF LOCALIZATION}Translate({$ENDIF}'Нарушение условий ограничения'{$IFDEF LOCALIZATION}, nil, True){$ENDIF},
      [rfIgnoreCase]);
    Result := StringReplace(Result,
      'on view or table',
      {$IFDEF LOCALIZATION}Translate({$ENDIF}'на представлении или таблице'{$IFDEF LOCALIZATION}, nil, True){$ENDIF},
      [rfIgnoreCase]);
    exit;
  end;

  //'lock conflict on no wait transaction'#$D#$A'deadlock'
  if (AnsiPos('lock conflict on no wait transaction', Result) > 0) then
  begin
    Result := StringReplace(Result,
      'lock conflict on no wait transaction',
      {$IFDEF LOCALIZATION}Translate({$ENDIF}'Ошибка при совместном доступе к объекту.'#13#10 +
      'Объект заблокирован другой транзакцией (lock conflict on no wait transaction)'#13#10{$IFDEF LOCALIZATION}, nil, True){$ENDIF},
      [rfIgnoreCase]);
    exit;
  end;

  //'validation error for column CONTACTKEY, value "0"'
  if (AnsiPos('validation error for column', Result) > 0) and
    (AnsiPos('value', Result) > 0) then
  begin
    Result := StringReplace(Result,
      'validation error for column',
      {$IFDEF LOCALIZATION}Translate({$ENDIF}'ошибка при проверке поля'{$IFDEF LOCALIZATION}, nil, True){$ENDIF},
      [rfIgnoreCase]);
    Result := StringReplace(Result,
      'value',
      {$IFDEF LOCALIZATION}Translate({$ENDIF}'значение'{$IFDEF LOCALIZATION}, nil, True){$ENDIF},
      [rfIgnoreCase]);
    exit;
  end;

  {$ENDIF}

end;

resourcestring
  cst_res_exception_rus = 'Исключение';

{Локализует эксепшены из базы, используя таблицу at_exceptions}
function LocalizeException(const msg: String): String;
const
  cst_word_exception = 'exception';

var
  ibsql: TIBSQL;
  Tr: TIBTransaction;
  sqlcode: String;
  i: Integer;
begin
{exception 53'#D#A'Exception body}
  Result := msg;

  if Assigned(IBLogin) and Assigned(IBLogin.Database) and IBLogin.Database.Connected then
  begin
    if AnsiPos(cst_word_exception, Trim(AnsiLowerCase(msg))) = 1 then
    begin
      //Считаем кэш для исключений. В кэше - только локализованные исключения
      if not Assigned(ExceptionCache) then
      begin
        ExceptionCache := TStringList.Create;
        ExceptionCache.Sorted := True;
        ExceptionCache.Duplicates := dupIgnore;

        tr := TIBTransaction.Create(nil);
        ibsql := TIBSQL.Create(nil);
        try
          try
            if Assigned(IBLogin) then
              tr.DefaultDatabase := IBLogin.Database;
            tr.StartTransaction;
            ibsql.Transaction := tr;
            ibsql.SQL.Text := 'SELECT * FROM at_exceptions a ' +
              ' JOIN rdb$exceptions e ON e.rdb$exception_name = a.exceptionname  ' +
              ' WHERE lmessage IS NOT NULL';
            ibsql.ExecQuery;
            while not ibsql.Eof do
            begin
              if Trim(ibsql.FieldByName('lmessage').AsString) > '' then
                ExceptionCache.Add(ibsql.FieldByName('rdb$exception_number').AsString + '=' +
                  {$IFDEF LOCALIZATION}Translate({$ENDIF}ibsql.FieldByName('lmessage').AsString{$IFDEF LOCALIZATION}, nil, True){$ENDIF});
              ibsql.Next;
            end;
            tr.Commit;
          except
            if tr.InTransaction then
              tr.Rollback;
          end;
        finally
          tr.Free;
          ibsql.Free;
        end;
      end;

      {Выделим код исключения}
      sqlcode := Copy(msg, Length(cst_word_exception) + 1, Length(msg) - Length(cst_word_exception));
      sqlcode := Trim(sqlcode);

      for I := 1 to Length(sqlcode) do
        if not (sqlcode[I] in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) then Break;

      if I > 1 then
      begin
        SetLength(sqlcode, I - 1);
        {по коду найдем локализованное исключение}
        if ExceptionCache.IndexOfName(sqlcode) > -1 then
        begin
          Result := cst_res_exception_rus +
            ' '+
            sqlcode + #13#10 +
            ExceptionCache.Values[sqlcode];
        end;
      end;
    end;
  end;  
end;

function LocalizeCheckException(const msg: String): String;
const
  cst_word_exception = 'Operation violates CHECK constraint';
  cst_table = 'on view or table';
var
  TableName: String;
  CheckName: String;
  i, k: Integer;

  procedure FillCheckExceptionCache(S: String);
  var
    ibsql: TIBSQL;
    Tr: TIBTransaction;
  begin
    if (Length(S) = 0) or (Length(S) > 31) then
      exit; 

    tr := TIBTransaction.Create(nil);
    ibsql := TIBSQL.Create(nil);
    try
      try
        if Assigned(IBLogin) then
          tr.DefaultDatabase := IBLogin.Database;
        tr.StartTransaction;
        ibsql.Transaction := tr;
        ibsql.SQL.Text := ' SELECT Z.MSG, Z.CHECKNAME ' +
          ' FROM AT_CHECK_CONSTRAINTS Z ' +
          ' LEFT JOIN RDB$CHECK_CONSTRAINTS C ON C.RDB$CONSTRAINT_NAME = Z.CHECKNAME ' +
          ' LEFT JOIN RDB$TRIGGERS T ON T.RDB$TRIGGER_NAME  =  C.RDB$TRIGGER_NAME ' +
          ' WHERE T.RDB$TRIGGER_TYPE = 1 ' +
          '   AND T.RDB$RELATION_NAME = :relationname';
        ibsql.ParamByName('relationname').AsString := S;
        ibsql.ExecQuery;
        while not ibsql.Eof do
        begin
          if Trim(ibsql.FieldByName('MSG').AsString) > '' then
            CheckExceptionCache.Add(ibsql.FieldByName('CHECKNAME').AsString + '=' +
              {$IFDEF LOCALIZATION}Translate({$ENDIF}ibsql.FieldByName('MSG').AsString{$IFDEF LOCALIZATION}, nil, True){$ENDIF});
          ibsql.Next;
        end;
        tr.Commit;
      except
        if tr.InTransaction then
          tr.Rollback;
      end;
    finally
      tr.Free;
      ibsql.Free;
    end;
  end;

begin
  Result := msg;
{Operation violates CHECK constraint USR$CHECK_USR$WG_MOVEMENTLINE61 on view or table USR$WG_MOVEMENTLINE}
  if AnsiPos(AnsiLowerCase(cst_word_exception), Trim(AnsiLowerCase(msg))) = 1 then
  begin
    TableName := Copy(msg, Pos(cst_table, msg) + Length(cst_table) + 1, Length(msg));

    k := Length(cst_word_exception) + 2;
    for i := k to Length(msg) do
      if msg[i] = ' ' then Break;

    CheckName := Copy(msg, k, i - k);

    if not Assigned(CheckExceptionCache) then
    begin
      CheckExceptionCache := TStringList.Create;
      CheckExceptionCache.Sorted := True;
      CheckExceptionCache.Duplicates := dupIgnore;

      FillCheckExceptionCache(TableName);
    end;

    if CheckExceptionCache.IndexOfName(CheckName) > -1 then
      Result := CheckExceptionCache.Values[CheckName]
    else begin  //т.к. изначально заполняем кэш только для одной таблицы
      FillCheckExceptionCache(TableName);
      if CheckExceptionCache.IndexOfName(CheckName) > -1 then
        Result := CheckExceptionCache.Values[CheckName];
    end;
  end;
end;
{$ENDIF}
{!!!!!e}

procedure IBDataBaseError;
var
  sqlcode: Long;
  IBErrorCode: Long;
  local_buffer: array[0..IBHugeLocalBufferLength - 1] of char;
  usr_msg: string;
  status_vector: PISC_STATUS;
  IBDataBaseErrorMessages: TIBDataBaseErrorMessages;
begin
  usr_msg := '';

  { Get a local reference to the status vector.
    Get a local copy of the IBDataBaseErrorMessages options.
    Get the SQL error code }
  status_vector := StatusVector;
  IBErrorCode := StatusVectorArray[1];
  IBDataBaseErrorMessages := GetIBDataBaseErrorMessages;
  sqlcode := isc_sqlcode(status_vector);

  if (ShowSQLCode in IBDataBaseErrorMessages) then
    usr_msg := usr_msg + 'SQLCODE: ' + IntToStr(sqlcode); {do not localize}
  Exclude(IBDataBaseErrorMessages, ShowSQLMessage);
  if (ShowSQLMessage in IBDataBaseErrorMessages) then
  begin
    isc_sql_interprete(sqlcode, local_buffer, IBLocalBufferLength);
    if (ShowSQLCode in IBDataBaseErrorMessages) then
      usr_msg := usr_msg + CRLF;
    usr_msg := usr_msg + string(local_buffer);
  end;

  if (ShowIBMessage in IBDataBaseErrorMessages) then
  begin
    if (ShowSQLCode in IBDataBaseErrorMessages) or
       (ShowSQLMessage in IBDataBaseErrorMessages) then
      usr_msg := usr_msg + CRLF;
    while (isc_interprete(local_buffer, @status_vector) > 0) do
    begin
      if (usr_msg <> '') and (usr_msg[Length(usr_msg)] <> LF) then
        usr_msg := usr_msg + CRLF;
      usr_msg := usr_msg + string(local_buffer);
    end;
  end;
  if (usr_msg <> '') and (usr_msg[Length(usr_msg)] = '.') then
    Delete(usr_msg, Length(usr_msg), 1);
  MonitorHook.SendError(IntToStr(sqlcode) + ' ' + IntToStr(IBErrorCode) + ' ' + usr_msg);
  {$IFDEF GEDEMIN}
  if IBErrorCode = isc_except then
    {Локализация эксепшена из БД, используя таблицу at_exceptions}
    usr_msg := LocalizeException(usr_msg)
  else if IBErrorCode = isc_check_constraint then
    usr_msg := LocalizeCheckException(usr_msg)
  else
    {Локализация эксепшена выдаваемого ограничениями БД}
    usr_msg := LocalizeMsg(usr_msg);
  {$ENDIF}
  if sqlcode <> -551 then
    raise EIBInterBaseError.Create(sqlcode, IBErrorCode, usr_msg)
  else
    raise EIBInterBaseRoleError.Create(sqlcode, IBErrorCode, usr_msg)
end;

{ Return the status vector for the current thread }
function StatusVector: PISC_STATUS;
begin
  result := @FStatusVector;
end;

function StatusVectorArray: PStatusVector;
begin
  result := @FStatusVector;
end;

function CheckStatusVector(ErrorCodes: array of ISC_STATUS): Boolean;
var
  p: PISC_STATUS;
  i: Integer;
  procedure NextP(i: Integer);
  begin
    p := PISC_STATUS(PChar(p) + (i * SizeOf(ISC_STATUS)));
  end;
begin
  p := @FStatusVector;
  result := False;
  while (p^ <> 0) and (not result) do
    case p^ of
      3: NextP(3);
      1, 4:
      begin
        NextP(1);
        i := 0;
        while (i <= High(ErrorCodes)) and (not result) do
        begin
          result := p^ = ErrorCodes[i];
          Inc(i);
        end;
        NextP(1);
      end;
      else
        NextP(2);
    end;
end;

function StatusVectorAsText: string;
var
  p: PISC_STATUS;
  function NextP(i: Integer): PISC_STATUS;
  begin
    p := PISC_STATUS(PChar(p) + (i * SizeOf(ISC_STATUS)));
    result := p;
  end;
begin
  p := @FStatusVector;
  result := '';
  while (p^ <> 0) do
    if (p^ = 3) then
    begin
      result := result + Format('%d %d %d', [p^, NextP(1)^, NextP(1)^]) + CRLF;
      NextP(1);
    end
    else begin
      result := result + Format('%d %d', [p^, NextP(1)^]) + CRLF;
      NextP(1);
    end;
end;

{ EIBError }
constructor EIBError.Create(ASQLCode: Long; Msg: string);
begin
  inherited Create(Msg);
  FSQLCode := ASQLCode;
end;

constructor EIBError.Create(ASQLCode: Long; AIBErrorCode: Long; Msg: string);
begin
  inherited Create(Msg);
  FSQLCode :=  ASQLCode;
  FIBErrorCode := AIBErrorCode;
end;

procedure SetIBDataBaseErrorMessages(Value: TIBDataBaseErrorMessages);
begin
  EnterCriticalSection(IBCS);
  try
    IBDataBaseErrorMessages := Value;
  finally
    LeaveCriticalSection(IBCS);
  end;
end;

function GetIBDataBaseErrorMessages: TIBDataBaseErrorMessages;
begin
  EnterCriticalSection(IBCS);
  try
    result := IBDataBaseErrorMessages;
  finally
    LeaveCriticalSection(IBCS);
  end;
end;

initialization
  IsMultiThread := True;
  InitializeCriticalSection(IBCS);
  IBDataBaseErrorMessages := [ShowSQLMessage, ShowIBMessage];
  {$IFDEF GEDEMIN}
    ExceptionCache := nil;
    CheckExceptionCache := nil;
  {$ENDIF}

finalization
  DeleteCriticalSection(IBCS);
  {$IFDEF GEDEMIN}
    if Assigned(ExceptionCache) then
       ExceptionCache.Free;
    if Assigned(CheckExceptionCache) then
      CheckExceptionCache.Free;
  {$ENDIF}
end.
