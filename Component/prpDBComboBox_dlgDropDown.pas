unit prpDBComboBox_dlgDropDown;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, Buttons, ExtCtrls;

type
  TprpDropDown = class(TForm)
    ActionList: TActionList;
    actNew: TAction;
    actDelete: TAction;
    actShrink: TAction;
    actGrow: TAction;
    Panel1: TPanel;
    pnlToolbar: TPanel;
    sbNew: TSpeedButton;
    sbDelete: TSpeedButton;
    SpeedButton5: TSpeedButton;
    sbGrow: TSpeedButton;
    lbItems: TListBox;
    actCancel: TAction;
    actOk: TAction;
    procedure actShrinkExecute(Sender: TObject);
    procedure actShrinkUpdate(Sender: TObject);
    procedure actGrowExecute(Sender: TObject);
    procedure actGrowUpdate(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure actNewExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
    procedure actDeleteUpdate(Sender: TObject);
  private
    FComboBox: TCustomComboBox;
    FItemIndex: Integer;
    procedure SetComboBox(const Value: TCustomComboBox);
    { Private declarations }
  public
    { Public declarations }
    property ComboBox: TCustomComboBox read FComboBox write SetComboBox;
  end;

var
  prpDropDown: TprpDropDown;

implementation
{$R *.DFM}

var
  prpCOMBOHOOK: HHOOK = 0;

function prpComboHookProc(nCode: Integer; wParam: Integer; lParam: Integer): LResult; stdcall;
var
  P: TPoint;
begin
  Result := CallNextHookEx(prpCOMBOHOOK, nCode, wParam, lParam);
  with PMouseHookStruct(lParam)^ do
  begin
    case wParam of
      WM_LBUTTONDOWN, WM_NCLBUTTONDOWN, WM_LBUTTONUP:
      begin
        if (Screen.ActiveForm is TprpDropDown) and (GetForegroundWindow = Screen.ActiveForm.Handle) then
        with (Screen.ActiveForm as TprpDropDown) do
        begin
          P := ScreenToClient(pt);
          if (P.X < 0) or (P.X > Width) or
            (P.Y < 0) or (P.Y > Height) then
          begin
            ModalResult := mrCancel;
            Result := 1;
          end else
            SendMessage(Handle, wParam, 0, MakeLParam(pt.X, pt.Y)); // was PostMessage
        end
      end;
    end;
  end;
end;

procedure TprpDropDown.actShrinkExecute(Sender: TObject);
var
  Pt: TPoint;
begin
  Width := Width - 20;
  if GetCursorPos(Pt) then SetCursorPos(Pt.X - 20, Pt.Y);
end;

procedure TprpDropDown.actShrinkUpdate(Sender: TObject);
begin
  actShrink.Enabled := Width > 100;
end;

procedure TprpDropDown.actGrowExecute(Sender: TObject);
var
  Pt: TPoint;
begin
  Width := Width + 20;
  if GetCursorPos(Pt) then SetCursorPos(Pt.X + 20, Pt.Y);
end;

procedure TprpDropDown.actGrowUpdate(Sender: TObject);
begin
  actGrow.Enabled := Left + Width < Screen.Width - 20;
end;

procedure TprpDropDown.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Pt: TPoint;
begin
  if GetCursorPos(Pt)
    and (FindVCLWindow(Pt) <> pnlToolbar) then
  begin
    ModalResult := mrOk;
  end;
end;
procedure TprpDropDown.FormShow(Sender: TObject);
begin
  if prpCOMBOHOOK = 0 then
    prpCOMBOHOOK := SetWindowsHookEx(WH_MOUSE, @prpComboHookProc, HINSTANCE, GetCurrentThreadID);
  FItemIndex := lbItems.ItemIndex;
//  FWasTabKey := False;
//  FLastKey := 0;
end;

procedure TprpDropDown.FormHide(Sender: TObject);
begin
  if prpCOMBOHOOK <> 0 then
  begin
    UnhookWindowsHookEx(prpCOMBOHOOK);
    prpCOMBOHOOK := 0;
  end;
end;

procedure TprpDropDown.actNewExecute(Sender: TObject);
begin
//
  if FComboBox <> nil then
    SendMessage(FComboBox.Handle,  WM_KEYDOWN, VK_F2, 0);
  lbItems.ItemIndex := - 1;
  ModalResult := mrOk;
end;

procedure TprpDropDown.SetComboBox(const Value: TCustomComboBox);
begin
  FComboBox := Value;
end;

procedure TprpDropDown.actDeleteExecute(Sender: TObject);
begin
  if FComboBox <> nil then
    SendMessage(FComboBox.Handle,  WM_KEYDOWN, VK_F8, 0);
  lbItems.ItemIndex := -1;
  ModalResult := mrOk;
end;

procedure TprpDropDown.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TprpDropDown.actOkExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TprpDropDown.actOkUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := lbItems.ItemIndex > - 1;
end;

procedure TprpDropDown.actDeleteUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (FItemIndex > -1) and (FItemIndex = lbItems.ItemIndex);
end;

end.
