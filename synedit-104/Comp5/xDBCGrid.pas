
{++

  Copyright (c) 1996 by Golden Software of Belarus

  Module

    xDBCGrid.pas

  Abstract

    A Delphi visual component. This is a Data Base Grid with check boxes.

  Author

    Denis Romanovski (03-Fab-95)

  Revisions history
    1.00    22-Fab-95             Initial version.
    1.10    25-Apr-95             Add event for change combo
    1.11    22-Jul-96    mikle    Minor bug fixed.
    1.12    ????                  Change.
    2.00    11-Aug-98    dennis   Addapted under Delphi 4. Some bugs corrected.

--}

unit xDBCGrid;

interface

uses
  Windows, SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Grids, DB, DBCtrls, DBTables, DBGrids, ExtCtrls, mmDBGrid;

type
  TVertAlign = (alTop, alVCenter, alBottom);
  THorizAlign = (alLeft, alCenter, alRight);

  TOnChangeCheckBox = procedure(Sender: TObject; Value: Boolean) of Object;

const
  DefScale = FALSE;
  DefVertAlign = alVCenter;
  DefHorizAlign = alCenter;

type
  TxDBCheckGrid = class(TmmDBGrid)
  private
    FDataLink: TFieldDataLink;
    FCol: Integer;
    FCheckedGlyph, FUncheckedGlyph: TBitmap;
    FScale: Boolean;
    FVertAlign: TVertAlign;
    FHorizAlign: THorizAlign;
    FOnChangeCheckBox: TOnChangeCheckBox;

    function GetDataField: String;

    procedure SetDataField(AValue: String);
    procedure SetCheckedGlyph(AValue: TBitmap);
    procedure SetUncheckedGlyph(AValue: TBitmap);
    procedure SetScale(AValue: Boolean);
    procedure SetVertAlign(AValue: TVertAlign);
    procedure SetHorizAlign(AValue: THorizAlign);

    procedure LoadCheckBoxBitmap(var ABitmap: TBitmap; Checked: Boolean);
    procedure DrawField(R: TRect; ABitmap: TBitmap);

    procedure WMChar(var Message: TWMChar);
      message WM_CHAR;
    procedure WMKeyDown(var Message: TWMKeyDown);
      message WM_KEYDOWN;
    procedure WMKeyUp(var Message: TWMKeyUp);
      message WM_KEYUP;
  protected
    procedure Loaded; override;
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  published
    property DataField: String read GetDataField write SetDataField;
    property CheckedGlyph: TBitmap read FCheckedGlyph write SetCheckedGlyph;
    property UncheckedGlyph: TBitmap read FUncheckedGlyph write SetUncheckedGlyph;
    property Scale: Boolean read FScale write SetScale
      default DefScale;
    property VertAlign: TVertAlign read FVertAlign write SetVertAlign
      default DefVertAlign;
    property HorizAlign: THorizAlign read FHorizAlign write SetHorizAlign
      default DefHorizAlign;

    property OnChangeCheckBox: TOnChangeCheckBox read FOnChangeCheckBox
      write FOnChangeCheckBox;
  end;

implementation

const
  BMPWidth = 13;
  BMPHeight = 13;

{
  Private Part -----------------------------------------------------------------
}

function TxDBCheckGrid.GetDataField: String;
begin
  FDataLink.DataSource := DataSource;
  Result := FDataLink.FieldName;
end;

procedure TxDBCheckGrid.SetDataField(AValue: String);
begin
  FDataLink.DataSource := DataSource;
  FDataLink.FieldName := AValue;
end;

procedure TxDBCheckGrid.SetCheckedGlyph(AValue: TBitmap);
begin
  if AValue <> nil then
    FCheckedGlyph.Assign(AValue)
  else
    LoadCheckBoxBitmap(FCheckedGlyph, TRUE);
end;

procedure TxDbCheckGrid.SetUncheckedGlyph(AValue: TBitmap);
begin
  if AValue <> nil then
    FUncheckedGlyph.Assign(AValue)
  else
    LoadCheckBoxBitmap(FUncheckedGlyph, FALSE);
end;

procedure TxDBCheckGrid.SetScale(AValue: Boolean);
begin
  if AValue <> FScale then FScale := AValue;
end;

procedure TxDBCheckGrid.SetVertAlign(AValue: TVertAlign);
begin
  if AValue <> FVertAlign then
  begin
    FVertAlign := AValue;
    Invalidate;
  end;
end;

