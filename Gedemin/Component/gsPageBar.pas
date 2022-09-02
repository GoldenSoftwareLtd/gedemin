// ShlTanya, 20.02.2019

{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    gsPageBar.pas

  Abstract

    Control that works like page bar in outlook.

  Author

    Romanovski Denis  (30.01.2001)

  Revisions history

    1.0    Denis    30.01.2001    Initial version.


--}


unit gsPageBar;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, ExtCtrls,
  StdCtrls, Dialogs;

type
  TgsPage = class;
  TgsPageBand = class;
  TgsPageBands = class;
  TgsPageBar = class;

  
  TgsPagePanel = class(TPanel)
  private
    function GetPage: TgsPage;
    procedure DrawTriangle(const X, Y: Integer; AColor: TColor; Opened: Boolean);

    procedure CMDesignHitTest(var Message: TCMDesignHitTest);
      message CM_DESIGNHITTEST;
    procedure WMEraseBkgnd(var Message: TWmEraseBkgnd);
      message WM_ERASEBKGND;

  protected
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Paint; override;

    property Page: TgsPage read GetPage;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

  published

  end;


  TgsPage = class(TCustomControl)
  private
    FPanel: TgsPagePanel;

    FControl: TWinControl;
    FPageBand: TgsPageBand;

    FUpdateCount: Integer;

    function GetIsValid: Boolean;

  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
    procedure UpdateControls;

    function CountHeight: Integer;

    property IsValid: Boolean read GetIsValid;

  public
    constructor Create(APageBand: TgsPageBand); reintroduce;
    destructor Destroy; override;

    procedure OpenPage;
    procedure ClosePage;

  end;


  TgsPageBand = class(TCollectionItem)
  private
    FPage: TgsPage;
    FPageBands: TgsPageBands;
    FHeight: Integer;
    FText: String;
    FPageOpened: Boolean;

    procedure SetControl(const Value: TWinControl);
    procedure SetHeight(const Value: Integer);
    function GetText: String;
    procedure SetText(const Value: String);
    function GetControl: TWinControl;
    procedure SetPageOpened(const Value: Boolean);
    function GetColor: TColor;
    function GetFont: TFont;
    procedure SetColor(const Value: TColor);
    procedure SetFont(const Value: TFont);

  protected
    function GetDisplayName: string; override;

  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    property PageBands: TgsPageBands read FPageBands;

  published
    property Control: TWinControl read GetControl write SetControl;
    property Height: Integer read FHeight write SetHeight;
    property Text: String read GetText write SetText;
    property PageOpened: Boolean read FPageOpened write SetPageOpened;
    property Color: TColor read GetColor write SetColor;
    property Font: TFont read GetFont write SetFont;

  end;


  TgsPageBands = class(TCollection)
  private
    FPageBar: TgsPageBar;

    function GetItem(Index: Integer): TgsPageBand;
    procedure SetItem(Index: Integer; const Value: TgsPageBand);

  protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;

    procedure UpdateBand(const Index: Integer);
    procedure UpdateBands;

  public
    constructor Create(APageBar: TgsPageBar);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;

    function Add: TgsPageBand;
    function FindBand(AControl: TWinControl): TgsPageBand;

    property PageBar: TgsPageBar read FPageBar;
    property Items[Index: Integer]: TgsPageBand read GetItem write SetItem; default;

  end;


  TgsPageBar = class(TScrollingWinControl)
  private
    FPageBands: TgsPageBands;

    FUpdateCount: Integer;
    FBorderStyle: TBorderStyle;

    procedure SetPageBands(const Value: TgsPageBands);
    procedure SetBorderStyle(const Value: TBorderStyle);

    procedure WMNCHitTest(var Message: TMessage); message WM_NCHITTEST;
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
    procedure CreateParams(var Params: TCreateParams); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

  published
    property PageBands: TgsPageBands read FPageBands write SetPageBands;

    property Align;
    property Anchors;
    property AutoScroll;
    property AutoSize;
    property BiDiMode;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
    property Constraints;
    property DockSite;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Color nodefault;
    property Ctl3D;
    property Font;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnCanResize;
    property OnClick;
    property OnConstrainedResize;
    property OnContextPopup;
    property OnDblClick;
    property OnDockDrop;
    property OnDockOver;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetSiteInfo;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;

  end;

