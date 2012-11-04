object gd_dlgAbout: Tgd_dlgAbout
  Left = 584
  Top = 200
  HelpContext = 119
  BorderStyle = bsDialog
  Caption = 'О программе'
  ClientHeight = 415
  ClientWidth = 564
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pc: TPageControl
    Left = 8
    Top = 8
    Width = 547
    Height = 371
    ActivePage = tsAbout
    TabOrder = 0
    object tsAbout: TTabSheet
      Caption = 'О программе'
      object lblTitle: TLabel
        Left = 6
        Top = 4
        Width = 225
        Height = 19
        Caption = 'Платформа Гедымин, v.2.5'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object mCredits: TMemo
        Left = 5
        Top = 29
        Width = 527
        Height = 309
        TabStop = False
        BorderStyle = bsNone
        Color = clBtnFace
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -9
        Font.Name = 'Tahoma'
        Font.Style = []
        Lines.Strings = (
          'http://gsbelarus.com, email: support@gsbelarus.com'
          ''
          'Компания Golden Software, Ltd:'
          
            'Михаил Шойхет, Андрей Киреев, Денис Романовский, Антон Смирнов, ' +
            'Владимир Катковский, Кирилл Новышный,'
          
            'Виктор Дуж, Владимир Белый, Сергей Мартиновский, Сергей Яницкий,' +
            ' Александр Персон, Виктор Подмаско,'
          
            'Руслан Калинков, Владимир Воробей, Александр Назаренко, Леонид А' +
            'гафонов, Николай Корначенко,'
          
            'Анжелика Фролова, Олег Поротиков, Александр Павлющик, Роман Волы' +
            'нец, Александр Ковриго, Дмитрий Сыч,'
          
            'Юрий Строков, Татьяна Орлова, Андрей Шадевский, Сергей Тюльменко' +
            'в, Пянко Елена, Юрий Лукашеня,'
          
            'Игорь Власик, Юрий Толкач, Татьяна Карпейчик, Николай Лапушко, А' +
            'лександр Чулаков, Сергей Иванов,'
          
            'Денис Кравцов, Юлия Терехина, Александр Дубровник, Александр Кар' +
            'пук, Олег Михайленко, Михаил Дроздов,'
          
            'Алексей Рогаль, Марк Каменев, Андрей Савелов, Надежда Сергеева, ' +
            'Сергей Лабуко, Леонид Карпушенко,'
          
            'Андрей Демьянов, Максим Муха, Антон Гочев, Александр Цобкало, Ал' +
            'ександр Федин, Александра Меджидова,'
          
            'Инна Корбан, Инна Чвырова, Александр Маркевич, Виталий Борушко, ' +
            'Наталия Отока, Алексей Данильчик,'
          
            'Павел Пугач, Ольга Кацап, Виталий Садовский, Александр Окруль, А' +
            'лексей Рассохин, Станислав Шляхтич,'
          
            'Владимир Ковшов, Юлия Бессарабова, Денис Шишкевич, Вероника Урба' +
            'найть, Илона Андилевко, Юрий Розмысл,'
          
            'Михаил Дубаневич, Наталья Клименко, Андрей Клещенок, Сергей Боро' +
            'вик, Виктор Лубинский, Ольга Корсак,'
          
            'Евгений Бриль, Татьяна Потолицына, Александр Моисеев, Вера Верем' +
            'ей, Юрий Ворохобко, Николай Уклейко,'
          
            'Екатерина Масловская, Владимир Квочин, Дмитрий Сонных, Екатерина' +
            ' Давыдова, Денис Мальцев,'
          
            'Андрей Казакевич, Дмитрий Некрасов, Антон Харченко, Михаил Тумащ' +
            'ик, Сергей Яськевич, Виктория Безрук,'
          
            'Владимир Марченко, Сергей Панютич, Виталий Карако, Дмитрий Богат' +
            'ырев, Игорь Волк, Мария Прохорова,'
          
            'Дмитрий Образцов, Алексей Гайдуков, Александр Кишко, Наталья Шук' +
            'лина, Жанна Хилько, Ольга Борисенко,'
          'Юрий Шойхет, Александр Харитоненко.'
          ''
          'Отдельное спасибо:'
          
            'ООО Святогор, Владимир Гетманец, Stefan Boether, Евгений Кучеряв' +
            'енко, Сергей "Дейрас" Борисовец,'
          'Андрей Башун, Наталья Белковская.')
        ParentFont = False
        ReadOnly = True
        TabOrder = 0
      end
    end
    object tsParams: TTabSheet
      Caption = 'Параметры системы'
      ImageIndex = 6
      object mSysData: TSynEdit
        Left = 3
        Top = 3
        Width = 532
        Height = 336
        Cursor = crIBeam
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
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
        Highlighter = SynIniSyn
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
    object tsFiles: TTabSheet
      Caption = 'Файлы платформы'
      ImageIndex = 2
      object mFiles: TSynEdit
        Left = 3
        Top = 3
        Width = 532
        Height = 336
        Cursor = crIBeam
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
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
        Highlighter = SynXMLSyn
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
    object tsUpdate: TTabSheet
      Caption = 'Обновление'
      ImageIndex = 3
      object lblStep: TLabel
        Left = 88
        Top = 200
        Width = 3
        Height = 13
      end
      object lblAll: TLabel
        Left = 88
        Top = 160
        Width = 3
        Height = 13
      end
      object Button1: TButton
        Left = 32
        Top = 40
        Width = 75
        Height = 21
        Action = actUpdate
        TabOrder = 0
      end
      object xpbAll: TxProgressBar
        Left = 80
        Top = 176
        Width = 401
        Height = 17
        TabOrder = 1
        Value = 0
      end
      object xpbStep: TxProgressBar
        Left = 80
        Top = 216
        Width = 401
        Height = 17
        TabOrder = 2
        Value = 0
      end
    end
  end
  object btnOk: TButton
    Left = 480
    Top = 386
    Width = 75
    Height = 21
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnHelp: TButton
    Left = 8
    Top = 386
    Width = 75
    Height = 21
    Caption = 'Справка'
    Enabled = False
    TabOrder = 2
    OnClick = btnHelpClick
  end
  object btnMSInfo: TButton
    Left = 89
    Top = 386
    Width = 75
    Height = 21
    Caption = 'О Системе...'
    TabOrder = 3
    OnClick = btnMSInfoClick
  end
  object btnCopy: TButton
    Left = 170
    Top = 386
    Width = 129
    Height = 21
    Caption = 'Копировать в буфер'
    TabOrder = 4
    OnClick = btnCopyClick
  end
  object SynIniSyn: TSynIniSyn
    DefaultFilter = 'INI Files (*.ini)|*.ini'
    CommentAttri.Style = []
    SectionAttri.Foreground = clNavy
    SectionAttri.Style = []
    Left = 448
    Top = 48
  end
  object SynXMLSyn: TSynXMLSyn
    DefaultFilter = 'XML Document (*.xml,*.xsd,*.xsl,*.xslt)|*.xml;*.xsd;*.xsl;*.xslt'
    WantBracesParsed = False
    Left = 448
    Top = 88
  end
  object al: TActionList
    Left = 468
    Top = 312
    object actUpdate: TAction
      Caption = 'Обновить'
      OnExecute = actUpdateExecute
      OnUpdate = actUpdateUpdate
    end
  end
end
