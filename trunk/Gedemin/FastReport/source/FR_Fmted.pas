
{******************************************}
{                                          }
{             FastReport v2.53             }
{              Format editor               }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_FmtEd;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TfrFmtForm = class(TForm)
    GroupBox2: TGroupBox;
    Button1: TButton;
    Button2: TButton;
    CatLB: TListBox;
    TypeLB: TListBox;
    Label3: TLabel;
    FormatEdit: TEdit;
    Label1: TLabel;
    DecEdit: TEdit;
    Label2: TLabel;
    SplEdit: TEdit;
    procedure FormActivate(Sender: TObject);
    procedure SplEditEnter(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CatLBClick(Sender: TObject);
    procedure TypeLBClick(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
  private
    { Private declarations }
    procedure ShowPanels;
    procedure Localize;
  public
    { Public declarations }
    Format: Integer;
    FormatStr: String;
  end;


implementation

{$R *.DFM}

uses FR_Class, FR_Const, FR_Utils;

const
  CategCount = 5;

{$WARNINGS OFF}
procedure TfrFmtForm.FormActivate(Sender: TObject);
var
  i: Integer;
begin
  CatLB.Items.Clear;
  for i := 0 to CategCount - 1 do
    CatLB.Items.Add(frLoadStr(SCateg1 + i));
  CatLB.ItemIndex := (Format and $0F000000) div $01000000;
  CatLBClick(nil);
  TypeLB.ItemIndex := (Format and $00FF0000) div $00010000;
  ShowPanels;
end;

procedure TfrFmtForm.FormDeactivate(Sender: TObject);
var
  c: Char;
begin
  if ModalResult = mrOk then
  begin
    Format := CatLB.ItemIndex * $01000000 + TypeLB.ItemIndex * $00010000 +
      StrToIntDef(DecEdit.Text, 0) * $00000100;
    c := ',';
    if SplEdit.Text <> '' then
      c := SplEdit.Text[1];
    Format := Format + Ord(c);
    if FormatEdit.Enabled then
      FormatStr := FormatEdit.Text;
  end;
end;

procedure TfrFmtForm.ShowPanels;
begin
  frEnableControls([Label1, Label2, DecEdit, SplEdit], CatLB.ItemIndex = 1);
  if DecEdit.Enabled then
  begin
    DecEdit.Text := IntToStr((Format and $0000FF00) div $00000100);
    SplEdit.Text := Chr(Format and $000000FF);
  end
  else
  begin
    DecEdit.Text := '';
    SplEdit.Text := '';
  end;

  frEnableControls([Label3, FormatEdit], TypeLB.ItemIndex = 4);
  if FormatEdit.Enabled then
    FormatEdit.Text := FormatStr else
    FormatEdit.Text := '';
end;

procedure TfrFmtForm.CatLBClick(Sender: TObject);
var
  i: Integer;
  s: String;
begin
  TypeLB.Items.Clear;
  for i := 0 to 4 do
  begin
    s := frLoadStr(SFormat11 + CatLB.ItemIndex * 5 + i);
    if s <> '' then
      TypeLB.Items.Add(s);
  end;
  TypeLB.ItemIndex := 0;
  TypeLBClick(nil);
end;

procedure TfrFmtForm.TypeLBClick(Sender: TObject);
begin
  ShowPanels;
end;

procedure TfrFmtForm.SplEditEnter(Sender: TObject);
begin
  SplEdit.SelectAll;
end;
{$WARNINGS ON}

procedure TfrFmtForm.Localize;
begin
  Caption := frLoadStr(frRes + 420);
  Label1.Caption := frLoadStr(frRes + 422);
  Label2.Caption := frLoadStr(frRes + 423);
  Label3.Caption := frLoadStr(frRes + 424);
  Button1.Caption := frLoadStr(SOk);
  Button2.Caption := frLoadStr(SCancel);
end;

procedure TfrFmtForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

end.
