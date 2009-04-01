{***************************************************}
{                                                   }
{  Flat ComboBox, FontComboBox v1.0                 }
{  For Delphi 2,3,4,5.                              }
{  Freeware.                                        }
{                                                   }
{  Copyright (c) 1999 by:                           }
{    Dmitry Statilko (dima_misc@hotbox.ru)          }
{    - Main idea and realisation of Flat ComboBox   }
{      inherited from TCustomComboBox               }
{                                                   }
{    Vladislav Necheporenko (andy@ukr.net)          }
{    - Help in bug fixes                            }
{    - Adaptation to work on Delphi 2               }
{    - MRU list in FontComboBox that stored values  }
{      in regitry                                   }
{    - Font preview box in FontComboBox             }
{                                                   }
{***************************************************}

unit FR_Combo;

interface
{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, CommCtrl, ExtCtrls, Registry;

type
  TfrCustomComboBox = class(TCustomComboBox)
  private
    FUpDropdown: Boolean;
    FButtonWidth: Integer;
    msMouseInControl: Boolean;
    FListHandle: HWND;
    FListInstance: Pointer;
    FDefListProc: Pointer;
    FChildHandle: HWND;
    FSolidBorder: Boolean;
    FReadOnly: Boolean;
    FEditOffset: Integer;
    procedure ListWndProc(var Message: TMessage);
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
    procedure CMEnabledChanged(var Msg: TMessage); message CM_ENABLEDCHANGED;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure PaintButtonGlyph(DC: HDC; x: Integer; y: Integer);
    procedure PaintButton(bnStyle: Integer);
    procedure PaintBorder(DC: HDC; const SolidBorder: Boolean);
    procedure PaintDisabled;
    function GetSolidBorder: Boolean;
    function GetListHeight: Integer;
    procedure SetReadOnly(Value: Boolean);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure ComboWndProc(var Message: TMessage; ComboWnd: HWnd; ComboProc: Pointer); override;
    procedure WndProc(var Message: TMessage); override;
    procedure CreateWnd; override;
    property SolidBorder: Boolean read FSolidBorder;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default False;
    procedure DrawImage(DC: HDC; Index: Integer; R: TRect); dynamic;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

{ TfrComboBox }
  TfrComboBox = class(TfrCustomComboBox)
  published
    property Color;
    property DragMode;
    property DragCursor;
    property DropDownCount;
    property Enabled;
    property Font;
    property ItemHeight;
    property Items;
    property MaxLength;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Sorted;
    property TabOrder;
    property TabStop;
    property Text;
    property ReadOnly;
    property Visible;
    property ItemIndex;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawItem;
    property OnDropDown;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnStartDrag;
{$IFDEF Delphi4}
    property Anchors;
    property BiDiMode;
    property Constraints;
    property DragKind;
    property ParentBiDiMode;
    property OnEndDock;
    property OnStartDock;
{$ENDIF}
  end;

  TfrFontPreview = class(TWinControl)
  private
    FPanel: TPanel;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

{ TFontComboBox }
  TfrFontComboBox = class(TfrCustomComboBox)
  private
    frFontViewForm: TfrFontPreview;
    FRegKey: String;
    FTrueTypeBMP: TBitmap;
    FOnClick: TNotifyEvent;
    FUpdate: Boolean;
    FShowMRU: Boolean;
    Numused: Integer;
    procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMFontChange(var Message: TMessage); message CM_FONTCHANGE;
    procedure SetRegKey(Value: String);
  protected
    procedure Loaded; override;
    procedure Init;
    procedure Reset;
    procedure PopulateList; virtual;
    procedure Click; override;
    procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
    procedure DrawImage(DC: HDC; Index: Integer; R: TRect); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property ShowMRU: Boolean read FShowMRU write FShowMRU default True;
    property MRURegKey: String read FRegKey write SetRegKey;
    property Text;
    property Color;
    property DragMode;
    property DragCursor;
    property DropDownCount;
    property Enabled;
    property Font;
{$IFDEF Delphi4}
    property Anchors;
    property BiDiMode;
    property Constraints;
    property DragKind;
    property ParentBiDiMode;
{$ENDIF}
    property ItemHeight;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnChange;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDropDown;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnStartDrag;
{$IFDEF Delphi4}
    property OnEndDock;
    property OnStartDock;
{$ENDIF}
  end;

implementation
{$R *.RES}
{$IFDEF Delphi6}
{$WARN SYMBOL_DEPRECATED OFF}
{$ENDIF}

uses Printers;

//--- Additional functions -----------------------------------------------------
function Min(val1, val2: Word): Word;
begin
  Result := val1;
  if val1 > val2 then
    Result := val2;
end;

function GetFontMetrics(Font: TFont): TTextMetric;
var
  DC: HDC;
  SaveFont: HFont;
begin
  DC := GetDC(0);
  SaveFont := SelectObject(DC, Font.Handle);
  GetTextMetrics(DC, Result);
  SelectObject(DC, SaveFont);
  ReleaseDC(0, DC);
end;

function GetFontHeight(Font: TFont): Integer;
begin
  Result := GetFontMetrics(Font).tmHeight;
end;

//--- TfrCustomComboBox ---------------------------------------------------------
constructor TfrCustomComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csReplicatable];
  FListInstance := MakeObjectInstance(ListWndProc);
  FDefListProc := nil;
  FButtonWidth := 11;
  ItemHeight := GetFontHeight(Font);
  Width := 100;
  FEditOffset := 0;
