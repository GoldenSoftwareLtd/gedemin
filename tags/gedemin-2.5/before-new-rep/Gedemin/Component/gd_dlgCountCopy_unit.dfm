object gd_dlgCountCopy: Tgd_dlgCountCopy
  Left = 377
  Top = 272
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Установки'
  ClientHeight = 87
  ClientWidth = 213
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
    Left = 22
    Top = 13
    Width = 92
    Height = 13
    Caption = 'Количество копий'
  end
  object xspeCopy: TxSpinEdit
    Left = 125
    Top = 9
    Width = 65
    Height = 21
    Value = 1
    IntValue = 1
    MaxValue = 999
    Increment = 1
    DecDigits = 0
    SpinCursor = 17555
    TabOrder = 0
  end
  object bOk: TButton
    Left = 21
    Top = 48
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
    OnClick = bOkClick
  end
  object Button2: TButton
    Left = 117
    Top = 48
    Width = 75
    Height = 25
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 2
  end
end
