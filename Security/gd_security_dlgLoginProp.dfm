object dlgSecLoginProp: TdlgSecLoginProp
  Left = 259
  Top = 142
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Параметры подключения к базе данных'
  ClientHeight = 269
  ClientWidth = 359
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object lSubSystem: TLabel
    Left = 10
    Top = 5
    Width = 105
    Height = 13
    Caption = 'Подсистема: (%d) %s'
  end
  object lUser: TLabel
    Left = 10
    Top = 23
    Width = 115
    Height = 13
    Caption = 'Пользователь: (%d) %s'
  end
  object lGroups: TLabel
    Left = 10
    Top = 41
    Width = 56
    Height = 13
    Caption = 'Группы: %s'
  end
  object lSession: TLabel
    Left = 10
    Top = 59
    Width = 57
    Height = 13
    Caption = 'Сессия: %d'
  end
  object lStartWork: TLabel
    Left = 10
    Top = 77
    Width = 223
    Height = 13
    Caption = 'Начало работы: %s, продолжительность: %s'
  end
  object lDBVersion: TLabel
    Left = 10
    Top = 95
    Width = 125
    Height = 13
    Caption = 'Версия базы данных: %s'
  end
  object lParamsInfo: TLabel
    Left = 10
    Top = 114
    Width = 208
    Height = 13
    Caption = 'Параметры подключения к базе данных:'
  end
  object memoDatabaseParams: TMemo
    Left = 10
    Top = 129
    Width = 342
    Height = 105
    Ctl3D = True
    Lines.Strings = (
      'memoDatabaseParams')
    ParentCtl3D = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object Button1: TButton
    Left = 279
    Top = 241
    Width = 75
    Height = 25
    Caption = 'Готово'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
end
