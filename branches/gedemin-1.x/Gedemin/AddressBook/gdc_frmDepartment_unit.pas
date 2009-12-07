
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
    procedure gdcDepartmentAfterInsert(DataSet: TDataSet);
  private
    isHolding: Boolean;

  public
    procedure SaveSettings; override;
    procedure LoadSettings; override;
  end;

var
  gdc_frmDepartment: Tgdc_frmDepartment;

implementation

{$R *.DFM}

uses
  gd_security, IBSQL,  gd_ClassList, gd_keyAssoc, Storages;

procedure Tgdc_frmDepartment.FormCreate(Sender: TObject);
begin
  gdcObject := gdcDepartment;
  gdcDetailObject := gdcEmployee;

  ibcmbCompany.CurrentKeyInt := UserStorage.ReadInteger('Department', 'CurrentCompany', IBLogin.CompanyKey);
  if ibcmbCompany.CurrentKeyInt = -1 then
    ibcmbCompany.CurrentKeyInt := IBLogin.CompanyKey;

  inherited;
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
  ibsql: TIBSQL;
begin
  if ibcmbCompany.CurrentKeyInt > 0 then
    if gdcObject.ParamByName('companykey').AsInteger <> ibcmbCompany.CurrentKeyInt then
    begin
      WasActive := gdcObject.Active;
      try
        ibsql := TIBSQL.Create(Self);
        try
          ibsql.SQL.Text := 'SELECT holdingkey FROM gd_holding WHERE holdingkey = ' +
            ibcmbCompany.CurrentKey;
          ibsql.Transaction := gdcObject.ReadTransaction;
          ibsql.ExecQuery;
          isHolding := ibsql.FieldByName('holdingkey').AsInteger > 0;
        finally
          ibsql.Free;
        end;

        gdcObject.Close;
        if IsHolding then
          gdcObject.AddSubSet(cst_Holding)
        else
          gdcObject.RemoveSubSet(cst_Holding);
        gdcObject.ParamByName('companykey').AsInteger :=
          ibcmbCompany.CurrentKeyInt;
      finally
        gdcObject.Active := WasActive;
      end;
    end;
end;

procedure Tgdc_frmDepartment.SaveSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMDEPARTMENT', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMDEPARTMENT', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMDEPARTMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMDEPARTMENT',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMDEPARTMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if Assigned(UserStorage) then
  begin
    UserStorage.SaveComponent(ibcmbCompany, ibcmbCompany.SaveToStream);
    UserStorage.WriteInteger('Department', 'CurrentCompany', ibcmbCompany.CurrentKeyInt);
  end;

  inherited;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMDEPARTMENT', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMDEPARTMENT', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmDepartment.LoadSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMDEPARTMENT', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMDEPARTMENT', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMDEPARTMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMDEPARTMENT',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMDEPARTMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if Assigned(UserStorage) then
    UserStorage.LoadComponent(ibcmbCompany, ibcmbCompany.LoadFromStream);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMDEPARTMENT', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMDEPARTMENT', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmDepartment.gdcDepartmentAfterInsert(DataSet: TDataSet);
begin
  inherited;

  if DataSet.FieldByName('parent').IsNull and (ibcmbCompany.CurrentKey > '') then
    DataSet.FieldByName('parent').AsInteger := ibcmbCompany.CurrentKeyInt;
end;

initialization
  RegisterFrmClass(Tgdc_frmDepartment);

finalization
  UnRegisterFrmClass(Tgdc_frmDepartment);
end.