procedure Register;

implementation

{$R GSPAGEBAR.RES}

{ TgsPage }

procedure TgsPage.AlignControls(AControl: TControl; var Rect: TRect);
var
  NewHeight: Integer;
begin
  if (FUpdateCount = 0) and not (csDestroying in ComponentState) then
  begin
    FPanel.SetBounds(Rect.Left, Rect.Top, Rect.Right, Rect.Top + FPanel.Height);

    if Assigned(FControl) then
    begin
      if FPageBand.FPageOpened then
        NewHeight := FPageBand.Height
      else
        NewHeight := 0;

      FControl.SetBounds(Rect.Left, FPanel.Top + FPanel.Height,
        Rect.Right, NewHeight);
    end;
  end;      
end;

procedure TgsPage.UpdateControls;
var
  NewHeight: Integer;
begin
  if FUpdateCount = 0 then
  begin
    FPanel.SetBounds(0, 0, Width, FPanel.Height);
    FPanel.Repaint;

    if Assigned(FControl) then
    begin
      if FPageBand.FPageOpened then
        NewHeight := FPageBand.Height
      else
        NewHeight := 0;

      FControl.SetBounds(0, FPanel.Top + FPanel.Height, Width, NewHeight);
    end;
  end;
end;

function TgsPage.CountHeight: Integer;
begin
  Result := FPanel.Top + FPanel.Height;

  if Assigned(FControl) and FPageBand.PageOpened then
    Inc(Result, FControl.Height);
end;

procedure TgsPage.ClosePage;
var
  Step: Integer;
begin
  Inc(FUpdateCount);

  try
    Step := Height div 2;

    while Height > FPanel.Height do
    begin
      Height := Height - Step;

      Step := Step div 2;
      if Step < 2 then Step := 2;
      //Application.ProcessMessages;
    end;

    Height := FPanel.Height;
    if Assigned(FControl) then
      FControl.Enabled := False;

    FPageBand.PageBands.FPageBar.Perform(WM_SIZE, 0, 0);
    FPanel.Repaint;
  finally
    Dec(FUpdateCount);
    UpdateControls;
  end;
end;

constructor TgsPage.Create(APageBand: TgsPageBand);
begin
  inherited Create(APageBand.PageBands.FPageBar);

  FPageBand := APageBand;
  //Align := alTop;
  FUpdateCount := 0;

  // Панель
  FPanel := TgsPagePanel.Create(Self);
  InsertControl(FPanel);
end;

destructor TgsPage.Destroy;
begin
  inherited;
end;

function TgsPage.GetIsValid: Boolean;
begin
  Result := Assigned(FControl);
end;

procedure TgsPage.OpenPage;
var
  Step: Integer;
begin
  Inc(FUpdateCount);

  try
    Step := FPageBand.Height div 2;

    while Height < FPageBand.Height + FPanel.Height do
    begin
      Height := Height + Step;

      Step := Step div 2;
      if Step < 2 then Step := 2;
      //Application.ProcessMessages;
    end;

    Height := FPageBand.Height + FPanel.Height;
    if Assigned(FControl) then
      FControl.Enabled := True;

    FPageBand.PageBands.FPageBar.Perform(WM_SIZE, 0, 0);
    FPanel.Repaint;
  finally
    Dec(FUpdateCount);
    UpdateControls;
    
    if Top + Height > FPageBand.PageBands.FPageBar.ClientHeight then
      FPageBand.PageBands.FPageBar.VertScrollBar.Position := Top + Height;
  end;
end;

procedure TgsPage.CreateParams(var Params: TCreateParams);
begin
  inherited;

  with Params do
    WindowClass.Style := WindowClass.Style and not (CS_HREDRAW or CS_VREDRAW);
end;

{ TgsPageBand }

