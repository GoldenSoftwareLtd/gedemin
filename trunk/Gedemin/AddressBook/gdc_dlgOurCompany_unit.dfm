inherited gdc_dlgOurCompany: Tgdc_dlgOurCompany
  Left = 368
  Top = 236
  ActiveControl = dbeName
  Caption = 'Компания'
  PixelsPerInch = 96
  TextHeight = 13
  inherited pgcMain: TPageControl
    inherited TabSheet3: TTabSheet
      inherited gsiblkupAddress: TgsIBLookupComboBox
        ItemHeight = 13
      end
      inherited gsIBlcHeadCompany: TgsIBLookupComboBox
        ItemHeight = 13
      end
      inherited gsiblkupChiefAccountant: TgsIBLookupComboBox
        ItemHeight = 13
      end
      inherited gsiblkupDirector: TgsIBLookupComboBox
        ItemHeight = 13
      end
    end
    object TabSheet1: TTabSheet
      Caption = 'План счетов'
      ImageIndex = 6
      object lbActive: TLabel
        Left = 9
        Top = 4
        Width = 120
        Height = 13
        Caption = 'Активный план счетов:'
      end
      object dbgCompanyChart: TgsIBGrid
        Left = 8
        Top = 24
        Width = 377
        Height = 257
        HelpContext = 3
        DataSource = dsCompanyChart
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
        TabOrder = 0
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
      object Button1: TButton
        Left = 393
        Top = 25
        Width = 75
        Height = 21
        Action = actChooseAccount
        TabOrder = 1
      end
      object Button2: TButton
        Left = 393
        Top = 49
        Width = 75
        Height = 21
        Action = actDeleteAccount
        TabOrder = 2
      end
      object Button3: TButton
        Left = 393
        Top = 73
        Width = 75
        Height = 21
        Action = actActiveAccount
        TabOrder = 3
      end
      object Button4: TButton
        Left = 393
        Top = 97
        Width = 75
        Height = 21
        Action = actEditChart
        TabOrder = 4
      end
    end
  end
  inherited alBase: TActionList
    object actChooseAccount: TAction
      Caption = 'Выбрать ...'
      OnExecute = actChooseAccountExecute
    end
    object actDeleteAccount: TAction
      Caption = 'Удалить'
      OnExecute = actDeleteAccountExecute
      OnUpdate = actDeleteAccountUpdate
    end
    object actActiveAccount: TAction
      Caption = 'Активный'
      OnExecute = actActiveAccountExecute
    end
    object actEditChart: TAction
      Caption = 'Изменить...'
      OnExecute = actEditChartExecute
      OnUpdate = actEditChartUpdate
    end
  end
  inherited dsAccount: TDataSource
    Left = 181
  end
  object dsCompanyChart: TDataSource
    DataSet = gdcAcctChart1
    Left = 263
    Top = 169
  end
  object gdcAcctChart1: TgdcAcctChart
    AfterOpen = gdcAcctChart1AfterOpen
    MasterSource = dsgdcBase
    MasterField = 'ID'
    DetailField = 'MASTER_RECORD_ID'
    SetTable = 'AC_COMPANYACCOUNT'
    Left = 232
    Top = 168
  end
end
