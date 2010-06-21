
{******************************************}
{                                          }
{     FastReport v2.5 - Data storage       }
{              Form editor                 }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FRD_Form;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DBCtrls, Db, ExtCtrls, FR_Ctrls, ComCtrls
{$IFDEF RX}
  , Mask, ToolEdit
{$ENDIF};

type
  TfrParamsDialogForm = class(TForm)
    Panel1: TPanel;
    Gr4B: TfrSpeedButton;
    Bevel2: TBevel;
    Gr8B: TfrSpeedButton;
    GrAlignB: TfrSpeedButton;
    CloseB: TfrSpeedButton;
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure Gr4BClick(Sender: TObject);
    procedure CloseBClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    b: TButton;
    procedure PlaceControls;
    procedure GetControlsInfo;
    procedure ComboBoxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
  public
    { Public declarations }
    Designing: Boolean;
  end;

  TfrDesignLabel = class(TLabel)
  public
    procedure WndProc(var Message: TMessage); override;
  end;

  TfrDesignEdit = class(TEdit)
  public
    procedure WndProc(var Message: TMessage); override;
  end;

  TfrDesignLookup = class(TDBLookupComboBox)
  public
    procedure WndProc(var Message: TMessage); override;
  end;

  TfrDesignCombo = class(TComboBox)
  public
    procedure WndProc(var Message: TMessage); override;
    procedure ComboWndProc(var Message: TMessage; ComboWnd: HWnd;
      ComboProc: Pointer); override;
  end;

{$UNDEF UseDateEdit}
{$IFDEF RX}
  {$DEFINE UseDateEdit}
{$ELSE}
  {$IFNDEF Delphi2}
    {$DEFINE UseDateEdit}
  {$ENDIF}
{$ENDIF}

{$IFDEF UseDateEdit}
{$IFDEF RX}
  TfrDesignDateEdit = class(TDateEdit)
{$ELSE}
  TfrDesignDateEdit = class(TDateTimePicker)
{$ENDIF}
  public
    procedure WndProc(var Message: TMessage); override;
  end;
{$ENDIF}

var
  frParamsDialogForm: TfrParamsDialogForm;
  ParamFormWidth, ParamFormHeight: Integer;
  SelList: TList;


implementation

uses FR_Class, FRD_Mngr, FRD_Prop, FR_Const, FR_Utils;

{$R *.DFM}

type
  THackControl = class(TControl)
  end;

  TPaintPanel = class(TPanel)
  private
    Down,DClick: Boolean;
    LastX,LastY: Integer;
    procedure DrawSelection(t:TControl);
    procedure ClearSelection;
    procedure MMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure MDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MDblClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
  end;


var
  CT: (ctNone, ct1, ct2, ct3, ct4);  // current mouse cursor (sizing arrows)
  OldRect: TRect;
  PaintPanel: TPaintPanel;
  IsDesigning: Boolean;


function CaptureWndProc(c: TControl; var Message: TMessage): Boolean;
begin
  Result := True;
  if IsDesigning then
    if (Message.Msg >= WM_MOUSEFIRST) and (Message.Msg <= WM_MOUSELAST) then
    begin
      with Message do
      begin
        LParam := (LParam div 65536 + c.Top) * 65536 + LParam mod 65536 + c.Left;
        PaintPanel.Dispatch(Message);
      end;
      Result := False;
    end;
end;

procedure TfrDesignLabel.WndProc(var Message: TMessage);
begin
  if CaptureWndProc(Self, Message) then
    inherited;
end;

procedure TfrDesignEdit.WndProc(var Message: TMessage);
begin
  if CaptureWndProc(Self, Message) then
    inherited;
end;

procedure TfrDesignLookup.WndProc(var Message: TMessage);
begin
  if CaptureWndProc(Self, Message) then
    inherited;
end;

procedure TfrDesignCombo.WndProc(var Message: TMessage);
begin
  if CaptureWndProc(Self, Message) then
    inherited;
end;

procedure TfrDesignCombo.ComboWndProc(var Message: TMessage; ComboWnd: HWnd;
  ComboProc: Pointer);
begin
  if CaptureWndProc(Self, Message) then
    inherited;
