
{++

  Copyright (c) 1996-98 by Golden Software of Belarus

  Module

    xbulbbtn.pas

  Abstract

    Bulb Buttons like in Word 97.

  Author

    Anton Smirnov (10-feb-97)

  Contact address

  Revisions history

    1.00     3-mar-97    sai       Initial version.
    1.01    27-mar-97    sai
    1.02    18-apr-97    sai
    1.03    12-may-97    sai
    1.04    19-may-97    sai       Resource error.
    1.05    25-may-97    andreik   Small changes.
    1.06    26-may-97    sai       Small changes.
    1.07     4-jun-97    sai       Property Default.
    1.08    10-jun-97    sai       Default select.
    1.09    06-jul-97    andreik   Minor bug fixed.
    1.08    26-08-97     sai       Small changes.
    1.09    17-11-97     sai       Delphi32, Transparent.
    1.10    26-02-98     andreik   Minor bug fixed.
    1.11    14-07-98     sai       FDefault, FCancel, ModalResult стали
                                                             нормально работать.
    1.12    14-nov-98    andreik   ParentColor added.
    1.15    25-02-99     alex      Small changes. Now if you changed a Gap property
                                   and AutoSize = False, then Width dosn't changes.
    1.16    10-03-99     alex      Added WMSetFocus and WMKillFocus for more better
                                   painting Component when an Owner Form receives or loses focus.

--}

unit xBulbBtn;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  TBulbButtonType = (btSmallBulbButton, btLargeBulbButton, btBigBulb,
                     btBulbDown, btBulbUp);

const
  Def_BulbButtonType = btSmallBulbButton;

  Def_FontName = 'Tahoma';
  Def_FontSize = 8;
  Def_FontStyle = [];
  Def_CharSet = RUSSIAN_CHARSET;

  Def_Gap = 7;
  Def_Color = clBtnFace;
  Def_Width = 100;
  Def_Height = 22;
  defParentFont = True;

  CalloutSize = 20;

  DefAutoSize = False;
  DefDefault = False;
  DefCancel = False;

type
  TxBulbButton = class(TCustomControl)
  private
    FCaption: String;
    MouseMove: Boolean;
    FBulbButtonType: TBulbButtonType;
    FGap: Integer;
    FColor: TColor;
    Test, TestCaption: Boolean;
    HeightBMP: Integer;
    DownFlag, MouseFlag, KeyPress: Boolean;
    DeltaPress: Integer;
    FOnClick: TNotifyEvent;
    FAutoSize: Boolean;
    FDefault: Boolean;
    FCancel: Boolean;
    FModalResult: TModalResult;
    FTransparent: Boolean;
    FAlignment: TAlignment;
    FWordWrap: Boolean;
    FActive: Boolean;
    FChecked: Boolean;

    procedure SetCaption(ACaption: String);
    procedure SetBulbButtonType(ABulbButtonType: TBulbButtonType);
    procedure SetGap(AGap: Integer);
    procedure SetColor(const AColor: TColor);
    procedure SetDefault(Value: Boolean);
    procedure SetAutoSize(AnAutoSize: Boolean);
    procedure SetAlignment(AnAlignment: TAlignment);
    procedure SetWordWrap(AWordWrap: Boolean);
    procedure SetTransparent(ATransparent: Boolean);
    procedure DoOnExit(Sender: TObject);
    procedure DoOnEnter(Sender: TObject);
    procedure SetActive(AnActive: Boolean);
    procedure SetChecked(AChecked: Boolean);
    procedure MakeBitmap(BMP: TBitmap; Coof: Integer);
    procedure DrawFocus;
    procedure SetCancel(AnCancel: Boolean);

    procedure WMMouseMove(var Message: TWMMouseMove);
      message WM_MouseMove;
    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LButtonDown;
    procedure WMLButtonUp(var Message: TWMLButtonUp);
      message WM_LButtonUp;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd);
      message WM_ERASEBKGND;
    procedure WMKeyDown(var Message: TWMKeyDown);
      message WM_KeyDown;
    procedure WMKeyUp(var Message: TWMKeyUp);
      message WM_KeyUp;
    procedure CMDialogKey(var Message: TCMDialogKey);
      message CM_DialogKey;
    procedure CMFontChanged(var Message: TMessage);
      message CM_FONTCHANGED;
    procedure CMEnabledChanged(var Message: TMessage);
      message CM_EnabledCHANGED;
    procedure WMSize(var Message: TMessage);
      message WM_Size;
    procedure CMFocusChanged(var Message: TCMFocusChanged);
      message CM_FOCUSCHANGED;
    procedure CNCommand(var Message: TWMCommand);
      message CN_COMMAND;

    property Active: Boolean read FActive write SetActive;

    procedure WMSetFocus(var Message: TWMSetFocus);
      message WM_SetFocus;
    procedure WMKillFocus(var Message: TWMKillFocus);
      message WM_KillFocus;

  protected
    procedure CreateWnd; override;
    procedure Paint; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Click; override;
    procedure CMParentColorChanged(var Message: TMessage);
      message CM_PARENTCOLORCHANGED;

  public
    constructor Create(AnOwner: TComponent); override;
    procedure Repaint; override;

  published
    property Caption: String read FCaption write SetCaption stored True;
    property Transparent: Boolean read FTransparent write SetTransparent;
    property WordWrap: Boolean read FWordWrap write SetWordWrap;
    property Alignment: TAlignment read FAlignment write SetAlignment;
    property BulbButtonType: TBulbButtonType read FBulbButtonType
      write SeTBulbButtonType;
    property Gap: Integer read FGap write SetGap;
    property Color: TColor read FColor write SetColor;
    property AutoSize: Boolean read FAutoSize write SetAutoSize
      default DefAutoSize;
    property Default: Boolean read FDefault write SetDefault
      default DefDefault;
    property Cancel: Boolean read FCancel write SetCancel
      default DefCancel;
    property ModalResult: TModalResult read FModalResult write FModalResult
      default 0;

    // inherited properties
    property Font;
    property ParentFont default defParentFont;
    property Enabled;
    property Visible;
    property Cursor;
    property TabOrder;
    property TabStop;
    property OnClick read FOnClick write FOnClick;
    property Checked: Boolean read FChecked write SetChecked;
    property ShowHint;
    property ParentColor;
  end;