end;

destructor TfrCustomComboBox.Destroy;
begin
  inherited Destroy;
  FreeObjectInstance(FListInstance);
end;

procedure TfrCustomComboBox.SetReadOnly(Value: Boolean);
begin
  if FReadOnly <> Value then
  begin
    FReadOnly := Value;
    if HandleAllocated then
      SendMessage(EditHandle, EM_SETREADONLY, Ord(Value), 0);
  end;
end;

procedure TfrCustomComboBox.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
    Style := (Style and not CBS_DROPDOWNLIST) or CBS_OWNERDRAWFIXED or CBS_DROPDOWN;
end;

procedure TfrCustomComboBox.CreateWnd;
var
  exStyle: Integer;
begin
  inherited;
  SendMessage(EditHandle, EM_SETREADONLY, Ord(FReadOnly), 0);
  // Desiding, which of the handles is DropDown list handle...
  if FChildHandle <> EditHandle then
    FListHandle := FChildHandle;
  //.. and superclassing it
  FDefListProc := Pointer(GetWindowLong(FListHandle, GWL_WNDPROC));
  SetWindowLong(FListHandle, GWL_WNDPROC, Longint(FListInstance));
  // here we setting up the border's edge
  exStyle := GetWindowLong(FListHandle, GWL_EXSTYLE);
  SetWindowLong(FListHandle, GWL_EXSTYLE, exStyle or WS_EX_CLIENTEDGE);
  exStyle := GetWindowLong(FListHandle, GWL_STYLE);
  SetWindowLong(FListHandle, GWL_STYLE, exStyle and not WS_BORDER );
end;


procedure TfrCustomComboBox.ListWndProc(var Message: TMessage);
var
  p: TPoint;

  procedure CallDefaultProc;
  begin
    with Message do
      Result := CallWindowProc(FDefListProc, FListHandle, Msg, WParam, LParam);
  end;

  procedure PaintListFrame;
  var
    DC: HDC;
    R: TRect;
  begin
    GetWindowRect(FListHandle, R);
    OffsetRect (R, -R.Left, -R.Top);
    DC := GetWindowDC(FListHandle);
    DrawEdge(DC, R, EDGE_RAISED, BF_RECT);
    ReleaseDC(FListHandle, DC);
  end;

begin
  case Message.Msg of
    WM_NCPAINT:
      begin
        CallDefaultProc;
        PaintListFrame;
      end;
    LB_SETTOPINDEX:
      begin
        if ItemIndex > DropDownCount then
          CallDefaultProc;
      end;
    WM_WINDOWPOSCHANGING:
      with TWMWindowPosMsg(Message).WindowPos^ do
      begin
        // calculating the size of the drop down list
        cx := Width - 1;
        cy := GetListHeight;
        p.x := cx;
        p.y := cy + GetFontHeight(Font) + 6;
        p := ClientToScreen(p);
        FUpDropdown := False;
        if p.y > Screen.Height then //if DropDownList showing below
          begin
            y := y - 2;
            FUpDropdown := True;
          end;
      end;
    else
      CallDefaultProc;
  end;
end;

