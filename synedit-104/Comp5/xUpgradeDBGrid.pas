
{++

  Copyright (c) 1996-98 by Golden Software of Belarus

  Module

    xUpgradeDBGrid.pas

  Abstract

    Ordinary DBGrid with menu inside. It stores all information
    about fonts and colors of DBGrid in registry and during
    work restores these settings. Also different row colors are
    supported here.

  Author

    Romanovski Denis (11-07-98)

  Revisions history

    Initial  11-07-98  Dennis  Initial version.

    beta1    14-07-98  Dennis  Beta version 1.

    beta2    19-07-98  Dennis  Beta version 2. Some bugs are corrected.
                               Two colors for two rows properties are added.

    beta3    22-07-98  Dennis  Some bugs are corrected under Delphi4.

    beta4    23-07-98  Dennis  Bug-g-g-g-gs.

    beta5    04-08-98  Dennis  Another bug is corrected.

    beta6    11-08-98  Dennis  Columns' sizes storing included.

--}

unit xUpgradeDBGrid;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, DBGrids, Menus, DB, StdCtrls;

// ��������� �� ��, ��� ���� ����� ���� ��������� ��� ������ ��� ��� ���������
type
  TPopupKind = (pkSubMenu, pkItem);

type
  TxUpgradeDBGrid = class(TDBGrid)
  private
    FPopupKind: TPopupKind; // ���� ��������� � ������ ��� ����������� � �����
    FRowColor1, FRowColor2: TColor; // ����� ������ � ������ ������ � �.�.
    FUserColors: Boolean; // ������������ �� ���� �����
    FSelectedColor: TColor; // ���� ���������� ����� Grid-�
    PopupColumn: TColumn; // ������� ���������� �������
    MyPopupMenu: TPopupMenu; // ��� �� PopupMenu?
    OldDataSet: TDataSet; // ������ DataSet
    FSettingsLoaded: Boolean; // ��������� �� ������ �� registry

    OldOnDataSetOpen, OldOnDataSetClose: TDataSetNotifyEvent; // Event AfterOpen, BeforeClose ������������
    OldOnDataChange: TDataChangeEvent; // Event OnDataChange ������������
    OldOnPopup: TNotifyEvent; // Event OnPopup ������������

    FontDlg: TFontDialog; // ������ ������ ������
    ColorDlg: TColorDialog; // ������ ������ �����

    procedure MakePopupSettings(APopupMenu: TPopupMenu; WithColumn: Boolean);

    procedure WMRButtonDown(var Message: TWMLButtonDown);
      message WM_RButtonDown;

    procedure DoOnDataSetOpen(DataSet: TDataSet);
    procedure DoOnDataSetClose(DataSet: TDataSet);
    procedure DoOnDataChange(Sender: TObject; Field: TField);
    procedure DoOnPopup(Sender: TObject);

    procedure DoOnTableFont(Sender: TObject);
    procedure DoOnTableTitleFont(Sender: TObject);
    procedure DoOnColFont(Sender: TObject);
    procedure DoOnColTitleFont(Sender: TObject);

    procedure DoOnTableColor(Sender: TObject);
    procedure DoOnTableTitleColor(Sender: TObject);
    procedure DoOnColColor(Sender: TObject);
    procedure DoOnColTitleColor(Sender: TObject);

    procedure DoOnColAlign(Sender: TObject);
    procedure DoOnColTitleAlign(Sender: TObject);

    procedure DoOnNewTitle(Sender: TObject);

    procedure LoadFromRegistry(Column: TColumn);
    procedure SaveToRegistry(Column: TColumn);

    function GetDataSource: TDataSource;
    procedure SetDataSource(ADataSource: TDataSource);

    function GetPopup: TPopupMenu;
    procedure SetPopup(APopupMenu: TPopupMenu);

    function GetPopupKind: TPopupKind;
    procedure SetPopupKind(APopupKind: TPopupKind);

    procedure SetRowColor1(ARowColor: TColor);
    procedure SetRowColor2(ARowColor: TColor);
    procedure SetUserColors(AUserColors: Boolean);
    procedure SetSelectedColor(const Value: TColor);

  protected
    procedure Loaded; override;
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;
    procedure Scroll(Distance: Integer); override;
    procedure ColWidthsChanged; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure CheckPopup(AMenu: TMenuItem);
  published
    // ��� ����
    property PopupKind: TPopupKind read GetPopupKind write SetPopupKind;
    // ������� DataSource
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    // ������� PopupMenu
    property PopupMenu: TPopupMenu read GetPopup write SetPopup;
    // ���� ������ ������
    property RowColor1: TColor read FRowColor1 write SetRowColor1;
    // ���� ������ ������
    property RowColor2: TColor read FRowColor2 write SetRowColor2;
    // ������������ �� ���� ����� Grid-�
    property UserColors: Boolean read FUserColors write SetUserColors;
    // ���� ���������� ����� Grid-�
    property SelectedColor: TColor read FSelectedColor write SetSelectedColor;

  end;

