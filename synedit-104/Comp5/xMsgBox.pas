
{++

  Copyright (c) 1996-98 by Golden Software of Belarus

  Module

    xmsgbox.pas

  Abstract

    Message Box like in Word 8.0 for Windows 95.

  Author

    Anton Smirnov (10-feb-97)

  Contact address

  Revisions history

    1.00     3-mar-97    sai        Initial version.
    1.01    27-mar-97    sai
    1.02    10-may-97    andreik    MsgBox, MsgBoxEx functions added.
    1.03    12-may-97    sai        Error ModalResult
    1.04     3-jun-97    sai        Small Change.
    1.05     26-08-97    sai        Small change.
    1.06      9-10-97    sai        Exclamation.
    1.07     19-01-98    sai        Delphi 32. Small Change (Font).
    1.08     24-05-98    andreik    Minor bug with fonts fixed.
    1.09     14-10-98    andreik    Overloaded functions added.

--}

unit xMsgBox;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Buttons, StdCtrls, xBulbBtn, xMsgWnd;

type
  TxMessageBox = class(TComponent)
  private
    FShadow: Boolean;
    FShadowDepth, FBorderWidth, FCalloutDisplaysment,
    FMaxWidth, FMinWidth: Integer;
    FFont, FSubtitleFont: TFont;
    FColor, FBorderColor: TColor;
    FCallout: TCallout;
    FAlignment: TAlignment;
    FLanguage: TLanguage;

    procedure SetFont(AFont: TFont);
    procedure SetSubtitleFont(AFont: TFont);

  protected
    procedure Loaded; override;
  public
    property Language: TLanguage read FLanguage write FLanguage;

    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

  published
    property Shadow: Boolean read FShadow write FShadow;
    property ShadowDepth: Integer read FShadowDepth write FShadowDepth;
    property Font: TFont read FFont write SetFont;
    property SubtitleFont: TFont read FSubtitleFont write SetSubtitleFont;
    property Color: TColor read FColor write FColor;
    property BorderColor: TColor read FBorderColor write FBorderColor;
    property BorderWidth: Integer read FBorderWidth write FBorderWidth;
    property Callout: TCallout read FCallout write FCallout;
    property CalloutDisplaysment: Integer read FCalloutDisplaysment
      write FCalloutDisplaysment;
    property Alignment: TAlignment read FAlignment write FAlignment;
    property MaxWidth: Integer read FMaxWidth write FMaxWidth;
    property MinWidth: Integer read FMinWidth write FMinWidth;
  end;

  ExWindowMessageError= class(Exception);

function MessageBox(WndParent: HWnd; Txt, Caption: PChar; TextType: Word): Integer; overload;
function MessageBox(WndParent: HWnd; Txt, Caption: String; TextType: Word): Integer; overload;
function MessageBoxPos(WndParent: HWnd; Txt, Caption: PChar; TextType: Word; Pos: TPoint): Integer; overload;
function MessageBoxPos(WndParent: HWnd; Txt, Caption: String; TextType: Word; Pos: TPoint): Integer; overload;
function MessageBoxEx(WndParent: HWnd; Txt, Caption: PChar; TextType: Word;
  WinCntrl: TWinControl = nil): Integer; overload;
function MessageBoxEx(WndParent: HWnd; Txt, Caption: String; TextType: Word;
  WinCntrl: TWinControl = nil): Integer; overload;

procedure Register;

var
  xMessageBox: TxMessageBox;

implementation

uses
  Rect
  {$IFDEF REGISTER_GSMULTILINGUALSUPPORT}
  , gsMultilingualSupport
  {$ENDIF}
  ;

//---------------------------------------------------------

function MessageBoxPos(WndParent: HWnd; Txt, Caption: PChar; TextType: Word;
  Pos: TPoint): Integer;
var
  xMessageForm: TxMessageForm;
  W, H, Z{, LLeft, TTop}: Integer;
  R{, RR}: TRect;
  WinControl: TWinControl;
