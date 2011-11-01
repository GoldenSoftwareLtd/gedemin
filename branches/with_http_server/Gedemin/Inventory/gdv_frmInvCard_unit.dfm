inherited gdv_frmInvCard: Tgdv_frmInvCard
  Left = 404
  Top = 116
  Width = 729
  Height = 513
  Caption = 'Карточка по ТМЦ'
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object splLeft: TSplitter [0]
    Left = 264
    Top = 90
    Width = 5
    Height = 368
    Cursor = crHSplit
  end
  inherited TBDock1: TTBDock
    Width = 721
    Height = 90
    inherited tbMainToolbar: TTBToolbar
      DockPos = 0
      DockRow = 0
      ParentShowHint = False
      ShowHint = True
      object tbiShowParamPanel: TTBItem [0]
        Action = actShowParamPanel
        AutoCheck = True
        Checked = True
      end
      object TBSeparatorItem1: TTBSeparatorItem [1]
      end
      object TBItem2: TTBItem [2]
        Action = actEdit
      end
      object TBSeparatorItem2: TTBSeparatorItem [3]
      end
      object tbiEditInGrid: TTBItem [4]
        Action = actEditInGrid
        AutoCheck = True
      end
      object TBSeparatorItem3: TTBSeparatorItem [5]
      end
      inherited TBItem4: TTBItem
        Visible = False
      end
    end
    inherited TBToolbar2: TTBToolbar
      Left = 0
      Top = 30
      object TBControlItem2: TTBControlItem [1]
        Control = chkAllInterval
      end
      inherited Panel4: TPanel
        Width = 227
        inherited lblPeriod: TLabel
          Top = 5
        end
        inherited SpeedButton1: TSpeedButton
          Left = 201
          Hint = 'Построить отчет'
        end
      end
      object chkAllInterval: TCheckBox
        Left = 227
        Top = 4
        Width = 162
        Height = 17
        Caption = 'За неограниченный период'
        Checked = True
        State = cbChecked
        TabOrder = 1
      end
    end
    object tbConfig: TTBToolbar
      Left = 166
      Top = 0
      Caption = 'Конфигурация'
      CloseButton = False
      DockPos = 136
      Images = dmImages.il16x16
      ParentShowHint = False
      ShowHint = True
      Stretch = True
      TabOrder = 2
      object TBControlItem3: TTBControlItem
        Control = pCofiguration
      end
      object TBItem5: TTBItem
        Action = actSaveConfig
        Caption = 'actSaveConfig'
      end
      object TBSeparatorItem4: TTBSeparatorItem
      end
      object iSaveGridSettings: TTBItem
        Action = actSaveGridSetting
      end
      object iClearSaveGrid: TTBItem
        Action = actClearGridSetting
      end
      object pCofiguration: TPanel
        Left = 0
        Top = 0
        Width = 229
        Height = 26
        BevelOuter = bvNone
        TabOrder = 0
        object lConfiguration: TLabel
          Left = 2
          Top = 6
          Width = 78
          Height = 13
          Caption = 'Конфигурация:'
        end
        object cmbConfig: TgsIBLookupComboBox
          Left = 81
          Top = 3
          Width = 145
          Height = 21
          HelpContext = 1
          Transaction = Transaction
          ListTable = 'AC_ACCT_CONFIG'
          ListField = 'NAME'
          KeyField = 'ID'
          gdClassName = 'TgdcInvCardConfig'
          Color = 15329769
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          OnChange = cmbConfigChange
        end
      end
    end
    object tbGoodInfo: TTBToolbar
      Left = 0
      Top = 60
      Caption = 'tbGoodInfo'
      DockPos = 0
      DockRow = 5
      FloatingMode = fmOnTopOfAllForms
      FullSize = True
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      object TBItem3: TTBItem
        Visible = False
      end
      object TBControlItem4: TTBControlItem
        Control = Panel3
      end
      object TBControlItem5: TTBControlItem
        Control = cmbGood
      end
      object TBControlItem6: TTBControlItem
        Control = cmbDept
      end
      object Panel3: TPanel
        Left = 0
        Top = 0
        Width = 409
        Height = 26
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object Label5: TLabel
          Left = 6
          Top = 6
          Width = 100
          Height = 13
          Caption = 'Остаток на начало '
        end
        object Label6: TLabel
          Left = 232
          Top = 6
          Width = 45
          Height = 13
          Caption = 'на конец'
        end
        object edBeginRest: TEdit
          Left = 107
          Top = 2
          Width = 121
          Height = 21
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 0
        end
        object edEndRest: TEdit
          Left = 281
          Top = 2
          Width = 121
          Height = 21
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 1
        end
      end
      object cmbGood: TgsIBLookupComboBox
        Left = 409
        Top = 2
        Width = 80
        Height = 21
        HelpContext = 1
        TabStop = False
        Database = dmDatabase.ibdbGAdmin
        ListTable = 'gd_good'
        ListField = 'name'
        KeyField = 'id'
        ItemHeight = 13
        TabOrder = 1
        Visible = False
      end
      object cmbDept: TgsIBLookupComboBox
        Left = 489
        Top = 2
        Width = 80
        Height = 21
        HelpContext = 1
        TabStop = False
        Database = dmDatabase.ibdbGAdmin
        ListTable = 'gd_contact'
        ListField = 'name'
        KeyField = 'id'
        Condition = 'c.contacttype = 4'
        ItemHeight = 13
        TabOrder = 2
        Visible = False
      end
    end
  end
  inherited Panel1: TPanel
    Left = 269
    Top = 90
    Width = 443
    Height = 368
    object ibgrMain: TgsIBGrid
      Left = 0
      Top = 49
      Width = 443
      Height = 319
      HelpContext = 3
      Align = alClient
      BorderStyle = bsNone
      DataSource = dsMain
      Options = [dgTitles, dgColumnResize, dgColLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
      ReadOnly = True
      TabOrder = 0
      OnDblClick = ibgrMainDblClick
      TableColor = 15329769
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
      ScaleColumns = True
      MinColWidth = 40
      ColumnEditors = <>
      Aliases = <>
      Columns = <
        item
          Alignment = taLeftJustify
          Expanded = False
          Width = 64
          Visible = True
        end>
    end
    object Panel2: TPanel
      Left = 0
      Top = 0
      Width = 443
      Height = 49
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 1
      Visible = False
      object Bevel1: TBevel
        Left = 0
        Top = 47
        Width = 443
        Height = 2
        Align = alBottom
        Shape = bsFrame
        Style = bsRaised
      end
    end
  end
  inherited TBDock2: TTBDock
    Top = 90
    Height = 368
  end
  inherited TBDock3: TTBDock
    Left = 712
    Top = 90
    Height = 368
  end
  inherited TBDock4: TTBDock
    Top = 458
    Width = 721
  end
  object pnlLeft: TPanel [6]
    Left = 9
    Top = 90
    Width = 255
    Height = 368
    Align = alLeft
    BevelOuter = bvNone
    Color = 15329769
    Constraints.MinHeight = 300
    Constraints.MinWidth = 255
    TabOrder = 5
    object sbLeft: TScrollBox
      Left = 0
      Top = 0
      Width = 255
      Height = 368
      Align = alClient
      BorderStyle = bsNone
      TabOrder = 0
      object spl1: TSplitter
        Left = 0
        Top = 353
        Width = 239
        Height = 5
        Cursor = crVSplit
        Align = alTop
      end
      object pnlTop: TPanel
        Left = 0
        Top = 0
        Width = 239
        Height = 89
        Align = alTop
        BevelOuter = bvNone
        ParentColor = True
        TabOrder = 0
        object chkGroupByDoc: TCheckBox
          Left = 5
          Top = 57
          Width = 196
          Height = 16
          Anchors = [akLeft, akBottom]
          Caption = 'Группировать по типу документа'
          TabOrder = 2
          Visible = False
          OnClick = chkInternalOpsClick
        end
        object chkInternalOps: TCheckBox
          Left = 5
          Top = 72
          Width = 212
          Height = 16
          Anchors = [akLeft, akBottom]
          Caption = 'Отображать внутренние операции'
          TabOrder = 0
          OnClick = chkInternalOpsClick
        end
        inline frMainValues: TfrFieldValues
          Width = 239
          Height = 57
          Align = alTop
          TabOrder = 1
          OnResize = frMainValuesResize
          inherited ppMain: TgdvParamPanel
            Width = 239
          end
          inherited sbMain: TgdvParamScrolBox
            Width = 239
            Height = 27
            Color = 15329769
          end
        end
      end
      object ppCardFields: TgdvParamPanel
        Left = 0
        Top = 185
        Width = 239
        Height = 168
        Align = alTop
        Caption = 'Отображаемые признаки карточки'
        Color = 15329769
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clNavy
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 1
        Unwraped = True
        HorisontalOffset = 0
        VerticalOffset = 0
        FillColor = 16316664
        StripeOdd = 47495848
        StripeEven = 49606634
        Origin = oLeft
        object lbCard: TCheckListBox
          Left = 1
          Top = 17
          Width = 237
          Height = 150
          Align = alClient
          BorderStyle = bsNone
          Color = 16316664
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemHeight = 13
          ParentFont = False
          Sorted = True
          TabOrder = 0
          OnClick = lbCardClick
          OnKeyPress = lbCardKeyPress
        end
      end
      object ppGoodFields: TgdvParamPanel
        Left = 0
        Top = 358
        Width = 239
        Height = 171
        Align = alTop
        Caption = 'Отображаемые признаки товара'
        Color = 15329769
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clNavy
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 2
        Unwraped = True
        HorisontalOffset = 0
        VerticalOffset = 0
        FillColor = 16316664
        StripeOdd = 47495848
        StripeEven = 49606634
        Origin = oLeft
        object lbGood: TCheckListBox
          Left = 1
          Top = 17
          Width = 237
          Height = 153
          Align = alClient
          BorderStyle = bsNone
          Color = 16316664
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemHeight = 13
          ParentFont = False
          Sorted = True
          TabOrder = 0
          OnClick = lbCardClick
          OnKeyPress = lbCardKeyPress
        end
      end
      inline frGoodValues: TfrFieldValues
        Top = 567
        Width = 239
        Height = 48
        Align = alTop
        TabOrder = 3
        inherited ppMain: TgdvParamPanel
          Width = 239
        end
        inherited sbMain: TgdvParamScrolBox
          Width = 239
          Height = 18
        end
      end
      inline frCardValues: TfrFieldValues
        Top = 529
        Width = 239
        Height = 38
        Align = alTop
        TabOrder = 4
        inherited ppMain: TgdvParamPanel
          Width = 239
        end
        inherited sbMain: TgdvParamScrolBox
          Width = 239
          Height = 8
        end
      end
      inline frCreditDocs: TfrFieldValues
        Top = 137
        Width = 239
        Height = 48
        Align = alTop
        TabOrder = 5
        inherited ppMain: TgdvParamPanel
          Width = 239
          Caption = 'Документы расхода'
        end
        inherited sbMain: TgdvParamScrolBox
          Top = 40
          Width = 239
          Height = 8
          Align = alNone
        end
      end
      inline frDebitDocs: TfrFieldValues
        Top = 89
        Width = 239
        Height = 48
        Align = alTop
        TabOrder = 6
        inherited ppMain: TgdvParamPanel
          Width = 239
          Caption = 'Документы прихода'
        end
        inherited sbMain: TgdvParamScrolBox
          Top = 40
          Width = 255
          Height = 8
          Align = alNone
        end
      end
    end
  end
  object StatusBar1: TStatusBar [7]
    Left = 0
    Top = 467
    Width = 721
    Height = 19
    Panels = <>
    SimplePanel = False
  end
  inherited dsMain: TDataSource
    DataSet = gdcInvCard
  end
  inherited alMain: TActionList
    inherited actRun: TAction
      OnUpdate = actRunUpdate
    end
    object actShowParamPanel: TAction
      Caption = 'Параметры'
      Hint = 'Показать\спрятать панель параметров'
      ImageIndex = 228
      OnExecute = actShowParamPanelExecute
    end
    object actSaveConfig: TAction
      Category = 'Commands'
      Caption = 'Сохранить конфигурацию'
      Hint = 'Сохранить текущую конфигурацию'
      ImageIndex = 38
      OnExecute = actSaveConfigExecute
    end
    object actSaveGridSetting: TAction
      Category = 'Commands'
      Caption = 'Сохранить настройки таблицы'
      Hint = 'Сохранить настройки таблицы'
      ImageIndex = 72
      OnExecute = actSaveGridSettingExecute
      OnUpdate = actSaveGridSettingUpdate
    end
    object actClearGridSetting: TAction
      Category = 'Commands'
      Caption = 'Сохранить настройки таблицы'
      Hint = 'Удалить настройки таблицы из текущей конфигурации'
      ImageIndex = 261
      OnExecute = actClearGridSettingExecute
      OnUpdate = actClearGridSettingUpdate
    end
    object actEditInGrid: TAction
      Category = 'Commands'
      Caption = 'Редактирование в таблице'
      Hint = 'Редактирование в таблице'
      ImageIndex = 213
      OnExecute = actEditInGridExecute
      OnUpdate = actEditInGridUpdate
    end
    object actEdit: TAction
      Category = 'Commands'
      Caption = 'Изменить...'
      Hint = 'Изменить...'
      ImageIndex = 1
      OnExecute = actEditExecute
      OnUpdate = actEditUpdate
    end
    object actInputParams: TAction
      Caption = 'actInputParams'
    end
    object actShowCard: TAction
      Caption = 'actShowCard'
      OnExecute = actShowCardExecute
    end
  end
  inherited gsQueryFilter: TgsQueryFilter
    IBDataSet = gdcInvCard
  end
  object gdcInvCard: TgdcInvCard
    Transaction = Transaction
    SubSet = 'ByID'
    ReadTransaction = Transaction
    OnFilterRecord = gdcInvCardFilterRecord
    OnGetSelectClause = gdcInvCardGetSelectClause
    OnGetFromClause = gdcInvCardGetFromClause
    OnGetGroupClause = gdcInvCardGetGroupClause
    Left = 361
    Top = 94
  end
  object Transaction: TIBTransaction
    Active = False
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 407
    Top = 104
  end
  object gdcConfig: TgdcInvCardConfig
    Transaction = Transaction
    ReadTransaction = Transaction
    Left = 81
    Top = 226
  end
end