procedure Register;

implementation

uses xAppReg;

const
  LeftSide = '�� ������ ����';
  RightSide = '�� ������� ����';
  Center = '�� ������';
  
  // ��������� ��� ������� ������������ ���� �� �����������������
  AddMenuTag = 1234567;

  UserCount: Integer = 0; // ���-�� �������������

var
  DrawBitmap: TBitmap; // ������������ �� WtireText.

{
  ����� �� ����� ������?
}

function Max(X, Y: Integer): Integer;
begin
  Result := Y;
  if X > Y then Result := X;
end;

{
  Borland-������ ������� �� ��������� ������.
}

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

{
  ********************
  **  Private Part  **
  ********************
}

{
  ���������� ���������� ����� ������� � ���� �������� Grid-� ���
  �� � ��������� �������������� ���� Grid-�.
}

procedure TxUpgradeDBGrid.MakePopupSettings(APopupMenu: TPopupMenu; WithColumn: Boolean);
var
  Group, Item, CurrItem: TMenuItem;

  // ��������� ������� ������
  function AddItem(S: String): TMenuItem;
  begin
    Result := TMenuItem.Create(Owner);
    Result.Caption := S;
    Result.Tag := AddMenuTag;
    Group.Add(Result);
  end;

  // ��������� ������� � ���������
  function AddSubItem(AGroup: TMenuItem; S: String): TMenuItem;
  begin
    Result := TMenuItem.Create(Owner);
    Result.Caption := S;
    Result.Tag := AddMenuTag;
    AGroup.Add(Result);
  end;

begin
  if FPopupKind = pkSubMenu then // ���� ��������� ���������
  begin
    Group := TMenuItem.Create(Owner);
    Group.Caption := '��������� �������';
    APopupMenu.Items.Add(Group);
  end else begin // ���� ���� ������������ � ����� ������ ������
    Group := APopupMenu.Items;

    // ��������� � ����� ���� ����� ����������, ���� ��� ������� �������������
    if Group.Count <> 0 then
    begin
      Item := TMenuItem.Create(Owner);
      Item.Caption := '-';
      Item.Tag := AddMenuTag;
      Group.Add(Item);
    end;
  end;

  Group.Tag := AddMenuTag;

  // ���������� ���� ����������� ������� � ����� ����
  AddItem('����� �������').OnClick := DoOnTableFont;
  AddItem('���� �������').OnClick := DoOnTableColor;
  AddItem('����� ��������').OnClick := DoOnTableTitleFont;
  AddItem('���� ��������').OnClick := DoOnTableTitleColor;

  if WithColumn then
  begin
    // ��������� ������ � ������� �������
    Group := AddItem('�������');
    if not FUserColors then
    begin
      AddItem('�����').OnClick := DoOnColFont;
      AddItem('����').OnClick := DoOnColColor;
    end;

    // ��������� ������ � ������� ������������
    Item := AddItem('������������');

    CurrItem := AddSubItem(Item, Center);
    CurrItem.GroupIndex := 1;
    CurrItem.RadioItem := True;
    CurrItem.OnClick := DoOnColAlign;
    if PopupColumn.Alignment = taCenter then CurrItem.Checked := True;

    CurrItem := AddSubItem(Item, LeftSide);
    CurrItem.GroupIndex := 1;
    CurrItem.RadioItem := True;
    CurrItem.OnClick := DoOnColAlign;
    if PopupColumn.Alignment = taLeftJustify then CurrItem.Checked := True;

    CurrItem := AddSubItem(Item, RightSide);
    CurrItem.GroupIndex := 1;
    CurrItem.RadioItem := True;
    CurrItem.OnClick := DoOnColAlign;
    if PopupColumn.Alignment = taRightJustify then CurrItem.Checked := True;

    // ��������� ������ � ������� ���������
    Item := AddItem('���������');
    AddSubItem(Item, '�����').OnClick := DoOnColTitleFont;
    AddSubItem(Item, '����').OnClick := DoOnColTitleColor;
    AddSubItem(Item, '�������� ��������').OnClick := DoOnNewTitle;

    // ��������� ������ � ������� ������������
    Item := AddSubItem(Item, '������������');

    CurrItem := AddSubItem(Item, Center);
    CurrItem.GroupIndex := 1;
    CurrItem.RadioItem := True;
    CurrItem.OnClick := DoOnColTitleAlign;
    if PopupColumn.Title.Alignment = taCenter then CurrItem.Checked := True;

    CurrItem := AddSubItem(Item, LeftSide);
    CurrItem.GroupIndex := 1;
    CurrItem.RadioItem := True;
    CurrItem.OnClick := DoOnColTitleAlign;
    if PopupColumn.Title.Alignment = taLeftJustify then CurrItem.Checked := True;

    CurrItem := AddSubItem(Item, RightSide);
    CurrItem.GroupIndex := 1;
    CurrItem.RadioItem := True;
    CurrItem.OnClick := DoOnColTitleAlign;
    if PopupColumn.Title.Alignment = taRightJustify then CurrItem.Checked := True;
  end;
