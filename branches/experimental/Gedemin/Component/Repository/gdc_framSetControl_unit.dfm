object gdc_framSetControl: Tgdc_framSetControl
  Left = 0
  Top = 0
  Width = 492
  Height = 285
  TabOrder = 0
  object Pnl: TPanel
    Left = 0
    Top = 0
    Width = 492
    Height = 35
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lk: TgsIBLookupComboBox
      Left = 8
      Top = 8
      Width = 145
      Height = 21
      HelpContext = 1
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnChange = lkChange
    end
    object Tb: TTBToolbar
      Left = 160
      Top = 8
      Width = 46
      Height = 22
      Caption = 'Tb'
      Images = dmImages.il16x16
      TabOrder = 1
      object tbiAddToSet: TTBItem
        Action = actAddToSet
        Visible = False
      end
      object tbiRemoveFromSet: TTBItem
        Action = actRemoveFromSet
      end
      object tbiAddToSetMany: TTBItem
        Action = actAddToSetMany
      end
    end
  end
  object Gr: TgsIBGrid
    Left = 0
    Top = 35
    Width = 492
    Height = 250
    Align = alClient
    DataSource = DS
    Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgTabs, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
    TabOrder = 1
    InternalMenuKind = imkWithSeparator
    Expands = <>
    ExpandsActive = False
    ExpandsSeparate = False
    TitlesExpanding = False
    Conditions = <>
    ConditionsActive = False
    CheckBox.Visible = False
    CheckBox.FirstColumn = False
    ScaleColumns = True
    MinColWidth = 40
    ColumnEditors = <>
    Aliases = <>
  end
  object DS: TDataSource
    Left = 208
    Top = 104
  end
  object Al: TActionList
    Images = dmImages.il16x16
    Left = 288
    Top = 96
    object actAddToSet: TAction
      Caption = 'actAddToSet'
      ImageIndex = 216
      OnExecute = actAddToSetExecute
      OnUpdate = actAddToSetUpdate
    end
    object actRemoveFromSet: TAction
      Caption = 'actRemoveFromSet'
      ImageIndex = 217
      OnExecute = actRemoveFromSetExecute
      OnUpdate = actRemoveFromSetUpdate
    end
    object actAddToSetMany: TAction
      Caption = 'actAddToSetMany'
      ImageIndex = 216
      OnExecute = actAddToSetManyExecute
      OnUpdate = actAddToSetManyUpdate
    end
  end
end
