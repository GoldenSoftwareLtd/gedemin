
(*

   Partition -- это глобальный раздел программы (например, справочники, отчеты и пр.).
   Chapter   -- это параграф, Partition делится на параграфы.







                 LM (left margin)           back color (BC)
             |<------>|                         |
             |        |                         |
 theme color ============================================------
 (TC)  ------|--      |                         |       |    |  TM (top margin)
             |        |                                 |    |
             |--------|---------------------------------|------
             |        |                                 |
             |        |                                 |
             |        |                                 |
             |        |                                 |
             |        |                                 |
             |        |                                 |
             |--------|---------------------------------|------
             |        |                                 |    | BM (bottom margin)
             |        |                                 |    |
             ============================================------


*)


unit mmTopPanel;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls;

const
  //=======================================================
  // colors для HiColor и выше
  //=======================================================
  clrSelectedRecord = $9CDFF7;
  clrDarkSelectedRecord = $33BBEE;

  // полосатый грид
  clrLightGridLine = $E7F3F7;
  clrDarkGridLine = $D6E7E7;

  // цвет заголовка таблицы
  clrGridFixedColor = $00D6E7E7;

  clrxLabelColor = $002392DC;
  clrYellowLabelColor = $00CBF5F8;

  clrColorTabHighlightColor = $009CDFF7;
  clrColorTabColor = $94a2a5;

  clrDialogColor = $CEDBDE;

  clrMainFormColor = $00A9BFC5;


  (*

    231 123 0    -- оранжевый цвет
    206 206 189  -- заголовок таблицы

    206 206 189
    242 242 228
    128 128 128

  *)

const
  DefTopMargin = 40;
  DefLeftMargin = 140;
  DefBottomMargin = 60;
  DefThemeColor = clWhite;
  DefBackColor = clBlack;

///////////////////////////////////////////////////////////
// InterfaceManager

type
  TmmInterfaceManager = class(TComponent)
  private
    FTopMargin: Integer;
    FLeftMargin: Integer;
    FBottomMargin: Integer;
    FThemeColor: TColor;
    FBackColor: TColor;
    OldOnCreate: TNotifyEvent;

    procedure SetBottomMargin(const Value: Integer);
    procedure SetLeftMargin(const Value: Integer);
    procedure SetTopMargin(const Value: Integer);
    procedure SetBackColor(const Value: TColor);
    procedure SetThemeColor(const Value: TColor);

    procedure DoOnCreate(Sender: TObject);

  protected
    procedure Loaded; override;
    procedure AdjustControls;

  public
    constructor Create(AnOwner: TComponent); override;

    procedure Invalidate;

  published
    property LeftMargin: Integer read FLeftMargin write SetLeftMargin
      default DefLeftMargin;
    property TopMargin: Integer read FTopMargin write SetTopMargin
      default DefTopMargin;
    property BottomMargin: Integer read FBottomMargin write SetBottomMargin
      default DefBottomMargin;
    property ThemeColor: TColor read FThemeColor write SetThemeColor
      default DefThemeColor;
    property BackColor: TColor read FBackColor write SetBackColor
      default DefBackColor;
  end;

///////////////////////////////////////////////////////////
// mmPanel

type
  TmmPanel = class(TPanel)
  private
    procedure SetInterfaceManager(const Value: TmmInterfaceManager);

  protected
    FInterfaceManager: TmmInterfaceManager;

    procedure Loaded; override;
    procedure AdjustAppearance; virtual; abstract;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;

  public
    constructor Create(AnOwner: TComponent); override;

  published
    property InterfaceManager: TmmInterfaceManager read FInterfaceManager
      write SetInterfaceManager;

    // inherited props
    property BevelOuter default bvNone;
    property BevelInner default bvNone;
  end;

///////////////////////////////////////////////////////////
// topPanel

