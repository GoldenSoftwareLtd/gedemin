inherited gdc_dlgFunction: Tgdc_dlgFunction
  Left = 779
  Top = 304
  Width = 647
  Height = 534
  BorderStyle = bsSizeable
  Caption = 'Редактирование функции'
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 5
    Top = 468
    Anchors = [akLeft, akBottom]
    TabOrder = 3
  end
  inherited btnNew: TButton
    Left = 77
    Top = 468
    Anchors = [akLeft, akBottom]
    TabOrder = 4
  end
  inherited btnHelp: TButton
    Left = 149
    Top = 468
    Anchors = [akLeft, akBottom]
    TabOrder = 5
  end
  inherited btnOK: TButton
    Left = 483
    Top = 468
    Anchors = [akRight, akBottom]
    Default = False
    TabOrder = 1
  end
  inherited btnCancel: TButton
    Left = 555
    Top = 468
    Anchors = [akRight, akBottom]
    TabOrder = 2
  end
  object pnlParam: TPanel [5]
    Left = 0
    Top = 0
    Width = 631
    Height = 464
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 0
    object pcFunction: TSuperPageControl
      Left = 4
      Top = 31
      Width = 623
      Height = 429
      BorderStyle = bsNone
      TabsVisible = True
      ActivePage = tsFuncMain
      Align = alClient
      HotTrack = True
      Style = tsFlatButtons
      TabHeight = 23
      TabOrder = 0
      OnChange = pcFunctionChange
      OnChanging = pcFunctionChanging
      object tsFuncMain: TSuperTabSheet
        Caption = 'Свойства'
        object Label1: TLabel
          Left = 8
          Top = 172
          Width = 90
          Height = 13
          Caption = 'Модуль функции:'
        end
        object Label12: TLabel
          Left = 8
          Top = 149
          Width = 74
          Height = 13
          Caption = 'Язык скрипта:'
        end
        object Label11: TLabel
          Left = 8
          Top = 76
          Width = 71
          Height = 13
          Caption = 'Комментарий:'
        end
        object Label6: TLabel
          Left = 8
          Top = 36
          Width = 124
          Height = 13
          Caption = 'Наименование функции:'
        end
        object dbtFunctionID: TDBText
          Left = 160
          Top = 8
          Width = 209
          Height = 17
          DataField = 'ID'
          DataSource = dsgdcBase
        end
        object lFunctionID: TLabel
          Left = 8
          Top = 8
          Width = 86
          Height = 13
          Caption = 'Идентификатор:'
        end
        object lbOwner: TLabel
          Left = 8
          Top = 56
          Width = 53
          Height = 13
          Caption = 'Владелец:'
        end
        object lLabel1: TLabel
          Left = 8
          Top = 222
          Width = 46
          Height = 13
          Caption = 'Изменил:'
        end
        object lEditorName: TLabel
          Left = 160
          Top = 222
          Width = 57
          Height = 13
          Caption = 'lEditorName'
        end
        object lLabel2: TLabel
          Left = 8
          Top = 243
          Width = 86
          Height = 13
          Caption = 'Дата изменения:'
        end
        object lEditDate: TLabel
          Left = 160
          Top = 243
          Width = 43
          Height = 13
          Caption = 'lEditDate'
        end
        object lOwner: TLabel
          Left = 160
          Top = 56
          Width = 32
          Height = 13
          Caption = 'Owner'
        end
        object Label2: TLabel
          Left = 8
          Top = 195
          Width = 134
          Height = 13
          Caption = 'Локальное наименование:'
        end
        object dbcbModule: TDBComboBox
          Left = 160
          Top = 168
          Width = 461
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          DataField = 'MODULE'
          DataSource = dsgdcBase
          ItemHeight = 13
          Items.Strings = (
            'MACROS'
            'EVENTS'
            'REPORTMAIN'
            'REPORTPARAM'
            'REPORTEVENT'
            'UNKNOWN')
          TabOrder = 3
          OnDropDown = dbcbModuleDropDown
        end
        object dbcbLang: TDBComboBox
          Left = 160
          Top = 144
          Width = 461
          Height = 21
          Style = csDropDownList
          Anchors = [akLeft, akTop, akRight]
          DataField = 'LANGUAGE'
          DataSource = dsgdcBase
          Enabled = False
          ItemHeight = 13
          Items.Strings = (
            'VBScript')
          ReadOnly = True
          TabOrder = 2
          OnClick = dbcbLangChange
        end
        object DBMemo1: TDBMemo
          Left = 160
          Top = 72
          Width = 461
          Height = 69
          Anchors = [akLeft, akTop, akRight]
          Ctl3D = True
          DataField = 'COMMENT'
          DataSource = dsgdcBase
          ParentCtl3D = False
          TabOrder = 1
        end
        object dbeFunctionName: TDBEdit
          Left = 160
          Top = 32
          Width = 461
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          Color = clWhite
          DataField = 'NAME'
          DataSource = dsgdcBase
          TabOrder = 0
        end
        object DBEdit1: TDBEdit
          Left = 160
          Top = 192
          Width = 461
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          DataField = 'LocalName'
          DataSource = dsgdcBase
          TabOrder = 4
        end
      end
      object tsFuncScript: TSuperTabSheet
        Caption = 'Текст функции'
        ImageIndex = 1
        object sbCoord: TStatusBar
          Left = 0
          Top = 387
          Width = 623
          Height = 19
          Panels = <
            item
              Width = 50
            end>
          SimplePanel = False
        end
        object dbseScript: TgsFunctionSynEdit
          Left = 0
          Top = 0
          Width = 623
          Height = 387
          Cursor = crIBeam
          Align = alClient
          Ctl3D = True
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Courier New Cyr'
          Font.Style = []
          ParentColor = False
          ParentCtl3D = False
          ParentFont = False
          TabOrder = 1
          OnClick = dbseScriptClick
          OnKeyUp = dbseScriptKeyUp
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
          WantTabs = True
          OnProcessCommand = dbseScriptProcessCommand
          UseParser = False
          ShowOnlyColor = clBlack
        end
      end
      object tsParams: TSuperTabSheet
        Caption = 'Параметры'
        ImageIndex = 2
        object ScrollBox1: TScrollBox
          Left = 0
          Top = 39
          Width = 623
          Height = 367
          VertScrollBar.Style = ssFlat
          Align = alClient
          BorderStyle = bsNone
          TabOrder = 1
          object Label19: TLabel
            Left = 0
            Top = 0
            Width = 623
            Height = 367
            Align = alClient
            Alignment = taCenter
            Caption = 'Нет параметров'
            Layout = tlCenter
          end
        end
        object pnlCaption: TPanel
          Left = 0
          Top = 0
          Width = 623
          Height = 39
          Align = alTop
          BevelInner = bvRaised
          BevelOuter = bvLowered
          TabOrder = 0
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
      object tsHistory: TSuperTabSheet
        Caption = 'История'
      end
    end
    object TBDock4: TTBDock
      Left = 4
      Top = 4
      Width = 623
      Height = 27
      BoundLines = [blBottom]
      object tb: TTBToolbar
        Left = 0
        Top = 0
        BorderStyle = bsNone
        Caption = 'tb'
        DockMode = dmCannotFloatOrChangeDocks
        DockPos = 0
        FullSize = True
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        object TBItem16: TTBItem
          Action = actLoadFromFile
          Images = dmImages.il16x16
        end
        object TBItem15: TTBItem
          Action = actSaveToFile
          Images = dmImages.il16x16
        end
        object TBSeparatorItem9: TTBSeparatorItem
        end
        object TBItem14: TTBItem
          Action = actCompile
          ImageIndex = 9
          Images = dmImages.imglActions
        end
        object TBItem18: TTBItem
          Caption = 'Подготовить'
          Hint = 'Подготовить'
          ImageIndex = 15
          Images = dmImages.imglActions
          ShortCut = 16504
        end
        object TBSeparatorItem8: TTBSeparatorItem
        end
        object TBItem12: TTBItem
          Action = actFind
          Images = dmImages.il16x16
        end
        object TBItem11: TTBItem
          Action = actReplace
          Images = dmImages.il16x16
        end
        object TBSeparatorItem7: TTBSeparatorItem
        end
        object TBItem13: TTBItem
          Action = actSQLEditor
          Images = dmImages.il16x16
        end
        object TBSeparatorItem6: TTBSeparatorItem
        end
        object TBItem10: TTBItem
          Action = actCopySQL
          ImageIndex = 19
          Images = dmImages.imFunction
        end
        object TBItem9: TTBItem
          Action = actPasteSQL
          ImageIndex = 20
          Images = dmImages.imFunction
        end
        object TBSeparatorItem5: TTBSeparatorItem
        end
        object TBItem2: TTBItem
          Action = actEvaluate
          ImageIndex = 16
          Images = dmImages.imglActions
        end
        object TBSeparatorItem4: TTBSeparatorItem
        end
        object TBItem8: TTBItem
          Action = actOptions
          Images = dmImages.il16x16
        end
      end
    end
  end
  inherited alBase: TActionList
    Left = 134
    Top = 391
  end
  inherited dsgdcBase: TDataSource
    Left = 104
    Top = 391
  end
  inherited pm_dlgG: TPopupMenu
    Left = 376
    Top = 344
  end
  object SynVBScriptSyn1: TSynVBScriptSyn
    DefaultFilter = 'VBScript files (*.vbs)|*.vbs'
    CommentAttri.Foreground = clRed
    NumberAttri.Style = [fsUnderline]
    StringAttri.Foreground = clBlue
    Left = 464
    Top = 400
  end
  object SynJScriptSyn1: TSynJScriptSyn
    DefaultFilter = 'Javascript files (*.js)|*.js'
    CommentAttri.Foreground = clRed
    NumberAttri.Style = [fsUnderline]
    StringAttri.Foreground = clBlue
    Left = 496
    Top = 400
  end
  object SynCompletionProposal: TSynCompletionProposal
    DefaultType = ctCode
    OnExecute = SynCompletionProposalExecute
    Position = 0
    NbLinesInWindow = 6
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
    Editor = dbseScript
    Left = 536
    Top = 400
  end
  object ActionList1: TActionList
    Images = dmImages.il16x16
    Left = 568
    Top = 400
    object actLoadFromFile: TAction
      Caption = 'Загрузить из файла'
      Hint = 'Загрузить скрипт из файла'
      ImageIndex = 27
      OnExecute = actLoadFromFileExecute
    end
    object actSaveToFile: TAction
      Caption = 'Сохранить в файл'
      Hint = 'Сохранить скрипт в файл'
      ImageIndex = 25
      OnExecute = actSaveToFileExecute
    end
    object actCompile: TAction
      Caption = 'Запуск'
      Hint = 'Запуск'
      ShortCut = 120
      OnExecute = actCompileExecute
    end
    object actSQLEditor: TAction
      Caption = 'SQL редактор'
      Hint = 'Показать SQL редактор'
      ImageIndex = 108
      OnExecute = actSQLEditorExecute
    end
    object actFind: TAction
      Caption = 'Поиск'
      Hint = 'Найти в скрипте '
      ImageIndex = 23
      ShortCut = 16454
      OnExecute = actFindExecute
    end
    object actReplace: TAction
      Caption = 'Заменить'
      Hint = 'Заменить'
      ImageIndex = 22
      ShortCut = 16466
      OnExecute = actReplaceExecute
    end
    object actCopySQL: TAction
      Caption = 'Копировать SQL'
      Hint = 'Копировать SQL'
      ImageIndex = 10
      OnExecute = actCopySQLExecute
    end
    object actPasteSQL: TAction
      Caption = 'Вставить SQL'
      Hint = 'Вставить SQL'
      ImageIndex = 11
      OnExecute = actPasteSQLExecute
    end
    object actOptions: TAction
      Caption = 'Настроики'
      Hint = 'Свойства редактора'
      ImageIndex = 28
      OnExecute = actOptionsExecute
    end
    object actEvaluate: TAction
      Caption = 'Вычислить'
      Hint = 'Вычислить выражение'
      ShortCut = 16499
      OnExecute = actEvaluateExecute
    end
    object actFindNext: TAction
      Caption = 'Найти далее'
      ImageIndex = 24
      ShortCut = 114
      OnExecute = actFindNextExecute
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 536
    Top = 360
  end
  object SaveDialog1: TSaveDialog
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 568
    Top = 360
  end
end
