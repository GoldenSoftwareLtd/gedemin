
{ TgsTrayIcon VCL. Version 1.3

  Requires:  Delphi 2.0 32 bit.

  Function: Adds an icon to the Windows 95 Tool Tray and
      has events to respond to mouse clicks.

  This component is based on the TToolIcon VCL that was written by
  Derek Stutsman (dereks@metronet.com).  He based his component on
  TWinControl, so it showed up as a clear, blank, resizable window at
  design time and also had more properties than the component actually
  needed.  This made it really hard to find on a busy form sometimes.

  I changed it so it would be based on TComponent so that it was readily
  visible at design time and also did not cover anything at run-time.
  The additional Top, left, width, etc. properties are also no longer
  necessary.  I added a ShowDesigning property so that you could test
  it at design time, but then turn it off so that TWO icons weren't shown
  on the tool tray when developing and testing.

  One strange anomaly that I worked around but don't know why it happens -
  if a ToolTip is not specified, then at run-time the icon shows up as
  blank.  If a ToolTip is specified, everything works fine.  To fix this,
  I set up another windows message that set the tool tip if it was blank -
  this ensures proper operation at all times, but I don't know why this
  is necessary.  If you can figure it out, send me some mail and let me
  know! (4/17/96 note - still no solution for this!)

  This is freeware (as was the original).  If you make cool changes to it,
  please send them to me.

  Enjoy!

  Pete Ness
  Compuserve ID: 102347,710
  Internet: 102347.710@compuserve.com
  http:\\ourworld.compuserve.com\homepages\peteness

  Release history:

  3/8/96 - Version 1.0
     Release by Derek Stutsman of TToolIcon version 1.0

  3/12/96 - Version 1.1

     Changed as outlined above by me (Pete Ness) and renamed to TgsTrayIcon.

  3/29/96 - Version 1.2
     Add default window handling to allow closing when Win95 shutdown.
     Previously, you had to manually close your application before closing
     Windows 95.

  4/17/96 - Version 1.3
     Added a PopupMenu property to automatically handle right clicking on
     the tray icon.
     Fixed bug that would not allow you to instantiate a TgsTrayIcon instance
     at run-time.
     Added an example program to show how to do some of the things I've
     gotten the most questions on.
     This version is available from my super lame web page - see above for
     the address.

  }


unit gsTrayIcon;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  ShellAPI, Forms, Menus, gsTrayIconInterface;

const
  WM_TOOLTRAYICON = WM_USER + 1;
  WM_RESETTOOLTIP = WM_USER + 2;

type
  TgsTrayIcon = class(TComponent, IgsTrayIcon)
  private
    IconData: TNOTIFYICONDATA;
    fIcon: TIcon;
    fToolTip: String;
    fWindowHandle: HWND;
    fActive: Boolean;
    fShowDesigning: Boolean;

    fOnClick: TNotifyEvent;
    fOnDblClick: TNotifyEvent;
    fOnRightClick: TMouseEvent;
    fPopupMenu: TPopupMenu;

    function AddIcon: Boolean;
    function ModifyIcon: Boolean;
    function DeleteIcon: Boolean;

    procedure SetActive(const Value: Boolean);
    procedure SetShowDesigning(const Value: Boolean);
    procedure SetIcon(Value: TIcon);
    procedure SetToolTip(const Value: String);
    function GetToolTip: String;
    procedure WndProc(var Msg: TMessage);

    procedure FillDataStructure;
    procedure DoRightClick( Sender: TObject );

  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

  published
    property Active: Boolean read fActive write SetActive;
    property ShowDesigning: Boolean read fShowDesigning write SetShowDesigning;
    property Icon: TIcon read fIcon write SetIcon;
    property ToolTip: String read GetToolTip write SetToolTip;

    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnDblClick: TNotifyEvent read FOnDblClick write FOnDblClick;
    property OnRightClick: TMouseEvent read FOnRightClick write FonRightClick;
    property PopupMenu: TPopupMenu read fPopupMenu write fPopupMenu;
  end;

procedure Register;

implementation

{$R gsTrayIcon.res}

procedure TgsTrayIcon.SetActive(const Value: Boolean);
begin
   if Value <> fActive then begin
     fActive := Value;
     if not (csdesigning in ComponentState) then begin
        if Value then begin
           AddIcon;
        end else begin
           DeleteIcon;
        end;
     end;
  end;
end;

