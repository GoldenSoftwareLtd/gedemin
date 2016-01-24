{++

  Copyright (c) 2001-2016 by Golden Software of Belarus, Ltd

  Module

    gdcMacrosMenu.pas

  Abstract

    Gedemin project. TgdMacrosMenu.

  Author

    Karpuk Alexander

  Revisions history

    1.00    15.02.02    tiptop        Initial version.

--}

unit gd_MacrosMenu;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, gdcDelphiObject, scrMacrosGroup, IBDataBase, gdcConstants, ActnList, Contnrs;

type
  TgdMacrosMenu = class(TPopupMenu)
  private
    FMacrosList: TscrMacrosList;
    FActionList: TActionList;

    procedure DoOnMenuClick(Sender: TObject);
    procedure DoOnMacrosListClick(Sender: TObject);

  public
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
  Storages,                  gd_ClassList,           gdc_createable_form,
  IBSQL,                     dmImages_unit;

procedure Register;
begin
  RegisterComponents('gdc', [TgdMacrosMenu]);
end;

{ TgdMacrosMenu }

destructor TgdMacrosMenu.Destroy;
begin
  FMacrosList.Free;

  inherited;
end;

procedure TgdMacrosMenu.DoOnMenuClick(Sender: TObject);
var
  OwnerForm: IDispatch;
begin
  if Assigned(ScriptFactory) then
  begin
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
const
  IdxMacros       = 123;
  IdxFolder       = 132;
  IdxScriptEditor = 21;

var
  MenuItem: TMenuItem;
  q: TIBSQL;
  FE: TgdFormEntry;
  GroupIDs, S: String;
  CurrMenu: TComponent;
  FormRootID: Integer;

  Action: TAction;

  MacrosItem: TscrMacrosItem;

  procedure IterateForms(AFE: TgdFormEntry);
  begin
    if (AFE.SubType > '') and (AFE.Parent is TgdFormEntry) then
      IterateForms(AFE.Parent as TgdFormEntry);

    if not AFE.AbstractBaseForm then
      GroupIDs := GroupIDs + IntToStr(AFE.MacrosGroupID) + ',';
  end;

  procedure AddFolder(F, M: TMenuItem);
  var
    I: Integer;
  begin
    I := F.Count - 1;
    while I > 0 do
    begin
      if F.Items[I].ImageIndex <> idxMacros then
        break;
      Dec(I);
    end;
    if I >= 0 then
      F.Insert(I + 1, M)
    else
      F.Add(M);
  end;

