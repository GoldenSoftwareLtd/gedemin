unit rp_report_const;

interface

uses
  Messages;

const
  ServSymbol = '~!@#$%^&*()_-+=|\{}[];:''"?/><,.`� ';
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

  MainModuleName = 'REPORTMAIN';        // ������ ��� ������� ���������� �������
  ParamModuleName = 'REPORTPARAM';      // ������ ��� ������� ������� ����������
  EventModuleName = 'REPORTEVENT';      // ������ ��� ������� ��������� �������
  scrEventModuleName = 'EVENTS';
  scrMethodModuleName = 'METHOD';
  scrMacrosModuleName = 'MACROS';      //������ ��� ��������
  scrUnkonownModule = 'UNKNOWN';
  scrVBClasses = 'VBCLASSES';
  scrVariables = 'VARIABLES';
  scrConst = 'CONST';
  scrGlobalObject = 'GLOBALOBJECT';
  scrEntryModuleName = 'ENTRY';         //������ ��� ��������

  ReportObjectName = 'BaseQuery';       // ������������ ������� ��� ����������������
  DefaultLanguage = 'VBScript';         // ���� ��� ���������������� �������� �� ���������
  FrqRebuildReport = 1;                 // ������ ��������������� ��� � ����
  MinFrqRefresh = 3600000;              // ����� ������������ ���������� ������ � ����

  WM_USER_CLOSE = WM_USER + 200;
  WM_USER_PARAM = WM_USER + 201;
  WM_USER_REFRESH = WM_USER + 202;
  WM_USER_REBUILD = WM_USER + 203;
  WM_USER_PRMSG_ADDREF = WM_USER + 204;
  WM_USER_PRMSG_RELEASE = WM_USER + 205;
  WM_USER_RESET = WM_USER + 206;
  WM_USER_CLOSE_PROMT = WM_USER + 207;

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
  dfPasteError = '�� �������� �������� ������ �� ������ ������.';
  dfCopyError  = '�� ������� ��������� ������ � �����.';
  dfCopyName   = '%s%s';

type
  TTemplateType = (ttNone, ttRTF, ttFR, ttXFR, ttGRD, ttFR4);

type
  TActionType = (atAddGroup, atEditGroup, atDelGroup, atAddReport, atEditReport, atDelReport, atDefServer);

implementation

end.