procedure TfrCustomComboBox.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_SETTEXT:
      Invalidate;
     WM_PARENTNOTIFY:
       if LoWord(Message.wParam)=WM_CREATE then begin
         if FDefListProc <> nil then
           begin
             // This check is necessary to be sure that combo is created, not
             // RECREATED (somehow CM_RECREATEWND does not work)
             SetWindowLong(FListHandle, GWL_WNDPROC, Longint(FDefListProc));
             FDefListProc := nil;
             FChildHandle := Message.lParam;
           end
          else
           begin
             // WM_Create is the only event I found where I can get the ListBox handle.
             // The fact that combo box usually creates more then 1 handle complicates the
             // things, so I have to have the FChildHandle to resolve it later (in CreateWnd).
             if FChildHandle = 0 then
               FChildHandle := Message.lParam
             else
               FListHandle := Message.lParam;
           end;
       end;
    WM_WINDOWPOSCHANGING:
      MoveWindow(EditHandle, 3+FEditOffset, 3, Width-FButtonWidth-7-FEditOffset,
        Height-6, True);
  end;
  inherited;
end;

procedure TfrCustomComboBox.WMPaint(var Message: TWMPaint);
var
  PS, PSE: TPaintStruct;
begin
  BeginPaint(Handle,PS);
  try
    if Enabled then
    begin
      DrawImage(PS.HDC, ItemIndex ,Rect(3, 3, FEditOffset + 3, Height - 3));
      if GetSolidBorder then
      begin
        PaintBorder(PS.HDC, True);
        if DroppedDown then
          PaintButton(2)
        else
          PaintButton(1);
      end else
      begin
        PaintBorder(PS.HDC, False);
        PaintButton(0);
      end;
    end else
    begin
      BeginPaint(EditHandle, PSE);
      try
        PaintDisabled;
      finally
        EndPaint(EditHandle, PSE);
      end;
    end;
  finally
    EndPaint(Handle,PS);
  end;
  Message.Result := 0;
end;

procedure TfrCustomComboBox.DrawImage(DC: HDC; Index: Integer; R: TRect);
begin
  if FEditOffset > 0 then
   FillRect(DC, R, GetSysColorBrush(COLOR_WINDOW));
end;

procedure TfrCustomComboBox.ComboWndProc(var Message: TMessage; ComboWnd: HWnd;
  ComboProc: Pointer);
var
  DC: HDC;
begin
  inherited;
  if (ComboWnd = EditHandle) then
    case Message.Msg of
      WM_SETFOCUS:
        begin
          DC:=GetWindowDC(Handle);
          PaintBorder(DC,True);
          PaintButton(1);
          ReleaseDC(Handle,DC);
        end;
      WM_KILLFOCUS:
        begin
          DC:=GetWindowDC(Handle);
          PaintBorder(DC,False);
          PaintButton(0);
          ReleaseDC(Handle,DC);
        end;
    end;
end;

procedure TfrCustomComboBox.CNCommand(var Message: TWMCommand);
begin
  inherited;
  if (Message.NotifyCode in [CBN_CLOSEUP]) then
    PaintButton(1);
end;

procedure TfrCustomComboBox.PaintBorder(DC: HDC; const SolidBorder: Boolean);
var
  R: TRect;
  BtnFaceBrush, WindowBrush: HBRUSH;
begin
  BtnFaceBrush := GetSysColorBrush(COLOR_BTNFACE);
  WindowBrush := GetSysColorBrush(COLOR_WINDOW);
  GetWindowRect(Handle, R);
  OffsetRect (R, -R.Left, -R.Top);
  InflateRect(R,-1,-1);
  FrameRect (DC, R, BtnFaceBrush);
  InflateRect(R,-1,-1);
  R.Right:=R.Right - FButtonWidth - 1;
  FrameRect (DC, R, WindowBrush);
  if SolidBorder then
  begin
    GetWindowRect(Handle, R);
    OffsetRect (R, -R.Left, -R.Top);
    DrawEdge (DC, R, BDR_SUNKENOUTER, BF_RECT);
  end else
  begin
    GetWindowRect(Handle, R);
    OffsetRect (R, -R.Left, -R.Top);
    FrameRect (DC, R, BtnFaceBrush);
  end;
end;

procedure TfrCustomComboBox.PaintButtonGlyph(DC: HDC; x: Integer; y: Integer);
var
  Pen, SavePen: HPEN;
