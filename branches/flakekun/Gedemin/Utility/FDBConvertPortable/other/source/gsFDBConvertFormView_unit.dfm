object gsFDBConvertFormView: TgsFDBConvertFormView
  Left = 436
  Top = 172
  BorderStyle = bsDialog
  Caption = 'FDB Convert'
  ClientHeight = 468
  ClientWidth = 634
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlLeft: TPanel
    Left = 0
    Top = 0
    Width = 150
    Height = 468
    Align = alLeft
    TabOrder = 0
  end
  object pnlRight: TPanel
    Left = 150
    Top = 0
    Width = 484
    Height = 468
    Align = alClient
    TabOrder = 1
    object pcMain: TPageControl
      Left = 1
      Top = 1
      Width = 482
      Height = 425
      ActivePage = tbs03
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      object tbs01: TTabSheet
        Caption = 'tbs01'
        object lblHello: TLabel
          Left = 8
          Top = 50
          Width = 457
          Height = 121
          AutoSize = False
          Caption = 'Приветствие.'
          WordWrap = True
        end
        object lblLanguage: TLabel
          Left = 8
          Top = 192
          Width = 94
          Height = 13
          Caption = 'Язык интерфейса:'
        end
        object lblStep01: TLabel
          Left = 8
          Top = 8
          Width = 46
          Height = 19
          Caption = '1/8 - '
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Bevel1: TBevel
          Left = 6
          Top = 34
          Width = 462
          Height = 2
        end
        object cbLanguage: TComboBox
          Left = 112
          Top = 188
          Width = 352
          Height = 21
          Style = csDropDownList
          ItemHeight = 0
          TabOrder = 0
          OnChange = cbLanguageChange
        end
      end
      object tbs02: TTabSheet
        Caption = 'tbs02'
        ImageIndex = 1
        object lblDatabaseBrowseDescription: TLabel
          Left = 8
          Top = 175
          Width = 281
          Height = 13
          Caption = 'Выберите базу данных или файл архива базы данных:'
        end
        object lblStep02: TLabel
          Left = 8
          Top = 8
          Width = 273
          Height = 19
          Caption = '2/8 - Выбор файла базы данных'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Bevel2: TBevel
          Left = 6
          Top = 34
          Width = 462
          Height = 2
        end
        object eDatabaseName: TEdit
          Left = 8
          Top = 199
          Width = 377
          Height = 21
          TabOrder = 0
        end
        object btnDatabaseBrowse: TButton
          Left = 388
          Top = 196
          Width = 75
          Height = 25
          Caption = 'Обзор ...'
          TabOrder = 1
          OnClick = btnDatabaseBrowseClick
        end
      end
      object tbs03: TTabSheet
        Caption = 'tbs03'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ImageIndex = 2
        ParentFont = False
        object lblStep03: TLabel
          Left = 8
          Top = 8
          Width = 250
          Height = 19
          Caption = '3/8 - Подробная информация'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Bevel3: TBevel
          Left = 6
          Top = 34
          Width = 462
          Height = 2
        end
        object lblOriginalDatabase: TLabel
          Left = 8
          Top = 48
          Width = 119
          Height = 13
          Caption = 'Исходная база данных:'
        end
        object lblOriginalDBVersion: TLabel
          Left = 8
          Top = 72
          Width = 109
          Height = 13
          Caption = 'Версия исходной БД:'
        end
        object lblOriginalServerVersion: TLabel
          Left = 8
          Top = 96
          Width = 93
          Height = 13
          Caption = 'Исходный сервер:'
        end
        object lblNewServerVersion: TLabel
          Left = 8
          Top = 120
          Width = 76
          Height = 13
          Caption = 'Новый сервер:'
        end
        object lblBackupName: TLabel
          Left = 8
          Top = 177
          Width = 82
          Height = 13
          Caption = 'Архивный файл:'
        end
        object lblTempDatabaseName: TLabel
          Left = 8
          Top = 201
          Width = 79
          Height = 13
          Caption = 'Временная БД:'
        end
        object lblPageSize: TLabel
          Left = 8
          Top = 257
          Width = 94
          Height = 13
          Caption = 'Размер страницы:'
        end
        object lblPageSize_02: TLabel
          Left = 304
          Top = 257
          Width = 23
          Height = 13
          Caption = 'байт'
        end
        object lblBufferSize: TLabel
          Left = 8
          Top = 281
          Width = 82
          Height = 13
          Caption = 'Размер буфера:'
        end
        object lblBufferSize_02: TLabel
          Left = 304
          Top = 281
          Width = 41
          Height = 13
          Caption = 'страниц'
        end
        object lblCharacterSet: TLabel
          Left = 8
          Top = 305
          Width = 96
          Height = 13
          Caption = 'Кодовая страница:'
        end
        object eOriginalDatabase: TEdit
          Left = 136
          Top = 44
          Width = 329
          Height = 21
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 0
        end
        object eOriginalDBVersion: TEdit
          Left = 136
          Top = 68
          Width = 329
          Height = 21
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 1
        end
        object eOriginalServerVersion: TEdit
          Left = 136
          Top = 92
          Width = 329
          Height = 21
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 2
        end
        object eNewServerVersion: TEdit
          Left = 136
          Top = 116
          Width = 329
          Height = 21
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 3
        end
        object eBackupName: TEdit
          Left = 136
          Top = 173
          Width = 297
          Height = 21
          TabOrder = 4
        end
        object btnBrowseBackupName: TButton
          Left = 434
          Top = 173
          Width = 29
          Height = 21
          Action = actBrowseBackupFile
          TabOrder = 5
        end
        object eTempDatabaseName: TEdit
          Left = 136
          Top = 197
          Width = 297
          Height = 21
          TabOrder = 6
        end
        object btnBrowseTempDatabaseName: TButton
          Left = 434
          Top = 197
          Width = 29
          Height = 21
          Action = actBrowseCopyFile
          TabOrder = 7
        end
        object eBufferSize: TEdit
          Left = 136
          Top = 277
          Width = 165
          Height = 21
          TabOrder = 9
        end
        object cbPageSize: TComboBox
          Left = 136
          Top = 253
          Width = 165
          Height = 21
          ItemHeight = 13
          TabOrder = 8
          Items.Strings = (
            '1024'
            '2048'
            '4096'
            '8192'
            '16384')
        end
        object cbCharacterSet: TComboBox
          Left = 136
          Top = 301
          Width = 329
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 10
        end
      end
      object tbs04: TTabSheet
        Caption = 'tbs04'
        ImageIndex = 3
        object lblStep04: TLabel
          Left = 8
          Top = 8
          Width = 231
          Height = 19
          Caption = '4/8 - Заменяемые функции'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Bevel4: TBevel
          Left = 6
          Top = 34
          Width = 462
          Height = 2
        end
        object lblOriginalFunction: TLabel
          Left = 63
          Top = 53
          Width = 107
          Height = 13
          Caption = 'Заменяемая функция'
        end
        object lblSubstituteFunction: TLabel
          Left = 297
          Top = 53
          Width = 113
          Height = 13
          Caption = 'Заменяющая функция'
        end
        object sgSubstituteList: TStringGrid
          Left = 8
          Top = 74
          Width = 458
          Height = 314
          ColCount = 2
          DefaultColWidth = 219
          DefaultRowHeight = 16
          FixedCols = 0
          RowCount = 20
          FixedRows = 0
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goEditing]
          ScrollBars = ssVertical
          TabOrder = 0
        end
      end
      object tbs05: TTabSheet
        Caption = 'tbs05'
        ImageIndex = 4
        OnShow = tbs05Show
        object lblStep05: TLabel
          Left = 8
          Top = 8
          Width = 154
          Height = 19
          Caption = '5/8 - Информация'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Bevel5: TBevel
          Left = 6
          Top = 34
          Width = 462
          Height = 2
        end
        object mProcessInformation: TMemo
          Left = 8
          Top = 48
          Width = 458
          Height = 340
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 0
        end
      end
      object tbs06: TTabSheet
        Caption = 'tbs06'
        ImageIndex = 5
        OnShow = tbs06Show
        object lblStep06: TLabel
          Left = 8
          Top = 8
          Width = 160
          Height = 19
          Caption = '6/8 - Ход процесса'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Bevel6: TBevel
          Left = 6
          Top = 34
          Width = 462
          Height = 2
        end
        object pbMain: TProgressBar
          Left = 8
          Top = 48
          Width = 458
          Height = 15
          Min = 0
          Max = 100
          TabOrder = 0
        end
        object mProgress: TMemo
          Left = 8
          Top = 70
          Width = 458
          Height = 318
          ReadOnly = True
          ScrollBars = ssVertical
          TabOrder = 1
        end
      end
      object tbs07: TTabSheet
        Caption = 'tbs07'
        ImageIndex = 8
        object Bevel7: TBevel
          Left = 6
          Top = 34
          Width = 462
          Height = 2
        end
        object lblStep07: TLabel
          Left = 8
          Top = 8
          Width = 151
          Height = 19
          Caption = '7/8 - Завершение'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object mAfterProcessInformation: TMemo
          Left = 8
          Top = 48
          Width = 458
          Height = 340
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 0
        end
      end
      object tbs08: TTabSheet
        Caption = 'tbs08'
        ImageIndex = 7
        object lblStep08: TLabel
          Left = 8
          Top = 8
          Width = 119
          Height = 19
          Caption = '8/8 - Реклама'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Bevel8: TBevel
          Left = 6
          Top = 34
          Width = 462
          Height = 2
        end
      end
    end
    object pnlButtons: TPanel
      Left = 1
      Top = 426
      Width = 482
      Height = 41
      Align = alBottom
      TabOrder = 1
      object btnExit: TButton
        Left = 400
        Top = 9
        Width = 75
        Height = 25
        Action = actClose
        TabOrder = 2
      end
      object btnNext: TButton
        Left = 296
        Top = 9
        Width = 89
        Height = 25
        Action = actNextPage
        TabOrder = 1
      end
      object btnPrev: TButton
        Left = 205
        Top = 9
        Width = 89
        Height = 25
        Action = actPrevPage
        TabOrder = 0
      end
    end
  end
  object ActionList1: TActionList
    Left = 8
    Top = 8
    object actPrevPage: TAction
      Caption = '< Назад'
      OnExecute = actPrevPageExecute
      OnUpdate = actPrevPageUpdate
    end
    object actNextPage: TAction
      Caption = 'Далее >'
      OnExecute = actNextPageExecute
      OnUpdate = actNextPageUpdate
    end
    object actClose: TAction
      Caption = 'Выйти'
      OnExecute = actCloseExecute
    end
    object actBrowseBackupFile: TAction
      Caption = '...'
      OnExecute = actBrowseBackupFileExecute
    end
    object actBrowseCopyFile: TAction
      Caption = '...'
      OnExecute = actBrowseCopyFileExecute
    end
  end
end
