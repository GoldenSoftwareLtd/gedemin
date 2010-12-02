{

  Toolbar2000 Modifications
  (patch.txt) & TBSkin+ Implementation (TBSkinPlus.Pas)
  Copyright 2001-2002 by Haralabos Michael. All rights reserved.

  See "lincense.txt" before modifing/copying this code

  Contributors:
  ColorDarker, ColorLighter functions (C) Aaron Chan

  Floating Windows OfficeXP & WindowsXP Style (C) Andreas Holstenson
  Windows XP Shadows (C) Andreas Holstenson

  Skin Manager, Docked Captions, Component Additions & Changes (C) Dean Harmon
  BlendTBXIcon, DrawTBXIconShadow (C) Alex Denisov
  Other color conversions found somewhere on Internet.

}

unit TBSkinPlus;

interface

uses
 Windows, Messages, Controls, SysUtils, Classes, Graphics;

const
  TBSkinVersion = 'Version 1.00.15';
  XPMargin = 4;
  ShadowContrast = 60;

 // Windows XP Support //
  ThemeLibrary = 'UxTheme.dll';

  ToolbarThemeName = 'Toolbar';
  MenuThemeName = 'Menu';
  ReBarThemeName = 'ReBar';
  ButtonThemeName = 'Button';
  WindowThemeName = 'Window';
 // Windows XP Support //

