object gdv_frAcctTreeAnalyticLine: Tgdv_frAcctTreeAnalyticLine
  Left = 0
  Top = 0
  Width = 443
  Height = 22
  Align = alTop
  TabOrder = 0
  object lAnaliticName: TLabel
    Left = 8
    Top = 5
    Width = 64
    Height = 13
    Caption = 'lAnaliticName'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object eLevel: TEdit
    Left = 76
    Top = 1
    Width = 125
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnChange = eLevelChange
  end
end
