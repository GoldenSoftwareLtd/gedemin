object Form1: TForm1
  Left = 144
  Top = 143
  Width = 517
  Height = 398
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Edit1: TEdit
    Left = 80
    Top = 8
    Width = 121
    Height = 21
    TabOrder = 0
    Text = 'JKL2001'
  end
  object Button2: TButton
    Left = 208
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Connect'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 208
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Disconnect'
    TabOrder = 2
    OnClick = Button3Click
  end
  object PageControl1: TPageControl
    Left = 8
    Top = 128
    Width = 497
    Height = 233
    TabOrder = 3
  end
  object Button1: TButton
    Left = 208
    Top = 72
    Width = 75
    Height = 25
    Caption = 'Запрос'
    TabOrder = 4
    OnClick = Button1Click
  end
  object Button4: TButton
    Left = 288
    Top = 72
    Width = 75
    Height = 25
    Caption = 'Button4'
    TabOrder = 5
  end
  object ClientSocket1: TClientSocket
    Active = False
    ClientType = ctNonBlocking
    Port = 2048
    OnDisconnect = ClientSocket1Disconnect
    OnRead = ClientSocket1Read
    OnError = ClientSocket1Error
    Left = 40
    Top = 8
  end
  object ServerSocket1: TServerSocket
    Active = False
    Port = 2048
    ServerType = stNonBlocking
    OnClientConnect = ServerSocket1ClientConnect
    OnClientDisconnect = ServerSocket1ClientDisconnect
    OnClientWrite = ServerSocket1ClientWrite
    Left = 8
    Top = 8
  end
  object IBDatabase1: TIBDatabase
    DatabaseName = 'ibserver:k:\bases\test\report2.gdb'
    Params.Strings = (
      'user_name=SYSDBA'
      'password=masterkey'
      'lc_ctype=WIN1251')
    LoginPrompt = False
    DefaultTransaction = IBTransaction1
    IdleTimer = 0
    SQLDialect = 3
    TraceFlags = []
    Left = 8
    Top = 56
  end
  object IBTransaction1: TIBTransaction
    Active = False
    DefaultDatabase = IBDatabase1
    Left = 40
    Top = 56
  end
  object IBQuery1: TIBQuery
    Database = IBDatabase1
    Transaction = IBTransaction1
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT * FROM rp_testreport')
    Left = 8
    Top = 88
  end
end
