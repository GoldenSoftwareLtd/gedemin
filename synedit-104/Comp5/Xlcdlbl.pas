
{++

  Copyright (c) 1995-99 by Golden Software of Belarus

  Module

    xlcdlbl.pas (used to be lcdlabel.pas)

  Abstract

    LCD label component.

  Author

    Andrei Kireev (13-Sep-95)
    Vladimir Belyi (6-Feb-96)

  Contact address

    http://www.gs.open.by

  Revisions history

    1.00    14-Sep-95    andreik    Initial version.
    1.01    18-Sep-95    andreik    Changed ancestor to TCustomControl.
                                    Reduced flicker while repainting.
    1.02    27-Sep-95    andreik    Some minor changes. Published inherited
                                    properties.
    1.03    03-Oct-95    andreik    Thanks Stefan Boether for his advice.
                                    Now we don't need in that goddamned BMP file
                                    and have lcd-digits image linked with DCU.
    1.04    04-Oct-95    andreik    Renamed to TLCDLabel. Added StrValue property.
    1.05    05-Oct-95    andreik    Fixed some minor bugs.
    1.06    25-Nov-95    andreik    Changed internal resource bitmap name.

    2.00    17-Feb-96    belyi      General reconstruction => You can see
                         andreik    what we've got...
    2.01    02-Jun-96    andreik    Fixed minor bug.
    2.02    21-May-99    andreik    Fixed minor bug with Ctl3d property saving.

--}

unit xLCDLbl;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls;

type
  TTextAlign = (alLeft, alRight, alCenter);

const
  DefDecDigits = 0;
  DefText = '';
  DefNumOfChars = 16;
  DefStretch = False;
  DefShift = 0;
  DefTextAlign = alLeft;
  DefCtl3D = True;

const
  TextLimit = 255;

const
  DefBitmapName = 'xlcd_1.bmp';
  DefCharSet = ' !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_';
  DefNilChar = ' ';

type
  TxLCDLabel = class(TCustomControl)
  private
    { Private declarations }
    FCharSet: String;
    FText: String;
    FImage: TBitmap;
    FNumOfChars: Word;
    FEnabled: Boolean;
    FCharWidth: Word;
    FCharHeight: Word;
    FNilChar: Char;
    FMemo: TBitmap;
    FStretch: Boolean;
    FShift: Word;
    FDecDigits: Word;
    FTextAlign: TTextAlign;
    FCtl3D: Boolean;

    CriticalChange: Boolean;
    LastCharShift: Word;

    procedure SetText(AText: String);
    procedure SetNumOfChars(ANumOfChars: Word);
    procedure SetImage(AImage: TBitmap);
    procedure SetAllowed(ToThis: String);
    procedure SetNilChar(NewNil: Char);
    procedure SetStretch(NewStretch: Boolean);
    procedure SetShift(NewShift: Word);
    function GetValue:Double;
    procedure SetValue(Value: Double);
    procedure SetDecDigits(Value: Word);
    procedure RegisterImage;
    procedure ResizeView;
    procedure SetTextAlign(Value: TTextAlign);
    procedure SetCtl3D(ACtl3D: Boolean);

  protected
    { Protected declarations }
    procedure Paint; override;
    procedure SetEnabled(AnEnabled: Boolean); override;

  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Repaint; override;
    
    procedure RelMove(Delta: Integer);
    procedure ChangeColors(FromColors, ToColors: array of TColor);

  published
    { Published declarations }
    property TextAlign: TTextAlign read FTextAlign write SetTextAlign
      default DefTextAlign;
    property Text: String read FText write SetText;
    property Value: Double read GetValue write SetValue stored False;
    property DecDigits: Word read FDecDigits write SetDecDigits
      default DefDecDigits;
    property Image: TBitmap read FImage write SetImage;
    property NilChar: Char read FNilChar write SetNilChar
      default DefNilChar;
    property CharSet: String read FCharSet write SetAllowed;
    property Stretch: Boolean read FStretch write SetStretch
      default DefStretch;
    property Shift: Word read FShift write SetShift
      default DefShift;
    property NumOfChars: Word read FNumOfChars write SetNumOfChars
      default DefNumOfChars;
    property Enabled: Boolean read FEnabled write SetEnabled
      default True;
    property Ctl3D: Boolean read FCtl3D write SetCtl3D
      default DefCtl3D;

    { publish inherited properties }
    property Visible;
    property Width;
    property Height;
  end;

type
  ExLCDLabelError = class(Exception);

