
{++

  Copyright (c) 2002 by Golden Software of Belarus

  Module

    gsCollectionEditor.pas

  Abstract

    Gedemin project. Collection Editor for TActionList in GEDEMIN Designer.

  Author

    Alexander Dubrovnik

  Revisions history

    1.00    18.03.2002    DAlex        Initial version.

--}

unit gsCollectionEditor;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Menus, ComCtrls, ToolWin, ImgList, ActnList, gsResizerInterface,
  ExtCtrls;

const
  ceAllCategory = '(Все)';
  ceNoneCategory = '(Отсутствует)';

  ceCaption = 'Редактор коллекции:  ';
type
  TFrmCollectionEditor = class(TForm)
    TlBrActions: TToolBar;
    TlBtnAdd: TToolButton;
    TlBtnDelete: TToolButton;
    ToolButton3: TToolButton;
    TlBtnUp: TToolButton;
    TlBtnDown: TToolButton;
    ilMain: TImageList;
    ToolButton1: TToolButton;
    popupMain: TPopupMenu;
    PMAddAction: TMenuItem;
    PMDeleteAction: TMenuItem;
    pnlCategories: TPanel;
    pnlActions: TPanel;
    LblCategories: TLabel;
    LstBxCategories: TListBox;
    LblActions: TLabel;
    LstBxActions: TListBox;
    procedure LstBxCategoriesClick(Sender: TObject);
    procedure LstBxActionsExit(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LstBxActionsClick(Sender: TObject);
    procedure TlBtnUpClick(Sender: TObject);
    procedure TlBtnDownClick(Sender: TObject);
    procedure TlBtnDeleteClick(Sender: TObject);
    procedure TlBtnAddClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure PMDeleteActionClick(Sender: TObject);
    procedure PMAddActionClick(Sender: TObject);
  private
    FActionListCol: TActionList;
    FManager: IgsResizeManager;
    FActionName: String;

    // метод заполняет LstBxCategories.Items категориями ActionList
    procedure SetCategoriesList;
    // метод обновляет LstBxCategories и LstBxActions
    procedure Plase;

    // метод возвращает текущий Action
    function GetActionFromList: TCustomAction;
  public
    constructor Create(AOwner: TComponent); override;

    // метод вызывает редактор коллекции и привязывает
    // переданный ActionList к инспектору объектов
    procedure ShowCollectionEditor(
      const AManager: TComponent;
      AnActionListCol: TActionList);

    property ActionListCol: TActionList read FActionListCol write FActionListCol;
  end;

var
  FrmCollectionEditor: TFrmCollectionEditor;

implementation

uses
  gsComponentEmulator, gsResizer;

type
  TComponentCracker = class(TComponent);

{$R *.DFM}

{ TForm2 }

constructor TFrmCollectionEditor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

procedure TFrmCollectionEditor.ShowCollectionEditor(
      const AManager: TComponent;
      AnActionListCol: TActionList);
begin
  if Assigned(AManager  ) then
    FManager := TgsResizeManager(AManager)
  else
    raise Exception.Create('Не передан ObjectInspector');

  if Assigned(AnActionListCol) then
    ActionListCol := AnActionListCol
  else
    ActionListCol := TActionList.Create(Self);
  SetCategoriesList;
  Caption := ceCaption + ActionListCol.Name;
  Show;
end;

procedure TFrmCollectionEditor.LstBxCategoriesClick(Sender: TObject);
var
  LocCount: Integer;
  LocCategory: String;
begin
  LstBxActions.Items.Clear;

  if LstBxCategories.ItemIndex = -1 then
    LstBxCategories.ItemIndex := 0;

  for LocCount := 0 to ActionListCol.ActionCount - 1 do
  begin
    if LstBxCategories.ItemIndex > -1 then
      LocCategory := LstBxCategories.Items[LstBxCategories.ItemIndex]
    else
      LocCategory := ceNoneCategory;
    if LocCategory = ceNoneCategory then
      LocCategory := '';
    if AnsiUpperCase(LstBxCategories.Items[LstBxCategories.ItemIndex]) = AnsiUpperCase(ceAllCategory) then
      LstBxActions.Items.Add(ActionListCol.Actions[LocCount].Name)
    else
      if AnsiUpperCase(LocCategory) = AnsiUpperCase(ActionListCol.Actions[LocCount].Category) then
        LstBxActions.Items.Add(ActionListCol.Actions[LocCount].Name);
  end;
end;

procedure TFrmCollectionEditor.LstBxActionsExit(Sender: TObject);
begin
  TlBtnDelete.Enabled := False;
  TlBtnUp.Enabled := False;
  TlBtnDown.Enabled := False;
  PMDeleteAction.Enabled := False;
end;

procedure TFrmCollectionEditor.FormShow(Sender: TObject);
begin
  TlBtnDelete.Enabled := False;
  TlBtnUp.Enabled := False;
  TlBtnDown.Enabled := False;
  PMDeleteAction.Enabled := False;
end;

procedure TFrmCollectionEditor.LstBxActionsClick(Sender: TObject);
var
  LocCustomAction: TCustomAction;
begin
  // проверка делает неактивной кнопку удаления для акшинов Delphi
  if (LstBxActions.ItemIndex > -1) and
    ((Pos(USERCOMPONENT_PREFIX, LstBxActions.Items[LstBxActions.ItemIndex]) = 1) or
    ((FManager.DesignerType = dtGlobal) and (Pos(GLOBALUSERCOMPONENT_PREFIX, LstBxActions.Items[LstBxActions.ItemIndex]) = 1))) then
  begin
    TlBtnDelete.Enabled := True;
    PMDeleteAction.Enabled := True;
  end else
    begin
      TlBtnDelete.Enabled := False;
      PMDeleteAction.Enabled := False;
    end;

  TlBtnUp.Enabled := True;
  TlBtnDown.Enabled := True;

  if LstBxActions.Items.Count > 0 then
  begin
    LocCustomAction := GetActionFromList;
    if Assigned(LocCustomAction) then
      FManager.AddNonVisibleComponent(GetActionFromList, False);
  end;
end;

procedure TFrmCollectionEditor.TlBtnUpClick(Sender: TObject);
begin
  if LstBxActions.ItemIndex <> 0 then
    LstBxActions.ItemIndex := LstBxActions.ItemIndex - 1;
  LstBxActions.OnClick(Self);
end;

procedure TFrmCollectionEditor.TlBtnDownClick(Sender: TObject);
begin
  if LstBxActions.ItemIndex <> LstBxActions.Items.Count - 1 then
    LstBxActions.ItemIndex := LstBxActions.ItemIndex + 1;
  LstBxActions.OnClick(Self);
end;

procedure TFrmCollectionEditor.TlBtnDeleteClick(Sender: TObject);
var
  Index, TempItemIndex: integer;
begin
  if (LstBxActions.Items.Count > 0) and (LstBxActions.ItemIndex > -1) then
  if (Pos(USERCOMPONENT_PREFIX, LstBxActions.Items[LstBxActions.ItemIndex]) = 1) or
    ((FManager.DesignerType = dtGlobal) and (Pos(GLOBALUSERCOMPONENT_PREFIX, LstBxActions.Items[LstBxActions.ItemIndex]) = 1)) then
  for Index := ActionListCol.ActionCount - 1 downto 0  do
    if AnsiUpperCase(ActionListCol.Actions[Index].Name) = AnsiUpperCase(LstBxActions.Items[LstBxActions.ItemIndex]) then
    begin
      TempItemIndex := LstBxActions.ItemIndex;
      LstBxActions.Items.Delete(LstBxActions.ItemIndex);
      ActionListCol.Actions[Index].Free;
      SetCategoriesList;
      if LstBxActions.Items.Count = 0 then
        LstBxActions.ItemIndex := 0
      else
        if LstBxActions.Items.Count > TempItemIndex then
          LstBxActions.ItemIndex := TempItemIndex
        else
          LstBxActions.ItemIndex := LstBxActions.Items.Count - 1;
      LstBxActions.OnClick(Self);
      FManager.RefreshList;
      Break;
    end;
  if LstBxActions.Items.Count = 0 then
    FManager.RefreshList;
end;

procedure TFrmCollectionEditor.SetCategoriesList;
var
  LocCount, Index: Integer;
begin
  LstBxCategories.Items.Clear;
  LstBxCategories.Items.Add(ceNoneCategory);

  for LocCount := 0 to ActionListCol.ActionCount - 1 do
  begin
    for Index := 0 to LstBxCategories.Items.Count - 1 do
    if AnsiUpperCase(LstBxCategories.Items[Index]) = AnsiUpperCase(ActionListCol.Actions[LocCount].Category) then
      break;
    if (Index = LstBxCategories.Items.Count) and (ActionListCol.Actions[LocCount].Category <> '') then
      LstBxCategories.Items.Add(ActionListCol.Actions[LocCount].Category);
  end;
  LstBxCategories.Items.Add(ceAllCategory);
end;

procedure TFrmCollectionEditor.TlBtnAddClick(Sender: TObject);
var
  LocAction: TgsAction;
begin
  LocAction := TgsAction.Create(FManager.EditForm);
  LocAction.Name :=  FManager.GetNewControlName('TgsAction');
  TComponentCracker(LocAction).SetDesigning(True, False);
  LocAction.Category := '';
  LocAction.ActionList := ActionListCol;
  FManager.RefreshList;

  LstBxCategories.ItemIndex := 0;
  Plase;
  LstBxActions.OnClick(Self);
end;

procedure TFrmCollectionEditor.Plase;
begin
  LstBxCategories.OnClick(Self);
  LstBxActions.ItemIndex := LstBxActions.Items.Count - 1;
  LstBxActions.SetFocus;
  LstBxActions.OnClick(Self);
end;

function TFrmCollectionEditor.GetActionFromList: TCustomAction;
var
  Index: Integer;
begin
  Result := nil;
  if LstBxActions.ItemIndex > -1 then
    FActionName := LstBxActions.Items[LstBxActions.ItemIndex];
  for Index := 0 to ActionListCol.ActionCount - 1 do
    if AnsiUpperCase(ActionListCol.Actions[Index].Name) = AnsiUpperCase(FActionName) then
    begin
      Result := ActionListCol.Actions[Index] as TCustomAction;
      Break;
    end;
end;

procedure TFrmCollectionEditor.FormActivate(Sender: TObject);
var
  Index: Integer;
  LocCustomAction: TCustomAction;

begin
  SetCategoriesList;

  LocCustomAction := GetActionFromList;
  if Assigned(LocCustomAction) then
  begin
    for Index := 0 to LstBxCategories.Items.Count - 1 do
    begin
      if AnsiUpperCase(LstBxCategories.Items[Index]) = AnsiUpperCase(LocCustomAction.Category) then
      begin
        LstBxCategories.ItemIndex := Index;
        LstBxCategoriesClick(Sender);
        Break;
      end;
    end;
    for Index := 0 to LstBxActions.Items.Count - 1 do
    begin
      if AnsiUpperCase(LstBxActions.Items[Index]) = AnsiUpperCase(LocCustomAction.Name) then
      begin
        LstBxActions.ItemIndex := Index;
        LstBxActionsClick(Sender);
        Break;
      end;
    end;
  end else
  begin
    LstBxCategories.ItemIndex := 0;
    LstBxCategoriesClick(Sender);
  end;
end;

procedure TFrmCollectionEditor.FormDeactivate(Sender: TObject);
begin
  if LstBxActions.ItemIndex > -1 then
    FActionName := LstBxActions.Items[LstBxActions.ItemIndex];
end;

procedure TFrmCollectionEditor.PMDeleteActionClick(Sender: TObject);
begin
  TlBtnDeleteClick(Sender);
end;

procedure TFrmCollectionEditor.PMAddActionClick(Sender: TObject);
begin
  TlBtnAddClick(Sender);
end;

end.
