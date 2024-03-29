// ShlTanya, 09.03.2019

unit gdc_acct_dlgEntry_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTR_unit, IBDatabase, Menus, Db, ActnList, StdCtrls, Mask, DBCtrls,
  gsIBLookupComboBox, Grids, DBGrids, gsDBGrid, gsIBGrid, xDateEdits,
  IBCustomDataSet, gdcBase, gdcAcctEntryRegister, gdcAcctTransaction,
  xCalculatorEdit, ExtCtrls, at_classes, IBSQL, gdc_dlgTRPC_unit,
  at_Container, ComCtrls, xCalc, TB2Dock, TB2Toolbar, gdvParamPanel,
  TB2Item, frAcctEntrySimpleLine_unit, AcctUtils, gdcBaseInterface;

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
    tbDebit: TTBToolbar;
    TBItem3: TTBItem;
    TBItem2: TTBItem;
    sboxDebit: TgdvParamScrolBox;
    Panel6: TPanel;
    Panel7: TPanel;
    TBDock2: TTBDock;
    tbCredit: TTBToolbar;
    TBItem4: TTBItem;
    TBItem1: TTBItem;
    sboxCredit: TgdvParamScrolBox;
    pnlHolding: TPanel;
    lblCompany: TLabel;
    iblkCompany: TgsIBLookupComboBox;
    pTransaction: TPanel;
    Label1: TLabel;
    iblcTransaction: TgsIBLookupComboBox;
    TBItem5: TTBItem;
    actDupDebit: TAction;
    actDupCredit: TAction;
    TBItem6: TTBItem;

    procedure actNewDebitExecute(Sender: TObject);
    procedure actDeleteDebitExecute(Sender: TObject);
    procedure actNewCreditExecute(Sender: TObject);
    procedure actDeleteCreditExecute(Sender: TObject);
    procedure actDeleteDebitUpdate(Sender: TObject);
    procedure actDeleteCreditUpdate(Sender: TObject);
    procedure pgcMainChanging(Sender: TObject; var AllowChange: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure actDupDebitExecute(Sender: TObject);
    procedure actDupDebitUpdate(Sender: TObject);
    procedure actDupCreditExecute(Sender: TObject);
    procedure actDupCreditUpdate(Sender: TObject);
    procedure sboxDebitMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure sboxCreditMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);

  private
    FNumerator: Integer;
    ChangedControl: String;

    procedure SaveAnalytic(W: TWinControl);

    function DeleteEnable(Sb: TWinControl): Boolean;
    procedure OnLineChange(Sender: TObject);
    procedure SetCurrRate(W: TWinControl; CurrKey: TID; Rate: Double);

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

  for I := sboxDebit.ControlCount - 1 downto 0 do
    if sboxDebit.Controls[I] is TfrAcctEntrySimpleLine then
      sboxDebit.Controls[I].Free;

  for I := sboxCredit.ControlCount - 1 downto 0 do
    if sboxCredit.Controls[I] is TfrAcctEntrySimpleLine then
      sboxCredit.Controls[I].Free;

  FNumerator := 0;    

  inherited;

  if gdcObject.State = dsInsert then
  begin
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
          L.Parent := sboxDebit
        else
          L.Parent := sboxCredit;

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
  inherited;
  if gdcObject.State = dsInsert then
    Caption := '���������� ������������� ��������'
  else
    Caption := '�������������� ������������� ��������';

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
        if GetTID(EntryLines[I].FieldByName('accountkey')) > 0 then
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
          '���������� ������� �������� �� ������ � �� �������'#13#10 +
          '�� ����� ���� ������������ ������ 1.'#13#10 +
          '������� �� ������ �������.', mtError, [mbOK], -1 );
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
          SetTID(ibsql.ParamByName('id'), EntryLines[I].FieldByName('accountkey'));
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
            MessageDlg('������������ ���� �� ����� ���� � ��������������� � ������� �������'#13#10 +
              '� ������� � ������ ������� ��������.', mtError, [mbOK], -1);
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
            if GetTID(EntryLines[I].FieldByName('accountkey')) > 0 then
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
          MessageDlg('���������� ������� ���� �� ���� ����.', mtError, [mbOK], -1 );
          Result := false;
          Exit;
        end else
        begin
          with gdcObject as TgdcAcctComplexRecord do
          begin
            for I := 0 to EntryLines.Count - 1 do
            begin
              if GetTID(EntryLines[I].FieldByName('accountkey')) = 0 then
              begin
                MessageDlg('���������� ������� ����.', mtError, [mbOK], -1 );
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
                if GetTID(EntryLines[I].FieldByName('accountkey')) > 0 then
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
                if GetTID(EntryLines[I].FieldByName('accountkey')) > 0 then
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
              MessageDlg('����� �� ������ �� ����� ����� �� �������.', mtError, [mbOK], -1 );
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
    Id: TID;
  begin
    for I := C.ControlCount - 1 downto 0 do
    begin
      if C.Controls[I] is TfrAcctEntrySimpleLine then
      begin
        L := TfrAcctEntrySimpleLine(C.Controls[I]);
        if (L.DataSet <> nil) and (GetTID(L.DataSet.FieldByName('accountkey')) = 0) then
        begin
          L.DisableControls;
          id := GetTID(L.DataSet.FieldByName('id'));
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
  F: TfrAcctEntrySimpleLine;
