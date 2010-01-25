
{++

  Copyright (c) 1999 by Golden Software of Belarus

  Module

    xSmartToolBar.pas

  Abstract

    An ordinary tool bar with a list of standart tool buttons.

  Author

    Romanovski Denis (17-02-99)

  Revisions history

    Initial  17-02-99  Dennis  Initial version.
    Beta1    18-02-99  Dennis  Everything works!
    Beta2    22-02-99  Dennis  Bugs fixed.
    Beta3    23-02-99  Dennis  Bugs fixed.
--}

{
  �������� ������ � ������ �����������:
  1. � ������ ������� ��� ������������� ������ ���������� ���������� � Design
     ������ ������� ActionList.
  2. � ���� ������ ���������� ������� �������� � ������� �� �� ������ � �����
     �������, � ����� ���������� �� ���������� � Tool Bar-�. ��������� �� ������
     ������������ ��� ������ �������� � ������ �������� �������� ���������
     (Category - ��� ��������� ����� ���� �����).
  3. ���� ������������ �����, ����� ������ � Tool Bar-� ����� ������� ���������������
     ������ ����������� (�.�. "�������" � ����), �� ������ ������ ������� ����������
     ������� � �������� �������� Tag. ������ �������� �������� ����� �����������
     ����.
  4. ���� �� ������� ��� ������ �� ������������, �� ��� ���������� �������� �
     ��������� ImageList (�.�. ImageList ����� ������� � Design ������), � ��� ImageList
     ��������� ������ �������� (Images). ������ ������� ����� ��������� �������� ��������
     ImageIndex. �������� Tag ��� ���� ������ ���� ����� 0.
  5. ����� ���������� �������, ���, ���� ������������ ���������� �����������
     "�������" � ���� �������, �� ������������ ��� ������� ������� �����
     ����� �������� "�������" � ���� Hint (��� �������, ��� Hint ����� '', ����� -
     ����� �������������� Hint ��������, ����������� �������������).

  ��������!

     ���� �� ����������� ��������� �������� ����������� ������ � ������ ����������, ��
     ��� ����������:
       �) ������� ���� xSmartToolBar.res
       �) � ����� bitmap-� �������� �������� �����
       �) ��������� ������� InternalButtonCount
       �) �������� Hint � ������ StandartHint
       �) ������������������ ������ ������� � ��� ������� ��������.
}

unit xSmartToolBar;

interface

uses
  Windows,        Messages,       SysUtils,       Classes,        Graphics,
  Controls,       Forms,          Dialogs,        ToolWin,        ComCtrls,
  ActnList;

type
  TxSmartToolBar = class(TToolBar)
  private
    FActions: TActionList; // ������ ��������
    FImageList: TImageList; // ������ ��������

    procedure SetActions(const Value: TActionList);
    
    function GetToolButtonByAction(AnAction: TAction): TToolButton;
    
    procedure ScanActionList;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Loaded; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
    
    procedure ShowCategory(Category: String; ShowIt: Boolean);

    // ������ �� ��������
    property ButtonByAction[AnAction: TAction]: TToolButton read GetToolButtonByAction;
  published
    // ������ ��������
    property Actions: TActionList read FActions write SetActions;
    
  end;

procedure Register;

implementation

uses ImgList;

// ���������� ������ ������ ��������
{$R xSmartToolBar}

// ������ ������ �� ��������� ��������
type
  TCategory = record
    Name: String; // ������������ ������
    Buttons: set of Byte; // ������ ������
   end;

const
  // ���������� ����������� ���������
  CategoryCount = 9;

  // ����� ���������� ������
  InternalButtonCount = 30;
  // ��������� �� ���������.
  CustomCategory = 8;

  // ����� ��� ����������� ���������
  StandartHint: array[1..InternalButtonCount] of String =
    (
    '��������',
    '�������������',
    '����������',
    '�������',
    '������� ���',
    '�����',
    '����� ���������',
    '����� � ��������',
    '��������� ������',
    '��������',
    '����������(������) ������',
    '������� ������',
    '���������',
    '���������',
    '�������',
    '�������� �������',
    '�������� ����������',
    '������� �������',
    '������� ��� ���������',
    '�������� ������',
    '������������� ������',
    '��������',
    '������',
    '������',
    '��������',
    '����������',
    '��������',
    '�������� ���',
    '��������',
    '�������'
    );

