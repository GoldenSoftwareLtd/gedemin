object st_frmMain: Tst_frmMain
  Left = 278
  Top = 260
  Width = 696
  Height = 480
  HelpContext = 108
  Caption = 'Хранилище'
  Color = clBtnFace
  Constraints.MinHeight = 80
  Constraints.MinWidth = 80
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object sb: TStatusBar
    Left = 0
    Top = 434
    Width = 688
    Height = 19
    Panels = <>
    SimplePanel = False
  end
  object TBDock1: TTBDock
    Left = 0
    Top = 0
    Width = 688
    Height = 49
    object TBToolbar1: TTBToolbar
      Left = 0
      Top = 23
      Caption = 'Панель инструментов'
      Images = dmImages.il16x16
      TabOrder = 0
      object TBItem7: TTBItem
        Action = actNewFolder
      end
      object TBItem6: TTBItem
        Action = actEditFolder
      end
      object TBItem5: TTBItem
        Action = actDeleteFolder
      end
      object TBItem8: TTBItem
        Action = actShowFolderProp
      end
      object TBItem9: TTBItem
        Action = actSearch
      end
      object TBSeparatorItem4: TTBSeparatorItem
      end
      object TBItem10: TTBItem
        Action = actSaveToFile
      end
      object TBItem11: TTBItem
        Action = actLoadFromFile
      end
      object TBSeparatorItem1: TTBSeparatorItem
      end
      object TBItem4: TTBItem
        Action = actNewValue
      end
      object TBItem3: TTBItem
        Action = actEditValue
      end
      object TBItem2: TTBItem
        Action = actDeleteValue
      end
      object TBSeparatorItem2: TTBSeparatorItem
      end
      object TBItem1: TTBItem
        Action = actSaveStorage
      end
      object TBSeparatorItem3: TTBSeparatorItem
      end
      object TBControlItem1: TTBControlItem
        Control = cb
      end
      object TBSeparatorItem8: TTBSeparatorItem
      end
      object TBItem28: TTBItem
        Action = actHelp
      end
      object cb: TComboBox
        Left = 277
        Top = 0
        Width = 145
        Height = 21
        Style = csDropDownList
        DropDownCount = 16
        ItemHeight = 13
        Sorted = True
        TabOrder = 0
        OnChange = cbChange
      end
    end
    object TBToolbar2: TTBToolbar
      Left = 0
      Top = 0
      Caption = 'Меню'
      CloseButton = False
      FullSize = True
      Images = dmImages.il16x16
      MenuBar = True
      ProcessShortCuts = True
      ShrinkMode = tbsmWrap
      TabOrder = 1
      object TBSubmenuItem1: TTBSubmenuItem
        Caption = 'Разделы'
        object TBItem17: TTBItem
          Action = actNewFolder
        end
        object TBItem16: TTBItem
          Action = actEditFolder
        end
        object TBItem15: TTBItem
          Action = actDeleteFolder
        end
        object TBSeparatorItem5: TTBSeparatorItem
        end
        object TBItem14: TTBItem
          Action = actShowFolderProp
        end
        object TBItem13: TTBItem
          Action = actSearch
        end
        object TBSeparatorItem6: TTBSeparatorItem
        end
        object TBItem19: TTBItem
          Action = actSaveToFile
        end
        object TBItem18: TTBItem
          Action = actLoadFromFile
        end
        object TBSeparatorItem7: TTBSeparatorItem
        end
        object TBItem20: TTBItem
          Action = actAddFolderToSetting
        end
        object TBItem26: TTBItem
          Action = actRefresh
        end
        object TBItem24: TTBItem
          Action = actSaveStorage
        end
      end
      object TBSubmenuItem2: TTBSubmenuItem
        Caption = 'Параметры'
        object TBItem23: TTBItem
          Action = actNewValue
        end
        object TBItem22: TTBItem
          Action = actEditValue
        end
        object TBItem21: TTBItem
          Action = actDeleteValue
        end
        object TBItem12: TTBItem
          Action = actRenameValue
        end
        object TBSeparatorItem9: TTBSeparatorItem
        end
        object TBItem25: TTBItem
          Action = actAddValueToSetting
        end
      end
      object TBSubmenuItem3: TTBSubmenuItem
        Caption = 'Справка'
        object TBItem27: TTBItem
          Action = actHelp
        end
      end
    end
  end
  object pnlWorkArea: TPanel
    Left = 0
    Top = 49
    Width = 688
    Height = 385
    Align = alClient
    BevelOuter = bvLowered
    TabOrder = 2
    object splSearch: TSplitter
      Left = 1
      Top = 349
      Width = 686
      Height = 8
      Cursor = crVSplit
      Align = alBottom
      Beveled = True
      Visible = False
    end
    object Panel1: TPanel
      Left = 1
      Top = 1
      Width = 686
      Height = 348
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      object splVert: TSplitter
        Left = 98
        Top = 0
        Width = 8
        Height = 348
        Cursor = crHSplit
        Beveled = True
      end
      object tv: TTreeView
        Left = 9
        Top = 0
        Width = 89
        Height = 348
        Align = alLeft
        BorderStyle = bsNone
        HideSelection = False
        Images = dmImages.il16x16
        Indent = 19
        PopupMenu = pmMain
        RightClickSelect = True
        SortType = stText
        TabOrder = 0
        OnChange = tvChange
        OnCustomDrawItem = tvCustomDrawItem
        OnEdited = tvEdited
        OnEditing = tvEditing
      end
      object Panel2: TPanel
        Left = 106
        Top = 0
        Width = 571
        Height = 348
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 1
        object lv: TListView
          Left = 0
          Top = 0
          Width = 571
          Height = 348
          Align = alClient
          BorderStyle = bsNone
          Columns = <
            item
              Caption = 'Наименование'
              Width = 180
            end
            item
              Caption = 'Тип'
              Width = 40
            end
            item
              AutoSize = True
              Caption = 'Данные'
            end
            item
              Caption = 'Дата'
              Width = 130
            end>
          HideSelection = False
          ReadOnly = True
          PopupMenu = pmDetail
          SortType = stText
          TabOrder = 0
          ViewStyle = vsReport
          OnCustomDrawItem = lvCustomDrawItem
          OnCustomDrawSubItem = lvCustomDrawSubItem
          OnDblClick = lvDblClick
          OnKeyDown = lvKeyDown
        end
      end
      object TBDock3: TTBDock
        Left = 677
        Top = 0
        Width = 9
        Height = 348
        Position = dpRight
      end
      object TBDock2: TTBDock
        Left = 0
        Top = 0
        Width = 9
        Height = 348
        Position = dpLeft
      end
    end
    object pnSearch: TPanel
      Left = 1
      Top = 357
      Width = 686
      Height = 27
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      Visible = False
      object lvSearch: TListView
        Left = 0
        Top = 0
        Width = 686
        Height = 27
        Align = alClient
        BorderStyle = bsNone
        Columns = <
          item
            AutoSize = True
          end>
        ReadOnly = True
        RowSelect = True
        ShowColumnHeaders = False
        SortType = stText
        TabOrder = 0
        ViewStyle = vsReport
        OnClick = lvSearchClick
      end
    end
  end
  object ActionList: TActionList
    Images = dmImages.il16x16
    Left = 293
    Top = 129
    object actNewValue: TAction
      Category = 'Values'
      Caption = 'Создать...'
      Hint = 'Создать параметр'
      ImageIndex = 40
      OnExecute = actNewValueExecute
      OnUpdate = actNewValueUpdate
    end
    object actNewFolder: TAction
      Category = 'Folders'
      Caption = 'Создать'
      Hint = 'Создать папку'
      ImageIndex = 0
      ShortCut = 45
      OnExecute = actNewFolderExecute
      OnUpdate = actNewFolderUpdate
    end
    object actEditValue: TAction
      Category = 'Values'
      Caption = 'Изменить...'
      Hint = 'Изменить параметр'
      ImageIndex = 38
      OnExecute = actEditValueExecute
      OnUpdate = actEditValueUpdate
    end
    object actSaveStorage: TAction
      Caption = 'Записать в базу'
      Hint = 'Сохранить в базе данных'
      ImageIndex = 18
      OnExecute = actSaveStorageExecute
      OnUpdate = actSaveStorageUpdate
    end
    object actEditFolder: TAction
      Category = 'Folders'
      Caption = 'Переименовать'
      Hint = 'Переименовать папку'
      ImageIndex = 1
      ShortCut = 113
      OnExecute = actEditFolderExecute
      OnUpdate = actEditFolderUpdate
    end
    object actDeleteFolder: TAction
      Category = 'Folders'
      Caption = 'Удалить'
      Hint = 'Удалить папку'
      ImageIndex = 2
      ShortCut = 16430
      OnExecute = actDeleteFolderExecute
      OnUpdate = actDeleteFolderUpdate
    end
    object actDeleteValue: TAction
      Category = 'Values'
      Caption = 'Удалить'
      Hint = 'Удалить параметр'
      ImageIndex = 41
      OnExecute = actDeleteValueExecute
      OnUpdate = actDeleteValueUpdate
    end
    object actSearch: TAction
      Caption = 'Поиск...'
      Hint = 'Поиск'
      ImageIndex = 23
      ShortCut = 114
      OnExecute = actSearchExecute
    end
    object actSaveToFile: TAction
      Caption = 'Сохранить в файл...'
      Hint = 'Сохранить в файл'
      ImageIndex = 25
      OnExecute = actSaveToFileExecute
      OnUpdate = actSaveToFileUpdate
    end
    object actLoadFromFile: TAction
      Caption = 'Загрузить из файла...'
      Hint = 'Загрузить из файла'
      ImageIndex = 27
      OnExecute = actLoadFromFileExecute
      OnUpdate = actLoadFromFileUpdate
    end
    object actRefresh: TAction
      Caption = 'Обновить'
      Hint = 'Обновить'
      ImageIndex = 17
      ShortCut = 116
      OnExecute = actRefreshExecute
    end
    object actShowFolderProp: TAction
      Category = 'Folders'
      Caption = 'Свойства...'
      Hint = 'Свойства папки'
      ImageIndex = 30
      OnExecute = actShowFolderPropExecute
      OnUpdate = actShowFolderPropUpdate
    end
    object actAddFolderToSetting: TAction
      Category = 'Folders'
      Caption = 'Добавить в настройку...'
      Hint = 'Добавить в настройку'
      ImageIndex = 81
      OnExecute = actAddFolderToSettingExecute
      OnUpdate = actAddFolderToSettingUpdate
    end
    object actAddValueToSetting: TAction
      Category = 'Values'
      Caption = 'Добавить в настройку...'
      Hint = 'Добавить значение в настройку'
      ImageIndex = 81
      OnExecute = actAddValueToSettingExecute
      OnUpdate = actAddValueToSettingUpdate
    end
    object actRenameValue: TAction
      Caption = 'Переименовать...'
      Hint = 'Переименовать'
      ImageIndex = 37
      OnExecute = actRenameValueExecute
      OnUpdate = actRenameValueUpdate
    end
    object actHelp: TAction
      Caption = 'Справка'
      Hint = 'Справка'
      ImageIndex = 13
      ShortCut = 112
      OnExecute = actHelpExecute
    end
    object actShowInSett: TAction
      Category = 'Folders'
      Caption = 'Показывать входящие в настройку'
      OnExecute = actShowInSettExecute
      OnUpdate = actShowInSettUpdate
    end
  end
  object pmMain: TPopupMenu
    Images = dmImages.il16x16
    Left = 57
    Top = 137
    object actNewFolder1: TMenuItem
      Action = actNewFolder
      Caption = 'Создать раздел'
    end
    object actEditFolder1: TMenuItem
      Action = actEditFolder
      Caption = 'Переименовать раздел'
    end
    object actDeleteFolder1: TMenuItem
      Action = actDeleteFolder
      Caption = 'Удалить раздел'
    end
    object actSearch1: TMenuItem
      Action = actSearch
    end
    object actRefresh1: TMenuItem
      Action = actRefresh
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object actSaveToFile1: TMenuItem
      Action = actSaveToFile
    end
    object actLoadFromFile1: TMenuItem
      Action = actLoadFromFile
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object actAddFolderToSetting1: TMenuItem
      Action = actAddFolderToSetting
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object actShowFolderProp1: TMenuItem
      Action = actShowFolderProp
    end
  end
  object pmDetail: TPopupMenu
    Images = dmImages.il16x16
    Left = 184
    Top = 113
    object actNewInteger1: TMenuItem
      Action = actNewValue
      Caption = 'Создать параметр...'
    end
    object actEditValue1: TMenuItem
      Action = actEditValue
      Caption = 'Изменить параметр...'
    end
    object actDeleteValue1: TMenuItem
      Action = actDeleteValue
      Caption = 'Удалить параметр'
    end
    object N4: TMenuItem
      Action = actRenameValue
    end
    object spValue1: TMenuItem
      Caption = '-'
    end
    object actAddValueToSetting1: TMenuItem
      Action = actAddValueToSetting
    end
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'stt'
    FileName = 'storage'
    Filter = 
      'Файлы хранилища (текст) *.stt|*.stt|Файлы хранилища (двоичные да' +
      'нные) *.stb|*.stb|Все файлы *.*|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Title = 'Сохранение данных хранилища'
    Left = 306
    Top = 88
  end
  object OpenDialog: TOpenDialog
    DefaultExt = 'stt'
    FileName = 'storage'
    Filter = 
      'Файлы хранилища (текст) *.stt|*.stt|Файлы хранилища (двоичные да' +
      'нные) *.stb|*.stb|Все файлы *.*|*.*'
    Title = 'Считывание данных хранилища'
    Left = 366
    Top = 88
  end
end
