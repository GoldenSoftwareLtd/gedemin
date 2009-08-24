
{******************************************}
{                                          }
{     FastReport v2.5 - Data storage       }
{           Table properties               }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FRD_Tbl;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FR_Ctrls, ExtCtrls, DB, FRD_Wrap;

type
  TfrTablePropForm = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    NameE: TEdit;
    GroupBox3: TGroupBox;
    Label4: TLabel;
    IndexCB: TComboBox;
    Label5: TLabel;
    FilterE: TEdit;
    Label6: TLabel;
    MasterCB: TComboBox;
    Label7: TLabel;
    MasterE: TfrComboEdit;
    FieldsB: TButton;
    Label8: TLabel;
    Button2: TButton;
    Button3: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure IndexCBDropDown(Sender: TObject);
    procedure FieldsBClick(Sender: TObject);
    procedure MasterSBClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FName, FIndexName, FFilter, FMasterFields: String;
    FMasterSource: TDataSource;
    procedure ApplySettings;
  public
    { Public declarations }
    Table: TfrTable;
  end;

implementation

uses FRD_Flde, FRD_md, FR_Const, FR_Utils, FRD_Mngr;

{$R *.DFM}

procedure TfrTablePropForm.FormShow(Sender: TObject);
begin
  FName := Table.Name;
  FIndexName := Table.IndexName;
  FFilter := Table.Filter;
  FMasterSource := Table.MasterSource;
  FMasterFields := Table.MasterFields;

  Caption := frLoadStr(STableProps) + ': ' + GetDataPath(Table);
  NameE.Text := Table.Name;

  frGetComponents(Table.Owner, TDataSet, MasterCB.Items, Table);
  MasterCB.Text := GetDataSetName(Table.Owner, Table.MasterSource);

  IndexCB.Text := Table.IndexName;
  FilterE.Text := Table.Filter;
  MasterE.Text := Table.MasterFields;
end;

procedure TfrTablePropForm.FormHide(Sender: TObject);
begin
  if ModalResult = mrOk then
    ApplySettings else
  begin
    Table.Name := FName;
    Table.IndexName := FIndexName;
    Table.Filter := FFilter;
    Table.Filtered := Table.Filter <> '';
    Table.MasterSource := FMasterSource;
    Table.MasterFields := FMasterFields;
  end;
end;

procedure TfrTablePropForm.ApplySettings;
var
  d: TDataset;
begin
  Table.Name := NameE.Text;
  Table.IndexName := IndexCB.Text;
  Table.Filter := FilterE.Text;
  Table.Filtered := Table.Filter <> '';
  d := frFindComponent(Table.Owner, MasterCB.Text) as TDataSet;
  Table.MasterSource := GetDataSource(d);
  Table.MasterFields := MasterE.Text;
end;

procedure TfrTablePropForm.IndexCBDropDown(Sender: TObject);
var
  i: Integer;
begin
  ApplySettings;
  IndexCB.Items.Clear;
  IndexCB.Text := '';
  if Table.IndexDefs <> nil then
  begin
    Table.IndexDefs.Update;
    for i := 0 to Table.IndexDefs.Count-1 do
      if Table.IndexDefs[i].Name <> '' then
        IndexCB.Items.Add(Table.IndexDefs[i].Name);
    if Table.IndexName <> '' then
      IndexCB.ItemIndex := IndexCB.Items.IndexOf(Table.IndexName);
  end;
end;

procedure TfrTablePropForm.FieldsBClick(Sender: TObject);
var
  FieldsEditorForm: TfrFieldsEditorForm;
begin
  ApplySettings;
  FieldsEditorForm := TfrFieldsEditorForm.Create(nil);
  with FieldsEditorForm do
  begin
    DataSet := Table;
    ShowModal;
    Free;
  end;
end;

procedure TfrTablePropForm.MasterSBClick(Sender: TObject);
var
  FieldsLinkForm: TfrFieldsLinkForm;
begin
  FieldsLinkForm := TfrFieldsLinkForm.Create(nil);
  with FieldsLinkForm do
  begin
    MasterDS := frFindComponent(Table.Owner, MasterCB.Text) as TDataSet;
    DetailDS := Table;
    if MasterDS <> nil then
    begin
      ApplySettings;
      ShowModal;
      MasterE.Text := Table.MasterFields;
    end;
    Free;
  end;
end;

procedure TfrTablePropForm.FormCreate(Sender: TObject);
begin
  GroupBox1.Caption := frLoadStr(frRes + 3020);
  Label1.Caption := frLoadStr(frRes + 3021);
  Label8.Caption := frLoadStr(frRes + 3022);
  FieldsB.Caption := frLoadStr(frRes + 3023);
  GroupBox3.Caption := frLoadStr(frRes + 3024);
  Label4.Caption := frLoadStr(frRes + 3025);
  Label5.Caption := frLoadStr(frRes + 3026);
  Label6.Caption := frLoadStr(frRes + 3027);
  Label7.Caption := frLoadStr(frRes + 3028);
  Button2.Caption := frLoadStr(SOk);
  Button3.Caption := frLoadStr(SCancel);
end;

end.

