object Form1: TForm1
  Left = 377
  Top = 143
  Width = 712
  Height = 819
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object m: TMemo
    Left = 48
    Top = 80
    Width = 345
    Height = 545
    TabOrder = 0
  end
  object Button1: TButton
    Left = 480
    Top = 80
    Width = 75
    Height = 25
    Action = actStart
    TabOrder = 1
  end
  object Button2: TButton
    Left = 480
    Top = 120
    Width = 75
    Height = 25
    Action = actStop
    TabOrder = 2
  end
  object ActionList1: TActionList
    Left = 576
    Top = 112
    object actStart: TAction
      Caption = 'Start'
      OnExecute = actStartExecute
      OnUpdate = actStartUpdate
    end
    object actStop: TAction
      Caption = 'Stop'
      OnExecute = actStopExecute
      OnUpdate = actStopUpdate
    end
  end
end