procedure TxDBCheckGrid.SetHorizAlign(AValue: THorizAlign);
begin
  if AValue <> FHorizAlign then
  begin
    FHorizAlign := AValue;
    Invalidate;
  end;
end;

procedure TxDBCheckGrid.LoadCheckBoxBitmap(var ABitmap: TBitmap; Checked: Boolean);
var
  B: TBitmap;
  R: TRect;
begin
  B := TBitmap.Create;
  B.Handle := LoadBitmap(0, MAKEINTRESOURCE(OBM_CHECKBOXES));

  ABitmap.Width := BMPWidth;
  ABitmap.Height := BMPHeight;

  if Checked then
    R := Rect(BMPWidth, 0, BMPWidth * 2, BMPHeight)
  else
    R := Rect(0, 0, BMPWidth, BMPHeight);

  ABitmap.Canvas.CopyRect(Rect(0, 0, BMPWidth, BMPHeight), B.Canvas, R);
  B.Free;
end;

procedure TxDBCheckGrid.DrawField(R: TRect; ABitmap: TBitmap);
var
  R2: TRect;
begin
  R2 := Rect(0, 0, ABitmap.Width, ABitmap.Height);

  if not FScale then
  begin
    case FVertAlign of
      alTop:
      begin
        R.Top := R.Top;
        R.Bottom := R.Top + ABitmap.Height;
      end;
      alVCenter:
      begin
        R.Top := R.Top + (R.Bottom - R.Top) div 2 - ABitmap.Height div 2;
        R.Bottom := R.Top + ABitmap.Height;
      end;
      alBottom:
      begin
        R.Top := R.Bottom - ABitmap.Height;
        R.Bottom := R.Bottom;
      end;
    end;

    case FHorizAlign of
      alLeft:
      begin
        R.Left := R.Left;
        R.Right := R.Left + ABitmap.Width;
      end;
      alCenter:
      begin
        R.Left := R.Left + (R.Right - R.Left) div 2 - ABitmap.Width div 2;
        R.Right := R.Left + ABitmap.Width;
      end;
      alRight:
      begin
        R.Left := R.Right - ABitmap.Width;
        R.Right := R.Right;
      end;
    end;
  end;

  Canvas.CopyRect(R, ABitmap.Canvas, R2);
end;

procedure TxDBCheckGrid.WMChar(var Message: TWMChar);
var
  F: TField;
  OldActive: LongInt;
  OldOptions: TDBGridOptions;
