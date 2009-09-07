unit AcctStrings;

interface

resourcestring
  MSG_WARNING =
    'Внимание';
  MSG_ACCOUNTINCORRECT =
    'Счет %s не найден в активном плане счетов.';
  MSG_INPUTANGROUPANALYTIC =
    'Пожалуйста, укажите аналитику, по которой будет'#13#10 +
    'производиться группировка журнал-ордера.';
  MSG_CONFIGEXITS =
    'Конфигурация с именем "%s" уже существует.'#13#10 +
    'Перезаписать ее?';
  MSG_LARGESQL =
    'Превышен максимально возможный размер сформированного SQL запроса.'#13#10 +
    'Построение отчета невозможно.';
  MSG_ENTERDESCRIPTION =
    'Пожалуйста, заполните поле "Описание".';
  MSG_ENTERDOCUMENTTYPE =
    'Пожалуйста, заполните поле "По документу".';
  MSG_ENTERFUNCTIONKEY =
    'Пожалуйста, укажите функцию проводки.';
  MSG_NOACTIVEACCOUTN =
    'Для организации "%s" не установлен активный план счетов.'#13#10#13#10 +
    'Для установки активного плана счетов на главном окне программы, в выпадающем '#13#10 +
    'списке "Организация", нажмите кнопку F4 и на вкладке "План счетов", '#13#10 +
    'выберете план счетов и нажмите кнопку "Активный".';
  MSG_CHOOSECOMPANY =
    'Выберите организацию в поле "Компания" раздела "Компании холдинга".';

const
  ENTRYDATE = 'ENTRYDATE';
  MONTH = 'MONTH';

  EXTRACT_DAY = ' EXTRACT(DAY FROM %0:s) ';
  EXTRACT_MONTH = ' EXTRACT(MONTH FROM %0:s) ';
  EXTRACT_QUARTER = ' (EXTRACT(MONTH FROM %0:s) - 1) / 3 + 1 ';
  EXTRACT_YEAR = ' EXTRACT(YEAR FROM %0:s) ';

  AC_ENTRY = 'AC_ENTRY';
//params
  BeginDate = 'BEGINDATE';
  EndDate = 'ENDDATE';

  fnImageIndex = 'imageindex';
  fnFolder = 'folder';
  fnShowInExplorer = 'showinexplorer';
  fnName = 'name';
  fnConfig = 'config';
  fnClassName = 'classname';
  fnDescription = 'description';
  fndocumenttypekey = 'documenttypekey';
  fnFunctionKey = 'functionkey';