begin
  {$IFDEF REGISTER_GSMULTILINGUALSUPPORT}
  Txt := PChar(TranslateText(StrPas(Txt)));
  Caption := PChar(TranslateText(StrPas(Caption)));
  {$ENDIF}

  if xMessageBox <> nil then
  begin
    WinControl := FindControl(WndParent);
    xMessageForm := TxMessageForm.Create(WinControl);
    try
      xMessageForm.Shadow := xMessageBox.Shadow;
      xMessageForm.ShadowDepth := xMessageBox.ShadowDepth;
      xMessageForm.TextFont.Assign(xMessageBox.Font);
      xMessageForm.SubtitleFont.Assign(xMessageBox.SubtitleFont);
      xMessageForm.Color := xMessageBox.Color;
      xMessageForm.BorderColor := xMessageBox.BorderColor;
      xMessageForm.BorderWidth := xMessageBox.BorderWidth;
      xMessageForm.Callout := xMessageBox.Callout;
      xMessageForm.CalloutDisplaysment := xMessageBox.FCalloutDisplaysment;
      xMessageForm.Alignment := xMessageBox.Alignment;
      xMessageForm.MaxWidth := xMessageBox.MaxWidth;
      xMessageForm.MinWidth := xMessageBox.MinWidth;
      xMessageForm.Language := xMessageBox.Language;

      xMessageForm.Caption := StrPas(Txt);
      xMessageForm.SubtitleName := StrPas(Caption);
      with xMessageForm do
      begin
        Z := TextType;
        IconType := itNone;
        if (TextType >= MB_ICONSTOP) and (TextType < MB_ICONQUESTION) then
        begin
          Z := TextType - 16;
          IconType := itIconStop;
	end;
        if (TextType >= MB_ICONQUESTION) and
           (TextType < MB_ICONEXCLAMATION) then
        begin
          Z := TextType - 32;
          IconType := itQUESTION;
        end;
        if (TextType >= MB_ICONEXCLAMATION) and
	   (TextType < MB_ICONINFORMATION) then
        begin
          Z := TextType - 48;
          IconType := itExclamation;
        end;
        if (TextType >= MB_ICONINFORMATION) and
           (TextType < MB_ICONINFORMATION + 16) then
        begin
	  Z := TextType - 64;
	  IconType := itIconInformation;
	end;
	case Z of
	  MB_ABORTRETRYIGNORE:
	   DialogType := dtABORTRETRYIGNORE;
	  MB_OK: DialogType := dtOk;
	  MB_OKCANCEL: DialogType := dtOkCancel;
	  MB_RETRYCANCEL: DialogType := dtRetryCancel;
	  MB_YESNO: DialogType := dtYesNo;
	  MB_YESNOCANCEL: DialogType := dtYesNoCancel;
	end;
	Font.Size := 8;

        R.BottomRight := Point(0, 0);
        R.TopLeft := Point(0, 0);
        xMessageForm.Canvas.Font.Assign(xMessageForm.TextFont);
      	xMessageForm.DataCalculation(W, H);
        DrawText(xMessageForm.Canvas.Handle, PChar(Txt), -1, R,
          DT_NOPREFIX or DT_CALCRECT);
        W := R.Right + 50;
        R := xMessageForm.xtRext;
        R.Right := R.Left + W - 50;
        xMessageForm.xtRext := R;
      	GetWindowRect(GetDeskTopWindow, R);
        if (Pos.X + W - 60) > (R.Right - 30) then
          Pos.X := (R.Right - W + 60 - 30);
        if (Pos.X - 60) < (R.Left + 30) then
          Pos.X := (R.Left + 60 + 30);
        if (Pos.Y - H) < (R.Top + 30) then
          Pos.Y := (R.Top + H + 30);
	SetBounds(Pos.X - 60{LLeft}, Pos.Y - H{TTop}, W, H);
{        Application.ProcessMessages;}
	xMessageForm.ShowModal;

	case xMessageForm.ModalResult of
	  mrAbort: Result := idAbort;
	  mrCancel: Result := idCancel;
	  mrIgnore: Result := idIgnore;
	  mrNo: Result := idNo;
	  mrOk: Result := idOk;
	  mrRetry: Result := idRetry;
	  mrYes: Result := idYes;
        else
          Result := idOk;
	end;

      end;
    finally
      xMessageForm.Free;
    end;
  end
  else
    Result := WinProcs.MessageBox(WndParent, Txt, Caption, TextType);
end;

function MessageBoxEx(WndParent: HWnd; Txt, Caption: PChar; TextType: Word;
  WinCntrl: TWinControl = nil): Integer;
