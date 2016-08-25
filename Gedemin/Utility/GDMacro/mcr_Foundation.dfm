object Form1: TForm1
  Left = 121
  Top = 143
  Width = 544
  Height = 460
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object lblMacroDecl: TLabel
    Left = 8
    Top = 8
    Width = 116
    Height = 13
    Caption = 'Объявление макросов'
  end
  object lbMacroDecl: TListBox
    Left = 8
    Top = 24
    Width = 249
    Height = 217
    ItemHeight = 13
    MultiSelect = True
    TabOrder = 0
  end
  object btSearch: TButton
    Left = 48
    Top = 352
    Width = 169
    Height = 25
    Caption = 'Search declarations'
    TabOrder = 1
    OnClick = btSearchClick
  end
  object gbSeachParams: TGroupBox
    Left = 8
    Top = 248
    Width = 249
    Height = 89
    Caption = 'Параметры поиска'
    TabOrder = 2
    object lbPath: TLabel
      Left = 8
      Top = 32
      Width = 24
      Height = 13
      Caption = 'Путь'
    end
    object lbMask: TLabel
      Left = 8
      Top = 64
      Width = 33
      Height = 13
      Caption = 'Маска'
    end
    object edPath: TEdit
      Left = 56
      Top = 24
      Width = 185
      Height = 21
      TabOrder = 0
      Text = 'D:\Golden\gedemin\Utility'
      OnDblClick = edPathDblClick
    end
    object edMask: TEdit
      Left = 56
      Top = 56
      Width = 185
      Height = 21
      TabOrder = 1
      Text = '*.txt'
    end
  end
  object lbMacroCall: TListBox
    Left = 280
    Top = 24
    Width = 249
    Height = 217
    ItemHeight = 13
    TabOrder = 3
  end
  object btnSearchCall: TButton
    Left = 320
    Top = 352
    Width = 185
    Height = 25
    Caption = 'btnSearchCall'
    TabOrder = 4
    OnClick = btnSearchCallClick
  end
end
