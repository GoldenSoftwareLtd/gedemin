object gd_frmSQLMonitor: Tgd_frmSQLMonitor
  Left = 311
  Top = 207
  Width = 760
  Height = 563
  Caption = 'SQL Монитор'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 443
    Width = 752
    Height = 93
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object Label1: TLabel
      Left = 326
      Top = 58
      Width = 59
      Height = 13
      Caption = 'Размер, Кб:'
    end
    object lblSize: TLabel
      Left = 389
      Top = 58
      Width = 24
      Height = 13
      Caption = '9999'
    end
    object btnUpdate: TButton
      Left = 326
      Top = 6
      Width = 91
      Height = 21
      Action = actUpdate
      TabOrder = 0
    end
    object btnClear: TButton
      Left = 326
      Top = 30
      Width = 91
      Height = 21
      Action = actClear
      TabOrder = 2
    end
    object btnFlush: TButton
      Left = 422
      Top = 6
      Width = 91
      Height = 21
      Action = actFlush
      TabOrder = 1
    end
    object gbTraceFlags: TGroupBox
      Left = 7
      Top = 1
      Width = 314
      Height = 73
      Caption = ' Параметры монитора '
      TabOrder = 6
      object chbxTracePrepare: TCheckBox
        Left = 12
        Top = 17
        Width = 65
        Height = 17
        Caption = 'Prepare'
        TabOrder = 0
        OnClick = chbxTracePrepareClick
      end
      object chbxTraceExecute: TCheckBox
        Tag = 1
        Left = 12
        Top = 32
        Width = 65
        Height = 17
        Caption = 'Execute'
        TabOrder = 4
        OnClick = chbxTracePrepareClick
      end
      object chbxTraceFetch: TCheckBox
        Tag = 2
        Left = 12
        Top = 47
        Width = 65
        Height = 17
        Caption = 'Fetch'
        TabOrder = 7
        OnClick = chbxTracePrepareClick
      end
      object chbxTraceError: TCheckBox
        Tag = 3
        Left = 186
        Top = 15
        Width = 65
        Height = 17
        Caption = 'Error'
        TabOrder = 2
        OnClick = chbxTracePrepareClick
      end
      object chbxTraceStatement: TCheckBox
        Tag = 4
        Left = 95
        Top = 17
        Width = 69
        Height = 17
        Caption = 'Statement'
        TabOrder = 1
        OnClick = chbxTracePrepareClick
      end
      object chbxTraceConnect: TCheckBox
        Tag = 5
        Left = 95
        Top = 32
        Width = 65
        Height = 17
        Caption = 'Connect'
        TabOrder = 5
        OnClick = chbxTracePrepareClick
      end
      object chbxTraceTransact: TCheckBox
        Tag = 6
        Left = 95
        Top = 47
        Width = 81
        Height = 17
        Caption = 'Transaction'
        TabOrder = 8
        OnClick = chbxTracePrepareClick
      end
      object chbxTraceBlob: TCheckBox
        Tag = 7
        Left = 186
        Top = 47
        Width = 65
        Height = 17
        Caption = 'Blob'
        TabOrder = 9
        OnClick = chbxTracePrepareClick
      end
      object chbxTraceService: TCheckBox
        Tag = 8
        Left = 186
        Top = 31
        Width = 65
        Height = 17
        Caption = 'Service'
        TabOrder = 6
        OnClick = chbxTracePrepareClick
      end
      object chbxTraceMisc: TCheckBox
        Tag = 9
        Left = 263
        Top = 15
        Width = 45
        Height = 17
        Caption = 'Misc'
        TabOrder = 3
        OnClick = chbxTracePrepareClick
      end
    end
    object btnClose: TButton
      Left = 422
      Top = 54
      Width = 91
      Height = 21
      Action = actClose
      Cancel = True
      TabOrder = 4
    end
    object chbxSQLMonitor: TCheckBox
      Left = 19
      Top = 75
      Width = 409
      Height = 17
      Caption = 
        'Вести лог выполняемых SQL запросов для всех пользователей систем' +
        'ы.'
      TabOrder = 5
      OnClick = chbxSQLMonitorClick
    end
    object btnForm: TButton
      Left = 422
      Top = 30
      Width = 91
      Height = 21
      Action = actForm
      Cancel = True
      TabOrder = 3
    end
  end
  object pc: TPageControl
    Left = 0
    Top = 0
    Width = 752
    Height = 443
    ActivePage = tsSQLMonitor
    Align = alClient
    TabOrder = 1
    OnChange = pcChange
    object tsSQLMonitor: TTabSheet
      Caption = 'SQL Монитор'
      object SynEdit: TSynEdit
        Left = 0
        Top = 0
        Width = 744
        Height = 415
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
        Lines.Strings = (
          '')
        ReadOnly = True
      end
    end
    object tsTransactions: TTabSheet
      Caption = 'Транзакции'
      ImageIndex = 1
      object lvTransactions: TListView
        Left = 0
        Top = 0
        Width = 744
        Height = 385
        Align = alClient
        Columns = <
          item
            Caption = 'N'
            Width = 22
          end
          item
            Caption = 'Name'
            Width = 120
          end
          item
            Caption = 'Owner'
            Width = 140
          end
          item
            Caption = 'Active'
            Width = 42
          end
          item
            AutoSize = True
            Caption = 'Params'
          end>
        GridLines = True
        HideSelection = False
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
      end
      object pnlTransaction: TPanel
        Left = 0
        Top = 385
        Width = 744
        Height = 30
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 1
        object btnRefreshTransactions: TButton
          Left = 5
          Top = 6
          Width = 75
          Height = 21
          Action = actRefreshTransactions
          TabOrder = 0
        end
        object btnStart: TButton
          Left = 88
          Top = 6
          Width = 75
          Height = 21
          Action = actStart
          TabOrder = 1
        end
        object btnCommit: TButton
          Left = 170
          Top = 6
          Width = 75
          Height = 21
          Action = actCommit
          TabOrder = 2
        end
        object btnRollback: TButton
          Left = 253
          Top = 6
          Width = 75
          Height = 21
          Action = actRollback
          TabOrder = 3
        end
        object chbxOnlyActive: TCheckBox
          Left = 344
          Top = 8
          Width = 193
          Height = 17
          Caption = 'Показывать только активные'
          Checked = True
          State = cbChecked
          TabOrder = 4
          OnClick = chbxOnlyActiveClick
        end
      end
    end
    object tsDatasets: TTabSheet
      Caption = 'Datasets'
      ImageIndex = 2
      object Panel2: TPanel
        Left = 0
        Top = 385
        Width = 744
        Height = 30
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 0
        object btnRefreshDatasets: TButton
          Left = 5
          Top = 6
          Width = 75
          Height = 21
          Action = actRefreshDatasets
          TabOrder = 0
        end
        object chbxOnlyActiveDataSet: TCheckBox
          Left = 344
          Top = 8
          Width = 193
          Height = 17
          Caption = 'Показывать только активные'
          Checked = True
          State = cbChecked
          TabOrder = 1
          OnClick = chbxOnlyActiveDataSetClick
        end
      end
      object lvDataSets: TListView
        Left = 0
        Top = 0
        Width = 744
        Height = 385
        Align = alClient
        Columns = <
          item
            Caption = 'N'
            Width = 22
          end
          item
            Caption = 'Name'
            Width = 120
          end
          item
            Caption = 'Owner'
            Width = 160
          end
          item
            Caption = 'Active'
            Width = 42
          end
          item
            Alignment = taRightJustify
            Caption = 'CacheSize'
            Width = 64
          end
          item
            Alignment = taRightJustify
            Caption = 'RecCount'
            Width = 60
          end
          item
            Alignment = taRightJustify
            Caption = 'FldCount'
            Width = 56
          end>
        GridLines = True
        HideSelection = False
        ReadOnly = True
        RowSelect = True
        TabOrder = 1
        ViewStyle = vsReport
      end
    end
  end
  object SynSQLSyn: TSynSQLSyn
    DefaultFilter = 'SQL Files (*.sql)|*.sql'
    SQLDialect = sqlSybase
    Left = 360
    Top = 216
  end
  object ActionList: TActionList
    Left = 568
    Top = 184
    object actUpdate: TAction
      Caption = 'Обновить'
      OnExecute = actUpdateExecute
    end
    object actClear: TAction
      Caption = 'Очистить'
      OnExecute = actClearExecute
    end
    object actFlush: TAction
      Caption = 'Записать в БД'
      OnExecute = actFlushExecute
      OnUpdate = actFlushUpdate
    end
    object actClose: TAction
      Caption = 'Закрыть'
      OnExecute = actCloseExecute
    end
    object actForm: TAction
      Caption = 'SQL запросы'
      OnExecute = actFormExecute
      OnUpdate = actFormUpdate
    end
    object actRefreshTransactions: TAction
      Caption = 'Обновить'
      OnExecute = actRefreshTransactionsExecute
      OnUpdate = actRefreshTransactionsUpdate
    end
    object actStart: TAction
      Caption = 'Start'
      OnExecute = actStartExecute
      OnUpdate = actStartUpdate
    end
    object actCommit: TAction
      Caption = 'Commit'
      OnExecute = actCommitExecute
      OnUpdate = actCommitUpdate
    end
    object actRollback: TAction
      Caption = 'Rollback'
      OnExecute = actRollbackExecute
      OnUpdate = actCommitUpdate
    end
    object actRefreshDatasets: TAction
      Caption = 'Обновить'
      OnExecute = actRefreshDatasetsExecute
      OnUpdate = actRefreshDatasetsUpdate
    end
  end
end