begin
  Pen := CreatePen(PS_SOLID, 1, ColorToRGB(clBlack));
  SavePen := SelectObject(DC, Pen);
  MoveToEx(DC, x, y, nil);
  LineTo(DC, x + 5, y);
  MoveToEx(DC, x + 1, y + 1, nil);
  LineTo(DC, x + 4, y + 1);
  MoveToEx(DC, x + 2, y + 2, nil);
  LineTo(DC, x + 3, y + 2);
  SelectObject(DC, SavePen);
  DeleteObject(Pen);
end;


procedure TfrCustomComboBox.PaintButton(bnStyle: Integer);
var
  R: TRect;
  DC: HDC;
  Brush, SaveBrush: HBRUSH;
  X, Y: Integer;
  Pen, SavePen: HPEN;
  WindowBrush: HBRUSH;
begin
  WindowBrush := GetSysColorBrush(COLOR_WINDOW);
  DC := GetWindowDC(Handle);
  SetRect(R, Width - FButtonWidth - 2, 2, Width -2, Height - 2);
  Brush := CreateSolidBrush(GetSysColor(COLOR_BTNFACE));
  SaveBrush := SelectObject(DC, Brush);
  FillRect(DC, R, Brush);
  SelectObject(DC, SaveBrush);
  DeleteObject(Brush);
  X := Trunc(FButtonWidth / 2) + Width - FButtonWidth - 4;
  Y := Trunc((Height - 4) / 2) + 1;
  if bnStyle = 0 then //No 3D border
  begin
    FrameRect (DC, R, WindowBrush);
    GetWindowRect(Handle, R);
    OffsetRect (R, -R.Left, -R.Top);
    InflateRect(R, -FButtonWidth - 3, -2);
    Pen := CreatePen(PS_SOLID, 1, ColorToRGB(clWindow));
    SavePen := SelectObject(DC, Pen);
    MoveToEx(DC,R.Right, R.Top, nil);
    LineTo(DC, R.Right, R.Bottom);
    SelectObject(DC, SavePen);
    DeleteObject(Pen);
    PaintButtonGlyph(DC, X, Y);
  end;
  if bnStyle = 1 then //3D up border
  begin
    DrawEdge (DC, R, BDR_RAISEDINNER, BF_RECT);
    GetWindowRect(Handle, R);
    OffsetRect (R, -R.Left, -R.Top);
    InflateRect(R, -FButtonWidth - 3, -1);
    Pen := CreatePen(PS_SOLID, 1, ColorToRGB(clBtnFace));
    SavePen := SelectObject(DC, Pen);
    MoveToEx(DC, R.Right, R.Top, nil);
    LineTo(DC, R.Right, R.Bottom);
    SelectObject(DC, SavePen);
    DeleteObject(Pen);
    PaintButtonGlyph(DC, X, Y);
  end;
  if bnStyle = 2 then //3D down border
  begin
    DrawEdge (DC, R, BDR_SUNKENOUTER, BF_RECT);
    GetWindowRect(Handle, R);
    OffsetRect (R, -R.Left, -R.Top);
    InflateRect(R, -FButtonWidth - 3, -1);
    Pen := CreatePen(PS_SOLID, 1, ColorToRGB(clBtnFace));
    SavePen := SelectObject(DC, Pen);
    MoveToEx(DC, R.Right, R.Top, nil);
    LineTo(DC, R.Right, R.Bottom);
    SelectObject(DC, SavePen);
    DeleteObject(Pen);
    PaintButtonGlyph(DC, X + 1, Y + 1);
  end;
  ReleaseDC(Handle, DC);
end;

procedure TfrCustomComboBox.PaintDisabled;
var
  R: TRect;
  Brush, SaveBrush: HBRUSH;
  DC: HDC;
  WindowBrush: HBRUSH;
begin
  WindowBrush := GetSysColorBrush(COLOR_WINDOW);
  DC := GetWindowDC(Handle);
  Brush := CreateSolidBrush(GetSysColor(COLOR_BTNFACE));
  SaveBrush := SelectObject(DC, Brush);
  FillRect(DC, ClientRect, Brush);
  SelectObject(DC, SaveBrush);
  DeleteObject(Brush);
  R := ClientRect;
  InflateRect(R, -2, -2);
  FrameRect (DC, R, WindowBrush);
  PaintButtonGlyph(DC, Trunc(FButtonWidth / 2) + Width - FButtonWidth - 4,
    Trunc((Height - 4) / 2) + 1);
  ReleaseDC(Handle,DC);
