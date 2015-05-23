object dlgPropertyFind: TdlgPropertyFind
  Left = 308
  Top = 509
  HelpContext = 328
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  BorderWidth = 5
  Caption = 'Поиск'
  ClientHeight = 262
  ClientWidth = 358
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
    Width = 358
    Height = 233
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
        Left = 0
        Top = 0
        Width = 82
        Height = 21
        AutoSize = False
        Caption = 'Искомый текст:'
        Layout = tlCenter
      end
      object cbText: TComboBox
        Left = 88
        Top = 0
        Width = 252
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 13
        TabOrder = 0
        OnChange = cbTextChange
        OnDropDown = cbTextDropDown
      end
      object gbOptions: TGroupBox
        Left = 0
        Top = 32
        Width = 164
        Height = 73
        Caption = ' Параметры '
        TabOrder = 1
        object cbCaseSensitive: TCheckBox
          Left = 8
          Top = 16
          Width = 137
          Height = 17
          Caption = 'С учетом регистра'
          TabOrder = 0
        end
        object cbWholeWord: TCheckBox
          Left = 8
          Top = 40
          Width = 145
          Height = 17
          Caption = 'Слово целиком'
          TabOrder = 1
        end
      end
      object rgDirection: TRadioGroup
        Left = 174
        Top = 32
        Width = 164
        Height = 73
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Направление'
        ItemIndex = 0
        Items.Strings = (
          'Вперёд'
          'Назад')
        TabOrder = 2
      end
      object rgScope: TRadioGroup
        Left = 0
        Top = 112
        Width = 164
        Height = 77
        Caption = ' Область '
        ItemIndex = 0
        Items.Strings = (
          'Весь текст'
          'Выделенный текст')
        TabOrder = 3
      end
      object rgOrigin: TRadioGroup
        Left = 174
        Top = 112
        Width = 164
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
      Caption = 'Поиск в базе данных'
      ImageIndex = 1
      OnShow = tsFindInDBShow
      object Label2: TLabel
        Left = 0
        Top = 0
        Width = 82
        Height = 21
        AutoSize = False
        Caption = 'Искомый текст:'
        Layout = tlCenter
      end
      object Label3: TLabel
        Left = 116
        Top = 171
        Width = 5
        Height = 13
        Caption = 'с'
      end
      object Label4: TLabel
        Left = 222
        Top = 171
        Width = 12
        Height = 13
        Caption = 'по'
      end
      object cbTextDB: TComboBox
        Left = 88
        Top = 1
        Width = 251
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 13
        TabOrder = 0
        OnChange = cbTextChange
        OnDropDown = cbTextDropDown
      end
      object gbOptionsDB: TGroupBox
        Left = 0
        Top = 79
        Width = 171
        Height = 82
        Caption = 'Опции'
        TabOrder = 3
        object cbCaseSensitiveDB: TCheckBox
          Left = 8
          Top = 16
          Width = 137
          Height = 17
          Caption = 'С учетом регистра'
          TabOrder = 0
        end
        object cbWholeWordDB: TCheckBox
          Left = 8
          Top = 32
          Width = 145
          Height = 17
          Caption = 'Слово целиком'
          TabOrder = 1
        end
      end
      object cbByID_DB: TCheckBox
        Left = 0
        Top = 32
        Width = 153
        Height = 17
        Caption = 'Поиск по ИД или RUID'
        TabOrder = 1
        OnClick = cbByID_DBClick
      end
      object gbScopeDB: TGroupBox
        Left = 176
        Top = 32
        Width = 163
        Height = 129
        Caption = ' Область поиска '
        TabOrder = 4
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
        Left = 0
        Top = 48
        Width = 169
        Height = 17
        Caption = 'Поиск для текущего объекта'
        TabOrder = 2
      end
      object cbDate: TCheckBox
        Left = 0
        Top = 170
        Width = 108
        Height = 17
        Caption = 'Дата изменения:'
        TabOrder = 5
        OnClick = cbDateClick
      end
      object xdeBeginDate: TxDateEdit
        Left = 128
        Top = 168
        Width = 81
        Height = 21
        Kind = kDate
        EditMask = '!99\.99\.9999;1;_'
        MaxLength = 10
        TabOrder = 6
        Text = '07.03.2003'
      end
      object xdeEndDate: TxDateEdit
        Left = 242
        Top = 168
        Width = 97
        Height = 21
        Kind = kDate
        EditMask = '!99\.99\.9999;1;_'
        MaxLength = 10
        TabOrder = 7
        Text = '07.03.2003'
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 233
    Width = 358
    Height = 29
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnFind: TButton
      Left = 203
      Top = 7
      Width = 75
      Height = 21
      Anchors = [akTop, akRight]
      Caption = 'ОК'
      Default = True
      TabOrder = 0
      OnClick = btnFindClick
    end
    object btnCancel: TButton
      Left = 282
      Top = 7
      Width = 75
      Height = 21
      Anchors = [akTop, akRight]
      Caption = 'Отмена'
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
    Left = 108
    Top = 160
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
