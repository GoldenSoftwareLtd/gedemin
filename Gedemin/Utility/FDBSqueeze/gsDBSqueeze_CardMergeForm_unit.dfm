object gsDBSqueeze_CardMergeForm: TgsDBSqueeze_CardMergeForm
  Left = 153
  Top = 27
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsDialog
  Caption = 'Объединение складских карточек'
  ClientHeight = 670
  ClientWidth = 1205
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object strngrdDocTypes: TStringGrid
    Left = 281
    Top = 26
    Width = 400
    Height = 399
    TabStop = False
    ColCount = 2
    DefaultColWidth = 315
    DefaultRowHeight = 20
    FixedCols = 0
    RowCount = 50
    FixedRows = 0
    Options = [goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
    ScrollBars = ssVertical
    TabOrder = 4
    OnDblClick = strngrdDocTypesDblClick
    OnDrawCell = strngrdDocTypesDrawCell
  end
  object txt5: TStaticText
    Left = 281
    Top = 9
    Width = 317
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
    Left = 599
    Top = 9
    Width = 82
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
    Height = 479
    HideSelection = False
    HotTrack = True
    Indent = 19
    ReadOnly = True
    TabOrder = 3
    ToolTips = False
    OnClick = tvDocTypesClick
    OnCustomDrawItem = tvDocTypesCustomDrawItem
  end
  object mDocTypes: TMemo
    Left = 281
    Top = 437
    Width = 400
    Height = 53
    TabStop = False
    Color = clBtnFace
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 6
  end
  object txt2: TStaticText
    Left = 693
    Top = 9
    Width = 500
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
    Left = 24
    Top = 499
    Width = 881
    Height = 137
    TabStop = False
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
    ReadOnly = True
    TabOrder = 8
  end
  object btnMergeGo: TButton
    Left = 1083
    Top = 636
    Width = 113
    Height = 25
    Caption = 'Запустить сейчас!'
    TabOrder = 11
    OnClick = btnMergeGoClick
  end
  object dtpMergingDate: TDateTimePicker
    Left = 308
    Top = 613
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
    TabOrder = 9
    TabStop = False
  end
  object btn1: TButton
    Left = 873
    Top = 636
    Width = 209
    Height = 25
    Caption = 'Выполнить в контексте обрезания БД'
    TabOrder = 10
    OnClick = btnIsMergeOption
  end
  object strngrdCardFeatures: TStringGrid
    Left = 693
    Top = 26
    Width = 500
    Height = 399
    TabStop = False
    ColCount = 2
    DefaultColWidth = 335
    DefaultRowHeight = 20
    FixedCols = 0
    RowCount = 50
    FixedRows = 0
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Options = [goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goRowSelect]
    ParentFont = False
    TabOrder = 5
    OnDblClick = strngrdCardFeaturesDblClick
    OnDrawCell = strngrdCardFeaturesDrawCell
  end
  object mCardFeatures: TMemo
    Left = 693
    Top = 437
    Width = 500
    Height = 53
    TabStop = False
    Color = clBtnFace
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 7
  end
  object actlstCardMerge: TActionList
    Left = 16
    Top = 16
    object actSelectAllDocs: TAction
      Caption = 'actSelectAllDocs'
      ShortCut = 16449
      OnExecute = actSelectAllDocsExecute
    end
  end
end
