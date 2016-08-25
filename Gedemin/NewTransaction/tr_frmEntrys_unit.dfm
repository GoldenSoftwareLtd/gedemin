object frmEntrys: TfrmEntrys
  Left = 89
  Top = 78
  Width = 696
  Height = 480
  Caption = 'Журнал хозяйственных операций'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 31
    Width = 688
    Height = 396
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 185
      Top = 0
      Width = 3
      Height = 396
      Cursor = crHSplit
    end
    object Panel2: TPanel
      Left = 0
      Top = 0
      Width = 185
      Height = 396
      Align = alLeft
      BevelInner = bvLowered
      BevelOuter = bvNone
      BorderWidth = 4
      TabOrder = 0
      object gsdbtvTransaction: TgsDBTreeView
        Left = 5
        Top = 5
        Width = 175
        Height = 361
        DataSource = dsTransaction
        KeyField = 'ID'
        ParentField = 'PARENT'
        DisplayField = 'NAME'
        Align = alClient
        BorderStyle = bsNone
        HideSelection = False
        Images = dmImages.ilTree
        Indent = 19
        ReadOnly = True
        SortType = stText
        TabOrder = 0
        OnChanging = gsdbtvTransactionChanging
        OnGetImageIndex = gsdbtvTransactionGetImageIndex
        OnGetSelectedIndex = gsdbtvTransactionGetSelectedIndex
        MainFolderHead = True
        MainFolder = False
        MainFolderCaption = 'Все'
        WithCheckBox = False
      end
      object Panel4: TPanel
        Left = 5
        Top = 366
        Width = 175
        Height = 25
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 1
        object cbViewSubLevel: TCheckBox
          Left = 4
          Top = 4
          Width = 165
          Height = 17
          Caption = 'Просмотр подуровней'
          TabOrder = 0
          OnClick = cbViewSubLevelClick
        end
      end
    end
    object Panel3: TPanel
      Left = 188
      Top = 0
      Width = 500
      Height = 396
      Align = alClient
      BevelInner = bvLowered
      BevelOuter = bvNone
      BorderWidth = 4
      TabOrder = 1
      object egEntries: TgdEntryGrid
        Left = 5
        Top = 5
        Width = 490
        Height = 386
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clBlack
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
        DescriptionFont.Charset = DEFAULT_CHARSET
        DescriptionFont.Color = clWindowText
        DescriptionFont.Height = -11
        DescriptionFont.Name = 'Tahoma'
        DescriptionFont.Style = []
        EntryFont.Charset = DEFAULT_CHARSET
        EntryFont.Color = clWindowText
        EntryFont.Height = -11
        EntryFont.Name = 'Tahoma'
        EntryFont.Style = []
        TotalFont.Charset = DEFAULT_CHARSET
        TotalFont.Color = clWhite
        TotalFont.Height = -11
        TotalFont.Name = 'Tahoma'
        TotalFont.Style = []
        AnalyticsFont.Charset = DEFAULT_CHARSET
        AnalyticsFont.Color = clWindowText
        AnalyticsFont.Height = -11
        AnalyticsFont.Name = 'Tahoma'
        AnalyticsFont.Style = []
        SelectedFont.Charset = DEFAULT_CHARSET
        SelectedFont.Color = clWhite
        SelectedFont.Height = -11
        SelectedFont.Name = 'Tahoma'
        SelectedFont.Style = []
        TitleColor = clBtnFace
        DescriptionColor = clWhite
        EntryColor = 14803425
        TotalColor = clNavy
        SelectedColor = clHighlight
        FocusedColor = clMaroon
        Database = dmDatabase.ibdbGAdmin
        Transaction = IBTransaction
        AutoLoad = True
        BorderStyle = bsNone
        Options = [egoAnalytics, egoEntries, egoTotals]
        Params = [pTrTypeLB, pTrTypeRB, pCompanyKey]
        EntryAmount = eaAmount
        SQLEvent = egEntriesSQLEvent
        TotalEvent = egEntriesTotalEvent
        Align = alClient
        TabOrder = 0
        TabStop = True
        PopupMenu = pOperation
        ParentFont = False
      end
    end
  end
  object CoolBar1: TCoolBar
    Left = 0
    Top = 0
    Width = 688
    Height = 31
    Bands = <
      item
        Control = ToolBar1
        ImageIndex = -1
        Width = 684
      end>
    object ToolBar1: TToolBar
      Left = 9
      Top = 0
      Width = 671
      Height = 25
      ButtonHeight = 21
      ButtonWidth = 80
      Caption = 'ToolBar1'
      EdgeInner = esNone
      EdgeOuter = esNone
      ShowCaptions = True
      TabOrder = 0
      Transparent = True
      object ToolButton1: TToolButton
        Left = 0
        Top = 2
        Action = actNewOperation
      end
      object ToolButton2: TToolButton
        Left = 80
        Top = 2
        Action = actEditOperation
      end
      object ToolButton3: TToolButton
        Left = 160
        Top = 2
        Action = actDelOperation
      end
      object ToolButton4: TToolButton
        Left = 240
        Top = 2
        Caption = 'Фильтрация...'
        DropdownMenu = pFilter
        ImageIndex = 0
        OnClick = ToolButton4Click
      end
      object ToolButton6: TToolButton
        Left = 320
        Top = 2
        Action = actRemains
      end
    end
  end
  object sbEntries: TStatusBar
    Left = 0
    Top = 427
    Width = 688
    Height = 19
    Panels = <
      item
        Text = 'Дебет: 0'
        Width = 120
      end
      item
        Text = 'Кредит: 0'
        Width = 120
      end
      item
        Text = 'Кол-во: 0'
        Width = 80
      end>
    SimplePanel = False
  end
  object ibdsTransaction: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    SelectSQL.Strings = (
      'SELECT * FROM gd_listtrtype'
      'WHERE companykey = :ck'
      'ORDER BY'
      '  parent DESC')
    Left = 120
    Top = 160
  end
  object dsTransaction: TDataSource
    DataSet = ibdsTransaction
    Left = 120
    Top = 190
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 120
    Top = 228
  end
  object Timer: TTimer
    Interval = 100
    OnTimer = TimerTimer
    Left = 300
    Top = 110
  end
  object ActionList1: TActionList
    Left = 300
    Top = 170
    object actNewOperation: TAction
      Caption = 'Добавить...'
      ShortCut = 45
      OnExecute = actNewOperationExecute
    end
    object actEditOperation: TAction
      Caption = 'Изменить...'
      ShortCut = 13
      OnExecute = actEditOperationExecute
      OnUpdate = actEditOperationUpdate
    end
    object actDelOperation: TAction
      Caption = 'Удалить'
      ShortCut = 46
      OnExecute = actDelOperationExecute
    end
    object actRemains: TAction
      Caption = 'Остатки'
      Hint = 'Остатки'
      OnExecute = actRemainsExecute
    end
  end
  object atSQLSetup: TatSQLSetup
    Ignores = <>
    Left = 350
    Top = 170
  end
  object pFilter: TPopupMenu
    Left = 240
    Top = 270
  end
  object gsQueryFilter: TgsQueryFilter
    OnFilterChanged = gsQueryFilterFilterChanged
    Database = dmDatabase.ibdbGAdmin
    RequeryParams = False
    IBDataSet = ibdsEmpty
    Left = 270
    Top = 270
  end
  object gsReportRegistry: TgsReportRegistry
    DataBase = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    PopupMenu = pOperation
    QueryFilter = gsQueryFilter
    MenuType = mtSeparator
    Caption = 'Печать реестра'
    GroupID = 1000200
    Left = 350
    Top = 230
  end
  object pOperation: TPopupMenu
    Left = 390
    Top = 100
    object N1: TMenuItem
      Action = actNewOperation
    end
    object N2: TMenuItem
      Action = actEditOperation
    end
    object N3: TMenuItem
      Action = actDelOperation
    end
  end
  object gsTransaction: TgsTransaction
    DocumentType = 801000
    DataSource = dsTransaction
    FieldKey = 'ID'
    FieldTrName = 'TRANSACTIONNAME'
    FieldDocumentKey = 'DOCUMENTKEY'
    BeginTransactionType = btManual
    DocumentOnly = False
    MakeDelayedEntry = False
    Left = 350
    Top = 200
  end
  object dsAccountInfo: TDataSource
    DataSet = ibdsAccountInfo
    Left = 390
    Top = 70
  end
  object ibsqlAccountSaldo: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      '  SELECT '
      
        '    SUM(e.DebitSumNCU) as DebitSum, SUM(e.CreditSumNCU) as Credi' +
        'tSum'
      '  FROM gd_entrys e'
      '  WHERE'
      '    e.accountkey = :accountkey and'
      '    e.entrydate < :datebegin')
    Transaction = IBTransaction
    Left = 420
    Top = 70
  end
  object ibdsAccountInfo: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    SelectSQL.Strings = (
      'SELECT * FROM '
      'gd_p_accountinfo(:accountkey, :datebegin, :dateend)')
    Left = 360
    Top = 70
  end
  object ibdsEmpty: TIBDataSet
    BufferChunks = 1000
    CachedUpdates = False
    Left = 300
    Top = 270
  end
end
