inherited gdv_frmAcctBaseForm: Tgdv_frmAcctBaseForm
  Left = 182
  Top = 192
  Width = 983
  Height = 656
  Caption = 'gdv_frmAcctBaseForm'
  OldCreateOrder = True
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object sLeft: TSplitter [0]
    Left = 255
    Top = 30
    Width = 6
    Height = 579
    Cursor = crHSplit
  end
  inherited TBDock1: TTBDock
    Width = 967
    inherited tbMainToolbar: TTBToolbar
      DockMode = dmCannotFloat
      DockPos = 0
      DockRow = 0
      ParentShowHint = False
      ShowHint = True
      object TBItem3: TTBItem [0]
        Action = actShowParamPanel
      end
      object TBSeparatorItem1: TTBSeparatorItem [1]
      end
      object TBItem2: TTBItem [2]
        Action = actGoto
      end
      object tbiComeBack: TTBItem [3]
        Action = actBack
      end
      object TBSeparatorItem2: TTBSeparatorItem [4]
      end
      inherited TBItem4: TTBItem
        Visible = False
      end
      object TBSeparatorItem3: TTBSeparatorItem [8]
      end
      object TBItem6: TTBItem [9]
        Action = actEditInGrid
        Caption = 'Редактирование в таблице'
      end
      object TBSeparatorItem4: TTBSeparatorItem [10]
      end
    end
    inherited TBToolbar2: TTBToolbar
      Left = 195
      DockMode = dmCannotFloat
      DockRow = 0
      ParentShowHint = False
      ShowHint = True
      inherited Panel4: TPanel
        Width = 229
        inherited lblPeriod: TLabel
          Left = 3
        end
        inherited SpeedButton1: TSpeedButton
          Left = 201
        end
      end
    end
    object TBToolbar1: TTBToolbar
      Left = 434
      Top = 0
      Caption = 'Конфигурация'
      CloseButton = False
      DockMode = dmCannotFloat
      DockPos = 384
      Images = dmImages.il16x16
      ParentShowHint = False
      ShowHint = True
      Stretch = True
      TabOrder = 2
      object TBControlItem2: TTBControlItem
        Control = pCofiguration
      end
      object TBItem5: TTBItem
        Action = actSaveConfig
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
        object iblConfiguratior: TgsIBLookupComboBox
          Left = 81
          Top = 3
          Width = 145
          Height = 21
          HelpContext = 1
          Transaction = Transaction
          ListTable = 'AC_ACCT_CONFIG'
          ListField = 'NAME'
          KeyField = 'ID'
          gdClassName = 'TgdcAcctBaseConfig'
          Color = 15329769
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          OnChange = iblConfiguratiorChange
        end
      end
    end
  end
  inherited Panel1: TPanel
    Left = 261
    Width = 697
    Height = 579
    object ibgrMain: TgsIBGrid
      Left = 0
      Top = 0
      Width = 697
      Height = 579
      HelpContext = 3
      Align = alClient
      BorderStyle = bsNone
      DataSource = dsMain
      Options = [dgTitles, dgColumnResize, dgColLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
      PopupMenu = ppMain
      ReadOnly = True
      TabOrder = 0
      OnDblClick = ibgrMainDblClick
      OnKeyDown = ibgrMainKeyDown
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
      MinColWidth = 40
      ColumnEditors = <>
      Aliases = <>
    end
  end
  inherited TBDock2: TTBDock
    Height = 579
  end
  inherited TBDock3: TTBDock
    Left = 958
    Height = 579
  end
  inherited TBDock4: TTBDock
    Top = 609
    Width = 967
  end
  object pLeft: TPanel [6]
    Left = 9
    Top = 30
    Width = 246
    Height = 579
    Align = alLeft
    BevelOuter = bvNone
    Caption = 'pLeft'
    TabOrder = 5
    object ScrollBox: TScrollBox
      Left = 0
      Top = 17
      Width = 246
      Height = 562
      VertScrollBar.Style = ssFlat
      Align = alClient
      BorderStyle = bsNone
      Color = 15329769
      ParentColor = False
      TabOrder = 0
      object Panel5: TPanel
        Left = 0
        Top = 0
        Width = 246
        Height = 64
        Align = alTop
        BevelOuter = bvNone
        Constraints.MinWidth = 224
        ParentColor = True
        TabOrder = 0
        object Label17: TLabel
          Left = 8
          Top = 12
          Width = 35
          Height = 13
          Caption = 'Счета:'
          Layout = tlCenter
        end
        object bAccounts: TButton
          Left = 219
          Top = 8
          Width = 20
          Height = 20
          Action = actAccounts
          Anchors = [akTop, akRight]
          TabOrder = 1
        end
        object cbSubAccount: TCheckBox
          Left = 8
          Top = 32
          Width = 127
          Height = 17
          Caption = 'Включать субсчета'
          TabOrder = 2
          OnClick = cbSubAccountClick
        end
        object cbIncludeInternalMovement: TCheckBox
          Left = 8
          Top = 48
          Width = 209
          Height = 17
          Caption = 'Включать внутренние проводки'
          TabOrder = 3
        end
        object cbAccounts: TComboBox
          Left = 45
          Top = 8
          Width = 174
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          ItemHeight = 13
          TabOrder = 0
          OnChange = cbAccountsChange
          OnExit = cbAccountsExit
        end
      end
      inline frAcctQuantity: TfrAcctQuantity
        Top = 105
        Width = 246
        Align = alTop
        TabOrder = 2
        inherited ppMain: TgdvParamPanel
          Width = 246
          FillColor = 16316664
          StripeOdd = 15967211
          StripeEven = 16379125
          Steps = 12
        end
      end
      inline frAcctSum: TfrAcctSum
        Top = 146
        Width = 246
        Height = 221
        VertScrollBar.Range = 0
        Align = alTop
        AutoScroll = False
        TabOrder = 3
        inherited ppMain: TgdvParamPanel
          Width = 246
          Height = 219
          HorisontalOffset = 5
          FillColor = 16316664
          inherited pnlEQ: TPanel
            Left = 6
            Width = 234
            inherited Label1: TLabel
              ParentColor = False
            end
            inherited Label2: TLabel
              ParentColor = False
            end
            inherited cbInEQ: TCheckBox
              ParentColor = False
            end
          end
          inherited pnlQuantity: TPanel
            Left = 6
            Width = 234
          end
          inherited pnlTop: TPanel
            Left = 6
            Width = 234
            inherited Label5: TLabel
              Color = 15987699
              ParentColor = False
              Transparent = True
            end
            inherited Label6: TLabel
              Transparent = True
            end
            inherited Label11: TLabel
              Transparent = True
            end
            inherited Label18: TLabel
              Transparent = True
            end
            inherited Label12: TLabel
              Transparent = True
            end
            inherited cbInNcu: TCheckBox
              ParentColor = False
            end
            inherited cbInCurr: TCheckBox
              ParentColor = False
            end
          end
        end
      end
      inline frAcctAnalytics: TfrAcctAnalytics
        Top = 64
        Width = 246
        TabOrder = 1
        inherited ppAnalytics: TgdvParamPanel
          Width = 246
          Caption = 'Аналитика'
          FillColor = 16316664
        end
      end
      inline frAcctCompany: TfrAcctCompany
        Top = 367
        Width = 246
        Height = 60
        Align = alTop
        TabOrder = 4
        inherited ppMain: TgdvParamPanel
          Width = 246
          FillColor = 16316664
          inherited cbAllCompanies: TCheckBox
            Width = 189
            Anchors = [akLeft, akTop, akRight]
            Color = 16316664
          end
          inherited iblCompany: TgsIBLookupComboBox
            Width = 153
            Anchors = [akLeft, akTop, akRight]
          end
        end
        inherited Transaction: TIBTransaction
          Left = 56
        end
      end
      object ppAppear: TgdvParamPanel
        Left = 0
        Top = 427
        Width = 246
        Height = 41
        Align = alTop
        Caption = 'Отображение'
        Color = 15329769
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 13238474
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 5
        TabStop = True
        Unwraped = True
        HorisontalOffset = 5
        VerticalOffset = 1
        FillColor = 16316664
        StripeOdd = 15709420
        StripeEven = 16111358
        Origin = oLeft
        object cbExtendedFields: TCheckBox
          Left = 14
          Top = 21
          Width = 195
          Height = 17
          Caption = 'Расширенное отображение полей'
          Color = 16316664
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          TabOrder = 0
        end
      end
    end
    object Panel2: TPanel
      Left = 0
      Top = 0
      Width = 246
      Height = 17
      Align = alTop
      Alignment = taLeftJustify
      BevelOuter = bvNone
      Caption = ' Параметры'
      TabOrder = 1
      Visible = False
      object sbCloseParamPanel: TSpeedButton
        Left = 214
        Top = 3
        Width = 14
        Height = 13
        Action = actCloseParamPanel
        Anchors = [akTop, akRight]
        Flat = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
      end
    end
  end
  inherited dsMain: TDataSource
    Left = 440
    Top = 72
  end
  inherited alMain: TActionList
    Left = 408
    Top = 72
    inherited actFilter: TAction
      Enabled = False
    end
    inherited actRun: TAction
      Hint = 'Построить отчет'
    end
    object actShowParamPanel: TAction
      Caption = 'Параметры'
      Hint = 'Показать\спрятать панель параметров'
      ImageIndex = 228
      OnExecute = actShowParamPanelExecute
      OnUpdate = actShowParamPanelUpdate
    end
    object actAccounts: TAction
      Category = 'Commands'
      Caption = '...'
      OnExecute = actAccountsExecute
    end
    object actCloseParamPanel: TAction
      Caption = 'X'
      Hint = 'Закрыть панель параметров'
      OnExecute = actCloseParamPanelExecute
    end
    object actGoto: TAction
      Caption = 'actGoto'
      ImageIndex = 53
      ShortCut = 16455
      OnExecute = actGotoExecute
      OnUpdate = actGotoUpdate
    end
    object actSaveConfig: TAction
      Category = 'Commands'
      Caption = 'Сохранить конфигурацию'
      Hint = 'Сохранить текущую конфигурацию'
      ImageIndex = 38
      OnExecute = actSaveConfigExecute
    end
    object actEditInGrid: TAction
      Caption = 'actEditInGrid'
      ImageIndex = 159
      OnExecute = actEditInGridExecute
      OnUpdate = actEditInGridUpdate
    end
    object actSaveGridSetting: TAction
      Category = 'Commands'
      Caption = 'Сохранить настройки таблицы'
      Hint = 'Сохранить настройки таблицы в текущую конфигурацию'
      ImageIndex = 72
      OnExecute = actSaveGridSettingExecute
      OnUpdate = actSaveGridSettingUpdate
    end
    object actClearGridSetting: TAction
      Category = 'Commands'
      Caption = 'Удалить настройки таблицы'
      Hint = 'Удалить настройки таблицы из текущей конфигурации'
      ImageIndex = 261
      OnExecute = actClearGridSettingExecute
      OnUpdate = actSaveGridSettingUpdate
    end
    object actBack: TAction
      Caption = 'Назад'
      Hint = 'Назад'
      ImageIndex = 239
      OnExecute = actBackExecute
      OnUpdate = actBackUpdate
    end
  end
  inherited gdMacrosMenu: TgdMacrosMenu
    Left = 472
    Top = 72
  end
  inherited gdReportMenu: TgdReportMenu
    Left = 504
    Top = 72
  end
  inherited gsQueryFilter: TgsQueryFilter
    Database = nil
    Left = 536
    Top = 72
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
  object ppMain: TPopupMenu
    Images = dmImages.il16x16
    Left = 439
    Top = 104
    object actGoto1: TMenuItem
      Action = actGoto
    end
  end
  object AccountDelayTimer: TTimer
    Enabled = False
    OnTimer = AccountDelayTimerTimer
    Left = 280
    Top = 72
  end
  object IBReadTr: TIBTransaction
    Active = False
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait'
      'read')
    AutoStopAction = saNone
    Left = 412
    Top = 150
  end
end
