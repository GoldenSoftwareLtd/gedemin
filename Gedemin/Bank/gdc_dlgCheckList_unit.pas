// ShlTanya, 30.01.2019

unit gdc_dlgCheckList_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgHGR_unit, Db, ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid,
  gsIBCtrlGrid, ComCtrls, ToolWin, ExtCtrls, StdCtrls, IBSQL, Mask,
  xDateEdits, gsIBLookupComboBox, DBCtrls, gdcCheckList, gd_Security,
  gd_security_body, TB2Item, TB2Dock, TB2Toolbar, IBDatabase, Menus;

type
  Tgdc_dlgCheckList = class(Tgdc_dlgHGR)
    Label11: TLabel;
    Label6: TLabel;
    dbeOperKind: TDBEdit;
    dbeDest: TgsIBLookupComboBox;
    Label16: TLabel;
    Label7: TLabel;
    dbeQueue: TDBEdit;
    dbeTerm: TxDateDBEdit;
    Label8: TLabel;
    dbeBankGroup: TDBEdit;
    Bevel3: TBevel;
    gsibluBankCode: TgsIBLookupComboBox;
    gsibluBank: TgsIBLookupComboBox;
    dbeDate: TxDateDBEdit;
    dbeNumber: TDBEdit;
    gsibluOwnAccount: TgsIBLookupComboBox;
    Bevel1: TBevel;
    sqlBankData: TIBSQL;
    Label1: TLabel;
    Label3: TLabel;
    Label2: TLabel;
    Label5: TLabel;
    Label4: TLabel;

  protected
    procedure BeforePost; override;

  public
    procedure SetupDialog; override;
  end;

var
  gdc_dlgCheckList: Tgdc_dlgCheckList;

implementation

{$R *.DFM}

uses
  gd_ClassList, gdcBaseInterface;

procedure Tgdc_dlgCheckList.BeforePost;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGCHECKLIST', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGCHECKLIST', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGCHECKLIST') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGCHECKLIST',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGCHECKLIST' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  if not (gdcObject.State in [dsEdit, dsInsert]) then
    gdcObject.Edit;

  gdcObject.FieldByName('DESTCODE').AsString := dbeDest.Text;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGCHECKLIST', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGCHECKLIST', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgCheckList.SetupDialog;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGCHECKLIST', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGCHECKLIST', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGCHECKLIST') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGCHECKLIST',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGCHECKLIST' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  FgdcDetailObject := TgdcCheckList(gdcObject).DetailObject;
  dsDetail.DataSet := FgdcDetailObject;

  gsibluOwnAccount.Condition := 'COMPANYKEY = ' + TID2S(IBLogin.CompanyKey);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGCHECKLIST', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGCHECKLIST', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}

end;

initialization
  RegisterFrmClass(Tgdc_dlgCheckList);

finalization
  UnRegisterFrmClass(Tgdc_dlgCheckList);

end.
