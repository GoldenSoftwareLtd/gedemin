unit xpDBGrid;

interface

uses
  SysUtils, Classes, Controls, Grids, DBGrids, Types, Windows, Messages,
  Graphics, Math, Db, Forms;

type
  TxpCustomDBGrid = class(TCustomDBGrid)
  protected
    {$IFNDEF PACK}
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;
    {$ENDIF}
  public
  published
  end;

  TxpDBGrid = class(TxpCustomDBGrid)
  public
    property Canvas;
    property SelectedRows;
  published
    property Align;
    property Anchors;
    property BiDiMode;
    property BorderStyle;
    property Color;
    property Columns stored False; //StoreColumns;
    property Constraints;
    property Ctl3D;
    property DataSource;
    property DefaultDrawing;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property FixedColor;
    property Font;
    property ImeMode;
    property ImeName;
    property Options;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property TitleFont;
    property Visible;
    property OnCellClick;
    property OnColEnter;
    property OnColExit;
    property OnColumnMoved;
    property OnDrawDataCell;  { obsolete }
    property OnDrawColumnCell;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEditButtonClick;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
    property OnTitleClick;
  end;

procedure Register;

implementation
//{$R xpDBGrids.res}
{const
  bmArrow = 'XPDBGARROW';
  bmEdit = 'XPDBEDIT';
  bmInsert = 'XPDBINSERT';
  bmMultiDot = 'XPDBMULTIDOT';
  bmMultiArrow = 'XPDBMULTIARROW';}

procedure Register;
begin
  RegisterComponents('XP Data Control', [TxpDBGrid]);
end;

{$IFNDEF PACK}
var
  DrawBitmap: TBitmap;
  UserCount: Integer;

procedure UsesBitmap;
begin
  if UserCount = 0 then
    DrawBitmap := TBitmap.Create;
  Inc(UserCount);
end;

procedure ReleaseBitmap;
begin
  Dec(UserCount);
  if UserCount = 0 then DrawBitmap.Free;
end;

procedure WriteText(ACanvas: TCanvas; ARect: TRect; DX, DY: Integer;
  const Text: string; Alignment: TAlignment; ARightToLeft: Boolean);
const
  AlignFlags : array [TAlignment] of Integer =
    ( DT_LEFT or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX,
      DT_RIGHT or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX,
      DT_CENTER or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX );
  RTL: array [Boolean] of Integer = (0, DT_RTLREADING);
var
  B, R: TRect;
  Hold, Left: Integer;
  I: TColorRef;
begin
  I := ColorToRGB(ACanvas.Brush.Color);
  if GetNearestColor(ACanvas.Handle, I) = I then
  begin                       { Use ExtTextOut for solid colors }
    { In BiDi, because we changed the window origin, the text that does not
      change alignment, actually gets its alignment changed. }
    if (ACanvas.CanvasOrientation = coRightToLeft) and (not ARightToLeft) then
      ChangeBiDiModeAlignment(Alignment);
    case Alignment of
      taLeftJustify:
        Left := ARect.Left + DX;
      taRightJustify:
        Left := ARect.Right - ACanvas.TextWidth(Text) - 3;
    else { taCenter }
      Left := ARect.Left + (ARect.Right - ARect.Left) shr 1
        - (ACanvas.TextWidth(Text) shr 1);
    end;
    ACanvas.TextRect(ARect, Left, ARect.Top + DY, Text);
  end
  else begin                  { Use FillRect and Drawtext for dithered colors }
    DrawBitmap.Canvas.Lock;
    try
      with DrawBitmap, ARect do { Use offscreen bitmap to eliminate flicker and }
      begin                     { brush origin tics in painting / scrolling.    }
        Width := Max(Width, Right - Left);
        Height := Max(Height, Bottom - Top);
        R := Rect(DX, DY, Right - Left - 1, Bottom - Top - 1);
        B := Rect(0, 0, Right - Left, Bottom - Top);
      end;
      with DrawBitmap.Canvas do
      begin
        Font := ACanvas.Font;
        Font.Color := ACanvas.Font.Color;
        Brush := ACanvas.Brush;
        Brush.Style := bsSolid;
        FillRect(B);
        SetBkMode(Handle, TRANSPARENT);
        if (ACanvas.CanvasOrientation = coRightToLeft) then
          ChangeBiDiModeAlignment(Alignment);
        DrawText(Handle, PChar(Text), Length(Text), R,
          AlignFlags[Alignment] or RTL[ARightToLeft]);
      end;
      if (ACanvas.CanvasOrientation = coRightToLeft) then
      begin
        Hold := ARect.Left;
        ARect.Left := ARect.Right;
        ARect.Right := Hold;
      end;
      ACanvas.CopyRect(ARect, DrawBitmap.Canvas, B);
    finally
      DrawBitmap.Canvas.Unlock;
    end;
  end;
