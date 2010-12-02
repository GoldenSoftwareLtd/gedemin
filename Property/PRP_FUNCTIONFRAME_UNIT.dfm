inherited FunctionFrame: TFunctionFrame
  OnResize = FrameResize
  inherited PageControl: TSuperPageControl
    OnChange = PageControlChange
    OnChanging = PageControlChanging
    inherited tsProperty: TSuperTabSheet
      inherited TBDock1: TTBDock
        Height = 28
        object TBToolbar1: TTBToolbar
          Left = 0
          Top = 0
          Caption = 'TBToolbar1'
          DockMode = dmCannotFloatOrChangeDocks
          Images = dmImages.il16x16
          ParentShowHint = False
          ShowHint = True
          Stretch = True
          TabOrder = 0
          object TBItem1: TTBItem
            Action = actProperty
          end
          object tbiWizard: TTBItem
            Action = actWizard
          end
        end
      end
      inherited pMain: TPanel
        Top = 28
        Height = 211
        OnResize = pMainResize
        inherited lbDescription: TLabel
          Top = 80
        end
        object lbOwner: TLabel [2]
          Left = 8
          Top = 36
          Width = 53
          Height = 13
          Caption = 'Владелец:'
        end
        object lbLanguage: TLabel [3]
          Left = 8
          Top = 156
          Width = 74
          Height = 13
          Caption = 'Язык скрипта:'
        end
        object lLocalName: TLabel [4]
          Left = 8
          Top = 180
          Width = 134
          Height = 13
          Caption = 'Локальное наименование:'
        end
        object lblRUIDFunction: TLabel [5]
          Left = 8
          Top = 60
          Width = 76
          Height = 13
          Caption = 'RUID функции:'
        end
        object edtRUIDFunction: TEdit [6]
          Left = 144
          Top = 56
          Width = 215
          Height = 21
          TabStop = False
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 2
        end
        inherited dbeName: TprpDBComboBox
          Width = 292
        end
        inherited dbmDescription: TDBMemo
          Top = 80
          Width = 292
          TabOrder = 4
        end
        object dbcbLang: TDBComboBox
          Left = 144
          Top = 152
          Width = 292
          Height = 21
          Hint = 'Язык скрипта'
          Style = csDropDownList
          Anchors = [akLeft, akTop, akRight]
          DataField = 'LANGUAGE'
          DataSource = DataSource
          Enabled = False
          ItemHeight = 13
          Items.Strings = (
            'JScript'
            'VBScript')
          ParentShowHint = False
          PopupMenu = PopupMenu
          ShowHint = True
          TabOrder = 5
        end
        object dbtOwner: TDBEdit
          Left = 144
          Top = 32
          Width = 291
          Height = 21
          Hint = 'Владелец функции'
          TabStop = False
          Anchors = [akLeft, akTop, akRight]
          Color = clBtnFace
          DataField = 'Name'
          DataSource = dsDelpthiObject
          ParentShowHint = False
          PopupMenu = PopupMenu
          ReadOnly = True
          ShowHint = True
          TabOrder = 1
        end
        object dbeLocalName: TDBEdit
          Left = 144
          Top = 176
          Width = 292
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          DataField = 'LocalName'
          DataSource = DataSource
          TabOrder = 6
        end
        object pnlRUIDFunction: TPanel
          Left = 361
          Top = 56
          Width = 75
          Height = 21
          Anchors = [akTop, akRight]
          BevelOuter = bvLowered
          TabOrder = 3
          object btnCopyRUIDFunction: TButton
            Left = 1
            Top = 1
            Width = 73
            Height = 19
            Caption = 'Копировать'
            TabOrder = 0
            OnClick = btnCopyRUIDFunctionClick
          end
        end
      end
    end
    object tsScript: TSuperTabSheet
      BorderWidth = 2
      Caption = 'Скрипт'
      ImageIndex = 1
      object gsFunctionSynEdit: TgsFunctionSynEdit
        Left = 0
        Top = 0
        Width = 431
        Height = 239
        Cursor = crIBeam
        HelpContext = 318
        gdcFunction = gdcFunction
        OnPaintGutter = gsFunctionSynEditPaintGutter
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        ParentShowHint = False
        PopupMenu = PopupMenu
        ShowHint = True
        TabOrder = 0
        BookMarkOptions.BookmarkImages = dmImages.imSynEdit
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -11
        Gutter.Font.Name = 'Terminal'
        Gutter.Font.Style = []
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
        WantTabs = True
        OnCommandProcessed = gsFunctionSynEditCommandProcessed
        OnGutterClick = gsFunctionSynEditGutterClick
        OnPlaceBookmark = gsFunctionSynEditPlaceBookmark
        OnProcessCommand = gsFunctionSynEditProcessCommand
        OnProcessUserCommand = gsFunctionSynEditProcessUserCommand
        OnReplaceText = gsFunctionSynEditReplaceText
        OnSpecialLineColors = gsFunctionSynEditSpecialLineColors
        UseParser = False
        ShowOnlyColor = clBlack
      end
    end
    object tsParams: TSuperTabSheet
      BorderWidth = 2
      Caption = 'Параметры'
      ImageIndex = 2
      object ScrollBox: TScrollBox
        Left = 0
        Top = 36
        Width = 431
        Height = 203
        VertScrollBar.Style = ssFlat
        Align = alClient
        BorderStyle = bsNone
        TabOrder = 0
        object Label19: TLabel
          Left = 0
          Top = 0
          Width = 82
          Height = 13
          Align = alClient
          Alignment = taCenter
          Caption = 'Нет параметров'
          Layout = tlCenter
        end
      end
      object pnlCaption: TPanel
        Left = 0
        Top = 0
        Width = 431
        Height = 36
        Align = alTop
        BevelInner = bvLowered
        BevelOuter = bvNone
        Color = clBtnHighlight
        TabOrder = 1
        object Label13: TLabel
          Left = 8
          Top = 4
          Width = 49
          Height = 13
          Caption = 'Параметр'
        end
        object Label14: TLabel
          Left = 8
          Top = 20
          Width = 66
          Height = 13
          Caption = 'Имя таблицы'
        end
        object Label15: TLabel
          Left = 160
          Top = 4
          Width = 73
          Height = 13
          Caption = 'Наименование'
        end
        object Label16: TLabel
          Left = 160
          Top = 20
          Width = 72
          Height = 13
          Caption = 'Поле таблицы'
        end
        object Label17: TLabel
          Left = 312
          Top = 4
          Width = 75
          Height = 13
          Caption = 'Тип параметра'
        end
        object Label18: TLabel
          Left = 312
          Top = 20
          Width = 75
          Height = 13
          Caption = 'Ключ таблицы'
        end
      end
    end
    object tsDependencies: TSuperTabSheet
      Caption = 'Зависимость'
      object Splitter1: TSplitter
        Left = 217
        Top = 0
        Width = 3
        Height = 243
        Cursor = crHSplit
      end
      object pnlDependent: TPanel
        Left = 0
        Top = 0
        Width = 217
        Height = 243
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 0
        object Panel3: TPanel
          Left = 0
          Top = 0
          Width = 217
          Height = 17
          Align = alTop
          Alignment = taLeftJustify
          BevelOuter = bvNone
          Caption = ' От данной функции зависят:'
          Color = clInactiveCaption
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clCaptionText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
        end
        object lbDependent: TListBox
          Left = 0
          Top = 17
          Width = 217
          Height = 226
          Align = alClient
          ItemHeight = 13
          PopupMenu = pmDependent
          TabOrder = 1
          OnDblClick = lbDependentDblClick
        end
      end
      object pnlDependedFrom: TPanel
        Left = 220
        Top = 0
        Width = 215
        Height = 243
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 1
        object Panel4: TPanel
          Left = 0
          Top = 0
          Width = 215
          Height = 17
          Align = alTop
          Alignment = taLeftJustify
          BevelOuter = bvNone
          Caption = ' Данная функция зависит от:'
          Color = clInactiveCaption
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clCaptionText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
        end
        object lbDependedFrom: TListBox
          Left = 0
          Top = 17
          Width = 215
          Height = 226
          Align = alClient
          ItemHeight = 13
          PopupMenu = pmDependedFrom
          TabOrder = 1
          OnDblClick = lbDependedFromDblClick
        end
      end
    end
    object tsHistory: TSuperTabSheet
      Caption = 'История'
    end
  end
  inherited DataSource: TDataSource
    DataSet = gdcFunction
    Left = 304
    Top = 8
  end
  inherited PopupMenu: TPopupMenu
    Images = dmImages.il16x16
    OnPopup = PopupMenuPopup
    Left = 304
    object miEnableBreakPoint: TMenuItem [0]
      Action = actEnableBreakPoint
      Visible = False
    end
    object miPropertyBreakPoint: TMenuItem [1]
      Action = actPropertyBreakPoint
      Visible = False
    end
    object miSeparator: TMenuItem [2]
      Caption = '-'
      Visible = False
    end
    object miS2: TMenuItem
      Caption = '-'
    end
    object miFind: TMenuItem
      Action = actFind
    end
    object miReplace: TMenuItem
      Action = actReplace
    end
    object miS3: TMenuItem
      Caption = '-'
    end
    object miRun: TMenuItem
      Action = actRun
    end
    object miPrepare: TMenuItem
      Action = actPrepare
    end
    object miS4: TMenuItem
      Caption = '-'
    end
    object miCopy: TMenuItem
      Action = actCopy
    end
    object miCut: TMenuItem
      Action = actCut
    end
    object miPaste: TMenuItem
      Action = actPaste
    end
    object miS5: TMenuItem
      Caption = '-'
    end
    object miCopyToRTF: TMenuItem
      Action = actCopyToRTF
    end
    object miS6: TMenuItem
      Caption = '-'
    end
    object miCopySQL: TMenuItem
      Action = actCopySQL
    end
    object miPasteSQL: TMenuItem
      Action = actPasteSQL
    end
    object miS7: TMenuItem
      Caption = '-'
    end
    object miComment: TMenuItem
      Action = actComment
    end
    object miUnComment: TMenuItem
      Action = actUnComment
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object N2: TMenuItem
      Action = actProperty
    end
    object TypeInfo1: TMenuItem
      Action = actTypeInfo
    end
    object N3: TMenuItem
      Action = actUpperCase
    end
    object N4: TMenuItem
      Action = actLowerCase
    end
  end
  inherited ActionList1: TActionList
    Left = 368
    Top = 8
    object actFind: TAction [3]
      Caption = 'Поиск'
      ImageIndex = 23
      OnExecute = actFindExecute
    end
    object actReplace: TAction [4]
      Caption = 'Замена'
      ImageIndex = 22
      OnExecute = actReplaceExecute
    end
    object actRun: TAction [5]
      Caption = 'Запуск'
      OnExecute = actRunExecute
      OnUpdate = actRunUpdate
    end
    object actPrepare: TAction [6]
      Caption = 'Проверка синтаксиса'
      Hint = 'Проверка синтаксиса'
      OnExecute = actPrepareExecute
      OnUpdate = actPrepareUpdate
    end
    object actCopy: TAction [7]
      Caption = 'Копировать'
      ImageIndex = 10
      OnExecute = actCopyExecute
      OnUpdate = actCopyUpdate
    end
    object actCut: TAction [8]
      Caption = 'Вырезать'
      ImageIndex = 9
      OnExecute = actCutExecute
      OnUpdate = actCutUpdate
    end
    object actPaste: TAction [9]
      Caption = 'Вставить'
      ImageIndex = 11
      OnExecute = actPasteExecute
      OnUpdate = actPasteUpdate
    end
    object actCopySQL: TAction [10]
      Caption = 'Копировать SQL'
      OnExecute = actCopySQLExecute
      OnUpdate = actCopySQLUpdate
    end
    object actPasteSQL: TAction [11]
      Caption = 'Вставить SQL'
      OnExecute = actPasteSQLExecute
      OnUpdate = actPasteSQLUpdate
    end
    object actComment: TAction [12]
      Caption = 'Закомментировать'
      ImageIndex = 51
      OnExecute = actCommentExecute
    end
    object actUnComment: TAction [13]
      Caption = 'Откомментировать'
      ImageIndex = 52
      OnExecute = actUnCommentExecute
    end
    object actCopyToRTF: TAction [14]
      Caption = 'Копировать в RTF'
      OnExecute = actCopyToRTFExecute
      OnUpdate = actCopyUpdate
    end
    object actEnableBreakPoint: TAction [21]
      Caption = 'Подключить точку останова'
      OnExecute = actEnableBreakPointExecute
      OnUpdate = actEnableBreakPointUpdate
    end
    object actPropertyBreakPoint: TAction [22]
      Caption = 'Свойства точки останова'
      OnExecute = actPropertyBreakPointExecute
      OnUpdate = actPropertyBreakPointUpdate
    end
    object actRefreshDependent: TAction
      Caption = 'Обновить'
      Hint = 'Обновить'
      ShortCut = 116
      OnExecute = actRefreshDependentExecute
    end
    object actRefreshDependedFrom: TAction
      Caption = 'Обновить'
      Hint = 'Обновить'
      ShortCut = 116
      OnExecute = actRefreshDependedFromExecute
    end
    object actTypeInfo: TAction
      Caption = 'Информация о типе'
      OnExecute = actTypeInfoExecute
    end
    object actWizard: TAction
      Caption = 'actWizard'
      Hint = 'Открыть конструктор функции'
      ImageIndex = 236
      OnExecute = actWizardExecute
      OnUpdate = actWizardUpdate
    end
    object actUpperCase: TAction
      Caption = 'В верхний регистр'
      OnExecute = actUpperCaseExecute
    end
    object actLowerCase: TAction
      Caption = 'В нижний регистр'
      OnExecute = actLowerCaseExecute
    end
  end
  object gdcFunction: TgdcFunction
    AfterDelete = gdcFunctionAfterDelete
    AfterEdit = gdcFunctionAfterEdit
    AfterInsert = gdcFunctionAfterInsert
    AfterOpen = gdcFunctionAfterOpen
    AfterPost = gdcFunctionAfterPost
    SubSet = 'ByID'
    Left = 336
    Top = 8
  end
  object gdcDelphiObject: TgdcDelphiObject
    AfterScroll = gdcDelphiObjectAfterScroll
    MasterSource = DataSource
    MasterField = 'MODULECODE'
    DetailField = 'ID'
    SubSet = 'ByID'
    ObjectType = otObject
    Left = 336
    Top = 40
  end
  object dsDelpthiObject: TDataSource
    DataSet = gdcDelphiObject
    Left = 304
    Top = 40
  end
  object SynCompletionProposal: TSynCompletionProposal
    DefaultType = ctCode
    OnExecute = SynCompletionProposalExecute
    Position = 0
    NbLinesInWindow = 8
    ClSelect = clHighlight
    ClText = clWindowText
    ClSelectedText = clHighlightText
    ClBackground = clWindow
    AnsiStrings = True
    CaseSensitive = False
    ShrinkList = True
    Width = 262
    BiggestWord = 'property'
    UsePrettyText = True
    UseInsertList = True
    EndOfTokenChr = '()[].,=<>-+&"'
    LimitToMatchedText = False
    TriggerChars = '.'
    ShortCut = 16416
    Editor = gsFunctionSynEdit
    Left = 336
    Top = 80
  end
  object ReplaceDialog: TReplaceDialog
    OnReplace = ReplaceDialogReplace
    Left = 336
    Top = 144
  end
  object OpenDialog: TOpenDialog
    Left = 304
    Top = 112
  end
  object SaveDialog: TSaveDialog
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 336
    Top = 112
  end
  object SynExporterRTF1: TSynExporterRTF
    Color = clWindow
    DefaultFilter = 'Rich Text Format (*.rtf)|*.rtf'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    Title = 'Untitled'
    UseBackground = False
    Left = 304
    Top = 144
  end
  object pmDependent: TPopupMenu
    Left = 108
    Top = 160
    object pmiRefreshDependent: TMenuItem
      Action = actRefreshDependent
    end
  end
  object pmDependedFrom: TPopupMenu
    Left = 77
    Top = 160
    object pmiRefreshDependedFrom: TMenuItem
      Action = actRefreshDependedFrom
    end
  end
end