end;

procedure TfrCustomComboBox.CMEnabledChanged(var Msg: TMessage);
begin
  inherited;
  Invalidate;
end;

procedure TfrCustomComboBox.CMMouseEnter(var Message: TMessage);
var
  DC: HDC;
begin
  inherited;
  msMouseInControl := True;
  if Enabled and not (GetFocus = EditHandle) and not DroppedDown then
  begin
    DC:=GetWindowDC(Handle);
    PaintBorder(DC, True);
    PaintButton(1);
    ReleaseDC(Handle, DC);
  end;
end;

procedure TfrCustomComboBox.CMMouseLeave(var Message: TMessage);
var
  DC: HDC;
begin
  inherited;
  msMouseInControl := False;
  if Enabled  and not (GetFocus = EditHandle) and not DroppedDown then
  begin
    DC:=GetWindowDC(Handle);
    PaintBorder(DC, False);
    PaintButton(0);
    ReleaseDC(Handle, DC);
  end;
end;

function TfrCustomComboBox.GetSolidBorder: Boolean;
begin
  Result := ((csDesigning in ComponentState)) or
    (DroppedDown or (GetFocus = EditHandle) or msMouseInControl);
end;

function TfrCustomComboBox.GetListHeight: Integer;
begin
  Result := ItemHeight * Min(DropDownCount, Items.Count) + 4;
  if (DropDownCount <= 0) or (Items.Count = 0) then
    Result := ItemHeight + 4;
end;

procedure TfrCustomComboBox.CMFontChanged(var Message: TMessage);
begin
  inherited;
  ItemHeight := GetFontHeight(Font);
  RecreateWnd;
end;

//--- TfrFontComboBox -----------------------------------------------------------
function CreateBitmap(ResName: PChar): TBitmap;
begin
   Result := TBitmap.Create;
   Result.Handle := LoadBitmap(HInstance, ResName);
   if Result.Handle = 0 then
   begin
     Result.Free;
     Result := nil;
   end;
end;

function EnumFontsProc(var LogFont: TLogFont; var TextMetric: TTextMetric;
  FontType: Integer; Data: Pointer): Integer; stdcall;
begin
  if (TStrings(Data).IndexOf(LogFont.lfFaceName) < 0) then
    TStrings(Data).AddObject(LogFont.lfFaceName, TObject(FontType));
  Result := 1;
end;

constructor TfrFontComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  if not (csDesigning in ComponentState) then
    frFontViewForm := TfrFontPreview.Create(Self);
  FTrueTypeBMP := CreateBitmap('FTRUETYPE_FNT');
  DropDownCount := 12;
  Width := 150;
  FEditOffset := 16;
  FReadOnly := True;
  FShowMRU := True;
  Numused := -1;
  FRegKey := '\Software\FastReport\MRUFont';
end;

destructor TfrFontComboBox.Destroy;
begin
  FTrueTypeBMP.Free;
  if not (csDesigning in ComponentState) then
    frFontViewForm.Destroy;
  inherited Destroy;
end;

procedure TfrFontComboBox.Loaded;
begin
  inherited Loaded;
  if csDesigning in ComponentState then exit;
  FUpdate := True;
  try
    PopulateList;
    if Items.IndexOf(Text) = -1 then
      ItemIndex:=0;
  finally
    FUpdate := False;
  end;
end;

procedure TfrFontComboBox.SetRegKey(Value: String);
begin
  if Value = '' then
    FRegKey := '\Software\FastReport\MRUFont' else
    FRegKey := Value;
end;

procedure TfrFontComboBox.PopulateList;
var
  LFont: TLogFont;
  DC: HDC;
  Reg: TRegistry;
  s: String;
  i: Integer;
  str: TStringList;