procedure TgsTrayIcon.SetShowDesigning(const Value: Boolean);
begin
  if csdesigning in ComponentState then
  begin
     if Value <> fShowDesigning then
     begin
        fShowDesigning := Value;
        if Value then
        begin
           AddIcon;
        end else
        begin
           DeleteIcon;
        end;
     end;
  end;
end;

procedure TgsTrayIcon.SetIcon(Value: Ticon);
begin
  if Value <> fIcon then
  begin
    fIcon.Assign(value);
    ModifyIcon;
  end;
end;

procedure TgsTrayIcon.SetToolTip(const Value: String);
begin
   // This routine ALWAYS re-sets the field value and re-loads the
   // icon.  This is so the ToolTip can be set blank when the component
   // is first loaded.  If this is changed, the icon will be blank on
   // the tray when no ToolTip is specified.
   fToolTip := Copy(Value, 1, 62);
   ModifyIcon;
end;

constructor TgsTrayIcon.Create(aOwner: Tcomponent);
begin
  inherited Create(aOwner);
  FWindowHandle := AllocateHWnd(WndProc);
  FIcon := TIcon.Create;
  TrayIcon := Self;
end;

destructor TgsTrayIcon.Destroy;
begin
  if (not (csDesigning in ComponentState) and fActive)
     or ((csDesigning in ComponentState) and fShowDesigning) then
        DeleteIcon;

  FIcon.Free;
  DeAllocateHWnd(FWindowHandle);
  TrayIcon := nil;
  inherited Destroy;
end;

procedure TgsTrayIcon.FillDataStructure;
begin

  with IconData do begin

     cbSize := sizeof(TNOTIFYICONDATA);
     wnd := FWindowHandle;
     uID := 0; // is not passed in with message so make it 0
     uFlags := NIF_MESSAGE + NIF_ICON + NIF_TIP;
     hIcon := fIcon.Handle;
     StrPCopy(szTip,fToolTip);
     uCallbackMessage := WM_TOOLTRAYICON;

  end;

end;

function TgsTrayIcon.AddIcon: Boolean;
{var
  Counter: Integer;}
begin
{  Counter := 2;
  repeat}
    try
      FillDataStructure;
      Result := Shell_NotifyIcon(NIM_ADD,@IconData);

      // For some reason, if there is no tool tip set up, then the icon
      // doesn't display.  This fixes that.

      if fToolTip = '' then
        PostMessage( fWindowHandle, WM_RESETTOOLTIP,0,0 );

      exit;
    except
      {Dec(Counter);
      Sleep(2000);}
    end;
  {until Counter = 0;}
  Result := False;
end;

function TgsTrayIcon.ModifyIcon: Boolean;
begin

   FillDataStructure;
   if fActive then
      Result := Shell_NotifyIcon(NIM_MODIFY,@IconData)
   else
      Result := True;

end;

procedure TgsTrayIcon.DoRightClick( Sender: TObject );
var MouseCo: Tpoint;
begin

   GetCursorPos(MouseCo);

   if Assigned( fPopupMenu ) then
   begin
     SetForegroundWindow( Application.Handle );
     Application.ProcessMessages;
     if not Application.Terminated then
       fPopupmenu.Popup( Mouseco.X, Mouseco.Y );
   end;

  if not Application.Terminated then
  begin
    if Assigned( FOnRightClick ) then
    begin
      FOnRightClick(self,mbRight,[],MouseCo.x,MouseCo.y);
    end;
  end;  
end;

function TgsTrayIcon.DeleteIcon: Boolean;
begin
   Result := Shell_NotifyIcon(NIM_DELETE,@IconData);
end;

procedure TgsTrayIcon.WndProc(var Msg: TMessage);
begin
   with Msg do
     if (Msg = WM_RESETTOOLTIP) then
        SetToolTip(fToolTip)
     else if (Msg = WM_TOOLTRAYICON) then begin
        case lParam of
           WM_LBUTTONDBLCLK  : if Assigned (FOnDblClick) then FOnDblClick(self);
           WM_LBUTTONUP      : if Assigned(FOnClick)then FOnClick(self);
           WM_RBUTTONUP      : DoRightClick(self);
        end;
     end
     else // Handle all messages with the default handler
        Result := DefWindowProc(FWindowHandle, Msg, wParam, lParam);
end;

procedure Register;
begin
  RegisterComponents('gsNew', [TgsTrayIcon]);
end;

function TgsTrayIcon.GetToolTip: String;
begin
  Result := FToolTip;
end;

end.