type
  ESkinError = class(Exception);
  TTBBaseSkin = class;
  PNotifyEvent = ^TNotifyEvent;

  TTBSkins = (tbsDisabled, tbsOfficeXP, tbsWindowsXP, tbsNativeXP);
  TTBColorSets =(tbcOfficeXP, tbcWindowsXP, tbcCustom);
  TTBSkinColor = (cFace, cPopup, cBorder, cToolbar, cDragHandle, cImageList,
    cImgListShadow, cSelBar, cSelBarBorder, cSelItem, cSelItemBorder,
    cSelPushed, cSelPushedBorder, cSeparator, cChecked, cCheckedOver,
    cDockBorderTitle, cDockBorderIn, cDockBorderOut, cGradStart, cGradEnd,
    cPopupGradStart, cPopupGradEnd, cImgGradStart, cImgGradEnd, cText,
    cHighlightText, cCaptionText);
  TTBOption  = (tboPopupOverlap, tboShadow, tboDockedCaptions, tboMenuTBColor,
    tboGradSelItem, tboBlendedImages, tboNoHoverIconShadow);
  TTBPopupStyle = (tbpsDefault, tbpsGradVert, tbpsGradHorz);
  TTBImgBackStyle = (tbimsDefault, tbimsGradVert, tbimsGradHorz);
  TTBGradDir = (tbgLeftRight, tbgTopBottom);
  TShadowStyle = (sOfficeXP, sWindowsXP);
  TTBOptions = set of TTBOption;

  // Windows XP Support //
  MenuPart = (MP_NONE, MP_MENUITEM, MP_MENUDROPDOWN, MP_MENUBARITEM,
    MP_MENUBARDROPDOWN, MP_CHEVRON,  MP_SEPARATOR);
  MenuState = (MS_NONE, MS_DEMOTED, MS_NORMAL, MS_SELECTED);

  ToolbarPart = (TP_NONE, TP_BUTTON, TP_DROPDOWNBUTTON, TP_SPLITBUTTON,
    TP_SPLITBUTTONDROPDOWN, TP_SEPARATOR, TP_SEPARATORVERT);
  ToolbarState = (TS_NONE, TS_NORMAL, TS_HOT, TS_PRESSED, TS_DISABLED,
    TS_CHECKED, TS_HOTCHECKED);

  ExplorerPart = (EBP_NONE, EBP_HEADERBACKGROUND, EBP_HEADERCLOSE,
    EBP_HEADERPIN, EBP_IEBARMENU, EBP_NORMALGROUPBACKGROUND,
    EBP_NORMALGROUPCOLLAPSE, EBP_NORMALGROUPEXPAND, EBP_NORMALGROUPHEAD,
    EBP_SPECIALGROUPBACKGROUND,EBP_SPECIALGROUPCOLLAPSE,
    EBP_SPECIALGROUPEXPAND,EBP_SPECIALGROUPHEAD);

  HeaderCloseState = (EBHC_NONE, EBHC_NORMAL, EBHC_HOT, EBHC_PRESSED);

  ButtonPart = (BP_NONE, BP_PUSHBUTTON, BP_RADIOBUTTON, BP_CHECKBOX,
    BP_GROUPBOX, BP_USERBUTTON);
  PushButtonState = (PBS_NONE, PBS_NORMAL, PBS_HOT, PBS_PRESSED,
                     PBS_DISABLED);

  ReBarPart = (RP_NONE, RP_GRIPPER, RP_GRIPPERVERT, RP_BAND, RP_CHEVRON,
    RP_CHEVRONVERT);

  ChevronState = (CHEVS_NONE, CHEVS_NORMAL, CHEVS_HOT, CHEVS_PRESSED);

  WindowPart = (WP_NONE, WP_CAPTION, WP_SMALLCAPTION, WP_MINCAPTION,
    WP_SMALLMINCAPTION, WP_MAXCAPTION, WP_SMALLMAXCAPTION, WP_FRAMELEFT,
    WP_FRAMERIGHT, WP_FRAMEBOTTOM, WP_SMALLFRAMELEFT, WP_SMALLFRAMERIGHT,
    WP_SMALLFRAMEBOTTOM, WP_SYSBUTTON, WP_MDISYSBUTTON, WP_MINBUTTON,
    WP_MDIMINBUTTON, WP_MAXBUTTON, WP_CLOSEBUTTON, WP_SMALLCLOSEBUTTON,
    WP_MDICLOSEBUTTON, WP_RESTOREBUTTON, WP_MDIRESTOREBUTTON, WP_HELPBUTTON,
    WP_MDIHELPBUTTON, WP_HORZSCROLL, WP_HORZTHUMB, WP_VERTSCROLL, WP_VERTTHUMB,
    WP_DIALOG, WP_CAPTIONSIZINGTEMPLATATE, WP_SMALLCAPTIONSIZINGTEMPLATATE,
    WP_FRAMELEFTSIZINGTEMPLATATE, WP_SMALLFRAMELEFTSIZINGTEMPLATATE,
    WP_FRAMERIGHTSIZINGTEMPLATATE, WP_SMALLFRAMERIGHTSIZINGTEMPLATATE,
    WP_FRAMEBOTTOMSIZINGTEMPLATATE, WP_SMALLFRAMEBOTTOMSIZINGTEMPLATATE);

  FrameState = (FS_NONE, FS_ACTIVE, FS_INACTIVE);
  CaptionState = (CS_NONE, CS_ACTIVE, CS_INACTIVE, CS_DISABLED);
  ButtonState = (CBS_NONE, CBS_NORMAL, CBS_HOT, CBS_PUSHED, CBS_DISABLED);
 // Windows XP Support //

  TTBColors = Class(TPersistent)
  private
    FParent: TTBBaseSkin;

    FFace: TColor;
    FPopup: TColor;
    FBorder: TColor;
    FToolbar: TColor;
    FImageList: TColor;
    FDragHandle: TColor;
    FChecked: TColor;
    FCheckedOver: TColor;
    FDockBorderIn: TColor;
    FDockBorderOut: TColor;
    FDockBorderTitle: TColor;
    FSelBar: TColor;
    FSelBarBorder: TColor;
    FSelItem: TColor;
    FSelItemBorder: TColor;
    FSelPushed: TColor;
    FSelPushedBorder: TColor;
    FImgListShadow: TColor;
    FSeparator: TColor;
    FGradStart: TColor;
    FGradEnd: TColor;
    FPopupGradStart: TColor;
    FPopupGradEnd: TColor;
    FImgGradStart: TColor;
    FImgGradEnd: TColor;
    FText: TColor;
    FHighlightText: TColor;
    FCaptionText: TColor;

    rgbFace: TColorRef;
    rgbPopup: TColorRef;
    rgbBorder: TColorRef;
    rgbToolbar: TColorRef;
    rgbImageList: TColorRef;
    rgbDragHandle: TColorRef;
    rgbChecked: TColorRef;
    rgbCheckedOver: TColorRef;
    rgbDockBorderIn: TColorRef;
    rgbDockBorderOut: TColorRef;
    rgbDockBorderTitle: TColorRef;
    rgbSelBar: TColorRef;
    rgbSelBarBorder: TColorRef;
    rgbSelItem: TColorRef;
    rgbSelItemBorder: TColorRef;
    rgbSelPushed: TColorRef;
    rgbSelPushedBorder: TColorRef;
    rgbSeparator: TColorRef;
    rgbImgListShadow: TColorRef;
    rgbGradStart: TColorRef;
    rgbGradEnd: TColorRef;
    rgbPopupGradStart: TColorRef;
    rgbPopupGradEnd: TColorRef;
    rgbImgGradStart: TColorRef;
    rgbImgGradEnd: TColorRef;
    rgbText: TColorRef;
    rgbHighlightText: TColorRef;
    rgbCaptionText: TColorRef;

    function GetSkinColor(const Index: Integer): TColor;
    procedure SetSkinColor(const Index: Integer; const Value: TColor);
  public
    constructor Create(AOwner: TTBBaseSkin);
  published
    property tcFace: TColor index 1 read GetSkinColor write SetSkinColor;
    property tcPopup: TColor index 2 read GetSkinColor write SetSkinColor;
    property tcBorder: TColor index 3 read GetSkinColor write SetSkinColor;
    property tcToolbar: TColor index 4 read GetSkinColor write SetSkinColor;
    property tcImageList: TColor index 5 read GetSkinColor write SetSkinColor;
    property tcDockBorderIn: TColor index 6 read GetSkinColor write SetSkinColor;
    property tcDockBorderOut: TColor index 7 read GetSkinColor write SetSkinColor;
    property tcDockBorderTitle: TColor index 8 read GetSkinColor write SetSkinColor;
    property tcDragHandle: TColor index 9 read GetSkinColor write SetSkinColor;
    property tcChecked: TColor index 10 read GetSkinColor write SetSkinColor;
    property tcCheckedOver: TColor index 11 read GetSkinColor write SetSkinColor;
    property tcSelBar: TColor index 12 read GetSkinColor write SetSkinColor;
    property tcSelBarBorder: TColor index 13 read GetSkinColor write SetSkinColor;
    property tcSelItem: TColor index 14 read GetSkinColor write SetSkinColor;
    property tcSelItemBorder: TColor index 15 read GetSkinColor write SetSkinColor;
    property tcSelPushed: TColor index 16 read GetSkinColor write SetSkinColor;
    property tcSelPushedBorder: TColor index 17 read GetSkinColor write SetSkinColor;
    property tcSeparator: TColor index 18 read GetSkinColor write SetSkinColor;
    property tcImgListShadow: TColor index 19 read GetSkinColor write SetSkinColor;
    property tcGradStart: TColor index 20 read GetSkinColor write SetSkinColor;
    property tcGradEnd: TColor index 21 read GetSkinColor write SetSkinColor;
    property tcPopupGradStart: TColor index 22 read GetSkinColor write SetSkinColor;
    property tcPopupGradEnd: TColor index 23 read GetSkinColor write SetSkinColor;
    property tcImgGradStart: TColor index 24 read GetSkinColor write SetSkinColor;
    property tcImgGradEnd: TColor index 25 read GetSkinColor write SetSkinColor;
    property tcText: TColor index 26 read GetSkinColor write SetSkinColor;
    property tcHighlightText: TColor index 27 read GetSkinColor write SetSkinColor;
    property tcCaptionText: TColor index 28 read GetSkinColor write SetSkinColor;
  end;

  TTBSkinManager = class(TList)
  private
    FOriginalDefault : TTBBaseSkin;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure SetSkinAsDefault(ASkin: TTBBaseSkin);
    function AddSkin(ASkin: TTBBaseSkin): Integer;
    procedure RemoveSkin(ASkin: TTBBaseSkin);
  end;

  TTBBaseSkin = class(TComponent)
  private
    FVersion: String;
    FTBColors: TTBColors;
    FNotifyList: TList;
    FTBSkin: TTBSkins;
    FTBColorSet: TTBColorSets;
    FTBOptions: TTBOptions;
    FTBGradSel: TTBGradDir;
    FIsDefault: Boolean;
    FPopupStyle: TTBPopupStyle;
    FImgBackStyle: TTBImgBackStyle;
    FShadowStyle: TShadowStyle;
    FParentTFont,
    FCaptionFont: TFont;
    FParentFont: Boolean;

    FViews: TList;
    FDockables: TList;

    procedure SetTBSkin(const Value: TTBSkins);
    procedure SetTBColorSet(const Value: TTBColorSets);
    procedure SetDefault(const Value: Boolean);
    procedure SetOptions(const Value: TTBOptions);
    procedure SetGradSel(const Value: TTBGradDir);
    procedure SetPopupStyle(const Value: TTBPopupStyle);
    procedure SetImgBackStyle(const Value: TTBImgBackStyle);
    procedure SetShadowStyle(const Value: TShadowStyle);

    procedure SetCaptionFont(const Value: TFont);
    procedure SetParentFont(const Value: Boolean);

    procedure OfficeXPColorSet;
    procedure WindowsXPColorSet;

    function GetComponentVersion: String;
    function IsFontStored: Boolean;
  protected
    procedure RegisterChanges (Proc: TNotifyEvent); virtual;
    procedure UnregisterChanges (Proc: TNotifyEvent); virtual;
    procedure AssignColorsToRGB; virtual;

    procedure RepaintRegisteredClasses; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;

    procedure CalculateColorSet;
    function GetPopupNCSize: Integer;
    function RGBColor(const AColor: TTBSkinColor) : TColorRef;

    property ColorSet: TTBColorSets read FTBColorSet write SetTBColorSet default tbcOfficeXP;
    property CaptionFont: TFont read FCaptionFont write SetCaptionFont stored IsFontStored;
    property Colors: TTBColors read FTBColors write FTBColors;
    property Gradient: TTBGradDir read FTBGradSel write SetGradSel default tbgTopBottom;
    property ImgBackStyle: TTBImgBackStyle read FImgBackStyle write SetImgBackStyle default tbimsDefault;
    property IsDefaultSkin: Boolean read FIsDefault write SetDefault;
    property Options: TTBOptions read FTBOptions write SetOptions default [tboShadow];
    property ParentFont: Boolean read FParentFont write SetParentFont;
    property PopupStyle: TTBPopupStyle read FPopupStyle write SetPopupStyle default tbpsDefault;
    property ShadowStyle: TShadowStyle read FShadowStyle write SetShadowStyle default sOfficeXP;
    property SkinType: TTBSkins read FTBSkin write SetTBSkin default tbsOfficeXP;
    property Version: String read GetComponentVersion write FVersion;

    function RegisterDockable(ADockable: TObject): Integer;
    function UnregisterDockable(ADockable: TObject): Boolean;
  end;

  TTBSkin = class(TTBBaseSkin)
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property ColorSet; //Must be before Colors!
    property CaptionFont;
    property Colors;
    property Gradient;
    property ImgBackStyle;
    property IsDefaultSkin;
    property Options;
    property ParentFont;
    property PopupStyle;
    property ShadowStyle;
    property SkinType;
    property Version;
  end;

  // Shadow Related //

  TShadow = class(TWinControl)
  private
    FPopup: Boolean;
    FRight: Boolean;
    FCorner1: Boolean;
    FCorner2: Boolean;
    FShadowStyle: TShadowStyle;
    FClipStart: Integer;
    FClipFinish: Integer;

    MemDC: HDC;
    MemBitmap: HBitmap;

    procedure OfficeXPShadow(const DC: HDC);
    procedure WindowsXPShadow(const DC: HDC);

    procedure WMNCPaint(var Message: TMessage); message WM_NCPAINT;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMNCHitTest(var Message: TMessage); message WM_NCHITTEST;
  protected
    FPrepared: Boolean;
    procedure CreateParams(Var Params: TCreateParams); override;
  public
    constructor Create(const AOwner: TComponent; const ARight: Boolean;
      const APopup: Boolean); reintroduce;
    destructor Destroy; override;

    procedure Prepare;
    procedure UnPrepare;
  published
    property Corner1: Boolean read FCorner1 write FCorner1;
    property Corner2: Boolean read FCorner2 write FCorner2;
    property ClipStart: Integer read FClipStart write FClipStart;
    property ClipFinish: Integer read FClipFinish write FClipFinish;
    property ShadowStyle: TShadowStyle read FShadowStyle write FShadowStyle;
  end;

  // Windows XP Support //
  procedure InitializeThemeSupport;
  procedure FinilizeThemeSupport;
  // Windows XP Support //

