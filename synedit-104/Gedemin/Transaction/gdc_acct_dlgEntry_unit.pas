unit gdc_acct_dlgEntry_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTR_unit, IBDatabase, Menus, Db, ActnList, StdCtrls, Mask, DBCtrls,
  gsIBLookupComboBox, Grids, DBGrids, gsDBGrid, gsIBGrid, xDateEdits,
  IBCustomDataSet, gdcBase, gdcAcctEntryRegister, gdcAcctTransaction,
  xCalculatorEdit, ExtCtrls, at_classes, IBSQL, gdc_dlgTRPC_unit,
  at_Container, ComCtrls, xCalc, TB2Dock, TB2Toolbar, gdvParamPanel,
  TB2Item, frAcctEntrySimpleLine_unit, AcctUtils;

type
  Tgdc_acct_dlgEntry = class(Tgdc_dlgTRPC)
    dsDebitLine: TDataSource;
    dsCreditLine: TDataSource;
    actNewDebit: TAction;
    actDeleteDebit: TAction;
    actNewCredit: TAction;
    actDeleteCredit: TAction;
    Panel1: TPanel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    xDateDBEdit1: TxDateDBEdit;
    DBEdit1: TDBEdit;
    DBEdit2: TDBEdit;
    Panel2: TPanel;
    Splitter1: TSplitter;
    Panel3: TPanel;
    Panel4: TPanel;
    TBDock1: TTBDock;
    TBToolbar1: TTBToolbar;
    TBItem3: TTBItem;
    TBItem2: TTBItem;
    sboxDebit: TgdvParamScrolBox;
    Panel6: TPanel;
    Panel7: TPanel;
    TBDock2: TTBDock;
    TBToolbar2: TTBToolbar;
    TBItem4: TTBItem;
    TBItem1: TTBItem;
    sboxCredit: TgdvParamScrolBox;
    pnlHolding: TPanel;
    lblCompany: TLabel;
    iblkCompany: TgsIBLookupComboBox;
    pTransaction: TPanel;
    Label1: TLabel;
    iblcTransaction: TgsIBLookupComboBox;

    procedure actNewDebitExecute(Sender: TObject);
    procedure actDeleteDebitExecute(Sender: TObject);
    procedure actNewCreditExecute(Sender: TObject);
    procedure actDeleteCreditExecute(Sender: TObject);
    procedure actDeleteDebitUpdate(Sender: TObject);
    procedure actDeleteCreditUpdate(Sender: TObject);
    procedure pgcMainChanging(Sender: TObject; var AllowChange: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    FNumerator: Integer;
    ChangedControl: String;
    procedure SaveAnalytic(W: TWinControl);

    function DeleteEnable(Sb: TWinControl): Boolean;
    procedure OnLineChange(Sender: TObject);
    procedure SetCurrRate(W: TWinControl; CurrKey: Integer; Rate: Currency);
  protected
    function DlgModified: Boolean; override;
    function TestCorrect: Boolean; override;
    procedure Post; override;
  public
    procedure SetupRecord; override;
    procedure SetupDialog; override;
  end;

var
  gdc_acct_dlgEntry: Tgdc_acct_dlgEntry;

implementation

{$R *.DFM}

uses
  Storages, gd_ClassList, gd_KeyAssoc, gd_security;

type
  TQuantityEdit = class(TEdit)
  public
    procedure KeyPress(var Key: Char); override;
  end;


{ Tgdc_acct_dlgEntry }

function Tgdc_acct_dlgEntry.DlgModified: Boolean;
begin
  Result := inherited DlgModified;
end;



procedure Tgdc_acct_dlgEntry.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  var
    I: Integer;
    L: TfrAcctEntrySimpleLine;
    gdcAcctEntryLine: TgdcAcctEntryLine;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_ACCT_DLGENTRY', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_ACCT_DLGENTRY', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_ACCT_DLGENTRY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_ACCT_DLGENTRY',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_ACCT_DLGENTRY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if gdcObject.State = dsInsert then
  begin
    for I := sboxDebit.ControlCount - 1 downto 0 do
      if sboxDebit.Controls[I] is TfrAcctEntrySimpleLine then
        sboxDebit.Controls[I].Free;
    for I := sboxCredit.ControlCount - 1 downto 0 do
      if sboxCredit.Controls[I] is TfrAcctEntrySimpleLine then
        sboxCredit.Controls[I].Free;

    with gdcObject as TgdcAcctComplexRecord do
    begin
      if EntryLines.Count = 0 then
      begin
        gdcAcctEntryLine := AppendLine;
        gdcAcctEntryLine.Edit;
        gdcAcctEntryLine.FieldByName('accountpart').AsString := 'D';

        gdcAcctEntryLine := AppendLine;
        gdcAcctEntryLine.Edit;
        gdcAcctEntryLine.FieldByName('accountpart').AsString := 'C';
      end;
    end;
  end;

  if gdcObject is TgdcAcctComplexRecord then
  begin
    with gdcObject as TgdcAcctComplexRecord do
    begin
      for I := 0 to EntryLines.Count - 1 do
      begin
        Inc(FNumerator);
        L := TfrAcctEntrySimpleLine.Create(Self);
        L.Name := Format('frAcctEntrySimpleLine_%d', [FNumerator]);

        if EntryLines[I].FieldByName('accountpart').AsString = 'D' then
        begin
          L.Parent := sboxDebit
        end else
        begin
          L.Parent := sboxCredit
        end;
        L.gdcObject := gdcObject;
        L.DataSet := EntryLines[I];

        L.LoadAnalytic;
        L.OnChange := OnLineChange;
      end;
    end;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_ACCT_DLGENTRY', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_ACCT_DLGENTRY', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_acct_dlgEntry.SetupDialog;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_ACCT_DLGENTRY', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_ACCT_DLGENTRY', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_ACCT_DLGENTRY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_ACCT_DLGENTRY',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_ACCT_DLGENTRY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if gdcObject.Owner is TgdcBase then
    if (gdcObject.Owner as TgdcBase).Active then
      pTransaction.Visible := False;
  ActivateTransaction(gdcObject.Transaction);
//  SetupEntry;
  inherited;
//  ActivateTransaction(gdcObject.Transaction);
  if gdcObject.State = dsInsert then
    Caption := 'Добавление хозяйственной операции'
  else
    Caption := 'Редактирование хозяйственной операции';

//  SetupEntry;

{  gdcObject.FieldByName('debitncu').OnChange := DoAmountFieldChange;
  dsDebitLine.DataSet.FieldByName('debitcurr').OnChange := DoAmountFieldChange;
  dsCreditLine.DataSet.FieldByName('creditcurr').OnChange := DoAmountFieldChange;

  if dsDebitLine.DataSet.FieldByName('debitcurr').AsCurrency <> 0 then
    ceRate.Value := gdcObject.FieldByName('debitncu').AsCurrency /
      dsDebitLine.DataSet.FieldByName('debitcurr').AsCurrency;
  if dsCreditLine.DataSet.FieldByName('creditcurr').AsCurrency <> 0 then
    ceCreditRate.Value := gdcObject.FieldByName('debitncu').AsCurrency /
      dsCreditLine.DataSet.FieldByName('creditcurr').AsCurrency;}

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_ACCT_DLGENTRY', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_ACCT_DLGENTRY', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

function Tgdc_acct_dlgEntry.TestCorrect: Boolean;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  ibsql: TIBSQL;
  isOffBalance: Boolean;
  i, k, D, C: Integer;
{  F: TField;}
  DebitNcu, CreditNcu: Currency;
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_ACCT_DLGENTRY', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_ACCT_DLGENTRY', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_ACCT_DLGENTRY') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_ACCT_DLGENTRY',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_ACCT_DLGENTRY' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  Result := inherited TestCorrect;
  if Result then
  begin
    D := 0;
    C := 0;
    with gdcObject as TgdcAcctComplexRecord do
    begin
      for I := 0 to EntryLines.Count - 1 do
      begin
        if EntryLines[I].FieldByName('accountkey').AsInteger > 0 then
        begin
          if EntryLines[I].FieldByName('accountpart').AsString = 'D' then
          begin
            Inc(D);
          end else
          begin
            Inc(C);
          end;
        end;
      end;

      if (D > 1) and (C > 1) then
      begin
        MessageDlg(
          'Количество позиций проводки по дебету и по кредету'#13#10 +
          'не может быть одновременно больше 1.'#13#10 +
          'Удалите не нужные позиции.', mtError, [mbOK], -1 );
        Result := False;
        Exit;
      end;
    end;

    ibsql := TIBSQL.Create(nil);
    try
      ibsql.Transaction := gdcObject.ReadTransaction;
      ibsql.SQL.Text := 'SELECT offbalance FROM ac_account WHERE id = :id';
      isOffBalance := False;
      for I := 0 to TgdcAcctComplexRecord(gdcObject).EntryLines.Count - 1 do
      begin
        with gdcObject as TgdcAcctComplexRecord do
        begin
          ibsql.Close;
          ibsql.ParamByName('id').AsInteger := EntryLines[I].FieldByName('accountkey').AsInteger;
          ibsql.ExecQuery;

          if ibsql.RecordCount > 0 then
          begin
            isOffBalance := ibsql.FieldByName('offbalance').AsInteger = 1
          end else
            isOffBalance := False;
          if isOffbalance then
            Break;
        end;
      end;
      if isOffBalance then
      begin
{        with gdcObject as TgdcAcctComplexRecord do
        begin
          k := 0;
          F := nil;
          for I := 0 to EntryLines.Count - 1 do
          begin
            if EntryLines[i].FieldByName('accountkey').AsInteger > 0 then
            begin
             if F = nil then
              F := EntryLines[i].FieldByName('accountkey');
             Inc(k);
            end;
          end;

          if k > 1 then
          begin
            MessageDlg('Забалансовый счет не может быть в корреспонденции с другими счетами'#13#10 +
              'и входить в состав сложной проводки.', mtError, [mbOK], -1);
            if F <> nil then
              F.FocusControl;

            Result := False;
            Exit;
          end;
        end; }
      end else
      begin
        k := 0;
        DebitNcu := 0;
        CreditNcu := 0;
        with gdcObject as TgdcAcctComplexRecord do
        begin
          for I := 0 to EntryLines.Count - 1 do
          begin
            if EntryLines[I].FieldByName('accountkey').AsInteger > 0 then
            begin
              Inc(k);
              if EntryLines[I].FieldByName('accountpart').AsString = 'D' then
              begin
                DebitNcu := DebitNcu + EntryLines[I].FieldByName('debitncu').AsCurrency
              end else
              begin
                CreditNcu := CreditNcu + EntryLines[I].FieldByName('creditncu').AsCurrency;
              end;
            end;
          end;
        end;
        if k = 0 then
        begin
          MessageDlg('Необходимо указать хотя бы один счет.', mtError, [mbOK], -1 );
          Result := false;
          Exit;
        end else
        begin
          with gdcObject as TgdcAcctComplexRecord do
          begin
            for I := 0 to EntryLines.Count - 1 do
            begin
              if EntryLines[I].FieldByName('accountkey').AsInteger = 0 then
              begin
                MessageDlg('Необходимо указать счет.', mtError, [mbOK], -1 );
                EntryLines[I].FieldByName('accountkey').FocusControl;
                Result := False;
                Exit;
              end;
            end;
          end;

          if DebitNcu <> CreditNcu then
          begin
            with gdcObject as TgdcAcctComplexRecord do
            begin
              for I := 0 to EntryLines.Count - 1 do
              begin
                if EntryLines[I].FieldByName('accountkey').AsInteger > 0 then
                begin
                  if ((D > 1) or ((D = 1) and (C = 1)))and (DebitNcu > 0) and (CreditNcu = 0) and (EntryLines[I].FieldByName('accountpart').AsString = 'C') then
                  begin
                    if not (EntryLines[I].State in [dsInsert, dsEdit]) then
                      EntryLines[I].Edit;

                    EntryLines[I].FieldByName('creditncu').AsCurrency := DebitNcu
                  end else
                  if ((C > 1) or ((C = 1) and (D = 1))) and (CreditNcu > 0) and (debitNcu = 0) and (EntryLines[I].FieldByName('accountpart').AsString = 'D') then
                  begin
                    if not (EntryLines[I].State in [dsInsert, dsEdit]) then
                      EntryLines[I].Edit;

                    EntryLines[I].FieldByName('debitncu').AsCurrency := CreditNcu
                  end else
                end;
              end;
            end;

            DebitNcu := 0;
            CreditNcu := 0;

            with gdcObject as TgdcAcctComplexRecord do
            begin
              for I := 0 to EntryLines.Count - 1 do
              begin
                if EntryLines[I].FieldByName('accountkey').AsInteger > 0 then
                begin
                  if EntryLines[I].FieldByName('accountpart').AsString = 'D' then
                  begin
                    DebitNcu := DebitNcu + EntryLines[I].FieldByName('debitncu').AsCurrency
                  end else
                  begin
                    CreditNcu := CreditNcu + EntryLines[I].FieldByName('creditncu').AsCurrency;
                  end;
                end;
              end;
            end;

            if DebitNcu <> CreditNcu  then
            begin
              MessageDlg('Сумма по дебету не равна сумме по кредиту.', mtError, [mbOK], -1 );
              Result := False;
              Exit;
            end;
          end;
        end;
      end;
    finally
      ibsql.Free;
    end;

  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_ACCT_DLGENTRY', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_ACCT_DLGENTRY', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;



procedure Tgdc_acct_dlgEntry.Post;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}

  procedure DeleteUnnecessaryLine(C: TWinControl);
  var
    I: Integer;
    l: TfrAcctEntrySimpleLine;
    Id: Integer;
  begin
    for I := C.ControlCount - 1 downto 0 do
    begin
      if C.Controls[I] is TfrAcctEntrySimpleLine then
      begin
        L := TfrAcctEntrySimpleLine(C.Controls[I]);
        if (L.DataSet <> nil) and (L.DataSet.FieldByName('accountkey').AsInteger = 0) then
        begin
          L.DisableControls;
          id := L.DataSet.FieldByName('id').AsInteger;
          (gdcObject as TgdcAcctComplexRecord).DeleteLine(id);
          L.Free;
        end;
      end;
    end;
  end;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_ACCT_DLGENTRY', 'POST', KEYPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_ACCT_DLGENTRY', KEYPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_ACCT_DLGENTRY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_ACCT_DLGENTRY',
  {M}          'POST', KEYPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_ACCT_DLGENTRY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
