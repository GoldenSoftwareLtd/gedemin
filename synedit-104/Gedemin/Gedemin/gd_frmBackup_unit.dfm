inherited gd_frmBackup: Tgd_frmBackup
  Left = 304
  Top = 218
  HelpContext = 28
  Caption = 'Создание архивной копии базы данных'
  PixelsPerInch = 96
  TextHeight = 13
  inherited mProgress: TMemo
    Lines.Strings = (
      'Для создания архива базы данных введите имя архивного файла  '
      'и нажмите кнопку Создать.'
      ''
      'Если необходимо создать несколько архивных файлов, например,'
      'для записи на дискеты, укажите имя каждого и его размер в байтах'
      '(должно быть положительное целое число не меньшее 2048). '
      'Для последнего файла в списке размер можно не задавать.'
      ''
      
        'Архивный файл создается на сервере базы данных в указанном катал' +
        'оге.'
      ''
      
        'Вывод подробной информации сильно замедляет процесс архивировани' +
        'я.'
      ''
      'Для создания архива пользователь должен ввести пароль SYSDBA.')
    TabOrder = 13
  end
  inherited btnDoIt: TButton
    TabOrder = 11
  end
  inherited btnClose: TButton
    TabOrder = 14
  end
  inherited btnHelp: TButton
    TabOrder = 12
  end
  inherited chbxVerbose: TCheckBox
    Left = 154
    Width = 271
    Caption = 'Подробная информация о ходе архивирования:'
    TabOrder = 10
  end
  inherited chbxDeleteTemp: TCheckBox
    Checked = False
    State = cbUnchecked
    TabOrder = 9
  end
  object chbxGarbage: TCheckBox [15]
    Left = 318
    Top = 168
    Width = 107
    Height = 17
    Alignment = taLeftJustify
    Caption = 'Сборка мусора:'
    TabOrder = 8
  end
  object chbxCheck: TCheckBox [16]
    Left = 5
    Top = 167
    Width = 200
    Height = 17
    Alignment = taLeftJustify
    Caption = 'Проверять целостность данных:'
    TabOrder = 5
  end
  object chbxSetToZero: TCheckBox [17]
    Left = 5
    Top = 183
    Width = 200
    Height = 17
    Alignment = taLeftJustify
    Caption = 'Сбросить идентификатор БД:'
    TabOrder = 6
  end
  inherited chbxShutDown: TCheckBox
    TabOrder = 7
  end
  inherited ActionList: TActionList
    inherited actDoIt: TAction
      Caption = 'Создать'
      OnExecute = actDoItExecute
    end
  end
  object IBBackupService: TIBBackupService [24]
    Protocol = TCP
    LoginPrompt = False
    TraceFlags = []
    BufferSize = 8192
    BlockingFactor = 0
    Options = []
    Left = 272
    Top = 16
  end
end
