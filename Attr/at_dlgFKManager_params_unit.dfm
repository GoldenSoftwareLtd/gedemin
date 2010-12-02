object at_dlgFKManager_params: Tat_dlgFKManager_params
  Left = 279
  Top = 423
  BorderStyle = bsDialog
  Caption = 'Параметры конвертации внешних ключей'
  ClientHeight = 155
  ClientWidth = 517
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 21
    Top = 39
    Width = 362
    Height = 13
    Caption = 
      'Таблица с внешним ключем содержит более                         ' +
      '      записей.'
  end
  object Label2: TLabel
    Left = 21
    Top = 65
    Width = 384
    Height = 13
    Caption = 
      'Количество уникальных значений в поле с внешним ключем не превыш' +
      'ает'
  end
  object Label3: TLabel
    Left = 8
    Top = 7
    Width = 504
    Height = 13
    Caption = 
      'Внешние ключи, удовлетворяющие заданным условиям, будут рекоменд' +
      'ованы для конвертации.'
  end
  object Bevel1: TBevel
    Left = 8
    Top = 26
    Width = 502
    Height = 92
    Shape = bsFrame
  end
  object xceMinRecCount: TxCalculatorEdit
    Left = 250
    Top = 36
    Width = 86
    Height = 21
    TabOrder = 2
    Text = '100000000'#0#0
    Value = 100000000
  end
  object xceMaxUqCount: TxCalculatorEdit
    Left = 410
    Top = 62
    Width = 59
    Height = 21
    TabOrder = 3
    Text = '99999'#0
    Value = 99999
  end
  object chbxDontProcessCyclicRef: TCheckBox
    Left = 19
    Top = 90
    Width = 341
    Height = 17
    Alignment = taLeftJustify
    Caption = 'Не обрабатывать циклические ссылки внутри одной таблицы'
    Checked = True
    State = cbChecked
    TabOrder = 4
  end
  object btnOk: TButton
    Left = 351
    Top = 126
    Width = 75
    Height = 21
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 435
    Top = 126
    Width = 75
    Height = 21
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 1
  end
end
