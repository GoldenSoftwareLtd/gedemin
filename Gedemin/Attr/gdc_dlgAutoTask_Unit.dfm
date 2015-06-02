inherited gdc_dlgAutoTask: Tgdc_dlgAutoTask
  Left = 633
  Top = 250
  Caption = 'gdc_dlgAutoTask'
  ClientHeight = 582
  ClientWidth = 440
  Font.Charset = DEFAULT_CHARSET
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lbPriority: TLabel [0]
    Left = 8
    Top = 500
    Width = 371
    Height = 13
    Caption = 
      'Порядковый номер выполнения для задач, назначенных на одно время' +
      ':'
  end
  object Label2: TLabel [1]
    Left = 223
    Top = 265
    Width = 205
    Height = 32
    AutoSize = False
    Caption = '(оставьте поле пустым для выполнения под любой учетной записью)'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    WordWrap = True
  end
  object lbName: TLabel [2]
    Left = 8
    Top = 20
    Width = 77
    Height = 13
    Caption = 'Наименование:'
  end
  object lbDescription: TLabel [3]
    Left = 8
    Top = 42
    Width = 53
    Height = 13
    Caption = 'Описание:'
  end
  object lbUser: TLabel [4]
    Left = 8
    Top = 244
    Width = 212
    Height = 13
    Caption = 'Выполнять только под учетной записью:'
  end
  object lbStartTime: TLabel [5]
    Left = 9
    Top = 457
    Width = 64
    Height = 13
    Caption = 'Выполнять с'
  end
  object lbEndTime: TLabel [6]
    Left = 143
    Top = 457
    Width = 13
    Height = 13
    Caption = 'до'
  end
  object Label4: TLabel [7]
    Left = 79
    Top = 479
    Width = 313
    Height = 13
    Caption = 'Оставьте поля пустыми для выполнения в любое время дня.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  inherited btnAccess: TButton
    Left = 7
    Top = 552
    TabOrder = 12
  end
  inherited btnNew: TButton
    Left = 79
    Top = 552
    TabOrder = 13
  end
  inherited btnHelp: TButton
    Left = 151
    Top = 552
    TabOrder = 14
  end
  inherited btnOK: TButton
    Left = 290
    Top = 552
    TabOrder = 10
  end
  inherited btnCancel: TButton
    Left = 362
    Top = 552
    TabOrder = 11
  end
  object gbTimeTables: TGroupBox [13]
    Left = 6
    Top = 302
    Width = 425
    Height = 146
    Caption = ' Расписание '
    TabOrder = 4
    object Label3: TLabel
      Left = 26
      Top = 69
      Width = 324
      Height = 13
      Caption = 'Отрицательные значения задают номера дней с конца месяца.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object rbExactDate: TRadioButton
      Left = 8
      Top = 20
      Width = 185
      Height = 21
      Caption = 'Однократно в указанный день:'
      TabOrder = 0
    end
    object xdbeExactDate: TxDateDBEdit
      Left = 200
      Top = 20
      Width = 65
      Height = 21
      DataField = 'exactdate'
      DataSource = dsgdcBase
      Kind = kDate
      EmptyAtStart = True
      EditMask = '!99\.99\.9999;1;_'
      MaxLength = 10
      TabOrder = 1
    end
    object rbMonthly: TRadioButton
      Left = 8
      Top = 44
      Width = 185
      Height = 21
      Caption = 'Ежемесячно в указанный день:'
      TabOrder = 2
    end
    object rbWeekly: TRadioButton
      Left = 8
      Top = 92
      Width = 193
      Height = 21
      Caption = 'Еженедельно в указанный день:'
      TabOrder = 3
    end
    object dbcbWeekly: TDBComboBox
      Left = 200
      Top = 92
      Width = 113
      Height = 21
      DataField = 'weekly'
      DataSource = dsgdcBase
      ItemHeight = 13
      Items.Strings = (
        '1'
        '2'
        '3'
        '4'
        '5'
        '6'
        '7')
      TabOrder = 4
    end
    object rbDaily: TRadioButton
      Left = 8
      Top = 119
      Width = 89
      Height = 17
      Caption = 'Ежедневно'
      TabOrder = 5
    end
    object dbcbMonthly: TDBComboBox
      Left = 200
      Top = 46
      Width = 65
      Height = 21
      DataField = 'MONTHLY'
      DataSource = dsgdcBase
      DropDownCount = 16
      ItemHeight = 13
      Items.Strings = (
        '1'
        '2'
        '3'
        '4'
        '5'
        '6'
        '7'
        '8'
        '9'
        '10'
        '11'
        '12'
        '13'
        '14'
        '15'
        '16'
        '17'
        '18'
        '19'
        '20'
        '21'
        '22'
        '23'
        '24'
        '25'
        '26'
        '27'
        '28'
        '29'
        '30'
        '31'
        '-1'
        '-2'
        '-3'
        '-4'
        '-5'
        '-6'
        '-7'
        '-8'
        '-9'
        '-10'
        '-11'
        '-12'
        '-13'
        '-14'
        '-15'
        '-16'
        '-17'
        '-18'
        '-19'
        '-20'
        '-21'
        '-22'
        '-23'
        '-24'
        '-25'
        '-26'
        '-27'
        '-28'
        '-29'
        '-30'
        '-31')
      TabOrder = 6
    end
  end
  object dbcbDisabled: TDBCheckBox [14]
    Left = 8
    Top = 522
    Width = 297
    Height = 17
    Caption = 'Задача отключена и не будет выполняться'
    DataField = 'disabled'
    DataSource = dsgdcBase
    TabOrder = 9
    ValueChecked = '1'
    ValueUnchecked = '0'
  end
  object dbcbPriority: TDBComboBox [15]
    Left = 384
    Top = 497
    Width = 48
    Height = 21
    DataField = 'PRIORITY'
    DataSource = dsgdcBase
    ItemHeight = 13
    Items.Strings = (
      '0'
      '1'
      '2'
      '3'
      '4'
      '5'
      '6'
      '7'
      '8'
      '9')
    TabOrder = 8
  end
  object dbedName: TDBEdit [16]
    Left = 99
    Top = 17
    Width = 330
    Height = 21
    Anchors = []
    DataField = 'NAME'
    DataSource = dsgdcBase
    TabOrder = 0
  end
  object dbmDescription: TDBMemo [17]
    Left = 99
    Top = 42
    Width = 330
    Height = 49
    Anchors = []
    DataField = 'Description'
    DataSource = dsgdcBase
    TabOrder = 1
  end
  object pcTask: TPageControl [18]
    Left = 8
    Top = 98
    Width = 421
    Height = 135
    ActivePage = tsFunction
    Anchors = []
    MultiLine = True
    TabOrder = 2
    object tsFunction: TTabSheet
      Caption = 'Скрипт-функция'
      object iblkupFunction: TgsIBLookupComboBox
        Left = 8
        Top = 8
        Width = 400
        Height = 21
        HelpContext = 1
        DataSource = dsgdcBase
        DataField = 'FUNCTIONKEY'
        ListTable = 'GD_FUNCTION'
        ListField = 'NAME'
        KeyField = 'ID'
        gdClassName = 'TgdcFunction'
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
      end
    end
    object tsCmd: TTabSheet
      Caption = 'Внешняя программа'
      ImageIndex = 1
      object Label1: TLabel
        Left = 8
        Top = 34
        Width = 368
        Height = 33
        AutoSize = False
        Caption = 
          'При необходимости укажите имя программы  (команды) и параметры к' +
          'омандной строки.'
        WordWrap = True
      end
      object dbeCmdLine: TDBEdit
        Left = 8
        Top = 8
        Width = 373
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        DataField = 'cmdline'
        DataSource = dsgdcBase
        TabOrder = 0
      end
      object btnCmdLine: TButton
        Left = 381
        Top = 7
        Width = 25
        Height = 21
        Anchors = [akTop, akRight]
        Caption = '...'
        TabOrder = 1
        OnClick = btnCmdLineClick
      end
    end
  end
  object iblkupUser: TgsIBLookupComboBox [19]
    Left = 222
    Top = 240
    Width = 208
    Height = 21
    HelpContext = 1
    DataSource = dsgdcBase
    DataField = 'USERKEY'
    ListTable = 'GD_USER'
    ListField = 'NAME'
    KeyField = 'ID'
    gdClassName = 'TgdcUser'
    Anchors = []
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
  end
  object xdbeStartTime: TxDateDBEdit [20]
    Left = 79
    Top = 455
    Width = 57
    Height = 21
    DataField = 'starttime'
    DataSource = dsgdcBase
    Kind = kTime
    EmptyAtStart = True
    EditMask = '!99\:99\:99;1;_'
    MaxLength = 8
    TabOrder = 5
  end
  object xdbeEndTime: TxDateDBEdit [21]
    Left = 162
    Top = 455
    Width = 57
    Height = 21
    DataField = 'endtime'
    DataSource = dsgdcBase
    Kind = kTime
    EmptyAtStart = True
    EditMask = '!99\:99\:99;1;_'
    MaxLength = 8
    TabOrder = 6
  end
  object btnClearTime: TButton [22]
    Left = 230
    Top = 454
    Width = 75
    Height = 21
    Caption = 'Очистить'
    TabOrder = 7
    OnClick = btnClearTimeClick
  end
  inherited alBase: TActionList
    Left = 238
    Top = 549
  end
  inherited dsgdcBase: TDataSource
    Left = 200
    Top = 549
  end
  inherited pm_dlgG: TPopupMenu
    Left = 272
    Top = 550
  end
  inherited ibtrCommon: TIBTransaction
    Left = 312
    Top = 550
  end
  object odCmdLine: TOpenDialog
    Filter = 
      'Исполняемые файлы *.exe|*.exe|Пакетные файлы *.bat|*.bat|Все фай' +
      'лы *.*|*.*'
    Title = 'Выбор файла'
    Left = 360
    Top = 552
  end
end
