{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    gdcMacrosMenu.pas

  Abstract

    Gedemin project. TgdMacrosMenu.

  Author

    Karpuk Alexander

  Revisions history

    1.00    15.02.02    tiptop        Initial version.

--}
{ TODO :
Данные меню обновляются только при открытии меню
Поэтому при изменении ShortCutов они начинают правильно
работать только после открытия меню.
Необходимо подумоть о способе уведомления об изменении
макросов. }
unit gd_MacrosMenu;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, gdcDelphiObject, scrMacrosGroup, IBDataBase, gdcConstants, ActnList, Contnrs;

type
  TgdMacrosMenu = class(TPopupMenu)
  private
    //FMacrosGroup: TscrMacrosGroup;

    FMacrosGroupList: TObjectList;

    FTransaction: TIBTransaction;
    FActionList: TActionList;

    procedure DoOnMenuClick(Sender: TObject);
    procedure DoOnMacrosListClick(Sender: TObject);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure ReloadGroup;
    procedure Popup(X, Y: Integer); override;
  end;

const
  CST_MacrosMENU = 'Редактор скрипт-объектов';

procedure Register;

implementation

uses
  gdcBaseInterface,          evt_i_Base,             gdcOLEClassList,
  gd_SetDatabase,            gd_i_ScriptFactory,     gs_Exception,
  gd_security_operationconst,gd_Createable_Form,     gd_security,
  Storages,                  gd_ClassList,           gdc_createable_form;

procedure Register;
begin
  RegisterComponents('gdc', [TgdMacrosMenu]);
end;

{ TgdMacrosMenu }

constructor TgdMacrosMenu.Create(AOwner: TComponent);
begin
  inherited;

  if not (csDesigning in ComponentState) then
  begin
    if gdcBaseManager <> nil then
    begin
      FTransaction :=  gdcBaseManager.ReadTransaction;

      FMacrosGroupList := TObjectList.Create(True);

    end else
      raise Exception.Create(GetGsException(Self, 'Database is not assigned'));
  end;
end;

destructor TgdMacrosMenu.Destroy;
begin
  FMacrosGroupList.Free;
  
  inherited;
end;

procedure TgdMacrosMenu.DoOnMenuClick(Sender: TObject);
var
  OwnerForm: IDispatch;
begin
  if Assigned(ScriptFactory) then
  begin
    if not Assigned(ScriptFactory.Transaction) then
      ScriptFactory.Transaction := FTransaction;

    if not Assigned(ScriptFactory.DataBase) then
      ScriptFactory.DataBase := FTransaction.DefaultDatabase;

    OwnerForm := nil;
    if Assigned(Self.Owner) and Self.Owner.InheritsFrom(TCreateableForm) then
    begin
      OwnerForm := GetGdcOLEObject(Self.Owner);
    end;
    ScriptFactory.ExecuteMacros(OwnerForm,
      TscrMacrosItem((TObject(Sender) as TAction).ImageIndex))
  end;
end;

procedure TgdMacrosMenu.DoOnMacrosListClick(Sender: TObject);
begin
  if Assigned(EventControl) then
    EventControl.EditObject(Owner, emMacros);
end;

procedure TgdMacrosMenu.Popup(X, Y: Integer);
begin
  ReloadGroup;
  inherited;
end;

procedure TgdMacrosMenu.ReloadGroup;
var
  gdcDelphiObject: TgdcDelphiObject;
  LocId: Integer;
  FE: TgdFormEntry;

  M: TMenuItem;

  procedure FillMenu(const Parent: TObject; MacrosGroup: TscrMacrosGroup);
  var
    I: Integer;
    M: TMenuItem;
    Index: Integer;
    AddCount: Integer;
    Action: TAction;
  begin
    Assert((Parent is TMenuItem) or (Parent is TPopUpMenu));

    if not Assigned(FActionList) then
      FActionList := TActionList.Create(Owner);

    if (Parent is TMenuItem) then
    begin
      Index := (Parent as TMenuItem).Tag;
      (Parent as TMenuItem).Clear;
    end else
      Index := 0;

    AddCount := 0;
    if (MacrosGroup.Count > 0) and (Index < MacrosGroup.Count) then
    begin
      for I := Index to MacrosGroup.Count - 1 do
      begin
        if MacrosGroup.GroupItems[Index].Id = MacrosGroup.GroupItems[I].Parent then
        begin
          M := TMenuItem.Create(Self);
          M.Tag := I;
