// ShlTanya, 09.03.2019

unit gdc_dlgAcctTransaction_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, DBCtrls, Mask, dmDatabase_unit, Db, IBCustomDataSet,
  IBDatabase, gsIBLookupComboBox, Grids, DBGrids, gsDBGrid, gsIBGrid, IBSQL,
  gd_security, gdc_dlgTR_unit, ExtCtrls, Menus, gdcBase, gdcAcctTransaction;

type
  Tgdc_dlgAcctTransaction = class(Tgdc_dlgTR)
    Label1: TLabel;
    dbedName: TDBEdit;
    Label2: TLabel;
    dbmDescription: TDBMemo;
    gsibluCompany: TgsIBLookupComboBox;
    Label3: TLabel;
    Bevel1: TBevel;
    Label4: TLabel;
    iblcParent: TgsIBLookupComboBox;
    btnAdd: TButton;
    actAddTypeEntry: TAction;
    gdcAcctTransactionEntry: TgdcAcctTransactionEntry;
    dbcbIsInternal: TDBCheckBox;
    dbcbIsDisabled: TDBCheckBox;
    procedure actAddTypeEntryExecute(Sender: TObject);
  public
    function TestCorrect: Boolean; override;
  end;

  Egdc_dlgAcctTransaction = class(Exception);

var
  gdc_dlgAcctTransaction: Tgdc_dlgAcctTransaction;

implementation

{$R *.DFM}


{ Tgdc_dlgAcctTransaction }

uses
  gd_ClassList, wiz_FunctionBlock_unit;

function Tgdc_dlgAcctTransaction.TestCorrect: Boolean;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_DLGACCTTRANSACTION', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGACCTTRANSACTION', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGACCTTRANSACTION') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGACCTTRANSACTION',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGACCTTRANSACTION' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  Result := True;

  if gdcObject.FieldByName('NAME').AsString = '' then
  begin
    ModalResult := mrNone;
    gdcObject.FieldByName('NAME').FocusControl;
    raise Egdc_dlgAcctTransaction.Create('Укажите наименование типовой операции!');
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGACCTTRANSACTION', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGACCTTRANSACTION', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgAcctTransaction.actAddTypeEntryExecute(Sender: TObject);
begin
  inherited;

  if MainFunction <> nil then
  begin
    MessageBox(Handle,
      'Нельзя добавить типовую проводку находясь в режиме Конструктора функций.'#13#10 +
      'Используйте режим редактирования из списка Типовых Хозяйственных Операций.',
      'Внимание',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);

    exit;
  end;

  if gdcObject.State = dsInsert then
    gdcObject.Post;
  gdcAcctTransactionEntry.CreateDialog;
end;

initialization
  RegisterFrmClass(Tgdc_dlgAcctTransaction);

finalization
  UnRegisterFrmClass(Tgdc_dlgAcctTransaction);

end.
