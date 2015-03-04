
 {++

   Copyright © 2000-2014 by Golden Software of Belarus, Ltd

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
  Temp: String;
  Res: OleVariant;
begin
  Result := inherited TestCorrect;

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
end;

initialization
  RegisterFrmClass(Tgdc_dlgBank);

finalization
  UnRegisterFrmClass(Tgdc_dlgBank);
end.
