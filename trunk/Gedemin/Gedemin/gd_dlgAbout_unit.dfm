object gd_dlgAbout: Tgd_dlgAbout
  Left = 616
  Top = 236
  HelpContext = 119
  BorderStyle = bsDialog
  Caption = 'О программе'
  ClientHeight = 382
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
    Height = 339
    ActivePage = TabSheet1
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'О программе'
      object lblTitle: TLabel
        Left = 6
        Top = 2
        Width = 240
        Height = 21
        Caption = 'Платформа Гедымин, v.2.5'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -17
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object mCredits: TMemo
        Left = 5
        Top = 30
        Width = 527
        Height = 279
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
            'Владимир Катковский,'
          
            'Виктор Дуж, Кирилл Новышный, Владимир Белый, Сергей Мартиновский' +
            ', Сергей Яницкий,'
          
            'Александр Персон, Руслан Калинков, Владимир Воробей, Александр Н' +
            'азаренко, Анжелика Фролова,'
          
            'Виктор Подмаско, Леонид Агафонов, Олег Поротиков, Александр Павл' +
            'ющик, Роман Волынец,'
          
            'Александр Ковриго, Дмитрий Сыч, Николай Корначенко, Юрий Строков' +
            ', Татьяна Орлова,'
          
            'Андрей Шадевский, Сергей Тюльменков, Юрий Лукашеня, Игорь Власик' +
            ', Татьяна Карпейчик,'
          
            'Николай Лапушко, Юрий Толкач, Александр Чулаков, Сергей Иванов, ' +
            'Денис Кравцов, Юлия Терехина,'
          
            'Александр Дубровник, Александр Карпук, Олег Михайленко, Леонид К' +
            'арпушенко, Алексей Рогаль,'
          
            'Антон Гочев, Андрей Савелов, Надежда Сергеева, Сергей Лабуко, Ми' +
            'хаил Дроздов, Андрей Демьянов,'
          
            'Максим Муха, Александр Цобкало, Александр Федин, Александра Медж' +
            'идова, Инна Корбан,'
          
            'Инна Чвырова, Александр Маркевич, Виталий Борушко, Алексей Данил' +
            'ьчик, Павел Пугач,'
          
            'Ольга Кацап, Виталий Садовский, Александр Окруль, Алексей Рассох' +
            'ин, Станислав Шляхтич,'
          
            'Владимир Ковшов, Юлия Бессарабова, Вероника Урбанайть, Денис Шиш' +
            'кевич, Илона Андилевко,'
          
            'Юрий Розмысл, Михаил Дубаневич, Наталья Клименко, Андрей Клещено' +
            'к, Виктор Лубинский,'
          
            'Ольга Корсак, Екатерина Масловская, Евгений Бриль, Татьяна Потол' +
            'ицына, Александр Моисеев,'
          
            'Вера Веремей, Юрий Ворохобко, Наталья Шуклина, Владимир Квочин, ' +
            'Дмитрий Сонных, Пянко Елена.'
          ''
          'Отдельное спасибо:'
          
            'ООО Святогор, Владимир Гетманец, Stefan Boether, Андрей Башун, Е' +
            'вгений Кучерявенко,'
          'Сергей "Дейрас" Борисовец, Наталья Белковская.'
          ' '
          ' '
          ' '
          ' '
          ' '
          ' '
          ' '
          ' '
          ' '
          ' '
          ' '
          ' ')
        ParentFont = False
        ReadOnly = True
        TabOrder = 0
      end
    end
    object TabSheet4: TTabSheet
      Caption = 'Параметры системы'
      ImageIndex = 6
      object btnCopy: TButton
        Left = 404
        Top = 286
        Width = 129
        Height = 21
        Caption = 'Копировать в буфер'
        TabOrder = 2
        OnClick = btnCopyClick
      end
      object mSysData: TSynEdit
        Left = 3
        Top = 3
        Width = 532
        Height = 277
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
      object btnMSInfo: TButton
        Left = 3
        Top = 286
        Width = 75
        Height = 21
        Caption = 'О Системе...'
        TabOrder = 1
        OnClick = btnMSInfoClick
      end
    end
  end
  object btnOk: TButton
    Left = 480
    Top = 354
    Width = 75
    Height = 21
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnHelp: TButton
    Left = 8
    Top = 354
    Width = 75
    Height = 21
    Caption = 'Справка'
    TabOrder = 2
    Visible = False
    OnClick = btnHelpClick
  end
  object SynIniSyn: TSynIniSyn
    DefaultFilter = 'INI Files (*.ini)|*.ini'
    CommentAttri.Style = []
    SectionAttri.Foreground = clNavy
    SectionAttri.Style = []
    Left = 464
    Top = 8
  end
end