procedure Register;

implementation

{$R XBULBBTN.RES}

uses
  Rect, ExtCtrls;

var
  LeftSideBMPSmall, RightSideBMPSmall, CenterBMPSmall,
  LeftSideBMPLarge, RightSideBMPLarge, CenterBMPLarge,
  LeftSideBMPBig, LeftSideBMPDown, LeftSideBMPUp: TBitmap;
  TestLargeBB, TestSmallBB, TestBigBB, TestUpBB, TestDownBB: Boolean;
  BitColor: String[3];
{---------------------------------------------------------}

procedure DoDelay(Pause: LongWord);
var
  OldTime: LongWord;
begin
  OldTime := GetTickCount;
  while GetTickCount - OldTime <= Pause do { nothing };
end;

procedure AddSmallBB;
begin
  if not TestSmallBB then
  begin
    LeftSideBMPSmall := TBitmap.Create;
    RightSideBMPSmall := TBitmap.Create;
    CenterBMPSmall := TBitmap.Create;
    LeftSideBMPSmall.LoadFromResourceName(hInstance, 'BulbButton_Left_Small_' + BitColor);
    RightSideBMPSmall.LoadFromResourceName(hInstance, 'BulbButton_Right_Small_' + BitColor);
    CenterBMPSmall.LoadFromResourceName(hInstance, 'BulbButton_Center_Small_' + BitColor);
    TestSmallBB := True;
  end;
end;

procedure AddLargeBB;
begin
  if not TestLargeBB then
  begin
    LeftSideBMPLarge := TBitmap.Create;
    RightSideBMPLarge := TBitmap.Create;
    CenterBMPLarge := TBitmap.Create;
    LeftSideBMPLarge.LoadFromResourceName(hInstance, 'BulbButton_Left_Large_' + BitColor);
    RightSideBMPLarge.LoadFromResourceName(hInstance, 'BulbButton_Right_Large_' + BitColor);
    CenterBMPLarge.LoadFromResourceName(hInstance, 'BulbButton_Center_Large_' + BitColor);
    TestLargeBB := True;
  end;
end;

procedure AddBigBB;
begin
  if not TestBigBB then
  begin
    LeftSideBMPBig := TBitmap.Create;
    TestBigBB := True;
    LeftSideBMPBig.LoadFromResourceName(hInstance, 'BULBBUTTON_LARGEBULB_' + BitColor);
  end;
