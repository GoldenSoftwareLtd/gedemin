object st_dlgFind: Tst_dlgFind
  Left = 432
  Top = 392
  BorderStyle = bsDialog
  Caption = 'Поиск'
  ClientHeight = 216
  ClientWidth = 375
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 5
    Top = 9
    Width = 93
    Height = 13
    Caption = 'Текст для поиска:'
  end
  object Label2: TLabel
    Left = 222
    Top = 119
    Width = 3
    Height = 13
    Caption = '-'
  end
  object edFindText: TEdit
    Left = 105
    Top = 5
    Width = 184
    Height = 21
    TabOrder = 0
  end
  object gbView: TGroupBox
    Left = 5
    Top = 30
    Width = 285
    Height = 81
    Caption = 'Просмотреть'
    TabOrder = 1
    TabStop = True
    object cbFolder: TCheckBox
      Left = 10
      Top = 20
      Width = 256
      Height = 17
      Caption = 'Названия разделов'
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
    object cbValue: TCheckBox
      Left = 10
      Top = 40
      Width = 256
      Height = 17
      Caption = 'Названия параметров'
      Checked = True
      State = cbChecked
      TabOrder = 1
    end
    object cbData: TCheckBox
      Left = 10
      Top = 60
      Width = 256
      Height = 17
      Caption = 'Значения параметров'
      Checked = True
      State = cbChecked
      TabOrder = 2
    end
  end
  object btnFind: TButton
    Left = 295
    Top = 5
    Width = 75
    Height = 19
    Caption = 'Найти'
    Default = True
    ModalResult = 1
    TabOrder = 6
  end
  object btnClose: TButton
    Left = 295
    Top = 29
    Width = 75
    Height = 19
    Cancel = True
    Caption = 'Закрыть'
    ModalResult = 2
    TabOrder = 7
  end
  object xdeFrom: TxDateEdit
    Left = 158
    Top = 191
    Width = 62
    Height = 21
    Kind = kDate
    EmptyAtStart = True
    EditMask = '!99\.99\.9999;1;_'
    MaxLength = 10
    TabOrder = 4
    Text = '  .  .    '
  end
  object xdeTo: TxDateEdit
    Left = 228
    Top = 191
    Width = 62
    Height = 21
    Kind = kDate
    EmptyAtStart = True
    EditMask = '!99\.99\.9999;1;_'
    MaxLength = 10
    TabOrder = 5
    Text = '  .  .    '
  end
  object cbDate: TCheckBox
    Left = 15
    Top = 193
    Width = 142
    Height = 17
    Caption = 'Измененные за период:'
    TabOrder = 3
    OnClick = cbDateClick
  end
  object rgSetting: TRadioGroup
    Left = 5
    Top = 112
    Width = 285
    Height = 74
    Caption = ' Показать '
    ItemIndex = 0
    Items.Strings = (
      'Все'
      'Если входит в настройку'
      'Если не входит в настройку')
    TabOrder = 2
  end
end
