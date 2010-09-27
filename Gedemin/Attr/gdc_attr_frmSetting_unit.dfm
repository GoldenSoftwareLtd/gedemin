inherited gdc_frmSetting: Tgdc_frmSetting
  Left = 317
  Top = 188
  Width = 823
  Height = 485
  HelpContext = 22
  Caption = 'Настройки'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 439
    Width = 815
  end
  inherited TBDockTop: TTBDock
    Width = 815
    inherited tbMainCustom: TTBToolbar
      Left = 431
      DockPos = 431
      object tbiSetActive: TTBItem
        Action = actSetActive
      end
      object tbiReActivate: TTBItem
        Action = actReActivate
      end
      object tbiSaveToBlob: TTBItem
        Action = actSaveToBlob
      end
      object tbsiCustomOne: TTBSeparatorItem
      end
      object tbiSetOrder: TTBItem
        Action = actSetOrder
      end
      object tbiChooseSettings: TTBItem
        Action = actChooseSetings
      end
      object tbiClearDependencies: TTBItem
        Action = actClearDependencies
      end
      object tbsCustomTwo: TTBSeparatorItem
      end
      object tbiSettingView: TTBItem
        Action = actSettingView
      end
      object TBItem8: TTBItem
        Action = actAddMissed
      end
      object TBItem9: TTBItem
        Action = actSet2Txt
      end
    end
    inherited tbMainMenu: TTBToolbar
      inherited tbsiMainMenuObject: TTBSubmenuItem
        object TBSeparatorItem2: TTBSeparatorItem [21]
        end
        object tbsiServiceMain: TTBSubmenuItem [22]
          Caption = 'Сервисные функции'
          object TBItem5: TTBItem
            Action = actSetActive
          end
          object TBItem4: TTBItem
            Action = actReActivate
          end
          object TBItem3: TTBItem
            Action = actSaveToBlob
          end
          object TBItem2: TTBItem
            Action = actSetOrder
          end
          object TBItem1: TTBItem
            Action = actChooseSetings
          end
          object tbiMainSettingView: TTBItem
            Action = actSettingView
          end
        end
      end
      inherited tbsiMainMenuDetailObject: TTBSubmenuItem
        object TBSeparatorItem3: TTBSeparatorItem
        end
        object TBItem7: TTBItem
          Action = actWithDetail
        end
        object tbiDetailNeedModify: TTBItem
          Action = actNeedModify
        end
        object tbiDetailNeedModifyDefault: TTBItem
          Action = actNeedModifyDefault
        end
        object TBItem6: TTBItem
          Action = actValidPos
        end
        object tbimOpenObject: TTBItem
          Action = actOpenObject
        end
      end
      object tbsiStorage: TTBSubmenuItem [2]
        Caption = 'Хранилище'
        object tbiNewForm: TTBItem
          Action = actAddForm
        end
        object tbiDeleteStorage: TTBItem
          Action = actStorageDelete
        end
        object tbsStorageOne: TTBSeparatorItem
        end
        object tbiFindStorage: TTBItem
          Action = actStorageFind
        end
        object tbiFilterStorage: TTBItem
          Action = actStorageFilter
        end
        object tbsStorageTwo: TTBSeparatorItem
        end
        object tbiStorageValid: TTBItem
          Action = actValidStorage
        end
      end
    end
    inherited tbChooseMain: TTBToolbar
      Left = 398
      DockPos = 398
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 381
  end
  inherited TBDockRight: TTBDock
    Left = 806
    Height = 381
  end
  inherited TBDockBottom: TTBDock
    Top = 430
    Width = 815
  end
  inherited pnlWorkArea: TPanel
    Width = 797
    Height = 381
    inherited sMasterDetail: TSplitter
      Width = 797
    end
    inherited spChoose: TSplitter
      Top = 278
      Width = 797
    end
    object spltStorrage: TSplitter [2]
      Left = 539
      Top = 171
      Width = 3
      Height = 107
      Cursor = crHSplit
      Align = alRight
      Visible = False
    end
    inherited pnlMain: TPanel
      Width = 797
      inherited ibgrMain: TgsIBGrid
        Width = 637
      end
    end
    inherited pnChoose: TPanel
      Top = 282
      Width = 797
      inherited pnButtonChoose: TPanel
        Left = 692
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 692
      end
      inherited pnlChooseCaption: TPanel
        Width = 797
      end
    end
    inherited pnlDetail: TPanel
      Width = 539
      Height = 107
      inherited TBDockDetail: TTBDock
        Width = 539
        inherited tbDetailToolbar: TTBToolbar
          object tbiOpenObject: TTBItem
            Action = actOpenObject
          end
        end
        inherited tbDetailCustom: TTBToolbar
          Left = 255
          DockPos = 255
          Images = dmImages.il16x16
          Visible = True
          object tbiWithDetail: TTBItem
            Action = actWithDetail
          end
          object tbiNeedModify: TTBItem
            Action = actNeedModify
          end
          object tbiNeedModifyDefault: TTBItem
            Action = actNeedModifyDefault
          end
          object tbiValidPos: TTBItem
            Action = actValidPos
          end
          object TBItem10: TTBItem
            Action = actAddForm
          end
        end
      end
      inherited pnlSearchDetail: TPanel
        Height = 81
        inherited sbSearchDetail: TScrollBox
          Height = 43
        end
        inherited pnlSearchDetailButton: TPanel
          Top = 43
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 379
        Height = 81
      end
    end
    object pnlStorage: TPanel
      Left = 542
      Top = 171
      Width = 255
      Height = 107
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 3
      Visible = False
      object TBDockStorage: TTBDock
        Left = 0
        Top = 0
        Width = 255
        Height = 26
        object tbStorageToolbar: TTBToolbar
          Left = 0
          Top = 0
          Caption = 'tbDetailToolbar'
          CloseButton = False
          DockMode = dmCannotFloat
          Images = dmImages.il16x16
          ParentShowHint = False
          ShowHint = True
          Stretch = True
          TabOrder = 0
          object tbiStorageAdd: TTBItem
            Action = actAddForm
          end
          object tbiStorageDelete: TTBItem
            Action = actStorageDelete
          end
          object tbsStorage: TTBSeparatorItem
          end
          object tbiStorageFind: TTBItem
            Action = actStorageFind
          end
          object tbiStorageFilter: TTBItem
            Action = actStorageFilter
          end
          object tbsStorage2: TTBSeparatorItem
          end
          object tbiValidStorage: TTBItem
            Action = actValidStorage
          end
        end
      end
      object pnlStorageFind: TPanel
        Left = 0
        Top = 26
        Width = 160
        Height = 81
        Align = alLeft
        BevelOuter = bvNone
        Color = 14741233
        TabOrder = 2
        Visible = False
        object sbSearchStorage: TScrollBox
          Left = 0
          Top = 0
          Width = 160
          Height = 51
          HorzScrollBar.Style = ssFlat
          HorzScrollBar.Visible = False
          VertScrollBar.Style = ssFlat
          Align = alClient
          BorderStyle = bsNone
          TabOrder = 0
        end
        object pnlSearchStorageButton: TPanel
          Left = 0
          Top = 51
          Width = 160
          Height = 30
          Align = alBottom
          BevelOuter = bvNone
          ParentColor = True
          TabOrder = 1
          object btnSearchStorage: TButton
            Left = 12
            Top = 5
            Width = 64
            Height = 19
            Action = actSearchDetail
            Default = True
            TabOrder = 0
          end
          object btnSearchStorageClose: TButton
            Left = 83
            Top = 5
            Width = 64
            Height = 19
            Action = actSearchStorageClose
            Caption = 'Закрыть'
            TabOrder = 1
          end
        end
      end
      object ibgrStorage: TgsIBGrid
        Left = 160
        Top = 26
        Width = 95
        Height = 81
        HelpContext = 3
        Align = alClient
        BorderStyle = bsNone
        DataSource = dsStorage
        Options = [dgTitles, dgColumnResize, dgColLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
        PopupMenu = pmStorage
        ReadOnly = True
        TabOrder = 1
        OnEnter = ibgrStorageEnter
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
      end
    end
  end
  inherited alMain: TActionList
    inherited actDetailEdit: TAction
      Visible = False
    end
    inherited actDetailDuplicate: TAction
      Visible = False
    end
    inherited actDetailPrint: TAction
      Visible = False
    end
    inherited actDetailReduction: TAction
      Visible = False
    end
    inherited actMainToSetting: TAction
      Visible = False
    end
    inherited actDetailToSetting: TAction
      Visible = False
    end
    object actSetActive: TAction
      Category = 'Main'
      Caption = 'Активировать настройку'
      Hint = 'Активировать настройку'
      ImageIndex = 38
      OnExecute = actSetActiveExecute
      OnUpdate = actSetActiveUpdate
    end
    object actSetOrder: TAction
      Category = 'Main'
      Caption = 'Установить порядок позиций'
      Hint = 'Установить порядок позиций'
      ImageIndex = 36
      OnExecute = actSetOrderExecute
      OnUpdate = actSetOrderUpdate
    end
    object actSaveToBlob: TAction
      Category = 'Main'
      Caption = 'Сформировать настройку'
      Hint = 'Сформировать настройку'
      ImageIndex = 7
      OnExecute = actSaveToBlobExecute
      OnUpdate = actSaveToBlobUpdate
    end
    object actStorageDelete: TAction
      Category = 'Storage'
      Caption = 'Удалить'
      Hint = 'Удалить'
      ImageIndex = 2
      OnExecute = actStorageDeleteExecute
      OnUpdate = actStorageDeleteUpdate
    end
    object actStorageFind: TAction
      Category = 'Storage'
      Caption = 'Поиск'
      Hint = 'Поиск'
      ImageIndex = 23
      OnExecute = actStorageFindExecute
      OnUpdate = actStorageFindUpdate
    end
    object actStorageFilter: TAction
      Category = 'Storage'
      Caption = 'Фильтр'
      Hint = 'Фильтр'
      ImageIndex = 20
      OnExecute = actStorageFilterExecute
      OnUpdate = actStorageFilterUpdate
    end
    object actSearchStorageClose: TAction
      Category = 'Storage'
      Caption = 'actSearchStorageClose'
      OnExecute = actSearchStorageCloseExecute
    end
    object actSearchStorage: TAction
      Category = 'Storage'
      Caption = 'actSearchStorage'
      OnExecute = actSearchStorageExecute
    end
    object actAddForm: TAction
      Category = 'Storage'
      Caption = 'Добавить форму пользователя'
      Hint = 'Добавить форму пользователя'
      ImageIndex = 229
      OnExecute = actAddFormExecute
      OnUpdate = actAddFormUpdate
    end
    object actWithDetail: TAction
      Category = 'Detail'
      Caption = 'Сохранять с детальными '
      Hint = 'Сохранять вместе с детальными объектами'
      ImageIndex = 105
      OnExecute = actWithDetailExecute
      OnUpdate = actWithDetailUpdate
    end
    object actReActivate: TAction
      Category = 'Main'
      Caption = 'Переактивация настройки'
      Hint = 'Переактивация настройки'
      ImageIndex = 37
      OnExecute = actReActivateExecute
      OnUpdate = actReActivateUpdate
    end
    object actValidPos: TAction
      Category = 'Detail'
      Caption = 'Проверка целостности настройки'
      Hint = 'Проверка целостности настройки'
      ImageIndex = 30
      ShortCut = 49232
      OnExecute = actValidPosExecute
      OnUpdate = actValidPosUpdate
    end
    object actValidStorage: TAction
      Category = 'Storage'
      Caption = 'Проверка целостности настройки хранилища'
      Hint = 'Проверка целостности настройки хранилища'
      ImageIndex = 30
      ShortCut = 49235
      OnExecute = actValidStorageExecute
      OnUpdate = actValidStorageUpdate
    end
    object actChooseSetings: TAction
      Category = 'Main'
      Caption = 'Выбрать промежуточные'
      Hint = 'Выбрать настройки, от которых зависит данная настройка'
      ImageIndex = 216
      OnExecute = actChooseSetingsExecute
      OnUpdate = actChooseSetingsUpdate
    end
    object actNeedModify: TAction
      Category = 'Detail'
      Caption = 'Необходимо модифицировать'
      Hint = 'Найденые данные модифицировать данными из потока'
      ImageIndex = 107
      OnExecute = actNeedModifyExecute
      OnUpdate = actNeedModifyUpdate
    end
    object actNeedModifyDefault: TAction
      Category = 'Detail'
      Caption = 'Установить флаг "Обновлять данные из потока" по умолчанию'
      Hint = 'Установить флаг "Обновлять данные из потока" по умолчанию'
      ImageIndex = 108
      OnExecute = actNeedModifyDefaultExecute
      OnUpdate = actNeedModifyDefaultUpdate
    end
    object actSettingView: TAction
      Category = 'Main'
      Caption = 'Просмотр настройки'
      Hint = 'Просмотр настройки'
      ImageIndex = 204
      OnExecute = actSettingViewExecute
      OnUpdate = actSettingViewUpdate
    end
    object actOpenObject: TAction
      Caption = 'Открыть объект'
      Hint = 'Открыть объект'
      ImageIndex = 131
      OnExecute = actOpenObjectExecute
      OnUpdate = actOpenObjectUpdate
    end
    object actClearDependencies: TAction
      Category = 'Main'
      Caption = 'Очистить зависимости'
      Hint = 'Очистить зависимости'
      ImageIndex = 217
      OnExecute = actClearDependenciesExecute
      OnUpdate = actClearDependenciesUpdate
    end
    object actAddMissed: TAction
      Category = 'Main'
      Caption = 'Добавить пропущенные позиции'
      Hint = 'Добавить пропущенные позиции'
      ImageIndex = 180
      OnExecute = actAddMissedExecute
      OnUpdate = actAddMissedUpdate
    end
    object actSet2Txt: TAction
      Category = 'Main'
      Caption = 'Выгрузить в текстовый файл...'
      Hint = 'Выгрузить в текстовый файл...'
      ImageIndex = 251
      OnExecute = actSet2TxtExecute
      OnUpdate = actSet2TxtUpdate
    end
  end
  inherited dsMain: TDataSource
    DataSet = gdcSetting
  end
  inherited dsDetail: TDataSource
    DataSet = gdcSettingPos
  end
  object gdcSetting: TgdcSetting
    Left = 129
    Top = 169
  end
  object gdcSettingPos: TgdcSettingPos
    MasterSource = dsMain
    MasterField = 'id'
    DetailField = 'settingkey'
    SubSet = 'BySetting'
    Left = 345
    Top = 276
  end
  object gdcSettingStorage: TgdcSettingStorage
    MasterSource = dsMain
    MasterField = 'id'
    DetailField = 'settingkey'
    SubSet = 'BySetting'
    Left = 473
    Top = 260
  end
  object dsStorage: TDataSource
    DataSet = gdcSettingStorage
    Left = 551
    Top = 276
  end
  object pmStorage: TPopupMenu
    Left = 519
    Top = 276
  end
end