//     SaveQuantity;
   DeleteUnnecessaryLine(sboxDebit);
   DeleteUnnecessaryLine(sboxCredit);
   SaveAnalytic(sboxDebit);
   SaveAnalytic(sboxCredit);
   Inherited;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_ACCT_DLGENTRY', 'POST', KEYPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_ACCT_DLGENTRY', 'POST', KEYPOST);
  {M}end;
  {END MACRO}
end;

function Tgdc_acct_dlgEntry.DeleteEnable(Sb: TWinControl): Boolean;
var
  I: Integer;
  B: Boolean;
begin
  B := False;
  for I := 0 to Sb.ControlCount - 1 do
  begin
    if Sb.Controls[I] is TfrAcctEntrySimpleLine then
    begin
      B := TfrAcctEntrySimpleLine(Sb.Controls[I]).IsFocused and (TfrAcctEntrySimpleLine(Sb.Controls[I]).gdcObject.State = dsInsert);
      if B then Break;
    end;
  end;

  Result := B and (Sb.ControlCount > 1);
end;

procedure Tgdc_acct_dlgEntry.SaveAnalytic(W: TWinControl);
var
  I: Integer;
  L: TfrAcctEntrySimpleLine;
begin
  for I := 0 to W.ControlCount - 1 do
  begin
    if W.Controls[I] is TfrAcctEntrySimpleLine then
    begin
      L := W.Controls[i] as TfrAcctEntrySimpleLine;
      L.SaveAnalytic;
    end;
  end;
