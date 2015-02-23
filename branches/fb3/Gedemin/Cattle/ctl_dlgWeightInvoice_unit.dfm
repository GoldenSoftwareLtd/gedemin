object ctl_dlgWeightInvoice: Tctl_dlgWeightInvoice
  Left = 353
  Top = 161
  ActiveControl = edQuantity
  BorderStyle = bsDialog
  Caption = 'Отвес-накладная'
  ClientHeight = 357
  ClientWidth = 411
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
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
  object pnlButtons: TPanel
    Left = 0
    Top = 320
    Width = 411
    Height = 37
    Align = alBottom
    BevelOuter = bvNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object btnOk: TButton
      Left = 252
      Top = 6
      Width = 75
      Height = 25
      Action = actOk
      Anchors = [akTop, akRight]
      Caption = '&Ок'
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 332
      Top = 6
      Width = 75
      Height = 25
      Action = actCancel
      Anchors = [akTop, akRight]
      Cancel = True
      TabOrder = 1
    end
    object btnNext: TButton
      Left = 8
      Top = 6
      Width = 75
      Height = 25
      Action = actNext
      Default = True
      TabOrder = 2
    end
  end
  object pcInvoice: TPageControl
    Left = 0
    Top = 0
    Width = 411
    Height = 320
    ActivePage = tsInvoicePos
    Align = alClient
    TabOrder = 1
    OnChange = cbKindChange
    object tsInvoice: TTabSheet
      Caption = '&1 Реквизиты'
      object Bevel3: TBevel
        Left = 3
        Top = 213
        Width = 396
        Height = 74
        Anchors = [akLeft, akTop, akRight]
        Shape = bsFrame
      end
      object Bevel2: TBevel
        Left = 3
        Top = 85
        Width = 396
        Height = 124
        Anchors = [akLeft, akTop, akRight]
        Shape = bsFrame
      end
      object Bevel1: TBevel
        Left = 3
        Top = 2
        Width = 396
        Height = 79
        Anchors = [akLeft, akTop, akRight]
        Shape = bsFrame
      end
      object lblDate: TLabel
        Left = 18
        Top = 11
        Width = 30
        Height = 13
        Caption = 'Дата:'
      end
      object lblDepartment: TLabel
        Left = 18
        Top = 57
        Width = 84
        Height = 13
        Caption = 'Подразделение:'
      end
      object lblNumber: TLabel
        Left = 18
        Top = 34
        Width = 75
        Height = 13
        Caption = '№ накладной:'
      end
      object lblTTN: TLabel
        Left = 203
        Top = 11
        Width = 39
        Height = 13
        Caption = '№ ТТН:'
      end
      object lblPurchaseKind: TLabel
        Left = 18
        Top = 92
        Width = 67
        Height = 13
        Caption = 'Вид закупки:'
      end
      object lblSuplier: TLabel
        Left = 18
        Top = 139
        Width = 61
        Height = 13
        Caption = 'Поставщик:'
      end
      object lblDeliveryKind: TLabel
        Left = 18
        Top = 222
        Width = 74
        Height = 13
        Caption = 'Вид доставки:'
      end
      object lblWasteCount: TLabel
        Left = 18
        Top = 246
        Width = 83
        Height = 28
        AutoSize = False
        Caption = 'Головы с пороками:'
        WordWrap = True
      end
      object lblKind: TLabel
        Left = 203
        Top = 34
        Width = 81
        Height = 13
        Caption = 'Вид накладной:'
      end
      object Label1: TLabel
        Left = 115
        Top = 162
        Width = 62
        Height = 13
        Caption = 'Расстояние:'
      end
      object Label2: TLabel
        Left = 186
        Top = 162
        Width = 60
        Height = 13
        Caption = 'С/Х скидка:'
      end
      object Label3: TLabel
        Left = 252
        Top = 162
        Width = 66
        Height = 13
        Caption = 'Ставка НДС:'
      end
      object lblDestination: TLabel
        Left = 181
        Top = 245
        Width = 63
        Height = 26
        Caption = 'Вид назначения:'
        WordWrap = True
      end
      object Label8: TLabel
        Left = 327
        Top = 162
        Width = 64
        Height = 13
        Caption = 'НДС трансп:'
      end
      object Label11: TLabel
        Left = 18
        Top = 116
        Width = 34
        Height = 13
        Caption = 'Район:'
      end
      object luDepartment: TgsIBLookupComboBox
        Left = 115
        Top = 54
        Width = 276
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrInvoice
        DataSource = dsInvoice
        DataField = 'DEPARTMENTKEY'
        ListTable = 'gd_contact'
        ListField = 'name'
        KeyField = 'id'
        Condition = 'contacttype=4'
        gdClassName = 'TgdcDepartment'
        ItemHeight = 0
        ParentShowHint = False
        ShowHint = True
        TabOrder = 4
      end
      object dbeDate: TxDateDBEdit
        Left = 115
        Top = 8
        Width = 81
        Height = 21
        DataField = 'DOCUMENTDATE'
        DataSource = dsDocument
        Kind = kDate
        EditMask = '!99\.99\.9999;1;_'
        MaxLength = 10
        TabOrder = 0
      end
      object dbeNumber: TDBEdit
        Left = 115
        Top = 31
        Width = 81
        Height = 21
        DataField = 'NUMBER'
        DataSource = dsDocument
        TabOrder = 1
      end
      object dbeTTN: TDBEdit
        Left = 310
        Top = 8
        Width = 81
        Height = 21
        DataField = 'TTNNUMBER'
        DataSource = dsInvoice
        TabOrder = 2
      end
      object luSupplier: TgsIBLookupComboBox
        Left = 115
        Top = 139
        Width = 275
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrInvoice
        DataSource = dsInvoice
        DataField = 'SUPPLIERKEY'
        ListTable = 'gd_contact'
        ListField = 'name'
        KeyField = 'id'
        ItemHeight = 0
        ParentShowHint = False
        ShowHint = True
        TabOrder = 7
        OnChange = luSupplierChange
      end
      object dbeWasteCount: TDBEdit
        Left = 115
        Top = 249
        Width = 61
        Height = 21
        DataField = 'WASTECOUNT'
        DataSource = dsInvoice
        TabOrder = 14
      end
      object cbForceSlaughter: TDBCheckBox
        Left = 265
        Top = 221
        Width = 123
        Height = 17
        Alignment = taLeftJustify
        Caption = 'Вынужденный убой'
        DataField = 'FORCESLAUGHTER'
        DataSource = dsInvoice
        TabOrder = 13
        ValueChecked = '1'
        ValueUnchecked = '0'
        OnKeyPress = cbForceSlaughterKeyPress
      end
      object cbPurchaseKind: TComboBox
        Left = 115
        Top = 91
        Width = 186
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 5
        OnChange = cbPurchaseKindChange
        Items.Strings = (
          'гос. закупка'
          'закупка у населения'
          'частный сектор')
      end
      object cbDeliveryKind: TComboBox
        Left = 115
        Top = 219
        Width = 134
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 12
        Items.Strings = (
          'центровывоз'
          'самовызов'
          'самовывоз разгрузочный пост')
      end
      object cbKind: TComboBox
        Left = 310
        Top = 31
        Width = 81
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 3
        OnChange = cbKindChange
        Items.Strings = (
          'на скот'
          'на мясо')
      end
      object dbeDistance: TDBEdit
        Left = 115
        Top = 177
        Width = 66
        Height = 21
        DataSource = dsContactProps
        TabOrder = 8
      end
      object dbeFarmTax: TDBEdit
        Left = 186
        Top = 177
        Width = 60
        Height = 21
        DataSource = dsContactProps
        TabOrder = 9
      end
      object dbeVAT: TDBEdit
        Left = 250
        Top = 177
        Width = 71
        Height = 21
        DataSource = dsContactProps
        TabOrder = 10
      end
      object luDestination: TgsIBLookupComboBox
        Left = 252
        Top = 249
        Width = 138
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrInvoice
        ListTable = 'CTL_REFERENCE'
        ListField = 'NAME'
        KeyField = 'ID'
        Condition = 'PARENT = 2000'
        ItemHeight = 0
        ParentShowHint = False
        ShowHint = True
        TabOrder = 15
      end
      object dbeNDSTrans: TDBEdit
        Left = 325
        Top = 177
        Width = 66
        Height = 21
        DataSource = dsContactProps
        TabOrder = 11
      end
      object luRegion: TgsIBLookupComboBox
        Left = 115
        Top = 115
        Width = 275
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrInvoice
        ListTable = 'gd_place'
        ListField = 'name'
        KeyField = 'id'
        Condition = 'placetype = '#39'Район'#39
        gdClassName = 'TgdcPlace'
        ItemHeight = 0
        ParentShowHint = False
        ShowHint = True
        TabOrder = 6
        OnChange = luRegionChange
      end
    end
    object tsInvoicePos: TTabSheet
      Caption = '&2 Приемка продукции'
      ImageIndex = 1
      object cbMain: TControlBar
        Left = 0
        Top = 65
        Width = 403
        Height = 26
        Align = alTop
        AutoDock = False
        AutoSize = True
        BevelEdges = [beBottom]
        BevelInner = bvNone
        BevelOuter = bvNone
        BevelKind = bkNone
        Color = clBtnFace
        DockSite = False
        ParentColor = False
        TabOrder = 1
        object tbMain: TToolBar
          Left = 11
          Top = 2
          Width = 376
          Height = 22
          AutoSize = True
          EdgeBorders = []
          Flat = True
          Images = dmImages.ilToolBarSmall
          TabOrder = 0
          object tbtNew: TToolButton
            Left = 0
            Top = 0
            Action = actNew
            ParentShowHint = False
            ShowHint = True
          end
          object tbtEdit: TToolButton
            Left = 23
            Top = 0
            Action = actEdit
            ParentShowHint = False
            ShowHint = True
          end
          object tbtDelete: TToolButton
            Left = 46
            Top = 0
            Action = actDelete
            ParentShowHint = False
            ShowHint = True
          end
          object tbtDuplicate: TToolButton
            Left = 69
            Top = 0
            Action = actDuplicate
            ParentShowHint = False
            ShowHint = True
          end
        end
      end
      object ibgrdInvoiceLine: TgsIBCtrlGrid
        Left = 0
        Top = 91
        Width = 403
        Height = 160
        Align = alClient
        DataSource = dsInvoiceLine
        Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgAlwaysShowSelection, dgCancelOnExit]
        TabOrder = 2
        OnDblClick = ibgrdInvoiceLineDblClick
        OnEnter = ibgrdInvoiceLineEnter
        RefreshType = rtNone
        Striped = False
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
            Alias = 'DESTNAME'
            LName = 'Назначение'
          end
          item
            Alias = 'GOODNAME'
            LName = 'Скот(мясо)'
          end>
      end
      object gbTotal: TGroupBox
        Left = 0
        Top = 251
        Width = 403
        Height = 41
        Align = alBottom
        Caption = 'Итого'
        Ctl3D = False
        ParentCtl3D = False
        TabOrder = 3
        object Label4: TLabel
          Left = 5
          Top = 11
          Width = 71
          Height = 13
          Caption = 'Кол-во голов:'
        end
        object Label5: TLabel
          Left = 5
          Top = 24
          Width = 78
          Height = 13
          Caption = 'Убойная масса:'
        end
        object lbQuantity: TLabel
          Left = 85
          Top = 11
          Width = 6
          Height = 13
          Caption = '0'
        end
        object lbMeatWeight: TLabel
          Left = 85
          Top = 24
          Width = 6
          Height = 13
          Caption = '0'
        end
        object Label6: TLabel
          Left = 175
          Top = 11
          Width = 58
          Height = 13
          Caption = 'Живой вес:'
        end
        object Label7: TLabel
          Left = 175
          Top = 23
          Width = 117
          Height = 13
          Caption = 'Живой вес со скидкой:'
        end
        object lbLiveWeight: TLabel
          Left = 295
          Top = 11
          Width = 6
          Height = 13
          Caption = '0'
        end
        object lbRealWeight: TLabel
          Left = 295
          Top = 23
          Width = 6
          Height = 13
          Caption = '0'
        end
      end
      object pnlControlValues: TPanel
        Left = 0
        Top = 0
        Width = 403
        Height = 65
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object Label9: TLabel
          Left = 5
          Top = 14
          Width = 71
          Height = 13
          Caption = 'Кол-во голов:'
        end
        object lbWeight: TLabel
          Left = 5
          Top = 39
          Width = 78
          Height = 13
          Caption = 'Убойная масса:'
        end
        object edQuantity: TEdit
          Left = 148
          Top = 10
          Width = 121
          Height = 21
          TabOrder = 0
          Text = '0'
        end
        object edMeatWeight: TEdit
          Left = 148
          Top = 35
          Width = 121
          Height = 21
          TabOrder = 1
          Text = '0'
        end
      end
    end
  end
  object alMain: TActionList
    Images = dmImages.ilToolBarSmall
    Left = 381
    Top = 328
    object actNew: TAction
      Category = 'Master'
      Caption = 'actNew'
      Hint = 'Создать новую запись'
      ImageIndex = 0
      ShortCut = 45
      OnExecute = actNewExecute
      OnUpdate = actNewUpdate
    end
    object actEdit: TAction
      Category = 'Master'
      Caption = 'actEdit'
      Hint = 'Изменить текущую запись'
      ImageIndex = 1
      ShortCut = 16429
      OnExecute = actEditExecute
    end
    object actDelete: TAction
      Category = 'Master'
      Caption = 'actDelete'
      Hint = 'Удалить текущую запись'
      ImageIndex = 2
      ShortCut = 16430
      OnExecute = actDeleteExecute
    end
    object actDuplicate: TAction
      Category = 'Master'
      Caption = 'actDuplicate'
      Hint = 'Создать копию текущей записи'
      ImageIndex = 3
    end
    object actOk: TAction
      Caption = 'Ok'
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Caption = 'Отменить'
      OnExecute = actCancelExecute
    end
    object actNext: TAction
      Caption = 'Дальше'
      OnExecute = actNextExecute
    end
    object actChangeParams: TAction
      Caption = 'actChangeParams'
      Hint = 'Изменение параметров накладной'
    end
  end
  object ibtrInvoice: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 21
    Top = 328
  end
  object ibdsDocument: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrInvoice
    DeleteSQL.Strings = (
      'delete from GD_DOCUMENT'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into GD_DOCUMENT'
      
        '  (ID, DOCUMENTTYPEKEY, TRTYPEKEY, NUMBER, DOCUMENTDATE, DESCRIP' +
        'TION, SUMNCU, '
      
        '   SUMCURR, SUMEQ, AFULL, ACHAG, AVIEW, CURRKEY, COMPANYKEY, CRE' +
        'ATORKEY, '
      '   CREATIONDATE, EDITORKEY, EDITIONDATE, DISABLED, RESERVED)'
      'values'
      
        '  (:ID, :DOCUMENTTYPEKEY, :TRTYPEKEY, :NUMBER, :DOCUMENTDATE, :D' +
        'ESCRIPTION, '
      
        '   :SUMNCU, :SUMCURR, :SUMEQ, :AFULL, :ACHAG, :AVIEW, :CURRKEY, ' +
        ':COMPANYKEY, '
      
        '   :CREATORKEY, :CREATIONDATE, :EDITORKEY, :EDITIONDATE, :DISABL' +
        'ED, :RESERVED)')
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
      'SELECT '
      '  *'
      ''
      'FROM'
      '  GD_DOCUMENT'
      ''
      'WHERE'
      '  '
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
    ReadTransaction = ibtrInvoice
    Left = 51
    Top = 328
  end
  object ibdsInvoice: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrInvoice
    DeleteSQL.Strings = (
      'delete from CTL_INVOICE'
      'where'
      '  DOCUMENTKEY = :OLD_DOCUMENTKEY')
    InsertSQL.Strings = (
      'insert into CTL_INVOICE'
      
        '  (DOCUMENTKEY, RECEIPTKEY, TTNNUMBER, KIND, DEPARTMENTKEY, PURC' +
        'HASEKIND, '
      
        '   SUPPLIERKEY, RECEIVINGKEY, FORCESLAUGHTER, WASTECOUNT, RESERV' +
        'ED, DELIVERYKIND, '
      '   FACEKEY)'
      'values'
      
        '  (:DOCUMENTKEY, :RECEIPTKEY, :TTNNUMBER, :KIND, :DEPARTMENTKEY,' +
        ' :PURCHASEKIND, '
      
        '   :SUPPLIERKEY, :RECEIVINGKEY, :FORCESLAUGHTER, :WASTECOUNT, :R' +
        'ESERVED, '
      '   :DELIVERYKIND, :FACEKEY)')
    RefreshSQL.Strings = (
      'Select '
      '  DOCUMENTKEY,'
      '  RECEIPTKEY,'
      '  TTNNUMBER,'
      '  KIND,'
      '  DEPARTMENTKEY,'
      '  PURCHASEKIND,'
      '  SUPPLIERKEY,'
      '  RECEIVINGKEY,'
      '  FORCESLAUGHTER,'
      '  WASTECOUNT,'
      '  RESERVED,'
      '  DELIVERYKIND,'
      '  FACEKEY'
      'from CTL_INVOICE '
      'where'
      '  DOCUMENTKEY = :DOCUMENTKEY')
    SelectSQL.Strings = (
      'SELECT '
      '  *'
      ''
      'FROM'
      '  CTL_INVOICE'
      ''
      'WHERE'
      '  DOCUMENTKEY = :DOCUMENTKEY'
      '')
    ModifySQL.Strings = (
      'update CTL_INVOICE'
      'set'
      '  DOCUMENTKEY = :DOCUMENTKEY,'
      '  RECEIPTKEY = :RECEIPTKEY,'
      '  TTNNUMBER = :TTNNUMBER,'
      '  KIND = :KIND,'
      '  DEPARTMENTKEY = :DEPARTMENTKEY,'
      '  PURCHASEKIND = :PURCHASEKIND,'
      '  SUPPLIERKEY = :SUPPLIERKEY,'
      '  RECEIVINGKEY = :RECEIVINGKEY,'
      '  FORCESLAUGHTER = :FORCESLAUGHTER,'
      '  WASTECOUNT = :WASTECOUNT,'
      '  RESERVED = :RESERVED,'
      '  DELIVERYKIND = :DELIVERYKIND,'
      '  FACEKEY = :FACEKEY'
      'where'
      '  DOCUMENTKEY = :OLD_DOCUMENTKEY')
    ReadTransaction = ibtrInvoice
    Left = 81
    Top = 328
  end
  object dsDocument: TDataSource
    DataSet = ibdsDocument
    Left = 171
    Top = 328
  end
  object dsInvoice: TDataSource
    DataSet = ibdsInvoice
    Left = 201
    Top = 328
  end
  object ibdsInvoiceLine: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrInvoice
    CachedUpdates = True
    DeleteSQL.Strings = (
      'delete from CTL_INVOICEPOS'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into CTL_INVOICEPOS'
      
        '  (ID, INVOICEKEY, GOODKEY, QUANTITY, MEATWEIGHT, LIVEWEIGHT, RE' +
        'ALWEIGHT, '
      '   DESTKEY, AFULL, ACHAG, AVIEW, RESERVED)'
      'values'
      
        '  (:ID, :INVOICEKEY, :GOODKEY, :QUANTITY, :MEATWEIGHT, :LIVEWEIG' +
        'HT, :REALWEIGHT, '
      '   :DESTKEY, :AFULL, :ACHAG, :AVIEW, :RESERVED)')
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
      '  G.NAME AS GOODNAME, G.ALIAS, '
      '  DEST.NAME AS DESTNAME, '
      ''
      '  CTL.LIVEWEIGHT, CTL.MEATWEIGHT, CTL.QUANTITY,'
      '  CTL.REALWEIGHT, '
      '  CTL.DESTKEY, CTL.GOODKEY, CTL.ID, CTL.INVOICEKEY, '
      '  CTL.ACHAG, CTL.AFULL, CTL.AVIEW, '
      '  CTL.RESERVED'
      ''
      'FROM'
      '  CTL_INVOICEPOS CTL'
      ''
      '    JOIN GD_GOOD G ON'
      '      CTL.GOODKEY = G.ID'
      ''
      '    JOIN CTL_REFERENCE DEST ON'
      '      DEST.ID = CTL.DESTKEY'
      ''
      'WHERE'
      '  CTL.INVOICEKEY = :DOCUMENTKEY'
      ' ')
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
      '  AFULL = :AFULL,'
      '  ACHAG = :ACHAG,'
      '  AVIEW = :AVIEW,'
      '  RESERVED = :RESERVED'
      'where'
      '  ID = :OLD_ID')
    ReadTransaction = ibtrInvoice
    Left = 111
    Top = 328
  end
  object dsInvoiceLine: TDataSource
    DataSet = ibdsInvoiceLine
    Left = 231
    Top = 328
  end
  object FormPlaceSaver: TFormPlaceSaver
    OnlyForm = True
    Left = 321
    Top = 328
  end
  object dnInvoice: TgsDocNumerator
    Database = dmDatabase.ibdbGAdmin
    DataSource = dsDocument
    DocumentType = 803001
    Left = 351
    Top = 328
  end
  object ibdsContactProps: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrInvoice
    AfterInsert = ibdsContactPropsAfterInsert
    DeleteSQL.Strings = (
      'delete from GD_CONTACTPROPS'
      'where'
      '  CONTACTKEY = :OLD_CONTACTKEY')
    InsertSQL.Strings = (
      'insert into GD_CONTACTPROPS'
      '  (CONTACTKEY, RESERVED)'
      'values'
      '  (:CONTACTKEY, :RESERVED)')
    RefreshSQL.Strings = (
      'Select '
      '  CONTACTKEY,'
      '  RESERVED'
      'from GD_CONTACTPROPS '
      'where'
      '  CONTACTKEY = :CONTACTKEY')
    SelectSQL.Strings = (
      'SELECT'
      '  *'
      ''
      'FROM'
      '  GD_CONTACTPROPS P'
      ''
      'WHERE'
      '  P.CONTACTKEY = :SUPPLIERKEY')
    ModifySQL.Strings = (
      'update GD_CONTACTPROPS'
      'set'
      '  CONTACTKEY = :CONTACTKEY,'
      '  RESERVED = :RESERVED'
      'where'
      '  CONTACTKEY = :OLD_CONTACTKEY')
    DataSource = dsInvoice
    ReadTransaction = ibtrInvoice
    Left = 141
    Top = 328
  end
  object atSQLSetup: TatSQLSetup
    Ignores = <
      item
        Link = ibdsInvoiceLine
        RelationName = 'GD_GOOD'
        IgnoryType = itFull
      end>
    Left = 291
    Top = 328
  end
  object dsContactProps: TDataSource
    DataSet = ibdsContactProps
    Left = 261
    Top = 328
  end
  object IBSQLDoubleList: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'select * from ctl_invoicepos ip'
      'where ip.invoicekey = :invoicekey and'
      '     exists ('
      '        select id from'
      '        ctl_invoicepos ip2'
      '        where ip2.invoicekey = :invoicekey and'
      '        ip.goodkey = ip2.goodkey and ip2.id <> ip.id)'
      'ORDER BY goodkey')
    Transaction = ibtrInvoice
    Left = 17
    Top = 191
  end
  object ibsqlUpdateLine: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'update ctl_invoicepos '
      '  set '
      'LIVEWEIGHT = :LIVEWEIGHT,'
      'MEATWEIGHT =  :MEATWEIGHT, '
      'QUANTITY = :QUANTITY, '
      'REALWEIGHT = :REALWEIGHT'
      'where id = :id'
      '')
    Transaction = ibtrInvoice
    Left = 47
    Top = 191
  end
  object IBSQLDeletePos: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'delete from ctl_invoicepos '
      'where id = :id'
      '')
    Transaction = ibtrInvoice
    Left = 77
    Top = 191
  end
  object ibsqlDistrict: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'SELECT p.id'
      'FROM gd_place p'
      'JOIN gd_contact c ON p.name = c.district'
      'WHERE /*p.number = 2*/'
      '/*AND*/ c.id = :ID')
    Transaction = ibtrInvoice
    Left = 108
    Top = 192
  end
end
