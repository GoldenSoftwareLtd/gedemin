object dlgEditStringList: TdlgEditStringList
  Left = 247
  Top = 155
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Редактирование'
  ClientHeight = 285
  ClientWidth = 388
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 302
    Top = 0
    Width = 86
    Height = 285
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 0
    object btnOK: TButton
      Left = 3
      Top = 5
      Width = 75
      Height = 23
      Caption = 'ОК'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 3
      Top = 31
      Width = 75
      Height = 23
      Cancel = True
      Caption = 'Отменить'
      ModalResult = 2
      TabOrder = 1
    end
    object Button1: TButton
      Left = 3
      Top = 71
      Width = 75
      Height = 23
      Action = actNew
      TabOrder = 2
    end
    object Button2: TButton
      Left = 3
      Top = 96
      Width = 75
      Height = 23
      Action = actDelete
      TabOrder = 3
    end
    object Button3: TButton
      Left = 3
      Top = 121
      Width = 75
      Height = 23
      Action = actNew
      Caption = 'Текст'
      TabOrder = 4
      OnClick = Button3Click
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 302
    Height = 285
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 6
    Caption = 'Panel2'
    TabOrder = 1
    object StringGrid: TStringGrid
      Left = 6
      Top = 6
      Width = 290
      Height = 273
      Align = alClient
      ColCount = 1
      DefaultRowHeight = 16
      FixedCols = 0
      FixedRows = 0
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goEditing]
      PopupMenu = PopupMenu
      TabOrder = 0
    end
  end
  object ActionList1: TActionList
    Left = 220
    Top = 65
    object actNew: TAction
      Caption = 'Новый'
      ShortCut = 45
      OnExecute = actNewExecute
    end
    object actDelete: TAction
      Caption = 'Удалить'
      ShortCut = 46
      OnExecute = actDeleteExecute
      OnUpdate = actDeleteUpdate
    end
  end
  object PopupMenu: TPopupMenu
    Left = 120
    Top = 65
    object N1: TMenuItem
      Action = actNew
    end
    object N2: TMenuItem
      Action = actDelete
    end
  end
end
