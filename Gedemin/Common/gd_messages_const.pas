
unit gd_messages_const;

interface

uses
  Messages;
  
const
  // messaged thread
  WM_GD_THREAD_USER           = WM_USER + 1000;
  WM_GD_EXIT_THREAD           = WM_USER + 117;
  WM_GD_UPDATE_TIMER          = WM_USER + 118;

  WM_GD_FIND_AND_EXECUTE_TASK = WM_GD_THREAD_USER + 101;
  WM_GD_LOAD_TASK_LIST        = WM_GD_THREAD_USER + 102;
  WM_GD_RELOAD_TASK_LIST      = WM_GD_THREAD_USER + 103;
  WM_GD_OUTSIDE_LOG           = WM_GD_THREAD_USER + 104;

  WM_GD_FINISH_SEND_EMAIL     = WM_USER + 11126;

  WM_ACTIVATESETTING          = WM_USER + 30000;
  WM_DEACTIVATESETTING        = WM_USER + 30001;

  WM_STARTMULTITRANSACTION    = WM_USER + 12653;
  WM_LOGOFF                   = WM_USER + 12654;

  WM_LOAD_NAMESPACE           = WM_USER + 1001;

  WM_GD_UPDATE_NOTIFIER       = WM_USER + 2001;

  WM_GD_AFTER_CONNECTION      = WM_USER + 1118;
  WM_GD_QUERY_SERVER          = WM_USER + 1119;
  WM_GD_GET_FILES_LIST        = WM_USER + 1120;
  WM_GD_UPDATE_FILES          = WM_USER + 1121;
  WM_GD_PROCESS_UPDATE_COMMAND= WM_USER + 1122;
  WM_GD_FINISH_UPDATE         = WM_USER + 1123;
  WM_GD_SEND_ERROR            = WM_USER + 1124;
  WM_GD_SEND_EMAIL            = WM_USER + 1125;

  WM_GD_RELOGIN               = WM_USER + 25488;
  //WM_GD_RUNONLOGINMACROS    = WM_USER + 25489;

  WM_FINISHOPENCOMPANY        = WM_USER + 25487;
  WM_CONNECTIONLOST           = WM_USER + 25488;

implementation

end.