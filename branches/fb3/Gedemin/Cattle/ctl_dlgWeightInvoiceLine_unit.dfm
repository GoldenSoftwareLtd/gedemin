object ctl_dlgWeightInvoiceLine: Tctl_dlgWeightInvoiceLine
  Left = 328
  Top = 101
  ActiveControl = grdBranch1
  BorderStyle = bsDialog
  Caption = 'Позиция отвес-накладной'
  ClientHeight = 387
  ClientWidth = 542
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 349
    Width = 542
    Height = 38
    Align = alBottom
    BevelOuter = bvNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    object btnOk: TButton
      Left = 376
      Top = 6
      Width = 75
      Height = 24
      Anchors = [akTop, akRight]
      Caption = 'OK'
      ModalResult = 1
      TabOrder = 1
    end
    object btnCancel: TButton
      Left = 456
      Top = 6
      Width = 75
      Height = 24
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 2
    end
    object btnNext: TButton
      Left = 11
      Top = 7
      Width = 90
      Height = 24
      Caption = '&Следующая...'
      TabOrder = 0
      OnClick = btnNextClick
    end
    object Button1: TButton
      Left = 112
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Дальше'
      Default = True
      TabOrder = 3
      OnClick = Button1Click
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 542
    Height = 349
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object Bevel2: TBevel
      Left = 10
      Top = 224
      Width = 522
      Height = 116
      Shape = bsFrame
    end
    object Bevel1: TBevel
      Left = 0
      Top = 347
      Width = 542
      Height = 2
      Align = alBottom
    end
    object Label3: TLabel
      Left = 22
      Top = 234
      Width = 71
      Height = 13
      Caption = 'Кол-во голов:'
      Transparent = True
    end
    object lblMeatWeight: TLabel
      Left = 148
      Top = 234
      Width = 47
      Height = 13
      Caption = 'Вес мяса:'
    end
    object lblLiveWeight: TLabel
      Left = 282
      Top = 234
      Width = 74
      Height = 26
      AutoSize = False
      Caption = 'Вес скота без скидки:'
      WordWrap = True
    end
    object lblRealWeight: TLabel
      Left = 413
      Top = 234
      Width = 73
      Height = 26
      AutoSize = False
      Caption = 'Вес скота со скидкой:'
      WordWrap = True
    end
    object lblDestination: TLabel
      Left = 326
      Top = 292
      Width = 85
      Height = 13
      Caption = 'Вид назначения:'
      Visible = False
    end
    object Label1: TLabel
      Left = 11
      Top = 7
      Width = 108
      Height = 13
      Caption = 'Группы скота (мяса):'
    end
    object lblGoodName: TLabel
      Left = 23
      Top = 292
      Width = 143
      Height = 13
      Caption = 'Наименование скота (мяса):'
    end
    object luDestination: TgsIBLookupComboBox
      Left = 326
      Top = 308
      Width = 191
      Height = 21
      HelpContext = 1
      TabStop = False
      Database = dmDatabase.ibdbGAdmin
      Transaction = ibtrInvoiceLine
      DataSource = dsInvoiceLine
      DataField = 'DESTKEY'
      ListTable = 'CTL_REFERENCE'
      ListField = 'NAME'
      KeyField = 'ID'
      Condition = 'PARENT = 2000'
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = True
      TabOrder = 6
      Visible = False
    end
    object dbeQuantity: TDBEdit
      Left = 21
      Top = 262
      Width = 106
      Height = 21
      DataField = 'QUANTITY'
      DataSource = dsInvoiceLine
      TabOrder = 1
      OnExit = dbeQuantityExit
    end
    object dbeMeatWeight: TDBEdit
      Left = 147
      Top = 262
      Width = 106
      Height = 21
      DataField = 'MEATWEIGHT'
      DataSource = dsInvoiceLine
      TabOrder = 2
    end
    object dbeLiveWeight: TDBEdit
      Left = 281
      Top = 262
      Width = 106
      Height = 21
      DataField = 'LIVEWEIGHT'
      DataSource = dsInvoiceLine
      TabOrder = 3
    end
    object pnlTree: TPanel
      Left = 10
      Top = 24
      Width = 523
      Height = 194
      Anchors = [akLeft, akTop, akRight]
      BevelOuter = bvNone
      TabOrder = 0
      object Splitter1: TSplitter
        Left = 170
        Top = 0
        Width = 6
        Height = 194
        Cursor = crHSplit
      end
      object Splitter2: TSplitter
        Left = 346
        Top = 0
        Width = 6
        Height = 194
        Cursor = crHSplit
      end
      object grdBranch3: TgsIBGrid
        Left = 352
        Top = 0
        Width = 171
        Height = 194
        Align = alClient
        DataSource = dsBranch3
        Options = [dgTitles, dgColumnResize, dgColLines, dgAlwaysShowSelection, dgCancelOnExit]
        TabOrder = 2
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
      object grdBranch2: TgsIBGrid
        Left = 176
        Top = 0
        Width = 170
        Height = 194
        Align = alLeft
        DataSource = dsBranch2
        Options = [dgTitles, dgColumnResize, dgColLines, dgAlwaysShowSelection, dgCancelOnExit]
        TabOrder = 1
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
      object grdBranch1: TgsIBGrid
        Left = 0
        Top = 0
        Width = 170
        Height = 194
        Align = alLeft
        DataSource = dsBranch1
        Options = [dgTitles, dgColumnResize, dgColLines, dgAlwaysShowSelection, dgCancelOnExit]
        TabOrder = 0
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
    end
    object dbeRealWeight: TDBEdit
      Left = 412
      Top = 262
      Width = 106
      Height = 21
      DataField = 'REALWEIGHT'
      DataSource = dsInvoiceLine
      TabOrder = 4
    end
    object luGood: TgsIBLookupComboBox
      Left = 22
      Top = 308
      Width = 288
      Height = 21
      HelpContext = 1
      Database = dmDatabase.ibdbGAdmin
      Transaction = ibtrInvoiceLine
      DataSource = dsInvoiceLine
      DataField = 'GOODKEY'
      ListTable = 'GD_GOOD'
      ListField = 'NAME'
      KeyField = 'ID'
      gdClassName = 'TgdcGood'
      Ctl3D = True
      ItemHeight = 13
      ParentCtl3D = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 5
      OnEnter = luGoodEnter
    end
  end
  object dsInvoiceLine: TDataSource
    DataSet = ibdsInvoiceLine
    Left = 70
    Top = 40
  end
  object ibdsInvoiceLine: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrInvoiceLine
    CachedUpdates = True
    DeleteSQL.Strings = (
      'delete from CTL_INVOICEPOS'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into CTL_INVOICEPOS'
      
        '  (ID, INVOICEKEY, GOODKEY, QUANTITY, MEATWEIGHT, LIVEWEIGHT, RE' +
        'ALWEIGHT, '
      '   DESTKEY, AFULL, ACHAG, AVIEW, DISABLED, RESERVED)'
      'values'
      
        '  (:ID, :INVOICEKEY, :GOODKEY, :QUANTITY, :MEATWEIGHT, :LIVEWEIG' +
        'HT, :REALWEIGHT, '
      '   :DESTKEY, :AFULL, :ACHAG, :AVIEW, :DISABLED, :RESERVED)')
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
      '  *'
      ''
      'FROM'
      '  CTL_INVOICEPOS'
      ''
      'WHERE'
      '  INVOICEKEY = :DOCUMENTKEY'
      '')
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
      '  DISABLED = :DISABLED,'
      '  RESERVED = :RESERVED'
      'where'
      '  ID = :OLD_ID')
    ReadTransaction = ibtrInvoiceLine
    Left = 70
    Top = 70
  end
  object ibtrInvoiceLine: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 100
    Top = 70
  end
  object ibdsBranch1: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrInvoiceLine
    AfterInsert = ibdsBranch1AfterInsert
    AfterOpen = ibdsBranch1AfterOpen
    AfterScroll = ibdsBranch1AfterScroll
    DeleteSQL.Strings = (
      'delete from GD_GOODGROUP'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into GD_GOODGROUP'
      '  (NAME, ID, LB, RB)'
      'values'
      '  (:NAME, :ID, :LB, :RB)')
    RefreshSQL.Strings = (
      'Select '
      '  gg.ID,'
      '  gg.PARENT,'
      '  gg.LB,'
      '  gg.RB,'
      '  gg.NAME,'
      '  gg.ALIAS,'
      '  gg.DESCRIPTION,'
      '  gg.DISABLED,'
      '  gg.RESERVED,'
      '  gg.AFULL,'
      '  gg.ACHAG,'
      '  gg.AVIEW'
      'from GD_GOODGROUP gg'
      'where'
      '  gg.ID = :ID')
    SelectSQL.Strings = (
      'SELECT'
      '  GG.NAME, GG.ID, GG.LB, GG.RB'
      ''
      'FROM'
      '    GD_GOODGROUP GG'
      ''
      'WHERE'
      '  GG.PARENT = :PARENTKEY'
      ''
      'ORDER BY'
      '  GG.NAME'
      ' ')
    ModifySQL.Strings = (
      'update GD_GOODGROUP'
      'set'
      '  NAME = :NAME,'
      '  ID = :ID,'
      '  LB = :LB,'
      '  RB = :RB'
      'where'
      '  ID = :OLD_ID')
    ReadTransaction = ibtrInvoiceLine
    Left = 170
    Top = 70
  end
  object dsBranch1: TDataSource
    DataSet = ibdsBranch1
    Left = 170
    Top = 40
  end
  object ibdsBranch2: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrInvoiceLine
    AfterInsert = ibdsBranch1AfterInsert
    AfterOpen = ibdsBranch1AfterOpen
    AfterScroll = ibdsBranch2AfterScroll
    DeleteSQL.Strings = (
      'delete from GD_GOODGROUP'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into GD_GOODGROUP'
      '  (NAME, ID, LB, RB)'
      'values'
      '  (:NAME, :ID, :LB, :RB)')
    RefreshSQL.Strings = (
      'Select '
      '  gg.ID,'
      '  gg.PARENT,'
      '  gg.LB,'
      '  gg.RB,'
      '  gg.NAME,'
      '  gg.ALIAS,'
      '  gg.DESCRIPTION,'
      '  gg.DISABLED,'
      '  gg.RESERVED,'
      '  gg.AFULL,'
      '  gg.ACHAG,'
      '  gg.AVIEW'
      'from GD_GOODGROUP gg'
      'where'
      '  gg.ID = :ID')
    SelectSQL.Strings = (
      'SELECT'
      '  GG.NAME, GG.ID, GG.LB, GG.RB'
      ''
      'FROM'
      '    GD_GOODGROUP GG'
      ''
      'WHERE'
      '  GG.PARENT = :ID'
      ''
      'ORDER BY'
      '  GG.NAME'
      ' ')
    ModifySQL.Strings = (
      'update GD_GOODGROUP'
      'set'
      '  NAME = :NAME,'
      '  ID = :ID,'
      '  LB = :LB,'
      '  RB = :RB'
      'where'
      '  ID = :OLD_ID')
    DataSource = dsBranch1
    ReadTransaction = ibtrInvoiceLine
    Left = 200
    Top = 70
  end
  object dsBranch2: TDataSource
    DataSet = ibdsBranch2
    Left = 200
    Top = 40
  end
  object ibdsBranch3: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrInvoiceLine
    AfterInsert = ibdsBranch1AfterInsert
    AfterOpen = ibdsBranch1AfterOpen
    AfterScroll = ibdsBranch3AfterScroll
    DeleteSQL.Strings = (
      'delete from GD_GOODGROUP'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into GD_GOODGROUP'
      '  (NAME, ID, LB, RB)'
      'values'
      '  (:NAME, :ID, :LB, :RB)')
    RefreshSQL.Strings = (
      'Select '
      '  gg.ID,'
      '  gg.PARENT,'
      '  gg.LB,'
      '  gg.RB,'
      '  gg.NAME,'
      '  gg.ALIAS,'
      '  gg.DESCRIPTION,'
      '  gg.DISABLED,'
      '  gg.RESERVED,'
      '  gg.AFULL,'
      '  gg.ACHAG,'
      '  gg.AVIEW'
      'from GD_GOODGROUP  gg'
      'where'
      '  gg.ID = :ID')
    SelectSQL.Strings = (
      'SELECT'
      '  GG.NAME, GG.ID, GG.LB, GG.RB'
      ''
      'FROM'
      '    GD_GOODGROUP GG'
      ''
      'WHERE'
      '  GG.PARENT = :ID'
      ''
      'ORDER BY'
      '  GG.NAME'
      ' ')
    ModifySQL.Strings = (
      'update GD_GOODGROUP'
      'set'
      '  NAME = :NAME,'
      '  ID = :ID,'
      '  LB = :LB,'
      '  RB = :RB'
      'where'
      '  ID = :OLD_ID')
    DataSource = dsBranch2
    ReadTransaction = ibtrInvoiceLine
    Left = 230
    Top = 70
  end
  object dsBranch3: TDataSource
    DataSet = ibdsBranch3
    Left = 230
    Top = 40
  end
  object ibsqlWeight: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'SELECT'
      '  D.GOODKEY'
      ''
      'FROM'
      '  CTL_DISCOUNT D'
      ''
      '    JOIN GD_GOOD G ON'
      '      G.ID = D.GOODKEY'
      ''
      '    JOIN GD_GOODGROUP GG ON'
      '      GG.ID = G.GROUPKEY'
      ''
      'WHERE'
      '  GG.LB >= :LB'
      '    AND'
      '  GG.RB <= :RB'
      '    AND'
      '  :WEIGHT BETWEEN D.MINWEIGHT AND D.MAXWEIGHT ')
    Transaction = ibtrInvoiceLine
    Left = 70
    Top = 100
  end
  object atSQLSetup: TatSQLSetup
    Ignores = <>
    Left = 70
    Top = 130
  end
  object q: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrInvoiceLine
    Left = 100
    Top = 101
  end
  object IBSQL: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrInvoiceLine
    Left = 130
    Top = 101
  end
end
