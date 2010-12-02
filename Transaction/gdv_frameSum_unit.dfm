object frameSum: TframeSum
  Left = 0
  Top = 0
  Width = 521
  Height = 107
  AutoSize = True
  TabOrder = 0
  object gbSum: TGroupBox
    Left = 0
    Top = 0
    Width = 521
    Height = 107
    Caption = ' Вывод сумм '
    TabOrder = 0
    object Label13: TLabel
      Left = 7
      Top = 41
      Width = 48
      Height = 11
      Caption = 'Дес. знаки:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label14: TLabel
      Left = 7
      Top = 62
      Width = 42
      Height = 11
      Caption = 'Масштаб:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label15: TLabel
      Left = 124
      Top = 39
      Width = 48
      Height = 11
      Caption = 'Дес. знаки:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label16: TLabel
      Left = 124
      Top = 60
      Width = 42
      Height = 11
      Caption = 'Масштаб:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label10: TLabel
      Left = 124
      Top = 80
      Width = 37
      Height = 11
      Caption = 'Валюта:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Bevel2: TBevel
      Left = 116
      Top = 13
      Width = 3
      Height = 86
      Shape = bsLeftLine
    end
    object Label1: TLabel
      Left = 272
      Top = 39
      Width = 48
      Height = 11
      Caption = 'Дес. знаки:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Bevel5: TBevel
      Left = 264
      Top = 13
      Width = 3
      Height = 86
      Shape = bsLeftLine
    end
    object Label2: TLabel
      Left = 272
      Top = 60
      Width = 42
      Height = 11
      Caption = 'Масштаб:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object bvl1: TBevel
      Left = 391
      Top = 13
      Width = 3
      Height = 86
      Shape = bsLeftLine
    end
    object Label3: TLabel
      Left = 400
      Top = 39
      Width = 48
      Height = 11
      Caption = 'Дес. знаки:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label4: TLabel
      Left = 400
      Top = 60
      Width = 42
      Height = 11
      Caption = 'Масштаб:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblInQuantity: TLabel
      Left = 399
      Top = 16
      Width = 94
      Height = 13
      Caption = 'Количеств. суммы'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object gsiblCurrKey: TgsIBLookupComboBox
      Left = 179
      Top = 76
      Width = 80
      Height = 19
      HelpContext = 1
      Database = dmDatabase.ibdbGAdmin
      Transaction = dmDatabase.ibtrGenUniqueID
      ListTable = 'GD_CURR'
      ListField = 'SHORTNAME'
      KeyField = 'ID'
      gdClassName = 'TgdcCurr'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemHeight = 11
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 6
    end
    object cbInNcu: TCheckBox
      Left = 7
      Top = 16
      Width = 105
      Height = 17
      Caption = 'Суммы в рублях'
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
    object cbInCurr: TCheckBox
      Left = 124
      Top = 16
      Width = 108
      Height = 17
      Caption = 'Суммы в валюте'
      TabOrder = 3
    end
    object cbNcuDecDigits: TComboBox
      Left = 61
      Top = 37
      Width = 50
      Height = 19
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemHeight = 11
      ParentFont = False
      TabOrder = 1
      Text = '2'
      OnKeyPress = cbNcuScaleKeyPress
      Items.Strings = (
        '0'
        '1'
        '2'
        '3'
        '4'
        '5'
        '6')
    end
    object cbNcuScale: TComboBox
      Left = 61
      Top = 58
      Width = 50
      Height = 19
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemHeight = 11
      ParentFont = False
      TabOrder = 2
      Text = '1'
      OnKeyPress = cbNcuScaleKeyPress
      Items.Strings = (
        '1'
        '1000'
        '1000000')
    end
    object cbCurrScale: TComboBox
      Left = 179
      Top = 56
      Width = 50
      Height = 19
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemHeight = 11
      ParentFont = False
      TabOrder = 5
      Text = '1'
      OnKeyPress = cbNcuScaleKeyPress
      Items.Strings = (
        '1'
        '1000'
        '1000000')
    end
    object cbCurrDecDigits: TComboBox
      Left = 179
      Top = 35
      Width = 50
      Height = 19
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemHeight = 11
      ParentFont = False
      TabOrder = 4
      Text = '2'
      OnKeyPress = cbNcuScaleKeyPress
      Items.Strings = (
        '0'
        '1'
        '2'
        '3'
        '4'
        '5'
        '6')
    end
    object cbInEQ: TCheckBox
      Left = 272
      Top = 16
      Width = 94
      Height = 17
      Caption = 'Суммы в экв.'
      TabOrder = 7
    end
    object cbEQScale: TComboBox
      Left = 328
      Top = 56
      Width = 50
      Height = 19
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemHeight = 11
      ParentFont = False
      TabOrder = 8
      Text = '1'
      OnKeyPress = cbNcuScaleKeyPress
      Items.Strings = (
        '1'
        '1000'
        '1000000')
    end
    object cbEQDecDigits: TComboBox
      Left = 328
      Top = 35
      Width = 50
      Height = 19
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemHeight = 11
      ParentFont = False
      TabOrder = 9
      Text = '2'
      OnKeyPress = cbNcuScaleKeyPress
      Items.Strings = (
        '0'
        '1'
        '2'
        '3'
        '4'
        '5'
        '6')
    end
    object cbQuantityDecDigits: TComboBox
      Left = 458
      Top = 35
      Width = 50
      Height = 19
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemHeight = 11
      ParentFont = False
      TabOrder = 10
      Text = '2'
      OnKeyPress = cbNcuScaleKeyPress
      Items.Strings = (
        '0'
        '1'
        '2'
        '3'
        '4'
        '5'
        '6')
    end
    object cbQuantityScale: TComboBox
      Left = 458
      Top = 56
      Width = 50
      Height = 19
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemHeight = 11
      ParentFont = False
      TabOrder = 11
      Text = '1'
      OnKeyPress = cbNcuScaleKeyPress
      Items.Strings = (
        '1'
        '1000'
        '1000000')
    end
  end
end