end;

procedure AddUpBB;
begin
  if not TestUpBB then
  begin
    LeftSideBMPUp := TBitmap.Create;
    LeftSideBMPUp.LoadFromResourceName(hInstance, 'BULBBUTTON_BULBUP_' + BitColor);
    TestUpBB := True;
  end;
end;

procedure AddDownBB;
begin
  if not TestDownBB then
  begin
    LeftSideBMPDown := TBitmap.Create;
    LeftSideBMPDown.LoadFromResourceName(hInstance, 'BULBBUTTON_BULBDOWN_' + BitColor);
    TestDownBB := True;
  end;
end;

{TxBulbButton --------------------------------------------}

constructor TxBulbButton.Create(AnOwner: TComponent);
var
  B: TBitmap;
begin
  inherited Create(AnOwner);
  MouseMove := True;
  FCaption := 'xBulbButton';
  FBulbButtonType := Def_BulbButtonType;
  FTransparent := False;
  FAlignment := taLeftJustify;
  ParentFont := defParentFont;;
{  Font.Name := Def_FontName;
  Font.Size := Def_FontSize;
  Font.Style := Def_FontStyle;
  Font.Charset := Def_CharSet;}
  FGap := Def_Gap;
  FColor := Def_Color;
  TestCaption := True;
  TabStop := True;
  OnExit := DoOnExit;
  OnEnter := DoOnEnter;
  FAutoSize := DefAutoSize;
  FDefault := DefDefault;
  FModalResult := 0;
  DownFlag := False;
  MouseFlag := False;
  KeyPress := False;
  DeltaPress := 0;
  Height := Def_Height;
  FChecked := False;

  B := TBitmap.Create;
  try
    B.Canvas.Font.Assign(Font);
    if FAutoSize then
      Width := Height * 2 + FGap + B.Canvas.TextWidth(FCaption)
    else  
      Width := Def_Width;
  finally
    B.Free;
  end;

  AddSmallBB;
end;

procedure TxBulbButton.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WindowClass.hbrBackground := 0;
  if FTransparent then
    Params.ExStyle := WS_EX_TRANSPARENT;
end;                            

procedure TxBulbButton.CreateWnd;
begin
  inherited CreateWnd;
  Active := FDefault;
end;

procedure TxBulbButton.Click;
var
  Form: TForm;
begin
  Form := GetParentForm(Self) as TForm;
  if Form <> nil then
    Form.ModalResult := FModalResult;
  inherited Click;
end;

procedure TxBulbButton.Paint;
var
  BMP: TBitmap;
begin
  if FDefault then
    Font.Style := [fsBold]
  else
    Font.Style := [];
    
  BMP := TBitmap.Create;
  try
    DeltaPress := 0;
    if not Enabled then
      MakeBitmap(BMP, 0)
    else
      if DownFlag then
      begin
        if MouseFlag then
        begin
          MakeBitmap(BMP, 2);
          DeltaPress := 1;
          Canvas.Draw(0, 0, BMP);
          DoDelay(50);
          MakeBitmap(BMP, 1);
        end
        else
          MakeBitmap(BMP, 4);
      end
      else
	if MouseFlag then
	  MakeBitmap(BMP, 3)
        else
          if FChecked then
            MakeBitmap(BMP, 3)
          else
            MakeBitmap(BMP, 4);
    Canvas.Draw(0, 0, BMP);
    DrawFocus;
  finally
    BMP.Free;
  end;
end;

procedure TxBulbButton.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := -1;
end;

