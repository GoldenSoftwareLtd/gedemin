
{******************************************}
{                                          }
{     FastReport v2.5 - Data storage       }
{               Fields list                }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FRD_Flde;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DB, FRD_Mngr, FR_Const;

type
  TfrFieldsEditorForm = class(TForm)
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
  public
    { Public declarations }
    DataSet: TDataSet;
  end;

implementation

uses FRD_Fldl, FRD_look, FR_Utils;

{$R *.DFM}

procedure TfrFieldsEditorForm.FillList;
var
  i: Integer;
begin
  FieldsL.Items.Clear;
  with DataSet do
  for i := 0 to FieldCount - 1 do
    FieldsL.Items.Add(Fields[i].FieldName);
end;

procedure TfrFieldsEditorForm.FormShow(Sender: TObject);
begin
  Caption := DataSet.Name + ' ' + frLoadStr(SFields);
  FillList;
end;

procedure TfrFieldsEditorForm.AddFieldsBClick(Sender: TObject);
var
  FieldsListForm: TfrFieldsListForm;
begin
  FieldsListForm := TfrFieldsListForm.Create(nil);
  with FieldsListForm do
  begin
    DataSet := Self.DataSet;
    if ShowModal = mrOk then
      FillList;
    Free;
  end;
end;

procedure TfrFieldsEditorForm.SelAllBClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to FieldsL.Items.Count - 1 do
    FieldsL.Selected[i] := True;
end;

procedure TfrFieldsEditorForm.DeleteBClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to FieldsL.Items.Count - 1 do
    if FieldsL.Selected[i] then
      DataSet.FindField(FieldsL.Items[i]).Free;
  FillList;
end;

procedure TfrFieldsEditorForm.AddLookupBClick(Sender: TObject);
var
  LookupFieldForm: TfrLookupFieldForm;
begin
  LookupFieldForm := TfrLookupFieldForm.Create(nil);
  with LookupFieldForm do
  begin
    Dataset := Self.Dataset;
    if ShowModal = mrOk then
      FillList;
    Free;
  end;
end;

procedure TfrFieldsEditorForm.FormCreate(Sender: TObject);
begin
  AddFieldsB.Caption := frLoadStr(frRes + 3040);
  AddLookupB.Caption := frLoadStr(frRes + 3041);
  SelAllB.Caption := frLoadStr(frRes + 3042);
  DeleteB.Caption := frLoadStr(frRes + 3043);
  ExitB.Caption := frLoadStr(frRes + 3044);
end;

end.