procedure Register;

implementation


{ TxLCDLabel ----------------------------------------------}

constructor TxLCDLabel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csFramed, csFixedWidth, csFixedHeight];

  FTextAlign := DefTextAlign;
  FStretch := DefStretch;
  FCharSet := DefCharSet;
  FNilChar := DefNilChar;
  FText := DefText;
  FNumOfChars := DefNumOfChars;
  FEnabled := True;
  FImage := TBitmap.Create;
  if (csDesigning in ComponentState) and FileExists(DefBitmapName) then
    FImage.LoadFromFile(DefBitmapName);
  FCharHeight := FImage.Height;
  FCharWidth := FImage.Width div Length(FCharSet);
  FMemo := TBitmap.Create;
  FMemo.Width := FCharWidth*(FNumOfChars+1);
  FMemo.Height := FCharHeight;
  FCtl3D := DefCtl3D; { keep in touch with ControlStyle }

  CriticalChange := True;
  LastCharShift := 0;

  ResizeView;
end;

destructor TxLCDLabel.Destroy;
begin
  FImage.Free;
  FMemo.Free;
  inherited Destroy;
end;

procedure TxLCDLabel.RelMove(Delta: Integer);
begin
  if FShift < MaxInt - Delta then
    Shift := FShift + Delta
  else
    Shift := 0;
end;

procedure TxLCDLabel.ChangeColors(FromColors, ToColors: array of TColor);
var
  I: Integer;
  R: TRect;
begin
  if High(FromColors) <> High(ToColors) then
    raise ExLCDLabelError.Create('Arrays have not equal sizes');

  FImage.Canvas.Brush.Style := bsSolid;
  R := Rect(0, 0, FImage.Width, FImage.Height);
  for I := Low(FromColors) to High(FromColors) do
  begin
    FImage.Canvas.Brush.Color := ToColors[I];
    FImage.Canvas.BrushCopy(R, FImage, R, FromColors[I]);
  end;
  RegisterImage;
end;

procedure TxLCDLabel.Paint;
var
  I: Integer;
  Source, Dest: TRect;
  InStr, Lack : Word;
  SubShift : Word;
  CharShift : Word;
begin
  if FImage.Empty then
    begin
      CriticalChange := False;
      exit;
    end;
  InStr:=Length(FText);
  if InStr<FNumOfChars then Lack:=FNumOfChars-InStr else Lack:=0;
  case FTextAlign of
    alLeft: Lack:=0;
    alRight:;
    alCenter: Lack:=Lack div 2;
  end;
  if InStr<>0 then
    CharShift := (FShift div FCharWidth) mod InStr
  else
    CharShift := 0;
  SubShift := FShift mod FCharWidth;
  if CriticalChange or (LastCharShift<>CharShift) then
    begin
      Source.Top := 0;
      Source.Bottom := FCharHeight;
      Dest.Top := 0;
      Dest.Bottom := FCharHeight;

      for I := CharShift to FNumOfChars+CharShift do
      begin
        Dest.Left := (I-CharShift) * FCharWidth ;
        Dest.Right := Dest.Left + FCharWidth;

        if FEnabled and (i>=Lack) and (i<InStr+Lack) then
          Source.Left := (system.pos(FText[I + 1 - Lack], FCharSet)-1)*FCharWidth
        else
          Source.Left := (system.pos(FNilChar, FCharSet)-1)*FCharWidth;

        Source.Right := Source.left + FCharWidth;

        Fmemo.Canvas.CopyRect(Dest, FImage.Canvas, Source);
      end;
      LastCharShift := CharShift;
      CriticalChange := False;
    end;

  if FStretch then
    Canvas.Copyrect(rect(0,0,Width,Height),FMemo.Canvas,
                    rect(SubShift,0,FMemo.Width-FCharWidth+SubShift,FMemo.Height))
  else
    Canvas.Copyrect(rect(0,0,FMemo.Width-FCharWidth,FMemo.Height),
                    FMemo.Canvas,
                    rect(SubShift,0,FMemo.Width-FCharWidth+SubShift,FMemo.Height));
end;

procedure TxLCDLabel.Repaint;
begin
  InvalidateRect(Handle, nil, False);
end;

procedure TxLCDLabel.SetText(AText: String);
var
  checked : Boolean;
  i : Integer;
begin
  CriticalChange := True;
  checked := True;
  for i := 1 to Length(AText) do
    if pos(AText[i], FCharSet)=0 then Checked := False;
  if Checked then
    begin
      FText := AText;
      Repaint;
    end
  else raise ExLCDLabelError.Create('You''ve used not allowed Characters.');
