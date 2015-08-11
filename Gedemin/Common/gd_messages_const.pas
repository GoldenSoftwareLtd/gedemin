
unit gd_messages_const;

interface

uses
  Messages;

const
  // gsTrayIcon
  WM_TOOLTRAYICON              = WM_USER + 1;
  WM_RESETTOOLTIP              = WM_USER + 2;

  // xCalculatorEdit
  WM_GD_CALC_FORMAT            = WM_USER + 18;

  // dlg_gsProperty_ColectEdit_unit
  AM_DeferUpdate               = WM_USER + 100;  // avoids break-before-make listview ugliness

  // rp_report_const
  WM_USER_CLOSE                = WM_USER + 200;
  WM_USER_PARAM                = WM_USER + 201;
  WM_USER_REFRESH              = WM_USER + 202;
  WM_USER_REBUILD              = WM_USER + 203;
  WM_USER_PRMSG_ADDREF         = WM_USER + 204;
  WM_USER_PRMSG_RELEASE        = WM_USER + 205;
  WM_USER_RESET                = WM_USER + 206;
  WM_USER_CLOSE_PROMT          = WM_USER + 207;

  // gdcFKManager
  WM_UPDATESTATS               = WM_USER + 377;

  // gdNamespaceLoader
  WM_LOAD_NAMESPACE            = WM_USER + 1001;

  // gsResizerInterface
  CM_NEWCONTROL                = WM_USER + 1025;
  CM_RESIZECONTROL             = WM_USER + 1026;
  CM_SHOWMENU                  = WM_USER + 1027;
  CM_ADDCONTROL                = WM_USER + 1028;
  CM_INSERTNEW                 = WM_USER + 1029;
  CM_SHOWINSPECTOR             = WM_USER + 1030;
  CM_SHOWPALETTE               = WM_USER + 1031;
  CM_NEWCONTROLR               = WM_USER + 1032;
  CM_PROPERTYCHANGED           = WM_USER + 1033;
  WM_USER_MOUSEMOVE            = WM_USER + 1034;
  WM_USER_LBUTTONUP            = WM_USER + 1035;
  CM_INSERTNEW2                = WM_USER + 1036;
  CM_DELETECONTROL             = WM_USER + 1037;
  CM_SHOWEVENTS                = WM_USER + 1038;
  CM_SHOWEDITFORM              = WM_USER + 1039;

  // messaged thread
  WM_GD_THREAD_USER            = WM_USER + 1000;
  WM_GD_EXIT_THREAD            = WM_USER + 117;
  WM_GD_UPDATE_TIMER           = WM_USER + 118;

  // db squeeze
  WM_DBS_TEST                  = WM_GD_THREAD_USER + 12;

  WM_DBS_SETPARAMS             = WM_GD_THREAD_USER + 4;
  WM_DBS_CONNECT               = WM_GD_THREAD_USER + 6;

  WM_DBS_SETDOCTYPESRINGS      = WM_GD_THREAD_USER + 7;

  WM_DBS_GETCARDFEATURES       = WM_GD_THREAD_USER + 8;

  WM_DBS_CREATEDBSSTATEJOURNAL = WM_GD_THREAD_USER + 9;
  WM_DBS_GETDBPROPERTIES       = WM_GD_THREAD_USER + 10;
  WM_DBS_SETCLOSINGDATE        = WM_GD_THREAD_USER + 11;

  WM_DBS_SETSALDOPARAMS        = WM_GD_THREAD_USER + 13;
  WM_DBS_SETSELECTEDDOCTYPES   = WM_GD_THREAD_USER + 14;
  WM_DBS_GETSTATISTICS_INVCARD = WM_GD_THREAD_USER + 15;
  WM_DBS_GETSTATISTICS         = WM_GD_THREAD_USER + 16;
  WM_DBS_GETPROCSTATISTICS     = WM_GD_THREAD_USER + 17;
  WM_DBS_STARTPROCESSING       = WM_GD_THREAD_USER + 18;
  WM_DBS_STOPPROCESSING        = WM_GD_THREAD_USER + 19;
  WM_DBS_RECONNECT             = WM_GD_THREAD_USER + 20;
  WM_DBS_SETFVARIABLLES        = WM_GD_THREAD_USER + 21;
  WM_DBS_CREATEMETADATA        = WM_GD_THREAD_USER + 22;
  WM_DBS_SAVEMETADATA          = WM_GD_THREAD_USER + 23;
  WM_DBS_CALCULATEACSALDO      = WM_GD_THREAD_USER + 24;
  WM_DBS_CALCULATEINVSALDO     = WM_GD_THREAD_USER + 25;
  WM_DBS_UPDATEINVCARD         = WM_GD_THREAD_USER + 26;
  WM_DBS_PREPAREREBINDINVCARDS = WM_GD_THREAD_USER + 27;
  WM_DBS_CREATEHIS_INCLUDEHIS  = WM_GD_THREAD_USER + 28;
  WM_DBS_PREPAREDB             = WM_GD_THREAD_USER + 29;
  WM_DBS_DELETEOLDBALANCE      = WM_GD_THREAD_USER + 30;
  WM_DBS_DELETEDOCHIS          = WM_GD_THREAD_USER + 31;
  WM_DBS_CREATEACENTRIES       = WM_GD_THREAD_USER + 32;
  WM_DBS_CREATEINVSALDO        = WM_GD_THREAD_USER + 33;
  WM_DBS_RESTOREDB             = WM_GD_THREAD_USER + 34;
  WM_DBS_REBINDINVCARDS        = WM_GD_THREAD_USER + 35;
  WM_DBS_CLEARDBSTABLES        = WM_GD_THREAD_USER + 36;
  WM_DBS_FINISH                = WM_GD_THREAD_USER + 37;
  WM_DBS_FINISHED              = WM_GD_THREAD_USER + 38;
  WM_DBS_DISCONNECT            = WM_GD_THREAD_USER + 39;
  WM_DBS_CREATE_INV_BALANCE    = WM_GD_THREAD_USER + 40;
  WM_DBS_MERGECARDS            = WM_GD_THREAD_USER + 41;
  WM_STOPNOTIFY                = WM_GD_THREAD_USER + 42;

  WM_GD_FIND_AND_EXECUTE_TASK  = WM_GD_THREAD_USER + 101;
  WM_GD_LOAD_TASK_LIST         = WM_GD_THREAD_USER + 102;
  WM_GD_RELOAD_TASK_LIST       = WM_GD_THREAD_USER + 103;
  //WM_GD_OUTSIDE_LOG            = WM_GD_THREAD_USER + 104;
  WM_GD_FREE_EMAIL_MESSAGE     = WM_GD_THREAD_USER + 105;

  // gdWebClientControl
  WM_GD_AFTER_CONNECTION       = WM_USER + 1118;
  WM_GD_QUERY_SERVER           = WM_USER + 1119;
  WM_GD_GET_FILES_LIST         = WM_USER + 1120;
  WM_GD_UPDATE_FILES           = WM_USER + 1121;
  WM_GD_PROCESS_UPDATE_COMMAND = WM_USER + 1122;
  WM_GD_FINISH_UPDATE          = WM_USER + 1123;
  WM_GD_SEND_ERROR             = WM_USER + 1124;
  WM_GD_SEND_EMAIL             = WM_USER + 1125;

  // gdNotifierThread
  WM_GD_UPDATE_NOTIFIER        = WM_USER + 2001;

  // gsIBLookupComboBoxInterface
  WM_GD_SELECTDOCUMENT         = WM_USER + 2220;
  WM_GD_OPENACCTACCCARD        = WM_USER + 2221;

  // gsIBGrid
  CM_DOREDUCE                  = WM_USER + 1281;

  // gdWebClientControl
  WM_GD_FINISH_SEND_EMAIL      = WM_USER + 11126;

  // at_classes_body
  WM_STARTMULTITRANSACTION     = WM_USER + 12653;
  WM_LOGOFF                    = WM_USER + 12654;

  // gsDBGrid
  WM_CHANGEDISPLAYFORMTS       = WM_USER + 21782;

  // gd_security_body
  WM_FINISHOPENCOMPANY         = WM_USER + 25487;
  WM_CONNECTIONLOST            = WM_USER + 25488;

  // gd_main_form
  WM_GD_RELOGIN                = WM_USER + 25489;
  //WM_GD_RUNONLOGINMACROS     = WM_USER + 25490;

  // at_ActivateSetting
  WM_ACTIVATESETTING           = WM_USER + 30000;
  WM_DEACTIVATESETTING         = WM_USER + 30001;

implementation

end.