inherited frmMakeDemand: TfrmMakeDemand
  Left = 261
  Top = 156
  Width = 696
  Height = 481
  Caption = 'Список накладных для формирования требований'
  Font.Charset = DEFAULT_CHARSET
  Font.Name = 'Tahoma'
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 416
    Width = 688
  end
  inherited pnlMain: TPanel
    Width = 688
    Height = 416
    inherited ibgrMain: TgsIBGrid
      Width = 686
      Height = 386
      PopupMenu = pMenu
      CheckBox.DisplayField = 'NUMBER'
      CheckBox.FieldName = 'DOCUMENTKEY'
      CheckBox.Visible = True
    end
    inherited cbMain: TControlBar
      Width = 686
      inherited tbMain: TToolBar
        object tblRun: TToolButton
          Left = 283
          Top = 0
          Action = actExecute
        end
      end
    end
  end
  inherited alMain: TActionList
    inherited actNew: TAction
      Visible = False
    end
    inherited actEdit: TAction
      Hint = 'Изменить текущий шаблон'
      OnExecute = actEditExecute
    end
    inherited actDelete: TAction
      Visible = False
    end
    inherited actDuplicate: TAction
      Visible = False
    end
    object actExecute: TAction
      Caption = 'Создать'
      ImageIndex = 5
      OnExecute = actExecuteExecute
    end
    object actSelectAll: TAction
      Caption = 'Отметить'
      ShortCut = 16449
      OnExecute = actSelectAllExecute
    end
    object actDeSelect: TAction
      Caption = 'Снять отметку'
      OnExecute = actDeSelectExecute
    end
  end
  inherited ibdsMain: TIBDataSet
    SelectSQL.Strings = (
      'SELECT '
      '  doc.number,'
      '  doc.documentdate,'
      '  docr.documentkey,'
      '  docr.transsumncu,'
      '  docr.transsumcurr,'
      '  doc.currkey,'
      '  docr.tocontactkey,'
      '  docr.fromcontactkey,'
      '  docr.fromdocumentkey,'
      '  docr.rate,'
      '  toc.name,'
      '  fromc.name as fromname,'
      '  docr.typetransport,'
      '  doci.contractkey,'
      '  con.percent'
      ''
      'FROM'
      '  gd_docrealization docr'
      'JOIN'
      '  gd_document doc ON doc.id = docr.documentkey  AND'
      '  doc.documenttypekey = :dt AND'
      '  doc.companykey = :ck'
      'JOIN'
      '  gd_contact toc ON docr.tocontactkey = toc.id '
      'JOIN'
      '  gd_contact fromc ON docr.fromcontactkey = fromc.id '
      'JOIN'
      '  gd_company comp ON docr.tocontactkey = comp.contactkey'
      'LEFT JOIN'
      '  gd_docrealinfo doci ON docr.documentkey = doci.documentkey'
      'LEFT JOIN'
      '  gd_contract con ON doci.contractkey = con.documentkey'
      'WHERE'
      '   not comp.companyaccountkey IS NULL AND'
      
        '   NOT exists(SELECT sourcedockey FROM gd_documentlink dl WHERE ' +
        '     dl.sourcedockey = docr.documentkey)'
      '   AND '
      
        '  (docr.typetransport IS NULL or docr.typetransport <> '#39'C'#39' or NO' +
        'T docr.fromdocumentkey IS NULL)'
      
        '  AND (docr.isrealization = 1 or NOT docr.fromdocumentkey IS NUL' +
        'L)')
  end
  inherited gsMainReportManager: TgsReportManager
    MenuType = mtSeparator
    Caption = 'Отчеты'
    GroupID = 2000005
  end
  object xFoCal: TxFoCal
    Expression = '0'
    Left = 64
    Top = 176
    _variables_ = (
      'PI'
      3.14159265358979
      'E'
      2.71828182845905)
  end
  object ibsqlInsert: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'INSERT INTO gd_documentlink (sourcedockey, destdockey)'
      '  VALUES (:sk, :dk)')
    Transaction = IBTransaction
    Left = 144
    Top = 173
  end
  object gsDocNumerator: TgsDocNumerator
    Database = dmDatabase.ibdbGAdmin
    DataSource = dsDocument
    DocumentType = 800200
    Left = 184
    Top = 136
  end
  object ibdsDocument: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 100
    DeleteSQL.Strings = (
      'delete from gd_document'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into gd_document'
      '  (ID, DOCUMENTTYPEKEY, TRTYPEKEY, NUMBER, DOCUMENTDATE, '
      'DESCRIPTION, SUMNCU, '
      '   SUMCURR, SUMEQ, AFULL, ACHAG, AVIEW, CURRKEY, COMPANYKEY, '
      'CREATORKEY, '
      '   CREATIONDATE, EDITORKEY, EDITIONDATE, DISABLED, RESERVED)'
      'values'
      '  (:ID, :DOCUMENTTYPEKEY, :TRTYPEKEY, :NUMBER, :DOCUMENTDATE, '
      ':DESCRIPTION, '
      '   :SUMNCU, :SUMCURR, :SUMEQ, :AFULL, :ACHAG, :AVIEW, :CURRKEY, '
      ':COMPANYKEY, '
      
        '   :CREATORKEY, :CREATIONDATE, :EDITORKEY, :EDITIONDATE, :DISABL' +
        'ED, '
      ':RESERVED)')
    RefreshSQL.Strings = (
      'Select *'
      'from gd_document '
      'where'
      '  ID = :ID')
    SelectSQL.Strings = (
      'SELECT * FROM gd_document')
    ModifySQL.Strings = (
      'update gd_document'
      'set'
      '  ID = :ID,'
      '  DOCUMENTTYPEKEY = :DOCUMENTTYPEKEY,'
      '  TRTYPEKEY = :TRTYPEKEY,'
      '  NUMBER = :NUMBER,'
      '  DOCUMENTDATE = :DOCUMENTDATE,'
      '  DESCRIPTION = :DESCRIPTION,'
      '  SUMNCU = :SUMNCU,'
      '  SUMCURR = :SUMCURR,'
      '  SUMEQ = :SUMEQ,'
      '  AFULL = :AFULL,'
      '  ACHAG = :ACHAG,'
      '  AVIEW = :AVIEW,'
      '  CURRKEY = :CURRKEY,'
      '  COMPANYKEY = :COMPANYKEY,'
      '  CREATORKEY = :CREATORKEY,'
      '  CREATIONDATE = :CREATIONDATE,'
      '  EDITORKEY = :EDITORKEY,'
      '  EDITIONDATE = :EDITIONDATE,'
      '  DISABLED = :DISABLED,'
      '  RESERVED = :RESERVED'
      'where'
      '  ID = :OLD_ID')
    ReadTransaction = IBTransaction
    Left = 184
    Top = 168
  end
  object dsDocument: TDataSource
    DataSet = ibdsDocument
    Left = 216
    Top = 168
  end
  object sqlCompanyData: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'SELECT '
      '  C.COUNTRY,  '
      '  COMP.FULLNAME,'
      '  CC.TAXID'
      ''
      'FROM'
      '  GD_CONTACT C'
      ''
      '    JOIN'
      '      GD_COMPANY COMP'
      '    ON'
      '      C.ID = COMP.CONTACTKEY'
      ''
      '    LEFT JOIN'
      '      GD_COMPANYCODE CC'
      '    ON'
      '      C.ID = CC.COMPANYKEY    '
      ''
      'WHERE'
      '  C.ID = :Id')
    Transaction = IBTransaction
    Left = 252
    Top = 166
  end
  object sqlBankData: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'SELECT '
      '  COMP.FULLNAME,'
      '  C.CITY,'
      '  BANK.BANKCODE,'
      '  BANK.BANKKEY,'
      '  A.ACCOUNT'
      ''
      'FROM'
      '  GD_COMPANYACCOUNT A,'
      ''
      '  GD_COMPANY COMP'
      ''
      '    JOIN'
      '      GD_CONTACT C'
      '    ON'
      '      COMP.CONTACTKEY = C.ID'
      ''
      '    JOIN'
      '      GD_BANK BANK'
      '    ON'
      '      COMP.CONTACTKEY = BANK.BANKKEY'
      ''
      'WHERE'
      '  A.ID = :Id'
      '    AND'
      '  COMP.CONTACTKEY = A.BANKKEY')
    Transaction = IBTransaction
    Left = 282
    Top = 166
  end
  object ibsqlCompanyAccount: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'SELECT'
      '   C.COMPANYACCOUNTKEY, CA.ACCOUNT, C.FULLNAME  '
      'FROM '
      '   GD_COMPANY C '
      '   LEFT JOIN GD_COMPANYACCOUNT CA'
      '   ON CA.ID = C.COMPANYACCOUNTKEY'
      'WHERE C.CONTACTKEY = :ck')
    Transaction = IBTransaction
    Left = 284
    Top = 197
  end
  object IBSQLCompanyName: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'SELECT '
      '  COMP.FULLNAME,'
      '  C.NAME'
      'FROM'
      '  gd_company comp, gd_contact c'
      'WHERE c.id = comp.companykey'
      '  and c.id = :id')
    Transaction = IBTransaction
    Left = 252
    Top = 196
  end
  object ibdsDemandPayment: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 100
    DeleteSQL.Strings = (
      'delete from bn_demandpayment'
      'where'
      '  DOCUMENTKEY = :OLD_DOCUMENTKEY')
    InsertSQL.Strings = (
      'insert into bn_demandpayment'
      '  (DOCUMENTKEY, ACCOUNTKEY, CORRCOMPANYKEY, CORRACCOUNTKEY, '
      'OWNCOMPTEXT, '
      '   OWNTAXID, OWNCOUNTRY, OWNBANKTEXT, OWNBANKCITY, '
      'OWNACCOUNT, OWNACCOUNTCODE, '
      '   CORRCOMPTEXT, CORRTAXID, CORRCOUNTRY, CORRBANKTEXT, '
      'CORRBANKCITY, CORRACCOUNT, '
      '   CORRACCOUNTCODE, CORRSECACC, AMOUNT, PROC, OPER, QUEUE, '
      'DESTCODEKEY, '
      '   DESTCODE, TERM, DESTINATION, SECONDACCOUNTKEY, SECONDAMOUNT, '
      'ENTERDATE, '
      '   SPECIFICATION, CARGOSENDER, CARGORECIEVER, CONTRACT, PAPER, '
      'CARGOSENDDATE, '
      '   PAPERSENDDATE, PERCENT)'
      'values'
      '  (:DOCUMENTKEY, :ACCOUNTKEY, :CORRCOMPANYKEY, :CORRACCOUNTKEY, '
      ':OWNCOMPTEXT, '
      '   :OWNTAXID, :OWNCOUNTRY, :OWNBANKTEXT, :OWNBANKCITY, '
      ':OWNACCOUNT, :OWNACCOUNTCODE, '
      '   :CORRCOMPTEXT, :CORRTAXID, :CORRCOUNTRY, :CORRBANKTEXT, '
      ':CORRBANKCITY, '
      '   :CORRACCOUNT, :CORRACCOUNTCODE, :CORRSECACC, :AMOUNT, :PROC, '
      ':OPER, '
      '   :QUEUE, :DESTCODEKEY, :DESTCODE, :TERM, :DESTINATION, '
      ':SECONDACCOUNTKEY, '
      '   :SECONDAMOUNT, :ENTERDATE, :SPECIFICATION, :CARGOSENDER, '
      ':CARGORECIEVER, '
      '   :CONTRACT, :PAPER, :CARGOSENDDATE, :PAPERSENDDATE,'
      '   :PERCENT)')
    RefreshSQL.Strings = (
      'Select *'
      'from bn_demandpayment '
      'where'
      '  DOCUMENTKEY = :DOCUMENTKEY')
    SelectSQL.Strings = (
      'SELECT * FROM bn_demandpayment')
    ModifySQL.Strings = (
      'update bn_demandpayment'
      'set'
      '  DOCUMENTKEY = :DOCUMENTKEY,'
      '  ACCOUNTKEY = :ACCOUNTKEY,'
      '  CORRCOMPANYKEY = :CORRCOMPANYKEY,'
      '  CORRACCOUNTKEY = :CORRACCOUNTKEY,'
      '  OWNCOMPTEXT = :OWNCOMPTEXT,'
      '  OWNTAXID = :OWNTAXID,'
      '  OWNCOUNTRY = :OWNCOUNTRY,'
      '  OWNBANKTEXT = :OWNBANKTEXT,'
      '  OWNBANKCITY = :OWNBANKCITY,'
      '  OWNACCOUNT = :OWNACCOUNT,'
      '  OWNACCOUNTCODE = :OWNACCOUNTCODE,'
      '  CORRCOMPTEXT = :CORRCOMPTEXT,'
      '  CORRTAXID = :CORRTAXID,'
      '  CORRCOUNTRY = :CORRCOUNTRY,'
      '  CORRBANKTEXT = :CORRBANKTEXT,'
      '  CORRBANKCITY = :CORRBANKCITY,'
      '  CORRACCOUNT = :CORRACCOUNT,'
      '  CORRACCOUNTCODE = :CORRACCOUNTCODE,'
      '  CORRSECACC = :CORRSECACC,'
      '  AMOUNT = :AMOUNT,'
      '  PROC = :PROC,'
      '  OPER = :OPER,'
      '  QUEUE = :QUEUE,'
      '  DESTCODEKEY = :DESTCODEKEY,'
      '  DESTCODE = :DESTCODE,'
      '  TERM = :TERM,'
      '  DESTINATION = :DESTINATION,'
      '  SECONDACCOUNTKEY = :SECONDACCOUNTKEY,'
      '  SECONDAMOUNT = :SECONDAMOUNT,'
      '  ENTERDATE = :ENTERDATE,'
      '  SPECIFICATION = :SPECIFICATION,'
      '  CARGOSENDER = :CARGOSENDER,'
      '  CARGORECIEVER = :CARGORECIEVER,'
      '  CONTRACT = :CONTRACT,'
      '  PAPER = :PAPER,'
      '  CARGOSENDDATE = :CARGOSENDDATE,'
      '  PAPERSENDDATE = :PAPERSENDDATE,'
      '  PERCENT = :PERCENT'
      'where'
      '  DOCUMENTKEY = :OLD_DOCUMENTKEY')
    ReadTransaction = IBTransaction
    Left = 184
    Top = 200
  end
  object ibsqlDocRealPos: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'SELECT '
      '  SUM(AmountNCU) as AmountNCU,'
      '  SUM(AmountCurr) as AmountCurr'
      '/**/'
      'FROM gd_docrealpos'
      '')
    Transaction = IBTransaction
    Left = 248
    Top = 288
  end
  object ibsqlDocument: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'SELECT * FROM gd_document WHERE id = :billkey')
    Transaction = IBTransaction
    Left = 248
    Top = 320
  end
  object ibsqlDocRealization: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'SELECT * FROM gd_docrealization'
      'WHERE documentkey = :billkey')
    Transaction = IBTransaction
    Left = 248
    Top = 352
  end
  object ibsqlDocRealInfo: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'SELECT * FROM gd_docrealinfo WHERE documentkey = :billkey')
    Transaction = IBTransaction
    Left = 248
    Top = 384
  end
  object pMenu: TPopupMenu
    Left = 184
    Top = 229
    object N1: TMenuItem
      Action = actSelectAll
    end
    object N2: TMenuItem
      Action = actDeSelect
    end
  end
  object ibsqlDocRealPosGroup: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'SELECT '
      '  SUM(docp.AmountNCU) as AmountNCU,'
      '  SUM(docp.AmountCurr) as AmountCurr'
      '/**/'
      'FROM gd_docrealpos docp JOIN gd_good g ON docp.GoodKey = g.id'
      'WHERE '
      '  documentkey = :billkey and'
      '  g.GroupKey = :gk')
    Transaction = IBTransaction
    Left = 288
    Top = 288
  end
  object ibsqlReturn: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    Left = 288
    Top = 320
  end
  object sqlOurCompany: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'SELECT '
      '  C.COUNTRY,  '
      '  COMP.FULLNAME,'
      '  CC.TAXID'
      ''
      'FROM'
      '  GD_CONTACT C'
      ''
      '    JOIN'
      '      GD_COMPANY COMP'
      '    ON'
      '      C.ID = COMP.CONTACTKEY'
      ''
      '    LEFT JOIN'
      '      GD_COMPANYCODE CC'
      '    ON'
      '      C.ID = CC.COMPANYKEY    '
      ''
      'WHERE'
      '  C.ID = :Id')
    Transaction = IBTransaction
    Left = 316
    Top = 166
  end
  object sqlOurBank: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'SELECT '
      '  COMP.FULLNAME,'
      '  C.CITY,'
      '  BANK.BANKCODE,'
      '  BANK.BANKKEY,'
      '  A.ACCOUNT'
      ''
      'FROM'
      '  GD_COMPANYACCOUNT A,'
      ''
      '  GD_COMPANY COMP'
      ''
      '    JOIN'
      '      GD_CONTACT C'
      '    ON'
      '      COMP.CONTACTKEY = C.ID'
      ''
      '    JOIN'
      '      GD_BANK BANK'
      '    ON'
      '      COMP.CONTACTKEY = BANK.BANKKEY'
      ''
      'WHERE'
      '  A.ID = :Id'
      '    AND'
      '  COMP.CONTACTKEY = A.BANKKEY')
    Transaction = IBTransaction
    Left = 322
    Top = 198
  end
end
