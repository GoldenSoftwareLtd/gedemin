
{++

  Copyright (c) 1996-98 by Golden Software of Belarus

  Module

    xCalculatorEdit.pas

  Abstract

    An ordinary TEdit with built in calulator.

  Author

    Romanovski Denis (11-07-98)

  Contact address

  Revisions history

    Initial  14-07-98  Dennis  Initial version.

    beta1    18-07-98  Dennis  Beta version 1.0
                               TxDBEditCalculator component added.
                               All the components are being tested.

    beta2    22-07-98  Dennis  Moved to Delphi4. Some bugs are corrected.
                               Message WM_MOUSEACTIVATE is a very cool thing.

    beta3    14-02-99  Dennis  Decimal Separator bug fixed.
                               ���� ����������� ������� ��������� ���������
                               CM_CANCELMODE �� WM_CANCELMODE, �� - ��������.

    beta4    14-02-99  Dennis  I hide window now if it's necessery (WM_WINDOWPOSCHANGING).

           18-02-2002  Nick    � create //  FCalculator := TxCalculator.Create(AnOwner);
                               AnOwner ������� �� Self
--}

unit xCalculatorEdit;

interface

uses
  Windows, WinProcs, Messages, SysUtils, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, DB, DBCtrls;

const
  DefDecDigits = {2}-1;

// �������� � �������
type
  TxCalculatorEdit = class;
  TExpressionAction = (eaPlus, eaMinus, eaDevide, eaMultiple, eaEqual, eaNone);

  TxCalcButton = class(TSpeedButton)
  private
    IsActive, IsPressed: Boolean;
    Is3D: Boolean;

    procedure CMMouseEnter(var Message: TMessage);
      message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage);
      message CM_MOUSELEAVE;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Paint; override;
  public
    constructor Create(AnOwner: TComponent); override;
  end;

  TxCalculator = class(TCustomControl)
  private
    FCalcImage: TImage; // ������� ������������
    PressedButton: TPoint; // ��������� ������� �������
    BtnRect: TRect; // �������� ���������� ������� �������
    IsInverted: Boolean; // ����������� �� ����������
    FCalculatorEdit: TWinControl; // ����� ������������
    IsFirst: Boolean; // ������ ���

    procedure WMMouseActivate(var Message: TWMMouseActivate);
      message WM_MouseActivate;
    procedure WMWindowPosChanging(var Message: TWMWindowPosChanging);
      message WM_WINDOWPOSCHANGING;

    procedure DoOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

    function GetPressedButton(Pos: TPoint; var BtnRect: TRect): TPoint;
    procedure InvertPressedButton;
    procedure InvertByPos(APos: TPoint);

  protected
    procedure CreateParams(var Params: TCreateParams); override;

  public
    constructor Create(AnOwner: TComponent); override;
  end;

  TxCalculatorEdit = class(TEdit)
  private
    FButton: TxCalcButton;               // ������ ������ ������������
    FCalculator: TxCalculator;           // ���� ������������
    OldValue: Double;                    // ���������� �������� (�� ����� ������ +-*/ � �.�.)
    OldValueEntered: Boolean;            // ������� �� ���������� �����
    NeedToChangeValue: Boolean;          // ����� �� ��������� ���� ������ �����
    ExpressionAction: TExpressionAction; // ��� ��������
    FDecDigits: Integer;                 // ���-�� ���� ����� ����������� ����� � ������� ������
    SL: TStringList;

    procedure WMSize(var Message: TWMSize);
      message WM_SIZE;
    procedure WMMouseMove(var Message: TWMMouseMove);
      message WM_MouseMove;
    procedure WMKillFocus(var Message: TWMKillFocus);
      message WM_KillFocus;
    procedure CMCancelMode(var Message: TCMCancelMode);
      message CM_CANCELMODE;
    procedure CMCtl3DChanged(var Message: TMessage);
      message CM_CTL3DCHANGED;

    procedure SetEditRect;
    function GetMinHeight: Integer;
    procedure ChangeInvertion;

    procedure DoOnButtonMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DoOnButtonClick(Sender: TObject);

    function GetValue: Double;
    procedure SetValue(AValue: Double);

  protected
    procedure SetDecDigits(ADecDigits: Integer); virtual;

    procedure CreateWnd; override;
    procedure CreateParams(var Params: TCreateParams); override;

    function IsValidChar(Key: Char): Boolean; virtual;

    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Loaded; override;
    procedure DoEnter; override;

    property BorderStyle;
    procedure WndProc(var Message: TMessage); override;

    procedure CMExit(var Message: TCMExit);
      message CM_EXIT;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

  published
    // �������� � �������� ����
    property Value: Double read GetValue write SetValue;
    // ���-�� ������ ����� �����-�����������
    property DecDigits: Integer read FDecDigits write SetDecDigits
      default DefDecDigits;
  end;

  TxDBCalculatorEdit = class(TxCalculatorEdit)
  private
    FDataLink: TFieldDataLink; // �������� ����� � TField �����������
    FFocused: Boolean;

    procedure DataChange(Sender: TObject);
    procedure EditingChange(Sender: TObject);
    procedure UpdateData(Sender: TObject);
    procedure SetFocused(Value: Boolean);

    procedure CMEnter(var Message: TCMEnter);
      message CM_ENTER;
    procedure CMExit(var Message: TCMExit);
      message CM_EXIT;
    procedure CMGetDataLink(var Message: TMessage);
      message CM_GETDATALINK;
    procedure WMCut(var Message: TMessage);
      message WM_CUT;
    procedure WMPaste(var Message: TMessage);
      message WM_PASTE;

    function GetField: TField;
    function GetDataField: string;
    function GetDataSource: TDataSource;
    function GetReadOnly: Boolean;

    procedure SetDataField(const Value: string);
    procedure SetDataSource(Value: TDataSource);
    procedure SetReadOnly(Value: Boolean);

  protected
    procedure SetDecDigits(ADecDigits: Integer); override;
    procedure Change; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;
    function EditCanModify: Boolean;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    property Field: TField read GetField;

  published
    // ���� ��� ��������������
    property DataField: string read GetDataField write SetDataField;
    // DataSource ������� ��� �������
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    // ����� �� �������������
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;

    //
    property Text stored False;
    property Value stored False;
  end;