var
  xMessageForm: TxMessageForm;
  W, H, Z, LLeft, TTop: Integer;
  R, RR: TRect;
  WinControl: TWinControl;
begin
  {$IFDEF REGISTER_GSMULTILINGUALSUPPORT}
  Txt := PChar(TranslateText(StrPas(Txt)));
  Caption := PChar(TranslateText(StrPas(Caption)));
  {$ENDIF}

  if WinCntrl = nil then
  begin
    Result := MessageBox(WndParent, Txt, Caption, TextType);
    exit;
  end;

  if xMessageBox <> nil then
  begin
    WinControl := FindControl(WndParent);
    xMessageForm := TxMessageForm.Create(WinControl);
    try
      xMessageForm.Shadow := xMessageBox.Shadow;
      xMessageForm.ShadowDepth := xMessageBox.ShadowDepth;
      xMessageForm.TextFont.Assign(xMessageBox.Font);
      xMessageForm.SubtitleFont.Assign(xMessageBox.SubtitleFont);
      xMessageForm.Color := xMessageBox.Color;
      xMessageForm.BorderColor := xMessageBox.BorderColor;
      xMessageForm.BorderWidth := xMessageBox.BorderWidth;
      xMessageForm.Callout := xMessageBox.Callout;
      xMessageForm.CalloutDisplaysment := xMessageBox.FCalloutDisplaysment;
      xMessageForm.Alignment := xMessageBox.Alignment;
      xMessageForm.MaxWidth := xMessageBox.MaxWidth;
      xMessageForm.MinWidth := xMessageBox.MinWidth;
      xMessageForm.Language := xMessageBox.Language;

      xMessageForm.Caption := StrPas(Txt);
      xMessageForm.SubtitleName := StrPas(Caption);
      with xMessageForm do
      begin
        Z := TextType;
        IconType := itNone;
        if (TextType >= MB_ICONSTOP) and (TextType < MB_ICONQUESTION) then
        begin
          Z := TextType - 16;
          IconType := itIconStop;
	end;
        if (TextType >= MB_ICONQUESTION) and
           (TextType < MB_ICONEXCLAMATION) then
        begin
          Z := TextType - 32;
          IconType := itQUESTION;
        end;
        if (TextType >= MB_ICONEXCLAMATION) and
	   (TextType < MB_ICONINFORMATION) then
        begin
          Z := TextType - 48;
          IconType := itExclamation;
        end;
        if (TextType >= MB_ICONINFORMATION) and
           (TextType < MB_ICONINFORMATION + 16) then
        begin
	  Z := TextType - 64;
	  IconType := itIconInformation;
	end;
	case Z of
	  MB_ABORTRETRYIGNORE:
	   DialogType := dtABORTRETRYIGNORE;
	  MB_OK: DialogType := dtOk;
	  MB_OKCANCEL: DialogType := dtOkCancel;
	  MB_RETRYCANCEL: DialogType := dtRetryCancel;
	  MB_YESNO: DialogType := dtYesNo;
	  MB_YESNOCANCEL: DialogType := dtYesNoCancel;
	end;
	Font.Size := 8;
	xMessageForm.DataCalculation(W, H);
	GetWindowRect(GetDeskTopWindow, R);
	DataCalculation(W, H);
	GetWindowRect(GetDeskTopWindow, R);
	if WinCntrl = nil then
	begin
	  LLeft := R.Right div 2 - W div 2;
	  Ttop := R.Bottom div 2 - H div 2
	end
	else
	begin
	  GetWindowRect(GetDeskTopWindow, R);
	  GetWindowRect(WinCntrl.Handle, RR);
	  LLeft := RR.Left + (RR.Right - RR.Left) div 2 - W div 2;
	  if LLeft + W > R.Right then
	    LLeft := R.Right - W;
	  if LLeft < 0 then
	    LLeft := 0;
	  if (RR.Bottom + H) > R.Bottom then
	  begin
	    TTop := RR.Top - H;
	    Callout := clBottom;
	  end
	  else
	  begin
	    TTop := RR.Bottom;
	    Callout := clTop;
	  end;
	  CalloutDisplaysMent := W div 2;
	end;
	DataCalculation(W, H);
	SetBounds(LLeft, TTop, W, H);
{        Application.ProcessMessages;}
	xMessageForm.ShowModal;

	case xMessageForm.ModalResult of
	  mrAbort: Result := idAbort;
	  mrCancel: Result := idCancel;
	  mrIgnore: Result := idIgnore;
	  mrNo: Result := idNo;
	  mrOk: Result := idOk;
	  mrRetry: Result := idRetry;
	  mrYes: Result := idYes;
        else
          Result := idOk;
	end;

      end;
    finally
      xMessageForm.Free;
    end;
  end
  else
    Result := WinProcs.MessageBox(WndParent, Txt, Caption, TextType);
