object at_dlgNamespaceOp: Tat_dlgNamespaceOp
  Left = 546
  Top = 461
  BorderStyle = bsDialog
  Caption = 'at_dlgNamespaceOp'
  ClientHeight = 299
  ClientWidth = 681
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
  object lblObject: TLabel
    Left = 24
    Top = 16
    Width = 41
    Height = 13
    Caption = 'lblObject'
  end
  object rbDelete: TRadioButton
    Left = 24
    Top = 40
    Width = 361
    Height = 17
    Caption = 'Удалить из пространства имен'
    TabOrder = 0
  end
  object rbMoveAdd: TRadioButton
    Left = 24
    Top = 72
    Width = 369
    Height = 17
    Caption = 'Переместить в пространство имен'
    TabOrder = 1
  end
  object Button1: TButton
    Left = 352
    Top = 224
    Width = 75
    Height = 21
    Action = actOk
    Default = True
    TabOrder = 2
  end
  object Button2: TButton
    Left = 456
    Top = 216
    Width = 75
    Height = 21
    Action = actCancel
    Cancel = True
    TabOrder = 3
  end
  object rbChange: TRadioButton
    Left = 24
    Top = 104
    Width = 393
    Height = 17
    Caption = 'Добавить/удалить зависимые объекты'
    TabOrder = 4
  end
  object ActionList: TActionList
    Left = 416
    Top = 80
    object actOk: TAction
      Caption = 'Ok'
    end
    object actCancel: TAction
      Caption = 'Отмена'
    end
  end
end
