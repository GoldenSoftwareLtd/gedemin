unit flt_EnumComboBoxList_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, CheckLst;

type
  TCloseUp = procedure(const AnResult: Boolean) of object;

type
  TEnumComboBoxList = class(TForm)
    clbView: TListView;
    procedure clbViewAdvancedCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; Stage: TCustomDrawStage;
      var DefaultDraw: Boolean);
    procedure clbViewResize(Sender: TObject);
  private
    // Обработчик для закрытия комбобокса
    FCloseUp: TCloseUp;
//    FSelectedIndex: Integer;

    function GetDropedDown: Boolean;
    // Запрет на активизацию окна
    procedure WMMouseActivate(var Message: TWMMouseActivate); message WM_MOUSEACTIVATE;
    // Поведение выпадоющего дерева при нажатиии на нем кнопки мыши
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    // Отслеживаем движение мышки выделением соответствующих записей
    procedure WMMouseMove(var Message: TWMMouseMove); message WM_MOUSEMOVE;

    procedure CNKeyDown(var Message: TMessage); message CN_KEYDOWN;
  protected
    // Задание параметров окна
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DoCloseUp(AnResult: Boolean);

  public
    property IsDroppedDown: Boolean read GetDropedDown;
    property CloseUp: TCloseUp read FCloseUp write FCloseUp;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{$R *.DFM}

type
  TCheckListBoxCracker = class(TCheckListBox);

{ TgsComboTreeBoxList }

constructor TEnumComboBoxList.Create(AOwner: TComponent);
begin
  inherited;
  BevelInner := bvNone;
  BevelOuter := bvNone;
  Height := 100;
end;

procedure TEnumComboBoxList.CreateParams(var Params: TCreateParams);
begin
  inherited;

  with Params do
  begin
    Style := WS_POPUPWINDOW or WS_BORDER or WS_VSCROLL;
    ExStyle := WS_EX_TOOLWINDOW;
    AddBiDiModeExStyle(ExStyle);
    WindowClass.Style := CS_SAVEBITS;
  end;
end;

function TEnumComboBoxList.GetDropedDown: Boolean;
begin
  Result := Visible;
end;

procedure TEnumComboBoxList.WMLButtonDown(var Message: TWMLButtonDown);
var
//  LMouseState: THitTests;
  LI: TListItem;
//  I: Integer;
begin
  inherited;

  LI := clbView.GetItemAt(Message.XPos, Message.YPos);
  if (LI <> nil) then
    if Message.XPos - LI.Left < LI.Indent then
      LI.Checked := not LI.Checked
    else
      DoCloseUp(True);
end;

procedure TEnumComboBoxList.WMMouseActivate(var Message: TWMMouseActivate);
begin
  // Если нажимаем на скролбокс, то не обрубаем дальнейшую обработку сообщения
  // в противном случае обрубаем
  if Message.HitTestCode in [HTHSCROLL, HTVSCROLL] then
    Message.Result := MA_NOACTIVATE
  else
    Message.Result := MA_NOACTIVATEANDEAT;
end;

procedure TEnumComboBoxList.WMMouseMove(var Message: TWMMouseMove);
var
  LI: TListItem;
begin
  LI := clbView.GetItemAt(Message.XPos, Message.YPos);
  if (LI <> nil) and not LI.Selected then
    LI.Selected := True;
end;

procedure TEnumComboBoxList.DoCloseUp(AnResult: Boolean);
begin
  if Assigned(FCloseUp) then
    FCloseUp(AnResult);
end;

procedure TEnumComboBoxList.clbViewAdvancedCustomDrawItem(
  Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  Stage: TCustomDrawStage; var DefaultDraw: Boolean);
var
  OldColor: TColor;
  LRect: TRect;
begin
  State := State - [cdsGrayed];
//  if (cdPostPaint = Stage) then
  begin
    OldColor := Sender.Canvas.Brush.Color;
    if Item.Selected then
    begin
      Sender.Canvas.Brush.Color := clHighLight;
      Sender.Canvas.Font.Color := clHighlightText;
    end else
    begin
      Sender.Canvas.Brush.Color := clWindow;
      Sender.Canvas.Font.Color := clWindowText;
    end;
    LRect := Item.DisplayRect(drLabel);
    Sender.Canvas.FillRect(LRect);
    Sender.Canvas.Brush.Color := OldColor;
    Sender.Canvas.TextRect(LRect, LRect.Left, LRect.Top, Item.Caption);
  end;
end;

procedure TEnumComboBoxList.clbViewResize(Sender: TObject);
begin
  clbView.Column[0].Width := clbView.Width;
end;

destructor TEnumComboBoxList.Destroy;
begin

  inherited;
end;

procedure TEnumComboBoxList.CNKeyDown(var Message: TMessage);
begin
//
end;

end.

