object gdc_frmG: Tgdc_frmG
  Left = 452
  Top = 263
  Width = 659
  Height = 411
  HelpContext = 116
  Caption = 'gdc_frmG'
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
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnHide = FormHide
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object sbMain: TStatusBar
    Left = 0
    Top = 365
    Width = 651
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
    ParentShowHint = False
    ShowHint = True
    SimplePanel = False
    UseSystemFont = False
  end
  object TBDockTop: TTBDock
    Left = 0
    Top = 0
    Width = 651
    Height = 49
    object tbMainToolbar: TTBToolbar
      Left = 0
      Top = 23
      Caption = 'Панель инструментов'
      CloseButton = False
      DockMode = dmCannotFloat
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
      object tbiDuplicate: TTBItem
        Action = actDuplicate
      end
      object tbiReduction: TTBItem
        Action = actMainReduction
      end
      object tbsiMainOne: TTBSeparatorItem
      end
      object tbiEditInGrid: TTBItem
        Action = actEditInGrid
      end
      object tbiCopy: TTBItem
        Action = actCopy
      end
      object tbiCut: TTBItem
        Action = actCut
      end
      object tbiPaste: TTBItem
        Action = actPaste
      end
      object tbsiMainOneAndHalf: TTBSeparatorItem
      end
      object tbiLoadFromFile: TTBItem
        Action = actLoadFromFile
      end
      object tbiSaveToFile: TTBItem
        Action = actSaveToFile
      end
      object tbsiMainTwo: TTBSeparatorItem
      end
      object tbiFind: TTBItem
        Action = actFind
      end
      object tbiFilter: TTBItem
        Action = actFilter
        Options = [tboDropdownArrow]
      end
      object tbiPrint: TTBItem
        Action = actPrint
        Options = [tboDropdownArrow]
      end
      object tbiOnlySelected: TTBItem
        Action = actOnlySelected
      end
      object tbiLinkObject: TTBItem
        Action = actLinkObject
      end
      object tbsiMainThreeAndAHalf: TTBSeparatorItem
      end
      object tbiHelp: TTBItem
        Action = actHlp
        Visible = False
      end
    end
    object tbMainCustom: TTBToolbar
      Left = 512
      Top = 23
      Caption = 'Дополнительная панель инструментов'
      CloseButton = False
      DockMode = dmCannotFloat
      DockPos = 512
      DockRow = 1
      FloatingMode = fmOnTopOfAllForms
      Images = dmImages.il16x16
      ParentShowHint = False
      ShowHint = True
      Stretch = True
      TabOrder = 1
      Visible = False
    end
    object tbMainMenu: TTBToolbar
      Left = 0
      Top = 0
      Caption = 'Главное меню'
      CloseButton = False
      DockMode = dmCannotFloat
      DockPos = 0
      FullSize = True
      MenuBar = True
      ProcessShortCuts = True
      ShrinkMode = tbsmWrap
      TabOrder = 2
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
          Action = actDuplicate
        end
        object tbi_mm_Reduction: TTBItem
          Action = actMainReduction
        end
        object tbi_mm_sep1_1: TTBSeparatorItem
        end
        object tbi_mm_Copy: TTBItem
          Action = actCopy
        end
        object tbi_mm_Cut: TTBItem
          Action = actCut
        end
        object tbi_mm_Paste: TTBItem
          Action = actPaste
        end
        object tbi_mm_sep2_2_: TTBSeparatorItem
        end
        object tbi_mm_AddToSelected: TTBItem
          Action = actAddToSelected
        end
        object tbi_mm_RemoveFromSelected: TTBItem
          Action = actRemoveFromSelected
        end
        object tbi_mm_sep2_1: TTBSeparatorItem
        end
        object tbi_mm_Load: TTBItem
          Action = actLoadFromFile
        end
        object tbi_mm_Save: TTBItem
          Action = actSaveToFile
        end
        object tbi_mm_sep3_1: TTBSeparatorItem
        end
        object tbi_mm_Commit: TTBItem
          Action = actCommit
        end
        object tbi_mm_Rollback: TTBItem
          Action = actRollback
        end
        object tbi_mm_sep4_1: TTBSeparatorItem
        end
        object tbi_mm_Find: TTBItem
          Action = actFind
        end
        object tbi_mm_Filter: TTBItem
          Action = actFilter
          Options = [tboDropdownArrow]
        end
        object tbi_mm_Print: TTBItem
          Action = actPrint
          Options = [tboDropdownArrow]
        end
        object tbi_mm_Macro: TTBItem
          Action = actMacros
          Options = [tboDropdownArrow, tboShowHint]
        end
        object tbi_mm_OnlySelected: TTBItem
          Action = actOnlySelected
        end
        object tbi_mm_LinkObject: TTBItem
          Action = actLinkObject
        end
        object tbi_mm_sep5_1: TTBSeparatorItem
        end
        object tbi_mm_MainToSetting: TTBItem
          Action = actMainToSetting
        end
        object tbi_mm_sep5_2_: TTBSeparatorItem
        end
        object tbi_mm_CopySettings: TTBItem
          Action = actCopySettingsFromUser
        end
        object tbiDistributeSettings: TTBItem
          Action = actDistributeSettings
        end
        object tbiDontSaveSettings: TTBItem
          Action = actDontSaveSettings
        end
      end
      object tbsiMainMenuHelp: TTBSubmenuItem
        Caption = 'Справка'
        object tbiMainMenuHelp: TTBItem
          Action = actHlp
        end
      end
    end
    object tbMainInvariant: TTBToolbar
      Left = 298
      Top = 23
      Caption = 'Дополнительная панель инструментов'
      CloseButton = False
      DockMode = dmCannotFloat
      DockPos = 280
      DockRow = 1
      Images = dmImages.il16x16
      ParentShowHint = False
      ShowHint = True
      Stretch = True
      TabOrder = 3
      OnVisibleChanged = tbMainInvariantVisibleChanged
      object tbiCommit: TTBItem
        Action = actCommit
      end
      object tbiRollback: TTBItem
        Action = actRollback
      end
      object tbsiMainThree: TTBSeparatorItem
      end
      object tbiMacros: TTBItem
        Action = actMacros
        Options = [tboDropdownArrow, tboShowHint]
      end
    end
    object tbChooseMain: TTBToolbar
      Left = 456
      Top = 23
      Caption = 'Дополнительная панель инструментов'
      CloseButton = False
      DockMode = dmCannotFloat
      DockPos = 456
      DockRow = 1
      FloatingMode = fmOnTopOfAllForms
      Images = dmImages.il16x16
      ParentShowHint = False
      ShowHint = True
      Stretch = True
      TabOrder = 4
      Visible = False
      object tbiSelectAll: TTBItem
        Action = actSelectAll
      end
      object tbiUnSelectAll: TTBItem
        Action = actUnSelectAll
      end
      object tbiClearSelection: TTBItem
        Action = actClearSelection
      end
    end
  end
  object TBDockLeft: TTBDock
    Left = 0
    Top = 49
    Width = 9
    Height = 307
    Position = dpLeft
  end
  object TBDockRight: TTBDock
    Left = 642
    Top = 49
    Width = 9
    Height = 307
    Position = dpRight
  end
  object TBDockBottom: TTBDock
    Left = 0
    Top = 356
    Width = 651
    Height = 9
    Position = dpBottom
  end
  object pnlWorkArea: TPanel
    Left = 9
    Top = 49
    Width = 633
    Height = 307
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 5
    object spChoose: TSplitter
      Left = 0
      Top = 204
      Width = 633
      Height = 4
      Cursor = crVSplit
      Align = alBottom
      Visible = False
    end
    object pnlMain: TPanel
      Left = 0
      Top = 0
      Width = 633
      Height = 204
      Align = alClient
      BevelOuter = bvNone
      Constraints.MinHeight = 100
      Constraints.MinWidth = 200
      TabOrder = 0
      object pnlSearchMain: TPanel
        Left = 0
        Top = 0
        Width = 160
        Height = 204
        Align = alLeft
        BevelOuter = bvNone
        Color = 14741233
        TabOrder = 0
        Visible = False
        OnEnter = pnlSearchMainEnter
        OnExit = pnlSearchMainExit
        object sbSearchMain: TScrollBox
          Left = 0
          Top = 0
          Width = 160
          Height = 166
          HorzScrollBar.Style = ssFlat
          HorzScrollBar.Visible = False
          VertScrollBar.Style = ssFlat
          Align = alClient
          BorderStyle = bsNone
          TabOrder = 0
        end
        object pnlSearchMainButton: TPanel
          Left = 0
          Top = 166
          Width = 160
          Height = 38
          Align = alBottom
          BevelOuter = bvNone
          ParentColor = True
          TabOrder = 1
          object btnSearchMain: TButton
            Left = 12
            Top = 16
            Width = 64
            Height = 18
            Action = actSearchMain
            Default = True
            TabOrder = 1
          end
          object btnSearchMainClose: TButton
            Left = 83
            Top = 15
            Width = 64
            Height = 19
            Action = actSearchMainClose
            TabOrder = 2
          end
          object chbxFuzzyMatch: TCheckBox
            Left = 12
            Top = -2
            Width = 97
            Height = 17
            Caption = 'Найти похожие'
            TabOrder = 0
            Visible = False
          end
        end
      end
    end
    object pnChoose: TPanel
      Left = 0
      Top = 208
      Width = 633
      Height = 99
      Align = alBottom
      BevelOuter = bvNone
      Constraints.MinHeight = 94
      TabOrder = 1
      Visible = False
      object pnButtonChoose: TPanel
        Left = 528
        Top = 18
        Width = 105
        Height = 81
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
          Action = actChooseOk
          Default = True
          TabOrder = 1
        end
        object btnDeleteChoose: TButton
          Left = 14
          Top = 51
          Width = 75
          Height = 19
          Action = actDeleteChoose
          TabOrder = 2
        end
      end
      object ibgrChoose: TgsIBGrid
        Left = 0
        Top = 18
        Width = 528
        Height = 81
        HelpContext = 3
        Align = alClient
        BorderStyle = bsNone
        DataSource = dsChoose
        Options = [dgTitles, dgColumnResize, dgColLines, dgTabs, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
        TabOrder = 1
        Visible = False
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        TitlesExpanding = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.Visible = False
        CheckBox.FirstColumn = False
        MinColWidth = 40
        ColumnEditors = <>
        Aliases = <>
        ShowTotals = False
      end
      object pnlChooseCaption: TPanel
        Left = 0
        Top = 0
        Width = 633
        Height = 18
        Align = alTop
        Alignment = taLeftJustify
        BevelOuter = bvNone
        Caption = '  Выбранные записи:'
        Color = clBtnHighlight
        TabOrder = 2
      end
    end
  end
  object alMain: TActionList
    Images = dmImages.il16x16
    Left = 92
    Top = 168
    object actNew: TAction
      Category = 'Commands'
      Caption = 'Добавить...'
      Hint = 'Добавить'
      ImageIndex = 0
      ShortCut = 45
      OnExecute = actNewExecute
      OnUpdate = actNewUpdate
    end
    object actEdit: TAction
      Category = 'Commands'
      Caption = 'Изменить...'
      Hint = 'Изменить'
      ImageIndex = 1
      OnExecute = actEditExecute
      OnUpdate = actEditUpdate
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
    object actDuplicate: TAction
      Category = 'Commands'
      Caption = 'Дубликат...'
      Hint = 'Дубликат'
      ImageIndex = 3
      OnExecute = actDuplicateExecute
      OnUpdate = actDuplicateUpdate
    end
    object actHlp: TAction
      Category = 'Commands'
      Caption = 'Помощь'
      Hint = 'Помощь'
      ImageIndex = 13
      ShortCut = 112
      OnExecute = actHlpExecute
    end
    object actPrint: TAction
      Category = 'Commands'
      Caption = 'Печать'
      Hint = 'Печать'
      ImageIndex = 15
      ShortCut = 16464
      OnExecute = actPrintExecute
      OnUpdate = actPrintUpdate
    end
    object actCut: TAction
      Category = 'Commands'
      Caption = 'Вырезать'
      Enabled = False
      Hint = 'Вырезать'
      ImageIndex = 9
      Visible = False
      OnExecute = actCutExecute
      OnUpdate = actCutUpdate
    end
    object actCopy: TAction
      Category = 'Commands'
      Caption = 'Копировать'
      Enabled = False
      Hint = 'Копировать'
      ImageIndex = 10
      Visible = False
      OnExecute = actCopyExecute
      OnUpdate = actCopyUpdate
    end
    object actPaste: TAction
      Category = 'Commands'
      Caption = 'Вставить'
      Enabled = False
      Hint = 'Вставить'
      ImageIndex = 11
      Visible = False
      OnExecute = actPasteExecute
      OnUpdate = actPasteUpdate
    end
    object actCommit: TAction
      Category = 'Commands'
      Caption = 'Сохранить'
      Hint = 'Сохранить'
      ImageIndex = 18
      OnExecute = actCommitExecute
      OnUpdate = actCommitUpdate
    end
    object actRollback: TAction
      Category = 'Commands'
      Caption = 'Отменить'
      Hint = 'Отменить'
      ImageIndex = 19
      Visible = False
      OnExecute = actRollbackExecute
      OnUpdate = actRollbackUpdate
    end
    object actMacros: TAction
      Category = 'Commands'
      Caption = 'Макросы'
      Hint = 'Макросы и события'
      ImageIndex = 21
      ShortCut = 16461
      OnExecute = actMacrosExecute
      OnUpdate = actMacrosUpdate
    end
    object actFind: TAction
      Category = 'Commands'
      Caption = 'Поиск...'
      Hint = 'Поиск'
      ImageIndex = 23
      ShortCut = 16467
      OnExecute = actFindExecute
      OnUpdate = actFindUpdate
    end
    object actMainReduction: TAction
      Category = 'Commands'
      Caption = 'Слияние...'
      Hint = 'Слияние'
      ImageIndex = 4
      OnExecute = actMainReductionExecute
      OnUpdate = actMainReductionUpdate
    end
    object actFilter: TAction
      Category = 'Commands'
      Caption = 'Фильтр'
      Hint = 'Фильтр'
      ImageIndex = 20
      OnExecute = actFilterExecute
      OnUpdate = actFilterUpdate
    end
    object actProperties: TAction
      Category = 'Commands'
      Caption = 'Свойства...'
      Hint = 'Свойства'
      ImageIndex = 28
      OnExecute = actPropertiesExecute
      OnUpdate = actPropertiesUpdate
    end
    object actLoadFromFile: TAction
      Category = 'Commands'
      Caption = 'Загрузить из файла...'
      Hint = 'Загрузить из файла'
      ImageIndex = 27
      OnExecute = actLoadFromFileExecute
      OnUpdate = actNewUpdate
    end
    object actSaveToFile: TAction
      Category = 'Commands'
      Caption = 'Сохранить в файл...'
      Hint = 'Сохранить в файл'
      ImageIndex = 25
      OnExecute = actSaveToFileExecute
      OnUpdate = actSaveToFileUpdate
    end
    object actSearchMain: TAction
      Category = 'Commands'
      Caption = 'Найти'
      Hint = 'Найти'
      OnExecute = actSearchMainExecute
      OnUpdate = actSearchMainUpdate
    end
    object actSearchMainClose: TAction
      Category = 'Commands'
      Caption = 'Закрыть'
      Hint = 'Закрыть'
      OnExecute = actSearchMainCloseExecute
    end
    object actOnlySelected: TAction
      Category = 'Commands'
      Caption = 'Только отмеченные'
      Hint = 'Только отмеченные'
      ImageIndex = 6
      OnExecute = actOnlySelectedExecute
      OnUpdate = actOnlySelectedUpdate
    end
    object actAddToSelected: TAction
      Category = 'Commands'
      Caption = 'Добавить в отмеченные'
      Hint = 'Добавить в отмеченные'
      ImageIndex = 5
      OnExecute = actAddToSelectedExecute
      OnUpdate = actAddToSelectedUpdate
    end
    object actRemoveFromSelected: TAction
      Category = 'Commands'
      Caption = 'Удалить из отмеченных'
      Hint = 'Удалить из отмеченных'
      OnExecute = actRemoveFromSelectedExecute
      OnUpdate = actAddToSelectedUpdate
    end
    object actQExport: TAction
      Caption = 'Экспорт...'
      OnExecute = actQExportExecute
      OnUpdate = actQExportUpdate
    end
    object actMainToSetting: TAction
      Category = 'Commands'
      Caption = 'Добавить в настройку ...'
      Hint = 'Добавить в настройку'
      ImageIndex = 81
      OnExecute = actMainToSettingExecute
      OnUpdate = actMainToSettingUpdate
    end
    object actChooseOk: TAction
      Category = 'Choose'
      Caption = 'Ok'
      Hint = 'Выбрать записи'
      OnExecute = actChooseOkExecute
      OnUpdate = actChooseOkUpdate
    end
    object actDeleteChoose: TAction
      Category = 'Choose'
      Caption = 'Удалить'
      Hint = 'Удалить из выбранных'
      OnExecute = actDeleteChooseExecute
      OnUpdate = actDeleteChooseUpdate
    end
    object actCopySettingsFromUser: TAction
      Caption = 'Загрузить настройки формы...'
      Hint = 'Загрузить настройки формы...'
      ImageIndex = 33
      OnExecute = actCopySettingsFromUserExecute
      OnUpdate = actCopySettingsFromUserUpdate
    end
    object actSelectAll: TAction
      Category = 'Choose'
      Caption = 'Выделить все'
      Hint = 'Выделить все'
      ImageIndex = 40
      Visible = False
      OnExecute = actSelectAllExecute
      OnUpdate = actSelectAllUpdate
    end
    object actUnSelectAll: TAction
      Category = 'Choose'
      Caption = 'Убрать выделение'
      Hint = 'Убрать выделение'
      ImageIndex = 41
      Visible = False
      OnExecute = actUnSelectAllExecute
      OnUpdate = actUnSelectAllUpdate
    end
    object actClearSelection: TAction
      Category = 'Choose'
      Caption = 'Убрать выделение со всех записей'
      Hint = 'Убрать выделение со всех записей'
      ImageIndex = 39
      Visible = False
      OnExecute = actClearSelectionExecute
      OnUpdate = actClearSelectionUpdate
    end
    object actEditInGrid: TAction
      Category = 'Commands'
      Caption = 'Редактирование в таблице'
      Hint = 'Редактирование в таблице'
      ImageIndex = 213
      Visible = False
    end
    object actLinkObject: TAction
      Category = 'Commands'
      Caption = 'Прикрепить...'
      Hint = 'Прикрепления'
      ImageIndex = 265
      OnExecute = actLinkObjectExecute
      OnUpdate = actLinkObjectUpdate
    end
    object actDistributeSettings: TAction
      Caption = 'Распространить настройки формы'
      ImageIndex = 236
      OnExecute = actDistributeSettingsExecute
      OnUpdate = actDistributeSettingsUpdate
    end
    object actDontSaveSettings: TAction
      Caption = 'Не сохранять настройки формы'
      OnExecute = actDontSaveSettingsExecute
      OnUpdate = actDontSaveSettingsUpdate
    end
  end
  object pmMain: TPopupMenu
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
    object nDublicate_OLD: TMenuItem
      Action = actDuplicate
    end
    object nProperties_OLD: TMenuItem
      Action = actProperties
    end
    object nQExport_OLD: TMenuItem
      Action = actQExport
    end
    object nSeparator1_OLD: TMenuItem
      Caption = '-'
    end
    object actCopy1_OLD: TMenuItem
      Action = actCopy
    end
    object actCut1_OLD: TMenuItem
      Action = actCut
    end
    object actPaste1_OLD: TMenuItem
      Action = actPaste
    end
    object nSepartor2_OLD: TMenuItem
      Caption = '-'
    end
    object nFind_OLD: TMenuItem
      Action = actFind
    end
    object nReduction_OLD: TMenuItem
      Action = actMainReduction
    end
    object nSeparator3_OLD: TMenuItem
      Caption = '-'
    end
    object actAddToSelected1: TMenuItem
      Action = actAddToSelected
    end
    object actRemoveFromSelected1: TMenuItem
      Action = actRemoveFromSelected
    end
    object sprSetting: TMenuItem
      Caption = '-'
    end
    object miMainToSetting: TMenuItem
      Action = actMainToSetting
    end
  end
  object dsMain: TDataSource
    Left = 92
    Top = 204
  end
  object gdMacrosMenu: TgdMacrosMenu
    Left = 249
    Top = 111
  end
  object dsChoose: TDataSource
    Left = 153
    Top = 306
  end
end
