
{******************************************}
{                                          }
{             FastReport v2.53             }
{             Template viewer              }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_Newrp;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, FR_Const, ComCtrls {$IFDEF Delphi4}, ImgList {$ENDIF};

type
  TfrTemplForm = class(TForm)
    GroupBox1: TGroupBox;
    Memo1: TMemo;
    Image1: TImage;
    Button1: TButton;
    Button2: TButton;
    LB1: TListView;
    ImageList1: TImageList;
    procedure FormActivate(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LB1DblClick(Sender: TObject);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
    TemplName: String;
  end;


implementation

uses FR_Class, FR_Desgn, FR_Utils;

{$R *.DFM}

var
  Path: String;


procedure TfrTemplForm.FormActivate(Sender: TObject);
var
  SearchRec: TSearchRec;
  r: Word;
  Item: TListItem;
begin
  Path := frTemplateDir;
  if frTemplateDir = '' then
    Path := ExtractFilePath(ParamStr(0))
  else if Path[Length(Path)] <> '\' then
    Path := Path + '\';
  LB1.Items.Clear;
  R := FindFirst(Path + '*.frt', faAnyFile, SearchRec);
  while R = 0 do
  begin
    if (SearchRec.Attr and faDirectory) = 0 then
    begin
      Item := LB1.Items.Add;
      Item.ImageIndex := 0;
      Item.StateIndex := 0;
      Item.Caption := ChangeFileExt(SearchRec.Name, '');
    end;
    R := FindNext(SearchRec);
  end;
  FindClose(SearchRec);
  Memo1.Lines.Clear;
  Image1.Picture.Bitmap.Assign(nil);
  Button1.Enabled := False;
end;

procedure TfrTemplForm.ListBox1Click(Sender: TObject);
begin
  Button1.Enabled := LB1.Selected <> nil;
  if Button1.Enabled then
  begin
    CurReport.LoadTemplate(Path + LB1.Selected.Caption + '.frt',
      Memo1.Lines, Image1.Picture.Bitmap, False);
  end;
end;

procedure TfrTemplForm.LB1DblClick(Sender: TObject);
begin
  if Button1.Enabled then ModalResult := mrOk;
end;

procedure TfrTemplForm.FormDeactivate(Sender: TObject);
begin
  if ModalResult = mrOk then
    TemplName := Path + LB1.Selected.Caption + '.frt';
end;

procedure TfrTemplForm.Localize;
begin
  Caption := frLoadStr(frRes + 318);
  GroupBox1.Caption := frLoadStr(frRes + 319);
  Button1.Caption := frLoadStr(SOk);
  Button2.Caption := frLoadStr(SCancel);
end;

procedure TfrTemplForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

end.

