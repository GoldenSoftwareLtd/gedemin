object msgShowMessage: TmsgShowMessage
  Left = 463
  Top = 324
  BorderStyle = bsDialog
  Caption = 'Внимание'
  ClientHeight = 87
  ClientWidth = 191
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 64
    Width = 146
    Height = 13
    Caption = 'Идет процесс фильтрации...'
  end
  object Animate1: TAnimate
    Left = 56
    Top = 8
    Width = 80
    Height = 50
    Active = True
    CommonAVI = aviFindFolder
    StopFrame = 29
  end
end
