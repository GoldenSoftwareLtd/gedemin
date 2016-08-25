object frmProgress: TfrmProgress
  Left = 314
  Top = 283
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Удаление'
  ClientHeight = 47
  ClientWidth = 327
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 312
    Height = 13
    Caption = 'Выполняется удаление программного комплекса Гедымин...'
  end
  object ProgressBar: TProgressBar
    Left = 8
    Top = 24
    Width = 313
    Height = 16
    Min = 0
    Max = 100
    TabOrder = 0
  end
end