begin
  B := False;

  for I := 0 to Sb.ControlCount - 1 do
  begin
    if Sb.Controls[I] is TfrAcctEntrySimpleLine then
    begin
      F := Sb.Controls[I] as TfrAcctEntrySimpleLine;
      if F.IsFocused and ((F.gdcObject.State = dsInsert)
        or ((F.Sum = 0) and (F.CurrSum = 0))) then
      begin
        B := True;
        Break;
      end;
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
  CurrKey: TID;
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
  //�������� ����� ����������������� �����
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
              CurrKey := -1;
              FieldName := 'debitncu';
              CorrFieldName := 'creditncu';
            end
            else
            begin
              CurrKey := GetTID(DataSet.FieldByName('currkey'));
              FieldName := 'debitcurr';
              CorrFieldName := 'creditcurr';
            end;
          end else
          begin
            if CE.Name = 'cSum' then
            begin
              CurrKey := -1;
              CorrFieldName := 'debitncu';
              FieldName := 'creditncu';
            end
            else
            begin
              CurrKey := GettID(DataSet.FieldByName('currkey'));
              CorrFieldName := 'debitcurr';
              FieldName := 'creditcurr';
            end;
          end;

          for I := 0 to EntryLines.Count - 1 do
          begin
            if EntryLines[I].FieldByName('accountpart').AsString = AccountPart then
            begin
              if ((CurrKey = -1) and (CE.Name <> 'cCurrSum')) or (CurrKey = GetTID(EntryLines[i].FieldByName('currkey'))) then
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
                if (EntryLines[i].FieldByName('accountpart').AsString <> AccountPart)
                  and ((CurrKey = GetTID(EntryLines[i].FieldByName('currkey'))) or (CE.Name = 'cSum')) then
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


procedure Tgdc_acct_dlgEntry.SetCurrRate(W: TWinControl; CurrKey: TID; Rate: Double);
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
  Temp: Integer;
begin
  EntryLine := (gdcObject as TgdcAcctComplexRecord).AppendLine;
  if EntryLine <> nil then
  begin
    Inc(FNumerator);
    L := TfrAcctEntrySimpleLine.Create(Self);
    L.Name := Format('frAcctEntrySimpleLine_%d', [FNumerator]);

    if sboxDebit.ControlCount > 0 then
      Temp := sboxDebit.Controls[sboxDebit.ControlCount - 1].Height + sboxDebit.Controls[sboxDebit.ControlCount - 1].Top
    else
      Temp := 0;

    L.Parent := sboxDebit;
    L.Top := Temp;

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
  Temp: Integer;
