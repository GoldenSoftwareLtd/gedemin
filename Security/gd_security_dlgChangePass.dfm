object dlgChangePass: TdlgChangePass
  Left = 256
  Top = 219
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Пароль пользователя'
  ClientHeight = 127
  ClientWidth = 223
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
  object lblUse: TLabel
    Left = 8
    Top = 33
    Width = 41
    Height = 13
    Caption = 'Пароль:'
    FocusControl = edPassword
  end
  object Label1: TLabel
    Left = 8
    Top = 9
    Width = 76
    Height = 13
    Caption = 'По&льзователь:'
    FocusControl = edPassword
  end
  object Label2: TLabel
    Left = 8
    Top = 57
    Width = 81
    Height = 26
    Caption = 'Подтверждение пароля:'
    FocusControl = edPasswordDouble
    WordWrap = True
  end
  object lblUser: TLabel
    Left = 96
    Top = 9
    Width = 79
    Height = 13
    Caption = 'Администратор'
    FocusControl = edPassword
  end
  object edPassword: TEdit
    Left = 96
    Top = 30
    Width = 121
    Height = 21
    Ctl3D = True
    ParentCtl3D = False
    PasswordChar = '*'
    TabOrder = 0
  end
  object edPasswordDouble: TEdit
    Left = 96
    Top = 54
    Width = 121
    Height = 21
    Ctl3D = True
    ParentCtl3D = False
    PasswordChar = '*'
    TabOrder = 1
  end
  object btnOk: TButton
    Left = 58
    Top = 98
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 142
    Top = 98
    Width = 75
    Height = 25
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 3
  end
end
