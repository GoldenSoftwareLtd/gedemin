
 {++
   Project ADDRESSBOOK
   Copyright © 2000- by Golden Software

   Модуль

     gdc_dlgContactGroup_unit

   Описание

     Диалоговое окно для добавления и редактирования Групп

   Автор

    Anton
    Julia

   История

     ver    date    who    what
     1.00 - 24.04.2000 - anton - Первая версия
            26.02.2002   Julia

 --}

unit gdc_dlgCustomGroup_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DBCtrls, ExtCtrls, ComCtrls, gdc_dlgTR_unit, Db, IBCustomDataSet,
  gdcBase, gdcContacts, Mask, ActnList, Grids,
  DBGrids, gsDBGrid, gsIBGrid, gsIBLookupComboBox,
  IBDatabase, at_Container, gdcTree, Menus, gdc_dlgTRPC_unit;

type
  Tgdc_dlgCustomGroup = class(Tgdc_dlgTRPC)
    actNewContact: TAction;
    actNewCompany: TAction;
    actChooseContact: TAction;
    actDeleteContact: TAction;
    Label1: TLabel;
    dbeName: TDBEdit;
    Label22: TLabel;
    dbmAddress: TDBMemo;
    Label28: TLabel;
    dbmPhone: TDBEdit;
    Label29: TLabel;
    dbmFax: TDBEdit;
    Label4: TLabel;
    dbmNote: TDBMemo;
    Label3: TLabel;
    gsibluFolder: TgsIBLookupComboBox;
  protected
    //Указывает необходимо ли отображать страницу
    function NeedVisibleTabSheet(const ARelationName: String): Boolean; override;
  end;

var
  gdc_dlgCustomGroup: Tgdc_dlgCustomGroup;

implementation

{$R *.DFM}

uses
  gd_ClassList;

{ Tgdc_dlgCustomGroup }

function Tgdc_dlgCustomGroup.NeedVisibleTabSheet(
  const ARelationName: String): Boolean;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_DLGTRPC_NEEDVISIBLETABSHEET('TGDC_DLGCUSTOMGROUP', 'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGCUSTOMGROUP', KEYNEEDVISIBLETABSHEET);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYNEEDVISIBLETABSHEET]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGCUSTOMGROUP') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), ARelationName]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGCUSTOMGROUP',
  {M}        'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = varBoolean then
  {M}          Result := Boolean(LResult);
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGCUSTOMGROUP' then
  {M}      begin
  {M}        Result := Inherited NeedVisibleTabSheet(ARelationName);
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  if AnsiCompareText(ARelationName, 'GD_HOLDING') = 0 then
    Result := False
  else
    Result := inherited NeedVisibleTabSheet(ARelationName);
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGCUSTOMGROUP', 'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGCUSTOMGROUP', 'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_dlgCustomGroup);

finalization
  UnRegisterFrmClass(Tgdc_dlgCustomGroup);

end.
