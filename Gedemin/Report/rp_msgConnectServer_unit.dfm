object msgConnectServer: TmsgConnectServer
  Left = 322
  Top = 254
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'Сервер отчетов'
  ClientHeight = 86
  ClientWidth = 226
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 64
    Top = 8
    Width = 161
    Height = 73
    Caption = 'Идет процесс подключения к серверу отчетов %s'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    WordWrap = True
  end
  object Animate1: TAnimate
    Left = 8
    Top = 8
    Width = 48
    Height = 45
    Active = False
    CommonAVI = aviFindComputer
    StopFrame = 8
  end
end
