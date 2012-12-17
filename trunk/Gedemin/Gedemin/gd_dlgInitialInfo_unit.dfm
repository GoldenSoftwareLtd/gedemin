object gd_dlgInitialInfo: Tgd_dlgInitialInfo
  Left = 411
  Top = 203
  BorderStyle = bsDialog
  Caption = 'Начальная информация'
  ClientHeight = 459
  ClientWidth = 716
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label20: TLabel
    Left = 10
    Top = 13
    Width = 422
    Height = 13
    Caption = 
      'Пожалуйста, для начала работы с программой введите следующую инф' +
      'ормацию:'
  end
  object btnOk: TButton
    Left = 480
    Top = 416
    Width = 75
    Height = 21
    Action = actOk
    Default = True
    TabOrder = 3
  end
  object gbCompany: TGroupBox
    Left = 8
    Top = 40
    Width = 345
    Height = 291
    Caption = ' Сведения об организации '
    TabOrder = 0
    object Label1: TLabel
      Left = 12
      Top = 26
      Width = 77
      Height = 13
      Caption = 'Наименование:'
    end
    object Label2: TLabel
      Left = 12
      Top = 50
      Width = 48
      Height = 13
      Caption = 'Телефон:'
    end
    object Label3: TLabel
      Left = 12
      Top = 76
      Width = 25
      Height = 13
      Caption = 'УНП:'
    end
    object Label4: TLabel
      Left = 12
      Top = 99
      Width = 41
      Height = 13
      Caption = 'Индекс:'
    end
    object Label5: TLabel
      Left = 12
      Top = 125
      Width = 41
      Height = 13
      Caption = 'Страна:'
    end
    object Label6: TLabel
      Left = 12
      Top = 149
      Width = 47
      Height = 13
      Caption = 'Область:'
    end
    object Label7: TLabel
      Left = 12
      Top = 197
      Width = 59
      Height = 13
      Caption = 'Нас. пункт:'
    end
    object Label8: TLabel
      Left = 12
      Top = 221
      Width = 35
      Height = 13
      Caption = 'Адрес:'
    end
    object Label9: TLabel
      Left = 12
      Top = 243
      Width = 54
      Height = 13
      Caption = 'Директор:'
    end
    object Label10: TLabel
      Left = 12
      Top = 267
      Width = 76
      Height = 13
      Caption = 'Гл. бухгалтер:'
    end
    object Label25: TLabel
      Left = 12
      Top = 173
      Width = 34
      Height = 13
      Caption = 'Район:'
    end
    object edName: TEdit
      Left = 96
      Top = 24
      Width = 241
      Height = 21
      TabOrder = 0
    end
    object edPhone: TEdit
      Left = 96
      Top = 48
      Width = 241
      Height = 21
      TabOrder = 1
    end
    object edTaxID: TEdit
      Left = 96
      Top = 72
      Width = 241
      Height = 21
      TabOrder = 2
    end
    object cbCountry: TComboBox
      Left = 96
      Top = 120
      Width = 241
      Height = 21
      Style = csDropDownList
      DropDownCount = 16
      ItemHeight = 13
      Sorted = True
      TabOrder = 4
      Items.Strings = (
        'Австралия'
        'Австрия'
        'Азербайджан'
        'Албания'
        'Алжир'
        'Ангилья (Ангуилла)'
        'Ангола'
        'Андорра'
        'Антигуа и Барбуда'
        'Аргентина'
        'Армения'
        'Аруба'
        'Афганистан'
        'Багамские острова'
        'Бангладеш'
        'Барбадос'
        'Бахрейн'
        'Беларусь'
        'Белиз'
        'Бельгия'
        'Бенин'
        'Бермудские острова'
        'Болгария'
        'Боливия'
        'Босния и Герцеговина'
        'Ботсвана'
        'Бразилия'
        'Британские Виргинские острова'
        'Бруней'
        'Буркина-Фасо'
        'Бурунди'
        'Бутан'
        'Вануату'
        'Ватикан'
        'Великобритания'
        'Венгрия'
        'Венесуэла'
        'Виргинские острова'
        'Восточное (Американское) Самоа'
        'Восточный Тимор'
        'Вьетнам'
        'Габон'
        'Гайана'
        'Гаити'
        'Гамбия'
        'Гана'
        'Гваделупа'
        'Гватемала'
        'Гвинея'
        'Гвинея-Бисау'
        'Германия'
        'Гибралтар'
        'Гондурас'
        'Гренада'
        'Гренландия'
        'Греция'
        'Грузия'
        'Гуам'
        'Дания'
        'Демократическая Республика Конго'
        'Джибути'
        'Доминика'
        'Доминиканская республика'
        'Египет'
        'Замбия'
        'Западная Сахара'
        'Западное Самоа'
        'Зимбабве'
        'Йемен'
        'Израиль'
        'Индия'
        'Индонезия'
        'Иордания'
        'Ирак'
        'Иран'
        'Ирландия'
        'Исландия'
        'Испания'
        'Италия'
        'Кабо-Верде'
        'Казахстан'
        'Каймановы острова'
        'Камбоджа'
        'Камерун'
        'Канада'
        'Катар'
        'Кения'
        'Кипр'
        'Киргизия'
        'Кирибати'
        'Китай'
        'КНДР'
        'Кокосовые острова'
        'Колумбия'
        'Коморские острова'
        'Коста-Рика'
        'Кот-д'#39'Ивуар'
        'Куба'
        'Кувейт'
        'Кука острова'
        'Лаос'
        'Латвия'
        'Лесото'
        'Либерия'
        'Ливан'
        'Ливия'
        'Литва'
        'Лихтенштейн'
        'Люксембург'
        'Маврикий'
        'Мавритания'
        'Мадагаскар'
        'Макао (Аомынь)'
        'Македония'
        'Малави'
        'Малайзия'
        'Мали'
        'Мальдивы'
        'Мальта'
        'Марокко'
        'Мартиника'
        'Маршаловы острова'
        'Мексика'
        'Мидуэй'
        'Микронезия'
        'Мозамбик'
        'Молдавия'
        'Монако'
        'Монголия'
        'Монтсеррат'
        'Мьянма (Бирма)'
        'Намибия'
        'Народная Республика Конго'
        'Науру'
        'Непал'
        'Нигер'
        'Нигерия'
        'Нидерландские Антиллы'
        'Нидерланды'
        'Никарагуа'
        'Ниуэ'
        'Новая Зеландия'
        'Новая Каледония'
        'Норвегия'
        'Норфолк'
        'ОАЭ'
        'Оман'
        'Пакистан'
        'Палау'
        'Палестина'
        'Панама'
        'Папуа-Новая Гвинея'
        'Парагвай'
        'Перу'
        'Питкэрн'
        'Польша'
        'Португалия'
        'Пуэрто-Рико'
        'Реюньон'
        'Рождества остров'
        'Россия'
        'Руанда'
        'Румыния'
        'Сальвадор'
        'Сан-Марино'
        'Сан-Томе и Принсипи'
        'Саудовская Аравия'
        'Свазиленд'
        'Святой Елены Остров'
        'Северные Марианские острова'
        'Сейшельские острова'
        'Сенегал'
        'Сен-Пьер и Микелон'
        'Сент-Винсент и Гренадины'
        'Сент-Китс и Невис'
        'Сент-Люсия'
        'Сербия и Черногория'
        'Сингапур'
        'Сирия'
        'Словакия'
        'Словения'
        'Сомали'
        'Судан'
        'Суринам'
        'США'
        'Сьерра-Леоне'
        'Таджикистан'
        'Таиланд'
        'Танзания'
        'Тёркс и Кайкос'
        'Того'
        'Токелау'
        'Тонга'
        'Тринидад и Тобаго'
        'Тувалу'
        'Тунис'
        'Туркменистан'
        'Турция'
        'Уганда'
        'Узбекистан'
        'Украина'
        'Уоллис и Футуна'
        'Уругвай'
        'Уэйк'
        'Фарерские острова'
        'Фиджи'
        'Филиппины'
        'Финляндия'
        'Фолклендские (Мальвинские) острова'
        'Франция'
        'Французская полинезия'
        'Хорватия'
        'Центрально-Африканская республика'
        'ЧАД'
        'Черногория'
        'Чехия'
        'Чили'
        'Швейцария'
        'Швеция'
        'Шри-Ланка'
        'Эквадор'
        'Экваториальная Гвинея'
        'Эритрея'
        'Эстония'
        'Эфиопия'
        'Южная Корея'
        'Южно-Африканская Республика'
        'Ямайка'
        'Япония')
    end
    object edZIP: TEdit
      Left = 96
      Top = 96
      Width = 241
      Height = 21
      TabOrder = 3
    end
    object edArea: TEdit
      Left = 96
      Top = 144
      Width = 241
      Height = 21
      TabOrder = 5
    end
    object edCity: TEdit
      Left = 96
      Top = 192
      Width = 241
      Height = 21
      TabOrder = 7
    end
    object edAddress: TEdit
      Left = 96
      Top = 216
      Width = 241
      Height = 21
      TabOrder = 8
    end
    object edDirector: TEdit
      Left = 96
      Top = 239
      Width = 241
      Height = 21
      TabOrder = 9
    end
    object edAccountant: TEdit
      Left = 96
      Top = 263
      Width = 241
      Height = 21
      TabOrder = 10
    end
    object edDistrict: TEdit
      Left = 96
      Top = 168
      Width = 241
      Height = 21
      TabOrder = 6
    end
  end
  object gbBank: TGroupBox
    Left = 363
    Top = 40
    Width = 345
    Height = 291
    Caption = ' Банковские реквизиты '
    TabOrder = 1
    object Label13: TLabel
      Left = 12
      Top = 26
      Width = 28
      Height = 13
      Caption = 'Банк:'
    end
    object Label14: TLabel
      Left = 12
      Top = 220
      Width = 37
      Height = 13
      Caption = 'Р/счет:'
    end
    object Label15: TLabel
      Left = 12
      Top = 52
      Width = 57
      Height = 13
      Caption = 'Код банка:'
    end
    object Label16: TLabel
      Left = 12
      Top = 102
      Width = 41
      Height = 13
      Caption = 'Страна:'
    end
    object Label17: TLabel
      Left = 12
      Top = 126
      Width = 47
      Height = 13
      Caption = 'Область:'
    end
    object Label18: TLabel
      Left = 12
      Top = 174
      Width = 59
      Height = 13
      Caption = 'Нас. пункт:'
    end
    object Label19: TLabel
      Left = 12
      Top = 198
      Width = 35
      Height = 13
      Caption = 'Адрес:'
    end
    object Label21: TLabel
      Left = 12
      Top = 244
      Width = 43
      Height = 13
      Caption = 'Валюта:'
    end
    object Label24: TLabel
      Left = 12
      Top = 77
      Width = 41
      Height = 13
      Caption = 'Индекс:'
    end
    object Label26: TLabel
      Left = 12
      Top = 150
      Width = 34
      Height = 13
      Caption = 'Район:'
    end
    object iblkupCurr: TgsIBLookupComboBox
      Left = 96
      Top = 242
      Width = 242
      Height = 21
      HelpContext = 1
      Database = dmDatabase.ibdbGAdmin
      Transaction = ibTr
      ListTable = 'GD_CURR'
      ListField = 'SHORTNAME'
      KeyField = 'ID'
      gdClassName = 'TgdcCurr'
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = True
      TabOrder = 9
    end
    object edBankName: TEdit
      Left = 96
      Top = 24
      Width = 241
      Height = 21
      TabOrder = 0
    end
    object edBankCode: TEdit
      Left = 96
      Top = 48
      Width = 241
      Height = 21
      TabOrder = 1
    end
    object edAccount: TEdit
      Left = 96
      Top = 218
      Width = 241
      Height = 21
      TabOrder = 8
    end
    object edBankArea: TEdit
      Left = 96
      Top = 122
      Width = 241
      Height = 21
      TabOrder = 4
    end
    object edBankCity: TEdit
      Left = 96
      Top = 170
      Width = 241
      Height = 21
      TabOrder = 6
    end
    object edBankAddress: TEdit
      Left = 96
      Top = 194
      Width = 241
      Height = 21
      TabOrder = 7
    end
    object cbBankCountry: TComboBox
      Left = 96
      Top = 98
      Width = 241
      Height = 21
      Style = csDropDownList
      DropDownCount = 16
      ItemHeight = 13
      Sorted = True
      TabOrder = 3
      Items.Strings = (
        'Австралия'
        'Австрия'
        'Азербайджан'
        'Албания'
        'Алжир'
        'Ангилья (Ангуилла)'
        'Ангола'
        'Андорра'
        'Антигуа и Барбуда'
        'Аргентина'
        'Армения'
        'Аруба'
        'Афганистан'
        'Багамские острова'
        'Бангладеш'
        'Барбадос'
        'Бахрейн'
        'Беларусь'
        'Белиз'
        'Бельгия'
        'Бенин'
        'Бермудские острова'
        'Болгария'
        'Боливия'
        'Босния и Герцеговина'
        'Ботсвана'
        'Бразилия'
        'Британские Виргинские острова'
        'Бруней'
        'Буркина-Фасо'
        'Бурунди'
        'Бутан'
        'Вануату'
        'Ватикан'
        'Великобритания'
        'Венгрия'
        'Венесуэла'
        'Виргинские острова'
        'Восточное (Американское) Самоа'
        'Восточный Тимор'
        'Вьетнам'
        'Габон'
        'Гайана'
        'Гаити'
        'Гамбия'
        'Гана'
        'Гваделупа'
        'Гватемала'
        'Гвинея'
        'Гвинея-Бисау'
        'Германия'
        'Гибралтар'
        'Гондурас'
        'Гренада'
        'Гренландия'
        'Греция'
        'Грузия'
        'Гуам'
        'Дания'
        'Демократическая Республика Конго'
        'Джибути'
        'Доминика'
        'Доминиканская республика'
        'Египет'
        'Замбия'
        'Западная Сахара'
        'Западное Самоа'
        'Зимбабве'
        'Йемен'
        'Израиль'
        'Индия'
        'Индонезия'
        'Иордания'
        'Ирак'
        'Иран'
        'Ирландия'
        'Исландия'
        'Испания'
        'Италия'
        'Кабо-Верде'
        'Казахстан'
        'Каймановы острова'
        'Камбоджа'
        'Камерун'
        'Канада'
        'Катар'
        'Кения'
        'Кипр'
        'Киргизия'
        'Кирибати'
        'Китай'
        'КНДР'
        'Кокосовые острова'
        'Колумбия'
        'Коморские острова'
        'Коста-Рика'
        'Кот-д'#39'Ивуар'
        'Куба'
        'Кувейт'
        'Кука острова'
        'Лаос'
        'Латвия'
        'Лесото'
        'Либерия'
        'Ливан'
        'Ливия'
        'Литва'
        'Лихтенштейн'
        'Люксембург'
        'Маврикий'
        'Мавритания'
        'Мадагаскар'
        'Макао (Аомынь)'
        'Македония'
        'Малави'
        'Малайзия'
        'Мали'
        'Мальдивы'
        'Мальта'
        'Марокко'
        'Мартиника'
        'Маршаловы острова'
        'Мексика'
        'Мидуэй'
        'Микронезия'
        'Мозамбик'
        'Молдавия'
        'Монако'
        'Монголия'
        'Монтсеррат'
        'Мьянма (Бирма)'
        'Намибия'
        'Народная Республика Конго'
        'Науру'
        'Непал'
        'Нигер'
        'Нигерия'
        'Нидерландские Антиллы'
        'Нидерланды'
        'Никарагуа'
        'Ниуэ'
        'Новая Зеландия'
        'Новая Каледония'
        'Норвегия'
        'Норфолк'
        'ОАЭ'
        'Оман'
        'Пакистан'
        'Палау'
        'Палестина'
        'Панама'
        'Папуа-Новая Гвинея'
        'Парагвай'
        'Перу'
        'Питкэрн'
        'Польша'
        'Португалия'
        'Пуэрто-Рико'
        'Реюньон'
        'Рождества остров'
        'Россия'
        'Руанда'
        'Румыния'
        'Сальвадор'
        'Сан-Марино'
        'Сан-Томе и Принсипи'
        'Саудовская Аравия'
        'Свазиленд'
        'Святой Елены Остров'
        'Северные Марианские острова'
        'Сейшельские острова'
        'Сенегал'
        'Сен-Пьер и Микелон'
        'Сент-Винсент и Гренадины'
        'Сент-Китс и Невис'
        'Сент-Люсия'
        'Сербия и Черногория'
        'Сингапур'
        'Сирия'
        'Словакия'
        'Словения'
        'Сомали'
        'Судан'
        'Суринам'
        'США'
        'Сьерра-Леоне'
        'Таджикистан'
        'Таиланд'
        'Танзания'
        'Тёркс и Кайкос'
        'Того'
        'Токелау'
        'Тонга'
        'Тринидад и Тобаго'
        'Тувалу'
        'Тунис'
        'Туркменистан'
        'Турция'
        'Уганда'
        'Узбекистан'
        'Украина'
        'Уоллис и Футуна'
        'Уругвай'
        'Уэйк'
        'Фарерские острова'
        'Фиджи'
        'Филиппины'
        'Финляндия'
        'Фолклендские (Мальвинские) острова'
        'Франция'
        'Французская полинезия'
        'Хорватия'
        'Центрально-Африканская республика'
        'ЧАД'
        'Черногория'
        'Чехия'
        'Чили'
        'Швейцария'
        'Швеция'
        'Шри-Ланка'
        'Эквадор'
        'Экваториальная Гвинея'
        'Эритрея'
        'Эстония'
        'Эфиопия'
        'Южная Корея'
        'Южно-Африканская Республика'
        'Ямайка'
        'Япония')
    end
    object edBankZIP: TEdit
      Left = 96
      Top = 73
      Width = 241
      Height = 21
      TabOrder = 2
    end
    object edBankDistrict: TEdit
      Left = 96
      Top = 146
      Width = 241
      Height = 21
      TabOrder = 5
    end
  end
  object gbLogin: TGroupBox
    Left = 8
    Top = 332
    Width = 345
    Height = 120
    Caption = ' Учетная запись пользователя '
    TabOrder = 2
    object Label11: TLabel
      Left = 12
      Top = 46
      Width = 34
      Height = 13
      Caption = 'Логин:'
    end
    object Label12: TLabel
      Left = 12
      Top = 70
      Width = 41
      Height = 13
      Caption = 'Пароль:'
    end
    object Label22: TLabel
      Left = 12
      Top = 22
      Width = 101
      Height = 13
      Caption = 'ФИО пользователя:'
    end
    object Label23: TLabel
      Left = 12
      Top = 94
      Width = 100
      Height = 13
      Caption = 'Подтверждение п.:'
    end
    object edUser: TEdit
      Left = 120
      Top = 18
      Width = 217
      Height = 21
      TabOrder = 0
    end
    object edLogin: TEdit
      Left = 120
      Top = 42
      Width = 217
      Height = 21
      TabOrder = 1
    end
    object edPassword: TEdit
      Left = 120
      Top = 66
      Width = 217
      Height = 21
      PasswordChar = '*'
      TabOrder = 2
    end
    object edPassword2: TEdit
      Left = 120
      Top = 90
      Width = 217
      Height = 21
      PasswordChar = '*'
      TabOrder = 3
    end
  end
  object btnCancel: TButton
    Left = 576
    Top = 416
    Width = 75
    Height = 21
    Action = actCancel
    TabOrder = 4
  end
  object Post: TActionList
    Left = 640
    Top = 336
    object actOk: TAction
      Caption = 'Ok'
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
  end
  object ibTr: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    AutoStopAction = saNone
    Left = 672
    Top = 336
  end
  object gdcCompany: TgdcCompany
    Transaction = ibTr
    ReadTransaction = ibTr
    Left = 400
    Top = 352
  end
  object gdcEmployee: TgdcEmployee
    Transaction = ibTr
    ReadTransaction = ibTr
    Left = 432
    Top = 352
  end
  object q: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibTr
    Left = 504
    Top = 352
  end
  object gdcFolder: TgdcFolder
    Transaction = ibTr
    ReadTransaction = ibTr
    Left = 360
    Top = 352
  end
  object gdcDepartment: TgdcDepartment
    Transaction = ibTr
    ReadTransaction = ibTr
    Left = 360
    Top = 384
  end
  object gdcUser: TgdcUser
    Transaction = ibTr
    ReadTransaction = ibTr
    Left = 400
    Top = 384
  end
  object gdcBank: TgdcBank
    Transaction = ibTr
    ReadTransaction = ibTr
    Left = 432
    Top = 384
  end
end
