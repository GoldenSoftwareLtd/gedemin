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
    object Bevel4: TBevel
      Left = 161
      Top = 90
      Width = 12
      Height = 8
      Shape = bsBottomLine
    end
    object Bevel3: TBevel
      Left = 8
      Top = 90
      Width = 12
      Height = 8
      Shape = bsBottomLine
    end
    object Label13: TLabel
      Left = 24
      Top = 40
      Width = 60
      Height = 13
      Caption = 'Дес. знаки:'
    end
    object Label14: TLabel
      Left = 24
      Top = 61
      Width = 49
      Height = 13
      Caption = 'Масштаб:'
    end
    object Label15: TLabel
      Left = 180
      Top = 42
      Width = 60
      Height = 13
      Caption = 'Дес. знаки:'
    end
    object Label16: TLabel
      Left = 180
      Top = 63
      Width = 49
      Height = 13
      Caption = 'Масштаб:'
    end
    object Label10: TLabel
      Left = 180
      Top = 83
      Width = 41
      Height = 13
      Caption = 'Валюта:'
    end
    object Bevel1: TBevel
      Left = 8
      Top = 35
      Width = 3
      Height = 61
      Shape = bsLeftLine
    end
    object Bevel2: TBevel
      Left = 161
      Top = 35
      Width = 3
      Height = 61
      Shape = bsLeftLine
    end
    object Label1: TLabel
      Left = 380
      Top = 42
      Width = 60
      Height = 13
      Caption = 'Дес. знаки:'
    end
    object Bevel5: TBevel
      Left = 361
      Top = 35
      Width = 3
      Height = 61
      Shape = bsLeftLine
    end
    object Bevel6: TBevel
      Left = 361
      Top = 90
      Width = 12
      Height = 8
      Shape = bsBottomLine
    end
    object Label2: TLabel
      Left = 380
      Top = 63
      Width = 49
      Height = 13
      Caption = 'Масштаб:'
    end
    object gsiblCurrKey: TgsIBLookupComboBox
      Left = 249
      Top = 81
      Width = 105
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
      Left = 8
      Top = 16
      Width = 145
      Height = 17
      Caption = 'Суммы в рублях'
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
    object cbInCurr: TCheckBox
      Left = 160
      Top = 16
      Width = 169
      Height = 17
      Caption = 'Суммы в валюте'
      TabOrder = 3
    end
    object cbNcuDecDigits: TComboBox
      Left = 88
      Top = 40
      Width = 65
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
      Left = 88
      Top = 61
      Width = 65
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
      Left = 248
      Top = 61
      Width = 65
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
      Left = 248
      Top = 40
      Width = 65
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
      Left = 360
      Top = 16
      Width = 121
      Height = 17
      Caption = 'Суммы в эквиваленте'
      TabOrder = 7
    end
    object cbEQScale: TComboBox
      Left = 448
      Top = 61
      Width = 65
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
      Left = 448
      Top = 40
      Width = 65
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
  end
end
