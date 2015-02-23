inherited ctl_dlgReceipt: Tctl_dlgReceipt
  Left = 243
  Top = 109
  Width = 463
  Height = 431
  BorderStyle = bsSizeable
  Caption = 'Приемная квитанция'
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnOk: TButton
    Left = 199
    Top = 379
    Anchors = [akRight, akBottom]
    ModalResult = 1
    TabOrder = 1
  end
  inherited btnCancel: TButton
    Left = 289
    Top = 379
    Anchors = [akRight, akBottom]
    ModalResult = 2
    TabOrder = 2
  end
  inherited btnHelp: TButton
    Left = 379
    Top = 379
    Anchors = [akRight, akBottom]
    TabOrder = 3
  end
  object pcReceipt: TPageControl [3]
    Left = 0
    Top = 0
    Width = 455
    Height = 372
    ActivePage = tsReceipt
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object tsReceipt: TTabSheet
      Caption = 'Реквизиты'
      object Bevel1: TBevel
        Left = 8
        Top = 10
        Width = 207
        Height = 136
        Shape = bsFrame
      end
      object lblNumber: TLabel
        Left = 22
        Top = 24
        Width = 35
        Height = 13
        Caption = 'Номер:'
      end
      object lblDate: TLabel
        Left = 22
        Top = 54
        Width = 30
        Height = 13
        Caption = 'Дата:'
      end
      object Label4: TLabel
        Left = 22
        Top = 78
        Width = 67
        Height = 27
        AutoSize = False
        Caption = 'Гуртовая ведомость:'
        WordWrap = True
      end
      object Label1: TLabel
        Left = 22
        Top = 110
        Width = 61
        Height = 28
        AutoSize = False
        Caption = 'Сумма по накладной:'
        WordWrap = True
      end
      object Label2: TLabel
        Left = 167
        Top = 154
        Width = 156
        Height = 13
        Anchors = [akTop, akRight]
        Caption = 'Итоговая сумма по квитанции:'
      end
      object dbeNumber: TDBEdit
        Left = 92
        Top = 21
        Width = 111
        Height = 21
        DataField = 'NUMBER'
        DataSource = dsDocument
        TabOrder = 0
      end
      object dbeDate: TDBEdit
        Left = 92
        Top = 52
        Width = 111
        Height = 21
        DataField = 'DOCUMENTDATE'
        DataSource = dsDocument
        TabOrder = 1
      end
      object dbeSheet: TDBEdit
        Left = 92
        Top = 82
        Width = 111
        Height = 21
        DataField = 'REGISTERSHEET'
        DataSource = dsReceipt
        TabOrder = 2
      end
      object ibgrdReceiptLine: TgsIBCtrlGrid
        Left = 8
        Top = 177
        Width = 430
        Height = 159
        Anchors = [akLeft, akTop, akRight, akBottom]
        DataSource = dsInvoiceLines
        Options = [dgEditing, dgTitles, dgColumnResize, dgColLines, dgRowLines, dgAlwaysShowSelection, dgCancelOnExit]
        TabOrder = 6
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
            Alias = 'DESTINATION'
            LName = 'Назначение'
          end
          item
            Alias = 'GOODNAME'
            LName = 'Скот(мясо)'
          end>
      end
      object dbeSumTotal: TDBEdit
        Left = 92
        Top = 113
        Width = 111
        Height = 21
        DataField = 'SUMTOTAL'
        DataSource = dsReceipt
        TabOrder = 3
      end
      object atContainer: TatContainer
        Left = 220
        Top = 10
        Width = 218
        Height = 136
        DataSource = dsReceipt
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 4
      end
      object dbeSumNCU: TDBEdit
        Left = 327
        Top = 151
        Width = 111
        Height = 21
        Anchors = [akTop, akRight]
        DataField = 'SUMNCU'
        DataSource = dsReceipt
        TabOrder = 5
      end
    end
  end
  object Button1: TButton [4]
    Left = 4
    Top = 379
    Width = 75
    Height = 21
    Action = actCompute
    Anchors = [akLeft, akBottom]
    TabOrder = 4
  end
  inherited ActionList: TActionList
    Images = dmImages.ilToolBarSmall
    Left = 370
    Top = 130
    object actNew: TAction
      Category = 'Master'
      Caption = 'Добавить'
      Hint = 'Добавить'
      ImageIndex = 0
    end
    object actEdit: TAction
      Category = 'Master'
      Caption = 'Редактировать'
      Hint = 'Редактировать'
      ImageIndex = 1
    end
    object actDelete: TAction
      Category = 'Master'
      Caption = 'Удалить'
      Hint = 'Удалить'
      ImageIndex = 2
    end
    object actCopy: TAction
      Category = 'Master'
      Caption = 'Копировать'
      Hint = 'Копировать'
      ImageIndex = 3
    end
    object actCompute: TAction
      Caption = 'Рассчитать'
      OnExecute = actComputeExecute
    end
  end
  object dsReceipt: TDataSource
    DataSet = ibdsReceipt
    Left = 280
    Top = 40
  end
  object ibtrReceipt: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 400
    Top = 70
  end
  object ibdsReceipt: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrReceipt
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
      'Select '
      '  DOCUMENTKEY,'
      '  REGISTERSHEET,'
      '  SUMTOTAL,'
      '  SUMNCU,'
      '  RESERVED'
      'from CTL_RECEIPT '
      'where'
      '  DOCUMENTKEY = :DOCUMENTKEY')
    SelectSQL.Strings = (
      'SELECT'
      '  D.NUMBER,'
      '  D.DOCUMENTDATE,  '
      '  R.*'
      ''
      'FROM'
      '  CTL_RECEIPT R'
      ''
      '    JOIN GD_DOCUMENT D ON'
      '      R.DOCUMENTKEY = D.ID'
      ''
      'WHERE'
      '  R.DOCUMENTKEY = :DOCUMENTKEY')
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
    Left = 280
    Top = 70
  end
  object ibdsInvoiceLine: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrReceipt
    AfterInsert = ibdsInvoiceLineAfterInsert
    DeleteSQL.Strings = (
      'delete from CTL_INVOICEPOS'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into CTL_INVOICEPOS'
      
        '  (ID, QUANTITY, MEATWEIGHT, LIVEWEIGHT, REALWEIGHT, PRICE, SUMN' +
        'CU)'
      'values'
      
        '  (:ID, :QUANTITY, :MEATWEIGHT, :LIVEWEIGHT, :REALWEIGHT, :PRICE' +
        ', :SUMNCU)')
    RefreshSQL.Strings = (
      'Select '
      '  ID,'
      '  INVOICEKEY,'
      '  GOODKEY,'
      '  QUANTITY,'
      '  MEATWEIGHT,'
      '  LIVEWEIGHT,'
      '  REALWEIGHT,'
      '  DESTKEY,'
      '  PRICEKEY,'
      '  PRICE,'
      '  SUMNCU,'
      '  AFULL,'
      '  ACHAG,'
      '  AVIEW,'
      '  DISABLED,'
      '  RESERVED'
      'from CTL_INVOICEPOS '
      'where'
      '  ID = :ID')
    SelectSQL.Strings = (
      'SELECT '
      '  G.NAME AS GOODNAME,'
      '  R.NAME AS DESTINATION,'
      '  P.QUANTITY, P.MEATWEIGHT, P.LIVEWEIGHT, '
      '  P.REALWEIGHT, P.PRICE, P.SUMNCU, P.ID'
      ''
      'FROM'
      '  CTL_INVOICE I,'
      '  CTL_INVOICEPOS P'
      ''
      '    JOIN GD_GOOD G ON'
      '      P.GOODKEY = G.ID'
      ''
      '    JOIN CTL_REFERENCE R ON'
      '      P.DESTKEY = R.ID'
      ''
      'WHERE'
      '  I.RECEIPTKEY = :DOCUMENTKEY '
      '    AND'
      '  P.INVOICEKEY = I.DOCUMENTKEY')
    ModifySQL.Strings = (
      'update CTL_INVOICEPOS'
      'set'
      '  ID = :ID,'
      '  QUANTITY = :QUANTITY,'
      '  MEATWEIGHT = :MEATWEIGHT,'
      '  LIVEWEIGHT = :LIVEWEIGHT,'
      '  REALWEIGHT = :REALWEIGHT,'
      '  PRICE = :PRICE,'
      '  SUMNCU = :SUMNCU'
      'where'
      '  ID = :OLD_ID')
    Left = 370
    Top = 70
  end
  object dsInvoiceLines: TDataSource
    DataSet = ibdsInvoiceLine
    Left = 370
    Top = 40
  end
  object dsDocument: TDataSource
    DataSet = ibdsDocument
    Left = 250
    Top = 40
  end
  object ibdsDocument: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrReceipt
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
      '  GD_DOCUMENT'
      ''
      'WHERE'
      '  ID = :DOCUMENTKEY')
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
    Left = 250
    Top = 70
  end
  object FormPlaceSaver: TFormPlaceSaver
    OnlyForm = True
    Left = 370
    Top = 100
  end
  object atSQLSetup: TatSQLSetup
    Ignores = <
      item
        Link = ibdsDocument
        RelationName = 'GD_DOCUMENT'
        IgnoryType = itFull
      end
      item
        Link = ibdsInvoiceLine
        RelationName = 'GD_CONTACT'
        IgnoryType = itFull
      end
      item
        Link = ibdsInvoiceLine
        RelationName = 'GD_GOOD'
        IgnoryType = itFull
      end
      item
        Link = ibdsInvoiceLine
        RelationName = 'CTL_INVOICE'
        IgnoryType = itFull
      end>
    Left = 400
    Top = 130
  end
  object ibdsInvoice: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrReceipt
    SelectSQL.Strings = (
      'SELECT'
      '  *'
      ''
      'FROM'
      '  CTL_INVOICE I'
      ''
      'WHERE'
      '  I.RECEIPTKEY = :RECEIPTKEY'
      '  ')
    Left = 310
    Top = 70
  end
  object DataSource1: TDataSource
    DataSet = ibdsInvoice
    Left = 310
    Top = 40
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
    Left = 252
    Top = 104
  end
end
