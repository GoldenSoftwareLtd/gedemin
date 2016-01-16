object gdv_frAcctTreeAnalyticLine: Tgdv_frAcctTreeAnalyticLine
  Left = 0
  Top = 0
  Width = 435
  Height = 22
  Align = alTop
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  object lAnaliticName: TLabel
    Left = 8
    Top = 5
    Width = 63
    Height = 13
    Caption = 'lAnaliticName'
  end
  object eLevel: TEdit
    Left = 76
    Top = 1
    Width = 142
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    OnChange = eLevelChange
  end
end
