
{******************************************}
{                                          }
{     FastReport v2.5 - DB components      }
{               SQL editor                 }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_DBSQLEdit;

interface

{$I FR.inc}


uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, FR_Ctrls, DB, FR_SynMemo
{$IFDEF QBUILDER}
, QBuilder
{$ENDIF}
;

type
  TfrDBSQLEditorForm = class(TForm)
    MemoPanel: TPanel;
    Bevel2: TBevel;
    Panel2: TPanel;
    Panel1: TPanel;
    OkBtn: TfrSpeedButton;
    CancelBtn: TfrSpeedButton;
    OpenBtn: TfrSpeedButton;
    SaveBtn: TfrSpeedButton;
    Bevel1: TBevel;
    CutBtn: TfrSpeedButton;
    CopyBtn: TfrSpeedButton;
    PasteBtn: TfrSpeedButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    SQLBtn: TfrSpeedButton;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure M1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
    procedure CutBtnClick(Sender: TObject);
    procedure CopyBtnClick(Sender: TObject);
    procedure PasteBtnClick(Sender: TObject);
    procedure OpenBtnClick(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure SQLBtnClick(Sender: TObject);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
    M1: TfrSyntaxMemo;
{$IFDEF QBUILDER}
    QBEngine: TOQBEngine;
{$ENDIF}
    Query: TDataSet;
  end;


implementation

uses FR_Class, FR_Const, FR_Utils, FR_Dock, Registry;

{$R *.DFM}


procedure TfrDBSQLEditorForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = vk_Return) and (ssCtrl in Shift) then
  begin
    ModalResult := mrOk;
    Key := 0;
  end;
end;

procedure TfrDBSQLEditorForm.M1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = vk_Escape then ModalResult := mrCancel;
end;

procedure TfrDBSQLEditorForm.Localize;
begin
  Caption := frLoadStr(frRes + 4010);
  OpenBtn.Hint := frLoadStr(frRes + 3099);
  SaveBtn.Hint := frLoadStr(frRes + 3100);
  CutBtn.Hint := frLoadStr(frRes + 091);
  CopyBtn.Hint := frLoadStr(frRes + 092);
  PasteBtn.Hint := frLoadStr(frRes + 093);
  SQLBtn.Hint := frLoadStr(frRes + 3101);
  OkBtn.Hint := frLoadStr(SOk);
  CancelBtn.Hint := frLoadStr(SCancel);
end;

procedure TfrDBSQLEditorForm.FormCreate(Sender: TObject);
var
  Ini: TRegIniFile;
  Nm: String;
begin
  Localize;
  Ini := TRegIniFile.Create(RegRootKey);
  M1 := TfrSyntaxMemo.Create(Self);
  M1.Parent := MemoPanel;
  M1.SyntaxType := stSQL;
  {$I *.inc}
  M1.Align := alClient;
  M1.HelpContext := 20;
  M1.OnKeyDown := M1KeyDown;

  Nm := rsForm + frDesigner.ClassName;
  M1.Font.Name := Ini.ReadString(Nm, 'ScriptFontName', 'Courier New');
  M1.Font.Size := Ini.ReadInteger(Nm, 'ScriptFontSize', 10);
  Ini.Free;

{$IFDEF QBUILDER}
  SQLBtn.Visible := False;
{$ENDIF}
end;

procedure TfrDBSQLEditorForm.CancelBtnClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrDBSQLEditorForm.OkBtnClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfrDBSQLEditorForm.CutBtnClick(Sender: TObject);
begin
  M1.CutToClipboard;
end;

procedure TfrDBSQLEditorForm.CopyBtnClick(Sender: TObject);
begin
  M1.CopyToClipboard;
end;

procedure TfrDBSQLEditorForm.PasteBtnClick(Sender: TObject);
begin
  M1.PasteFromClipboard;
end;

procedure TfrDBSQLEditorForm.OpenBtnClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    M1.Lines.LoadFromFile(OpenDialog1.FileName);
end;

procedure TfrDBSQLEditorForm.SaveBtnClick(Sender: TObject);
begin
  if SaveDialog1.Execute then
    M1.Lines.SaveToFile(SaveDialog1.FileName);
end;

procedure TfrDBSQLEditorForm.SQLBtnClick(Sender: TObject);
{$IFDEF QBUILDER}
var
  OQB: TOQBuilderDialog;
{$ENDIF}
begin
{$IFDEF QBUILDER}
  OQB := TOQBuilderDialog.Create(nil);
  OQB.OQBEngine := QBEngine;

//  QBEngine.UpdateTableList;
  OQB.ShowButtons := [bOpenDialog, bSaveDialog, bRunQuery];
  if OQB.Execute then
    M1.Lines.Assign(OQB.SQL);

  OQB.Free;
{$ENDIF}
end;

end.
