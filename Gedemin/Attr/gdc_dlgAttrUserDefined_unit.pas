
{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    gdc_dlgAttrUserDefined_unit.pas

  Abstract

    Part of gedemin project.
    Dialog window for user defined tables.

  Author

    Denis Romanovski

  Revisions history

    1.0    30.10.2001    Dennis    Initial version.


--}

unit gdc_dlgAttrUserDefined_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTR_unit, Db, ActnList, StdCtrls, at_Container, ExtCtrls, gdcAttrUserDefined,
  Menus, gdc_dlgG_unit, IBDatabase;

type
  Tgdc_dlgAttrUserDefined = class(Tgdc_dlgTR)
    pnlMain: TPanel;
    atAttributes: TatContainer;

  public
    procedure SetupDialog; override;

    procedure SaveSettings; override;

    class procedure RegisterClassHierarchy; override;

  end;

var
  gdc_dlgAttrUserDefined: Tgdc_dlgAttrUserDefined;

implementation
{$R *.DFM}

uses
  at_classes, Storages, gd_ClassList, gdcBase;

{ Tgdc_dlgAttrUserDefined }

class procedure Tgdc_dlgAttrUserDefined.RegisterClassHierarchy;

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
          SL.Add(Items[I].LName + '=' + Items[I].RelationName);
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
            and not Assigned(Items[I].RelationFields.ByFieldName('PARENT'))
            and not Assigned(Items[I].RelationFields.ByFieldName('INHERITED'))then
          begin
            SL.Add(Items[I].LName + '=' + Items[I].RelationName);
          end;
      end;

      for I := 0 to SL.Count - 1 do
      begin
        CurrCE := gdClassList.Add(ACE.TheClass, SL.Values[SL.Names[I]], SL.Names[I],  ACE.SubType);
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
  CEBase := gdClassList.Find(Self);

  if CEBase = nil then
    raise EgdcException.Create('Unregistered class.');

  ReadFromRelations(CEBase);
end;

procedure Tgdc_dlgAttrUserDefined.SaveSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGATTRUSERDEFINED', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGATTRUSERDEFINED', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGATTRUSERDEFINED') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGATTRUSERDEFINED',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGATTRUSERDEFINED' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGATTRUSERDEFINED', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGATTRUSERDEFINED', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgAttrUserDefined.SetupDialog;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  RelName: String;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGATTRUSERDEFINED', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGATTRUSERDEFINED', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGATTRUSERDEFINED') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGATTRUSERDEFINED',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGATTRUSERDEFINED' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  RelName := '';

  try
    if gdcObject is TgdcAttrUserDefined then
      RelName := atDatabase.Relations.ByRelationName((gdcObject as TgdcAttrUserDefined).RelationName).LName
    else if gdcObject is TgdcAttrUserDefinedTree then
      RelName := atDatabase.Relations.ByRelationName((gdcObject as TgdcAttrUserDefinedTree).RelationName).LName
    else if gdcObject is TgdcAttrUserDefinedLBRBTree then
      RelName := atDatabase.Relations.ByRelationName((gdcObject as TgdcAttrUserDefinedLBRBTree).RelationName).LName;
  except
  end;

  if gdcObject.State = dsInsert then
    Caption := 'Добавление: ' + RelName
  else if gdcObject.State = dsEdit then
    Caption := 'Редактирование: ' + RelName
  else
    Caption := 'Просмотр: ' + RelName;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGATTRUSERDEFINED', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGATTRUSERDEFINED', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_dlgAttrUserDefined);

finalization
  UnRegisterFrmClass(Tgdc_dlgAttrUserDefined);

end.

