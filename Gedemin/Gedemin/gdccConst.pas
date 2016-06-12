
unit gdccConst;

interface

uses
  Messages;

const
  gdccDefPort             = 47900;
  gdccDefAddress          = '127.0.0.1';
  gdccMutexName           = 'gdccMutex';
  gdccVersion             = 4;

  WM_GDCC_SERVER_NOTIFY   = WM_USER + 4299;
  WM_GDCC_SERVER_CLOSE    = WM_USER + 4300;

  gdcc_Signature          = 1718192021;
  gdcc_Version            = 1;

  gdcc_cmd_Unknown        = 0;
  gdcc_cmd_Connect        = 1;
  gdcc_cmd_Disconnect     = 2;
  gdcc_cmd_AckConnect     = 3;
  gdcc_cmd_Hello          = 4;
  gdcc_cmd_ServerClosing  = 5;
  gdcc_cmd_StartWork      = 6;
  gdcc_cmd_EndWork        = 7;
  gdcc_cmd_StartStep      = 8;
  gdcc_cmd_Record         = 9;
  gdcc_cmd_CancelProgress = 10;
  gdcc_cmd_UserShowLog    = 11;
  gdcc_cmd_ShowLog        = 12;
  gdcc_cmd_Process        = 13;
  gdcc_cmd_GetLog         = 14;
  gdcc_cmd_LogTransfered  = 15;

  // битовые маски!
  gdcc_lt_Info            = $1;
  gdcc_lt_Warning         = $2;
  gdcc_lt_Error           = $4;

implementation

end.