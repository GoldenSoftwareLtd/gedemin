
unit gdc_bug_dlgBugBase_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTRPC_unit, IBDatabase, Db, ActnList, at_Container, DBCtrls,
  StdCtrls, ComCtrls, Mask, IBSQL, gsIBLookupComboBox, Menus;

type
  Tgdc_bug_dlgBugBase = class(Tgdc_dlgTRPC)
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    DBText2: TDBText;
    dbcbSubSystem: TDBComboBox;
    DBEdit1: TDBEdit;
    DBEdit2: TDBEdit;
    dbcbBugArea: TDBComboBox;
    dbcbBugType: TDBComboBox;
    dbcbBugFrequency: TDBComboBox;
    DBEdit3: TDBEdit;
    DBMemo1: TDBMemo;
    DBMemo2: TDBMemo;
    iblkupFounder: TgsIBLookupComboBox;
    iblkupResponsible: TgsIBLookupComboBox;
    dbcbPriority: TDBComboBox;
    DBMemo3: TDBMemo;
    Label1: TLabel;
    DBText1: TDBText;
    Label8: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    DBText3: TDBText;
    procedure DBEdit1Exit(Sender: TObject);

  public
    procedure SetupDialog; override;
  end;

var
  gdc_bug_dlgBugBase: Tgdc_bug_dlgBugBase;

implementation

{$R *.DFM}

uses
  gdcBugBase,  gd_ClassList;

{ Tgdc_bug_dlgBugBase }

procedure Tgdc_bug_dlgBugBase.DBEdit1Exit(Sender: TObject);
begin
  if DBEdit2.Text = '' then DBEdit2.Text := DBEdit1.Text;
end;

procedure Tgdc_bug_dlgBugBase.SetupDialog;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_BUG_DLGBUGBASE', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_BUG_DLGBUGBASE', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_BUG_DLGBUGBASE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_BUG_DLGBUGBASE',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_BUG_DLGBUGBASE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  (gdcObject as TgdcBugBase).GetBugAreas(dbcbBugArea.Items);
  (gdcObject as TgdcBugBase).GetSubSystems(dbcbSubSystem.Items);
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_BUG_DLGBUGBASE', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_BUG_DLGBUGBASE', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_bug_dlgBugBase);
  //RegisterClass(Tgdc_bug_dlgBugBase);
finalization
  UnRegisterFrmClass(Tgdc_bug_dlgBugBase);

end.