Var
  DefaultSkin : TTBBaseSkin;
  TBSkinManager: TTBSkinManager;

  // Windows XP Support //
  ThemeDLL: THandle;
  aTheme: THandle;
  aPart: Integer;
  aState: Integer;

  OpenThemeData: function (hwnd: HWND; pszClassList: LPCWSTR): THandle; stdcall;
  CloseThemeData: function (hTheme: THandle): HRESULT; stdcall;
  DrawThemeBackground: function (hTheme: THandle; hdc: HDC; iPartId, iStateId: integer;
                                 const pRect: TRect; pClipRect: PRECT): HRESULT; stdcall;
  DrawThemeText: function (hTheme: THandle; hdc: HDC; iPartId, iStateId: integer;
                           pszText: LPCWSTR; iCharCount: integer; dwTextFlags, dwTextFlags2: DWORD;
                           const pRect: TRect): HRESULT; stdcall;
  DrawThemeEdge: function (hTheme: THandle; hdc: HDC; iPartId, iStateId: integer;
                           const pDestRect: TRect; uEdge, uFlags: UINT; pConTeThementRect: PRECT): HRESULT; stdcall;
  GetThemeColor: function (hTheme: THandle; iPartId, iStateId, iPropId: integer;
                           pColor: TColorRef): HRESULT; stdcall;
  GetThemeSysColor: function(hTheme: THandle; iColorId: Integer): COLORREF; stdcall;
  IsThemeActive: function : Boolean; stdcall;
  // Windows XP Support //

implementation

uses
  Forms, TBSkinShared, TB2Common, TB2Dock, TB2ToolWindow;

{ Helper Functions }

// Windows XP Support //

procedure InitializeThemeSupport;
begin
  ThemeDLL := LoadLibrary(ThemeLibrary);

  if ThemeDLL <> 0 then
  begin
    @OpenThemeData := GetProcAddress(ThemeDLL, 'OpenThemeData');
    @CloseThemeData := GetProcAddress(ThemeDLL, 'CloseThemeData');
    @DrawThemeBackground := GetProcAddress(ThemeDLL, 'DrawThemeBackground');
    @DrawThemeText := GetProcAddress(ThemeDLL, 'DrawThemeText');
    @DrawThemeEdge := GetProcAddress(ThemeDLL, 'DrawThemeEdge');
    @GetThemeColor := GetProcAddress(ThemeDLL, 'GetThemeColor');
    @GetThemeSysColor := GetProcAddress(ThemeDLL, 'GetThemeSysColor');
    @IsThemeActive := GetProcAddress(ThemeDLL, 'IsThemeActive');
  end
  else
    ThemeDLL := 0;
end;

procedure FinilizeThemeSupport;
begin
  if ThemeDLL <> 0 then
    FreeLibrary(ThemeDLL);
end;
// Windows XP Support //

{ TTBColors }

constructor TTBColors.Create(AOwner: TTBBaseSkin);
begin
  inherited Create;

  FParent := AOwner;
end;

function TTBColors.GetSkinColor(const Index: Integer): TColor;
begin
  case Index of
    1: Result := FFace;
    2: Result := FPopup;
    3: Result := FBorder;
    4: Result := FToolbar;
    5: Result := FImageList;
    6: Result := FDockBorderIn;
    7: Result := FDockBorderOut;
    8: Result := FDockBorderTitle;
    9: Result := FDragHandle;
    10: Result := FChecked;
    11: Result := FCheckedOver;
    12: Result := FSelBar;
    13: Result := FSelBarBorder;
    14: Result := FSelItem;
    15: Result := FSelItemBorder;
    16: Result := FSelPushed;
    17: Result := FSelPushedBorder;
    18: Result := FSeparator;
    19: Result := FImgListShadow;
    20: Result := FGradStart;
    21: Result := FGradEnd;
    22: Result := FPopupGradStart;
    23: Result := FPopupGradEnd;
    24: Result := FImgGradStart;
    25: Result := FImgGradEnd;
    26: Result := FText;
    27: Result := FHighlightText;
    28: Result := FCaptionText;
    else Result := clNone;
  end;
end;

