
 {++

   Copyright © 2000-2017 by Golden Software of Belarus, Ltd

   Модуль

     gdc_dlgCompany_unit

   Описание

     Окно для работы с компанией

   Автор

     Anton

   История

     ver    date    who    what

     1.00 - 25.06.2001 - anton - Первая версия

 --}

unit gdc_dlgBank_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgCustomCompany_unit, Db, IBCustomDataSet, gdcBase, gdcContacts,
  ActnList, at_Container, ComCtrls, ToolWin, ExtCtrls, DBCtrls, StdCtrls,
  Grids, Mask, Buttons, gsIBGrid, Menus, IBDatabase, TB2Item, TB2Dock,
  TB2Toolbar, JvDBImage, gsDBGrid, gsIBLookupComboBox, DBGrids;

type
  Tgdc_dlgBank = class(Tgdc_dlgCustomCompany)
    LabelCode: TLabel;
    dbeBankCode: TDBEdit;
    LabelMFO: TLabel;
    dbeBankMFO: TDBEdit;
    lblSWIFT: TLabel;
    dbeSWIFT: TDBEdit;
    lblBankBranch: TLabel;
    dbedBankBranch: TDBEdit;

  public
    function TestCorrect: Boolean; override;
  end;

var
  gdc_dlgBank: Tgdc_dlgBank;

implementation

{$R *.DFM}

uses
  gd_ClassList, gdcBaseInterface;

function Tgdc_dlgBank.TestCorrect: Boolean;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  {Temp: String;
  Res: OleVariant;}
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_DLGBANK', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGBANK', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGBANK') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGBANK',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGBANK' then
  {M}      begin
  {M}        Result := inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  Result := inherited TestCorrect;

  {
  if Result then
  begin
    if (gdcObject.State = dsInsert) or gdcObject.FieldChanged('bankcode')
      or gdcObject.FieldChanged('bankbranch') then
    begin
      Temp := 'SELECT FIRST 1 * FROM gd_bank WHERE TRIM(bankcode) = ''' +
        Trim(StringReplace(gdcObject.FieldByName('bankcode').AsString, '''', '''''', [rfReplaceAll])) + ''' ';

      if gdcObject.FieldByName('bankbranch').isNull then
        Temp := Temp + ' AND COALESCE(bankbranch, '''') = '''' '
      else
        Temp := Temp + ' AND TRIM(bankbranch) = ''' +
          Trim(StringReplace(gdcObject.FieldByName('bankbranch').AsString, '''', '''''', [rfReplaceAll])) + '''';

      Temp := Temp + ' AND bankkey <> ' + gdcObject.FieldByName('bankkey').AsString;

      gdcBaseManager.ExecSingleQueryResult(Temp, 0, Res);

      if (not VarIsEmpty(Res)) then
      begin
        MessageBox(Handle,
          'Банк с таким кодом и номером отделения уже существует в базе данных.',
          'Внимание',
          MB_OK or MB_ICONHAND or MB_TASKMODAL);
        Result := False;
      end;
    end;
  end;
  }

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGBANK', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGBANK', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_dlgBank);

finalization
  UnRegisterFrmClass(Tgdc_dlgBank);
end.