procedure TgsPageBand.Assign(Source: TPersistent);
begin
  if Source is TgsPageBand then
  begin
    Inc(FPage.FUpdateCount);

    Control := (Source as TgsPageBand).Control;
    Height := (Source as TgsPageBand).Height;
    Text := (Source as TgsPageBand).Text;
    PageOpened := (Source as TgsPageBand).PageOpened;
    Color := (Source as TgsPageBand).Color;
    Font := (Source as TgsPageBand).Font;

    Dec(FPage.FUpdateCount);
    Changed(False);
  end;
end;

constructor TgsPageBand.Create(Collection: TCollection);
begin
  inherited;

  FPageBands := Collection as TgsPageBands;
  
  FPage := TgsPage.Create(Self);
  FPageBands.FPageBar.InsertControl(FPage);
end;

destructor TgsPageBand.Destroy;
begin
  // Необходимо для возврата контрола
  Control := nil;

  if Assigned(FPage) then
    FreeAndNil(FPage);

  inherited;
end;

function TgsPageBand.GetColor: TColor;
begin
  Result := FPage.FPanel.Color;
end;

function TgsPageBand.GetControl: TWinControl;
begin
  if Assigned(FPage) then
    Result := FPage.FControl
  else
    Result := nil;  
end;

function TgsPageBand.GetDisplayName: string;
begin
  if FText > '' then
    Result := FText
  else
    Result := inherited GetDisplayName;
end;

function TgsPageBand.GetFont: TFont;
begin
  Result := FPage.FPanel.Font;
end;

function TgsPageBand.GetText: String;
begin
  if FText > '' then
    Result := FText
  else
    Result := DisplayName;
end;

procedure TgsPageBand.SetColor(const Value: TColor);
begin
  FPage.FPanel.Color := Value;
end;

procedure TgsPageBand.SetControl(const Value: TWinControl);
var
  F: TCustomForm;
begin
  if not Assigned(FPage) then Exit;

  if FPage.FControl <> Value then
  begin
    if
      (Value = PageBands.FPageBar)
        or
      Assigned(Value) and Assigned(PageBands.FindBand(Value))
    then
      Exit;

    if Assigned(FPage) then
    with FPage do
    begin
      if Assigned(FControl) then
      begin
        RemoveControl(FControl);
        FControl.RemoveFreeNotification(PageBands.FPageBar);

        if not (csDestroying in FControl.ComponentState) then
        begin
          F := GetParentForm(FPage);
          if Assigned(F) then
            F.InsertControl(FControl);

          FControl.Height := Self.Height;
        end;
      end;

      FControl := Value;

      if Assigned(FControl) then
      begin
        FHeight := FControl.Height;

        if Assigned(FControl.Parent) then
          FControl.Parent.RemoveControl(FControl);

        FControl.Height := 0;
        FControl.Enabled := False;
        PageOpened := False;

        InsertControl(FControl);
        FControl.FreeNotification(PageBands.FPageBar);
      end else
        FHeight := 0;
    end;

    Changed(False);
  end;
end;

procedure TgsPageBand.SetFont(const Value: TFont);
begin
  FPage.FPanel.Font := Value;
end;

procedure TgsPageBand.SetHeight(const Value: Integer);
begin
  FHeight := Value;
  Changed(False);
end;

procedure TgsPageBand.SetPageOpened(const Value: Boolean);
begin
  if FPageOpened <> Value then
  begin
    FPageOpened := Value;
    if FPageOpened then
      FPage.OpenPage
    else
      FPage.ClosePage;
  end;
end;

procedure TgsPageBand.SetText(const Value: String);
begin
  if FText <> Value then
  begin
    FText := Value;
    Changed(False);
  end;
end;

{ TgsPageBands }

function TgsPageBands.Add: TgsPageBand;
begin
  Result := TgsPageBand(inherited Add);
  if Count > 1 then
    Items[Count - 2].Changed(False);
end;

procedure TgsPageBands.Assign(Source: TPersistent);
begin
  if Source is TgsPageBands then
    FPageBar := (Source as TgsPageBands).FPageBar;

  inherited Assign(Source);
end;

