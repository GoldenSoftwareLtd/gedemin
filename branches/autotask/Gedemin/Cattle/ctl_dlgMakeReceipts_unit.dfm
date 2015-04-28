object ctl_dlgMakeReceipts: Tctl_dlgMakeReceipts
  Left = 338
  Top = 186
  Width = 467
  Height = 330
  Caption = 'Создание приемных квитанций'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 264
    Width = 459
    Height = 39
    Align = alBottom
    BevelOuter = bvNone
    BorderWidth = 2
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object Bevel1: TBevel
      Left = 2
      Top = 2
      Width = 455
      Height = 2
      Align = alTop
    end
    object btnOk: TButton
      Left = 300
      Top = 10
      Width = 75
      Height = 25
      Action = actOk
      Anchors = [akTop, akRight]
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 380
      Top = 10
      Width = 75
      Height = 25
      Action = actCancel
      Anchors = [akTop, akRight]
      Cancel = True
      ModalResult = 2
      TabOrder = 1
    end
    object btnSetup: TButton
      Left = 3
      Top = 10
      Width = 75
      Height = 25
      Action = actSetup
      TabOrder = 2
    end
  end
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 459
    Height = 264
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 2
    TabOrder = 1
    object Panel3: TPanel
      Left = 2
      Top = 2
      Width = 455
      Height = 260
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      object Panel4: TPanel
        Left = 0
        Top = 0
        Width = 455
        Height = 18
        Align = alTop
        Alignment = taLeftJustify
        BevelInner = bvLowered
        Caption = ' Список новых квитанций'
        TabOrder = 0
      end
      object ibgrInvoice: TgsIBGrid
        Left = 0
        Top = 18
        Width = 455
        Height = 242
        Align = alClient
        BorderStyle = bsNone
        DataSource = dsInvoice
        Options = [dgTitles, dgColumnResize, dgColLines, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
        PopupMenu = pmList
        TabOrder = 1
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        TitlesExpanding = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.Visible = False
        CheckBox.FirstColumn = False
        MinColWidth = 40
        ColumnEditors = <>
        Aliases = <
          item
            Alias = 'DEPARTMENT'
            LName = 'Подразделение'
          end
          item
            Alias = 'FACE'
            LName = 'Физ.лицо'
          end
          item
            Alias = 'SUPPLIER'
            LName = 'Поставщик'
          end
          item
            Alias = 'RECEIVING'
            LName = 'Вид поставки'
          end>
      end
    end
  end
  object alMain: TActionList
    Images = dmImages.ilToolBarSmall
    Left = 290
    Top = 60
    object actOk: TAction
      Caption = 'Ok'
      OnExecute = actOkExecute
      OnUpdate = actOkUpdate
    end
    object actCancel: TAction
      Caption = 'Отменить'
      OnExecute = actCancelExecute
    end
    object actSetup: TAction
      Caption = 'Настройка'
      Hint = 'Настройка расчета'
      OnExecute = actSetupExecute
    end
  end
  object ibtrNewReceipt: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 290
    Top = 170
  end
  object dsReceipt: TDataSource
    DataSet = ibdsReceipt
    Left = 100
    Top = 120
  end
  object ibdsReceipt: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrNewReceipt
    CachedUpdates = True
    DeleteSQL.Strings = (
      'delete from CTL_RECEIPT'
      'where'
      '  DOCUMENTKEY = :OLD_DOCUMENTKEY')
    InsertSQL.Strings = (
      'insert into CTL_RECEIPT'
      '  (DOCUMENTKEY, REGISTERSHEET, SUMTOTAL, SUMNCU, RESERVED)'
      'values'
      '  (:DOCUMENTKEY, :REGISTERSHEET, :SUMTOTAL, :SUMNCU, :RESERVED)')
    RefreshSQL.Strings = (
      '')
    SelectSQL.Strings = (
      'SELECT'
      '  *'
      ''
      'FROM '
      '  CTL_RECEIPT')
    ModifySQL.Strings = (
      'update CTL_RECEIPT'
      'set'
      '  DOCUMENTKEY = :DOCUMENTKEY,'
      '  REGISTERSHEET = :REGISTERSHEET,'
      '  SUMTOTAL = :SUMTOTAL,'
      '  SUMNCU = :SUMNCU,'
      '  RESERVED = :RESERVED'
      'where'
      '  DOCUMENTKEY = :OLD_DOCUMENTKEY')
    ReadTransaction = ibtrNewReceipt
    Left = 130
    Top = 120
  end
  object ibsqlPricePos: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'SELECT'
      '  PP.*, p.relevancedate'
      ''
      'FROM'
      '  GD_PRICEPOS PP'
      '    JOIN'
      '      GD_PRICE P'
      '    ON'
      '      P.ID = PP.PRICEKEY'
      ''
      'WHERE'
      '  P.PRICETYPE = '#39'P'#39
      '    AND'
      '  PP.GOODKEY = :GOODKEY'
      '   AND'
      '  P.CONTACTKEY IS NULL'
      '    AND'
      '  P.RELEVANCEDATE ='
      '  ('
      '    SELECT '
      '       MAX(P2.RELEVANCEDATE) '
      '    '
      '    FROM '
      '      GD_PRICE P2'
      '        JOIN GD_PRICEPOS PP2 ON'
      '          P2.ID = PP2.PRICEKEY'
      ''
      '    WHERE  '
      '      P2.RELEVANCEDATE <= :INVOICEDATE'
      '         AND'
      '      P2.CONTACTKEY IS NULL'
      '        AND'
      '      PP2.GOODKEY = PP.GOODKEY'
      '  )')
    Transaction = ibtrNewReceipt
    Left = 290
    Top = 90
  end
  object ibsqlContactProps: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'SELECT'
      '  *'
      ''
      'FROM'
      '  GD_CONTACTPROPS P'
      ''
      'WHERE'
      '  P.CONTACTKEY = :CONTACTKEY')
    Transaction = ibtrNewReceipt
    Left = 290
    Top = 140
  end
  object ibdsDocument: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrNewReceipt
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
    SelectSQL.Strings = (
      'SELECT '
      '  *'
      ''
      'FROM '
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
    ReadTransaction = ibtrNewReceipt
    Left = 130
    Top = 90
  end
  object dsDocument: TDataSource
    DataSet = ibdsDocument
    Left = 100
    Top = 90
  end
  object ibdsInvoiceLine: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrNewReceipt
    CachedUpdates = True
    DeleteSQL.Strings = (
      'delete from CTL_INVOICEPOS'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into CTL_INVOICEPOS'
      
        '  (ID, INVOICEKEY, GOODKEY, QUANTITY, MEATWEIGHT, LIVEWEIGHT, RE' +
        'ALWEIGHT, '
      
        '   DESTKEY, PRICEKEY, PRICE, SUMNCU, AFULL, ACHAG, AVIEW, DISABL' +
        'ED, RESERVED)'
      'values'
      
        '  (:ID, :INVOICEKEY, :GOODKEY, :QUANTITY, :MEATWEIGHT, :LIVEWEIG' +
        'HT, :REALWEIGHT, '
      
        '   :DESTKEY, :PRICEKEY, :PRICE, :SUMNCU, :AFULL, :ACHAG, :AVIEW,' +
        ' :DISABLED, '
      '   :RESERVED)')
    SelectSQL.Strings = (
      'SELECT'
      '  I.*'
      ''
      'FROM '
      '  CTL_INVOICEPOS I'
      ''
      'WHERE'
      '  I.INVOICEKEY = :DOCUMENTKEY')
    ModifySQL.Strings = (
      'update CTL_INVOICEPOS'
      'set'
      '  ID = :ID,'
      '  INVOICEKEY = :INVOICEKEY,'
      '  GOODKEY = :GOODKEY,'
      '  QUANTITY = :QUANTITY,'
      '  MEATWEIGHT = :MEATWEIGHT,'
      '  LIVEWEIGHT = :LIVEWEIGHT,'
      '  REALWEIGHT = :REALWEIGHT,'
      '  DESTKEY = :DESTKEY,'
      '  PRICEKEY = :PRICEKEY,'
      '  PRICE = :PRICE,'
      '  SUMNCU = :SUMNCU,'
      '  AFULL = :AFULL,'
      '  ACHAG = :ACHAG,'
      '  AVIEW = :AVIEW,'
      '  DISABLED = :DISABLED,'
      '  RESERVED = :RESERVED'
      'where'
      '  ID = :OLD_ID')
    ReadTransaction = ibtrNewReceipt
    Left = 50
    Top = 120
  end
  object dsInvoiceLine: TDataSource
    DataSet = ibdsInvoiceLine
    Left = 20
    Top = 120
  end
  object ibdsInvoice: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrNewReceipt
    CachedUpdates = True
    DeleteSQL.Strings = (
      'delete from CTL_INVOICE'
      'where'
      '  DOCUMENTKEY = :OLD_DOCUMENTKEY')
    InsertSQL.Strings = (
      'insert into CTL_INVOICE'
      
        '  (DOCUMENTKEY, NUMBER, DOCUMENTDATE, SUPPLIER, SUPPLIERKEY, KIN' +
        'D, PURCHASEKIND, '
      '   DELIVERYKIND, RECEIPTKEY, WASTECOUNT)'
      'values'
      
        '  (:DOCUMENTKEY, :NUMBER, :DOCUMENTDATE, :SUPPLIER, :SUPPLIERKEY' +
        ', :KIND, '
      '   :PURCHASEKIND, :DELIVERYKIND, :RECEIPTKEY, :WASTECOUNT)')
    SelectSQL.Strings = (
      'SELECT'
      '  I.DOCUMENTKEY,'
      '  D.NUMBER, D.DOCUMENTDATE, '
      '  C.NAME AS SUPPLIER,'
      '  C.CONTACTTYPE,'
      '  I.SUPPLIERKEY,'
      '  I.KIND,'
      '  I.PURCHASEKIND,'
      '  I.DELIVERYKIND,'
      '  I.RECEIPTKEY,'
      '  I.WASTECOUNT,'
      '  I.TTNNUMBER'
      ''
      'FROM'
      '  CTL_INVOICE I'
      '    JOIN GD_DOCUMENT D ON'
      '      D.ID = I.DOCUMENTKEY'
      ''
      '    JOIN GD_CONTACT C ON'
      '      C.ID = I.SUPPLIERKEY'
      ''
      'WHERE'
      '  I.RECEIPTKEY IS NULL'
      ''
      'ORDER BY'
      '  D.DOCUMENTDATE DESC, I.SUPPLIERKEY')
    ModifySQL.Strings = (
      'update CTL_INVOICE'
      'set'
      '  DOCUMENTKEY = :DOCUMENTKEY,'
      '  NUMBER = :NUMBER,'
      '  DOCUMENTDATE = :DOCUMENTDATE,'
      '  SUPPLIER = :SUPPLIER,'
      '  SUPPLIERKEY = :SUPPLIERKEY,'
      '  KIND = :KIND,'
      '  PURCHASEKIND = :PURCHASEKIND,'
      '  DELIVERYKIND = :DELIVERYKIND,'
      '  RECEIPTKEY = :RECEIPTKEY,'
      '  WASTECOUNT = :WASTECOUNT'
      'where'
      '  DOCUMENTKEY = :OLD_DOCUMENTKEY')
    ReadTransaction = ibtrNewReceipt
    Left = 50
    Top = 90
  end
  object dsInvoice: TDataSource
    DataSet = ibdsInvoice
    Left = 20
    Top = 90
  end
  object Calculator: TxFoCal
    Expression = '0'
    Left = 260
    Top = 60
    _variables_ = (
      'PI'
      3.14159265358979
      'E'
      2.71828182845905)
  end
  object atSQLSetup: TatSQLSetup
    Ignores = <
      item
        Link = ibdsDocument
        RelationName = 'GD_DOCUMENT'
        IgnoryType = itFull
      end
      item
        Link = ibdsInvoice
        RelationName = 'CTL_INVOICE'
        IgnoryType = itFull
      end
      item
        Link = ibdsInvoiceLine
        RelationName = 'CTL_INVOICELINE'
        IgnoryType = itFull
      end>
    Left = 260
    Top = 90
  end
  object ibsqlAutoTariff: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'SELECT'
      '  A.*'
      ''
      'FROM'
      '  CTL_AUTOTARIFF A'
      '  '
      'WHERE'
      '  A.DISTANCE = :DISTANCE'
      '  AND'
      '  A.CARGOCLASS = 1')
    Transaction = ibtrNewReceipt
    Left = 260
    Top = 140
  end
  object FormPlaceSaver: TFormPlaceSaver
    OnlyForm = True
    Left = 230
    Top = 90
  end
  object dnReceipt: TgsDocNumerator
    Database = dmDatabase.ibdbGAdmin
    DocumentType = 803101
    Left = 130
    Top = 60
  end
  object pmList: TPopupMenu
    Left = 107
    Top = 187
    object N1: TMenuItem
      Caption = 'Выделить все'
      ShortCut = 16449
      OnClick = N1Click
    end
    object N2: TMenuItem
      Caption = 'Снять выделения'
      OnClick = N2Click
    end
  end
  object gsTransaction: TgsTransaction
    DocumentType = 803101
    DataSource = dsDocument
    FieldName = 'TRTYPEKEY'
    FieldKey = 'ID'
    FieldTrName = 'TRANSACTIONNAME'
    FieldDocumentKey = 'ID'
    BeginTransactionType = btManual
    DocumentOnly = False
    MakeDelayedEntry = False
    Left = 320
    Top = 60
  end
  object ibsqlCustomerPricePos: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'SELECT'
      '  PP.*, p.relevancedate'
      ''
      'FROM'
      '  GD_PRICEPOS PP'
      '    JOIN'
      '      GD_PRICE P'
      '    ON'
      '      P.ID = PP.PRICEKEY'
      ''
      'WHERE'
      '  P.PRICETYPE = '#39'P'#39
      '    AND'
      '  PP.GOODKEY = :GOODKEY'
      '    AND '
      '  P.CONTACTKEY = :CONTACTKEY'
      '    AND'
      '  P.RELEVANCEDATE ='
      '  ('
      '    SELECT '
      '       MAX(P2.RELEVANCEDATE) '
      '    '
      '    FROM '
      '      GD_PRICE P2'
      '        JOIN GD_PRICEPOS PP2 ON'
      '          P2.ID = PP2.PRICEKEY'
      ''
      '    WHERE  '
      '      P2.RELEVANCEDATE <= :INVOICEDATE'
      '        AND'
      '      P2.CONTACTKEY = :CONTACTKEY2'
      '        AND'
      '      PP2.GOODKEY = PP.GOODKEY'
      '  )')
    Transaction = ibtrNewReceipt
    Left = 320
    Top = 90
  end
  object ibsqlDeleteReceipt: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'DELETE FROM gd_document WHERE id = :documentkey')
    Transaction = ibtrNewReceipt
    Left = 320
    Top = 140
  end
  object ibdsGoodGroup: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrNewReceipt
    SelectSQL.Strings = (
      'select gg.*'
      'from gd_goodgroup gg JOIN gd_good g ON gg.id=g.groupkey'
      'where g.id=:ID')
    ReadTransaction = ibtrNewReceipt
    Left = 178
    Top = 162
  end
end
