object PopupWindow: TPopupWindow
  Left = 435
  Top = 226
  BorderStyle = bsNone
  Caption = 'PopupWindow'
  ClientHeight = 13
  ClientWidth = 104
  Color = clInfoBk
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lMessage: TLabel
    Left = 0
    Top = 0
    Width = 104
    Height = 13
    Align = alClient
    Caption = 'lMessage'
    Layout = tlCenter
  end
  object Timer: TTimer
    Interval = 100
    OnTimer = TimerTimer
    Left = 144
    Top = 16
  end
end