end;

{
  �������� ������� ���������� �������
}

procedure TxUpgradeDBGrid.WMRButtonDown(var Message: TWMLButtonDown);
var
  K: Integer;
begin
  inherited;
  K := MouseCoord(Message.XPos, Message.YPos).X;

  if dgIndicator in Options then
  begin
    if K > 0 then
      PopupColumn := Columns[K - 1]
    else
      PopupColumn := nil;
  end else begin
    if K >= 0 then
      PopupColumn := Columns[K]
    else
      PopupColumn := nil;
  end;

  if (PopupColumn <> nil) and (PopupColumn.PopupMenu <> nil) then
  begin
    OldOnPopup := PopupColumn.PopupMenu.OnPopup;
    PopupColumn.PopupMenu.OnPopup := DoOnPopup;
  end else begin
    OldOnPopup := PopupMenu.OnPopup;
    PopupMenu.OnPopup := DoOnPopup;
  end;
end;

{
  �� �������� ������� ���������� ���������� ����
}

procedure TxUpgradeDBGrid.DoOnDataSetOpen(DataSet: TDataSet);
var
  I: Integer;
begin
  if Assigned(OldOnDataSetOpen) then OldOnDataSetOpen(DataSource.DataSet);

  for I := 0 to Columns.Count - 1 do LoadFromRegistry(Columns.Items[I]);
  FSettingsLoaded := True;
end;

{
  �� �������� ������� ���������� ���������� ������.
}
  
procedure TxUpgradeDBGrid.DoOnDataSetClose(DataSet: TDataSet);
begin
  DataSource.DataSet.AfterOpen := OldOnDataSetOpen;
  DataSource.DataSet.BeforeClose := OldOnDataSetClose;

  if Assigned(OldOnDataSetClose) then OldOnDataSetClose(DataSource.DataSet);

  OldOnDataSetOpen := nil;
  OldOnDataSetClose := nil;
  OldDataSet := nil;

  FSettingsLoaded := False;
end;

{
  �� ��������� � ������ ���������� �������� �� ��������� ���-��
  ������� � Grid-�.
}

procedure TxUpgradeDBGrid.DoOnDataChange(Sender: TObject; Field: TField);
begin
  if Assigned(OldOnDataChange) then OldOnDataChange(Sender, Field);

  if Assigned(DataSource) and Assigned(DataSource.DataSet)
    and (OldDataSet <> DataSource.DataSet) then
  begin
    if Assigned(OldDataSet) then
    begin
      OldDataSet.AfterOpen := OldOnDataSetOpen;
      OldDataSet.BeforeClose := OldOnDataSetClose;
    end;

    OldOnDataSetOpen := DataSource.DataSet.AfterOpen;
    DataSource.DataSet.AfterOpen := DoOnDataSetOpen;

    OldOnDataSetClose := DataSource.DataSet.BeforeClose;
    DataSource.DataSet.BeforeClose := DoOnDataSetClose;

    OldDataSet := DataSource.DataSet;
  end;
