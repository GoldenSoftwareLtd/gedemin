{*******************************************************************}
{                                                                   }
{       Almediadev Visual Component Library                         }
{       BusinessSkinForm                                            }
{       Version 10.20                                               }
{                                                                   }
{       Copyright (c) 2000-2013 Almediadev                          }
{       ALL RIGHTS RESERVED                                         }
{                                                                   }
{       Home:  http://www.almdev.com                                }
{       Support: support@almdev.com                                 }
{                                                                   }
{*******************************************************************}

unit bsconst;

{$I bsdefine.inc}

interface

resourcestring

  BS_MI_MINCAPTION = 'Mi&nimize';
  BS_MI_MAXCAPTION = 'Ma&ximize';
  BS_MI_CLOSECAPTION = '&Close';
  BS_MI_RESTORECAPTION = '&Restore';
  BS_MI_MINTOTRAYCAPTION = 'Minimize to &Tray';
  BS_MI_ROLLUPCAPTION = 'Ro&llUp';

  BS_MINBUTTON_HINT = 'Minimize';
  BS_MAXBUTTON_HINT = 'Maximize';
  BS_CLOSEBUTTON_HINT = 'Close';
  BS_TRAYBUTTON_HINT = 'Minimize to Tray';
  BS_ROLLUPBUTTON_HINT = 'Roll Up';
  BS_MENUBUTTON_HINT = 'System menu';
  BS_RESTORE_HINT = 'Restore';

  BS_EDIT_UNDO = 'Undo';
  BS_EDIT_COPY = 'Copy';
  BS_EDIT_CUT = 'Cut';
  BS_EDIT_PASTE = 'Paste';
  BS_EDIT_DELETE = 'Delete';
  BS_EDIT_SELECTALL = 'Select All';

  BS_MSG_BTN_YES = '&Yes';
  BS_MSG_BTN_NO = '&No';
  BS_MSG_BTN_OK = 'OK';
  BS_MSG_BTN_CLOSE = 'Close';
  BS_MSG_BTN_CANCEL = 'Cancel';
  BS_MSG_BTN_ABORT = '&Abort';
  BS_MSG_BTN_RETRY = '&Retry';
  BS_MSG_BTN_IGNORE = '&Ignore';
  BS_MSG_BTN_ALL = '&All';
  BS_MSG_BTN_NOTOALL = 'N&oToAll';
  BS_MSG_BTN_YESTOALL = '&YesToAll';
  BS_MSG_BTN_HELP = '&Help';
  BS_MSG_BTN_OPEN = '&Open';
  BS_MSG_BTN_SAVE = '&Save';

  BS_MSG_BTN_BACK_HINT = 'Go To Last Folder Visited';
  BS_MSG_BTN_UP_HINT = 'Up One Level';
  BS_MSG_BTN_NEWFOLDER_HINT = 'Create New Folder';
  BS_MSG_BTN_VIEWMENU_HINT = 'View Menu';
  BS_MSG_BTN_STRETCH_HINT = 'Stretch Picture';


  BS_MSG_FILENAME = 'File name:';
  BS_MSG_FILETYPE = 'File type:';
  BS_MSG_NEWFOLDER = 'New Folder';
  BS_MSG_LV_DETAILS = 'Details';
  BS_MSG_LV_ICON = 'Large icons';
  BS_MSG_LV_SMALLICON = 'Small icons';
  BS_MSG_LV_LIST = 'List';
  BS_MSG_PREVIEWSKIN = 'Preview';
  BS_MSG_PREVIEWBUTTON = 'Button';
  BS_MSG_OVERWRITE = 'Do you want to overwrite old file?';

  BS_MSG_CAP_WARNING = 'Warning';
  BS_MSG_CAP_ERROR = 'Error';
  BS_MSG_CAP_INFORMATION = 'Information';
  BS_MSG_CAP_CONFIRM = 'Confirm';
  BS_MSG_CAP_SHOWFLAG = 'Do not display this message again';

  BS_CALC_CAP = 'Calculator';
  BS_ERROR = 'Error';

  BS_COLORGRID_CAP = 'Basic colors';
  BS_CUSTOMCOLORGRID_CAP = 'Custom colors';
  BS_ADDCUSTOMCOLORBUTTON_CAP = 'Add to Custom Colors';

  BS_FONTDLG_COLOR = 'Color:';
  BS_FONTDLG_NAME = 'Name:';
  BS_FONTDLG_SIZE = 'Size:';
  BS_FONTDLG_HEIGHT = 'Height:';
  BS_FONTDLG_EXAMPLE = 'Example:';
  BS_FONTDLG_STYLE = 'Style:';
  BS_FONTDLG_SCRIPT = 'Script:';

  BS_DBNAV_FIRST_HINT = 'FirstRecord';
  BS_DBNAV_PRIOR_HINT = 'PriorRecord';
  BS_DBNAV_NEXT_HINT = 'NextRecord';
  BS_DBNAV_LAST_HINT = 'LastRecord';
  BS_DBNAV_INSERT_HINT = 'InsertRecord';
  BS_DBNAV_DELETE_HINT = 'DeleteRecord';
  BS_DBNAV_EDIT_HINT = 'EditRecord';
  BS_DBNAV_POST_HINT = 'PostEdit';
  BS_DBNAV_CANCEL_HINT = 'CancelEdit';
  BS_DBNAV_REFRESH_HINT = 'RefreshRecord';

  BS_DB_DELETE_QUESTION = 'Delete record?';
  BS_DB_MULTIPLEDELETE_QUESTION = 'Delete all selected records?';

  BS_NODISKINDRIVE = 'There is no disk in Drive or Drive is not ready';
  BS_NOVALIDDRIVEID = 'Not a valid Drive ID';

  BS_FLV_NAME = 'Name';
  BS_FLV_SIZE = 'Size';
  BS_FLV_TYPE = 'Type';
  BS_FLV_LOOKIN = 'Look in: ';
  BS_FLV_MODIFIED = 'Modified';
  BS_FLV_ATTRIBUTES = 'Attributes';
  BS_FLV_DISKSIZE = 'Disk Size';
  BS_FLV_FREESPACE = 'Free Space';

  BS_PRNSTATUS_Paused = 'Paused';
  BS_PRNSTATUS_PendingDeletion = 'Pending Deletion';
  BS_PRNSTATUS_Busy = 'Busy';
  BS_PRNSTATUS_DoorOpen = 'Door Open';
  BS_PRNSTATUS_Error = 'Error';
  BS_PRNSTATUS_Initializing = 'Initializing';
  BS_PRNSTATUS_IOActive = 'IO Active';
  BS_PRNSTATUS_ManualFeed = 'Manual Feed';
  BS_PRNSTATUS_NoToner = 'No Toner';
  BS_PRNSTATUS_NotAvailable = 'Not Available';
  BS_PRNSTATUS_OFFLine = 'Offline';
  BS_PRNSTATUS_OutOfMemory = 'Out of Memory';
  BS_PRNSTATUS_OutBinFull = 'Output Bin Full';
  BS_PRNSTATUS_PagePunt = 'Page Punt';
  BS_PRNSTATUS_PaperJam = 'Paper Jam';
  BS_PRNSTATUS_PaperOut = 'Paper Out';
  BS_PRNSTATUS_PaperProblem = 'Paper Problem';
  BS_PRNSTATUS_Printing = 'Printing';
  BS_PRNSTATUS_Processing = 'Processing';
  BS_PRNSTATUS_TonerLow = 'Toner Low';
  BS_PRNSTATUS_UserIntervention = 'User Intervention';
  BS_PRNSTATUS_Waiting = 'Waiting';
  BS_PRNSTATUS_WarningUp = 'Warming Up';
  BS_PRNSTATUS_Ready = 'Ready';
  BS_PRNSTATUS_PrintingAndWaiting = 'Printing: %d document(s) waiting';
  BS_PRNDLG_PRINTER = 'Printer';
  BS_PRNDLG_NAME = 'Name:';
  BS_PRNDLG_PROPERTIES = 'Properties...';
  BS_PRNDLG_STATUS = 'Status:';
  BS_PRNDLG_TYPE = 'Type:';
  BS_PRNDLG_WHERE = 'Where:';
  BS_PRNDLG_COMMENT = 'Comment:';
  BS_PRNDLG_PRINTRANGE = 'Print range';
  BS_PRNDLG_COPIES = 'Copies';
  BS_PRNDLG_NUMCOPIES = 'Number of copies:';
  BS_PRNDLG_COLLATE = 'Collate';
  BS_PRNDLG_ALL = 'All';
  BS_PRNDLG_PAGES = 'Pages';
  BS_PRNDLG_SELECTION = 'Selection';
  BS_PRNDLG_FROM = 'from:';
  BS_PRNDLG_TO = 'to:';
  BS_PRNDLG_PRINTTOFILE = 'Print to file';
  BS_PRNDLG_ORIENTATION = 'Orientation';
  BS_PRNDLG_PAPER = 'Paper';
  BS_PRNDLG_PORTRAIT = 'Portrait';
  BS_PRNDLG_LANDSCAPE = 'Landscape';
  BS_PRNDLG_SOURCE = 'Source:';
  BS_PRNDLG_SIZE = 'Size:';
  BS_PRNDLG_MARGINS = 'Margins (millimeters)';
  BS_PRNDLG_MARGINS_INCHES = 'Margins (inches)';
  BS_PRNDLG_LEFT = 'Left:';
  BS_PRNDLG_RIGHT = 'Right:';
  BS_PRNDLG_TOP = 'Top:';
  BS_PRNDLG_BOTTOM = 'Bottom:';
  BS_PRNDLG_WARNING = 'There are no printers in your system!';
  BS_FIND_NEXT = 'Find next';
  BS_FIND_WHAT = 'Find what:';
  BS_FIND_DIRECTION = 'Direction';
  BS_FIND_DIRECTIONUP = 'Up';
  BS_FIND_DIRECTIONDOWN = 'Down';
  BS_FIND_MATCH_CASE = 'Match case';
  BS_FIND_MATCH_WHOLE_WORD_ONLY = 'Match whole word only';
  BS_FIND_REPLACE_WITH = 'Replace with:';
  BS_FIND_REPLACE = 'Replace';
  BS_FIND_REPLACE_All = 'Replace All';

  BS_MORECOLORS = 'More colors...';
  BS_AUTOCOLOR = 'Automatic';
  BS_CUSTOMCOLOR = 'Custom...';

  BS_DBNAV_FIRST = 'FIRST';
  BS_DBNAV_PRIOR = 'PRIOR';
  BS_DBNAV_NEXT = 'NEXT';
  BS_DBNAV_LAST = 'LAST';
  BS_DBNAV_INSERT = 'INSERT';
  BS_DBNAV_DELETE = 'DELETE';
  BS_DBNAV_EDIT = 'EDIT';
  BS_DBNAV_POST = 'POST';
  BS_DBNAV_CANCEL = 'CANCEL';
  BS_DBNAV_REFRESH = 'REFRESH';

implementation

end.
