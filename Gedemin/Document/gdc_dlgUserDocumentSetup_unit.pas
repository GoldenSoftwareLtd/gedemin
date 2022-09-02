// ShlTanya, 24.02.2019

{++

  Copyright (c) 2001-2015 by Golden Software of Belarus, Ltd

  Module

    gdc_dlgUserDocumentSetup_unit.pas

  Abstract

    Business class. User base document.

  Author

    Romanovski Denis (03-12-2001)

  Revisions history

    Initial  03-12-2001  Dennis  Initial version.

--}

unit gdc_dlgUserDocumentSetup_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, Db, ActnList, StdCtrls, ExtCtrls, DBCtrls, Mask, ComCtrls,
  ImgList, TB2Item, TB2Dock, TB2Toolbar, gdcMetaData, IBCustomDataSet,
  gdcBase, Grids, DBGrids, gsDBGrid, gsIBGrid, gsIBLookupComboBox,
  gdc_dlgTR_unit, IBDatabase, gdcCustomTable, gdc_dlgDocumentType_unit,
  gdcAcctTransaction, gdcClasses, gdcFunction, gdcTree, gdcDelphiObject,
  gdcEvent, Menus, IBSQL, gdcCustomFunction;

type
  Tgdc_dlgUserDocumentSetup = class(Tgdc_dlgDocumentType)
    actNewField: TAction;
    actEditField: TAction;
    actDeleteField: TAction;
    actNewFieldDetail: TAction;
    actEditFieldDetail: TAction;
    actDeleteFieldDetail: TAction;

  protected
    procedure BeforePost; override;
  end;

  Egdc_dlgUserDocumentSetup = class(Exception);

var
  gdc_dlgUserDocumentSetup: Tgdc_dlgUserDocumentSetup;

implementation

uses
  dmImages_unit, at_classes, dmDatabase_unit,  gd_ClassList, gdcClasses_interface,
  gdcBaseInterface;

{$R *.DFM}

{ Tgdc_dlgUserDocumentSetup }

procedure Tgdc_dlgUserDocumentSetup.BeforePost;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  rpgroupkey: TID;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGUSERDOCUMENTSETUP', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGUSERDOCUMENTSETUP', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGUSERDOCUMENTSETUP') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGUSERDOCUMENTSETUP',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGUSERDOCUMENTSETUP' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  rpgroupkey := GetTID(gdcObject.FieldByName('reportgroupkey'));
  if not (gdcObject as TgdcBaseDocumentType).UpdateReportGroup(
    'Документы пользователя',
    gdcObject.FieldByName('name').AsString,
    rpgroupkey, True)
  then
    raise EgdcIBError.Create('Невозможно создать группу отчетов!');

  SetTID(gdcObject.FieldByName('reportgroupkey'), rpgroupkey);

  inherited;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGUSERDOCUMENTSETUP', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGUSERDOCUMENTSETUP', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_dlgUserDocumentSetup);

finalization
  UnRegisterFrmClass(Tgdc_dlgUserDocumentSetup);
end.

