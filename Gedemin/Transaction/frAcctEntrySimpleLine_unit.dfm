object frAcctEntrySimpleLine: TfrAcctEntrySimpleLine
  Left = 0
  Top = 0
  Width = 435
  Height = 234
  Align = alTop
  AutoSize = True
  Constraints.MinWidth = 291
  Color = 15329769
  Ctl3D = False
  ParentColor = False
  ParentCtl3D = False
  TabOrder = 0
  OnResize = FrameResize
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 435
    Height = 234
    Align = alTop
    AutoSize = True
    BevelOuter = bvNone
    BorderWidth = 1
    Color = 15329769
    TabOrder = 0
    OnResize = Panel1Resize
    object ppMain: TgdvParamPanel
      Left = 1
      Top = 1
      Width = 433
      Height = 232
      Align = alTop
      AutoSize = True
      Color = 15329769
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnResize = ppMainResize
      Unwraped = True
      HorisontalOffset = 3
      VerticalOffset = 0
      FillColor = 16053492
      StripeOdd = 47495848
      StripeEven = 49606634
      Origin = oLeft
      object Panel5: TPanel
        Left = 4
        Top = 17
        Width = 425
        Height = 140
        Align = alTop
        BevelOuter = bvNone
        Color = 16053492
        TabOrder = 0
        object lAccount: TLabel
          Left = 8
          Top = 7
          Width = 29
          Height = 13
          Caption = 'Счет:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lSum: TLabel
          Left = 8
          Top = 30
          Width = 35
          Height = 13
          Caption = 'Сумма:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lCurr: TLabel
          Left = 8
          Top = 77
          Width = 43
          Height = 13
          Caption = 'Валюта:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lRate: TLabel
          Left = 8
          Top = 99
          Width = 28
          Height = 13
          Caption = 'Курс:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lSumCurr: TLabel
          Left = 8
          Top = 122
          Width = 86
          Height = 13
          Caption = 'Сумма в валюте:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lEQ: TLabel
          Left = 8
          Top = 53
          Width = 112
          Height = 13
          Caption = 'Сумма в эквиваленте:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object cbAccount: TgsIBLookupComboBox
          Left = 56
          Top = 3
          Width = 380
          Height = 21
          HelpContext = 1
          Database = dmDatabase.ibdbGAdmin
          Transaction = Transaction
          DataSource = DataSource
          DataField = 'ACCOUNTKEY'
          Fields = 'NAME'
          ListTable = 'AC_ACCOUNT'
          ListField = 'ALIAS'
          KeyField = 'ID'
          SortOrder = soAsc
          Condition = 
            '(ACCOUNTTYPE = '#39'A'#39' or ACCOUNTTYPE = '#39'S'#39') AND ID IN (SELECT a1.id' +
            ' FROM ac_companyaccount ca LEFT JOIN ac_account a ON a.id = ca.a' +
            'ccountkey LEFT JOIN ac_account a1 on a1.lb >=a.lb and a1.rb <= a' +
            '.rb WHERE ca.companykey = <COMPANYKEY/>) '
          Distinct = True
          Anchors = [akLeft, akTop, akRight]
          Constraints.MinWidth = 193
          Ctl3D = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemHeight = 13
          ParentCtl3D = False
          ParentFont = False
          TabOrder = 0
          OnChange = cbAccountChange
          OnExit = cbAccountExit
        end
        object cSum: TxDBCalculatorEdit
          Left = 56
          Top = 26
          Width = 380
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          Constraints.MinWidth = 193
          Ctl3D = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentCtl3D = False
          ParentFont = False
          TabOrder = 1
          OnChange = cSumChange
          DecDigits = 4
          DataField = 'DEBITNCU'
          DataSource = DataSource
        end
        object cbCurrency: TgsIBLookupComboBox
          Left = 93
          Top = 72
          Width = 156
          Height = 21
          HelpContext = 1
          Database = dmDatabase.ibdbGAdmin
          Transaction = Transaction
          DataSource = DataSource
          DataField = 'CURRKEY'
          Fields = 'Name'
          ListTable = 'GD_CURR'
          ListField = 'SHORTNAME'
          KeyField = 'ID'
          SortOrder = soAsc
          Condition = 'isncu = 0 or isncu is null'
          gdClassName = 'TgdcCurr'
          Constraints.MinWidth = 156
          Ctl3D = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemHeight = 13
          ParentCtl3D = False
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 3
          OnChange = cbCurrencyChange
        end
        object cRate: TxCalculatorEdit
          Left = 93
          Top = 95
          Width = 343
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          Constraints.MinWidth = 156
          Ctl3D = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentCtl3D = False
          ParentFont = False
          TabOrder = 5
          OnChange = cRateChange
          DecDigits = 4
        end
        object cCurrSum: TxDBCalculatorEdit
          Left = 93
          Top = 118
          Width = 343
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          Constraints.MinWidth = 156
          Ctl3D = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentCtl3D = False
          ParentFont = False
          TabOrder = 6
          OnChange = cCurrSumChange
          DecDigits = 4
          DataField = 'DEBITCURR'
          DataSource = DataSource
        end
        object cEQSum: TxDBCalculatorEdit
          Left = 122
          Top = 49
          Width = 314
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          Constraints.MinWidth = 143
          Ctl3D = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentCtl3D = False
          ParentFont = False
          TabOrder = 2
          OnChange = cSumChange
          DecDigits = 4
          DataField = 'DEBITEQ'
          DataSource = DataSource
        end
        object cbRounded: TCheckBox
          Left = 252
          Top = 74
          Width = 84
          Height = 17
          Caption = 'Округлять'
          Checked = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          State = cbChecked
          TabOrder = 4
        end
      end
      inline frAcctAnalytics: TfrAcctAnalytics
        Left = 4
        Top = 157
        Width = 425
        TabOrder = 1
        inherited ppAnalytics: TgdvParamPanel
          Width = 425
          Color = 16053492
          Font.Name = 'Tahoma'
          ParentColor = False
          TabStop = False
          HorisontalOffset = 8
          FillColor = clWhite
        end
      end
      inline frQuantity: TfrEntrySimpleLineQuantity
        Left = 4
        Top = 198
        Width = 425
        Height = 33
        TabOrder = 2
        inherited ppMain: TgdvParamPanel
          Width = 425
          Height = 33
          Color = 16053492
          Font.Color = 14705703
          Font.Name = 'Tahoma'
          TabStop = False
          HorisontalOffset = 8
          FillColor = clWhite
          StripeOdd = 15646882
          StripeEven = 15521463
        end
      end
    end
  end
  object Transaction: TIBTransaction
    Active = False
    AutoStopAction = saNone
    Left = 62
    Top = 70
  end
  object DataSource: TDataSource
    Left = 102
    Top = 94
  end
end
