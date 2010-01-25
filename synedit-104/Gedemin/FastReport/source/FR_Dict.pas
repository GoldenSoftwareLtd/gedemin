
{******************************************}
{                                          }
{             FastReport v2.53             }
{             Data dictionary              }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_Dict;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, FR_Class, FR_Ctrls, FR_DSet, FR_Pars, ExtCtrls
{$IFDEF Delphi4}, ImgList, Buttons {$ENDIF};

type
  TfrDictForm = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    Button1: TButton;
    Button2: TButton;
    FieldAliasesTree: TTreeView;
    Label1: TLabel;
    GroupBox1: TGroupBox;
    CB1: TCheckBox;
    Label2: TLabel;
    Edit1: TEdit;
    ImageList1: TImageList;
    VarTree: TTreeView;
    ValCombo: TComboBox;
    ValList: TListBox;
    Label3: TLabel;
    Label4: TLabel;
    ExprEdit: TfrComboEdit;
    ExprCB: TCheckBox;
    NewCategoryBtn: TfrSpeedButton;
    NewVarBtn: TfrSpeedButton;
    EditBtn: TfrSpeedButton;
    DelBtn: TfrSpeedButton;
    EditListBtn: TfrSpeedButton;
    GroupBox2: TGroupBox;
    Label5: TLabel;
    Edit2: TEdit;
    Label6: TLabel;
    BandDSTree: TTreeView;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    AllTablesLB: TListBox;
    frSpeedButton1: TfrSpeedButton;
    frSpeedButton2: TfrSpeedButton;
    frSpeedButton3: TfrSpeedButton;
    frSpeedButton4: TfrSpeedButton;
    frSpeedButton5: TfrSpeedButton;
    frSpeedButton6: TfrSpeedButton;
    frSpeedButton7: TfrSpeedButton;
    frSpeedButton8: TfrSpeedButton;
    AllBandsLB: TListBox;
    Image4: TImage;
    procedure FieldAliasesTreeClick(Sender: TObject);
    procedure Edit1Exit(Sender: TObject);
    procedure CB1Click(Sender: TObject);
    procedure NewCategoryBtnClick(Sender: TObject);
    procedure NewVarBtnClick(Sender: TObject);
    procedure EditBtnClick(Sender: TObject);
    procedure DelBtnClick(Sender: TObject);
    procedure VarTreeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ValComboClick(Sender: TObject);
    procedure ValComboDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure ValListDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure FieldAliasesTreeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure FieldAliasesTreeChange(Sender: TObject; Node: TTreeNode);
    procedure ExprCBClick(Sender: TObject);
    procedure BandDSTreeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BandDSTreeClick(Sender: TObject);
    procedure BandDSTreeChange(Sender: TObject; Node: TTreeNode);
    procedure Edit2Exit(Sender: TObject);
    procedure Edit2KeyPress(Sender: TObject; var Key: Char);
    procedure VarTreeEdited(Sender: TObject; Node: TTreeNode; var S: string);
    procedure VarTreeChange(Sender: TObject; Node: TTreeNode);
    procedure ValListClick(Sender: TObject);
    procedure ExprEditExit(Sender: TObject);
    procedure ExprEditEnter(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure EditListBtnClick(Sender: TObject);
    procedure ExprEditButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FieldAliasesTreeExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure AllTablesLBDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure AllBandsLBDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure frSpeedButton1Click(Sender: TObject);
    procedure frSpeedButton3Click(Sender: TObject);
    procedure frSpeedButton4Click(Sender: TObject);
    procedure frSpeedButton2Click(Sender: TObject);
    procedure frSpeedButton5Click(Sender: TObject);
    procedure frSpeedButton6Click(Sender: TObject);
    procedure frSpeedButton7Click(Sender: TObject);
    procedure frSpeedButton8Click(Sender: TObject);
    procedure FieldAliasesTreeDragOver(Sender, Source: TObject; X,
      Y: Integer; State: TDragState; var Accept: Boolean);
    procedure FieldAliasesTreeDragDrop(Sender, Source: TObject; X,
      Y: Integer);
    procedure AllTablesLBDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure AllTablesLBDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure BandDSTreeDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure BandDSTreeDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure AllBandsLBDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure AllBandsLBDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure AllTablesLBDblClick(Sender: TObject);
    procedure AllBandsLBDblClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
    Variables: TfrVariables;
    FieldAliases: TfrVariables;
    BandDatasources: TfrVariables;
    ActiveNode: TTreeNode;
    Busy: Boolean;
    procedure FillFieldAliases;
    procedure FillBandDataSources;
    procedure FillVariables(FirstTime: Boolean);
    function CurDataSet: String;
    procedure GetFields(Value: String);
    procedure GetSpecValues;
    procedure FillValCombo;
    procedure ShowValue(Value: String);
    procedure ApplyChanges;
    function GetItemName(s: String): String;
    procedure AddFieldAlias(DSName: String);
    procedure DeleteFieldAlias(TreeNode: TTreeNode);
    procedure AddBandDS(DSName: String);
    procedure Localize;
  public
    { Public declarations }
    Doc: TfrReport;
  end;


implementation

{$R *.DFM}

uses FR_Const, FR_Utils, FR_DBRel, FR_Vared, FR_Expr
{$IFDEF IBO}
  , IB_Components
{$ELSE}
  , DB
{$ENDIF};


procedure TfrDictForm.Localize;
begin
  Caption := frLoadStr(frRes + 340);
  TabSheet1.Caption := frLoadStr(frRes + 341);
  TabSheet2.Caption := frLoadStr(frRes + 342);
  TabSheet3.Caption := frLoadStr(frRes + 343);
  Label3.Caption := frLoadStr(frRes + 344);
  Label4.Caption := frLoadStr(frRes + 345);
  ExprCB.Caption := frLoadStr(frRes + 346);
  NewCategoryBtn.Hint := frLoadStr(frRes + 347);
  NewVarBtn.Hint := frLoadStr(frRes + 348);
  EditBtn.Hint := frLoadStr(frRes + 349);
  DelBtn.Hint := frLoadStr(frRes + 350);
  EditListBtn.Hint := frLoadStr(frRes + 351);
  Label1.Caption := frLoadStr(frRes + 353);
  GroupBox1.Caption := frLoadStr(frRes + 354);
  GroupBox2.Caption := frLoadStr(frRes + 354);
  Label2.Caption := frLoadStr(frRes + 355);
  Label5.Caption := frLoadStr(frRes + 355);
  CB1.Caption := frLoadStr(frRes + 356);
  Label6.Caption := frLoadStr(frRes + 358);
  Button1.Caption := frLoadStr(SOk);
  Button2.Caption := frLoadStr(SCancel);
end;

procedure TfrDictForm.FormCreate(Sender: TObject);
begin
  Localize;
{$IFDEF Delphi4}
  BorderStyle := bsSizeable;
{$ENDIF}
end;

procedure TfrDictForm.FormShow(Sender: TObject);
begin
  Variables := TfrVariables.Create;
  FieldAliases := TfrVariables.Create;
  BandDatasources := TfrVariables.Create;

  FillVariables(True);
  FillFieldAliases;
  FillBandDataSources;
  FillValCombo;
  ValCombo.ItemIndex := 0;
  ValComboClick(nil);
  ExprCBClick(nil);
  VarTree.SetFocus;
end;

procedure TfrDictForm.FormHide(Sender: TObject);
begin
  Variables.Free;
  FieldAliases.Free;
  BandDataSources.Free;
end;

procedure TfrDictForm.Button1Click(Sender: TObject);
begin
  ApplyChanges;
end;

procedure TfrDictForm.ApplyChanges;
begin
  Doc.Dictionary.Variables.Assign(Variables);
  Doc.Dictionary.FieldAliases.Assign(FieldAliases);
  Doc.Dictionary.BandDataSources.Assign(BandDataSources);
end;

function TfrDictForm.GetItemName(s: String): String;
begin
  if Pos('{', s) <> 0 then
    Result := Trim(Copy(s, 1, Pos('{', s) - 1)) else
    Result := s;
end;


{ Field aliases }

procedure TfrDictForm.AddFieldAlias(DSName: String);
var
  TreeNode: TTreeNode;
begin
  if DSName <> '' then
  begin
    FieldAliasesTree.Items.AddChild(FieldAliasesTree.Items[0], DSName);
    TreeNode := FieldAliasesTree.Items[0].GetLastChild;
    TreeNode.ImageIndex := 1;
    TreeNode.SelectedIndex := 1;
    FieldAliasesTree.Items.AddChild(TreeNode, frLoadStr(SNotAssigned));
  end;
end;

procedure TfrDictForm.DeleteFieldAlias(TreeNode: TTreeNode);
var
  i, n: Integer;
  s, ItemName: String;
begin
  ItemName := GetItemName(TreeNode.Text);
  for i := 0 to TreeNode.Count - 1 do
  begin
    s := TreeNode.Item[i].Text;
    n := FieldAliases.IndexOf(ItemName + '.' + GetItemName(s));
    if n <> -1 then
      FieldAliases.Delete(n);
  end;
end;

procedure TfrDictForm.FillFieldAliases;
var
  i, n: Integer;
  TreeNode: TTreeNode;
  sl: TStringList;
  DataSet: TfrTDataSet;
  s, s1: String;
begin
  FieldAliases.Assign(Doc.Dictionary.FieldAliases);

  TreeNode := FieldAliasesTree.Items[0];
  TreeNode.Text := frLoadStr(frRes + 352);
  TreeNode.DeleteChildren;
  CurReport := Doc;

  sl := TStringList.Create;
{$IFDEF IBO}
  frGetComponents(Doc.Owner, TIB_DataSet, sl, nil);
{$ELSE}
  frGetComponents(Doc.Owner, TDataSet, sl, nil);
{$ENDIF}
  sl.Sort;

  for i := 0 to sl.Count - 1 do
  begin
    DataSet := frGetDataSet(sl[i]);
    if (DataSet <> nil) and Doc.Dictionary.DataSetEnabled(sl[i]) then
    begin
      s := sl[i];
      s1 := s;

      n := FieldAliases.IndexOf(s);
      if (FieldAliases.Count = 0) or (n = -1) then
        s := ''
      else if FieldAliases.Value[n] <> '' then
        s := s + ' {' + FieldAliases.Value[n] + '}';

      if s <> '' then
        AddFieldAlias(s) else
        AllTablesLB.Items.Add(s1);
    end;
  end;

  FieldAliasesTree.Items[0].Expand(False);
  FieldAliasesTree.Selected := FieldAliasesTree.Items[0];
  sl.Free;
end;

procedure TfrDictForm.FieldAliasesTreeExpanding(Sender: TObject;
  Node: TTreeNode; var AllowExpansion: Boolean);
var
  i, n, ImageIndex: Integer;
  sl: TStringList;
  ItemName, s: String;
  DataSet: TfrTDataSet;
  NewItem: TTreeNode;
begin
  if Node.ImageIndex = 3 then
    AllowExpansion := False
  else if Node.ImageIndex = 1 then
  begin
    if Node.GetLastChild.ImageIndex = 0 then
      Node.DeleteChildren else
      Exit;
    sl := TStringList.Create;
    ItemName := GetItemName(Node.Text);
    DataSet := frGetDataSet(ItemName);
    try
      frGetFieldNames(DataSet, sl);
      sl.Sort;
    except;
    end;

    for i := 0 to sl.Count - 1 do
    begin
      ImageIndex := 2;
      s := sl[i];
      n := FieldAliases.IndexOf(ItemName + '.' + sl[i]);
      if n <> -1 then
        if FieldAliases.Value[n] <> '' then
          s := sl[i] + ' {' + FieldAliases.Value[n] + '}' else
          ImageIndex := 4;

      FieldAliasesTree.Items.AddChild(Node, s);
      NewItem := Node.GetLastChild;
      NewItem.ImageIndex := ImageIndex;
      NewItem.SelectedIndex := ImageIndex;
    end;

    sl.Free;
  end;
end;

procedure TfrDictForm.FieldAliasesTreeClick(Sender: TObject);
var
  TreeNode: TTreeNode;
  s: String;
begin
  if Edit1.Modified then Edit1Exit(nil);
  TreeNode := FieldAliasesTree.Selected;
  if TreeNode <> FieldAliasesTree.Items[0] then
  begin
    s := TreeNode.Text;
    if Pos('{', s) <> 0 then
      s := Copy(s, Pos('{', s) + 1, Pos('}', s) - Pos('{', s) - 1);
    Edit1.Text := s;
  end
  else
    Edit1.Text := '';
  ActiveNode := TreeNode;
  Busy := True;
  CB1.Checked := (TreeNode <> FieldAliasesTree.Items[0]) and (TreeNode.ImageIndex in [3, 4]);
  Busy := False;
end;

procedure TfrDictForm.Edit1Exit(Sender: TObject);
var
  s: String;
begin
  if Edit1.Modified then
    if ActiveNode <> FieldAliasesTree.Items[0] then
    begin
      s := GetItemName(ActiveNode.Text);
      ActiveNode.Text := s + ' {' + Edit1.Text + '}';
      if ActiveNode.ImageIndex = 2 then
        s := GetItemName(ActiveNode.Parent.Text) + '.' + s;
      FieldAliases[s] := Edit1.Text;
    end;
  Edit1.Modified := False;
end;

procedure TfrDictForm.CB1Click(Sender: TObject);
var
  TreeNode: TTreeNode;
  ItemName, FullName: String;
begin
  if Busy then Exit;
  TreeNode := FieldAliasesTree.Selected;
  if (TreeNode = FieldAliasesTree.Items[0]) or (TreeNode = nil) then Exit;

  if TreeNode.ImageIndex in [2, 4] then
  begin
    ItemName := GetItemName(TreeNode.Text);
    FullName := GetItemName(TreeNode.Parent.Text) + '.' + ItemName;
    if TreeNode.ImageIndex = 2 then
      TreeNode.ImageIndex := 4 else
      TreeNode.ImageIndex := 2;
    TreeNode.SelectedIndex := TreeNode.ImageIndex;

    if TreeNode.ImageIndex = 2 then
      FieldAliases.Delete(FieldAliases.IndexOf(FullName)) else
      FieldAliases[FullName] := '';
    TreeNode.Text := ItemName;
  end;
end;

procedure TfrDictForm.FieldAliasesTreeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = vk_Return then
    Edit1.SetFocus
  else if Key = vk_Space then
    CB1.Checked := not CB1.Checked;
end;

procedure TfrDictForm.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    FieldAliasesTree.SetFocus;
end;

procedure TfrDictForm.FieldAliasesTreeChange(Sender: TObject; Node: TTreeNode);
begin
  FieldAliasesTreeClick(nil);
end;

procedure TfrDictForm.AllTablesLBDrawItem(Control: TWinControl;
  Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  r: TRect;
begin
  r := ARect;
  r.Right := r.Left + 18;
  r.Bottom := r.Top + 15;
  OffsetRect(r, 2, 0);
  with AllTablesLB.Canvas do
  begin
    FillRect(ARect);
    BrushCopy(r, Image1.Picture.Bitmap, Rect(0, 0, 18, 15),
      Image1.Picture.Bitmap.TransparentColor);
    TextOut(ARect.Left + 20, ARect.Top + 1, AllTablesLB.Items[Index]);
  end;
end;

procedure TfrDictForm.frSpeedButton1Click(Sender: TObject);
var
  i, n: Integer;
  s: String;
begin
  n := AllTablesLB.ItemIndex;
  i := 0;
  while i < AllTablesLB.Items.Count do
  begin
    if AllTablesLB.Selected[i] then
    begin
      s := AllTablesLB.Items[i];
      AddFieldAlias(s);
      FieldAliases[s] := '';
      AllTablesLB.Items.Delete(i);
    end
    else
      Inc(i);
  end;

  FieldAliasesTree.Items[0].Expand(False);
  FieldAliasesTree.Selected := FieldAliasesTree.Items[0];
  if n >= AllTablesLB.Items.Count then
    Dec(n);
  if n < AllTablesLB.Items.Count then
    AllTablesLB.Selected[n] := True;
end;

procedure TfrDictForm.frSpeedButton2Click(Sender: TObject);
var
  TreeNode: TTreeNode;
  s: String;
begin
  TreeNode := FieldAliasesTree.Selected;
  if (TreeNode = nil) or (TreeNode.ImageIndex <> 1) then Exit;

  s := GetItemName(TreeNode.Text);
  DeleteFieldAlias(TreeNode);
  AllTablesLB.Items.Add(s);
  TreeNode.Delete;
  FieldAliases.Delete(FieldAliases.IndexOf(s));
end;

procedure TfrDictForm.frSpeedButton3Click(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to AllTablesLB.Items.Count - 1 do
  begin
    AddFieldAlias(AllTablesLB.Items[i]);
    FieldAliases[AllTablesLB.Items[i]] := '';
  end;
  AllTablesLB.Items.Clear;
  FieldAliasesTree.Items[0].Expand(False);
  FieldAliasesTree.Selected := FieldAliasesTree.Items[0];
end;

procedure TfrDictForm.frSpeedButton4Click(Sender: TObject);
var
  i: Integer;
  TreeNode: TTreeNode;
begin
  for i := 0 to FieldAliases.Count - 1 do
    if Pos('"', FieldAliases.Name[i]) = 0 then
      AllTablesLB.Items.Add(FieldAliases.Name[i]);

  FieldAliases.Clear;
  TreeNode := FieldAliasesTree.Items[0];
  TreeNode.DeleteChildren;
end;

procedure TfrDictForm.FieldAliasesTreeDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := Source is TListBox;
end;

procedure TfrDictForm.FieldAliasesTreeDragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
  frSpeedButton1Click(nil);
end;

procedure TfrDictForm.AllTablesLBDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := Source is TTreeView;
end;

procedure TfrDictForm.AllTablesLBDragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
  frSpeedButton2Click(nil);
end;

procedure TfrDictForm.AllTablesLBDblClick(Sender: TObject);
begin
  frSpeedButton1Click(nil);
end;


{ Band Datasources }

procedure TfrDictForm.AddBandDS(DSName: String);
var
  TreeNode: TTreeNode;
begin
  if DSName <> '' then
  begin
    BandDSTree.Items.AddChild(BandDSTree.Items[0], DSName);
    TreeNode := BandDSTree.Items[0].GetLastChild;
    TreeNode.ImageIndex := 7;
    TreeNode.SelectedIndex := 7;
  end;
end;

procedure TfrDictForm.FillBandDataSources;
var
  i, n: Integer;
  TreeNode: TTreeNode;
  sl: TStringList;
  s: String;
begin
  BandDataSources.Assign(Doc.Dictionary.BandDataSources);

  TreeNode := BandDSTree.Items[0];
  TreeNode.Text := frLoadStr(frRes + 357);
  TreeNode.DeleteChildren;
  CurReport := Doc;

  sl := TStringList.Create;
  frGetComponents(Doc.Owner, TfrDataSet, sl, nil);
  sl.Sort;

  AllBandsLB.Items.Assign(sl);

  for i := 0 to sl.Count - 1 do
  begin
    s := sl[i];
    n := BandDatasources.IndexOf(sl[i]);
    if (BandDataSources.Count = 0) or (n = -1) then
      s := ''
    else if BandDatasources.Value[n] <> '' then
      s := s + ' {' + BandDatasources.Value[n] + '}';

    AddBandDS(s);
    if s <> '' then
      AllBandsLB.Items.Delete(AllBandsLB.Items.IndexOf(sl[i]));
  end;

  BandDSTree.FullExpand;
  BandDSTree.Selected := BandDSTree.Items[0];
  sl.Free;
end;

procedure TfrDictForm.BandDSTreeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = vk_Return then
    Edit2.SetFocus
end;

procedure TfrDictForm.BandDSTreeClick(Sender: TObject);
var
  TreeNode: TTreeNode;
  s: String;
begin
  if Edit2.Modified then Edit2Exit(nil);
  TreeNode := BandDSTree.Selected;
  if TreeNode <> BandDSTree.Items[0] then
  begin
    s := TreeNode.Text;
    if Pos('{', s) <> 0 then
      s := Copy(s, Pos('{', s) + 1, Pos('}', s) - Pos('{', s) - 1);
    Edit2.Text := s;
  end
  else
    Edit2.Text := '';
  ActiveNode := TreeNode;
end;

procedure TfrDictForm.BandDSTreeChange(Sender: TObject; Node: TTreeNode);
begin
  BandDSTreeClick(nil);
end;

procedure TfrDictForm.Edit2Exit(Sender: TObject);
var
  s, ItemName: String;
begin
  if Edit2.Modified then
    if ActiveNode <> BandDSTree.Items[0] then
    begin
      s := ActiveNode.Text;
      ItemName := GetItemName(s);
      if Pos('{', s) <> 0 then
        s := Copy(s, 1, Pos('{', s) - 1) else
        s := s + ' ';
      ActiveNode.Text := s + '{' + Edit2.Text + '}';
      BandDataSources[ItemName] := Edit2.Text;
    end;
  Edit2.Modified := False;
end;

procedure TfrDictForm.Edit2KeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    BandDSTree.SetFocus;
end;

procedure TfrDictForm.AllBandsLBDrawItem(Control: TWinControl;
  Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  r: TRect;
begin
  r := ARect;
  r.Right := r.Left + 18;
  r.Bottom := r.Top + 15;
  OffsetRect(r, 2, 0);
  with AllBandsLB.Canvas do
  begin
    FillRect(ARect);
    BrushCopy(r, Image4.Picture.Bitmap, Rect(0, 0, 18, 15),
      Image4.Picture.Bitmap.TransparentColor);
    TextOut(ARect.Left + 20, ARect.Top + 1, AllBandsLB.Items[Index]);
  end;
end;

procedure TfrDictForm.frSpeedButton5Click(Sender: TObject);
var
  i, n: Integer;
  s: String;
begin
  n := AllBandsLB.ItemIndex;
  i := 0;
  while i < AllBandsLB.Items.Count do
  begin
    if AllBandsLB.Selected[i] then
    begin
      s := AllBandsLB.Items[i];
      AddBandDS(s);
      BandDataSources[s] := '';
      AllBandsLB.Items.Delete(i);
    end
    else
      Inc(i);
  end;

  BandDSTree.Items[0].Expand(False);
  BandDSTree.Selected := BandDSTree.Items[0];
  if n >= AllBandsLB.Items.Count then
    Dec(n);
  if n < AllBandsLB.Items.Count then
    AllBandsLB.Selected[n] := True;
end;

procedure TfrDictForm.frSpeedButton6Click(Sender: TObject);
var
  TreeNode: TTreeNode;
  s: String;
begin
  TreeNode := BandDSTree.Selected;
  if (TreeNode = nil) or (TreeNode.ImageIndex <> 7) then Exit;

  s := GetItemName(TreeNode.Text);
  AllBandsLB.Items.Add(s);
  TreeNode.Delete;
  BandDataSources.Delete(BandDataSources.IndexOf(s));
end;

procedure TfrDictForm.frSpeedButton7Click(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to AllBandsLB.Items.Count - 1 do
  begin
    AddBandDS(AllBandsLB.Items[i]);
    BandDataSources[AllBandsLB.Items[i]] := '';
  end;
  AllBandsLB.Items.Clear;
  BandDSTree.Items[0].Expand(False);
  BandDSTree.Selected := BandDSTree.Items[0];
end;

procedure TfrDictForm.frSpeedButton8Click(Sender: TObject);
var
  i: Integer;
  TreeNode: TTreeNode;
begin
  for i := 0 to BandDataSources.Count - 1 do
    AllBandsLB.Items.Add(BandDataSources.Name[i]);

  BandDataSources.Clear;
  TreeNode := BandDSTree.Items[0];
  TreeNode.DeleteChildren;
end;

procedure TfrDictForm.BandDSTreeDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := Source is TListBox;
end;

procedure TfrDictForm.BandDSTreeDragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
  frSpeedButton5Click(nil);
end;

procedure TfrDictForm.AllBandsLBDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := Source is TTreeView;
end;

procedure TfrDictForm.AllBandsLBDragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
  frSpeedButton6Click(nil);
end;

procedure TfrDictForm.AllBandsLBDblClick(Sender: TObject);
begin
  frSpeedButton5Click(nil);
end;


{ Variables }

procedure TfrDictForm.FillVariables(FirstTime: Boolean);
var
  i: Integer;
  ANode, TreeNode: TTreeNode;
  s: String;
begin
  Busy := True;
  if VarTree.Items.Count > 0 then
    VarTree.Items.Clear;
  if FirstTime then
    Variables.Assign(Doc.Dictionary.Variables);

  if Variables.Count = 0 then
  begin
    TreeNode := VarTree.Items.Add(VarTree.Selected, frLoadStr(SNotAssigned));
    TreeNode.ImageIndex := -1;
    TreeNode.SelectedIndex := -1;
    VarTree.ShowRoot := False;
    ExprCB.Enabled := False;
  end
  else
  begin
    TreeNode := nil;
    for i := 0 to Variables.Count - 1 do
    begin
      s := Variables.Name[i];
      if (s <> '') and (s[1] = ' ') then
      begin
        TreeNode := VarTree.Items.Add(nil, Copy(s, 2, 255));
        TreeNode.ImageIndex := 5;
        TreeNode.SelectedIndex := 5;
      end
      else if TreeNode <> nil then
      begin
        ANode := VarTree.Items.AddChild(TreeNode, s);
        ANode.ImageIndex := 6;
        ANode.SelectedIndex := 6;
      end;
    end;
  end;
  Busy := False;
  VarTree.FullExpand;
  VarTree.Items[0].Selected := True;
end;

procedure TfrDictForm.NewCategoryBtnClick(Sender: TObject);
var
  ANode, TreeNode: TTreeNode;
  s: String;

  function CreateNewCategory: String;
  var
    i: Integer;

    function FindCategory(s: String): Boolean;
    var
      i: Integer;
    begin
      Result := False;
      for i := 0 to Variables.Count - 1 do
      begin
        if AnsiCompareText(Variables.Name[i], s) = 0 then
        begin
          Result := True;
          break;
        end;
      end;
    end;

  begin
    for i := 1 to 1000 do
    begin
      Result := 'Category' + IntToStr(i);
      if not FindCategory(' ' + Result) then
        break;
    end;
  end;

begin
  TreeNode := VarTree.Selected;
  if VarTree.ShowRoot = False then
  begin
    TreeNode.Delete;
    TreeNode := nil;
    VarTree.ShowRoot := True;
    ExprCB.Enabled := True;
  end;
  if TreeNode <> nil then
    TreeNode := VarTree.Items[0];

  s := CreateNewCategory;
  Variables[' ' + s] := '';
  ANode := VarTree.Items.Add(TreeNode, s);
  ANode.ImageIndex := 5;
  ANode.SelectedIndex := 5;
  VarTree.Selected := ANode;
  ANode.EditText;
end;

procedure TfrDictForm.NewVarBtnClick(Sender: TObject);
var
  ANode, TreeNode: TTreeNode;
  s: String;

  function CreateNewVariable: String;
  var
    i: Integer;

    function FindVariable(s: String): Boolean;
    var
      i: Integer;
    begin
      Result := False;
      for i := 0 to Variables.Count - 1 do
      begin
        if AnsiCompareText(Variables.Name[i], s) = 0 then
        begin
          Result := True;
          break;
        end;
      end;
    end;

  begin
    for i := 1 to 1000 do
    begin
      Result := 'Variable' + IntToStr(i);
      if not FindVariable(Result) then
        break;
    end;
  end;

begin
  TreeNode := VarTree.Selected;
  if (TreeNode = nil) or not VarTree.ShowRoot then Exit;
  if TreeNode.Parent <> nil then
    TreeNode := TreeNode.Parent;

  s := CreateNewVariable;

  if TreeNode.GetNextSibling <> nil then
    Variables.Insert(Variables.IndexOf(' ' + TreeNode.GetNextSibling.Text), s) else
    Variables[s] := '';

  ANode := VarTree.Items.AddChild(TreeNode, s);
  ANode.ImageIndex := 6;
  ANode.SelectedIndex := 6;
  TreeNode.Expand(True);
  VarTree.Selected := ANode;
  ANode.EditText;
end;

procedure TfrDictForm.EditBtnClick(Sender: TObject);
var
  TreeNode: TTreeNode;
begin
  TreeNode := VarTree.Selected;
  if (TreeNode <> nil) and VarTree.ShowRoot then
    TreeNode.EditText;
end;

procedure TfrDictForm.DelBtnClick(Sender: TObject);
var
  TreeNode: TTreeNode;
  i: Integer;
begin
  TreeNode := VarTree.Selected;
  if (TreeNode <> nil) and VarTree.ShowRoot then
  begin
    if TreeNode.ImageIndex = 5 then
    begin
      i := Variables.IndexOf(' ' + TreeNode.Text);
      Variables.Delete(i);
      while (i < Variables.Count) and (Variables.Name[i][1] <> ' ') do
        Variables.Delete(i);
    end
    else
      Variables.Delete(Variables.IndexOf(TreeNode.Text));

    TreeNode.Delete;
    if VarTree.Items.Count = 0 then
    begin
      TreeNode := VarTree.Items.Add(VarTree.Selected, frLoadStr(SNotAssigned));
      TreeNode.ImageIndex := -1;
      TreeNode.SelectedIndex := -1;
      VarTree.ShowRoot := False;
      VarTree.Selected := VarTree.Items[0];
      ExprCB.Enabled := False;
    end;
  end;
end;

procedure TfrDictForm.VarTreeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = vk_Insert then
    if ssCtrl in Shift then
      NewCategoryBtnClick(nil)
    else
      if (VarTree.Selected = nil) or (VarTree.ShowRoot = False) then
        NewCategoryBtnClick(nil) else
        NewVarBtnClick(nil)
  else if (Key = vk_Delete) and not VarTree.IsEditing then
    DelBtnClick(nil)
  else if Key = vk_Return then
    EditBtnClick(nil)
  else if (Key = vk_Escape) and not VarTree.IsEditing then
    Button2.Click;
end;

procedure TfrDictForm.VarTreeEdited(Sender: TObject; Node: TTreeNode; var S: string);
var
  s1: String;
begin
  if Node.ImageIndex = 6 then
    s1 := s else
    s1 := ' ' + s;
  if (AnsiCompareText(s, Node.Text) <> 0) and
     (Variables.IndexOf(s1) <> -1) then
    s := Node.Text
  else
  begin
    if Node.ImageIndex = 6 then
      Variables.Name[Variables.IndexOf(Node.Text)] := s1 else
      Variables.Name[Variables.IndexOf(' ' + Node.Text)] := s1;
  end;
end;

function TfrDictForm.CurDataSet: String;
begin
  Result := '';
  if ValCombo.ItemIndex <> -1 then
    Result := ValCombo.Items[ValCombo.ItemIndex];
end;

procedure TfrDictForm.FillValCombo;
var
  s: TStringList;
begin
  s := TStringList.Create;
  CurReport.Dictionary.GetDatasetList(s);
  s.Sort;
  s.Add(frLoadStr(SSystemVariables));
  ValCombo.Items.Assign(s);
  s.Free;
end;

procedure TfrDictForm.ValComboClick(Sender: TObject);
begin
  if CurDataSet <> frLoadStr(SSystemVariables) then
    GetFields(CurDataSet) else
    GetSpecValues;
end;

procedure TfrDictForm.GetFields(Value: String);
begin
  CurReport.Dictionary.GetFieldList(Value, ValList.Items);
  ValList.Items.Insert(0, frLoadStr(SNotAssigned));
end;

procedure TfrDictForm.GetSpecValues;
var
  i: Integer;
begin
  with ValList.Items do
  begin
    Clear;
    Add(frLoadStr(SNotAssigned));
    for i := 0 to frSpecCount - 1 do
      if i <> 1 then
        Add(frLoadStr(SVar1 + i));
  end;
end;

procedure TfrDictForm.ValComboDrawItem(Control: TWinControl; Index: Integer;
  ARect: TRect; State: TOwnerDrawState);
var
  Image: TImage;
  r: TRect;
begin
  r := ARect;
  r.Right := r.Left + 18;
  r.Bottom := r.Top + 16;
  OffsetRect(r, 2, 0);
  with ValCombo.Canvas do
  begin
    FillRect(ARect);
    if Index = ValCombo.Items.Count - 1 then
      Image := Image3 else
      Image := Image1;
    BrushCopy(r, Image.Picture.Bitmap, Rect(0, 0, 18, 16),
      Image.Picture.Bitmap.TransparentColor);
    TextOut(ARect.Left + 20, ARect.Top + 1, ValCombo.Items[Index]);
  end;
end;

procedure TfrDictForm.ValListDrawItem(Control: TWinControl; Index: Integer;
  ARect: TRect; State: TOwnerDrawState);
var
  Image: TImage;
  r: TRect;
begin
  r := ARect;
  r.Right := r.Left + 18;
  r.Bottom := r.Top + 15;
  OffsetRect(r, 2, 0);
  with ValList.Canvas do
  begin
    FillRect(ARect);
    if CurDataSet = frLoadStr(SSystemVariables) then
      Image := Image3 else
      Image := Image2;
    if Index <> 0 then
      BrushCopy(r, Image.Picture.Bitmap, Rect(0, 0, 18, 15),
        Image.Picture.Bitmap.TransparentColor);
    TextOut(ARect.Left + 20, ARect.Top + 1, ValList.Items[Index]);
  end;
end;

procedure TfrDictForm.ExprCBClick(Sender: TObject);
begin
  frEnableControls([ExprEdit], ExprCB.Checked);
  if not ExprCB.Checked then
  begin
    ExprEdit.Text := '';
    if not Busy then
    begin
      ValList.ItemIndex := 0;
      ValListClick(nil);
    end;
  end
  else if not Busy then
  begin
    if not VarTree.Focused then
      ExprEdit.SetFocus;
    ValList.ItemIndex := 0;
  end;
end;

procedure TfrDictForm.VarTreeChange(Sender: TObject; Node: TTreeNode);
var
  s: String;
begin
  if Busy then Exit;
  ExprEditExit(nil);
  if Node.ImageIndex = 5 then
    s := ' ' + Node.Text
  else if Node.ImageIndex = 6 then
    s := Node.Text
  else
    Exit;
  ExprCB.Enabled := Node.ImageIndex = 6;
  if not ExprCB.Enabled then
    ExprCB.Checked := False;
  ShowValue(Variables[s]);
end;

procedure TfrDictForm.ShowValue(Value: String);
var
  i, n: Integer;
  s1, s2: String;
  Found: Boolean;

  function FindStr(List: TStrings; Str: String; IsField: Boolean): Integer;
  var
    i: Integer;
    s: String;
  begin
    Result := -1;
    for i := 0 to List.Count - 1 do
    begin
      if IsField then
        s := CurReport.Dictionary.RealFieldName[List[i]] else
        s := CurReport.Dictionary.RealDataSetName[List[i]];
      if AnsiCompareText(s, Str) = 0 then
      begin
        Result := i;
        break;
      end;
    end;
  end;

begin
  s1 := ''; s2 := '';
  Found := False;

  if Pos('.', Value) <> 0 then
  begin
    for i := Length(Value) downto 1 do
      if Value[i] = '.' then
      begin
        s1 := Copy(Value, 1, i - 1);
        s2 := Copy(Value, i + 1, 255);
        break;
      end;
    n := FindStr(ValCombo.Items, s1, False);
    if n <> -1 then
    begin
      if ValCombo.ItemIndex <> n then
      begin
        ValCombo.ItemIndex := n;
        ValComboClick(nil);
      end;
      if (s2 <> '') and (s2[1] = '"') then
        s2 := Copy(s2, 2, Length(s2) - 2);
      n := FindStr(ValList.Items, s2, True);
      if n <> - 1 then
      begin
        ValList.ItemIndex := n;
        Found := True;
      end;
    end;
  end;

  if not Found then
  begin
    if Trim(Value) = '' then
    begin
      ValList.ItemIndex := 0;
      ExprEdit.Text := '';
      ExprCB.Checked:= False;
    end
    else
    begin
      for i := 0 to frSpecCount - 1 do
        if AnsiCompareText(frSpecFuncs[i], Value) = 0 then
        begin
          n := ValCombo.Items.IndexOf(frLoadStr(SSystemVariables));
          if ValCombo.ItemIndex <> n then
          begin
            ValCombo.ItemIndex := n;
            ValComboClick(nil);
          end;
          if i = 0 then
            ValList.ItemIndex := 1 else
            ValList.ItemIndex := i;
          Found := True;
          break;
        end;

      if not Found then
      begin
        ExprEdit.Text := Value;
        ExprCB.Checked := True;
      end;
    end;
  end;

  if Found then
  begin
    Busy := True;
    ExprCB.Checked := False;
    Busy := False;
  end;
end;

procedure TfrDictForm.ValListClick(Sender: TObject);
var
  TreeNode: TTreeNode;
  s: String;
  n: Integer;
begin
  Busy := True;
  ExprCB.Checked := False;
  Busy := False;
  TreeNode := VarTree.Selected;
  if (TreeNode = nil) or (TreeNode.ImageIndex <> 6) then Exit;

  if ValList.ItemIndex = 0 then
    s := ''
  else
  begin
    if CurDataset = frLoadStr(SSystemVariables) then
    begin
      n := ValList.ItemIndex;
      if n = 1 then
        n := 0;
      s := frSpecFuncs[n];
    end
    else with CurReport.Dictionary do
      s := RealDataSetName[CurDataset] + '."' + RealFieldName[ValList.Items[ValList.ItemIndex]] + '"';
  end;
  Variables[TreeNode.Text] := s;
end;

procedure TfrDictForm.ExprEditEnter(Sender: TObject);
begin
  ActiveNode := VarTree.Selected;
end;

procedure TfrDictForm.ExprEditExit(Sender: TObject);
var
  TreeNode: TTreeNode;
begin
  TreeNode := ActiveNode;
  if (TreeNode = nil) or (TreeNode.ImageIndex <> 6) or not ExprEdit.Enabled then Exit;
  Variables[TreeNode.Text] := ExprEdit.Text;
  ActiveNode := nil;
end;

procedure TfrDictForm.EditListBtnClick(Sender: TObject);
begin
  with TfrVaredForm.Create(nil) do
  begin
    Variables := Self.Variables;
    if ShowModal = mrOk then
      FillVariables(False);
    VarTree.Items[0].Selected := True;
    Free;
  end;
end;

procedure TfrDictForm.ExprEditButtonClick(Sender: TObject);
begin
  with TfrExprForm.Create(nil) do
  begin
    ExprMemo.Text := ExprEdit.Text;
    if ShowModal = mrOk then
      ExprEdit.Text := ExprMemo.Text;
    Free;
  end;
end;


procedure TfrDictForm.FormResize(Sender: TObject);
begin
{$IFDEF Delphi4}
  PageControl1.Anchors := [akLeft, akTop, akRight, akBottom];
  VarTree.Anchors := [akLeft, akTop, akRight, akBottom];
  ValList.Anchors := [akTop, akRight, akBottom];
  ValCombo.Anchors := [akTop, akRight];
  Label4.Anchors := [akTop, akRight];
  ExprCB.Anchors := [akLeft, akBottom];
  ExprEdit.Anchors := [akLeft, akRight, akBottom];
  Button1.Anchors := [akRight, akBottom];
  Button2.Anchors := [akRight, akBottom];
  NewCategoryBtn.Top := VarTree.Height + 26;
  NewVarBtn.Top := NewCategoryBtn.Top;
  EditBtn.Top := NewCategoryBtn.Top;
  DelBtn.Top := NewCategoryBtn.Top;
  EditListBtn.Top := NewCategoryBtn.Top;
{$ENDIF}
end;

end.
