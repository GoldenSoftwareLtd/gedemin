object dlgOptionsManager: TdlgOptionsManager
  Left = 295
  Top = 171
  HelpContext = 319
  BorderStyle = bsDialog
  BorderWidth = 5
  Caption = 'Установки редактора'
  ClientHeight = 371
  ClientWidth = 438
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 344
    Width = 438
    Height = 27
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnOK: TButton
      Left = 288
      Top = 5
      Width = 72
      Height = 21
      Anchors = [akRight, akBottom]
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 1
    end
    object btnCancel: TButton
      Left = 364
      Top = 5
      Width = 72
      Height = 21
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 2
    end
    object btnFont: TButton
      Left = 2
      Top = 5
      Width = 72
      Height = 21
      Caption = 'Шрифт'
      TabOrder = 0
      OnClick = btnFontClick
    end
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 438
    Height = 344
    ActivePage = tsGeneral
    Align = alClient
    TabHeight = 22
    TabOrder = 0
    object tsGeneral: TTabSheet
      BorderWidth = 7
      Caption = 'Общие'
      object Label1: TLabel
        Left = 0
        Top = 184
        Width = 159
        Height = 13
        Caption = 'Быстрая настройка редактора:'
        Layout = tlCenter
      end
      object Label3: TLabel
        Left = 31
        Top = 216
        Width = 119
        Height = 13
        Caption = 'Размер буфера отката:'
        Layout = tlCenter
      end
      object Label4: TLabel
        Left = 52
        Top = 248
        Width = 102
        Height = 13
        Caption = 'Позиция табуляции:'
        Layout = tlCenter
      end
      object GroupBox1: TGroupBox
        Left = 0
        Top = 0
        Width = 416
        Height = 105
        Align = alTop
        Caption = 'Опции редактора'
        TabOrder = 0
        object cbAutoIndentMode: TCheckBox
          Left = 8
          Top = 16
          Width = 209
          Height = 17
          Caption = 'Режим автоматического отступа'
          TabOrder = 0
        end
        object cbInsertMode: TCheckBox
          Left = 8
          Top = 32
          Width = 177
          Height = 17
          Caption = 'Режим вставки'
          TabOrder = 1
        end
        object cbSmartTab: TCheckBox
          Left = 8
          Top = 48
          Width = 177
          Height = 17
          Caption = 'Интеллектуальная табуляция'
          TabOrder = 2
        end
        object cbGroupUndo: TCheckBox
          Left = 8
          Top = 80
          Width = 177
          Height = 17
          Caption = 'Групповой откат'
          TabOrder = 4
        end
        object cbCursorBeyondEOF: TCheckBox
          Left = 232
          Top = 16
          Width = 177
          Height = 17
          Caption = 'Курсор за пределами EOF'
          TabOrder = 5
        end
        object cbUndoAfterSave: TCheckBox
          Left = 232
          Top = 32
          Width = 177
          Height = 17
          Caption = 'Откат после сохранения'
          TabOrder = 6
        end
        object cbKeepTrailingBlanks: TCheckBox
          Left = 232
          Top = 48
          Width = 177
          Height = 17
          Caption = 'Отслеживать пустые пробелы'
          TabOrder = 7
        end
        object cbFindTextAtCursor: TCheckBox
          Left = 232
          Top = 64
          Width = 177
          Height = 17
          Caption = 'Поиск текста от курсора'
          TabOrder = 8
        end
        object cbUseSyntaxHighLight: TCheckBox
          Left = 232
          Top = 80
          Width = 177
          Height = 17
          Caption = 'Подсветка синтаксиса'
          TabOrder = 9
        end
        object cbTabToSpaces: TCheckBox
          Left = 8
          Top = 64
          Width = 177
          Height = 17
          Caption = 'Замена табуляции на пробелы'
          TabOrder = 3
        end
      end
      object cbEditorSpeedSettings: TComboBox
        Left = 160
        Top = 184
        Width = 257
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 2
        OnChange = cbEditorSpeedSettingsChange
        Items.Strings = (
          'Default'
          'Classic')
      end
      object cbUndoLimit: TComboBox
        Left = 160
        Top = 216
        Width = 257
        Height = 21
        ItemHeight = 13
        TabOrder = 3
        Text = '1024'
      end
      object cbTabStops: TComboBox
        Left = 160
        Top = 248
        Width = 257
        Height = 21
        ItemHeight = 13
        TabOrder = 4
        Text = '8'
      end
      object GroupBox2: TGroupBox
        Left = 0
        Top = 112
        Width = 416
        Height = 65
        Caption = 'Граница и гуттер'
        TabOrder = 1
        object Label6: TLabel
          Left = 152
          Top = 16
          Width = 45
          Height = 13
          Caption = 'Граница:'
        end
        object Label7: TLabel
          Left = 288
          Top = 16
          Width = 121
          Height = 13
          Caption = 'Ширина левой границы:'
        end
        object cbVisibleRightMargine: TCheckBox
          Left = 8
          Top = 24
          Width = 129
          Height = 17
          Caption = 'Показывать границу'
          TabOrder = 0
        end
        object cbVisibleGutter: TCheckBox
          Left = 8
          Top = 40
          Width = 129
          Height = 17
          Caption = 'Показывать гуттер'
          TabOrder = 1
        end
        object cbRightMargin: TComboBox
          Left = 152
          Top = 32
          Width = 129
          Height = 21
          ItemHeight = 13
          TabOrder = 2
          Text = '80'
        end
        object cbGutterWidth: TComboBox
          Left = 288
          Top = 32
          Width = 121
          Height = 21
          ItemHeight = 13
          TabOrder = 3
          Text = '30'
        end
      end
    end
    object tsKeyMappings: TTabSheet
      BorderWidth = 7
      Caption = 'Назначение клавиш'
      ImageIndex = 1
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 416
        Height = 169
        Align = alTop
        BevelOuter = bvLowered
        TabOrder = 0
        object Label5: TLabel
          Left = 8
          Top = 8
          Width = 118
          Height = 13
          Caption = 'Раскладки клавиатуры'
        end
        object lbKeyMapping: TListBox
          Left = 8
          Top = 24
          Width = 398
          Height = 129
          Anchors = [akLeft, akTop, akRight, akBottom]
          ItemHeight = 13
          Items.Strings = (
            'Default'
            'Classic')
          TabOrder = 0
          OnClick = lbKeyMappingClick
        end
      end
      object Button1: TButton
        Left = 312
        Top = 176
        Width = 99
        Height = 21
        Action = actEditKeystrokes
        TabOrder = 2
      end
      object Button2: TButton
        Left = 176
        Top = 176
        Width = 131
        Height = 21
        Action = actResetKeystrokes
        TabOrder = 1
      end
    end
    object tsColors: TTabSheet
      BorderWidth = 7
      Caption = 'Цвета'
      ImageIndex = 2
      object pnlTop: TPanel
        Left = 0
        Top = 0
        Width = 416
        Height = 149
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object cbLanguages: TComboBox
          Left = 0
          Top = 7
          Width = 145
          Height = 21
          ItemHeight = 13
          TabOrder = 0
          OnChange = cbLanguagesChange
          Items.Strings = (
            'VB Script'
            'Java Script'
            'SQL Script')
        end
        object lbAttributes: TListBox
          Left = 0
          Top = 30
          Width = 145
          Height = 114
          ItemHeight = 13
          TabOrder = 1
          OnClick = lbAttributesClick
        end
        object ColorGrid: TColorGrid
          Left = 150
          Top = 7
          Width = 136
          Height = 136
          ForegroundEnabled = False
          BackgroundEnabled = False
          TabOrder = 2
          OnChange = ColorGridChange
        end
        object gbTextAttr: TGroupBox
          Left = 290
          Top = 7
          Width = 126
          Height = 78
          Caption = 'Текстовые атрибуты'
          TabOrder = 3
          object cbBold: TCheckBox
            Left = 7
            Top = 20
            Width = 78
            Height = 13
            Caption = 'Жирный'
            TabOrder = 0
            OnClick = cbBoldClick
          end
          object cbItalic: TCheckBox
            Left = 7
            Top = 33
            Width = 78
            Height = 13
            Caption = 'Курсив'
            TabOrder = 1
            OnClick = cbItalicClick
          end
          object cbUnderLine: TCheckBox
            Left = 7
            Top = 46
            Width = 111
            Height = 13
            Caption = 'Подчеркнутый'
            TabOrder = 2
            OnClick = cbUnderLineClick
          end
          object cbStrikeOut: TCheckBox
            Left = 7
            Top = 59
            Width = 111
            Height = 13
            Caption = 'Перечеркнутый'
            TabOrder = 3
            OnClick = cbStrikeOutClick
          end
        end
        object gbNoneGround: TGroupBox
          Left = 290
          Top = 91
          Width = 126
          Height = 53
          Caption = 'По умолчанию'
          TabOrder = 4
          object cbFont: TCheckBox
            Left = 7
            Top = 20
            Width = 78
            Height = 13
            Caption = 'Шрифт'
            TabOrder = 0
            OnClick = cbFontClick
          end
          object cbBack: TCheckBox
            Left = 7
            Top = 33
            Width = 78
            Height = 13
            Caption = 'Фон'
            TabOrder = 1
            OnClick = cbBackClick
          end
        end
      end
      object seTestScript: TSynEdit
        Left = 0
        Top = 149
        Width = 416
        Height = 149
        Cursor = crIBeam
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Courier New'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        TabOrder = 1
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -13
        Gutter.Font.Name = 'Terminal'
        Gutter.Font.Style = []
        Highlighter = SynVBScriptSyn1
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
        Options = [eoAutoIndent, eoDragDropEditing, eoNoCaret, eoShowScrollHint, eoSmartTabs, eoTabsToSpaces, eoTrimTrailingSpaces, eoSmartTabDelete, eoGroupUndo]
        ReadOnly = True
        OnSpecialLineColors = seTestScriptSpecialLineColors
      end
    end
  end
  object SynJScriptSyn1: TSynJScriptSyn
    DefaultFilter = 'Javascript files (*.js)|*.js'
    Left = 200
    Top = 344
  end
  object SynVBScriptSyn1: TSynVBScriptSyn
    DefaultFilter = 'VBScript files (*.vbs)|*.vbs'
    CommentAttri.Foreground = clRed
    NumberAttri.Style = [fsUnderline]
    SpaceAttri.Background = clAqua
    SpaceAttri.Foreground = clFuchsia
    StringAttri.Foreground = clBlue
    Left = 232
    Top = 344
  end
  object SynSQLSyn1: TSynSQLSyn
    DefaultFilter = 'SQL files (*.sql)|*.sql'
    SQLDialect = sqlSybase
    Left = 264
    Top = 344
  end
  object FontDialog1: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    MinFontSize = 0
    MaxFontSize = 0
    Left = 168
    Top = 344
  end
  object Default: TgsKeyStrokes
    KeyStrokes = <
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
        Command = ecTab
        ShortCut = 16457
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
      end
      item
        Command = ecFind
        ShortCut = 16454
      end
      item
        Command = ecReplace
        ShortCut = 16466
      end
      item
        Command = ecDeleteItem
        ShortCut = 16430
      end
      item
        Command = ecCommit
        ShortCut = 16467
      end
      item
        Command = ecDebugRun
        ShortCut = 120
      end
      item
        Command = ecDebugstepIn
        ShortCut = 118
      end
      item
        Command = ecDebugStepOut
        ShortCut = 119
      end
      item
        Command = ecDebugGotoCursor
        ShortCut = 115
      end
      item
        Command = ecProgramReset
        ShortCut = 16497
      end
      item
        Command = ecToggleBreakPoint
        ShortCut = 116
      end
      item
        Command = ecPrepare
        ShortCut = 16504
      end
      item
        Command = ecDebugStepOut
        ShortCut = 8310
      end
      item
        Command = ecSetMarker0
        ShortCut = 16459
        ShortCut2 = 16432
      end
      item
        Command = ecSetMarker1
        ShortCut = 16459
        ShortCut2 = 16433
      end
      item
        Command = ecSetMarker2
        ShortCut = 16459
        ShortCut2 = 16434
      end
      item
        Command = ecSetMarker3
        ShortCut = 16459
        ShortCut2 = 16435
      end
      item
        Command = ecSetMarker4
        ShortCut = 16459
        ShortCut2 = 16436
      end
      item
        Command = ecSetMarker5
        ShortCut = 16459
        ShortCut2 = 16437
      end
      item
        Command = ecSetMarker6
        ShortCut = 16459
        ShortCut2 = 16438
      end
      item
        Command = ecSetMarker7
        ShortCut = 16459
        ShortCut2 = 16439
      end
      item
        Command = ecSetMarker8
        ShortCut = 16459
        ShortCut2 = 16440
      end
      item
        Command = ecSetMarker9
        ShortCut = 16459
        ShortCut2 = 16441
      end
      item
        Command = ecSetMarker0
        ShortCut = 16459
        ShortCut2 = 48
      end
      item
        Command = ecSetMarker1
        ShortCut = 16459
        ShortCut2 = 49
      end
      item
        Command = ecSetMarker2
        ShortCut = 16459
        ShortCut2 = 50
      end
      item
        Command = ecSetMarker3
        ShortCut = 16459
        ShortCut2 = 51
      end
      item
        Command = ecSetMarker4
        ShortCut = 16459
        ShortCut2 = 52
      end
      item
        Command = ecSetMarker5
        ShortCut = 16459
        ShortCut2 = 53
      end
      item
        Command = ecSetMarker6
        ShortCut = 16459
        ShortCut2 = 54
      end
      item
        Command = ecSetMarker7
        ShortCut = 16459
        ShortCut2 = 55
      end
      item
        Command = ecSetMarker8
        ShortCut = 16459
        ShortCut2 = 56
      end
      item
        Command = ecSetMarker9
        ShortCut = 16459
        ShortCut2 = 57
      end
      item
        Command = ecGotoMarker0
        ShortCut = 16465
        ShortCut2 = 48
      end
      item
        Command = ecGotoMarker1
        ShortCut = 16465
        ShortCut2 = 49
      end
      item
        Command = ecGotoMarker2
        ShortCut = 16465
        ShortCut2 = 50
      end
      item
        Command = ecGotoMarker3
        ShortCut = 16465
        ShortCut2 = 51
      end
      item
        Command = ecGotoMarker4
        ShortCut = 16465
        ShortCut2 = 52
      end
      item
        Command = ecGotoMarker5
        ShortCut = 16465
        ShortCut2 = 53
      end
      item
        Command = ecGotoMarker6
        ShortCut = 16465
        ShortCut2 = 54
      end
      item
        Command = ecGotoMarker7
        ShortCut = 16465
        ShortCut2 = 55
      end
      item
        Command = ecGotoMarker8
        ShortCut = 16465
        ShortCut2 = 56
      end
      item
        Command = ecGotoMarker9
        ShortCut = 16465
        ShortCut2 = 57
      end
      item
        Command = ecGotoMarker0
        ShortCut = 16465
        ShortCut2 = 16432
      end
      item
        Command = ecGotoMarker1
        ShortCut = 16465
        ShortCut2 = 16433
      end
      item
        Command = ecGotoMarker2
        ShortCut = 16465
        ShortCut2 = 16434
      end
      item
        Command = ecGotoMarker3
        ShortCut = 16465
        ShortCut2 = 16435
      end
      item
        Command = ecGotoMarker4
        ShortCut = 16465
        ShortCut2 = 16436
      end
      item
        Command = ecGotoMarker5
        ShortCut = 16465
        ShortCut2 = 16437
      end
      item
        Command = ecGotoMarker6
        ShortCut = 16465
        ShortCut2 = 16438
      end
      item
        Command = ecGotoMarker7
        ShortCut = 16465
        ShortCut2 = 16439
      end
      item
        Command = ecGotoMarker8
        ShortCut = 16465
        ShortCut2 = 16440
      end
      item
        Command = ecGotoMarker9
        ShortCut = 16465
        ShortCut2 = 16441
      end
      item
        Command = ecAddWatch
        ShortCut = 16500
      end>
    Left = 8
    Top = 301
  end
  object Classic: TgsKeyStrokes
    KeyStrokes = <
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
      end
      item
        Command = ecAddWatch
        ShortCut = 16502
      end>
    Left = 40
    Top = 301
  end
  object NewClassic: TgsKeyStrokes
    KeyStrokes = <
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
    Left = 72
    Top = 301
  end
  object ActionList: TActionList
    Left = 139
    Top = 303
    object actEditKeystrokes: TAction
      Caption = 'Редактировать'
      OnExecute = actEditKeystrokesExecute
      OnUpdate = actEditKeystrokesUpdate
    end
    object actResetKeystrokes: TAction
      Caption = 'Сбросить по умолчанию'
      OnExecute = actResetKeystrokesExecute
      OnUpdate = actEditKeystrokesUpdate
    end
  end
  object VisualStudio: TgsKeyStrokes
    KeyStrokes = <
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
    Left = 104
    Top = 301
  end
end