end;

{$IFDEF UseDateEdit}
procedure TfrDesignDateEdit.WndProc(var Message: TMessage);
begin
  if CaptureWndProc(Self, Message) then
    inherited;
end;
{$ENDIF}

{-----------------------------------------------------------------------------}
constructor TPaintPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Parent := AOwner as TWinControl;
  Top := 40;
  Align := alClient;
  BevelInner := bvNone;
  BevelOuter := bvNone;
  OnMouseDown := MDown;
  OnMouseMove := MMove;
  OnMouseUp := MUp;
  OnDblClick := MDblClick;
end;

procedure TPaintPanel.DrawSelection(t: TControl);
var
  px,py: Word;

  procedure DrawPoint(x, y: Word);
  begin
    Canvas.MoveTo(x, y);
    Canvas.LineTo(x, y);
  end;

begin
  if t = nil then Exit;
  with t,Canvas do
  begin
    Pen.Width := 5;
    Pen.Color := clBlack;
    px := Left + Width div 2;
    py := Top + Height div 2;
    DrawPoint(Left - 2, Top - 2); DrawPoint(Left + Width + 2, Top - 2);
    DrawPoint(Left - 2, Top + Height + 2); DrawPoint(Left + Width + 2, Top + Height + 2);
    if SelList.Count = 1 then
    begin
      DrawPoint(px, Top - 2); DrawPoint(px, Top + Height + 2);
      DrawPoint(Left - 2, py); DrawPoint(Left + Width + 2, py);
    end;
    Pen.Mode := pmCopy;
  end;
end;

procedure TPaintPanel.ClearSelection;
var
  i: Integer;
  r: TRect;
begin
  for i := 0 to SelList.Count - 1 do
  begin
    r := TControl(SelList[i]).BoundsRect;
    Dec(r.Left, 10); Dec(r.Top, 10);
    Inc(r.Right, 10); Inc(r.Bottom, 10);
    InvalidateRect(Handle, @r, False);
  end;
end;

procedure TPaintPanel.Paint;
var
  i: Integer;
  Bmp: TBitmap;
begin
  inherited;
  if IsDesigning then
  begin
    Bmp := TBitmap.Create;
    Bmp.Width := 8; Bmp.Height := 8;
    with Bmp.Canvas do
    begin
      Brush.Color := clBtnFace;
      FillRect(Rect(0, 0, 8, 8));
      Pixels[0, 0] := clBlack;
      if frParamsDialogForm.Gr4B.Down then
      begin
        Pixels[0, 4] := clBlack;
        Pixels[4, 0] := clBlack;
        Pixels[4, 4] := clBlack;
      end;
    end;
    Canvas.Brush.Bitmap := Bmp;
    Canvas.FillRect(Rect(0, 0, Width, Height));
    if not Down then
      for i := 0 to SelList.Count - 1 do
        DrawSelection(TControl(SelList[i]));
    Bmp.Free;
  end;
end;

procedure TPaintPanel.MMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  i, kx, ky, w, Right, Bottom: Integer;

  function Cont(px, py, x, y: Integer): Boolean;
  begin
    Result := (x >= px - w) and (x <= px + w + 1) and
      (y >= py - w) and (y <= py + w + 1);
  end;

  function GridCheck: Boolean;
  var
    GridSize: Integer;
  begin
    GridSize := 4;
    if frParamsDialogForm.Gr8B.Down then
      GridSize := 8;
    Result := (kx >= GridSize) or (kx <= -GridSize) or
              (ky >= GridSize) or (ky <= -GridSize);
    if Result then
    begin
      kx := kx - kx mod GridSize;
      ky := ky - ky mod GridSize;
    end;
  end;