constructor TgsPageBands.Create(APageBar: TgsPageBar);
begin
  inherited Create(TgsPageBand);
  FPageBar := APageBar;
end;

destructor TgsPageBands.Destroy;
begin
  inherited;

end;

function TgsPageBands.FindBand(AControl: TWinControl): TgsPageBand;
var
  I: Integer;
begin
  if AControl <> nil then
    for I := 0 to Count - 1 do
      if Items[I].Control = AControl then
      begin
        Result := Items[I];
        Exit;
      end;

  Result := nil;  
end;

function TgsPageBands.GetItem(Index: Integer): TgsPageBand;
begin
  Result := (inherited GetItem(Index) as TgsPageBand);
end;

function TgsPageBands.GetOwner: TPersistent;
begin
  Result := FPageBar;
end;

procedure TgsPageBands.SetItem(Index: Integer; const Value: TgsPageBand);
begin
  inherited SetItem(Index, Value);
end;

procedure TgsPageBands.Update(Item: TCollectionItem);
begin
  if (Item <> nil) then
    UpdateBand(Item.Index)
  else
    UpdateBands;
end;

procedure TgsPageBands.UpdateBand(const Index: Integer);
begin
  if Assigned(Items[Index].FPage) then
  with Items[Index].FPage do
  begin
    UpdateControls;
    Height := CountHeight;
  end;
end;

procedure TgsPageBands.UpdateBands;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    UpdateBand(I);
end;

{ TgsPageBar }

procedure TgsPageBar.AlignControls(AControl: TControl; var Rect: TRect);
var
  I: Integer;
  CurrPos: Integer;
begin
  if (FUpdateCount > 0) or (csDestroying in ComponentState) then Exit;

  Inc(FUpdateCount);
  try
    CurrPos := - VertScrollBar.Position;
    for I := 0 to FPageBands.Count - 1 do
    with FPageBands[I] do
    begin
      if not Assigned(FPage) then Continue;
      
      FPage.Left := Rect.Left;
      FPage.Width := Rect.Right;
      FPage.Top := CurrPos;
      Inc(CurrPos, FPage.Height);
    end;
  finally
    Dec(FUpdateCount);
  end;
end;

procedure TgsPageBar.CMCtl3DChanged(var Message: TMessage);
begin
  if NewStyleControls and (FBorderStyle = bsSingle) then RecreateWnd;
  inherited;
end;

constructor TgsPageBar.Create(AOwner: TComponent);
begin
  inherited;

  ControlStyle := [csCaptureMouse, csClickEvents, csDoubleClicks];
  FBorderStyle := bsSingle;

  FPageBands := TgsPageBands.Create(Self);
  FUpdateCount := 0;

  Width := 100;
  Height := 100;

  Color := clBtnFace;
end;

procedure TgsPageBar.CreateParams(var Params: TCreateParams);
const
  BorderStyles: array[TBorderStyle] of DWORD = (0, WS_BORDER);
begin
  inherited CreateParams(Params);

  with Params do
  begin
    Style := Style or BorderStyles[FBorderStyle];
    if NewStyleControls and Ctl3D and (FBorderStyle = bsSingle) then
    begin
      WindowClass.Style := WindowClass.Style and not (CS_HREDRAW or CS_VREDRAW);
      Style := Style and not WS_BORDER;
      ExStyle := ExStyle or WS_EX_CLIENTEDGE;
    end;
  end;
end;

destructor TgsPageBar.Destroy;
begin
  FreeAndNil(FPageBands);
  
  inherited;
end;

procedure TgsPageBar.Notification(AComponent: TComponent;
  Operation: TOperation);
var
  Band: TgsPageBand;
begin
  inherited;

  if (Operation = opRemove) and (AComponent is TWinControl) and
    Assigned(FPageBands) then
  begin
    Band := FPageBands.FindBand(AComponent as TWinControl);

    if Assigned(Band) then
      Band.Control := nil;
  end;
end;

procedure TgsPageBar.SetBorderStyle(const Value: TBorderStyle);
begin
  if Value <> FBorderStyle then
  begin
    FBorderStyle := Value;
    RecreateWnd;
  end;
