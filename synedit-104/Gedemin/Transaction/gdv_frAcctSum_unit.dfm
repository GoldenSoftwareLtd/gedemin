object frAcctSum: TfrAcctSum
  Left = 0
  Top = 0
  Width = 319
  Height = 233
  Color = 15329769
  ParentColor = False
  TabOrder = 0
  object ppMain: TgdvParamPanel
    Left = 0
    Top = 0
    Width = 319
    Height = 225
    Align = alTop
    BevelOuter = bvNone
    Caption = 'Вывод сумм'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentColor = True
    ParentFont = False
    TabOrder = 0
    TabStop = True
    OnResize = ppMainResize
    Unwraped = True
    HorisontalOffset = 8
    VerticalOffset = 1
    FillColor = clBtnFace
    StripeOdd = 47495848
    StripeEven = 49606634
    Steps = 12
    Origin = oLeft
    object Label5: TLabel
      Left = 22
      Top = 38
      Width = 60
      Height = 13
      Caption = 'Дес. знаки:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label6: TLabel
      Left = 22
      Top = 58
      Width = 49
      Height = 13
      Caption = 'Масштаб:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label11: TLabel
      Left = 22
      Top = 98
      Width = 60
      Height = 13
      Caption = 'Дес. знаки:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label12: TLabel
      Left = 22
      Top = 138
      Width = 41
      Height = 13
      Caption = 'Валюта:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label18: TLabel
      Left = 22
      Top = 118
      Width = 49
      Height = 13
      Caption = 'Масштаб:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label1: TLabel
      Left = 22
      Top = 178
      Width = 60
      Height = 13
      Caption = 'Дес. знаки:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label2: TLabel
      Left = 22
      Top = 198
      Width = 49
      Height = 13
      Caption = 'Масштаб:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object cbInNcu: TCheckBox
      Left = 14
      Top = 18
      Width = 183
      Height = 17
      Caption = 'Суммы в национальной валюте'
      Checked = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      State = cbChecked
      TabOrder = 0
    end
    object cbNcuDecDigits: TComboBox
      Left = 86
      Top = 35
      Width = 51
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
      Left = 86
      Top = 55
      Width = 51
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
      OnExit = cbNcuScaleExit
      OnKeyPress = cbNcuScaleKeyPress
      Items.Strings = (
        '1'
        '1000'
        '1000000')
    end
    object cbInCurr: TCheckBox
      Left = 14
      Top = 76
      Width = 123
      Height = 17
      Caption = 'Суммы в валюте'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
    end
    object cbCurrdecDigits: TComboBox
      Left = 86
      Top = 95
      Width = 51
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
      Items.Strings = (
        '0'
        '1'
        '2'
        '3'
        '4'
        '5'
        '6')
    end
    object cbCurrScale: TComboBox
      Left = 86
      Top = 115
      Width = 51
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
      OnExit = cbNcuScaleExit
      OnKeyPress = cbNcuScaleKeyPress
      Items.Strings = (
        '1'
        '1000'
        '1000000')
    end
    object gsiblCurrKey: TgsIBLookupComboBox
      Left = 86
      Top = 135
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
    object cbInEQ: TCheckBox
      Left = 14
      Top = 156
      Width = 195
      Height = 17
      Caption = 'Суммы в эквиваленте'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 7
    end
    object cbEQdecDigits: TComboBox
      Left = 86
      Top = 175
      Width = 51
      Height = 19
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemHeight = 11
      ParentFont = False
      TabOrder = 8
      Text = '2'
      Items.Strings = (
        '0'
        '1'
        '2'
        '3'
        '4'
        '5'
        '6')
    end
    object cbEQScale: TComboBox
      Left = 86
      Top = 195
      Width = 51
      Height = 19
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemHeight = 11
      ParentFont = False
      TabOrder = 9
      Text = '1'
      OnExit = cbNcuScaleExit
      OnKeyPress = cbNcuScaleKeyPress
      Items.Strings = (
        '1'
        '1000'
        '1000000')
    end
  end
end
