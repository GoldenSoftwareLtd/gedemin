object gp_dlgEnterDistance: Tgp_dlgEnterDistance
  Left = 316
  Top = 276
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Ввод расстояния'
  ClientHeight = 85
  ClientWidth = 237
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 12
    Top = 16
    Width = 63
    Height = 13
    Caption = 'Расстояние '
  end
  object speDistance: TxSpinEdit
    Left = 84
    Top = 12
    Width = 141
    Height = 21
    Increment = 1
    DecDigits = 0
    SpinCursor = 17555
    TabOrder = 0
  end
  object bOk: TButton
    Left = 29
    Top = 50
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object bCancel: TButton
    Left = 133
    Top = 50
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 2
  end
end
