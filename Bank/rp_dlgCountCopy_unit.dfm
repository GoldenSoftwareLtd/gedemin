object rp_dlgCountCopy: Trp_dlgCountCopy
  Left = 270
  Top = 236
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Количество копий'
  ClientHeight = 98
  ClientWidth = 263
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 0
    Top = 60
    Width = 266
    Height = 2
  end
  object btnOk: TButton
    Left = 51
    Top = 70
    Width = 76
    Height = 23
    Caption = 'ОK'
    Default = True
    ModalResult = 1
    TabOrder = 4
  end
  object btnCancel: TButton
    Left = 141
    Top = 70
    Width = 76
    Height = 23
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 5
  end
  object btnPlus: TButton
    Left = 180
    Top = 30
    Width = 76
    Height = 23
    Caption = 'Плюс 1'
    TabOrder = 1
    OnClick = btnPlusClick
  end
  object btnMinus: TButton
    Left = 5
    Top = 30
    Width = 76
    Height = 23
    Caption = 'Минус 1'
    TabOrder = 0
    OnClick = btnMinusClick
  end
  object pnDoc: TPanel
    Left = 5
    Top = 5
    Width = 251
    Height = 21
    BevelInner = bvLowered
    BevelOuter = bvNone
    Caption = 'pnDoc'
    TabOrder = 2
  end
  object pnCopy: TPanel
    Left = 84
    Top = 30
    Width = 93
    Height = 23
    BevelInner = bvLowered
    BevelOuter = bvNone
    Caption = '1'
    TabOrder = 3
  end
end
