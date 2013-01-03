unit gdc_dlgNamespaceObjectPos_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, ComCtrls;

type
  Tgdc_dlgNamespaceObjectPos = class(TForm)
    lv: TListView;
    ActionList: TActionList;
    btnOk: TButton;
    actOK: TAction;
    btnCancel: TButton;
    actCancel: TAction;
    btnUp: TButton;
    actUp: TAction;
    btnDown: TButton;
    actDown: TAction;
    procedure actOKExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actUpUpdate(Sender: TObject);
    procedure actDownUpdate(Sender: TObject);
    procedure actUpExecute(Sender: TObject);
    procedure actDownExecute(Sender: TObject);
  end;

var
  gdc_dlgNamespaceObjectPos: Tgdc_dlgNamespaceObjectPos;

implementation

{$R *.DFM}

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
  LI: TListItem;
begin
  lv.Items.BeginUpdate;
  try
    LI := lv.Items.Insert(lv.Selected.Index - 1);
    LI.Caption := lv.Selected.Caption;
    LI.SubItems.Assign(lv.Selected.SubItems);
    lv.Selected.Free;
    LI.Selected := True;
  finally
    lv.Items.EndUpdate;
  end;
end;

procedure Tgdc_dlgNamespaceObjectPos.actDownExecute(Sender: TObject);
var
  LI: TListItem;
begin
  lv.Items.BeginUpdate;
  try
    LI := lv.Items.Insert(lv.Selected.Index + 2);
    LI.Caption := lv.Selected.Caption;
    LI.SubItems.Assign(lv.Selected.SubItems);
    lv.Selected.Free;
    LI.Selected := True;
  finally
    lv.Items.EndUpdate;
  end;
end;

end.
