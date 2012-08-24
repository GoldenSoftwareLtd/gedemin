object gdc_inv_dlgViewFieldEvent: Tgdc_inv_dlgViewFieldEvent
  Left = 360
  Top = 126
  BorderStyle = bsDialog
  Caption = 'Выбор поля для просмотра события'
  ClientHeight = 157
  ClientWidth = 356
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object rgFields: TRadioGroup
    Left = 16
    Top = 8
    Width = 321
    Height = 97
    Caption = 'Поле'
    ItemIndex = 0
    Items.Strings = (
      'Сумма'
      'Цена '
      'Количество')
    TabOrder = 0
  end
  object bOk: TButton
    Left = 80
    Top = 120
    Width = 75
    Height = 25
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object bCancel: TButton
    Left = 200
    Top = 120
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 2
  end
end
