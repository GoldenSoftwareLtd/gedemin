object gd_security_dlgDatabases: Tgd_security_dlgDatabases
  Left = 404
  Top = 297
  HelpContext = 40
  BorderStyle = bsDialog
  Caption = 'Регистрация базы данных'
  ClientHeight = 284
  ClientWidth = 496
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 187
    Width = 35
    Height = 13
    Caption = 'Поиск:'
  end
  object btnSelect: TButton
    Left = 408
    Top = 8
    Width = 75
    Height = 21
    Action = actOk
    Default = True
    TabOrder = 4
  end
  object lv: TListView
    Left = 8
    Top = 8
    Width = 393
    Height = 172
    Columns = <
      item
        Caption = 'Псевдоним'
        Width = 140
      end
      item
        AutoSize = True
        Caption = 'База данных'
      end>
    HideSelection = False
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnChange = lvChange
  end
  object btnCancel: TButton
    Left = 408
    Top = 32
    Width = 75
    Height = 21
    Action = actCancel
    Cancel = True
    TabOrder = 5
  end
  object btnAdd: TButton
    Left = 408
    Top = 135
    Width = 75
    Height = 21
    Action = actAdd
    TabOrder = 8
  end
  object btnDelete: TButton
    Left = 408
    Top = 111
    Width = 75
    Height = 21
    Action = actDelete
    TabOrder = 7
  end
  object btnRestore: TButton
    Left = 408
    Top = 159
    Width = 75
    Height = 21
    Action = actRestore
    TabOrder = 9
  end
  object gbProps: TGroupBox
    Left = 8
    Top = 204
    Width = 483
    Height = 73
    TabOrder = 3
    object edAlias: TEdit
      Left = 8
      Top = 16
      Width = 385
      Height = 21
      Color = clBtnFace
      ReadOnly = True
      TabOrder = 0
    end
    object edDatabase: TEdit
      Left = 8
      Top = 40
      Width = 353
      Height = 21
      Color = clBtnFace
      ReadOnly = True
      TabOrder = 1
    end
    object btnEdit: TButton
      Left = 400
      Top = 16
      Width = 75
      Height = 21
      Action = actEdit
      TabOrder = 3
    end
    object btnSave: TButton
      Left = 400
      Top = 40
      Width = 75
      Height = 21
      Action = actSave
      TabOrder = 4
    end
    object btnBrowseDir: TButton
      Left = 360
      Top = 40
      Width = 33
      Height = 21
      Action = actBrowseDir
      TabOrder = 2
    end
  end
  object btnHelp: TButton
    Left = 408
    Top = 56
    Width = 75
    Height = 21
    Action = actHelp
    TabOrder = 6
  end
  object edSearch: TEdit
    Left = 45
    Top = 184
    Width = 276
    Height = 21
    Hint = 'Поиск (Ctrl-F)'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    OnChange = edSearchChange
  end
  object btnSearch: TButton
    Left = 326
    Top = 184
    Width = 75
    Height = 21
    Action = actSearchNext
    TabOrder = 2
  end
  object ActionList: TActionList
    Left = 168
    Top = 80
    object actAdd: TAction
      Caption = 'Добавить'
      OnExecute = actAddExecute
      OnUpdate = actAddUpdate
    end
    object actEdit: TAction
      Caption = 'Изменить'
      OnExecute = actEditExecute
      OnUpdate = actEditUpdate
    end
    object actDelete: TAction
      Caption = 'Удалить'
      OnExecute = actDeleteExecute
      OnUpdate = actDeleteUpdate
    end
    object actCancel: TAction
      Caption = 'Выйти'
      OnExecute = actCancelExecute
    end
    object actOk: TAction
      Caption = 'Выбрать'
      OnExecute = actOkExecute
      OnUpdate = actOkUpdate
    end
    object actRestore: TAction
      Caption = 'Восстановить'
      OnExecute = actRestoreExecute
      OnUpdate = actRestoreUpdate
    end
    object actSave: TAction
      Caption = 'Сохранить'
      OnExecute = actSaveExecute
      OnUpdate = actSaveUpdate
    end
    object actHelp: TAction
      Caption = 'Справка'
      Enabled = False
      ShortCut = 112
      Visible = False
      OnExecute = actHelpExecute
    end
    object actBrowseDir: TAction
      Caption = '...'
      OnExecute = actBrowseDirExecute
    end
    object actSearchNext: TAction
      Caption = 'Следующая'
      OnExecute = actSearchNextExecute
      OnUpdate = actSearchUpdate
    end
    object actFind: TAction
      Caption = 'actFind'
      ShortCut = 16454
      OnExecute = actFindExecute
    end
    object actSearch: TAction
      Caption = 'actSearch'
      OnExecute = actSearchExecute
      OnUpdate = actSearchUpdate
    end
  end
  object od: TOpenDialog
    Filter = 'Файл базы данных|*.?db|Все файлы|*.*'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'Файл базы данных'
    Left = 272
    Top = 96
  end
end
