object dlgFilter_Grid: TdlgFilter_Grid
  Left = 305
  Top = 515
  BorderStyle = bsDialog
  Caption = 'Фильтр'
  ClientHeight = 95
  ClientWidth = 346
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 121
    Height = 13
    Caption = 'Введите строку поиска:'
  end
  object cbText: TComboBox
    Left = 8
    Top = 24
    Width = 249
    Height = 21
    ItemHeight = 13
    TabOrder = 0
  end
  object chbxRegExp: TCheckBox
    Left = 8
    Top = 50
    Width = 233
    Height = 17
    Action = actRegExp
    TabOrder = 1
  end
  object btnOk: TButton
    Left = 264
    Top = 8
    Width = 75
    Height = 21
    Action = actOk
    Default = True
    TabOrder = 3
  end
  object btnCancel: TButton
    Left = 264
    Top = 33
    Width = 75
    Height = 21
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 4
  end
  object chbxConvertSQL: TCheckBox
    Left = 8
    Top = 69
    Width = 249
    Height = 17
    Caption = 'Конвертировать символы % и _'
    Checked = True
    State = cbChecked
    TabOrder = 2
  end
  object ActionList: TActionList
    Left = 192
    Top = 8
    object actOk: TAction
      Caption = 'Искать'
      OnExecute = actOkExecute
      OnUpdate = actOkUpdate
    end
    object actRegExp: TAction
      Caption = 'Использовать регулярные выражения'
      OnExecute = actRegExpExecute
      OnUpdate = actRegExpUpdate
    end
  end
end
