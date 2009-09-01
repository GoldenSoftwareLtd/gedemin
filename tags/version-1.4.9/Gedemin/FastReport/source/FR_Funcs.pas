
{******************************************}
{                                          }
{             FastReport v2.53             }
{              Function list               }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_Funcs;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls {$IFDEF Delphi4}, ImgList {$ENDIF};

type
  TfrFuncForm = class(TForm)
    DescrLabel: TLabel;
    Bevel1: TBevel;
    FuncLB: TListBox;
    FuncLabel: TLabel;
    Button1: TButton;
    Button2: TButton;
    Image1: TImage;
    Tree1: TTreeView;
    ImageList1: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure FuncLBClick(Sender: TObject);
    procedure FuncLBDblClick(Sender: TObject);
    procedure CatLBDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure Tree1Change(Sender: TObject; Node: TTreeNode);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
  end;


implementation

{$R *.DFM}

uses FR_Class, FR_Const, FR_Utils;


{ TfrFuncForm }

procedure TfrFuncForm.Localize;
begin
  Caption := frLoadStr(frRes + 720);
  Button1.Caption := frLoadStr(SOk);
  Button2.Caption := frLoadStr(SCancel);
end;

procedure TfrFuncForm.FormCreate(Sender: TObject);
var
  i: Integer;
  sl: TStringList;
  ANode, TreeNode: TTreeNode;
begin
  Localize;
  sl := TStringList.Create;
  frInstalledFunctions.GetCategoryList(sl);

  TreeNode := Tree1.Items.Add(nil, frLoadStr(SAllCategories));
  TreeNode.ImageIndex := 0;
  TreeNode.SelectedIndex := 0;

  for i := 0 to sl.Count - 1 do
  begin
    ANode := Tree1.Items.AddChild(TreeNode, sl[i]);
    ANode.ImageIndex := 1;
    ANode.SelectedIndex := 1;
  end;

  Tree1.FullExpand;
  Tree1.Selected := Tree1.Items[0];
  sl.Free;
end;

procedure TfrFuncForm.Tree1Change(Sender: TObject; Node: TTreeNode);
begin
  frInstalledFunctions.GetFunctionList(Node.Text, FuncLB.Items);
  FuncLB.ItemIndex := 0;
  FuncLBClick(nil);
end;

procedure TfrFuncForm.FuncLBClick(Sender: TObject);
var
  s: String;
begin
  s := frInstalledFunctions.GetFunctionDesc(FuncLB.Items[FuncLB.ItemIndex]);
  FuncLabel.Caption := Copy(s, 1, Pos('/', s) - 1);
  DescrLabel.Caption := Copy(s, Pos('/', s) + 1, 1000);
end;

procedure TfrFuncForm.FuncLBDblClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfrFuncForm.CatLBDrawItem(Control: TWinControl; Index: Integer;
  ARect: TRect; State: TOwnerDrawState);
var
  r: TRect;
begin
  r := ARect;
  r.Right := r.Left + 18;
  r.Bottom := r.Top + 16;
  OffsetRect(r, 2, 0);
  with TListBox(Control) do
  begin
    Canvas.FillRect(ARect);
    Canvas.BrushCopy(r, Image1.Picture.Bitmap, Rect(0, 0, 18, 16),
      Image1.Picture.Bitmap.TransparentColor);
    Canvas.TextOut(ARect.Left + 20, ARect.Top + 1, Items[Index]);
  end;
end;


end.
