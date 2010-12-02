object prp_FunctionHistoryFrame: Tprp_FunctionHistoryFrame
  Left = 0
  Top = 0
  Width = 435
  Height = 266
  Align = alClient
  TabOrder = 0
  object Splitter1: TSplitter
    Left = 0
    Top = 121
    Width = 435
    Height = 3
    Cursor = crVSplit
    Align = alTop
  end
  object pnlLog: TPanel
    Left = 0
    Top = 0
    Width = 435
    Height = 121
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object ibgrLog: TgsIBGrid
      Left = 0
      Top = 0
      Width = 435
      Height = 121
      Align = alClient
      DataSource = dsLog
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
      PopupMenu = pmHistoryFrame
      ReadOnly = True
      TabOrder = 0
      OnDblClick = ibgrLogDblClick
      StripeOdd = clWhite
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
      ShowTotals = False
    end
  end
  object pnlFileView: TPanel
    Left = 0
    Top = 152
    Width = 435
    Height = 114
    Align = alClient
    BevelOuter = bvNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
  end
  object Panel1: TPanel
    Left = 0
    Top = 124
    Width = 435
    Height = 28
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    object TBDock1: TTBDock
      Left = 0
      Top = 0
      Width = 435
      Height = 26
      object TBToolbar1: TTBToolbar
        Left = 0
        Top = 0
        Caption = 'TBToolbar1'
        DefaultDock = TBDock1
        DockMode = dmCannotFloatOrChangeDocks
        Images = dmImages.il16x16
        ParentShowHint = False
        ShowHint = True
        Stretch = True
        TabOrder = 0
        object TBItem1: TTBItem
          Caption = 'Следующее отличие'
          Hint = 'Следующее отличие'
          ImageIndex = 48
          Images = dmImages.il16x16
          OnClick = TBItem1Click
        end
        object TBItem2: TTBItem
          Caption = 'Предыдущее отличие'
          Hint = 'Предыдущее отличие'
          ImageIndex = 47
          Images = dmImages.il16x16
          OnClick = TBItem2Click
        end
        object TBSeparatorItem1: TTBSeparatorItem
        end
        object tbOnlyDiff: TTBItem
          Caption = 'Только отличия'
          Hint = 'Только отличия'
          ImageIndex = 29
          Images = dmImages.il16x16
          OnClick = tbOnlyDiffClick
        end
        object TBSeparatorItem2: TTBSeparatorItem
        end
        object TBControlItem1: TTBControlItem
          Control = lblDiffStatus
        end
        object lblDiffStatus: TLabel
          Left = 81
          Top = 4
          Width = 3
          Height = 13
        end
      end
    end
  end
  object ibdsLog: TIBDataSet
    AfterOpen = ibdsLogAfterOpen
    SelectSQL.Strings = (
      'SELECT'
      '  l.id, CAST(l.revision AS VARCHAR(7)) AS revisionname, '
      '  l.revision,'
      '  l.script, l.editiondate, c.name AS authorname'
      'FROM'
      '  gd_function_log l JOIN gd_contact c ON c.id = l.editorkey'
      'WHERE'
      '  l.functionkey = :ID'
      ''
      'ORDER BY 3 DESC')
    Left = 320
    Top = 32
  end
  object dsLog: TDataSource
    OnDataChange = dsLogDataChange
    Left = 352
    Top = 32
  end
  object alHistoryFrame: TActionList
    Images = dmImages.il16x16
    Left = 200
    Top = 184
    object actCompareContents: TAction
      Category = 'Grid'
      Caption = 'Сравнить содержимое'
      ImageIndex = 121
      OnExecute = actCompareContentsExecute
      OnUpdate = actCompareContentsUpdate
    end
    object actCheckOut: TAction
      Category = 'Grid'
      Caption = 'Загрузить версию'
      ImageIndex = 27
      OnExecute = actCheckOutExecute
      OnUpdate = actCheckOutUpdate
    end
  end
  object pmHistoryFrame: TPopupMenu
    Images = dmImages.il16x16
    Left = 144
    Top = 64
    object N1: TMenuItem
      Action = actCompareContents
    end
    object N2: TMenuItem
      Action = actCheckOut
    end
  end
end