type
  TmmTopPanel = class(TmmPanel)
  private
    FChapterName: String;
    FPartitionName: String;
    UnderMouse: Boolean;

    procedure SetChapterName(const Value: String);
    procedure SetPartitionName(const Value: String);

  protected
    procedure Loaded; override;
    procedure Paint; override;
    procedure AdjustAppearance; override;

    procedure DrawChapterName;

    procedure WMMouseMove(var Message: TWMMouseMove);
      message WM_MOUSEMOVE;

  public
    constructor Create(AnOwner: TComponent); override;

  published
    property PartitionName: String read FPartitionName write SetPartitionName;
    property ChapterName: String read FChapterName write SetChapterName;

    property Align default alTop;
    property Height default DefTopMargin;
  end;

///////////////////////////////////////////////////////////
// bottomPanel

type
  TmmBottomPanel = class(TmmPanel)
  public
    constructor Create(AnOwner: TComponent); override;

  protected
    procedure Paint; override;
    procedure AdjustAppearance; override;

  published
    property Align default alBottom;
    property Height default DefBottomMargin;
  end;

///////////////////////////////////////////////////////////
// leftPanel

type
  TmmLeftPanel = class(TmmPanel)
  public
    constructor Create(AnOwner: TComponent); override;

  protected
    procedure Paint; override;
    procedure Loaded; override;
    procedure AdjustAppearance; override;

  published
    property Align default alLeft;
    property Width default DefLeftMargin;
  end;

///////////////////////////////////////////////////////////
// formPanel

type
  TmmFormPanel = class(TmmPanel)
  protected
    procedure AdjustAppearance; override;

  public
    constructor Create(AnOwner: TComponent); override;

  published
    property Align default alClient;
  end;

implementation

// TmmPanel -----------------------------------------------

constructor TmmPanel.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  Caption := '';
  BevelInner := bvNone;
  BevelOuter := bvNone;
end;

procedure TmmPanel.Loaded;
begin
  inherited Loaded;
  Caption := '';
end;

procedure TmmPanel.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if (AComponent = FInterfaceManager) and (Operation = opRemove) then
    FInterfaceManager := nil;
end;

procedure TmmPanel.SetInterfaceManager(
  const Value: TmmInterfaceManager);
begin
  FInterfaceManager := Value;
  Invalidate;
end;

// TmmTopPanel --------------------------------------------

constructor TmmTopPanel.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  Align := alTop;
  Height := DefTopMargin;
  UnderMouse := False;
end;

procedure TmmTopPanel.Loaded;
begin
  inherited Loaded;
end;

procedure TmmTopPanel.Paint;
begin
  inherited Paint;

  if Assigned(FInterfaceManager) then
  begin
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Color := FInterfaceManager.ThemeColor;
    Canvas.FillRect(Rect(0, 0, FInterfaceManager.LeftMargin, Height));
    Canvas.Brush.Color := FInterfaceManager.BackColor;
    Canvas.FillRect(Rect(FInterfaceManager.LeftMargin, 0, Width, Height));
    DrawChapterName;
  end;
end;

procedure TmmTopPanel.AdjustAppearance;
begin
  if Assigned(FInterfaceManager) then
  begin
    Height := FInterfaceManager.TopMargin;
    Invalidate;
  end;
end;

procedure TmmTopPanel.DrawChapterName;
var
  Y: Integer;
begin
  if Assigned(FInterfaceManager) then
  begin
    Canvas.Font := Font;
    if UnderMouse then
      Canvas.Font.Color := clGray;
    Canvas.Brush.Style := bsClear;
    Y := (Height - Canvas.TextExtent(FChapterName).cy) div 2;
    Canvas.TextOut(0 + 10, Y, FPartitionName);
    Canvas.TextOut(FInterfaceManager.LeftMargin + 20, Y, FChapterName);
  end;
end;

procedure TmmTopPanel.WMMouseMove(var Message: TWMMouseMove);
begin
  inherited;

  if (PopupMenu = nil) or (FInterfaceManager = nil) then
    exit;

  with Message do
  begin
    if (XPos > 0) and (XPos < FInterfaceManager.LeftMargin) and
      (YPos > 0) and (YPos < Height) then
    begin
      if (not UnderMouse) or (not MouseCapture) then
      begin
        MouseCapture := True;
        UnderMouse := True;
        DrawChapterName;
      end;
    end else
    begin
      if MouseCapture or UnderMouse then
      begin
        MouseCapture := False;
        UnderMouse := False;
        DrawChapterName;
      end;
    end;
  end;