type
  ExCalculator = class(Exception);

procedure Register;

implementation

{$R XCALCULATOREDIT.RES}

uses
  gdHelp_Interface;

// ���������� ������ ������
const
  CalcButtonWidth = 17;
  CalcButtonHeight = 17;

// ��������� ��� ����������� ������� �������
const
  VertSkip = 19;
  HorizSkip = 10;
  Between = 2;

  ButtonWidth = 20;
  ButtonHeight = 20;

  EqualWidth = 42;

  VertNumber = 5;
  HorizNumber = 4;

{
  �������� ������ ����������.
}

procedure TimeDelay(Pause: LongWord; DoProcessMessages: Boolean);
var
  OldTime: LongWord;
begin
  OldTime := GetTickCount;
  while GetTickCount - OldTime <= Pause do
    if DoProcessMessages then Application.ProcessMessages;
end;

{
  ---------------------------
  ---- xCalcButton Class ----
  ---------------------------
}

constructor TxCalcButton.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  IsActive := False;
  IsPressed := False;
  Is3D := True;
end;

procedure TxCalcButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;

  IsActive := True;
  Paint;
end;

procedure TxCalcButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;

  IsActive := False;
  Paint;
end;

procedure TxCalcButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);

  IsPressed := True;
  Paint;
end;

procedure TxCalcButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);

  IsPressed := False;
  Paint;
end;

procedure TxCalcButton.Paint;
var
  Y: Integer;
begin
  if not Is3D then
  begin
    if not IsPressed then
      Canvas.Brush.Color := $0094A2A5
    else
      Canvas.Brush.Color := clBlack;

    Canvas.FillRect(Rect(0, 0, Width, Height));

    Canvas.Brush.Color := clBlack;
    Canvas.FrameRect(Rect(0, 0, Width, Height));

    Y := Height div 2 - 1;

    if (IsActive and not TxCalculatorEdit(Parent).FCalculator.Visible) or IsPressed then
      Canvas.Pen.Color := clWhite
    else
      Canvas.Pen.Color := clBlack;

    Canvas.MoveTo(6, Y + 1);
    Canvas.LineTo(11, Y + 1);

    Canvas.MoveTo(7, Y + 2);
    Canvas.LineTo(10, Y + 2);

    if (IsActive and not TxCalculatorEdit(Parent).FCalculator.Visible) or IsPressed then
      Canvas.Pixels[8, Y + 3] := clWhite
    else
      Canvas.Pixels[8, Y + 3] := clBlack;
  end else
    inherited Paint;
end;

{
  ----------------------------
  ---- TxCalulator Class  ----
  ----------------------------
}

{
  ********************
  **  Private Part  **
  ********************
}

{
  ��������� ��������� ���� �� ������� ������ ����.
}

procedure TxCalculator.WMMouseActivate(var Message: TWMMouseActivate);
begin
  Message.Result := MA_NOACTIVATE;
end;

{
  �������� �� �������� ����.
}

