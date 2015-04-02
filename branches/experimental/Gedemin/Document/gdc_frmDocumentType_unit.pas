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

  protected
    procedure SetGdcObject(const Value: TgdcBase); override;

    procedure SetgdcDetailObject(const Value: TgdcBase); override;

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;

  end;

var
  gdc_frmDocumentType: Tgdc_frmDocumentType;

implementation

{$R *.DFM}

uses gdcBaseInterface,  gd_ClassList, gdcInvPriceList_unit, gdcInvDocument_unit;

{ Tgdc_frmDocumentType }

procedure Tgdc_frmDocumentType.SetgdcDetailObject(const Value: TgdcBase);
begin
  inherited;

  tbsmNew.Clear;
  tbsmNew.DropdownCombo := gdClassList.Get(TgdBaseEntry, gdcDetailObject.ClassName,
    gdcDetailObject.SubType).Count > 0;
  tbsmNew.OnPopup := tbiDetailNewPopup;

  actDetailNew.Visible := True;
  actDetailNew.OnExecute := actDetailNewExecute;

  tbiDetailNew.Visible := False;

  tbsmNew.Action := actDetailNew;
end;

procedure Tgdc_frmDocumentType.SetGdcObject(const Value: TgdcBase);
begin
  inherited;

  tbiNew.Visible := False;

  TBSubmenuItem1.Clear;
  TBSubmenuItem1.DropdownCombo := gdClassList.Get(TgdBaseEntry, gdcObject.ClassName,
    gdcObject.SubType).Count > 0;
  TBSubmenuItem1.OnPopup := tbiNewPopup;
end;

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
  // Не удалять!!! Нужен для подджки dfm до наследования!!!
end;

procedure Tgdc_frmDocumentType.actNewSubUpdate(Sender: TObject);
begin
// Не удалять!!! Нужен для подджки dfm до наследования!!!
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

procedure Tgdc_frmDocumentType.actAddUserDocExecute(Sender: TObject);
begin
  // Не удалять!!! Нужен для подджки dfm до наследования!!!
end;

procedure Tgdc_frmDocumentType.actAddInvDocumentExecute(Sender: TObject);
begin
  // Не удалять!!! Нужен для подджки dfm до наследования!!!
end;

procedure Tgdc_frmDocumentType.actAddInvPriceListExecute(Sender: TObject);
begin
  // Не удалять!!! Нужен для подджки dfm до наследования!!!
end;

procedure Tgdc_frmDocumentType.actAddInvDocumentUpdate(Sender: TObject);
begin
  // Не удалять!!! Нужен для подджки dfm до наследования!!!
end;

procedure Tgdc_frmDocumentType.actAddInvPriceListUpdate(Sender: TObject);
begin
  // Не удалять!!! Нужен для подджки dfm до наследования!!!
end;

procedure Tgdc_frmDocumentType.actAddUserDocUpdate(Sender: TObject);
begin
  // Не удалять!!! Нужен для подджки dfm до наследования!!!
end;

procedure Tgdc_frmDocumentType.tbsmNewClick(Sender: TObject);
begin
  // Не удалять!!! Нужен для подджки dfm до наследования!!!
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

