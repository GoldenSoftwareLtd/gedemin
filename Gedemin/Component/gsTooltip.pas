
unit gsTooltip;

interface

uses
  Windows, Messages, Graphics;

const
  TOOLTIPS_CLASS        = 'tooltips_class32';
  
  TTS_ALWAYSTIP		= $01;
  TTS_NOPREFIX		= $02;
  TTS_BALLOON           = $40;
  TTF_TRANSPARENT       = $0100;
  TTF_CENTERTIP         = $0002;
  TTF_IDISHWND		= $0001;
  TTF_SUBCLASS		= $0010;

  TTM_ACTIVATE		= WM_USER + 1;
  TTM_SETDELAYTIME	= WM_USER + 3;
  TTM_ADDTOOL		= WM_USER + 4;
  TTM_DELTOOL		= WM_USER + 5;
  TTM_RELAYEVENT	= WM_USER + 7;
  TTM_UPDATETIPTEXT	= WM_USER + 12;
  TTM_GETTOOLCOUNT	= WM_USER + 13;
  TTM_SETTIPBKCOLOR	= WM_USER + 19;
  TTM_SETTIPTEXTCOLOR	= WM_USER + 20;
  TTM_GETTIPBKCOLOR	= WM_USER + 22;
  TTM_SETMAXTIPWIDTH	= WM_USER + 24;
  TTM_SETMARGIN		= WM_USER + 26;
  TTM_GETMARGIN		= WM_USER + 27;
  
  TTN_FIRST		= 0-520;
  TTN_GETDISPINFO	= TTN_FIRST;
  TTN_NEEDTEXTA		= TTN_FIRST - 0;
  TTN_NEEDTEXT		= TTN_NEEDTEXTA;

  ICC_WIN95_CLASSES     = $000000FF;

  LPSTR_TEXTCALLBACK    = Longint(-1);

type
  TTOOLINFO = packed record
    cbSize: Integer;
    uFlags: Integer;
    hwnd: THandle;
    uId: Integer;
    rect: TRect;
    hinst: THandle;
    lpszText: PAnsiChar;
    lParam: Integer;
  end;

  TNMHDR = packed record
    hWndFrom: THandle;
    idFrom: Integer;
    code: Integer;
  end;
  PNMHDR = ^TNMHDR;

  TNMTTDISPINFO = packed record
    nmhdr: TNMHDR;
    lpszText: PAnsiChar;
    tchar: array[0..79] of AnsiChar;
    hInst: THandle;
    lParam: Integer;
  end;
  PNMTTDISPINFO = ^TNMTTDISPINFO;

implementation

end.

