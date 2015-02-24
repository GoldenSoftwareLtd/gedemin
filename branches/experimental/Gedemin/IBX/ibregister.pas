
unit IBRegister;

interface

uses
  Classes,
  ib,
  IBBatchMove,
  ibblob,
  IBConnectionBroker,
  IBCustomDataSet,
  ibdatabase,
  ibdatabaseinfo,
  IBDatabaseINI,
  IBDialogs,
  iberrorcodes,
  ibevents,
  ibexternals,
  IBExtract,
  {IBFilterDialog,}
  {IBFilterSummary,}
  ibheader,
  IBInstall,
  IBInstallHeader,
  IBIntf,
  ibquery,
  IBScript,
  IBServices,
  IBSQL,
  ibsqlmonitor,
  ibstoredproc,
  ibtable,
  ibupdatesql,
  ibutils,
  IBXConst,
  IBXMLHeader;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('InterBase', [
    TIBBackupservice,
    TIBConfigService,
    TIBDatabase,
    TIBDatabaseInfo,
    TIBDataSet,
    TIBEvents,
    TIBExtract,
    TIBInstall,
    TIBLicensingService,
    TIBLogService,
    TIBQuery,
    TIBRestoreService,
    TIBSecurityService,
    TIBServerProperties,
    TIBSQL,
    TIBSQLMonitor,
    TIBStatisticalService,
    TIBStoredProc,
    TIBTable,
    TIBTransaction,
    TIBUnInstall,
    TIBUpdateSQL,
    TIBValidationService,
    TIBConnectionBroker,
    TIBDatabaseINI,
    {TIBFilterDialog,}
    TIBScript,
    TIBSQLParser,
    TIBStringField,
    TIBBCDField
  ]);
end;

end.
