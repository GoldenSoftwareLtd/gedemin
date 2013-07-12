object gsDBSqueeze_MainForm: TgsDBSqueeze_MainForm
  Left = 475
  Top = 130
  BorderStyle = bsDialog
  ClientHeight = 448
  ClientWidth = 698
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object lbl4: TLabel
    Left = 311
    Top = 15
    Width = 71
    Height = 13
    Caption = 'Выполняется:'
  end
  object grpOptions: TGroupBox
    Left = 8
    Top = 200
    Width = 293
    Height = 169
    Caption = ' Options '
    DragMode = dmAutomatic
    TabOrder = 2
    object lbl5: TLabel
      Left = 10
      Top = 23
      Width = 183
      Height = 13
      Caption = 'Удалить записи из gd_document до:'
    end
    object lbl6: TLabel
      Left = 11
      Top = 46
      Width = 183
      Height = 13
      Caption = 'Рассчитать и сохранить сальдо по: '
    end
    object dtpClosingDate: TDateTimePicker
      Left = 197
      Top = 20
      Width = 86
      Height = 21
      Hint = 'рассчитать сальдо и удалить документы'
      CalAlignment = dtaLeft
      Date = 41380.5593590046
      Time = 41380.5593590046
      Color = clWhite
      DateFormat = dfShort
      DateMode = dmComboBox
      Kind = dtkDate
      ParseInput = False
      TabOrder = 0
    end
    object cbbCompany: TComboBox
      Left = 35
      Top = 111
      Width = 248
      Height = 21
      Enabled = False
      ItemHeight = 13
      TabOrder = 3
    end
    object rbAllOurCompanies: TRadioButton
      Left = 17
      Top = 63
      Width = 225
      Height = 17
      Caption = 'всем рабочим организациям'
      TabOrder = 1
    end
    object rbCompany: TRadioButton
      Left = 17
      Top = 87
      Width = 225
      Height = 17
      Action = actCompany
      Caption = 'рабочей организации'
      TabOrder = 2
    end
  end
  object grpDatabase: TGroupBox
    Left = 8
    Top = 19
    Width = 293
    Height = 167
    BiDiMode = bdLeftToRight
    Caption = ' Database '
    ParentBiDiMode = False
    TabOrder = 0
    object lbl1: TLabel
      Left = 10
      Top = 45
      Width = 75
      Height = 13
      Caption = 'Database path:'
    end
    object lbl2: TLabel
      Left = 10
      Top = 102
      Width = 26
      Height = 13
      Caption = 'User:'
    end
    object lbl3: TLabel
      Left = 139
      Top = 102
      Width = 50
      Height = 13
      Caption = 'Password:'
    end
    object edDatabaseName: TEdit
      Left = 10
      Top = 67
      Width = 272
      Height = 21
      TabOrder = 2
      Text = 'C:\_AKSAMIT2.fdb'
    end
    object edUserName: TEdit
      Left = 40
      Top = 99
      Width = 88
      Height = 21
      TabOrder = 3
      Text = 'SYSDBA'
    end
    object edPassword: TEdit
      Left = 194
      Top = 99
      Width = 88
      Height = 21
      PasswordChar = '*'
      TabOrder = 4
      Text = 'masterkey'
    end
    object btnConnect: TButton
      Left = 119
      Top = 131
      Width = 75
      Height = 21
      Action = actConnect
      TabOrder = 5
    end
    object btnDisconnect: TButton
      Left = 206
      Top = 131
      Width = 75
      Height = 21
      Action = actDisconnect
      TabOrder = 6
    end
    object edServer: TEdit
      Left = 88
      Top = 19
      Width = 88
      Height = 21
      Enabled = False
      TabOrder = 0
      Text = 'India/3053'
    end
    object chbServer: TCheckBox
      Left = 10
      Top = 21
      Width = 56
      Height = 17
      Action = actServer
      Caption = 'Server'
      TabOrder = 1
    end
  end
  object btnGo: TButton
    Left = 116
    Top = 382
    Width = 75
    Height = 21
    Action = actGo
    Caption = 'Go!'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
  end
  object mLog: TMemo
    Left = 310
    Top = 32
    Width = 377
    Height = 384
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object ActionList: TActionList
    Left = 269
    Top = 382
    object actConnect: TAction
      Caption = 'Connect'
      OnExecute = actConnectExecute
      OnUpdate = actConnectUpdate
    end
    object actGo: TAction
      Caption = 'actGo'
      OnExecute = actGoExecute
      OnUpdate = actGoUpdate
    end
    object actDisconnect: TAction
      Caption = 'Disconnect'
      OnExecute = actDisconnectExecute
      OnUpdate = actDisconnectUpdate
    end
    object actCompany: TAction
      Caption = 'actCompany'
      OnExecute = actCompanyExecute
      OnUpdate = actCompanyUpdate
    end
    object actServer: TAction
      Caption = 'actServer'
      OnExecute = actServerExecute
      OnUpdate = actServerUpdate
    end
  end
end