end;

{
  �� ��������� ���� ���������� � ���� ���� �����������.
}

procedure TxUpgradeDBGrid.DoOnPopup(Sender: TObject);
begin
  if PopupColumn <> nil  then
  begin
    if PopupColumn.PopupMenu <> nil then
    begin
      CheckPopup(PopupColumn.PopupMenu.Items);
      MakePopupSettings(PopupColumn.PopupMenu, True)
    end else begin
      CheckPopup(PopupMenu.Items);
      MakePopupSettings(PopupMenu, True);
    end;
  end else begin
    CheckPopup(PopupMenu.Items);
    MakePopupSettings(PopupMenu, False);
  end;

  if Assigned(OldOnPopup) then
    OldOnPopup(Sender);

  if (PopupColumn <> nil) and (PopupColumn.PopupMenu <> nil) then
    PopupColumn.PopupMenu.OnPopup := OldOnPopup
  else
    PopupMenu.OnPopup := OldOnPopup;

  OldOnPopup := nil;
end;

{
  �� ������ ������� "����� �������" ���������� ��������� ������� ������
  ������. ���� ����� ����� �������, �� ����������� ��� � �������.
}

procedure TxUpgradeDBGrid.DoOnTableFont(Sender: TObject);
begin
  FontDlg := TFontDialog.Create(Owner);
  FontDlg.Font.Assign(Font);

  try
    if FontDlg.Execute then
    begin
      Font.Assign(FontDlg.Font);
      SaveToRegistry(nil);
    end;
  finally
    FontDlg.Free;
  end;
end;

{
  �� ������ ������� "����� �������� �������" ���������� ��������� ������� ������
  ������. ���� ����� ����� �������, �� ����������� ��� � �������.
}

procedure TxUpgradeDBGrid.DoOnTableTitleFont(Sender: TObject);
begin
  FontDlg := TFontDialog.Create(Owner);
  FontDlg.Font.Assign(TitleFont);

  try
    if FontDlg.Execute then
    begin
      TitleFont.Assign(FontDlg.Font);
      SaveToRegistry(nil);
    end;
  finally
    FontDlg.Free;
  end;
end;

{
  �� ������ ������� "�����" ���������� ��������� ������� ������
  ������. ���� ����� ����� �������, �� ����������� ��� � �������.
}

procedure TxUpgradeDBGrid.DoOnColFont(Sender: TObject);
begin
  FontDlg := TFontDialog.Create(Owner);

  if Sender is TMenuItem then
    FontDlg.Font.Assign(PopupColumn.Font);

  try
    if FontDlg.Execute then
    begin
      PopupColumn.Font.Assign(FontDlg.Font);
      SaveToRegistry(PopupColumn);
    end;
  finally
    FontDlg.Free;
  end;
end;

{
  �� ������ ������� "�����" ���������� ��������� ������� ������
  ������. ���� ����� ����� �������, �� ����������� ��� � �������� �������.
}

procedure TxUpgradeDBGrid.DoOnColTitleFont(Sender: TObject);
begin
  FontDlg := TFontDialog.Create(Owner);

  if Sender is TMenuItem then
    FontDlg.Font.Assign(PopupColumn.Title.Font);

  try
    if FontDlg.Execute then
    begin
      PopupColumn.Title.Font.Assign(FontDlg.Font);
      SaveToRegistry(PopupColumn);
    end;
  finally
    FontDlg.Free;
  end;
end;

{
  �� ������ ������� "���� �������" ���������� ��������� ������� ������
  �����. ���� ����� ���� �������, �� ����������� ��� � �������.
}

procedure TxUpgradeDBGrid.DoOnTableColor(Sender: TObject);
begin
  ColorDlg := TColorDialog.Create(Owner);
  ColorDlg.Color := Color;

  try
    if ColorDlg.Execute then
    begin
      Color := ColorDlg.Color;
      SaveToRegistry(nil);
    end;
  finally
    ColorDlg.Free;
  end;
end;

{
  �� ������ ������� "���� �������" ���������� ��������� ������� ������
  �����. ���� ����� ���� �������, �� ����������� ��� � �������.
}