procedure TxBulbButton.MakeBitmap(BMP: TBitmap; Coof: Integer);
var
  LeftSideBMP, RightSideBMP, CenterBMP: TBitmap;
  BMP1, BMP2: TBitMap;
  Z, Y: Integer;
  XX: Integer;
  S: PChar;
  Format: Word;
  R: TRect;

  procedure LoadBMP;
  begin
    case FBulbButtonType of
      btSmallBulbButton:
      begin
        LeftSideBmp.Assign(LeftSideBmpSmall);
        RightSideBmp.Assign(RightSideBmpSmall);
        CenterBmp.Assign(CenterBmpSmall);
        HeightBMP := 22;
      end;
      
      btLargeBulbButton:
      begin
	LeftSideBmp.Assign(LeftSideBmpLarge);
        RightSideBmp.Assign(RightSideBmpLarge);
        CenterBmp.Assign(CenterBmpLarge);
        HeightBMP := 24;
      end;
      
      btBigBulb:
      begin
        LeftSideBmp.Assign(LeftSideBmpBig);
        HeightBMP := 15;
      end;
      
      btBulbDown:
      begin
        LeftSideBmp.Assign(LeftSideBmpDown);
        HeightBMP := 9;
      end;
      
      btBulbUp:
      begin
	LeftSideBmp.Assign(LeftSideBmpUp);
        HeightBMP := 9;
      end;
    end;
  end;

  procedure BMPCopyRect(BMPSource: TBitMap; X: Integer);
  begin
    BMP1.Height := HeightBMP;
    BMP2.Height := HeightBMP;
    BMP1.Width := BMPSource.Width;
    BMP2.Width := BMPSource.Width;
    if (FBulbButtonType = btLargeBulbButton) or
       (FBulbButtonType = btSmallBulbButton) then
    begin
      BMP1.Canvas.CopyRect(RectSet(0, 0, BMP1.Width, BMP1.Height),
                           BMPSource.Canvas,
			   RectSet(0, HeightBMP * Coof, BMP1.Width,
                                   HeightBMP * (Coof + 1)));
      BMP2.Canvas.CopyRect(RectSet(0, 0, BMP2.Width, BMP2.Height),
                           BMPSource.Canvas,
                           RectSet(0, HeightBMP * Coof + BMPSource.Height div 2,
                           BMP2.Width,
                           HeightBMP * (Coof + 1) + BMPSource.Height div 2));
    end
    else
    begin
      BMP1.Canvas.CopyRect(RectSet(0, 0, BMP1.Width, BMP1.Height),
                         BMPSource.Canvas,
			 RectSet(0, 0, BMP1.Width, HeightBMP));
      if Coof = 0 then
	Coof := 4;
      BMP2.Canvas.CopyRect(RectSet(0, 0, BMP2.Width, BMP2.Height),
                           BMPSource.Canvas,
			   RectSet(0, HeightBMP * Coof,
                                   BMP2.Width, HeightBMP * (Coof + 1)));
    end;
      BitBlt(BMP.Canvas.Handle, X, Y, X + Bmp1.Width, Y + Bmp1.Height,
             Bmp1.Canvas.Handle, 0, 0, SrcAnd);
      BitBlt(BMP.Canvas.Handle, X, Y, X + Bmp1.Width, Y + Bmp1.Height,
             Bmp2.Canvas.Handle, 0, 0, SrcPaint);
  end;

  procedure IncRect;
  begin
    Inc(R.Left);
    Inc(R.Right);
    Inc(R.Top);
    Inc(R.Bottom);
  end;

