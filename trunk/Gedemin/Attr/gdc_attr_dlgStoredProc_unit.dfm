inherited gdc_attr_dlgStoredProc: Tgdc_attr_dlgStoredProc
  Left = 371
  Top = 211
  Width = 586
  Height = 461
  HelpContext = 78
  BorderStyle = bsSizeable
  Caption = 'Редактирование хранимой процедуры'
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 3
    Top = 399
    Height = 22
    Anchors = [akLeft, akBottom]
    TabOrder = 3
  end
  inherited btnNew: TButton
    Left = 75
    Top = 399
    Height = 22
    Anchors = [akLeft, akBottom]
    TabOrder = 4
  end
  inherited btnHelp: TButton
    Left = 147
    Top = 399
    Height = 22
    Anchors = [akLeft, akBottom]
    TabOrder = 5
  end
  inherited btnOK: TButton
    Left = 426
    Top = 399
    Height = 22
    Anchors = [akRight, akBottom]
    TabOrder = 1
  end
  inherited btnCancel: TButton
    Left = 499
    Top = 399
    Height = 22
    Anchors = [akRight, akBottom]
    TabOrder = 2
  end
  object pcStoredProc: TPageControl [5]
    Left = 0
    Top = 0
    Width = 570
    Height = 395
    ActivePage = tsBodySP
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    OnChange = pcStoredProcChange
    OnChanging = pcStoredProcChanging
    object tsNameSP: TTabSheet
      Caption = 'Наименование'
      object Label1: TLabel
        Left = 8
        Top = 12
        Width = 133
        Height = 13
        Caption = 'Наименование процедуры'
      end
      object Label2: TLabel
        Left = 8
        Top = 41
        Width = 109
        Height = 13
        Caption = 'Описание процедуры'
      end
      object dbedProcedureName: TDBEdit
        Left = 153
        Top = 8
        Width = 401
        Height = 21
        CharCase = ecUpperCase
        DataField = 'PROCEDURENAME'
        DataSource = dsgdcBase
        MaxLength = 31
        TabOrder = 0
        OnEnter = dbedProcedureNameEnter
        OnKeyDown = dbedProcedureNameKeyDown
        OnKeyPress = dbedProcedureNameKeyPress
      end
      object dbmDescription: TDBMemo
        Left = 153
        Top = 39
        Width = 401
        Height = 89
        DataField = 'RDB$DESCRIPTION'
        DataSource = dsgdcBase
        TabOrder = 1
      end
    end
    object tsBodySP: TTabSheet
      Caption = 'Текст процедуры'
      ImageIndex = 1
      object pProcedureBody: TPanel
        Left = 0
        Top = 0
        Width = 562
        Height = 367
        Align = alClient
        BevelInner = bvLowered
        BevelOuter = bvNone
        BorderWidth = 4
        TabOrder = 0
        object smProcedureBody: TSynMemo
          Left = 5
          Top = 5
          Width = 552
          Height = 357
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
        end
      end
    end
  end
  object SynSQLSyn: TSynSQLSyn
    DefaultFilter = 'SQL files (*.sql)|*.sql'
    SQLDialect = sqlInterbase6
    Left = 316
    Top = 152
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 196
    Top = 176
  end
end
