object dlgPrice: TdlgPrice
  Left = 65
  Top = 64
  Width = 696
  Height = 516
  ActiveControl = dbedName
  Caption = 'Прайс-лист'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 688
    Height = 187
    ActivePage = TabSheet1
    Align = alTop
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = '&1.Свойства'
      object Label1: TLabel
        Left = 8
        Top = 12
        Width = 141
        Height = 13
        Caption = 'Наименование прайс-листа'
      end
      object Label2: TLabel
        Left = 312
        Top = 12
        Width = 98
        Height = 13
        Caption = 'Дата актуальности'
      end
      object Label3: TLabel
        Left = 8
        Top = 59
        Width = 50
        Height = 13
        Caption = 'Описание'
      end
      object Label4: TLabel
        Left = 8
        Top = 39
        Width = 81
        Height = 13
        Caption = 'Кому относится'
      end
      object dbedName: TDBEdit
        Left = 157
        Top = 8
        Width = 148
        Height = 21
        DataField = 'NAME'
        DataSource = dsPrice
        TabOrder = 0
      end
      object dbmDescription: TDBMemo
        Left = 8
        Top = 75
        Width = 662
        Height = 56
        DataField = 'DESCRIPTION'
        DataSource = dsPrice
        TabOrder = 5
      end
      object dbchPriceType: TDBCheckBox
        Left = 510
        Top = 12
        Width = 153
        Height = 17
        Caption = 'Прайс лист на продажу'
        DataField = 'PRICETYPE'
        DataSource = dsPrice
        TabOrder = 2
        ValueChecked = 'C'
        ValueUnchecked = 'P'
      end
      object xdbdeRelevanceDate: TxDateDBEdit
        Left = 419
        Top = 8
        Width = 83
        Height = 21
        DataField = 'RELEVANCEDATE'
        DataSource = dsPrice
        Kind = kDate
        EditMask = '!99\.99\.9999;1;_'
        MaxLength = 10
        TabOrder = 1
      end
      object dbchDisabled: TDBCheckBox
        Left = 510
        Top = 37
        Width = 97
        Height = 17
        Caption = 'Отключен'
        DataField = 'DISABLED'
        DataSource = dsPrice
        TabOrder = 4
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object gsiblcContact: TgsIBLookupComboBox
        Left = 157
        Top = 35
        Width = 346
        Height = 21
        Database = dmDatabase.ibdbGAdmin
        Transaction = IBTransaction
        DataSource = dsPrice
        DataField = 'CONTACTKEY'
        ListTable = 'GD_CONTACT'
        ListField = 'NAME'
        KeyField = 'ID'
        SortOrder = soAsc
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
      end
      object Button1: TButton
        Left = 9
        Top = 133
        Width = 75
        Height = 25
        Action = actAccess
        TabOrder = 6
      end
    end
    object TabSheet3: TTabSheet
      Caption = '&2.Курсы'
      ImageIndex = 2
      object sbCurs: TScrollBox
        Left = 0
        Top = 0
        Width = 680
        Height = 159
        Align = alClient
        TabOrder = 0
      end
    end
    object TabSheet2: TTabSheet
      Caption = '&3.Атрибуты'
      ImageIndex = 2
      object atContainer: TatContainer
        Left = 0
        Top = 0
        Width = 680
        Height = 159
        Align = alClient
        TabOrder = 0
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 187
    Width = 688
    Height = 261
    Align = alClient
    TabOrder = 1
    object CoolBar1: TCoolBar
      Left = 1
      Top = 1
      Width = 686
      Height = 32
      Bands = <
        item
          Control = tbPricePosAction
          ImageIndex = -1
          Width = 682
        end>
      object tbPricePosAction: TToolBar
        Left = 9
        Top = 0
        Width = 669
        Height = 25
        ButtonHeight = 21
        ButtonWidth = 94
        Flat = True
        ShowCaptions = True
        TabOrder = 0
        TabStop = True
        object ToolButton1: TToolButton
          Left = 0
          Top = 0
          Action = actNewPosition
        end
        object ToolButton2: TToolButton
          Left = 94
          Top = 0
          Action = actDelPosition
        end
        object ToolButton3: TToolButton
          Left = 188
          Top = 0
          Action = actFilter
          DropdownMenu = PopupMenu1
        end
        object ToolButton4: TToolButton
          Left = 282
          Top = 0
          Caption = 'Пересчет цен'
          ImageIndex = 0
          OnClick = ToolButton4Click
        end
      end
    end
    object Panel3: TPanel
      Left = 1
      Top = 33
      Width = 686
      Height = 227
      Align = alClient
      BevelInner = bvLowered
      BevelOuter = bvNone
      BorderWidth = 4
      TabOrder = 1
      object gsibgrPricePos: TgsIBCtrlGrid
        Left = 5
        Top = 5
        Width = 676
        Height = 217
        Align = alClient
        BorderStyle = bsNone
        DataSource = dsPricePos
        TabOrder = 0
        RefreshType = rtNone
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.Visible = False
        CheckBox.FirstColumn = False
        MinColWidth = 40
        ColumnEditors = <>
        Aliases = <>
        OnSetCtrl = gsibgrPricePosSetCtrl
      end
      object gsiblcGood: TgsIBLookupComboBox
        Left = 16
        Top = 88
        Width = 199
        Height = 21
        Database = dmDatabase.ibdbGAdmin
        Transaction = IBTransaction
        DataSource = dsPricePos
        DataField = 'GOODKEY'
        ListTable = 'GD_GOOD'
        ListField = 'NAME'
        KeyField = 'ID'
        SortOrder = soAsc
        Condition = 'DISABLED = 0'
        gdClassName = 'TgdcGood'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        Visible = False
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 448
    Width = 688
    Height = 41
    Align = alBottom
    TabOrder = 2
    object bOk: TButton
      Left = 254
      Top = 8
      Width = 75
      Height = 25
      Action = actOk
      Default = True
      TabOrder = 0
    end
    object bCancel: TButton
      Left = 358
      Top = 8
      Width = 75
      Height = 25
      Action = actCancel
      Cancel = True
      TabOrder = 1
    end
    object bHelp: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Action = actHelp
      TabOrder = 2
    end
  end
  object ibdsPrice: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from gd_price'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into gd_price'
      '  (ID, NAME, DESCRIPTION, RELEVANCEDATE, PRICETYPE, DISABLED, '
      'RESERVED, '
      '   AFULL, ACHAG, AVIEW, CONTACTKEY)'
      'values'
      
        '  (:ID, :NAME, :DESCRIPTION, :RELEVANCEDATE, :PRICETYPE, :DISABL' +
        'ED, '
      ':RESERVED, '
      '   :AFULL, :ACHAG, :AVIEW, :CONTACTKEY)')
    RefreshSQL.Strings = (
      'Select *'
      'from gd_price '
      'where'
      '  ID = :ID')
    SelectSQL.Strings = (
      'SELECT * FROM gd_price'
      'WHERE id = :PriceKey')
    ModifySQL.Strings = (
      'update gd_price'
      'set'
      '  ID = :ID,'
      '  NAME = :NAME,'
      '  DESCRIPTION = :DESCRIPTION,'
      '  RELEVANCEDATE = :RELEVANCEDATE,'
      '  CONTACTKEY = :CONTACTKEY,'
      '  PRICETYPE = :PRICETYPE,'
      '  DISABLED = :DISABLED,'
      '  RESERVED = :RESERVED,'
      '  AFULL = :AFULL,'
      '  ACHAG = :ACHAG,'
      '  AVIEW = :AVIEW'
      'where'
      '  ID = :OLD_ID')
    Left = 228
    Top = 112
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
    Top = 112
  end
  object dsPrice: TDataSource
    DataSet = ibdsPrice
    Left = 196
    Top = 112
  end
  object ibdsPricePos: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    AfterDelete = ibdsPricePosAfterDelete
    AfterInsert = ibdsPricePosAfterInsert
    AfterPost = ibdsPricePosAfterPost
    BeforeInsert = ibdsPricePosBeforeInsert
    BeforePost = ibdsPricePosBeforePost
    BufferChunks = 1000
    CachedUpdates = True
    DeleteSQL.Strings = (
      'delete from gd_pricepos'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into gd_pricepos'
      '  (ID, PRICEKEY, GOODKEY)'
      'values'
      '  (:ID, :PRICEKEY, :GOODKEY)')
    SelectSQL.Strings = (
      'SELECT '
      '   pp.ID, '
      '   pp.PriceKey,'
      '   pp.GoodKey,'
      '   g.Name,'
      '   g.Alias,'
      '   v.Name as Mes'
      'FROM '
      '  gd_pricepos pp JOIN gd_good g ON pp.GoodKey = g.ID AND'
      '  pp.PriceKey = :id LEFT JOIN gd_value v ON g.ValueKey = v.ID')
    ModifySQL.Strings = (
      'update gd_pricepos'
      'set'
      '  ID = :ID,'
      '  PRICEKEY = :PRICEKEY,'
      '  GOODKEY = :GOODKEY'
      'where'
      '  ID = :OLD_ID')
    Left = 224
    Top = 241
  end
  object dsPricePos: TDataSource
    DataSet = ibdsPricePos
    Left = 195
    Top = 242
  end
  object ActionList1: TActionList
    Left = 329
    Top = 242
    object actNewPosition: TAction
      Category = 'Goods'
      Caption = 'Выбор позиций...'
      OnExecute = actNewPositionExecute
    end
    object actDelPosition: TAction
      Category = 'Goods'
      Caption = 'Удалить'
      OnExecute = actDelPositionExecute
      OnUpdate = actDelPositionUpdate
    end
    object actOk: TAction
      Category = 'All'
      Caption = 'OK'
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Category = 'All'
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
    object actHelp: TAction
      Category = 'All'
      Caption = 'Справка'
    end
    object actAccess: TAction
      Category = 'All'
      Caption = 'Права...'
    end
    object actFilter: TAction
      Category = 'Goods'
      Caption = 'Фильтр'
      OnExecute = actFilterExecute
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 121
    Top = 258
  end
  object atSQLSetup: TatSQLSetup
    Ignores = <>
    Left = 436
    Top = 120
  end
  object gsQueryFilter: TgsQueryFilter
    Database = dmDatabase.ibdbGAdmin
    RequeryParams = False
    IBDataSet = ibdsPricePos
    Left = 257
    Top = 242
  end
  object ibsqlPricePosOption: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      'SELECT '
      '  p.*, c.* '
      'FROM'
      '  gd_priceposoption p LEFT JOIN gd_curr c ON p.CurrKey = c.ID')
    Transaction = IBTransaction
    Left = 225
    Top = 282
  end
  object xFoCal: TxFoCal
    Expression = '0'
    Left = 265
    Top = 282
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
  object ibsqlGood: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      'SELECT g.*, v.Name as ValueName'
      'FROM '
      '  gd_good g '
      'LEFT JOIN '
      '  gd_value v ON g.valuekey = v.id  WHERE g.id = :id')
    Transaction = IBTransaction
    Left = 225
    Top = 322
  end
  object FormPlaceSaver: TFormPlaceSaver
    OnlyForm = True
    Left = 369
    Top = 290
  end
end