const
//Шаблоны запросов
  cInternalMovementClauseTemplate = ' AND NOT EXISTS('#13#10 +
    '    SELECT'#13#10 +
    '      e_m.id'#13#10 +
    '    FROM'#13#10+
    '      ac_entry e_m'#13#10 +
    '      JOIN ac_entry e_cm ON e_cm.recordkey = e_m.recordkey AND'#13#10 +
    '        e_cm.accountpart <> e_m.accountpart AND'#13#10 +
    '        e_cm.accountkey + 0 = e_m.accountkey AND'#13#10 +
    '        (e_m.debitncu = e_cm.creditncu AND '#13#10 +
    '        e_m.creditncu = e_cm.debitncu AND '#13#10 +
    '        e_m.debitcurr = e_cm.creditcurr AND'#13#10 +
    '        e_m.creditcurr = e_cm.debitcurr) ' +
    '    %s'#13#10 +
    '    WHERE'#13#10 +
    '      e_m.id = e.id)'#13#10;

  cInternalMovementClauseTemplateNew =
    ' AND NOT EXISTS( '#13#10 +
    '    SELECT '#13#10 +
    '      e_cm.id '#13#10 +
    '    FROM '#13#10+
    '      ac_entry e_cm '#13#10 +
    '    WHERE '#13#10 +
    '      e_cm.recordkey = %0:s.recordkey AND '#13#10 +
    '      e_cm.accountpart <> %0:s.accountpart AND '#13#10 +
    '      e_cm.accountkey + 0 = %0:s.accountkey AND '#13#10 +
    '        (%0:s.debitncu = e_cm.creditncu AND '#13#10 +
    '        %0:s.creditncu = e_cm.debitncu AND '#13#10 +
    '        %0:s.debitcurr = e_cm.creditcurr AND '#13#10 +
    '        %0:s.creditcurr = e_cm.debitcurr) ' +
    '    %1:s )'#13#10;

  cDebitCredit =
    'SELECT '#13#10 +
    '%s, '#13#10 +
    '%s' +
    '%s' +
    '  CAST(IIF(SUM(e2.debitncu) <> 0, SUM(e2.debitncu) / %d, 0) AS %s) AS NCU_DEBIT,'#13#10 +
    '%s' +
    '  CAST(IIF(SUM(e2.creditncu) <> 0, SUM(e2.creditncu) / %d, 0) AS %s) AS NCU_CREDIT , '#13#10 +
    '%s' +
    #13#10 +
    '%s' +
    '%s'#13#10 +
    '  CAST(IIF(SUM(e2.debitcurr) <> 0, SUM(e2.debitcurr) /%d, 0)  AS %s) AS CURR_DEBIT,'#13#10 +
    '%s'#13#10 +
    '  CAST(IIF(SUM(e2.creditcurr) <> 0, SUM(e2.creditcurr)/ %d, 0) AS %s) AS CURR_CREDIT, '#13#10 +
    '%s,' +
    #13#10 +
    '%s' +
    '%s'#13#10 +
    '  CAST(IIF(SUM(e2.debiteq) <> 0, SUM(e2.debiteq) /%d, 0)  AS %s) AS EQ_DEBIT,'#13#10 +
    '%s'#13#10 +
    '  CAST(IIF(SUM(e2.crediteq) <> 0, SUM(e2.crediteq)/ %d, 0) AS %s) AS EQ_CREDIT, '#13#10 +
    '%s' +
    'FROM '#13#10 +
    '  ac_entry e '#13#10 +
    '  LEFT JOIN ac_entry e1 ON e1.recordkey = e.recordkey AND e1.id = e.id and '#13#10 +
    '    e1.entrydate < :begindate'#13#10 +
    '  LEFT JOIN ac_entry e2 ON e2.recordkey = e.recordkey AND e2.id = e.id and '#13#10 +
    '    e2.entrydate >= :begindate and e2.entrydate <= :enddate '#13#10 +
    '%s'#13#10 +
    'WHERE '#13#10 +
    '  %s e.entrydate <= :enddate '#13#10 +
    '  AND e.companykey  IN (%s) '#13#10 +
    '%s' +
    '%s' +
    'GROUP BY %s '#13#10 +
    '%s ';

  cFirstEntryDateDebitCredit =
    'SELECT '#13#10 +
    '%s, '#13#10 +
    '  CAST(IIF(NOT ls.debitncubegin IS NULL, ls.debitncubegin / %d, 0) AS %s) AS NCU_BEGIN_DEBIT, '#13#10 +
    '  CAST(IIF(NOT ls.creditncubegin IS NULL, ls.creditncubegin / %d, 0) AS %s) AS NCU_BEGIN_CREDIT, '#13#10 +
    '%s' +
    '  CAST(IIF(SUM(e2.debitncu) <> 0, SUM(e2.debitncu) / %d, 0) AS %s) AS NCU_DEBIT,'#13#10 +
    '%s' +
    '  CAST(IIF(SUM(e2.creditncu) <> 0, SUM(e2.creditncu) / %d, 0) AS %s) AS NCU_CREDIT , '#13#10 +
    '  CAST(IIF(NOT ls.debitncuend IS NULL, ls.debitncuend / %d, 0) AS %s)  AS NCU_END_DEBIT, '#13#10 +
    '  CAST(IIF(NOT ls.creditncuend IS NULL, ls.creditncuend / %d, 0) AS %s) AS NCU_END_CREDIT, '#13#10 +
    #13#10 +
    '  CAST(IIF(NOT ls.debitcurrbegin IS NULL, ls.debitcurrbegin / %d, 0) AS %s) AS CURR_BEGIN_DEBIT, '#13#10 +
    '  CAST(IIF(NOT ls.creditcurrbegin IS NULL, ls.creditcurrbegin / %d, 0) AS %s) AS CURR_BEGIN_CREDIT, '#13#10 +
    '%s'#13#10 +
    '  CAST(IIF(SUM(e2.debitcurr) <> 0, SUM(e2.debitcurr) /%d, 0) AS %s) AS CURR_DEBIT,'#13#10 +
    '%s'#13#10 +
    '  CAST(IIF(SUM(e2.creditcurr) <> 0, SUM(e2.creditcurr)/ %d, 0) AS %s) AS CURR_CREDIT, '#13#10 +
    '  CAST(IIF(NOT ls.debitcurrend IS NULL, ls.debitcurrend / %d, 0) AS %s) AS CURR_END_DEBIT, '#13#10 +
    '  CAST(IIF(NOT ls.creditcurrend IS NULL, ls.creditcurrend / %d, 0) AS %s) AS CURR_END_CREDIT, '#13#10 +
    #13#10 +
    '  CAST(IIF(NOT ls.debiteqbegin IS NULL, ls.debiteqbegin / %d, 0) AS %s) AS EQ_BEGIN_DEBIT, '#13#10 +
    '  CAST(IIF(NOT ls.crediteqbegin IS NULL, ls.crediteqbegin / %d, 0) AS %s) AS EQ_BEGIN_CREDIT, '#13#10 +
    '%s'#13#10 +
    '  CAST(IIF(SUM(e2.debiteq) <> 0, SUM(e2.debiteq) /%d, 0) AS %s) AS EQ_DEBIT,'#13#10 +
    '%s'#13#10 +
    '  CAST(IIF(SUM(e2.crediteq) <> 0, SUM(e2.crediteq)/ %d, 0) AS %s) AS EQ_CREDIT, '#13#10 +
    '  CAST(IIF(NOT ls.debiteqend IS NULL, ls.debiteqend / %d, 0) AS %s) AS EQ_END_DEBIT, '#13#10 +
    '  CAST(IIF(NOT ls.crediteqend IS NULL, ls.crediteqend / %d, 0) AS %s) AS EQ_END_CREDIT '#13#10 +
    'FROM '#13#10 +
    '  %s ls '#13#10 +
    '%s'#13#10 +
    '  LEFT JOIN ac_entry e ON %s /*AccountInClause*/ ls.forceshow = 0 AND e.entrydate = ls.entrydate AND'#13#10 +
    '    e.entrydate >= :begindate AND e.entrydate <= :enddate %s'#13#10 +
    '  LEFT JOIN ac_entry e2 ON e.id = e2.id '#13#10 +
    '%s'#13#10 +
    'WHERE '#13#10 +
    '  ls.forceshow = 1 OR ('#13#10 +
    '  e.companykey IN (%s)'#13#10 +
    '%s' +
    '%s)' +
    'GROUP BY %s '#13#10;
