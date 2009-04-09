
{++

  Copyright (c) 1996-99 by Golden Software of Belarus

  Module

    mmDBGridCheck.pas

  Abstract

    A Delphi visual component. A DBGrid with check boxes inside. 

  Author

    Denis Romanovski (28-Jan-99)

  Revisions history

    Initial  28-01-99  Dennis  Initial version.

    Beta1    28-01-99  Dennis  Everything works.
--}

unit mmDBGridCheck;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, DBGrids, mmDBGrid, DBCtrls, DB;

// ���� ������������ �������� � ��.
type
  TVertAlign = (alTop, alVCenter, alBottom);
  THorizAlign = (alLeft, alCenter, alRight);
  TOnChangeCheckBox = procedure(Sender: TObject; Value: Boolean) of object;

// �������� �� ���������
const
  DefScale = FALSE;
  DefVertAlign = alVCenter;
  DefHorizAlign = alCenter;

type
  TmmDBGridCheck = class(TmmDBGrid)
  private
    FDataLink: TFieldDataLink; // ����� � �������

    FCheckedGlyph, FUncheckedGlyph: TBitmap; // �������

    FScale: Boolean; // ���������������
    FVertAlign: TVertAlign; // ������������ ������������
    FHorizAlign: THorizAlign; // ������������ ��������������
    FList: TStringList; // ������ ���������� ���������
    FOnChangeCheckBox: TOnChangeCheckBox; // Event �� ������� �� CheckBox

    CurrRec: Integer; // ������� ������

    OldBeforeDelete, OldAfterDelete: TDataSetNotifyEvent;

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
    procedure ClearCheckList;
    procedure DeleteCheck(const ACheck: String);
    procedure AddCheck(const ACheck: String);

    property CheckList: TStringList read FList;

  published
    // ����, ��� ����� ��������� ���������� CheckBox-�
    property DataField: String read GetDataField write SetDataField;
    // ������� ���������� ���������
    property CheckedGlyph: TBitmap read FCheckedGlyph write SetCheckedGlyph;
    // ������� ������������ ���������
    property UncheckedGlyph: TBitmap read FUncheckedGlyph write SetUncheckedGlyph;
    // ���������������
    property Scale: Boolean read FScale write SetScale
      default DefScale;
    // ������������ ������������
    property VertAlign: TVertAlign read FVertAlign write SetVertAlign
      default DefVertAlign;
    // �������������� ������������
    property HorizAlign: THorizAlign read FHorizAlign write SetHorizAlign
      default DefHorizAlign;
    // Event �� ������� �� CheckBox
    property OnChangeCheckBox: TOnChangeCheckBox read FOnChangeCheckBox
      write FOnChangeCheckBox;
  end;

implementation

const
  BMPWidth = 13;
  BMPHeight = 13;

{
  ***********************
  ***   Public Part   ***
  ***********************
}

{
  ������ ��������� ���������.
}

constructor TmmDBGridCheck.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FDataLink := TFieldDataLink.Create;

  // ������� ������
  FList := TStringList.Create;
  FList.Sorted := False;
  FList.Duplicates := dupIgnore;

  // ��������� �������
  FCheckedGlyph := TBitmap.Create;
  LoadCheckBoxBitmap(FCheckedGlyph, TRUE);

  FUncheckedGlyph := TBitmap.Create;
  LoadCheckBoxBitmap(FUncheckedGlyph, FALSE);

  // ������ ���������
  FHorizAlign := DefHorizAlign;
  FVertAlign := DefVertAlign;

  CurrRec := 0;
end;

{
  ������������ ������.
}

destructor TmmDBGridCheck.Destroy;
begin
  if Assigned(DataSource) and Assigned(DataSource.DataSet) then
  begin
    DataSource.DataSet.BeforeDelete := OldBeforeDelete;
    DataSource.DataSet.AfterDelete := OldAfterDelete;
  end;  

  FList.Free;
  FCheckedGlyph.Free;
  FUncheckedGlyph.Free;
  FDataLink.Free;

  inherited Destroy;
