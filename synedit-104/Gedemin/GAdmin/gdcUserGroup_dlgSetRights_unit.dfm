object gdcUserGroup_dlgSetRights: TgdcUserGroup_dlgSetRights
  Left = 447
  Top = 394
  BorderStyle = bsDialog
  Caption = 'Настройка прав группы пользователей'
  ClientHeight = 327
  ClientWidth = 323
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
  object Label1: TLabel
    Left = 8
    Top = 14
    Width = 143
    Height = 13
    Caption = 'Для группы пользователей:'
  end
  object lblGroupName: TLabel
    Left = 158
    Top = 14
    Width = 67
    Height = 13
    Caption = 'lblGroupName'
  end
  object Panel1: TPanel
    Left = 8
    Top = 189
    Width = 305
    Height = 100
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 4
    object Label2: TLabel
      Left = 14
      Top = 54
      Width = 161
      Height = 13
      Caption = 'Список таблиц (через запятую):'
    end
    object edTables: TEdit
      Left = 13
      Top = 70
      Width = 281
      Height = 21
      TabOrder = 0
      Text = 'gd_contact, gd_good'
    end
  end
  object rgCommand: TRadioGroup
    Left = 8
    Top = 40
    Width = 305
    Height = 41
    Caption = ' Доступ к бизнес-классам и командам Исследователя '
    Columns = 3
    ItemIndex = 2
    Items.Strings = (
      'Открыть'
      'Закрыть'
      'Не изменять')
    TabOrder = 0
  end
  object rgTable: TRadioGroup
    Left = 8
    Top = 88
    Width = 305
    Height = 41
    Caption = ' Доступ к таблицам и полям '
    Columns = 3
    ItemIndex = 2
    Items.Strings = (
      'Открыть'
      'Закрыть'
      'Не изменять')
    TabOrder = 1
  end
  object rgDoc: TRadioGroup
    Left = 8
    Top = 136
    Width = 305
    Height = 41
    Caption = ' Доступ к документам '
    Columns = 3
    ItemIndex = 2
    Items.Strings = (
      'Открыть'
      'Закрыть'
      'Не изменять')
    TabOrder = 2
  end
  object Button1: TButton
    Left = 158
    Top = 297
    Width = 75
    Height = 21
    Action = actOk
    Default = True
    TabOrder = 5
  end
  object Button2: TButton
    Left = 238
    Top = 297
    Width = 75
    Height = 21
    Action = actCancel
    TabOrder = 6
  end
  object rgObjects: TRadioGroup
    Left = 21
    Top = 196
    Width = 281
    Height = 41
    Caption = ' Доступ к прочим объектам '
    Columns = 3
    ItemIndex = 2
    Items.Strings = (
      'Открыть'
      'Закрыть'
      'Не изменять')
    TabOrder = 3
  end
  object ActionList: TActionList
    Left = 40
    Top = 296
    object actOk: TAction
      Caption = 'Выполнить'
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Caption = 'Закрыть'
      OnExecute = actCancelExecute
    end
  end
end
