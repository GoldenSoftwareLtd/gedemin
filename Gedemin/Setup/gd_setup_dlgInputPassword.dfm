object dlgInputPassword: TdlgInputPassword
  Left = 275
  Top = 267
  BorderStyle = bsDialog
  Caption = 'Введите пароль'
  ClientHeight = 134
  ClientWidth = 363
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnActivate = FormActivate
  OnDeactivate = FormDeactivate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 85
    Width = 122
    Height = 13
    Caption = 'Пользователь: SYSDBA'
  end
  object Label2: TLabel
    Left = 8
    Top = 109
    Width = 41
    Height = 13
    Caption = 'Пароль:'
  end
  object lbKL: TLabel
    Left = 322
    Top = 112
    Width = 3
    Height = 13
    Color = clActiveCaption
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object btnOk: TButton
    Left = 280
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Готово'
    Default = True
    Enabled = False
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 280
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Выход'
    TabOrder = 2
    OnClick = btnCancelClick
  end
  object edPassword: TEdit
    Left = 88
    Top = 104
    Width = 121
    Height = 21
    PasswordChar = '*'
    TabOrder = 0
    OnChange = edPasswordChange
  end
  object Memo: TMemo
    Left = 8
    Top = 8
    Width = 265
    Height = 69
    TabStop = False
    BorderStyle = bsNone
    Color = clBtnFace
    Lines.Strings = (
      'На компьютере обнаружен Interbase сервер.'
      'Для установки базы данных комплекса Gedemin'
      'необходимо подключиться к серверу.'
      ''
      'Введите пароль для администратора:')
    ReadOnly = True
    TabOrder = 3
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 500
    OnTimer = Timer1Timer
    Left = 266
    Top = 105
  end
end
