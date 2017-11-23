object dnmn_frmMain: Tdnmn_frmMain
  Left = 467
  Top = 226
  BorderStyle = bsSingle
  Caption = 'DNMN'
  ClientHeight = 484
  ClientWidth = 520
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 520
    Height = 484
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 0
    object PageControl1: TPageControl
      Left = 4
      Top = 4
      Width = 512
      Height = 476
      ActivePage = TabSheet1
      Align = alClient
      TabOrder = 0
      object TabSheet1: TTabSheet
        Caption = 'Важно!'
        ImageIndex = 3
        object Label2: TLabel
          Left = 16
          Top = 430
          Width = 27
          Height = 11
          Caption = 'v.1.25'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -9
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object Memo1: TMemo
          Left = 10
          Top = 12
          Width = 476
          Height = 373
          BorderStyle = bsNone
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clMaroon
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          Lines.Strings = (
            'Перед началом деноминирования базы данных ОБЯЗАТЕЛЬНО'
            'создайте ее архивную копию и проверьте, что из неё без ошибок'
            'можно восстановить исходную базу данных.'
            ''
            'Храните архив на съёмном носителе в надёжном месте.'
            ''
            'Неденоминированная копия базы данных потребуется вам для'
            'сверки данных и построения отчётов за прошлые периоды.'
            ''
            'После деноминирования базы данных рекомендуем выполнить'
            'архирование с последующим восстановлением и работать'
            'с восстановленным из архива файлом.'
            ''
            ''
            'По всем вопросам обращайтесь в офис компании '
            'Golden Software of Belarus, Ltd по телефонам:'
            ''
            '+375-17-256 27 82, 256 27 83, 256 17 59'
            ''
            'http://gsbelarus.com'
            ''
            'Copyright (c) 2016 by Golden Software of Belarus, Ltd'
            'All rights reserved.')
          ParentColor = True
          ParentFont = False
          ReadOnly = True
          TabOrder = 0
        end
        object Button1: TButton
          Left = 12
          Top = 395
          Width = 121
          Height = 21
          HelpContext = 1111111
          Caption = 'Открыть сайт...'
          TabOrder = 1
          OnClick = Button1Click
        end
      end
      object tsDenom: TTabSheet
        Caption = 'Деноминация'
        object lblLog: TLabel
          Left = 20
          Top = 210
          Width = 72
          Height = 13
          Caption = 'Ход процесса:'
        end
        object lblPassword: TLabel
          Left = 214
          Top = 70
          Width = 41
          Height = 13
          Caption = 'Пароль:'
        end
        object lblUser: TLabel
          Left = 6
          Top = 70
          Width = 97
          Height = 13
          Caption = 'Имя пользователя:'
        end
        object lblPath: TLabel
          Left = 6
          Top = 4
          Width = 184
          Height = 13
          Caption = 'Полный путь к деноминируемой БД:'
        end
        object Label1: TLabel
          Left = 6
          Top = 45
          Width = 117
          Height = 11
          Caption = '[server[/port]:]full_file_name'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -9
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object mLog: TMemo
          Left = 5
          Top = 184
          Width = 494
          Height = 260
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
          ReadOnly = True
          ScrollBars = ssBoth
          TabOrder = 8
        end
        object btnBeginDNMN: TButton
          Left = 5
          Top = 158
          Width = 100
          Height = 21
          Caption = 'Начать'
          TabOrder = 7
          OnClick = btnBeginDNMNClick
        end
        object edPassword: TEdit
          Left = 259
          Top = 67
          Width = 83
          Height = 21
          PasswordChar = '*'
          TabOrder = 3
          Text = 'masterkey'
        end
        object edUser: TEdit
          Left = 110
          Top = 67
          Width = 83
          Height = 21
          TabOrder = 2
          Text = 'SYSDBA'
        end
        object edPath: TEdit
          Left = 6
          Top = 21
          Width = 463
          Height = 21
          TabOrder = 0
        end
        object btnPath: TButton
          Left = 468
          Top = 20
          Width = 30
          Height = 21
          Caption = '...'
          TabOrder = 1
          OnClick = btnPathClick
        end
        object cbRoundEntrySum: TCheckBox
          Left = 6
          Top = 97
          Width = 395
          Height = 17
          Caption = 'Округлять суммы по проводкам до целой копейки (0.01 руб)'
          TabOrder = 4
        end
        object cbMeta: TCheckBox
          Left = 6
          Top = 118
          Width = 404
          Height = 17
          Caption = 'Только исправить метаданные (домены), не деноминировать данные'
          TabOrder = 5
        end
        object cbMakeSaldo: TCheckBox
          Left = 6
          Top = 139
          Width = 419
          Height = 17
          Caption = 
            'Сохранить сальдо по бухгалтерским счетам до деноминации на 30.06' +
            '.2016'
          Checked = True
          State = cbChecked
          TabOrder = 6
        end
      end
      object tsFieldsSum: TTabSheet
        BorderWidth = 4
        Caption = 'Поля суммовые'
        ImageIndex = 1
        object mFieldsSum: TMemo
          Left = 0
          Top = 0
          Width = 496
          Height = 440
          Align = alClient
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
          ScrollBars = ssVertical
          TabOrder = 0
        end
      end
      object tsFieldsRate: TTabSheet
        BorderWidth = 4
        Caption = 'Поля курсовые'
        ImageIndex = 2
        object mFieldsRate: TMemo
          Left = 0
          Top = 0
          Width = 496
          Height = 440
          Align = alClient
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
          ScrollBars = ssVertical
          TabOrder = 0
        end
      end
    end
  end
end
