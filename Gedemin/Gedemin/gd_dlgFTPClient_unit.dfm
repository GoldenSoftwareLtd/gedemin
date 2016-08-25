object gd_dlgFTPClient: Tgd_dlgFTPClient
  Left = 581
  Top = 338
  Width = 338
  Height = 384
  Caption = 'gd_dlgFTPClient'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object cbParamsConnect: TGroupBox
    Left = 5
    Top = 4
    Width = 316
    Height = 157
    Caption = 'Параметры соединения'
    TabOrder = 0
    object lServerName: TLabel
      Left = 10
      Top = 16
      Width = 70
      Height = 13
      Caption = 'Имя сервера:'
    end
    object lPort: TLabel
      Left = 10
      Top = 44
      Width = 28
      Height = 13
      Caption = 'Порт:'
    end
    object lUserName: TLabel
      Left = 10
      Top = 68
      Width = 99
      Height = 13
      Caption = 'Имя пользователя:'
    end
    object lPassword: TLabel
      Left = 10
      Top = 92
      Width = 41
      Height = 13
      Caption = 'Пароль:'
    end
    object Label3: TLabel
      Left = 10
      Top = 116
      Width = 40
      Height = 13
      Caption = 'TimeOut'
    end
    object eServerName: TEdit
      Left = 120
      Top = 16
      Width = 185
      Height = 21
      TabOrder = 0
    end
    object eUserName: TEdit
      Left = 120
      Top = 64
      Width = 185
      Height = 21
      TabOrder = 1
    end
    object ePassword: TEdit
      Left = 120
      Top = 88
      Width = 185
      Height = 21
      TabOrder = 2
    end
    object sePort: TSpinEdit
      Left = 216
      Top = 40
      Width = 89
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 3
      Value = 0
    end
    object seTimeOut: TSpinEdit
      Left = 216
      Top = 112
      Width = 89
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 4
      Value = 0
    end
  end
  object GroupBox1: TGroupBox
    Left = 5
    Top = 176
    Width = 316
    Height = 129
    TabOrder = 1
    object Label1: TLabel
      Left = 10
      Top = 20
      Width = 121
      Height = 13
      Caption = 'Локальная директория:'
    end
    object Label2: TLabel
      Left = 10
      Top = 44
      Width = 121
      Height = 13
      Caption = 'Удаленная директория:'
    end
    object Label4: TLabel
      Left = 10
      Top = 68
      Width = 136
      Height = 13
      Caption = 'Интервал опроса сервера:'
    end
    object eLocalPath: TEdit
      Left = 144
      Top = 16
      Width = 161
      Height = 21
      TabOrder = 0
    end
    object eRemotePath: TEdit
      Left = 144
      Top = 40
      Width = 161
      Height = 21
      TabOrder = 1
    end
    object chbxOn: TCheckBox
      Left = 10
      Top = 104
      Width = 153
      Height = 17
      Caption = 'Опрос сервера включен'
      TabOrder = 2
    end
    object seInterval: TSpinEdit
      Left = 216
      Top = 67
      Width = 89
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 3
      Value = 0
    end
  end
  object Button1: TButton
    Left = 158
    Top = 321
    Width = 75
    Height = 21
    Caption = 'Готово'
    Default = True
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 246
    Top = 321
    Width = 75
    Height = 21
    Caption = 'Отмена'
    Default = True
    TabOrder = 3
    OnClick = Button2Click
  end
end