end;

procedure TmmTopPanel.SetChapterName(const Value: String);
begin
  FChapterName := Value;
  Invalidate;
end;

procedure TmmTopPanel.SetPartitionName(const Value: String);
begin
  FPartitionName := Value;
  Invalidate;
end;

{ TmmInterfaceManager }

procedure TmmInterfaceManager.AdjustControls;
var
  I: Integer;
begin
  for I := 0 to Owner.ComponentCount - 1 do
    if Owner.Components[I] is TmmPanel then
    begin
      (Owner.Components[I] as TmmPanel).AdjustAppearance;
    end;
end;

constructor TmmInterfaceManager.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FTopMargin := DefTopMargin;
  FLeftMargin := DefLeftMargin;
  FBottomMargin := DefBottomMargin;
  FThemeColor := DefThemeColor;
  FBackColor := DefBackColor;
end;

procedure TmmInterfaceManager.DoOnCreate(Sender: TObject);
begin
  if Assigned(OldOnCreate) then
    OldOnCreate(Sender);
  AdjustControls;
end;

procedure TmmInterfaceManager.Invalidate;
begin
  if Owner is TForm then
    (Owner as TForm).Invalidate;
end;

procedure TmmInterfaceManager.Loaded;
begin
  inherited Loaded;
  if (Owner is TForm) and (ComponentState * [csDesigning] = []) then
  begin
    OldOnCreate := (Owner as TForm).OnCreate;
    (Owner as TForm).OnCreate := DoOnCreate;
  end;
end;

procedure TmmInterfaceManager.SetBackColor(const Value: TColor);
begin
  FBackColor := Value;
  AdjustControls;
end;

procedure TmmInterfaceManager.SetBottomMargin(const Value: Integer);
begin
  FBottomMargin := Value;
  AdjustControls;
end;

procedure TmmInterfaceManager.SetLeftMargin(const Value: Integer);
begin
  FLeftMargin := Value;
  AdjustControls;
end;

procedure TmmInterfaceManager.SetThemeColor(const Value: TColor);
begin
  FThemeColor := Value;
  AdjustControls;
end;

procedure TmmInterfaceManager.SetTopMargin(const Value: Integer);
begin
  FTopMargin := Value;
  AdjustControls;
end;

// TmmBottomPanel -----------------------------------------

procedure TmmBottomPanel.AdjustAppearance;
begin
  if Assigned(FInterfaceManager) then
  begin
    Height := FInterfaceManager.BottomMargin;
    Color := FInterfaceManager.BackColor;
  end;
end;

constructor TmmBottomPanel.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  Align := alBottom;
  Height := DefBottomMargin;
end;

procedure TmmBottomPanel.Paint;
begin
  inherited Paint;
  (*
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := RGB(206, 206, 189);
  Canvas.FillRect(Rect(0, 0, Width, Height));
  *)
end;


{ TmmLeftPanel }

procedure TmmLeftPanel.AdjustAppearance;
begin
  if Assigned(FInterfaceManager) then
  begin
    Width := FInterfaceManager.LeftMargin;
    Color := FInterfaceManager.BackColor;
  end;
end;

constructor TmmLeftPanel.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  Align := alLeft;
  Width := DefLeftMargin;
end;

procedure TmmLeftPanel.Loaded;
begin
  inherited Loaded;
  if Assigned(FInterfaceManager) then
    Color := FInterfaceManager.BackColor;
end;

procedure TmmLeftPanel.Paint;
begin
  inherited Paint;

  if Assigned(FInterfaceManager) then
  begin
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Color := FInterfaceManager.BackColor;
    Canvas.FillRect(GetClientRect);
  end;
end;

{ TmmFormPanel }

procedure TmmFormPanel.AdjustAppearance;
begin
  //...
end;

constructor TmmFormPanel.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  Align := alClient;
end;

end.
