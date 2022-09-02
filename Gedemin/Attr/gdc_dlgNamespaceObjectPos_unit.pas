// ShlTanya, 03.02.2019

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
    procedure edFindKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    FFindPos: Integer;
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

    while (Sel <> nil)
      and (lv.GetNextItem(Sel, sdBelow, [isNone]) <> nil) do
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
  I: Integer;
begin
  if lv.Items.Count > 0 then
  begin
    if lv.Selected <> nil then
    begin
      if lv.Selected.Index = FFindPos then
        Inc(FFindPos)
      else
        FFindPos := lv.Selected.Index;

      if lv.MultiSelect then
      begin
        for I := 0 to lv.Items.Count - 1 do
        begin
          if lv.Items[I].Selected then
            lv.Items[I].Selected := False;
        end;
      end;
    end
    else
      FFindPos := -1;

    if ((FFindPos + 1) <= (lv.Items.Count - 1)) then
    begin
      for I := FFindPos + 1 to lv.Items.Count - 1 do
      begin
        if StrIPos(edFind.Text, lv.Items[I].Caption) > 0 then
        begin
          lv.SetFocus;
          lv.Items[I].Selected := True;
          lv.Items[I].MakeVisible(True);
          exit;
        end;
      end;
    end;

    for I := 0 to FFindPos do
    begin
      if StrIPos(edFind.Text, lv.Items[I].Caption) > 0 then
      begin
        lv.SetFocus;
        lv.Items[I].Selected := True;
        lv.Items[I].MakeVisible(True);
        exit;
      end;
    end;
  end;
end;

procedure Tgdc_dlgNamespaceObjectPos.actFindUpdate(Sender: TObject);
begin
  actFind.Enabled := (edFind.Text > '') and (lv.Items.Count > 0);
end;

procedure Tgdc_dlgNamespaceObjectPos.edFindKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (Shift = [ssCtrl])
    and (LowerCase(Chr(Key)) = 'a') then
  begin
    edFind.SelectAll;
  end;
end;

end.