end;

{
  ���������� ����� � ������ ���������� ��������.
}

function TmmDBGridCheck.SearchInList(const ACheck: String): Integer;
begin
  Result := FList.IndexOf(ACheck) + 1;
end;

{
  ��������� ������ �������� � ����������� ������.
}

procedure TmmDBGridCheck.AssignNewList(AList: TStringList);
begin
  FList.Assign(AList);
  Invalidate;
end;

{
  ������� ��� ������ �� ������������ ������.
}

procedure TmmDBGridCheck.ClearCheckList;
begin
  FList.Clear;
  Invalidate;
end;

{
  ��������� �������� � ������.
}

procedure TmmDBGridCheck.AddCheck(const ACheck: String);
begin
  FList.Add(ACheck);
end;

{
  ������� �������� �� �������.
}

procedure TmmDBGridCheck.DeleteCheck(const ACheck: String);
var
  Num: Integer;
begin
  Num:= SearchInList(ACheck);
  if Num > 0 then FList.Delete(Num - 1);
end;


{
  **************************
  ***   Protected Part   ***
  **************************
}

{
  �� �������� ������� ������ ���� ���������.
}

procedure TmmDBGridCheck.Loaded;
begin
  inherited Loaded;

  if Assigned(DataSource) and Assigned(DataSource.DataSet) then
  begin
    OldBeforeDelete := DataSource.DataSet.BeforeDelete;
    DataSource.DataSet.BeforeDelete := DoBeforeDelete;

    OldAfterDelete := DataSource.DataSet.AfterDelete;
    DataSource.DataSet.AfterDelete := DoAfterDelete;
  end;
end;

{
  ���������� ����������� ������ �������.
}

procedure TmmDBGridCheck.DrawCell(ACol, ARow: Longint; ARect: TRect;
  AState: TGridDrawState);
var
  F: TField;
  Index: Integer;
  OldActive: LongInt;
  OldDefaultDrawing: Boolean;
begin
  // �������� ����
  F := GetColField(ACol - Integer(dgIndicator in Options));
  OldDefaultDrawing := DefaultDrawing;

  // ��� ����, ����� ������������� ��������� ������ ��������� ���� DefaultDrawing
  if not (gdFixed in AState) and not (csDesigning in ComponentState) and
    (F <> nil) and (CompareText(F.FieldName, DataField) = 0)
  then
    DefaultDrawing := False;

  inherited DrawCell(ACol, ARow, ARect, AState);

  DefaultDrawing := OldDefaultDrawing;

  // ���� ���� ������������� �������� CheckBox
  if not (gdFixed in AState) and not (csDesigning in ComponentState) and
    (F <> nil) and (CompareText(F.FieldName, DataField) = 0) then
  begin
    Canvas.FillRect(ARect);

    // �������� ����������� ������ � �������
    OldActive := DataLink.ActiveRecord;
    try
      DataLink.ActiveRecord := ARow - Integer(dgTitles in Options);
      Index := SearchInList(Fields[ACol - Integer(dgIndicator in Options)].AsString);
    finally
      DataLink.ActiveRecord := OldActive;
    end;
    // �������� ���� �� ��������� ���������
    if Index > 0 then
      DrawField(ARect, FCheckedGlyph)
    else
      DrawField(ARect, FUncheckedGlyph);

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

{
  ���������� ���� �������� �� ������� ����.
}

procedure TmmDBGridCheck.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  R: TGridCoord;
  F: TField;
  Index: Integer;
  OldActive: LongInt;
  OldOptions: TDBGridOptions;
begin
  F := nil;

  // ���� ������ ����� ������ ����.
  if Button = mbLeft then
  begin
    R := MouseCoord(X, Y);

    if (R.X - Integer(dgIndicator in Options) >= 0) and
      (R.Y - Integer(dgTitles in Options) >= 0) then
    begin
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
          FList.Add(Fields[Col - Integer(dgIndicator in Options)].AsString);
          if Assigned(FOnChangeCheckBox) then FOnChangeCheckBox(Self, true);
        end;
      end;

      InvalidateCell(Col, Row);
      Options := OldOptions;
    end;
