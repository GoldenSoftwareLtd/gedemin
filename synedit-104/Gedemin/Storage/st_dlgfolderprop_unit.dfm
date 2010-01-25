object st_dlgfolderprop: Tst_dlgfolderprop
  Left = 417
  Top = 238
  BorderStyle = bsDialog
  Caption = 'Папка'
  ClientHeight = 188
  ClientWidth = 327
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel5: TBevel
    Left = 8
    Top = 14
    Width = 314
    Height = 9
    Shape = bsTopLine
  end
  object Label1: TLabel
    Left = 8
    Top = 20
    Width = 79
    Height = 13
    Caption = 'Наименование:'
  end
  object Label2: TLabel
    Left = 8
    Top = 48
    Width = 69
    Height = 13
    Caption = 'Размещение:'
  end
  object Bevel2: TBevel
    Left = 8
    Top = 147
    Width = 314
    Height = 9
    Shape = bsTopLine
  end
  object Bevel3: TBevel
    Left = 8
    Top = 40
    Width = 314
    Height = 9
    Shape = bsTopLine
  end
  object Label6: TLabel
    Left = 8
    Top = 89
    Width = 68
    Height = 13
    Caption = 'Переменных:'
  end
  object Label7: TLabel
    Left = 8
    Top = 110
    Width = 82
    Height = 13
    Caption = 'Размер данных:'
  end
  object Label8: TLabel
    Left = 8
    Top = 69
    Width = 35
    Height = 13
    Caption = 'Папок:'
  end
  object Bevel4: TBevel
    Left = 87
    Top = 15
    Width = 10
    Height = 132
    Shape = bsRightLine
  end
  object lName: TLabel
    Left = 104
    Top = 20
    Width = 79
    Height = 13
    Caption = 'Наименование:'
  end
  object lFolders: TLabel
    Left = 104
    Top = 69
    Width = 35
    Height = 13
    Caption = 'Папок:'
  end
  object lValues: TLabel
    Left = 104
    Top = 89
    Width = 68
    Height = 13
    Caption = 'Переменных:'
  end
  object lSize: TLabel
    Left = 104
    Top = 110
    Width = 42
    Height = 13
    Caption = 'Размер:'
  end
  object Label3: TLabel
    Left = 8
    Top = 130
    Width = 55
    Height = 13
    Caption = 'Изменено:'
  end
  object lModified: TLabel
    Left = 104
    Top = 130
    Width = 52
    Height = 13
    Caption = 'Изменено'
  end
  object Button1: TButton
    Left = 247
    Top = 160
    Width = 75
    Height = 21
    Caption = 'Закрыть'
    Default = True
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 159
    Top = 160
    Width = 75
    Height = 21
    Caption = 'Справка'
    TabOrder = 1
  end
  object eLocation: TEdit
    Left = 104
    Top = 48
    Width = 217
    Height = 19
    BorderStyle = bsNone
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 2
    Text = 'Размещение'
  end
end
