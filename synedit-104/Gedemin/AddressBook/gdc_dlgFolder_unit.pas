 {++
   Project ADDRESSBOOK
   Copyright © 2000- 2001 by Golden Software

   Модуль

     gdc_dlgFolder_unit

   Описание

     Форма для ввода папки

   Автор

     Anton

   История

     ver    date    who    what
     1.00 - 14.06.2001 - Anton - Первая версия

 --}

unit gdc_dlgFolder_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IBDatabase, IBSQL, ActnList, IBCustomDataSet, IBUpdateSQL, gd_security,
  Db, IBQuery, StdCtrls, Mask, DBCtrls, ExtCtrls, gdc_dlgTRPC_unit, gdcBase,
  gdcContacts,  gdc_dlgG_unit, Menus, at_Container, ComCtrls,
  gsIBLookupComboBox;

type
  Tgdc_dlgFolder = class(Tgdc_dlgTRPC)
    Label1: TLabel;
    dbeName: TDBEdit;
    gsIBLookupComboBox1: TgsIBLookupComboBox;
    Label2: TLabel;
    protected
      function NeedVisibleTabSheet(const ARelationName: String): Boolean; override;
  end;

var
  gdc_dlgFolder: Tgdc_dlgFolder;

implementation

{$R *.DFM}


uses
  gd_ClassList;

{ Tgdc_dlgFolder }

function Tgdc_dlgFolder.NeedVisibleTabSheet(
  const ARelationName: String): Boolean;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_DLGTRPC_NEEDVISIBLETABSHEET('TGDC_DLGFOLDER', 'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGFOLDER', KEYNEEDVISIBLETABSHEET);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYNEEDVISIBLETABSHEET]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGFOLDER') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), ARelationName]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGFOLDER',
  {M}        'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = varBoolean then
  {M}          Result := Boolean(LResult);
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGFOLDER' then
  {M}      begin
  {M}        Result := Inherited NeedVisibleTabSheet(ARelationName);
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  if AnsiCompareText(ARelationName, 'GD_HOLDING') = 0 then
    Result := False
  else if AnsiCompareText(ARelationName, 'GD_CONTACTLIST') = 0 then
    Result := False
  else
    Result := inherited NeedVisibleTabSheet(ARelationName);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGFOLDER', 'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGFOLDER', 'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_dlgFolder);

finalization
  UnRegisterFrmClass(Tgdc_dlgFolder);

end.
