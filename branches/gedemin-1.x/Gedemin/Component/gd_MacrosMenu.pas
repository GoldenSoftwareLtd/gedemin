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
������ ���� ����������� ������ ��� �������� ����
������� ��� ��������� ShortCut�� ��� �������� ���������
�������� ������ ����� �������� ����.
���������� �������� � ������� ����������� �� ���������
��������. }
unit gd_MacrosMenu;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, gdcDelphiObject, scrMacrosGroup, IBDataBase, gdcConstants, ActnList;

type
  TgdMacrosMenu = class(TPopupMenu)
  private
    FLMacrosGroup: TscrMacrosGroup;
    FGMacrosGroup: TscrMacrosGroup;
    FTransaction: TIBTransaction;
    FActionList: TActionList;

    procedure DoOnMenuClick(Sender: TObject);
    procedure DoOnMacrosListClick(Sender: TObject);

  protected
    procedure PrepareMenu; virtual;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure ReloadGroup;
    procedure Popup(X, Y: Integer); override;
  end;

const
  CST_MacrosMENU = '�������� ������-��������';

procedure Register;

implementation

uses
  gdcBaseInterface,          evt_i_Base,             gdcOLEClassList,
  gd_SetDatabase,            gd_i_ScriptFactory,     gs_Exception,
  gd_security_operationconst,gd_Createable_Form,     gd_security,
  Storages;

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

      FLMacrosGroup := TscrMacrosGroup.Create(True);
      FLMacrosGroup.Transaction := FTransaction;
      FGMacrosGroup := TscrMacrosGroup.Create(True);
      FGMacrosGroup.Transaction := FTransaction;
    end else
      raise Exception.Create(GetGsException(Self, 'Database is not assigned'));
  end;
end;

destructor TgdMacrosMenu.Destroy;
begin
  FLMacrosGroup.Free;
  FGMacrosGroup.Free;
  
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

procedure TgdMacrosMenu.PrepareMenu;
var
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
      M.Caption := '�����';
      M.Enabled := False;
      if (Parent is TMenuItem) then
        (Parent as TMenuItem).Add(M)
      else
        (Parent as TPopUpMenu).Items.Add(M);
    end;
  end;

begin
  if not Assigned(Owner) then
    Exit;

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

  if (FGMacrosGroup.Count > 1) or ((FGMacrosGroup.Count = 1) and (FGMacrosGroup[0].MacrosList.Count > 0)) then
  begin
    M := TMenuItem.Create(Self);
    M.Caption := '-';
    Self.Items.Add(M);

    FillMenu(Self, FGMacrosGroup);
  end;
  if (FLMacrosGroup.Count > 1) or ((FLMacrosGroup.Count = 1) and (FLMacrosGroup[0].MacrosList.Count > 0)) then
  begin
    M := TMenuItem.Create(Self);
    M.Caption := '-';
    Self.Items.Add(M);
    FillMenu(Self, FLMacrosGroup);
  end;
end;

procedure TgdMacrosMenu.ReloadGroup;
var
  gdcDelphiObject: TgdcDelphiObject;
  LocId: Integer;
begin
  if not Assigned(Owner) then
    raise Exception.Create('Owner not assigned');

  gdcDelphiObject := TgdcDelphiObject.Create(nil);
  try
    LocId := gdcDelphiObject.AddObject(Owner);
    gdcDelphiObject.Close;
    gdcDelphiObject.SubSet := ssById;
    gdcDelphiObject.ID := LocId;
    gdcDelphiObject.Open;

    FLMacrosGroup.Load(gdcDelphiObject.FieldByName(fnMacrosGroupKey).AsInteger);
  finally
    gdcDelphiObject.Free;
  end;
  FGMacrosGroup.Load(OBJ_GLOBALMACROS);
  PrepareMenu;
end;

end.