begin
  LeftSideBMP := TBitmap.Create;
  RightSideBMP := TBitmap.Create;
  CenterBMP := TBitmap.Create;
  try
    LoadBMP;
    BMP.Width := Width;
    if (FBulbButtonType = btBulbDown) or (FBulbButtonType = btBulbUp) then
    begin
      Y := 6;
      BMP.Height := Height;
    end
    else
    if FBulbButtonType = btBigBulb then
    begin
      Y := 4;
      BMP.Height := Height;
    end
    else
    begin
      Y := 0;
      BMP.Height := HeightBMP;
    end;

    BMP.Canvas.Pen.Style := psClear;
    if FTransparent then
    begin
      BMP.Canvas.Brush.Style := bsClear;
      BMP.Canvas.CopyRect(GetClientRect, Canvas, GetClientRect);
                                                  { added by andreik !!!}
    end
    else
    begin
      BMP.Canvas.Brush.Color := FColor;
    end;

    BMP.Canvas.Rectangle(0, 0, BMP.Width + 1, BMP.Height + 1);
    BMP.Canvas.Font.Assign(Font);
    BMP.Canvas.Brush.Style := bsClear;
    BMP1 := TBitmap.Create;
    BMP2 := TBitmap.Create;

    try
      BMPCopyRect(LeftSideBMP, 0);
      if (FBulbButtonType = btLargeBulbButton) or
         (FBulbButtonType = btSmallBulbButton) then
      begin
        for Z := 0 to (Width - LeftSideBMP.Width - RightSideBmp.Width) div 5 do
	  BMPCopyRect(CenterBMP, Z * 5 + LeftSideBMP.Width);
        BMPCopyRect(RightSideBMP, Width - RightSideBMP.Width);
      end;
    finally
      BMP1.Free;
      BMP2.Free;
    end;

  finally
    LeftSideBMP.Free;
    RightSideBMP.Free;
    CenterBmp.Free;
  end;

  if (FBulbButtonType = btBulbDown) or (FBulbButtonType = btBulbUp) then
    XX := 10
  else
    XX := 0;
  DeltaPress := 0;
  R.Left := XX + HeightBMP + FGap + 1;
  R.Top := 4;
  R.Right := Width - 1;
  R.Bottom := Height - 1;

  if Coof = 1 then
  begin
    if not FTransparent then
      DeltaPress := 1;
    if TestCaption then
      if (FBulbButtonType <> btLargeBulbButton) and
         (FBulbButtonType <> btSmallBulbButton) and
          not FAutoSize and FWordWrap then
      begin
        S := StrAlloc(Length(Caption) + 1);
        try
	  StrPCopy(S, Caption);
	  Format := DT_WORDBREAK;
	  case FAlignment of
	    taRightJustify: Format := Format or DT_RIGHT;
            taCenter: Format := Format or DT_CENTER;
          else
            Format := Format or DT_LEFT;
          end;
          if not FTransparent then
            IncRect;
          DrawText(BMP.Canvas.Handle, S, Length(FCaption), R, Format);
        finally
          StrDispose(S);
        end;
      end
      else
        BMP.Canvas.TextOut(XX + HeightBMP + FGap + DeltaPress, 
          4 + DeltaPress, FCaption)
  end
  else
    if (Coof = 0) and TestCaption then
    begin
      if (FBulbButtonType <> btLargeBulbButton) and (FBulbButtonType <> btSmallBulbButton)
          and not FAutoSize and FTransparent then
      begin
	S := StrAlloc(Length(Caption) + 1);
        try
          StrPCopy(S, Caption);
          Format := DT_WORDBREAK;
          case FAlignment of
            taRightJustify: Format := Format or DT_RIGHT;
            taCenter: Format := Format or DT_CENTER;
          else
            Format := Format or DT_LEFT;
          end;
          BMP.Canvas.Font.Color := clWhite;
	  DrawText(Bmp.Canvas.Handle, S, Length(Caption), R, Format);
          BMP.Canvas.Font.Color := clBtnShadow;
          IncRect;
	  DrawText(Bmp.Canvas.Handle, S, Length(Caption), R, Format);
        finally
          StrDispose(S);
        end;
      end
      else
      begin
	BMP.Canvas.Font.Color := clWhite;
        BMP.Canvas.TextOut(XX + HeightBMP + FGap + 1, 5, FCaption);
        BMP.Canvas.Font.Color := clBtnShadow;
        BMP.Canvas.TextOut(XX + HeightBMP + FGap, 4, FCaption);
      end;
    end
    else
      if TestCaption then
        if (FBulbButtonType <> btLargeBulbButton) and (FBulbButtonType <> btSmallBulbButton)
            and not FAutoSize and FWordWrap then
	begin
          S := StrAlloc(Length(Caption) + 1);
          try
            StrPCopy(S, Caption);
            Format := DT_WORDBREAK;
            case FAlignment of
              taRightJustify: Format := Format or DT_RIGHT;
              taCenter: Format := Format or DT_CENTER;
            else
              Format := Format or DT_LEFT;
	    end;
	    DrawText(Bmp.Canvas.Handle, S, Length(Caption), R, Format);
          finally
            StrDispose(S);
	  end;
	end
	else
	  BMP.Canvas.TextOut(XX + HeightBMP + FGap, 4, FCaption);
end;

procedure TxBulbButton.Repaint;
begin
{  if FTransparent and (Parent <> nil) then
    Parent.Invalidate;}
  Invalidate;
end;

