
{++

  Copyright (c) 1996-97 by Golden Software of Belarus

  Module

    xDBCGrid.pas

  Abstract

    A Delphi visual component. This is a DBGrid with check boxes which I
    handle in a string list in sorted way.

  Author

    Denis Romanovski (6-Apr-96)

  Revisions history

    1.00    dennis    06-apr-96    Initial version.
    1.01    andreik   20-mar-96    Minor change.
    1.02    vitya     27-nov-97    Add clear method.
--}

unit xDBCheck;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Grids, DB, DBTables, DBCtrls, DBGrids, ExtCtrls;

type
  TVertAlign = (alTop, alVCenter, alBottom);
  THorizAlign = (alLeft, alCenter, alRight);
  TOnChangeCheckBox = procedure(Sender: TObject; Value: Boolean) of object;

const
  DefScale = FALSE;
  DefVertAlign = alVCenter;
  DefHorizAlign = alCenter;

type
  TxDBCheck = class(TDBGrid)
  private
    FDataLink: TFieldDataLink;
    FCol: Integer;
    FCheckedGlyph, FUncheckedGlyph: TBitmap;
    FScale: Boolean;
    FVertAlign: TVertAlign;
    FHorizAlign: THorizAlign;
    FList: TStringList;
    FOnChangeCheckBox: TOnChangeCheckBox;

    CurrRec: Integer;

    function GetDataField: String;

    procedure SetDataField(AValue: String);
    procedure SetCheckedGlyph(AValue: TBitmap);
    procedure SetUncheckedGlyph(AValue: TBitmap);
    procedure SetScale(AValue: Boolean);
    procedure SetVertAlign(AValue: TVertAlign);
    procedure SetHorizAlign(AValue: THorizAlign);

    procedure LoadCheckBoxBitmap(var ABitmap: TBitmap; Checked: Boolean);
    procedure DrawField(R: TRect; ABitmap: TBitmap);
    procedure DoBeforeDelete(DataSet: TDataSet);
    procedure DoAfterDelete(DataSet: TDataSet);

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

    function SearchInList(const ACheck: String): Integer;
    procedure AssignNewList(AList: TStringList);
    procedure DeleteCheck(const ACheck: String);
    procedure AddCheck(const ACheck: String);
    procedure ClearCheckList;

    property CheckList: TStringList read FList;

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

procedure Register;

implementation

const
  BMPWidth = 13;
  BMPHeight = 13;

{ Public Part --------------------------------------------}

constructor TxDBCheck.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FList := TStringList.Create;
  FList.Sorted := False;
  FList.Duplicates := dupIgnore;

  FDataLink := TFieldDataLink.Create;

  FCol := 0;
  FCheckedGlyph := TBitmap.Create;
  LoadCheckBoxBitmap(FCheckedGlyph, TRUE);

  FUncheckedGlyph := TBitmap.Create;
  LoadCheckBoxBitmap(FUncheckedGlyph, FALSE);

  FHorizAlign := DefHorizAlign;
  FVertAlign := DefVertAlign;

  CurrRec := 0;
end;

destructor TxDBCheck.Destroy;
begin
  if FList <> nil then FList.Free;
  if FDataLink <> nil then FDataLink.Free;
  if FCheckedGlyph <> nil then FCheckedGlyph.Free;
  if FUncheckedGlyph <> nil then FUncheckedGlyph.Free;
  
  inherited Destroy;
end;

procedure TxDBCheck.AssignNewList(AList: TStringList);
begin
  FList.Assign(AList);
  Invalidate;
end;

procedure TxDBCheck.ClearCheckList;
begin
  FList.Clear;
  Invalidate;
end;

{ Protected Part -----------
------------------------------}

