object Form1: TForm1
  Left = 323
  Top = 222
  Width = 918
  Height = 259
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object SpeedButton1: TSpeedButton
    Left = 384
    Top = 40
    Width = 23
    Height = 22
    OnClick = SpeedButton1Click
  end
  object Label1: TLabel
    Left = 112
    Top = 104
    Width = 32
    Height = 13
    Caption = 'Label1'
  end
  object Label2: TLabel
    Left = 112
    Top = 120
    Width = 32
    Height = 13
    Caption = 'Label2'
  end
  object gsPeriodEdit: TgsPeriodEdit
    Left = 40
    Top = 40
    Width = 148
    Height = 21
    TabOrder = 0
    OnChange = gsPeriodEditChange
  end
  object Edit1: TEdit
    Left = 216
    Top = 40
    Width = 121
    Height = 21
    TabOrder = 1
    Text = 'Edit1'
  end
end
