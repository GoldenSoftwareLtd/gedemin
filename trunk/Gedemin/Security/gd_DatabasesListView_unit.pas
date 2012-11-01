unit gd_DatabasesListView_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, ComCtrls, TB2Dock, TB2Toolbar, ExtCtrls, TB2Item,
  TB2ExtItems;

type
  Tgd_DatabasesListView = class(TForm)
    al: TActionList;
    actOk: TAction;
    pnlBottom: TPanel;
    pnlWorkArea: TPanel;
    lv: TListView;
    pnlButtons: TPanel;
    btnOk: TButton;
    actCreate: TAction;
    actEdit: TAction;
    actDelete: TAction;
    TBDock: TTBDock;
    tb: TTBToolbar;
    tbiCreate: TTBItem;
    tbiEdit: TTBItem;
    tbiDelete: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    TBControlItem1: TTBControlItem;
    Label1: TLabel;
    actImport: TAction;
    TBSeparatorItem2: TTBSeparatorItem;
    TBItem1: TTBItem;
    Button1: TButton;
    actCancel: TAction;
    edFilter: TEdit;
    TBControlItem2: TTBControlItem;
    procedure actOkExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actCreateExecute(Sender: TObject);
    procedure actImportUpdate(Sender: TObject);
    procedure actImportExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure edFilterChange(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);

  public
    procedure InitDatabasesList;
  end;

var
  gd_DatabasesListView: Tgd_DatabasesListView;

implementation

{$R *.DFM}

uses
  gd_DatabasesList_unit, jclStrings;

procedure Tgd_DatabasesListView.actOkExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure Tgd_DatabasesListView.InitDatabasesList;
var
  I: Integer;
  DI: Tgd_DatabaseItem;
  LI: TListItem;
  Saved: String;
begin
  if lv.Selected <> nil then
    Saved := lv.Selected.Caption
  else
    Saved := '';

  lv.Items.Clear;
  for I := 0 to gd_DatabasesList.Count - 1 do
  begin
    DI := gd_DatabasesList.Items[I] as Tgd_DatabaseItem;

    if (edFilter.Text = '') or (StrIPos(edFilter.Text,
      DI.Name + DI.Server + DI.FileName) > 0) then
    begin
      LI := lv.Items.Add;
      LI.Caption := DI.Name;
      LI.SubItems.Add(DI.Server);
      LI.SubItems.Add(DI.FileName);
      if (LI.Caption = Saved) or (lv.Items.Count = 1) then
        LI.Selected := True;
    end;
  end;

  if edFilter.Text = '' then
  begin
    lv.Color := clWindow;
    edFilter.Color := clWindow;
  end else
  begin
    lv.Color := clInfoBK;
    edFilter.Color := clInfoBk;
  end;
end;

procedure Tgd_DatabasesListView.FormCreate(Sender: TObject);
begin
  InitDatabasesList;
end;

procedure Tgd_DatabasesListView.actCreateExecute(Sender: TObject);
var
  DI: Tgd_DatabaseItem;
begin
  DI := gd_DatabasesList.Add as Tgd_DatabaseItem;
  try
    if DI.EditInDialog then
      InitDatabasesList
    else
      DI.Free;
  except
    DI.Free;
    raise;
  end;
end;

procedure Tgd_DatabasesListView.actImportUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := gd_DatabasesList <> nil;
end;

procedure Tgd_DatabasesListView.actImportExecute(Sender: TObject);
begin
  gd_DatabasesList.ReadFromRegistry;
  InitDatabasesList;
end;

procedure Tgd_DatabasesListView.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure Tgd_DatabasesListView.edFilterChange(Sender: TObject);
begin
  InitDatabasesList;
end;

procedure Tgd_DatabasesListView.actOkUpdate(Sender: TObject);
begin
  actOk.Enabled := lv.Selected <> nil;
end;

end.