procedure TTBColors.SetSkinColor(const Index: Integer; const Value: TColor);
begin
  if FParent.FTBColorSet <> tbcCustom then
    exit;

  case Index of
    1: FFace := Value;
    2: FPopup := Value;
    3: FBorder := Value;
    4: FToolbar := Value;
    5: FImageList := Value;
    6: FDockBorderIn := Value;
    7: FDockBorderOut := Value;
    8: FDockBorderTitle := Value;
    9: FDragHandle := Value;
    10: FChecked := Value;
    11: FCheckedOver := Value;
    12: FSelBar := Value;
    13: FSelBarBorder := Value;
    14: FSelItem := Value;
    15: FSelItemBorder := Value;
    16: FSelPushed := Value;
    17: FSelPushedBorder := Value;
    18: FSeparator := Value;
    19: FImgListShadow := Value;
    20: FGradStart := Value;
    21: FGradEnd := Value;
    22: FPopupGradStart := Value;
    23: FPopupGradEnd := Value;
    24: FImgGradStart := Value;
    25: FImgGradEnd := Value;
    26: FText := Value;
    27: FHighlightText := Value;
    28: FCaptionText := Value;
  end;

  case Index of
    1: rgbFace := ColorToRGB(Value);
    2: rgbPopup := ColorToRGB(Value);
    3: rgbBorder := ColorToRGB(Value);
    4: rgbToolbar := ColorToRGB(Value);
    5: rgbImageList := ColorToRGB(Value);
    6: rgbDockBorderIn := ColorToRGB(Value);
    7: rgbDockBorderOut := ColorToRGB(Value);
    8: rgbDockBorderTitle := ColorToRGB(Value);
    9: rgbDragHandle := ColorToRGB(Value);
    10: rgbChecked := ColorToRGB(Value);
    11: rgbCheckedOver := ColorToRGB(Value);
    12: rgbSelBar := ColorToRGB(Value);
    13: rgbSelBarBorder := ColorToRGB(Value);
    14: rgbSelItem := ColorToRGB(Value);
    15: rgbSelItemBorder := ColorToRGB(Value);
    16: rgbSelPushed := ColorToRGB(Value);
    17: rgbSelPushedBorder := ColorToRGB(Value);
    18: rgbSeparator := ColorToRGB(Value);
    19: rgbImgListShadow := ColorToRGB(Value);
    20: rgbGradStart := ColorToRGB(Value);
    21: rgbGradEnd := ColorToRGB(Value);
    22: rgbPopupGradStart := ColorToRGB(Value);
    23: rgbPopupGradEnd := ColorToRGB(Value);
    24: rgbImgGradStart := ColorToRGB(Value);
    25: rgbImgGradEnd := ColorToRGB(Value);
    26: rgbText := ColorToRGB(Value);
    27: rgbHighlightText := ColorToRGB(Value);
    28: rgbCaptionText := ColorToRGB(Value);
  end;

  if FParent.FIsDefault and (DefaultSkin <> nil) then
  with DefaultSkin.Colors do
  case Index of
    1: tcFace := Value;
    2: tcPopup := Value;
    3: tcBorder := Value;
    4: tcToolbar := Value;
    5: tcImageList := Value;
    6: tcDockBorderIn := Value;
    7: tcDockBorderOut := Value;
    8: tcDockBorderTitle := Value;
    9: tcDragHandle := Value;
    10: tcChecked := Value;
    11: tcCheckedOver := Value;
    12: tcSelBar := Value;
    13: tcSelBarBorder := Value;
    14: tcSelItem := Value;
    15: tcSelItemBorder := Value;
    16: tcSelPushed := Value;
    17: tcSelPushedBorder := Value;
    18: tcSeparator := Value;
    19: tcImgListShadow := Value;
    20: tcGradStart := Value;
    21: tcGradEnd := Value;
    22: tcPopupGradStart := Value;
    23: tcPopupGradEnd := Value;
    24: tcImgGradStart := Value;
    25: tcImgGradEnd := Value;
    26: tcText := Value;
    27: tcHighlightText := Value;
    28: tcCaptionText := Value;
  end;

  FParent.RepaintRegisteredClasses;
end;

{ TTBSkinManager }

function TTBSkinManager.AddSkin(ASkin: TTBBaseSkin): Integer;
var
  Counter: Integer;
begin
  for Counter := 0 to Count - 1 do
  if ASkin = Self[Counter] then
  begin
    Result := Counter;
    Exit;
  end;

  Result := Add(ASkin);

//if it's the first skin that is being added, make it the default instead

  if (Count = 1) and (DefaultSkin <> nil) then
  begin
    DefaultSkin.Assign(ASkin);
    ASkin.FIsDefault := True;
  end;
end;

constructor TTBSkinManager.Create;
begin
  FOriginalDefault := TTBBaseSkin.Create(nil);
  FOriginalDefault.Assign(DefaultSkin);
end;

destructor TTBSkinManager.Destroy;
begin
  if DefaultSkin <> nil then
    DefaultSkin.Assign(FOriginalDefault);
    
  FOriginalDefault.Free;

  inherited;
end;

procedure TTBSkinManager.RemoveSkin(ASkin: TTBBaseSkin);
var
  Counter: Integer;
  WasDefault: Boolean;
begin
  Counter := IndexOf(ASkin);

  if Counter <> -1 then
  begin
    WasDefault := ASkin.IsDefaultSkin;
    Delete(Counter);

    if WasDefault and (Count > 0) then
      TTBBaseSkin(Self[0]).FIsDefault := True
    else
    if (Count = 0) and (DefaultSkin <> nil) then
      DefaultSkin.Assign(FOriginalDefault);
  end
  else
    raise ESkinError.Create('The skin cannot be removed because it''s not part of the SkinManager');
end;

procedure TTBSkinManager.SetSkinAsDefault(ASkin: TTBBaseSkin);
var
  Counter1, Counter2: Integer;
begin
  if Assigned(ASkin) then
  begin
    Counter1 := IndexOf(ASkin);

    //make sure all the others are *not* the default anymore
    if (Counter1 <> -1) and ASkin.IsDefaultSkin then
    for Counter2 := 0 to Count - 1 do
      if TTBSkin(Self[Counter2]) <> ASkin then
        TTBSkin(Self[Counter2]).FIsDefault := False;

    if Counter1 = -1 then
    begin
      raise ESkinError.Create('This skin has not been added to the SkinManager.');
      exit;
    end;

    ASkin.FIsDefault := True;

    if DefaultSkin <> nil then
      DefaultSkin.Assign(ASkin);
  end
  else
    if DefaultSkin <> nil then
      DefaultSkin.Assign(FOriginalDefault);
   //if nil is passed, then we set it to the original
end;

{ TTBBaseSkin }

