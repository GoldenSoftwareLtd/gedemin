object frmSQLEditorSyn: TfrmSQLEditorSyn
  Left = 391
  Top = 156
  Width = 691
  Height = 556
  HelpContext = 121
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'SQL ��������'
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
    Width = 683
    Height = 499
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object pcMain: TSuperPageControl
      Left = 9
      Top = 26
      Width = 665
      Height = 464
      BorderStyle = bsNone
      TabsVisible = True
      ActivePage = tsQuery
      Align = alClient
      TabHeight = 23
      TabOrder = 0
      OnChange = pcMainChange
      OnChanging = pcMainChanging
      object tsQuery: TSuperTabSheet
        BorderWidth = 3
        Caption = '��������������'
        object Splitter1: TSplitter
          Left = 0
          Top = 357
          Width = 659
          Height = 4
          Cursor = crVSplit
          Align = alBottom
        end
        object seQuery: TSynEdit
          Left = 0
          Top = 0
          Width = 659
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
        end
        object mmPlan: TMemo
          Left = 0
          Top = 361
          Width = 659
          Height = 74
          Align = alBottom
          ReadOnly = True
          TabOrder = 1
        end
      end
      object tsResult: TSuperTabSheet
        BorderWidth = 3
        Caption = '���������'
        ImageIndex = 1
        object pnlNavigator: TPanel
          Left = 0
          Top = 0
          Width = 659
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
            Top = 0
            Width = 98
            Height = 22
            Caption = 'tbResult'
            Images = dmImages.il16x16
            TabOrder = 1
            object TBItem14: TTBItem
              Action = actEditBusinessObject
            end
            object TBItem15: TTBItem
              Action = actDeleteBusinessObject
            end
            object TBSeparatorItem16: TTBSeparatorItem
            end
            object TBItem26: TTBItem
              Action = actShowGrid
              Caption = '�������� �������'
            end
            object TBItem27: TTBItem
              Action = actShowRecord
              Caption = '�������� ������'
            end
          end
        end
        object dbgResult: TgsDBGrid
          Left = 0
          Top = 26
          Width = 659
          Height = 409
          HelpContext = 3
          Align = alClient
          DataSource = dsResult
          Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
          ReadOnly = True
          TabOrder = 1
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
        object pnlRecord: TPanel
          Left = 0
          Top = 26
          Width = 659
          Height = 409
          Align = alClient
          BevelInner = bvLowered
          BevelOuter = bvNone
          TabOrder = 2
          Visible = False
          object sbRecord: TScrollBox
            Left = 1
            Top = 1
            Width = 657
            Height = 407
            Align = alClient
            BorderStyle = bsNone
            TabOrder = 0
          end
        end
      end
      object tsHistory: TSuperTabSheet
        BorderWidth = 3
        Caption = '������� ��������'
        object Splitter2: TSplitter
          Left = 0
          Top = 432
          Width = 659
          Height = 3
          Cursor = crVSplit
          Align = alBottom
        end
        object Panel2: TPanel
          Left = 0
          Top = 0
          Width = 659
          Height = 432
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 0
          object Label14: TLabel
            Left = 8
            Top = 10
            Width = 42
            Height = 13
            Caption = '������:'
          end
          object eFilter: TEdit
            Left = 64
            Top = 8
            Width = 591
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 0
            OnChange = eFilterChange
          end
          object lvHistory: TListView
            Left = 0
            Top = 36
            Width = 659
            Height = 396
            Align = alBottom
            Anchors = [akLeft, akTop, akRight, akBottom]
            Columns = <
              item
                Caption = '#'
              end
              item
                AutoSize = True
                Caption = '������'
              end>
            GridLines = True
            HideSelection = False
            ReadOnly = True
            RowSelect = True
            ParentShowHint = False
            PopupMenu = pmHistory
            ShowHint = True
            TabOrder = 1
            ViewStyle = vsReport
            OnDblClick = lvHistoryDblClick
            OnInfoTip = lvHistoryInfoTip
          end
        end
      end
      object tsStatistic: TSuperTabSheet
        HelpContext = 122
        BorderWidth = 3
        Caption = '����������'
        ImageIndex = 2
        object tsStatisticExtra: TSuperPageControl
          Left = 0
          Top = 26
          Width = 659
          Height = 409
          BorderStyle = bsNone
          TabsVisible = True
          ActivePage = tsGraphStatistic
          Align = alClient
          TabHeight = 23
          TabOrder = 0
          object tsGraphStatistic: TSuperTabSheet
            Caption = '����������� �������������'
            object ChReads: TChart
              Left = 0
              Top = 0
              Width = 651
              Height = 328
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
            Caption = '�������������'
            object Panel1: TPanel
              Left = 0
              Top = 0
              Width = 184
              Height = 386
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
                  Caption = '����� ����������'
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
                  Caption = '����������'
                end
                object Label3: TLabel
                  Left = 8
                  Top = 56
                  Width = 62
                  Height = 13
                  Caption = '����������'
                end
                object Label4: TLabel
                  Left = 8
                  Top = 80
                  Width = 50
                  Height = 13
                  Caption = '��������'
                end
                object Label5: TLabel
                  Left = 8
                  Top = 112
                  Width = 46
                  Height = 13
                  Caption = '������'
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
                  Caption = '�������'
                end
                object Label7: TLabel
                  Left = 8
                  Top = 160
                  Width = 73
                  Height = 13
                  Caption = '������������'
                end
                object Label8: TLabel
                  Left = 8
                  Top = 184
                  Width = 32
                  Height = 13
                  Caption = '�����'
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
                  Caption = '��������'
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
                  Caption = '������'
                end
                object Label11: TLabel
                  Left = 8
                  Top = 264
                  Width = 35
                  Height = 13
                  Caption = '������'
                end
                object Label12: TLabel
                  Left = 8
                  Top = 288
                  Width = 50
                  Height = 13
                  Caption = '��������'
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
              Width = 475
              Height = 386
              Align = alClient
              Columns = <
                item
                  Caption = '��� �������'
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
          Width = 659
          Height = 26
          object tbStatistic: TTBToolbar
            Left = 0
            Top = 0
            Caption = 'tbStatistic'
            DefaultDock = TBDock5
            DockMode = dmCannotFloatOrChangeDocks
            FullSize = True
            Images = imStatistic
            ParentShowHint = False
            ShowHint = True
            TabOrder = 0
            object TBItem17: TTBItem
              Caption = '�������������� ������'
              Checked = True
              DisplayMode = nbdmImageAndText
              Hint = '�������������� ������'
              ImageIndex = 1
              OnClick = actRefreshChartExecute
            end
            object TBSeparatorItem9: TTBSeparatorItem
            end
            object TBItem18: TTBItem
              Caption = '����������������� ������'
              Checked = True
              DisplayMode = nbdmImageAndText
              Hint = '����������������� ������'
              ImageIndex = 0
              OnClick = actRefreshChartExecute
            end
            object TBSeparatorItem10: TTBSeparatorItem
            end
            object TBItem19: TTBItem
              Caption = '�������'
              DisplayMode = nbdmImageAndText
              Hint = '�������'
              ImageIndex = 4
              OnClick = actRefreshChartExecute
            end
            object TBSeparatorItem11: TTBSeparatorItem
            end
            object TBItem20: TTBItem
              Caption = '����������'
              DisplayMode = nbdmImageAndText
              Hint = '����������'
              ImageIndex = 2
              OnClick = actRefreshChartExecute
            end
            object TBSeparatorItem12: TTBSeparatorItem
            end
            object TBItem21: TTBItem
              Caption = '��������'
              DisplayMode = nbdmImageAndText
              Hint = '��������'
              ImageIndex = 3
              OnClick = actRefreshChartExecute
            end
            object TBSeparatorItem13: TTBSeparatorItem
            end
            object tbItemAllRecord: TTBItem
              Caption = '����� �������'
              DisplayMode = nbdmImageAndText
              Hint = '����� �������'
              ImageIndex = 5
              OnClick = actRefreshChartExecute
            end
          end
        end
      end
      object tsLog: TSuperTabSheet
        BorderWidth = 3
        Caption = '������'
        ImageIndex = 3
        object mmLog: TMemo
          Left = 0
          Top = 0
          Width = 651
          Height = 435
          Align = alClient
          ScrollBars = ssVertical
          TabOrder = 0
        end
      end
      object tsTransaction: TSuperTabSheet
        BorderWidth = 3
        Caption = '����������'
        object mTransaction: TMemo
          Left = 0
          Top = 0
          Width = 659
          Height = 149
          Align = alTop
          Lines.Strings = (
            '')
          TabOrder = 0
        end
        object mTransactionParams: TMemo
          Left = 0
          Top = 190
          Width = 659
          Height = 245
          Align = alClient
          Color = clBtnFace
          ReadOnly = True
          ScrollBars = ssVertical
          TabOrder = 2
        end
        object Panel3: TPanel
          Left = 0
          Top = 149
          Width = 659
          Height = 41
          Align = alTop
          Alignment = taLeftJustify
          BevelOuter = bvNone
          TabOrder = 1
          object Label15: TLabel
            Left = 0
            Top = 24
            Width = 242
            Height = 13
            Caption = '���������� �������� ���������� ����������:'
          end
          object chbxAutoCommitDDL: TCheckBox
            Left = 0
            Top = 3
            Width = 409
            Height = 17
            Caption = '������������� ������������ ���������� �� ��������� ����������'
            TabOrder = 0
            OnClick = chbxAutoCommitDDLClick
          end
        end
      end
      object tsMonitor: TSuperTabSheet
        BorderWidth = 3
        Caption = '������� ��������'
        object Panel4: TPanel
          Left = 0
          Top = 0
          Width = 651
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
        object ibgrMonitor: TgsIBGrid
          Left = 0
          Top = 26
          Width = 651
          Height = 409
          Align = alClient
          DataSource = dsMonitor
          Options = [dgTitles, dgColumnResize, dgColLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
          ReadOnly = True
          TabOrder = 1
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
      end
      object tsReport: TSuperTabSheet
        Caption = '������'
        object FfrxPreview: TfrxPreview
          Left = 0
          Top = 0
          Width = 665
          Height = 441
          Align = alClient
          OutlineVisible = False
          OutlineWidth = 120
          ThumbnailVisible = False
          UseReportHints = True
        end
      end
    end
    object TBDock1: TTBDock
      Left = 0
      Top = 0
      Width = 683
      Height = 26
      object TBToolbar1: TTBToolbar
        Left = 0
        Top = 0
        Caption = '������ ������������'
        CloseButton = False
        FullSize = True
        Images = dmImages.il16x16
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        object TBItem13: TTBItem
          Action = actNew
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
          ImageIndex = 181
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
        object TBItem28: TTBItem
          Action = actQueryBuilder
          Caption = '����������� ��������'
        end
        object TBItem7: TTBItem
          Action = actExport
          Images = dmImages.ImageList
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
        object Label13: TLabel
          Left = 393
          Top = 4
          Width = 51
          Height = 13
          Caption = '�������: '
        end
        object iblkupTable: TgsIBLookupComboBox
          Left = 444
          Top = 0
          Width = 145
          Height = 21
          HelpContext = 1
          Fields = 'lname'
          ListTable = 'at_relations'
          ListField = 'relationname'
          KeyField = 'id'
          SortOrder = soAsc
          gdClassName = 'TgdcTable'
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
      Height = 464
      Position = dpLeft
    end
    object TBDock3: TTBDock
      Left = 674
      Top = 26
      Width = 9
      Height = 464
      Position = dpRight
    end
    object TBDock4: TTBDock
      Left = 0
      Top = 490
      Width = 683
      Height = 9
      Position = dpBottom
    end
  end
  object pModal: TPanel
    Left = 0
    Top = 499
    Width = 683
    Height = 30
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    Visible = False
    object Button1: TButton
      Left = 515
      Top = 4
      Width = 75
      Height = 21
      Action = actOk
      Anchors = [akRight, akBottom]
      TabOrder = 0
    end
    object Button2: TButton
      Left = 596
      Top = 4
      Width = 75
      Height = 21
      Action = actCancel
      Anchors = [akRight, akBottom]
      TabOrder = 1
    end
  end
  object ibtrEditor: TIBTransaction
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
      Caption = '�������� SQL ������'
      Hint = '�������� SQL ������'
      ImageIndex = 189
      OnExecute = actShowMonitorSQLExecute
      OnUpdate = actShowMonitorSQLUpdate
    end
    object actExecute: TAction
      Caption = '���������'
      Hint = '���������'
      ImageIndex = 0
      ShortCut = 120
      OnExecute = actExecuteExecute
      OnUpdate = actExecuteUpdate
    end
    object actDisconnectUser: TAction
      Category = 'Monitor'
      Caption = '����������� ������������'
      Hint = '����������� ������������'
      ImageIndex = 34
      OnExecute = actDisconnectUserExecute
      OnUpdate = actDisconnectUserUpdate
    end
    object actPrepare: TAction
      Caption = '�����������'
      Hint = '�����������'
      ImageIndex = 1
      ShortCut = 16504
      OnExecute = actPrepareExecute
      OnUpdate = actPrepareUpdate
    end
    object actCommit: TAction
      Caption = 'actCommit'
      Hint = '�������'
      ImageIndex = 2
      ShortCut = 49219
      OnExecute = actCommitExecute
      OnUpdate = actCommitUpdate
    end
    object actRollback: TAction
      Caption = 'actRollback'
      Hint = '��������'
      ImageIndex = 3
      ShortCut = 49234
      OnExecute = actRollbackExecute
      OnUpdate = actCommitUpdate
    end
    object actFind: TAction
      Caption = '�����...'
      Hint = '�����'
      ImageIndex = 23
      ShortCut = 16454
      OnExecute = actFindExecute
      OnUpdate = actFindUpdate
    end
    object actExport: TAction
      Caption = 'actExport'
      Hint = '�������'
      ImageIndex = 5
      ShortCut = 16453
    end
    object actOptions: TAction
      Caption = '�������� ���������'
      Hint = '�������� ���������'
      ImageIndex = 30
      OnExecute = actOptionsExecute
      OnUpdate = actOptionsUpdate
    end
    object actReplace: TAction
      Caption = '������...'
      Hint = '������'
      ImageIndex = 22
      OnExecute = actReplaceExecute
      OnUpdate = actOpenScriptUpdate
    end
    object actClearHistory: TAction
      Category = 'History'
      Caption = '�������� �������'
      OnExecute = actClearHistoryExecute
    end
    object actDeleteHistItem: TAction
      Category = 'History'
      Caption = '������� ������'
      OnExecute = actDeleteHistItemExecute
      OnUpdate = actDeleteHistItemUpdate
    end
    object actOpenScript: TAction
      Caption = 'actOpenScript'
      Hint = '��������� ������'
      ImageIndex = 27
      OnExecute = actOpenScriptExecute
      OnUpdate = actOpenScriptUpdate
    end
    object actSaveScript: TAction
      Caption = 'actSaveScript'
      Hint = '��������� ������'
      ImageIndex = 25
      OnExecute = actSaveScriptExecute
      OnUpdate = actSaveScriptUpdate
    end
    object actNew: TAction
      Caption = '����� ������'
      Hint = '�������� ����� �������'
      ImageIndex = 123
      OnExecute = actNewExecute
    end
    object actNextQuery: TAction
      Caption = '��������� ������'
      ImageIndex = 46
      OnExecute = actNextQueryExecute
      OnUpdate = actNextQueryUpdate
    end
    object actPrevQuery: TAction
      Caption = '���������� ������'
      ImageIndex = 45
      OnExecute = actPrevQueryExecute
      OnUpdate = actPrevQueryUpdate
    end
    object actOk: TAction
      Caption = 'OK'
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Caption = '������'
      OnExecute = actCancelExecute
    end
    object actEditBusinessObject: TAction
      Category = 'Result'
      Caption = '������������� ������-������...'
      ImageIndex = 1
      OnExecute = actEditBusinessObjectExecute
      OnUpdate = actEditBusinessObjectUpdate
    end
    object actDeleteBusinessObject: TAction
      Category = 'Result'
      Caption = '������� ������-������'
      ImageIndex = 2
      OnExecute = actDeleteBusinessObjectExecute
      OnUpdate = actDeleteBusinessObjectUpdate
    end
    object actParse: TAction
      Caption = '��������� ������'
      ImageIndex = 265
      OnExecute = actParseExecute
      OnUpdate = actParseUpdate
    end
    object actRefreshChart: TAction
      Caption = 'actRefreshChart'
      OnExecute = actRefreshChartExecute
    end
    object actCopyAllHistory: TAction
      Category = 'History'
      Caption = '���������� ��� � �����'
      OnExecute = actCopyAllHistoryExecute
    end
    object actRefreshMonitor: TAction
      Category = 'Monitor'
      Caption = '��������'
      Hint = '��������'
      ImageIndex = 17
      OnExecute = actRefreshMonitorExecute
    end
    object actDeleteStatement: TAction
      Category = 'Monitor'
      Caption = '�������� ���������� �������'
      Hint = '�������� ���������� �������'
      ImageIndex = 117
      OnExecute = actDeleteStatementExecute
      OnUpdate = actDeleteStatementUpdate
    end
    object actShowGrid: TAction
      Category = 'Result'
      Caption = 'actShowGrid'
      Hint = '�������� �������'
      ImageIndex = 220
      OnExecute = actShowGridExecute
      OnUpdate = actShowGridUpdate
    end
    object actShowRecord: TAction
      Category = 'Result'
      Caption = 'actShowRecord'
      Hint = '�������� ������'
      ImageIndex = 176
      OnExecute = actShowRecordExecute
      OnUpdate = actShowGridUpdate
    end
    object actQueryBuilder: TAction
      Caption = 'actQueryBuilder'
      Hint = '����������� ��������'
      ImageIndex = 74
      OnExecute = actQueryBuilderExecute
      OnUpdate = actQueryBuilderUpdate
    end
  end
  object ibsqlPlan: TIBSQL
    Transaction = ibtrEditor
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
  object FindDialog1: TFindDialog
    OnFind = FindDialog1Find
    Left = 256
    Top = 80
  end
  object ReplaceDialog1: TReplaceDialog
    OnFind = FindDialog1Find
    OnReplace = ReplaceDialog1Replace
    Left = 360
    Top = 120
  end
  object pmHistory: TPopupMenu
    Left = 260
    Top = 113
    object N8: TMenuItem
      Action = actCopyAllHistory
    end
    object N9: TMenuItem
      Caption = '-'
    end
    object N2: TMenuItem
      Action = actDeleteHistItem
    end
    object N1: TMenuItem
      Action = actClearHistory
    end
  end
  object ActionList2: TActionList
    Left = 126
    Top = 117
    object actEditCopy: TEditCopy
      Category = 'Edit'
      Caption = '����������'
      Hint = 'Copy'
      ImageIndex = 1
      ShortCut = 16451
    end
    object actEditCut: TEditCut
      Category = 'Edit'
      Caption = '��������'
      Hint = 'Cut'
      ImageIndex = 0
      ShortCut = 16472
    end
    object actEditPaste: TEditPaste
      Category = 'Edit'
      Caption = '��������'
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
  end
  object OpenDialog: TOpenDialog
    Filter = 'SQL �����|*.sql|��� �����|*.*'
    Left = 368
    Top = 240
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'sql'
    Filter = 'SQL �����|*.sql|��� �����|*.*'
    Left = 408
    Top = 240
  end
  object ibqryWork: TIBDataSet
    Transaction = ibtrEditor
    BeforeClose = ibqryWorkBeforeClose
    ReadTransaction = ibtrEditor
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
      '  st.mon$attachment_id,'
      '  att.mon$timestamp AS att_start,'
      '  st.mon$statement_id,'
      
        '  (SELECT FIRST 1 u.name FROM gd_user u WHERE u.ibname = att.mon' +
        '$user) AS gd_user,'
      '  att.mon$user,'
      '  att.mon$remote_address, '
      '  st.mon$state,'
      '  st.mon$timestamp,'
      '  st.mon$sql_text'
      ''
      'FROM'
      '  mon$statements st'
      '  JOIN mon$attachments att'
      '    ON att.mon$attachment_id = st.mon$attachment_id'
      ''
      'WHERE'
      '  st.mon$sql_text > '#39#39
      ''
      'ORDER BY'
      '  st.mon$attachment_id,'
      '  st.mon$state DESC,'
      '  st.mon$statement_id')
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
    AutoStopAction = saNone
    Left = 464
    Top = 369
  end
  object FReport: TfrxReport
    Version = '4.7.5'
    DotMatrixReport = False
    IniFile = '\Software\Fast Reports'
    Preview = FfrxPreview
    PreviewOptions.Buttons = [pbPrint, pbLoad, pbSave, pbExport, pbZoom, pbFind, pbOutline, pbPageSetup, pbTools, pbEdit, pbNavigator, pbExportQuick]
    PreviewOptions.Zoom = 1
    PrintOptions.Printer = 'Default'
    PrintOptions.PrintOnSheet = 0
    ReportOptions.CreateDate = 38006.7863842593
    ReportOptions.LastChange = 39852.9561858681
    ScriptLanguage = 'PascalScript'
    ScriptText.Strings = (
      'begin'
      ''
      'end.')
    OnBeforePrint = FReportBeforePrint
    Left = 133
    Top = 207
    Datasets = <>
    Variables = <>
    Style = <>
    object Data: TfrxDataPage
      Height = 1000
      Width = 1000
    end
    object Page1: TfrxReportPage
      Orientation = poLandscape
      PaperWidth = 297
      PaperHeight = 210
      PaperSize = 9
      LeftMargin = 10
      RightMargin = 10
      TopMargin = 10
      BottomMargin = 10
      object MasterData1: TfrxMasterData
        Height = 83
        Top = 105.82684
        Width = 1046.92981
        RowCount = 1
        object Cross1: TfrxCrossView
          Width = 105
          Height = 83
          ShowHint = False
          DownThenAcross = False
          ShowColumnTotal = False
          ShowRowHeader = False
          ShowRowTotal = False
          ShowTitle = False
          Memos = {
            3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
            662D38223F3E3C63726F73733E3C63656C6C6D656D6F733E3C546672784D656D
            6F56696577204C6566743D2232302220546F703D223134372E38323638342220
            57696474683D22363522204865696768743D2232312220526573747269637469
            6F6E733D223234222053686F7748696E743D2246616C73652220416C6C6F7745
            787072657373696F6E733D2246616C736522204672616D652E5479703D223135
            2220476170583D22332220476170593D2233222048416C69676E3D2268614365
            6E74657222205374796C653D2263656C6C222056416C69676E3D22766143656E
            7465722220546578743D2230222F3E3C546672784D656D6F5669657720546167
            3D223122204C6566743D22302220546F703D2230222057696474683D22302220
            4865696768743D223022205265737472696374696F6E733D2238222053686F77
            48696E743D2246616C73652220416C6C6F7745787072657373696F6E733D2246
            616C736522204672616D652E5479703D2231352220476170583D223322204761
            70593D2233222048416C69676E3D226861526967687422205374796C653D2263
            656C6C222056416C69676E3D22766143656E7465722220546578743D22222F3E
            3C546672784D656D6F56696577205461673D223222204C6566743D2230222054
            6F703D2230222057696474683D223022204865696768743D2230222052657374
            72696374696F6E733D2238222053686F7748696E743D2246616C73652220416C
            6C6F7745787072657373696F6E733D2246616C736522204672616D652E547970
            3D2231352220476170583D22332220476170593D2233222048416C69676E3D22
            6861526967687422205374796C653D2263656C6C222056416C69676E3D227661
            43656E7465722220546578743D22222F3E3C546672784D656D6F566965772054
            61673D223322204C6566743D22302220546F703D2230222057696474683D2230
            22204865696768743D223022205265737472696374696F6E733D223822205368
            6F7748696E743D2246616C73652220416C6C6F7745787072657373696F6E733D
            2246616C736522204672616D652E5479703D2231352220476170583D22332220
            476170593D2233222048416C69676E3D226861526967687422205374796C653D
            2263656C6C222056416C69676E3D22766143656E7465722220546578743D2222
            2F3E3C2F63656C6C6D656D6F733E3C63656C6C6865616465726D656D6F733E3C
            546672784D656D6F56696577204C6566743D22302220546F703D223022205769
            6474683D223022204865696768743D223022205265737472696374696F6E733D
            2238222053686F7748696E743D2246616C73652220416C6C6F77457870726573
            73696F6E733D2246616C736522204672616D652E5479703D2231352220476170
            583D22332220476170593D2233222056416C69676E3D22766143656E74657222
            20546578743D22222F3E3C546672784D656D6F56696577204C6566743D223022
            20546F703D2230222057696474683D223022204865696768743D223022205265
            737472696374696F6E733D2238222053686F7748696E743D2246616C73652220
            416C6C6F7745787072657373696F6E733D2246616C736522204672616D652E54
            79703D2231352220476170583D22332220476170593D2233222056416C69676E
            3D22766143656E7465722220546578743D22222F3E3C2F63656C6C6865616465
            726D656D6F733E3C636F6C756D6E6D656D6F733E3C546672784D656D6F566965
            77205461673D2231303022204C6566743D2232302220546F703D223132352E38
            32363834222057696474683D22363522204865696768743D2232322220526573
            7472696374696F6E733D223234222053686F7748696E743D2246616C73652220
            416C6C6F7745787072657373696F6E733D2246616C73652220436F6C6F723D22
            35323437392220466F6E742E436861727365743D22312220466F6E742E436F6C
            6F723D22302220466F6E742E4865696768743D222D31332220466F6E742E4E61
            6D653D22417269616C2220466F6E742E5374796C653D223122204672616D652E
            5479703D2231352220476170583D22332220476170593D2233222048416C6967
            6E3D22686143656E7465722220506172656E74466F6E743D2246616C73652220
            5374796C653D22636F6C756D6E222056416C69676E3D22766143656E74657222
            20546578743D22222F3E3C2F636F6C756D6E6D656D6F733E3C636F6C756D6E74
            6F74616C6D656D6F733E3C546672784D656D6F56696577205461673D22333030
            22204C6566743D22302220546F703D2230222057696474683D22302220486569
            6768743D223022205265737472696374696F6E733D2238222056697369626C65
            3D2246616C7365222053686F7748696E743D2246616C73652220416C6C6F7745
            787072657373696F6E733D2246616C73652220466F6E742E436861727365743D
            22312220466F6E742E436F6C6F723D22302220466F6E742E4865696768743D22
            2D31332220466F6E742E4E616D653D22417269616C2220466F6E742E5374796C
            653D223122204672616D652E5479703D2231352220476170583D223322204761
            70593D2233222048416C69676E3D22686143656E7465722220506172656E7446
            6F6E743D2246616C736522205374796C653D22636F6C6772616E64222056416C
            69676E3D22766143656E7465722220546578743D224772616E6420546F74616C
            222F3E3C2F636F6C756D6E746F74616C6D656D6F733E3C636F726E65726D656D
            6F733E3C546672784D656D6F56696577204C6566743D22302220546F703D2230
            222057696474683D2232303022204865696768743D2230222052657374726963
            74696F6E733D2238222056697369626C653D2246616C7365222053686F774869
            6E743D2246616C73652220416C6C6F7745787072657373696F6E733D2246616C
            736522204672616D652E5479703D2231352220476170583D2233222047617059
            3D2233222048416C69676E3D22686143656E746572222056416C69676E3D2276
            6143656E7465722220546578743D22222F3E3C546672784D656D6F5669657720
            4C6566743D2232302220546F703D223132352E3832363834222057696474683D
            22363522204865696768743D223022205265737472696374696F6E733D223822
            2056697369626C653D2246616C7365222053686F7748696E743D2246616C7365
            2220416C6C6F7745787072657373696F6E733D2246616C736522204672616D65
            2E5479703D2231352220476170583D22332220476170593D2233222048416C69
            676E3D22686143656E746572222056416C69676E3D22766143656E7465722220
            546578743D22222F3E3C546672784D656D6F56696577204C6566743D22302220
            546F703D2230222057696474683D223022204865696768743D22302220526573
            7472696374696F6E733D2238222056697369626C653D2246616C736522205368
            6F7748696E743D2246616C73652220416C6C6F7745787072657373696F6E733D
            2246616C736522204672616D652E5479703D2231352220476170583D22332220
            476170593D2233222048416C69676E3D22686143656E746572222056416C6967
            6E3D22766143656E7465722220546578743D22222F3E3C546672784D656D6F56
            696577204C6566743D22302220546F703D2230222057696474683D2232303022
            204865696768743D223022205265737472696374696F6E733D2238222053686F
            7748696E743D2246616C73652220416C6C6F7745787072657373696F6E733D22
            46616C736522204672616D652E5479703D2231352220476170583D2233222047
            6170593D2233222048416C69676E3D22686143656E746572222056416C69676E
            3D22766143656E7465722220546578743D22222F3E3C2F636F726E65726D656D
            6F733E3C726F776D656D6F733E3C546672784D656D6F56696577205461673D22
            32303022204C6566743D2231302220546F703D223332222057696474683D2232
            303022204865696768743D22313030303022205265737472696374696F6E733D
            223234222053686F7748696E743D2246616C73652220416C6C6F774578707265
            7373696F6E733D2246616C736522204672616D652E5479703D22313522204761
            70583D22332220476170593D2233222048416C69676E3D22686143656E746572
            22205374796C653D22726F77222056416C69676E3D22766143656E7465722220
            546578743D22222F3E3C2F726F776D656D6F733E3C726F77746F74616C6D656D
            6F733E3C546672784D656D6F56696577205461673D2234303022204C6566743D
            22302220546F703D2230222057696474683D223022204865696768743D223022
            205265737472696374696F6E733D2238222056697369626C653D2246616C7365
            222053686F7748696E743D2246616C73652220416C6C6F774578707265737369
            6F6E733D2246616C73652220466F6E742E436861727365743D22312220466F6E
            742E436F6C6F723D22302220466F6E742E4865696768743D222D31332220466F
            6E742E4E616D653D22417269616C2220466F6E742E5374796C653D2231222046
            72616D652E5479703D2231352220476170583D22332220476170593D22332220
            48416C69676E3D22686143656E7465722220506172656E74466F6E743D224661
            6C736522205374796C653D22726F776772616E64222056416C69676E3D227661
            43656E7465722220546578743D224772616E6420546F74616C222F3E3C2F726F
            77746F74616C6D656D6F733E3C63656C6C66756E6374696F6E733E3C6974656D
            20302F3E3C2F63656C6C66756E6374696F6E733E3C636F6C756D6E736F72743E
            3C6974656D20322F3E3C2F636F6C756D6E736F72743E3C726F77736F72743E3C
            6974656D20302F3E3C2F726F77736F72743E3C2F63726F73733E}
        end
      end
      object PageFooter1: TfrxPageFooter
        Height = 22.67718
        Top = 249.44898
        Width = 1046.92981
        object Memo1: TfrxMemoView
          Left = 7.55906
          Width = 79.37013
          Height = 18.89765
          ShowHint = False
          Memo.UTF8 = (
            '[Page]')
        end
      end
      object ReportTitle1: TfrxReportTitle
        Height = 26.45671
        Top = 18.89765
        Width = 1046.92981
        object Memo2: TfrxMemoView
          Left = 453.5436
          Top = 3.77953
          Width = 158.74026
          Height = 18.89765
          ShowHint = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = [fsBold]
          HAlign = haCenter
          Memo.UTF8 = (
            'Результат запроса')
          ParentFont = False
        end
      end
    end
  end
end
