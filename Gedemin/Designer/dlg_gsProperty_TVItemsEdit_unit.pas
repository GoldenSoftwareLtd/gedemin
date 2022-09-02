// ShlTanya, 24.02.2019

unit dlg_gsProperty_TVItemsEdit_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, dmImages_unit,
  StdCtrls, Buttons, ComCtrls;

type
  TdlgPropertyTVItemsEdit = class(TForm)
    gbItems: TGroupBox;
    tvShow: TTreeView;
    btnNewItem: TBitBtn;
    btnNewSubItem: TBitBtn;
    btnDelete: TBitBtn;
    OKButton: TButton;
    CancelButton: TButton;
    HelpButton: TButton;
    gbItemProperties: TGroupBox;
    edtText: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    edtImageIndex: TEdit;
    Label3: TLabel;
    edtSelectedIndex: TEdit;
    Label4: TLabel;
    edtStateIndex: TEdit;
    procedure tvShowChange(Sender: TObject; Node: TTreeNode);
    procedure edtTextChange(Sender: TObject);
    procedure btnNewItemClick(Sender: TObject);
    procedure btnNewSubItemClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure HelpButtonClick(Sender: TObject);
    procedure edtImageIndexExit(Sender: TObject);
    procedure edtSelectedIndexExit(Sender: TObject);
    procedure edtStateIndexExit(Sender: TObject);
    procedure tvShowDragDrop(Sender, Source: TObject; X, Y: Integer);
  private
    procedure RefreshControls;
    function GetIntValue(AEdit: TEdit): integer;
  public
    function Edit(Value: TTreeNodes): boolean;
  end;

var
  dlgPropertyTVItemsEdit: TdlgPropertyTVItemsEdit;

implementation

{$R *.DFM}

{ TdlgPropertyTVItemsEdit }

procedure TdlgPropertyTVItemsEdit.RefreshControls;
var
  tn: TTreeNode;
begin
  tn:= tvShow.Selected;
 if not Assigned(tn) then begin
   edtText.Enabled:= False;
   edtText.Text:= '';
   edtImageIndex.Enabled:= False;
   edtImageIndex.Text:= '-1';
   edtSelectedIndex.Enabled:= False;
   edtSelectedIndex.Text:= '-1';
   edtStateIndex.Enabled:= False;
   edtStateIndex.Text:= '-1';
   btnNewSubItem.Enabled:= False;
   btnDelete.Enabled:= False;
 end
 else begin
   edtText.Enabled:= True;
   edtText.Text:= tn.Text;
   edtImageIndex.Enabled:= True;
   edtImageIndex.Text:= IntToStr(tn.ImageIndex);
   edtSelectedIndex.Enabled:= True;
   edtSelectedIndex.Text:= IntToStr(tn.SelectedIndex);
   edtStateIndex.Enabled:= True;
   edtStateIndex.Text:= IntToStr(tn.StateIndex);
   btnNewSubItem.Enabled:= True;
   btnDelete.Enabled:= True;
 end;
end;

procedure TdlgPropertyTVItemsEdit.tvShowChange(Sender: TObject; Node: TTreeNode);
begin
  RefreshControls;
end;

function TdlgPropertyTVItemsEdit.Edit(Value: TTreeNodes): boolean;
begin
  Result := False;
  tvShow.Items.Assign(Value);
  if (ShowModal = mrOk) then begin
    Value.Assign(tvShow.Items);
    Result := True;
  end;
end;

procedure TdlgPropertyTVItemsEdit.edtTextChange(Sender: TObject);
var
  tn: TTreeNode;
begin
  tn:= tvShow.Selected;
  if not Assigned(tn) then Exit;
  tn.Text:= edtText.Text;
end;

procedure TdlgPropertyTVItemsEdit.btnNewItemClick(Sender: TObject);
var
  tn: TTreeNode;
begin
  tn:= tvShow.Selected;
  tn:= tvShow.Items.Add(tn, '');
  tvShow.Selected:= tn;
  edtText.SetFocus;
end;

procedure TdlgPropertyTVItemsEdit.btnNewSubItemClick(Sender: TObject);
var
  tn: TTreeNode;
begin
  tn:= tvShow.Selected;
  if not Assigned(tn) then Exit;
  tn.Expand(False);
  tn:= tvShow.Items.AddChild(tn, '');
  tvShow.Selected:= tn;
  edtText.SetFocus;
end;

procedure TdlgPropertyTVItemsEdit.btnDeleteClick(Sender: TObject);
var
  tn: TTreeNode;
begin
  tn:= tvShow.Selected;
  if not Assigned(tn) then Exit;
  tvShow.Items.Delete(tn);
end;

procedure TdlgPropertyTVItemsEdit.HelpButtonClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

function TdlgPropertyTVItemsEdit.GetIntValue(AEdit: TEdit): integer;
begin
  try
    Result:= StrToInt(AEdit.Text);
  except
    raise Exception.Create(QuotedStr(edtImageIndex.Text) + ' is not a valid integer value');
    AEdit.SetFocus;
    Result:= -1;
  end;
end;

procedure TdlgPropertyTVItemsEdit.edtImageIndexExit(Sender: TObject);
var
  tn: TTreeNode;
begin
  tn:= tvShow.Selected;
  if not Assigned(tn) then Exit;
  tn.ImageIndex:= GetIntValue(edtImageIndex);
  RefreshControls;
end;

procedure TdlgPropertyTVItemsEdit.edtSelectedIndexExit(Sender: TObject);
var
  tn: TTreeNode;
begin
  tn:= tvShow.Selected;
  if not Assigned(tn) then Exit;
  tn.SelectedIndex:= GetIntValue(edtSelectedIndex);
  RefreshControls;
end;

procedure TdlgPropertyTVItemsEdit.edtStateIndexExit(Sender: TObject);
var
  tn: TTreeNode;
begin
  tn:= tvShow.Selected;
  if not Assigned(tn) then Exit;
  tn.StateIndex:= GetIntValue(edtStateIndex);
  RefreshControls;
end;

procedure TdlgPropertyTVItemsEdit.tvShowDragDrop(Sender, Source: TObject;
  X, Y: Integer);
var
  tn: TTreeNode;
  amMode: TNodeAttachMode;
  HT: THitTests;
begin
  if tvShow.Selected = nil then Exit;
  HT := tvShow.GetHitTestInfoAt(X, Y);
  tn := tvShow.GetNodeAt(X, Y);
  amMode:= naAdd;
  if (HT - [htOnItem, htOnIcon, htNowhere, htOnIndent] <> HT) then begin
    if (htOnItem in HT) or (htOnIcon in HT) then amMode:= naAddChild
    else if htNowhere in HT then amMode:= naAdd
    else if htOnIndent in HT then amMode := naInsert;
    tvShow.Selected.MoveTo(tn, amMode);
  end;
end;

end.