procedure TxBulbButton.WMMouseMove(var Message: TWMMouseMove);
begin
  inherited;
  if MouseMove then
  begin
    if Enabled and not KeyPress then
    begin
      if not MouseCapture then
      begin
        MouseFlag := True;
        MouseCapture := True;
        Repaint;
      end
      else
        if (Message.XPos < 0) or (Message.XPos > Width) or
           (Message.YPos < 0) or (Message.YPos > Height) then
        begin
          if not DownFlag then
          begin
            MouseCapture := False;
            Repaint;
          end
          else
	    MouseCapture := True;
	  MouseFlag := False;
	  if Test then
	  begin
	    Test := False;
            Repaint;
          end;
        end
        else
        begin
          MouseFlag := True;
          if not Test then
          begin
            Repaint;
            Test := True;
          end;
        end;
    end;
  end
  else
    MouseMove := True;
end;

procedure TxBulbButton.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;
  if Enabled and not KeyPress then
  begin
    if not Focused then SetFocus;
    if not DownFlag then
    begin
      MouseCapture := True;
      DownFlag := True;
      Repaint;                              
      Test := True;
    end;
  end;
end;

procedure TxBulbButton.WMKeyDown(var Message: TWMKeyDown);
begin
  if Enabled and (Message.CharCode = 32) and not KeyPress then
  begin
    DownFlag := True;
    MouseFlag := True;
    if not KeyPress then
    begin
      MouseCapture := True;
      KeyPress := True;
      Repaint;
    end;
    Message.Result := 0;
  end
  else
    inherited;
end;

procedure TxBulbButton.WMKeyUp(var Message: TWMKeyUp);
var
  Form: TForm;
begin
  if Enabled and (Message.CharCode = 32) then
  begin
    DownFlag := False;
    KeyPress := False;
    MouseCapture := False;
    Message.Result := 0;
    Form := GetParentForm(Self) as TForm;
    if Form <> nil then
      Form.ModalResult := FModalResult;
    if (Message.CharCode = 32) and Assigned(FOnClick) then
    begin
      MouseFlag := False;
      Repaint;
      Application.ProcessMessages;
      FOnClick(Self)
    end
    else
    begin
      MouseFlag := False;
      Repaint;
      Application.ProcessMessages;
    end;
    Message.Result := 0;
  end
  else
    inherited;
end;

procedure TxBulbButton.CMDialogKey(var Message: TCMDialogKey);
var
  Form: TForm;
begin
  with Message do
  begin
    if (((CharCode = VK_RETURN) and FActive and Enabled) or
      ((CharCode = VK_ESCAPE) and FCancel and Enabled)) and
      (KeyDataToShiftState(Message.KeyData) = []) and CanFocus then
    begin
      DownFlag := False;
      MouseFlag := False;
      Repaint;
      if  (((CharCode = VK_RETURN) and FActive and Enabled) or
        ((CharCode = VK_ESCAPE) and FCancel and Enabled)) and Assigned(FOnClick) then
        FOnClick(Self);
      Result := 1;
    end
    else
      inherited;
    if  ((CharCode = VK_RETURN) and FActive and Enabled) or
        ((CharCode = VK_ESCAPE) and FCancel and Enabled) then
    begin
      Form := GetParentForm(Self) as TForm;
      if Form <> nil then
        Form.ModalResult := FModalResult;
    end;
  end;
end;

procedure TxBulbButton.CMFontChanged(var Message: TMessage);
begin
  inherited;
  Repaint;
end;

procedure TxBulbButton.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  Repaint;
end;

procedure TxBulbButton.CNCommand(var Message: TWMCommand);
begin
  if Message.NotifyCode = BN_CLICKED then Click;
end;

procedure TxBulbButton.WMSize(var Message: TMessage);
begin
  inherited;
  case FBulbButtonType of
    btSmallBulbButton: Height := 22;
    btLargeBulbButton: Height := 24;
  end;
  if FAutoSize then
  begin
    Width := Height * 2 + FGap + Canvas.TextWidth(FCaption);
    case FBulbButtonType of
      btBigBulb: Height := 20;
      btBulbDown: Height := 20;
      btBulbUp: Height := 20;
    end;
  end;
end;

procedure TxBulbButton.WMLButtonUp(var Message: TWMLButtonUp);
var
  Flag: Boolean;
begin
  inherited;
{  if FDefault then
    FModalResult := mrOk;}
  if Enabled then
  begin
    Flag := MouseFlag;
    if DownFlag then
    begin
      DownFlag := False;
      MouseCapture := True;
      MouseMove := False;
      if Flag and Assigned(FOnClick) then
      begin
{***        MouseFlag := False;
        MouseFlag := True;***}
	Repaint;
        Application.ProcessMessages;
        if Assigned(FOnClick) then
          FOnClick(Self);
      end
      else
      begin
        MouseFlag := True;
        Repaint;
        WMMouseMove(Message);
      end;
    end;
  end;