end;

procedure Tgdc_acct_dlgEntry.OnLineChange(Sender: TObject);
var
  CE: TxDBCalculatorEdit;
  DataSet: TDataSet;
  AccountPart: string;
  I: Integer;
  CorrCount: Integer;
  Sum: Currency;
  CurrKey: Integer;
  CorrFieldName, FieldName: string;
begin
  if ModalResult <> 0 then exit;

  if Sender is TControl then
  begin
    if (Sender as TControl).Name = 'cRate' then
    begin
      if ((Sender as TControl).Owner as TControl).Parent.Name = 'sboxDebit' then
        SetCurrRate(sboxCredit, ((Sender as TControl).Owner.FindComponent('cbCurrency') as TgsIBLookupComboBox).CurrentKeyInt,
          (Sender as TxCalculatorEdit).Value)
      else
        SetCurrRate(sboxDebit, ((Sender as TControl).Owner.FindComponent('cbCurrency') as TgsIBLookupComboBox).CurrentKeyInt,
          (Sender as TxCalculatorEdit).Value);
    end;
  end;  
  //Изменяем сумму корреспондирующей части
  if (Sender is TxDBCalculatorEdit) then
  begin

    if ChangedControl = '' then
      ChangedControl := (Sender as TControl).Name;

    try
      if ChangedControl <> (Sender as TControl).Name then
        exit;
      CE := TxDBCalculatorEdit(Sender);
      if (CE.Name = 'cSum') or (CE.Name = 'cCurrSum') then
      begin
        DataSet := CE.DataSource.DataSet;
        if DataSet = nil then Exit;
        AccountPart := DataSet.FieldByName('accountpart').AsString;
        with gdcObject as TgdcAcctComplexRecord do
        begin
          CorrCount := 0;
          Sum := 0;
          if AccountPart = 'D' then
          begin
            if CE.Name = 'cSum' then
            begin
              FieldName := 'debitncu';
              CorrFieldName := 'creditncu';
            end
            else
            begin
              FieldName := 'debitcurr';
              CorrFieldName := 'creditcurr';
            end;
          end else
          begin
            if CE.Name = 'cSum' then
            begin
              CorrFieldName := 'debitncu';
              FieldName := 'creditncu';
            end
            else
            begin
              CorrFieldName := 'debitcurr';
              FieldName := 'creditcurr';
            end;
          end;

          CurrKey := -1;
          if CE.Name = 'cCurrSum' then
          begin
            for I := 0 to EntryLines.Count - 1 do
              CurrKey := EntryLines[i].FieldByName('currkey').AsInteger;
          end;

          for I := 0 to EntryLines.Count - 1 do
          begin
            if EntryLines[I].FieldByName('accountpart').AsString = AccountPart then
            begin
              if ((CurrKey = -1) and (CE.Name <> 'cCurrSum')) or (CurrKey = EntryLines[i].FieldByName('currkey').AsInteger) then
              begin
                if EntryLines[i] <> DataSet then
                  Sum := Sum + EntryLines[i].FieldByName(FieldName).AsCurrency
                else
                  Sum := Sum + CE.Value;
              end;
            end else
            begin
              Inc(CorrCount);
            end;
          end;

          if CorrCount = 1 then
          begin
            if (CE.Name = 'cSum') or (CurrKey <> -1) then
            begin
              for I := 0 to EntryLines.Count - 1 do
              begin
                if EntryLines[i].FieldByName('accountpart').AsString <> AccountPart then
                begin
                  if not (EntryLines[I].State in [dsEdit, dsInsert]) then EntryLines[I].Edit; 
{                  begin}
                    if EntryLines[I].FieldByName(CorrFieldName).AsCurrency <> Sum then
                    begin
                      if Sum = 0 then
                         EntryLines[I].FieldByName(CorrFieldName).Clear
                      else
                        if EntryLines[i] <> DataSet then
                          EntryLines[I].FieldByName(CorrFieldName).AsCurrency := Sum;
{                    end}
                  end
                end;
              end;
            end;
          end;
        end;
      end;
    finally
      if ChangedControl = (Sender as TControl).Name then
        ChangedControl := '';
    end;
  end;
