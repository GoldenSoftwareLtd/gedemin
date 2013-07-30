object gsDBSqueeze_MainForm: TgsDBSqueeze_MainForm
  Left = 7
  Top = 202
  BorderStyle = bsDialog
  ClientHeight = 432
  ClientWidth = 814
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
  object pnl1: TPanel
    Left = 416
    Top = 16
    Width = 384
    Height = 404
    TabOrder = 0
    object lbl7: TLabel
      Left = 7
      Top = 1
      Width = 84
      Height = 13
      Caption = 'Ход выполнения'
    end
  end
  object grpOptions: TGroupBox
    Left = 8
    Top = 177
    Width = 393
    Height = 152
    Caption = ' Options '
    DragMode = dmAutomatic
    TabOrder = 3
    object lbl5: TLabel
      Left = 20
      Top = 23
      Width = 183
      Height = 13
      Caption = 'Удалить записи из gd_document до:'
    end
    object lbl6: TLabel
      Left = 21
      Top = 46
      Width = 183
      Height = 13
      Caption = 'Рассчитать и сохранить сальдо по: '
    end
    object dtpClosingDate: TDateTimePicker
      Left = 212
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
      Left = 56
      Top = 111
      Width = 241
      Height = 21
      Enabled = False
      ItemHeight = 13
      TabOrder = 3
    end
    object rbAllOurCompanies: TRadioButton
      Left = 37
      Top = 63
      Width = 225
      Height = 17
      Caption = 'всем рабочим организациям'
      TabOrder = 1
    end
    object rbCompany: TRadioButton
      Left = 38
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
    Width = 393
    Height = 134
    BiDiMode = bdLeftToRight
    Caption = ' Database Connection '
    ParentBiDiMode = False
    TabOrder = 1
    object lbl1: TLabel
      Left = 21
      Top = 45
      Width = 71
      Height = 13
      Caption = 'Database Path'
    end
    object lbl2: TLabel
      Left = 70
      Top = 70
      Width = 22
      Height = 13
      Caption = 'User'
    end
    object lbl3: TLabel
      Left = 200
      Top = 70
      Width = 46
      Height = 13
      Caption = 'Password'
    end
    object edDatabaseName: TEdit
      Left = 100
      Top = 43
      Width = 253
      Height = 21
      TabOrder = 2
      Text = 'C:\_AKSAMIT2.fdb'
    end
    object edUserName: TEdit
      Left = 99
      Top = 67
      Width = 88
      Height = 21
      TabOrder = 4
      Text = 'SYSDBA'
    end
    object edPassword: TEdit
      Left = 254
      Top = 67
      Width = 99
      Height = 21
      PasswordChar = '*'
      TabOrder = 5
      Text = 'masterkey'
    end
    object btnConnect: TButton
      Left = 191
      Top = 99
      Width = 75
      Height = 21
      Action = actConnect
      TabOrder = 6
    end
    object btnDisconnect: TButton
      Left = 277
      Top = 99
      Width = 75
      Height = 21
      Action = actDisconnect
      TabOrder = 7
    end
    object edServer: TEdit
      Left = 100
      Top = 19
      Width = 89
      Height = 21
      Enabled = False
      TabOrder = 0
      Text = 'India/3053'
    end
    object chbServer: TCheckBox
      Left = 10
      Top = 21
      Width = 87
      Height = 17
      Action = actServer
      Caption = 'Server (IPv4)'
      TabOrder = 1
    end
    object btnDatabaseBrowse: TButton
      Left = 361
      Top = 43
      Width = 20
      Height = 20
      Action = actDatabaseBrowse
      Caption = '...'
      TabOrder = 3
    end
  end
  object btnGo: TButton
    Left = 164
    Top = 362
    Width = 75
    Height = 21
    Action = actGo
    Caption = 'Go!'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 4
  end
  object mLog: TMemo
    Left = 419
    Top = 32
    Width = 377
    Height = 384
    ScrollBars = ssVertical
    TabOrder = 2
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
    object actDatabaseBrowse: TAction
      Caption = 'actDatabaseBrowse'
      OnExecute = actDatabaseBrowseExecute
    end
  end
end
