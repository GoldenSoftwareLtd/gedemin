object dlgEditDFM: TdlgEditDFM
  Left = 255
  Top = 156
  Width = 544
  Height = 520
  Caption = 'DFM'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object seDFM: TSynEdit
    Left = 0
    Top = 22
    Width = 536
    Height = 443
    Cursor = crIBeam
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    PopupMenu = TBPopupMenu1
    TabOrder = 0
    Gutter.Font.Charset = DEFAULT_CHARSET
    Gutter.Font.Color = clWindowText
    Gutter.Font.Height = -11
    Gutter.Font.Name = 'Terminal'
    Gutter.Font.Style = []
    Gutter.Width = 18
    Highlighter = SynDfmSyn1
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
  object Panel1: TPanel
    Left = 0
    Top = 465
    Width = 536
    Height = 28
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnOk: TButton
      Left = 356
      Top = 4
      Width = 75
      Height = 21
      Anchors = [akRight, akBottom]
      Caption = 'Сохранить'
      ModalResult = 1
      TabOrder = 0
      OnClick = btnOkClick
    end
    object Button2: TButton
      Left = 443
      Top = 4
      Width = 75
      Height = 21
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object TBToolbar1: TTBToolbar
    Left = 0
    Top = 0
    Width = 536
    Height = 22
    Align = alTop
    Caption = 'TBToolbar1'
    CloseButton = False
    DockPos = 80
    DockRow = 1
    Images = dmImages.il16x16
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    object TBItem18: TTBItem
      Action = actSaveToFile
      Images = dmImages.il16x16
    end
    object TBItem19: TTBItem
      Action = actLoadFromFile
    end
    object TBSeparatorItem4: TTBSeparatorItem
    end
    object TBItem16: TTBItem
      Action = actFind
    end
    object TBItem15: TTBItem
      Action = actReplace
    end
    object TBSeparatorItem5: TTBSeparatorItem
    end
    object TBItem14: TTBItem
      Action = actCopy
    end
    object TBItem13: TTBItem
      Action = actCut
      Images = dmImages.il16x16
    end
    object TBItem12: TTBItem
      Action = actPaste
    end
  end
  object SynDfmSyn1: TSynDfmSyn
    DefaultFilter = 'Delphi/C++ Builder Form Files (*.dfm;*.xfm)|*.dfm;*.xfm'
    NumberAttri.Foreground = clBlue
    StringAttri.Foreground = clRed
    Left = 432
    Top = 24
  end
  object ActionList: TActionList
    Images = dmImages.il16x16
    Left = 72
    Top = 152
    object actLoadFromFile: TAction
      Category = 'Script'
      Caption = 'Загрузить DFM'
      Hint = 'Загрузить скрипт из файла'
      ImageIndex = 27
      OnExecute = actLoadFromFileExecute
    end
    object actSaveToFile: TAction
      Category = 'Script'
      Caption = 'Сохранить DFM'
      Hint = 'Сохранить скрипт в файл'
      ImageIndex = 25
      OnExecute = actSaveToFileExecute
    end
    object actFind: TAction
      Category = 'Script'
      Caption = 'Поиск'
      Hint = 'Поиск'
      ImageIndex = 23
      ShortCut = 16454
      OnExecute = actFindExecute
    end
    object actReplace: TAction
      Category = 'Script'
      Caption = 'Замена'
      Hint = 'Замена'
      ImageIndex = 22
      ShortCut = 16466
      OnExecute = actReplaceExecute
    end
    object actCopy: TAction
      Category = 'Script'
      Caption = 'Копировать в буфер'
      Hint = 'Копировать в буфер'
      ImageIndex = 10
      OnExecute = actCopyExecute
    end
    object actCut: TAction
      Category = 'Script'
      Caption = 'Вырезать в буфер'
      Hint = 'Вырезать в буфер'
      ImageIndex = 9
      OnExecute = actCutExecute
    end
    object actPaste: TAction
      Category = 'Script'
      Caption = 'Вставить из буфера'
      Hint = 'Вставить из буфера'
      ImageIndex = 8
      OnExecute = actPasteExecute
    end
  end
  object TBPopupMenu1: TTBPopupMenu
    Images = dmImages.il16x16
    Left = 160
    Top = 96
    object TBItem1: TTBItem
      Action = actSaveToFile
      Images = dmImages.il16x16
    end
    object TBItem2: TTBItem
      Action = actLoadFromFile
    end
    object TBSeparatorItem1: TTBSeparatorItem
    end
    object TBItem3: TTBItem
      Action = actFind
    end
    object TBItem4: TTBItem
      Action = actReplace
    end
    object TBSeparatorItem2: TTBSeparatorItem
    end
    object TBItem5: TTBItem
      Action = actCopy
    end
    object TBItem6: TTBItem
      Action = actCut
      Images = dmImages.il16x16
    end
    object TBItem7: TTBItem
      Action = actPaste
    end
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '*.dfm'
    Filter = 'DFM файлы|*.dfm|Все файлы|*.*'
    Left = 56
    Top = 32
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = '*.dfm'
    Filter = 'DFM файлы|*.dfm|Все файлы|*.*'
    Left = 88
    Top = 32
  end
  object FindDialog1: TFindDialog
    OnFind = FindDialog1Find
    Left = 144
    Top = 40
  end
  object ReplaceDialog1: TReplaceDialog
    OnFind = FindDialog1Find
    OnReplace = ReplaceDialog1Replace
    Left = 192
    Top = 40
  end
end
