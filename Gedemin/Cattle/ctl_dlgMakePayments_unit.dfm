object ctl_dlgMakePayments: Tctl_dlgMakePayments
  Left = 288
  Top = 139
  Width = 465
  Height = 348
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Формирование платежных документов по квитанциям'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object btnCancel: TButton
    Left = 369
    Top = 294
    Width = 79
    Height = 21
    Action = actCancel
    Anchors = [akRight, akBottom]
    Cancel = True
    ModalResult = 2
    TabOrder = 2
  end
  object btnCreate: TButton
    Left = 279
    Top = 294
    Width = 79
    Height = 21
    Action = actOk
    Anchors = [akRight, akBottom]
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object ibgrdReceipts: TgsIBGrid
    Left = 10
    Top = 10
    Width = 437
    Height = 272
    HelpContext = 3
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = dsReceipts
    Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgAlwaysShowSelection]
    PopupMenu = pmReceipts
    TabOrder = 0
    InternalMenuKind = imkWithSeparator
    Expands = <>
    ExpandsActive = False
    ExpandsSeparate = False
    TitlesExpanding = False
    Conditions = <>
    ConditionsActive = False
    CheckBox.DisplayField = 'DOCUMENTDATE'
    CheckBox.FieldName = 'DOCUMENTKEY'
    CheckBox.Visible = True
    CheckBox.FirstColumn = False
    MinColWidth = 40
    ColumnEditors = <>
    Aliases = <
      item
        Alias = 'SUPPLIER'
        LName = 'Поставщик'
      end>
  end
  object btnSetup: TButton
    Left = 10
    Top = 294
    Width = 79
    Height = 21
    Action = actSetup
    Anchors = [akLeft, akBottom]
    TabOrder = 3
  end
  object btnFilter: TButton
    Left = 99
    Top = 294
    Width = 79
    Height = 21
    Action = actFilter
    Anchors = [akLeft, akBottom]
    TabOrder = 4
  end
  object alPayments: TActionList
    Left = 80
    Top = 100
    object actOk: TAction
      Category = 'Main'
      Caption = 'Создать'
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Category = 'Main'
      Caption = 'Отменить'
      OnExecute = actCancelExecute
    end
    object actSetup: TAction
      Category = 'Main'
      Caption = 'Настроить'
      OnExecute = actSetupExecute
    end
    object actFilter: TAction
      Category = 'Main'
      Caption = 'Фильтр'
      OnExecute = actFilterExecute
    end
    object actChooseAll: TAction
      Category = 'Receipt'
      Caption = 'Выбрать все'
      OnExecute = actChooseAllExecute
    end
    object actInverse: TAction
      Category = 'Receipt'
      Caption = 'Инвертировать'
      OnExecute = actInverseExecute
    end
  end
  object ibdsReceipt: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrPayments
    SelectSQL.Strings = (
      'SELECT'
      '  D.DOCUMENTDATE,'
      '  D.NUMBER,'
      '  D.ID,'
      '  C.NAME AS SUPPLIER,'
      '  R.*,'
      '  I.*,'
      '  DI.DOCUMENTDATE AS INVOICEDATE,'
      '  DI.NUMBER AS INVOICENUMBER'
      ''
      'FROM'
      '  CTL_RECEIPT R'
      ''
      '    JOIN GD_DOCUMENT D ON'
      '      R.DOCUMENTKEY = D.ID'
      ''
      '    JOIN CTL_INVOICE I ON'
      '      I.RECEIPTKEY = R.DOCUMENTKEY'
      ''
      '    JOIN GD_DOCUMENT DI ON'
      '      I.DOCUMENTKEY = DI.ID'
      ''
      '    JOIN GD_CONTACT C ON'
      '      C.ID = I.SUPPLIERKEY'
      ''
      '    LEFT JOIN GD_DOCUMENTLINK DL ON'
      '      R.DOCUMENTKEY = DL.SOURCEDOCKEY'
      ''
      'WHERE'
      '  DL.SOURCEDOCKEY IS NULL')
    ReadTransaction = ibtrPayments
    Left = 140
    Top = 100
  end
  object dsReceipts: TDataSource
    DataSet = ibdsReceipt
    Left = 170
    Top = 100
  end
  object ibtrPayments: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 110
    Top = 100
  end
  object qfPayments: TgsQueryFilter
    Database = dmDatabase.ibdbGAdmin
    RequeryParams = False
    IBDataSet = ibdsReceipt
    Left = 200
    Top = 100
  end
  object pmPayments: TPopupMenu
    Left = 230
    Top = 100
  end
  object pmReceipts: TPopupMenu
    Left = 260
    Top = 100
    object N1: TMenuItem
      Action = actChooseAll
    end
    object N2: TMenuItem
      Action = actInverse
    end
  end
  object ibdsPayment: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrPayments
    CachedUpdates = True
    DeleteSQL.Strings = (
      'delete from BN_DEMANDPAYMENT'
      'where'
      '  DOCUMENTKEY = :OLD_DOCUMENTKEY')
    InsertSQL.Strings = (
      'insert into BN_DEMANDPAYMENT'
      
        '  (DOCUMENTKEY, ACCOUNTKEY, CORRCOMPANYKEY, CORRACCOUNTKEY, OWNC' +
        'OMPTEXT, '
      
        '   OWNTAXID, OWNCOUNTRY, OWNBANKTEXT, OWNBANKCITY, OWNACCOUNT, O' +
        'WNACCOUNTCODE, '
      
        '   CORRCOMPTEXT, CORRTAXID, CORRCOUNTRY, CORRBANKTEXT, CORRBANKC' +
        'ITY, CORRACCOUNT, '
      
        '   CORRACCOUNTCODE, CORRSECACC, AMOUNT, PROC, OPER, QUEUE, DESTC' +
        'ODEKEY, '
      
        '   DESTCODE, TERM, DESTINATION, SECONDACCOUNTKEY, SECONDAMOUNT, ' +
        'ENTERDATE, '
      
        '   SPECIFICATION, CARGOSENDER, CARGORECIEVER, CONTRACT, PAPER, C' +
        'ARGOSENDDATE, '
      '   PAPERSENDDATE)'
      'values'
      
        '  (:DOCUMENTKEY, :ACCOUNTKEY, :CORRCOMPANYKEY, :CORRACCOUNTKEY, ' +
        ':OWNCOMPTEXT, '
      
        '   :OWNTAXID, :OWNCOUNTRY, :OWNBANKTEXT, :OWNBANKCITY, :OWNACCOU' +
        'NT, :OWNACCOUNTCODE, '
      
        '   :CORRCOMPTEXT, :CORRTAXID, :CORRCOUNTRY, :CORRBANKTEXT, :CORR' +
        'BANKCITY, '
      
        '   :CORRACCOUNT, :CORRACCOUNTCODE, :CORRSECACC, :AMOUNT, :PROC, ' +
        ':OPER, '
      
        '   :QUEUE, :DESTCODEKEY, :DESTCODE, :TERM, :DESTINATION, :SECOND' +
        'ACCOUNTKEY, '
      
        '   :SECONDAMOUNT, :ENTERDATE, :SPECIFICATION, :CARGOSENDER, :CAR' +
        'GORECIEVER, '
      '   :CONTRACT, :PAPER, :CARGOSENDDATE, :PAPERSENDDATE)')
    RefreshSQL.Strings = (
      'Select '
      '  DOCUMENTKEY,'
      '  ACCOUNTKEY,'
      '  CORRCOMPANYKEY,'
      '  CORRACCOUNTKEY,'
      '  OWNCOMPTEXT,'
      '  OWNTAXID,'
      '  OWNCOUNTRY,'
      '  OWNBANKTEXT,'
      '  OWNBANKCITY,'
      '  OWNACCOUNT,'
      '  OWNACCOUNTCODE,'
      '  CORRCOMPTEXT,'
      '  CORRTAXID,'
      '  CORRCOUNTRY,'
      '  CORRBANKTEXT,'
      '  CORRBANKCITY,'
      '  CORRACCOUNT,'
      '  CORRACCOUNTCODE,'
      '  CORRSECACC,'
      '  AMOUNT,'
      '  PROC,'
      '  OPER,'
      '  QUEUE,'
      '  DESTCODEKEY,'
      '  DESTCODE,'
      '  TERM,'
      '  DESTINATION,'
      '  SECONDACCOUNTKEY,'
      '  SECONDAMOUNT,'
      '  ENTERDATE,'
      '  SPECIFICATION,'
      '  CARGOSENDER,'
      '  CARGORECIEVER,'
      '  CONTRACT,'
      '  PAPER,'
      '  CARGOSENDDATE,'
      '  PAPERSENDDATE'
      'from BN_DEMANDPAYMENT '
      'where'
      '  DOCUMENTKEY = :DOCUMENTKEY')
    SelectSQL.Strings = (
      'SELECT'
      '  *'
      ''
      'FROM'
      '  BN_DEMANDPAYMENT')
    ModifySQL.Strings = (
      'update BN_DEMANDPAYMENT'
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
    ReadTransaction = ibtrPayments
    Left = 140
    Top = 130
  end
  object ibdsDocumentLink: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrPayments
    CachedUpdates = True
    DeleteSQL.Strings = (
      'delete from GD_DOCUMENTLINK'
      'where'
      '  SOURCEDOCKEY = :OLD_SOURCEDOCKEY and'
      '  DESTDOCKEY = :OLD_DESTDOCKEY')
    InsertSQL.Strings = (
      'insert into GD_DOCUMENTLINK'
      '  (SOURCEDOCKEY, DESTDOCKEY, SUMNCU, SUMCURR, SUMEQ, RESERVED)'
      'values'
      
        '  (:SOURCEDOCKEY, :DESTDOCKEY, :SUMNCU, :SUMCURR, :SUMEQ, :RESER' +
        'VED)')
    RefreshSQL.Strings = (
      'Select '
      '  SOURCEDOCKEY,'
      '  DESTDOCKEY,'
      '  SUMNCU,'
      '  SUMCURR,'
      '  SUMEQ,'
      '  RESERVED'
      'from GD_DOCUMENTLINK '
      'where'
      '  SOURCEDOCKEY = :SOURCEDOCKEY and'
      '  DESTDOCKEY = :DESTDOCKEY')
    SelectSQL.Strings = (
      'SELECT'
      '  *'
      ''
      'FROM'
      '  GD_DOCUMENTLINK')
    ModifySQL.Strings = (
      'update GD_DOCUMENTLINK'
      'set'
      '  SOURCEDOCKEY = :SOURCEDOCKEY,'
      '  DESTDOCKEY = :DESTDOCKEY,'
      '  SUMNCU = :SUMNCU,'
      '  SUMCURR = :SUMCURR,'
      '  SUMEQ = :SUMEQ,'
      '  RESERVED = :RESERVED'
      'where'
      '  SOURCEDOCKEY = :OLD_SOURCEDOCKEY and'
      '  DESTDOCKEY = :OLD_DESTDOCKEY')
    ReadTransaction = ibtrPayments
    Left = 170
    Top = 130
  end
  object ibdsDocument: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrPayments
    CachedUpdates = True
    DeleteSQL.Strings = (
      'delete from GD_DOCUMENT'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into GD_DOCUMENT'
      
        '  (ID, DOCUMENTTYPEKEY, TRTYPEKEY, NUMBER, DOCUMENTDATE, DESCRIP' +
        'TION, SUMNCU, '
      
        '   SUMCURR, SUMEQ, DELAYED, AFULL, ACHAG, AVIEW, CURRKEY, COMPAN' +
        'YKEY, CREATORKEY, '
      '   CREATIONDATE, EDITORKEY, EDITIONDATE, DISABLED, RESERVED)'
      'values'
      
        '  (:ID, :DOCUMENTTYPEKEY, :TRTYPEKEY, :NUMBER, :DOCUMENTDATE, :D' +
        'ESCRIPTION, '
      
        '   :SUMNCU, :SUMCURR, :SUMEQ, :DELAYED, :AFULL, :ACHAG, :AVIEW, ' +
        ':CURRKEY, '
      
        '   :COMPANYKEY, :CREATORKEY, :CREATIONDATE, :EDITORKEY, :EDITION' +
        'DATE, :DISABLED, '
      '   :RESERVED)')
    RefreshSQL.Strings = (
      'Select '
      '  ID,'
      '  DOCUMENTTYPEKEY,'
      '  TRTYPEKEY,'
      '  NUMBER,'
      '  DOCUMENTDATE,'
      '  DESCRIPTION,'
      '  SUMNCU,'
      '  SUMCURR,'
      '  SUMEQ,'
      '  DELAYED,'
      '  AFULL,'
      '  ACHAG,'
      '  AVIEW,'
      '  CURRKEY,'
      '  COMPANYKEY,'
      '  CREATORKEY,'
      '  CREATIONDATE,'
      '  EDITORKEY,'
      '  EDITIONDATE,'
      '  DISABLED,'
      '  RESERVED'
      'from GD_DOCUMENT '
      'where'
      '  ID = :ID')
    SelectSQL.Strings = (
      'SELECT'
      '  *'
      ''
      'FROM'
      '  GD_DOCUMENT')
    ModifySQL.Strings = (
      'update GD_DOCUMENT'
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
      '  DELAYED = :DELAYED,'
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
    ReadTransaction = ibtrPayments
    Left = 110
    Top = 130
  end
  object ibsqlCompany: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'SELECT '
      '  C.COUNTRY,  '
      '  COMP.FULLNAME,'
      '  CC.TAXID,'
      '  COMP.COMPANYACCOUNTKEY,'
      '  A.ACCOUNT'
      ''
      'FROM'
      '  GD_CONTACT C'
      ''
      '    JOIN GD_COMPANY COMP ON'
      '      C.ID = COMP.CONTACTKEY'
      ''
      '    JOIN GD_COMPANYACCOUNT A ON'
      '      A.ID = COMP.COMPANYACCOUNTKEY'
      ''
      '    LEFT JOIN GD_COMPANYCODE CC ON'
      '      C.ID = CC.COMPANYKEY    '
      ''
      'WHERE'
      '  C.ID = :CONTACTKEY')
    Transaction = ibtrPayments
    Left = 110
    Top = 180
  end
  object ibsqlBank: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'SELECT '
      '  COMP.FULLNAME,'
      '  C.CITY,'
      '  BANK.BANKCODE,'
      '  BANK.BANKKEY'
      ''
      'FROM'
      '  GD_COMPANYACCOUNT A,'
      ''
      '  GD_COMPANY COMP'
      ''
      '    JOIN GD_CONTACT C ON'
      '      COMP.CONTACTKEY = C.ID'
      ''
      '    JOIN GD_BANK BANK ON'
      '      COMP.CONTACTKEY = BANK.BANKKEY'
      ''
      'WHERE'
      '  A.ID = :ACCOUNTKEY'
      '    AND'
      '  COMP.CONTACTKEY = A.BANKKEY')
    Transaction = ibtrPayments
    Left = 140
    Top = 180
  end
  object ibsqlDestName: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'SELECT '
      '  *'
      'FROM'
      '  BN_DESTCODE'
      ''
      'WHERE'
      '  ID = :ID')
    Transaction = ibtrPayments
    Left = 170
    Top = 180
  end
  object dnPayment: TgsDocNumerator
    Database = dmDatabase.ibdbGAdmin
    DataSource = dsDocument
    DocumentType = 800100
    Left = 50
    Top = 130
  end
  object dsDocument: TDataSource
    DataSet = ibdsDocument
    Left = 80
    Top = 130
  end
end
