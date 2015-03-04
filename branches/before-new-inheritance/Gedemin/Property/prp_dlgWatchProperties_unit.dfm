object dlgWatchProperties: TdlgWatchProperties
  Left = 356
  Top = 271
  HelpContext = 316
  ActiveControl = cbName
  BorderStyle = bsDialog
  BorderWidth = 5
  Caption = 'Свойства просмотра'
  ClientHeight = 81
  ClientWidth = 322
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
  PixelsPerInch = 96
  TextHeight = 13
  object XPBevel1: TXPBevel
    Left = 0
    Top = 0
    Width = 322
    Height = 55
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    Shape = bsFrame
    Style = bsLowered
  end
  object lExpression: TLabel
    Left = 8
    Top = 8
    Width = 62
    Height = 13
    Caption = 'Выражение:'
  end
  object cbName: TComboBox
    Left = 80
    Top = 8
    Width = 238
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 0
  end
  object Button1: TButton
    Left = 246
    Top = 60
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 4
  end
  object Button2: TButton
    Left = 166
    Top = 60
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 3
    OnClick = Button2Click
  end
  object cbEnabled: TCheckBox
    Left = 8
    Top = 32
    Width = 105
    Height = 17
    Caption = 'Вычислять'
    TabOrder = 1
  end
  object cbAllowFunctionCall: TCheckBox
    Left = 150
    Top = 32
    Width = 169
    Height = 17
    Caption = 'Разрешить вызов функций'
    TabOrder = 2
  end
end
