object frm_SettingView: Tfrm_SettingView
  Left = 321
  Top = 74
  Width = 789
  Height = 600
  Caption = 'Просмотр настройки'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 781
    Height = 537
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object splLeft: TSplitter
      Left = 283
      Top = 0
      Width = 3
      Height = 537
      Cursor = crHSplit
    end
    object pnlPositionText: TPanel
      Left = 286
      Top = 0
      Width = 495
      Height = 537
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object TBDock1: TTBDock
        Left = 0
        Top = 0
        Width = 495
        Height = 26
        object TBToolbar1: TTBToolbar
          Left = 0
          Top = 0
          Caption = 'TBToolbar1'
          DockMode = dmCannotFloatOrChangeDocks
          DragHandleStyle = dhNone
          FullSize = True
          Images = dmImages.il16x16
          TabOrder = 0
          object TBItem2: TTBItem
            Action = actSaveToFile
            Visible = False
          end
          object TBSeparatorItem1: TTBSeparatorItem
          end
          object TBItem1: TTBItem
            Action = actFind
          end
        end
      end
      object sePositionText: TSynEdit
        Left = 0
        Top = 26
        Width = 495
        Height = 511
        Cursor = crIBeam
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        TabOrder = 1
        Gutter.DigitCount = 2
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -11
        Gutter.Font.Name = 'Tahoma'
        Gutter.Font.Style = []
        Gutter.LeftOffset = 8
        Gutter.ShowLineNumbers = True
        Gutter.Width = 16
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
    object pnlLeft: TPanel
      Left = 0
      Top = 0
      Width = 283
      Height = 537
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
      object splInfo: TSplitter
        Left = 0
        Top = 84
        Width = 283
        Height = 3
        Cursor = crVSplit
        Align = alTop
      end
      object pnlPositions: TPanel
        Left = 0
        Top = 87
        Width = 283
        Height = 450
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 1
        object lbPositions: TListBox
          Left = 0
          Top = 25
          Width = 283
          Height = 425
          Align = alClient
          ItemHeight = 13
          Sorted = True
          TabOrder = 0
          OnClick = lbPositionsClick
        end
        object pnlPositionsCaption: TPanel
          Left = 0
          Top = 0
          Width = 283
          Height = 25
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 1
          object lblPositions: TLabel
            Left = 7
            Top = 6
            Width = 247
            Height = 13
            Caption = 'Позиции настройки: Classname (Subtype) Settable'
          end
        end
      end
      object pnlSettingInfo: TPanel
        Left = 0
        Top = 0
        Width = 283
        Height = 84
        Align = alTop
        TabOrder = 0
        object mSettingInfo: TMemo
          Left = 1
          Top = 26
          Width = 281
          Height = 57
          Align = alClient
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Courier'
          Font.Style = []
          ParentFont = False
          ReadOnly = True
          TabOrder = 0
          WantReturns = False
        end
        object pnlSettingInfoCaption: TPanel
          Left = 1
          Top = 1
          Width = 281
          Height = 25
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 1
          object lblSettingInfo: TLabel
            Left = 7
            Top = 6
            Width = 107
            Height = 13
            Caption = 'Свойства настройки:'
          end
        end
      end
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 537
    Width = 781
    Height = 32
    Align = alBottom
    BevelOuter = bvLowered
    TabOrder = 1
    object pnlButtons: TPanel
      Left = 610
      Top = 1
      Width = 170
      Height = 30
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object btnClose: TButton
        Left = 80
        Top = 4
        Width = 75
        Height = 25
        Cancel = True
        Caption = 'Закрыть'
        Default = True
        TabOrder = 0
        OnClick = btnCloseClick
      end
    end
  end
  object alMain: TActionList
    Images = dmImages.il16x16
    Left = 366
    Top = 80
    object actFind: TAction
      Caption = 'Поиск...'
      ImageIndex = 23
      ShortCut = 16454
      OnExecute = actFindExecute
      OnUpdate = actFindUpdate
    end
    object actSaveToFile: TAction
      Caption = 'Сохранить в файл...'
      ImageIndex = 25
      ShortCut = 16467
    end
    object actFindNext: TAction
      Caption = 'Найти далее'
      ShortCut = 114
      OnExecute = actFindNextExecute
    end
  end
  object fdMain: TFindDialog
    OnFind = fdMainFind
    Left = 398
    Top = 80
  end
end
