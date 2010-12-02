object DataBaseCompare: TDataBaseCompare
  Left = 495
  Top = 100
  Width = 723
  Height = 583
  Caption = 'Сравнение баз данных'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object spcMain: TSuperPageControl
    Left = 0
    Top = 0
    Width = 707
    Height = 545
    BorderStyle = bsNone
    TabsVisible = True
    ActivePage = stbsResult
    Align = alClient
    TabHeight = 23
    TabOrder = 0
    TabStop = False
    object stbsConnection: TSuperTabSheet
      Caption = 'Настройка'
      object gbExternalConnection: TGroupBox
        Left = 7
        Top = 3
        Width = 400
        Height = 98
        Caption = ' Параметры соединения '
        TabOrder = 0
        object lbExtUserName: TLabel
          Left = 8
          Top = 49
          Width = 76
          Height = 13
          Caption = 'Пользователь:'
        end
        object lbExtPassword: TLabel
          Left = 8
          Top = 73
          Width = 41
          Height = 13
          Caption = 'Пароль:'
        end
        object lbExServer: TLabel
          Left = 192
          Top = 49
          Width = 40
          Height = 13
          Caption = 'Сервер:'
        end
        object edExtDatabaseName: TEdit
          Left = 8
          Top = 21
          Width = 362
          Height = 21
          TabOrder = 0
        end
        object btnExtOpen: TButton
          Left = 370
          Top = 21
          Width = 20
          Height = 20
          Action = actExtOpen
          TabOrder = 1
        end
        object edExtUserName: TEdit
          Left = 88
          Top = 45
          Width = 89
          Height = 21
          TabOrder = 2
          Text = 'SYSDBA'
        end
        object edExtPassword: TEdit
          Left = 88
          Top = 69
          Width = 89
          Height = 21
          PasswordChar = '*'
          TabOrder = 3
          Text = 'masterkey'
        end
        object edExtServerName: TEdit
          Left = 240
          Top = 45
          Width = 131
          Height = 21
          TabOrder = 4
        end
      end
      object gbSearchOptions: TGroupBox
        Left = 7
        Top = 103
        Width = 400
        Height = 108
        Caption = ' Объекты для сравнения '
        TabOrder = 1
        object cbVBClass: TCheckBox
          Left = 8
          Top = 17
          Width = 97
          Height = 17
          Caption = 'VB классы'
          Checked = True
          State = cbChecked
          TabOrder = 0
        end
        object cbGO: TCheckBox
          Left = 8
          Top = 33
          Width = 153
          Height = 18
          Caption = 'Глобальные VB-объекты'
          Checked = True
          State = cbChecked
          TabOrder = 1
        end
        object cbConst: TCheckBox
          Left = 8
          Top = 50
          Width = 145
          Height = 17
          Caption = 'Константы'
          Checked = True
          State = cbChecked
          TabOrder = 2
        end
        object cbMacros: TCheckBox
          Left = 8
          Top = 66
          Width = 97
          Height = 17
          Caption = 'Макросы'
          Checked = True
          State = cbChecked
          TabOrder = 3
        end
        object cbSF: TCheckBox
          Left = 8
          Top = 83
          Width = 123
          Height = 17
          Caption = 'Скрипт-функции'
          Checked = True
          State = cbChecked
          TabOrder = 4
        end
        object cbReport: TCheckBox
          Left = 170
          Top = 17
          Width = 97
          Height = 17
          Caption = 'Отчеты'
          Checked = True
          State = cbChecked
          TabOrder = 5
        end
        object cbMethod: TCheckBox
          Left = 170
          Top = 33
          Width = 97
          Height = 17
          Caption = 'Методы'
          Checked = True
          State = cbChecked
          TabOrder = 6
        end
        object cbEvents: TCheckBox
          Left = 170
          Top = 50
          Width = 97
          Height = 17
          Caption = 'События'
          Checked = True
          State = cbChecked
          TabOrder = 7
        end
        object cbEntry: TCheckBox
          Left = 170
          Top = 66
          Width = 97
          Height = 17
          Caption = 'Проводки'
          Checked = True
          State = cbChecked
          TabOrder = 8
        end
        object cbTrigger: TCheckBox
          Left = 260
          Top = 17
          Width = 97
          Height = 17
          Caption = 'Триггеры'
          Checked = True
          State = cbChecked
          TabOrder = 9
        end
        object cbView: TCheckBox
          Left = 260
          Top = 33
          Width = 97
          Height = 17
          Caption = 'Представления'
          Checked = True
          State = cbChecked
          TabOrder = 10
        end
        object cbSP: TCheckBox
          Left = 260
          Top = 50
          Width = 137
          Height = 17
          Caption = 'Хранимые процедуры'
          Checked = True
          State = cbChecked
          TabOrder = 11
        end
        object cbTable: TCheckBox
          Left = 260
          Top = 67
          Width = 97
          Height = 17
          Caption = 'Таблицы'
          Checked = True
          State = cbChecked
          TabOrder = 12
        end
      end
      object btnCompareDB: TButton
        Left = 416
        Top = 22
        Width = 75
        Height = 25
        Action = actCompareDB
        TabOrder = 2
      end
      object btnCompareSetting: TButton
        Left = 417
        Top = 54
        Width = 137
        Height = 25
        Action = actCompareSetting
        TabOrder = 3
      end
    end
    object stbsResult: TSuperTabSheet
      Caption = 'Результат'
      object pnBottom: TPanel
        Left = 0
        Top = 26
        Width = 707
        Height = 496
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object sbDBCompare: TStatusBar
          Left = 0
          Top = 477
          Width = 707
          Height = 19
          Panels = <
            item
              Width = 540
            end
            item
              Alignment = taRightJustify
              BiDiMode = bdLeftToRight
              ParentBiDiMode = False
              Width = 50
            end>
          SimplePanel = False
        end
        object spcResult: TSuperPageControl
          Left = 0
          Top = 0
          Width = 707
          Height = 477
          BorderStyle = bsNone
          TabsVisible = True
          ActivePage = stbsScripts
          Align = alClient
          TabHeight = 23
          TabOrder = 1
          TabStop = False
          object stbsScripts: TSuperTabSheet
            Caption = 'Скрипты и макросы'
            object lvMacros: TgsListView
              Left = 0
              Top = 0
              Width = 707
              Height = 454
              Align = alClient
              Columns = <
                item
                  AutoSize = True
                  Caption = 'Наименование'
                end
                item
                  Caption = 'Дата изменения'
                  Width = 115
                end
                item
                  Alignment = taCenter
                  AutoSize = True
                  Caption = 'Статус'
                  MaxWidth = 48
                  MinWidth = 48
                end
                item
                  AutoSize = True
                  Caption = 'Наименование'
                end
                item
                  Caption = 'Дата изменения'
                  Width = 115
                end>
              GridLines = True
              ReadOnly = True
              RowSelect = True
              SmallImages = dmImages.il16x16
              TabOrder = 0
              ViewStyle = vsReport
              OnDblClick = actMacrosDblClickExecute
            end
          end
          object stbsMetadata: TSuperTabSheet
            Caption = 'Метаданные'
            object lvMetaData: TgsListView
              Left = 0
              Top = 0
              Width = 707
              Height = 454
              Align = alClient
              Columns = <
                item
                  AutoSize = True
                  Caption = 'Наименование'
                end
                item
                  Caption = 'Дата изменения'
                  Width = 115
                end
                item
                  AutoSize = True
                  Caption = 'Статус'
                  MaxWidth = 48
                  MinWidth = 48
                end
                item
                  AutoSize = True
                  Caption = 'Наименование'
                end
                item
                  Caption = 'Дата изменения'
                  Width = 115
                end>
              GridLines = True
              ReadOnly = True
              RowSelect = True
              PopupMenu = pmMain
              SmallImages = dmImages.il16x16
              TabOrder = 0
              ViewStyle = vsReport
              OnDblClick = lvMetaDataDblClick
            end
          end
        end
      end
      object tbdResult: TTBDock
        Left = 0
        Top = 0
        Width = 707
        Height = 26
        object tbtResult: TTBToolbar
          Left = 0
          Top = 0
          BorderStyle = bsNone
          Caption = 'tbtResult'
          FullSize = True
          Images = dmImages.il16x16
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          object tbOnlyFirstDBItems: TTBItem
            Caption = 'Скрипты, которые есть только в текущей БД'
            Hint = 'Скрипты, которые есть только в текущей БД'
            ImageIndex = 156
            OnClick = acRefreshExecute
          end
          object tbEquivItems: TTBItem
            Caption = 'Одинаковые скрипты'
            Hint = 'Одинаковые скрипты'
            ImageIndex = 214
            OnClick = acRefreshExecute
          end
          object tbDiffItems: TTBItem
            Caption = 'Скрипты с отличиями'
            Hint = 'Скрипты с отличиями'
            ImageIndex = 121
            OnClick = acRefreshExecute
          end
          object tbOnlyExtDBItems: TTBItem
            Caption = 'Скрипты, которые есть только в сравнимаемой БД'
            Hint = 'Скрипты, которые есть только в сравнимаемой БД'
            ImageIndex = 157
            OnClick = acRefreshExecute
          end
        end
      end
    end
  end
  object odExternalDB: TOpenDialog
    Filter = 'Interbase database|*.gdb;*.fdb|All|*.*'
    Left = 496
    Top = 248
  end
  object ibExtDataBase: TIBDatabase
    AllowStreamedConnected = False
    Left = 528
    Top = 248
  end
  object alCompareDB: TActionList
    Images = dmImages.il16x16
    Left = 559
    Top = 248
    object actCompareDB: TAction
      Caption = 'Сравнить'
      Hint = 'Сравнить'
      OnExecute = actCompareDBExecute
      OnUpdate = actCompareDBUpdate
    end
    object acRefresh: TAction
      Caption = 'acRefresh'
      OnExecute = acRefreshExecute
    end
    object actMacrosDblClick: TAction
      Caption = 'actMacrosDblClick'
      OnExecute = actMacrosDblClickExecute
    end
    object actAddPos: TAction
      Caption = 'Добавить в настройку ...'
      Hint = 'Добавить в настройку'
      ImageIndex = 81
      OnExecute = actAddPosExecute
      OnUpdate = actAddPosUpdate
    end
    object actCompareSetting: TAction
      Caption = 'Сравнить с настройкой'
      Hint = 'Сравнить с настройкой'
      OnExecute = actCompareSettingExecute
    end
    object actExtOpen: TAction
      Caption = '...'
      Hint = 'Путь к сравниваемой БД'
      OnExecute = actExtOpenExecute
    end
  end
  object DSMacros: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 464
    Top = 248
  end
  object DSMetaData: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 464
    Top = 280
  end
  object pmMain: TPopupMenu
    Images = dmImages.il16x16
    Left = 376
    Top = 250
    object N1: TMenuItem
      Action = actAddPos
    end
  end
end