//          M.Name := 'G' + IntToStr(MacrosGroup.GroupItems[I].Id);
          M.Caption := MacrosGroup.GroupItems[I].Name;
          if (Parent is TMenuItem) then
            (Parent as TMenuItem).Add(M)
          else
            (Parent as TPopUpMenu).Items.Add(M);
          FillMenu(M, MacrosGroup);
          Inc(AddCount);
        end;
      end;
      for I := 0 to MacrosGroup.GroupItems[Index].MacrosList.Count - 1 do
      begin
        Action := TAction.Create(FActionList);
        Action.Caption := MacrosGroup.GroupItems[Index].MacrosList.Macros[I].Name;;
//        Action.Name := 'A' + IntToStr(MacrosGroup.GroupItems[Index].MacrosList.Macros[I].Id);
        Action.ShortCut := MacrosGroup.GroupItems[Index].MacrosList.Macros[I].ShortCut;
        Action.ImageIndex := Integer(MacrosGroup.GroupItems[Index].MacrosList.Macros[I]);
        Action.OnExecute := DoOnMenuClick;
        Action.ActionList := FActionList;

        M := TMenuItem.Create(Self);
//        M.Tag := Integer(FLMacrosGroup.GroupItems[Index].MacrosList.Macros[I]);
//        M.Name := 'M' + IntToStr(MacrosGroup.GroupItems[Index].MacrosList.Macros[I].Id);
        M.Action := Action;
//        M.Caption := FLMacrosGroup.GroupItems[Index].MacrosList.Macros[I].Name;
//        M.OnClick := DoOnMenuClick;
//        M.ShortCut := FLMacrosGroup.GroupItems[Index].MacrosList.Macros[I].ShortCut;
        if (Parent is TMenuItem) then
          (Parent as TMenuItem).Add(M)
        else
          (Parent as TPopUpMenu).Items.Add(M);
        Inc(AddCount);
      end;
    end;
    if AddCount = 0 then
    begin
      M := TMenuItem.Create(Self);
//      M.Name := 'N' + IntToStr(Index);
      M.Caption := 'Пусто';
      M.Enabled := False;
      if (Parent is TMenuItem) then
        (Parent as TMenuItem).Add(M)
      else
        (Parent as TPopUpMenu).Items.Add(M);
    end;
  end;

  procedure LoadMacrosGroup(AMacrosGroupID: Integer);
  var
    LMacrosGroup: TscrMacrosGroup;
  begin
    LMacrosGroup := TscrMacrosGroup.Create(True);
    LMacrosGroup.Transaction := FTransaction;
    LMacrosGroup.Load(AMacrosGroupID);

    FMacrosGroupList.Add(LMacrosGroup);

    if (LMacrosGroup.Count > 1) or ((LMacrosGroup.Count = 1) and (LMacrosGroup[0].MacrosList.Count > 0)) then
    begin
      M := TMenuItem.Create(Self);
      M.Caption := '-';
      Self.Items.Add(M);

      FillMenu(Self, LMacrosGroup);
    end;
  end;

  procedure IterateAncestor(AFE: TgdFormEntry);
  begin
    Assert(AFE <> nil);

    if AFE.SubType <> '' then
      IterateAncestor(AFE.Parent as TgdFormEntry);

    if not AFE.AbstractBaseForm then
      LoadMacrosGroup(AFE.MacrosGroupID);
  end;

begin
  if not Assigned(Owner) then
    raise Exception.Create('Owner not assigned');


  if Assigned(FActionList) then
  begin
    FActionList.Free;
    FActionList := nil;
  end;

  Items.Clear;

  if Assigned(GlobalStorage) and Assigned(IBLogin)
    and ((GlobalStorage.ReadInteger('Options\Policy',
      GD_POL_RUN_MACRO_ID, GD_POL_RUN_MACRO_MASK, False) and IBLogin.InGroup) = 0) then
  begin
    exit;
  end;

  if IBLogin.IsUserAdmin then
  begin
    M := TMenuItem.Create(Self);
    M.Caption := CST_MacrosMENU;
    M.OnClick := DoOnMacrosListClick;
    Self.Items.Add(M);
  end;

  FMacrosGroupList.Clear;

  LoadMacrosGroup(OBJ_GLOBALMACROS);

  gdcDelphiObject := TgdcDelphiObject.Create(nil);
  try
    LocId := gdcDelphiObject.AddObject(Owner);
    gdcDelphiObject.Close;
    gdcDelphiObject.SubSet := ssById;
    gdcDelphiObject.ID := LocId;
    gdcDelphiObject.Open;

    if Owner is TgdcCreateableForm then
    begin
      FE := gdClassList.Get(TgdFormEntry, Owner.ClassName,
        TgdcCreateableForm(Owner).SubType) as TgdFormEntry;

      if FE.SubType <> '' then
        IterateAncestor(FE.Parent as TgdFormEntry);
    end;

    LoadMacrosGroup(gdcDelphiObject.FieldByName(fnMacrosGroupKey).AsInteger);

  finally
    gdcDelphiObject.Free;
  end;
end;

end.