procedure TxUpgradeDBGrid.DoOnTableTitleColor(Sender: TObject);
begin
  ColorDlg := TColorDialog.Create(Owner);
  ColorDlg.Color := FixedColor;

  try
    if ColorDlg.Execute then
    begin
      FixedColor := ColorDlg.Color;
      SaveToRegistry(nil);
    end;
  finally
    ColorDlg.Free;
  end;
end;

{
  �� ������ ������� "����" ���������� ��������� ������� ������
  �����. ���� ����� ���� �������, �� ����������� ��� � ������ �������.
}

procedure TxUpgradeDBGrid.DoOnColColor(Sender: TObject);
begin
  ColorDlg := TColorDialog.Create(Owner);
  ColorDlg.Color := PopupColumn.Color;

  try
    if ColorDlg.Execute then
    begin
      PopupColumn.Color := ColorDlg.Color;
      SaveToRegistry(PopupColumn);
    end;
  finally
    ColorDlg.Free;
  end;
end;

{
  �� ������ ������� "����" ���������� ��������� ������� ������
  �����. ���� ����� ���� �������, �� ����������� ��� � ������ �������� �������.
}

procedure TxUpgradeDBGrid.DoOnColTitleColor(Sender: TObject);
begin
  ColorDlg := TColorDialog.Create(Owner);
  ColorDlg.Color := PopupColumn.Title.Color;

  try
    if ColorDlg.Execute then
    begin
      PopupColumn.Title.Color := ColorDlg.Color;
      SaveToRegistry(PopupColumn);
    end;
  finally
    ColorDlg.Free;
  end;
end;

{
  �� ������ ������� "������������" � ������ ���������������� ��� ����
  ����������� ��������� � �������.
}

procedure TxUpgradeDBGrid.DoOnColAlign(Sender: TObject);
begin
  if AnsiCompareText((Sender as TMenuItem).Caption, Center) = 0 then
    PopupColumn.Alignment := taCenter
  else if AnsiCompareText((Sender as TMenuItem).Caption, LeftSide) = 0 then
    PopupColumn.Alignment := taLeftJustify
  else if AnsiCompareText((Sender as TMenuItem).Caption, RightSide) = 0 then
    PopupColumn.Alignment := taRightJustify;

  (Sender as TMenuItem).Checked := True;
  SaveToRegistry(PopupColumn);
end;

{
  �� ������ ������� "������������" � ������ ���������������� ��� ����
  ����������� ��������� ��� ����� ������� � �������.
}

procedure TxUpgradeDBGrid.DoOnColTitleAlign(Sender: TObject);
begin
  if AnsiCompareText((Sender as TMenuItem).Caption, Center) = 0 then
    PopupColumn.Title.Alignment := taCenter
  else if AnsiCompareText((Sender as TMenuItem).Caption, LeftSide) = 0 then
    PopupColumn.Title.Alignment := taLeftJustify
  else if AnsiCompareText((Sender as TMenuItem).Caption, RightSide) = 0 then
    PopupColumn.Title.Alignment := taRightJustify;

  (Sender as TMenuItem).Checked := True;
  SaveToRegistry(PopupColumn);
end;

{
  �� ������ ������� ���� "�������� ��������" ����������� ������ �������
  ������ �������� ������� � ����� ������������� � �������.
}

procedure TxUpgradeDBGrid.DoOnNewTitle(Sender: TObject);
var
  AskTitle: TForm;
  editTitle: TEdit;
  btnOk, btnCancel: TButton;
begin
  AskTitle := TForm.Create(Owner);
  try
    AskTitle.Width := 300;
    AskTitle.Height := 86;
    AskTitle.Caption := '�������� �������';
    AskTitle.BorderStyle := bsDialog;
    AskTitle.Position := poScreenCenter;

    editTitle := TEdit.Create(Owner);
    editTitle.Left := 4;
    editTitle.Top := 4;
    editTitle.Width := 286;

    btnOk := TButton.Create(Owner);
    btnOk.Left := 4;
    btnOk.Top := 30;
    btnOk.Width := 100;
    btnOk.Caption := '&Ok';
    btnOk.ModalResult := mrOk;
    btnOk.Default := True;

    btnCancel := TButton.Create(Owner);
    btnCancel.Left := 114;
    btnCancel.Top := 30;
    btnCancel.Width := 100;
    btnCancel.Caption := '&Cancel';
    btnCancel.ModalResult := mrCancel;
    btnCancel.Cancel := True;

    AskTitle.InsertControl(editTitle);
    AskTitle.InsertControl(btnOk);
    AskTitle.InsertControl(btnCancel);

    editTitle.Text := PopupColumn.Title.Caption;

    if AskTitle.ShowModal = mrOk then
    begin
      PopupColumn.Title.Caption := editTitle.Text;
      SaveToRegistry(PopupColumn);
    end;
  finally
    AskTitle.Free;
  end;
