// ShlTanya, 20.02.2019

unit gsPanel;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls;

type
  TgsPanel = class(TPanel)
  private
    FBorderColor: TColor;
    FTextArea3: TStrings;
    FTextArea1: TStrings;
    FTextArea2: TStrings;
    FWidthArea2: Integer;
    FHeightArea1: Integer;
    FFontArea1: TFont;
    FFontArea2: TFont;
    FFontArea3: TFont;
    procedure SetTextArea1(const Value: TStrings);
    procedure SetTextArea2(const Value: TStrings);
    procedure SetTextArea3(const Value: TStrings);

    procedure SetBorderColor(const Value: TColor);

    procedure SetFontArea1(const Value: TFont);
    procedure SetFontArea2(const Value: TFont);
    procedure SetFontArea3(const Value: TFont);
    { Private declarations }
  protected
    { Protected declarations }
    procedure Paint; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

  published
    { Published declarations }
    property BorderColor: TColor read FBorderColor write SetBorderColor;

    property TextArea1: TStrings read FTextArea1 write SetTextArea1;
    property TextArea2: TStrings read FTextArea2 write SetTextArea2;
    property TextArea3: TStrings read FTextArea3 write SetTextArea3;

    property FontArea1: TFont read FFontArea1 write SetFontArea1;
    property FontArea2: TFont read FFontArea2 write SetFontArea2;
    property FontArea3: TFont read FFontArea3 write SetFontArea3;

    property HeightArea1: Integer read FHeightArea1 write FHeightArea1;
    property WidthArea2: Integer read FWidthArea2 write FWidthArea2;

  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('X-VisualControl', [TgsPanel]);
end;

{ TgsPanel }

constructor TgsPanel.Create(AOwner: TComponent);
begin
  inherited;
  FBorderColor := clWindowFrame;

  FTextArea1 := TStringList.Create;
  FTextArea2 := TStringList.Create;
  FTextArea3 := TStringList.Create;

  FFontArea1 := TFont.Create;
  FFontArea2 := TFont.Create;
  FFontArea3 := TFont.Create;

  BevelOuter := bvNone;
  BevelInner := bvNone;
end;

destructor TgsPanel.Destroy;
begin
  inherited;

  FFontArea1.Free;
  FFontArea2.Free;
  FFontArea3.Free;

  FTextArea1.Free;
  FTextArea2.Free;
  FTextArea3.Free;
end;

procedure TgsPanel.Paint;
const
  Alignments: array[TAlignment] of Longint = (DT_LEFT, DT_RIGHT, DT_CENTER);
var
  Rect: TRect;
  TopColor, BottomColor: TColor;
  Flags: Longint;

  procedure AdjustColors(Bevel: TPanelBevel);
  begin
    TopColor := clBtnHighlight;
    if Bevel = bvLowered then TopColor := clBtnShadow;
    BottomColor := clBtnShadow;
    if Bevel = bvLowered then BottomColor := clBtnHighlight;
  end;

begin
  Rect := GetClientRect;
  if BevelOuter <> bvNone then
  begin
    AdjustColors(BevelOuter);
    Frame3D(Canvas, Rect, TopColor, BottomColor, BevelWidth);
  end;
  Frame3D(Canvas, Rect, BorderColor, BorderColor, BorderWidth);
  if BevelInner <> bvNone then
  begin
    AdjustColors(BevelInner);
    Frame3D(Canvas, Rect, TopColor, BottomColor, BevelWidth);
  end; 
  with Canvas do
  begin
    Brush.Color := Color;
    FillRect(Rect);
    Brush.Style := bsClear;

    if TextArea1.Count > 0 then
    begin
      Font := Self.FontArea1;
      with Rect do
      begin
        Top := BorderWidth + 1;
        Bottom := Top + HeightArea1;
        Left := BorderWidth;
      end;
      Flags := DT_TOP or Alignments[Alignment];
      Flags := DrawTextBiDiModeFlags(Flags);
      DrawText(Handle, TextArea1.GetText, -1, Rect, Flags);
    end;

    if TextArea2.Count > 0 then
    begin
      Font := Self.FontArea2;
      with Rect do
      begin
        Top := BorderWidth + HeightArea1 + 1;
        Bottom := Self.Height - BorderWidth - 1;
        Left := BorderWidth;
        Right := BorderWidth + WidthArea2 + 1;
      end;
      Flags := DT_BOTTOM or DT_LEFT;
      Flags := DrawTextBiDiModeFlags(Flags);
      DrawText(Handle, TextArea2.GetText, -1, Rect, Flags);
    end;

    if TextArea3.Count > 0 then
    begin
      Font := Self.FontArea3;
      with Rect do
      begin
        Top := BorderWidth + HeightArea1 + 1;
        Bottom := Self.Height - BorderWidth - 1;
        Left := WidthArea2 + BorderWidth + 2;
        Right := Self.Width - BorderWidth;
      end;
      Flags := DT_BOTTOM or DT_RIGHT;
      Flags := DrawTextBiDiModeFlags(Flags);
      DrawText(Handle, TextArea3.GetText, -1, Rect, Flags);
    end;
  end;
end;

procedure TgsPanel.SetBorderColor(const Value: TColor);
begin
  FBorderColor := Value;
  Invalidate;
end;

procedure TgsPanel.SetFontArea1(const Value: TFont);
begin
  FFontArea1.Assign(Value);
  Invalidate;
end;

procedure TgsPanel.SetFontArea2(const Value: TFont);
begin
  FFontArea2.Assign(Value);
  Invalidate;
end;

procedure TgsPanel.SetFontArea3(const Value: TFont);
begin
  FFontArea3.Assign(Value);
  Invalidate;
end;

procedure TgsPanel.SetTextArea1(const Value: TStrings);
begin
  FTextArea1.Assign(Value);
  Invalidate;
end;

procedure TgsPanel.SetTextArea2(const Value: TStrings);
begin
  FTextArea2.Assign(Value);
  Invalidate;
end;

procedure TgsPanel.SetTextArea3(const Value: TStrings);
begin
  FTextArea3.Assign(Value);
  Invalidate;
end;

end.
