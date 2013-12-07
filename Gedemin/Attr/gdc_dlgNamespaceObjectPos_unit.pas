unit gdc_dlgNamespaceObjectPos_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, ComCtrls, ExtCtrls;

type
  Tgdc_dlgNamespaceObjectPos = class(TForm)
    ActionList: TActionList;
    actOK: TAction;
    actCancel: TAction;
    actUp: TAction;
    actDown: TAction;
    pnlButtons: TPanel;
    btnUp: TButton;
    btnDown: TButton;
    Panel2: TPanel;
    lv: TListView;
    Panel3: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    pnlFind: TPanel;
    Label1: TLabel;
    edFind: TEdit;
    btnFind: TButton;
    actFind: TAction;
    procedure actOKExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actUpUpdate(Sender: TObject);
    procedure actDownUpdate(Sender: TObject);
    procedure actUpExecute(Sender: TObject);
    procedure actDownExecute(Sender: TObject);
    procedure actFindExecute(Sender: TObject);
    procedure actFindUpdate(Sender: TObject);

  private
    PrevSel: TListItem;
  end;

var
  gdc_dlgNamespaceObjectPos: Tgdc_dlgNamespaceObjectPos;

implementation

{$R *.DFM}

uses
  jclStrings;

procedure Tgdc_dlgNamespaceObjectPos.actOKExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure Tgdc_dlgNamespaceObjectPos.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure Tgdc_dlgNamespaceObjectPos.actUpUpdate(Sender: TObject);
begin
  actUp.Enabled := (lv.Selected <> nil) and (lv.Selected.Index > 0);
end;

procedure Tgdc_dlgNamespaceObjectPos.actDownUpdate(Sender: TObject);
begin
  actDown.Enabled := (lv.Selected <> nil)
    and (lv.Selected.Index < (lv.Items.Count - 1));
end;

procedure Tgdc_dlgNamespaceObjectPos.actUpExecute(Sender: TObject);
var
  LI, Sel: TListItem;
begin
  lv.Items.BeginUpdate;
  try
    Sel := lv.Selected;
    while Sel <> nil do
    begin
      LI := lv.Items.Insert(Sel.Index - 1);
      LI.Caption := Sel.Caption;
      LI.SubItems.Assign(Sel.SubItems);
      Sel.Free;
      LI.Selected := True;
      Sel := lv.GetNextItem(LI, sdBelow, [isSelected]);
    end;
  finally
    lv.Items.EndUpdate;
  end;
end;

procedure Tgdc_dlgNamespaceObjectPos.actDownExecute(Sender: TObject);
var
  LI, Sel: TListItem;
begin
  lv.Items.BeginUpdate;
  try
    Sel := lv.Selected;

    while (Sel <> nil) and (lv.GetNextItem(Sel, sdBelow, [isSelected]) <> nil) do
      Sel := lv.GetNextItem(Sel, sdBelow, [isSelected]);

    while Sel <> nil do
    begin
      LI := lv.Items.Insert(Sel.Index + 2);
      LI.Caption := Sel.Caption;
      LI.SubItems.Assign(Sel.SubItems);
      Sel.Free;
      LI.Selected := True;
      Sel := lv.GetNextItem(LI, sdAbove, [isSelected]);
    end;
  finally
    lv.Items.EndUpdate;
  end;
end;

procedure Tgdc_dlgNamespaceObjectPos.actFindExecute(Sender: TObject);
var
  Sel: TListItem;
begin
  if lv.Selected <> nil then
    Sel := lv.Selected
  else if lv.Items.Count > 0 then
    Sel := lv.Items[0]
  else
    Sel := nil;

  while Sel <> nil do
  begin
    if StrIPos(edFind.Text, Sel.Caption) > 0 then
    begin
      if Sel <> PrevSel then
      begin
        PrevSel := Sel;
        Sel.Selected := True;
        break;
      end;
    end;
    Sel := lv.GetNextItem(Sel, sdBelow, [isNone, isFocused, isSelected, isActivating]);
  end;
end;

procedure Tgdc_dlgNamespaceObjectPos.actFindUpdate(Sender: TObject);
begin
  actFind.Enabled := (edFind.Text > '') and (lv.Items.Count > 0);
end;

end.
