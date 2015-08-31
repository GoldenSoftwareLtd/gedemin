unit gdc_frmDocumentType_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDVTree_unit, Db, Menus, ActnList, Grids, DBGrids, gsDBGrid,
  gsIBGrid, ComCtrls, gsDBTreeView, ToolWin, ExtCtrls, TB2Item, TB2Dock,
  TB2Toolbar, gdcClasses, IBCustomDataSet, gdcBase, gdcTree, StdCtrls,
  gd_MacrosMenu, dmImages_unit;

type
  Tgdc_frmDocumentType = class(Tgdc_frmMDVTree)
    gdcDocumentType: TgdcDocumentType;
    actNewSub: TAction;
    TBSubmenuItem1: TTBSubmenuItem;
    TBItem1: TTBItem;
    TBItem2: TTBItem;
    tbsmNew: TTBSubmenuItem;
    actAddUserDoc: TAction;
    actAddInvDocument: TAction;
    actAddInvPriceList: TAction;
    tbiAddInvPriceList: TTBItem;
    tbiAddInvDocument: TTBItem;
    tbiAddUserDoc: TTBItem;
    gdcBaseDocumentType: TgdcBaseDocumentType;
    pnlDocumentOptions: TPanel;
    splDocumentOptions: TSplitter;
    procedure FormCreate(Sender: TObject);
    procedure actNewSubExecute(Sender: TObject);
    procedure actNewSubUpdate(Sender: TObject);
    procedure actDetailNewExecute(Sender: TObject);
    procedure actAddUserDocExecute(Sender: TObject);
    procedure actAddInvDocumentExecute(Sender: TObject);
    procedure actAddInvPriceListExecute(Sender: TObject);
    procedure actAddInvDocumentUpdate(Sender: TObject);
    procedure actAddInvPriceListUpdate(Sender: TObject);
    procedure actAddUserDocUpdate(Sender: TObject);
    procedure tbsmNewClick(Sender: TObject);
    procedure actNewExecute(Sender: TObject);
    procedure tvGroupGetImageIndex(Sender: TObject; Node: TTreeNode);
  private

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;

  end;

var
  gdc_frmDocumentType: Tgdc_frmDocumentType;

implementation

{$R *.DFM}

uses gdcBaseInterface,  gd_ClassList, gdcInvPriceList_unit, gdcInvDocument_unit;

{ Tgdc_frmDocumentType }

class function Tgdc_frmDocumentType.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmDocumentType) then
    gdc_frmDocumentType := Tgdc_frmDocumentType.Create(AnOwner);

  Result := gdc_frmDocumentType;
end;

procedure Tgdc_frmDocumentType.FormCreate(Sender: TObject);
begin
  gdcObject := gdcBaseDocumentType;
  gdcDetailObject := gdcDocumentType;
  inherited;
end;

procedure Tgdc_frmDocumentType.actNewSubExecute(Sender: TObject);
begin
  (gdcObject as TgdcTree).CreateChildrenDialog(TgdcDocumentBranch);
end;

procedure Tgdc_frmDocumentType.actNewSubUpdate(Sender: TObject);
begin
  actNewSub.Enabled :=
    (gdcObject <> nil) and (gdcObject.CanCreate)
    and (gdcObject.State = dsBrowse)
    and (not gdcObject.EOF);
end;

procedure Tgdc_frmDocumentType.actDetailNewExecute(Sender: TObject);
begin
  gdcDocumentType.CreateDialog;
end;

procedure Tgdc_frmDocumentType.actAddUserDocExecute(Sender: TObject);
begin
  gdcDetailObject.CreateDialog(TgdcUserDocumentType);
end;

procedure Tgdc_frmDocumentType.actAddInvDocumentExecute(Sender: TObject);
begin
  gdcDetailObject.CreateDialog(TgdcInvDocumentType);
end;

procedure Tgdc_frmDocumentType.actAddInvPriceListExecute(Sender: TObject);
begin
  gdcDetailObject.CreateDialog(TgdcInvPriceListType);
end;

procedure Tgdc_frmDocumentType.actAddInvDocumentUpdate(Sender: TObject);
var
  N: TTreeNode;
begin
  N := tvGroup.Selected;
  while (N <> nil) and (N.Parent <> nil) do
    N := N.Parent;
  actAddInvDocument.Enabled := actDetailNew.Enabled
    and (N <> nil)
    and (gdcBaseManager.GetRUIDStringByID(Integer(N.Data)) = '804000_17');
end;

procedure Tgdc_frmDocumentType.actAddInvPriceListUpdate(Sender: TObject);
var
  N: TTreeNode;
begin
  N := tvGroup.Selected;
  while (N <> nil) and (N.Parent <> nil) do
    N := N.Parent;
  actAddInvPriceList.Enabled := actDetailNew.Enabled
    and (N <> nil)
    and (gdcBaseManager.GetRUIDStringByID(Integer(N.Data)) = '805000_17');
end;

procedure Tgdc_frmDocumentType.actAddUserDocUpdate(Sender: TObject);
var
  N: TTreeNode;
begin
  N := tvGroup.Selected;
  while (N <> nil) and (N.Parent <> nil) do
    N := N.Parent;
  actAddUserDoc.Enabled := actDetailNew.Enabled
    and (N <> nil)
    and (gdcBaseManager.GetRUIDStringByID(Integer(N.Data)) <> '805000_17')
    and (gdcBaseManager.GetRUIDStringByID(Integer(N.Data)) <> '804000_17');
end;

procedure Tgdc_frmDocumentType.tbsmNewClick(Sender: TObject);
begin
  actAddUserDoc.Update;
  actAddInvPriceList.Update;
  actAddInvDocument.Update;

  if actAddUserDoc.Enabled then
    actAddUserDoc.Execute
  else if actAddInvPriceList.Enabled then
    actAddInvPriceList.Execute
  else if actAddInvDocument.Enabled then
    actAddInvDocument.Execute;
end;

procedure Tgdc_frmDocumentType.actNewExecute(Sender: TObject);
begin
  gdcObject.CreateDialog(TgdcDocumentBranch);
end;

procedure Tgdc_frmDocumentType.tvGroupGetImageIndex(Sender: TObject;
  Node: TTreeNode);
var
  V: Variant;
begin
  V := gdcObject.GetFieldValueForID(Integer(Node.Data), 'documenttype');
  if (VarType(V) = varString) and (V = 'D') then
    Node.ImageIndex := 3
  else
    Node.ImageIndex := 0;
  Node.SelectedIndex := Node.ImageIndex;
end;

initialization
  RegisterFrmClass(Tgdc_frmDocumentType);

finalization
  UnRegisterFrmClass(Tgdc_frmDocumentType);
end.

