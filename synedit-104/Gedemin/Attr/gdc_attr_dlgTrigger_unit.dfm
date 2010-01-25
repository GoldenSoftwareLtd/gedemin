inherited gdc_dlgTrigger: Tgdc_dlgTrigger
  Left = 307
  Top = 199
  Width = 435
  Height = 413
  HelpContext = 87
  BorderStyle = bsSizeable
  Caption = 'Редактирование триггера'
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 11
    Top = 357
    Anchors = [akLeft, akBottom]
  end
  inherited btnNew: TButton
    Top = 357
    Anchors = [akLeft, akBottom]
    Enabled = False
  end
  inherited btnOK: TButton
    Left = 280
    Top = 357
    Anchors = [akRight, akBottom]
    Default = False
  end
  inherited btnCancel: TButton
    Left = 352
    Top = 357
    Anchors = [akRight, akBottom]
  end
  inherited btnHelp: TButton
    Top = 357
    Anchors = [akLeft, akBottom]
  end
  object pnHead: TPanel [5]
    Left = 0
    Top = 0
    Width = 427
    Height = 65
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 5
    object Label1: TLabel
      Left = 8
      Top = 13
      Width = 77
      Height = 13
      Caption = 'Наименование:'
    end
    object Label2: TLabel
      Left = 9
      Top = 37
      Width = 22
      Height = 13
      Caption = 'Тип:'
    end
    object Label3: TLabel
      Left = 297
      Top = 13
      Width = 46
      Height = 13
      Caption = 'Позиция:'
    end
    object dbeName: TDBEdit
      Left = 112
      Top = 8
      Width = 169
      Height = 21
      CharCase = ecUpperCase
      DataField = 'triggername'
      DataSource = dsgdcBase
      TabOrder = 0
    end
    object cmbType: TComboBox
      Left = 112
      Top = 32
      Width = 169
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 1
      OnChange = cmbTypeChange
      Items.Strings = (
        'Before Insert'
        'After Insert'
        'Before Update'
        'After Update'
        'Before Delete'
        'After Delete'
        'Before Insert Or Update'
        'After Insert Or Update'
        'Before Insert Or Delete'
        'After Insert Or Delete'
        'Before Update Or Delete'
        'After Update Or Delete'
        'Before Insert Or Update Or Delete'
        'After Insert Or Update Or Delete')
    end
    object dbcActive: TDBCheckBox
      Left = 329
      Top = 34
      Width = 75
      Height = 17
      Caption = 'Активный'
      DataField = 'trigger_inactive'
      DataSource = dsgdcBase
      TabOrder = 2
      ValueChecked = '0'
      ValueUnchecked = '1'
    end
    object dbePos: TDBEdit
      Left = 352
      Top = 9
      Width = 47
      Height = 21
      DataField = 'rdb$trigger_sequence'
      DataSource = dsgdcBase
      TabOrder = 3
    end
  end
  object pnText: TPanel [6]
    Left = 0
    Top = 65
    Width = 427
    Height = 288
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 6
    object smTriggerBody: TSynMemo
      Left = 0
      Top = 0
      Width = 427
      Height = 288
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
    end
  end
  inherited alBase: TActionList
    Left = 270
    Top = 191
  end
  inherited dsgdcBase: TDataSource
    Left = 240
    Top = 191
  end
  inherited pm_dlgG: TPopupMenu
    Left = 312
    Top = 192
  end
  object SynSQLSyn: TSynSQLSyn
    DefaultFilter = 'SQL files (*.sql)|*.sql'
    SQLDialect = sqlInterbase6
    Left = 368
    Top = 136
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    AutoStopAction = saNone
    Left = 192
    Top = 121
  end
end