end;


procedure Tgdc_acct_dlgEntry.SetCurrRate(W: TWinControl; CurrKey: Integer; Rate: Currency);
var
  I: Integer;
  L: TfrAcctEntrySimpleLine;
begin
  for I := 0 to W.ControlCount - 1 do
  begin
    if W.Controls[I] is TfrAcctEntrySimpleLine then
    begin
      L := W.Controls[i] as TfrAcctEntrySimpleLine;
      L.SetCurrRate(CurrKey, Rate);
    end;
  end;
end;

{ TQuantityEdit }

procedure TQuantityEdit.KeyPress(var Key: Char);
begin
 if Key = Chr(VK_RETURN) then
 begin
   Exit;
 end;
 if (not (Key in [DecimalSeparator, '0'..'9'])) and (Ord(Key) > $39) then
// if (not (Key in [DecimalSeparator, '0'..'9']) or (Ord(Key) > $39)) then
   Key := #0;

 inherited KeyPress(Key);
end;

procedure Tgdc_acct_dlgEntry.actNewDebitExecute(Sender: TObject);
var
  EntryLine: TgdcAcctEntryLine;
  L: TfrAcctEntrySimpleLine;
begin
  EntryLine := (gdcObject as TgdcAcctComplexRecord).AppendLine;
  if EntryLine <> nil then
  begin
    Inc(FNumerator);
    L := TfrAcctEntrySimpleLine.Create(Self);
    L.Name := Format('frAcctEntrySimpleLine_%d', [FNumerator]);
    L.Parent := sboxDebit;

    EntryLine.Edit;
    EntryLine.FieldByName('accountpart').AsString := 'D';
    L.gdcObject := gdcObject;
    L.DataSet := EntryLine;
    L.cbAccount.SetFocus;
    L.OnChange := OnLineChange;

    UpdateTabOrder(sboxDebit);
  end;
