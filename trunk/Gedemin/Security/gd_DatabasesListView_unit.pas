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
    tbiFilter: TTBEditItem;
    Label1: TLabel;
    procedure actOkExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actCreateExecute(Sender: TObject);

  public
    procedure InitDatabasesList;
  end;

var
  gd_DatabasesListView: Tgd_DatabasesListView;

implementation

{$R *.DFM}

uses
  gd_DatabasesList_unit;

procedure Tgd_DatabasesListView.actOkExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure Tgd_DatabasesListView.InitDatabasesList;
var
  I: Integer;
  DI: Tgd_DatabaseItem;
  LI: TListItem;
begin
  lv.Items.Clear;
  for I := 0 to gd_DatabasesList.Count - 1 do
  begin
    DI := gd_DatabasesList.Items[I] as Tgd_DatabaseItem;
    LI := lv.Items.Add;
    LI.Caption := DI.Name;
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
  if DI.EditInDialog then
    InitDatabasesList
  else
    DI.Free;
end;

end.
