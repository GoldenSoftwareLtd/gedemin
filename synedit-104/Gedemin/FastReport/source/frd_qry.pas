
{******************************************}
{                                          }
{     FastReport v2.5 - Data storage       }
{            Query properties              }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}
// 18/11/1999 :
// Implementation of QBUILDER is
// made by Olivier GUILBAUD (golivier@free.fr)

unit FRD_Qry;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DB, FRD_Wrap
{$IFDEF QBUILDER}
, FR_QBEng, QBuilder
{$ENDIF}
{$IFDEF MWEDIT}
, mwHighlighter, wmSQLSyn, mwCustomEdit
{$ENDIF};

type
  TfrQueryPropForm = class(TForm)
    GroupBox3: TGroupBox;
    Label6: TLabel;
    MasterCB: TComboBox;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    NameE: TEdit;
    FieldsB: TButton;
    Button2: TButton;
    Button3: TButton;
    ParamsB: TButton;
    Label3: TLabel;
    AliasCB: TComboBox;
    Button1: TButton;
    Button4: TButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    bSQB: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure ParamsBClick(Sender: TObject);
    procedure FieldsBClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure bSQBClick(Sender: TObject);
    procedure AliasCBChange(Sender: TObject);
  private
    { Private declarations }
{$IFDEF MWEDIT}
    SQLMemo: TmwCustomEdit;
    SynParser: TwmSQLSyn;
{$ELSE}
    SQLMemo: TMemo;
{$ENDIF}
    FSQL: TStringList;
    FName, FAlias: String;
    FMaster: TDataSource;
{$IFDEF QBUILDER}
    frQBE: TfrQBEngine;
    OQB: TfrQBuilderDialog;
{$ENDIF}
    procedure ApplySettings;
  public
    { Public declarations }
    Query: TfrQuery;
  end;

implementation

uses FRD_Flde, FRD_Parm, FR_Const, FR_Utils, FRD_Mngr, FR_Class;

{$R *.DFM}


procedure TfrQueryPropForm.FormShow(Sender: TObject);
begin
  FSQL := TStringList.Create;
  FSQL.Assign(Query.SQL);
  FName := Query.Name;
  FAlias := Query.frDatabaseName;
  FMaster := Query.DataSource;

  NameE.Text := Query.Name;
  GetDatabaseList(AliasCB.Items);
  if AliasCB.Items.IndexOf(Query.frDatabaseName) <> -1 then
    AliasCB.ItemIndex := AliasCB.Items.IndexOf(Query.frDatabaseName) else
    AliasCB.Text := Query.frDatabaseName;

  SQLMemo.Lines.Assign(Query.SQL);
  frGetComponents(Query.Owner, TDataSet, MasterCB.Items, Query);
  MasterCB.Text := GetDataSetName(Query.Owner, Query.DataSource);
{$IFDEF QBUILDER}
  AliasCBChange(nil);
{$ENDIF}
end;

procedure TfrQueryPropForm.FormHide(Sender: TObject);
begin
  if ModalResult = mrCancel then
  begin
    Query.SQL.Assign(FSQL);
    Query.Name := FName;
    Query.frDatabaseName := FAlias;
    Query.DataSource := FMaster;
  end;
  FSQL.Free;
end;

procedure TfrQueryPropForm.ApplySettings;
var
  d: TDataset;
begin
  Query.Name := NameE.Text;
  Query.frDatabaseName := AliasCB.Text;
  Query.SQL.Assign(SQLMemo.Lines);
  d := frFindComponent(frDataModule, MasterCB.Text) as TDataset;
  Query.DataSource := GetDataSource(d);
end;

procedure TfrQueryPropForm.ParamsBClick(Sender: TObject);
var
  ParamsForm: TfrParamsForm;
begin
  ApplySettings;
  if Query.frParams.Count = 0 then Exit;
  ParamsForm := TfrParamsForm.Create(nil);
  with ParamsForm do
  begin
    Query := Self.Query;
    Caption := Query.Name + ' ' + frLoadStr(SParams);
    ShowModal;
    Free;
  end;
end;

