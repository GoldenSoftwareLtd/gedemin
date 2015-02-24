
{******************************************}
{                                          }
{     FastReport v2.5 - Data storage       }
{        Master/detail definition          }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FRD_md;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DB, FRD_Wrap, ExtCtrls, StdCtrls, FR_Const;

type
  TfrFieldsLinkForm = class(TForm)
    DetailL: TListBox;
    MasterL: TListBox;
    Label1: TLabel;
    Label2: TLabel;
    AddB: TButton;
    JoinL: TListBox;
    Label3: TLabel;
    ClearB: TButton;
    Bevel1: TBevel;
    OkB: TButton;
    CancelB: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure ClearBClick(Sender: TObject);
    procedure DetailLDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure DetailLClick(Sender: TObject);
    procedure MasterLClick(Sender: TObject);
    procedure AddBClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FMasterFields, FCurFields: String;
    lm, ld: TStringList;
    procedure FillLists;
  public
    { Public declarations }
    MasterDS: TDataset;
    DetailDS: TfrTable;
  end;

implementation

uses FR_Utils;

{$R *.DFM}

procedure TfrFieldsLinkForm.FillLists;
var
  i: Integer;
  s: String;
begin
  MasterL.Items.Assign(lm);
  DetailL.Items.Assign(ld);
  JoinL.Items.Clear;
  i := 1;
  while i <= Length(FCurFields) do
  begin
    s := ExtractFieldName(FCurFields, i);
    JoinL.Items.Add(DetailL.Items[0] + ' -> ' + s);
    DetailL.Items.Delete(0);
    MasterL.Items.Delete(MasterL.Items.IndexOf(s));
  end;
  AddB.Enabled := False;
end;

procedure TfrFieldsLinkForm.FormShow(Sender: TObject);
var
  i: Integer;
begin
  Caption := DetailDS.Name + ' -> ' + MasterDS.Name;
  lm := TStringList.Create;
  ld := TStringList.Create;
  FMasterFields := DetailDS.MasterFields;
  FCurFields := FMasterFields;
  MasterDS.GetFieldNames(lm);
  DetailDS.Open;
  for i := 0 to DetailDS.IndexFieldCount - 1 do
    ld.Add(DetailDS.IndexFields[i].FieldName);
  DetailDS.Close;
  FillLists;
end;

procedure TfrFieldsLinkForm.FormHide(Sender: TObject);
begin
  if ModalResult = mrOk then
    DetailDS.MasterFields := FCurFields else
    DetailDS.MasterFields := FMasterFields;
  ld.Free;
  lm.Free;
end;

procedure TfrFieldsLinkForm.ClearBClick(Sender: TObject);
begin
  FCurFields := '';
  FillLists;
end;

procedure TfrFieldsLinkForm.DetailLDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  with DetailL.Canvas do
  begin
    if Index > 0 then
      Font.Color := clBtnShadow;
    FillRect(Rect);
    TextOut(Rect.Left + 2, Rect.Top, DetailL.Items[Index]);
  end;
end;

procedure TfrFieldsLinkForm.DetailLClick(Sender: TObject);
begin
  if DetailL.ItemIndex > 0 then
    DetailL.ItemIndex := 0;
  if MasterL.ItemIndex <> -1 then
    AddB.Enabled := True;
end;

procedure TfrFieldsLinkForm.MasterLClick(Sender: TObject);
begin
  if DetailL.ItemIndex <> -1 then
    AddB.Enabled := True;
end;

procedure TfrFieldsLinkForm.AddBClick(Sender: TObject);
var s: String;
begin
  s := MasterL.Items[MasterL.ItemIndex];
  if FCurFields = '' then
    FCurFields := s else
    FCurFields := FCurFields + ';' + s;
  FillLists;
end;

procedure TfrFieldsLinkForm.FormCreate(Sender: TObject);
begin
  Label1.Caption := frLoadStr(frRes + 3130);
  Label2.Caption := frLoadStr(frRes + 3131);
  Label3.Caption := frLoadStr(frRes + 3132);
  AddB.Caption := frLoadStr(frRes + 3133);
  ClearB.Caption := frLoadStr(frRes + 3134);
  OkB.Caption := frLoadStr(SOk);
  CancelB.Caption := frLoadStr(SCancel);
end;

end.

