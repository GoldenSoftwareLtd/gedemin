object dlgCheckMessage: TdlgCheckMessage
  Left = 268
  Top = 207
  BorderStyle = bsDialog
  ClientHeight = 92
  ClientWidth = 336
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object btnOk: TButton
    Left = 259
    Top = 4
    Width = 75
    Height = 25
    Caption = 'Продолжить'
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 259
    Top = 34
    Width = 75
    Height = 25
    Caption = 'Отменить'
    ModalResult = 2
    TabOrder = 1
  end
  object chbNoMore: TCheckBox
    Left = 5
    Top = 73
    Width = 265
    Height = 17
    Caption = 'Не показывать больше сообщения об ошибках'
    TabOrder = 2
  end
  object Panel1: TPanel
    Left = 4
    Top = 4
    Width = 249
    Height = 65
    BevelInner = bvSpace
    BevelOuter = bvLowered
    TabOrder = 3
    object lbMessage: TLabel
      Left = 2
      Top = 2
      Width = 245
      Height = 61
      Align = alClient
      Alignment = taCenter
      AutoSize = False
      Caption = 'lbMessage'
      Layout = tlCenter
    end
  end
end
