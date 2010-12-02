unit BtnEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, buttons;

type
  TBtnEdit = class;

  TEditSButton = class(TSpeedButton)
  private
    function GetEdit: TBtnEdit;
  public
    property Edit: TBtnEdit read GetEdit;
  end;

  TBtnEdit = class(TCustomEdit)
  private
    FEditButton: TEditSButton;

    function GetMinHeight: Integer;
    function  GetBtnCaption: TCaption;
    function  GetBtnGlyph: TBitmap;
    function  GetBtnWidth: Integer;
    function  GetBtnOnClick: TNotifyEvent;
    function  GetBtnOnMouseDown: TMouseEvent;
    function  GetBtnOnMouseUp: TMouseEvent;
    function  GetBtnCursor: TCursor;

    procedure SetEditRect;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure SetBtnCaption(const Value: TCaption);
    procedure SetBtnCursor(const Value: TCursor);
    procedure SetBtnGlyph(const Value: TBitmap);
    procedure SetBtnWidth(const Value: Integer);
    procedure SetBtnMouseDown(const Value: TMouseEvent);
    procedure SetBtnOnClick(const Value: TNotifyEvent);
    procedure SetBtnOnMouseUp(const Value: TMouseEvent);
    function GetAction: TBasicAction;
    procedure SetAction(const Value: TBasicAction);
    function GetBtnShowHint: Boolean;
    procedure SetBtnShowHint(const Value: Boolean);
  protected
    function GetEnabled: Boolean; override;

    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure SetEnabled(Value: Boolean); override;
  public
    constructor Create(AOwner: TComponent); override;

    procedure AssignSize(Source: TBtnEdit);
  published
    property BtnCaption: TCaption read GetBtnCaption write SetBtnCaption;
    property BtnCursor: TCursor read GetBtnCursor write SetBtnCursor;
    property BtnGlyph: TBitmap read GetBtnGlyph write SetBtnGlyph;
    property BtnShowHint: Boolean read GetBtnShowHint write SetBtnShowHint;
    property BtnWidth: Integer read GetBtnWidth write SetBtnWidth;
    property BtnOnClick: TNotifyEvent read GetBtnOnClick write SetBtnOnClick;
    property BtnOnMouseDown: TMouseEvent read GetBtnOnMouseDown write SetBtnMouseDown;
    property BtnOnMouseUp: TMouseEvent read GetBtnOnMouseUp write SetBtnOnMouseUp;

    property Action: TBasicAction read GetAction write SetAction;
    property Anchors;
    property AutoSelect;
    property AutoSize;
    property Color;
    property Constraints;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property Enabled: Boolean read GetEnabled write SetEnabled;
    property Font;
    property MaxLength;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Text;
    property Visible;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDrag;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TBtnEdit]);
end;

{ TBtnEdit }

procedure TBtnEdit.AssignSize(Source: TBtnEdit);
begin
  BoundsRect := Source.BoundsRect;
  Align   := Source.Align;
  Anchors := Source.Anchors;
  FEditButton.Width  := Source.FEditButton.Width;
  FEditButton.Height := Source.FEditButton.Height;
end;

constructor TBtnEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 171;
  Height := 24;
  FEditButton := TEditSButton.Create(Self);
  FEditButton.Width := 50;
  FEditButton.Height := 19;
  FEditButton.Visible := True;
  FEditButton.Parent := Self;
  FEditButton.Align := alRight;
  FEditButton.Cursor := crArrow;
  ControlStyle := ControlStyle - [csSetCaption];
end;

procedure TBtnEdit.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or ES_MULTILINE or WS_CLIPCHILDREN;
end;

procedure TBtnEdit.CreateWnd;
begin
  inherited CreateWnd;
  SetEditRect;
end;

function TBtnEdit.GetAction: TBasicAction;
begin
  Result := FEditButton.Action;
end;

function TBtnEdit.GetBtnCaption: TCaption;
begin
  Result := FEditButton.Caption;
end;

function TBtnEdit.GetBtnCursor: TCursor;
begin
  Result := FEditButton.Cursor;
end;

