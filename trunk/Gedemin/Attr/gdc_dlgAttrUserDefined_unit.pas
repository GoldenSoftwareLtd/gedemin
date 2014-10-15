
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
  end;

var
  gdc_dlgAttrUserDefined: Tgdc_dlgAttrUserDefined;

implementation
{$R *.DFM}

uses
  at_classes, Storages, gd_ClassList, gdcBase;

{ Tgdc_dlgAttrUserDefined }

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

