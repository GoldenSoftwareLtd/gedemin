object dlgServerConnectOptions: TdlgServerConnectOptions
  Left = 279
  Top = 228
  BorderStyle = bsDialog
  Caption = 'Параметры подключения сервера'
  ClientHeight = 119
  ClientWidth = 286
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 11
    Width = 76
    Height = 13
    Caption = 'Пользователь:'
  end
  object Label2: TLabel
    Left = 16
    Top = 35
    Width = 41
    Height = 13
    Caption = 'Пароля:'
  end
  object Label3: TLabel
    Left = 16
    Top = 59
    Width = 123
    Height = 13
    Caption = 'Подтверждение пароля:'
  end
  object edUser: TEdit
    Left = 152
    Top = 8
    Width = 129
    Height = 21
    TabOrder = 0
  end
  object edPass: TEdit
    Left = 152
    Top = 32
    Width = 129
    Height = 21
    PasswordChar = '*'
    TabOrder = 1
  end
  object edConPass: TEdit
    Left = 152
    Top = 56
    Width = 129
    Height = 21
    PasswordChar = '*'
    TabOrder = 2
  end
  object btnOk: TButton
    Left = 128
    Top = 88
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 3
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 208
    Top = 88
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 4
  end
end
