object gsDBSqueeze_CardMergeForm: TgsDBSqueeze_CardMergeForm
  Left = 303
  Top = 154
  BorderStyle = bsDialog
  Caption = 'Объединение складских карточек'
  ClientHeight = 752
  ClientWidth = 1026
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object strngrdIgnoreDocTypes: TStringGrid
    Left = 281
    Top = 26
    Width = 498
    Height = 474
    TabStop = False
    ColCount = 2
    DefaultColWidth = 390
    DefaultRowHeight = 20
    FixedCols = 0
    RowCount = 50
    FixedRows = 0
    Options = [goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
    ScrollBars = ssVertical
    TabOrder = 4
  end
  object txt5: TStaticText
    Left = 281
    Top = 9
    Width = 392
    Height = 17
    Alignment = taCenter
    AutoSize = False
    Caption = 'Тип документа'
    Color = 671448
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindow
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 0
  end
  object txt1: TStaticText
    Left = 674
    Top = 9
    Width = 105
    Height = 17
    Alignment = taCenter
    AutoSize = False
    Caption = 'ID'
    Color = 671448
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindow
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 1
  end
  object tvDocTypes: TTreeView
    Left = 9
    Top = 10
    Width = 262
    Height = 553
    HideSelection = False
    HotTrack = True
    Indent = 19
    ReadOnly = True
    TabOrder = 3
    ToolTips = False
  end
  object mIgnoreDocTypes: TMemo
    Left = 281
    Top = 509
    Width = 498
    Height = 53
    TabStop = False
    Color = clBtnFace
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 5
  end
  object txt2: TStaticText
    Left = 793
    Top = 9
    Width = 224
    Height = 17
    Alignment = taCenter
    AutoSize = False
    Caption = 'Общие признаки карточек'
    Color = 671448
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindow
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 2
  end
  object mmo1: TMemo
    Left = 16
    Top = 576
    Width = 873
    Height = 137
    BorderStyle = bsNone
    Color = clBtnFace
    Lines.Strings = (
      'Описание:'
      
        '  Под объединением карточек понимается процесс замены однотипных' +
        ' карточек на одну из них - остальные удалются и на оставшуюся пе' +
        'репривязываются все ссылки.'
      
        '  Однотипные карточки - карточки, созданные выбранными нами доку' +
        'ментами, у которых goodkey и выбранные признаки являются одинако' +
        'выми.'
      
        '  Обрабатываемое множество карточек:  карточки, созданные докуме' +
        'нтами до выбранной даты.'
      ''
      '1. Выберете типы документов'
      ''
      '2. Выберете общие признаки карточек'
      ''
      '3. Укажите дату, до которой будут выбраны карточки:')
    TabOrder = 6
  end
  object btnMergeGo: TButton
    Left = 696
    Top = 720
    Width = 113
    Height = 25
    Caption = 'Запустить сейчас!'
    TabOrder = 8
  end
  object dtpClosingDate: TDateTimePicker
    Left = 300
    Top = 690
    Width = 86
    Height = 21
    Hint = 'рассчитать сальдо и удалить документы'
    CalAlignment = dtaLeft
    Date = 41380.5593590046
    Time = 41380.5593590046
    Color = clWhite
    DateFormat = dfShort
    DateMode = dmComboBox
    Kind = dtkDate
    ParseInput = False
    TabOrder = 7
    TabStop = False
  end
  object btn1: TButton
    Left = 810
    Top = 720
    Width = 209
    Height = 25
    Caption = 'Выполнить в контексте обрезания БД'
    TabOrder = 9
  end
end
