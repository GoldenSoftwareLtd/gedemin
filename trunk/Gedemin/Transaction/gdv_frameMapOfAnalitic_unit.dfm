object frameMapOfAnaliticLine: TframeMapOfAnaliticLine
  Left = 0
  Top = 0
  Width = 435
  Height = 44
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
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
  object eAnalitic: TEdit
    Left = 168
    Top = 18
    Width = 128
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    Visible = False
    OnChange = eAnaliticChange
  end
  object cbInputParam: TCheckBox
    Left = 154
    Top = 6
    Width = 204
    Height = 17
    Caption = 'Запрашивать значение'
    TabOrder = 1
  end
end