procedure TxCalculator.WMWindowPosChanging(var Message: TWMWindowPosChanging);  
begin
  with Message do 
  begin
    if (WindowPos.flags = SWP_NOSIZE or SWP_NOMOVE or SWP_NOACTIVATE) and (WindowPos.x = 0) and
      (WindowPos.y = 0) and (WindowPos.cx = 0) and (WindowPos.cy = 0) and Visible then
    begin
      if IsFirst then
      begin
        IsFirst := False;
        Exit;
      end;

      (FCalculatorEdit as TxCalculatorEdit).ExpressionAction := eaNone;
      Visible := False;
    end;
  end;  
  
  inherited;
end;

{
  �� ������� ���� ���������� �������� focus-� �������� �
  ������ �������� �� �����������
}

procedure TxCalculator.DoOnMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
const
  Arr: array[1..5, 1..4] of Char = (
    ('7', '8', '9', '/'),
    ('4', '5', '6', '*'),
    ('1', '2', '3', '-'),
    ('0', '.', 'I', '+'),
    ('C', 'B', '=', '=')
  );

begin
  Arr[4, 2] := DecimalSeparator;
  
  PressedButton := GetPressedButton(Point(X, Y), BtnRect);
  // ���� ������ ���� �� ������
  try
    with PressedButton do
    case Arr[Y, X] of
      'B': SendMessage(Parent.Handle, WM_CHAR, VK_BACK, 0);
      'I': (Parent as TxCalculatorEdit).ChangeInvertion;
    else
      SendMessage(Parent.Handle, WM_CHAR, Ord(Arr[PressedButton.Y, PressedButton.X]), 0);
    end;
  except
  end;
end;

{
  �������������, ����� �� ������ ���� ������ �� ������������
}

function TxCalculator.GetPressedButton(Pos: TPoint; var BtnRect: TRect): TPoint;
var
  I, K: Integer;
  NewRect: TRect;
begin
  Result := Point(0, 0); // ������������� 0-�� �������� ����������

  for I := 0 to HorizNumber - 1 do
  begin
    NewRect.Left := HorizSkip + ButtonWidth * I + Between * I;
    NewRect.Right := NewRect.Left + ButtonWidth - 1;

    for K := 0 to VertNumber - 1 do
    begin
      // ���� ������ "="
      if (I > 1) and (K >= 4) then
      begin
        NewRect.Left := HorizSkip + ButtonWidth * 2 + Between * 2;
        NewRect.Right := NewRect.Left + EqualWidth - 1;
      end;

      NewRect.Top := VertSkip + ButtonHeight * K + Between * K;
      NewRect.Bottom := NewRect.Top + ButtonHeight - 1;

      if (Pos.X >= NewRect.Left) and (Pos.X <= NewRect.Right) and
        (Pos.Y >= NewRect.Top) and (Pos.Y <= NewRect.Bottom) then
      begin
        Result.X := I + 1;
        Result.Y := K + 1;
        BtnRect := NewRect;
        Exit;
      end;
    end;

  end;
end;

{
  ���������� �������������� ������� �������.
}

procedure TxCalculator.InvertPressedButton;
begin
  InvertRect(FCalcImage.Canvas.Handle, BtnRect);
  FCalcImage.Repaint;
end;

{
  ���������� �������������� ������� �� ������� ������
}

procedure TxCalculator.InvertByPos(APos: TPoint);
begin
  APos.X := HorizSkip + (ButtonWidth + Between) * APos.X;
  APos.Y := VertSkip + (ButtonHeight + Between) * APos.Y;
  PressedButton := GetPressedButton(APos, BtnRect);

  if not IsInverted then
  begin
    IsInverted := True;
    InvertPressedButton;
    TimeDelay(100, False);
    if not Application.Terminated then
    begin
      InvertPressedButton;
      IsInverted := False;
    end;
  end;
end;

{
  **********************
  **  Protected Part  **
  **********************
}

{
  ������������� ���� ��������� ��� ����
}

procedure TxCalculator.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := WS_POPUP;
    ExStyle := WS_EX_TOOLWINDOW;
    AddBiDiModeExStyle(ExStyle);
  end;
end;

{
  *******************
  **  Public Part  **
  *******************
}

{
  ������ ��������� ���������
}

constructor TxCalculator.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  // ��������� bitmap ������������
  FCalcImage := TImage.Create(AnOwner);
  FCalcImage.Parent := Self;
  FCalcImage.Picture.Bitmap.LoadFromResourceName(hInstance, 'CALCULATOR');
  FCalcImage.Align := alClient;

  Width := FCalcImage.Picture.Bitmap.Width;
  Height := FCalcImage.Picture.Bitmap.Height;

  TabStop := False;
  Visible := False;

  FCalcImage.OnMouseDown := DoOnMouseDown;
  PressedButton := Point(0, 0);
  IsInverted := False;

  FCalculatorEdit := nil;
  IsFirst := True;
end;