begin
  if not IsDesigning then Exit;
  w := 2;
  if not Down then
  begin
    if SelList.Count = 1 then
    with TControl(SelList[0]) do
    begin
      Right := Left + Width;
      Bottom := Top + Height;
      if Cont(Left - 2, Top - 2, x, y) or Cont(Right + 2, Bottom + 2, x, y) then
        Self.Cursor := crSizeNWSE
      else if Cont(Right + 2, Top - 2, x, y) or Cont(Left - 2, Bottom + 2, x, y) then
        Self.Cursor := crSizeNESW
      else if Cont(Left + Width div 2, Top - 2, x, y) or
        Cont(Left + Width div 2, Bottom + 2, x, y) then
        Self.Cursor := crSizeNS
      else if Cont(Left - 2, Top + Height div 2, x, y) or
        Cont(Right + 2, Top + Height div 2, x, y) then
        Self.Cursor := crSizeWE
      else
        Self.Cursor := crArrow;
    end
    else
      Cursor := crArrow;
  end;
  if Down and (Cursor = crArrow) and (SelList.Count > 0) then // moving
  begin
    kx := X - LastX;
    ky := Y - LastY;
    if frParamsDialogForm.GrAlignB.Down and not GridCheck then Exit;
    for i := 0 to SelList.Count-1 do
    with TControl(SelList[i]) do
    begin
      Left := Left + kx;
      Top := Top + ky;
    end;
    Inc(LastX, kx);
    Inc(LastY, ky);
    frDesigner.Modified := True;
    Exit;
  end;
  if Down and (SelList.Count = 0) then // focus rectangle
  begin
    Canvas.DrawFocusRect(OldRect);
    OldRect := Rect(OldRect.Left, OldRect.Top, x, y);
    Canvas.DrawFocusRect(OldRect);
    Exit;
  end;
  if Down and (Cursor <> crArrow) then // sizing
  with TControl(SelList[0]) do
  begin
    kx := x - LastX;
    ky := y - LastY;
    if frParamsDialogForm.GrAlignB.Down and not GridCheck then Exit;
    w := 3;
    if Self.Cursor = crSizeNWSE then
      if (CT = ct1) or Cont(Left - 2, Top - 2, LastX, LastY) then
      begin
        SetBounds(Left + kx, Top + ky, Width - kx, Height - ky);
        CT := ct1;
      end
      else
        SetBounds(Left, Top, Width + kx, Height + ky);
    if Self.Cursor = crSizeNESW then
      if (CT = ct2) or Cont(Left + Width + 2, Top - 2, LastX, LastY) then
      begin
        SetBounds(Left, Top + ky, Width + kx, Height - ky);
        CT := ct2;
      end
      else
        SetBounds(Left + kx, Top, Width - kx, Height + ky);
    if Self.Cursor = crSizeWE then
      if (CT = ct3) or Cont(Left - 2, Top + Height div 2, LastX, LastY) then
      begin
        SetBounds(Left + kx, Top, Width - kx, Height);
        CT := ct3;
      end
      else
        SetBounds(Left, Top, Width + kx, Height);
    if Self.Cursor = crSizeNS then
      if (CT = ct4) or Cont(Left + Width div 2, Top, LastX, LastY) then
      begin
        SetBounds(Left, Top + ky, Width, Height - ky);
        CT := ct4;
      end
      else
        SetBounds(Left, Top, Width, Height + ky);
    Inc(LastX, kx);
    Inc(LastY, ky);
    frDesigner.Modified := True;
  end;
end;

procedure TPaintPanel.MDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i, j: Integer;
  c, c1: TControl;
  f: Boolean;
begin
  if not IsDesigning then Exit;
  if DClick then
  begin
    DClick := False;
    exit;
  end;
  ClearSelection;
  if Cursor = crArrow then
  begin
    f := True; c1 := nil;
    for i := ControlCount - 1 downto 0 do
    begin
      c := Controls[i];
      if PtInRect(c.BoundsRect, Point(X, Y)) then
      begin
        c1 := c;
        for j := 0 to SelList.Count-1 do
          if SelList[j] = c then
          begin
            if ssShift in Shift then
              SelList.Delete(j);
            f := False;
            break;
          end;
        break;
      end;
    end;
    if f then
    begin
      if not (ssShift in Shift) or (c1 = nil) then SelList.Clear;
      if c1 <> nil then SelList.Add(c1);
    end;
  end;
  Down := True;
  LastX := X;
  LastY := Y;
  OldRect := Rect(X, Y, X, Y);
end;

procedure TPaintPanel.MUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
  c: TControl;