function TBtnEdit.GetBtnGlyph: TBitmap;
begin
  Result := FEditButton.Glyph;
end;

function TBtnEdit.GetBtnOnClick: TNotifyEvent;
begin
  Result := FEditButton.OnClick;
end;

function TBtnEdit.GetBtnOnMouseDown: TMouseEvent;
begin
  Result := FEditButton.OnMouseDown;
end;

function TBtnEdit.GetBtnOnMouseUp: TMouseEvent;
begin
  Result := FEditButton.OnMouseUp;
end;

function TBtnEdit.GetBtnShowHint: Boolean;
begin
  Result := FEditButton.ShowHint;
end;

function TBtnEdit.GetBtnWidth: Integer;
begin
  Result := FEditButton.Width;
end;

function TBtnEdit.GetEnabled: Boolean;
begin
  Result := Inherited GetEnabled;
end;

function TBtnEdit.GetMinHeight: Integer;
var
  DC: HDC;
  SaveFont: HFont;
  I: Integer;
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
  I := SysMetrics.tmHeight;
  if I > Metrics.tmHeight then I := Metrics.tmHeight;
  Result := Metrics.tmHeight + I div 4 + GetSystemMetrics(SM_CYBORDER) * 4 + 2;
end;

procedure TBtnEdit.SetAction(const Value: TBasicAction);
begin
  FEditButton.Action := Value;
end;

procedure TBtnEdit.SetBtnCaption(const Value: TCaption);
begin
  FEditButton.Caption := Value;
end;

procedure TBtnEdit.SetBtnCursor(const Value: TCursor);
begin
  FEditButton.Cursor := Value;
end;

procedure TBtnEdit.SetBtnGlyph(const Value: TBitmap);
begin
  FEditButton.Glyph := Value;
end;

procedure TBtnEdit.SetBtnMouseDown(const Value: TMouseEvent);
begin
  FEditButton.OnMouseDown := Value;
end;

procedure TBtnEdit.SetBtnOnClick(const Value: TNotifyEvent);
begin
  FEditButton.OnClick := Value;
end;

procedure TBtnEdit.SetBtnOnMouseUp(const Value: TMouseEvent);
begin
  FEditButton.OnMouseUp := Value;
end;

procedure TBtnEdit.SetBtnShowHint(const Value: Boolean);
begin
  FEditButton.ShowHint := Value;
end;

procedure TBtnEdit.SetBtnWidth(const Value: Integer);
begin
  FEditButton.Width := Value;
  SetEditRect;
end;

procedure TBtnEdit.SetEditRect;
var
  Loc: TRect;
begin
  SendMessage(Handle, EM_GETRECT, 0, LongInt(@Loc));
  Loc.Bottom := ClientHeight + 1;  {+1 is workaround for windows paint bug}
  Loc.Right := ClientWidth - FEditButton.Width - 2;
  Loc.Top := 0;
  Loc.Left := 0;
  SendMessage(Handle, EM_SETRECTNP, 0, LongInt(@Loc));
  SendMessage(Handle, EM_GETRECT, 0, LongInt(@Loc));  {debug}
end;

procedure TBtnEdit.SetEnabled(Value: Boolean);
begin
  Inherited SetEnabled(Value);
  FEditButton.Enabled := Self.Enabled;
end;

procedure TBtnEdit.WMSize(var Message: TWMSize);
var
  MinHeight: Integer;
begin
  inherited;
  MinHeight := GetMinHeight;
    { text edit bug: if size to less than minheight, then edit ctrl does
      not display the text }
  if Height < MinHeight then
    Height := MinHeight
  else if FEditButton <> nil then
  begin
    if NewStyleControls and Ctl3D then
      FEditButton.SetBounds(Width - FEditButton.Width - 5, 0, FEditButton.Width, Height - 5)
    else FEditButton.SetBounds (Width - FEditButton.Width, 1, FEditButton.Width, Height - 3);
    SetEditRect;
  end;
end;

{ TEditSButton }

function TEditSButton.GetEdit: TBtnEdit;
begin
  if Parent is TBtnEdit then
    Result := TBtnEdit(Parent)
  else
    Result := nil;
end;

end.
