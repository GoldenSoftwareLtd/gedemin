
unit mxButton;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

const
  DefFrameColor = $E7F3F7;
  DefFocusFrameColor = $525152;
  DefNormalColor = $94A2A5;
  DefPressedColor = clBlack;
  DefNormalTextColor = clBlack;
  DefHighlightTextColor = clWhite;

type
  TmxButton = class(TCustomControl)
  private
    FDefault: Boolean;
    FCaption: String;
    FPressedColor: TColor;
    FFocusFrameColor: TColor;
    FNormalTextColor: TColor;
    FNormalColor: TColor;
    FHighlightTextColor: TColor;
    FFrameColor: TColor;
    FFont: TFont;
    procedure SetCaption(const Value: String);
    procedure SetDefault(const Value: Boolean);
    procedure SetFocusFrameColor(const Value: TColor);
    procedure SetFrameColor(const Value: TColor);
    procedure SetHighlightTextColor(const Value: TColor);
    procedure SetNormalColor(const Value: TColor);
    procedure SetNormalTextColor(const Value: TColor);
    procedure SetPressedColor(const Value: TColor);
    procedure SetFont(const Value: TFont);

  protected
    procedure Paint; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

  published
    property Caption: String read FCaption write SetCaption;
    property Default: Boolean read FDefault write SetDefault
      default False;
    property FrameColor: TColor read FFrameColor write SetFrameColor
      default DefFrameColor;
    property FocusFrameColor: TColor read FFocusFrameColor write SetFocusFrameColor
      default DefFocusFrameColor;
    property NormalColor: TColor read FNormalColor write SetNormalColor
      default DefNormalColor;
    property PressedColor: TColor read FPressedColor write SetPressedColor
      default DefPressedColor;
    property NormalTextColor: TColor read FNormalTextColor write SetNormalTextColor
      default DefNormalTextColor;
    property HighlightTextColor: TColor read FHighlightTextColor write SetHighlightTextColor
      default DefHighlightTextColor;
    property Font: TFont read FFont write SetFont;  
  end;

procedure Register;

implementation

uses
  Rect;

{ TmxButton }

constructor TmxButton.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FDefault := False;
  FFrameColor := DefFrameColor;
  FFocusFrameColor := DefFocusFrameColor;
  FNormalColor := DefNormalColor;
  FPressedColor := DefPressedColor;
  FNormalTextColor := DefNormalTextColor;
  FHighlightTextColor := DefHighlightTextColor;
  FFont := TFont.Create;
end;

destructor TmxButton.Destroy;
begin
  inherited Destroy;
  FFont.Free;
end;

procedure TmxButton.Paint;
var
  R: TRect;
begin
  R := GetClientRect;
  Canvas.Brush.Color := FrameColor;
  Canvas.Brush.Style := bsSolid;
  Canvas.FrameRect(R);
  RectGrow(R, -1);
  Canvas.Brush.Color := NormalColor;
  Canvas.FillRect(R);

end;

procedure TmxButton.SetCaption(const Value: String);
begin
  FCaption := Value;
end;

procedure TmxButton.SetDefault(const Value: Boolean);
begin
  FDefault := Value;
end;

procedure TmxButton.SetFocusFrameColor(const Value: TColor);
begin
  FFocusFrameColor := Value;
end;

procedure TmxButton.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TmxButton.SetFrameColor(const Value: TColor);
begin
  FFrameColor := Value;
end;

procedure TmxButton.SetHighlightTextColor(const Value: TColor);
begin
  FHighlightTextColor := Value;
end;

procedure TmxButton.SetNormalColor(const Value: TColor);
begin
  FNormalColor := Value;
end;

procedure TmxButton.SetNormalTextColor(const Value: TColor);
begin
  FNormalTextColor := Value;
end;

procedure TmxButton.SetPressedColor(const Value: TColor);
begin
  FPressedColor := Value;
end;

// Register ----------------------------------------------

procedure Register;
begin
  RegisterComponents('gsBtn', [TmxButton]);
end;

end.