end;

{
  ���������� ���������� ������ �� Registry MS Windows.
  ���� ColNum = -1, �� ��������� ��������� ����� ��� ���� �������,
  ���� ���, �� ��������� ������ ��� ������������ �������
}

procedure TxUpgradeDBGrid.LoadFromRegistry(Column: TColumn);
var
  CommonKey: String;
begin
  // ����� ���� � Registry
  if Assigned(DataSource) and Assigned(DataSource.DataSet) then
    CommonKey := Name + '\' + DataSource.DataSet.Name +  '\��������� �������'
  else
    CommonKey := Name + '\Without table\��������� �������';

  if Column = nil then // ���� ����� ������� ������ ������� ���������
  begin
    Color := AppRegistry.ReadColor(CommonKey, 'Color', Color);
    FixedColor := AppRegistry.ReadColor(CommonKey, 'FixedColor', FixedColor);
    AppRegistry.ReadFont(CommonKey, 'Font', Font);
    AppRegistry.ReadFont(CommonKey, 'TitleFont', TitleFont);
  end else begin // ���� ����� ������� ��������� �� ����� �� �������
    CommonKey := CommonKey + '\Field ' + Column.FieldName;
    Column.Width := AppRegistry.ReadInteger(CommonKey, 'Width', Column.Width);
    Column.Color := AppRegistry.ReadColor(CommonKey, 'Color', Color);
    Column.Alignment := TAlignment(AppRegistry.ReadInteger(CommonKey, 'Alignment',
      Integer(Column.Alignment)));
    AppRegistry.ReadFont(CommonKey, 'Font', Column.Font);

    CommonKey := CommonKey + '\Title';
    Column.Title.Color := AppRegistry.ReadColor(CommonKey, 'Color', FixedColor);
    Column.Title.Alignment := TAlignment(AppRegistry.ReadInteger(CommonKey, 'Alignment',
      Integer(Column.Title.Alignment)));
    Column.Title.Caption := AppRegistry.ReadString(CommonKey, 'Title', Column.Title.Caption);
    AppRegistry.ReadFont(CommonKey, 'Font', Column.Title.Font);
  end;
end;

{
  ��������� ���������� ������ ������ ������� ��� ����� ������
  � Registry MS Windows.
}

procedure TxUpgradeDBGrid.SaveToRegistry(Column: TColumn);
var
  CommonKey: String;
begin
  if not FSettingsLoaded then Exit;
  // ����� ���� � Registry
  if Assigned(DataSource) and Assigned(DataSource.DataSet) then
    CommonKey := Name + '\' + DataSource.DataSet.Name +  '\��������� �������'
  else
    CommonKey := Name + '\Without table\��������� �������';

  if Column = nil then // ���� ����� ������� ������ ������� ���������
  begin
    AppRegistry.WriteColor(CommonKey, 'Color', Color);
    AppRegistry.WriteColor(CommonKey, 'FixedColor', FixedColor);
    AppRegistry.WriteFont(CommonKey, 'Font', Font);
    AppRegistry.WriteFont(CommonKey, 'TitleFont', TitleFont);
  end else begin // ���� ����� ������� ��������� �� ����� �� �������
    CommonKey := CommonKey + '\Field ' + Column.FieldName;
    AppRegistry.WriteInteger(CommonKey, 'Width', Column.Width);
    AppRegistry.WriteColor(CommonKey, 'Color', Column.Color);
    AppRegistry.WriteInteger(CommonKey, 'Alignment', Integer(Column.Alignment));
    AppRegistry.WriteFont(CommonKey, 'Font', Column.Font);

    CommonKey := CommonKey + '\Title';
    AppRegistry.WriteColor(CommonKey, 'Color', Column.Title.Color);
    AppRegistry.WriteInteger(CommonKey, 'Alignment', Integer(Column.Title.Alignment));
    AppRegistry.WriteString(CommonKey, 'Title', Column.Title.Caption);
    AppRegistry.WriteFont(CommonKey, 'Font', Column.Title.Font);
  end;
