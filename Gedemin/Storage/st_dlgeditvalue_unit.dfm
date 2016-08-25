object st_dlgeditvalue: Tst_dlgeditvalue
  Left = 374
  Top = 260
  HelpContext = 109
  BorderStyle = bsDialog
  Caption = 'Редактирование переменной'
  ClientHeight = 191
  ClientWidth = 377
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 10
    Top = 80
    Width = 144
    Height = 13
    Caption = 'Наименование переменной:'
  end
  object Label2: TLabel
    Left = 10
    Top = 123
    Width = 51
    Height = 13
    Caption = 'Значение:'
  end
  object lblID: TLabel
    Left = 282
    Top = 80
    Width = 83
    Height = 13
    Caption = 'Идентификатор:'
  end
  object edName: TEdit
    Left = 8
    Top = 96
    Width = 265
    Height = 21
    TabOrder = 1
  end
  object edValue: TEdit
    Left = 8
    Top = 136
    Width = 361
    Height = 21
    TabOrder = 2
  end
  object rg: TRadioGroup
    Left = 8
    Top = 8
    Width = 361
    Height = 65
    Caption = ' Тип значения '
    Columns = 2
    ItemIndex = 0
    Items.Strings = (
      'Целое число'
      'Дата и время'
      'Строка'
      'Дробное число'
      'Булевское значение (1/0)')
    TabOrder = 0
    TabStop = True
  end
  object btnHelp: TButton
    Left = 8
    Top = 164
    Width = 75
    Height = 21
    Action = actHelp
    TabOrder = 5
  end
  object btnOk: TButton
    Left = 211
    Top = 164
    Width = 75
    Height = 21
    Action = actOk
    Default = True
    ModalResult = 1
    TabOrder = 3
  end
  object btnCancel: TButton
    Left = 293
    Top = 164
    Width = 75
    Height = 21
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 4
  end
  object edID: TEdit
    Left = 280
    Top = 96
    Width = 89
    Height = 21
    Enabled = False
    ReadOnly = True
    TabOrder = 6
  end
  object ActionList1: TActionList
    Left = 64
    Top = 120
    object actOk: TAction
      Caption = 'Готово'
      OnUpdate = actOkUpdate
    end
    object actHelp: TAction
      Caption = 'Справка'
      ShortCut = 112
      OnExecute = actHelpExecute
    end
  end
end
