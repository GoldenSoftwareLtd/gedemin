object Form1: TForm1
  Left = 232
  Top = 194
  Width = 696
  Height = 480
  Caption = 'Gedemin Regression Tests'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  PixelsPerInch = 96
  TextHeight = 13
  object CheckBox1: TCheckBox
    Left = 16
    Top = 16
    Width = 193
    Height = 17
    Caption = 'Тэсціраваньне разбору SQL'
    TabOrder = 0
  end
  object Button1: TButton
    Left = 16
    Top = 392
    Width = 75
    Height = 25
    Caption = 'Пачаць'
    Default = True
    TabOrder = 1
    OnClick = Button1Click
  end
  object mLog: TMemo
    Left = 264
    Top = 24
    Width = 345
    Height = 385
    Lines.Strings = (
      'mLog')
    ScrollBars = ssVertical
    TabOrder = 2
  end
end