end;

{
  �� ��������� ������ DataSource ���������� ���� ���������
}

procedure TxUpgradeDBGrid.SetDataSource;
var
  I: Integer;
begin
  if not (csLoading in ComponentState) and not (csDesigning in ComponentState) then
    if Assigned(DataSource) then
    begin
      DataSource.OnDataChange := OldOnDataChange;
      if Assigned(DataSource.DataSet) then
      begin
        DataSource.DataSet.AfterOpen := OldOnDataSetOpen;
        DataSource.DataSet.BeforeClose := OldOnDataSetClose;

        OldOnDataSetOpen := nil;
        OldOnDataSetClose := nil;
      end;
    end;

  inherited DataSource := ADataSource;

  if not (csDesigning in ComponentState) then
    if Assigned(DataSource) then
    begin
      OldDataSet := DataSource.DataSet;

      OldOnDataChange := DataSource.OnDataChange;
      DataSource.OnDataChange := DoOnDataChange;

      if Assigned(DataSource.DataSet) then
      begin
        FSettingsLoaded := False;
        OldOnDataSetOpen := DataSource.DataSet.AfterOpen;
        DataSource.DataSet.AfterOpen := DoOnDataSetOpen;

        OldOnDataSetClose := DataSource.DataSet.BeforeClose;
        DataSource.DataSet.BeforeClose := DoOnDataSetClose;

        if DataSource.DataSet.Active then
        begin
          for I := 0 to Columns.Count - 1 do LoadFromRegistry(Columns.Items[I]);
          FSettingsLoaded := True;
        end;  
      end;
    end;
end;

{
  �������� DataSource
}

function TxUpgradeDBGrid.GetDataSource;
begin
  Result := inherited DataSource;
end;

{
  �������� PopupMenu.
}

function TxUpgradeDBGrid.GetPopup: TPopupMenu;
begin
  Result := inherited PopupMenu;
end;

{
  �������� ����� PopupMenu
}

procedure TxUpgradeDBGrid.SetPopup(APopupMenu: TPopupMenu);
begin
  if Assigned(APopupMenu) then
    inherited PopupMenu := APopupMenu
  else begin
    if MyPopupMenu = nil then MyPopupMenu := TPopupMenu.Create(Owner);
    inherited PopupMenu := MyPopupMenu;
  end;
end;

{
  �������� ��� PopupMenu
}

function TxUpgradeDBGrid.GetPopupKind: TPopupKind;
begin
  Result := FPopupKind;
end;

{
  ������������� ����� �������� ���� PopupMenu
}

procedure TxUpgradeDBGrid.SetPopupKind(APopupKind: TPopupKind);
begin
  FPopupKind := APopupKind;
end;

{
  ������������� ���� ��� ������ ������
}

procedure TxUpgradeDBGrid.SetRowColor1(ARowColor: TColor);
begin
  FRowColor1 := ARowColor;
  if FUserColors then Invalidate;
end;

{
  ������������� ���� ��� ������ ������
}

procedure TxUpgradeDBGrid.SetRowColor2(ARowColor: TColor);
begin
  FRowColor2 := ARowColor;
  if FUserColors then Invalidate;
end;

{
  ������������� ���� ������������� ������ ��� ������ � ������ ������ � �.�.
}

procedure TxUpgradeDBGrid.SetUserColors(AUserColors: Boolean);
begin
  FUserColors := AUserColors;
  Invalidate;
end;

{
  ������������� ���� ���������� ����� Gird-�
}

procedure TxUpgradeDBGrid.SetSelectedColor(const Value: TColor);
begin
  FSelectedColor := Value;
  Invalidate;
end;

{
  **********************
  **  Protected Part  **
  **********************
}

{
  ����� ��������� �������� ���� properties ���������� ���� ���������.
}

procedure TxUpgradeDBGrid.Loaded;
begin
  inherited Loaded;

  if not (csDesigning in ComponentState) then
  begin
    if PopupMenu = nil then
    begin
      if MyPopupMenu = nil then MyPopupMenu := TPopupMenu.Create(Owner);
      inherited PopupMenu := MyPopupMenu;
    end;
    
    LoadFromRegistry(nil);
  end;