//Шаблон если первым полем для групировки стоит месяц, год, квартал
  cFirstGroupEntryDateDebitCredit =
    'SELECT '#13#10 +
    '%s, '#13#10 +
    '  CAST(IIF(NOT ls.debitncubegin IS NULL, ls.debitncubegin / %d, 0) AS %s) AS NCU_BEGIN_DEBIT, '#13#10 +
    '  CAST(IIF(NOT ls.creditncubegin IS NULL, ls.creditncubegin / %d, 0) AS %s) AS NCU_BEGIN_CREDIT, '#13#10 +
    '%s' +
    '  CAST(IIF(SUM(e2.debitncu) <> 0, SUM(e2.debitncu) / %d, 0) AS %s) AS NCU_DEBIT,'#13#10 +
    '%s' +
    '  CAST(IIF(SUM(e2.creditncu) <> 0, SUM(e2.creditncu) / %d, 0) AS %s) AS NCU_CREDIT , '#13#10 +
    '  CAST(IIF(NOT ls.debitncuend IS NULL, ls.debitncuend / %d, 0) AS %s)  AS NCU_END_DEBIT, '#13#10 +
    '  CAST(IIF(NOT ls.creditncuend IS NULL, ls.creditncuend / %d, 0) AS %s) AS NCU_END_CREDIT, '#13#10 +
    #13#10 +
    '  CAST(IIF(NOT ls.debitcurrbegin IS NULL, ls.debitcurrbegin / %d, 0) AS %s) AS CURR_BEGIN_DEBIT, '#13#10 +
    '  CAST(IIF(NOT ls.creditcurrbegin IS NULL, ls.creditcurrbegin / %d, 0) AS %s) AS CURR_BEGIN_CREDIT, '#13#10 +
    '%s'#13#10 +
    '  CAST(IIF(SUM(e2.debitcurr) <> 0, SUM(e2.debitcurr) /%d, 0) AS %s) AS CURR_DEBIT,'#13#10 +
    '%s'#13#10 +
    '  CAST(IIF(SUM(e2.creditcurr) <> 0, SUM(e2.creditcurr)/ %d, 0) AS %s) AS CURR_CREDIT, '#13#10 +
    '  CAST(IIF(NOT ls.debitcurrend IS NULL, ls.debitcurrend / %d, 0) AS %s) AS CURR_END_DEBIT, '#13#10 +
    '  CAST(IIF(NOT ls.creditcurrend IS NULL, ls.creditcurrend / %d, 0) AS %s) AS CURR_END_CREDIT, '#13#10 +
    #13#10 +
    '  CAST(IIF(NOT ls.debiteqbegin IS NULL, ls.debiteqbegin / %d, 0) AS %s) AS EQ_BEGIN_DEBIT, '#13#10 +
    '  CAST(IIF(NOT ls.crediteqbegin IS NULL, ls.crediteqbegin / %d, 0) AS %s) AS EQ_BEGIN_CREDIT, '#13#10 +
    '%s'#13#10 +
    '  CAST(IIF(SUM(e2.debiteq) <> 0, SUM(e2.debiteq) /%d, 0) AS %s) AS EQ_DEBIT,'#13#10 +
    '%s'#13#10 +
    '  CAST(IIF(SUM(e2.crediteq) <> 0, SUM(e2.crediteq)/ %d, 0) AS %s) AS EQ_CREDIT, '#13#10 +
    '  CAST(IIF(NOT ls.debiteqend IS NULL, ls.debiteqend / %d, 0) AS %s) AS EQ_END_DEBIT, '#13#10 +
    '  CAST(IIF(NOT ls.crediteqend IS NULL, ls.crediteqend / %d, 0) AS %s) AS EQ_END_CREDIT '#13#10 +
    'FROM '#13#10 +
    '  %s ls '#13#10 +
    '%s'#13#10 +
    '  LEFT JOIN ac_entry e ON %s ls.forceshow = 0 AND g_d_getdateparam(e.entrydate, %s) = ls.dateparam AND '#13#10 +
    '    e.entrydate >= :begindate AND e.entrydate <= :enddate %s'#13#10 +
    '  LEFT JOIN ac_entry e2 ON e.id = e2.id '#13#10 +
    '%s'#13#10 +
    'WHERE '#13#10 +
    '  ls.forceshow = 1 OR ('#13#10 +
    '  e.companykey IN (%s)'#13#10 +
    '%s' +
    '%s)' +
    'GROUP BY %s '#13#10;

  cBeginSaldoSQLTemplate =
    'SELECT '#13#10 +
    '%s, '#13#10 +
    '%s, ' +
    '%s' +
    'FROM '#13#10 +
    '  ac_entry e '#13#10 +
    '%s'#13#10 +
    'WHERE '#13#10 +
    '  %s e.entrydate < :begindate '#13#10 +
    '  AND e.companykey IN (%s) '#13#10 +
    '%s' +
    '%s' +
    'GROUP BY %s '#13#10 +
    '%s ';

  cCirculationListTemplate =
    'SELECT'#13#10 +
    '  cl.id,'#13#10 +
    '  cl.alias ,'#13#10 +
    '  cl.Name,'#13#10 +
    '  cl.offbalance,'#13#10 +
    '  CAST((cl.NCU_BEGIN_DEBIT / %d) as %s) as NCU_BEGIN_DEBIT,'#13#10 +
    '  CAST((cl.NCU_BEGIN_CREDIT / %d) as %s) as NCU_BEGIN_CREDIT,'#13#10 +
    '%s'#13#10 + //Расшифоавка по дебиту
    '  CAST((cl.NCU_DEBIT / %d) as %s) as NCU_DEBIT,'#13#10 +
    '%s'#13#10 + //Расшифровка по кредиту
    '  CAST((cl.NCU_CREDIT / %d) as %s) as NCU_CREDIT,'#13#10 +
    '  CAST((cl.NCU_END_DEBIT / %d) as %s) as NCU_END_DEBIT,'#13#10 +
    '  CAST((cl.NCU_END_CREDIT / %d) as %s) as NCU_END_CREDIT,' +

    '  CAST((cl.CURR_BEGIN_DEBIT / %d) as %s) as CURR_BEGIN_DEBIT,'#13#10 +
    '  CAST((cl.CURR_BEGIN_CREDIT / %d) as %s) as CURR_BEGIN_CREDIT,'#13#10 +
    '%s'#13#10 + //Расшифоавка по дебиту
    '  CAST((cl.CURR_DEBIT / %d) as %s) as CURR_DEBIT,'#13#10 +
    '%s'#13#10 + //Расшифровка по кредиту
    '  CAST((cl.CURR_CREDIT / %d) as %s) as CURR_CREDIT,'#13#10 +
    '  CAST((cl.CURR_END_DEBIT / %d) as %s) as CURR_END_DEBIT,'#13#10 +
    '  CAST((cl.CURR_END_CREDIT / %d) as %s) as CURR_END_CREDIT,' +

    '  CAST((cl.EQ_BEGIN_DEBIT / %d) as %s) as EQ_BEGIN_DEBIT,'#13#10 +
    '  CAST((cl.EQ_BEGIN_CREDIT / %d) as %s) as EQ_BEGIN_CREDIT,'#13#10 +
    '%s'#13#10 + //Расшифоавка по дебиту
    '  CAST((cl.EQ_DEBIT / %d) as %s) as EQ_DEBIT,'#13#10 +
    '%s'#13#10 + //Расшифровка по кредиту
    '  CAST((cl.EQ_CREDIT / %d) as %s) as EQ_CREDIT,'#13#10 +
    '  CAST((cl.EQ_END_DEBIT / %d) as %s) as EQ_END_DEBIT,'#13#10 +
    '  CAST((cl.EQ_END_CREDIT / %d) as %s) as EQ_END_CREDIT' +

    '%s'#13#10 + //Quantyti select clause
    'FROM'#13#10 +
    '  %s cl'#13#10 +
    '%s' +
    'ORDER BY cl.offbalance DESC, cl.alias';

  cGeneralLedgerTemplate =
    'SELECT'#13#10 +
    '  cl.m,'#13#10 +
    '  cl.y ,'#13#10 +
    '  CAST(1 AS INTEGER) AS SORTFIELD, '#13#10 +
    '  CAST((cl.DEBITNCUBEGIN / %d) as %s) as NCU_BEGIN_DEBIT,'#13#10 +
    '  CAST((cl.CREDITNCUBEGIN / %d) as %s) as NCU_BEGIN_CREDIT,'#13#10 +
    '%s'#13#10 + //Расшифоавка по дебиту
    '  CAST((IIF(SUM(e2.debitncu) IS NULL, 0, SUM(e2.debitncu) / %d)) as %s) as NCU_DEBIT,'#13#10 +
    '%s'#13#10 + //Расшифровка по кредиту
    '  CAST(IIF(SUM(e2.creditncu) IS NULL, 0, SUM(e2.creditncu) / %d) as %s) as NCU_CREDIT,'#13#10 +
    '  CAST((cl.DEBITNCUEND / %d) as %s) as NCU_END_DEBIT,'#13#10 +
    '  CAST((cl.CREDITNCUEND / %d) as %s) as NCU_END_CREDIT,'#13#10 +

    '  CAST((cl.DEBITCURRBEGIN / %d) as %s) as CURR_BEGIN_DEBIT,'#13#10 +
    '  CAST((cl.CREDITCURRBEGIN / %d) as %s) as CURR_BEGIN_CREDIT,'#13#10 +
    '%s'#13#10 + //Расшифоавка по дебиту
    '  CAST((IIF(SUM(e2.debitcurr) IS NULL, 0, SUM(e2.debitcurr) / %d)) as %s) as CURR_DEBIT,'#13#10 +
    '%s'#13#10 + //Расшифровка по кредиту
    '  CAST(IIF(SUM(e2.creditcurr) IS NULL, 0, SUM(e2.creditcurr) / %d) as %s) as CURR_CREDIT,'#13#10 +
    '  CAST((cl.DEBITCURREND / %d) as %s) as CURR_END_DEBIT,'#13#10 +
    '  CAST((cl.CREDITCURREND / %d) as %s) as CURR_END_CREDIT,'#13#10 +

    '  CAST((cl.DEBITEQBEGIN / %d) as %s) as EQ_BEGIN_DEBIT,'#13#10 +
    '  CAST((cl.CREDITEQBEGIN / %d) as %s) as EQ_BEGIN_CREDIT,'#13#10 +
    '%s'#13#10 + //Расшифоавка по дебиту
    '  CAST((IIF(SUM(e2.debiteq) IS NULL, 0, SUM(e2.debiteq) / %d)) as %s) as EQ_DEBIT,'#13#10 +
    '%s'#13#10 + //Расшифровка по кредиту
    '  CAST(IIF(SUM(e2.crediteq) IS NULL, 0, SUM(e2.crediteq) / %d) as %s) as EQ_CREDIT,'#13#10 +
    '  CAST((cl.DEBITEQEND / %d) as %s) as EQ_END_DEBIT,'#13#10 +
    '  CAST((cl.CREDITEQEND / %d) as %s) as EQ_END_CREDIT' +

    '%s'#13#10 + //Quantyti select clause
    'FROM'#13#10 +
    '  %s cl'#13#10 +
    '  LEFT JOIN ac_entry e ON e.entrydate >= :begindate AND '#13#10 +
    '    e.entrydate <= :enddate AND %s cl.forceshow = 0 AND '#13#10 +
    '    cl.y = EXTRACT(YEAR FROM e.entrydate) AND '#13#10 +
    '    cl.m = EXTRACT(MONTH FROM e.entrydate) '#13#10 +
    '  LEFT JOIN ac_entry e2 ON e.id = e2.id '#13#10 +
    '  /*LEFT JOIN ac_record r ON r.id = e.recordkey*/ '#13#10 +
    '%s' +
    'WHERE'#13#10 +
    '  cl.forceshow = 1 OR ('#13#10 +
    '  e.companykey in (%s)  '#13#10 +
    '%s' +
    '%s)' +
    'GROUP BY cl.m, cl.y, cl.DEBITNCUBEGIN, cl.CREDITNCUBEGIN,'#13#10 +
    '  cl.DEBITNCUEND, cl.CREDITNCUEND,'#13#10 +
    ' cl.DEBITCURRBEGIN, cl.CREDITCURRBEGIN,'#13#10 +
    '  cl.DEBITCURREND, cl.CREDITCURREND,'#13#10 +
    ' cl.DEBITEQBEGIN, cl.CREDITEQBEGIN,'#13#10 +
    '  cl.DEBITEQEND, cl.CREDITEQEND'#13#10 +
    '%s'#13#10 +
    'ORDER BY 2, 1';

  cStoredProcedureTemplate =
    '('#13#10 +
    '    L INTEGER,'#13#10 +
    '    NODEKEY INTEGER)'#13#10 +
    'RETURNS ('#13#10 +
    '    ID INTEGER)'#13#10 +
    'AS'#13#10 +
    'DECLARE VARIABLE LB INTEGER;'#13#10 +
    'DECLARE VARIABLE RB INTEGER;'#13#10 +
    'DECLARE VARIABLE V INTEGER;'#13#10 +
    'BEGIN'#13#10 +
    '  FOR'#13#10 +
    '    SELECT'#13#10 +
    '      gg1.id,'#13#10 +
    '      gg1.lb,'#13#10 +
    '      gg1.rb'#13#10 +
    '    FROM'#13#10 +
    '      %0:s gg'#13#10 +
    '      LEFT JOIN %0:s gg1 ON gg1.lb <= gg.lb AND gg1.rb >= gg.rb'#13#10 +
    '    WHERE'#13#10 +
    '      gg.%1:s = :nodekey'#13#10 +
    '    ORDER BY gg1.lb'#13#10 +
    '    INTO :ID,'#13#10 +
    '      :LB,'#13#10 +
    '      :RB'#13#10 +
    '  DO'#13#10 +
    '  BEGIN'#13#10 +
    '    SELECT'#13#10 +
    '      COUNT(*)'#13#10 +
    '    FROM'#13#10 +
    '      %0:s gg1'#13#10 +
    '    WHERE'#13#10 +
    '      gg1.lb <= :lb AND'#13#10 +
    '      gg1.rb >= :rb'#13#10 +
    '    INTO'#13#10 +
    '      :V;'#13#10 +
    ''#13#10 +
    '    IF (:V = :L) THEN'#13#10 +
    '    BEGIN'#13#10 +
    '      SUSPEND;'#13#10 +
    '      EXIT;'#13#10 +
    '    END'#13#10 +
    '  END'#13#10 +
    'END';

implementation

end.