end;

procedure Tgdc_acct_dlgEntry.actDeleteDebitExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to sboxdebit.ControlCount - 1 do
  begin
    if sboxDebit.Controls[I] is TfrAcctEntrySimpleLine then
    begin
      if TfrAcctEntrySimpleLine(sboxDebit.Controls[I]).IsFocused then
      begin
        if (gdcObject as TgdcAcctComplexRecord).DeleteLine(TfrAcctEntrySimpleLine(sboxDebit.Controls[I]).Id) then
        begin
          TfrAcctEntrySimpleLine(sboxDebit.Controls[I]).Free;
          UpdateTabOrder(sboxDebit);
          Exit;
        end;
      end;
    end;
  end;
end;

procedure Tgdc_acct_dlgEntry.actNewCreditExecute(Sender: TObject);
var
  EntryLine: TgdcAcctEntryLine;
  L: TfrAcctEntrySimpleLine;
begin
  EntryLine := (gdcObject as TgdcAcctComplexRecord).AppendLine;
  if EntryLine <> nil then
  begin
    Inc(FNumerator);
    L := TfrAcctEntrySimpleLine.Create(Self);
    L.Name := Format('frAcctEntrySimpleLine_%d', [FNumerator]);
    L.Parent := sboxCredit;

    EntryLine.Edit;
    EntryLine.FieldByName('accountpart').AsString := 'C';
    L.gdcObject := gdcObject;
    L.DataSet := EntryLine;
    L.cbAccount.SetFocus;
    L.OnChange := OnLineChange;

    UpdateTabOrder(sboxCredit);
  end;
