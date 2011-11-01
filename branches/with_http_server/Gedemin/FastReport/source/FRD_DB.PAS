
{******************************************}
{                                          }
{     FastReport v2.5 - Data storage       }
{       Database properties dialog         }
{                                          }
{ Copyright (c) 1998-2004 by Tzyganenko A. }
{                                          }
{******************************************}

unit FRD_DB;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FRD_Wrap, FR_Ctrls, ExtCtrls;

type
  TfrDBPropForm = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    NameE: TEdit;
    DirE: TfrComboEdit;
    GroupBox2: TGroupBox;
    Param: TMemo;
    Button1: TButton;
    Button2: TButton;
    OpenDB: TOpenDialog;
    Label3: TLabel;
    DriverCB: TComboBox;
    LoginCB: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure DirBClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Database: TfrDatabase;
  end;


implementation

{$R *.DFM}

uses FR_Const, FR_Utils
{$IFDEF ADO}
  , ADODB, ADOInt
{$ENDIF}
{$IFDEF BDE}
  , DB, DBTables
{$ENDIF};

procedure TfrDBPropForm.FormCreate(Sender: TObject);
begin
  DirE.ButtonEnabled := True;
  GroupBox1.Caption := frLoadStr(frRes + 3201);
  GroupBox2.Caption := frLoadStr(frRes + 3202);
  Label1.Caption := frLoadStr(frRes + 3203);
{$IFDEF ADO}
  Caption := frLoadStr(frRes + 3200) + ': ADO';
  Label2.Caption := frLoadStr(frRes + 3204);
{$ENDIF}
{$IFDEF IBX}
  Caption := frLoadStr(frRes + 3200) + ': IBX';
  Label2.Caption := frLoadStr(frRes + 3205);
{$ENDIF}
{$IFDEF BDE}
  Caption := frLoadStr(frRes + 3200) + ': BDE';
  Label2.Caption := frLoadStr(frRes + 3206);
  DirE.ButtonEnabled := False;
  frEnableControls([Label3, DriverCB], True);
  Session.GetDriverNames(DriverCB.Items);
{$ENDIF}
  Label3.Caption := frLoadStr(frRes + 3207);
  LoginCB.Caption := frLoadStr(frRes + 3208);
  Button1.Caption := frLoadStr(SOk);
  Button2.Caption := frLoadStr(SCancel);
end;

procedure TfrDBPropForm.FormShow(Sender: TObject);
begin
  NameE.Text := Database.Name;
  DirE.Text := Database.frDatabaseName;
  DriverCB.ItemIndex := DriverCB.Items.IndexOf(Database.frDriver);
  LoginCB.Checked := Database.LoginPrompt;
  if Database.Params <> nil then
    Param.Lines.Assign(Database.Params) else
    frEnableControls([Param], False);
end;

procedure TfrDBPropForm.FormHide(Sender: TObject);
begin
  if ModalResult = mrOk then
  begin
    Database.Connected := False;
    Database.Name := NameE.Text;
    Database.frDriver := DriverCB.Items[DriverCB.ItemIndex];
    Database.LoginPrompt := LoginCB.Checked;
    if Database.Params <> nil then
      Database.Params.Assign(Param.Lines);
    Database.frDatabaseName := DirE.Text;
    Database.Connected := True;
  end;
end;

procedure TfrDBPropForm.DirBClick(Sender: TObject);
var
  fName: String;
begin
  fName := '';
{$IFDEF IBX}
  OpenDB.Filter := frLoadStr(SDatabase) + ' (*.gdb)|*.gdb';
{$ENDIF}
{$IFDEF ADO}
  fName := PromptDataLinkFile(Handle, '');
  if fName <> '' then
    fName := CT_FILENAME + fName;
{$ELSE}
  if OpenDB.Execute then
    fName := OpenDB.FileName;
{$ENDIF}
  DirE.Text := fName;
end;

end.
