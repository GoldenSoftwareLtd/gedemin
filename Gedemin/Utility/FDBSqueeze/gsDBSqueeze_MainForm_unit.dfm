object gsDBSqueeze_MainForm: TgsDBSqueeze_MainForm
  Left = 9
  Top = 35
  BorderStyle = bsDialog
  ClientHeight = 662
  ClientWidth = 1009
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
    Width = 585
    Height = 641
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
    Top = 462
    Width = 393
    Height = 152
    Caption = ' Options '
    DragMode = dmAutomatic
    TabOrder = 4
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
    Top = 627
    Width = 75
    Height = 21
    Action = actGo
    Caption = 'Go!'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 5
  end
  object mLog: TMemo
    Left = 420
    Top = 34
    Width = 575
    Height = 607
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object grpDBProperties: TGroupBox
    Left = 8
    Top = 160
    Width = 393
    Height = 297
    Caption = ' Properties '
    TabOrder = 3
    object txt1: TStaticText
      Left = 32
      Top = 48
      Width = 82
      Height = 17
      BorderStyle = sbsSingle
      Caption = 'DB File Size        '
      Color = clInactiveCaption
      ParentColor = False
      TabOrder = 4
    end
    object txt2: TStaticText
      Left = 32
      Top = 64
      Width = 242
      Height = 17
      Caption = '                 Number of records in a table                 '
      Color = clWhite
      ParentColor = False
      TabOrder = 5
    end
    object txt3: TStaticText
      Left = 32
      Top = 80
      Width = 80
      Height = 17
      BorderStyle = sbsSingle
      Caption = 'GD_DOCUMENT'
      Color = clInactiveCaption
      ParentColor = False
      TabOrder = 6
    end
    object txt4: TStaticText
      Left = 32
      Top = 96
      Width = 80
      Height = 17
      BorderStyle = sbsSingle
      Caption = 'AC_ENTRY        '
      Color = clInactiveCaption
      ParentColor = False
      TabOrder = 10
    end
    object txt5: TStaticText
      Left = 32
      Top = 112
      Width = 82
      Height = 17
      BorderStyle = sbsSingle
      Caption = 'INV_MOVEMENT'
      Color = clInactiveCaption
      ParentColor = False
      TabOrder = 13
    end
    object txt6: TStaticText
      Left = 112
      Top = 80
      Width = 82
      Height = 17
      BorderStyle = sbsSunken
      Caption = '                          '
      TabOrder = 7
    end
    object txt7: TStaticText
      Left = 112
      Top = 96
      Width = 82
      Height = 17
      BorderStyle = sbsSunken
      Caption = '                          '
      TabOrder = 11
    end
    object txt8: TStaticText
      Left = 112
      Top = 112
      Width = 82
      Height = 17
      BorderStyle = sbsSunken
      Caption = '                          '
      TabOrder = 14
    end
    object txt9: TStaticText
      Left = 112
      Top = 47
      Width = 82
      Height = 17
      BorderStyle = sbsSunken
      Caption = '                          '
      TabOrder = 2
    end
    object txt11: TStaticText
      Left = 192
      Top = 24
      Width = 81
      Height = 17
      BorderStyle = sbsSingle
      Caption = 'AFTER               '
      TabOrder = 1
    end
    object txt12: TStaticText
      Left = 192
      Top = 47
      Width = 82
      Height = 17
      BorderStyle = sbsSunken
      Caption = '                          '
      TabOrder = 3
    end
    object txt13: TStaticText
      Left = 192
      Top = 80
      Width = 82
      Height = 17
      BorderStyle = sbsSunken
      Caption = '                          '
      TabOrder = 8
    end
    object txt14: TStaticText
      Left = 192
      Top = 96
      Width = 82
      Height = 17
      BorderStyle = sbsSunken
      Caption = '                          '
      TabOrder = 12
    end
    object txt15: TStaticText
      Left = 192
      Top = 112
      Width = 82
      Height = 17
      BorderStyle = sbsSunken
      Caption = '                          '
      TabOrder = 15
    end
    object txt10: TStaticText
      Left = 112
      Top = 24
      Width = 79
      Height = 17
      BorderStyle = sbsSingle
      Caption = 'BEFORE            '
      TabOrder = 0
    end
    object btnGetStatistics: TButton
      Left = 288
      Top = 80
      Width = 89
      Height = 49
      Action = actGet
      Caption = 'GET STATISTICS'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 9
    end
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
    object actGet: TAction
      Caption = 'actGet'
      OnExecute = actGetExecute
      OnUpdate = actGetUpdate
    end
    object actUpdate: TAction
      Caption = 'actUpdate'
    end
  end
end
