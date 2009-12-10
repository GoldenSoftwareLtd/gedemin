inherited gdc_dlgRelation: Tgdc_dlgRelation
  Left = 345
  Top = 222
  Width = 503
  Height = 430
  HelpContext = 84
  BorderStyle = bsSizeable
  Caption = 'Редактирование таблицы'
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 3
    Top = 377
    Anchors = [akLeft, akBottom]
  end
  inherited btnNew: TButton
    Left = 79
    Top = 377
    Anchors = [akLeft, akBottom]
    Enabled = False
  end
  inherited btnHelp: TButton
    Left = 155
    Top = 377
    Anchors = [akLeft, akBottom]
  end
  inherited btnOK: TButton
    Left = 347
    Top = 377
    Anchors = [akRight, akBottom]
  end
  inherited btnCancel: TButton
    Left = 423
    Top = 377
    Anchors = [akRight, akBottom]
  end
  object pcRelation: TPageControl [5]
    Left = 3
    Top = 8
    Width = 489
    Height = 367
    ActivePage = tsCommon
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 5
    OnChanging = pcRelationChanging
    object tsCommon: TTabSheet
      Caption = 'Таблица'
      object lblTableName: TLabel
        Left = 6
        Top = 11
        Width = 217
        Height = 13
        Caption = 'Название таблицы (на английском языке):'
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
        Top = 201
        Width = 218
        Height = 13
        Caption = 'Ссылка на таблицу (связь один к одному):'
        Visible = False
      end
      object lblBranch: TLabel
        Left = 6
        Top = 171
        Width = 234
        Height = 13
        Caption = 'Ветка для команды вызова в Исследователе:'
      end
      object Label3: TLabel
        Left = 6
        Top = 230
        Width = 206
        Height = 13
        Caption = 'Поле для отображения (на английском):'
      end
      object Label4: TLabel
        Left = 6
        Top = 260
        Width = 235
        Height = 31
        AutoSize = False
        Caption = 
          'Поля для расширенного отображения  (на английском через запятую)' +
          ':'
        WordWrap = True
      end
      object Label5: TLabel
        Left = 6
        Top = 295
        Width = 169
        Height = 13
        Caption = 'Соответствующий бизнес-класс:'
      end
      object Label6: TLabel
        Left = 6
        Top = 320
        Width = 140
        Height = 13
        Caption = 'Соответствующий подтип:'
      end
      object dbedRelationName: TDBEdit
        Left = 256
        Top = 8
        Width = 221
        Height = 21
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
        Width = 221
        Height = 21
        DataField = 'LNAME'
        DataSource = dsgdcBase
        TabOrder = 1
      end
      object dbeShortRelationName: TDBEdit
        Left = 256
        Top = 65
        Width = 221
        Height = 21
        DataField = 'LSHORTNAME'
        DataSource = dsgdcBase
        TabOrder = 2
      end
      object dbeRelationDescription: TDBMemo
        Left = 256
        Top = 96
        Width = 221
        Height = 61
        DataField = 'DESCRIPTION'
        DataSource = dsgdcBase
        TabOrder = 3
      end
      object ibcmbReference: TgsIBLookupComboBox
        Left = 256
        Top = 198
        Width = 222
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = IBTransaction
        Fields = 'relationname'
        ListTable = 'at_relations'
        ListField = 'lname'
        KeyField = 'id'
        gdClassName = 'TgdcRelation'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 5
        Visible = False
      end
      object iblcExplorerBranch: TgsIBLookupComboBox
        Left = 256
        Top = 167
        Width = 222
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = dmDatabase.ibtrGenUniqueID
        ListTable = 'GD_COMMAND'
        ListField = 'NAME'
        KeyField = 'ID'
        Condition = 'ClassName IS NULL'
        gdClassName = 'TgdcExplorer'
        ViewType = vtTree
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 4
        OnChange = iblcExplorerBranchChange
      end
      object dbeExtendedFields: TDBEdit
        Left = 256
        Top = 260
        Width = 222
        Height = 21
        CharCase = ecUpperCase
        DataField = 'extendedfields'
        DataSource = dsgdcBase
        TabOrder = 7
      end
      object dbeListField: TDBEdit
        Left = 256
        Top = 230
        Width = 222
        Height = 21
        CharCase = ecUpperCase
        DataField = 'listfield'
        DataSource = dsgdcBase
        TabOrder = 6
      end
      object lClass: TEdit
        Left = 256
        Top = 287
        Width = 222
        Height = 21
        TabStop = False
        BorderStyle = bsNone
        Color = clBtnFace
        TabOrder = 8
      end
      object lSubType: TEdit
        Left = 256
        Top = 312
        Width = 222
        Height = 21
        TabStop = False
        BorderStyle = bsNone
        Color = clBtnFace
        TabOrder = 9
      end
    end
    object tsFields: TTabSheet
      Caption = 'Поля'
      ImageIndex = 1
      object ibgrRelationFields: TgsIBGrid
        Left = 3
        Top = 30
        Width = 475
        Height = 305
        HelpContext = 3
        Anchors = [akLeft, akTop, akRight, akBottom]
        DataSource = dsRelationFields
        Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
        TabOrder = 0
        OnDblClick = ibgrRelationFieldsDblClick
        OnEnter = actSetShortCatExecute
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
        MinColWidth = 40
        ColumnEditors = <>
        Aliases = <>
        ShowTotals = False
      end
      object tbFields: TTBToolbar
        Left = 3
        Top = 3
        Width = 341
        Height = 22
        Caption = 'Редактирование таблицы'
        Images = dmImages.il16x16
        TabOrder = 1
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
      end
    end
    object tsTrigger: TTabSheet
      Caption = 'Триггеры'
      ImageIndex = 2
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 481
        Height = 339
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object Splitter1: TSplitter
          Left = 0
          Top = 113
          Width = 481
          Height = 4
          Cursor = crVSplit
          Align = alTop
        end
        object Panel2: TPanel
          Left = 0
          Top = 0
          Width = 481
          Height = 113
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 0
          object tvTriggers: TTreeView
            Left = 0
            Top = 0
            Width = 481
            Height = 113
            Align = alClient
            Images = dmImages.ilToolBarSmall
            Indent = 19
            ReadOnly = True
            TabOrder = 0
            OnChange = tvTriggersChange
            OnCustomDrawItem = tvTriggersCustomDrawItem
            OnDblClick = tvTriggersDblClick
            Items.Data = {
              06000000260000001C0000001C000000FFFFFFFFFFFFFFFF0000000000000000
              0D4265666F726520496E73657274250000001C0000001C000000FFFFFFFFFFFF
              FFFF00000000000000000C416674657220496E73657274260000001C0000001C
              000000FFFFFFFFFFFFFFFF00000000000000000D4265666F7265205570646174
              65250000001C0000001C000000FFFFFFFFFFFFFFFF00000000000000000C4166
              74657220557064617465260000001C0000001C000000FFFFFFFFFFFFFFFF0000
              0000000000000D4265666F72652044656C657465250000001C0000001C000000
              FFFFFFFFFFFFFFFF00000000000000000C41667465722044656C657465}
          end
        end
        object Panel3: TPanel
          Left = 0
          Top = 117
          Width = 481
          Height = 222
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 1
          object tbTriggers: TTBToolbar
            Left = 3
            Top = 5
            Width = 229
            Height = 22
            Caption = 'Редактирование триггеров'
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
          end
          object smTriggerBody: TSynMemo
            Left = 3
            Top = 32
            Width = 474
            Height = 192
            Cursor = crIBeam
            Anchors = [akLeft, akTop, akRight, akBottom]
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Courier New'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 1
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
                Command = ecPaste
                ShortCut = 8237
              end
              item
                Command = ecDeleteChar
                ShortCut = 46
              end
              item
                Command = ecCut
                ShortCut = 8238
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
                Command = ecSelectAll
                ShortCut = 16449
              end
              item
                Command = ecCopy
                ShortCut = 16451
              end
              item
                Command = ecBlockIndent
                ShortCut = 24649
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
                Command = ecBlockUnindent
                ShortCut = 24661
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
                Command = ecTab
                ShortCut = 9
              end
              item
                Command = ecShiftTab
                ShortCut = 8201
              end
              item
                Command = ecMatchBracket
                ShortCut = 24642
              end>
            Lines.Strings = (
              '')
            ReadOnly = True
          end
        end
      end
    end
    object tsIndices: TTabSheet
      Caption = 'Индексы'
      ImageIndex = 3
      object tbIndices: TTBToolbar
        Left = 3
        Top = 3
        Width = 377
        Height = 22
        Caption = 'tbIndices'
        Images = dmImages.il16x16
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
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
      end
      object ibgrIndices: TgsIBGrid
        Left = 3
        Top = 30
        Width = 475
        Height = 305
        HelpContext = 3
        Anchors = [akLeft, akTop, akRight, akBottom]
        DataSource = dsIndices
        Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
        ReadOnly = True
        TabOrder = 0
        OnDblClick = actEditIndexExecute
        OnEnter = actSetShortCatExecute
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
        MinColWidth = 40
        ColumnEditors = <>
        Aliases = <>
        ShowTotals = False
      end
    end
    object tsConstraints: TTabSheet
      Caption = 'Ограничения'
      ImageIndex = 4
      object ibgrConstraints: TgsIBGrid
        Left = 3
        Top = 30
        Width = 475
        Height = 305
        Anchors = [akLeft, akTop, akRight, akBottom]
        DataSource = dsConstraints
        Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
        TabOrder = 0
        OnDblClick = actEditCheckExecute
        OnEnter = actSetShortCatExecute
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
        MinColWidth = 40
        ColumnEditors = <>
        Aliases = <>
        ShowTotals = False
      end
      object tbChecks: TTBToolbar
        Left = 3
        Top = 3
        Width = 464
        Height = 22
        Caption = 'tbChecks'
        Images = dmImages.il16x16
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
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
      end
    end
    object tsScript: TTabSheet
      Caption = 'Скрипт'
      ImageIndex = 5
      object smScriptText: TSynMemo
        Left = 0
        Top = 0
        Width = 481
        Height = 339
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
    Left = 379
    Top = 105
    object actNewField: TAction
      Category = 'Fields'
      Caption = 'Добавить поле'
      ImageIndex = 0
      OnExecute = actNewFieldExecute
      OnUpdate = actNewFieldUpdate
    end
    object actEditField: TAction
      Category = 'Fields'
      Caption = 'Редактировать поле'
      Hint = 'Редактировать поле'
      ImageIndex = 1
      OnExecute = actEditFieldExecute
      OnUpdate = actEditFieldUpdate
    end
    object actDeleteField: TAction
      Category = 'Fields'
      Caption = 'Удалить поле'
      Hint = 'Удалить поле'
      ImageIndex = 2
      ShortCut = 16430
      OnExecute = actDeleteFieldExecute
      OnUpdate = actDeleteFieldUpdate
    end
    object actNewTrigger: TAction
      Category = 'Triggers'
      Caption = 'Добавить'
      OnExecute = actNewTriggerExecute
      OnUpdate = actNewTriggerUpdate
    end
    object actEditTrigger: TAction
      Category = 'Triggers'
      Caption = 'Изменить'
      OnExecute = actEditTriggerExecute
      OnUpdate = actEditTriggerUpdate
    end
    object actDeleteTrigger: TAction
      Category = 'Triggers'
      Caption = 'Удалить'
      OnExecute = actDeleteTriggerExecute
      OnUpdate = actDeleteTriggerUpdate
    end
    object actNewIndex: TAction
      Category = 'Indices'
      Caption = 'Добавить индекс'
      Hint = 'Добавить'
      ImageIndex = 0
      OnExecute = actNewIndexExecute
      OnUpdate = actNewIndexUpdate
    end
    object actEditIndex: TAction
      Category = 'Indices'
      Caption = 'Редактировать индекс'
      Hint = 'Изменить'
      ImageIndex = 1
      OnExecute = actEditIndexExecute
      OnUpdate = actEditIndexUpdate
    end
    object actDeleteIndex: TAction
      Category = 'Indices'
      Caption = 'Удалить индекс'
      Hint = 'Удалить'
      ImageIndex = 2
      OnExecute = actDeleteIndexExecute
      OnUpdate = actDeleteIndexUpdate
    end
    object actSetShortCat: TAction
      Caption = 'Установка горячих главиш'
      OnExecute = actSetShortCatExecute
    end
    object actNewCheck: TAction
      Category = 'Checks'
      Caption = 'Добавить ограничение'
      Hint = 'Добавить'
      ImageIndex = 0
      OnExecute = actNewCheckExecute
    end
    object actEditCheck: TAction
      Category = 'Checks'
      Caption = 'Редактировать ограничение'
      Hint = 'Изменить'
      ImageIndex = 1
      OnExecute = actEditCheckExecute
    end
    object actDeleteCheck: TAction
      Category = 'Checks'
      Caption = 'Удалить ограничение'
      Hint = 'Удалить'
      ImageIndex = 2
      OnExecute = actDeleteCheckExecute
      OnUpdate = actDeleteCheckUpdate
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 350
    Top = 105
  end
  object dsRelationFields: TDataSource
    Left = 350
    Top = 134
  end
  object SynSQLSyn: TSynSQLSyn
    DefaultFilter = 'SQL files (*.sql)|*.sql'
    CommentAttri.Foreground = clBlue
    SQLDialect = sqlInterbase6
    Left = 116
    Top = 208
  end
  object dsIndices: TDataSource
    DataSet = gdcIndex
    Left = 348
    Top = 168
  end
  object gdcIndex: TgdcIndex
    MasterSource = dsgdcBase
    MasterField = 'id'
    DetailField = 'relationkey'
    SubSet = 'ByRelation'
    Left = 379
    Top = 134
  end
  object gdcTrigger: TgdcTrigger
    AfterInsert = gdcTriggerAfterInsert
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
    AutoStopAction = saNone
    Left = 268
    Top = 168
  end
  object dsConstraints: TDataSource
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
end