procedure TTBBaseSkin.OfficeXPColorSet;
begin
  with FTBColors do
  begin
    FFace := clBtnFace;
    FBorder := BlendColors(clBtnShadow, clBlack, 0.20);
    FToolbar := BlendColors(clBtnFace, clWindow, 0.16);
    FDragHandle := BlendColors(clBtnShadow, clWindow, 0.231);
    FSelBar := BlendColors(clHighlight, clWindow, 0.70);
    FSelBarBorder := clHighlight;

    FSelItem := FSelBar;
    FSelItemBorder  := clHighlight;

    FSelPushed := BlendColors(clHighlight, clWindow, 0.601);
    FSelPushedBorder := clHighlight;

    FImageList := BlendColors(clBtnFace, clWindow, 0.16);
    FImgListShadow := BlendColors(clHighlight, clBtnShadow, 0.701);

    FPopup := BlendColors(clWindow, clBtnFace, 0.15);
    FChecked := BlendColors(FSelPushed, BlendColors(clBtnFace, clWindow, 0.44), 0.794);
    FCheckedOver := FSelPushed;

    FDockBorderIn := BlendColors(clBtnShadow, clBlack, 0.15);
    FDockBorderOut := FDockBorderIn;
    FDockBorderTitle := clBtnShadow;

    FGradStart := ColorLighter(FSelItem, 70);
    FGradEnd := FSelItem;

    FPopupGradStart := ColorLighter(FSelItem, 100);
    FPopupGradEnd := BlendColors(clMaroon, ColorLighter($000080FF, 100), 0.95);

    FPopupGradStart := FImageList;
    FPopupGradEnd := ColorLighter(FImageList, 70);

    FImgGradStart := FImageList;
    FImgGradEnd := ColorDarker(FImageList, 50);

    FSeparator := ColorLighter(clBtnShadow, 15);

    FText := clWindowText;
    FHighlightText := clWindowText;
    FCaptionText := clHighlightText;
  end;

  AssignColorsToRGB;
end;

procedure TTBBaseSkin.WindowsXPColorSet;
begin
  with FTBColors do
  begin
    FFace := clMenu;
    FPopup := clWindow;
    FBorder := clBtnShadow;
    FToolbar := clBtnFace;
    FDragHandle := clBtnShadow;

    FSelBar := clWindow;
    FSelBarBorder := clBtnShadow;

    FSelItem := ColorLighter(clHighlight, 13);
    FSelItemBorder := clHighlight;

    FSelPushed := ColorDarker(FSelItem, 20);
    FSelPushedBorder := FSelItem;

    FImageList := clMenu;
    FImgListShadow := clBtnShadow;

    FChecked := FSelBar;
    FCheckedOver := FSelPushed;

    FDockBorderIn := FPopup;
    FDockBorderOut := clBlack;
    FDockBorderTitle := clWindow;

    FGradStart := clWhite;
    FGradEnd := FSelItem;

    FSeparator := FBorder;

    FGradStart := ColorLighter(FSelItem, 70);
    FGradEnd := FSelItem;

    FPopupGradStart := ColorLighter(FSelItem, 100);
    FPopupGradEnd := BlendColors(clMaroon, ColorLighter($000080FF, 100), 0.95);

    FPopupGradStart := ColorLighter(FSelItem, 40);
    FPopupGradEnd := ColorLighter(FSelItem, 100);

    FImgGradStart := ColorLighter(FSelItem, 50);
    FImgGradEnd := ColorLighter(FSelItem, 100);

    FText := clWindowText;
    FHighlightText := clHighlightText;
    FCaptionText := clWindowText;
  end;

  AssignColorsToRGB;
end;

constructor TTBBaseSkin.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FTBColors := TTBColors.Create(Self);
  FTBSkin := tbsOfficeXP;
  FTBOptions := [];
  FShadowStyle := sOfficeXP;
  FTBGradSel := tbgTopBottom;
  FPopupStyle := tbpsDefault;
  FImgBackStyle := tbimsDefault;

  FCaptionFont := TFont.Create;
  FCaptionFont.Style := [fsBold];
  FParentTFont := TFont.Create;
  FParentTFont.Style := [fsBold];
  FParentFont := True;

  CalculateColorSet;

  FIsDefault := False;

  FViews := TList.Create;
  FDockables := TList.Create;
end;

destructor TTBBaseSkin.Destroy;
var
  Counter: Integer;
begin
  Destroying;

  inherited;

  if Assigned(FNotifyList) then
  begin
   for Counter := FNotifyList.Count-1 downto 0 do
     Dispose(PNotifyEvent(FNotifyList[Counter]));

    FNotifyList.Free;
  end;

  FreeAndNil(FViews);
  FreeAndNil(FTBColors);
  FreeAndNil(FParentTFont);
  FreeAndNil(FCaptionFont);
  FreeAndNil(FDockables);
end;

procedure TTBBaseSkin.RegisterChanges(Proc: TNotifyEvent);
var
  P: PNotifyEvent;
  Counter: Integer;
begin
  if FNotifyList = nil then
    FNotifyList := TList.Create;

  for Counter := 0 to FNotifyList.Count-1 do
  begin
    P := FNotifyList[Counter];

    if (TMethod(P^).Code = TMethod(Proc).Code) and
       (TMethod(P^).Data = TMethod(Proc).Data) then
      Exit;
  end;

  FNotifyList.Expand;
  New(P);
  P^ := Proc;
  FNotifyList.Add(P);
end;

procedure TTBBaseSkin.UnregisterChanges (Proc: TNotifyEvent);
var
  P: PNotifyEvent;
  Counter: Integer;
begin
  if FNotifyList = nil then
    Exit;

  for Counter := 0 to FNotifyList.Count-1 do
  begin
    P := FNotifyList[Counter];

    if (TMethod(P^).Code = TMethod(Proc).Code) and
       (TMethod(P^).Data = TMethod(Proc).Data) then
    begin
      FNotifyList.Delete(Counter);
      Dispose(P);
      Break;
    end;
  end;
end;

procedure TTBBaseSkin.CalculateColorSet;
begin
  case FTBColorSet of
    tbcOfficeXP: OfficeXPColorSet;
    tbcWindowsXP: WindowsXPColorSet;
  end;
end;

procedure TTBBaseSkin.SetTBSkin(const Value: TTBSkins);
begin
  if FTBSkin <> Value then
  begin
     FTBSkin := Value;

    if (Value = tbsNativeXP) and (not IsWindowsXP or not IsThemeActive) then
      FTBSkin := tbsWindowsXP;

{    if Value <> tbsNativeXP then
      FTBSkin := Value
    else
    if (IsWindowsXP and IsThemeActive) = False then
      FTBSkin := tbsWindowsXP
    else
      FTBSkin := Value;}

    tbChevronSize := 12;

    case FTBSkin of
      tbsOfficeXP: begin
                     Options := Options + [tboBlendedImages, tboShadow] - [tboPopupOverlap];
                     ShadowStyle := sOfficeXP;
                     tbChevronSize := 11;

                     if FTBColorSet <> tbcCustom then
                     begin
                       ColorSet := tbcOfficeXP;
                       CalculateColorSet;
                     end;
                   end;
      tbsNativeXP,
      tbsWindowsXP: begin
                      Options := Options + [tboShadow, tboPopupOverlap] - [tboBlendedImages];
                      ShadowStyle := sWindowsXP;

                      if FTBColorSet <> tbcCustom then
                      begin
                        ColorSet := tbcWindowsXP;
                        CalculateColorSet;
                      end;
                    end;
    end;

    if (DefaultSkin <> nil) and IsDefaultSkin then
      DefaultSkin.SetTBSkin(Value);

    RepaintRegisteredClasses;
  end;
end;

procedure TTBBaseSkin.SetTBColorSet(const Value: TTBColorSets);
begin
  if (FTBSkin <> tbsDisabled) and (FTBColorSet <> Value) then
  begin
    FTBColorSet := Value;

    if FTBColorSet <> tbcCustom then
      CalculateColorSet;

    if FIsDefault and (DefaultSkin <> nil) then
      DefaultSkin.SetTBColorSet(Value);

    RepaintRegisteredClasses;
  end;
