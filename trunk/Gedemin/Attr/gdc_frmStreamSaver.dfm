object gdc_frmStreamSaver: Tgdc_frmStreamSaver
  Left = 629
  Top = 192
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Мастер переноса данных'
  ClientHeight = 371
  ClientWidth = 506
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlBottom: TPanel
    Left = 0
    Top = 342
    Width = 506
    Height = 29
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnClose: TButton
      Left = 405
      Top = 5
      Width = 96
      Height = 21
      Caption = 'Закрыть'
      TabOrder = 2
      OnClick = btnCloseClick
    end
    object btnNext: TButton
      Left = 297
      Top = 5
      Width = 96
      Height = 21
      Action = actNext
      Caption = 'Дальше >'
      Default = True
      TabOrder = 1
    end
    object btnPrev: TButton
      Left = 196
      Top = 5
      Width = 96
      Height = 21
      Action = actPrev
      Caption = '< Назад'
      TabOrder = 0
    end
  end
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 506
    Height = 342
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object pnlTop: TPanel
      Left = 0
      Top = 0
      Width = 506
      Height = 25
      Align = alTop
      BevelOuter = bvNone
      Color = clWindow
      TabOrder = 0
      object lblFirst: TLabel
        Left = 17
        Top = 5
        Width = 104
        Height = 13
        Caption = '1. Тип сохранения'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblSecond: TLabel
        Left = 384
        Top = 5
        Width = 74
        Height = 13
        Caption = '2. Сохранение'
      end
    end
    object PageControl: TPageControl
      Left = 0
      Top = 25
      Width = 506
      Height = 317
      ActivePage = tbsProcess
      Align = alClient
      Style = tsFlatButtons
      TabOrder = 1
      object tbsSave: TTabSheet
        Caption = 'tbsSave'
        TabVisible = False
        OnShow = tbsSaveShow
        object lblIncrementedHelp: TLabel
          Left = 8
          Top = 70
          Width = 481
          Height = 19
          AutoSize = False
          Caption = 
            'Из таблицы выберите базу данных на которую будут отправлены сохр' +
            'аняемые данные:'
          WordWrap = True
        end
        object lblFileType: TLabel
          Left = 8
          Top = 22
          Width = 57
          Height = 13
          Caption = 'Тип файла:'
        end
        object lblIncremented: TLabel
          Left = 8
          Top = 46
          Width = 79
          Height = 13
          Caption = 'Инкрементный:'
        end
        object pnlDatabases: TPanel
          Left = 0
          Top = 116
          Width = 498
          Height = 191
          Align = alBottom
          BevelOuter = bvNone
          TabOrder = 0
        end
        object cbStreamFormat: TComboBox
          Left = 116
          Top = 18
          Width = 364
          Height = 21
          Style = csDropDownList
          ItemHeight = 0
          TabOrder = 1
          OnChange = cbStreamFormatChange
        end
        object cbIncremented: TCheckBox
          Left = 116
          Top = 45
          Width = 221
          Height = 17
          TabOrder = 2
          OnClick = cbIncrementedClick
        end
      end
      object tbsLoad: TTabSheet
        Caption = 'tbsLoad'
        ImageIndex = 1
        TabVisible = False
        OnShow = tbsLoadShow
        object lblFileName: TLabel
          Left = 8
          Top = 22
          Width = 58
          Height = 13
          Caption = 'Имя файла:'
        end
        object lblLoadingSourceBase: TLabel
          Left = 8
          Top = 94
          Width = 79
          Height = 13
          Caption = 'Исходная база:'
        end
        object lblLoadingTargetBase: TLabel
          Left = 8
          Top = 118
          Width = 74
          Height = 13
          Caption = 'Целевая база:'
        end
        object lblLoadingFileTypeLabel: TLabel
          Left = 8
          Top = 46
          Width = 57
          Height = 13
          Caption = 'Тип файла:'
        end
        object lblLoadingFileType: TLabel
          Left = 116
          Top = 46
          Width = 3
          Height = 13
        end
        object lblLoadingIncremented: TLabel
          Left = 116
          Top = 70
          Width = 3
          Height = 13
        end
        object lblLoadingIncrementedLabel: TLabel
          Left = 8
          Top = 70
          Width = 79
          Height = 13
          Caption = 'Инкрементный:'
        end
        object eFileName: TEdit
          Left = 116
          Top = 18
          Width = 364
          Height = 21
          AutoSize = False
          ReadOnly = True
          TabOrder = 0
        end
        object eLoadingSourceBase: TEdit
          Left = 116
          Top = 90
          Width = 222
          Height = 21
          AutoSize = False
          ReadOnly = True
          TabOrder = 1
        end
        object eLoadingTargetBase: TEdit
          Left = 116
          Top = 114
          Width = 222
          Height = 21
          AutoSize = False
          ReadOnly = True
          TabOrder = 2
        end
      end
      object tbsProcess: TTabSheet
        ImageIndex = 3
        TabVisible = False
        OnShow = tbsProcessShow
        object lblErrorMsg: TLabel
          Left = 0
          Top = 125
          Width = 497
          Height = 124
          AutoSize = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clMaroon
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          Transparent = True
          Visible = False
          WordWrap = True
        end
        object lblProcessText: TLabel
          Left = 6
          Top = 105
          Width = 483
          Height = 39
          AutoSize = False
          Transparent = True
          WordWrap = True
        end
        object lblResult: TLabel
          Left = 0
          Top = 33
          Width = 497
          Height = 13
          Alignment = taCenter
          AutoSize = False
          Caption = 'Выполнение...'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblWasErrorMsg: TLabel
          Left = 0
          Top = 105
          Width = 497
          Height = 14
          Alignment = taCenter
          AutoSize = False
          Caption = 'В процессе работы возникли ошибки...'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clMaroon
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          Transparent = True
          Visible = False
          WordWrap = True
        end
        object lblProgressMain: TLabel
          Left = 72
          Top = 87
          Width = 354
          Height = 13
          Alignment = taCenter
          AutoSize = False
          Caption = '0 / 0'
        end
        object imgStatus: TImage
          Left = 344
          Top = 280
          Width = 16
          Height = 16
        end
        object btnShowLog: TButton
          Left = 363
          Top = 277
          Width = 134
          Height = 21
          Action = actShowLog
          TabOrder = 0
        end
        object pbMain: TProgressBar
          Left = 8
          Top = 62
          Width = 481
          Height = 17
          Min = 0
          Max = 10
          Smooth = True
          TabOrder = 1
        end
      end
      object tbsSetting: TTabSheet
        Caption = 'tbsSetting'
        ImageIndex = 4
        TabVisible = False
        OnShow = tbsSettingShow
        object lblSettingHint01: TLabel
          Left = 4
          Top = 70
          Width = 441
          Height = 26
          Caption = 
            '  Для того, чтобы структуры данных были созданы, а макросы начал' +
            'и выполняться, настройку, после ее загрузки в базу данных, необх' +
            'одимо активизировать.'
          Visible = False
          WordWrap = True
        end
        object lblSettingHint02: TLabel
          Left = 4
          Top = 102
          Width = 461
          Height = 26
          Caption = 
            '  Для этого необходимо установить на нее курсор и выбрать команд' +
            'у Активизировать на панели инструментов.'
          Visible = False
          WordWrap = True
        end
        object lblSettingQuestion: TLabel
          Left = 10
          Top = 7
          Width = 475
          Height = 39
          AutoSize = False
          Caption = 'lblSettingQuestion'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          Visible = False
          WordWrap = True
        end
        object lblSettingFormat: TLabel
          Left = 6
          Top = 126
          Width = 98
          Height = 13
          Caption = 'Формат настройки:'
          Visible = False
        end
        object cbMakeSetting: TCheckBox
          Left = 6
          Top = 90
          Width = 300
          Height = 17
          Caption = 'Сформировать настройку перед сохранением'
          Checked = True
          State = cbChecked
          TabOrder = 0
          Visible = False
          OnClick = cbMakeSettingClick
        end
        object cbSettingFormat: TComboBox
          Left = 116
          Top = 122
          Width = 222
          Height = 21
          Style = csDropDownList
          ItemHeight = 0
          TabOrder = 1
          Visible = False
          OnChange = cbSettingFormatChange
        end
      end
    end
  end
  object alMain: TActionList
    Left = 208
    Top = 288
    object actNext: TAction
      Caption = 'Дальше'
      OnExecute = actNextExecute
    end
    object actPrev: TAction
      Caption = 'Назад'
      OnExecute = actPrevExecute
    end
    object actShowLog: TAction
      Caption = 'Просмотреть лог...'
      OnExecute = actShowLogExecute
      OnUpdate = actShowLogUpdate
    end
  end
end
