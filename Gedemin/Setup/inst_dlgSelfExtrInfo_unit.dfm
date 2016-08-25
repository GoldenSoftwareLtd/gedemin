object inst_dlgSelfExtrInfo: Tinst_dlgSelfExtrInfo
  Left = 240
  Top = 156
  HelpContext = 100003
  ActiveControl = btnClose
  BorderStyle = bsDialog
  Caption = 'Установка вспомогательных программ'
  ClientHeight = 196
  ClientWidth = 418
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  HelpFile = 'GedyminGS.chm'
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 4
    Top = 4
    Width = 410
    Height = 157
    Shape = bsFrame
  end
  object btnClose: TButton
    Left = 336
    Top = 168
    Width = 77
    Height = 21
    Cancel = True
    Caption = 'Закрыть'
    Default = True
    ModalResult = 2
    TabOrder = 2
  end
  object cbDontShowAgain: TCheckBox
    Left = 8
    Top = 140
    Width = 193
    Height = 17
    Caption = 'Не выводить больше это окно'
    TabOrder = 1
  end
  object Memo1: TMemo
    Left = 9
    Top = 11
    Width = 401
    Height = 121
    TabStop = False
    BorderStyle = bsNone
    Color = clBtnFace
    Lines.Strings = (
      'Сейчас будет произведена установка программы'
      'Она необходима для работы комплекса Гедымин.'
      ''
      'Для установки программы необходимо согласиться с условиями '
      
        'предложенного лицензионного соглашения и следовать другим инстру' +
        'кциям.'
      ''
      
        'Рекомендуется не изменять предлагаемый по умолчанию путь установ' +
        'ки.'
      ''
      'После завершения будет продолжена установка комплекса Гедымин.')
    ReadOnly = True
    TabOrder = 0
  end
  object Button1: TButton
    Left = 5
    Top = 167
    Width = 77
    Height = 21
    Cancel = True
    Caption = 'Справка'
    Default = True
    ModalResult = 2
    TabOrder = 3
    OnClick = Button1Click
  end
end