{
  ������� �������� ������

  ��������������:
  1 - ��������               10
  2 - ������������           11
  3 - ����������             12
  4 - �������                13
  5 - ������� ���            14

  �����:
  6 - �����                  20
  7 - ����� ���������        21
  8 - ����� � ��������       22

  ��������:
  9 - ��������� ������
  10 - �������� (������� ������ ������)

  ������:
  11 - ����������/������ ������
  12 - ������� ������

  ����:
  13 - ���������
  14 - ���������
  15 - �������

  ������:
  16 - �������� �������
  17 - �������� ����������
  18 - ������� �������
  19 - ������� ��� ���������
  20 - �������� ������
  21 - ������������� ������

  ������:
  22 - ��������
  23 - ������

  ������:
  24 - ������

  ������ � clipboard-��:
  25 - ��������
  26 - ����������
  27 - ��������
  28 - �������� ���

  ��������/�������:
  29 - ��������
  30 - �������
}

{
  �������� ������ ���� ��������!
}

{
  ***********************
  ***   Public Part   ***
  ***********************
}

{
  ������������ ��������� ���������.
}

constructor TxSmartToolBar.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FActions := nil;
                            
  ShowHint := True;
  Transparent := True;
  Flat := True;

  // ��������� ������� � ��������� �� � ������.
  if not (csDesigning in ComponentState) then
  begin
    FImageList := TImageList.Create(Owner);
    FImageList.Width := 18;
    FImageList.Height := 17;
    FImageList.GetResource(rtBitmap, 'SMARTBUTTONS', 18, [lrDefaultColor], clSilver);
  end;
end;

{
  �������������� ������. �������� ���������.
}

destructor TxSmartToolBar.Destroy;
begin
  inherited Destroy;
end;

{
  ������ ��� ��������� ������� (���������) �� "�����" Show.
}

procedure TxSmartToolBar.ShowCategory(Category: String; ShowIt: Boolean);
var
  I: Integer;
  L, F: Integer;
begin
  L := -1;
  F := -1;

  for I := 0 to ButtonCount - 1 do
    if (Buttons[I].Action <> nil) and
      (AnsiCompareText((Buttons[I].Action as TAction).Category, Category) = 0) then
    begin
      Buttons[I].Visible := ShowIt;

      if F = -1 then F := I;
      L := I;
    end;

  if (F > 0) and (Buttons[F - 1].Style = tbsSeparator) then
    Buttons[F - 1].Visible := ShowIt
  else if (L < ButtonCount - 1) and (Buttons[L + 1].Style = tbsSeparator) then
    Buttons[L + 1].Visible := ShowIt;

  // ����� �������� ���������� ������ Borland ���������� ����� �������� ���� Tool Bar-�.  
  RecreateWnd;
end;

{
  **************************
  ***   Protected Part   ***
  **************************
}

{
  ���� ������������ ������� ������ ��������, �� ���������� ������� ������������ ���������
  � ����������.
}

procedure TxSmartToolBar.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if (Operation = opRemove) and (AComponent = FActions) then
    Actions := nil;
end;

{
  �� �������� ���������� ������ ���� ���������.
}

procedure TxSmartToolBar.Loaded;
var
  I: Integer;
begin
  inherited Loaded;

  // ������������� ���������� ������ ������ ������ ������������
  if not (csDesigning in ComponentState) then
  begin
    Images := FImageList;

    // ������� ��� ������, ����������� ������������� � Design ������.
    for I := 0 to ButtonCount - 1 do Buttons[0].Free;

    // ������� ������ �������
    while FImageList.Count > InternalButtonCount do FImageList.Delete(FImageList.Count - 1);
    if (FActions <> nil) and (FActions.Images <> nil) then FImageList.AddImages(FActions.Images);

    // ������� ����������� ������ ������.
    ScanActionList;
  end;
end;

{
  ************************
  ***   Private Part   ***
  ************************
}