begin
  EntryLine := (gdcObject as TgdcAcctComplexRecord).AppendLine;
  if EntryLine <> nil then
  begin
    Inc(FNumerator);
    L := TfrAcctEntrySimpleLine.Create(Self);
    L.Name := Format('frAcctEntrySimpleLine_%d', [FNumerator]);

    if sboxCredit.ControlCount > 0 then
      Temp := sboxCredit.Controls[sboxCredit.ControlCount - 1].Height + sboxCredit.Controls[sboxCredit.ControlCount - 1].Top
    else
      Temp := 0;

    L.Parent := sboxCredit;
    L.Top := Temp;

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

procedure Tgdc_acct_dlgEntry.actDupDebitExecute(Sender: TObject);
var
  EntryLine: TgdcAcctEntryLine;
  L: TfrAcctEntrySimpleLine;
  I, Temp: Integer;
begin
  for I := 0 to sboxDebit.ControlCount - 1 do
  begin
    if sboxDebit.Controls[I] is TfrAcctEntrySimpleLine then
    begin
      if TfrAcctEntrySimpleLine(sboxDebit.Controls[I]).IsFocused then
      begin
        EntryLine := (gdcObject as TgdcAcctComplexRecord).AppendLine;
        if EntryLine <> nil then
        begin
          Inc(FNumerator);
          L := TfrAcctEntrySimpleLine.Create(Self);
          L.Name := Format('frAcctEntrySimpleLine_%d', [FNumerator]);

          if sboxDebit.ControlCount > 0 then
            Temp := sboxDebit.Controls[sboxDebit.ControlCount - 1].Height + sboxDebit.Controls[sboxDebit.ControlCount - 1].Top
          else
            Temp := 0;

          L.Parent := sboxDebit;
          L.Top := Temp;

          EntryLine.Edit;
          EntryLine.FieldByName('accountpart').AsString := 'D';
          L.gdcObject := gdcObject;
          L.DataSet := EntryLine;
          L.OnChange := OnLineChange;

          L.cbAccount.Text := TfrAcctEntrySimpleLine(sboxDebit.Controls[I]).cbAccount.Text;
          L.cSum.SetFocus;
          L.cSum.Value := TfrAcctEntrySimpleLine(sboxDebit.Controls[I]).cSum.Value;
          L.cbCurrency.Text := TfrAcctEntrySimpleLine(sboxDebit.Controls[I]).cbCurrency.Text;
          L.cRate.SetFocus;
          L.cRate.Value := TfrAcctEntrySimpleLine(sboxDebit.Controls[I]).cRate.Value;
          L.cCurrSum.SetFocus;
          L.cCurrSum.Value := TfrAcctEntrySimpleLine(sboxDebit.Controls[I]).cCurrSum.Value;
          L.cEQSum.SetFocus;
          L.cEQSum.Value := TfrAcctEntrySimpleLine(sboxDebit.Controls[I]).cEQSum.Value;
          L.cbRounded.Checked := TfrAcctEntrySimpleLine(sboxDebit.Controls[I]).cbRounded.Checked;
          L.cbAccount.SetFocus;
          L.cbCurrency.SetFocus;
          L.frAcctAnalytics.Values := TfrAcctEntrySimpleLine(sboxDebit.Controls[I]).frAcctAnalytics.Values;
          L.frQuantity.Values := TfrAcctEntrySimpleLine(sboxDebit.Controls[I]).frQuantity.Values;

          L.cbAccount.SetFocus;
          UpdateTabOrder(sboxDebit);
        end;
      end;
    end;
  end;
end;

procedure Tgdc_acct_dlgEntry.actDupDebitUpdate(Sender: TObject);
var
  I: Integer;
begin
  TAction(Sender).Enabled := False;
  for I := 0 to sboxDebit.ControlCount - 1 do
  begin
    if sboxDebit.Controls[I] is TfrAcctEntrySimpleLine then
    begin
      if TfrAcctEntrySimpleLine(sboxDebit.Controls[I]).IsFocused then
        TAction(Sender).Enabled := True;
    end;
  end;
end;

procedure Tgdc_acct_dlgEntry.actDupCreditExecute(Sender: TObject);
var
  EntryLine: TgdcAcctEntryLine;
  L: TfrAcctEntrySimpleLine;
  I, Temp: Integer;
