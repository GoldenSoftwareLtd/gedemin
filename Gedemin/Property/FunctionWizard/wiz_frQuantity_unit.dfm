object frQuantity: TfrQuantity
  Left = 0
  Top = 0
  Width = 320
  Height = 240
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  object TBDock1: TTBDock
    Left = 0
    Top = 0
    Width = 320
    Height = 28
    BoundLines = [blTop, blBottom, blLeft, blRight]
    object TBToolbar1: TTBToolbar
      Left = 0
      Top = 0
      Caption = 'TBToolbar1'
      CloseButton = False
      DockMode = dmCannotFloatOrChangeDocks
      FullSize = True
      Images = dmImages.il16x16
      TabOrder = 0
      object TBItem2: TTBItem
        Action = actAddQuantity
      end
      object TBItem3: TTBItem
        Action = actEditQuantity
      end
      object TBSeparatorItem1: TTBSeparatorItem
      end
      object TBItem1: TTBItem
        Action = actDeleteQuantity
      end
    end
  end
  object lvQuantity: TListView
    Left = 0
    Top = 28
    Width = 320
    Height = 212
    Align = alClient
    Columns = <
      item
        Caption = 'Единица измерения'
        Width = 195
      end
      item
        Caption = 'Количество'
        Width = 200
      end
      item
        Caption = 'Script'
      end>
    TabOrder = 1
    ViewStyle = vsReport
    OnDblClick = lvQuantityDblClick
  end
  object ActionList: TActionList
    Images = dmImages.il16x16
    Left = 40
    Top = 152
    object actAddQuantity: TAction
      Caption = 'actAddQuantity'
      ImageIndex = 179
      OnExecute = actAddQuantityExecute
    end
    object actDeleteQuantity: TAction
      Caption = 'actDelteQuantity'
      ImageIndex = 178
      OnExecute = actDeleteQuantityExecute
      OnUpdate = actDeleteQuantityUpdate
    end
    object actEditQuantity: TAction
      Caption = 'actEditQuantity'
      ImageIndex = 177
      OnExecute = actEditQuantityExecute
      OnUpdate = actEditQuantityUpdate
    end
  end
end