end;

procedure TxBulbButton.SetCaption(ACaption: String);
begin
  FCaption := ACaption;
  if (FCaption = '') or (FCaption = ' ') then
  begin
    TestCaption := False;
    FCaption := ' ';
  end 
  else
    TestCaption := True;
  if FAutoSize then
    Width := Height * 3 div 2 + FGap + Canvas.TextWidth(FCaption);
  Repaint;
end;

procedure TxBulbButton.DoOnExit(Sender: TObject);
begin
  MouseFlag := False;
  DownFlag := False;
  MouseCapture := False;
  MouseMove := False;
  Repaint;
  Application.ProcessMessages
end;

procedure TxBulbButton.DoOnEnter(Sender: TObject);
begin
  Repaint;
end;

procedure TxBulbButton.DrawFocus;
var
  XX: Integer;

  procedure DrawLine(X1, Y1, X2, Y2: Integer);
  var
    X, Y: Integer;
    TestCoord: Boolean;

    function MinValue(Value1, Value2: Integer): Integer;
    begin
      Result := Value1;
      if Value1 > Value2 then
	Result := Value2
    end;

  begin
    TestCoord := True;
    if X1 = X2 then
      TestCoord := False;
    with Canvas do
      if not TestCoord then
      begin
        for Y := 0 to Abs(Y2 - Y1) div 2 do
        begin
	  MoveTo(X1, Y * 2 + Y1);
          LineTo(X1, Y * 2 + Y1 + 1);
        end;
      end
      else
	for X := 0 to Abs(X2 - X1) div 2 do
        begin
          MoveTo(X * 2 + X1, Y1);
          LineTo(X * 2 + X1 + 1, Y1);
      end;
  end;

  procedure DrawRectangle(XL, YL, XR, YR: Integer);
  begin
    DrawLine(XL, YL, XL, YR);
    DrawLine(XR, YL, XR, YR);
    DrawLine(XL, YL, XR, YL);
    DrawLine(XL, YR, XR, YR);
  end;

begin
  if (not FTransparent) and TestCaption then
  begin
    if (FBulbButtonType = btBulbDown) or (FBulbButtonType = btBulbUp) then
      XX := 10
    else
      XX := 0;
    if Enabled then
      with Canvas do
      begin
        Pen.Color := clBtnShadow;
        Brush.Style := bsClear;
	Pen.Style := psDot;
	Pen.Width := 1;
	if Focused then
        begin
          Pen.Color := clBtnShadow;
	  Canvas.Font.Assign(Self.Font);
          if (FBulbButtonType <> btLargeBulbButton) and
	     (FBulbButtonType <> btSmallBulbButton) then
            DrawRectangle(XX + HeightBMP + FGap -1, 4, Width - 1, Height - 1)
          else
            DrawRectangle(XX + HeightBMP + FGap -1, 4,
                          XX + HeightBMP + FGap + Canvas.TextWidth(FCaption) + 1,
                          4 + Canvas.TextHeight(FCaption) - 1);
          DeltaPress := 0;
        end;
        Pen.Style := psSolid;
      end;
    end;
end;

procedure TxBulbButton.SeTBulbButtonType(ABulbButtonType: TBulbButtonType);
begin
  if ABulbButtonType <> FBulbButtonType then
  begin
    FBulbButtonType := ABulbButtonType;
    case FBulbButtonType of
      btSmallBulbButton: AddSmallBB;
      btLargeBulbButton: AddLargeBB;
      btBigBulb: AddBigBB;
      btBulbDown: AddDownBB;
      btBulbUp: AddUpBB;
    end;
    case FBulbButtonType of
      btSmallBulbButton: Height := 22;
      btLargeBulbButton: Height := 24;
    end;
    if FAutoSize then
      case FBulbButtonType of
        btBigBulb: Height := 20;
        btBulbDown: Height := 20;
        btBulbUp: Height := 20;
      end;
    Repaint;
  end;
end;

procedure TxBulbButton.SetGap(AGap: Integer);
begin
  if AGap <> FGap then
  begin
    FGap := AGap;
    if FAutoSize then
      Width := Height * 2 + FGap + Canvas.TextWidth(FCaption);
    Repaint;
  end;