end;

function MessageBox(WndParent: HWnd; Txt, Caption: PChar; TextType: Word): Integer;
var
  xMessageForm: TxMessageForm;
  W, H, Z: Integer;
  R: TRect;
  WinControl: TWinControl;
begin
  {$IFDEF REGISTER_GSMULTILINGUALSUPPORT}
  Txt := PChar(TranslateText(StrPas(Txt)));
  Caption := PChar(TranslateText(StrPas(Caption)));
  {$ENDIF}

  if xMessageBox <> nil then
  begin
    WinControl := FindControl(WndParent);
    xMessageForm := TxMessageForm.Create(WinControl);
    try
      xMessageForm.Shadow := xMessageBox.Shadow;
      xMessageForm.ShadowDepth := xMessageBox.ShadowDepth;
      xMessageForm.TextFont.Assign(xMessageBox.Font);
      xMessageForm.SubtitleFont.Assign(xMessageBox.SubtitleFont);
      xMessageForm.Color := xMessageBox.Color;
      xMessageForm.BorderColor := xMessageBox.BorderColor;
      xMessageForm.BorderWidth := xMessageBox.BorderWidth;
      xMessageForm.Callout := xMessageBox.Callout;
      xMessageForm.CalloutDisplaysment := xMessageBox.FCalloutDisplaysment;
      xMessageForm.Alignment := xMessageBox.Alignment;
      xMessageForm.MaxWidth := xMessageBox.MaxWidth;
      xMessageForm.MinWidth := xMessageBox.MinWidth;
{      if Phrases.Language = lEnglish then
	xMessageForm.Language := lngEnglish
      else}
	xMessageForm.Language := lngRussian;
	      xMessageForm.Caption := StrPas(Txt);
      xMessageForm.SubtitleName := StrPas(Caption);
      with xMessageForm do
      begin
        Z := TextType;
        IconType := itNone;
        if (TextType >= MB_ICONSTOP) and (TextType < MB_ICONQUESTION) then
        begin
          Z := TextType - 16;
          IconType := itIconStop;
        end;
        if (TextType >= MB_ICONQUESTION) and
           (TextType < MB_ICONEXCLAMATION) then
        begin
          Z := TextType - 32;
          IconType := itQUESTION;
        end;
        if (TextType >= MB_ICONEXCLAMATION) and
           (TextType < MB_ICONINFORMATION) then
        begin
          Z := TextType - 48;
          IconType := itExclamation;
        end;
        if (TextType >= MB_ICONINFORMATION) and
           (TextType < MB_ICONINFORMATION + 16) then
        begin
          Z := TextType - 64;
          IconType := itIconInformation;
        end;
        case Z of
          MB_ABORTRETRYIGNORE:
           DialogType := dtABORTRETRYIGNORE;
          MB_OK: DialogType := dtOk;
          MB_OKCANCEL: DialogType := dtOkCancel;
          MB_RETRYCANCEL: DialogType := dtRetryCancel;
          MB_YESNO: DialogType := dtYesNo;
          MB_YESNOCANCEL: DialogType := dtYesNoCancel;
        end;
        Font.Size := 8;
        xMessageForm.DataCalculation(W, H);
        GetWindowRect(GetDeskTopWindow, R);
        SetBounds(R.Right div 2 - W div 2, R.Bottom div 2 - H div 2 , W, H);
{        Application.ProcessMessages;}
        xMessageForm.ShowModal;
        case xMessageForm.ModalResult of
          mrAbort: Result := idAbort;
          mrCancel: Result := idCancel;
          mrIgnore: Result := idIgnore;
          mrNo: Result := idNo;
          mrOk: Result := idOk;
          mrRetry: Result := idRetry;
          mrYes: Result := idYes;
        else
          Result := idOk;
        end;
      end;
    finally
      xMessageForm.Free;
{      Application.ProcessMessages;}
    end;
  end
  else
    Result := WinProcs.MessageBox(WndParent, Txt, Caption, TextType);
