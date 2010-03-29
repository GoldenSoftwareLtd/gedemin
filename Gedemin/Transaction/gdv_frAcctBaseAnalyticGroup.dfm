object frAcctBaseAnalyticsGroup: TfrAcctBaseAnalyticsGroup
  Left = 0
  Top = 0
  Width = 320
  Height = 240
  TabOrder = 0
  object ActionList1: TActionList
    Left = 54
    Top = 42
    object actUp: TAction
      Caption = '¬верх'
      OnExecute = actUpExecute
      OnUpdate = actUpUpdate
    end
    object actInclude: TAction
      Caption = '>'
      OnExecute = actIncludeExecute
      OnUpdate = actIncludeUpdate
    end
    object actDown: TAction
      Caption = '¬низ'
      OnExecute = actDownExecute
      OnUpdate = actDownUpdate
    end
    object actExclude: TAction
      Caption = '<'
      OnExecute = actExcludeExecute
      OnUpdate = actExcludeUpdate
    end
    object actIncludeAll: TAction
      Caption = '>>'
      OnExecute = actIncludeAllExecute
      OnUpdate = actIncludeAllUpdate
    end
    object actExcludeAll: TAction
      Caption = '<<'
      OnExecute = actExcludeAllExecute
      OnUpdate = actExcludeAllUpdate
    end
  end
end
