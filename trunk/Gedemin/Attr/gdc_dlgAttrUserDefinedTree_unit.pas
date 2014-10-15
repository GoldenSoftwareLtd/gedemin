
unit gdc_dlgAttrUserDefinedTree_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgAttrUserDefined_unit, StdCtrls, gsIBLookupComboBox, Menus, Db,
  ActnList, at_Container, ExtCtrls, IBDatabase, gdcAttrUserDefined;

type
  Tgdc_dlgAttrUserDefinedTree = class(Tgdc_dlgAttrUserDefined)
    gsiblkupParent: TgsIBLookupComboBox;
    ibtrParent: TIBTransaction;
    lblParent: TLabel;

  public
    procedure SetupDialog; override;
  end;

var
  gdc_dlgAttrUserDefinedTree: Tgdc_dlgAttrUserDefinedTree;

implementation

{$R *.DFM}

uses
  gdcTree, gdcBaseInterface, gd_ClassList, gdcBase, at_Classes;

{ Tgdc_dlgAttrUserDefinedTree }

procedure TGDC_DLGATTRUSERDEFINEDTREE.SetupDialog;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
       LSubtype: string;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGATTRUSERDEFINEDTREE', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGATTRUSERDEFINEDTREE', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGATTRUSERDEFINEDTREE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGATTRUSERDEFINEDTREE',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGATTRUSERDEFINEDTREE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  if gdcObject is TgdcTree then
    with gdcObject as TgdcTree do
    begin
      ibtrParent.DefaultDatabase := Database;
      gsiblkupParent.gdClassName := ClassName;
      LSubtype := SubType;
      While ClassParentSubtype(LSubtype) <> '' do
        LSubtype := ClassParentSubtype(LSubtype);
      gsiblkupParent.SubType := LSubType;
    end;
    
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGATTRUSERDEFINEDTREE', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGATTRUSERDEFINEDTREE', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_dlgAttrUserDefinedTree);

finalization
  UnRegisterFrmClass(Tgdc_dlgAttrUserDefinedTree);

end.