end;

function TTBBaseSkin.RGBColor(const AColor: TTBSkinColor): TColorRef;
begin
  with FTBColors do
  case AColor of
    cFace : Result := rgbFace;
    cPopup : Result := rgbPopup;
    cBorder : Result := rgbBorder;
    cToolbar : Result := rgbToolbar;
    cImageList : Result := rgbImageList;
    cDragHandle : Result := rgbDragHandle;
    cChecked: Result := rgbChecked;
    cCheckedOver : Result := rgbCheckedOver;
    cDockBorderIn : Result := rgbDockBorderIn;
    cDockBorderOut : Result := rgbDockBorderOut;
    cDockBorderTitle: Result := rgbDockBorderTitle;
    cSelBar : Result := rgbSelBar;
    cSelBarBorder : Result := rgbSelBarBorder;
    cSelItem : Result := rgbSelItem;
    cSelItemBorder : Result := rgbSelItemBorder;
    cSelPushed : Result := rgbSelPushed;
    cSelPushedBorder : Result := rgbSelPushedBorder;
    cSeparator: Result := rgbSeparator;
    cImgListShadow: Result := rgbImgListShadow;
    cGradStart: Result := rgbGradStart;
    cGradEnd: Result := rgbGradend;
    cPopupGradStart: Result := rgbPopupGradStart;
    cPopupGradEnd: Result := rgbPopupGradend;
    cImgGradStart: Result := rgbImgGradStart;
    cImgGradEnd: Result := rgbImgGradend;
    cText: Result := rgbText;
    cHighlightText: Result := rgbHighlightText;
    cCaptionText: Result := rgbCaptionText;
    else Result := ColorToRGB(clWhite);
  end;
end;

procedure TTBBaseSkin.AssignColorsToRGB;
var
  DC: HDC;
begin
  DC := GetDC(0);

  with FTBColors do
  begin
    rgbFace := GetNearestColor(DC, ColorToRGB(FFace));
    rgbPopup := GetNearestColor(DC, ColorToRGB(FPopup));
    rgbBorder := GetNearestColor(DC, ColorToRGB(FBorder));
    rgbToolbar := GetNearestColor(DC, ColorToRGB(FToolbar));
    rgbImageList := GetNearestColor(DC, ColorToRGB(FImageList));
    rgbDragHandle := GetNearestColor(DC, ColorToRGB(FDragHandle));
    rgbChecked := GetNearestColor(DC, ColorToRGB(FChecked));
    rgbCheckedOver := GetNearestColor(DC, ColorToRGB(FCheckedOver));
    rgbDockBorderIn := GetNearestColor(DC, ColorToRGB(FDockBorderIn));
    rgbDockBorderOut := GetNearestColor(DC, ColorToRGB(FDockBorderOut));
    rgbDockBorderTitle := GetNearestColor(DC, ColorToRGB(FDockBorderTitle));
    rgbSelBar := GetNearestColor(DC, ColorToRGB(FSelBar));
    rgbSelBarBorder := GetNearestColor(DC, ColorToRGB(FSelBarBorder));
    rgbSelItem := GetNearestColor(DC, ColorToRGB(FSelItem));
    rgbSelItemBorder := GetNearestColor(DC, ColorToRGB(FSelItemBorder));
    rgbSelPushed := GetNearestColor(DC, ColorToRGB(FSelPushed));
    rgbSelPushedBorder := GetNearestColor(DC, ColorToRGB(FSelPushedBorder));
    rgbSeparator := GetNearestColor(DC, ColorToRGB(FSeparator));
    rgbImgListShadow := GetNearestColor(DC, ColorToRGB(FImgListShadow));
    rgbGradStart := GetNearestColor(DC, ColorToRGB(FGradStart));
    rgbGradEnd := GetNearestColor(DC, ColorToRGB(FGradEnd));
    rgbPopupGradStart := GetNearestColor(DC, ColorToRGB(FPopupGradStart));
    rgbPopupGradEnd := GetNearestColor(DC, ColorToRGB(FPopupGradEnd));
    rgbImgGradStart := GetNearestColor(DC, ColorToRGB(FImgGradStart));
    rgbImgGradEnd := GetNearestColor(DC, ColorToRGB(FImgGradEnd));
    rgbText := GetNearestColor(DC, ColorToRGB(FText));
    rgbHighlightText := GetNearestColor(DC, ColorToRGB(FHighlightText));
    rgbCaptionText := GetNearestColor(DC, ColorToRGB(FCaptionText));
  end;

  ReleaseDC(0, DC);
end;

procedure TTBBaseSkin.SetDefault(const Value: Boolean);
begin
  if FIsDefault <> Value then
  begin
    FIsDefault := Value;

    if Value then
      TBSkinManager.SetSkinAsDefault(Self)
    else
      TBSkinManager.SetSkinAsDefault(Nil);

    RepaintRegisteredClasses;
  end;
end;

procedure TTBBaseSkin.Assign(Source: TPersistent);
begin
  with FTBColors do
  begin
    tcFace := TTBBaseSkin(Source).FTBColors.tcFace;
    tcPopup := TTBBaseSkin(Source).FTBColors.tcPopup;
    tcBorder := TTBBaseSkin(Source).FTBColors.tcBorder;
    tcDragHandle := TTBBaseSkin(Source).FTBColors.tcDragHandle;
    tcChecked := TTBBaseSkin(Source).FTBColors.tcChecked;
    tcCheckedOver := TTBBaseSkin(Source).FTBColors.tcCheckedOver;
    tcDockBorderIn := TTBBaseSkin(Source).FTBColors.tcDockBorderIn;
    tcDockBorderOut := TTBBaseSkin(Source).FTBColors.tcDockBorderOut;
    tcDockBorderTitle := TTBBaseSkin(Source).FTBColors.tcDockBorderTitle;
    tcSelBar := TTBBaseSkin(Source).FTBColors.tcSelBar;
    tcSelBarBorder := TTBBaseSkin(Source).FTBColors.tcSelBarBorder;
    tcSelItem := TTBBaseSkin(Source).FTBColors.tcSelItem;
    tcSelItemBorder := TTBBaseSkin(Source).FTBColors.tcSelItemBorder;
    tcSelPushed := TTBBaseSkin(Source).FTBColors.tcSelPushed;
    tcSelPushedBorder := TTBBaseSkin(Source).FTBColors.tcSelPushedBorder;
    tcImageList := TTBBaseSkin(Source).FTBColors.tcImageList;
    tcImgListShadow := TTBBaseSkin(Source).FTBColors.tcImgListShadow;

    ColorSet := TTBBaseSkin(Source).ColorSet;
    Gradient := TTBBaseSkin(Source).Gradient;
    Options := TTBBaseSkin(Source).Options;
    ShadowStyle := TTBBaseSkin(Source).ShadowStyle;
    SkinType := TTBBaseSkin(Source).SkinType;
    Tag := TTBBaseSkin(Source).Tag;
  end;
end;

