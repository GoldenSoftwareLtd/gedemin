
{******************************************}
{                                          }
{     FastReport v2.5 - Dialog designer    }
{           String list editor             }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_LEdit;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, FR_Ctrls;

type
  TfrLinesEditorForm = class(TForm)
    MemoPanel: TPanel;
    Bevel2: TBevel;
    M1: TMemo;
    Panel2: TPanel;
    Panel1: TPanel;
    OkBtn: TfrSpeedButton;
    CancelBtn: TfrSpeedButton;
    Bevel1: TBevel;
    CutBtn: TfrSpeedButton;
    CopyBtn: TfrSpeedButton;
    PasteBtn: TfrSpeedButton;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure M1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure CutBtnClick(Sender: TObject);
    procedure CopyBtnClick(Sender: TObject);
    procedure PasteBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
  end;


implementation

uses FR_Class, FR_Const, FR_Utils;

{$R *.DFM}


procedure TfrLinesEditorForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = vk_Return) and (ssCtrl in Shift) then
  begin
    ModalResult := mrOk;
    Key := 0;
  end;
end;

procedure TfrLinesEditorForm.M1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = vk_Escape then ModalResult := mrCancel;
end;

procedure TfrLinesEditorForm.Localize;
begin
  Caption := frLoadStr(frRes + 4000);
  CutBtn.Hint := frLoadStr(frRes + 091);
  CopyBtn.Hint := frLoadStr(frRes + 092);
  PasteBtn.Hint := frLoadStr(frRes + 093);
  OkBtn.Hint := frLoadStr(SOk);
  CancelBtn.Hint := frLoadStr(SCancel);
end;

procedure TfrLinesEditorForm.FormCreate(Sender: TObject);
begin
  Localize;
{$IFNDEF Delphi2}
  M1.Font.Charset := frCharset;
{$ENDIF}
end;

procedure TfrLinesEditorForm.CutBtnClick(Sender: TObject);
begin
  M1.CutToClipboard;
end;

procedure TfrLinesEditorForm.CopyBtnClick(Sender: TObject);
begin
  M1.CopyToClipboard;
end;

procedure TfrLinesEditorForm.PasteBtnClick(Sender: TObject);
begin
  M1.PasteFromClipboard;
end;

procedure TfrLinesEditorForm.CancelBtnClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrLinesEditorForm.OkBtnClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

end.
