object frmGedeminMain: TfrmGedeminMain
  Left = 389
  Top = 83
  Width = 977
  Height = 85
  HelpContext = 76
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  Caption = 'Gedemin'
  Color = clBtnFace
  Constraints.MaxHeight = 85
  Constraints.MaxWidth = 2000
  Constraints.MinHeight = 80
  Constraints.MinWidth = 400
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  OnActivate = FormActivate
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object TBDockMain: TTBDock
    Left = 0
    Top = 0
    Width = 961
    Height = 26
    LimitToOneRow = True
    object tbMainMenu: TTBToolbar
      Left = 0
      Top = 0
      BorderStyle = bsNone
      Caption = 'tbMainMenu'
      CloseButton = False
      DockMode = dmCannotFloatOrChangeDocks
      DockPos = 0
      DragHandleStyle = dhNone
      FullSize = True
      Images = dmImages.il16x16
      MenuBar = True
      ParentShowHint = False
      ProcessShortCuts = True
      ShowHint = True
      Stretch = True
      TabOrder = 0
      object tbsiDatabase: TTBSubmenuItem
        Caption = 'База данных'
        object N14: TTBItem
          Action = actShowUsers
        end
        object TBSeparatorItem15: TTBSeparatorItem
        end
        object tbiDatabasesList: TTBItem
          Action = actDatabasesList
          ImageIndex = 107
        end
        object MenuItem1: TTBItem
          Action = actLogIn
        end
        object N15: TTBItem
          Action = actLogOff
        end
        object TBItem27: TTBItem
          Action = actReconnect
        end
        object N23: TTBSeparatorItem
        end
        object N18: TTBItem
          Action = actLoginSingle
        end
        object N19: TTBItem
          Action = actBringOnline
        end
        object N20: TTBSeparatorItem
        end
        object actBackup1: TTBItem
          Action = actBackup
        end
        object N22: TTBItem
          Action = actRestore
        end
        object TBSeparatorItem9: TTBSeparatorItem
        end
        object tbiSqueeze: TTBItem
          Action = actDBSqueeze
        end
        object tbiRecompile: TTBItem
          Action = actRecompileStatistics
        end
        object TBSeparatorItem8888: TTBSeparatorItem
        end
        object TBItem10: TTBItem
          Action = actExit
        end
      end
      object tbsiMacro: TTBSubmenuItem
        Caption = 'Сервис'
        object Property1: TTBItem
          Action = actProperty
        end
        object TBItem2: TTBItem
          Action = actEditForm
        end
        object TBItem21: TTBItem
          Action = actSQLEditor
        end
        object TBItem1: TTBItem
          Action = actSQLMonitor
        end
        object TBSeparatorItem14: TTBSeparatorItem
        end
        object tbsiAdministrator: TTBSubmenuItem
          Caption = 'Администратор'
          ImageIndex = 155
          object TBItem26: TTBItem
            Action = actUserGroups
          end
          object TBItem25: TTBItem
            Action = actJournal
          end
          object TBItem24: TTBItem
            Action = actUsers
          end
        end
        object tbsiAttributes: TTBSubmenuItem
          Caption = 'Атрибуты'
          ImageIndex = 175
          object tbiGenerators: TTBItem
            Action = actGenerators
          end
          object tbiDomains: TTBItem
            Action = actDomains
          end
          object tbiExceptions: TTBItem
            Action = actExceptions
          end
          object tbiViews: TTBItem
            Action = actViews
          end
          object tbiProcedures: TTBItem
            Action = actProcedures
          end
          object tbiTables: TTBItem
            Action = actTables
          end
        end
        object tbiDocumentType: TTBItem
          Action = actDocumentType
        end
        object tbiStorage: TTBItem
          Action = actStorage
        end
        object N24: TTBSeparatorItem
          Visible = False
        end
        object TBItem3: TTBItem
          Caption = 'Регистрационый номер'
          OnClick = TBItem3Click
        end
        object TBItem4: TTBItem
          Caption = 'Лицензия'
          OnClick = TBItem4Click
        end
        object TBSeparatorItem2: TTBSeparatorItem
        end
        object TBItem9: TTBItem
          Action = actShowSQLObjects
        end
        object TBSeparatorItem12: TTBSeparatorItem
        end
        object tbiSettings: TTBItem
          Action = actSettings
        end
        object TBItem22: TTBItem
          Action = actLoadPackage
          Caption = 'Установить пакеты настроек...'
        end
        object TBSeparatorItem13: TTBSeparatorItem
        end
        object TBItem23: TTBItem
          Action = actShowMonitoring
        end
        object TBItem17: TTBItem
          Action = actCompareDataBases
        end
        object TBItem20: TTBItem
          Action = actShell
        end
        object tbiScanTemplate: TTBItem
          Action = actScanTemplate
        end
        object TBSeparatorItem6: TTBSeparatorItem
        end
        object tbiStreamSaverOptions: TTBItem
          Action = actStreamSaverOptions
        end
        object tbiOptions: TTBItem
          Action = actOptions
        end
      end
      object tbsiWindow: TTBSubmenuItem
        Caption = 'Окна'
        object TBItem6: TTBItem
          Action = actExplorer
        end
        object tbiSQLProcessWindow: TTBItem
          Action = actSQLProcess
        end
        object TBSeparatorItem1: TTBSeparatorItem
        end
        object N25: TTBItem
          Action = actActiveFormList
        end
        object N26: TTBItem
          Action = actClear
        end
        object TBSeparatorItem3: TTBSeparatorItem
        end
        object TBItem7: TTBItem
          Action = actSaveDesktop
        end
        object TBItem8: TTBItem
          Action = actDeleteDesktop
        end
      end
      object tbsiHelp: TTBSubmenuItem
        Caption = 'Справка'
        object TBItem18: TTBItem
          Caption = 'Начинаем работать'
          ImageIndex = 13
          Visible = False
          OnClick = TBItem18Click
        end
        object TBItem12: TTBItem
          Caption = 'Руководство пользователя'
          ImageIndex = 13
          OnClick = TBItem12Click
        end
        object TBItem11: TTBItem
          Caption = 'Руководство разработчика'
          ImageIndex = 13
          Visible = False
          OnClick = TBItem11Click
        end
        object TBItem19: TTBItem
          Caption = 'Руководство программиста'
          ImageIndex = 13
          Visible = False
          OnClick = TBItem19Click
        end
        object TBSeparatorItem10: TTBSeparatorItem
        end
        object TBItem13: TTBItem
          Caption = 'Справка по VBScript'
          ImageIndex = 13
          OnClick = TBItem13Click
        end
        object TBItem16: TTBItem
          Caption = 'Руководство по FastReport'
          ImageIndex = 13
          OnClick = TBItem16Click
        end
        object TBSeparatorItem11: TTBSeparatorItem
        end
        object TBItem5: TTBItem
          Caption = 'www.gsbelarus.com'
          ImageIndex = 119
          OnClick = TBItem5Click
        end
        object TBSeparatorItem5: TTBSeparatorItem
        end
        object tbiRegistration: TTBItem
          Action = actRegistration
        end
        object N2: TTBItem
          Action = actAbout
        end
      end
      object TBSeparatorItem7: TTBSeparatorItem
      end
      object TBControlItem3: TTBControlItem
        Control = Label1
      end
      object TBControlItem1: TTBControlItem
        Control = cbDesktop
      end
      object TBItem14: TTBItem
        Action = actSaveDesktop
      end
      object TBItem15: TTBItem
        Action = actDeleteDesktop
      end
      object tbiCloseAll: TTBItem
        Action = actCloseAll
        Hint = 'Закрыть все окна'
      end
      object TBSeparatorItem4: TTBSeparatorItem
      end
      object TBControlItem5: TTBControlItem
        Control = Label2
      end
      object TBControlItem4: TTBControlItem
        Control = gsiblkupCompany
      end
      object tbiWorkingCompaniesBtn: TTBItem
        Action = actWorkingCompanies
      end
      object TBSeparatorItem8: TTBSeparatorItem
      end
      object TBControlItem6: TTBControlItem
        Control = lblDatabase
      end
      object Label1: TLabel
        Left = 235
        Top = 4
        Width = 32
        Height = 13
        Caption = 'Стол: '
      end
      object Label2: TLabel
        Left = 487
        Top = 4
        Width = 73
        Height = 13
        Caption = 'Организация: '
      end
      object lblDatabase: TLabel
        Left = 734
        Top = 4
        Width = 3
        Height = 13
        Alignment = taRightJustify
        PopupMenu = pmlblDataBase
        OnDblClick = actCopyExecute
      end
      object cbDesktop: TComboBox
        Left = 267
        Top = 0
        Width = 145
        Height = 21
        Style = csDropDownList
        Anchors = []
        DropDownCount = 16
        ItemHeight = 13
        Sorted = True
        TabOrder = 0
        OnChange = cbDesktopChange
      end
      object gsiblkupCompany: TgsIBLookupComboBox
        Left = 560
        Top = 0
        Width = 145
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = IBTransaction
        ListTable = 'gd_ourcompany z JOIN gd_contact c ON c.id = z.companykey'
        ListField = 'c.name'
        KeyField = 'companykey'
        SortOrder = soAsc
        gdClassName = 'TgdcOurCompany'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnChange = gsiblkupCompanyChange
      end
    end
  end
  object TBDockForms: TTBDock
    Left = 0
    Top = 26
    Width = 961
    Height = 27
    BoundLines = [blTop]
    Color = clWindow
    LimitToOneRow = True
    Position = dpBottom
    object tbForms: TTBToolbar
      Left = 0
      Top = 0
      BorderStyle = bsNone
      Caption = 'Формы'
      ChevronHint = 'Показать все'
      CloseButton = False
      Color = clBtnHighlight
      DockMode = dmCannotFloatOrChangeDocks
      DockPos = 0
      DragHandleStyle = dhNone
      FullSize = True
      Images = dmImages.il16x16
      ParentShowHint = False
      PopupMenu = pmForms
      ShowHint = True
      Stretch = True
      SystemFont = False
      TabOrder = 0
    end
  end
  object ActionList: TActionList
    Images = dmImages.il16x16
    Left = 606
    Top = 30
    object actAbout: TAction
      Category = 'Справка'
      Caption = 'О системе...'
      ImageIndex = 150
      OnExecute = actAboutExecute
    end
    object actExit: TAction
      Category = 'File'
      Caption = 'Выход'
      ImageIndex = 125
      OnExecute = actExitExecute
      OnUpdate = actExitUpdate
    end
    object actExplorer: TAction
      Category = 'Просмотр'
      Caption = 'Исследователь'
      ImageIndex = 219
      ShortCut = 16506
      OnExecute = actExplorerExecute
      OnUpdate = actExplorerUpdate
    end
    object actSaveDesktop: TAction
      Category = 'Просмотр'
      Caption = 'Сохранить стол...'
      Hint = 'Сохранить стол'
      ImageIndex = 38
      OnExecute = actSaveDesktopExecute
      OnUpdate = actSaveDesktopUpdate
    end
    object actDeleteDesktop: TAction
      Category = 'Просмотр'
      Caption = 'Удалить стол'
      Hint = 'Удалить стол'
      ImageIndex = 39
      OnExecute = actDeleteDesktopExecute
      OnUpdate = actDeleteDesktopUpdate
    end
    object actShow: TAction
      Category = 'Tray'
      Caption = 'Открыть'
      ImageIndex = 0
      OnExecute = actShowExecute
      OnUpdate = actShowUpdate
    end
    object actActiveFormList: TAction
      Category = 'Actions'
      Caption = 'Список активных окон...'
      ImageIndex = 226
      OnExecute = actActiveFormListExecute
      OnUpdate = actActiveFormListUpdate
    end
    object actClear: TAction
      Category = 'Actions'
      Caption = 'Очистить память'
      OnExecute = actClearExecute
      OnUpdate = actClearUpdate
    end
    object actLogIn: TAction
      Category = 'Actions'
      Caption = 'Подключиться...'
      ImageIndex = 111
      OnExecute = actLogInExecute
      OnUpdate = actLogInUpdate
    end
    object actLogOff: TAction
      Category = 'Actions'
      Caption = 'Отключиться'
      ImageIndex = 102
      OnExecute = actLogOffExecute
      OnUpdate = actLogOffUpdate
    end
    object actLoginSingle: TAction
      Category = 'Actions'
      Caption = 'Монопольный режим'
      OnExecute = actLoginSingleExecute
      OnUpdate = actLoginSingleUpdate
    end
    object actBringOnline: TAction
      Category = 'Actions'
      Caption = 'Многопользовательский режим'
      OnExecute = actBringOnlineExecute
      OnUpdate = actBringOnlineUpdate
    end
    object actBackup: TAction
      Category = 'Actions'
      Caption = 'Архивное копирование...'
      ImageIndex = 109
      OnExecute = actBackupExecute
      OnUpdate = actBackupUpdate
    end
    object actRestore: TAction
      Category = 'Actions'
      Caption = 'Восстановление из архива...'
      ImageIndex = 106
      OnExecute = actRestoreExecute
      OnUpdate = actRestoreUpdate
    end
    object actEditForm: TAction
      Category = 'Actions'
      Caption = 'Редактор форм...'
      ImageIndex = 115
      OnExecute = actEditFormExecute
      OnUpdate = actEditFormUpdate
    end
    object actShowUsers: TAction
      Category = 'Actions'
      Caption = 'Подключенные пользователи...'
      ImageIndex = 35
      OnExecute = actShowUsersExecute
      OnUpdate = actShowUsersUpdate
    end
    object actShowSQLObjects: TAction
      Category = 'Actions'
      Caption = 'actShowSQLObjects'
      OnExecute = actShowSQLObjectsExecute
      OnUpdate = actShowSQLObjectsUpdate
    end
    object actProperty: TAction
      Category = 'Справка'
      Caption = 'Редактор скрипт-объектов...'
      ImageIndex = 21
      OnExecute = actPropertyExecute
      OnUpdate = actPropertyUpdate
    end
    object actOptions: TAction
      Caption = 'Параметры...'
      ImageIndex = 28
      OnExecute = actOptionsExecute
      OnUpdate = actOptionsUpdate
    end
    object actScanTemplate: TAction
      Category = 'Просмотр'
      Caption = 'Просмотр шаблона документов...'
      OnExecute = actScanTemplateExecute
      OnUpdate = actScanTemplateUpdate
    end
    object actSQLEditor: TAction
      Caption = 'SQL редактор...'
      ImageIndex = 72
      OnExecute = actSQLEditorExecute
      OnUpdate = actSQLEditorUpdate
    end
    object actCloseForm: TAction
      Category = 'Forms'
      Caption = 'Закрыть форму'
      Hint = 'Закрыть форму'
      OnExecute = actCloseFormExecute
      OnUpdate = actCloseFormUpdate
    end
    object actCloseAll: TAction
      Category = 'Forms'
      Caption = 'Закрыть все'
      Hint = 'Закрыть все'
      ImageIndex = 42
      OnExecute = actCloseAllExecute
      OnUpdate = actCloseAllUpdate
    end
    object actHideForm: TAction
      Category = 'Forms'
      Caption = 'Свернуть форму'
      Hint = 'Свернуть форму'
      OnExecute = actHideFormExecute
      OnUpdate = actHideFormUpdate
    end
    object actHideAll: TAction
      Category = 'Forms'
      Caption = 'Свернуть все'
      Hint = 'Свернуть все'
      OnExecute = actHideAllExecute
      OnUpdate = actHideAllUpdate
    end
    object actWorkingCompanies: TAction
      Caption = 'Рабочие организации...'
      Hint = 'Рабочие организации'
      ImageIndex = 134
      OnExecute = actWorkingCompaniesExecute
      OnUpdate = actWorkingCompaniesUpdate
    end
    object actHelp: TAction
      Caption = 'Справка'
      ImageIndex = 12
      ShortCut = 112
      OnExecute = actHelpExecute
    end
    object actLoadPackage: TAction
      Category = 'Actions'
      Caption = 'Установить настройки...'
      Hint = 'Установить пакеты настроек...'
      ImageIndex = 80
      OnExecute = actLoadPackageExecute
      OnUpdate = actLoadPackageUpdate
    end
    object actRegistration: TAction
      Category = 'Справка'
      Caption = 'Регистрация...'
      ImageIndex = 214
      OnExecute = actRegistrationExecute
      OnUpdate = actRegistrationUpdate
    end
    object actRecompileStatistics: TAction
      Category = 'Actions'
      Caption = 'Обновление статистики индексов...'
      ImageIndex = 144
      OnExecute = actRecompileStatisticsExecute
      OnUpdate = actRecompileStatisticsUpdate
    end
    object actSQLMonitor: TAction
      Category = 'Actions'
      Caption = 'SQL Монитор'
      OnExecute = actSQLMonitorExecute
      OnUpdate = actSQLMonitorUpdate
    end
    object actCopy: TAction
      Caption = 'Копировать'
      ImageIndex = 10
      OnExecute = actCopyExecute
      OnUpdate = actCopyUpdate
    end
    object actCompareDataBases: TAction
      Category = 'Actions'
      Caption = 'Сравнить базы данных...'
      Hint = 'Сравнить базы данных'
      ImageIndex = 121
      OnExecute = actCompareDataBasesExecute
      OnUpdate = actCompareDataBasesUpdate
    end
    object actShell: TAction
      Caption = 'Использовать как оболочку...'
      ImageIndex = 85
      OnExecute = actShellExecute
      OnUpdate = actShellUpdate
    end
    object actSettings: TAction
      Category = 'Service'
      Caption = 'Настройки'
      ImageIndex = 7
      OnExecute = actSettingsExecute
      OnUpdate = actSettingsUpdate
    end
    object actGenerators: TAction
      Category = 'Service'
      Caption = 'Генераторы'
      ImageIndex = 236
      OnExecute = actGeneratorsExecute
      OnUpdate = actGeneratorsUpdate
    end
    object actDomains: TAction
      Category = 'Service'
      Caption = 'Домены'
      ImageIndex = 250
      OnExecute = actDomainsExecute
      OnUpdate = actDomainsUpdate
    end
    object actExceptions: TAction
      Category = 'Service'
      Caption = 'Исключения'
      ImageIndex = 254
      OnExecute = actExceptionsExecute
      OnUpdate = actExceptionsUpdate
    end
    object actViews: TAction
      Category = 'Service'
      Caption = 'Представления'
      ImageIndex = 252
      OnExecute = actViewsExecute
      OnUpdate = actViewsUpdate
    end
    object actProcedures: TAction
      Category = 'Service'
      Caption = 'Процедуры'
      ImageIndex = 253
      OnExecute = actProceduresExecute
      OnUpdate = actProceduresUpdate
    end
    object actTables: TAction
      Category = 'Service'
      Caption = 'Таблицы'
      ImageIndex = 251
      OnExecute = actTablesExecute
      OnUpdate = actTablesUpdate
    end
    object actDocumentType: TAction
      Category = 'Service'
      Caption = 'Типовые документы'
      ImageIndex = 0
      OnExecute = actDocumentTypeExecute
      OnUpdate = actDocumentTypeUpdate
    end
    object actStorage: TAction
      Category = 'Service'
      Caption = 'Хранилище'
      ImageIndex = 255
      OnExecute = actStorageExecute
      OnUpdate = actStorageUpdate
    end
    object actStreamSaverOptions: TAction
      Category = 'Service'
      Caption = 'Параметры переноса данных...'
      ImageIndex = 228
      OnExecute = actStreamSaverOptionsExecute
      OnUpdate = actStreamSaverOptionsUpdate
    end
    object actShowMonitoring: TAction
      Category = 'Actions'
      Caption = 'Монитор подлючений'
      Hint = 'Монитор подлючений'
      ImageIndex = 120
      OnExecute = actShowMonitoringExecute
      OnUpdate = actShowMonitoringUpdate
    end
    object actSQLProcess: TAction
      Category = 'Actions'
      Caption = 'Журнал SQL команд...'
      ImageIndex = 211
      OnExecute = actSQLProcessExecute
    end
    object actUserGroups: TAction
      Category = 'Admin'
      Caption = 'Группы пользователей'
      ImageIndex = 35
      OnExecute = actUserGroupsExecute
      OnUpdate = actUserGroupsUpdate
    end
    object actJournal: TAction
      Category = 'Admin'
      Caption = 'Журнал событий'
      ImageIndex = 256
      OnExecute = actJournalExecute
      OnUpdate = actJournalUpdate
    end
    object actUsers: TAction
      Category = 'Admin'
      Caption = 'Пользователи'
      ImageIndex = 34
      OnExecute = actUsersExecute
      OnUpdate = actUsersUpdate
    end
    object actReconnect: TAction
      Category = 'Actions'
      Caption = 'Переподключиться'
      ImageIndex = 108
      OnExecute = actReconnectExecute
      OnUpdate = actReconnectUpdate
    end
    object actDBSqueeze: TAction
      Category = 'Service'
      Caption = 'Сжатие базы данных...'
      OnExecute = actDBSqueezeExecute
      OnUpdate = actDBSqueezeUpdate
    end
    object actDatabasesList: TAction
      Category = 'Actions'
      Caption = 'Список баз данных...'
      ImageIndex = 105
      OnExecute = actDatabasesListExecute
      OnUpdate = actDatabasesListUpdate
    end
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 648
    Top = 26
  end
  object pmForms: TPopupMenu
    Images = dmImages.il16x16
    Left = 344
    Top = 24
    object N1: TMenuItem
      Action = actHideForm
    end
    object N3: TMenuItem
      Action = actHideAll
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object actCloseForm1: TMenuItem
      Action = actCloseForm
    end
    object N4: TMenuItem
      Action = actCloseAll
    end
  end
  object pmlblDataBase: TPopupMenu
    Images = dmImages.il16x16
    Left = 424
    Top = 24
    object N6: TMenuItem
      Action = actCopy
    end
  end
end
