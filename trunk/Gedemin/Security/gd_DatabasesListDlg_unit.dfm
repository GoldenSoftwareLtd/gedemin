object gd_DatabasesListDlg: Tgd_DatabasesListDlg
  Left = 776
  Top = 370
  BorderStyle = bsDialog
  Caption = 'gd_DatabasesListDlg'
  ClientHeight = 205
  ClientWidth = 394
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 79
    Height = 13
    Caption = 'Наименование:'
  end
  object Label2: TLabel
    Left = 16
    Top = 44
    Width = 40
    Height = 13
    Caption = 'Сервер:'
  end
  object Label4: TLabel
    Left = 16
    Top = 72
    Width = 60
    Height = 13
    Caption = 'Имя файла:'
  end
  object Label5: TLabel
    Left = 16
    Top = 96
    Width = 132
    Height = 13
    Caption = 'Параметры подключения:'
  end
  object edName: TEdit
    Left = 104
    Top = 13
    Width = 281
    Height = 21
    TabOrder = 0
    Text = 'edName'
  end
  object edServer: TEdit
    Left = 104
    Top = 40
    Width = 121
    Height = 21
    TabOrder = 1
    Text = 'edServer'
  end
  object edFileName: TEdit
    Left = 104
    Top = 64
    Width = 249
    Height = 21
    TabOrder = 2
    Text = 'edFileName'
  end
  object Button1: TButton
    Left = 224
    Top = 160
    Width = 75
    Height = 21
    Caption = 'Ok'
    ModalResult = 1
    TabOrder = 3
  end
  object Button2: TButton
    Left = 304
    Top = 160
    Width = 75
    Height = 21
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 4
  end
  object edDBParams: TEdit
    Left = 104
    Top = 112
    Width = 281
    Height = 21
    TabOrder = 5
    Text = 'edDBParams'
  end
  object Button3: TButton
    Left = 360
    Top = 64
    Width = 21
    Height = 21
    Caption = '...'
    TabOrder = 6
  end
end
