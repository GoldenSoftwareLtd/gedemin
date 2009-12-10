
{******************************************}
{                                          }
{     FastReport v2.5 - DB components      }
{           Available fields list          }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_DBFldList;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DB;

type
  TfrDBFieldsListForm = class(TForm)
    FieldsL: TListBox;
    Button1: TButton;
    Button2: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    function FieldExists(FName: String): Boolean;
    procedure Localize;
  public
    { Public declarations }
    DataSet: TDataSet;
  end;


implementation

uses FR_Const, FR_DBUtils, FR_Utils;

{$R *.DFM}

function TfrDBFieldsListForm.FieldExists(FName: String): Boolean;
var
  i: Integer;
begin
  Result := False;
  with DataSet do
  for i := 0 to FieldCount - 1 do
    if AnsiCompareText(Fields[i].FieldName, FName) = 0 then
    begin
      Result := True;
      break;
    end;
end;

procedure TfrDBFieldsListForm.FormShow(Sender: TObject);
var
  i: Integer;
begin
  FieldsL.Clear;
  with DataSet do
  begin
    FieldDefs.Update;
    for i := 0 to FieldDefs.Count - 1 do
      if not FieldExists(FieldDefs.Items[i].Name) then
        FieldsL.Items.Add(FieldDefs.Items[i].Name);
  end;
  for i := 0 to FieldsL.Items.Count - 1 do
    FieldsL.Selected[i] := True;
end;

procedure TfrDBFieldsListForm.FormHide(Sender: TObject);
var
  i: Integer;
begin
  if ModalResult = mrOk then
    for i := 0 to FieldsL.Items.Count - 1 do
      if FieldsL.Selected[i] then
        frFindFieldDef(DataSet, FieldsL.Items[i]).CreateField(DataSet);
end;

procedure TfrDBFieldsListForm.Localize;
begin
  Caption := frLoadStr(frRes + 3060);
  Button1.Caption := frLoadStr(SOk);
  Button2.Caption := frLoadStr(SCancel);
end;

procedure TfrDBFieldsListForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

end.

