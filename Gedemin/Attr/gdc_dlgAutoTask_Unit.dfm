inherited gdc_dlgAutoTask: Tgdc_dlgAutoTask
  Left = 510
  Top = 141
  Caption = 'gdc_dlgAutoTask'
  ClientHeight = 516
  ClientWidth = 461
  Font.Charset = DEFAULT_CHARSET
  Font.Name = 'MS Sans Serif'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lbName: TLabel [0]
    Left = 8
    Top = 20
    Width = 79
    Height = 13
    Caption = 'Наименование:'
  end
  object lbDescription: TLabel [1]
    Left = 8
    Top = 42
    Width = 53
    Height = 13
    Caption = 'Описание:'
  end
  object lbUser: TLabel [2]
    Left = 8
    Top = 250
    Width = 84
    Height = 13
    Caption = 'Учетная запись:'
  end
  inherited btnAccess: TButton
    Top = 486
    TabOrder = 9
  end
  inherited btnNew: TButton
    Top = 486
    TabOrder = 10
  end
  inherited btnHelp: TButton
    Top = 486
    TabOrder = 11
  end
  inherited btnOK: TButton
    Left = 313
    Top = 486
    TabOrder = 7
  end
  inherited btnCancel: TButton
    Left = 385
    Top = 486
    TabOrder = 8
  end
  object dbedName: TDBEdit [8]
    Left = 104
    Top = 16
    Width = 343
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    DataField = 'NAME'
    DataSource = dsgdcBase
    TabOrder = 0
  end
  object dbmDescription: TDBMemo [9]
    Left = 104
    Top = 40
    Width = 343
    Height = 49
    Anchors = [akLeft, akTop, akRight]
    DataField = 'Description'
    DataSource = dsgdcBase
    TabOrder = 1
  end
  object iblkupUser: TgsIBLookupComboBox [10]
    Left = 104
    Top = 248
    Width = 343
    Height = 21
    HelpContext = 1
    DataSource = dsgdcBase
    DataField = 'USERKEY'
    ListTable = 'GD_USER'
    ListField = 'NAME'
    KeyField = 'ID'
    gdClassName = 'TgdcUser'
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
  end
  object gbTimeInterval: TGroupBox [11]
    Left = 8
    Top = 384
    Width = 177
    Height = 49
    Caption = 'Временной интервал'
    TabOrder = 5
    object lbStartTime: TLabel
      Left = 8
      Top = 22
      Width = 6
      Height = 13
      Caption = 'с'
    end
    object lbEndTime: TLabel
      Left = 88
      Top = 22
      Width = 15
      Height = 13
      Caption = 'до:'
    end
    object xdbeStartTime: TxDateDBEdit
      Left = 24
      Top = 20
      Width = 57
      Height = 21
      DataField = 'starttime'
      DataSource = dsgdcBase
      Kind = kTime
      EmptyAtStart = True
      EditMask = '!99\:99\:99;1;_'
      MaxLength = 8
      TabOrder = 0
    end
    object xdbeEndTime: TxDateDBEdit
      Left = 112
      Top = 20
      Width = 57
      Height = 21
      DataField = 'endtime'
      DataSource = dsgdcBase
      Kind = kTime
      EmptyAtStart = True
      EditMask = '!99\:99\:99;1;_'
      MaxLength = 8
      TabOrder = 1
    end
  end
  object gbTimeTables: TGroupBox [12]
    Left = 8
    Top = 272
    Width = 297
    Height = 105
    Caption = 'Расписание'
    TabOrder = 4
    object lbMonthly: TLabel
      Left = 208
      Top = 48
      Width = 83
      Height = 13
      Caption = '-ой день месяца'
    end
    object lbWeekly: TLabel
      Left = 208
      Top = 72
      Width = 81
      Height = 13
      Caption = '-ой день недели'
    end
    object rbExactDate: TRadioButton
      Left = 8
      Top = 20
      Width = 169
      Height = 21
      Caption = 'Выполнить один раз после:'
      TabOrder = 0
      OnClick = rbExactDateClick
    end
    object xdbeExactDate: TxDateDBEdit
      Left = 176
      Top = 20
      Width = 113
      Height = 21
      DataField = 'exactdate'
      DataSource = dsgdcBase
      EmptyAtStart = True
      EditMask = '!99\.99\.9999 99\:99\:99;1;_'
      MaxLength = 19
      TabOrder = 1
    end
    object rbMonthly: TRadioButton
      Left = 8
      Top = 44
      Width = 129
      Height = 21
      Caption = 'Выполнять каждый'
      TabOrder = 2
      OnClick = rbMonthlyClick
    end
    object dbcbMonthly: TDBComboBox
      Left = 136
      Top = 44
      Width = 65
      Height = 21
      DataField = 'monthly'
      DataSource = dsgdcBase
      ItemHeight = 13
      Items.Strings = (
        '-30'
        '-29'
        '-28'
        '-27'
        '-26'
        '-25'
        '-24'
        '-23'
        '-22'
        '-21'
        '-20'
        '-19'
        '-18'
        '-17'
        '-16'
        '-15'
        '-14'
        '-13'
        '-12'
        '-11'
        '-10'
        '-9'
        '-8'
        '-7'
        '-6'
        '-5'
        '-4'
        '-3'
        '-2'
        '-1'
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
        '31')
      TabOrder = 3
    end
    object rbWeekly: TRadioButton
      Left = 8
      Top = 68
      Width = 129
      Height = 21
      Caption = 'Выполнять каждый'
      TabOrder = 4
      OnClick = rbWeeklyClick
    end
    object dbcbWeekly: TDBComboBox
      Left = 136
      Top = 68
      Width = 65
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
      TabOrder = 5
    end
  end
  object gbType: TGroupBox [13]
    Left = 8
    Top = 96
    Width = 448
    Height = 145
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Тип задачи'
    TabOrder = 2
    object rbFunction: TRadioButton
      Left = 8
      Top = 20
      Width = 89
      Height = 21
      Caption = 'Функция:'
      TabOrder = 0
      OnClick = rbFunctionClick
    end
    object iblkupFunction: TgsIBLookupComboBox
      Left = 96
      Top = 20
      Width = 343
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
      TabOrder = 1
    end
    object rbCmdLine: TRadioButton
      Left = 8
      Top = 92
      Width = 89
      Height = 21
      Caption = 'Программа:'
      TabOrder = 2
      OnClick = rbCmdLineClick
    end
    object dbeCmdLine: TDBEdit
      Left = 96
      Top = 92
      Width = 309
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      DataField = 'cmdline'
      DataSource = dsgdcBase
      TabOrder = 3
    end
    object rbBackupFile: TRadioButton
      Left = 8
      Top = 116
      Width = 89
      Height = 21
      Caption = 'Архив:'
      TabOrder = 5
      OnClick = rbBackupFileClick
    end
    object dbeBackupFile: TDBEdit
      Left = 96
      Top = 116
      Width = 309
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      DataField = 'backupfile'
      DataSource = dsgdcBase
      TabOrder = 6
    end
    object btnCmdLine: TButton
      Left = 412
      Top = 92
      Width = 25
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '...'
      TabOrder = 4
      OnClick = btnCmdLineClick
    end
    object btnBackupFile: TButton
      Left = 412
      Top = 116
      Width = 25
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '...'
      TabOrder = 7
      OnClick = btnBackupFileClick
    end
    object rbAutoTr: TRadioButton
      Left = 8
      Top = 46
      Width = 89
      Height = 17
      Caption = 'Авто ХО:'
      TabOrder = 8
    end
    object rbReport: TRadioButton
      Left = 8
      Top = 70
      Width = 89
      Height = 17
      Caption = 'Отчет:'
      TabOrder = 9
    end
    object iblkupAutoTr: TgsIBLookupComboBox
      Left = 96
      Top = 44
      Width = 343
      Height = 21
      HelpContext = 1
      Anchors = [akLeft, akTop, akRight]
      ItemHeight = 13
      TabOrder = 10
    end
    object iblkupReport: TgsIBLookupComboBox
      Left = 96
      Top = 68
      Width = 343
      Height = 21
      HelpContext = 1
      Anchors = [akLeft, akTop, akRight]
      ItemHeight = 13
      TabOrder = 11
    end
  end
  object dbcbDisabled: TDBCheckBox [14]
    Left = 8
    Top = 448
    Width = 97
    Height = 17
    Caption = 'Отключена'
    DataField = 'disabled'
    DataSource = dsgdcBase
    TabOrder = 6
    ValueChecked = '1'
    ValueUnchecked = '0'
  end
  inherited alBase: TActionList
    Left = 238
    Top = 397
  end
  inherited dsgdcBase: TDataSource
    Left = 200
    Top = 397
  end
  inherited pm_dlgG: TPopupMenu
    Left = 272
    Top = 398
  end
  inherited ibtrCommon: TIBTransaction
    Left = 312
    Top = 398
  end
  object odCmdLine: TOpenDialog
    Filter = 
      'Исполняемые файлы *.exe|*.exe|Пакетные файлы *.bat|*.bat|Все фай' +
      'лы *.*|*.*'
    Title = 'Выбор файла'
    Left = 384
    Top = 336
  end
end
