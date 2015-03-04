object dlgMakeDemand: TdlgMakeDemand
  Left = 269
  Top = 156
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Формирование требований'
  ClientHeight = 354
  ClientWidth = 582
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 0
    Top = 29
    Width = 582
    Height = 325
    Align = alClient
    BevelInner = bvLowered
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 0
    object gsibgrRealization: TgsIBGrid
      Left = 5
      Top = 5
      Width = 572
      Height = 315
      Align = alClient
      BorderStyle = bsNone
      DataSource = dsDocRealization
      TabOrder = 0
      InternalMenuKind = imkWithSeparator
      Expands = <>
      ExpandsActive = False
      ExpandsSeparate = False
      Conditions = <>
      ConditionsActive = False
      CheckBox.DisplayField = 'NUMBER'
      CheckBox.FieldName = 'DOCUMENTKEY'
      CheckBox.Visible = True
      CheckBox.FirstColumn = False
      MinColWidth = 40
      ColumnEditors = <>
      Aliases = <>
    end
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 582
    Height = 29
    ButtonHeight = 21
    ButtonWidth = 83
    Caption = 'ToolBar1'
    Flat = True
    ShowCaptions = True
    TabOrder = 1
    object ToolButton1: TToolButton
      Left = 0
      Top = 0
      Action = actRun
    end
    object ToolButton2: TToolButton
      Left = 83
      Top = 0
      Action = actFormat
    end
    object ToolButton3: TToolButton
      Left = 166
      Top = 0
      Caption = 'Фильтрация'
      DropdownMenu = PopupMenu1
    end
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 428
    Top = 256
  end
  object ibsqlDocument: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      'SELECT * FROM gd_document WHERE id = :billkey')
    Transaction = IBTransaction
    Left = 464
    Top = 256
  end
  object ibsqlDocRealization: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      'SELECT * FROM gd_docrealization'
      'WHERE documentkey = :billkey')
    Transaction = IBTransaction
    Left = 464
    Top = 288
  end
  object ibsqlDocRealInfo: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      'SELECT * FROM gd_docrealinfo WHERE documentkey = :billkey')
    Transaction = IBTransaction
    Left = 464
    Top = 320
  end
  object ibsqlDocRealPos: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      'SELECT '
      '  SUM(AmountNCU) as AmountNCU,'
      '  SUM(AmountCurr) as AmountCurr'
      '/**/'
      'FROM gd_docrealpos'
      'WHERE documentkey = :billkey')
    Transaction = IBTransaction
    Left = 464
    Top = 224
  end
  object gsDocNumerator: TgsDocNumerator
    Database = dmDatabase.ibdbGAdmin
    DataSource = dsDocument
    DocumentType = 800200
    Left = 400
    Top = 72
  end
  object ibdsDocument: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
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
    Left = 400
    Top = 104
  end
  object dsDocument: TDataSource
    DataSet = ibdsDocument
    Left = 432
    Top = 104
  end
  object xFoCal: TxFoCal
    Expression = '0'
    Left = 280
    Top = 112
    _variables_ = (
      'PI'
      3.14159265358979
      'E'
      2.71828182845905)
  end
  object ibdsDemandPayment: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
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
      '   PAPERSENDDATE)'
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
      '   :CONTRACT, :PAPER, :CARGOSENDDATE, :PAPERSENDDATE)')
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
      '  PAPERSENDDATE = :PAPERSENDDATE'
      'where'
      '  DOCUMENTKEY = :OLD_DOCUMENTKEY')
    Left = 400
    Top = 136
  end
  object sqlCompanyData: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
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
      '    JOIN'
      '      GD_COMPANYCODE CC'
      '    ON'
      '      C.ID = CC.COMPANYKEY    '
      ''
      'WHERE'
      '  C.ID = :Id')
    Transaction = IBTransaction
    Left = 468
    Top = 102
  end
  object IBSQLCompanyName: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      'SELECT '
      '  COMP.FULLNAME,'
      '  C.NAME'
      'FROM'
      '  gd_company comp, gd_contact c'
      'WHERE c.id = comp.companykey'
      '  and c.id = :id')
    Transaction = IBTransaction
    Left = 468
    Top = 132
  end
  object sqlBankData: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
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
    Left = 498
    Top = 102
  end
  object ibdsDocRealization: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from gd_document'
      'where'
      '  id = :OLD_DOCUMENTKEY')
    RefreshSQL.Strings = (
      'SELECT '
      '  doc.number,'
      '  doc.documentdate,'
      '  docr.documentkey,'
      '  docr.transsumncu,'
      '  docr.transsumcurr,'
      '  doc.currkey,'
      '  docr.tocontactkey,'
      '  docr.fromcontactkey,'
      '  docr.delayedsale,'
      '  docr.rate,'
      '  toc.name,'
      '  fromc.name as fromname'
      'FROM'
      '  gd_docrealization docr'
      'JOIN'
      '  gd_document doc ON doc.id = docr.documentkey'
      'JOIN'
      '  gd_contact toc ON docr.tocontactkey = toc.id '
      'JOIN'
      '  gd_contact fromc ON docr.fromcontactkey = fromc.id '
      'where'
      '  DOCUMENTKEY = :DOCUMENTKEY')
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
      '  docr.delayedsale,'
      '  docr.rate,'
      '  toc.name,'
      '  fromc.name as fromname'
      'FROM'
      '  gd_docrealization docr'
      'JOIN'
      '  gd_document doc ON doc.id = docr.documentkey '
      'JOIN'
      '  gd_contact toc ON docr.tocontactkey = toc.id '
      'JOIN'
      '  gd_contact fromc ON docr.fromcontactkey = fromc.id '
      'JOIN'
      '  gd_company comp ON docr.tocontactkey = comp.contactkey'
      'WHERE'
      '   not comp.companyaccountkey IS NULL')
    Left = 99
    Top = 61
  end
  object dsDocRealization: TDataSource
    DataSet = ibdsDocRealization
    Left = 72
    Top = 61
  end
  object ibsqlCompanyAccount: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      'SELECT'
      '   C.COMPANYACCOUNTKEY, CA.ACCOUNT, C.FULLNAME  '
      'FROM '
      '   GD_COMPANY C '
      '   LEFT JOIN GD_COMPANYACCOUNT CA'
      '   ON CA.ID = C.COMPANYACCOUNTKEY'
      'WHERE C.CONTACTKEY = :ck')
    Transaction = IBTransaction
    Left = 500
    Top = 133
  end
  object ActionList1: TActionList
    Left = 280
    Top = 193
    object actRun: TAction
      Caption = 'Сформировать'
      OnExecute = actRunExecute
    end
    object actFormat: TAction
      Caption = 'Шаблон'
      OnExecute = actFormatExecute
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 184
    Top = 189
  end
  object gsQueryFilter: TgsQueryFilter
    Database = dmDatabase.ibdbGAdmin
    RequeryParams = False
    IBDataSet = ibdsDocRealization
    Left = 224
    Top = 189
  end
  object ibsqlInsert: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      'INSERT INTO gd_documentlink (sourcedockey, destdockey)'
      '  VALUES (:sk, :dk)')
    Transaction = IBTransaction
    Left = 360
    Top = 109
  end
end
