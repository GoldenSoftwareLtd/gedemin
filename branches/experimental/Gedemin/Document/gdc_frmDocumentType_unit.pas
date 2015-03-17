unit gdc_frmDocumentType_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDVTree_unit, Db, Menus, ActnList, Grids, DBGrids, gsDBGrid,
  gsIBGrid, ComCtrls, gsDBTreeView, ToolWin, ExtCtrls, TB2Item, TB2Dock,
  TB2Toolbar, gdcClasses, IBCustomDataSet, gdcBase, gdcTree, StdCtrls,
  gd_MacrosMenu, dmImages_unit, Contnrs;

type
  Tgdc_frmDocumentType = class(Tgdc_frmMDVTree)
    gdcDocumentType: TgdcDocumentType;
    actNewSub: TAction;
    gdcDocumentBranch: TgdcDocumentBranch;
    procedure FormCreate(Sender: TObject);
    procedure tvGroupGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure actDetailNewExecute(Sender: TObject);
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
  gdcObject := gdcDocumentBranch;
  gdcDetailObject := gdcDocumentType;
  inherited;
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

procedure Tgdc_frmDocumentType.actDetailNewExecute(Sender: TObject);
var
  N: TTreeNode;
  RUID: String;
begin
  N := tvGroup.Selected;
  while (N <> nil) and (N.Parent <> nil) do
    N := N.Parent;

  if N <> nil then
  begin
    RUID := gdcBaseManager.GetRUIDStringByID(Integer(N.Data));
    if RUID = '804000_17' then
      gdcDetailObject.CreateDialog(TgdcInvDocumentType)
    else
      if RUID = '805000_17' then
        gdcDetailObject.CreateDialog(TgdcInvPriceListType)
      else
        gdcDetailObject.CreateDialog(TgdcUserDocumentType);
  end;
end;

initialization
  RegisterFrmClass(Tgdc_frmDocumentType);

finalization
  UnRegisterFrmClass(Tgdc_frmDocumentType);
end.