function TTBBaseSkin.RegisterDockable(ADockable: TObject): Integer;
var
  Counter: Integer;
begin
  Counter := FDockables.IndexOf(ADockable);

  if Counter = -1 then
    Result := FDockables.Add(ADockable)
  else
    Result := Counter;
end;

function TTBBaseSkin.UnregisterDockable(ADockable: TObject): Boolean;
var
  Counter: Integer;
begin
  if FDockables = nil then
  begin
    Result := True;
    Exit;
  end;

  Counter := FDockables.IndexOf(ADockable);

  if Counter <> -1 then
  begin
    FDockables.Delete(Counter);
    Result := True
  end
  else
    Result := False;
end;

procedure TTBBaseSkin.RepaintRegisteredClasses;
var
  Counter: Integer;
begin
  for Counter := 0 to FDockables.Count - 1 do
  if TTBCustomDockableWindow(FDockables[Counter]).HandleAllocated and
     TTBCustomDockableWindow(FDockables[Counter]).Showing then
  if TTBCustomDockableWindow(FDockables[Counter]).Docked then
    SetWindowPos(TTBCustomDockableWindow(FDockables[Counter]).Handle,
      0, 0, 0, 0, 0, SWP_FRAMECHANGED or SWP_NOACTIVATE or SWP_NOMOVE or
      SWP_NOZORDER)
  else
  with TTBCustomDockableWindow(FDockables[Counter]) do
  begin
    TTBCustomDockableWindow(FDockables[Counter]).Perform(WM_SETREDRAW, 0, 0);
    SetBounds(Left, Top, Width, Height -1);
    SetBounds(Left, Top, Width, Height +1);
    TTBCustomDockableWindow(FDockables[Counter]).Perform(WM_SETREDRAW, 1, 0);

    if (TTBCustomDockableWindow(FDockables[Counter]) is TTBToolWindow) = False then
      SetWindowPos(TTBCustomDockableWindow(FDockables[Counter]).Handle, 0, 0,
        0, 0, 0, SWP_FRAMECHANGED or SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOZORDER);
  end;
end;

procedure TTBBaseSkin.SetOptions(const Value: TTBOptions);
begin
  if FTBOptions <> Value then
  begin
    FTBOptions := Value;

    if FIsDefault and (DefaultSkin <> nil) then
      DefaultSkin.SetOptions(Value);

    RepaintRegisteredClasses;
  end;
end;

procedure TTBBaseSkin.SetGradSel(const Value: TTBGradDir);
begin
  if FTBGradSel <> Value then
  begin
    FTBGradSel := Value;

    if FIsDefault and (DefaultSkin <> nil) then
      DefaultSkin.SetGradSel(Value);
  end;
end;

procedure TTBBaseSkin.SetPopupStyle(const Value: TTBPopupStyle);
begin
  if FPopupStyle <> Value then
  begin
    FPopupStyle := Value;

    if FIsDefault and (DefaultSkin <> nil) then
      DefaultSkin.SetPopupStyle(Value);
  end;
end;

procedure TTBBaseSkin.SetImgBackStyle(const Value: TTBImgBackStyle);
begin
  if FImgBackStyle <> Value then
  begin
    FImgBackStyle := Value;

    if FIsDefault and (DefaultSkin <> nil) then
      DefaultSkin.SetImgBackStyle(Value);
  end;
end;

procedure TTBBaseSkin.SetShadowStyle(const Value: TShadowStyle);
begin
  if FShadowStyle <> Value then
  begin
    FShadowStyle := Value;

    if FIsDefault and (DefaultSkin <> nil) then
      DefaultSkin.SetShadowStyle(Value);
  end;
end;

procedure TTBBaseSkin.SetCaptionFont(const Value: TFont);
begin
  if FCaptionFont <> Value then
  begin
    FCaptionFont.Assign(Value);
    SetParentFont(False);

    if FIsDefault and (DefaultSkin <> nil) then
    begin
      DefaultSkin.SetCaptionFont(Value);
      DefaultSkin.SetParentFont(False);
    end;

    RepaintRegisteredClasses;
  end;
end;

procedure TTBBaseSkin.SetParentFont(const Value: Boolean);
begin
  if FParentFont <> Value then
  begin
    FParentFont := Value;

    if Value = True then
      FCaptionFont.Assign(FParentTFont);

    if FIsDefault and (DefaultSkin <> nil) then
    begin
      DefaultSkin.SetParentFont(Value);
      DefaultSkin.SetCaptionFont(FParentTFont);
    end;

    RepaintRegisteredClasses;
  end;
end;

function TTBBaseSkin.GetPopupNCSize: Integer;
begin
  if (FTBSkin = tbsDisabled) or (FTBSkin = tbsNativeXP) then
    Result := 3
  else
  if (FTBSkin = tbsWindowsXP) then
    if (FPopupStyle <> tbpsDefault) or (FImgBackStyle <> tbimsDefault) then
      Result := 1
    else
      Result := 3
  else
    Result := 2;
end;

function TTBBaseSkin.IsFontStored: Boolean;
begin
   Result := not ParentFont;
end;

function TTBBaseSkin.GetComponentVersion;
begin
  Result := TBSkinVersion;
end;

// TTBSkin //

constructor TTBSkin.Create(AOwner: TComponent);
begin
  inherited;

  TBSkinManager.AddSkin(Self);
end;

destructor TTBSkin.Destroy;
begin
  SkinType := tbsDisabled;
  Destroying;

  inherited;

  if Assigned(TBSkinManager) then
    TBSkinManager.RemoveSkin(Self);
end;

// TShadow //

constructor TShadow.Create(const AOwner: TComponent; const ARight: Boolean;
  const APopup: Boolean);
begin
  inherited Create(AOwner);

  FPopup := APopup;
  FRight := ARight;

  { Use Application.Handle if possible so that the taskbar button for
    the app doesn't pop up when a TTBEditItem on a popup menu is focused.
    When Application.Handle is zero, use GetDesktopWindow() as the parent
    window, not zero, otherwise UpdateControlState won't show the window }

  if Application.Handle <> 0 then
    ParentWindow := Application.Handle
  else
    ParentWindow := GetDesktopWindow;

  Corner1 := False;
  Corner2 := False;

  FClipStart  := -1;
  FClipFinish := 0;

  Hide;
end;

procedure TShadow.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);

  with Params do
  begin
    Style := (Style and not (WS_CHILD or WS_GROUP or WS_TABSTOP)) or WS_POPUP;
    ExStyle := ExStyle or WS_EX_TOPMOST or WS_EX_TOOLWINDOW;

    WindowClass.Style := WindowClass.Style or CS_SAVEBITS or
      (not (CS_HREDRAW) and (CS_VREDRAW));
  end;
end;

destructor TShadow.Destroy;
begin
  if FPrepared then
   UnPrepare;

  inherited Destroy;
end;

procedure TShadow.WMNCPaint(var Message: TMessage);
begin
  Message.Result := 0;
end;

procedure TShadow.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  BitBlt(Message.DC, 0, 0, Width, Height, MemDC, 0, 0, SRCCOPY);

  Message.Result := 0;
end;

procedure TShadow.WMNCHitTest(var Message: TMessage);
begin
  Message.Result := HTTransparent;
