object frmIncrDatabaseList: TfrmIncrDatabaseList
  Left = 0
  Top = 0
  Width = 460
  Height = 374
  TabOrder = 0
  object TBDock1: TTBDock
    Left = 0
    Top = 0
    Width = 460
    Height = 26
    object TBToolbar1: TTBToolbar
      Left = 0
      Top = 0
      Caption = 'TBToolbar1'
      DockMode = dmCannotFloat
      DragHandleStyle = dhNone
      FullSize = True
      Images = dmImages.il16x16
      TabOrder = 0
      object TBItem3: TTBItem
        Caption = 'Новая база'
        ImageIndex = 0
        OnClick = TBItem3Click
      end
      object TBItem1: TTBItem
        Caption = 'Удалить'
        ImageIndex = 2
        OnClick = TBItem1Click
      end
    end
  end
  object ibgrDatabases: TgsIBGrid
    Left = 0
    Top = 26
    Width = 460
    Height = 348
    Align = alClient
    DataSource = dsDatabases
    TabOrder = 1
    OnExit = ibgrDatabasesExit
    InternalMenuKind = imkWithSeparator
    Expands = <>
    ExpandsActive = False
    ExpandsSeparate = False
    TitlesExpanding = False
    Conditions = <>
    ConditionsActive = False
    CheckBox.Visible = False
    CheckBox.FirstColumn = False
    MinColWidth = 40
    ColumnEditors = <>
    Aliases = <>
  end
  object dsDatabases: TDataSource
    DataSet = gdcDatabases
    Left = 264
    Top = 96
  end
  object gdcDatabases: TgdcRplDatabase2
    Left = 320
    Top = 96
  end
end
