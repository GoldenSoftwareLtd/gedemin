
{******************************************}
{                                          }
{     FastReport v2.5 - Data storage       }
{          Select table dialog             }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FRD_Tbl1;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, FR_DBOp;

type
  TfrSelectTblForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    CB1: TComboBox;
    CB2: TComboBox;
    GroupBox2: TGroupBox;
    BrowseB: TButton;
    OpenTable: TfrOpenDBDialog;
    procedure FormHide(Sender: TObject);
    procedure CB1Click(Sender: TObject);
    procedure BrowseBClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    DBName, TableName: String;
  end;


implementation

{$R *.DFM}

uses FRD_Mngr, FRD_Wrap, FR_Utils, FR_Const
{$IFDEF IBX}, IBDatabase{$ENDIF}
{$IFDEF ADO}, ADODB{$ENDIF}
{$IFDEF BDE}, DB, DBTables{$ENDIF};


procedure TfrSelectTblForm.FormCreate(Sender: TObject);
begin
  Caption := frLoadStr(frRes + 3220);
  GroupBox1.Caption := frLoadStr(frRes + 3221);
  GroupBox2.Caption := frLoadStr(frRes + 3222);
  Label1.Caption := frLoadStr(frRes + 3223);
  Label2.Caption := frLoadStr(frRes + 3224);
  BrowseB.Caption := frLoadStr(frRes + 3225);
  Button1.Caption := frLoadStr(SOK);
  Button2.Caption := frLoadStr(SCancel);
  GetDatabaseList(CB1.Items);
{$IFNDEF BDE}
  BrowseB.Enabled := False;
{$ENDIF}
end;

procedure TfrSelectTblForm.FormHide(Sender: TObject);
begin
  if ModalResult = mrOk then
  begin
    DBName := CB1.Text;
    TableName := CB2.Text;
  end;
end;

procedure TfrSelectTblForm.CB1Click(Sender: TObject);
{$IFDEF IBX}
var
  d: TIBDatabase;
{$ENDIF}
{$IFDEF ADO}
var
  d: TADOConnection;
{$ENDIF}
begin
{$IFDEF BDE}
  Session.GetTableNames(CB1.Text, '', True, False, CB2.Items);
{$ENDIF}
{$IFDEF IBX}
  d := frFindComponent(frDataModule, CB1.Text) as TIBDatabase;
  CB2.Items.Clear;
  if d <> nil then
    d.GetTableNames(CB2.Items);
{$ENDIF}
{$IFDEF ADO}
  d := frFindComponent(frDataModule, CB1.Text) as TADOConnection;
  CB2.Items.Clear;
  if d <> nil then
    d.GetTableNames(CB2.Items);
{$ENDIF}
end;

procedure TfrSelectTblForm.BrowseBClick(Sender: TObject);
begin
  OpenTable.Filter := frLoadStr(STables) + ' (*.db,*.dbf)|*.db;*.dbf';
  if OpenTable.Execute then
  begin
    CB1.Text := OpenTable.AliasName;
    CB2.Text := OpenTable.TableName;
  end;
end;

end.