end;

function CanPaintShadow(const Point, Start, Finish: Integer): Boolean;
begin
  if (Start >0) and (Finish >0) and (Point >= Start) and
     (Point <= Finish) then
    Result := False
  else
    Result := True;
end;

procedure TShadow.OfficeXPShadow(const DC: HDC);
var
  X, Y: Integer;
begin
  if FRight then
  for X := 0 to Width - 1 do
  begin
    //Draw Fade Out At Top Edge Shadow
    if Corner1 then
    for Y := Width to (Width * 2) - 1 do
      if CanPaintShadow(Y, FClipStart, FClipFinish) then
        SetPixel(MemDC, X, Y, ColorDarkerRGB(GetPixel(MemDC, X, Y), (ShadowContrast - 20) - ((X + ((Width * 2) - 1 - Y)) * 5)));

    //Draw The Main Shadow...
    for Y := (Width * 2) to Height - 1 - (Width - 4) do
      if CanPaintShadow(Y, FClipStart, FClipFinish) then
        SetPixel(MemDC, X, Y, ColorDarkerRGB(GetPixel(MemDC, X, Y), ShadowContrast - (X * 15)));
  end
  else
  for Y := 0 to Height - 1 do
  begin
    //Draw Fade In At Left Edge Shadow
    if Corner1 then
    for X := 0 to Height - 1 do
      if CanPaintShadow(X, FClipStart, FClipFinish) then
        SetPixel(MemDC, X, Y, ColorDarkerRGB(GetPixel(MemDC, X, Y), 60 - ((Y + ((Height * 2) - 1 - X)) * 5)));

    //Draw The Main Shadow...
    for X := (Height) to Width - 1 - (Height) do
      if CanPaintShadow(X, FClipStart, FClipFinish) then
        SetPixel(MemDC, X, Y, ColorDarkerRGB(GetPixel(MemDC, X, Y), ShadowContrast - (Y * 15)));

    //Draw Fade Out At Right Edge Shadow
    if Corner2 then
    for X := 0 to Height -1 do
      if CanPaintShadow(X, Width + FClipStart, Width + FClipFinish) then
        SetPixel(MemDC, Width-1-(X), Y, ColorDarkerRGB(GetPixel(MemDC, Width-1-(X), Y), ((X + ((Height * 2) - 1 - Y)) * 5)-15 ));
  end;
end;

procedure TShadow.WindowsXPShadow(const DC: HDC);
Const
 ShadowMask: array[0..15] of Double =
   (0.1,   0.031, 0,     0,
    0.175, 0.1,   0.031, 0,
    0.245, 0.175, 0.1,   0.01,
    0.315, 0.245, 0.175, 0.031);
var
  X, Y: Integer;
  ColorToUse: TColor;
begin
  ColorToUse := TColor(RGB(30,30,30));

  if FRight then
  for X := 0 to Width - 1 do
  begin
    for Y := Width to (Width * 2) - 1 do
      SetPixel(MemDC, X, Y, BlendColors(GetPixel(MemDC, X, Y), ColorToUse,
        ShadowMask[x + ((y-4) * Width)]));

    if Corner1 then
    for Y := (Width * 2) to Height - 1 - (Width - 4) do
      SetPixel(MemDC, X, Y, BlendColors(GetPixel(MemDC, X, Y), ColorToUse, (50 - (X * 15))/100));
  end
  else
  for Y := 0 to Height - 1 do
  begin
    // Draw fade in at left edge shadow
    if Corner1 then
    for X := 0 to Height - 1 do
      SetPixel(MemDC, X, Y, BlendColors(GetPixel(MemDC, X, Y), ColorToUse, (60 - ((Y + ((Height * 2) - 1 - X)) * 7.1))/100));

    // draw the main shadow...
    for X := (Height) to Width - 1 - (Height) do
      SetPixel(MemDC, X, Y, BlendColors(GetPixel(MemDC, X, Y), ColorToUse, ( 50 - (Y * 15))/100));

    // Draw fade out at right edge shadow (ah Note: I think it should be a straight shadow like _|)
    if Corner2 then
    for X := 0 to Height -1 do
      if (X = 3) and (Y = 0) then
        SetPixel(MemDC, Width-1-(X), Y, BlendColors(GetPixel(MemDC, Width-1-(X), Y), ColorToUse, (50 - (0 * 15))/100))
      else
      if (X = 3) and (Y = 1) then
        SetPixel(MemDC, Width-1-(X), Y, BlendColors(GetPixel(MemDC, Width-1-(X), Y), ColorToUse, ( 50 - (1 * 15))/100))
      else
      if (X = 2) and (Y < 2) then
        SetPixel(MemDC, Width-1-(X), Y, BlendColors(GetPixel(MemDC, Width-1-(X), Y), ColorToUse, ( 50 - (1 * 15))/100))
      Else
      if (X > 1) and (Y = 2) then
        SetPixel(MemDC, Width-1-(X), Y, BlendColors(GetPixel(MemDC, Width-1-(X), Y), ColorToUse, ( 50 - (2 * 15))/100))
      Else
      if (X = 1) and (Y < 3) then
        SetPixel(MemDC, Width-1-(X), Y, BlendColors(GetPixel(MemDC, Width-1-(X), Y), ColorToUse, ( 50 - (2 * 15))/100))
      Else
      if (X > 0) and (Y = 3) then
        SetPixel(MemDC, Width-1-(X), Y, BlendColors(GetPixel(MemDC, Width-1-(X), Y), ColorToUse, ( 50 - (3 * 15))/100))
      Else
      if (X = 0) and (Y < 4) then
        SetPixel(MemDC, Width-1-(X), Y, BlendColors(GetPixel(MemDC, Width-1-(X), Y), ColorToUse, ( 50 - (3 * 15))/100))
  end;
end;

procedure TShadow.Prepare;
var
  DC: HDC;
begin
  if FPrepared then
   Exit;

  MemDC := GetDC(0);
  MemBitmap := CreateCompatibleBitmap(MemDC, Width, Height);
  ReleaseDC(0, MemDC);

  MemDC := CreateCompatibleDC(0);
  SelectObject(MemDC, MemBitmap);

  ProcessPaintMessages;

  DC := GetDC(0);
  BitBlt(MemDC, 0, 0, Width, Height, DC,
         Left, Top, SRCCOPY);
  ReleaseDC(0, DC);

  if ShadowStyle = sOfficeXP then
    OfficeXPShadow(DC)
  else
    WindowsXPShadow(DC);

  FPrepared := True;
end;

procedure TShadow.UnPrepare;
begin
  if FPrepared then
  begin
    DeleteDC(MemDC);
    DeleteObject(MemBitmap);
  end;
end;

initialization
  DefaultSkin := TTBBaseSkin.Create(nil);
  DefaultSkin.FTBSkin := tbsDisabled;
  DefaultSkin.Options := [];

  TBSkinManager := TTBSkinManager.Create;

  InitializeThemeSupport;
Finalization
  TBSkinManager.Free;
  TBSkinManager := nil;

  DefaultSkin.Free;
  DefaultSkin := nil;

  FinilizeThemeSupport;
end.
