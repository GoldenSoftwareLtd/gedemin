unit rpl_DropDownForm_unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ActnList;

type
  TDropDownForm = class(TForm)
    ListBox: TListBox;
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure ListBoxKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ListBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ListBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    FDropDownCount: Integer;
    procedure SetDropDownCount(const Value: Integer);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    function CalcHeight: Integer;
  public
    { Public declarations }
    property DropDownCount: Integer read FDropDownCount write SetDropDownCount;
  end;

implementation
uses Consts;
var
  HMouseProc: HHOOK;
const
  DefaultDropDownCount = 8;

function HookMouseProc(nCode: Integer; wParam: Integer; lParam: Integer): LResult; stdcall;
var
  P: TPoint;
begin
  Result := CallNextHookEx(HMouseProc, nCode, wParam, lParam);
  with PMouseHookStruct(lParam)^ do
  begin
    case wParam of
      WM_LBUTTONDOWN, WM_NCLBUTTONDOWN, WM_LBUTTONUP:
      begin
        if (Screen.ActiveForm is TDropDownForm) and (GetForegroundWindow = Screen.ActiveForm.Handle) then
        with (Screen.ActiveForm as TDropDownForm) do
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

{$R *.dfm}

{ TDropDownForm }

procedure TDropDownForm.FormShow(Sender: TObject);
begin
  if HMouseProc = 0 then
    HMouseProc := SetWindowsHookEx(WH_MOUSE, @HookMouseProc, HINSTANCE, GetCurrentThreadID);
  Height := CalcHeight;   
//  FItemIndex := lbItems.ItemIndex;
end;

procedure TDropDownForm.FormHide(Sender: TObject);
begin
  if HMouseProc <> 0 then
  begin
    UnhookWindowsHookEx(HMouseProc);
    HMouseProc := 0;
  end;
end;

procedure TDropDownForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style or WS_BORDER	{or WS_SIZEBOX} 	
end;

procedure TDropDownForm.SetDropDownCount(const Value: Integer);
begin
  if FDropDownCount <> Value then
  begin
    FDropDownCount := Value;
    Height := CalcHeight;
  end;
end;

function TDropDownForm.CalcHeight: Integer;
begin
  Result := ListBox.ItemHeight * FDropDownCount + 2;
end;

procedure TDropDownForm.FormCreate(Sender: TObject);
begin
  FDropDownCount := DefaultDropDownCount;
end;

procedure TDropDownForm.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TDropDownForm.ListBoxKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_RETURN:
    begin
      if (ListBox.ItemIndex > - 1) then
        ModalResult := mrOk
    end;
    VK_ESCAPE: ModalResult := mrCancel;
  end;  
end;

procedure TDropDownForm.ListBoxMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  ListBox.ItemIndex := ListBox.ItemAtPos(Point(X, Y), True);
end;

procedure TDropDownForm.ListBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if ListBox.ItemIndex > - 1 then
    ModalResult := mrOk
end;

end.