{
  ��������� ������ ��������.
}

procedure TxSmartToolBar.SetActions(const Value: TActionList);
var
  I: Integer;
begin
  if FActions <> Value then
  begin
    FActions := Value;

    if (FActions <> nil) and not (csDesigning in ComponentState) then
      if not (csLoading in ComponentState) then
      begin
        // ������� ������ �������
        while FImageList.Count > InternalButtonCount do FImageList.Delete(FImageList.Count - 1);

        if FActions.Images <> nil then FImageList.AddImages(FActions.Images);

        // ������� ��� ������, ����������� ������������� � Design ������.
        for I := 0 to ButtonCount - 1 do Buttons[0].Free;

        // ������� ����������� ������ ������.
        ScanActionList;
      end;
  end;
end;

{
  �� �������� ���������� ������ �� ������.
}

function TxSmartToolBar.GetToolButtonByAction(AnAction: TAction): TToolButton;
var
  I: Integer;
begin
  Result := nil;
  
  for I := 0 to ButtonCount - 1 do
    if Buttons[I].Action = AnAction then
    begin
      Result := Buttons[I];
      Break;
    end;
end;

{
  ��������� ������ �������� � �� ��������� ��� ��������� Tool Bar.
}

procedure TxSmartToolBar.ScanActionList;
var
  I: Integer;
  CurrCategory: String;
  T: TToolButton;
  SortList: TList;

  // ���������� ������ �������
  function GetImageIndex(AnAction: TContainedAction): Integer;
  begin
    if AnAction.Tag in [1..InternalButtonCount] then
    begin
      Result := AnAction.Tag - 1;

      if TAction(AnAction).Hint = '' then
        TAction(AnAction).Hint := StandartHint[AnAction.Tag];
    end else begin
      if TAction(AnAction).ImageIndex = -1 then
        Result := -1
      else
        Result := InternalButtonCount + TAction(AnAction).ImageIndex;
    end;
  end;

  // �������, ���� ����� ��������� ����� ������
  function GetStartPosition: Integer;
  begin
    if ButtonCount > 0 then
      Result := Buttons[ButtonCount - 1].Left + Buttons[ButtonCount - 1].Width
    else
      Result := 0;
  end; 

  // ������� ������������� ������ ��������
  procedure MakeSortedActionList;
  var
    K, L: Integer;
    Cat: String;
  begin
    for K := 0 to FActions.ActionCount - 1 do
      // ���� ����� ���������,
      if (K = 0) or (Cat <> FActions[K].Category) then
      begin
        // �� ����������� ��
        Cat := FActions[K].Category;

        // ��������� ��� �������� �� ������ ���������
        for L := 0 to FActions.ActionCount - 1 do
          if (FActions[L].Category = Cat) and (SortList.IndexOf(FActions[L]) = -1) then
            SortList.Add(FActions[L]);
      end;
  end;

begin
  // ���� ������ �������� �� ��������, �� �� ���������� ������� ���������.
  if FActions = nil then Exit;

  SortList := TList.Create;

  try
    // ������� ������������� ������ ��������
    MakeSortedActionList;

    CurrCategory := '';

    // ��������� ������
    for I := 0 to SortList.Count - 1 do
    begin
      // ���� ����� ������ ���������
      if I = 0 then
        CurrCategory := TAction(SortList[I]).Category
      // ���� ����� ���������, �� ��������� �����������
      else if CurrCategory <> TAction(SortList[I]).Category then
      begin
        CurrCategory := TAction(SortList[I]).Category;
        T := TToolButton.Create(Owner);
        InsertControl(T);
        T.Style := tbsSeparator;
        T.Left := GetStartPosition;
      end;

      // ��������� ������
      T := TToolButton.Create(Owner);
      InsertControl(T);
      T.Action := TAction(SortList[I]);
      T.ImageIndex := GetImageIndex(TAction(SortList[I]));
      T.Left := GetStartPosition;
    end;
  finally
    SortList.Free;
  end;
end;

{
  **********************************
  ***   Registration Procedure   ***
  **********************************
}

procedure Register;
begin
  RegisterComponents('gsVC', [TxSmartToolBar]);
end;

end.

