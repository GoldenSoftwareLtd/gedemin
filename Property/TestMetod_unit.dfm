object Form1: TForm1
  Left = 314
  Top = 221
  BorderStyle = bsDialog
  Caption = 'Form1'
  ClientHeight = 174
  ClientWidth = 314
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 8
    Width = 32
    Height = 13
    Caption = 'Метод'
  end
  object Label2: TLabel
    Left = 16
    Top = 48
    Width = 59
    Height = 13
    Caption = 'Параметры'
  end
  object Label3: TLabel
    Left = 16
    Top = 88
    Width = 65
    Height = 13
    Caption = 'Тип функции'
  end
  object Label4: TLabel
    Left = 184
    Top = 8
    Width = 37
    Height = 13
    Caption = 'Список'
  end
  object Button1: TButton
    Left = 232
    Top = 136
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Edit1: TEdit
    Left = 16
    Top = 24
    Width = 161
    Height = 21
    TabOrder = 1
    Text = 'Sum'
  end
  object Edit2: TEdit
    Left = 16
    Top = 64
    Width = 161
    Height = 21
    TabOrder = 2
    Text = 'A: Integer; out B: Integer'
  end
  object Edit3: TEdit
    Left = 16
    Top = 104
    Width = 161
    Height = 21
    TabOrder = 3
  end
  object ListBox1: TListBox
    Left = 184
    Top = 24
    Width = 121
    Height = 100
    ItemHeight = 13
    TabOrder = 4
  end
end
