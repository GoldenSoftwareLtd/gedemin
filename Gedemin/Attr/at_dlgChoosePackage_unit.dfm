object at_dlgChoosePackage: Tat_dlgChoosePackage
  Left = 310
  Top = 428
  HelpContext = 128
  BorderStyle = bsDialog
  Caption = 'Выбор пакета настроек'
  ClientHeight = 254
  ClientWidth = 537
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
  object Bevel1: TBevel
    Left = 8
    Top = 8
    Width = 521
    Height = 49
  end
  object mGSFInfo: TMemo
    Left = 304
    Top = 64
    Width = 225
    Height = 89
    TabStop = False
    Color = clBtnFace
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object btnChoose: TBitBtn
    Left = 304
    Top = 160
    Width = 225
    Height = 21
    Caption = 'Выбрать'
    Default = True
    ModalResult = 1
    TabOrder = 2
    OnClick = btnChooseClick
    NumGlyphs = 2
  end
  object btnCancel: TBitBtn
    Left = 424
    Top = 224
    Width = 105
    Height = 21
    Caption = 'Отмена'
    ModalResult = 3
    TabOrder = 3
    NumGlyphs = 2
  end
  object btnExist: TBitBtn
    Left = 304
    Top = 192
    Width = 225
    Height = 21
    Caption = 'Оставить существующую'
    Default = True
    ModalResult = 5
    TabOrder = 4
    NumGlyphs = 2
  end
  object lbPackage: TListBox
    Left = 8
    Top = 64
    Width = 289
    Height = 185
    ItemHeight = 16
    Style = lbOwnerDrawFixed
    TabOrder = 0
    OnClick = lbPackageClick
  end
  object Memo1: TMemo
    Left = 16
    Top = 12
    Width = 505
    Height = 41
    BorderStyle = bsNone
    Color = clBtnFace
    Lines.Strings = (
      
        'Устанавливаемый пакет настроек зависит от другого пакета. По ука' +
        'занному пути и/или в базе '
      
        'данных обнаружено несколько версий данного пакета настроек. Укаж' +
        'ите ту, которую вы '
      'хотите установить. ')
    TabOrder = 5
  end
  object btnHelp: TBitBtn
    Left = 304
    Top = 224
    Width = 105
    Height = 21
    Caption = 'Справка'
    TabOrder = 6
    OnClick = btnHelpClick
    NumGlyphs = 2
  end
end