end;


{ TxpCustomDBGrid }

procedure TxpCustomDBGrid.DrawCell(ACol, ARow: Integer; ARect: TRect;
  AState: TGridDrawState);
var
  FrameOffs: Byte;

  function RowIsMultiSelected: Boolean;
  var
    Index: Integer;
  begin
    Result := (dgMultiSelect in Options) and Datalink.Active and
      SelectedRows.Find(Datalink.Datasource.Dataset.Bookmark, Index);
  end;

  procedure DrawTitleCell(ACol, ARow: Integer; Column: TColumn; var AState: TGridDrawState);
  const
    ScrollArrows: array [Boolean, Boolean] of Integer =
      ((DFCS_SCROLLRIGHT, DFCS_SCROLLLEFT), (DFCS_SCROLLLEFT, DFCS_SCROLLRIGHT));
  var
    MasterCol: TColumn;
    TitleRect, TextRect, ButtonRect: TRect;
    I: Integer;
    InBiDiMode: Boolean;
  begin
    TitleRect := CalcTitleRect(Column, ARow, MasterCol);

    if MasterCol = nil then
    begin
      Canvas.FillRect(ARect);
      Exit;
    end;

    Canvas.Font := MasterCol.Title.Font;
    Canvas.Brush.Color := MasterCol.Title.Color;
    if [dgRowLines, dgColLines] * Options = [dgRowLines, dgColLines] then
    begin
      TitleRect.Left := TitleRect.Left + 1;
      TitleRect.Top := TitleRect.Top + 1;
//      InflateRect(TitleRect, -1, -1);
    end;
    TextRect := TitleRect;
    I := GetSystemMetrics(SM_CXHSCROLL);
    if ((TextRect.Right - TextRect.Left) > I) and MasterCol.Expandable then
    begin
      Dec(TextRect.Right, I);
      ButtonRect := TitleRect;
      ButtonRect.Left := TextRect.Right;
      I := SaveDC(Canvas.Handle);
      try
        Canvas.FillRect(ButtonRect);
        InflateRect(ButtonRect, -1, -1);
        IntersectClipRect(Canvas.Handle, ButtonRect.Left,
          ButtonRect.Top, ButtonRect.Right, ButtonRect.Bottom);
        InflateRect(ButtonRect, 1, 1);
        { DrawFrameControl doesn't draw properly when orienatation has changed.
          It draws as ExtTextOut does. }
        InBiDiMode := Canvas.CanvasOrientation = coRightToLeft;
        if InBiDiMode then { stretch the arrows box }
          Inc(ButtonRect.Right, GetSystemMetrics(SM_CXHSCROLL) + 4);
        DrawFrameControl(Canvas.Handle, ButtonRect, DFC_SCROLL,
          ScrollArrows[InBiDiMode, MasterCol.Expanded] or DFCS_FLAT);
      finally
        RestoreDC(Canvas.Handle, I);
      end;
    end;
    with MasterCol.Title do
      WriteText(Canvas, TextRect, FrameOffs, FrameOffs, Caption, Alignment,
        IsRightToLeft);
    if [dgRowLines, dgColLines] * Options = [dgRowLines, dgColLines] then
    begin
      InflateRect(TitleRect, 1, 1);
      DrawEdge(Canvas.Handle, TitleRect, BDR_RAISEDINNER, BF_BOTTOMRIGHT);
      DrawEdge(Canvas.Handle, TitleRect, BDR_RAISEDINNER, BF_TOPLEFT);
    end;
    AState := AState - [gdFixed];  // prevent box drawing later
  end;

var
  OldActive: Integer;
  Indicator: Integer;
  Highlight: Boolean;
  Value: string;
  DrawColumn: TColumn;
  MultiSelected: Boolean;
  ALeft: Integer;
