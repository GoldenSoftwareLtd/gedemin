{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    ctl_ChooseCattleBranch_unit.pas

  Abstract

    Window.

  Author

    Denis Romanosvki  (01.04.2001)

  Revisions history

    1.0    01.04.2001    Denis    Initial version.


--}

unit ctl_ChooseCattleBranch_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_dlgG_unit, ComCtrls, gsIBLargeTreeView, ActnList, StdCtrls,
  ctl_CattleConstants_unit;

type
  Tctl_ChooseCattleBranch = class(Tgd_dlgG)
    lvGood: TgsIBLargeTreeView;

    procedure actOkExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actCancelExecute(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);

  private

  public
    function Execute: Boolean;

  end;

var
  ctl_ChooseCattleBranch: Tctl_ChooseCattleBranch;

implementation

{$R *.DFM}

uses
  ctl_dlgSetupPrice_unit, dmDataBase_unit, Storages, gsStorage;

procedure Tctl_ChooseCattleBranch.actOkExecute(Sender: TObject);
var
  F: TgsStorageFolder;
begin
  inherited;

  //
  // Сохраняем в глобальном хранилище!
  F := GlobalStorage.OpenFolder(FOLDER_CATTLE_SETTINGS);
  try
    F.WriteString(VALUE_CATTLEBRANCH, (lvGood.Selected as TgsIBTreeNode).ID);
  finally  
    GlobalStorage.CloseFolder(F);
  end;
end;

procedure Tctl_ChooseCattleBranch.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
//
end;

procedure Tctl_ChooseCattleBranch.actCancelExecute(Sender: TObject);
begin
  inherited;
//
end;

procedure Tctl_ChooseCattleBranch.actOkUpdate(Sender: TObject);
begin
  actOk.Enabled := lvGood.Selected <> nil;
end;

function Tctl_ChooseCattleBranch.Execute: Boolean;
var
  ID: String;
  F: TgsStorageFolder;
begin
  //
  // Восстанавливаем настройку

  F := GlobalStorage.OpenFolder(FOLDER_CATTLE_SETTINGS, True, False);
  try
    ID := F.ReadString(VALUE_CATTLEBRANCH, '');
  finally
    GlobalStorage.CloseFolder(F, False);
  end;

  lvGood.OpenBranch(ID);

  Result := ShowModal = mrOK;
end;

end.