end;


{
  ************************
  ***   Private Part   ***
  ************************
}


{
  �������� ����������� ���� ��� ���������.
}

function TmmDBGridCheck.GetDataField: String;
begin
  FDataLink.DataSource := DataSource;
  Result := FDataLink.FieldName;
end;

{
  ������������� ����������� ���� ��� ���������.
}

procedure TmmDBGridCheck.SetDataField(AValue: String);
begin
  FDataLink.DataSource := DataSource;
  FDataLink.FieldName := AValue;
end;

{
  ������������ ������� ���������� ����.
}

procedure TmmDBGridCheck.SetCheckedGlyph(AValue: TBitmap);
begin
  if AValue <> nil then
    FCheckedGlyph.Assign(AValue)
  else
    LoadCheckBoxBitmap(FCheckedGlyph, TRUE);
end;

{
  ������������ ������� ������������ ����.
}

procedure TmmDBGridCheck.SetUncheckedGlyph(AValue: TBitmap);
begin
  if AValue <> nil then
    FUncheckedGlyph.Assign(AValue)
  else
    LoadCheckBoxBitmap(FUncheckedGlyph, FALSE);
end;

{
  ������������� ���������������.
}

procedure TmmDBGridCheck.SetScale(AValue: Boolean);
begin
  FScale := AValue;
end;

{
  ������������� ������������ ������������.
}

procedure TmmDBGridCheck.SetVertAlign(AValue: TVertAlign);
begin
  if AValue <> FVertAlign then
  begin
    FVertAlign := AValue;
    Invalidate;
  end;
end;

{
  ������������� �������������� ������������.
}

procedure TmmDBGridCheck.SetHorizAlign(AValue: THorizAlign);
begin
  if AValue <> FHorizAlign then
  begin
    FHorizAlign := AValue;
    Invalidate;
  end;
end;

{
  ���������� �������� ��������.
}

procedure TmmDBGridCheck.LoadCheckBoxBitmap(var ABitmap: TBitmap; Checked: Boolean);
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

{
  ���������� ���������� ��������.
}

procedure TmmDBGridCheck.DrawField(R: TRect; ABitmap: TBitmap);
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

{
  ���������� ����� ���������� ��������.
}

procedure TmmDBGridCheck.DoBeforeDelete(DataSet: TDataSet);
begin
  CurrRec := SearchInList(DataSource.DataSet.FieldByName(DataField).AsString);
  if Assigned(OldBeforeDelete) then OldBeforeDelete(DataSet);
end;

{
  ������� �������� �� ������������ ������.
}

procedure TmmDBGridCheck.DoAfterDelete(DataSet: TDataSet);
begin
  if CurrRec > 0 then FList.Delete(CurrRec - 1);
  if Assigned(OldAfterDelete) then OldAfterDelete(DataSet);
end;

{
  �� ������� ������������ ������ ���������� ���� ��������.
}

procedure TmmDBGridCheck.WMChar(var Message: TWMChar);
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

      if Index > 0 then
      begin
        FList.Delete(Index - 1);
        if Assigned(FOnChangeCheckBox) then FOnChangeCheckBox(Self, false);
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

{
  ��������� ����� ��������������.
}

procedure TmmDBGridCheck.WMKeyDown(var Message: TWMKeyDown);
begin
  if (Message.CharCode <> VK_F2) or (CompareText(GetColField(Col -
    Integer(dgIndicator in Options)).FieldName, DataField) <> 0) then inherited;
end;

{
  ��������� ����� ��������������.
}

procedure TmmDBGridCheck.WMKeyUp(var Message: TWMKeyUp);
begin
  if (Message.CharCode <> VK_F2) or (CompareText(GetColField(Col -
    Integer(dgIndicator in Options)).FieldName, DataField) <> 0) then inherited;
end;

end.