begin
  if csLoading in ComponentState then
  begin
    Canvas.Brush.Color := Color;
    Canvas.FillRect(ARect);
    Exit;
  end;

  Dec(ARow, FTitleOffset);
  Dec(ACol, FIndicatorOffset);

  if (gdFixed in AState) and ([dgRowLines, dgColLines] * Options =
    [dgRowLines, dgColLines]) then
  begin
    ARect.Left := Arect.Left + 1;
    ARect.Top := ARect.Top + 1;
//    InflateRect(ARect, -1, -1);
    FrameOffs := 1;
  end
  else
    FrameOffs := 2;

  if (gdFixed in AState) and (ACol < 0) then
  begin
    Canvas.Brush.Color := FixedColor;
    Canvas.FillRect(ARect);
    if Assigned(DataLink) and DataLink.Active  then
    begin
      MultiSelected := False;
      if ARow >= 0 then
      begin
        OldActive := DataLink.ActiveRecord;
        try
          Datalink.ActiveRecord := ARow;
          MultiSelected := RowIsMultiselected;
        finally
          Datalink.ActiveRecord := OldActive;
        end;
      end;
      if (ARow = DataLink.ActiveRecord) or MultiSelected then
      begin
        Indicator := 0;
        if DataLink.DataSet <> nil then
          case DataLink.DataSet.State of
            dsEdit: Indicator := 1;
            dsInsert: Indicator := 2;
            dsBrowse:
              if MultiSelected then
                if (ARow <> Datalink.ActiveRecord) then
                  Indicator := 3
                else
                  Indicator := 4;  // multiselected and current row
          end;
        FIndicators.BkColor := FixedColor;
        ALeft := ARect.Right - FIndicators.Width - FrameOffs;
        if Canvas.CanvasOrientation = coRightToLeft then Inc(ALeft);
        FIndicators.Draw(Canvas, ALeft,
          (ARect.Top + ARect.Bottom - FIndicators.Height) shr 1, Indicator, True);
        if ARow = Datalink.ActiveRecord then
          FSelRow := ARow + FTitleOffset;
      end;
    end;
  end
  else with Canvas do
  begin
    DrawColumn := Columns[ACol];
    if not DrawColumn.Showing then Exit;
    if not (gdFixed in AState) then
    begin
      Font := DrawColumn.Font;
      Brush.Color := DrawColumn.Color;
    end;
    if ARow < 0 then
      DrawTitleCell(ACol, ARow + FTitleOffset, DrawColumn, AState)
    else if (DataLink = nil) or not DataLink.Active then
      FillRect(ARect)
    else
    begin
      Value := '';
      OldActive := DataLink.ActiveRecord;
      try
        DataLink.ActiveRecord := ARow;
        if Assigned(DrawColumn.Field) then
          Value := DrawColumn.Field.DisplayText;
        Highlight := HighlightCell(ACol, ARow, Value, AState);
        if Highlight then
        begin
          Brush.Color := clHighlight;
          Font.Color := clHighlightText;
        end;
        if not Enabled then
          Font.Color := clGrayText;
        if DefaultDrawing then
          WriteText(Canvas, ARect, 2, 2, Value, DrawColumn.Alignment,
            UseRightToLeftAlignmentForField(DrawColumn.Field, DrawColumn.Alignment));
        if Columns.State = csDefault then
          DrawDataCell(ARect, DrawColumn.Field, AState);
        DrawColumnCell(ARect, ACol, DrawColumn, AState);
      finally
        DataLink.ActiveRecord := OldActive;
      end;
      if DefaultDrawing and (gdSelected in AState)
        and ((dgAlwaysShowSelection in Options) or Focused)
        and not (csDesigning in ComponentState)
        and not (dgRowSelect in Options)
        and (UpdateLock = 0)
        and (ValidParentForm(Self).ActiveControl = Self) then
        Windows.DrawFocusRect(Handle, ARect);
    end;
  end;
  if (gdFixed in AState) and ([dgRowLines, dgColLines] * Options =
    [dgRowLines, dgColLines]) then
  begin
    InflateRect(ARect, 1, 1);
    DrawEdge(Canvas.Handle, ARect, BDR_RAISEDINNER, BF_BOTTOMRIGHT);
    DrawEdge(Canvas.Handle, ARect, BDR_RAISEDINNER, BF_TOPLEFT);
  end;
end;
{$ENDIF}

end.