{
  --------------------------------
  ---- TxCalulatorEdit Class  ----
  --------------------------------
}

{
  ********************
  **  Private Part  **
  ********************
}

{
  �� ��������� �������� ���� ���������� � ���� ��������� ��� ������.
  ��������� ����������� ������ ����
}

procedure TxCalculatorEdit.WMSize(var Message: TWMSize);
var
  MinHeight: Integer;
begin
  inherited;
  MinHeight := GetMinHeight;
  if Height < MinHeight then
    Height := MinHeight
  else if FButton <> nil then
  begin
    if NewStyleControls and Ctl3D then
      FButton.SetBounds(Width - FButton.Width - 4, 0, FButton.Width, Height - 4)
    else
      FButton.SetBounds (Width - FButton.Width, 0, FButton.Width, Height);
    SetEditRect;
  end;
end;

{
  �� �������� ������� � ���� �������� ��� ��������
}

procedure TxCalculatorEdit.WMMouseMove(var Message: TWMMouseMove);
begin
  inherited;
  Cursor := crIBeam;
end;

{
  �� ������ Focus-� ������ ���� ������������
}

procedure TxCalculatorEdit.WMKillFocus(var Message: TWMKillFocus);
begin
  if not (csDesigning in ComponentState) then
    if FCalculator.Visible and (Message.FocusedWND <> FCalculator.Handle)
       and (Message.FocusedWND <> Handle)
    then
      FCalculator.Visible := False;

  inherited;
end;

{
  ������ �����������, ���� ������� ������ ����������
}

procedure TxCalculatorEdit.CMCancelMode(var Message: TCMCancelMode);
begin
  inherited;
  if not (csDesigning in ComponentState) then
    if (Message.Sender <> Self) and (Message.Sender <> FCalculator) and
      (Message.Sender <> FButton) and (Message.Sender <> FCalculator.FCalcImage) then
    begin
      FCalculator.Hide;
      ExpressionAction := eaNone;
    end;
end;

procedure TxCalculatorEdit.CMCtl3DChanged(var Message: TMessage);
begin
  inherited;

  if FButton <> nil then
  begin
    FButton.Is3D := Ctl3d;
    FButton.Repaint;
  end;
end;

{
  ������������� ������ ����� � TEdit.
}

procedure TxCalculatorEdit.SetEditRect;
var
  Loc: TRect;
begin
  SendMessage(Handle, EM_GETRECT, 0, LongInt(@Loc));
  Loc.Bottom := ClientHeight + 1;  {+1 is workaround for windows paint bug}
  Loc.Right := ClientWidth - CalcButtonWidth - 2;
  Loc.Top := 0;
  Loc.Left := 0;
  SendMessage(Handle, EM_SETRECT, 0, LongInt(@Loc));
end;

{
  ������������� ����������� ������ ����
}

function TxCalculatorEdit.GetMinHeight: Integer;
var
  DC: HDC;
  SaveFont: HFont;
  SysMetrics, Metrics: TTextMetric;
begin
  DC := GetDC(0);

  try
    GetTextMetrics(DC, SysMetrics);
    SaveFont := SelectObject(DC, Font.Handle);
    GetTextMetrics(DC, Metrics);
    SelectObject(DC, SaveFont);
  finally
    ReleaseDC(0, DC);
  end;

  Result := SysMetrics.tmHeight;
  if Result > Metrics.tmHeight then
    Result := Metrics.tmHeight;
end;

{
  ���� ����� ����������������� ���� ("+" �� "-"; "-" �� "+")
}

procedure TxCalculatorEdit.ChangeInvertion;
begin
  Value := -Value;
  SelStart := Length(Text) + 1;
end;

{
  �� MouseMove ������ ���������� ���� ��������� ��� �������
}

procedure TxCalculatorEdit.DoOnButtonMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  Cursor := crArrow;
end;

{
  �� ������� ������ � Edit-� ���������� ��������� ������������ � ���
  �����������.
}

procedure TxCalculatorEdit.DoOnButtonClick(Sender: TObject);
var
  P: TPoint;
begin
  if not FCalculator.Visible then
  begin
    if ReadOnly then
      exit;

    P := ClientToScreen(Point(0, 0));

    P.X := P.X + Width - FCalculator.Width - 2;

    if P.Y + Height - 1 + FCalculator.Height > GetSystemMetrics(SM_CYSCREEN) then
      P.Y := P.Y - FCalculator.Height - 2
    else
      P.Y := P.Y + Height - 1;

    FCalculator.SetBounds(P.X, P.Y, FCalculator.Width, FCalculator.Height);
