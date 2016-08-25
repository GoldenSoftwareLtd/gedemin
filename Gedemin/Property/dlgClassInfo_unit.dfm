object dlgClassInfo: TdlgClassInfo
  Left = 381
  Top = 346
  BorderStyle = bsDialog
  Caption = 'Информация о классе'
  ClientHeight = 159
  ClientWidth = 400
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 64
    Height = 13
    Caption = 'Имя класса:'
  end
  object Label2: TLabel
    Left = 16
    Top = 36
    Width = 40
    Height = 13
    Caption = 'Подтип:'
  end
  object Label3: TLabel
    Left = 16
    Top = 56
    Width = 108
    Height = 13
    Caption = 'Родительский класс:'
  end
  object Label4: TLabel
    Left = 16
    Top = 76
    Width = 89
    Height = 13
    Caption = 'Главная таблица:'
  end
  object Label5: TLabel
    Left = 16
    Top = 96
    Width = 53
    Height = 13
    Caption = 'Название:'
  end
  object lblClassName: TLabel
    Left = 128
    Top = 16
    Width = 3
    Height = 13
  end
  object lblSubType: TLabel
    Left = 128
    Top = 36
    Width = 3
    Height = 13
  end
  object lblParentClass: TLabel
    Left = 128
    Top = 56
    Width = 3
    Height = 13
  end
  object lblMainTable: TLabel
    Left = 128
    Top = 76
    Width = 3
    Height = 13
  end
  object lblName: TLabel
    Left = 128
    Top = 96
    Width = 3
    Height = 13
  end
  object Bevel1: TBevel
    Left = 8
    Top = 8
    Width = 385
    Height = 113
    Shape = bsFrame
  end
  object btnOk: TButton
    Left = 317
    Top = 128
    Width = 75
    Height = 21
    Cancel = True
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object btnCreate: TButton
    Left = 8
    Top = 128
    Width = 75
    Height = 21
    Caption = 'Создать'
    ModalResult = 6
    TabOrder = 1
  end
end
