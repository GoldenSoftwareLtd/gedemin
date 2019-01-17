inherited gdc_dlgRelation: Tgdc_dlgRelation
  Left = 689
  Top = 171
  Width = 538
  Height = 544
  HelpContext = 84
  BorderStyle = bsSizeable
  BorderWidth = 4
  Caption = 'Редактирование таблицы'
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 0
    Top = 475
    Anchors = [akLeft, akBottom]
    TabOrder = 3
  end
  inherited btnNew: TButton
    Left = 72
    Top = 475
    Anchors = [akLeft, akBottom]
    Enabled = False
    TabOrder = 4
  end
  inherited btnHelp: TButton
    Left = 144
    Top = 475
    Anchors = [akLeft, akBottom]
    TabOrder = 5
  end
  inherited btnOK: TButton
    Left = 374
    Top = 475
    Anchors = [akRight, akBottom]
    TabOrder = 1
  end
  inherited btnCancel: TButton
    Left = 446
    Top = 475
    Anchors = [akRight, akBottom]
    TabOrder = 2
  end
  object pcRelation: TPageControl [5]
    Left = 0
    Top = 0
    Width = 522
    Height = 469
    ActivePage = tsCommon
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    OnChange = pcRelationChange
    object tsCommon: TTabSheet
      Caption = 'Таблица'
      object lblTableName: TLabel
        Left = 6
        Top = 11
        Width = 99
        Height = 13
        Caption = 'Название таблицы:'
      end
      object lblLName: TLabel
        Left = 6
        Top = 40
        Width = 185
        Height = 13
        Caption = 'Локализованное название таблицы:'
      end
      object lblLShortName: TLabel
        Left = 6
        Top = 68
        Width = 144
        Height = 13
        Caption = 'Краткое название таблицы:'
      end
      object lblDescription: TLabel
        Left = 6
        Top = 97
        Width = 100
        Height = 13
        Caption = 'Описание таблицы:'
      end
      object lblReference: TLabel
        Left = 6
        Top = 229
        Width = 240
        Height = 13
        Caption = 'Ссылка на таблицу/наследование от таблицы:'
        Visible = False
      end
      object lblBranch: TLabel
        Left = 6
        Top = 199
        Width = 234
        Height = 13
        Caption = 'Ветка для команды вызова в Исследователе:'
      end
      object Label3: TLabel
        Left = 6
        Top = 258
        Width = 240
        Height = 13
        Caption = 'Поле для отображения в выпадающем списке:'
      end
      object Label4: TLabel
        Left = 6
        Top = 283
        Width = 235
        Height = 31
        AutoSize = False
        Caption = 
          'Поля для расширенного отображения в выпадающем списке (через зап' +
          'ятую):'
        WordWrap = True
      end
      object Label5: TLabel
        Left = 6
        Top = 319
        Width = 70
        Height = 13
        Caption = 'Бизнес-класс:'
      end
      object Label6: TLabel
        Left = 6
        Top = 347
        Width = 42
        Height = 13
        Caption = 'Подтип:'
      end
      object Label1: TLabel
        Left = 6
        Top = 167
        Width = 138
        Height = 13
        Caption = 'Семантические категории:'
      end
      object dbedRelationName: TDBEdit
        Left = 256
        Top = 8
        Width = 241
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        CharCase = ecUpperCase
        DataField = 'RELATIONNAME'
        DataSource = dsgdcBase
        MaxLength = 31
        TabOrder = 0
        OnEnter = dbedRelationNameEnter
        OnKeyDown = dbedRelationNameKeyDown
        OnKeyPress = dbedRelationNameKeyPress
      end
      object dbedLRelationName: TDBEdit
        Left = 256
        Top = 36
        Width = 241
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        DataField = 'LNAME'
        DataSource = dsgdcBase
        TabOrder = 1
      end
      object dbeShortRelationName: TDBEdit
        Left = 256
        Top = 65
        Width = 241
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        DataField = 'LSHORTNAME'
        DataSource = dsgdcBase
        TabOrder = 2
      end
      object dbeRelationDescription: TDBMemo
        Left = 256
        Top = 94
        Width = 241
        Height = 61
        Anchors = [akLeft, akTop, akRight]
        DataField = 'DESCRIPTION'
        DataSource = dsgdcBase
        TabOrder = 3
      end
      object ibcmbReference: TgsIBLookupComboBox
        Left = 256
        Top = 224
        Width = 241
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = IBTransaction
        Fields = 'relationname'
        ListTable = 'at_relations'
        ListField = 'lname'
        KeyField = 'id'
        gdClassName = 'TgdcRelation'
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 6
        Visible = False
      end
      object iblcExplorerBranch: TgsIBLookupComboBox
        Left = 256
        Top = 194
        Width = 241
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = IBTransaction
        ListTable = 'GD_COMMAND'
        ListField = 'NAME'
        KeyField = 'ID'
        Condition = 'ClassName IS NULL'
        gdClassName = 'TgdcExplorer'
        ViewType = vtTree
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 5
      end
      object dbeExtendedFields: TDBEdit
        Left = 256
        Top = 283
        Width = 241
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        CharCase = ecUpperCase
        DataField = 'extendedfields'
        DataSource = dsgdcBase
        TabOrder = 8
      end
      object dbeListField: TDBEdit
        Left = 256
        Top = 254
        Width = 241
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        CharCase = ecUpperCase
        DataField = 'listfield'
        DataSource = dsgdcBase
        TabOrder = 7
      end
      object lClass: TEdit
        Left = 256
        Top = 313
        Width = 241
        Height = 21
        TabStop = False
        Anchors = [akLeft, akTop, akRight]
        Color = clBtnFace
        TabOrder = 9
      end
      object lSubType: TEdit
        Left = 256
        Top = 343
        Width = 241
        Height = 21
        TabStop = False
        Anchors = [akLeft, akTop, akRight]
        Color = clBtnFace
        TabOrder = 10
      end
      object Panel8: TPanel
        Left = 0
        Top = 393
        Width = 514
        Height = 48
        Align = alBottom
        BevelOuter = bvNone
        BorderWidth = 4
        TabOrder = 11
        object lblWarn: TLabel
          Left = 4
          Top = 4
          Width = 506
          Height = 40
          Align = alClient
          AutoSize = False
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clRed
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          WordWrap = True
        end
      end
      object dbedSemCategory: TDBEdit
        Left = 256
        Top = 164
        Width = 241
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        DataField = 'SEMCATEGORY'
        DataSource = dsgdcBase
        TabOrder = 4
      end
    end
    object tsFields: TTabSheet
      BorderWidth = 2
      Caption = 'Поля'
      ImageIndex = 1
      object ibgrTableField: TgsIBGrid
        Left = 0
        Top = 26
        Width = 502
        Height = 411
        HelpContext = 3
        Align = alClient
        DataSource = dsTableField
        Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
        ReadOnly = True
        TabOrder = 0
        RefreshType = rtNone
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
      object TBDock1: TTBDock
        Left = 0
        Top = 0
        Width = 502
        Height = 26
        object tbFields: TTBToolbar
          Left = 0
          Top = 0
          BorderStyle = bsNone
          Caption = 'Редактирование таблицы'
          DockMode = dmCannotFloatOrChangeDocks
          FullSize = True
          Images = dmImages.il16x16
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          object TBItem3: TTBItem
            Action = actNewField
            DisplayMode = nbdmImageAndText
          end
          object TBItem2: TTBItem
            Action = actEditField
            DisplayMode = nbdmImageAndText
          end
          object TBItem1: TTBItem
            Action = actDeleteField
            DisplayMode = nbdmImageAndText
          end
          object TBSeparatorItem1: TTBSeparatorItem
          end
          object TBItem10: TTBItem
            Action = actAddFieldToSetting
          end
        end
      end
    end
    object tsTriggers: TTabSheet
      BorderWidth = 2
      Caption = 'Триггеры'
      ImageIndex = 2
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 502
        Height = 437
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object splTrigger: TSplitter
          Left = 0
          Top = 140
          Width = 502
          Height = 4
          Cursor = crVSplit
          Align = alTop
        end
        object Panel2: TPanel
          Left = 0
          Top = 0
          Width = 502
          Height = 140
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 0
          object ibgrTrigger: TgsIBGrid
            Left = 0
            Top = 26
            Width = 502
            Height = 114
            Align = alClient
            DataSource = dsTrigger
            Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
            ReadOnly = True
            TabOrder = 0
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
          object TBDock2: TTBDock
            Left = 0
            Top = 0
            Width = 502
            Height = 26
            object tbTriggers: TTBToolbar
              Left = 0
              Top = 0
              BorderStyle = bsNone
              Caption = 'Редактирование триггеров'
              DockMode = dmCannotFloatOrChangeDocks
              FullSize = True
              Images = dmImages.il16x16
              ShowCaption = False
              TabOrder = 0
              object TBItem4: TTBItem
                Action = actNewTrigger
                DisplayMode = nbdmImageAndText
                ImageIndex = 0
              end
              object TBItem5: TTBItem
                Action = actEditTrigger
                DisplayMode = nbdmImageAndText
                ImageIndex = 1
              end
              object TBItem6: TTBItem
                Action = actDeleteTrigger
                DisplayMode = nbdmImageAndText
                ImageIndex = 2
              end
              object TBSeparatorItem2: TTBSeparatorItem
              end
              object TBItem11: TTBItem
                Action = actAddTriggerToSetting
              end
            end
          end
        end
        object Panel3: TPanel
          Left = 0
          Top = 144
          Width = 502
          Height = 293
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 1
          object dbseTriggerBody: TDBSynEdit
            Left = 0
            Top = 27
            Width = 502
            Height = 266
            Cursor = crIBeam
            DataField = 'RDB$TRIGGER_SOURCE'
            DataSource = dsTrigger
            Align = alClient
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Courier New'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 0
            Gutter.DigitCount = 3
            Gutter.Font.Charset = DEFAULT_CHARSET
            Gutter.Font.Color = clWindowText
            Gutter.Font.Height = -13
            Gutter.Font.Name = 'Courier New'
            Gutter.Font.Style = []
            Gutter.LeftOffset = 0
            Gutter.ShowLineNumbers = True
            Highlighter = SynSQLSyn
            Keystrokes = <
              item
                Command = ecUp
                ShortCut = 38
              end
              item
                Command = ecSelUp
                ShortCut = 8230
              end
              item
                Command = ecScrollUp
                ShortCut = 16422
              end
              item
                Command = ecDown
                ShortCut = 40
              end
              item
                Command = ecSelDown
                ShortCut = 8232
              end
              item
                Command = ecScrollDown
                ShortCut = 16424
              end
              item
                Command = ecLeft
                ShortCut = 37
              end
              item
                Command = ecSelLeft
                ShortCut = 8229
              end
              item
                Command = ecWordLeft
                ShortCut = 16421
              end
              item
                Command = ecSelWordLeft
                ShortCut = 24613
              end
              item
                Command = ecRight
                ShortCut = 39
              end
              item
                Command = ecSelRight
                ShortCut = 8231
              end
              item
                Command = ecWordRight
                ShortCut = 16423
              end
              item
                Command = ecSelWordRight
                ShortCut = 24615
              end
              item
                Command = ecPageDown
                ShortCut = 34
              end
              item
                Command = ecSelPageDown
                ShortCut = 8226
              end
              item
                Command = ecPageBottom
                ShortCut = 16418
              end
              item
                Command = ecSelPageBottom
                ShortCut = 24610
              end
              item
                Command = ecPageUp
                ShortCut = 33
              end
              item
                Command = ecSelPageUp
                ShortCut = 8225
              end
              item
                Command = ecPageTop
                ShortCut = 16417
              end
              item
                Command = ecSelPageTop
                ShortCut = 24609
              end
              item
                Command = ecLineStart
                ShortCut = 36
              end
              item
                Command = ecSelLineStart
                ShortCut = 8228
              end
              item
                Command = ecEditorTop
                ShortCut = 16420
              end
              item
                Command = ecSelEditorTop
                ShortCut = 24612
              end
              item
                Command = ecLineEnd
                ShortCut = 35
              end
              item
                Command = ecSelLineEnd
                ShortCut = 8227
              end
              item
                Command = ecEditorBottom
                ShortCut = 16419
              end
              item
                Command = ecSelEditorBottom
                ShortCut = 24611
              end
              item
                Command = ecToggleMode
                ShortCut = 45
              end
              item
                Command = ecCopy
                ShortCut = 16429
              end
              item
                Command = ecCut
                ShortCut = 8238
              end
              item
                Command = ecPaste
                ShortCut = 8237
              end
              item
                Command = ecDeleteChar
                ShortCut = 46
              end
              item
                Command = ecDeleteLastChar
                ShortCut = 8
              end
              item
                Command = ecDeleteLastChar
                ShortCut = 8200
              end
              item
                Command = ecDeleteLastWord
                ShortCut = 16392
              end
              item
                Command = ecUndo
                ShortCut = 32776
              end
              item
                Command = ecRedo
                ShortCut = 40968
              end
              item
                Command = ecLineBreak
                ShortCut = 13
              end
              item
                Command = ecLineBreak
                ShortCut = 8205
              end
              item
                Command = ecTab
                ShortCut = 9
              end
              item
                Command = ecShiftTab
                ShortCut = 8201
              end
              item
                Command = ecContextHelp
                ShortCut = 16496
              end
              item
                Command = ecSelectAll
                ShortCut = 16449
              end
              item
                Command = ecCopy
                ShortCut = 16451
              end
              item
                Command = ecPaste
                ShortCut = 16470
              end
              item
                Command = ecCut
                ShortCut = 16472
              end
              item
                Command = ecBlockIndent
                ShortCut = 24649
              end
              item
                Command = ecBlockUnindent
                ShortCut = 24661
              end
              item
                Command = ecLineBreak
                ShortCut = 16461
              end
              item
                Command = ecInsertLine
                ShortCut = 16462
              end
              item
                Command = ecDeleteWord
                ShortCut = 16468
              end
              item
                Command = ecDeleteLine
                ShortCut = 16473
              end
              item
                Command = ecDeleteEOL
                ShortCut = 24665
              end
              item
                Command = ecUndo
                ShortCut = 16474
              end
              item
                Command = ecRedo
                ShortCut = 24666
              end
              item
                Command = ecGotoMarker0
                ShortCut = 16432
              end
              item
                Command = ecGotoMarker1
                ShortCut = 16433
              end
              item
                Command = ecGotoMarker2
                ShortCut = 16434
              end
              item
                Command = ecGotoMarker3
                ShortCut = 16435
              end
              item
                Command = ecGotoMarker4
                ShortCut = 16436
              end
              item
                Command = ecGotoMarker5
                ShortCut = 16437
              end
              item
                Command = ecGotoMarker6
                ShortCut = 16438
              end
              item
                Command = ecGotoMarker7
                ShortCut = 16439
              end
              item
                Command = ecGotoMarker8
                ShortCut = 16440
              end
              item
                Command = ecGotoMarker9
                ShortCut = 16441
              end
              item
                Command = ecSetMarker0
                ShortCut = 24624
              end
              item
                Command = ecSetMarker1
                ShortCut = 24625
              end
              item
                Command = ecSetMarker2
                ShortCut = 24626
              end
              item
                Command = ecSetMarker3
                ShortCut = 24627
              end
              item
                Command = ecSetMarker4
                ShortCut = 24628
              end
              item
                Command = ecSetMarker5
                ShortCut = 24629
              end
              item
                Command = ecSetMarker6
                ShortCut = 24630
              end
              item
                Command = ecSetMarker7
                ShortCut = 24631
              end
              item
                Command = ecSetMarker8
                ShortCut = 24632
              end
              item
                Command = ecSetMarker9
                ShortCut = 24633
              end
              item
                Command = ecNormalSelect
                ShortCut = 24654
              end
              item
                Command = ecColumnSelect
                ShortCut = 24643
              end
              item
                Command = ecLineSelect
                ShortCut = 24652
              end
              item
                Command = ecMatchBracket
                ShortCut = 24642
              end>
            ReadOnly = True
          end
          object Panel6: TPanel
            Left = 0
            Top = 0
            Width = 502
            Height = 27
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 1
            object lblTriggerType: TLabel
              Left = 2
              Top = 7
              Width = 68
              Height = 13
              Caption = 'lblTriggerType'
            end
          end
        end
      end
    end
    object tsIndices: TTabSheet
      BorderWidth = 2
      Caption = 'Индексы'
      ImageIndex = 3
      object ibgrIndex: TgsIBGrid
        Left = 0
        Top = 26
        Width = 502
        Height = 411
        HelpContext = 3
        Align = alClient
        DataSource = dsIndex
        Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
        ReadOnly = True
        TabOrder = 0
        OnDblClick = actEditIndexExecute
        RefreshType = rtNone
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
      object TBDock3: TTBDock
        Left = 0
        Top = 0
        Width = 502
        Height = 26
        object tbIndices: TTBToolbar
          Left = 0
          Top = 0
          BorderStyle = bsNone
          Caption = 'tbIndices'
          DockMode = dmCannotFloatOrChangeDocks
          FullSize = True
          Images = dmImages.il16x16
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          object tbiNewIndices: TTBItem
            Action = actNewIndex
            DisplayMode = nbdmImageAndText
          end
          object tbiEditIndices: TTBItem
            Action = actEditIndex
            DisplayMode = nbdmImageAndText
          end
          object tbiDeleteIndices: TTBItem
            Action = actDeleteIndex
            DisplayMode = nbdmImageAndText
          end
          object TBSeparatorItem3: TTBSeparatorItem
          end
          object TBItem12: TTBItem
            Action = actAddIndexToSetting
          end
        end
      end
    end
    object tsConstraints: TTabSheet
      BorderWidth = 2
      Caption = 'Ограничения'
      ImageIndex = 4
      object ibgrCheckConstraint: TgsIBGrid
        Left = 0
        Top = 26
        Width = 502
        Height = 310
        Align = alClient
        DataSource = dsCheckConstraint
        Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
        ReadOnly = True
        TabOrder = 0
        OnDblClick = actEditCheckExecute
        RefreshType = rtNone
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
      object TBDock4: TTBDock
        Left = 0
        Top = 0
        Width = 502
        Height = 26
        object tbChecks: TTBToolbar
          Left = 0
          Top = 0
          BorderStyle = bsNone
          Caption = 'tbChecks'
          DockMode = dmCannotFloatOrChangeDocks
          FullSize = True
          Images = dmImages.il16x16
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          object TBItem7: TTBItem
            Action = actNewCheck
            DisplayMode = nbdmImageAndText
          end
          object TBItem8: TTBItem
            Action = actEditCheck
            DisplayMode = nbdmImageAndText
          end
          object TBItem9: TTBItem
            Action = actDeleteCheck
            DisplayMode = nbdmImageAndText
          end
          object TBSeparatorItem4: TTBSeparatorItem
          end
          object TBItem13: TTBItem
            Action = actAddConstraintToSetting
          end
        end
      end
      object dbseConstraint: TDBSynEdit
        Left = 0
        Top = 341
        Width = 502
        Height = 96
        Cursor = crIBeam
        DataField = 'RDB$TRIGGER_SOURCE'
        DataSource = dsCheckConstraint
        Align = alBottom
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        TabOrder = 2
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -11
        Gutter.Font.Name = 'Terminal'
        Gutter.Font.Style = []
        Gutter.Visible = False
        Highlighter = SynSQLSyn
        Keystrokes = <
          item
            Command = ecUp
            ShortCut = 38
          end
          item
            Command = ecSelUp
            ShortCut = 8230
          end
          item
            Command = ecScrollUp
            ShortCut = 16422
          end
          item
            Command = ecDown
            ShortCut = 40
          end
          item
            Command = ecSelDown
            ShortCut = 8232
          end
          item
            Command = ecScrollDown
            ShortCut = 16424
          end
          item
            Command = ecLeft
            ShortCut = 37
          end
          item
            Command = ecSelLeft
            ShortCut = 8229
          end
          item
            Command = ecWordLeft
            ShortCut = 16421
          end
          item
            Command = ecSelWordLeft
            ShortCut = 24613
          end
          item
            Command = ecRight
            ShortCut = 39
          end
          item
            Command = ecSelRight
            ShortCut = 8231
          end
          item
            Command = ecWordRight
            ShortCut = 16423
          end
          item
            Command = ecSelWordRight
            ShortCut = 24615
          end
          item
            Command = ecPageDown
            ShortCut = 34
          end
          item
            Command = ecSelPageDown
            ShortCut = 8226
          end
          item
            Command = ecPageBottom
            ShortCut = 16418
          end
          item
            Command = ecSelPageBottom
            ShortCut = 24610
          end
          item
            Command = ecPageUp
            ShortCut = 33
          end
          item
            Command = ecSelPageUp
            ShortCut = 8225
          end
          item
            Command = ecPageTop
            ShortCut = 16417
          end
          item
            Command = ecSelPageTop
            ShortCut = 24609
          end
          item
            Command = ecLineStart
            ShortCut = 36
          end
          item
            Command = ecSelLineStart
            ShortCut = 8228
          end
          item
            Command = ecEditorTop
            ShortCut = 16420
          end
          item
            Command = ecSelEditorTop
            ShortCut = 24612
          end
          item
            Command = ecLineEnd
            ShortCut = 35
          end
          item
            Command = ecSelLineEnd
            ShortCut = 8227
          end
          item
            Command = ecEditorBottom
            ShortCut = 16419
          end
          item
            Command = ecSelEditorBottom
            ShortCut = 24611
          end
          item
            Command = ecToggleMode
            ShortCut = 45
          end
          item
            Command = ecCopy
            ShortCut = 16429
          end
          item
            Command = ecCut
            ShortCut = 8238
          end
          item
            Command = ecPaste
            ShortCut = 8237
          end
          item
            Command = ecDeleteChar
            ShortCut = 46
          end
          item
            Command = ecDeleteLastChar
            ShortCut = 8
          end
          item
            Command = ecDeleteLastChar
            ShortCut = 8200
          end
          item
            Command = ecDeleteLastWord
            ShortCut = 16392
          end
          item
            Command = ecUndo
            ShortCut = 32776
          end
          item
            Command = ecRedo
            ShortCut = 40968
          end
          item
            Command = ecLineBreak
            ShortCut = 13
          end
          item
            Command = ecLineBreak
            ShortCut = 8205
          end
          item
            Command = ecTab
            ShortCut = 9
          end
          item
            Command = ecShiftTab
            ShortCut = 8201
          end
          item
            Command = ecContextHelp
            ShortCut = 16496
          end
          item
            Command = ecSelectAll
            ShortCut = 16449
          end
          item
            Command = ecCopy
            ShortCut = 16451
          end
          item
            Command = ecPaste
            ShortCut = 16470
          end
          item
            Command = ecCut
            ShortCut = 16472
          end
          item
            Command = ecBlockIndent
            ShortCut = 24649
          end
          item
            Command = ecBlockUnindent
            ShortCut = 24661
          end
          item
            Command = ecLineBreak
            ShortCut = 16461
          end
          item
            Command = ecInsertLine
            ShortCut = 16462
          end
          item
            Command = ecDeleteWord
            ShortCut = 16468
          end
          item
            Command = ecDeleteLine
            ShortCut = 16473
          end
          item
            Command = ecDeleteEOL
            ShortCut = 24665
          end
          item
            Command = ecUndo
            ShortCut = 16474
          end
          item
            Command = ecRedo
            ShortCut = 24666
          end
          item
            Command = ecGotoMarker0
            ShortCut = 16432
          end
          item
            Command = ecGotoMarker1
            ShortCut = 16433
          end
          item
            Command = ecGotoMarker2
            ShortCut = 16434
          end
          item
            Command = ecGotoMarker3
            ShortCut = 16435
          end
          item
            Command = ecGotoMarker4
            ShortCut = 16436
          end
          item
            Command = ecGotoMarker5
            ShortCut = 16437
          end
          item
            Command = ecGotoMarker6
            ShortCut = 16438
          end
          item
            Command = ecGotoMarker7
            ShortCut = 16439
          end
          item
            Command = ecGotoMarker8
            ShortCut = 16440
          end
          item
            Command = ecGotoMarker9
            ShortCut = 16441
          end
          item
            Command = ecSetMarker0
            ShortCut = 24624
          end
          item
            Command = ecSetMarker1
            ShortCut = 24625
          end
          item
            Command = ecSetMarker2
            ShortCut = 24626
          end
          item
            Command = ecSetMarker3
            ShortCut = 24627
          end
          item
            Command = ecSetMarker4
            ShortCut = 24628
          end
          item
            Command = ecSetMarker5
            ShortCut = 24629
          end
          item
            Command = ecSetMarker6
            ShortCut = 24630
          end
          item
            Command = ecSetMarker7
            ShortCut = 24631
          end
          item
            Command = ecSetMarker8
            ShortCut = 24632
          end
          item
            Command = ecSetMarker9
            ShortCut = 24633
          end
          item
            Command = ecNormalSelect
            ShortCut = 24654
          end
          item
            Command = ecColumnSelect
            ShortCut = 24643
          end
          item
            Command = ecLineSelect
            ShortCut = 24652
          end
          item
            Command = ecMatchBracket
            ShortCut = 24642
          end>
        ReadOnly = True
      end
      object Panel7: TPanel
        Left = 0
        Top = 336
        Width = 502
        Height = 5
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 3
      end
    end
    object tsScript: TTabSheet
      BorderWidth = 2
      Caption = 'Скрипт'
      ImageIndex = 5
      object smScriptText: TSynMemo
        Left = 0
        Top = 0
        Width = 502
        Height = 437
        Cursor = crIBeam
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        TabOrder = 0
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -11
        Gutter.Font.Name = 'Terminal'
        Gutter.Font.Style = []
        Highlighter = SynSQLSyn
        Keystrokes = <
          item
            Command = ecUp
            ShortCut = 38
          end
          item
            Command = ecSelUp
            ShortCut = 8230
          end
          item
            Command = ecScrollUp
            ShortCut = 16422
          end
          item
            Command = ecDown
            ShortCut = 40
          end
          item
            Command = ecSelDown
            ShortCut = 8232
          end
          item
            Command = ecScrollDown
            ShortCut = 16424
          end
          item
            Command = ecLeft
            ShortCut = 37
          end
          item
            Command = ecSelLeft
            ShortCut = 8229
          end
          item
            Command = ecWordLeft
            ShortCut = 16421
          end
          item
            Command = ecSelWordLeft
            ShortCut = 24613
          end
          item
            Command = ecRight
            ShortCut = 39
          end
          item
            Command = ecSelRight
            ShortCut = 8231
          end
          item
            Command = ecWordRight
            ShortCut = 16423
          end
          item
            Command = ecSelWordRight
            ShortCut = 24615
          end
          item
            Command = ecPageDown
            ShortCut = 34
          end
          item
            Command = ecSelPageDown
            ShortCut = 8226
          end
          item
            Command = ecPageBottom
            ShortCut = 16418
          end
          item
            Command = ecSelPageBottom
            ShortCut = 24610
          end
          item
            Command = ecPageUp
            ShortCut = 33
          end
          item
            Command = ecSelPageUp
            ShortCut = 8225
          end
          item
            Command = ecPageTop
            ShortCut = 16417
          end
          item
            Command = ecSelPageTop
            ShortCut = 24609
          end
          item
            Command = ecLineStart
            ShortCut = 36
          end
          item
            Command = ecSelLineStart
            ShortCut = 8228
          end
          item
            Command = ecEditorTop
            ShortCut = 16420
          end
          item
            Command = ecSelEditorTop
            ShortCut = 24612
          end
          item
            Command = ecLineEnd
            ShortCut = 35
          end
          item
            Command = ecSelLineEnd
            ShortCut = 8227
          end
          item
            Command = ecEditorBottom
            ShortCut = 16419
          end
          item
            Command = ecSelEditorBottom
            ShortCut = 24611
          end
          item
            Command = ecToggleMode
            ShortCut = 45
          end
          item
            Command = ecCopy
            ShortCut = 16429
          end
          item
            Command = ecCut
            ShortCut = 8238
          end
          item
            Command = ecPaste
            ShortCut = 8237
          end
          item
            Command = ecDeleteChar
            ShortCut = 46
          end
          item
            Command = ecDeleteLastChar
            ShortCut = 8
          end
          item
            Command = ecDeleteLastChar
            ShortCut = 8200
          end
          item
            Command = ecDeleteLastWord
            ShortCut = 16392
          end
          item
            Command = ecUndo
            ShortCut = 32776
          end
          item
            Command = ecRedo
            ShortCut = 40968
          end
          item
            Command = ecLineBreak
            ShortCut = 13
          end
          item
            Command = ecLineBreak
            ShortCut = 8205
          end
          item
            Command = ecTab
            ShortCut = 9
          end
          item
            Command = ecShiftTab
            ShortCut = 8201
          end
          item
            Command = ecContextHelp
            ShortCut = 16496
          end
          item
            Command = ecSelectAll
            ShortCut = 16449
          end
          item
            Command = ecCopy
            ShortCut = 16451
          end
          item
            Command = ecPaste
            ShortCut = 16470
          end
          item
            Command = ecCut
            ShortCut = 16472
          end
          item
            Command = ecBlockIndent
            ShortCut = 24649
          end
          item
            Command = ecBlockUnindent
            ShortCut = 24661
          end
          item
            Command = ecLineBreak
            ShortCut = 16461
          end
          item
            Command = ecInsertLine
            ShortCut = 16462
          end
          item
            Command = ecDeleteWord
            ShortCut = 16468
          end
          item
            Command = ecDeleteLine
            ShortCut = 16473
          end
          item
            Command = ecDeleteEOL
            ShortCut = 24665
          end
          item
            Command = ecUndo
            ShortCut = 16474
          end
          item
            Command = ecRedo
            ShortCut = 24666
          end
          item
            Command = ecGotoMarker0
            ShortCut = 16432
          end
          item
            Command = ecGotoMarker1
            ShortCut = 16433
          end
          item
            Command = ecGotoMarker2
            ShortCut = 16434
          end
          item
            Command = ecGotoMarker3
            ShortCut = 16435
          end
          item
            Command = ecGotoMarker4
            ShortCut = 16436
          end
          item
            Command = ecGotoMarker5
            ShortCut = 16437
          end
          item
            Command = ecGotoMarker6
            ShortCut = 16438
          end
          item
            Command = ecGotoMarker7
            ShortCut = 16439
          end
          item
            Command = ecGotoMarker8
            ShortCut = 16440
          end
          item
            Command = ecGotoMarker9
            ShortCut = 16441
          end
          item
            Command = ecSetMarker0
            ShortCut = 24624
          end
          item
            Command = ecSetMarker1
            ShortCut = 24625
          end
          item
            Command = ecSetMarker2
            ShortCut = 24626
          end
          item
            Command = ecSetMarker3
            ShortCut = 24627
          end
          item
            Command = ecSetMarker4
            ShortCut = 24628
          end
          item
            Command = ecSetMarker5
            ShortCut = 24629
          end
          item
            Command = ecSetMarker6
            ShortCut = 24630
          end
          item
            Command = ecSetMarker7
            ShortCut = 24631
          end
          item
            Command = ecSetMarker8
            ShortCut = 24632
          end
          item
            Command = ecSetMarker9
            ShortCut = 24633
          end
          item
            Command = ecNormalSelect
            ShortCut = 24654
          end
          item
            Command = ecColumnSelect
            ShortCut = 24643
          end
          item
            Command = ecLineSelect
            ShortCut = 24652
          end
          item
            Command = ecMatchBracket
            ShortCut = 24642
          end>
        ReadOnly = True
      end
    end
  end
  inherited alBase: TActionList
    Left = 299
    Top = 65
    object actNewField: TAction
      Category = 'Fields'
      Hint = 'Создать поле'
      ImageIndex = 0
      ShortCut = 45
      OnExecute = actNewFieldExecute
      OnUpdate = actNewFieldUpdate
    end
    object actEditField: TAction
      Category = 'Fields'
      Hint = 'Редактировать поле'
      ImageIndex = 1
      ShortCut = 16397
      OnExecute = actEditFieldExecute
      OnUpdate = actEditFieldUpdate
    end
    object actDeleteField: TAction
      Category = 'Fields'
      Hint = 'Удалить поле'
      ImageIndex = 2
      ShortCut = 16430
      OnExecute = actDeleteFieldExecute
      OnUpdate = actDeleteFieldUpdate
    end
    object actNewTrigger: TAction
      Category = 'Triggers'
      Hint = 'Добавить триггер'
      OnExecute = actNewTriggerExecute
      OnUpdate = actNewTriggerUpdate
    end
    object actEditTrigger: TAction
      Category = 'Triggers'
      Hint = 'Изменить триггер'
      OnExecute = actEditTriggerExecute
      OnUpdate = actEditTriggerUpdate
    end
    object actDeleteTrigger: TAction
      Category = 'Triggers'
      Hint = 'Удалить триггер'
      OnExecute = actDeleteTriggerExecute
      OnUpdate = actDeleteTriggerUpdate
    end
    object actNewIndex: TAction
      Category = 'Indices'
      Hint = 'Добавить индекс'
      ImageIndex = 0
      OnExecute = actNewIndexExecute
      OnUpdate = actNewIndexUpdate
    end
    object actEditIndex: TAction
      Category = 'Indices'
      Hint = 'Редактировать индекс'
      ImageIndex = 1
      OnExecute = actEditIndexExecute
      OnUpdate = actEditIndexUpdate
    end
    object actDeleteIndex: TAction
      Category = 'Indices'
      Hint = 'Удалить индекс'
      ImageIndex = 2
      OnExecute = actDeleteIndexExecute
      OnUpdate = actDeleteIndexUpdate
    end
    object actSetShortCat: TAction
      Caption = 'Установка горячих главиш'
    end
    object actNewCheck: TAction
      Category = 'Checks'
      Hint = 'Добавить ограничение'
      ImageIndex = 0
      OnExecute = actNewCheckExecute
      OnUpdate = actNewCheckUpdate
    end
    object actEditCheck: TAction
      Category = 'Checks'
      Hint = 'Редактировать ограничение'
      ImageIndex = 1
      OnExecute = actEditCheckExecute
      OnUpdate = actEditCheckUpdate
    end
    object actDeleteCheck: TAction
      Category = 'Checks'
      Hint = 'Удалить ограничение'
      ImageIndex = 2
      OnExecute = actDeleteCheckExecute
      OnUpdate = actDeleteCheckUpdate
    end
    object actAddFieldToSetting: TAction
      Category = 'Fields'
      Hint = 'Добавить в ПИ...'
      ImageIndex = 81
      OnExecute = actAddFieldToSettingExecute
      OnUpdate = actAddFieldToSettingUpdate
    end
    object actAddTriggerToSetting: TAction
      Category = 'Triggers'
      Hint = 'Добавить в ПИ...'
      ImageIndex = 81
      OnExecute = actAddTriggerToSettingExecute
      OnUpdate = actAddTriggerToSettingUpdate
    end
    object actAddIndexToSetting: TAction
      Category = 'Indices'
      Hint = 'Добавить в ПИ...'
      ImageIndex = 81
      OnExecute = actAddIndexToSettingExecute
      OnUpdate = actAddIndexToSettingUpdate
    end
    object actAddConstraintToSetting: TAction
      Category = 'Checks'
      Hint = 'Добавить в ПИ...'
      ImageIndex = 81
      OnExecute = actAddConstraintToSettingExecute
      OnUpdate = actAddConstraintToSettingUpdate
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 350
    Top = 65
  end
  inherited pm_dlgG: TPopupMenu
    Left = 224
    Top = 376
  end
  object dsTableField: TDataSource
    Left = 350
    Top = 102
  end
  object SynSQLSyn: TSynSQLSyn
    DefaultFilter = 'SQL files (*.sql)|*.sql'
    CommentAttri.Foreground = clBlue
    SQLDialect = sqlInterbase6
    Left = 180
    Top = 376
  end
  object dsIndex: TDataSource
    DataSet = gdcIndex
    Left = 348
    Top = 136
  end
  object gdcIndex: TgdcIndex
    MasterSource = dsgdcBase
    MasterField = 'id'
    DetailField = 'relationkey'
    SubSet = 'ByRelation'
    Left = 387
    Top = 134
  end
  object gdcTrigger: TgdcTrigger
    MasterSource = dsgdcBase
    MasterField = 'id'
    DetailField = 'relationkey'
    SubSet = 'ByRelation'
    Left = 380
    Top = 168
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    DefaultAction = TACommit
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 268
    Top = 168
  end
  object dsCheckConstraint: TDataSource
    DataSet = gdcCheckConstraint
    Left = 349
    Top = 202
  end
  object gdcCheckConstraint: TgdcCheckConstraint
    MasterSource = dsgdcBase
    MasterField = 'id'
    DetailField = 'relationkey'
    SubSet = 'ByRelation'
    Left = 383
    Top = 203
  end
  object dsTrigger: TDataSource
    DataSet = gdcTrigger
    OnDataChange = dsTriggerDataChange
    Left = 350
    Top = 175
  end
end
