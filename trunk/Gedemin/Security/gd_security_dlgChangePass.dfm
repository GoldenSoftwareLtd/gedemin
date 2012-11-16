object dlgChangePass: TdlgChangePass
  Left = 392
  Top = 294
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Пароль пользователя'
  ClientHeight = 138
  ClientWidth = 295
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lblUse: TLabel
    Left = 16
    Top = 61
    Width = 41
    Height = 13
    Caption = 'Пароль:'
    FocusControl = edPassword
  end
  object lblMsg: TLabel
    Left = 16
    Top = 14
    Width = 273
    Height = 35
    AutoSize = False
    Caption = 'Необходимо ввести новый пароль для пользователя %user%.'
    FocusControl = edPassword
    WordWrap = True
  end
  object Label2: TLabel
    Left = 16
    Top = 85
    Width = 129
    Height = 16
    Caption = 'Подтверждение пароля:'
    FocusControl = edPasswordDouble
    WordWrap = True
  end
  object edPassword: TEdit
    Left = 160
    Top = 58
    Width = 121
    Height = 21
    Ctl3D = True
    ParentCtl3D = False
    PasswordChar = '*'
    TabOrder = 0
  end
  object edPasswordDouble: TEdit
    Left = 160
    Top = 82
    Width = 121
    Height = 21
    Ctl3D = True
    ParentCtl3D = False
    PasswordChar = '*'
    TabOrder = 1
  end
  object btnOk: TButton
    Left = 124
    Top = 110
    Width = 75
    Height = 21
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 206
    Top = 110
    Width = 75
    Height = 21
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 3
  end
end
