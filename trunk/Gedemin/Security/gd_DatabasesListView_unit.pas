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
    procedure lvChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure lvDblClick(Sender: TObject);

  public
    procedure SyncControls;
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

procedure Tgd_DatabasesListView.SyncControls;
var
  I: Integer;
  DI: Tgd_DatabaseItem;
  LI: TListItem;
begin
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
      if DI.Selected then
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

  if lv.Selected <> nil then
    lv.Selected.MakeVisible(False);
end;

procedure Tgd_DatabasesListView.FormCreate(Sender: TObject);
begin
  SyncControls;
end;

procedure Tgd_DatabasesListView.actCreateExecute(Sender: TObject);
var
  DI: Tgd_DatabaseItem;
begin
  DI := gd_DatabasesList.Add as Tgd_DatabaseItem;
  try
    if DI.EditInDialog then
    begin
      DI.Selected := True;
      SyncControls;
    end else
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
  SyncControls;
end;

procedure Tgd_DatabasesListView.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure Tgd_DatabasesListView.edFilterChange(Sender: TObject);
begin
  SyncControls;
end;

procedure Tgd_DatabasesListView.actOkUpdate(Sender: TObject);
begin
  actOk.Enabled := (gd_DatabasesList.Count = 0) or
    (gd_DatabasesList.FindSelected <> nil);
end;

procedure Tgd_DatabasesListView.lvChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var
  DI: Tgd_DatabaseItem;
begin
  if lv.Selected <> nil then
  begin
    DI := gd_DatabasesList.FindByName(lv.Selected.Caption);
    if DI <> nil then
      DI.Selected := True;
  end;
end;

procedure Tgd_DatabasesListView.lvDblClick(Sender: TObject);
begin
  actOk.Execute;
end;

end.