begin
  if not IsDesigning then Exit;
  Down := False;
  if SelList.Count = 0 then
  begin
    Canvas.DrawFocusRect(OldRect);
    for i := 0 to ControlCount - 1 do
    begin
      c := Controls[i];
      with OldRect do
      if not ((c.Left > Right) or (c.Left + c.Width < Left) or
              (c.Top > Bottom) or (c.Top + c.Height < Top)) then
        SelList.Add(c);
    end;
  end;
  for i := 0 to SelList.Count - 1 do
    DrawSelection(TControl(SelList[i]));
  CT := ctNone;
end;

procedure TPaintPanel.MDblClick(Sender: TObject);
var
  PropForm: TfrPropForm;
  i: Integer;
  b: Boolean;
  c, c1: TControl;
begin
  if not IsDesigning or (SelList.Count = 0) then Exit;
  Down := False;
  DClick := True;
  b := False;
  c1 := SelList[0];
  for i := 0 to SelList.Count-1 do
  begin
    c := SelList[i];
    if c.ClassName <> c1.ClassName then
      b := True;
  end;
  if b then Exit;
  PropForm := TfrPropForm.Create(nil);
  with PropForm do
  begin
    ShowModal;
    frDesigner.Modified := True;
    Free;
  end;
  Repaint;
end;

{-----------------------------------------------------------------------------}
procedure TfrParamsDialogForm.FormShow(Sender: TObject);
begin
  IsDesigning := Designing;
  Panel1.Visible := IsDesigning;
  PlaceControls;
end;

procedure TfrParamsDialogForm.FormHide(Sender: TObject);
begin
  SelList.Clear;
  if not IsDesigning then
    b.Free;
  GetControlsInfo;
end;

procedure TfrParamsDialogForm.FormResize(Sender: TObject);
begin
  Repaint;
end;

{$HINTS OFF}
procedure TfrParamsDialogForm.PlaceControls;
var
  i, n: Integer;
  p: PfrParamInfo;
  c: TControl;

  procedure FillProperties(c: THackControl; p: PfrControlInfo);
  begin
    c.Parent := PaintPanel;
    with p^, c do
    begin
      if TControl(c) is TLabel then
      begin
        TLabel(c).AutoSize := Bounds.Right = 0;
        TLabel(c).WordWrap := Bounds.Right <> 0;
      end;
      with Bounds do
        SetBounds(Left, Top, Right, Bottom);
      c.Caption := p.Caption;
      Font.Name := FontName;
      Font.Size := FontSize;
      Font.Style := frSetFontStyle(FontStyle);
{$IFNDEF Delphi2}
      Font.Charset := FontCharset;
{$ENDIF}
      Font.Color := FontColor;
      if IsDesigning then
        Cursor := crArrow;
    end;
  end;

begin
  for i := 0 to PaintPanel.ControlCount - 1 do
    PaintPanel.Controls[0].Free;
  ClientWidth := ParamFormWidth; ClientHeight := ParamFormHeight;
  for i := 0 to frParamList.Count - 1 do
  begin
    p := frParamList[i];
    c := TfrDesignLabel.Create(PaintPanel);
    FillProperties(THackControl(c), @p^.LabelControl);
    c.Tag := i;

    n := p^.QueryRef.frParams.ParamIndex(p^.ParamName);
    case p^.Typ of
      ptEdit:
{$IFDEF UseDateEdit}
        if p^.QueryRef.frParams.ParamType[n] in [ftDate, ftDateTime] then
          c := TfrDesignDateEdit.Create(PaintPanel) else
{$ENDIF}
          c := TfrDesignEdit.Create(PaintPanel);
      ptLookup: c := TfrDesignLookup.Create(PaintPanel);
      ptCombo: c := TfrDesignCombo.Create(PaintPanel);
    end;
    FillProperties(THackControl(c), @p^.EditControl);
    c.Tag := i;
    if p^.Typ = ptLookup then
      with c as TfrDesignLookup do
      begin
        ListSource := frFindComponent(nil, p^.LookupDS) as TDataSource;
        KeyField := p^.LookupKF;
        ListField := p^.LookupLF;
      end
    else if p^.Typ = ptCombo then
      with c as TfrDesignCombo do
      begin
        Style := csOwnerDrawFixed;
        OnDrawItem := ComboBoxDrawItem;
        Items.Assign(p^.ComboStrings);
      end;
  end;
  if not IsDesigning then
  begin
    b := TButton.Create(Self);
    b.Parent := PaintPanel;
    b.SetBounds((PaintPanel.Width - 75) div 2, PaintPanel.Height - 33, 75, 25);
    b.Caption := 'OK';
    b.ModalResult := mrOk;
    b.Default := True;
  end;
