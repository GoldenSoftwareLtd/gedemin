inherited frAcctAnalyticsGroup: TfrAcctAnalyticsGroup
  Width = 224
  Height = 136
  object ppMain: TgdvParamPanel [0]
    Left = 0
    Top = 0
    Width = 224
    Height = 136
    Align = alTop
    Caption = 'Группировать по аналитике'
    Color = 15329769
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 16724787
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    TabStop = True
    OnResize = ppMainResize
    Unwraped = True
    HorisontalOffset = 5
    VerticalOffset = 1
    FillColor = 15987699
    StripeOdd = 16760767
    StripeEven = 16767449
    Origin = oLeft
    object pClient: TPanel
      Left = 6
      Top = 18
      Width = 212
      Height = 116
      Align = alClient
      BevelOuter = bvNone
      Color = 15987699
      TabOrder = 0
      object bAvail: TBevel
        Left = 4
        Top = 16
        Width = 88
        Height = 81
        Shape = bsFrame
      end
      object bSelected: TBevel
        Left = 122
        Top = 16
        Width = 88
        Height = 81
        Shape = bsFrame
      end
      object lAvail: TLabel
        Left = 4
        Top = 2
        Width = 52
        Height = 13
        Caption = 'Доступно:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        Transparent = True
        Layout = tlBottom
      end
      object lSelected: TLabel
        Left = 122
        Top = 2
        Width = 48
        Height = 13
        Caption = 'Выбрано:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        Transparent = True
        Layout = tlBottom
      end
      object lbAvail: TListBox
        Left = 6
        Top = 18
        Width = 84
        Height = 77
        Hint = 'Доступная аналитика'
        BorderStyle = bsNone
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ItemHeight = 13
        MultiSelect = True
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        Sorted = True
        TabOrder = 0
        OnDblClick = lbAvailDblClick
        OnKeyDown = lbAvailKeyDown
      end
      object bUp: TButton
        Left = 123
        Top = 98
        Width = 40
        Height = 17
        Action = actUp
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 5
      end
      object bDown: TButton
        Left = 168
        Top = 98
        Width = 40
        Height = 17
        Action = actDown
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 6
      end
      object bIncludeAll: TButton
        Left = 94
        Top = 38
        Width = 25
        Height = 17
        Action = actIncludeAll
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
      end
      object bInclude: TButton
        Left = 94
        Top = 20
        Width = 25
        Height = 17
        Action = actInclude
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
      end
      object bExcludeAll: TButton
        Left = 94
        Top = 74
        Width = 25
        Height = 17
        Action = actExcludeAll
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 4
      end
      object bExclude: TButton
        Left = 94
        Top = 56
        Width = 25
        Height = 17
        Action = actExclude
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 3
      end
      object lbSelected: TCheckListBox
        Left = 123
        Top = 17
        Width = 84
        Height = 78
        OnClickCheck = lbSelectedClickCheck
        BorderStyle = bsNone
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ItemHeight = 13
        ParentFont = False
        TabOrder = 7
        OnDblClick = lbSelectedDblClick
        OnKeyDown = lbSelectedKeyDown
      end
    end
  end
end
