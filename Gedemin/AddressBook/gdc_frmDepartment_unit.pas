// andreik, 15.01.2019

unit gdc_frmDepartment_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDVTree_unit, Db, Menus, ActnList, Grids, DBGrids, gsDBGrid,
  gsIBGrid, ComCtrls, gsDBTreeView, ToolWin, ExtCtrls, TB2Item, TB2Dock,
  TB2Toolbar, IBCustomDataSet, gdcBase, gdcContacts, IBDatabase, gdcTree,
  StdCtrls, gd_MacrosMenu, gsIBLookupComboBox;

type
  Tgdc_frmDepartment = class(Tgdc_frmMDVTree)
    gdcDepartment: TgdcDepartment;
    IBTransaction: TIBTransaction;
    actSubNew: TAction;
    tbsiNew: TTBSubmenuItem;
    tbiMenuSubNew: TTBItem;
    tbiMenuNew: TTBItem;
    TBControlItem2: TTBControlItem;
    Label1: TLabel;
    TBControlItem1: TTBControlItem;
    ibcmbCompany: TgsIBLookupComboBox;
    gdcEmployee: TgdcEmployee;
    procedure FormCreate(Sender: TObject);
    procedure actNewExecute(Sender: TObject);
    procedure actSubNewExecute(Sender: TObject);
    procedure ibcmbCompanyChange(Sender: TObject);
    procedure gdcDepartmentNewRecord(DataSet: TDataSet);

  protected
    procedure SetGdcObject(const Value: TgdcBase); override;
  end;

var
  gdc_frmDepartment: Tgdc_frmDepartment;

implementation

{$R *.DFM}

uses
  gd_security, IBSQL, gd_ClassList, gd_keyAssoc, Storages, gdcBaseInterface;

procedure Tgdc_frmDepartment.FormCreate(Sender: TObject);
begin
  gdcObject := gdcDepartment;
  gdcDetailObject := gdcEmployee;

  ibcmbCompany.CurrentKeyInt := IBLogin.CompanyKey;

  inherited;
end;

procedure Tgdc_frmDepartment.SetGdcObject(const Value: TgdcBase);
begin
  inherited;

  tbsiNew.Visible := False;
  tbiNew.Visible := True;
end;

procedure Tgdc_frmDepartment.actNewExecute(Sender: TObject);
begin
  if gdcDepartment.RecordCount = 0 then
    gdcDepartment.Parent := ibcmbCompany.CurrentKeyInt;
  gdcDepartment.CreateDialog;
end;

procedure Tgdc_frmDepartment.actSubNewExecute(Sender: TObject);
begin
  gdcDepartment.CreateChildrenDialog;
end;

procedure Tgdc_frmDepartment.ibcmbCompanyChange(Sender: TObject);
var
  WasActive: Boolean;
begin
  if not EqTID(gdcObject.ParamByName('companykey'), ibcmbCompany.CurrentKeyInt) then
  begin
    WasActive := gdcObject.Active;
    try
      gdcObject.Active := False;
      SetTID(gdcObject.ParamByName('companykey'), ibcmbCompany.CurrentKeyInt);
    finally
      gdcObject.Active := WasActive;
    end;
  end;
end;

procedure Tgdc_frmDepartment.gdcDepartmentNewRecord(DataSet: TDataSet);
begin
  inherited;
  if DataSet.FieldByName('parent').IsNull and (ibcmbCompany.CurrentKey > '') then
    SetTID(DataSet.FieldByName('parent'), ibcmbCompany.CurrentKeyInt);
end;

initialization
  RegisterFrmClass(Tgdc_frmDepartment);

finalization
  UnRegisterFrmClass(Tgdc_frmDepartment);
end.