procedure TxDBCheck.Loaded;
begin
  inherited Loaded;

  if Assigned(DataSource) and Assigned(DataSource.DataSet) then
  begin
    if DataSource.DataSet is TTable then
    begin
      (DataSource.DataSet as TTable).BeforeDelete := DoBeforeDelete;
      (DataSource.DataSet as TTable).AfterDelete := DoAfterDelete;
    end
    else if DataSource.DataSet is TQuery then
    begin
      (DataSource.DataSet as TQuery).BeforeDelete := DoBeforeDelete;
      (DataSource.DataSet as TQuery).AfterDelete := DoAfterDelete;
    end;
  end;
end;

procedure TxDBCheck.DrawCell(ACol, ARow: Longint; ARect: TRect;
  AState: TGridDrawState);
var
  F: TField;
  Index: Integer;
  OldActive: LongInt;
  HighLight: Boolean;
begin
  F := GetColField(ACol - Integer(dgIndicator in Options));

  if (gdFixed in AState) or (csDesigning in ComponentState) or
    (F = nil) or (CompareText(F.FieldName, DataField) <> 0)
  then
    inherited DrawCell(ACol, ARow, ARect, AState)
  else begin
    HighLight := HighLightCell(ACol, ARow, '', AState);

    if HighLight then
    begin
      Canvas.Brush.Color := clHighLight;
      Canvas.Font.Color := clHighLightText;
    end else
      Canvas.Brush.Color := Color;

    Canvas.FillRect(ARect);

    OldActive := DataLink.ActiveRecord;
    try
      DataLink.ActiveRecord := ARow - Integer(dgTitles in Options);
      Index := SearchInList(Fields[ACol - Integer(dgIndicator in Options)].AsString);
    finally
      DataLink.ActiveRecord := OldActive;
    end;

    if Index > 0 then
      DrawField(ARect, FCheckedGlyph)
    else
      DrawField(ARect, FUncheckedGlyph);

    if HighLight and not (dgRowSelect in Options) and not (csDesigning in ComponentState)then
      Canvas.DrawFocusRect(ARect);
  end;
end;

procedure TxDBCheck.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  R: TGridCoord;
  F: TField;
  Index: Integer;
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
        DataLink.ActiveRecord := Row - Integer(dgTitles in Options);
        Index := SearchInList(Fields[Col - Integer(dgIndicator in Options)].AsString);
      finally
        DataLink.ActiveRecord := OldActive;
      end;

      if Index > 0 then
      begin
        FList.Delete(Index - 1);
        if Assigned(FOnChangeCheckBox) then
          FOnChangeCheckBox(Self, false);
      end else begin
        if Fields[Col - Integer(dgIndicator in Options)].AsString <> '' then
        begin
          Flist.Add(Fields[Col - Integer(dgIndicator in Options)].AsString);
          if Assigned(FOnChangeCheckBox) then FOnChangeCheckBox(Self, true);
        end;
      end;

      InvalidateCell(Col, Row);
      Options := OldOptions;
    end;
end;

{ Private Part -------------------------------------------}

function TxDBCheck.GetDataField: String;
begin
  FDataLink.DataSource := DataSource;
  Result := FDataLink.FieldName;
end;

procedure TxDBCheck.SetDataField(AValue: String);
begin
  FDataLink.DataSource := DataSource;
  FDataLink.FieldName := AValue;
end;

procedure TxDBCheck.SetCheckedGlyph(AValue: TBitmap);
begin
  if AValue <> nil then
    FCheckedGlyph.Assign(AValue)
  else
    LoadCheckBoxBitmap(FCheckedGlyph, TRUE);
end;

procedure TxDBCheck.SetUncheckedGlyph(AValue: TBitmap);
begin
  if AValue <> nil then
    FUncheckedGlyph.Assign(AValue)
  else
    LoadCheckBoxBitmap(FUncheckedGlyph, FALSE);
end;

procedure TxDBCheck.SetScale(AValue: Boolean);
begin
  FScale := AValue;
end;

procedure TxDBCheck.SetVertAlign(AValue: TVertAlign);
begin
  if AValue <> FVertAlign then
  begin
    FVertAlign := AValue;
    Invalidate;
  end;
end;