//    GetParentForm(Self).ActiveControl := nil;
    NeedToChangeValue := True;
    ExpressionAction := eaNone;
    Value := Value;
    SelStart := Length(Text) + 1;
    FCalculator.Show;
    SetFocus;
  end else begin
    FCalculator.Hide;
    ExpressionAction := eaNone;
  end;
end;

{
  ���������� �����, ���������� ������� � ������ ������ � Edit-�
}

function TxCalculatorEdit.GetValue: Double;
var
  L: Integer;
begin
  Result := 0;
  if Text > '' then
  begin
    L := SendMessage(Handle, EM_LINEFROMCHAR, SelStart, 0);
    if SL = nil then SL := TStringList.Create;
    SL.Text := Text;
    try
      if (L < SL.Count) and (SL[L] > '') then
        Result := StrToFloat(SL[L])
      else
        Result := StrToFloat(SL[0]);
    except
      on EConvertError do ;
    end;
  end;
end;

{
  ������������� ����� �������� ��� ���� Text � ��������� ����
}

procedure TxCalculatorEdit.SetValue(AValue: Double);
begin
  if Value <> AValue then
  begin
    if DecDigits = -1 then
      Text := FloatToStr(AValue)
    else
      Text := FloatToStrF(AValue, ffFixed, 15, DecDigits);
  end;    
end;

{
  ���������������, ���-�� ������ ������� �����
}

procedure TxCalculatorEdit.SetDecDigits(ADecDigits: Integer);
begin
  if FDecDigits <> ADecDigits then
  begin
    FDecDigits := ADecDigits;
  end;
end;

{
  **********************
  **  Protected Part  **
  **********************
}

{
  �� �������� ���� ���������� ������� �������� ���������� ��������������
  ������.
}

procedure TxCalculatorEdit.CreateWnd;
begin
  inherited CreateWnd;
  if not (csDesigning in ComponentState) then
  begin
    SetEditRect;
    SelStart := Length(Text) + 1;
  end;
end;

{
  �������� ��������� ���������
}

procedure TxCalculatorEdit.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or WS_CLIPCHILDREN or ES_MULTILINE;
  Params.Style := Params.Style and (not ES_WANTRETURN);
end;

{
  ���������� �������� �����
}

