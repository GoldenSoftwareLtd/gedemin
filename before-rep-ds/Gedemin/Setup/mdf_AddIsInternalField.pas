unit mdf_AddIsInternalField;

interface

uses
  IBDatabase, gdModify;

procedure AddIsInternalField(IBDB: TIBDatabase; Log: TModifyLog);

implementation

uses
  IBSQL, SysUtils, IBScript, classes, mdf_MetaData_unit;

const
  FieldCount = 1;
  Fields: array[0..FieldCount - 1] of TmdfField = (
    (RelationName: 'AC_TRANSACTION'; FieldName: 'ISINTERNAL'; Description:
      'DBOOLEAN')
  );

  ProcedureCount = 1;
  Procedures: array[0..ProcedureCount - 1] of TmdfStoredProcedure = (
    (ProcedureName: 'AC_CIRCULATIONLIST';
     Description:
       '( '#13#10 +
       '     DATEBEGIN DATE, '#13#10 +
       '     DATEEND DATE, '#13#10 +
       '     COMPANYKEY INTEGER, '#13#10 +
       '     ALLHOLDINGCOMPANIES INTEGER, '#13#10 +
       '     ACCOUNTKEY INTEGER, '#13#10 +
       '     INGROUP INTEGER, '#13#10 +
       '     CURRKEY INTEGER, '#13#10 +
       '     DONTINMOVE INTEGER) '#13#10 +
       ' RETURNS ( '#13#10 +
       '     ALIAS VARCHAR(20), '#13#10 +
       '     NAME VARCHAR(180), '#13#10 +
       '     ID INTEGER, '#13#10 +
       '     NCU_BEGIN_DEBIT NUMERIC(15,4), '#13#10 +
       '     NCU_BEGIN_CREDIT NUMERIC(15,4), '#13#10 +
       '     NCU_DEBIT NUMERIC(15,4), '#13#10 +
       '     NCU_CREDIT NUMERIC(15,4), '#13#10 +
       '     NCU_END_DEBIT NUMERIC(15,4), '#13#10 +
       '     NCU_END_CREDIT NUMERIC(15,4), '#13#10 +
       '     CURR_BEGIN_DEBIT NUMERIC(15,4), '#13#10 +
       '     CURR_BEGIN_CREDIT NUMERIC(15,4), '#13#10 +
       '     CURR_DEBIT NUMERIC(15,4), '#13#10 +
       '     CURR_CREDIT NUMERIC(15,4), '#13#10 +
       '     CURR_END_DEBIT NUMERIC(15,4), '#13#10 +
       '     CURR_END_CREDIT NUMERIC(15,4), '#13#10 +
       '     EQ_BEGIN_DEBIT NUMERIC(15,4), '#13#10 +
       '     EQ_BEGIN_CREDIT NUMERIC(15,4), '#13#10 +
       '     EQ_DEBIT NUMERIC(15,4), '#13#10 +
       '     EQ_CREDIT NUMERIC(15,4), '#13#10 +
       '     EQ_END_DEBIT NUMERIC(15,4), '#13#10 +
       '     EQ_END_CREDIT NUMERIC(15,4), '#13#10 +
       '     OFFBALANCE INTEGER) '#13#10 +
       ' AS '#13#10 +
       '   declare variable activity varchar(1); '#13#10 +
       '   declare variable saldo numeric(15,4); '#13#10 +
       '   declare variable saldocurr numeric(15,4); '#13#10 +
       '   declare variable saldoeq numeric(15,4); '#13#10 +
       '   declare variable fieldname varchar(60); '#13#10 +
       '   declare variable lb integer; '#13#10 +
       '   declare variable rb integer; '#13#10 +
       ' BEGIN '#13#10 +
       '   SELECT c.lb, c.rb FROM ac_account c '#13#10 +
       '   WHERE c.id = :ACCOUNTKEY '#13#10 +
       '   INTO :lb, :rb; '#13#10 +
       ' '#13#10 +
       '   FOR '#13#10 +
       '     SELECT a.ID, a.ALIAS, a.activity, f.fieldname, a.Name, a.offbalance '#13#10 +
       '     FROM ac_account a LEFT JOIN at_relation_fields f ON a.analyticalfield = f.id '#13#10 +
       '     WHERE '#13#10 +
       '       a.accounttype IN (''A'', ''S'') AND '#13#10 +
       '       a.LB >= :LB AND a.RB <= :RB AND a.alias <> ''00'' '#13#10 +
       '     INTO :id, :ALIAS, :activity, :fieldname, :name, :offbalance '#13#10 +
       '   DO '#13#10 +
       '   BEGIN '#13#10 +
       '     NCU_BEGIN_DEBIT = 0; '#13#10 +
       '     NCU_BEGIN_CREDIT = 0; '#13#10 +
       '     CURR_BEGIN_DEBIT = 0; '#13#10 +
       '     CURR_BEGIN_CREDIT = 0; '#13#10 +
       '     EQ_BEGIN_DEBIT = 0; '#13#10 +
       '     EQ_BEGIN_CREDIT = 0; '#13#10 +
       '  '#13#10 +
       '     IF ((activity <> ''B'') OR (fieldname IS NULL)) THEN '#13#10 +
       '     BEGIN '#13#10 +
       '       IF ( ALLHOLDINGCOMPANIES = 0) THEN '#13#10 +
       '       SELECT '#13#10 +
       '         SUM(e.DEBITNCU - e.CREDITNCU), '#13#10 +
       '         SUM(e.DEBITCURR - e.CREDITCURR), '#13#10 +
       '         SUM(e.DEBITEQ - e.CREDITEQ) '#13#10 +
       '       FROM '#13#10 +
       '         ac_entry e '#13#10 +
       '       WHERE '#13#10 +
       '         e.accountkey = :id AND e.entrydate < :datebegin AND '#13#10 +
       '         (e.companykey = :companykey) AND '#13#10 +
       '         ((0 = :currkey) OR (e.currkey = :currkey)) '#13#10 +
       '       INTO '#13#10 +
       '         :SALDO, :SALDOCURR, :SALDOEQ; '#13#10 +
       '       ELSE '#13#10 +
       '       SELECT '#13#10 +
       '         SUM(e.DEBITNCU - e.CREDITNCU), '#13#10 +
       '         SUM(e.DEBITCURR - e.CREDITCURR), '#13#10 +
       '         SUM(e.DEBITEQ - e.CREDITEQ) '#13#10 +
       '       FROM '#13#10 +
       '         ac_entry e '#13#10 +
       '       WHERE '#13#10 +
       '         e.accountkey = :id AND e.entrydate < :datebegin AND '#13#10 +
       '         (e.companykey = :companykey or e.companykey IN ( '#13#10 +
       '           SELECT '#13#10 +
       '             h.companykey '#13#10 +
       '           FROM '#13#10 +
       '             gd_holding h '#13#10 +
       '           WHERE '#13#10 +
       '             h.holdingkey = :companykey)) AND '#13#10 +
       '         ((0 = :currkey) OR (e.currkey = :currkey)) '#13#10 +
       '       INTO '#13#10 +
       '         :SALDO, :SALDOCURR, :SALDOEQ; '#13#10 +
       ' '#13#10 +
       '       IF (SALDO IS NULL) THEN '#13#10 +
       '         SALDO = 0; '#13#10 +
       '       IF (SALDOCURR IS NULL) THEN '#13#10 +
       '         SALDOCURR = 0; '#13#10 +
       '       IF (SALDOEQ IS NULL) THEN '#13#10 +
       '         SALDOEQ = 0; '#13#10 +
       ' '#13#10 +
       '       IF (SALDO > 0) THEN '#13#10 +
       '         NCU_BEGIN_DEBIT = SALDO; '#13#10 +
       '       ELSE '#13#10 +
       '         NCU_BEGIN_CREDIT = 0 - SALDO; '#13#10 +
       ' '#13#10 +
       '       IF (SALDOCURR > 0) THEN '#13#10 +
       '         CURR_BEGIN_DEBIT = SALDOCURR; '#13#10 +
       '       ELSE '#13#10 +
       '         CURR_BEGIN_CREDIT = 0 - SALDOCURR; '#13#10 +
       ' '#13#10 +
       '       IF (SALDOEQ > 0) THEN '#13#10 +
       '         EQ_BEGIN_DEBIT = SALDOEQ; '#13#10 +
       '       ELSE '#13#10 +
       '         EQ_BEGIN_CREDIT = 0 - SALDOEQ; '#13#10 +
       '     END '#13#10 +
       '     ELSE '#13#10 +
       '     BEGIN '#13#10 +
       '       SELECT '#13#10 +
       '         DEBITsaldo, '#13#10 +
       '         creditsaldo '#13#10 +
       '       FROM '#13#10 +
       '         AC_ACCOUNTEXSALDO(:datebegin, :ID, :FIELDNAME, :COMPANYKEY, '#13#10 +
       '           :allholdingcompanies, :INGROUP, :currkey) '#13#10 +
       '       INTO '#13#10 +
       '         :NCU_BEGIN_DEBIT, '#13#10 +
       '         :NCU_BEGIN_CREDIT; '#13#10 +
       '     END '#13#10 +
       '  '#13#10 +
       '     IF (ALLHOLDINGCOMPANIES = 0) THEN '#13#10 +
       '     BEGIN '#13#10 +
       '       IF (DONTINMOVE = 1) THEN '#13#10 +
       '         SELECT '#13#10 +
       '           SUM(e.DEBITNCU), '#13#10 +
       '           SUM(e.CREDITNCU), '#13#10 +
       '           SUM(e.DEBITCURR), '#13#10 +
       '           SUM(e.CREDITCURR), '#13#10 +
       '           SUM(e.DEBITEQ), '#13#10 +
       '           SUM(e.CREDITEQ) '#13#10 +
       '         FROM '#13#10 +
       '           ac_entry e '#13#10 +
       '         WHERE '#13#10 +
       '           e.accountkey = :id AND e.entrydate >= :datebegin AND '#13#10 +
       '           e.entrydate <= :dateend AND (e.companykey = :companykey) AND '#13#10 +
       '           ((0 = :currkey) OR (e.currkey = :currkey)) AND '#13#10 +
       '           NOT EXISTS(SELECT t.id FROM ac_transaction t WHERE t.id = e.transactionkey AND t.isinternal = 1) '#13#10 +
       '         INTO :NCU_DEBIT, :NCU_CREDIT, :CURR_DEBIT, CURR_CREDIT, :EQ_DEBIT, EQ_CREDIT; '#13#10 +
       '       ELSE '#13#10 +
       '         SELECT '#13#10 +
       '           SUM(e.DEBITNCU), '#13#10 +
       '           SUM(e.CREDITNCU), '#13#10 +
       '           SUM(e.DEBITCURR), '#13#10 +
       '           SUM(e.CREDITCURR), '#13#10 +
       '           SUM(e.DEBITEQ), '#13#10 +
       '           SUM(e.CREDITEQ) '#13#10 +
       '         FROM '#13#10 +
       '           ac_entry e '#13#10 +
       '         WHERE '#13#10 +
       '           e.accountkey = :id AND e.entrydate >= :datebegin AND '#13#10 +
       '           e.entrydate <= :dateend AND (e.companykey = :companykey) AND '#13#10 +
       '           ((0 = :currkey) OR (e.currkey = :currkey)) '#13#10 +
       '         INTO :NCU_DEBIT, :NCU_CREDIT, :CURR_DEBIT, CURR_CREDIT, :EQ_DEBIT, EQ_CREDIT; '#13#10 +
       '     END '#13#10 +
       '     ELSE '#13#10 +
       '     BEGIN '#13#10 +
       '       IF (DONTINMOVE = 1) THEN '#13#10 +
       '         SELECT '#13#10 +
       '           SUM(e.DEBITNCU), '#13#10 +
       '           SUM(e.CREDITNCU), '#13#10 +
       '           SUM(e.DEBITCURR), '#13#10 +
       '           SUM(e.CREDITCURR), '#13#10 +
       '           SUM(e.DEBITEQ), '#13#10 +
       '           SUM(e.CREDITEQ) '#13#10 +
       '         FROM '#13#10 +
       '           ac_entry e '#13#10 +
       '         WHERE '#13#10 +
       '           e.accountkey = :id AND e.entrydate >= :datebegin AND '#13#10 +
       '           e.entrydate <= :dateend AND '#13#10 +
       '           (e.companykey = :companykey or e.companykey IN ( '#13#10 +
       '           SELECT h.companykey FROM gd_holding h '#13#10 +
       '            WHERE h.holdingkey = :companykey)) AND '#13#10 +
       '           ((0 = :currkey) OR (e.currkey = :currkey)) AND '#13#10 +
       '           NOT EXISTS(SELECT t.id FROM ac_transaction t WHERE t.id = e.transactionkey AND t.isinternal = 1) '#13#10 +
       '         INTO :NCU_DEBIT, :NCU_CREDIT, :CURR_DEBIT, CURR_CREDIT, :EQ_DEBIT, :EQ_CREDIT; '#13#10 +
       '       ELSE '#13#10 +
       '         SELECT '#13#10 +
       '           SUM(e.DEBITNCU), '#13#10 +
       '           SUM(e.CREDITNCU), '#13#10 +
       '           SUM(e.DEBITCURR), '#13#10 +
       '           SUM(e.CREDITCURR), '#13#10 +
       '           SUM(e.DEBITEQ), '#13#10 +
       '           SUM(e.CREDITEQ) '#13#10 +
       '         FROM '#13#10 +
       '           ac_entry e '#13#10 +
       '         WHERE '#13#10 +
       '           e.accountkey = :id AND e.entrydate >= :datebegin AND '#13#10 +
       '           e.entrydate <= :dateend AND '#13#10 +
       '           (e.companykey = :companykey or e.companykey IN ( '#13#10 +
       '           SELECT h.companykey FROM gd_holding h '#13#10 +
       '            WHERE h.holdingkey = :companykey)) AND '#13#10 +
       '           ((0 = :currkey) OR (e.currkey = :currkey)) '#13#10 +
       '         INTO :NCU_DEBIT, :NCU_CREDIT, :CURR_DEBIT, CURR_CREDIT, :EQ_DEBIT, :EQ_CREDIT; '#13#10 +
       '     END '#13#10 +
       ' '#13#10 +
       '     IF (NCU_DEBIT IS NULL) THEN '#13#10 +
       '       NCU_DEBIT = 0; '#13#10 +
       '     IF (NCU_CREDIT IS NULL) THEN '#13#10 +
       '       NCU_CREDIT = 0; '#13#10 +
       '     IF (CURR_DEBIT IS NULL) THEN '#13#10 +
       '       CURR_DEBIT = 0; '#13#10 +
       '     IF (CURR_CREDIT IS NULL) THEN '#13#10 +
       '       CURR_CREDIT = 0; '#13#10 +
       '     IF (EQ_DEBIT IS NULL) THEN '#13#10 +
       '       EQ_DEBIT = 0; '#13#10 +
       '     IF (EQ_CREDIT IS NULL) THEN '#13#10 +
       '       EQ_CREDIT = 0; '#13#10 +
       ' '#13#10 +
       '     NCU_END_DEBIT = 0; '#13#10 +
       '     NCU_END_CREDIT = 0; '#13#10 +
       '     CURR_END_DEBIT = 0; '#13#10 +
       '     CURR_END_CREDIT = 0; '#13#10 +
       '     EQ_END_DEBIT = 0; '#13#10 +
       '     EQ_END_CREDIT = 0; '#13#10 +
       ' '#13#10 +
       '     IF ((ACTIVITY <> ''B'') OR (FIELDNAME IS NULL)) THEN '#13#10 +
       '     BEGIN '#13#10 +
       '       SALDO = NCU_BEGIN_DEBIT - NCU_BEGIN_CREDIT + NCU_DEBIT - NCU_CREDIT; '#13#10 +
       '       IF (SALDO > 0) THEN '#13#10 +
       '         NCU_END_DEBIT = SALDO; '#13#10 +
       '       ELSE '#13#10 +
       '         NCU_END_CREDIT = 0 - SALDO; '#13#10 +
       ' '#13#10 +
       '       SALDOCURR = CURR_BEGIN_DEBIT - CURR_BEGIN_CREDIT + CURR_DEBIT - CURR_CREDIT; '#13#10 +
       '       IF (SALDOCURR > 0) THEN '#13#10 +
       '         CURR_END_DEBIT = SALDOCURR; '#13#10 +
       '       ELSE '#13#10 +
       '         CURR_END_CREDIT = 0 - SALDOCURR; '#13#10 +
       ' '#13#10 +
       '       SALDOEQ = EQ_BEGIN_DEBIT - EQ_BEGIN_CREDIT + EQ_DEBIT - EQ_CREDIT; '#13#10 +
       '       IF (SALDOEQ > 0) THEN '#13#10 +
       '         EQ_END_DEBIT = SALDOEQ; '#13#10 +
       '       ELSE '#13#10 +
       '         EQ_END_CREDIT = 0 - SALDOEQ; '#13#10 +
       '     END '#13#10 +
       '     ELSE '#13#10 +
       '     BEGIN '#13#10 +
       '       IF ((NCU_BEGIN_DEBIT <> 0) OR (NCU_BEGIN_CREDIT <> 0) OR '#13#10 +
       '         (NCU_DEBIT <> 0) OR (NCU_CREDIT <> 0) OR '#13#10 +
       '         (CURR_BEGIN_DEBIT <> 0) OR (CURR_BEGIN_CREDIT <> 0) OR '#13#10 +
       '         (CURR_DEBIT <> 0) OR (CURR_CREDIT <> 0) OR '#13#10 +
       '         (EQ_BEGIN_DEBIT <> 0) OR (EQ_BEGIN_CREDIT <> 0) OR '#13#10 +
       '         (EQ_DEBIT <> 0) OR (EQ_CREDIT <> 0)) THEN '#13#10 +
       '       BEGIN '#13#10 +
       '         SELECT '#13#10 +
       '           debitsaldo, creditsaldo, '#13#10 +
       '           currdebitsaldo, currcreditsaldo, '#13#10 +
       '           eqdebitsaldo, eqcreditsaldo '#13#10 +
       '         FROM AC_ACCOUNTEXSALDO(:DATEEND + 1, :ID, :FIELDNAME, :COMPANYKEY, '#13#10 +
       '           :allholdingcompanies, :INGROUP, :currkey) '#13#10 +
       '         INTO :NCU_END_DEBIT, :NCU_END_CREDIT, :CURR_END_DEBIT, :CURR_END_CREDIT, :EQ_END_DEBIT, :EQ_END_CREDIT; '#13#10 +
       '       END '#13#10 +
       '     END '#13#10 +
       '     IF ((NCU_BEGIN_DEBIT <> 0) OR (NCU_BEGIN_CREDIT <> 0) OR '#13#10 +
       '       (NCU_DEBIT <> 0) OR (NCU_CREDIT <> 0) OR '#13#10 +
       '       (CURR_BEGIN_DEBIT <> 0) OR (CURR_BEGIN_CREDIT <> 0) OR '#13#10 +
       '       (CURR_DEBIT <> 0) OR (CURR_CREDIT <> 0) OR '#13#10 +
       '       (EQ_BEGIN_DEBIT <> 0) OR (EQ_BEGIN_CREDIT <> 0) OR '#13#10 +
       '       (EQ_DEBIT <> 0) OR (EQ_CREDIT <> 0)) THEN '#13#10 +
       '     SUSPEND; '#13#10 +
       '   END '#13#10 +
       ' END'));