begin
  F := GetColField(Col - Integer(dgIndicator in Options));

  if (Char(Message.CharCode) in [#32..#255, ^H, Chr(VK_RETURN)]) and
    (CompareText(F.FieldName, DataField) = 0) then
  begin
    if Char(Message.CharCode) = #32 then
    begin
      OldOptions := Options;
      Options := Options - [dgEditing];

      OldActive := DataLink.ActiveRecord;
      try
        DataLink.ActiveRecord := Row - Integer(dgTitles in Options);
        F := Fields[Col - Integer(dgIndicator in Options)];
        if not ReadOnly then
        begin
          DataSource.DataSet.Edit;
          if F.DataType = ftBoolean then
            F.AsBoolean := not F.AsBoolean
          else
            F.AsInteger := Integer( not Boolean(F.AsInteger));
          if Assigned(FOnChangeCheckBox) then
            FOnChangeCheckBox(Self, F.AsBoolean);
        end;
      finally
        DataLink.ActiveRecord := OldActive;
        Options := OldOptions;
      end;
    end;
  end else
    inherited;
end;

procedure TxDBCheckGrid.WMKeyDown(var Message: TWMKeyDown);
begin
  if (Message.CharCode <> VK_F2) or (CompareText(GetColField(Col -
    Integer(dgIndicator in Options)).FieldName, DataField) <> 0) then inherited;
end;

procedure TxDBcheckGrid.WMKeyUp(var Message: TWMKeyUp);
begin
  if (Message.CharCode <> VK_F2) or (CompareText(GetColField(Col -
    Integer(dgIndicator in Options)).FieldName, DataField) <> 0) then inherited;
end;

{
  Protected Part ---------------------------------------------------------------
}

procedure TxDBCheckGrid.Loaded;
begin
  inherited Loaded;
end;

procedure TxDBCheckGrid.DrawCell(ACol, ARow: Longint; ARect: TRect;
  AState: TGridDrawState);
var
  F: TField;
  OldActive: LongInt;
  OldDefaultDrawing: Boolean;
  IsCheck: Boolean;
begin
  // Получаем поле
  F := GetColField(ACol - Integer(dgIndicator in Options));
  OldDefaultDrawing := DefaultDrawing;

  // Для того, чтобы предотвратить рисование текста отключаем флаг DefaultDrawing
  if not (gdFixed in AState) and not (csDesigning in ComponentState) and
    (F <> nil) and (CompareText(F.FieldName, DataField) = 0)
  then
    DefaultDrawing := False;

  inherited DrawCell(ACol, ARow, ARect, AState);

  DefaultDrawing := OldDefaultDrawing;

  // Если есть необходимость рисовать CheckBox
  if not (gdFixed in AState) and not (csDesigning in ComponentState) and
    (F <> nil) and (CompareText(F.FieldName, DataField) = 0) then
  begin
    Canvas.FillRect(ARect);

    OldActive := DataLink.ActiveRecord;
    try
      DataLink.ActiveRecord := ARow - Integer(dgTitles in Options);

      if Fields[ACol - Integer(dgIndicator in Options)].DataType = ftBoolean then
        IsCheck:= Fields[ACol - Integer(dgIndicator in Options)].AsBoolean
      else
        IsCheck:= (Fields[ACol - Integer(dgIndicator in Options)].AsInteger = 1);

      if IsCheck then
        DrawField(ARect, FCheckedGlyph)
      else
        DrawField(ARect, FUncheckedGlyph);
    finally
      DataLink.ActiveRecord := OldActive;
    end;

    if DefaultDrawing and (gdSelected in AState)
      and ((dgAlwaysShowSelection in Options) or Focused)
      and not (csDesigning in ComponentState)
      and not (dgRowSelect in Options)
      and (UpdateLock = 0)
      and (ValidParentForm(Self).ActiveControl = Self)
    then
      Windows.DrawFocusRect(Handle, ARect);
  end;
end;

procedure TxDBCheckGrid.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  R: TGridCoord;
  F: TField;
  OldActive: LongInt;
  OldOptions: TDBGridOptions;
begin
  F := nil;
  if Button = mbLeft then
  begin
    R := MouseCoord(X, Y);

    if (R.X - Integer(dgIndicator in Options) >= 0) and
      (R.Y - Integer(dgTitles in Options) >= 0)
    then begin
      F := GetColField(R.X - Integer(dgIndicator in Options));

      if CompareText(F.FieldName, DataField) = 0 then
      begin
        OldOptions := Options;
        Options := Options - [dgEditing];
      end;
    end;
  end;  

  inherited MouseDown(Button, Shift, X, Y);

  if (R.X - Integer(dgIndicator in Options) >= 0) and
    (R.Y - Integer(dgTitles in Options) >= 0) and (F <> nil) and (Button = mbLeft)
  then
    if CompareText(F.FieldName, DataField) = 0 then
    begin
      HideEditor;
      OldActive := DataLink.ActiveRecord;
      try
        DataLink.ActiveRecord := R.Y - Integer(dgTitles in Options);
        F := Fields[R.X - Integer(dgIndicator in Options)];
        if not ReadOnly then
        begin
          DataSource.DataSet.Edit;
          if F.DataType = ftBoolean then
            F.AsBoolean := not F.AsBoolean
          else
            F.AsInteger := Integer( not Boolean(F.AsInteger));
          if Assigned(FOnChangeCheckBox) then
            FOnChangeCheckBox(Self, F.AsBoolean);
        end;
      finally
        DataLink.ActiveRecord := OldActive;
        Options := OldOptions;
      end;
    end;
end;

{
  Public Part ------------------------------------------------------------------
}

constructor TxDBCheckGrid.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FDataLink := TFieldDataLink.Create;

  FCol := 0;
  FCheckedGlyph := TBitmap.Create;
  LoadCheckBoxBitmap(FCheckedGlyph, TRUE);

  FUncheckedGlyph := TBitmap.Create;
  LoadCheckBoxBitmap(FUncheckedGlyph, FALSE);

  FHorizAlign := DefHorizAlign;
  FVertAlign := DefVertAlign;
end;

destructor TxDBCheckGrid.Destroy;
begin
  if FDataLink <> nil then FDataLink.Free;
  if FCheckedGlyph <> nil then FCheckedGlyph.Free;
  if FUncheckedGlyph <> nil then FUncheckedGlyph.Free;

  inherited Destroy;
end;

end.

