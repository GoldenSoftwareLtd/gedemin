
{******************************************}
{                                          }
{     FastReport v2.5 - DB components      }
{              Field editor                }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_DBFldEditor;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DB;

type
  TfrDBFieldsEditorForm = class(TForm)
    FieldsL: TListBox;
    AddFieldsB: TButton;
    AddLookupB: TButton;
    SelAllB: TButton;
    DeleteB: TButton;
    ExitB: TButton;
    procedure FormShow(Sender: TObject);
    procedure AddFieldsBClick(Sender: TObject);
    procedure SelAllBClick(Sender: TObject);
    procedure DeleteBClick(Sender: TObject);
    procedure AddLookupBClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure FillList;
    procedure Localize;
  public
    { Public declarations }
    DataSet: TDataSet;
    DisableLookups: Boolean;
  end;


implementation

uses FR_Const, FR_DBFldList, FR_DBNewLookup, FR_Utils;

{$R *.DFM}

procedure TfrDBFieldsEditorForm.FillList;
var
  i: Integer;
begin
  FieldsL.Items.Clear;
  with DataSet do
  for i := 0 to FieldCount - 1 do
    FieldsL.Items.Add(Fields[i].FieldName);
end;

procedure TfrDBFieldsEditorForm.FormShow(Sender: TObject);
begin
  Caption := DataSet.Name + ' ' + frLoadStr(SFields);
  FillList;
  AddLookupB.Enabled := not DisableLookups;
end;

procedure TfrDBFieldsEditorForm.AddFieldsBClick(Sender: TObject);
begin
  try
    DataSet.FieldDefs.Update;
    with TfrDBFieldsListForm.Create(nil) do
    begin
      DataSet := Self.DataSet;
      if ShowModal = mrOk then
        FillList;
      Free;
    end;
  finally;
  end;
end;

procedure TfrDBFieldsEditorForm.SelAllBClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to FieldsL.Items.Count - 1 do
    FieldsL.Selected[i] := True;
end;

procedure TfrDBFieldsEditorForm.DeleteBClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to FieldsL.Items.Count - 1 do
    if FieldsL.Selected[i] then
      DataSet.FindField(FieldsL.Items[i]).Free;
  FillList;
end;

procedure TfrDBFieldsEditorForm.AddLookupBClick(Sender: TObject);
begin
  with TfrDBLookupFieldForm.Create(nil) do
  begin
    Dataset := Self.Dataset;
    if ShowModal = mrOk then
      FillList;
    Free;
  end;
end;

procedure TfrDBFieldsEditorForm.Localize;
begin
  AddFieldsB.Caption := frLoadStr(frRes + 3040);
  AddLookupB.Caption := frLoadStr(frRes + 3041);
  SelAllB.Caption := frLoadStr(frRes + 3042);
  DeleteB.Caption := frLoadStr(frRes + 3043);
  ExitB.Caption := frLoadStr(frRes + 3044);
end;

procedure TfrDBFieldsEditorForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

end.