end;

procedure TxLCDLabel.SetNumOfChars(ANumOfChars: Word);
begin
  if ANumOfChars <> FNumOfChars then
  begin
    if ANumOfChars > TextLimit then ANumOfChars := TextLimit
    else if ANumOfChars < 1 then ANumOfChars := 1;
    CriticalChange := True;
    FNumOfChars := ANumOfChars;
    FMemo.Width := FNumOfChars * FCharWidth + FCharWidth;
    FMemo.Height := FCharHeight;
    ResizeView;
    Refresh;
  end;
end;

procedure TxLCDLabel.SetEnabled(AnEnabled: Boolean);
begin
  if AnEnabled <> FEnabled then
  begin
    CriticalChange := True;
    FEnabled := AnEnabled;
    Refresh;
  end;
end;

procedure TxLCDLabel.RegisterImage;
begin
  FCharHeight := FImage.Height;
  FCharWidth := FImage.Width div Length(FCharSet);
  FMemo.Width := FCharWidth*(FNumOfChars + 1);
  FMemo.Height := FCharHeight;
  CriticalChange := True;
  Refresh;
end;

procedure TxLCDLabel.SetImage(AImage: TBitmap);
begin
  FImage.Assign(AImage);
  RegisterImage;
  ResizeView;
end;

procedure TxLCDLabel.SetAllowed(ToThis: String);
var
  I: Integer;
begin
  if ToThis='' then
    raise ExLCDLabelError.Create('Some Chars should be allowed.')
  else
    begin
      FCharSet:=ToThis;
      if pos(FNilChar, FCharSet)=0 then FNilChar:=FCharSet[1];
      if pos('.', FCharSet)=0 then FDecDigits:=0;
      for i:=1 to length(text) do
        if pos(FText[i], FCharSet)=0 then FText[i]:=FNilChar;
      RegisterImage;
      ResizeView;
    end;
end;

procedure TxLCDLabel.SetNilChar(NewNil: Char);
begin
  CriticalChange := True;
  if pos(NewNil, FCharSet)=0 then
    raise ExLCDLabelError.Create('Nil Char is not within CharSet.')
  else FNilChar := NewNil;
  Refresh;
end;

procedure TxLCDLabel.SetStretch(NewStretch: Boolean);
begin
  CriticalChange := True;
  FStretch := NewStretch;
  ResizeView;
  Refresh;
end;

procedure TxLCDLabel.SetShift(NewShift: Word);
begin
  if FShift <> NewShift then
  begin
    FShift := NewShift;
    Repaint;
  end;
end;

function TxLCDLabel.GetValue: Double;
var
  Code: Integer;
begin
  Val(text, Result, Code);
  if Code<>0 then
    if csDesigning in ComponentState then Result:=0
     else raise ExLCDLabelError.Create('Cannot convert String to a number.')
end;

procedure TxLCDLabel.SetValue(Value: Double);
var s : String;
begin
  str(Value:1:FDecDigits, s);
  try
    Text := s;
  except
    on ExLCDLabelError do
      raise ExLCDLabelError.create('Your CharSet property doesn''t allow '+
                                   'to display number ' + s);
  end;
end;

procedure TxLCDLabel.SetDecDigits(Value : Word);
begin
  FDecDigits := Value;
  if Value > 19 then FDecDigits := 19;
end;

procedure TxLCDLabel.SetTextAlign(Value: TTextAlign);
begin
  if Value<>FTextAlign then
    begin
      CriticalChange:=True;
      FTextAlign := Value;
      Refresh;
    end;
end;

procedure TxLCDLabel.SetCtl3D(ACtl3D: Boolean);
begin
  if FCtl3D <> ACtl3D then
  begin
    if ACtl3D then ControlStyle := ControlStyle + [csFramed]
      else ControlStyle := ControlStyle - [csFramed];
    RecreateWnd;
    if Owner is TWinControl then
      TWinControl(Owner).Invalidate;
    FCtl3D := ACtl3D;
  end;
end;

procedure TxLCDLabel.ResizeView;
begin
  if not FStretch then
    begin
      Width := FNumOfChars * FCharWidth;
      Height := FCharHeight;
    end;
end;

{ Registration --------------------------------------------}

procedure Register;
begin
  RegisterComponents('xTool-2', [TxLCDLabel]);
end;

end.