begin
  for I := 0 to sboxCredit.ControlCount - 1 do
  begin
    if sboxCredit.Controls[I] is TfrAcctEntrySimpleLine then
    begin
      if TfrAcctEntrySimpleLine(sboxCredit.Controls[I]).IsFocused then
      begin
        EntryLine := (gdcObject as TgdcAcctComplexRecord).AppendLine;
        if EntryLine <> nil then
        begin
          Inc(FNumerator);
          L := TfrAcctEntrySimpleLine.Create(Self);
          L.Name := Format('frAcctEntrySimpleLine_%d', [FNumerator]);

          if sboxCredit.ControlCount > 0 then
            Temp := sboxCredit.Controls[sboxCredit.ControlCount - 1].Height + sboxCredit.Controls[sboxCredit.ControlCount - 1].Top
          else
            Temp := 0;

          L.Parent := sboxCredit;
          L.Top := Temp;

          EntryLine.Edit;
          EntryLine.FieldByName('accountpart').AsString := 'C';
          L.gdcObject := gdcObject;
          L.DataSet := EntryLine;
          L.OnChange := OnLineChange;

          L.cbAccount.Text := TfrAcctEntrySimpleLine(sboxCredit.Controls[I]).cbAccount.Text;
          L.cSum.SetFocus;
          L.cSum.Value := TfrAcctEntrySimpleLine(sboxCredit.Controls[I]).cSum.Value;
          L.cbCurrency.Text := TfrAcctEntrySimpleLine(sboxCredit.Controls[I]).cbCurrency.Text;
          L.cRate.SetFocus;
          L.cRate.Value := TfrAcctEntrySimpleLine(sboxCredit.Controls[I]).cRate.Value;
          L.cCurrSum.SetFocus;
          L.cCurrSum.Value := TfrAcctEntrySimpleLine(sboxCredit.Controls[I]).cCurrSum.Value;
          L.cEQSum.SetFocus;
          L.cEQSum.Value := TfrAcctEntrySimpleLine(sboxCredit.Controls[I]).cEQSum.Value;
          L.cbRounded.Checked := TfrAcctEntrySimpleLine(sboxCredit.Controls[I]).cbRounded.Checked;
          L.cbAccount.SetFocus;
          L.cbCurrency.SetFocus;
          L.frAcctAnalytics.Values := TfrAcctEntrySimpleLine(sboxCredit.Controls[I]).frAcctAnalytics.Values;
          L.frQuantity.Values := TfrAcctEntrySimpleLine(sboxCredit.Controls[I]).frQuantity.Values;

          L.cbAccount.SetFocus;
          UpdateTabOrder(sboxCredit);
        end;
      end;
    end;
  end;
end;

procedure Tgdc_acct_dlgEntry.actDupCreditUpdate(Sender: TObject);
var
  I: Integer;
begin
  TAction(Sender).Enabled := False;
  for I := 0 to sboxCredit.ControlCount - 1 do
  begin
    if sboxCredit.Controls[I] is TfrAcctEntrySimpleLine then
    begin
      if TfrAcctEntrySimpleLine(sboxCredit.Controls[I]).IsFocused then
        TAction(Sender).Enabled := True;
    end;
  end;
end;

procedure Tgdc_acct_dlgEntry.sboxDebitMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
begin
  inherited;
  if WheelDelta < 0 then WheelDelta := -10 else WheelDelta := 10;
  sboxDebit.VertScrollBar.Position := sboxDebit.VertScrollBar.Position - WheelDelta;
end;

procedure Tgdc_acct_dlgEntry.sboxCreditMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
begin
  inherited;
  if WheelDelta < 0 then WheelDelta := -10 else WheelDelta := 10;
  sboxCredit.VertScrollBar.Position := sboxCredit.VertScrollBar.Position - WheelDelta;
end;

initialization
  RegisterFrmClass(Tgdc_acct_dlgEntry);

finalization
  UnRegisterFrmClass(Tgdc_acct_dlgEntry);


end.