end;

procedure TxBulbButton.SetColor(const AColor: TColor);
begin
  if AColor <> FColor then
  begin
    FColor := AColor;
    ParentColor := False;
    Repaint;
  end;
end;

procedure TxBulbButton.SetChecked(AChecked: Boolean);
begin    
  FChecked := AChecked;
  Repaint;
end;

procedure TxBulbButton.SetActive(AnActive: Boolean);
begin
  if AnActive <> FActive then
  begin
    FActive := AnActive;
    Repaint;
  end;
end;

procedure TxBulbButton.SetCancel(AnCancel: Boolean);
begin
  FCancel := AnCancel;
  if FCancel then
    ModalResult := mrCancel;
end;

procedure TxBulbButton.SetDefault(Value: Boolean);
begin
  FDefault := Value;
  if FDefault then
    FModalResult := mrOk;
  Repaint;
  if HandleAllocated then
    with GetParentForm(Self) do
      Perform(CM_FOCUSCHANGED, 0, Longint(ActiveControl));
end;

procedure TxBulbButton.SetAutoSize(AnAutoSize: Boolean);
begin
  if FAutoSize <> AnAutoSize then
  begin
    FAutoSize := AnAutoSize;
    if FAutoSize then
      Width := Height * 2 + FGap + Canvas.TextWidth(FCaption);
  end;
end;

procedure TxBulbButton.SetAlignment(AnAlignment: TAlignment);
begin
  FAlignment := AnAlignment;
  Repaint;
end;

procedure TxBulbButton.SetWordWrap(AWordWrap: Boolean);
begin
  FWordWrap := AWordWrap;
  Repaint;
end;

procedure TxBulbButton.SetTransparent(ATransparent: Boolean);
begin
  FTransparent := ATransparent;
  Repaint;
end;

procedure TxBulbButton.CMFocusChanged(var Message: TCMFocusChanged);
begin
  with Message do
    if (Sender is TButton) or (Sender is TxBulbButton) then
	      Active := Sender = Self
    else
      Active := FDefault;
  inherited;
end;

procedure TxBulbButton.CMParentColorChanged(var Message: TMessage);
begin
  if ParentColor then
  begin
    if Message.wParam <> 0 then
    begin
      SetColor(TColor(Message.lParam))
    end else
    begin
      if Parent is TForm then
        SetColor((Parent as TForm).Color)
      else if Parent is TPanel then
        SetColor((Parent as TPanel).Color)
      else if Parent is TNotebook then
        SetColor((Parent as TNotebook).Color);
    end;
    ParentColor := True;
  end;
end;

procedure FreeBitmap(BMP: TBitmap);
begin
  try
    if BMP <> nil then
      BMP.Free;
  except
    {...}
  end;
end;

{
   WM_SET_FOCUS
}
procedure TxBulbButton.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  Invalidate;
end;

{
   WM_KILL_FOCUS
}
procedure TxBulbButton.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
  MouseFlag := False;
  MouseMove := True;
  Invalidate;
end;

{Registration --------------------------------------------}

procedure Register;
begin
  RegisterComponents('x-Button', [TxBulbButton]);
end;

{Exit Procedures -----------------------------------------}

var
  DC: HDC;
  
{Initialization -------------------------------------------}

initialization

  DC := GetDC(0);
  try
    if GetDeviceCaps(DC, BITSPIXEL) > 8 then 
      BitColor := '256'
    else
      BitColor := '16'
  finally
    ReleaseDC(0, DC);
  end;
  TestLargeBB := False;
  TestSmallBB := False;
  TestBigBB := False;
  TestUpBB := False;
  TestDownBB := False;
finalization

  if TestSmallBB then
  begin
    FreeBitmap(LeftSideBMPSmall);
    FreeBitmap(RightSideBMPSmall);
    FreeBitmap(CenterBMPSmall);
  end;

  if TestLargeBB then
  begin
    FreeBitmap(LeftSideBMPLarge);
    FreeBitmap(RightSideBMPLarge);
    FreeBitmap(CenterBMPLarge);
  end;

  if TestUpBB then
    FreeBitmap(LeftSideBMPUp);  
  if TestDownBB then
    FreeBitmap(LeftSideBMPDown);  
  if TestBigBB then
    FreeBitmap(LeftSideBMPBig);  

end.