procedure AddIsInternalField(IBDB: TIBDatabase; Log: TModifyLog);
var
  I: Integer;
  Tr: TIBTransaction;
  q: TIBSQL;
begin
  for I := 0 to FieldCount - 1 do
  begin
    if not FieldExist(Fields[i], IBDB) then
    begin
      Log(Format('Добавление поля %s в таблицу %s', [Fields[i].FieldName,
        Fields[I].RelationName]));
      try
        AddField(Fields[I], IBDB);
      except
        on E: Exception do
        begin
          Log(E.Message);
          raise;
        end;
      end;

      Log(Format('Изменение процедуры %s ', [Procedures[I].ProcedureName]));
      try
        AlterProcedure(Procedures[I], IBDB);
      except
        on E: Exception do
        begin
          Log(E.Message);
          raise;
        end;
      end;
    end;
  end;

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := IBDB;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q.SQl.Text :=
      'INSERT INTO fin_versioninfo ' +
      '  VALUES (111, ''0000.0001.0000.0143'', ''12.01.2009'', ''Добавлено поле ISINTERNAL в таблицу AC_TRANSACTION для определения внутренних проводок'') ';
    try
      q.ExecQuery;
    except
    end;
    q.Close;

    Tr.Commit;
  finally
    q.Free;
    Tr.Free;
  end;
end;

end.
