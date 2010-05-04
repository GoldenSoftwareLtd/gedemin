object frmMain: TfrmMain
  Left = 235
  Top = 159
  BorderStyle = bsDialog
  Caption = 'Апгрэйд базы дадзеных'
  ClientHeight = 433
  ClientWidth = 546
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel2: TBevel
    Left = 5
    Top = 10
    Width = 139
    Height = 119
    Shape = bsFrame
  end
  object Bevel1: TBevel
    Left = 152
    Top = 10
    Width = 306
    Height = 102
    Shape = bsFrame
  end
  object Label1: TLabel
    Left = 161
    Top = 3
    Width = 205
    Height = 13
    Caption = 'Шлях да архіва з новай базай дадзеных:'
  end
  object Label2: TLabel
    Left = 161
    Top = 43
    Width = 171
    Height = 13
    Caption = 'Шлях да дзеючай базы дадзеных:'
  end
  object Label3: TLabel
    Left = 14
    Top = 44
    Width = 98
    Height = 13
    Caption = 'Імя карыстальніка:'
  end
  object Label4: TLabel
    Left = 14
    Top = 84
    Width = 41
    Height = 13
    Caption = 'Пароль:'
  end
  object Label5: TLabel
    Left = 14
    Top = 4
    Width = 80
    Height = 13
    Caption = 'Назва сэрвера:'
  end
  object Label6: TLabel
    Left = 8
    Top = 136
    Width = 67
    Height = 13
    Caption = 'Ход працэса:'
  end
  object Label7: TLabel
    Left = 162
    Top = 88
    Width = 130
    Height = 13
    Caption = 'Дыялект базы дадзеных:'
  end
  object Label8: TLabel
    Left = 8
    Top = 322
    Width = 47
    Height = 13
    Caption = 'Памылкі:'
  end
  object Button1: TButton
    Left = 464
    Top = 10
    Width = 75
    Height = 25
    Action = actUpgade
    Default = True
    TabOrder = 7
  end
  object Button2: TButton
    Left = 464
    Top = 40
    Width = 75
    Height = 25
    Action = actExit
    TabOrder = 8
  end
  object edSourceArchive: TEdit
    Left = 161
    Top = 19
    Width = 289
    Height = 21
    TabOrder = 3
  end
  object edTargetDatabase: TEdit
    Left = 161
    Top = 59
    Width = 289
    Height = 21
    TabOrder = 4
  end
  object Memo: TMemo
    Left = 4
    Top = 152
    Width = 538
    Height = 169
    TabStop = False
    Lines.Strings = (
      '')
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 9
  end
  object edUserName: TEdit
    Left = 14
    Top = 60
    Width = 121
    Height = 21
    TabOrder = 1
    Text = 'SYSDBA'
  end
  object edPassword: TEdit
    Left = 14
    Top = 100
    Width = 121
    Height = 21
    PasswordChar = '*'
    TabOrder = 2
    Text = 'masterkey'
  end
  object edServerName: TEdit
    Left = 14
    Top = 20
    Width = 121
    Height = 21
    TabStop = False
    TabOrder = 0
  end
  object chbReplication: TCheckBox
    Left = 152
    Top = 115
    Width = 249
    Height = 17
    Caption = 'Переносить данные репликации'
    TabOrder = 6
  end
  object edSQLDialect: TEdit
    Left = 296
    Top = 85
    Width = 25
    Height = 21
    TabOrder = 5
    Text = '3'
  end
  object CheckBox1: TCheckBox
    Left = 152
    Top = 131
    Width = 209
    Height = 17
    Caption = 'Переподключаться к базе'
    Checked = True
    Enabled = False
    State = cbChecked
    TabOrder = 10
  end
  object MemoErr: TMemo
    Left = 4
    Top = 336
    Width = 538
    Height = 92
    TabStop = False
    Lines.Strings = (
      '')
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 11
  end
  object ActionList: TActionList
    Left = 504
    Top = 264
    object actUpgade: TAction
      Caption = 'Абнавіць'
      OnExecute = actUpgadeExecute
    end
    object actExit: TAction
      Caption = 'Выхад'
      OnExecute = actExitExecute
    end
  end
  object boUpgrade: TboDBUpgrade
    SQLDialect = 3
    OnLogRecord = boUpgradeLogRecord
    Left = 416
    Top = 104
  end
end