end;
{$HINTS ON}

{$WARNINGS OFF}
procedure TfrParamsDialogForm.GetControlsInfo;
var
  i: Integer;
  p: PfrParamInfo;
  p1: PfrControlInfo;
  c: TControl;
begin
  for i := 0 to PaintPanel.ControlCount - 1 do
  begin
    c := PaintPanel.Controls[i];
    p := frParamList[c.Tag];
    if c is TLabel then
      p1 := @p^.LabelControl
    else if (c is TEdit) or (c is TDBLookupComboBox)
{$IFDEF UseDateEdit}
{$IFDEF RX}
      or (c is TDateEdit)
{$ELSE}
      or (c is TDateTimePicker)
{$ENDIF}
{$ENDIF}
      or (c is TComboBox) then
      p1 := @p^.EditControl
    else
      continue;
    with p1^, THackControl(c) do
    begin
      Bounds := Rect(Left, Top, Width, Height);
      if c is TLabel then
        if TLabel(c).AutoSize then
          Bounds.Right := 0;
      p1.Caption := THackControl(c).Caption;
      FontName := Font.Name;
      FontSize := Font.Size;
      FontStyle := frGetFontStyle(Font.Style);
{$IFNDEF Delphi2}
      FontCharset := Font.Charset;
{$ENDIF}
      FontColor := Font.Color;
    end;
    p^.Typ := ptEdit;
    if c is TDBLookupComboBox then
      with p^, c as TDBLookupComboBox do
      begin
        Typ := ptLookup;
        LookupDS := '';
        if ListSource <> nil then
          LookupDS := ListSource.Owner.Name + '.' + ListSource.Name;
        LookupKF := KeyField;
        LookupLF := ListField;
        if not IsDesigning then
          p1^.Caption := ListSource.DataSet.FieldByName(KeyField).AsString;
      end
    else if c is TComboBox then
      with p^, c as TComboBox do
      begin
        Typ := ptCombo;
        ComboStrings.Assign((c as TComboBox).Items);
        if not IsDesigning then
          if Pos(';', p1^.Caption) <> 0 then
            p1^.Caption := Trim(Copy(p1^.Caption, Pos(';', p1^.Caption) + 1, 255));
      end;
  end;
  ParamFormWidth := ClientWidth; ParamFormHeight := ClientHeight;
end;
{$WARNINGS ON}

procedure TfrParamsDialogForm.Gr4BClick(Sender: TObject);
begin
  PaintPanel.Repaint;
end;

procedure TfrParamsDialogForm.CloseBClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfrParamsDialogForm.ComboBoxDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  ComboBox: TComboBox;
  s: String;
begin
  ComboBox := Control as TComboBox;
  with ComboBox.Canvas do
  begin
    FillRect(Rect);
    s := ComboBox.Items[Index];
    if Pos(';', s) <> 0 then
      s := Copy(s, 1, Pos(';', s) - 1);
    TextOut(Rect.Left + 2, Rect.Top + 1, s);
  end;
end;

procedure TfrParamsDialogForm.FormCreate(Sender: TObject);
begin
  Caption := frLoadStr(frRes + 3150);
  Gr4B.Hint := frLoadStr(frRes + 3151);
  Gr8B.Hint := frLoadStr(frRes + 3152);
  GrAlignB.Hint := frLoadStr(frRes + 3153);
  CloseB.Caption := frLoadStr(frRes + 3154);
end;

initialization
  frParamsDialogForm := TfrParamsDialogForm.Create(nil);
  PaintPanel := TPaintPanel.Create(frParamsDialogForm);
  SelList := TList.Create;

finalization
  PaintPanel.Free;
  frParamsDialogForm.Free;
  SelList.Free;

end.

