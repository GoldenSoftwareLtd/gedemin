unit xp_frmDropDown_unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ActnList;

type
  TfrmDropDownClass = class of TfrmDropDown;
  TfrmDropDown = class(TForm)
    ActionList: TActionList;
    actCancel: TAction;
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
  private
    { Private declarations }
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure SetValue(const Value: Variant); virtual;
    function GetValue: Variant; virtual;
    function GetInitBounds(ALeft, ATop, AWidth, AHeight: Integer; FirstTime: Boolean): TRect; virtual;
  public
    { Public declarations }
    procedure InitBounds(ALeft, ATop, AWidth, AHeight: Integer; FirstTime: Boolean); virtual;
    property Value: Variant read GetValue write SetValue;
  end;

var
  frmDropDown: TfrmDropDown;

implementation

{$R *.dfm}

var
  COMBOHOOK: HHOOK = 0;

function ComboHookProc(nCode: Integer; wParam: Integer; lParam: Integer): LResult; stdcall;
var
  P: TPoint;
begin
  Result := CallNextHookEx(COMBOHOOK, nCode, wParam, lParam);

  if nCode = HC_ACTION then
  begin
    with PMouseHookStruct(lParam)^ do
    begin
      case wParam of
        WM_LBUTTONDOWN, WM_NCLBUTTONDOWN, WM_LBUTTONUP:
        begin
          if (Screen.ActiveForm is TfrmDropDown)
            and (GetForegroundWindow = Screen.ActiveForm.Handle) then
          with (Screen.ActiveForm as TfrmDropDown) do
          begin
            P := ScreenToClient(pt);
            if (P.X < 0) or (P.X > Width) or
              (P.Y < 0) or (P.Y > Height) then
            begin
              ModalResult := mrCancel;
              Result := 1;
            end else
            begin
              //SendMessage(Handle, wParam, 0, MakeLParam(pt.X, pt.Y)); // was PostMessage
              Result := 0;
            end;
          end
        end;
      end;
    end;
  end;
end;

procedure TfrmDropDown.FormShow(Sender: TObject);
{var
  R: TRect;
  Pt: TPoint;}
begin
  if COMBOHOOK = 0 then
    COMBOHOOK := SetWindowsHookEx(WH_MOUSE, @ComboHookProc, HINSTANCE, GetCurrentThreadID);

{  GetWindowRect(gsdbGrid.Handle, R);
  GetCursorPos(Pt);
  FMouseFlag := (((GetAsyncKeyState(VK_LBUTTON)) shr 1) = 0)
    or (not PtInRect(R, Pt));}
end;

procedure TfrmDropDown.FormHide(Sender: TObject);
begin
  if COMBOHOOK <> 0 then
  begin
    UnhookWindowsHookEx(COMBOHOOK);
    COMBOHOOK := 0;
  end;
end;

procedure TfrmDropDown.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := WS_POPUPWINDOW;
  end;
end;

procedure TfrmDropDown.SetValue(const Value: Variant);
begin
end;

function TfrmDropDown.GetValue: Variant;
begin
end;

procedure TfrmDropDown.InitBounds(ALeft, ATop, AWidth, AHeight: Integer; FirstTime: Boolean);
var
  R: TRect;
begin
  R := GetInitBounds(ALeft, ATop, AWidth, AHeight, FirstTime);

  if (Screen.Width >= ALeft + R.Right) then
  begin
    if (Screen.Height >= ATop + R.Bottom) then
      SetBounds(ALeft, ATop + AHeight, R.Right, R.Bottom)
    else
      SetBounds(ALeft, ATop - R.Bottom, R.Right, R.Bottom)
  end else
  begin
    if (Screen.Height >= ATop + R.Bottom) then
      SetBounds(ALeft + AWidth - R.Right, ATop + AHeight, R.Right, R.Bottom)
    else
      SetBounds(ALeft + AWidth - R.Right, ATop - R.Bottom, R.Right, R.Bottom)
  end;
end;

procedure TfrmDropDown.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

function TfrmDropDown.GetInitBounds(ALeft, ATop, AWidth,
  AHeight: Integer; FirstTime: Boolean): TRect;
begin
  if FirstTime then
    Result := Rect(0, 0, AWidth, AHeight)
  else
    Result := Rect(0, 0, Width, Height)  
end;

end.
