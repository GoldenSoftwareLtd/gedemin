object DataBaseCompare: TDataBaseCompare
  Left = 608
  Top = 258
  Width = 926
  Height = 583
  Caption = 'Сравнение баз данных'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object pnMain: TPanel
    Left = 0
    Top = 0
    Width = 910
    Height = 545
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object pnTop: TPanel
      Left = 0
      Top = 0
      Width = 910
      Height = 120
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object gbViewItems: TGroupBox
        Left = 791
        Top = 6
        Width = 106
        Height = 45
        Caption = ' Фильтр '
        TabOrder = 0
        object pnViewItems: TPanel
          Left = 2
          Top = 15
          Width = 102
          Height = 28
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 0
          object TBToolbar1: TTBToolbar
            Left = 5
            Top = 0
            Width = 92
            Height = 22
            Caption = 'TBToolbar1'
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
      object gbSearchOptions: TGroupBox
        Left = 379
        Top = 6
        Width = 404
        Height = 108
        Caption = ' Сравнивать объекты  '
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
      object pc: TPageControl
        Left = 8
        Top = 8
        Width = 361
        Height = 105
        ActivePage = tsDB
        TabOrder = 2
        object tsDB: TTabSheet
          Caption = 'База данных'
          object lbExtUserName: TLabel
            Left = 5
            Top = 32
            Width = 76
            Height = 13
            Caption = 'Пользователь:'
          end
          object lbExtPassword: TLabel
            Left = 214
            Top = 32
            Width = 41
            Height = 13
            Caption = 'Пароль:'
          end
          object Label1: TLabel
            Left = 97
            Top = 6
            Width = 4
            Height = 13
            Caption = ':'
          end
          object btnCompareDB: TButton
            Left = 274
            Top = 53
            Width = 75
            Height = 21
            Action = actCompareDB
            TabOrder = 5
          end
          object edExtDatabaseName: TEdit
            Left = 104
            Top = 3
            Width = 227
            Height = 21
            TabOrder = 1
            Text = '<файл БД>'
          end
          object btnExtOpen: TButton
            Left = 330
            Top = 3
            Width = 20
            Height = 20
            Caption = '...'
            TabOrder = 2
            OnClick = btnExtOpenClick
          end
          object edExtUserName: TEdit
            Left = 84
            Top = 28
            Width = 89
            Height = 21
            TabOrder = 3
            Text = 'SYSDBA'
          end
          object edExtServerName: TEdit
            Left = 4
            Top = 3
            Width = 90
            Height = 21
            TabOrder = 0
            Text = '<сервер>'
          end
          object edExtPassword: TEdit
            Left = 261
            Top = 28
            Width = 89
            Height = 21
            PasswordChar = '*'
            TabOrder = 4
            Text = 'masterkey'
          end
        end
        object tsSetting: TTabSheet
          Caption = 'Файл настройки'
          ImageIndex = 1
          object btnCompareSetting: TButton
            Left = 5
            Top = 5
            Width = 75
            Height = 21
            Caption = 'Сравнить...'
            TabOrder = 0
            OnClick = btnCompareSettingClick
          end
        end
      end
    end
    object pnBottom: TPanel
      Left = 0
      Top = 120
      Width = 910
      Height = 425
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object sbDBCompare: TStatusBar
        Left = 0
        Top = 406
        Width = 910
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
      object SuperPageControl1: TSuperPageControl
        Left = 0
        Top = 0
        Width = 910
        Height = 406
        BorderStyle = bsNone
        TabsVisible = True
        ActivePage = SuperTabSheet1
        Align = alClient
        TabHeight = 23
        TabOrder = 1
        object SuperTabSheet1: TSuperTabSheet
          Caption = 'Скрипты и макросы'
          object lvMacros: TgsListView
            Left = 0
            Top = 0
            Width = 910
            Height = 383
            Align = alClient
            Columns = <
              item
                AutoSize = True
                Caption = 'Наименование'
              end
              item
                AutoSize = True
                Caption = 'Функция'
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
                AutoSize = True
                Caption = 'Функция'
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
        object SuperTabSheet2: TSuperTabSheet
          Caption = 'Метаданные'
          object lvMetaData: TgsListView
            Left = 0
            Top = 0
            Width = 1078
            Height = 383
            Align = alClient
            Columns = <
              item
                AutoSize = True
                Caption = 'Тип'
              end
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
                Caption = 'Тип'
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
            PopupMenu = pmMetaData
            SmallImages = dmImages.il16x16
            TabOrder = 0
            ViewStyle = vsReport
            OnDblClick = lvMetaDataDblClick
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
  object pmMetaData: TPopupMenu
    Images = dmImages.il16x16
    Left = 376
    Top = 250
    object N1: TMenuItem
      Action = actAddPos
    end
  end
end
