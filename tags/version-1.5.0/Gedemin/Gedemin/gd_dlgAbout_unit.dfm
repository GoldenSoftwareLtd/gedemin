object gd_dlgAbout: Tgd_dlgAbout
  Left = 433
  Top = 244
  HelpContext = 119
  BorderStyle = bsDialog
  Caption = 'О программе'
  ClientHeight = 353
  ClientWidth = 487
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
  object PageControl1: TPageControl
    Left = 8
    Top = 8
    Width = 472
    Height = 313
    ActivePage = TabSheet1
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'О программе'
      object Label30: TLabel
        Left = 6
        Top = 2
        Width = 299
        Height = 21
        Caption = 'Платформа Гедымин, v.2.5 beta 1'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -17
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Memo1: TMemo
        Left = 5
        Top = 30
        Width = 452
        Height = 247
        TabStop = False
        BorderStyle = bsNone
        Color = clBtnFace
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -8
        Font.Name = 'Tahoma'
        Font.Style = []
        Lines.Strings = (
          
            'Copyright (c) 1994-2009 by Golden Software of Belarus, Ltd. All ' +
            'rights reserved.'
          ''
          'http://gsbelarus.com, email: support@gsbelarus.com'
          'тел/факс: +375-17-2921333, 3313546.'
          ''
          'Компания Golden Software, Ltd:'
          
            'Михаил Шойхет, Андрей Киреев, Денис Романовский, Антон Смирнов, ' +
            'Виктор Дуж, Кирилл Новышный,'
          
            'Владимир Белый, Сергей Мартиновский, Сергей Яницкий, Александр П' +
            'ерсон, Руслан Калинков,'
          
            'Владимир Воробей, Александр Назаренко, Анжелика Фролова, Виктор ' +
            'Подмаско, Леонид Агафонов,'
          
            'Олег Поротиков, Александр Павлющик, Роман Волынец, Александр Ков' +
            'риго, Дмитрий Сыч,'
          
            'Николай Корначенко, Юрий Строков, Татьяна Орлова, Андрей Шадевск' +
            'ий, Сергей Тюльменков,'
          
            'Юрий Лукашеня, Игорь Власик, Татьяна Карпейчик, Николай Лапушко,' +
            ' Юрий Толкач, Александр Чулаков,'
          
            'Сергей Иванов, Денис Кравцов, Юлия Терехина, Александр Дубровник' +
            ', Александр Карпук,'
          
            'Олег Михайленко, Леонид Карпушенко, Алексей Рогаль, Антон Гочев,' +
            ' Андрей Савелов, Надежда Сергеева,'
          
            'Сергей Лабуко, Михаил Дроздов, Андрей Демьянов, Максим Муха, Але' +
            'ксандр Цобкало, Александр Федин,'
          
            'Александра Меджидова, Инна Корбан, Инна Чвырова, Александр Марке' +
            'вич, Виталий Борушко,'
          
            'Алексей Данильчик, Павел Пугач, Ольга Кацап, Виталий Садовский, ' +
            'Александр Окруль, Алексей Рассохин,'
          
            'Станислав Шляхтич, Владимир Ковшов, Юлия Бессарабова, Вероника У' +
            'рбанайть, Денис Шишкевич,'
          
            'Илона Андилевко, Юрий Розмысл, Михаил Дубаневич, Клименко Наталь' +
            'я, Андрей Клещенок,'
          'Виктор Лубинский.'
          ''
          'Отдельное спасибо:'
          
            'ООО Святогор, Владимир Гетманец, Stefan Boether, Сергей "Дейрас"' +
            ' Борисовец.'
          ' '
          ' '
          ' '
          ' '
          ' ')
        ParentFont = False
        ReadOnly = True
        TabOrder = 0
      end
      object btnMSInfo: TButton
        Left = 380
        Top = 256
        Width = 75
        Height = 21
        Caption = 'О Системе...'
        TabOrder = 1
        OnClick = btnMSInfoClick
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Файлы'
      ImageIndex = 1
      object gbGDS32: TGroupBox
        Left = 8
        Top = 8
        Width = 446
        Height = 65
        Caption = ' Библиотека GDS32 '
        TabOrder = 0
        object Label2: TLabel
          Left = 11
          Top = 17
          Width = 77
          Height = 13
          Caption = 'Расположение:'
        end
        object lGDS32FileName: TLabel
          Left = 136
          Top = 17
          Width = 77
          Height = 13
          Caption = 'lGDS32FileName'
        end
        object lGDS32Version: TLabel
          Left = 136
          Top = 31
          Width = 69
          Height = 13
          Caption = 'lGDS32Version'
        end
        object lGDS32FileDescription: TLabel
          Left = 136
          Top = 45
          Width = 87
          Height = 13
          Caption = 'lGDS32Description'
        end
        object Label3: TLabel
          Left = 11
          Top = 31
          Width = 39
          Height = 13
          Caption = 'Версия:'
        end
        object Label4: TLabel
          Left = 11
          Top = 45
          Width = 88
          Height = 13
          Caption = 'Описание файла:'
        end
      end
      object GroupBox2: TGroupBox
        Left = 8
        Top = 74
        Width = 446
        Height = 144
        Caption = ' Сервер '
        TabOrder = 1
        object lServerVersion: TLabel
          Left = 136
          Top = 15
          Width = 69
          Height = 13
          Caption = 'lServerVersion'
        end
        object lDBSiteName: TLabel
          Left = 136
          Top = 46
          Width = 60
          Height = 13
          Caption = 'lDBSiteName'
        end
        object lODSVersion: TLabel
          Left = 136
          Top = 61
          Width = 58
          Height = 13
          Caption = 'lODSVersion'
        end
        object lPageSize: TLabel
          Left = 136
          Top = 77
          Width = 45
          Height = 13
          Caption = 'lPageSize'
        end
        object lForcedWrites: TLabel
          Left = 136
          Top = 92
          Width = 66
          Height = 13
          Caption = 'lForcedWrites'
        end
        object lNumBuffers: TLabel
          Left = 136
          Top = 108
          Width = 58
          Height = 13
          Caption = 'lNumBuffers'
        end
        object lCurrentMemory: TLabel
          Left = 136
          Top = 123
          Width = 77
          Height = 13
          Caption = 'lCurrentMemory'
        end
        object Label1: TLabel
          Left = 11
          Top = 15
          Width = 83
          Height = 13
          Caption = 'Версия сервера:'
        end
        object Label5: TLabel
          Left = 11
          Top = 30
          Width = 75
          Height = 13
          Caption = 'Имя файла БД:'
        end
        object Label6: TLabel
          Left = 11
          Top = 46
          Width = 89
          Height = 13
          Caption = 'Имя компьютера:'
        end
        object Label7: TLabel
          Left = 11
          Top = 61
          Width = 63
          Height = 13
          Caption = 'ODS версия:'
        end
        object Label8: TLabel
          Left = 11
          Top = 77
          Width = 91
          Height = 13
          Caption = 'Размер страницы:'
        end
        object Label9: TLabel
          Left = 11
          Top = 92
          Width = 114
          Height = 13
          Caption = 'Принудительная зап.:'
        end
        object Label10: TLabel
          Left = 11
          Top = 108
          Width = 111
          Height = 13
          Caption = 'Количество буферов:'
        end
        object Label11: TLabel
          Left = 11
          Top = 123
          Width = 114
          Height = 13
          Caption = 'Используемая память:'
        end
        object eDBFileName: TEdit
          Left = 136
          Top = 30
          Width = 305
          Height = 15
          BorderStyle = bsNone
          Ctl3D = False
          ParentColor = True
          ParentCtl3D = False
          ReadOnly = True
          TabOrder = 0
          Text = 'eDBFileName'
        end
      end
      object GroupBox3: TGroupBox
        Left = 8
        Top = 219
        Width = 446
        Height = 62
        Caption = ' Гедымин '
        TabOrder = 2
        object lGedeminFile: TLabel
          Left = 136
          Top = 16
          Width = 59
          Height = 13
          Caption = 'lGedeminFile'
        end
        object lGedeminPath: TLabel
          Left = 136
          Top = 30
          Width = 65
          Height = 13
          Caption = 'lGedeminPath'
        end
        object lGedeminVersion: TLabel
          Left = 136
          Top = 44
          Width = 78
          Height = 13
          Caption = 'lGedeminVersion'
        end
        object Label12: TLabel
          Left = 11
          Top = 16
          Width = 58
          Height = 13
          Caption = 'Имя файла:'
        end
        object Label13: TLabel
          Left = 11
          Top = 30
          Width = 77
          Height = 13
          Caption = 'Расположение:'
        end
        object Label14: TLabel
          Left = 11
          Top = 44
          Width = 74
          Height = 13
          Caption = 'Версия файла:'
        end
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Переменные среды'
      ImageIndex = 2
      object GroupBox4: TGroupBox
        Left = 8
        Top = 8
        Width = 446
        Height = 273
        Caption = ' Переменные среды '
        TabOrder = 0
        object lISC_USER: TLabel
          Left = 114
          Top = 16
          Width = 51
          Height = 13
          Caption = 'lISC_USER'
        end
        object lISC_PASSWORD: TLabel
          Left = 114
          Top = 32
          Width = 82
          Height = 13
          Caption = 'lISC_PASSWORD'
        end
        object lISC_PATH: TLabel
          Left = 114
          Top = 48
          Width = 51
          Height = 13
          Caption = 'lISC_PATH'
        end
        object lTemp: TLabel
          Left = 114
          Top = 64
          Width = 28
          Height = 13
          Caption = 'lTemp'
        end
        object lTmp: TLabel
          Left = 114
          Top = 80
          Width = 22
          Height = 13
          Caption = 'lTmp'
        end
        object Label15: TLabel
          Left = 10
          Top = 16
          Width = 53
          Height = 13
          Caption = 'ISC_USER:'
        end
        object Label16: TLabel
          Left = 10
          Top = 32
          Width = 84
          Height = 13
          Caption = 'ISC_PASSWORD:'
        end
        object Label17: TLabel
          Left = 10
          Top = 48
          Width = 53
          Height = 13
          Caption = 'ISC_PATH:'
        end
        object Label18: TLabel
          Left = 10
          Top = 64
          Width = 30
          Height = 13
          Caption = 'TEMP:'
        end
        object Label19: TLabel
          Left = 10
          Top = 80
          Width = 24
          Height = 13
          Caption = 'TMP:'
        end
        object Label20: TLabel
          Left = 10
          Top = 96
          Width = 30
          Height = 13
          Caption = 'PATH:'
        end
        object mPath: TMemo
          Left = 111
          Top = 96
          Width = 322
          Height = 169
          TabStop = False
          BorderStyle = bsNone
          Color = clBtnFace
          Lines.Strings = (
            'mPath')
          ReadOnly = True
          TabOrder = 0
        end
      end
    end
    object tsLogin: TTabSheet
      Caption = 'Подключение'
      ImageIndex = 3
      object GroupBox6: TGroupBox
        Left = 8
        Top = 8
        Width = 446
        Height = 129
        Caption = ' Пользователь '
        TabOrder = 0
        object Label25: TLabel
          Left = 11
          Top = 61
          Width = 101
          Height = 13
          Caption = 'ИД учетной записи:'
        end
        object Label26: TLabel
          Left = 11
          Top = 46
          Width = 92
          Height = 13
          Caption = 'Пользователь ИБ:'
        end
        object Label27: TLabel
          Left = 11
          Top = 30
          Width = 47
          Height = 13
          Caption = 'Контакт:'
        end
        object Label28: TLabel
          Left = 11
          Top = 15
          Width = 84
          Height = 13
          Caption = 'Учетная запись:'
        end
        object lUser: TLabel
          Left = 136
          Top = 15
          Width = 2
          Height = 13
          Caption = 'l'
        end
        object lContact: TLabel
          Left = 136
          Top = 30
          Width = 2
          Height = 13
          Caption = 'l'
        end
        object lIBUser: TLabel
          Left = 136
          Top = 46
          Width = 2
          Height = 13
          Caption = 'l'
        end
        object lUserKey: TLabel
          Left = 136
          Top = 61
          Width = 2
          Height = 13
          Caption = 'l'
        end
        object Label33: TLabel
          Left = 11
          Top = 77
          Width = 70
          Height = 13
          Caption = 'ИД контакта:'
        end
        object lContactKey: TLabel
          Left = 136
          Top = 77
          Width = 2
          Height = 13
          Caption = 'l'
        end
        object Label29: TLabel
          Left = 11
          Top = 93
          Width = 39
          Height = 13
          Caption = 'Сессия:'
        end
        object lSession: TLabel
          Left = 136
          Top = 93
          Width = 2
          Height = 13
          Caption = 'l'
        end
        object Label31: TLabel
          Left = 11
          Top = 109
          Width = 110
          Height = 13
          Caption = 'Дата и время подкл.:'
        end
        object lDateAndTime: TLabel
          Left = 136
          Top = 109
          Width = 2
          Height = 13
          Caption = 'l'
        end
      end
      object GroupBox7: TGroupBox
        Left = 8
        Top = 141
        Width = 446
        Height = 41
        Caption = ' Командная строка '
        TabOrder = 1
        object Label34: TEdit
          Left = 8
          Top = 14
          Width = 433
          Height = 21
          BorderStyle = bsNone
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 0
        end
      end
    end
    object tsDB: TTabSheet
      Caption = 'База данных'
      ImageIndex = 4
      object GroupBox5: TGroupBox
        Left = 8
        Top = 1
        Width = 446
        Height = 81
        Caption = ' Файл базы данных '
        TabOrder = 0
        object Label21: TLabel
          Left = 11
          Top = 15
          Width = 91
          Height = 13
          Caption = 'Версия файла БД:'
        end
        object Label22: TLabel
          Left = 11
          Top = 30
          Width = 71
          Height = 13
          Caption = 'ИД файла БД:'
        end
        object Label23: TLabel
          Left = 11
          Top = 46
          Width = 85
          Height = 13
          Caption = 'Дата релиза БД:'
        end
        object Label24: TLabel
          Left = 11
          Top = 61
          Width = 71
          Height = 13
          Caption = 'Комментарий:'
        end
        object lDBComment: TLabel
          Left = 136
          Top = 61
          Width = 2
          Height = 13
          Caption = 'l'
        end
        object lDBRelease: TLabel
          Left = 136
          Top = 46
          Width = 2
          Height = 13
          Caption = 'l'
        end
        object lDBID: TLabel
          Left = 136
          Top = 30
          Width = 2
          Height = 13
          Caption = 'l'
        end
        object lDBVersion: TLabel
          Left = 136
          Top = 15
          Width = 2
          Height = 13
          Caption = 'l'
        end
      end
      object GroupBox8: TGroupBox
        Left = 8
        Top = 82
        Width = 446
        Height = 79
        Caption = ' Параметры подключения  '
        TabOrder = 1
        object mDBParams: TMemo
          Left = 9
          Top = 15
          Width = 427
          Height = 55
          TabStop = False
          ReadOnly = True
          TabOrder = 0
        end
      end
      object gbTrace: TGroupBox
        Left = 8
        Top = 161
        Width = 446
        Height = 59
        Caption = ' Параметры трассировки подключения к БД '
        TabOrder = 2
        object mTrace: TMemo
          Left = 9
          Top = 16
          Width = 427
          Height = 35
          TabStop = False
          ReadOnly = True
          TabOrder = 0
        end
      end
      object GroupBox9: TGroupBox
        Left = 8
        Top = 221
        Width = 446
        Height = 60
        Caption = ' Параметры трассировки SQL монитора '
        TabOrder = 3
        object mSQLMonitor: TMemo
          Left = 9
          Top = 16
          Width = 427
          Height = 35
          TabStop = False
          ReadOnly = True
          TabOrder = 0
        end
      end
    end
    object tsTempFiles: TTabSheet
      Caption = 'Врем. файлы'
      ImageIndex = 5
      object lblTempPath: TLabel
        Left = 9
        Top = 8
        Width = 35
        Height = 13
        Caption = 'Папка:'
      end
      object lvTempFiles: TListView
        Left = 7
        Top = 32
        Width = 449
        Height = 113
        Columns = <
          item
            Caption = 'Имя'
            Width = 280
          end
          item
            Alignment = taRightJustify
            AutoSize = True
            Caption = 'Размер, байт'
          end>
        GridLines = True
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
      end
      object edTempPath: TEdit
        Left = 48
        Top = 4
        Width = 408
        Height = 21
        Color = clBtnFace
        ReadOnly = True
        TabOrder = 2
        Text = 'edTempPath'
      end
      object mTempFiles: TMemo
        Left = 7
        Top = 152
        Width = 449
        Height = 124
        Color = clBtnFace
        Lines.Strings = (
          
            'Временные файлы используются для кэширования информации из базы ' +
            'данных и'
          'ускорения запуска программы.'
          ''
          
            'Для удаления временных файлов вручную: закройте Гедымин, перейди' +
            'те в'
          'указанную папку, удалите файлы по списку.'
          ''
          
            'Запретить создание временных файлов можно с помощью параметра ко' +
            'мандной'
          'строки /nc.'
          ' '
          ' '
          ' ')
        ReadOnly = True
        TabOrder = 1
      end
    end
  end
  object btnOk: TButton
    Left = 405
    Top = 328
    Width = 75
    Height = 21
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnHelp: TButton
    Left = 8
    Top = 328
    Width = 75
    Height = 21
    Caption = 'Справка'
    TabOrder = 2
    OnClick = btnHelpClick
  end
  object IBDatabaseInfo1: TIBDatabaseInfo
    Left = 328
    Top = 56
  end
end
