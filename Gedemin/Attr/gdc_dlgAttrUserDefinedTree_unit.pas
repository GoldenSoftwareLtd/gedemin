
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

    class procedure RegisterClassHierarchy; override;

  end;

var
  gdc_dlgAttrUserDefinedTree: Tgdc_dlgAttrUserDefinedTree;

implementation

{$R *.DFM}

uses
  gdcTree, gdcBaseInterface, gd_ClassList, gdcBase, at_Classes;

{ Tgdc_dlgAttrUserDefinedTree }

class procedure Tgdc_dlgAttrUserDefinedTree.RegisterClassHierarchy;

  procedure ReadFromRelations(ACE: TgdClassEntry);
  var
    CurrCE: TgdClassEntry;
    SL: TStringList;
    I: Integer;
  begin
    if ACE.Initialized then
      exit;

    SL := TStringList.Create;
    try
      if ACE.SubType > '' then
      begin
        with atDatabase.Relations do
        for I := 0 to Count - 1 do
        if Items[I].IsUserDefined
          and Assigned(Items[I].PrimaryKey)
          and Assigned(Items[I].PrimaryKey.ConstraintFields)
          and (Items[I].PrimaryKey.ConstraintFields.Count = 1)
          and (AnsiCompareText(Items[I].PrimaryKey.ConstraintFields[0].FieldName, 'ID') = 0)
          and  Assigned(Items[I].RelationFields.ByFieldName('INHERITED'))
          and (AnsiCompareText(Items[I].RelationFields.ByFieldName('ID').ForeignKey.ReferencesRelation.RelationName,
            ACE.SubType) = 0) then
        begin
          SL.Add(Items[I].RelationName);
        end;
      end
      else
      begin
        with atDatabase.Relations do
        for I := 0 to Count - 1 do
          if Items[I].IsUserDefined
            and Assigned(Items[I].PrimaryKey)
            and Assigned(Items[I].PrimaryKey.ConstraintFields)
            and (Items[I].PrimaryKey.ConstraintFields.Count = 1)
            and (AnsiCompareText(Items[I].PrimaryKey.ConstraintFields[0].FieldName, 'ID') = 0)
            and Assigned(Items[I].RelationFields.ByFieldName('PARENT'))
            and not Assigned(Items[I].RelationFields.ByFieldName('INHERITED'))then
          begin
            SL.Add(Items[I].RelationName);
          end;
      end;

      for I := 0 to SL.Count - 1 do
      begin
        CurrCE := frmClassList.Add(ACE.TheClass, SL[I], ACE.SubType);
        ReadFromRelations(CurrCE);
      end;
    finally
      SL.Free;
    end;

    ACE.Initialized := True;
  end;

var
  CEBase: TgdClassEntry;

begin
  CEBase := frmClassList.Find(Self);

  if CEBase = nil then
    raise EgdcException.Create('Unregistered class.');

  ReadFromRelations(CEBase);
end;


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
