// ShlTanya, 24.02.2019

unit gdc_frmDocumentType_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDVTree_unit, Db, Menus, ActnList, Grids, DBGrids, gsDBGrid,
  gsIBGrid, ComCtrls, gsDBTreeView, ToolWin, ExtCtrls, TB2Item, TB2Dock,
  TB2Toolbar, gdcClasses, IBCustomDataSet, gdcBase, gdcTree, StdCtrls,
  gd_MacrosMenu, dmImages_unit, gdcInvDocumentOptions, IBDatabase;

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
    tbdDTOptions: TTBDock;
    tbDTOptions: TTBToolbar;
    ibgrOptions: TgsIBGrid;
    dsInvDocumentOptions: TDataSource;
    ibdsDocumentOptions: TIBDataSet;
    ibTr: TIBTransaction;
    actDeleteOption: TAction;
    TBItem3: TTBItem;
    actCommitOption: TAction;
    TBItem4: TTBItem;
    TBSeparatorItem2: TTBSeparatorItem;
    actRollbackOption: TAction;
    TBItem5: TTBItem;
    gdcInvDocumentTypeOptions: TgdcInvDocumentTypeOptions;
    actNewOption: TAction;
    TBItem6: TTBItem;
    actEditOption: TAction;
    TBItem7: TTBItem;
    actRefreshOption: TAction;
    TBSeparatorItem3: TTBSeparatorItem;
    TBItem8: TTBItem;
    actFullDublicate: TAction;
    TBItem9: TTBItem;
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
    procedure FormDestroy(Sender: TObject);
    procedure actDeleteOptionExecute(Sender: TObject);
    procedure actDeleteOptionUpdate(Sender: TObject);
    procedure actCommitOptionUpdate(Sender: TObject);
    procedure actCommitOptionExecute(Sender: TObject);
    procedure actRollbackOptionUpdate(Sender: TObject);
    procedure actRollbackOptionExecute(Sender: TObject);
    procedure actNewOptionExecute(Sender: TObject);
    procedure actNewOptionUpdate(Sender: TObject);
    procedure actEditOptionExecute(Sender: TObject);
    procedure actEditOptionUpdate(Sender: TObject);
    procedure actRefreshOptionExecute(Sender: TObject);
    procedure actFullDublicateExecute(Sender: TObject);

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
  Assert(gdcBaseManager <> nil);

  gdcObject := gdcBaseDocumentType;
  gdcDetailObject := gdcDocumentType;
  inherited;

  ibTr.DefaultDatabase := gdcBaseManager.Database;
  ibTr.StartTransaction;
  ibdsDocumentOptions.Open;
  gdcInvDocumentTypeOptions.Open;
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
    and (gdcBaseManager.GetRUIDStringByID(GetTID(N.Data, Name)) = '804000_17');
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
    and (gdcBaseManager.GetRUIDStringByID(GetTID(N.Data, Name)) = '805000_17');
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
    and (gdcBaseManager.GetRUIDStringByID(GetTID(N.Data, Name)) <> '805000_17')
    and (gdcBaseManager.GetRUIDStringByID(GetTID(N.Data, Name)) <> '804000_17');
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
  V := gdcObject.GetFieldValueForID(GetTID(Node.Data, Name), 'documenttype');
  if (VarType(V) = varString) and (V = 'D') then
    Node.ImageIndex := 3
  else
    Node.ImageIndex := 0;
  Node.SelectedIndex := Node.ImageIndex;
end;

procedure Tgdc_frmDocumentType.FormDestroy(Sender: TObject);
begin
  inherited;
  if ibTr.InTransaction then
    ibTr.Commit;
end;

procedure Tgdc_frmDocumentType.actDeleteOptionExecute(Sender: TObject);
begin
  gdcInvDocumentTypeOptions.Delete;
  ibdsDocumentOptions.Delete;
end;

procedure Tgdc_frmDocumentType.actDeleteOptionUpdate(Sender: TObject);
begin
  actDeleteOption.Enabled := (not gdcInvDocumentTypeOptions.IsEmpty)
    and (not ibdsDocumentOptions.IsEmpty);
end;

procedure Tgdc_frmDocumentType.actCommitOptionUpdate(Sender: TObject);
begin
  actCommitOption.Enabled := ibTr.InTransaction;
end;

procedure Tgdc_frmDocumentType.actCommitOptionExecute(Sender: TObject);
begin
  ibTr.CommitRetaining;
end;

procedure Tgdc_frmDocumentType.actRollbackOptionUpdate(Sender: TObject);
begin
  actRollbackOption.Enabled := ibTr.InTransaction;
end;

procedure Tgdc_frmDocumentType.actRollbackOptionExecute(Sender: TObject);
begin
  ibTr.RollbackRetaining;
  ibdsDocumentOptions.Close;
  ibdsDocumentOptions.Open;
end;

procedure Tgdc_frmDocumentType.actNewOptionExecute(Sender: TObject);
var
  ID: TID;
begin
  if gdcInvDocumentTypeOptions.CreateDialog then
  begin
    ID := gdcInvDocumentTypeOptions.ID;
    ibdsDocumentOptions.Close;
    ibdsDocumentOptions.Open;
    ibdsDocumentOptions.Locate('id', TID2V(ID), []);
  end;
end;

procedure Tgdc_frmDocumentType.actNewOptionUpdate(Sender: TObject);
begin
  actNewOption.Enabled := gdcInvDocumentTypeOptions.Active;
end;

procedure Tgdc_frmDocumentType.actEditOptionExecute(Sender: TObject);
begin
  if gdcInvDocumentTypeOptions.EditDialog then
    ibdsDocumentOptions.Refresh;
end;

procedure Tgdc_frmDocumentType.actEditOptionUpdate(Sender: TObject);
begin
  actEditOption.Enabled := not gdcInvDocumentTypeOptions.IsEmpty;
end;

procedure Tgdc_frmDocumentType.actRefreshOptionExecute(Sender: TObject);
begin
  ibdsDocumentOptions.Close;
  ibdsDocumentOptions.Open;
end;

procedure Tgdc_frmDocumentType.actFullDublicateExecute(Sender: TObject);
begin
  inherited;
  gdcDocumentType.FullCopyDocument;
end;

initialization
  RegisterFrmClass(Tgdc_frmDocumentType);

finalization
  UnRegisterFrmClass(Tgdc_frmDocumentType);
end.

