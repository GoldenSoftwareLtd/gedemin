unit gdc_attr_frmFunction_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcFunction, gdc_frmMDVTree_unit,
  gdcTree, gdcDelphiObject, gsDBTreeView, gdcCustomFunction;

type
  Tgdc_frmFunction = class(Tgdc_frmMDVTree)
    gdcFunction: TgdcFunction;
    gdcDelphiObject: TgdcDelphiObject;
    procedure FormCreate(Sender: TObject);

  protected
    procedure RemoveSubSetList(S: TStrings); override;

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
    
    procedure SetChoose(AnObject: TgdcBase); override;
  end;

var
  gdc_frmFunction: Tgdc_frmFunction;

implementation

{$R *.DFM}

uses
  gd_ClassList, gd_security_operationconst, rp_report_const;

class function Tgdc_frmFunction.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmFunction) then
    gdc_frmFunction := Tgdc_frmFunction.Create(AnOwner);
  Result := gdc_frmFunction;
end;

procedure Tgdc_frmFunction.FormCreate(Sender: TObject);
begin
  gdcObject := gdcDelphiObject;
  gdcDetailObject := gdcFunction;
//  gdcObject.ParamByName('objectkey').AsInteger := OBJ_APPLICATION;
  inherited;
end;

procedure Tgdc_frmFunction.RemoveSubSetList(S: TStrings);
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_MDH_REMOVESUBSETLIST('TGDC_FRMFUNCTION', 'REMOVESUBSETLIST', KEYREMOVESUBSETLIST)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_FRMFUNCTION', KEYREMOVESUBSETLIST);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYREMOVESUBSETLIST]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMFUNCTION') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(S)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMFUNCTION',
  {M}        'REMOVESUBSETLIST', KEYREMOVESUBSETLIST, Params, LResult) then exit;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMFUNCTION' then
  {M}      begin
  {M}        Inherited;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  inherited;
  S.Add('ByLBRBModule');
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMFUNCTION', 'REMOVESUBSETLIST', KEYREMOVESUBSETLIST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMFUNCTION', 'REMOVESUBSETLIST', KEYREMOVESUBSETLIST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmFunction.SetChoose(AnObject: TgdcBase);
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_SETUP('TGDC_FRMFUNCTION', 'SETCHOOSE', KEYSETCHOOSE)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_FRMFUNCTION', KEYSETCHOOSE);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETCHOOSE]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMFUNCTION') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(AnObject)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMFUNCTION',
  {M}        'SETCHOOSE', KEYSETCHOOSE, Params, LResult) then exit;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMFUNCTION' then
  {M}      begin
  {M}        Inherited;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
 inherited;
  if AnObject is TgdcFunction then
  begin
    gdcObject.ExtraConditions.Clear;
    gdcObject.ExtraConditions.Add('EXISTS (SELECT * FROM evt_object o1 LEFT JOIN gd_function f ON o1.id = f.modulecode ' +
      'WHERE o1.lb >= z.lb AND o1.rb <= z.rb AND ' +
      '((UPPER(f.module) = ''' + scrUnkonownModule + ''') OR ' +
      '(UPPER(f.module) = ''' + scrGlobalObject + ''') OR ' +
      '(UPPER(f.module) = ''' + scrVBClasses + ''') OR ' +
      '(UPPER(f.module) = ''' + MainModuleName + ''') OR ' +
      '(UPPER(f.module) = ''' + ParamModuleName + ''') OR ' +
      '(UPPER(f.module) = ''' + EventModuleName + ''') OR ' +
      '(UPPER(f.module) = ''' + scrEntryModuleName + ''') OR ' +
      '(UPPER(f.module) = ''' + scrConst + '''))' +
      ' ) ');
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMFUNCTION', 'SETCHOOSE', KEYSETCHOOSE)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMFUNCTION', 'SETCHOOSE', KEYSETCHOOSE);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_frmFunction);
  //RegisterClass(Tgdc_frmFunction);
finalization
  UnRegisterFrmClass(Tgdc_frmFunction);

end.
