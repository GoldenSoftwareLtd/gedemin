inherited gdc_dlgAcctBaseAccount: Tgdc_dlgAcctBaseAccount
  Left = 396
  Top = 118
  BorderIcons = [biSystemMenu]
  BorderWidth = 5
  Caption = 'Счет'
  ClientHeight = 465
  ClientWidth = 483
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 1
    Top = 441
    TabOrder = 1
  end
  inherited btnNew: TButton
    Left = 73
    Top = 441
    TabOrder = 2
  end
  inherited btnHelp: TButton
    Left = 147
    Top = 441
  end
  inherited btnOK: TButton
    Left = 339
    Top = 441
    TabOrder = 3
  end
  inherited btnCancel: TButton
    Left = 413
    Top = 441
    TabOrder = 4
  end
  inherited pgcMain: TPageControl
    Left = 1
    Top = 1
    Width = 480
    Height = 432
    inherited tbsMain: TTabSheet
      inherited dbtxtID: TDBText
        Left = 121
      end
      object lblAlias: TLabel
        Left = 8
        Top = 56
        Width = 67
        Height = 13
        Caption = 'Номер счета:'
      end
      object lblName: TLabel
        Left = 8
        Top = 81
        Width = 109
        Height = 13
        Caption = 'Наименование счета:'
      end
      object Label2: TLabel
        Left = 8
        Top = 31
        Width = 111
        Height = 13
        Caption = 'Раздел плана счетов:'
      end
      object pAccountInfo: TPanel
        Left = 7
        Top = 102
        Width = 466
        Height = 66
        BevelOuter = bvNone
        TabOrder = 3
        object GroupBox1: TGroupBox
          Left = 0
          Top = 0
          Width = 225
          Height = 66
          Caption = ' Параметры счета '
          TabOrder = 0
          object dbcbCurrAccount: TDBCheckBox
            Left = 9
            Top = 16
            Width = 97
            Height = 17
            Caption = 'Валютный счет'
            DataField = 'MULTYCURR'
            DataSource = dsgdcBase
            TabOrder = 0
            ValueChecked = '1'
            ValueUnchecked = '0'
          end
          object dbcbOffBalance: TDBCheckBox
            Left = 9
            Top = 39
            Width = 144
            Height = 17
            Caption = 'Забалансовый счет'
            DataField = 'OFFBALANCE'
            DataSource = dsgdcBase
            TabOrder = 1
            ValueChecked = '1'
            ValueUnchecked = '0'
          end
        end
        object dbrgTypeAccount: TDBRadioGroup
          Left = 232
          Top = 0
          Width = 225
          Height = 66
          Caption = ' Тип счета '
          DataField = 'ACTIVITY'
          DataSource = dsgdcBase
          Items.Strings = (
            'Активный'
            'Пассивный'
            'Активно-пассивный')
          TabOrder = 1
          Values.Strings = (
            'A'
            'P'
            'B')
        end
      end
      object dbedAlias: TDBEdit
        Left = 120
        Top = 52
        Width = 122
        Height = 21
        DataField = 'ALIAS'
        DataSource = dsgdcBase
        TabOrder = 1
      end
      object dbedName: TDBEdit
        Left = 120
        Top = 77
        Width = 344
        Height = 21
        DataField = 'NAME'
        DataSource = dsgdcBase
        TabOrder = 2
      end
      object dbcbDisabled: TDBCheckBox
        Left = 8
        Top = 382
        Width = 138
        Height = 17
        Caption = 'Запись отключена'
        DataField = 'DISABLED'
        DataSource = dsgdcBase
        TabOrder = 10
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object bbAnalyze: TBitBtn
        Left = 7
        Top = 175
        Width = 165
        Height = 25
        Action = actAnalyze
        Caption = 'Аналитика'
        TabOrder = 4
      end
      object sbAnalyze: TScrollBox
        Left = 7
        Top = 199
        Width = 165
        Height = 180
        TabOrder = 5
      end
      object sbValues: TScrollBox
        Left = 344
        Top = 199
        Width = 120
        Height = 180
        Enabled = False
        TabOrder = 9
      end
      object bbValues: TBitBtn
        Left = 344
        Top = 175
        Width = 120
        Height = 25
        Action = actValues
        Caption = 'Ед.изм.'
        TabOrder = 8
      end
      object gsiblcGroupAccount: TgsIBLookupComboBox
        Left = 120
        Top = 27
        Width = 346
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'PARENT'
        ListTable = 'AC_ACCOUNT'
        ListField = 'ALIAS'
        KeyField = 'ID'
        Condition = 'AC_ACCOUNT.accounttype = '#39'F'#39
        gdClassName = 'TgdcAcctFolder'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
      end
      object bbAnalyzeExt: TBitBtn
        Left = 176
        Top = 175
        Width = 165
        Height = 25
        Action = actAnalyzeExt
        Caption = 'Аналитика для разв. сальдо'
        TabOrder = 6
      end
      object sbAnalyzeExt: TScrollBox
        Left = 176
        Top = 199
        Width = 165
        Height = 180
        Enabled = False
        TabOrder = 7
      end
    end
    object TabSheet1: TTabSheet [1]
      Caption = 'Описание'
      ImageIndex = 2
      object DBMemo1: TDBMemo
        Left = 0
        Top = 0
        Width = 472
        Height = 404
        Align = alClient
        DataField = 'description'
        DataSource = dsgdcBase
        TabOrder = 0
      end
    end
    inherited tbsAttr: TTabSheet
      TabVisible = False
      inherited atcMain: TatContainer
        Width = 481
        Height = 404
      end
    end
  end
  inherited alBase: TActionList
    Left = 375
    Top = 10
    object actSelectedAnalytics: TAction
      Caption = 'Только отмеченные'
    end
    object actSelectedValues: TAction
      Caption = 'Только отмеченные'
    end
    object actAnalyze: TAction
      Caption = 'Аналитика'
      OnExecute = actAnalyzeExecute
    end
    object actValues: TAction
      Caption = 'Ед.изм.'
      OnExecute = actValuesExecute
    end
    object actAnalyzeExt: TAction
      Caption = 'Аналитика для разв. сальдо'
      OnExecute = actAnalyzeExtExecute
    end
    object actSelectedAnalyticsExt: TAction
      Caption = 'Только отмеченные'
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 345
    Top = 10
  end
  inherited pm_dlgG: TPopupMenu
    Left = 360
    Top = 136
  end
  inherited ibtrCommon: TIBTransaction
    Left = 392
    Top = 136
  end
end
