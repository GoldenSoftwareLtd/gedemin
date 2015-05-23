object dlgPropertyReplace: TdlgPropertyReplace
  Left = 307
  Top = 294
  HelpContext = 331
  ActiveControl = cbSeachText
  Anchors = [akLeft, akBottom]
  BorderStyle = bsDialog
  Caption = 'Замена'
  ClientHeight = 242
  ClientWidth = 375
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 82
    Height = 21
    AutoSize = False
    Caption = 'Искомый текст:'
    Layout = tlCenter
  end
  object Label2: TLabel
    Left = 8
    Top = 40
    Width = 82
    Height = 21
    AutoSize = False
    Caption = 'Заменить:'
    Layout = tlCenter
  end
  object cbSeachText: TComboBox
    Left = 104
    Top = 8
    Width = 264
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 0
    OnChange = cbSeachTextChange
    OnDropDown = cbSeachTextDropDown
  end
  object gbOptions: TGroupBox
    Left = 8
    Top = 66
    Width = 177
    Height = 73
    Anchors = [akLeft, akBottom]
    Caption = 'Опции'
    TabOrder = 2
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
      Top = 32
      Width = 145
      Height = 17
      Caption = 'Слово целиком'
      TabOrder = 1
    end
    object cbPromt: TCheckBox
      Left = 8
      Top = 48
      Width = 161
      Height = 17
      Caption = 'Запрос на замену'
      TabOrder = 2
    end
  end
  object rgDirection: TRadioGroup
    Left = 192
    Top = 66
    Width = 176
    Height = 73
    Anchors = [akLeft, akBottom]
    BiDiMode = bdLeftToRight
    Caption = 'Направление'
    ItemIndex = 0
    Items.Strings = (
      'Вперёд'
      'Назад')
    ParentBiDiMode = False
    TabOrder = 4
  end
  object rgScope: TRadioGroup
    Left = 8
    Top = 146
    Width = 177
    Height = 57
    Anchors = [akLeft, akBottom]
    Caption = 'Пределы'
    ItemIndex = 0
    Items.Strings = (
      'Весь текст'
      'Выделенный текст')
    TabOrder = 3
  end
  object rgOrigin: TRadioGroup
    Left = 192
    Top = 146
    Width = 176
    Height = 57
    Anchors = [akLeft, akBottom]
    Caption = 'Начало'
    ItemIndex = 1
    Items.Strings = (
      'От курсора'
      'От начала текста')
    TabOrder = 5
  end
  object btnOk: TButton
    Left = 117
    Top = 214
    Width = 75
    Height = 21
    Anchors = [akLeft, akBottom]
    Caption = 'Заменить'
    Default = True
    TabOrder = 6
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 293
    Top = 214
    Width = 75
    Height = 21
    Anchors = [akLeft, akBottom]
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 8
  end
  object cbReplaceText: TComboBox
    Left = 104
    Top = 40
    Width = 264
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 1
    OnChange = cbReplaceTextChange
    OnDropDown = cbReplaceTextDropDown
  end
  object btnReplaceAll: TButton
    Left = 197
    Top = 214
    Width = 91
    Height = 21
    Caption = 'Заменить все'
    TabOrder = 7
    OnClick = btnOkClick
  end
  object btnHelp: TButton
    Left = 8
    Top = 214
    Width = 75
    Height = 21
    Action = actHelp
    TabOrder = 9
  end
  object ActionList: TActionList
    Left = 88
    Top = 160
    object WindowClose: TWindowClose
      Category = 'Window'
      Caption = 'C&lose'
      ShortCut = 27
      OnExecute = WindowCloseExecute
    end
    object actHelp: TAction
      Caption = 'Справка'
      OnExecute = actHelpExecute
    end
  end
end