function TxCalculatorEdit.IsValidChar(Key: Char): Boolean;
begin
  Result := (Key in [DecimalSeparator, '0'..'9']) or
    ((Key < #32) and not (Key in [Chr(VK_RETURN)]));
end;

{
  �� ������� ������ ���������� ���� ��������
}

procedure TxCalculatorEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if not (csDesigning in ComponentState) then
  begin
    case Key of
      VK_ESCAPE, VK_MENU:
        if FCalculator.Visible then
        begin
          FCalculator.Hide;
          ExpressionAction := eaNone;
        end else
        begin
          if Assigned(Parent) and (Key = VK_ESCAPE) then
          begin
            PostMessage(Parent.Handle, WM_KEYDOWN, VK_ESCAPE, 0);
            Key := 0;
          end;
        end;
      VK_UP, VK_DOWN, VK_LEFT, VK_RIGHT, VK_NEXT, VK_PRIOR, VK_END, VK_HOME:
        if FCalculator.Visible then Key := 0;
    end;
  end;

  if (Key <> 0) then
    inherited KeyDown(Key, Shift)
end;

{
  ���������� ������� �������� ������ � �������� �� ���� ������������ ��������
  ��� ������ ����� ��������� � ��������� � ���� ��� ����������� ��������
  ��� ������������.
}

procedure TxCalculatorEdit.KeyPress(var Key: Char);

  function CountValue: Double; // ������������ ���������
  begin
    case ExpressionAction of
      eaPlus: Result := OldValue + Value;
      eaMinus: Result := OldValue - Value;
      eaMultiple: Result := OldValue * Value;
      eaDevide: // �������� ������� �� 0
        try
          Result := OldValue / Value;
        except
          on Exception do
          begin
            MessageDlg('������ ������ �� 0!', mtWarning, [MBOK], 0);
            Result := OldValue;
          end;
        end;
      else Result := Value;
    end;

    ExpressionAction := eaEqual;
  end;

begin
  // �������� �� ������� ����� ����: ��������� ������ �������, ���� ����� �����������
  if not FCalculator.Visible and (Ord(Key) = VK_RETURN) then
  begin
    Key := #0;
    PostMessage(Parent.Handle, WM_KEYDOWN, VK_RETURN, 0);
    exit;
  end;

  if ReadOnly then
  begin
    inherited KeyPress(Key);
    exit;
  end;

  if not (csDesigning in ComponentState) then
  begin

    case Key of
      '.', ',', ' ': Key := DecimalSeparator;
    end;

    if not IsValidChar(Key) then
    begin
      if not FCalculator.Visible then
      begin
        if (Key in ['-', '+', '*', '/']) then
        begin
          if (SelLength = Length(Text)) and (Key in ['-', '+']) then
          begin
            inherited KeyPress(Key);
            exit;
          end;

          DoOnButtonClick(FButton);
        end;
      end;

      // ������������ ����������� ������ ������������
      if FCalculator.Visible then
      begin
        case Key of
          '/': FCalculator.InvertByPos(Point(3, 0));
          '*': FCalculator.InvertByPos(Point(3, 1));
          '-': FCalculator.InvertByPos(Point(3, 2));
          '+': FCalculator.InvertByPos(Point(3, 3));
          '=': FCalculator.InvertByPos(Point(3, 4));
          else if AnsiCompareText(Key, 'c') = 0 then
            FCalculator.InvertByPos(Point(0, 4));
        end;
      end;

      if FCalculator.Visible then
      begin
        // ���� ������ ������ ������
        if Key in ['C', 'c', '�', '�'] then
        begin
          Text := '';
          ExpressionAction := eaEqual;
          OldValue := 0;
          OldValueEntered := False;
          NeedToChangeValue := False;
        end
        else if ((Ord(Key) = VK_RETURN) or (Key = '=')) then
        begin // ���� ������ ������ Enter ��� ���� "="
          if not NeedToChangeValue then
          begin
            Value := CountValue;
            SelStart := Length(Text) + 1;
          end;

          FCalculator.Hide;
          OldValue := 0;
          OldValueEntered := False;
        end
        else if (Key in ['+', '-', '*', '/']) then
        begin // ���� ������ ���� �� ����������������� ������
          if OldValueEntered and not NeedToChangeValue then
            Value := CountValue;

          case Key of // ������������� ��� ��������
            '+': ExpressionAction := eaPlus;
            '-': ExpressionAction := eaMinus;
            '*': ExpressionAction := eaMultiple;
            '/': ExpressionAction := eaDevide;
          end;

          // ���������� ���������� ������� ����� ��� ��� ���������
          if not OldValueEntered or (Key <> '=') then
          begin
            OldValue := Value;
            OldValueEntered := True;
            NeedToChangeValue := True;
          end
          else if not NeedToChangeValue then
          begin
            OldValue := 0;
            OldValueEntered := False;
          end;
        end;
      end;

      Key := #0;
    end else
    begin
      // ������������ ����������� ������ ������������
      if FCalculator.Visible then
        case Key of
          '7'..'9': FCalculator.InvertByPos(Point(StrToInt(Key) - 7, 0));
          '4'..'6': FCalculator.InvertByPos(Point(StrToInt(Key) - 4, 1));
          '1'..'3': FCalculator.InvertByPos(Point(StrToInt(Key) - 1, 2));
          '0': FCalculator.InvertByPos(Point(0, 3));
          else if Key = DecimalSeparator then
            FCalculator.InvertByPos(Point(1, 3))
          else if Ord(Key) = VK_BACK then
            FCalculator.InvertByPos(Point(1, 4));
        end;

      if (Ord(Key) = VK_BACK) and FCalculator.Visible then
      begin // ���� ������ ������ BACKSPACE
      end
      else if NeedToChangeValue and FCalculator.Visible then
      begin // ���� ����� ���������� ����� �����
        NeedToChangeValue := False;

        if ExpressionAction = eaNone then
          ExpressionAction := eaEqual;

        if Key <> DecimalSeparator then
          Text := ''
        else
          Text := '0';

      // � ������ �� ����� ���� ��������� ������������
      end
      else if (Key = DecimalSeparator) and (Pos(Key, Text) > 0) then
        Key := #0;
    end;

    // ���� � ������ ����� ������ 0, �� �� ������� ���
    if (Key <> #0) and (Text = '0') and (Key <> DecimalSeparator) then
      Text := '';

    if Key <> #0 then
    begin
      inherited KeyPress(Key);
      // ����������� 0 ��� BACKSPACE
      if (Length(Text) <= 1) and (Ord(Key) = VK_BACK) and FCalculator.Visible then
        Text := '0 ';
    end;
  end else
    inherited KeyPress(Key);

  // ������������� ������� ������� � �����
  { TODO : ��� ������������ ��������, ������ ��� ���� ������������� }
  if FCalculator.Visible then
    SelStart := Length(Text) + 1;
end;

{
  �� ������� ������ ���� ���������� ���� ��������
}

procedure TxCalculatorEdit.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if FCalculator.Visible then
  begin
    FCalculator.Hide;
    ExpressionAction := eaNone;
    SetFocus;
  end;
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TxCalculatorEdit.Loaded;
begin
  inherited Loaded;

  if FButton <> nil then
  begin
    FButton.Is3D := Ctl3d;
    FButton.Repaint;
  end;
end;

{
  *******************
  **  Public Part  **
  *******************
}

{
  �� �������� ���������� ������ ��������� ���������
}

constructor TxCalculatorEdit.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  ControlStyle := ControlStyle - [csSetCaption];

  FButton := TxCalcButton.Create(Self);
  FButton.Glyph.LoadFromResourceName(hInstance, 'CALCBTN');
  FButton.ControlStyle := FButton.ControlStyle - [csAcceptsControls, csSetCaption] +
    [csFramed, csOpaque];

  FButton.Caption := '';
  FButton.Width := CalcButtonWidth;
  FButton.Height := CalcButtonHeight;
  FButton.Visible := True;
  FButton.Parent := Self;
  FButton.Cursor := crArrow;
  FButton.OnMouseMove := DoOnButtonMouseMove;
  FButton.OnClick := DoOnButtonClick;

  if not (csDesigning in ComponentState) then
  begin
    FCalculator := TxCalculator.Create(Self);
    FCalculator.FCalculatorEdit := Self;
    FCalculator.Parent := Self;
  end;

  OldValue := 0;
  OldValueEntered := False;
  ExpressionAction := eaEqual;
  NeedToChangeValue := False;
  FDecDigits := DefDecDigits;
end;

{
  ----------------------------------
  ---- TxDBCalulatorEdit Class  ----
  ----------------------------------
}

{
  ********************
  **  Private Part  **
  ********************
}

{
  �� ��������� ������ ���������� ���� ���������
}

procedure TxDBCalculatorEdit.DataChange(Sender: TObject);
begin
  if FDataLink.Field <> nil then
  begin
    if FDataLink.Field.IsNull then
      Text := ''
    else
      Value := FDataLink.Field.AsFloat;
  end;
end;

{
  �� ��������� ������ �������������� ���������� ���� ��������
}

procedure TxDBCalculatorEdit.EditingChange(Sender: TObject);
begin
  inherited ReadOnly := not FDataLink.Editing;
end;

{
  �� ���������� ������ ���������� ���� ���������
}

procedure TxDBCalculatorEdit.UpdateData(Sender: TObject);
begin
  if FDataLink.Field <> nil then
  begin
    if Trim(Text) = '' then
    begin
      if not FDataLink.Field.IsNull then
        FDataLink.Field.Clear;
    end else
      case FDataLink.Field.DataType of
        ftInteger, ftSmallInt, ftWord:
        begin
        {���������������. ��� ��������� ��������, ���������� � ������� ��,
        ��������� ���� � ����� ������: ���������� ��������� ���������� �� ���
        ������������� �������� ��� ���}
          FDataLink.Field.AsFloat := Trunc(Value);
        end;
        ftString:
        begin
          FDataLink.Field.AsString := Text;
        end
        else begin
          FDataLink.Field.AsFloat := Value;
        end;
      end;
  end;
end;

{
  ��������� ������
}

procedure TxDBCalculatorEdit.CMEnter(var Message: TCMEnter);
begin
  SetFocused(True);
  inherited;
  if SysLocale.FarEast and FDataLink.CanModify then
    inherited ReadOnly := False;
end;

procedure TxDBCalculatorEdit.CMExit(var Message: TCMExit);
begin
  try
    FDataLink.UpdateRecord;
  except
    SetFocus;
    raise;
  end;
  SetFocused(False);
  DoExit;
end;

{
  �� ��������� �� ClipBoard ���������� ������� � ����� ��������������
}

procedure TxDBCalculatorEdit.WMCut(var Message: TMessage);
begin
  FDataLink.Edit;
  inherited;
end;

{
  �������� FDataLink �� ���������.
}

procedure TxDBCalculatorEdit.CMGetDataLink(var Message: TMessage);
begin
  Message.Result := Integer(FDataLink);
end;

{
  �� ��������� � ClipBoard ���������� ������� � ����� ��������������
}

procedure TxDBCalculatorEdit.WMPaste(var Message: TMessage);
begin
  FDataLink.Edit;
  inherited;
end;

{
  �������� ����.
}

function TxDBCalculatorEdit.GetField: TField;
begin
  Result := FDataLink.Field;
end;

{
  �������� ��� �������� ����
}

function TxDBCalculatorEdit.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

{
  �������� ����� DataSource.
}

function TxDBCalculatorEdit.GetDataSource: TDataSource;
begin
  if FDataLink <> nil then
    Result := FDataLink.DataSource
  else
    Result := nil;
end;

{
  �������� ���� � ����������� ��������������
}

function TxDBCalculatorEdit.GetReadOnly: Boolean;
begin
  Result := FDataLink.ReadOnly;
end;

{
  ��������� ����� ��� ����
}

procedure TxDBCalculatorEdit.SetDataField(const Value: string);
begin
  FDataLink.FieldName := Value;
end;

{
  ������������� ����� DataSource.
}

procedure TxDBCalculatorEdit.SetDataSource(Value: TDataSource);
begin
  if FDataLink <> nil then
    FDataLink.DataSource := Value;
end;

{
  ������������� ���� ����������� ��������������
}

procedure TxDBCalculatorEdit.SetReadOnly(Value: Boolean);
begin
  FDataLink.ReadOnly := Value;
end;

{
  **********************
  **  Protected Part  **
  **********************
}

{
  �� ��������� � ������ ���������� ��������� � ������ ����
}

procedure TxDBCalculatorEdit.Change;
begin
  if FDataLink <> nil then FDataLink.Modified;
  inherited Change;
end;

{
  �� ����� �������� ��������� ���� ����������� ���������� ����
  ��������.
}

procedure TxDBCalculatorEdit.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = DataSource) then FDataLink.DataSource := nil;
end;

{
  ���������� ���� � ����������� ��������������
}

function TxDBCalculatorEdit.EditCanModify: Boolean;
begin
  Result := FDataLink.Edit;
end;

{
  �� ������� ������������ ������ ���������� ������� � �����
  �������������� ������
}

procedure TxDBCalculatorEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if (Key = VK_DELETE) or ((Key = VK_INSERT) and (ssShift in Shift)) then
    FDataLink.Edit;
end;

{
  �� ������� ������������ ������ ���������� ������� � �����
  �������������� ������
}

procedure TxDBCalculatorEdit.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  if (Key in [#32..#255]) and (FDataLink.Field <> nil) and
    not FDataLink.Field.IsValidChar(Key) then
  begin
    MessageBeep(0);
    Key := #0;
  end;
  case Key of
    ^H, ^V, ^X, #32..#255:
      FDataLink.Edit;
    #27:
      begin
        FDataLink.Reset;
        SelectAll;
        Key := #0;
      end;
  end;
end;

{
  *******************
  **  Public Part  **
  *******************
}

{
  �� �������� ���������� ���������� ��������� ���������.
}

constructor TxDBCalculatorEdit.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  // ������� � ������������� ��������� ������ FieldDataLink
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnEditingChange := EditingChange;
  FDataLink.OnUpdateData := UpdateData;

  inherited ReadOnly := False;
end;

{
  � ����� ������ ���������� ���������� ������������� ������.
}

destructor TxDBCalculatorEdit.Destroy;
begin
  FDataLink.Free;
  FDataLink := nil;

  inherited Destroy;
end;

{
  ����������� ���������� xCalculatorEdit
}

procedure Register;
begin
  RegisterComponents('x-DataBase', [TxDBCalculatorEdit]);
  RegisterComponents('x-VisualControl', [TxCalculatorEdit]);
end;

procedure TxDBCalculatorEdit.SetDecDigits(ADecDigits: Integer);
begin
  if DecDigits <> ADecDigits then
  begin
    inherited;
    DataChange(nil);
  end;
end;

procedure TxCalculatorEdit.DoEnter;
begin
  inherited;

  if not ReadOnly then
  begin
    SelStart := 0;
    SelLength := Length(Text);
  end;  
end;

procedure TxDBCalculatorEdit.SetFocused(Value: Boolean);
begin
  if FFocused <> Value then
  begin
    FFocused := Value;
    FDataLink.Reset;
  end;
end;

destructor TxCalculatorEdit.Destroy;
begin
  SL.Free;
  inherited;
end;

procedure TxCalculatorEdit.WndProc(var Message: TMessage);
var
  B: PChar;
  S: String;
  OldLParam: LongInt;
begin
  case Message.Msg of
    WM_SETTEXT:
    begin
      OldLParam := Message.LParam;

      if (Message.LParam <> 0) and (PChar(Message.LParam)^ <> #0) then
      begin
        S := FormatFloat('#,##0.########', StrToFloat(PChar(Message.LParam)));
        B := PChar(S);
        Message.LParam := LongInt(B);
      end;

      inherited;

      Message.LParam := OldLParam;
    end;

    WM_GETTEXT:
    begin
      inherited;

      if Message.Result > 0 then
      begin
        B := PChar(Message.LParam);
        while B^ <> #0 do
        begin
          if B^ in [#32, #160, #9] then
          begin
            StrCopy(B, @B[1]);
            Dec(Message.Result);
          end else
            Inc(B, SizeOf(Char));
        end;
      end;
    end;

  else
    inherited;
  end;
end;


procedure TxCalculatorEdit.CMExit(var Message: TCMExit);
var
  S: String;
begin
  S := Text;
  if S > '' then
    Perform(WM_SETTEXT, 0, Longint(PChar(S)));
end;

end.

