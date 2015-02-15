object frmSQLEditorSyn: TfrmSQLEditorSyn
  Left = 295
  Top = 117
  Width = 963
  Height = 556
  HelpContext = 121
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'SQL редактор'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 947
    Height = 488
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object pcMain: TSuperPageControl
      Left = 9
      Top = 26
      Width = 929
      Height = 453
      BorderStyle = bsNone
      TabsVisible = True
      ActivePage = tsClasses
      Align = alClient
      TabHeight = 23
      TabOrder = 0
      OnChange = pcMainChange
      OnChanging = pcMainChanging
      object tsQuery: TSuperTabSheet
        BorderWidth = 3
        Caption = 'Редактирование'
        object splQuery: TSplitter
          Left = 0
          Top = 357
          Width = 923
          Height = 5
          Cursor = crVSplit
          Align = alBottom
        end
        object seQuery: TSynEdit
          Left = 0
          Top = 0
          Width = 923
          Height = 357
          Cursor = crIBeam
          Align = alClient
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          PopupMenu = pmQuery
          TabOrder = 0
          BookMarkOptions.BookmarkImages = imScript
          Gutter.DigitCount = 2
          Gutter.Font.Charset = DEFAULT_CHARSET
          Gutter.Font.Color = clWindowText
          Gutter.Font.Height = -11
          Gutter.Font.Name = 'Tahoma'
          Gutter.Font.Style = []
          Gutter.LeftOffset = 8
          Gutter.ShowLineNumbers = True
          Gutter.Width = 16
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
          OnChange = seQueryChange
          OnSpecialLineColors = seQuerySpecialLineColors
        end
        object mmPlan: TMemo
          Left = 0
          Top = 362
          Width = 923
          Height = 62
          Align = alBottom
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
          ReadOnly = True
          ScrollBars = ssVertical
          TabOrder = 1
        end
      end
      object tsResult: TSuperTabSheet
        BorderWidth = 3
        Caption = 'Результат'
        ImageIndex = 1
        object pnlNavigator: TPanel
          Left = 0
          Top = 0
          Width = 923
          Height = 26
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 0
          object dbNavigator: TDBNavigator
            Left = 0
            Top = 0
            Width = 110
            Height = 25
            DataSource = dsResult
            VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast, nbRefresh]
            TabOrder = 0
          end
          object tbResult: TTBToolbar
            Left = 120
            Top = 2
            Width = 150
            Height = 22
            Caption = 'tbResult'
            CloseButton = False
            DockMode = dmCannotFloatOrChangeDocks
            Images = dmImages.il16x16
            Options = [tboShowHint]
            ParentShowHint = False
            ShowHint = True
            TabOrder = 1
            object TBItem14: TTBItem
              Action = actEditBusinessObject
            end
            object TBItem15: TTBItem
              Action = actDeleteBusinessObject
            end
            object TBSeparatorItem16: TTBSeparatorItem
            end
            object TBItem28: TTBItem
              Action = actShowViewForm
            end
            object TBSeparatorItem17: TTBSeparatorItem
            end
            object TBItem26: TTBItem
              Action = actShowGrid
              Caption = 'Показать таблицу'
            end
            object TBItem30: TTBItem
              Action = actShowTree
            end
            object TBItem27: TTBItem
              Action = actShowRecord
              Caption = 'Показать запись'
            end
          end
        end
        object dbgResult: TgsDBGrid
          Left = 0
          Top = 26
          Width = 923
          Height = 398
          HelpContext = 3
          Align = alClient
          DataSource = dsResult
          Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
          ReadOnly = True
          TabOrder = 3
          OnDblClick = dbgResultDblClick
          InternalMenuKind = imkWithSeparator
          Expands = <>
          ExpandsActive = False
          ExpandsSeparate = False
          Conditions = <>
          ConditionsActive = False
          CheckBox.Visible = False
          CheckBox.FirstColumn = False
          MinColWidth = 40
          ShowFooter = True
        end
        object tvResult: TgsDBTreeView
          Left = 0
          Top = 26
          Width = 923
          Height = 398
          KeyField = 'ID'
          ParentField = 'PARENT'
          DisplayField = 'NAME'
          Align = alClient
          Indent = 19
          ReadOnly = True
          SortType = stText
          TabOrder = 1
          Visible = False
          MainFolderHead = True
          MainFolder = False
          MainFolderCaption = 'Все'
          WithCheckBox = False
        end
        object pnlRecord: TPanel
          Left = 0
          Top = 26
          Width = 923
          Height = 398
          Align = alClient
          BevelInner = bvLowered
          BevelOuter = bvNone
          TabOrder = 2
          Visible = False
          object sbRecord: TScrollBox
            Left = 1
            Top = 1
            Width = 921
            Height = 396
            Align = alClient
            BorderStyle = bsNone
            TabOrder = 0
          end
        end
      end
      object tsHistory: TSuperTabSheet
        BorderWidth = 3
        Caption = 'История'
        object Splitter2: TSplitter
          Left = 0
          Top = 421
          Width = 923
          Height = 3
          Cursor = crVSplit
          Align = alBottom
        end
        object pnlTest: TPanel
          Left = 0
          Top = 0
          Width = 923
          Height = 421
          Align = alClient
          TabOrder = 0
          OnResize = pnlTestResize
        end
      end
      object tsStatistic: TSuperTabSheet
        HelpContext = 122
        BorderWidth = 3
        Caption = 'Статистика'
        ImageIndex = 2
        object tsStatisticExtra: TSuperPageControl
          Left = 0
          Top = 26
          Width = 923
          Height = 398
          BorderStyle = bsNone
          TabsVisible = True
          ActivePage = tsGraphStatistic
          Align = alClient
          TabHeight = 23
          TabOrder = 0
          object tsGraphStatistic: TSuperTabSheet
            Caption = 'Графическое представление'
            object ChReads: TChart
              Left = 0
              Top = 0
              Width = 923
              Height = 375
              BackWall.Brush.Color = clWhite
              BackWall.Brush.Style = bsClear
              Title.Text.Strings = (
                '')
              Legend.Visible = False
              View3D = False
              Align = alClient
              BevelOuter = bvNone
              TabOrder = 0
              object Series1: THorizBarSeries
                Marks.Arrow.Width = 2
                Marks.ArrowLength = 8
                Marks.BackColor = clWhite
                Marks.Style = smsValue
                Marks.Transparent = True
                Marks.Visible = True
                SeriesColor = clRed
                Title = 'ChartSeries'
                XValues.DateTime = False
                XValues.Name = 'Bar'
                XValues.Multiplier = 1
                XValues.Order = loNone
                YValues.DateTime = False
                YValues.Name = 'Y'
                YValues.Multiplier = 1
                YValues.Order = loAscending
              end
            end
          end
          object tsAdditionalStatistic: TSuperTabSheet
            Caption = 'Дополнительно'
            object Panel1: TPanel
              Left = 0
              Top = 0
              Width = 184
              Height = 375
              Align = alLeft
              BevelOuter = bvNone
              TabOrder = 0
              object ScrollBox1: TScrollBox
                Left = 0
                Top = 0
                Width = 184
                Height = 328
                Align = alClient
                BorderStyle = bsNone
                TabOrder = 0
                object Label1: TLabel
                  Left = 8
                  Top = 8
                  Width = 115
                  Height = 13
                  Caption = 'Время выполнения'
                  Font.Charset = DEFAULT_CHARSET
                  Font.Color = clWindowText
                  Font.Height = -12
                  Font.Name = 'MS Sans Serif'
                  Font.Style = [fsBold]
                  ParentFont = False
                end
                object Bevel1: TBevel
                  Left = 8
                  Top = 24
                  Width = 155
                  Height = 2
                end
                object Label2: TLabel
                  Left = 8
                  Top = 32
                  Width = 61
                  Height = 13
                  Caption = 'Подготовка'
                end
                object Label3: TLabel
                  Left = 8
                  Top = 56
                  Width = 62
                  Height = 13
                  Caption = 'Выполнение'
                end
                object Label4: TLabel
                  Left = 8
                  Top = 80
                  Width = 50
                  Height = 13
                  Caption = 'Передачи'
                end
                object Label5: TLabel
                  Left = 8
                  Top = 112
                  Width = 46
                  Height = 13
                  Caption = 'Память'
                  Font.Charset = DEFAULT_CHARSET
                  Font.Color = clWindowText
                  Font.Height = -12
                  Font.Name = 'MS Sans Serif'
                  Font.Style = [fsBold]
                  ParentFont = False
                end
                object Bevel2: TBevel
                  Left = 8
                  Top = 128
                  Width = 153
                  Height = 2
                end
                object Label6: TLabel
                  Left = 8
                  Top = 136
                  Width = 45
                  Height = 13
                  Caption = 'Текущая'
                end
                object Label7: TLabel
                  Left = 8
                  Top = 160
                  Width = 73
                  Height = 13
                  Caption = 'Максимальная'
                end
                object Label8: TLabel
                  Left = 8
                  Top = 184
                  Width = 32
                  Height = 13
                  Caption = 'Буфер'
                end
                object lblPrepare: TLabel
                  Left = 152
                  Top = 31
                  Width = 6
                  Height = 13
                  Alignment = taRightJustify
                  Caption = '0'
                end
                object lblExecute: TLabel
                  Left = 152
                  Top = 56
                  Width = 6
                  Height = 13
                  Alignment = taRightJustify
                  Caption = '0'
                end
                object lblFetch: TLabel
                  Left = 152
                  Top = 80
                  Width = 6
                  Height = 13
                  Alignment = taRightJustify
                  Caption = '0'
                end
                object lblCurrent: TLabel
                  Left = 152
                  Top = 136
                  Width = 6
                  Height = 13
                  Alignment = taRightJustify
                  Caption = '0'
                end
                object lblMax: TLabel
                  Left = 152
                  Top = 160
                  Width = 6
                  Height = 13
                  Alignment = taRightJustify
                  Caption = '0'
                end
                object lblBuffer: TLabel
                  Left = 152
                  Top = 183
                  Width = 6
                  Height = 13
                  Alignment = taRightJustify
                  Caption = '0'
                end
                object Label9: TLabel
                  Left = 8
                  Top = 216
                  Width = 59
                  Height = 13
                  Caption = 'Операции'
                  Font.Charset = DEFAULT_CHARSET
                  Font.Color = clWindowText
                  Font.Height = -12
                  Font.Name = 'MS Sans Serif'
                  Font.Style = [fsBold]
                  ParentFont = False
                end
                object Bevel3: TBevel
                  Left = 3
                  Top = 232
                  Width = 153
                  Height = 2
                end
                object Label10: TLabel
                  Left = 8
                  Top = 240
                  Width = 37
                  Height = 13
                  Caption = 'Чтение'
                end
                object Label11: TLabel
                  Left = 8
                  Top = 264
                  Width = 35
                  Height = 13
                  Caption = 'Запись'
                end
                object Label12: TLabel
                  Left = 8
                  Top = 288
                  Width = 50
                  Height = 13
                  Caption = 'Передача'
                end
                object lblRead: TLabel
                  Left = 150
                  Top = 240
                  Width = 6
                  Height = 13
                  Alignment = taRightJustify
                  Caption = '0'
                end
                object lblWrite: TLabel
                  Left = 150
                  Top = 264
                  Width = 6
                  Height = 13
                  Alignment = taRightJustify
                  Caption = '0'
                end
                object lblFetches: TLabel
                  Left = 150
                  Top = 288
                  Width = 6
                  Height = 13
                  Alignment = taRightJustify
                  Caption = '0'
                end
              end
            end
            object lvReads: TListView
              Left = 184
              Top = 0
              Width = 739
              Height = 375
              Align = alClient
              Columns = <
                item
                  Caption = 'Имя таблицы'
                  Width = 184
                end
                item
                  Caption = 'IR'
                end
                item
                  Caption = 'NIR'
                end
                item
                  Caption = 'INS'
                end
                item
                  Caption = 'UPD'
                end
                item
                  Caption = 'DEL'
                end>
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -12
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              GridLines = True
              RowSelect = True
              ParentFont = False
              TabOrder = 1
              ViewStyle = vsReport
            end
          end
        end
        object TBDock5: TTBDock
          Left = 0
          Top = 0
          Width = 923
          Height = 26
          object tbStatistic: TTBToolbar
            Left = 0
            Top = 0
            Caption = 'tbStatistic'
            CloseButton = False
            DefaultDock = TBDock5
            DockMode = dmCannotFloatOrChangeDocks
            FullSize = True
            Images = imStatistic
            ParentShowHint = False
            ShowHint = True
            TabOrder = 0
            object TBItem17: TTBItem
              Caption = 'Индексированные чтения'
              Checked = True
              DisplayMode = nbdmImageAndText
              Hint = 'Индекированные чтения'
              ImageIndex = 1
              OnClick = actRefreshChartExecute
            end
            object TBSeparatorItem9: TTBSeparatorItem
            end
            object TBItem18: TTBItem
              Caption = 'Неиндексированные чтения'
              Checked = True
              DisplayMode = nbdmImageAndText
              Hint = 'Неиндексированные чтения'
              ImageIndex = 0
              OnClick = actRefreshChartExecute
            end
            object TBSeparatorItem10: TTBSeparatorItem
            end
            object TBItem19: TTBItem
              Caption = 'Вставки'
              DisplayMode = nbdmImageAndText
              Hint = 'Вставки'
              ImageIndex = 4
              OnClick = actRefreshChartExecute
            end
            object TBSeparatorItem11: TTBSeparatorItem
            end
            object TBItem20: TTBItem
              Caption = 'Обновления'
              DisplayMode = nbdmImageAndText
              Hint = 'Обновления'
              ImageIndex = 2
              OnClick = actRefreshChartExecute
            end
            object TBSeparatorItem12: TTBSeparatorItem
            end
            object TBItem21: TTBItem
              Caption = 'Удаления'
              DisplayMode = nbdmImageAndText
              Hint = 'Удаления'
              ImageIndex = 3
              OnClick = actRefreshChartExecute
            end
            object TBSeparatorItem13: TTBSeparatorItem
            end
            object tbItemAllRecord: TTBItem
              Caption = 'Всего записей'
              DisplayMode = nbdmImageAndText
              Hint = 'Всего записей'
              ImageIndex = 5
              OnClick = actRefreshChartExecute
            end
          end
        end
      end
      object tsTrace: TSuperTabSheet
        BorderWidth = 3
        Caption = 'Трассировка'
        object pnlTrace: TPanel
          Left = 0
          Top = 0
          Width = 923
          Height = 424
          Align = alClient
          TabOrder = 0
          OnResize = pnlTraceResize
        end
      end
      object tsLog: TSuperTabSheet
        BorderWidth = 3
        Caption = 'Журнал'
        ImageIndex = 3
        object mmLog: TMemo
          Left = 0
          Top = 0
          Width = 923
          Height = 424
          Align = alClient
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
          ScrollBars = ssVertical
          TabOrder = 0
        end
      end
      object tsTransaction: TSuperTabSheet
        BorderWidth = 3
        Caption = 'Транзакция'
        object Panel3: TPanel
          Left = 0
          Top = 0
          Width = 923
          Height = 54
          Align = alTop
          Alignment = taLeftJustify
          BevelOuter = bvNone
          TabOrder = 0
          object Label15: TLabel
            Left = 81
            Top = 32
            Width = 277
            Height = 13
            Caption = 'указанные ниже параметры к выбранной транзакции:'
          end
          object Label14: TLabel
            Left = 5
            Top = 8
            Width = 110
            Height = 13
            Caption = 'Выбрана транзакция:'
          end
          object Label16: TLabel
            Left = 489
            Top = 7
            Width = 349
            Height = 13
            Caption = 'Смена транзакции может привести к нестабильной работе системы!'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clRed
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object cbTransactions: TComboBox
            Left = 120
            Top = 4
            Width = 361
            Height = 21
            Style = csDropDownList
            DropDownCount = 24
            ItemHeight = 13
            TabOrder = 0
            OnChange = cbTransactionsChange
          end
          object btnSetTransactionParams: TButton
            Left = 1
            Top = 29
            Width = 75
            Height = 21
            Action = actSetTransactionParams
            TabOrder = 1
          end
        end
        object chlbTransactionParams: TCheckListBox
          Left = 0
          Top = 54
          Width = 923
          Height = 370
          Align = alClient
          ItemHeight = 13
          Sorted = True
          TabOrder = 1
        end
      end
      object tsMonitor: TSuperTabSheet
        BorderWidth = 3
        Caption = 'Монитор'
        object Panel4: TPanel
          Left = 0
          Top = 0
          Width = 923
          Height = 26
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 0
          object dbnvMonitor: TDBNavigator
            Left = 0
            Top = 0
            Width = 110
            Height = 25
            DataSource = dsMonitor
            VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast, nbRefresh]
            TabOrder = 0
          end
          object tbMonitor: TTBToolbar
            Left = 120
            Top = 0
            Width = 104
            Height = 22
            Caption = 'TBToolbar2'
            CloseButton = False
            DockMode = dmCannotFloatOrChangeDocks
            Images = dmImages.il16x16
            ParentShowHint = False
            ShowHint = True
            TabOrder = 1
            object TBItem24: TTBItem
              Action = actShowMonitorSQL
            end
            object TBSeparatorItem14: TTBSeparatorItem
            end
            object TBItem22: TTBItem
              Action = actRefreshMonitor
            end
            object TBSeparatorItem15: TTBSeparatorItem
            end
            object TBItem23: TTBItem
              Action = actDeleteStatement
            end
            object TBItem25: TTBItem
              Action = actDisconnectUser
            end
          end
        end
        object pnlMonitor: TPanel
          Left = 0
          Top = 26
          Width = 923
          Height = 398
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 1
          object spMonitor: TSplitter
            Left = 497
            Top = 0
            Width = 5
            Height = 398
            Cursor = crHSplit
          end
          object ibgrMonitor: TgsIBGrid
            Left = 0
            Top = 0
            Width = 497
            Height = 398
            Align = alLeft
            DataSource = dsMonitor
            Options = [dgTitles, dgColumnResize, dgColLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
            ReadOnly = True
            TabOrder = 0
            OnDblClick = ibgrMonitorDblClick
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
            ShowFooter = True
            ShowTotals = False
          end
          object dbseSQLText: TDBSynEdit
            Left = 502
            Top = 0
            Width = 421
            Height = 398
            Cursor = crIBeam
            DataField = 'sql_text'
            DataSource = dsMonitor
            Align = alClient
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
        end
      end
      object tsClasses: TSuperTabSheet
        Caption = 'Бизнес-классы'
        object pnlClassesToolbar: TPanel
          Left = 0
          Top = 0
          Width = 929
          Height = 26
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 0
          object lblClassesCount: TLabel
            Left = 273
            Top = 6
            Width = 10
            Height = 13
            Caption = 'lbl'
          end
          object Label17: TLabel
            Left = 60
            Top = 6
            Width = 42
            Height = 13
            Caption = 'Фильтр:'
          end
          object tbClasses: TTBToolbar
            Left = 6
            Top = 2
            Width = 46
            Height = 22
            Caption = 'tbClasses'
            CloseButton = False
            DockMode = dmCannotFloatOrChangeDocks
            Images = dmImages.il16x16
            ParentShowHint = False
            ShowHint = True
            TabOrder = 0
            object TBItem32: TTBItem
              Action = actClassesShowSelectSQL
            end
            object TBItem33: TTBItem
              Action = actClassesShowViewForm
            end
          end
          object edClassesFilter: TEdit
            Left = 106
            Top = 3
            Width = 160
            Height = 21
            TabOrder = 1
            OnChange = edClassesFilterChange
          end
        end
        object lvClasses: TListView
          Left = 0
          Top = 26
          Width = 929
          Height = 404
          Align = alClient
          Columns = <
            item
              Caption = 'Бизнес-класс'
              Width = 380
            end
            item
              Caption = 'Подтип'
              Width = 200
            end
            item
              Caption = 'Описание'
              Width = 240
            end
            item
              Caption = 'Таблица'
              Width = 180
            end>
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Courier New'
          Font.Style = []
          HideSelection = False
          ReadOnly = True
          RowSelect = True
          ParentFont = False
          TabOrder = 1
          ViewStyle = vsReport
        end
      end
    end
    object TBDock1: TTBDock
      Left = 0
      Top = 0
      Width = 947
      Height = 26
      object TBToolbar1: TTBToolbar
        Left = 0
        Top = 0
        Caption = 'Панель инструментов'
        CloseButton = False
        DockMode = dmCannotFloatOrChangeDocks
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        FullSize = True
        Images = dmImages.il16x16
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        object TBItem13: TTBItem
          Action = actNew
        end
        object TBItem31: TTBItem
          Action = actExternalEditor
        end
        object TBSeparatorItem6: TTBSeparatorItem
        end
        object TBItem12: TTBItem
          Action = actPrevQuery
        end
        object TBItem11: TTBItem
          Action = actNextQuery
        end
        object TBSeparatorItem7: TTBSeparatorItem
        end
        object TBItem10: TTBItem
          Action = actSaveScript
          Images = dmImages.il16x16
        end
        object TBItem9: TTBItem
          Action = actOpenScript
          Images = dmImages.il16x16
        end
        object TBSeparatorItem5: TTBSeparatorItem
        end
        object TBItem6: TTBItem
          Action = actExecute
          ImageIndex = 9
          Images = dmImages.imglActions
        end
        object TBItem5: TTBItem
          Action = actPrepare
          ImageIndex = 15
          Images = dmImages.imglActions
        end
        object TBItem16: TTBItem
          Action = actParse
        end
        object tbiFilter: TTBItem
          Action = actFilter
        end
        object TBSeparatorItem1: TTBSeparatorItem
        end
        object TBItem4: TTBItem
          Action = actCommit
          ImageIndex = 9
          Images = dmImages.imFunction
        end
        object TBItem3: TTBItem
          Action = actRollback
          Images = dmImages.ImageList
        end
        object TBSeparatorItem2: TTBSeparatorItem
        end
        object TBItem2: TTBItem
          Action = actFind
          Images = dmImages.il16x16
        end
        object TBItem1: TTBItem
          Action = actReplace
          Images = dmImages.il16x16
        end
        object TBSeparatorItem3: TTBSeparatorItem
        end
        object TBItem7: TTBItem
          Action = actExport
          Images = dmImages.ImageList
        end
        object TBSeparatorItem18: TTBSeparatorItem
        end
        object TBItem34: TTBItem
          Action = actChangeRUID
        end
        object TBSeparatorItem4: TTBSeparatorItem
        end
        object TBItem8: TTBItem
          Action = actOptions
          Images = dmImages.il16x16
        end
        object TBSeparatorItem8: TTBSeparatorItem
        end
        object TBControlItem2: TTBControlItem
          Control = Label13
        end
        object TBControlItem1: TTBControlItem
          Control = iblkupTable
        end
        object TBItem29: TTBItem
          Action = actMakeSelect
        end
        object Label13: TLabel
          Left = 445
          Top = 4
          Width = 51
          Height = 13
          Caption = 'Таблицы: '
        end
        object iblkupTable: TgsIBLookupComboBox
          Left = 496
          Top = 0
          Width = 145
          Height = 21
          HelpContext = 1
          Fields = 'lname'
          ListTable = 'at_relations'
          ListField = 'relationname'
          KeyField = 'id'
          SortOrder = soAsc
          gdClassName = 'TgdcRelation'
          StrictOnExit = False
          ItemHeight = 13
          TabOrder = 0
        end
      end
    end
    object TBDock2: TTBDock
      Left = 0
      Top = 26
      Width = 9
      Height = 453
      Position = dpLeft
    end
    object TBDock3: TTBDock
      Left = 938
      Top = 26
      Width = 9
      Height = 453
      Position = dpRight
    end
    object TBDock4: TTBDock
      Left = 0
      Top = 479
      Width = 947
      Height = 9
      Position = dpBottom
    end
  end
  object pModal: TPanel
    Left = 0
    Top = 488
    Width = 947
    Height = 30
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    Visible = False
    object Button1: TButton
      Left = 787
      Top = 4
      Width = 75
      Height = 21
      Action = actOk
      Anchors = [akRight, akBottom]
      TabOrder = 0
    end
    object Button2: TButton
      Left = 868
      Top = 4
      Width = 75
      Height = 21
      Action = actCancel
      Anchors = [akRight, akBottom]
      TabOrder = 1
    end
  end
  object _ibtrEditor: TIBTransaction
    Active = False
    DefaultAction = TACommit
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 466
    Top = 187
  end
  object ActionList: TActionList
    Images = dmImages.il16x16
    Left = 514
    Top = 139
    object actShowMonitorSQL: TAction
      Category = 'Monitor'
      Caption = 'Показать SQL запрос'
      Hint = 'Показать SQL запрос'
      ImageIndex = 189
      OnExecute = actShowMonitorSQLExecute
      OnUpdate = actShowMonitorSQLUpdate
    end
    object actExecute: TAction
      Caption = 'Выполнить'
      Hint = 'Выполнить'
      ImageIndex = 0
      ShortCut = 120
      OnExecute = actExecuteExecute
      OnUpdate = actExecuteUpdate
    end
    object actDisconnectUser: TAction
      Category = 'Monitor'
      Caption = 'Завершить сеанс пользователя'
      Hint = 'Завершить сеанс пользователя'
      ImageIndex = 34
      OnExecute = actDisconnectUserExecute
      OnUpdate = actDisconnectUserUpdate
    end
    object actPrepare: TAction
      Caption = 'Подготовить'
      Hint = 'Подготовить'
      ImageIndex = 1
      ShortCut = 16504
      OnExecute = actPrepareExecute
      OnUpdate = actPrepareUpdate
    end
    object actCommit: TAction
      Caption = 'actCommit'
      Hint = 'Принять'
      ImageIndex = 2
      ShortCut = 49219
      OnExecute = actCommitExecute
      OnUpdate = actCommitUpdate
    end
    object actRollback: TAction
      Caption = 'actRollback'
      Hint = 'Откатить'
      ImageIndex = 3
      ShortCut = 49234
      OnExecute = actRollbackExecute
      OnUpdate = actCommitUpdate
    end
    object actFind: TAction
      Caption = 'Поиск...'
      Hint = 'Поиск'
      ImageIndex = 23
      ShortCut = 16454
      OnExecute = actFindExecute
      OnUpdate = actFindUpdate
    end
    object actExport: TAction
      Caption = 'actExport'
      Hint = 'Экспорт'
      ImageIndex = 5
      ShortCut = 16453
    end
    object actOptions: TAction
      Caption = 'Свойства редактора'
      Hint = 'Свойства редактора'
      ImageIndex = 30
      OnExecute = actOptionsExecute
      OnUpdate = actOptionsUpdate
    end
    object actReplace: TAction
      Caption = 'Замена...'
      Hint = 'Замена'
      ImageIndex = 22
      OnExecute = actReplaceExecute
      OnUpdate = actOpenScriptUpdate
    end
    object actOpenScript: TAction
      Caption = 'actOpenScript'
      Hint = 'Загрузить скрипт'
      ImageIndex = 27
      OnExecute = actOpenScriptExecute
      OnUpdate = actOpenScriptUpdate
    end
    object actSaveScript: TAction
      Caption = 'actSaveScript'
      Hint = 'Сохранить скрипт'
      ImageIndex = 25
      OnExecute = actSaveScriptExecute
      OnUpdate = actSaveScriptUpdate
    end
    object actNew: TAction
      Caption = 'Новый запрос'
      Hint = 'Очистить текст запроса'
      ImageIndex = 123
      OnExecute = actNewExecute
    end
    object actNextQuery: TAction
      Caption = 'Следующий запрос'
      ImageIndex = 46
      OnExecute = actNextQueryExecute
      OnUpdate = actNextQueryUpdate
    end
    object actPrevQuery: TAction
      Caption = 'Предыдущий запрос'
      ImageIndex = 45
      OnExecute = actPrevQueryExecute
      OnUpdate = actPrevQueryUpdate
    end
    object actOk: TAction
      Caption = 'OK'
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
    object actEditBusinessObject: TAction
      Category = 'Result'
      Caption = 'Редактировать бизнес-объект...'
      Hint = 'Редактировать бизнес-объект...'
      ImageIndex = 1
      OnExecute = actEditBusinessObjectExecute
      OnUpdate = actEditBusinessObjectUpdate
    end
    object actDeleteBusinessObject: TAction
      Category = 'Result'
      Caption = 'Удалить бизнес-объект'
      Hint = 'Удалить бизнес-объект'
      ImageIndex = 2
      OnExecute = actDeleteBusinessObjectExecute
      OnUpdate = actEditBusinessObjectUpdate
    end
    object actParse: TAction
      Caption = 'Разобрать запрос'
      ImageIndex = 181
      OnExecute = actParseExecute
      OnUpdate = actParseUpdate
    end
    object actRefreshChart: TAction
      Caption = 'actRefreshChart'
      OnExecute = actRefreshChartExecute
    end
    object actRefreshMonitor: TAction
      Category = 'Monitor'
      Caption = 'Обновить'
      Hint = 'Обновить'
      ImageIndex = 17
      OnExecute = actRefreshMonitorExecute
      OnUpdate = actRefreshMonitorUpdate
    end
    object actDeleteStatement: TAction
      Category = 'Monitor'
      Caption = 'Прервать выполнение запроса'
      Hint = 'Прервать выполнение запроса'
      ImageIndex = 117
      OnExecute = actDeleteStatementExecute
      OnUpdate = actDeleteStatementUpdate
    end
    object actShowGrid: TAction
      Category = 'Result'
      Caption = 'Показать в таблице'
      Hint = 'Показать таблицу'
      ImageIndex = 220
      OnExecute = actShowGridExecute
      OnUpdate = actShowGridUpdate
    end
    object actShowRecord: TAction
      Category = 'Result'
      Caption = 'Показать одну запись'
      Hint = 'Показать запись'
      ImageIndex = 176
      OnExecute = actShowRecordExecute
      OnUpdate = actShowGridUpdate
    end
    object actShowViewForm: TAction
      Category = 'Result'
      Caption = 'actShowViewForm'
      Hint = 'Открыть форму просмотра'
      ImageIndex = 210
      OnExecute = actShowViewFormExecute
      OnUpdate = actEditBusinessObjectUpdate
    end
    object actMakeSelect: TAction
      Caption = 'Создать запрос для таблицы'
      Hint = 'Создать запрос для выбранной таблицы'
      ImageIndex = 251
      OnExecute = actMakeSelectExecute
      OnUpdate = actMakeSelectUpdate
    end
    object actSaveFieldToFile: TAction
      Category = 'Result'
      Caption = 'Сохранить в файл...'
      Hint = 'Сохранить значение поля в файл'
      ImageIndex = 25
      OnExecute = actSaveFieldToFileExecute
      OnUpdate = actSaveFieldToFileUpdate
    end
    object actFindNext: TAction
      Caption = 'Найти далее'
      ImageIndex = 24
      ShortCut = 114
      OnExecute = actFindNextExecute
      OnUpdate = actFindNextUpdate
    end
    object actShowTree: TAction
      Category = 'Result'
      Caption = 'Показать в виде дерева'
      Hint = 'Показать в виде дерева'
      ImageIndex = 219
      OnExecute = actShowTreeExecute
      OnUpdate = actShowTreeUpdate
    end
    object actExternalEditor: TAction
      Caption = 'Внешний редактор...'
      Hint = 'Редактировать текст запроса во внешнем редакторе'
      ImageIndex = 177
      OnExecute = actExternalEditorExecute
      OnUpdate = actExternalEditorUpdate
    end
    object actClassesShowSelectSQL: TAction
      Category = 'Classes'
      Caption = 'Показать запрос'
      Hint = 'Показать запрос для выбранного класса'
      ImageIndex = 152
      OnExecute = actClassesShowSelectSQLExecute
      OnUpdate = actClassesShowSelectSQLUpdate
    end
    object actClassesShowViewForm: TAction
      Category = 'Classes'
      Caption = 'actClassesShowViewForm'
      Hint = 'Открыть форму просмотра для выбранного класса'
      ImageIndex = 210
      OnExecute = actClassesShowViewFormExecute
      OnUpdate = actClassesShowSelectSQLUpdate
    end
    object actConvertToPas: TAction
      Caption = 'SQL -> PASCAL'
      OnExecute = actConvertToPasExecute
      OnUpdate = actConvertToPasUpdate
    end
    object actConvertToSQL: TAction
      Caption = 'PASCAL -> SQL'
      OnExecute = actConvertToSQLExecute
      OnUpdate = actConvertToSQLUpdate
    end
    object actSetTransactionParams: TAction
      Caption = 'Применить'
      OnExecute = actSetTransactionParamsExecute
      OnUpdate = actSetTransactionParamsUpdate
    end
    object actChangeRUID: TAction
      Caption = 'Заменить РУИД...'
      Hint = 'Заменить РУИД'
      ImageIndex = 37
      OnExecute = actChangeRUIDExecute
    end
    object actFilter: TAction
      Caption = 'actFilter'
      Hint = 'Обработать запрос фильтром'
      ImageIndex = 20
      OnExecute = actFilterExecute
      OnUpdate = actFilterUpdate
    end
  end
  object ibsqlPlan: TIBSQL
    Transaction = _ibtrEditor
    Left = 498
    Top = 83
  end
  object dsResult: TDataSource
    DataSet = ibqryWork
    Left = 434
    Top = 83
  end
  object IBDatabaseInfo: TIBDatabaseInfo
    Left = 394
    Top = 99
  end
  object imScript: TImageList
    Left = 437
    Top = 147
    Bitmap = {
      494C01010F001300040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000005000000001002000000000000050
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000084
      8400008484000084840000848400008484000084840000848400008484000084
      8400008484000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000848400C6C6
      C60000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF00C6C6C6000084840000000000000000000000000000000000000000000000
      0000000000000000000000000000840000008400000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000084840000FF
      FF0000FFFF0000FFFF0000FFFF00000000000000000000FFFF0000FFFF0000FF
      FF0000FFFF000084840000000000000000000000000000000000000000000000
      00000000000000000000FFFF0000FF0000008400000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FFFF
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000084840000FF
      FF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF000084840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF0000000000
      0000000000000000000000000000000000000000000000000000FF000000FF00
      0000FFFF00000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000848400C6C6
      C60000FFFF0000FFFF0000FFFF00000000000000000000FFFF0000FFFF0000FF
      FF00C6C6C6000084840000000000000000000000000000000000000000000000
      00000000000000000000FFFF0000FF0000008400000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      0000000000000000000000000000000000000000000000000000FF000000FF00
      0000FF000000FFFF000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000084
      840000FFFF0000FFFF0000FFFF00000000000000000000FFFF0000FFFF0000FF
      FF00008484000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFF0000FF0000008400000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FFFF0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008484
      8400C6C6C60000FFFF0000FFFF00000000000000000000FFFF0000FFFF00C6C6
      C600848484000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFF0000FF0000008400000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      0000000000000000000000000000000000000000000000000000FF000000FF00
      0000FF000000FFFF000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000084840000FFFF0000FFFF00000000000000000000FFFF0000FFFF000084
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FFFF0000FF00000084000000000000000000
      0000000000000000000000000000000000000000000000000000FF0000000000
      0000000000000000000000000000000000000000000000000000FF000000FF00
      0000FFFF00000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000084848400C6C6C60000FFFF00000000000000000000FFFF00C6C6C6008484
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000008400000084000000C6C6C600FFFF0000FF000000840000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FFFF
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000084840000FFFF0000FFFF0000FFFF0000FFFF00008484000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFF0000FF00000084000000C6C6C600FFFF0000FF000000840000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000008484008484840000FFFF0000FFFF0084848400008484000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFF0000FF0000008400000084000000FF000000FF000000840000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000848400008484000084840000848400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFF0000FF000000FF000000FF00000084000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFF0000FFFF0000FFFF000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000C6C6C6008484
      0000008400008484000000840000848400000084000084840000FF000000FF00
      00000000000000000000000000000000000000000000FF000000C6C6C6008484
      0000008400008484000000840000848400000084000084840000FF000000FF00
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000C6C6C6000084
      00008484000000FFFF0000FFFF0000FFFF008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      00008484000000840000848400000084000000FFFF0000840000FF0000008484
      8400FF0000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF0084840000008400008484000000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      00000084000084840000008400008484000000FFFF0084840000FF0000008484
      8400FF0000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008400000000
      0000000000000000000000840000000000000000000000000000000000000000
      00000000000000840000000000000000000000000000FF000000C6C6C6000084
      000000FFFF0000840000848400000084000000FFFF0000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      00008484000000840000848400000084000000FFFF0000840000FF0000008484
      8400FF0000000000000000000000000000000000000000000000000000000000
      00000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000084
      0000000000000084000000840000008400000084000000000000000000000000
      00000084000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF0084840000008400008484000000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      00000084000000FFFF0000FFFF008484000000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000000000000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000FF0000008400000084000000840000000000000000
      00000000000000000000000000000000000000000000FF000000C6C6C6008484
      00008484000000FFFF0000FFFF0000FFFF008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF00008400008484000000FFFF0000FFFF0000840000FF0000008484
      8400FF000000000000000000000000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000084000000FF0000848400000084000000840000000000000000
      00000000000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF0084840000008400008484000000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF0084840000008400008484000000FFFF0084840000FF0000008484
      8400FF000000000000000000000000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF00000000000000
      0000000000000000000000000000000000000000000000000000008400000084
      0000000000000084000000FF000000FF00000084000000840000000000000000
      00000084000000840000000000000000000000000000FF000000C6C6C6000084
      000000FFFF0000840000848400000084000000FFFF0000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF0000840000848400000084000000FFFF0000840000FF0000008484
      8400FF0000000000000000000000000000000000FF000000FF00000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000084000000FF000000FF00000084000000840000000000000000
      00000000000000000000000000000000000000000000FF000000C6C6C6008484
      00000084000000FFFF0000FFFF0000FFFF000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      00000084000000FFFF0000FFFF0000FFFF000084000084840000FF0000008484
      8400FF0000000000000000000000000000000000FF000000FF00000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000084000000FF000000FF00000084000000840000000000000000
      00000000000000000000000000000000000000000000FF000000C6C6C6000084
      0000848400000084000084840000008400008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      0000848400000084000084840000008400008484000000840000FF0000008484
      8400FF0000000000000000000000000000000000FF000000FF00000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000084000000FF000000FF000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000008484
      8400FF000000000000000000000000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000840000C6C6C60000840000008400000000000000000000C6C6C6000084
      0000000000000000000000000000000000000000000000000000FF000000C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6008484
      8400FF0000000000000000000000000000000000000000000000FF000000C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6008484
      8400FF000000000000000000000000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF00000000000000
      0000000000000000000000000000000000000000000000000000000000000084
      0000000000000000FF00000084000084000000000000000084000000FF000000
      000000840000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      00000000000000000000000000000000000000000000000000000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000840000FF00000084000000008400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000008400000084000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      00000000000000000000000000000000000000000000FF000000C6C6C6008484
      0000008400008484000000840000848400000084000084840000FF000000FF00
      00000000000000000000000000000000000000000000FF000000C6C6C6008484
      0000008400008484000000840000848400000084000084840000FF000000FF00
      00000000000000000000000000000000000000000000FF000000C6C6C6008484
      0000008400008484000000840000848400000084000084840000FF000000FF00
      00000000000000000000000000000000000000000000FF000000C6C6C6008484
      0000008400008484000000840000848400000084000084840000FF000000FF00
      00000000000000000000000000000000000000000000FF000000C6C6C6000084
      000084840000008400008484000000FFFF008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      00008484000000FFFF0000FFFF0000FFFF008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      00008484000000FFFF0000FFFF0000FFFF008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      0000848400000084000000FFFF00008400008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000840000848400000084000000FFFF000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF0084840000008400008484000000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF0084840000008400008484000000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      0000008400008484000000FFFF00848400000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000084840000008400008484000000FFFF008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      00008484000000840000848400000084000000FFFF0000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF0000840000848400000084000000FFFF0000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      0000848400000084000000FFFF00008400008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      00000084000084840000008400008484000000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF0084840000008400008484000000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000840000848400000084000000FFFF000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF00008400008484000000FFFF008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF0000FFFF0000FFFF0000FFFF008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF0000FFFF0000FFFF0000FFFF008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000084840000008400008484000000FFFF008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF00848400000084000000FFFF000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF008484000000840000848400000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF008484000000840000848400000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      00000084000084840000008400008484000000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF00008400008484000000FFFF008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF000084000084840000008400008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF0000840000848400000084000000FFFF0000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF0000840000848400000084000000FFFF0000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF00848400000084000000FFFF000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      00000084000000FFFF0000FFFF0000FFFF000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      0000848400000084000084840000008400008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      0000848400000084000084840000008400008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      0000848400000084000084840000008400008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      0000848400000084000084840000008400008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000008484
      8400FF0000000000000000000000000000000000000000000000FF000000C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6008484
      8400FF0000000000000000000000000000000000000000000000FF000000C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6008484
      8400FF0000000000000000000000000000000000000000000000FF000000C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6008484
      8400FF0000000000000000000000000000000000000000000000FF000000C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6008484
      8400FF000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      00000000000000000000000000000000000000000000FF000000C6C6C6008484
      0000008400008484000000840000848400000084000084840000FF000000FF00
      00000000000000000000000000000000000000000000FF000000C6C6C6008484
      0000008400008484000000840000848400000084000084840000FF000000FF00
      00000000000000000000000000000000000000000000FF000000C6C6C6008484
      0000008400008484000000840000848400000084000084840000FF000000FF00
      00000000000000000000000000000000000000000000FF000000C6C6C6008484
      0000008400008484000000840000848400000084000084840000FF000000FF00
      00000000000000000000000000000000000000000000FF000000C6C6C6000084
      00008484000000FFFF0000FFFF0000FFFF008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      00008484000000FFFF0000FFFF0000FFFF008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF0084840000008400008484000000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      0000008400008484000000FFFF00848400000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF008484000000840000848400000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF0084840000008400008484000000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF0000840000848400000084000000FFFF0000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      0000848400000084000000FFFF00008400008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      00008484000000FFFF0084840000008400008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      00008484000000840000848400000084000000FFFF0000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF0084840000008400008484000000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      0000008400008484000000FFFF00848400000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      0000008400008484000000FFFF00848400000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      00000084000084840000008400008484000000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF0000840000848400000084000000FFFF0000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      0000848400000084000000FFFF00008400008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000084840000008400008484000000FFFF008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      0000848400000084000000FFFF0000FFFF008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF0084840000008400008484000000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF008484000000FFFF00848400000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      00000084000084840000008400008484000000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      00000084000084840000008400008484000000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF0000840000848400000084000000FFFF0000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      00008484000000FFFF0000FFFF00008400008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF0000840000848400000084000000FFFF0000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF0000840000848400000084000000FFFF0000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      00000084000000FFFF0000FFFF0000FFFF000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      0000008400008484000000FFFF00848400000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      00000084000000FFFF0000FFFF0000FFFF000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      00000084000000FFFF0000FFFF0000FFFF000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      0000848400000084000084840000008400008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      0000848400000084000084840000008400008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      0000848400000084000084840000008400008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      0000848400000084000084840000008400008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000008484
      8400FF0000000000000000000000000000000000000000000000FF000000C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6008484
      8400FF0000000000000000000000000000000000000000000000FF000000C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6008484
      8400FF0000000000000000000000000000000000000000000000FF000000C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6008484
      8400FF0000000000000000000000000000000000000000000000FF000000C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6008484
      8400FF000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000500000000100010000000000800200000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FFFFFFFFFFFF0000FFFFFFFFFFFF0000
      FFFFFFFFFFFF0000E007FFFFFFFF0000C003FE7FFFFF0000C003FC7FFF8F0000
      C003FFFFDFC70000C003FC7FEFC30000E007FC7FF0010000E007FC7FEFC30000
      F00FFE3FDFC70000F00FF81FFF8F0000F81FF01FFFFF0000F81FF01FFFFF0000
      FC3FF83FFFFF0000FFFFFC7FFFFF0000FFFFFFFFFFFFFFFF801F801FFFFFFFFF
      800F800FFFFFFFFF80078007FFFFFFFF80078007FFFFCC7380078007F1FFE027
      80078007C07FF00F80078007803FF81F80078007803FC81380078007001FE007
      80078007001FF83F80078007001FF00F80078007803FE007C007C007803FE817
      E00FE00FC07FFC3FFFFFFFFFF1FFFA5FFFFFFFFFFFFFFFFF801F801F801F801F
      800F800F800F800F800780078007800780078007800780078007800780078007
      8007800780078007800780078007800780078007800780078007800780078007
      800780078007800780078007800780078007800780078007C007C007C007C007
      E00FE00FE00FE00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF801F801F801F801F
      800F800F800F800F800780078007800780078007800780078007800780078007
      8007800780078007800780078007800780078007800780078007800780078007
      800780078007800780078007800780078007800780078007C007C007C007C007
      E00FE00FE00FE00FFFFFFFFFFFFFFFFF00000000000000000000000000000000
      000000000000}
  end
  object SynSQLSyn: TSynSQLSyn
    DefaultFilter = 'SQL files (*.sql)|*.sql'
    SQLDialect = sqlInterbase6
    Left = 301
    Top = 232
  end
  object ActionList2: TActionList
    Left = 126
    Top = 117
    object actEditCopy: TEditCopy
      Category = 'Edit'
      Caption = 'Копировать'
      Hint = 'Copy'
      ImageIndex = 1
      ShortCut = 16451
    end
    object actEditCut: TEditCut
      Category = 'Edit'
      Caption = 'Вырезать'
      Hint = 'Cut'
      ImageIndex = 0
      ShortCut = 16472
    end
    object actEditPaste: TEditPaste
      Category = 'Edit'
      Caption = 'Вставить'
      Hint = 'Paste'
      ImageIndex = 2
      ShortCut = 16470
    end
  end
  object pmQuery: TPopupMenu
    Left = 182
    Top = 117
    object N7: TMenuItem
      Action = actNew
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object Copy1: TMenuItem
      Action = actEditCopy
    end
    object Cut1: TMenuItem
      Action = actEditCut
    end
    object Paste1: TMenuItem
      Action = actEditPaste
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object actFind1: TMenuItem
      Action = actFind
    end
    object N4: TMenuItem
      Action = actReplace
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object act1: TMenuItem
      Action = actExecute
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object PASCAL1: TMenuItem
      Action = actConvertToPas
    end
    object actConvertToSQL1: TMenuItem
      Action = actConvertToSQL
    end
  end
  object OpenDialog: TOpenDialog
    Filter = 'SQL файлы|*.sql|Все файлы|*.*'
    Left = 368
    Top = 240
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'sql'
    Filter = 'SQL файлы|*.sql|Все файлы|*.*'
    Left = 408
    Top = 240
  end
  object ibqryWork: TIBDataSet
    Transaction = _ibtrEditor
    BeforeClose = ibqryWorkBeforeClose
    ReadTransaction = _ibtrEditor
    Left = 528
    Top = 82
  end
  object imStatistic: TTBImageList
    Left = 108
    Top = 252
    Bitmap = {
      494C010106000900040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000003000000001002000000000000030
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000000000000000000000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000000000000000000000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000000000000000000000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000000000000000000000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000000000000000000000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000000000000000000000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000000000000000000000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000000000000000000000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000000000000000000000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000000000000000000000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000000000000000000000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000000000000000000000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000000000000000000000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000000000000000000000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF000000000000000000000000800000008000000080
      0000008000000080000000800000008000000080000000800000008000000080
      0000008000000080000000800000000000000000000000204000002040000020
      4000002040000020400000204000002040000020400000204000002040000020
      400000204000002040000020400000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF000000000000000000000000800000008000000080
      0000008000000080000000800000008000000080000000800000008000000080
      0000008000000080000000800000000000000000000000204000002040000020
      4000002040000020400000204000002040000020400000204000002040000020
      400000204000002040000020400000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF000000000000000000000000800000008000000080
      0000008000000080000000800000008000000080000000800000008000000080
      0000008000000080000000800000000000000000000000204000002040000020
      4000002040000020400000204000002040000020400000204000002040000020
      400000204000002040000020400000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF000000000000000000000000800000008000000080
      0000008000000080000000800000008000000080000000800000008000000080
      0000008000000080000000800000000000000000000000204000002040000020
      4000002040000020400000204000002040000020400000204000002040000020
      400000204000002040000020400000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF000000000000000000000000800000008000000080
      0000008000000080000000800000008000000080000000800000008000000080
      0000008000000080000000800000000000000000000000204000002040000020
      4000002040000020400000204000002040000020400000204000002040000020
      400000204000002040000020400000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF000000000000000000000000800000008000000080
      0000008000000080000000800000008000000080000000800000008000000080
      0000008000000080000000800000000000000000000000204000002040000020
      4000002040000020400000204000002040000020400000204000002040000020
      400000204000002040000020400000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF000000000000000000000000800000008000000080
      0000008000000080000000800000008000000080000000800000008000000080
      0000008000000080000000800000000000000000000000204000002040000020
      4000002040000020400000204000002040000020400000204000002040000020
      400000204000002040000020400000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF000000000000000000000000800000008000000080
      0000008000000080000000800000008000000080000000800000008000000080
      0000008000000080000000800000000000000000000000204000002040000020
      4000002040000020400000204000002040000020400000204000002040000020
      400000204000002040000020400000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF000000000000000000000000800000008000000080
      0000008000000080000000800000008000000080000000800000008000000080
      0000008000000080000000800000000000000000000000204000002040000020
      4000002040000020400000204000002040000020400000204000002040000020
      400000204000002040000020400000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF000000000000000000000000800000008000000080
      0000008000000080000000800000008000000080000000800000008000000080
      0000008000000080000000800000000000000000000000204000002040000020
      4000002040000020400000204000002040000020400000204000002040000020
      400000204000002040000020400000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF000000000000000000000000800000008000000080
      0000008000000080000000800000008000000080000000800000008000000080
      0000008000000080000000800000000000000000000000204000002040000020
      4000002040000020400000204000002040000020400000204000002040000020
      400000204000002040000020400000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF000000000000000000000000800000008000000080
      0000008000000080000000800000008000000080000000800000008000000080
      0000008000000080000000800000000000000000000000204000002040000020
      4000002040000020400000204000002040000020400000204000002040000020
      400000204000002040000020400000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF000000000000000000000000800000008000000080
      0000008000000080000000800000008000000080000000800000008000000080
      0000008000000080000000800000000000000000000000204000002040000020
      4000002040000020400000204000002040000020400000204000002040000020
      400000204000002040000020400000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF000000000000000000000000800000008000000080
      0000008000000080000000800000008000000080000000800000008000000080
      0000008000000080000000800000000000000000000000204000002040000020
      4000002040000020400000204000002040000020400000204000002040000020
      4000002040000020400000204000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000300000000100010000000000800100000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000}
  end
  object SynCompletionProposal: TSynCompletionProposal
    DefaultType = ctCode
    OnExecute = SynCompletionProposalExecute
    Position = 0
    NbLinesInWindow = 16
    ClSelect = clHighlight
    ClText = clWindowText
    ClSelectedText = clHighlightText
    ClBackground = clWindow
    AnsiStrings = True
    CaseSensitive = False
    ShrinkList = True
    Width = 262
    BiggestWord = 'procedure'
    UsePrettyText = True
    UseInsertList = True
    EndOfTokenChr = '()[].'
    LimitToMatchedText = False
    TriggerChars = '.'
    ShortCut = 16416
    Editor = seQuery
    UseBuiltInTimer = True
    Left = 268
    Top = 232
  end
  object ibdsMonitor: TIBDataSet
    Transaction = ibtrMonitor
    SelectSQL.Strings = (
      'SELECT'
      '  st.mon$attachment_id AS att_id,'
      '  att.mon$timestamp AS att_start,'
      '  st.mon$statement_id AS stmt_id,'
      
        '  (SELECT FIRST 1 u.name FROM gd_user u WHERE u.ibname = att.mon' +
        '$user) AS gd_user,'
      '  /* att.mon$user, */'
      
        '  CAST(SUBSTRING(att.mon$remote_address FROM 1 FOR 36) AS VARCHA' +
        'R(36)) AS remote_address, '
      '  st.mon$state as state,'
      
        '  (SELECT TRIM(rdb$type_name) FROM rdb$types WHERE rdb$type = st' +
        '.mon$state AND rdb$field_name = '#39'MON$STATE'#39') AS state_name,'
      '  st.mon$timestamp AS executed,'
      '  st.mon$sql_text AS sql_text,'
      '  mu.mon$memory_used AS mem_used'
      ''
      'FROM'
      '  mon$statements st'
      '  JOIN mon$attachments att'
      '    ON att.mon$attachment_id = st.mon$attachment_id'
      '  JOIN mon$memory_usage mu'
      '    ON mu.mon$stat_id = st.mon$stat_id'
      ''
      'WHERE'
      '  st.mon$sql_text > '#39#39
      ''
      'ORDER BY'
      '  st.mon$attachment_id,'
      '  st.mon$state DESC,'
      '  st.mon$statement_id'
      ' '
      ' '
      ' '
      ' '
      ' '
      ' ')
    ReadTransaction = ibtrMonitor
    Left = 497
    Top = 369
  end
  object dsMonitor: TDataSource
    DataSet = ibdsMonitor
    Left = 529
    Top = 369
  end
  object ibtrMonitor: TIBTransaction
    Active = False
    DefaultAction = TACommit
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 464
    Top = 369
  end
  object pmSaveFieldToFile: TPopupMenu
    Images = dmImages.il16x16
    Left = 188
    Top = 180
    object nSaveFieldToFile: TMenuItem
      Action = actSaveFieldToFile
    end
  end
end