begin
  Sorted:=True;
  Items.BeginUpdate;
  str := TStringList.Create;
  str.Sorted := True;
  try
    Clear;
    DC := GetDC(0);
    try
      FillChar(LFont, sizeof(LFont), 0);
      LFont.lfCharset := DEFAULT_CHARSET;
      EnumFontFamiliesEx(DC, LFont, @EnumFontsProc, LongInt(str), 0);
    finally
      ReleaseDC(0, DC);
    end;
    if Printer.Printers.Count > 0 then
    try
      FillChar(LFont, sizeof(LFont), 0);
      LFont.lfCharset := DEFAULT_CHARSET;
      EnumFontFamiliesEx(Printer.Handle, LFont, @EnumFontsProc, LongInt(str), 0);
    except;
    end;
  finally
    Items.Assign(str);
    Items.EndUpdate;
  end;
  str.Free;
  Sorted := False;
  if FShowMRU then
  begin
    Items.BeginUpdate;
    Reg:=TRegistry.Create;
    try
      Reg.OpenKey(FRegKey, True);
      for i := 4 downto 0 do
      begin
        s := Reg.ReadString('Font' + IntToStr(i));
        if (s <> '') and (Items.IndexOf(s) <> -1) then
        begin
          Items.InsertObject(0, s, TObject(Reg.ReadInteger('FontType' + IntToStr(i))));
          Inc(Numused);
        end else
        begin
          Reg.WriteString('Font' + IntToStr(i), '');
          Reg.WriteInteger('FontType' + IntToStr(i), 0);
        end;
      end;
    finally
      Reg.Free;
      Items.EndUpdate;
    end;
  end;
end;

procedure TfrFontComboBox.DrawImage(DC: HDC; Index: Integer; R: TRect);
var
  C: TCanvas;
  Bitmap: TBitmap;
begin
  inherited;
  Index := Items.IndexOf(Text);
  if Index = -1 then exit;
  C := TCanvas.Create;
  C.Handle := DC;
  if (Integer(Items.Objects[Index]) and TRUETYPE_FONTTYPE) <> 0 then
    Bitmap := FTrueTypeBMP
  else  Bitmap := nil;
  if Bitmap <> nil then
  begin
    C.Brush.Color := clWindow;
    C.BrushCopy(Bounds(R.Left, (R.Top + R.Bottom - Bitmap.Height)
     div 2, Bitmap.Width, Bitmap.Height), Bitmap, Bounds(0, 0, Bitmap.Width,
     Bitmap.Height), Bitmap.TransparentColor);
  end;
  C.Free;
end;


procedure TfrFontComboBox.DrawItem(Index: Integer; Rect: TRect;
  State: TOwnerDrawState);
var
  Bitmap: TBitmap;
  BmpWidth: Integer;
  Text: array[0..255] of Char;
begin
 if odSelected in State then
 begin
   frFontViewForm.FPanel.Caption:=self.Items[index];
   frFontViewForm.FPanel.Font.Name:=self.Items[index];
 end;
 with Canvas do
 begin
   BmpWidth  := 15;
   FillRect(Rect);
   if (Integer(Items.Objects[Index]) and TRUETYPE_FONTTYPE) <> 0 then
     Bitmap := FTrueTypeBMP
   else Bitmap := nil;
   if Bitmap <> nil then
   begin
     BmpWidth := Bitmap.Width;
     BrushCopy(Bounds(Rect.Left+1 , (Rect.Top + Rect.Bottom - Bitmap.Height)
       div 2, Bitmap.Width, Bitmap.Height), Bitmap, Bounds(0, 0, Bitmap.Width,
       Bitmap.Height), Bitmap.TransparentColor);
   end;
   StrPCopy(Text, Items[Index]);
   Rect.Left := Rect.Left + BmpWidth + 2;
   DrawText(Canvas.Handle, Text, StrLen(Text), Rect,
{$IFDEF Delphi4}
   DrawTextBiDiModeFlags(DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX));
{$ELSE}
   DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX);
{$ENDIF}
   if (Index = Numused) then
   begin
     Pen.Color := clBtnShadow;
     MoveTo(0,Rect.Bottom - 2);
     LineTo(width, Rect.Bottom - 2);
   end;
   if (Index = Numused + 1) and (Numused <> -1) then
   begin
     Pen.Color := clBtnShadow;
     MoveTo(0, Rect.Top);
     LineTo(width, Rect.Top);
   end;
 end;
end;

procedure TfrFontComboBox.CMFontChanged(var Message: TMessage);
begin
  inherited;
  Init;
end;

procedure TfrFontComboBox.CMFontChange(var Message: TMessage);
begin
  inherited;
  Reset;
