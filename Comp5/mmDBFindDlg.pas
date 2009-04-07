
{++

  Copyright (c) 1999 by Golden Software of Belarus

  Module

    mmDBFindDlg.pas

  Abstract

    Dialog box for choosing parameters of searching.

  Author

    Romanovski Denis (22-01-99)

  Revisions history

    15.04.1999     Dennis      Initial version. Remaking component on the basis of TDBSearchField.

--}

unit mmDBFindDlg;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes,  Graphics, Controls,
  StdCtrls, ExtCtrls, Forms,    Buttons,  xBulbBtn, xTrSpBtn, 
  Dialogs, mBitButton, ComCtrls, mmComboBox, mmCheckBoxEx,
  mmRadioButtonEx, gsMultilingualSupport;

type
  TfrmDBFindDlg = class(TForm)
    btnFind: TmBitButton;
    btnCancel: TmBitButton;
    rgDirection: TmmRadioGroup;
    antFind: TAnimate;
    gbFind: TGroupBox;
    btnFull: TSpeedButton;
    gbParameters: TGroupBox;
    cbMatchCase: TmmCheckBoxEx;
    cbWholeField: TmmCheckBoxEx;
    comboSearchText: TmmComboBox;
    gsMultilingualSupport: TgsMultilingualSupport;

    procedure cbWholeFieldClick(Sender: TObject);
    procedure comboSearchTextChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnFullClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  protected
  public
  end;

var
  frmDBFindDlg: TfrmDBFindDlg;

implementation

{$R *.DFM}

{
  ���� ����� �� ������ �����, �� �������� �������� ��������.
}

procedure TfrmDBFindDlg.cbWholeFieldClick(Sender: TObject);
begin
  if cbWholeField.Checked then
  begin
    cbMatchCase.Checked := False;
    cbMatchCase.Enabled := not cbWholeField.Checked;
  end else
    cbMatchCase.Enabled := True;
end;

{
  ����� �������� ������, ���� ������� ���������� ��� ������.
}

procedure TfrmDBFindDlg.comboSearchTextChange(Sender: TObject);
begin
   btnFind.Enabled:= comboSearchText.Text <> '';
end;

{
  ���������� ���� ����� �������� ���������� ��� ��������� ������ ����.
}

procedure TfrmDBFindDlg.FormActivate(Sender: TObject);
begin
  comboSearchText.SetFocus;
end;

{
  �������� ������� ���� �� ������� ������������.
}

procedure TfrmDBFindDlg.btnFullClick(Sender: TObject);
begin
  if Height > 107 then
  begin
    while Height - 107 > 5 do
      Height := Height - 5;
    Height := 107;
  end else
  begin
    while 185 - Height > 5 do
      Height := Height + 5;
    Height := 185;
  end;
end;

{
  ��� �������� ���� ������������� ��� ������.
}

procedure TfrmDBFindDlg.FormCreate(Sender: TObject);
begin
  Height := 185;
end;

end.


