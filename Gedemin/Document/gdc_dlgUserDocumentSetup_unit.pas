
{++


  Copyright (c) 2001 by Golden Software of Belarus

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
    procedure FormCreate(Sender: TObject);

  private
//    FReportGroupKey: Integer;

  protected
    procedure BeforePost; override;

  public
    procedure SetupRecord; override;

    function TestCorrect: Boolean; override;
  end;

  Egdc_dlgUserDocumentSetup = class(Exception);

var
  gdc_dlgUserDocumentSetup: Tgdc_dlgUserDocumentSetup;

implementation

uses dmImages_unit, at_classes, dmDatabase_unit,  gd_ClassList, gdcClasses_interface;

{$R *.DFM}

{ Tgdc_dlgUserDocumentSetup }

procedure Tgdc_dlgUserDocumentSetup.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  DE: TgdDocumentEntry;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGUSERDOCUMENTSETUP', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGUSERDOCUMENTSETUP', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGUSERDOCUMENTSETUP') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGUSERDOCUMENTSETUP',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGUSERDOCUMENTSETUP' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  DE := gdClassList.FindDocByTypeID(gdcObject.FieldByName('parent').AsInteger, dcpHeader);
  if DE <> nil then
  begin
    iblcHeaderTable.gdClassName := 'TgdcTableToDocumentTable';
    iblcLineTable.gdClassName := 'TgdcTableToDocumentLineTable';
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGUSERDOCUMENTTYPE', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGUSERDOCUMENTTYPE', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

function Tgdc_dlgUserDocumentSetup.TestCorrect: Boolean;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_DLGUSERDOCUMENTSETUP', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGUSERDOCUMENTSETUP', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGUSERDOCUMENTSETUP') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGUSERDOCUMENTSETUP',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGUSERDOCUMENTSETUP' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  Result := inherited TestCorrect;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGUSERDOCUMENTSETUP', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGUSERDOCUMENTSETUP', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;


procedure Tgdc_dlgUserDocumentSetup.FormCreate(Sender: TObject);
begin
  inherited;

  if tsCommon.TabVisible then
    pcMain.ActivePage := tsCommon;
end;


procedure Tgdc_dlgUserDocumentSetup.BeforePost;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  rpgroupkey: Integer;
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
  inherited;
  rpgroupkey := gdcObject.FieldByName('reportgroupkey').AsInteger;
  if not (gdcObject as TgdcBaseDocumentType).UpdateReportGroup(
    'Документы пользователя',
    gdcObject.FieldByName('name').AsString,
    rpgroupkey, True)
  then
    raise EgdcIBError.Create('Невозможно создать группу отчетов!');

  gdcObject.FieldByName('reportgroupkey').AsInteger := rpgroupkey;
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

