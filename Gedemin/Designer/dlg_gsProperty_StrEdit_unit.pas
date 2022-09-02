// ShlTanya, 24.02.2019

{*******************************************************}
{                                                       }
{       Delphi Visual Component Library                 }
{       TStrings property editor dialog                 }
{                                                       }
{       Copyright (c) 1999 Borland International        }
{                                                       }
{*******************************************************}

unit dlg_gsProperty_StrEdit_unit;

interface

uses Windows, Classes, Forms, Controls, Buttons, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Menus;

type
  TdlgPropertyStrEdit = class(TForm)
    LineCount: TLabel;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    HelpButton: TButton;
    OKButton: TButton;
    CancelButton: TButton;
    Memo: TRichEdit;
    StringEditorMenu: TPopupMenu;
    LoadItem: TMenuItem;
    SaveItem: TMenuItem;
    CodeEditorItem: TMenuItem;
    Label1: TLabel;
    Bevel1: TBevel;
    procedure FileOpen(Sender: TObject);
    procedure FileSave(Sender: TObject);
    procedure UpdateStatus(Sender: TObject);
    procedure Memo1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure HelpButtonClick(Sender: TObject);
  private
    FModified: Boolean;
  public
    function Edit(Value: TStrings): Boolean;
  end;

implementation
uses Sysutils;
{$R *.DFM}


{ TStrEditDlg }

procedure TdlgPropertyStrEdit.FileOpen(Sender: TObject);
begin
  with OpenDialog do
    if Execute then Memo.Lines.LoadFromFile(FileName);
end;

procedure TdlgPropertyStrEdit.FileSave(Sender: TObject);
begin
  SaveDialog.FileName := OpenDialog.FileName;
  with SaveDialog do
    if Execute then Memo.Lines.SaveToFile(FileName);
end;

procedure TdlgPropertyStrEdit.UpdateStatus(Sender: TObject);
begin
  if Sender = Memo then
    FModified := True;
  LineCount.Caption := IntToStr(Memo.Lines.Count);
end;

procedure TdlgPropertyStrEdit.Memo1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then CancelButton.Click;
end;

function TdlgPropertyStrEdit.Edit(Value: TStrings): Boolean;
begin
  Result := False;
  Memo.Lines.Assign(Value);
  if (ShowModal = mrOk) and FModified then
  begin
    Value.Assign(Memo.Lines);
    Result := True;
  end;
end;

procedure TdlgPropertyStrEdit.HelpButtonClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

end.
