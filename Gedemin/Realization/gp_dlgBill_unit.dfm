object gp_dlgBill: Tgp_dlgBill
  Left = 178
  Top = 39
  Width = 746
  Height = 535
  Caption = 'Счет-фактура'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pcBill: TPageControl
    Left = 0
    Top = 0
    Width = 738
    Height = 193
    ActivePage = tsMain
    Align = alTop
    TabOrder = 0
    object tsMain: TTabSheet
      Caption = '&1. Основные'
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 730
        Height = 165
        Align = alClient
        BevelInner = bvLowered
        BevelOuter = bvNone
        BorderWidth = 4
        TabOrder = 0
        object Label1: TLabel
          Left = 13
          Top = 15
          Width = 37
          Height = 13
          Caption = 'Номер '
        end
        object Label2: TLabel
          Left = 248
          Top = 15
          Width = 29
          Height = 13
          Caption = 'Дата '
        end
        object Label3: TLabel
          Left = 13
          Top = 42
          Width = 39
          Height = 13
          Caption = 'От кого'
        end
        object Label4: TLabel
          Left = 13
          Top = 67
          Width = 26
          Height = 13
          Caption = 'Кому'
        end
        object Label5: TLabel
          Left = 425
          Top = 15
          Width = 38
          Height = 13
          Caption = 'Валюта'
        end
        object Label6: TLabel
          Left = 544
          Top = 15
          Width = 24
          Height = 13
          Caption = 'Курс'
        end
        object Label7: TLabel
          Left = 13
          Top = 93
          Width = 78
          Height = 13
          Caption = 'Текущий прайс'
        end
        object Label8: TLabel
          Left = 344
          Top = 93
          Width = 99
          Height = 13
          Caption = 'Использовать цену'
        end
        object Label25: TLabel
          Left = 13
          Top = 118
          Width = 63
          Height = 13
          Caption = 'Оплатить до'
        end
        object Label29: TLabel
          Left = 425
          Top = 67
          Width = 44
          Height = 13
          Caption = 'Договор'
        end
        object SpeedButton1: TSpeedButton
          Left = 645
          Top = 63
          Width = 21
          Height = 21
          Action = actAddContract
        end
        object Label9: TLabel
          Left = 344
          Top = 118
          Width = 63
          Height = 13
          Caption = 'Примечание'
        end
        object dbedNumber: TDBEdit
          Left = 115
          Top = 11
          Width = 121
          Height = 21
          DataField = 'NUMBER'
          DataSource = dsDocument
          TabOrder = 0
        end
        object ddbDocumentDate: TxDateDBEdit
          Left = 296
          Top = 11
          Width = 121
          Height = 21
          DataField = 'DOCUMENTDATE'
          DataSource = dsDocument
          Kind = kDate
          EditMask = '!99\.99\.9999;1;_'
          MaxLength = 10
          TabOrder = 1
        end
        object gsiblcFromContact: TgsIBLookupComboBox
          Left = 115
          Top = 37
          Width = 552
          Height = 21
          HelpContext = 1
          Database = dmDatabase.ibdbGAdmin
          Transaction = IBTranLookup
          DataSource = dsDocRealization
          DataField = 'FROMCONTACTKEY'
          ListTable = 'gd_contact'
          ListField = 'name'
          KeyField = 'id'
          SortOrder = soAsc
          Condition = 'CONTACTTYPE = 4'
          gdClassName = 'TgdcDepartment'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 4
          OnChange = gsiblcFromContactChange
        end
        object gsiblcToContact: TgsIBLookupComboBox
          Left = 115
          Top = 62
          Width = 304
          Height = 21
          HelpContext = 1
          Database = dmDatabase.ibdbGAdmin
          Transaction = IBTranLookup
          DataSource = dsDocRealization
          DataField = 'TOCONTACTKEY'
          Fields = 'CITY'
          ListTable = 'gd_contact'
          ListField = 'name'
          KeyField = 'id'
          SortOrder = soAsc
          Condition = 'contacttype=3'
          gdClassName = 'TgdcCompany'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 5
        end
        object gsiblcCurr: TgsIBLookupComboBox
          Left = 476
          Top = 11
          Width = 61
          Height = 21
          HelpContext = 1
          Database = dmDatabase.ibdbGAdmin
          Transaction = IBTransaction
          DataSource = dsDocument
          DataField = 'CURRKEY'
          ListTable = 'GD_CURR'
          ListField = 'SHORTNAME'
          KeyField = 'ID'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
        end
        object dbedRate: TDBEdit
          Left = 573
          Top = 11
          Width = 94
          Height = 21
          DataField = 'RATE'
          DataSource = dsDocRealization
          TabOrder = 3
        end
        object gsiblcPrice: TgsIBLookupComboBox
          Left = 115
          Top = 88
          Width = 225
          Height = 21
          HelpContext = 1
          Database = dmDatabase.ibdbGAdmin
          Transaction = IBTranLookup
          DataSource = dsDocRealization
          DataField = 'PRICEKEY'
          ListTable = 'GD_PRICE'
          ListField = 'NAME'
          KeyField = 'ID'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 7
        end
        object cbPriceField: TComboBox
          Left = 476
          Top = 89
          Width = 189
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 8
        end
        object ddeDatePayment: TxDateDBEdit
          Left = 115
          Top = 114
          Width = 225
          Height = 21
          DataField = 'DATEPAYMENT'
          DataSource = dsDocRealInfo
          Kind = kDate
          EditMask = '!99\.99\.9999;1;_'
          MaxLength = 10
          TabOrder = 9
        end
        object dbedContract: TDBEdit
          Left = 476
          Top = 62
          Width = 170
          Height = 21
          DataField = 'CONTRACTNUM'
          DataSource = dsDocRealInfo
          TabOrder = 6
        end
        object dbcbDelayed: TDBCheckBox
          Left = 14
          Top = 140
          Width = 139
          Height = 14
          Caption = 'Отложенный документ'
          DataField = 'DELAYED'
          DataSource = dsDocument
          TabOrder = 11
          ValueChecked = '1'
          ValueUnchecked = '0'
        end
        object dbedDescription: TDBEdit
          Left = 477
          Top = 114
          Width = 188
          Height = 21
          DataField = 'DESCRIPTION'
          DataSource = dsDocument
          TabOrder = 10
        end
      end
    end
    object TabSheet3: TTabSheet
      Caption = '&2. Атрибуты'
      ImageIndex = 2
      object atContainer: TatContainer
        Left = 0
        Top = 0
        Width = 730
        Height = 165
        DataSource = dsDocRealization
        Align = alClient
        TabOrder = 0
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 467
    Width = 738
    Height = 41
    Align = alBottom
    TabOrder = 2
    object Button1: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Action = actHelp
      TabOrder = 0
    end
    object Panel4: TPanel
      Left = 478
      Top = 1
      Width = 259
      Height = 39
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 1
      object bOk: TButton
        Left = 10
        Top = 7
        Width = 75
        Height = 25
        Action = actOk
        Default = True
        TabOrder = 0
      end
      object Button3: TButton
        Left = 92
        Top = 7
        Width = 75
        Height = 25
        Action = actNext
        TabOrder = 1
      end
      object Button4: TButton
        Left = 174
        Top = 7
        Width = 75
        Height = 25
        Action = actCancel
        TabOrder = 2
      end
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 193
    Width = 738
    Height = 274
    Align = alClient
    BevelInner = bvLowered
    BorderWidth = 4
    TabOrder = 1
    object gsibgrDocRealPos: TgsIBCtrlGrid
      Left = 6
      Top = 31
      Width = 726
      Height = 185
      Align = alClient
      BorderStyle = bsNone
      DataSource = dsDocRealPos
      PopupMenu = pGridMenu
      TabOrder = 6
      OnEnter = gsibgrDocRealPosEnter
      RefreshType = rtNone
      InternalMenuKind = imkWithSeparator
      Expands = <>
      ExpandsActive = False
      ExpandsSeparate = False
      TitlesExpanding = False
      Conditions = <>
      ConditionsActive = False
      CheckBox.Visible = False
      CheckBox.FirstColumn = False
      MinColWidth = 20
      ColumnEditors = <>
      Aliases = <>
      OnSetCtrl = gsibgrDocRealPosSetCtrl
    end
    object ToolBar1: TToolBar
      Left = 6
      Top = 6
      Width = 726
      Height = 25
      ButtonHeight = 21
      ButtonWidth = 60
      Caption = 'ToolBar1'
      Flat = True
      ShowCaptions = True
      TabOrder = 7
      object ToolButton1: TToolButton
        Left = 0
        Top = 0
        Action = actChoose
      end
      object ToolButton2: TToolButton
        Left = 60
        Top = 0
        Action = actDelete
      end
      object cbAmount: TCheckBox
        Left = 120
        Top = 0
        Width = 224
        Height = 21
        BiDiMode = bdLeftToRight
        Caption = 'Пересчитывать итого (Alt+C)'
        ParentBiDiMode = False
        TabOrder = 0
        OnClick = cbAmountClick
      end
    end
    object gsiblcGood: TgsIBLookupComboBox
      Left = 40
      Top = 88
      Width = 199
      Height = 21
      HelpContext = 1
      Database = dmDatabase.ibdbGAdmin
      Transaction = IBTranLookup
      DataSource = dsDocRealPos
      DataField = 'GOODKEY'
      ListTable = 'GD_GOOD JOIN GD_GOODGROUP GR ON GD_GOOD.GROUPKEY = GR.ID'
      ListField = 'NAME'
      KeyField = 'ID'
      SortOrder = soAsc
      Condition = 'DISABLED = 0'
      gdClassName = 'TgdcGood'
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      Visible = False
      OnEnter = gsiblcGoodEnter
      OnExit = gsiblcGoodExit
      OnKeyDown = gsiblcGoodKeyDown
    end
    object gsiblcValue: TgsIBLookupComboBox
      Left = 40
      Top = 120
      Width = 139
      Height = 21
      HelpContext = 1
      Database = dmDatabase.ibdbGAdmin
      Transaction = IBTranLookup
      DataSource = dsDocRealPos
      DataField = 'VALUEKEY'
      ListTable = 'GD_VALUE'
      ListField = 'NAME'
      KeyField = 'ID'
      SortOrder = soAsc
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      Visible = False
      OnEnter = gsiblcGoodEnter
    end
    object gsiblcWeight: TgsIBLookupComboBox
      Left = 40
      Top = 144
      Width = 139
      Height = 21
      HelpContext = 1
      Database = dmDatabase.ibdbGAdmin
      Transaction = IBTranLookup
      DataSource = dsDocRealPos
      DataField = 'WEIGHTKEY'
      ListTable = 'GD_VALUE'
      ListField = 'NAME'
      KeyField = 'ID'
      SortOrder = soAsc
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      Visible = False
      OnEnter = gsiblcGoodEnter
    end
    object gsiblcPack: TgsIBLookupComboBox
      Left = 40
      Top = 168
      Width = 139
      Height = 21
      HelpContext = 1
      Database = dmDatabase.ibdbGAdmin
      Transaction = IBTranLookup
      DataSource = dsDocRealPos
      DataField = 'PACKKEY'
      ListTable = 'GD_VALUE'
      ListField = 'NAME'
      KeyField = 'ID'
      SortOrder = soAsc
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      Visible = False
      OnEnter = gsiblcGoodEnter
    end
    object edCostNCU: TEdit
      Left = 520
      Top = 40
      Width = 121
      Height = 21
      TabOrder = 4
      Visible = False
      OnExit = edCostNCUExit
    end
    object edCostCurr: TEdit
      Left = 520
      Top = 64
      Width = 121
      Height = 21
      TabOrder = 5
      Visible = False
      OnExit = edCostCurrExit
    end
    object lvAmount: TListView
      Left = 6
      Top = 216
      Width = 726
      Height = 52
      Align = alBottom
      Columns = <
        item
          Caption = 'Итого НДЕ'
          Width = 80
        end
        item
          Caption = 'Кол-во'
          Width = 60
        end
        item
          Caption = 'Без тары'
          Width = 62
        end
        item
          Caption = 'Вес'
          Width = 60
        end
        item
          Caption = 'Без тары'
          Width = 62
        end
        item
          Caption = 'Упаковок'
          Width = 70
        end
        item
          Caption = 'Итого вал.'
          Width = 80
        end
        item
          Caption = 'Итого по накл.'
          Width = 90
        end
        item
          Caption = 'По накл. в вал.'
          Width = 90
        end>
      FullDrag = True
      GridLines = True
      Items.Data = {
        3E0000000100000000000000FFFFFFFFFFFFFFFF080000000000000001300130
        0130013001300130013001300130FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
      RowSelect = True
      TabOrder = 8
      ViewStyle = vsReport
    end
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
      'DESCRIPTION, DELAYED,'
      '   SUMNCU, SUMCURR, SUMEQ, AFULL, ACHAG, AVIEW, CURRKEY, '
      'COMPANYKEY, CREATORKEY, '
      '   CREATIONDATE, EDITORKEY, EDITIONDATE, DISABLED, RESERVED)'
      'values'
      '  (:ID, :DOCUMENTTYPEKEY, :TRTYPEKEY, :NUMBER, :DOCUMENTDATE, '
      ':DESCRIPTION, :DELAYED,'
      '   :SUMNCU, :SUMCURR, :SUMEQ, :AFULL, :ACHAG, :AVIEW, :CURRKEY, '
      ':COMPANYKEY, '
      
        '   :CREATORKEY, :CREATIONDATE, :EDITORKEY, :EDITIONDATE, :DISABL' +
        'ED, '
      ':RESERVED)')
    RefreshSQL.Strings = (
      'Select *'
      'from gd_document doc'
      'where'
      '  doc.ID = :ID')
    SelectSQL.Strings = (
      'SELECT doc.* FROM gd_document doc'
      'WHERE doc.id = :id')
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
    ReadTransaction = IBTransaction
    Left = 164
    Top = 256
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 276
    Top = 312
  end
  object ibdsDocRealization: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 100
    DeleteSQL.Strings = (
      'delete from gd_docrealization'
      'where'
      '  DOCUMENTKEY = :OLD_DOCUMENTKEY')
    InsertSQL.Strings = (
      'insert into gd_docrealization'
      '  (DOCUMENTKEY, TOCONTACTKEY, FROMCONTACTKEY, '
      '   TRANSSUMNCU, TRANSSUMCURR, '
      '   PRICEKEY, PRICEFIELD, RATE, ISREALIZATION)'
      'values'
      '  (:DOCUMENTKEY, :TOCONTACTKEY, :FROMCONTACTKEY, '
      '   :TRANSSUMNCU, :TRANSSUMCURR,'
      '   :PRICEKEY, :PRICEFIELD, :RATE, :ISREALIZATION)')
    RefreshSQL.Strings = (
      'Select *'
      'from gd_docrealization '
      'where'
      '  DOCUMENTKEY = :DOCUMENTKEY')
    SelectSQL.Strings = (
      'SELECT * FROM gd_docrealization r'
      'WHERE r.documentkey = :id')
    ModifySQL.Strings = (
      'update gd_docrealization'
      'set'
      '  DOCUMENTKEY = :DOCUMENTKEY,'
      '  TOCONTACTKEY = :TOCONTACTKEY,'
      '  FROMCONTACTKEY = :FROMCONTACTKEY,'
      '  TRANSSUMNCU = :TRANSSUMNCU,'
      '  TRANSSUMCURR = :TRANSSUMCURR,'
      '  PRICEKEY = :PRICEKEY,'
      '  PRICEFIELD = :PRICEFIELD,'
      '  ISREALIZATION = :ISREALIZATION,'
      '  RATE = :RATE'
      'where'
      '  DOCUMENTKEY = :OLD_DOCUMENTKEY')
    ReadTransaction = IBTransaction
    Left = 164
    Top = 288
  end
  object ibdsDocRealPos: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    AfterDelete = ibdsDocRealPosAfterDelete
    AfterInsert = ibdsDocRealPosAfterInsert
    AfterPost = ibdsDocRealPosAfterPost
    AfterScroll = ibdsDocRealPosAfterScroll
    BeforeInsert = ibdsDocRealPosBeforeInsert
    BeforePost = ibdsDocRealPosBeforePost
    BufferChunks = 100
    CachedUpdates = True
    DeleteSQL.Strings = (
      'delete from gd_docrealpos'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into gd_docrealpos'
      '  (ID, DOCUMENTKEY, GOODKEY, QUANTITY, AMOUNTNCU, AMOUNTCURR, '
      'AMOUNTEQ, TRTYPEKEY, MAINQUANTITY,'
      '   VALUEKEY, WEIGHTKEY, WEIGHT, PACKKEY, PACKINQUANT, '
      'PACKQUANTITY, RESERVED, '
      '   AFULL, ACHAG, AVIEW)'
      'values'
      
        '  (:ID, :DOCUMENTKEY, :GOODKEY, :QUANTITY, :AMOUNTNCU, :AMOUNTCU' +
        'RR, '
      ':AMOUNTEQ, :TRTYPEKEY, :MAINQUANTITY,'
      '   :VALUEKEY, :WEIGHTKEY, :WEIGHT, :PACKKEY, :PACKINQUANT, '
      ':PACKQUANTITY, '
      '   :RESERVED, :AFULL, :ACHAG, :AVIEW)')
    SelectSQL.Strings = (
      'SELECT '
      '  pos.*,'
      '  g.Name,'
      '  g.valuekey as goodvaluekey,'
      '  g.Alias,'
      '  g.description,'
      '  g.GroupKey,'
      '  pos.AmountNCU / pos.Quantity  as CostNCU,'
      '  pos.AmountCurr / pos.Quantity  as CostCurr,'
      '  v.Name as VALUENAME,'
      '  vg.scale,'
      '  vg.decdigit,'
      '  w.Name as WeightName,'
      '  wg.scale as WeightScale,'
      '  p.Name as PackName,'
      '  pg.scale as PackScale,'
      '  t.Name as TransactionName'
      'FROM'
      '  gd_docrealpos pos '
      'JOIN '
      '  gd_good g ON pos.goodkey = g.id '
      'JOIN'
      '  gd_value v ON pos.valuekey = v.id'
      'LEFT JOIN'
      
        '  gd_goodvalue vg ON pos.goodkey = vg.goodkey AND pos.valuekey =' +
        ' vg.valuekey'
      'LEFT JOIN'
      '  gd_value w ON pos.weightkey = w.id'
      'LEFT JOIN'
      '  gd_goodvalue wg ON wg.goodkey = g.id and wg.valuekey = w.id'
      'LEFT JOIN'
      '  gd_value p ON pos.packkey = p.id  '
      'LEFT JOIN'
      '  gd_goodvalue pg ON pg.goodkey = g.id and pg.valuekey = p.id'
      'LEFT JOIN'
      '  gd_listtrtype t ON pos.trtypekey = t.id'
      'WHERE'
      '  pos.documentkey = :dockey and'
      '  pos.quantity <> 0'
      'ORDER BY pos.id  ')
    ModifySQL.Strings = (
      'update gd_docrealpos'
      'set'
      '  ID = :ID,'
      '  DOCUMENTKEY = :DOCUMENTKEY,'
      '  TRTYPEKEY = :TRTYPEKEY,'
      '  GOODKEY = :GOODKEY,'
      '  QUANTITY = :QUANTITY,'
      '  MAINQUANTITY = :MAINQUANTITY,'
      '  AMOUNTNCU = :AMOUNTNCU,'
      '  AMOUNTCURR = :AMOUNTCURR,'
      '  AMOUNTEQ = :AMOUNTEQ,'
      '  VALUEKEY = :VALUEKEY,'
      '  WEIGHTKEY = :WEIGHTKEY,'
      '  WEIGHT = :WEIGHT,'
      '  PACKKEY = :PACKKEY,'
      '  PACKINQUANT = :PACKINQUANT,'
      '  PACKQUANTITY = :PACKQUANTITY,'
      '  RESERVED = :RESERVED,'
      '  AFULL = :AFULL,'
      '  ACHAG = :ACHAG,'
      '  AVIEW = :AVIEW'
      'where'
      '  ID = :OLD_ID')
    ReadTransaction = IBTransaction
    Left = 164
    Top = 321
  end
  object dsDocRealPos: TDataSource
    DataSet = ibdsDocRealPos
    Left = 191
    Top = 321
  end
  object ActionList1: TActionList
    Left = 352
    Top = 257
    object actChoose: TAction
      Caption = 'Выбрать...'
    end
    object actDelete: TAction
      Caption = 'Удалить'
      OnExecute = actDeleteExecute
      OnUpdate = actDeleteUpdate
    end
    object actOk: TAction
      Caption = 'OK'
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
    object actNext: TAction
      Caption = 'Следующий'
      ShortCut = 45
      OnExecute = actNextExecute
    end
    object actHelp: TAction
      Caption = 'Справка'
    end
    object actDolg: TAction
      Caption = 'Задолженность'
      OnExecute = actDolgExecute
    end
    object actAmount: TAction
      Caption = 'Итого...'
      ShortCut = 16467
    end
    object actSetTrType: TAction
      Caption = 'Установить операции...'
    end
    object actChangeTransaction: TAction
      Caption = 'Редактировать проводки...'
    end
    object actCalcAmount: TAction
      Caption = 'actCalcAmount'
      ShortCut = 32835
      OnExecute = actCalcAmountExecute
    end
    object actAddContract: TAction
      Caption = '...'
      OnExecute = actAddContractExecute
    end
  end
  object dsDocRealization: TDataSource
    DataSet = ibdsDocRealization
    Left = 191
    Top = 288
  end
  object dsDocument: TDataSource
    DataSet = ibdsDocument
    Left = 192
    Top = 256
  end
  object ibsqlGood: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'SELECT * FROM gd_good WHERE id = :id')
    Transaction = IBTransaction
    Left = 308
    Top = 305
  end
  object ibsqlValue: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'SELECT * FROM '
      '  gd_value v LEFT JOIN gd_goodvalue gv ON gv.valuekey = v.id'
      '   and  gv.goodkey = :gk '
      'WHERE v.id = :id')
    Transaction = IBTransaction
    Left = 336
    Top = 305
  end
  object ibdsDocRealInfo: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    AfterInsert = ibdsDocRealInfoAfterInsert
    BufferChunks = 100
    DeleteSQL.Strings = (
      'delete from gd_docrealinfo'
      'where'
      '  DOCUMENTKEY = :OLD_DOCUMENTKEY')
    InsertSQL.Strings = (
      'insert into gd_docrealinfo'
      '  (DOCUMENTKEY, CARGORECEIVERKEY, CAR, CAROWNERKEY, DRIVER, '
      'LOADINGPOINT, '
      '   UNLOADINGPOINT, ROUTE, READDRESSING, HOOKED, WAYSHEETNUMBER, '
      'SURRENDERKEY, '
      '   RECEPTION, WARRANTNUMBER, WARRANTDATE, CONTRACTNUM, '
      'DATEPAYMENT, '
      '   FORWARDERKEY, CONTRACTKEY)'
      'values'
      
        '  (:DOCUMENTKEY, :CARGORECEIVERKEY, :CAR, :CAROWNERKEY, :DRIVER,' +
        ' '
      ':LOADINGPOINT, '
      '   :UNLOADINGPOINT, :ROUTE, :READDRESSING, :HOOKED, '
      ':WAYSHEETNUMBER, :SURRENDERKEY, '
      '   :RECEPTION, :WARRANTNUMBER, :WARRANTDATE, :CONTRACTNUM, '
      ':DATEPAYMENT, '
      ' :FORWARDERKEY, :CONTRACTKEY)')
    RefreshSQL.Strings = (
      'Select *'
      'from gd_docrealinfo '
      'where'
      '  DOCUMENTKEY = :DOCUMENTKEY')
    SelectSQL.Strings = (
      'SELECT * FROM gd_docrealinfo'
      'where documentkey = :id')
    ModifySQL.Strings = (
      'update gd_docrealinfo'
      'set'
      '  DOCUMENTKEY = :DOCUMENTKEY,'
      '  CARGORECEIVERKEY = :CARGORECEIVERKEY,'
      '  CAR = :CAR,'
      '  CAROWNERKEY = :CAROWNERKEY,'
      '  DRIVER = :DRIVER,'
      '  LOADINGPOINT = :LOADINGPOINT,'
      '  UNLOADINGPOINT = :UNLOADINGPOINT,'
      '  ROUTE = :ROUTE,'
      '  READDRESSING = :READDRESSING,'
      '  HOOKED = :HOOKED,'
      '  WAYSHEETNUMBER = :WAYSHEETNUMBER,'
      '  SURRENDERKEY = :SURRENDERKEY,'
      '  RECEPTION = :RECEPTION,'
      '  WARRANTNUMBER = :WARRANTNUMBER,'
      '  WARRANTDATE = :WARRANTDATE,'
      '  CONTRACTNUM = :CONTRACTNUM,'
      '  CONTRACTKEY = :CONTRACTKEY,'
      '  DATEPAYMENT = :DATEPAYMENT,'
      '  FORWARDERKEY = :FORWARDERKEY'
      'where'
      '  DOCUMENTKEY = :OLD_DOCUMENTKEY')
    ReadTransaction = IBTransaction
    Left = 272
    Top = 369
  end
  object dsDocRealInfo: TDataSource
    DataSet = ibdsDocRealInfo
    Left = 302
    Top = 369
  end
  object atSQLSetup: TatSQLSetup
    Ignores = <
      item
        Link = ibdsDocument
        RelationName = 'GD_DOCUMENT'
        IgnoryType = itFull
      end>
    Left = 486
    Top = 82
  end
  object xFoCal: TxFoCal
    Expression = '0'
    Left = 408
    Top = 315
    _variables_ = (
      'PI'
      3.14159265358979
      'E'
      2.71828182845905)
  end
  object boCurrency: TboCurrency
    Left = 497
    Top = 242
  end
  object pGridMenu: TPopupMenu
    Left = 96
    Top = 248
    object N1: TMenuItem
      Action = actChoose
    end
    object N2: TMenuItem
      Action = actDelete
      ShortCut = 16430
    end
    object N3: TMenuItem
      Action = actSetTrType
    end
    object N4: TMenuItem
      Action = actChangeTransaction
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 224
    Top = 312
  end
  object ibsqlCheckNumber: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'SELECT ID FROM '
      '  gd_document'
      'WHERE'
      '  documenttypekey = :dt and'
      '  companykey = :ck and'
      '  id <> :cid and'
      '  number = :number')
    Transaction = IBTransaction
    Left = 448
    Top = 312
  end
  object FormPlaceSaver: TFormPlaceSaver
    Left = 616
    Top = 304
  end
  object ibsqlPack: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'SELECT gv.valuekey, gv.scale FROM '
      '  gd_goodvalue gv JOIN gd_value v ON gv.valuekey = v.id'
      'WHERE gv.goodkey = :gk and v.ispack = 1')
    Transaction = IBTransaction
    Left = 368
    Top = 306
  end
  object IBTranLookup: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 340
    Top = 368
  end
end