end;

function MessageBox(WndParent: HWnd; Txt, Caption: String; TextType: Word): Integer;
begin
  {$IFDEF REGISTER_GSMULTILINGUALSUPPORT}
  Txt := TranslateText(Txt);
  Caption := TranslateText(Caption);
  {$ENDIF}

  Txt := Txt + #0;
  Caption := Caption + #0;
  Result := MessageBox(WndParent, @Txt[1], @Caption[1], TextType);
end;

function MessageBoxPos(WndParent: HWnd; Txt, Caption: String; TextType: Word;
  Pos: TPoint): Integer;
begin
  {$IFDEF REGISTER_GSMULTILINGUALSUPPORT}
  Txt := TranslateText(Txt);
  Caption := TranslateText(Caption);
  {$ENDIF}

  Txt := Txt + #0;
  Caption := Caption + #0;
  Result := MessageBoxPos(WndParent, PChar(Txt), Pchar(Caption), TextType, Pos);
end;

function MessageBoxEx(WndParent: HWnd; Txt, Caption: String; TextType: Word;
  WinCntrl: TWinControl = nil): Integer;
begin
  {$IFDEF REGISTER_GSMULTILINGUALSUPPORT}
  Txt := TranslateText(Txt);
  Caption := TranslateText(Caption);
  {$ENDIF}

  Txt := Txt + #0;
  Caption := Caption + #0;
  Result := MessageBoxEx(WndParent, @Txt[1], @Caption[1], TextType, WinCntrl);
end;

(*
procedure DoDelay(Pause: Word);
var
  OldTime: LongInt;
begin
  OldTime := GetTickCount;
  while GetTickCount - OldTime <= Pause do { nothing };
end;
*)

{TxMessageBox --------------------------------------------}

constructor TxMessageBox.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  if Assigned(xMessageBox) then
    raise ExWindowMessageError.Create('Only one instance of TxMessageBox allowed');

  FShadow := True;
  FShadowDepth := 6;
  FCalloutDisplaysment := 60;
  FFont := TFont.Create;
  FFont.Name := Def_FontName;
  FFont.Size := Def_FontSize;
  FFont.Style := Def_FontStyle;
//  FFont.CharSet := RUSSIAN_CHARSET;

  FSubtitleFont := TFont.Create;
  FSubtitleFont.Name := Def_FontName;
  FSubtitleFont.Size := Def_FontSize;
  FSubtitleFont.Style := [fsBold];
//  FSubtitleFont.CharSet := RUSSIAN_CHARSET;

  FShadow :=  True;
  FShadowDepth := 4;
  FBorderWidth := 1;
  FColor := $00C0FFFF;
  FBorderColor := clBlack;
  FAlignment := taCenter;
  FMaxWidth := 400;
  FMinWidth := 200;
  FCallout := clBottom;
  xMessagebox := Self;
end;

destructor TxMessageBox.Destroy;
begin
  FFont.Free;
  FSubtitleFont.Free;
  xMessageBox := nil; 
  inherited Destroy;
end;

procedure TxMessageBox.SetFont(AFont: TFont);
begin
  FFont.Assign(AFont);
end;

procedure TxMessageBox.SetSubtitleFont(AFont: TFont);
begin
  FSubtitleFont.Assign(AFont);
end;

procedure TxMessageBox.Loaded;
begin
  inherited Loaded;

  {$IFDEF REGISTER_GSMULTILINGUALSUPPORT}
  if TranslateBase <> nil then
  begin
    FFont.Charset := TranslateBase.Charset;
    FSubtitleFont.Charset := TranslateBase.Charset;
  end;
  {$ENDIF}
end;

{Registration --------------------------------------------}

procedure Register;
begin
  RegisterComponents('gsDlg', [TxMessageBox]);
end;

{Initialization ------------------------------------------}

initialization

  xMessageBox := nil;

finalization

  if Assigned(xMessageBox) then
  begin
    xMessageBox.Free;
    xMessageBox := nil;
  end;
  
end.
