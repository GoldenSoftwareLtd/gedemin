object dlgPropertySettings: TdlgPropertySettings
  Left = 450
  Top = 194
  BorderStyle = bsDialog
  BorderWidth = 5
  Caption = 'Опции'
  ClientHeight = 231
  ClientWidth = 382
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object TXPBevel
    Left = 168
    Top = 88
    Width = 50
    Height = 50
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 382
    Height = 201
    ActivePage = TabSheet1
    Align = alClient
    TabHeight = 23
    TabOrder = 0
    object TabSheet1: TTabSheet
      BorderWidth = 5
      Caption = 'Общие'
      object Bevel1: TXPBevel
        Left = 0
        Top = 0
        Width = 364
        Height = 158
        Align = alClient
        Shape = bsFrame
        Style = bsLowered
      end
      object cbAutoSaveChanges: TCheckBox
        Left = 8
        Top = 8
        Width = 313
        Height = 17
        Caption = 'Автосохранение изменений при закрытии редактора'
        TabOrder = 0
      end
      object cbAutoSaveOnExecute: TCheckBox
        Left = 8
        Top = 25
        Width = 289
        Height = 17
        Caption = 'Автосохранение изменений перед запуском'
        TabOrder = 1
      end
      object cbAutoSaveCaretPos: TCheckBox
        Left = 8
        Top = 42
        Width = 313
        Height = 17
        Caption = 'Сохранять положение курсора и закладки'
        TabOrder = 2
      end
      object cbFullClassName: TCheckBox
        Left = 8
        Top = 59
        Width = 305
        Height = 17
        Caption = 'Выводить имя класса + подтип'
        TabOrder = 3
      end
      object cbNoticeTreeRefresh: TCheckBox
        Left = 8
        Top = 76
        Width = 305
        Height = 17
        Caption = 'Предупреждение об обновлении дерева'
        TabOrder = 4
      end
      object cbRestoreDeskTop: TCheckBox
        Left = 8
        Top = 92
        Width = 345
        Height = 17
        Caption = 'Восстанавливать рабочий стол'
        TabOrder = 5
      end
    end
    object TabSheet3: TTabSheet
      BorderWidth = 5
      Caption = 'Отладка'
      ImageIndex = 2
      object Bevel3: TXPBevel
        Left = 0
        Top = 0
        Width = 364
        Height = 158
        Align = alClient
        Shape = bsFrame
        Style = bsLowered
      end
      object cbUseDebugInfo: TCheckBox
        Left = 8
        Top = 8
        Width = 289
        Height = 17
        Caption = 'Использовать отладочную информацию'
        TabOrder = 0
      end
      object cbRuntimeSave: TCheckBox
        Left = 8
        Top = 24
        Width = 345
        Height = 17
        Caption = 'Сохранять время выполнения СФ в файл ScriptRuntime.log'
        TabOrder = 1
      end
    end
    object TabSheet5: TTabSheet
      BorderWidth = 5
      Caption = 'Ошибки'
      ImageIndex = 4
      object Bevel5: TXPBevel
        Left = 0
        Top = 0
        Width = 364
        Height = 158
        Align = alClient
        Shape = bsFrame
        Style = bsLowered
      end
      object cbStopOnDelphiException: TCheckBox
        Left = 8
        Top = 24
        Width = 313
        Height = 17
        Hint = 'Ошибки возникающие внутри объектов'
        Caption = 'Останавливать при возникновении внутренних ошибок'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
      end
      object cbStopOnException: TCheckBox
        Left = 8
        Top = 8
        Width = 257
        Height = 17
        Caption = 'Останавливать при возникновении ошибок'
        TabOrder = 0
        OnClick = cbStopOnExceptionClick
      end
      object cbSaveErrorLog: TCheckBox
        Left = 8
        Top = 58
        Width = 273
        Height = 17
        Caption = 'Сохранять информацию об ошибках в файл'
        TabOrder = 2
        OnClick = cbSaveErrorLogClick
      end
      object pnlErrLog: TPanel
        Left = 8
        Top = 80
        Width = 348
        Height = 69
        BevelOuter = bvLowered
        TabOrder = 3
        object Label4: TLabel
          Left = 8
          Top = 12
          Width = 171
          Height = 13
          Caption = 'Имя файла в каталоге Гедемина:'
        end
        object spErrorLines: TSpinEdit
          Left = 184
          Top = 40
          Width = 121
          Height = 22
          MaxLength = 5
          MaxValue = 20000
          MinValue = 100
          TabOrder = 2
          Value = 500
        end
        object cbLimitLines: TCheckBox
          Left = 8
          Top = 37
          Width = 174
          Height = 17
          Caption = 'Ограничить количество строк'
          Checked = True
          State = cbChecked
          TabOrder = 1
          OnClick = cbLimitLinesClick
        end
        object cbErrorLogFile: TComboBox
          Left = 184
          Top = 13
          Width = 156
          Height = 21
          Hint = 
            'Имя *.log в каталоге Гедемин, в который должна сохраняться инфор' +
            'мация об ошибках в скрипт-функциях.'
          ItemHeight = 0
          ParentShowHint = False
          ShowHint = True
          Sorted = True
          TabOrder = 0
          Text = 'ErrScript'
          OnExit = cbErrorLogFileExit
        end
      end
    end
    object TabSheet2: TTabSheet
      BorderWidth = 5
      Caption = 'Фильтр скрипт-функций'
      ImageIndex = 1
      object Bevel2: TXPBevel
        Left = 0
        Top = 0
        Width = 364
        Height = 158
        Align = alClient
        Shape = bsFrame
        Style = bsLowered
      end
      object cbShowUserSf: TCheckBox
        Left = 8
        Top = 8
        Width = 300
        Height = 17
        Caption = 'Выводить скрипт-функции, созданные пользователем'
        TabOrder = 0
      end
      object cbShowVBClassSF: TCheckBox
        Left = 8
        Top = 24
        Width = 300
        Height = 17
        Caption = 'Выводить скрипт-функции VB классов'
        TabOrder = 1
      end
      object cbShowMacrosSF: TCheckBox
        Left = 8
        Top = 40
        Width = 300
        Height = 17
        Caption = 'Выводить скрипт-функции макросов'
        TabOrder = 2
      end
      object cbShowReportSf: TCheckBox
        Left = 8
        Top = 56
        Width = 300
        Height = 17
        Caption = 'Выводить скрипт-функции отчетов'
        TabOrder = 3
      end
      object cbShowMethodSF: TCheckBox
        Left = 8
        Top = 72
        Width = 300
        Height = 17
        Caption = 'Выводить скрипт-функции методов'
        TabOrder = 4
      end
      object cbShowEventSf: TCheckBox
        Left = 8
        Top = 88
        Width = 300
        Height = 17
        Caption = 'Выводить скрипт-функции событий'
        TabOrder = 5
      end
      object cbShowEntrySf: TCheckBox
        Left = 8
        Top = 104
        Width = 345
        Height = 17
        Caption = 'Выводить скрипт-функции проводок'
        TabOrder = 6
      end
    end
    object TabSheet4: TTabSheet
      BorderWidth = 5
      Caption = 'Фильтр'
      ImageIndex = 3
      object Bevel4: TXPBevel
        Left = 0
        Top = 0
        Width = 364
        Height = 158
        Align = alClient
        Shape = bsFrame
        Style = bsLowered
      end
      object Label1: TLabel
        Left = 8
        Top = 7
        Width = 115
        Height = 13
        Caption = 'Наименование класса'
        Layout = tlCenter
      end
      object Label2: TLabel
        Left = 8
        Top = 31
        Width = 116
        Height = 13
        Caption = 'Наименование метода'
        Layout = tlCenter
      end
      object Label3: TLabel
        Left = 8
        Top = 55
        Width = 121
        Height = 13
        Caption = 'Наименование объекта'
        Layout = tlCenter
      end
      object z: TLabel
        Left = 8
        Top = 79
        Width = 122
        Height = 13
        Caption = 'Наименование события'
        Layout = tlCenter
      end
      object cbOnlySpecEvent: TCheckBox
        Left = 8
        Top = 107
        Width = 313
        Height = 17
        Caption = 'Выводить только переопределенные события и методы'
        TabOrder = 8
        OnClick = cbOnlySpecEventClick
      end
      object cbfoClass: TComboBox
        Left = 136
        Top = 7
        Width = 105
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 0
        OnChange = cbfoClassChange
        Items.Strings = (
          'Все'
          'Начинается с'
          'Содержит'
          'Заканчивается')
      end
      object eClassName: TEdit
        Left = 248
        Top = 7
        Width = 108
        Height = 21
        MaxLength = 255
        TabOrder = 1
      end
      object cbfoMethod: TComboBox
        Left = 136
        Top = 31
        Width = 105
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 2
        OnChange = cbfoMethodChange
        Items.Strings = (
          'Все'
          'Начинается с'
          'Содержит'
          'Заканчивается')
      end
      object eMethodName: TEdit
        Left = 248
        Top = 31
        Width = 108
        Height = 21
        MaxLength = 255
        TabOrder = 3
      end
      object cbfoObject: TComboBox
        Left = 136
        Top = 55
        Width = 105
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 4
        OnChange = cbfoObjectChange
        Items.Strings = (
          'Все'
          'Начинается с'
          'Содержит'
          'Заканчивается')
      end
      object eObjectName: TEdit
        Left = 248
        Top = 55
        Width = 108
        Height = 21
        MaxLength = 255
        TabOrder = 5
      end
      object cbfoEvent: TComboBox
        Left = 136
        Top = 79
        Width = 105
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 6
        OnChange = cbfoEventChange
        Items.Strings = (
          'Все'
          'Начинается с'
          'Содержит'
          'Заканчивается')
      end
      object eEventName: TEdit
        Left = 248
        Top = 79
        Width = 108
        Height = 21
        MaxLength = 255
        TabOrder = 7
      end
      object cbOnlyDisabled: TCheckBox
        Left = 8
        Top = 125
        Width = 313
        Height = 17
        Caption = 'Выводить только отключенные события и методы'
        TabOrder = 9
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 201
    Width = 382
    Height = 30
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object Button1: TButton
      Left = 227
      Top = 9
      Width = 75
      Height = 21
      Anchors = [akRight, akBottom]
      Caption = 'ОК'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object Button3: TButton
      Left = 307
      Top = 9
      Width = 75
      Height = 21
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 1
    end
  end
end
