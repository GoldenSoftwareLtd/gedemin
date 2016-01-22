object at_frmUserForm: Tat_frmUserForm
  Left = 115
  Top = 93
  Width = 670
  Height = 445
  Caption = 'Формы пользователя'
  Color = clBtnFace
  Constraints.MinHeight = 140
  Constraints.MinWidth = 180
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Scaled = False
  Visible = True
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object sbMain: TStatusBar
    Left = 0
    Top = 387
    Width = 654
    Height = 19
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Panels = <
      item
        Width = 400
      end
      item
        Width = 160
      end>
    SimplePanel = False
    UseSystemFont = False
  end
  object TBDockTop: TTBDock
    Left = 0
    Top = 0
    Width = 654
    Height = 51
    object tbMainToolbar: TTBToolbar
      Left = 0
      Top = 25
      Caption = 'Панель инструментов'
      CloseButton = False
      DockPos = 16
      DockRow = 1
      FloatingMode = fmOnTopOfAllForms
      Images = dmImages.il16x16
      ParentShowHint = False
      ProcessShortCuts = True
      ShowHint = True
      Stretch = True
      TabOrder = 0
      object tbiNew: TTBItem
        Action = actNew
      end
      object tbiEdit: TTBItem
        Action = actEdit
      end
      object tbiDelete: TTBItem
        Action = actDelete
      end
      object tbiMainSep1: TTBSeparatorItem
      end
      object tbiLoadFromFile: TTBItem
        Action = actLoadFromFile
      end
      object tbiSaveToFile: TTBItem
        Action = actSaveToFile
      end
      object tbiHelp: TTBItem
        Action = actHlp
        Visible = False
      end
    end
    object tbMainMenu: TTBToolbar
      Left = 0
      Top = 0
      Caption = 'Главное меню'
      CloseButton = False
      DockPos = 48
      DockRow = 1
      FullSize = True
      MenuBar = True
      ProcessShortCuts = True
      ShrinkMode = tbsmWrap
      TabOrder = 1
      object tbsiMainMenuObject: TTBSubmenuItem
        Caption = 'Главный'
        object tbi_mm_New: TTBItem
          Action = actNew
        end
        object tbi_mm_Edit: TTBItem
          Action = actEdit
        end
        object tbi_mm_Delete: TTBItem
          Action = actDelete
        end
        object tbi_mm_Duplicate: TTBItem
          Caption = 'Дубликат'
          Hint = 'Дубликат'
          ImageIndex = 3
        end
        object tbi_mm_Reduction: TTBItem
          Caption = 'Слияние ...'
          Hint = 'Слияние'
          ImageIndex = 4
        end
        object tbi_mm_sep1: TTBSeparatorItem
        end
        object tbi_mm_Copy: TTBItem
          Caption = 'Копировать'
          Hint = 'Копировать'
          ImageIndex = 10
          ShortCut = 16429
        end
        object tbi_mm_Cut: TTBItem
          Caption = 'Вырезать'
          Hint = 'Вырезать'
          ImageIndex = 9
          ShortCut = 8238
        end
        object tbi_mm_Paste: TTBItem
          Caption = 'Вставить'
          Hint = 'Вставить'
          ImageIndex = 11
          ShortCut = 8237
        end
        object tbi_mm_sep2: TTBSeparatorItem
        end
        object tbi_mm_Load: TTBItem
          Action = actLoadFromFile
        end
        object tbi_mm_Save: TTBItem
          Action = actSaveToFile
        end
        object tbi_mm_sep3: TTBSeparatorItem
        end
        object tbi_mm_Commit: TTBItem
          Caption = 'Сохранить'
          Hint = 'Сохранить'
          ImageIndex = 18
        end
        object tbi_mm_Rollback: TTBItem
          Caption = 'Отменить'
          Hint = 'Отменить'
          ImageIndex = 19
        end
        object tbi_mm_sep4: TTBSeparatorItem
        end
        object tbi_mm_Find: TTBItem
          Caption = 'Поиск ...'
          Hint = 'Поиск'
          ImageIndex = 23
          ShortCut = 16467
        end
        object tbi_mm_Filter: TTBItem
          Caption = 'Фильтр'
          ImageIndex = 20
          Options = [tboDropdownArrow]
          ShortCut = 16454
        end
        object tbi_mm_Print: TTBItem
          Caption = 'Печать'
          Hint = 'Печать'
          ImageIndex = 15
          Options = [tboDropdownArrow]
          ShortCut = 16464
        end
        object tbi_mm_Macro: TTBItem
          Caption = 'Макросы'
          Hint = 'Макросы и события'
          ImageIndex = 21
          Options = [tboDropdownArrow, tboShowHint]
          ShortCut = 16461
        end
        object tbi_mm_OnlySelected: TTBItem
          Caption = 'Только отмеченные'
          Hint = 'Только отмеченные'
          ImageIndex = 6
        end
      end
      object tbsiMainMenuHelp: TTBSubmenuItem
        Caption = 'Справка'
        object tbiMainMenuHelp: TTBItem
          Action = actHlp
        end
      end
    end
    object tbChooseMain: TTBToolbar
      Left = 456
      Top = 25
      Caption = 'Дополнительная панель инструментов'
      CloseButton = False
      DockPos = 456
      DockRow = 1
      FloatingMode = fmOnTopOfAllForms
      Images = dmImages.il16x16
      ParentShowHint = False
      ShowHint = True
      Stretch = True
      TabOrder = 2
      object tbiSelectAll: TTBItem
        Action = actSelectAll
      end
      object tbiUnSelectAll: TTBItem
        Action = actUnSelectAll
      end
    end
  end
  object TBDockLeft: TTBDock
    Left = 0
    Top = 51
    Width = 9
    Height = 327
    Position = dpLeft
  end
  object TBDockRight: TTBDock
    Left = 645
    Top = 51
    Width = 9
    Height = 327
    Position = dpRight
  end
  object TBDockBottom: TTBDock
    Left = 0
    Top = 378
    Width = 654
    Height = 9
    Position = dpBottom
  end
  object pnlWorkArea: TPanel
    Left = 9
    Top = 51
    Width = 636
    Height = 327
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 5
    object spChoose: TSplitter
      Left = 0
      Top = 225
      Width = 636
      Height = 3
      Cursor = crVSplit
      Align = alBottom
    end
    object pnlMain: TPanel
      Left = 0
      Top = 0
      Width = 636
      Height = 225
      Align = alClient
      BevelOuter = bvNone
      Constraints.MinHeight = 100
      Constraints.MinWidth = 200
      TabOrder = 0
      object ibgrMain: TgsDBGrid
        Left = 0
        Top = 0
        Width = 636
        Height = 225
        Align = alClient
        DataSource = dsMain
        PopupMenu = pmMain
        ReadOnly = True
        RefreshType = rtNone
        TabOrder = 0
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.DisplayField = 'FormName'
        CheckBox.FieldName = 'FormName'
        CheckBox.Visible = True
        CheckBox.CheckBoxEvent = ibgrMainClickCheck
        CheckBox.FirstColumn = True
        MinColWidth = 40
        OnClickCheck = ibgrMainClickCheck
      end
    end
    object pnChoose: TPanel
      Left = 0
      Top = 228
      Width = 636
      Height = 99
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      object pnButtonChoose: TPanel
        Left = 531
        Top = 0
        Width = 105
        Height = 99
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 0
        object btnCancelChoose: TButton
          Left = 14
          Top = 27
          Width = 75
          Height = 19
          Caption = 'Отмена'
          ModalResult = 2
          TabOrder = 0
        end
        object btnOkChoose: TButton
          Left = 14
          Top = 3
          Width = 75
          Height = 19
          Caption = 'Ok'
          Default = True
          ModalResult = 1
          TabOrder = 1
        end
        object btnDelSelect: TButton
          Left = 14
          Top = 51
          Width = 75
          Height = 19
          Action = actDeleteChoose
          Caption = 'Удалить'
          TabOrder = 2
        end
      end
      object ibgrChoose: TgsDBGrid
        Left = 0
        Top = 0
        Width = 531
        Height = 99
        Align = alClient
        BorderStyle = bsNone
        DataSource = dsChoose
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgTabs, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
        ReadOnly = True
        TabOrder = 1
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.Visible = False
        CheckBox.FirstColumn = False
        MinColWidth = 40
      end
    end
  end
  object alMain: TActionList
    Images = dmImages.il16x16
    Left = 92
    Top = 176
    object actNew: TAction
      Category = 'Commands'
      Caption = 'Добавить ...'
      Hint = 'Добавить'
      ImageIndex = 0
      ShortCut = 45
      OnExecute = actNewExecute
    end
    object actEdit: TAction
      Category = 'Commands'
      Caption = 'Изменить ...'
      Hint = 'Изменить'
      ImageIndex = 1
      OnExecute = actEditExecute
    end
    object actDelete: TAction
      Category = 'Commands'
      Caption = 'Удалить'
      Hint = 'Удалить'
      ImageIndex = 2
      ShortCut = 46
      OnExecute = actDeleteExecute
      OnUpdate = actDeleteUpdate
    end
    object actHlp: TAction
      Category = 'Commands'
      Caption = 'Помощь'
      Hint = 'Помощь'
      ImageIndex = 13
      ShortCut = 112
    end
    object actLoadFromFile: TAction
      Category = 'Commands'
      Caption = 'Загрузить'
      Hint = 'Загрузить из файла'
      ImageIndex = 27
      OnExecute = actLoadFromFileExecute
    end
    object actSaveToFile: TAction
      Category = 'Commands'
      Caption = 'Сохранить'
      Hint = 'Сохранить в файл'
      ImageIndex = 25
      OnExecute = actSaveToFileExecute
      OnUpdate = actSaveToFileUpdate
    end
    object actDeleteChoose: TAction
      Category = 'Choose'
      Caption = 'Удалить выбранные записи'
      Hint = 'Удалить выбранные записи'
      ImageIndex = 32
      OnExecute = actDeleteChooseExecute
      OnUpdate = actDeleteChooseUpdate
    end
    object actMainToSetting: TAction
      Category = 'Commands'
      Caption = 'Пространство имен...'
      Hint = 'Добавить в пространство имен'
      OnExecute = actMainToSettingExecute
      OnUpdate = actMainToSettingUpdate
    end
    object actLoadForms: TAction
      Category = 'Commands'
      Caption = 'Перечитать список форм'
      Hint = 'Перечитать список форм'
      ShortCut = 116
      OnExecute = actLoadFormsExecute
    end
    object actSelectAll: TAction
      Category = 'Choose'
      Caption = 'Выделить все записи'
      Hint = 'Выделить все записи'
      ImageIndex = 40
      OnExecute = actSelectAllExecute
    end
    object actUnSelectAll: TAction
      Category = 'Choose'
      Caption = 'Убрать выделение'
      Hint = 'Убрать выделение'
      ImageIndex = 41
      OnExecute = actUnSelectAllExecute
      OnUpdate = actUnSelectAllUpdate
    end
  end
  object pmMain: TPopupMenu
    Images = dmImages.il16x16
    Left = 124
    Top = 204
    object nNew_OLD: TMenuItem
      Action = actNew
    end
    object nEdit_OLD: TMenuItem
      Action = actEdit
    end
    object nDel_OLD: TMenuItem
      Action = actDelete
    end
    object sprSetting: TMenuItem
      Caption = '-'
    end
    object miMainToSetting: TMenuItem
      Action = actMainToSetting
    end
    object miMainSep2: TMenuItem
      Caption = '-'
    end
    object miLoadForms: TMenuItem
      Action = actLoadForms
    end
  end
  object dsMain: TDataSource
    DataSet = cldsMain
    Left = 92
    Top = 204
  end
  object dsChoose: TDataSource
    DataSet = cldsChoose
    Left = 153
    Top = 346
  end
  object cldsMain: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 209
    Top = 161
    object cldsMainFormName: TStringField
      FieldName = 'FormName'
      Size = 255
    end
  end
  object cldsChoose: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 273
    Top = 363
    object cldsChooseFormName: TStringField
      FieldName = 'FormName'
      Size = 255
    end
  end
  object OpenDialog: TOpenDialog
    DefaultExt = 'stt'
    FileName = 'storage'
    Filter = 
      'Файлы хранилища (текст) *.stt|*.stt|Файлы хранилища (двоичные да' +
      'нные) *.stb|*.stb|Все файлы *.*|*.*'
    Title = 'Считывание данных хранилища'
    Left = 350
    Top = 120
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'stt'
    FileName = 'storage'
    Filter = 
      'Файлы хранилища (текст) *.stt|*.stt|Файлы хранилища (двоичные да' +
      'нные) *.stb|*.stb|Все файлы *.*|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Title = 'Сохранение данных хранилища'
    Left = 290
    Top = 120
  end
end
