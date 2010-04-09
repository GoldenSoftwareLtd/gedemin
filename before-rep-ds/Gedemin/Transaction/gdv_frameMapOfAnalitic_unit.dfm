object frameMapOfAnaliticLine: TframeMapOfAnaliticLine
  Left = 0
  Top = 0
  Width = 450
  Height = 44
  Align = alTop
  Constraints.MinWidth = 220
  TabOrder = 0
  object lAnaliticName: TLabel
    Left = 8
    Top = 6
    Width = 64
    Height = 13
    Caption = 'lAnaliticName'
  end
  object Bevel1: TBevel
    Left = 0
    Top = 41
    Width = 450
    Height = 3
    Align = alBottom
    Shape = bsBottomLine
  end
  object cbAnalitic: TgsIBLookupComboBox
    Left = 192
    Top = 2
    Width = 167
    Height = 21
    HelpContext = 1
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 0
    Visible = False
    OnChange = eAnaliticChange
  end
  object eAnalitic: TEdit
    Left = 192
    Top = 2
    Width = 128
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
    Visible = False
    OnChange = eAnaliticChange
  end
  object cbInputParam: TCheckBox
    Left = 18
    Top = 24
    Width = 204
    Height = 17
    Caption = 'Запрашивать значение'
    TabOrder = 2
  end
end
