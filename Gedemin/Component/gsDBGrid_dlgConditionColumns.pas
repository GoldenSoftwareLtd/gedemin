// ShlTanya, 17.02.2019

unit gsDBGrid_dlgConditionColumns;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, CheckLst;

type
  TdlgConditionColumns = class(TForm)
    Panel2: TPanel;
    Panel3: TPanel;
    btnCancel: TButton;
    btnOk: TButton;
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    clbFields: TCheckListBox;
    cbAll: TCheckBox;
    procedure clbFieldsClickCheck(Sender: TObject);
    procedure cbAllClick(Sender: TObject);
  private

  public
    function ShowModal: Integer; override;

  end;

var
  dlgConditionColumns: TdlgConditionColumns;

implementation

{$R *.DFM}


function TdlgConditionColumns.ShowModal: Integer;
var
  I: Integer;
begin
  cbAll.OnClick := nil;
  cbAll.Checked := True;

  for I := 0 to clbFields.Items.Count - 1 do
    if clbFields.State[I] = cbUnchecked then
    begin
      cbAll.Checked := False;
      Break;
    end;

  cbAll.OnClick := cbAllClick;

  Result := inherited ShowModal;
end;

procedure TdlgConditionColumns.clbFieldsClickCheck(Sender: TObject);
var
  I: Integer;
begin
  if cbAll.Checked then
  begin
    cbAll.OnClick := nil;

    for I := 0 to clbFields.Items.Count - 1 do
      if clbFields.State[I] = cbUnchecked then
      begin
        cbAll.Checked := False;
        Break;
      end;

    cbAll.OnClick := cbAllClick;
  end;
end;

procedure TdlgConditionColumns.cbAllClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to clbFields.Items.Count - 1 do
    if cbAll.Checked then
      clbFields.State[I] := cbChecked
    else
      clbFields.State[I] := cbUnChecked;
end;

end.
