object frAcctCompany: TfrAcctCompany
  Left = 0
  Top = 0
  Width = 252
  Height = 91
  Color = 15329769
  ParentColor = False
  TabOrder = 0
  object ppMain: TgdvParamPanel
    Left = 0
    Top = 0
    Width = 252
    Height = 60
    Align = alTop
    Caption = 'Компании холдинга'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 6513193
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentColor = True
    ParentFont = False
    TabOrder = 0
    TabStop = True
    OnResize = ppMainResize
    Unwraped = True
    HorisontalOffset = 5
    VerticalOffset = 1
    FillColor = 15987699
    StripeOdd = 14079651
    StripeEven = 15791076
    Origin = oLeft
    object lCompany: TLabel
      Left = 14
      Top = 22
      Width = 54
      Height = 13
      Caption = 'Компания:'
      FocusControl = iblCompany
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      Transparent = True
    end
    object cbAllCompanies: TCheckBox
      Left = 14
      Top = 41
      Width = 147
      Height = 17
      Caption = 'Все компании холдинга'
      Checked = True
      Color = 15987699
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      State = cbChecked
      TabOrder = 1
    end
    object iblCompany: TgsIBLookupComboBox
      Left = 71
      Top = 19
      Width = 170
      Height = 21
      HelpContext = 1
      Transaction = Transaction
      ListTable = 'gd_contact JOIN gd_ourcompany ON companykey=gd_contact.id'
      ListField = 'NAME'
      KeyField = 'ID'
      gdClassName = 'TgdcOurCompany'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ItemHeight = 13
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnChange = iblCompanyChange
    end
  end
  object Transaction: TIBTransaction
    Active = False
    AutoStopAction = saNone
    Left = 64
  end
end
