object dlgSelectDatabase: TdlgSelectDatabase
  Left = 274
  Top = 253
  ActiveControl = eServerName
  BorderStyle = bsDialog
  Caption = 'Путь к базе данных'
  ClientHeight = 121
  ClientWidth = 378
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 0
    Top = 0
    Width = 377
    Height = 89
    Shape = bsFrame
  end
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 226
    Height = 13
    Caption = 'Укажите путь к базе данных и имя сервера:'
  end
  object Label2: TLabel
    Left = 8
    Top = 34
    Width = 40
    Height = 13
    Caption = 'Сервер:'
  end
  object Label3: TLabel
    Left = 8
    Top = 58
    Width = 55
    Height = 13
    Caption = 'Путь к БД:'
  end
  object btnOk: TButton
    Left = 208
    Top = 96
    Width = 77
    Height = 21
    Caption = 'OK'
    Default = True
    TabOrder = 3
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 288
    Top = 96
    Width = 77
    Height = 21
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 4
  end
  object eFileName: TEdit
    Left = 72
    Top = 56
    Width = 271
    Height = 21
    AutoSelect = False
    TabOrder = 1
  end
  object btnSelect: TButton
    Left = 344
    Top = 56
    Width = 21
    Height = 20
    Caption = '...'
    TabOrder = 2
    OnClick = btnSelectClick
  end
  object eServerName: TEdit
    Left = 72
    Top = 32
    Width = 113
    Height = 21
    TabOrder = 0
  end
end
