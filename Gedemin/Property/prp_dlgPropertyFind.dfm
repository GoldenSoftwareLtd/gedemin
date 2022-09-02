object dlgPropertyFind: TdlgPropertyFind
  Left = 464
  Top = 218
  HelpContext = 328
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  BorderWidth = 5
  Caption = 'Поиск'
  ClientHeight = 310
  ClientWidth = 384
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PC: TPageControl
    Left = 0
    Top = 0
    Width = 384
    Height = 281
    ActivePage = tsFindInDB
    Align = alClient
    TabHeight = 23
    TabOrder = 0
    OnChange = PCChange
    object tsFind: TTabSheet
      HelpContext = 329
      BorderWidth = 5
      Caption = 'Поиск'
      OnShow = tsFindShow
      object Label1: TLabel
        Left = 2
        Top = 0
        Width = 82
        Height = 21
        AutoSize = False
        Caption = 'Искомый текст:'
        Layout = tlCenter
      end
      object cbText: TComboBox
        Left = 90
        Top = 0
        Width = 278
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 13
        TabOrder = 0
        OnChange = cbTextChange
        OnDropDown = cbTextDropDown
      end
      object gbOptions: TGroupBox
        Left = 2
        Top = 31
        Width = 168
        Height = 77
        Caption = ' Параметры '
        TabOrder = 1
        object cbCaseSensitive: TCheckBox
          Left = 8
          Top = 20
          Width = 137
          Height = 17
          Caption = 'С учетом регистра'
          TabOrder = 0
        end
        object cbWholeWord: TCheckBox
          Left = 8
          Top = 48
          Width = 145
          Height = 17
          Caption = 'Слово целиком'
          TabOrder = 1
        end
      end
      object rgDirection: TRadioGroup
        Left = 176
        Top = 31
        Width = 190
        Height = 77
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Направление'
        ItemIndex = 0
        Items.Strings = (
          'Вперёд'
          'Назад')
        TabOrder = 2
      end
      object rgScope: TRadioGroup
        Left = 2
        Top = 123
        Width = 168
        Height = 77
        Caption = ' Область '
        ItemIndex = 0
        Items.Strings = (
          'Весь текст'
          'Выделенный текст')
        TabOrder = 3
      end
      object rgOrigin: TRadioGroup
        Left = 176
        Top = 123
        Width = 190
        Height = 77
        Anchors = [akLeft, akTop, akRight]
        Caption = ' Начало '
        ItemIndex = 1
        Items.Strings = (
          'От курсора'
          'От начала текста')
        TabOrder = 4
      end
    end
    object tsFindInDB: TTabSheet
      HelpContext = 330
      BorderWidth = 5
      Caption = 'Поиск и замена в базе данных'
      ImageIndex = 1
      OnShow = tsFindInDBShow
      object Label2: TLabel
        Left = 2
        Top = 0
        Width = 82
        Height = 21
        AutoSize = False
        Caption = 'Искомый текст:'
        Layout = tlCenter
      end
      object Label3: TLabel
        Left = 118
        Top = 202
        Width = 5
        Height = 13
        Caption = 'с'
      end
      object Label4: TLabel
        Left = 224
        Top = 202
        Width = 12
        Height = 13
        Caption = 'по'
      end
      object cbTextDB: TComboBox
        Left = 92
        Top = 1
        Width = 274
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 13
        TabOrder = 0
        OnChange = cbTextChange
        OnDropDown = cbTextDropDown
      end
      object gbOptionsDB: TGroupBox
        Left = 2
        Top = 103
        Width = 171
        Height = 88
        Caption = 'Опции'
        TabOrder = 5
        object cbCaseSensitiveDB: TCheckBox
          Left = 8
          Top = 15
          Width = 137
          Height = 17
          Caption = 'С учетом регистра'
          TabOrder = 0
        end
        object cbWholeWordDB: TCheckBox
          Left = 8
          Top = 31
          Width = 145
          Height = 17
          Caption = 'Слово целиком'
          TabOrder = 1
        end
        object cbUseRegExpDB: TCheckBox
          Left = 8
          Top = 48
          Width = 145
          Height = 17
          Caption = 'Регулярные выражения'
          TabOrder = 2
          OnClick = cbUseRegExpDBClick
        end
        object cbSkipCommentsDB: TCheckBox
          Left = 8
          Top = 64
          Width = 156
          Height = 17
          Caption = 'Не искать в комментариях'
          TabOrder = 3
        end
      end
      object cbByID_DB: TCheckBox
        Left = 2
        Top = 56
        Width = 191
        Height = 17
        Caption = 'Поиск функции по её ID или RUID'
        TabOrder = 3
        OnClick = cbByID_DBClick
      end
      object gbScopeDB: TGroupBox
        Left = 201
        Top = 56
        Width = 163
        Height = 135
        Caption = ' Область поиска '
        TabOrder = 6
        object cbInTextDB: TCheckBox
          Left = 8
          Top = 16
          Width = 97
          Height = 17
          Caption = 'Поиск в тексте'
          Checked = True
          State = cbChecked
          TabOrder = 0
        end
        object cbInCaptionDB: TCheckBox
          Left = 8
          Top = 32
          Width = 105
          Height = 17
          Caption = 'Поиск в имени'
          Checked = True
          State = cbChecked
          TabOrder = 1
          OnClick = cbInCaptionDBClick
        end
        object Panel2: TPanel
          Left = 7
          Top = 51
          Width = 149
          Height = 71
          BevelInner = bvRaised
          BevelOuter = bvLowered
          TabOrder = 2
          object cbInMacroName: TCheckBox
            Left = 8
            Top = 3
            Width = 113
            Height = 17
            Caption = 'в имени макроса'
            TabOrder = 0
          end
          object cbInReportName: TCheckBox
            Left = 8
            Top = 19
            Width = 113
            Height = 17
            Caption = 'в имени отчета'
            TabOrder = 1
          end
          object cbInOtherName: TCheckBox
            Left = 8
            Top = 51
            Width = 118
            Height = 17
            Caption = 'во всех остальных'
            Checked = True
            State = cbChecked
            TabOrder = 2
          end
          object cbInEventName: TCheckBox
            Left = 8
            Top = 35
            Width = 113
            Height = 17
            Caption = 'в имени события'
            TabOrder = 3
          end
        end
      end
      object cbCurrentObject: TCheckBox
        Left = 2
        Top = 72
        Width = 169
        Height = 17
        Caption = 'Поиск для текущего объекта'
        TabOrder = 4
      end
      object cbDate: TCheckBox
        Left = 2
        Top = 201
        Width = 108
        Height = 17
        Caption = 'Дата изменения:'
        TabOrder = 7
        OnClick = cbDateClick
      end
      object xdeBeginDate: TxDateEdit
        Left = 130
        Top = 199
        Width = 81
        Height = 21
        Kind = kDate
        EditMask = '!99\.99\.9999;1;_'
        MaxLength = 10
        TabOrder = 8
        Text = '07.03.2003'
      end
      object xdeEndDate: TxDateEdit
        Left = 244
        Top = 199
        Width = 97
        Height = 21
        Kind = kDate
        EditMask = '!99\.99\.9999;1;_'
        MaxLength = 10
        TabOrder = 9
        Text = '07.03.2003'
      end
      object cbReplaceText: TComboBox
        Left = 92
        Top = 27
        Width = 274
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        Enabled = False
        ItemHeight = 13
        TabOrder = 2
        OnChange = cbReplaceTextChange
        OnDropDown = cbReplaceTextDropDown
      end
      object cbWithReplace: TCheckBox
        Left = 2
        Top = 29
        Width = 88
        Height = 17
        Caption = 'заменить на:'
        TabOrder = 1
        OnClick = cbWithReplaceClick
      end
      object cbNotLimitResults: TCheckBox
        Left = 2
        Top = 218
        Width = 335
        Height = 17
        Caption = 'Не ограничивать количество результатов поиска'
        TabOrder = 10
      end
    end
    object tsFindIdentifier: TTabSheet
      Caption = 'Поиск и замена идентификаторов'
      ImageIndex = 2
      object mPeriodHelp: TMemo
        Left = 7
        Top = 7
        Width = 345
        Height = 213
        TabStop = False
        Color = clInfoBk
        Lines.Strings = (
          'Будет произведен поиск числовых значений '
          '(идентификаторов), которые необходимо заменить.'
          ''
          'В результат поиска НЕ попадают значения:'
          '- меньше 147 000 000;'
          '- входящие в конструкции:'
          '  - GetIDByRUID(..., ...);'
          '  - GD_P_GETID(...);'
          '  - <RUID XID = ...DBID = .../>.'
          ''
          'Найденные значения можно будет заменить на один '
          'из вариантов с созданием соответсвующего РУИДа:'
          '- gdcBaseManager.GetIDByRUID(..., ...);'
          '- GD_P_GETID(..., ...);'
          '- <RUID XID = ...DBID = .../>.')
        ReadOnly = True
        TabOrder = 0
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 281
    Width = 384
    Height = 29
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnFind: TButton
      Left = 229
      Top = 7
      Width = 75
      Height = 21
      Anchors = [akTop, akRight]
      Caption = 'Найти'
      Default = True
      TabOrder = 0
      OnClick = btnFindClick
    end
    object btnCancel: TButton
      Left = 308
      Top = 7
      Width = 75
      Height = 21
      Anchors = [akTop, akRight]
      Caption = 'Закрыть'
      ModalResult = 2
      TabOrder = 1
    end
    object Button1: TButton
      Left = 1
      Top = 7
      Width = 75
      Height = 21
      Action = actHelp
      TabOrder = 2
    end
  end
  object ActionList1: TActionList
    Left = 140
    Top = 152
    object WindowClose: TWindowClose
      Category = 'Window'
      Caption = 'C&lose'
      ShortCut = 27
      OnExecute = WindowCloseExecute
    end
    object actChangePage: TAction
      Caption = 'actChangePage'
      ShortCut = 16393
      OnExecute = actChangePageExecute
    end
    object actHelp: TAction
      Caption = 'Справка'
      OnExecute = actHelpExecute
    end
  end
end