end;

{
  ���������� ����������� ������ grid-�
}

procedure TxUpgradeDBGrid.DrawCell(ACol, ARow: Longint; ARect: TRect;
  AState: TGridDrawState);
var
  OldActive: LongInt;
  HighLight: Boolean;
  Value: string;
  DrawColumn: TColumn;
begin
  // ����������� ���������� �������������� ������ � Runtime ������!
  if (gdFixed in AState) or not FUserColors
  then
    inherited DrawCell(ACol, ARow, ARect, AState)
  else with Canvas do
  begin
    DrawColumn := Columns[ACol - Integer(dgIndicator in Options)];

    Font := DrawColumn.Font;
    Brush.Color := DrawColumn.Color;

    if (DataLink = nil) or not DataLink.Active then
    begin // ���� ������ ���, �� ������ ������� �������������
      FillRect(ARect);
    end else begin

      Value := '';
      OldActive := DataLink.ActiveRecord;
      try
        DataLink.ActiveRecord := ARow - Integer(dgTitles in Options);

        if Assigned(DrawColumn.Field) then Value := DrawColumn.Field.DisplayText;
        Highlight := HighlightCell(ACol, ARow, Value, AState);

        // ������ �����
        if Highlight then
        begin
          Brush.Color := FSelectedColor;
        end else begin
          if (ARow mod 2) = 0 then
            Brush.Color := FRowColor2
          else
            Brush.Color := FRowColor1;

          Font := DrawColumn.Font;
        end;

        if DefaultDrawing then
          WriteText(Canvas, ARect, 2, 2, Value, DrawColumn.Alignment,
            UseRightToLeftAlignmentForField(DrawColumn.Field, DrawColumn.Alignment));

        if Columns.State = csDefault then
          DrawDataCell(ARect, DrawColumn.Field, AState);

        DrawColumnCell(ARect, ACol, DrawColumn, AState);
      finally
        DataLink.ActiveRecord := OldActive;
      end;

      // ������ Focus
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
end;

{
  �� ������������ grid-� ������ ���� ��������
}

procedure TxUpgradeDBGrid.Scroll(Distance: Integer);
begin
  inherited Scroll(Distance);
  Invalidate;
end;

{
  ���������� ������ grid-������ �������
}

procedure TxUpgradeDBGrid.ColWidthsChanged;
var
  I: Integer;
begin
  inherited ColWidthsChanged;
  
  SaveToRegistry(nil);
  for I := 0 to Columns.Count - 1 do SaveToRegistry(Columns.Items[I]);
end;

{
  *******************
  **  Public Part  **
  *******************
}

{
  ������ ��������� ���������
}

constructor TxUpgradeDBGrid.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FSettingsLoaded := False;
  FUserColors := False;
  FPopupKind := pkItem;
  // ���-�� �������������
  if UserCount = 0 then
    DrawBitmap := TBitmap.Create;

  Inc(UserCount);

  FRowColor1 := Color;
  FRowColor2 := Color;
  FSelectedColor := clHighLight;

  PopupColumn := nil;
  MyPopupMenu := nil;
end;

{
  ������������ ������
}

destructor TxUpgradeDBGrid.Destroy;
begin
  if Assigned(DataSource) and Assigned(DataSource.DataSet) then
  begin
    DataSource.DataSet.AfterOpen := OldOnDataSetOpen;
    DataSource.DataSet.BeforeClose := OldOnDataSetClose;
    DataSource.OnDataChange := OldOnDataChange;
  end;

  OldOnDataSetOpen := nil;
  OldOnDataSetClose := nil;
  OldDataSet := nil;

  Dec(UserCount);
  if (UserCount <= 0) and (DrawBitmap <> nil) then
  begin
    DrawBitmap.Free;
    DrawBitmap := nil;
  end;

  inherited Destroy;
end;

{
  �������� �� ������� ������ ����������� � PopupMenu � �������� ��
}

procedure TxUpgradeDBGrid.CheckPopup(AMenu: TMenuItem);
var
  K: Integer;
begin
  for K := AMenu.Count - 1 downto 0 do
    if AMenu.Items[K].Tag = AddMenuTag then AMenu.Delete(K);
end;

{
  ����������� ����������
}

procedure Register;
begin
  RegisterComponents('gsDB', [TxUpgradeDBGrid]);
end;

end.