end;

procedure TfrFontComboBox.Init;
begin
  if GetFontHeight(Font) > FTrueTypeBMP.Height then
    ItemHeight := GetFontHeight(Font)
  else
    ItemHeight := FTrueTypeBMP.Height + 1;
  RecreateWnd;
end;

procedure TfrFontComboBox.Click;
begin
 inherited Click;
 if not (csReading in ComponentState) then
   if not FUpdate and Assigned(FOnClick) then FOnClick(Self);
end;

procedure TfrFontComboBox.Reset;
begin
  if csDesigning in ComponentState then exit;
  FUpdate := True;
  try
    PopulateList;
    if Items.IndexOf(Text) = -1 then
      ItemIndex := 0;
  finally
    FUpdate := False;
  end;
end;

procedure TfrFontComboBox.CNCommand(var Message: TWMCommand);
var
  pnt:TPoint;
  ind,i:integer;
  Reg: TRegistry;
begin
  inherited;
  if (Message.NotifyCode in [CBN_CLOSEUP]) then
  begin
    frFontViewForm.Visible := False;
    ind := itemindex;
    if (ItemIndex = -1) or (ItemIndex = 0) then exit;
    if FShowMRU then
    begin
      Items.BeginUpdate;
      if Items.IndexOf(Items[ind]) <= Numused then
      begin
        Items.Move(Items.IndexOf(Items[ind]), 0);
        ItemIndex := 0;
      end else
      begin
        Items.InsertObject(0, Items[ItemIndex], Items.Objects[ItemIndex]);
        Itemindex := 0;
        if Numused < 4 then
          Inc(Numused)
        else
          Items.Delete(5);
      end;
      Items.EndUpdate;
      Reg := TRegistry.Create;
      try
        Reg.OpenKey(FRegKey,True);
        for i := 0 to 4 do
          if i <= Numused then
          begin
           Reg.WriteString('Font' + IntToStr(i), Items[i]);
           Reg.WriteInteger('FontType' + IntToStr(i), Integer(Items.Objects[i]));
         end else
         begin
           Reg.WriteString('Font' + IntToStr(i), '');
           Reg.WriteInteger('FontType' + IntToStr(i), 0);
         end;
       finally
         Reg.Free;
       end;
    end;
  end;
  if (Message.NotifyCode in [CBN_DROPDOWN]) then
  begin
    if ItemIndex < 5 then
      PostMessage(FListHandle, LB_SETCURSEL, 0, 0);
    pnt.x := (Self.Left ) + Self.width;
    pnt.y := (Self.Top ) + Self.height;
    pnt := Parent.ClientToScreen(pnt);
    frFontViewForm.Top := pnt.y;
    frFontViewForm.Left := pnt.x;

    if frFontViewForm.Left+frFontViewForm.Width > Screen.Width then
    begin
      pnt.x := (Self.Left );
      pnt := Parent.ClientToScreen(pnt);
      frFontViewForm.Left := pnt.x - frFontViewForm.Width - 1;
    end;
    if FUpDropdown then
    begin
      pnt.y := (Self.Top );
      pnt := Parent.ClientToScreen(pnt);
      frFontViewForm.Top := pnt.y - frFontViewForm.Height;
    end;
    frFontViewForm.Visible := True;
  end;
end;

//--- TfrFontPreview ------------------------------------------------------------
constructor TfrFontPreview.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 200;
  Height := 50;
  Visible := False;
  Parent := AOwner as TWinControl;

  FPanel := TPanel.Create(Self);
  with FPanel do
  begin
    Parent := Self;
    Color := clWindow;
    Ctl3D := False;
    ParentCtl3D := False;
    BorderStyle := bsSingle;
    BevelInner := bvNone;
    BevelOuter := bvNone;
    Font.Color := clWindowText;
    Font.Size := 18;
    Align := alClient;
  end;
end;

destructor TfrFontPreview.Destroy;
begin
  FPanel.Free;
  FPanel := nil;
  inherited Destroy;
end;

procedure TfrFontPreview.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams( Params);
    with Params do begin
      Style := WS_POPUP or WS_CLIPCHILDREN;
      ExStyle := WS_EX_TOOLWINDOW;
      WindowClass.Style := WindowClass.Style or CS_SAVEBITS;
    end;
end;

end.