procedure TxDBCheck.SetHorizAlign(AValue: THorizAlign);
begin
  if AValue <> FHorizAlign then
  begin
    FHorizAlign := AValue;
    Invalidate;
  end;
end;

procedure TxDBCheck.LoadCheckBoxBitmap(var ABitmap: TBitmap; Checked: Boolean);
var
  B: TBitmap;
  R: TRect;
begin
  B := TBitmap.Create;
  try
    B.Handle := LoadBitmap(0, MAKEINTRESOURCE(OBM_CHECKBOXES));

    ABitmap.Width := BMPWidth;
    ABitmap.Height := BMPHeight;

    if Checked then
      R := Rect(BMPWidth, 0, BMPWidth * 2, BMPHeight)
    else
      R := Rect(0, 0, BMPWidth, BMPHeight);

    ABitmap.Canvas.CopyRect(Rect(0, 0, BMPWidth, BMPHeight), B.Canvas, R);
  finally
    B.Free;
  end;
end;

procedure TxDBCheck.DrawField(R: TRect; ABitmap: TBitmap);
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

function TxDBCheck.SearchInList(const ACheck: String): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FList.Count - 1 do
    if FList[I] = ACheck then
    begin
      Result := I + 1;
      Break;
    end;
end;

procedure TxDBCheck.DeleteCheck(const ACheck: String);
var
  Num: Integer;
begin
  Num:= SearchInList(ACheck);
  if Num > 0 then
    FList.Delete(Num - 1);
end;

procedure TxDBCheck.AddCheck(const ACheck: String);
begin
  FList.Add(ACheck);
end;

procedure TxDBCheck.DoBeforeDelete(DataSet: TDataSet);
begin
  CurrRec := SearchInList(DataSource.DataSet.FieldByName(DataField).AsString);
end;

procedure TxDBCheck.DoAfterDelete(DataSet: TDataSet);
begin
  if CurrRec > 0 then
    FList.Delete(CurrRec - 1);
end;

procedure TxDBCheck.WMChar(var Message: TWMChar);
var
  F: TField;
  Index: Integer;
  OldActive: LongInt;
begin
  F := GetColField(Col - Integer(dgIndicator in Options));

  if (Char(Message.CharCode) in [#32..#255, ^H, Chr(VK_RETURN)]) and
    (CompareText(F.FieldName, DataField) = 0) then
  begin
    if Char(Message.CharCode) = #32 then
    begin

      OldActive := DataLink.ActiveRecord;
      try
        DataLink.ActiveRecord := Row - Integer(dgTitles in Options);
        Index := SearchInList(Fields[Col - Integer(dgIndicator in Options)].AsString);
      finally
        DataLink.ActiveRecord := OldActive;
      end;

      if Index > 0 then begin
        FList.Delete(Index - 1);
        if Assigned(FOnChangeCheckBox) then
          FOnChangeCheckBox(Self, false);
      end else begin
        if Fields[Col - Integer(dgIndicator in Options)].AsString <> '' then
        begin
          Flist.Add(Fields[Col - Integer(dgIndicator in Options)].AsString);
          if Assigned(FOnChangeCheckBox) then FOnChangeCheckBox(Self, true);
        end;    
      end;

      InvalidateCell(Col, Row);
    end;
  end else
    inherited;
end;

procedure TxDBCheck.WMKeyDown(var Message: TWMKeyDown);
begin
  if (Message.CharCode <> VK_F2) or (CompareText(GetColField(Col -
    Integer(dgIndicator in Options)).FieldName, DataField) <> 0) then inherited;
end;

procedure TxDBCheck.WMKeyUp(var Message: TWMKeyUp);
begin
  if (Message.CharCode <> VK_F2) or (CompareText(GetColField(Col -
    Integer(dgIndicator in Options)).FieldName, DataField) <> 0) then inherited;
end;

{ Register Part ------------------------------------------}

procedure Register;
begin
  RegisterComponents('x-DataBase', [TxDBCheck]);
end;

end.