end;

procedure TgsPageBar.SetPageBands(const Value: TgsPageBands);
begin
  FPageBands.Assign(Value);
end;

procedure TgsPageBar.WMNCHitTest(var Message: TMessage);
begin
  DefaultHandler(Message);
end;

{ TgsPagePanel }

procedure TgsPagePanel.CMDesignHitTest(var Message: TCMDesignHitTest);
begin
  Message.Result := Ord(Page.FControl <> nil);
end;

constructor TgsPagePanel.Create(AnOwner: TComponent);
begin
  inherited;
  
  Height := 20;
  Align := alTop;
  Cursor := crHandPoint;
  TabStop := True;
  FullRepaint := True;
end;

destructor TgsPagePanel.Destroy;
begin
  inherited;
end;

procedure TgsPagePanel.DoEnter;
begin
  inherited;
  Repaint;
end;

procedure TgsPagePanel.DoExit;
begin
  inherited;
  Repaint;
end;

procedure TgsPagePanel.DrawTriangle(const X, Y: Integer; AColor: TColor; Opened: Boolean);
begin
  Canvas.Pen.Color := AColor;

  if Opened then
  begin
    Canvas.MoveTo(X, Y + 7);
    Canvas.LineTo(X + 7, Y + 7);

    Canvas.MoveTo(X + 1, Y + 6);
    Canvas.LineTo(X + 6, Y + 6);

    Canvas.MoveTo(X + 2, Y + 5);
    Canvas.LineTo(X + 5, Y + 5);

    Canvas.Pixels[X + 3, Y + 4] := AColor;
  end else begin
    Canvas.MoveTo(X, Y + 5);
    Canvas.LineTo(X + 7, Y + 5);

    Canvas.MoveTo(X + 1, Y + 6);
    Canvas.LineTo(X + 6, Y + 6);

    Canvas.MoveTo(X + 2, Y + 7);
    Canvas.LineTo(X + 5, Y + 7);

    Canvas.Pixels[X + 3, Y + 8] := AColor;
  end;

  Canvas.MoveTo(X + 11, Y + 1);
  Canvas.LineTo(X + 11, Y + 13);
end;

function TgsPagePanel.GetPage: TgsPage;
begin
  Result := Owner as TgsPage;
end;

procedure TgsPagePanel.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;

  if (Key = VK_SPACE) and (Page.FUpdateCount = 0) then
    Page.FPageBand.PageOpened := not Page.FPageBand.PageOpened;
end;

procedure TgsPagePanel.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;

  if (Button = mbLeft) then
  begin
    if Page.FUpdateCount = 0 then
      Page.FPageBand.PageOpened := not Page.FPageBand.PageOpened;

    if not Focused then
    begin
      SetFocus;
      Repaint;
    end;
  end;  
end;

procedure TgsPagePanel.Paint;
var
  R: TRect;
begin
  Canvas.Brush.Color := Color;
  Canvas.FillRect(ClientRect);

  if Page.FPageBand.PageOpened or
    (Page.FPageBand.Index = Page.FPageBand.PageBands.Count - 1)
  then begin
    Canvas.Pen.Color := clGray;
    Canvas.MoveTo(ClientRect.Left, ClientRect.Bottom - 1);
    Canvas.LineTo(ClientRect.Right, ClientRect.Bottom - 1);
  end;

  Canvas.Pen.Color := clGray;
  Canvas.MoveTo(ClientRect.Left, 0);
  Canvas.LineTo(ClientRect.Right, 0);

  Canvas.Font := Font;
  DrawTriangle(3, 3, Canvas.Font.Color, Page.FPageBand.PageOpened);

  with ClientRect do
    R := Rect(Left + 18, Top + 2, Right - 2, Bottom - 2);

  Canvas.TextRect(R, 22, 2, Page.FPageBand.DisplayName);

  if Focused then
    Canvas.DrawFocusRect(R);
end;

procedure TgsPagePanel.WMEraseBkgnd(var Message: TWmEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure Register;
begin
  RegisterComponents('gsNew', [TgsPageBar]);
end;

end.

