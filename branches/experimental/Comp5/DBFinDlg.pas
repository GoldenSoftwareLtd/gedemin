
{

  Copyright (c) 1996-98 by Golden Software

  Module

    dbfindlg.pas

  Abstract

    A dialog box for DBSearch component.

  Author

    Mikle Shoihet (who knows)

  History
    1.00    ????          mikle      Initial version.
    1.01    06-jul-1997   andreik    Appearance changed.
    1.02    12-aug-1997   andreik    Appearance changed.
    1.03    08-nov-1997   andreik    Arial to Arial Cyr changed.
    1.04    23-dec-1997   andreik    Minor change.
    1.05    09-Feb-1998   andreik    Hint added.
    1.06    18-Feb-1998   andreik    Font changed to Ms Sans Serif.
    1.07    27-Oct-1998   andreik    Minor changes.
    1.08    18-Nov-1998   andreik    Minor bug fixed.

}

unit DBFindlg;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes,  Graphics, Controls,
  StdCtrls, ExtCtrls, Forms,    Buttons,  xBulbBtn, xTrSpBtn, FrmPlSvr,
  Dialogs;

type
  TDBFindDlg = class(TForm)
    FindWhatLabel: TLabel;
    FindWhatComboBox: TComboBox;
    SearchLabel: TLabel;
    SearchComboBox: TComboBox;
    MatchCaseCheckBox: TCheckBox;
    WholeFieldCheckBox: TCheckBox;
    xbbFind: TxBulbButton;
    xbbCancel: TxBulbButton;
    xtrspbtnFull: TxTransSpeedButton;
    fpsFindDlg: TFormPlaceSaver;

    procedure WholeFieldCheckBoxClick(Sender: TObject);
    procedure FindWhatComboBoxChange(Sender: TObject);
    procedure CancelBitBtnClick(Sender: TObject);
    procedure FindBitBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure xtrspbtnFullClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  protected
    procedure Loaded; override;

  public
    IsFirst: Boolean;

    procedure UpdateButtons;
  end;

implementation

{$R *.DFM}

procedure TDBFindDlg.WholeFieldCheckBoxClick(Sender: TObject);
begin
  with WholeFieldCheckBox do
  begin
    MatchCaseCheckBox.Checked := false;
    MatchCaseCheckBox.Enabled := not Checked;
  end;
end;

procedure TDBFindDlg.FindWhatComboBoxChange(Sender: TObject);
begin
   xbbFind.Enabled:= FindWhatComboBox.Text <> '';
end;

procedure TDBFindDlg.CancelBitBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TDBFindDlg.FindBitBtnClick(Sender: TObject);
var
  I: Integer;
begin
  xbbCancel.Caption := 'Закрыть';
  for I := 0 to FindWhatComboBox.Items.Count - 1 do
    if FindWhatComboBox.Text = FindWhatComboBox.Items[I] then
      exit;
  FindWhatComboBox.Items.Add(FindWhatComboBox.Text);
end;

procedure TDBFindDlg.FormActivate(Sender: TObject);
begin
  FindWhatComboBox.SetFocus;
end;

procedure TDBFindDlg.xtrspbtnFullClick(Sender: TObject);
begin
  if Height > 84 then
  begin
    while Height - 84 > 5 do
      Height := Height - 5;
    Height := 84;
  end else
  begin
    while 137 - Height > 5 do
      Height := Height + 5;
    Height := 137;
  end;

  xtrspbtnFull.Down := Height = 137;
end;

procedure TDBFindDlg.FormCreate(Sender: TObject);
begin
  Height := 137;
end;

procedure TDBFindDlg.Loaded;
begin
  inherited Loaded;
  UpdateButtons;
end;

procedure TDBFindDlg.UpdateButtons;
begin
  xbbFind.Color := Color;
  xbbCancel.Color := Color;
end;

end.


