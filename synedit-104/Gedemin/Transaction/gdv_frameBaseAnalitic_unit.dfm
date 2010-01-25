object frameBaseAnalitic: TframeBaseAnalitic
  Left = 0
  Top = 0
  Width = 339
  Height = 121
  AutoSize = True
  TabOrder = 0
  object gbGroup: TGroupBox
    Left = 0
    Top = 0
    Width = 339
    Height = 121
    Caption = ' Группировка по аналитике '
    TabOrder = 0
    object Label11: TLabel
      Left = 10
      Top = 14
      Width = 52
      Height = 13
      Caption = 'Доступно:'
    end
    object Label12: TLabel
      Left = 193
      Top = 14
      Width = 48
      Height = 13
      Caption = 'Выбрано:'
    end
    object lbAvail: TListBox
      Left = 10
      Top = 30
      Width = 137
      Height = 69
      ItemHeight = 13
      MultiSelect = True
      Sorted = True
      TabOrder = 0
      OnDblClick = lbAvailDblClick
    end
    object lbSelected: TListBox
      Left = 193
      Top = 30
      Width = 137
      Height = 70
      ItemHeight = 13
      TabOrder = 5
      OnDblClick = lbSelectedDblClick
    end
    object Button1: TButton
      Left = 193
      Top = 100
      Width = 65
      Height = 17
      Action = actUp
      TabOrder = 6
    end
    object Button2: TButton
      Left = 265
      Top = 100
      Width = 65
      Height = 17
      Action = actDown
      TabOrder = 7
    end
    object Button3: TButton
      Left = 149
      Top = 30
      Width = 41
      Height = 17
      Action = actInclude
      TabOrder = 1
    end
    object Button4: TButton
      Left = 149
      Top = 47
      Width = 41
      Height = 17
      Action = actIncludeAll
      TabOrder = 2
    end
    object Button5: TButton
      Left = 149
      Top = 64
      Width = 41
      Height = 17
      Action = actExclude
      TabOrder = 3
    end
    object Button6: TButton
      Left = 149
      Top = 81
      Width = 41
      Height = 17
      Action = actExcludeAll
      TabOrder = 4
    end
  end
  object ActionList1: TActionList
    Left = 56
    Top = 40
    object actUp: TAction
      Caption = 'Вверх'
      OnExecute = actUpExecute
      OnUpdate = actUpUpdate
    end
    object actDown: TAction
      Caption = 'Вниз'
      OnExecute = actDownExecute
      OnUpdate = actDownUpdate
    end
    object actInclude: TAction
      Caption = '>'
      OnExecute = actIncludeExecute
      OnUpdate = actIncludeUpdate
    end
    object actIncludeAll: TAction
      Caption = '>>'
      OnExecute = actIncludeAllExecute
      OnUpdate = actIncludeAllUpdate
    end
    object actExclude: TAction
      Caption = '<'
      OnExecute = actExcludeExecute
      OnUpdate = actExcludeUpdate
    end
    object actExcludeAll: TAction
      Caption = '<<'
      OnExecute = actExcludeAllExecute
      OnUpdate = actExcludeAllUpdate
    end
  end
end
