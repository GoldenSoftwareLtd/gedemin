object gdc_frmStreamSaver: Tgdc_frmStreamSaver
  Left = 474
  Top = 199
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Мастер переноса данных'
  ClientHeight = 371
  ClientWidth = 506
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlBottom: TPanel
    Left = 0
    Top = 330
    Width = 506
    Height = 41
    Align = alBottom
    TabOrder = 1
    object btnClose: TButton
      Left = 408
      Top = 8
      Width = 85
      Height = 25
      Caption = 'Закрыть'
      TabOrder = 3
      OnClick = btnCloseClick
    end
    object btnNext: TButton
      Left = 279
      Top = 8
      Width = 110
      Height = 25
      Action = actNext
      Caption = 'Дальше >'
      Default = True
      TabOrder = 2
    end
    object btnPrev: TButton
      Left = 193
      Top = 8
      Width = 85
      Height = 25
      Action = actPrev
      Caption = '< Назад'
      TabOrder = 1
    end
    object btnSettings: TButton
      Left = 13
      Top = 8
      Width = 76
      Height = 25
      Action = actStreamSettings
      TabOrder = 0
    end
  end
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 506
    Height = 330
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object pnlTop: TPanel
      Left = 0
      Top = 0
      Width = 506
      Height = 41
      Align = alTop
      TabOrder = 0
      object lblFirst: TLabel
        Left = 17
        Top = 13
        Width = 111
        Height = 13
        Caption = '1. Тип сохранения'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblSecond: TLabel
        Left = 201
        Top = 13
        Width = 74
        Height = 13
        Caption = '2. Выбор базы'
      end
      object lblThird: TLabel
        Left = 384
        Top = 13
        Width = 72
        Height = 13
        Caption = '3. Сохранение'
      end
    end
    object PageControl: TPageControl
      Left = 0
      Top = 41
      Width = 506
      Height = 289
      ActivePage = tbsFirst
      Align = alClient
      TabOrder = 1
      object tbsFirst: TTabSheet
        Caption = 'tbsFirst'
        TabVisible = False
        OnShow = tbsFirstShow
        object gbOptions: TGroupBox
          Left = 5
          Top = 0
          Width = 488
          Height = 145
          Caption = ' Свойства  '
          TabOrder = 0
          object lblFileName: TLabel
            Left = 8
            Top = 22
            Width = 60
            Height = 13
            Caption = 'Имя файла:'
          end
          object lblFileType: TLabel
            Left = 8
            Top = 46
            Width = 57
            Height = 13
            Caption = 'Тип файла:'
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
          object lblIncremented: TLabel
            Left = 8
            Top = 70
            Width = 80
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
          object eFileType: TEdit
            Left = 116
            Top = 42
            Width = 222
            Height = 21
            AutoSize = False
            ReadOnly = True
            TabOrder = 1
          end
          object eLoadingSourceBase: TEdit
            Left = 116
            Top = 90
            Width = 222
            Height = 21
            AutoSize = False
            ReadOnly = True
            TabOrder = 2
          end
          object eLoadingTargetBase: TEdit
            Left = 116
            Top = 114
            Width = 222
            Height = 21
            AutoSize = False
            ReadOnly = True
            TabOrder = 3
          end
          object eIncremented: TEdit
            Left = 116
            Top = 66
            Width = 222
            Height = 21
            AutoSize = False
            ReadOnly = True
            TabOrder = 4
          end
        end
      end
      object tbsSecond: TTabSheet
        Caption = 'tbsSecond'
        ImageIndex = 1
        TabVisible = False
        OnShow = tbsSecondShow
        object Label1: TLabel
          Left = 10
          Top = 7
          Width = 448
          Height = 13
          Caption = 
            'Из таблицы выберите базу данных на которую будут отправлены сохр' +
            'аняемые данные.'
          WordWrap = True
        end
        object pnlDatabases: TPanel
          Left = 0
          Top = 21
          Width = 498
          Height = 258
          Align = alBottom
          BevelOuter = bvNone
          TabOrder = 0
        end
      end
      object tbsThird: TTabSheet
        ImageIndex = 3
        TabVisible = False
        OnShow = tbsThirdShow
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
          Font.Name = 'MS Sans Serif'
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
          Font.Name = 'MS Sans Serif'
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
        object btnShowLog: TButton
          Left = 355
          Top = 251
          Width = 134
          Height = 25
          Caption = 'Просмотреть лог-файл'
          TabOrder = 0
          OnClick = btnShowLogClick
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
          Width = 489
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
    object actStreamSettings: TAction
      Caption = 'Опции'
      OnExecute = actStreamSettingsExecute
    end
  end
end
