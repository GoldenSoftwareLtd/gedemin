object gd_dlgDeleteDesktop: Tgd_dlgDeleteDesktop
  Left = 334
  Top = 285
  BorderStyle = bsDialog
  Caption = 'Удаление рабочего стола'
  ClientHeight = 202
  ClientWidth = 282
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 121
    Height = 13
    Caption = '&Список рабочих столов:'
    FocusControl = lb
  end
  object lb: TListBox
    Left = 8
    Top = 24
    Width = 265
    Height = 137
    ItemHeight = 13
    Sorted = True
    TabOrder = 0
  end
  object btnDelete: TButton
    Left = 59
    Top = 172
    Width = 75
    Height = 21
    Action = actDelete
    Caption = '&Удалить'
    TabOrder = 1
  end
  object btnClose: TButton
    Left = 147
    Top = 172
    Width = 75
    Height = 21
    Cancel = True
    Caption = '&Закрыть'
    Default = True
    TabOrder = 2
    OnClick = btnCloseClick
  end
  object ActionList: TActionList
    Left = 240
    Top = 168
    object actDelete: TAction
      Caption = 'Удалить'
      OnExecute = actDeleteExecute
      OnUpdate = actDeleteUpdate
    end
  end
end
