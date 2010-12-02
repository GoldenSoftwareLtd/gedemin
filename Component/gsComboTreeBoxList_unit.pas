unit gsComboTreeBoxList_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls;

type
  TCloseUp = procedure(const AnResult: Boolean) of object;

type
  TgsComboTreeBoxList = class(TForm)
    tvTree: TTreeView;
    // ����������� ������� � ����������� �������
    procedure tvTreeAdvancedCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage;
      var PaintImages, DefaultDraw: Boolean);
    // ������������ ���� FTopNodeEnabled ��� ������ � �����������
    procedure tvTreeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tvTreeGetSelectedIndex(Sender: TObject; Node: TTreeNode);
  private
    // ���������� ��� �������� ����������
    FCloseUp: TCloseUp;
    // ���� ����������� ��������� �������� ������
    FTopNodeEnabled: Boolean;

    function GetDropedDown: Boolean;
    // ������ �� ����������� ����
    procedure WMMouseActivate(var Message: TWMMouseActivate); message WM_MOUSEACTIVATE;
    // ��������� ����������� ������ ��� �������� �� ��� ������ ����
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    // ����������� �������� ����� ���������� ��������������� �������
    procedure WMMouseMove(var Message: TWMMouseMove); message WM_MOUSEMOVE;

  protected
    // ������� ���������� ����
    procedure CreateParams(var Params: TCreateParams); override;

  public
    property IsDroppedDown: Boolean read GetDropedDown;
    property CloseUp: TCloseUp read FCloseUp write FCloseUp;
    property TopNodeEnabled: Boolean read FTopNodeEnabled write FTopNodeEnabled;

    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.DFM}

{ TgsComboTreeBoxList }

constructor TgsComboTreeBoxList.Create(AOwner: TComponent);
begin
  inherited;

//  ControlStyle := ControlStyle + [csNoDesignVisible, csReflector, csReplicatable];
  BevelInner := bvNone;
  BevelOuter := bvNone;
  Height := 100;

end;

procedure TgsComboTreeBoxList.CreateParams(var Params: TCreateParams);
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

function TgsComboTreeBoxList.GetDropedDown: Boolean;
begin
  Result := Visible;
end;

procedure TgsComboTreeBoxList.WMLButtonDown(var Message: TWMLButtonDown);
var
  LMouseState: THitTests;
  TN: TTreeNode;
begin
  inherited;

  // ���������� ����� ������� � ������
  LMouseState := tvTree.GetHitTestInfoAt(Message.XPos, Message.YPos);
  // ���� ������ �� ����, �� ���������/��������� ���
  if (htOnButton in LMouseState) then
  begin
    TN := tvTree.GetNodeAt(Message.XPos, Message.YPos);
    if TN <> nil then
    begin
      TN.Expanded := not TN.Expanded;
      TN.Selected := not TN.HasChildren or (FTopNodeEnabled and TN.Selected);
    end;
  end else
    // ���� �� ������, �� ��������� ���� � �������.
    if (htOnItem in LMouseState) or (htOnLabel in LMouseState) or
     (htOnIndent in LMouseState) or (htOnRight in LMouseState) then
      CloseUp(True);
{    else
      if IsDroppedDown then}
//        PostMessage(tvTree.Handle, Message.Msg, TMessage(Message).WParam, TMessage(Message).LParam);
//      CloseUp(False);
end;

procedure TgsComboTreeBoxList.WMMouseActivate(var Message: TWMMouseActivate);
begin
  // ���� �������� �� ���������, �� �� �������� ���������� ��������� ���������
  // � ��������� ������ ��������
  if Message.HitTestCode in [HTHSCROLL, HTVSCROLL] then
    Message.Result := MA_NOACTIVATE
  else
    Message.Result := MA_NOACTIVATEANDEAT;
end;

procedure TgsComboTreeBoxList.WMMouseMove(var Message: TWMMouseMove);
var
  I: TTreeNode;
begin
  I := tvTree.GetNodeAt(Message.XPos, Message.YPos);
  // ������� ������� ��� ��������� �� �������� ��� ��������������� �����
  if (I <> nil) and (not I.HasChildren or FTopNodeEnabled) and
   (Message.YPos < tvTree.Height - tvTree.Font.Size div 2) then
    I.Selected := True;
end;

procedure TgsComboTreeBoxList.tvTreeAdvancedCustomDrawItem(
  Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
  Stage: TCustomDrawStage; var PaintImages, DefaultDraw: Boolean);
var
  OldColor: TColor;
  LRect: TRect;
begin
  State := State - [cdsGrayed];
  if (cdPostPaint = Stage) then
  begin
    OldColor := Sender.Canvas.Brush.Color;          
    if (cdsSelected in State) then
      Sender.Canvas.Brush.Color := clHighLight
    else
      Sender.Canvas.Brush.Color := clWhite;
    LRect := Node.DisplayRect(True);
    Sender.Canvas.FillRect(LRect);
    Sender.Canvas.Brush.Color := OldColor;
    Sender.Canvas.TextRect(LRect, LRect.Left, LRect.Top, Node.Text);
  end;
end;

procedure TgsComboTreeBoxList.tvTreeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  I: Integer;
begin
  case Key of
    VK_UP:
      if not TopNodeEnabled then
      begin
        if Assigned(tvTree.Selected) then
          I := tvTree.Selected.AbsoluteIndex - 1
        else
          I := tvTree.Items.Count - 1;
        while I >= 0 do
        begin
          if tvTree.Items[I].IsVisible and not tvTree.Items[I].HasChildren then
          begin
            tvTree.Items[I].Selected := True;
            Break;
          end;
          Dec(I);
        end;
        Key := 0;
      end;
    VK_DOWN:
      if not TopNodeEnabled then
      begin
        if Assigned(tvTree.Selected) then
          I := tvTree.Selected.AbsoluteIndex + 1
        else
          I := 0;
        while I < tvTree.Items.Count do
        begin
          if tvTree.Items[I].IsVisible and not tvTree.Items[I].HasChildren then
          begin
            tvTree.Items[I].Selected := True;
            Break;
          end;
          Inc(I);
        end;
        Key := 0;
      end;
  end;
end;

procedure TgsComboTreeBoxList.tvTreeGetSelectedIndex(Sender: TObject;
  Node: TTreeNode);
begin
  Node.SelectedIndex := Node.ImageIndex;
end;

end.

