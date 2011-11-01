object Form1: TForm1
  Left = 419
  Top = 177
  BorderStyle = bsDialog
  Caption = 'Поиск и замена'
  ClientHeight = 375
  ClientWidth = 394
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
  object Label1: TLabel
    Left = 16
    Top = 24
    Width = 162
    Height = 13
    Caption = 'Искать и заменить в файле(ах):'
  end
  object Label2: TLabel
    Left = 16
    Top = 128
    Width = 82
    Height = 13
    Caption = 'Искомый текст:'
  end
  object Label3: TLabel
    Left = 16
    Top = 168
    Width = 68
    Height = 13
    Caption = 'Заменить на:'
  end
  object Label4: TLabel
    Left = 16
    Top = 213
    Width = 265
    Height = 13
    Caption = 'Только, если перед искомым текстом встречается:'
  end
  object Label5: TLabel
    Left = 16
    Top = 253
    Width = 280
    Height = 13
    Caption = 'Только, если перед искомым текстом не встречается:'
  end
  object Label6: TLabel
    Left = 151
    Top = 272
    Width = 18
    Height = 13
    Caption = 'или'
  end
  object Label7: TLabel
    Left = 16
    Top = 296
    Width = 269
    Height = 13
    Caption = 'Только, если в Н предыдущих строк не встречается:'
  end
  object Label8: TLabel
    Left = 16
    Top = 315
    Width = 11
    Height = 13
    Caption = 'Н:'
  end
  object Label9: TLabel
    Left = 104
    Top = 315
    Width = 33
    Height = 13
    Caption = 'Текст:'
  end
  object Label10: TLabel
    Left = 16
    Top = 88
    Width = 129
    Height = 13
    Caption = 'Не обрабатывать файлы:'
  end
  object Label11: TLabel
    Left = 16
    Top = 336
    Width = 276
    Height = 13
    Caption = 'Только, если после искомого текста не встречается::'
  end
  object Button1: TButton
    Left = 312
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Начать'
    Default = True
    TabOrder = 11
    OnClick = Button1Click
  end
  object chbxSubFolders: TCheckBox
    Left = 16
    Top = 64
    Width = 225
    Height = 17
    Caption = 'Обрабатывать подкаталоги'
    TabOrder = 1
  end
  object edFile: TEdit
    Left = 16
    Top = 40
    Width = 281
    Height = 21
    TabOrder = 0
  end
  object edWhat: TEdit
    Left = 16
    Top = 144
    Width = 281
    Height = 21
    TabOrder = 3
  end
  object edFor: TEdit
    Left = 16
    Top = 184
    Width = 281
    Height = 21
    TabOrder = 4
  end
  object Button2: TButton
    Left = 312
    Top = 72
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Закрыть'
    TabOrder = 12
    OnClick = Button2Click
  end
  object edBefore: TEdit
    Left = 16
    Top = 229
    Width = 281
    Height = 21
    TabOrder = 5
  end
  object edNotBefore: TEdit
    Left = 16
    Top = 269
    Width = 129
    Height = 21
    TabOrder = 6
  end
  object edNotBefore2: TEdit
    Left = 176
    Top = 268
    Width = 121
    Height = 21
    TabOrder = 7
  end
  object edLinesBefore: TEdit
    Left = 32
    Top = 312
    Width = 65
    Height = 21
    TabOrder = 8
  end
  object edNotInLinesBefore: TEdit
    Left = 144
    Top = 312
    Width = 153
    Height = 21
    TabOrder = 9
  end
  object edExcludeFiles: TEdit
    Left = 16
    Top = 104
    Width = 281
    Height = 21
    TabOrder = 2
  end
  object edNotAfter: TEdit
    Left = 16
    Top = 349
    Width = 281
    Height = 21
    TabOrder = 10
  end
end
