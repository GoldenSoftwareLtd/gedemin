inherited gdc_dlgFunction: Tgdc_dlgFunction
  Left = 264
  Top = 290
  Width = 647
  Height = 529
  BorderStyle = bsSizeable
  Caption = 'Редактирование функции'
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 5
    Top = 474
    Anchors = [akLeft, akBottom]
    TabOrder = 1
  end
  inherited btnNew: TButton
    Left = 77
    Top = 474
    Anchors = [akLeft, akBottom]
    TabOrder = 2
  end
  inherited btnHelp: TButton
    Left = 149
    Top = 474
    Anchors = [akLeft, akBottom]
    TabOrder = 3
  end
  inherited btnOK: TButton
    Left = 483
    Top = 474
    Anchors = [akRight, akBottom]
    Default = False
    TabOrder = 4
  end
  inherited btnCancel: TButton
    Left = 563
    Top = 474
    Anchors = [akRight, akBottom]
    TabOrder = 5
  end
  object pnlParam: TPanel [5]
    Left = 0
    Top = 0
    Width = 639
    Height = 468
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 0
    object Bevel1: TBevel
      Left = 1
      Top = 1
      Width = 546
      Height = 8
      Shape = bsTopLine
    end
    object pcFunction: TSuperPageControl
      Left = 0
      Top = 27
      Width = 639
      Height = 441
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
          Top = 176
          Width = 90
          Height = 13
          Caption = 'Модуль функции:'
        end
        object Label12: TLabel
          Left = 8
          Top = 144
          Width = 74
          Height = 13
          Caption = 'Язык скрипта:'
        end
        object Label11: TLabel
          Left = 8
          Top = 72
          Width = 71
          Height = 13
          Caption = 'Комментарий:'
        end
        object Label6: TLabel
          Left = 8
          Top = 32
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
          Top = 228
          Width = 46
          Height = 13
          Caption = 'Изменил:'
        end
        object lEditorName: TLabel
          Left = 160
          Top = 228
          Width = 57
          Height = 13
          Caption = 'lEditorName'
        end
        object lLabel2: TLabel
          Left = 8
          Top = 249
          Width = 86
          Height = 13
          Caption = 'Дата изменения:'
        end
        object lEditDate: TLabel
          Left = 160
          Top = 249
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
          Top = 196
          Width = 134
          Height = 13
          Caption = 'Локальное наименование:'
        end
        object dbcbModule: TDBComboBox
          Left = 160
          Top = 168
          Width = 469
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
          Width = 469
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
          Width = 469
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
          Width = 469
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
          Width = 469
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
          Top = 399
          Width = 639
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
          Width = 639
          Height = 399
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
          MaxLeftChar = 0
          WantTabs = True
          OnProcessCommand = dbseScriptProcessCommand
          UseParser = False
          ShowOnlyColor = clBlack
          RemovedKeystrokes = <
            item
              Command = ecLineBreak
              ShortCut = 8205
            end
            item
              Command = ecContextHelp
              ShortCut = 112
            end>
          AddedKeystrokes = <>
        end
      end
      object tsParams: TSuperTabSheet
        Caption = 'Параметры'
        ImageIndex = 2
        object ScrollBox1: TScrollBox
          Left = 0
          Top = 39
          Width = 639
          Height = 379
          VertScrollBar.Style = ssFlat
          Align = alClient
          BorderStyle = bsNone
          TabOrder = 1
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
          Width = 639
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
      Left = 0
      Top = 0
      Width = 639
      Height = 27
      BoundLines = [blBottom]
      object TBToolbar1: TTBToolbar
        Left = 0
        Top = 0
        Caption = 'TBToolbar1'
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
    Options = [scoAnsiStrings, scoLimitToMatchedText, scoUseInsertList, scoUsePrettyText, scoUseBuiltInTimer, scoEndCharCompletion, scoCompleteWithTab, scoCompleteWithEnter]
    NbLinesInWindow = 6
    Width = 262
    EndOfTokenChr = '()[].,=<>-+&"'
    TriggerChars = '.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clBtnText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = [fsBold]
    Columns = <>
    OnExecute = SynCompletionProposalExecute
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
      OnExecute = actFindExecute
    end
    object actReplace: TAction
      Caption = 'Заменить'
      Hint = 'Заменить'
      ImageIndex = 22
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
  object FindDialog1: TFindDialog
    OnFind = FindDialog1Find
    Left = 464
    Top = 360
  end
  object ReplaceDialog1: TReplaceDialog
    OnFind = FindDialog1Find
    OnReplace = ReplaceDialog1Replace
    Left = 496
    Top = 360
  end
end