procedure TfrQueryPropForm.FieldsBClick(Sender: TObject);
var
  FieldsEditorForm: TfrFieldsEditorForm;
begin
  ApplySettings;
  FieldsEditorForm := TfrFieldsEditorForm.Create(nil);
  with FieldsEditorForm do
  begin
    Dataset := Query;
    ShowModal;
    Free;
  end;
end;

procedure TfrQueryPropForm.Button2Click(Sender: TObject);
begin
  ApplySettings;
  try
    Query.FieldDefs.Update;
  except
    on E: exception do
    begin
      MessageBox(0, PChar(frLoadStr(SQueryError) + #13#10 + E.Message), PChar(frLoadStr(SError)),
        mb_Ok + mb_IconError);
      ModalResult := 0;
    end;
  end;
end;

procedure TfrQueryPropForm.FormCreate(Sender: TObject);
begin
  Caption := frLoadStr(frRes + 3090);
  GroupBox3.Caption := frLoadStr(frRes + 3091);
  Label6.Caption := frLoadStr(frRes + 3092);
  GroupBox1.Caption := frLoadStr(frRes + 3093);
  Label1.Caption := frLoadStr(frRes + 3094);
  Label2.Caption := frLoadStr(frRes + 3095);
  Label3.Caption := frLoadStr(frRes + 3096);
  FieldsB.Caption := frLoadStr(frRes + 3097);
  ParamsB.Caption := frLoadStr(frRes + 3098);
  Button1.Caption := frLoadStr(frRes + 3099);
  Button4.Caption := frLoadStr(frRes + 3100);
  bSQB.Caption := frLoadStr(frRes + 3101);
  Button2.Caption := frLoadStr(SOk);
  Button3.Caption := frLoadStr(SCancel);

{$IFDEF MWEDIT}
  SQLMemo := TmwCustomEdit.Create(Self);
  SynParser := TwmSQLSyn.Create(Self);
  {$I *.inc}
{$ELSE}
  SQLMemo := TMemo.Create(Self);
{$ENDIF}
  SQLMemo.Parent := GroupBox1;
  SQLMemo.SetBounds(8, 84, 429, 165);
  SQLMemo.HelpContext := 176;
  SQLMemo.ScrollBars := ssNone;
  SQLMemo.Font.Name := 'Courier New';
  SQLMemo.Font.Size := 10;
{$IFDEF MWEDIT}
  SQLMemo.Highlighter := SynParser;
  SQLMemo.Gutter.Visible := False;
{$ENDIF}
{$IFNDEF Delphi2}
  SQLMemo.Font.Charset := frCharset;
{$ENDIF}

{$IFDEF QBUILDER}
  bSQB.Visible := True;
  bSQB.Enabled := False;
{$ELSE}
  bSQB.Visible := False;
{$ENDIF}
end;

procedure TfrQueryPropForm.Button1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
    SQLMemo.Lines.LoadFromFile(OpenDialog1.FileName);
end;

procedure TfrQueryPropForm.Button4Click(Sender: TObject);
begin
  if SaveDialog1.Execute then
    SQLMemo.Lines.SaveToFile(SaveDialog1.FileName);
end;

procedure TfrQueryPropForm.bSQBClick(Sender: TObject);
begin
{$IFDEF QBUILDER}
// Initialisation

  frQBE := TfrQBEngine.Create(nil);
  OQB := TfrQBuilderDialog.Create(nil);
  OQB.OQBEngine := frQBE;

  Query.Name := NameE.Text;
  Query.frDatabaseName := AliasCB.Text;

  frQBE.frQuery := Self.Query;
  frQBE.UpdateTableList;
  if OQB.Execute then                          
  begin
    SQLMemo.Lines.Assign(OQB.SQL);
    Query.SQL.Assign(OQB.SQL);
  end;

  frQBE.Free;
  OQB.Free;

{$ENDIF}
end;

procedure TfrQueryPropForm.AliasCBChange(Sender: TObject);
begin
{$IFDEF QBUILDER}
  bSQB.Enabled := ((AliasCB.Text <> '') and (NameE.Text <> ''));
{$ENDIF}
end;

end.