begin
  FreeAndNil(FMacrosList);
  FreeAndNil(FActionList);

  Items.Clear;

  if Assigned(GlobalStorage) and Assigned(IBLogin)
    and ((GlobalStorage.ReadInteger('Options\Policy',
      GD_POL_RUN_MACRO_ID, GD_POL_RUN_MACRO_MASK, False) and IBLogin.InGroup) = 0) then
  begin
    exit;
  end;

  Self.AutoLineReduction := Menus.maAutomatic;
  Self.Tag := -1;
  Self.Images := dmImages.il16x16;

  if IBLogin.IsUserAdmin then
  begin
    MenuItem := TMenuItem.Create(Self);
    MenuItem.Caption := CST_MacrosMENU;
    MenuItem.OnClick := DoOnMacrosListClick;
    MenuItem.ImageIndex := idxScriptEditor;
    Self.Items.Add(MenuItem);
    MenuItem := TMenuItem.Create(Self);
    MenuItem.Caption := '-';
    Self.Items.Add(MenuItem);
  end;

  GroupIDs := IntToStr(OBJ_GLOBALMACROS) + ',';

  CurrMenu := Self;
  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;

    FormRootID := -1;

    if Owner is TgdcCreateableForm then
    begin
      FE := gdClassList.Get(TgdFormEntry, Owner.ClassName,
        TgdcCreateableForm(Owner).SubType) as TgdFormEntry;

      if FE.ShowInFormEditor then
        begin
          q.SQL.Text :=
            'SELECT macrosgroupkey FROM evt_object ' +
            'WHERE UPPER(objectname) = :objectname';
          q.Params[0].AsString := UpperCase(TCreateableForm(Owner).InitialName);
          q.ExecQuery;
          if not q.EOF then
          begin
            GroupIDs := GroupIDs + q.Fields[0].AsString + ',';
            FormRootID := q.Fields[0].AsInteger;
          end;
        end else
        begin
          FormRootID := FE.GroupID;
          IterateForms(FE);
        end;
    end;

    SetLength(GroupIDs, Length(GroupIDs) - 1);

    if IBLogin.IsUserAdmin then
      S := ''
    else
      S := 'AND BIN_AND(r.aview, :InGroup) <> 0 ';

    q.SQL.Text :=
      'SELECT '#13#10 +
      '  g.id AS groupid, '#13#10 +
      '  g.parent AS groupparent, '#13#10 +
      '  g.name AS groupname, '#13#10 +
      '  r.* '#13#10 +
      'FROM '#13#10 +
      '  evt_macrosgroup gparent '#13#10 +
      '  JOIN evt_macrosgroup g '#13#10 +
      '    ON g.lb >= gparent.lb AND g.rb <= gparent.rb '#13#10 +
      '  LEFT JOIN evt_macroslist r '#13#10 +
      '    ON r.macrosgroupkey = g.id '#13#10 +
      'WHERE '#13#10 +
      '  gparent.id IN (' + GroupIDs + ') '#13#10 +
      '  AND r.displayinmenu <> 0 '#13#10 +
      S +
      'ORDER BY '#13#10 +
      '  gparent.lb, g.name, r.name';
    if S > '' then
      q.ParamByName('InGroup').AsInteger := IBLogin.InGroup;

    q.Close;
    q.ExecQuery;

    while not q.EOF do
    begin
      if CurrMenu.Tag <> q.FieldByName('groupid').AsInteger then
      begin
        if q.FieldbyName('groupparent').IsNull
          or (q.FieldByName('groupid').AsInteger = FormRootID) then
        begin
          CurrMenu := Self;
        end else
        begin
          MenuItem := TMenuItem.Create(Self);
          MenuItem.Caption := q.FieldbyName('groupname').AsString;
          MenuItem.Tag := q.FieldByName('groupid').AsInteger;
          MenuItem.ImageIndex := idxFolder;

          if CurrMenu is TMenuItem then
          begin
            if CurrMenu.Tag = q.FieldByName('groupparent').AsInteger then
              AddFolder(CurrMenu as TMenuItem, MenuItem)
            else if (CurrMenu as TMenuItem).Parent is TMenuItem then
              AddFolder((CurrMenu as TMenuItem).Parent, MenuItem)
            else
              AddFolder(Self.Items, MenuItem);
          end else
            AddFolder(Self.Items, MenuItem);

          CurrMenu := MenuItem;
        end;
      end;

      if q.FieldByName('id').AsInteger > 0 then
      begin
        if FMacrosList = nil then
          FMacrosList :=  TscrMacrosList.Create(True);
        if FActionList = nil then
          FActionList := TActionList.Create(Owner);

        MacrosItem := TscrMacrosItem.Create;
        MacrosItem.ReadFromSQL(q);
        FMacrosList.Add(MacrosItem);

        Action := TAction.Create(FActionList);
        Action.Caption := q.FieldbyName('name').AsString;
        Action.ShortCut := q.FieldbyName('shortcut').AsInteger;
        Action.ImageIndex := Integer(MacrosItem);
        Action.OnExecute := DoOnMenuClick;
        Action.ActionList := FActionList;

        MenuItem := TMenuItem.Create(Self);
        MenuItem.Action := Action;
        MenuItem.Tag := q.FieldByName('id').AsInteger;
        MenuItem.ImageIndex := idxMacros;

        if CurrMenu is TMenuItem then
          (CurrMenu as TMenuItem).Add(MenuItem)
        else
          Self.Items.Add(MenuItem);
      end;

      q.Next;
    end;
  finally
    q.Free;
  end;
end;

end.

