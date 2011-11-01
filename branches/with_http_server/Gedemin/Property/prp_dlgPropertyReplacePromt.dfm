object dlgPropertyReplacePromt: TdlgPropertyReplacePromt
  Left = 387
  Top = 446
  BorderStyle = bsDialog
  Caption = 'Запрос на замену'
  ClientHeight = 73
  ClientWidth = 343
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 8
    Width = 56
    Height = 13
    Caption = 'Заменить?'
  end
  object Button1: TButton
    Left = 8
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Да'
    Default = True
    ModalResult = 6
    TabOrder = 0
  end
  object Button2: TButton
    Left = 88
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Нет'
    ModalResult = 7
    TabOrder = 1
  end
  object Button3: TButton
    Left = 168
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 2
  end
  object Button4: TButton
    Left = 248
    Top = 40
    Width = 89
    Height = 25
    Caption = 'Заменить все'
    ModalResult = 8
    TabOrder = 3
  end
end
