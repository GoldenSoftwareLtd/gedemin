object gsDatabaseShutdown_dlgShowUsers: TgsDatabaseShutdown_dlgShowUsers
  Left = 267
  Top = 187
  BorderStyle = bsDialog
  Caption = 'Перевод в однопользовательский режим'
  ClientHeight = 233
  ClientWidth = 375
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
    Left = 8
    Top = 8
    Width = 68
    Height = 13
    Caption = 'База данных:'
  end
  object Label2: TLabel
    Left = 8
    Top = 56
    Width = 197
    Height = 13
    Caption = 'Список подключенных пользователей:'
  end
  object mUsers: TMemo
    Left = 8
    Top = 72
    Width = 265
    Height = 153
    TabStop = False
    Lines.Strings = (
      '')
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object btnOk: TButton
    Left = 288
    Top = 24
    Width = 75
    Height = 21
    Caption = 'Перевести'
    Default = True
    TabOrder = 1
    OnClick = btnOkClick
  end
  object edDatabaseName: TEdit
    Left = 8
    Top = 24
    Width = 265
    Height = 21
    TabStop = False
    ReadOnly = True
    TabOrder = 4
  end
  object btnCancel: TButton
    Left = 288
    Top = 56
    Width = 75
    Height = 21
    Caption = 'Отмена'
    TabOrder = 2
    OnClick = btnCancelClick
  end
  object btnHelp: TButton
    Left = 288
    Top = 112
    Width = 75
    Height = 21
    Caption = 'Справка'
    TabOrder = 3
  end
  object Timer: TTimer
    Enabled = False
    OnTimer = TimerTimer
    Left = 288
    Top = 144
  end
end
