// ShlTanya, 27.02.2019

unit rp_report_const;

interface

uses
  Messages;

const
  ServSymbol = '~!@#$%^&*()_-+=|\{}[];:''"?/><,.`№ ';
  NameSymbol = 'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM_0123456789';

  ServerReportName = 'REPORTSERVEREVENT';

  VarBegin = 'VariantStart';
  VarEnd   = 'VariantFinish';

  ReportNone = '';
  ReportRTF  = 'RTF';
  ReportFR   = 'FR';
  ReportXFR  = 'XFR';
  ReportGRD  = 'GRD';
  ReportFR4  = 'FR4';

  MainModuleName = 'REPORTMAIN';        // Модуль для функций построения отчетов
  ParamModuleName = 'REPORTPARAM';      // Модуль для функций запроса параметров
  EventModuleName = 'REPORTEVENT';      // Модуль для функций обработки событий
  scrEventModuleName = 'EVENTS';
  scrMethodModuleName = 'METHOD';
  scrMacrosModuleName = 'MACROS';      //Модуль для макросов
  scrUnkonownModule = 'UNKNOWN';
  scrVBClasses = 'VBCLASSES';
  scrVariables = 'VARIABLES';
  scrConst = 'CONST';
  scrGlobalObject = 'GLOBALOBJECT';
  scrEntryModuleName = 'ENTRY';         //Модуль для проводок
  scrPrologModuleName = 'PROLOG';

  ReportObjectName = 'BaseQuery';       // Наименование объекта для программирования
  DefaultLanguage = 'VBScript';         // Язык для программирования скриптов по умолчанию
  FrqRebuildReport = 1;                 // Отчеты перестраиваются раз в день
  MinFrqRefresh = 3600000;              // Время минимального обновления данных в мсек

  DefaultTCPPort = 2048;
  rpStartBlock = 'STARTBUFFER';
  rpFinishBlock = 'FINISHBUFFER';

const
  ResultSelectSQL = 'SELECT * FROM rp_reportresult';
  ResultInsertSQL = 'INSERT INTO rp_reportresult ' +
  '(FUNCTIONKEY, CRCPARAM, PARAMORDER, RESULTDATA, CREATEDATE, EXECUTETIME, ' +
  ' LASTUSEDATE, RESERVED, PARAMDATA) ' +
  ' VALUES(:FUNCTIONKEY, :CRCPARAM, :PARAMORDER, :RESULTDATA, :CREATEDATE, ' +
  ' :EXECUTETIME, :LASTUSEDATE, :RESERVED, :PARAMDATA)';
  ResultUpdateSQL = 'UPDATE rp_reportresult SET ' +
      'FUNCTIONKEY = :FUNCTIONKEY, ' +
      'CRCPARAM = :CRCPARAM, ' +
      'PARAMORDER = :PARAMORDER, ' +
      'RESULTDATA = :RESULTDATA, ' +
      'CREATEDATE = :CREATEDATE, ' +
      'EXECUTETIME = :EXECUTETIME, ' +
      'LASTUSEDATE = :LASTUSEDATE, ' +
      'RESERVED = :RESERVED, ' +
      'PARAMDATA = :PARAMDATA ' +
      ' WHERE ' +
      'FUNCTIONKEY = :OLD_FUNCTIONKEY AND ' +
      'CRCPARAM = :OLD_CRCPARAM AND ' +
      'PARAMORDER = :OLD_PARAMORDER';
//  ResultRefreshSQL = 'SELECT * FROM rp_reportresult';
  ResultDeleteSQL = 'DELETE FROM rp_reportresult ' +
      ' WHERE ' +
      'FUNCTIONKEY = :OLD_FUNCTIONKEY AND ' +
      'CRCPARAM = :OLD_CRCPARAM AND ' +
      'PARAMORDER = :OLD_PARAMORDER';
  ResultOrderSQL = ' ORDER BY paramorder ';

  ReportResultIndex = 'FUNCTIONKEY;CRCPARAM;PARAMORDER';

const
  rpTempPrefix = '~gs';
  rpTempDir = '~gsReport\';

const
  dfPasteError = 'Не возможно вставить данные из буфера обмена.';
  dfCopyError  = 'Не удалось сохранить данные в буфер.';
  dfCopyName   = '%s%s';

type
  TTemplateType = (ttNone, ttRTF, ttFR, ttXFR, ttGRD, ttFR4);

type
  TActionType = (atAddGroup, atEditGroup, atDelGroup, atAddReport, atEditReport, atDelReport, atDefServer);

implementation

end.