end;

procedure Tgdc_acct_dlgEntry.actDeleteCreditExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to sboxCredit.ControlCount - 1 do
  begin
    if sboxCredit.Controls[I] is TfrAcctEntrySimpleLine then
    begin
      if TfrAcctEntrySimpleLine(sboxCredit.Controls[I]).IsFocused then
      begin
        if (gdcObject as TgdcAcctComplexRecord).DeleteLine(TfrAcctEntrySimpleLine(sboxCredit.Controls[I]).Id) then
        begin
          sboxCredit.Controls[I].Free;
          UpdateTabOrder(sboxCredit);
          Exit;
        end;
      end;
    end;
  end;
end;

procedure Tgdc_acct_dlgEntry.actDeleteDebitUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled :=  DeleteEnable(sboxDebit);
end;

procedure Tgdc_acct_dlgEntry.actDeleteCreditUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled :=  DeleteEnable(sboxCredit);
end;

procedure Tgdc_acct_dlgEntry.pgcMainChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  inherited;
  AllowChange := True
end;

procedure Tgdc_acct_dlgEntry.FormCreate(Sender: TObject);
begin
  inherited;
  ChangedControl := '';
  Assert(IBLogin <> nil);
  pnlHolding.Enabled := IBLogin.IsHolding;
  if pnlHolding.Enabled then
  begin
    iblkCompany.Condition := 'gd_contact.id IN (' + IBLogin.HoldingList + ')';
  end;
end;

initialization
  RegisterFrmClass(Tgdc_acct_dlgEntry);

finalization
  UnRegisterFrmClass(Tgdc_acct_dlgEntry);


end.
