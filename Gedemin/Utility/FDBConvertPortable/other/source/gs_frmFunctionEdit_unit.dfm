object frmFunctionEdit: TfrmFunctionEdit
  Left = 275
  Top = 63
  Width = 935
  Height = 696
  Caption = '��������������'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 174
    Width = 919
    Height = 3
    Cursor = crVSplit
    Align = alTop
  end
  object pnlSynEdit: TPanel
    Left = 0
    Top = 177
    Width = 919
    Height = 444
    Align = alClient
    TabOrder = 0
    object seFunction: TSynEdit
      Left = 1
      Top = 24
      Width = 917
      Height = 419
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
      Gutter.AutoSize = True
      Gutter.Font.Charset = DEFAULT_CHARSET
      Gutter.Font.Color = clWindowText
      Gutter.Font.Height = -11
      Gutter.Font.Name = 'Terminal'
      Gutter.Font.Style = []
      Gutter.LeftOffset = 0
      Gutter.ShowLineNumbers = True
      Gutter.UseFontStyle = False
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
    end
    object pnlFunctionLabel: TPanel
      Left = 1
      Top = 1
      Width = 917
      Height = 23
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 1
      object lblFunction: TLabel
        Left = 8
        Top = 5
        Width = 29
        Height = 13
        Caption = 'SQL:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object pnlComment: TPanel
        Left = 640
        Top = 0
        Width = 277
        Height = 23
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 0
        object btnComment: TButton
          Left = 21
          Top = 2
          Width = 116
          Height = 19
          Action = actComment
          TabOrder = 0
        end
        object btnUncomment: TButton
          Left = 144
          Top = 2
          Width = 120
          Height = 19
          Action = actUncomment
          TabOrder = 1
        end
      end
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 621
    Width = 919
    Height = 37
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object pnlBottomRight: TPanel
      Left = 664
      Top = 0
      Width = 255
      Height = 37
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object btnSave: TButton
        Left = 87
        Top = 8
        Width = 75
        Height = 25
        Action = actSave
        ModalResult = 1
        TabOrder = 0
      end
      object btnSkip: TButton
        Left = 171
        Top = 8
        Width = 75
        Height = 25
        Action = actCancel
        ModalResult = 2
        TabOrder = 1
      end
    end
    object btnStopConvert: TButton
      Left = 12
      Top = 8
      Width = 157
      Height = 25
      Action = actStopConvert
      ModalResult = 3
      TabOrder = 1
    end
  end
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 919
    Height = 174
    Align = alTop
    TabOrder = 2
    object Splitter2: TSplitter
      Left = 423
      Top = 1
      Width = 3
      Height = 172
      Cursor = crHSplit
      Align = alRight
    end
    object pnlError: TPanel
      Left = 1
      Top = 1
      Width = 422
      Height = 172
      Align = alClient
      TabOrder = 0
      object Panel2: TPanel
        Left = 1
        Top = 1
        Width = 420
        Height = 19
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object lblEditComment: TLabel
          Left = 8
          Top = 3
          Width = 286
          Height = 13
          Caption = '��������� ������ ��� ���������� ���������:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
      end
      object seError: TSynEdit
        Left = 1
        Top = 20
        Width = 420
        Height = 151
        Cursor = crIBeam
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        TabOrder = 1
        Gutter.AutoSize = True
        Gutter.DigitCount = 3
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -11
        Gutter.Font.Name = 'Terminal'
        Gutter.Font.Style = []
        Gutter.LeftOffset = 0
        Gutter.ShowLineNumbers = True
        Gutter.UseFontStyle = False
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
      end
    end
    object pnlParams: TPanel
      Left = 426
      Top = 1
      Width = 492
      Height = 172
      Align = alRight
      TabOrder = 1
      Visible = False
      object seParams: TSynEdit
        Left = 1
        Top = 20
        Width = 490
        Height = 151
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
        Gutter.AutoSize = True
        Gutter.DigitCount = 3
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -11
        Gutter.Font.Name = 'Terminal'
        Gutter.Font.Style = []
        Gutter.LeftOffset = 0
        Gutter.ShowLineNumbers = True
        Gutter.UseFontStyle = False
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
      end
      object pnlParamsLabel: TPanel
        Left = 1
        Top = 1
        Width = 490
        Height = 19
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        object lblParams: TLabel
          Left = 8
          Top = 3
          Width = 202
          Height = 13
          Caption = '��������� �������� ���������:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
      end
    end
  end
  object ActionList1: TActionList
    Left = 504
    Top = 112
    object actSave: TAction
      Caption = '���������'
      OnExecute = actSaveExecute
    end
    object actCancel: TAction
      Caption = '����������'
      OnExecute = actCancelExecute
    end
    object actStopConvert: TAction
      Caption = '�������� ����������� ��'
      OnExecute = actStopConvertExecute
    end
    object actComment: TAction
      Caption = '����������������'
      OnExecute = actCommentExecute
    end
    object actUncomment: TAction
      Caption = '����������������'
      OnExecute = actUncommentExecute
    end
  end
  object SynSQLSyn: TSynSQLSyn
    DefaultFilter = 'SQL Files (*.sql)|*.sql'
    SQLDialect = sqlSybase
    Left = 232
    Top = 67
  end
end
